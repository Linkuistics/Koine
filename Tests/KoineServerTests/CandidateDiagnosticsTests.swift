import Foundation
import KoineCore
import KoineProviderAPI
import Testing

@testable import KoineProviderLoader
@testable import KoineServer

/// `KoineManagement.providers` as a management client reads it over the public
/// interface: every candidate and synthetic row, with the additive fields
/// (docs/specs/machine.md, "Candidate diagnostics and schema identity").
///
/// **G** tests over substituted candidate reports: the real staging,
/// verification and selection run over copies of sealed bundles, and the private
/// seam stands in for `dlopen`, so no image of the `Sl` family is ever mapped in
/// this process. What they establish is what the loader's reports become at the
/// GraphQL seam; native loading is N's.
@Suite struct CandidateDiagnosticsTests {
    /// One row as a client sees it.
    struct Row: Equatable {
        let provider: String
        let version: String
        let schemaVersion: String
        let state: String
        let diagnostic: String?
        let candidateId: String?
        let origin: String?
        let selection: String?
        let selectedCandidateId: String?
        let reason: String?
    }

    static let query = """
        { koineManagement { providers {
          provider version schemaVersion state diagnostic
          candidateId origin selection selectedCandidateId reason
        } } }
        """

    /// What a substituted load hands the core: a well-formed contribution for
    /// the candidate's identity, so composition and publication run for real.
    struct Substitute: Sendable {
        var failingLoads: Set<String> = []
        var failingStarts: Set<String> = []
        /// Contributions that also need another provider's read capability.
        var needing: [String: String] = [:]

        func seam(_ seam: inout ProviderLoader.Seam) {
            let substitute = self
            seam.load = { attempt in
                if substitute.failingLoads.contains(attempt.version) {
                    throw ProviderLoader.loadRefusal("built to fail its load")
                }
                let prefix = attempt.providerId == "fixtureqz" ? "FixtureQz" : "FixtureSl"
                let field = "fixture\(prefix.dropFirst(7))Value"
                let coordinate = "Query.\(field)"
                let stub = Stub(
                    id: attempt.providerId, prefix: prefix,
                    sdl: "extend type Query { \"read.\" \(field): String }",
                    fields: [(coordinate, .read)],
                    additional: substitute.needing[attempt.providerId].map {
                        [coordinate: [ProviderCapabilityRequirement(providerId: $0, kind: .read)]]
                    } ?? [:]
                )
                if substitute.failingStarts.contains(attempt.version) {
                    return LoadedProvider(
                        descriptor: stub.active.descriptor, provider: FailingStart())
                }
                return LoadedProvider(descriptor: stub.active.descriptor, provider: stub.provider)
            }
        }
    }

    final class FailingStart: Provider, @unchecked Sendable {
        func start() async throws { throw StartFailure() }
        func stop() async {}
        func resolve(_ request: ResolutionRequest) async -> ResolutionResult { .success(.null) }
    }

    struct StartFailure: Error, CustomStringConvertible {
        var description: String { "built to fail its start" }
    }

    static func harness(
        _ installation: ProviderSelectionTests.Installation,
        catalogue: Result<ProviderCatalogue, ProviderCatalogue.Invalid>? = nil,
        substitute: Substitute = Substitute(), providers: [ActiveProvider] = [],
        hostTeam: String?? = .none
    ) async throws -> Harness {
        let catalogue = try catalogue ?? .success(ProviderSelectionTests.catalogue(qz: true))
        let team = try hostTeam ?? ProviderSelectionTests.team()
        return try await Harness(
            providerRoots: [installation.userRoot],
            bundledRoots: [.bundled(installation.bundledRoot)], providers: providers,
            catalogue: catalogue, hostTeam: team, loaderSeam: { substitute.seam(&$0) }
        )
    }

    static func rows(_ harness: Harness, authorization: String? = nil) async throws -> [Row] {
        let credential: String
        if let authorization { credential = authorization } else {
            credential = try await harness.consoleGrant(
                label: "manager", capabilities: ["koine:manage"])
        }
        let reply = try await harness.post(query, authorization: "Bearer \(credential)")
        #expect(reply.errors.isEmpty, Comment(rawValue: "\(reply.errors)"))
        let management = try #require(reply.data?["koineManagement"] as? [String: Any])
        let rows = try #require(management["providers"] as? [[String: Any]])
        return rows.map { row in
            func text(_ key: String) -> String? { row[key] as? String }
            return Row(
                provider: text("provider") ?? "", version: text("version") ?? "",
                schemaVersion: text("schemaVersion") ?? "", state: text("state") ?? "",
                diagnostic: text("diagnostic"), candidateId: text("candidateId"),
                origin: text("origin"), selection: text("selection"),
                selectedCandidateId: text("selectedCandidateId"), reason: text("reason")
            )
        }
    }

