/// One authorized field resolution. Carries no credential and no grant.
public struct ResolutionRequest: Sendable {
    /// Identifies the GraphQL operation this resolution belongs to, for the
    /// provider's own correlation. It carries no authority.
    public var requestId: String
    public var resolverId: String
    /// The field's coerced arguments by name.
    public var arguments: [String: ProviderValue]
    /// The value this provider returned for the enclosing object, or nil for a
    /// root field.
    public var parent: ProviderValue?

    public init(resolverId: String, arguments: [String: ProviderValue], parent: ProviderValue?) {
        self.init(requestId: "", resolverId: resolverId, arguments: arguments, parent: parent)
    }

    public init(
        requestId: String, resolverId: String, arguments: [String: ProviderValue],
        parent: ProviderValue?
    ) {
        self.requestId = requestId
        self.resolverId = resolverId
        self.arguments = arguments
        self.parent = parent
    }
}

public enum ResolutionResult: Sendable {
    case success(ProviderValue)
    case failure(ProviderFailure)
}

/// An owned, bounded value tree. Objects are keyed by GraphQL field name. The
/// host refuses a tree that does not fit the field's GraphQL type.
public enum ProviderValue: Sendable, Equatable {
    /// Ordinary absence; an error only where the schema says non-null.
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    /// A resource reference, `koine://<provider>/<remainder>`. The host checks
    /// the envelope and reads only the provider; the remainder is the provider's.
    case reference(String)
    case list([ProviderValue])
    case object([String: ProviderValue])
}

/// A structured provider failure. The host supplies the response path and the
/// GraphQL error; the message must not carry native stack traces.
public struct ProviderFailure: Sendable, Error {
    public enum Kind: Sendable {
        /// The target is gone, of the wrong kind, or its reference remainder
        /// is not interpretable.
        case unavailable
        /// The OS operation failed or timed out.
        case failed
        /// Koine lacks the platform consent named by `permission`.
        case osPermission
        /// The provider has no resolver for the request's `resolverId`: the
        /// descriptor and the provider disagree.
        case unknownResolver
        /// An argument is well formed GraphQL but not a value of its provider-owned
        /// type, such as a provider-private scalar in a form the provider does
        /// not accept. The host reports input coercion, not a domain
        /// classification, and the provider has performed no action.
        case invalidInput
    }

    public var kind: Kind
    public var message: String
    /// The platform consent Koine lacks, such as `accessibility`. Meaningful
    /// only with `Kind.osPermission`.
    public var permission: String?

    public init(kind: Kind, message: String) {
        self.kind = kind
        self.message = message
    }

    public static func osPermission(_ permission: String, message: String) -> ProviderFailure {
        var failure = ProviderFailure(kind: .osPermission, message: message)
        failure.permission = permission
        return failure
    }
}
