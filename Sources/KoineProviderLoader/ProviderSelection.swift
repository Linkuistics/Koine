import Foundation

/// The startup calculation that freezes one choice per identity, before any
/// provider code loads (docs/specs/machine.md, "Eligibility and precedence" and
/// "Selection before execution"). It is a pure function of the discovered
/// candidates and their pre-load verdicts: it touches no file, image or clock,
/// so the native tests substitute candidate sets, orders and verdicts and run
/// the real verifier and loader around it.
///
/// Nothing here breaks a tie by path, discovery order, modification time, schema
/// version or content hash; the candidates are sorted by their opaque identity
/// only so that the notes read the same whichever order they were found in.
struct SelectionPlan {
    enum Verdict {
        /// The frozen choice. `reason` is `selected-with-refusals` when another
        /// copy of the identity, or its designated bundle, was refused.
        case selected(reason: String?, note: String?)
        case notSelected(Refusal)
    }

    /// An enabled slot with nothing to run, or whose designated bundle is missing.
    struct SyntheticRow {
        let providerId: String
        let reason: String
        let selectedCandidateId: String?
        let message: String
    }

    let verdicts: [String: Verdict]
    /// The frozen choice for each provider identifier, by candidate identity.
    let chosen: [String: String]
    let synthetics: [SyntheticRow]
}