    // MARK: The published rows

    @Test func aSelectedUpdateAndTheCopyItSupersededAreBothPublished() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()
        try installation.install("r1.5.0", as: "update")
        let harness = try await Self.harness(installation)

        let rows = try await Self.rows(harness).filter { $0.provider == "fixturesl" }

        // By provider, then origin (BUNDLED before PER_USER), then candidate.
        #expect(rows.map(\.origin) == ["BUNDLED", "PER_USER"])
        let bundled = rows[0]
        let update = rows[1]
        #expect(update.state == "ACTIVE" && update.selection == "SELECTED")
        #expect(update.version == "1.5.0")
        // A healthy selection with nothing competing has no reason at all, and
        // names itself.
        #expect(update.reason == nil)
        #expect(update.candidateId != nil && update.selectedCandidateId == update.candidateId)
        #expect(bundled.state == "REJECTED" && bundled.selection == "NOT_SELECTED")
        #expect(bundled.reason == ProviderReason.supersededCandidate)
        #expect(bundled.selectedCandidateId == update.candidateId)
        #expect(bundled.candidateId != nil && bundled.candidateId != update.candidateId)
        // The refused copy sits beside the running version, and says why.
        #expect(bundled.diagnostic?.contains("Superseded") == true)
        await harness.stop()
    }

    @Test func aSyntheticMissingBundledRowSurvivesAnUpdateThatFillsTheSlot() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.install("r1.5.0", as: "update")
        let harness = try await Self.harness(installation)

        let rows = try await Self.rows(harness).filter { $0.provider == "fixturesl" }

        #expect(rows.count == 2)
        let update = rows[0]
        let missing = rows[1]  // synthetic rows sort last for their provider
        #expect(update.state == "ACTIVE" && update.selection == "SELECTED")
        #expect(update.reason == ProviderReason.selectedWithRefusals)
        #expect(update.diagnostic?.isEmpty == false)
        #expect(missing.candidateId == nil && missing.origin == nil)
        #expect(missing.state == "REJECTED" && missing.selection == "UNAVAILABLE")
        #expect(missing.reason == ProviderReason.missingBundled)
        #expect(missing.selectedCandidateId == update.candidateId)
        // Unknown actual versions, and the expected baseline in the diagnostic.
        #expect(missing.version == "unknown" && missing.schemaVersion == "unknown")
        #expect(missing.diagnostic?.contains("1.0.0") == true)
        await harness.stop()
    }

    @Test func anEmptyInstallationHasOneMissingBundledRowAndNoChoice() async throws {
        let installation = try ProviderSelectionTests.Installation()
        let harness = try await Self.harness(
            installation, catalogue: .success(try ProviderSelectionTests.catalogue()))

        let rows = try await Self.rows(harness)

        // The reserved-only identity has no bundle claiming it and no row.
        #expect(rows.map(\.provider) == ["fixturesl"])
        let only = rows[0]
        #expect(only.candidateId == nil && only.origin == nil)
        #expect(only.state == "REJECTED" && only.selection == "UNAVAILABLE")
        #expect(only.reason == ProviderReason.missingBundled)
        #expect(only.selectedCandidateId == nil)
        await harness.stop()
    }

    /// A bundle that is present but not admitted leaves the slot with no choice:
    /// one `no-eligible-candidate` row beside the refused copies, never two
    /// synthetic rows for the slot, and every cause kept in its own row.
    @Test func aPresentButRefusedBundleLeavesOneNoEligibleCandidateRow() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "update")
        let harness = try await Self.harness(installation, hostTeam: .some(nil))

        let rows = try await Self.rows(harness).filter { $0.provider == "fixturesl" }

        #expect(rows.count == 3)
        let synthetic = try #require(rows.last)
        #expect(synthetic.candidateId == nil && synthetic.origin == nil)
        #expect(synthetic.state == "REJECTED" && synthetic.selection == "UNAVAILABLE")
        #expect(synthetic.reason == ProviderReason.noEligibleCandidate)
        #expect(synthetic.selectedCandidateId == nil)
        for refused in rows.dropLast() {
            #expect(refused.reason == ProviderReason.hostTeamUnavailable)
            #expect(refused.state == "REJECTED" && refused.selection == "NOT_SELECTED")
            #expect(refused.selectedCandidateId == nil && refused.candidateId != nil)
        }
        #expect(rows.dropLast().map(\.origin) == ["BUNDLED", "PER_USER"])
        await harness.stop()
    }

    @Test func aCatalogueFailureIsOneUnknownRowThatIsNotAProviderNamedUnknown() async throws {
        let installation = try ProviderSelectionTests.Installation()
        // A real provider whose identifier is `unknown` is valid, and composes.
        let real = Stub.good("unknown")
        let harness = try await Self.harness(
            installation, catalogue: .failure(ProviderCatalogue.Invalid(reason: "Two identities overlap.")),
            providers: [real.active])

        let rows = try await Self.rows(harness)

        #expect(rows.map(\.provider) == ["(unknown)", "unknown"])
        let synthetic = rows[0]
        #expect(synthetic.state == "REJECTED" && synthetic.selection == "UNAVAILABLE")
        #expect(synthetic.reason == ProviderReason.catalogueInvalid)
        #expect(synthetic.version == "unknown" && synthetic.schemaVersion == "unknown")
        #expect(synthetic.candidateId == nil && synthetic.origin == nil)
        #expect(synthetic.diagnostic?.contains("Two identities overlap.") == true)
        // The real provider is a different row, composed in the test: the candidate
        // fields are unknown for it, not invented.
        let composed = rows[1]
        #expect(composed.state == "ACTIVE" && composed.candidateId == nil && composed.selection == nil)
        await harness.stop()
    }

    // MARK: Refusals

    @Test func aTiedGroupIsNotSelectedAndALowerChoiceNamesItsRefusals() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "first")
        try installation.install("r2.0.0", as: "second")
        try installation.install("r1.5.0", as: "lower")
        let harness = try await Self.harness(installation)

        let rows = try await Self.rows(harness).filter { $0.provider == "fixturesl" }

        let chosen = try #require(rows.first { $0.selection == "SELECTED" })
        #expect(chosen.version == "1.5.0" && chosen.state == "ACTIVE")
        #expect(chosen.reason == ProviderReason.selectedWithRefusals)
        let tied = rows.filter { $0.reason == ProviderReason.ambiguousUpdate }
        #expect(tied.count == 2)
        for row in tied {
            #expect(row.state == "REJECTED" && row.selection == "NOT_SELECTED")
            #expect(row.origin == "PER_USER" && row.selectedCandidateId == chosen.candidateId)
        }
        #expect(rows.count == 4)
        await harness.stop()
    }

    @Test func aRefusedUpdateKeepsItsClassAndItsStableReason() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()
        try installation.install("r2.0.0-no-feature", as: "unmarked")
        let harness = try await Self.harness(installation)

        let rows = try await Self.rows(harness).filter { $0.provider == "fixturesl" }

        let refused = try #require(rows.first { $0.origin == "PER_USER" })
        #expect(refused.state == "INCOMPATIBLE" && refused.selection == "NOT_SELECTED")
        #expect(refused.reason == ProviderReason.selectionFeatureRequired)
        let running = try #require(rows.first { $0.origin == "BUNDLED" })
        #expect(running.state == "ACTIVE" && running.selection == "SELECTED")
        // The refusal is not hidden behind a healthy row: the running version's
        // reason and diagnostic both say a refusal exists.
        #expect(running.reason == ProviderReason.selectedWithRefusals)
        #expect(running.diagnostic?.contains("first-party-selection-v1") == true)
        #expect(refused.selectedCandidateId == running.candidateId)
        await harness.stop()
    }

    @Test func aFrozenChoiceWhoseLoadFailsStaysSelectedAndTakesItsOwnReason() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()
        try installation.install("r1.5.0", as: "update")
        let harness = try await Self.harness(
            installation, substitute: Substitute(failingLoads: ["1.5.0"]))

        let rows = try await Self.rows(harness).filter { $0.provider == "fixturesl" }

        // Nothing is retried: the bundled copy did not become the choice.
        let failed = try #require(rows.first { $0.origin == "PER_USER" })
        #expect(failed.state == "REJECTED" && failed.selection == "SELECTED")
        #expect(failed.reason == ProviderReason.loadFailed)
        #expect(failed.selectedCandidateId == failed.candidateId)
        let bundled = try #require(rows.first { $0.origin == "BUNDLED" })
        #expect(bundled.selection == "NOT_SELECTED" && bundled.state == "REJECTED")
        #expect(bundled.selectedCandidateId == failed.candidateId)
        await harness.stop()
    }

    @Test func aSelectedProviderWhoseStartFailsIsFailedAndStillSelected() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()
        let harness = try await Self.harness(
            installation, substitute: Substitute(failingStarts: ["1.0.0"]))

        let row = try #require(
            try await Self.rows(harness).first { $0.provider == "fixturesl" })

        #expect(row.state == "FAILED" && row.selection == "SELECTED")
        #expect(row.reason == "start-failed")
        #expect(row.selectedCandidateId == row.candidateId && row.candidateId != nil)
        #expect(row.diagnostic?.contains("built to fail its start") == true)
        await harness.stop()
    }

    @Test func theMissingCapabilityOwnerCascadeIsReportedOnTheContributionItRemoved() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()  // fixturesl needs fixtureqz, which is not installed
        let harness = try await Self.harness(
            installation, catalogue: .success(try ProviderSelectionTests.catalogue(qz: true)),
            substitute: Substitute(needing: ["fixturesl": "fixtureqz"]))

        let rows = try await Self.rows(harness)

        let removed = try #require(rows.first { $0.provider == "fixturesl" })
        #expect(removed.state == "REJECTED")
        #expect(removed.reason == ProviderReason.missingCapabilityOwner)
        // A frozen choice later refused by the core remains selected, on its own row.
        #expect(removed.selection == "SELECTED" && removed.selectedCandidateId == removed.candidateId)
        #expect(removed.diagnostic?.contains("fixtureqz") == true)
        // The owner's own slot is shown as empty, not silently dropped.
        let owner = try #require(rows.first { $0.provider == "fixtureqz" })
        #expect(owner.reason == ProviderReason.missingBundled && owner.selection == "UNAVAILABLE")
        await harness.stop()
    }

    // MARK: Authority and schema

    @Test func theCandidateFieldsAreDeniedWithoutManageAuthority() async throws {
        let installation = try ProviderSelectionTests.Installation()
        try installation.bundle()
        let harness = try await Self.harness(installation)
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])

        let reply = try await harness.post(Self.query, authorization: "Bearer \(credential)")

        #expect(!reply.errors.isEmpty)
        let management = reply.data?["koineManagement"]
        #expect(management == nil || management is NSNull)
        // Nothing of a location or candidate leaks into the refusal.
        let text = String(decoding: try JSONSerialization.data(withJSONObject: reply.json), as: UTF8.self)
        #expect(!text.contains(installation.bundledRoot.path))
        #expect(!text.contains("FixtureSl"))
        await harness.stop()
    }

    @Test func introspectionShowsTheAdditiveFieldsAsNullableAndTheOldOnesUnchanged() async throws {
        let installation = try ProviderSelectionTests.Installation()
        let harness = try await Self.harness(
            installation, catalogue: .success(try ProviderSelectionTests.catalogue()))
        let credential = try await harness.consoleGrant(label: "tooling", capabilities: [])

        let reply = try await harness.post(
            """
            { status: __type(name: "KoineProviderStatus") {
                fields { name type { kind name ofType { kind name } } } }
              origin: __type(name: "KoineProviderOrigin") { enumValues { name } }
              selection: __type(name: "KoineProviderSelection") { enumValues { name } }
              state: __type(name: "KoineProviderState") { enumValues { name } } }
            """, authorization: "Bearer \(credential)")
        #expect(reply.errors.isEmpty)
        let data = try #require(reply.data)

        let fields = try #require((data["status"] as? [String: Any])?["fields"] as? [[String: Any]])
        func kind(_ field: [String: Any]) -> String {
            ((field["type"] as? [String: Any])?["kind"] as? String) ?? ""
        }
        let byName = Dictionary(uniqueKeysWithValues: fields.map { ($0["name"] as! String, kind($0)) })
        // Introspection sorts fields; declared order is the digest's.
        #expect(Set(fields.map { $0["name"] as! String }) == [
            "provider", "version", "schemaVersion", "state", "diagnostic",
            "candidateId", "origin", "selection", "selectedCandidateId", "reason",
        ])
        for original in ["provider", "version", "schemaVersion", "state"] {
            #expect(byName[original] == "NON_NULL")
        }
        for added in ["diagnostic", "candidateId", "origin", "selection", "selectedCandidateId", "reason"] {
            #expect(byName[added] != "NON_NULL", "\(added) must be nullable")
        }
        func values(_ key: String) -> [String] {
            ((data[key] as? [String: Any])?["enumValues"] as? [[String: Any]])?
                .compactMap { $0["name"] as? String } ?? []
        }
        #expect(values("origin") == ["BUNDLED", "PER_USER"])
        #expect(values("selection") == ["SELECTED", "NOT_SELECTED", "UNAVAILABLE"])
        #expect(values("state") == ["ACTIVE", "INCOMPATIBLE", "REJECTED", "FAILED"])
        await harness.stop()
    }
}
