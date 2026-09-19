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

    public let provider: String
    public let version: String
    public let schemaVersion: String
    public let state: State
    public let diagnostic: String?

    public init(
        provider: String, version: String, schemaVersion: String, state: State,
        diagnostic: String?
    ) {
        self.provider = provider
        self.version = version
        self.schemaVersion = schemaVersion
        self.state = state
        self.diagnostic = diagnostic
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
            if !refusals.isEmpty {
                // A host feature the provider needs is a compatibility matter,
                // wherever it was discovered.
                state = refusals.allSatisfy { $0.reason == .unsupportedFeature }
                    ? .incompatible : .rejected
                messages = refusals.map(\.message)
            } else if let failure = await accepted.first(where: { $0.providerId == id })?
                .lifecycle.failure
            {
                state = .failed
                messages.insert(failure, at: 0)
            } else {
                state = .active
            }
            statuses.append(
                ProviderStatus(
                    provider: id, version: active.version, schemaVersion: active.schemaVersion,
                    state: state, diagnostic: messages.isEmpty ? nil : messages.joined(separator: " ")
                )
            )
        }
        return statuses.sorted { ($0.provider, $0.version) < ($1.provider, $1.version) }
    }
}
