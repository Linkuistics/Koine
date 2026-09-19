/// One authorized field resolution. Carries no credential and no grant.
public struct ResolutionRequest: Sendable {
    public var resolverId: String
    /// The field's coerced arguments by name.
    public var arguments: [String: ProviderValue]
    /// The value this provider returned for the enclosing object, or nil for a
    /// root field.
    public var parent: ProviderValue?

    public init(resolverId: String, arguments: [String: ProviderValue], parent: ProviderValue?) {
        self.resolverId = resolverId
        self.arguments = arguments
        self.parent = parent
    }
}

public enum ResolutionResult: Sendable {
    case success(ProviderValue)
    case failure(ProviderFailure)
}

/// An owned value tree. Objects are keyed by GraphQL field name.
public enum ProviderValue: Sendable, Equatable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case list([ProviderValue])
    case object([String: ProviderValue])
}

/// A structured provider failure. The host supplies the response path and the
/// GraphQL error; the message must not carry native stack traces.
public struct ProviderFailure: Sendable, Error {
    public enum Kind: Sendable {
        /// The target is gone, of the wrong kind, or not interpretable.
        case unavailable
        /// The OS operation failed or timed out.
        case failed
    }

    public var kind: Kind
    public var message: String

    public init(kind: Kind, message: String) {
        self.kind = kind
        self.message = message
    }
}
