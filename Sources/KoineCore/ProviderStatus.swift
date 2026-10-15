/// One provider bundle's state, as `koineManagement.providers` serves it. Every
/// bundle found has one, whether or not it contributes.
public struct ProviderStatus: Sendable, Equatable {
    public enum State: String, Sendable {
        case active = "ACTIVE"
        /// An honest bundle this host cannot run; none of its code was loaded.
        case incompatible = "INCOMPATIBLE"
        /// A malformed bundle or a refused contribution.
        case rejected = "REJECTED"
        /// Its contribution is published but its start failed; its fields are
        /// `unavailable`.
        case failed = "FAILED"
    }

    /// Where a candidate is installed: the application's sealed root or the
    /// user's own. Never inferred from composition position.
    public enum Origin: String, Sendable {
        case bundled = "BUNDLED"
        case perUser = "PER_USER"
    }

    /// Whether the candidate is the frozen choice for its identity.
    public enum Selection: String, Sendable {
        case selected = "SELECTED"
        case notSelected = "NOT_SELECTED"
        /// A synthetic row for a slot with nothing to run.
        case unavailable = "UNAVAILABLE"
    }

    public let provider: String
    public let version: String
    public let schemaVersion: String
    public let state: State
    public let diagnostic: String?
    /// The candidate-specific fields the selection-aware loader fills
    /// (docs/specs/machine.md, "Candidate diagnostics and schema identity"). Nil
    /// where their meaning is not known: a provider composed in a test, or a
    /// synthetic row for `candidateId` and `origin`.
    public let candidateId: String?
    public let origin: Origin?
    public let selection: Selection?
    public let selectedCandidateId: String?
    /// A stable, open diagnostic code.
    public let reason: String?

    public init(
        provider: String, version: String, schemaVersion: String, state: State,
        diagnostic: String?, candidateId: String? = nil, origin: Origin? = nil,
        selection: Selection? = nil, selectedCandidateId: String? = nil, reason: String? = nil
    ) {
        self.provider = provider
        self.version = version
        self.schemaVersion = schemaVersion
        self.state = state
        self.diagnostic = diagnostic
        self.candidateId = candidateId
        self.origin = origin
        self.selection = selection
        self.selectedCandidateId = selectedCandidateId
        self.reason = reason
    }
}

/// Reads every provider's current status: what the loader refused, what
/// composition refused, and how each accepted provider's start went.
struct ProviderStatusReport: Sendable {
    /// Bundles the host found and did not load.
    let unloaded: [ProviderStatus]
    /// Every provider offered to composition, accepted or not.
    let offered: [ActiveProvider]
    let accepted: [ProviderContribution]
    let diagnostics: ProviderDiagnostics

    func all() async -> [ProviderStatus] {
        let diagnostics = diagnostics.all
        var statuses = unloaded
        for active in offered {
            let id = active.descriptor.providerId
            let own = diagnostics.filter { $0.providerId == id }
            let refusals = own.filter { $0.reason != .resolverMismatch }
            let state: ProviderStatus.State
            var messages = own.map(\.message)
            var reason = active.candidate?.reason
            if !refusals.isEmpty {
                // A host feature the provider needs is a compatibility matter,
                // wherever it was discovered.
                state = refusals.allSatisfy { $0.reason == .unsupportedFeature }
                    ? .incompatible : .rejected
                messages = refusals.map(\.message)
                reason = refusals[0].reason.stableReason
            } else if let failure = await accepted.first(where: { $0.providerId == id })?
                .lifecycle.failure
            {
                state = .failed
                messages.insert(failure, at: 0)
                reason = "start-failed"
            } else {
                state = .active
            }
            // The earlier competing refusals stay in the diagnostic of a
            // frozen choice that later fails: its own failure takes the reason.
            if let note = active.candidate?.note { messages.append(note) }
            let candidate = active.candidate
            statuses.append(
                ProviderStatus(
                    provider: id, version: active.version, schemaVersion: active.schemaVersion,
                    state: state, diagnostic: messages.isEmpty ? nil : messages.joined(separator: " "),
                    candidateId: candidate?.candidateId, origin: candidate?.origin,
                    selection: candidate == nil ? nil : .selected,
                    selectedCandidateId: candidate?.candidateId, reason: reason
                )
            )
        }
        // Provider, then origin and candidate identifier in Unicode order, with a
        // synthetic row (no candidate) last for its provider.
        return statuses.sorted {
            ($0.provider, $0.candidateId == nil ? 1 : 0, $0.origin?.rawValue ?? "", $0.candidateId ?? "", $0.version)
                < ($1.provider, $1.candidateId == nil ? 1 : 0, $1.origin?.rawValue ?? "", $1.candidateId ?? "", $1.version)
        }
    }
}

extension ProviderDiagnostic.Reason {
    /// The stable code a later refusal of a frozen selection carries. Reserved
    /// names claimed after loading are the reserved-identity refusal.
    var stableReason: String {
        switch self {
        case .reservedName: "reserved-identity"
        case .duplicateIdentifier: "manifest-collision"
        case .missingCapabilityOwner: "missing-capability-owner"
        case .invalidIdentity: "invalid-identity"
        case .nameCollision: "name-collision"
        case .missingPrefix: "missing-prefix"
        case .invalidSDL: "invalid-sdl"
        case .foreignTypeExtension: "foreign-type-extension"
        case .missingResolver: "missing-resolver"
        case .unclassifiedField: "unclassified-field"
        case .unknownCoordinate: "unknown-coordinate"
        case .actionOutsideMutation: "action-outside-mutation"
        case .unsupportedFeature: "unsupported-feature"
        case .undeclaredFeature: "undeclared-feature"
        case .invalidCapabilityRequirement: "invalid-capability-requirement"
        case .introspectionLimit: "introspection-limit"
        case .resolverMismatch: "resolver-mismatch"
        }
    }
}
