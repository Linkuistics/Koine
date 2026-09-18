/// Capability names owned by the core. Providers add their own in later stages.
public enum CoreCapability {
    public static let manage = "koine:manage"
}

public enum GrantState: String, Sendable {
    case active = "ACTIVE"
    case revoked = "REVOKED"
}

/// The persisted form of a grant. It never holds the bearer secret.
public struct GrantRecord: Sendable, Equatable {
    public let id: String
    public let clientLabel: String
    public let capabilities: [String]
    public let credentialDigest: String
    public let state: GrantState

    public init(
        id: String, clientLabel: String, capabilities: [String],
        credentialDigest: String, state: GrantState
    ) {
        self.id = id
        self.clientLabel = clientLabel
        self.capabilities = capabilities
        self.credentialDigest = credentialDigest
        self.state = state
    }
}

public enum GrantStoreError: Error {
    /// Credential digests are globally unique; the caller retries with a new secret.
    case duplicateDigest
}

/// The durable grant database. Every write is an atomic, durable commit, and a
/// store that cannot be read throws: callers fail closed, never open.
public protocol GrantStore: Sendable {
    func insert(_ grant: GrantRecord) throws
    func grants() throws -> [GrantRecord]
    func grant(id: String) throws -> GrantRecord?
    /// Marks the grant revoked and returns it as committed, or nil when no
    /// grant has this ID. Revoking a revoked grant changes nothing and succeeds.
    /// It returns only after the revocation is durable.
    func revoke(id: String) throws -> GrantRecord?
}

/// Who is executing an operation. The three admission cases are distinct:
/// console authority is never a fallback for a failed HTTP authentication.
public enum Principal: Sendable {
    /// A client presenting the bearer credential of this grant.
    case grant(id: String)
    /// The embedding application's in-process management console. It holds
    /// `koine:manage` without a grant and has no serialized form.
    case localConsole
    /// No credential. Admits nothing until enrollment exists.
    case anonymous
}