enum ProviderSelection {
    static func plan(catalogue: ProviderCatalogue, candidates: [SelectionCandidate]) -> SelectionPlan {
        let ordered = candidates.sorted { $0.id < $1.id }
        var verdicts: [String: SelectionPlan.Verdict] = [:]
        var chosen: [String: String] = [:]
        var synthetics: [SelectionPlan.SyntheticRow] = []

        // A pre-load refusal excludes only that candidate, whatever else it claims.
        for candidate in ordered {
            if let refusal = candidate.refusal { verdicts[candidate.id] = .notSelected(refusal) }
        }

        for entry in catalogue.entries {
            guard let baseline = entry.baseline else { continue }
            let members = ordered.filter { $0.role == .slot(entry) }
            let bundle = members.first { $0.origin == .bundled && $0.isVerified }
            let present = ordered.contains {
                $0.origin == .bundled && $0.bundleName == baseline.bundleName
            }

            // Which per-user copies may replace the bundle at all.
            var pool: [SelectionCandidate] = []
            for update in members where update.origin == .perUser && update.isVerified {
                guard let release = update.release, let schema = update.schema else { continue }
                if release < baseline.release {
                    verdicts[update.id] = .notSelected(
                        .rejected(
                            ProviderReason.olderThanBundled,
                            "Release \(release) is older than the bundled baseline \(baseline.release), so it never replaces the bundle."
                        )
                    )
                } else if release == baseline.release {
                    verdicts[update.id] = .notSelected(
                        .rejected(
                            ProviderReason.equalToBundled,
                            "Release \(release) equals the bundled baseline, so it never replaces the bundle."
                        )
                    )
                } else if schema.major != baseline.schema.major || schema < baseline.schema {
                    verdicts[update.id] = .notSelected(
                        .incompatible(
                            ProviderReason.schemaIncompatible,
                            "Schema \(schema) is not compatible with the baseline's \(baseline.schema): a per-user update keeps the same schema major and a schema version at least the baseline's."
                        )
                    )
                } else {
                    pool.append(update)
                }
            }

            // The greatest release wins if it is alone. A tied group is refused
            // whole, removed, and the calculation repeats.
            var winner: SelectionCandidate?
            while let top = pool.compactMap(\.release).max() {
                let group = pool.filter { $0.release == top }
                if group.count == 1 {
                    winner = group[0]
                    break
                }
                let places = group.map(\.installed).sorted().joined(separator: ", ")
                for tied in group {
                    verdicts[tied.id] = .notSelected(
                        .rejected(
                            ProviderReason.ambiguousUpdate,
                            "Release \(top) is installed more than once (\(places)); every copy of it is refused. Remove the extra copy and restart."
                        )
                    )
                }
                pool.removeAll { $0.release == top }
            }
            let selected = winner ?? bundle

            // Valid copies the choice passed over are refused, not failed.
            for member in members
            where member.isVerified && member.id != selected?.id && verdicts[member.id] == nil {
                let running = selected.map { "release \($0.release.map(\.description) ?? "?")" } ?? "another copy"
                verdicts[member.id] = .notSelected(
                    .rejected(
                        ProviderReason.supersededCandidate,
                        "Superseded: \(running) is the frozen choice for \(entry.providerId)."
                    )
                )
            }

            // Everything else claiming this identity that was refused, for the
            // selected row's diagnostic and the missing-slot row's.
            var causes: [String] = []
            for other in ordered
            where (other.claim?.providerId == entry.providerId || other.role == .slot(entry))
                && other.id != selected?.id
            {
                guard case .notSelected(let refusal)? = verdicts[other.id],
                    refusal.reason != ProviderReason.supersededCandidate
                else { continue }
                let claim = other.claim
                causes.append(
                    "\(other.installed) (claims release \(claim?.version ?? "unknown"), schema \(claim?.schemaVersion ?? "unknown")) is refused as \(refusal.reason): \(refusal.message)"
                )
            }
            if !present {
                causes.append(
                    "The designated bundled copy \(baseline.bundleName) (release \(baseline.release), schema \(baseline.schema)) is missing from the application."
                )
            }

            if let selected {
                chosen[entry.providerId] = selected.id
                verdicts[selected.id] = .selected(
                    reason: causes.isEmpty ? nil : ProviderReason.selectedWithRefusals,
                    note: causes.isEmpty
                        ? nil
                        : "Selected release \(selected.release.map(\.description) ?? selected.claim?.version ?? "?") (\(selected.origin.rawValue)). \(causes.joined(separator: " "))"
                )
            }
            // One synthetic row at most: a missing bundle is always shown, even
            // when an update fills the slot; otherwise a slot with no choice.
            if !present {
                synthetics.append(
                    SelectionPlan.SyntheticRow(
                        providerId: entry.providerId, reason: ProviderReason.missingBundled,
                        selectedCandidateId: selected?.id,
                        message: causes.joined(separator: " ")
                            + (selected == nil
                                ? " No eligible per-user update fills \(entry.providerId), so the slot is unavailable and stays reserved. Restore the application's bundle or install an approved newer release, then restart."
                                : " Reinstall Koine to restore the baseline.")
                    )
                )
            } else if selected == nil {
                synthetics.append(
                    SelectionPlan.SyntheticRow(
                        providerId: entry.providerId, reason: ProviderReason.noEligibleCandidate,
                        selectedCandidateId: nil,
                        message: (causes.isEmpty ? "" : causes.joined(separator: " ") + " ")
                            + "No candidate for \(entry.providerId) passed verification, so the slot is unavailable and stays reserved. Fix or remove the refused copies and restart."
                    )
                )
            }
        }

        // Ordinary providers keep the ordinary duplicate refusals, among the
        // candidates that passed every pre-load check: a refused rival never
        // contests a valid provider.
        let ordinary = ordered.filter { $0.role == .ordinary && $0.isVerified }
        for candidate in ordinary {
            guard let claim = candidate.claim else { continue }
            let rivals = ordinary.filter {
                guard $0.id != candidate.id, let other = $0.claim else { return false }
                return other.providerId == claim.providerId || other.graphQLPrefix == claim.graphQLPrefix
            }
            if rivals.isEmpty {
                chosen[claim.providerId] = candidate.id
                verdicts[candidate.id] = .selected(reason: nil, note: nil)
            } else {
                verdicts[candidate.id] = .notSelected(
                    .rejected(
                        ProviderReason.manifestCollision,
                        "Another eligible provider (\(rivals.map(\.installed).sorted().joined(separator: ", "))) claims this identifier or prefix; both are refused."
                    )
                )
            }
        }

        return SelectionPlan(verdicts: verdicts, chosen: chosen, synthetics: synthetics)
    }
}
