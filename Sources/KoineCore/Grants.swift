import Foundation

/// Where the server reads the time. The embedding host may supply one; nothing
/// a client sends can. Instants that must survive a restart are stored as the
/// wall-clock values it returns.
public typealias TimeSource = @Sendable () -> Date

/// Capability names owned by the core. Each active provider adds its own
/// `<providerId>:read` and `<providerId>:control`.
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

/// Every state but `pending` is terminal. `expired` is never stored: it is what
/// a stored `pending` request is once its lifetime has passed
/// (`GrantRequestRecord.standing`).
public enum GrantRequestState: String, Sendable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case denied = "DENIED"
    case expired = "EXPIRED"

    /// Whether proof of the submitted secret reads this request's status. Once
    /// approved the grant decides instead, so a revoked grant's secret is nothing.
    var isStatusOnly: Bool { self != .approved }
}

/// The persisted form of a client's request for a grant. It holds the digest
/// of the secret the client generated, never the secret. The label and the
/// requested capabilities are as submitted and never change.
public struct GrantRequestRecord: Sendable, Equatable {
    public let id: String
    public let clientLabel: String
    public let requestedCapabilities: [String]
    public let credentialDigest: String
    public let comparisonCode: String
    public let state: GrantRequestState
    /// The grant approval created; nil until then.
    public let grantId: String?
    public let submittedAt: Date
    /// When it was approved or denied; nil while the stored state is `pending`.
    public let decidedAt: Date?

    public init(
        id: String, clientLabel: String, requestedCapabilities: [String],
        credentialDigest: String, comparisonCode: String, state: GrantRequestState,
        grantId: String?, submittedAt: Date, decidedAt: Date? = nil
    ) {
        self.id = id
        self.clientLabel = clientLabel
        self.requestedCapabilities = requestedCapabilities
        self.credentialDigest = credentialDigest
        self.comparisonCode = comparisonCode
        self.state = state
        self.grantId = grantId
        self.submittedAt = submittedAt
        self.decidedAt = decidedAt
    }

    func with(state: GrantRequestState, decidedAt: Date?) -> GrantRequestRecord {
        GrantRequestRecord(
            id: id, clientLabel: clientLabel, requestedCapabilities: requestedCapabilities,
            credentialDigest: credentialDigest, comparisonCode: comparisonCode, state: state,
            grantId: grantId, submittedAt: submittedAt, decidedAt: decidedAt
        )
    }

    /// The request as it stands at `now`: a stored `pending` request past its
    /// lifetime is `expired`, as of the end of that lifetime. Nil once a
    /// terminal request's status is past retention. The stored row stays either
    /// way, so its digest is never free again.
    func standing(at now: Date, under policy: RequestPolicy) -> GrantRequestRecord? {
        var state = state
        var terminalAt = decidedAt
        let expiry = submittedAt + policy.pendingRequestLifetime.timeInterval
        if state == .pending, now >= expiry {
            state = .expired
            terminalAt = expiry
        }
        // A terminal row always carries its instant; one that does not is kept.
        if state != .pending, let terminalAt,
            now >= terminalAt + policy.requestStatusRetention.timeInterval
        {
            return nil
        }
        return with(state: state, decidedAt: decidedAt)
    }
}

extension Duration {
    var timeInterval: TimeInterval {
        TimeInterval(components.seconds) + TimeInterval(components.attoseconds) * 1e-18
    }
}

public enum GrantStoreError: Error {
    /// Credential digests are globally unique across requests and grants,
    /// whatever their state; the caller needs a new secret.
    case duplicateDigest
}

/// The durable grant database. Every write is an atomic, durable commit, and a
/// store that cannot be read throws: callers fail closed, never open.
public protocol GrantStore: Sendable {
    /// Throws `duplicateDigest` when a grant or a request already has this digest.
    func insert(_ grant: GrantRecord) throws
    func grants() throws -> [GrantRecord]
    func grant(id: String) throws -> GrantRecord?
    /// Marks the grant revoked and returns it as committed, or nil when no
    /// grant has this ID. Revoking a revoked grant changes nothing and succeeds.
    /// It returns only after the revocation is durable.
    func revoke(id: String) throws -> GrantRecord?

    /// Throws `duplicateDigest` when a request or a grant already has this digest.
    func insertRequest(_ request: GrantRequestRecord) throws
    func requests() throws -> [GrantRequestRecord]
    func request(id: String) throws -> GrantRequestRecord?
    /// In one durable commit, marks the pending request approved and inserts
    /// `grant`, bound to it. False, with nothing written, when the request is
    /// missing or no longer pending. Throws `duplicateDigest`, with nothing
    /// written, when the digest already belongs to a grant.
    /// `at` is stored as the decision's instant. The store knows no clock and
    /// no lifetime: whether a stored `pending` request has expired is the
    /// caller's to decide before it asks.
    func approve(requestId: String, as grant: GrantRecord, at instant: Date) throws -> Bool
    /// In one durable commit, marks the pending request denied. False, with
    /// nothing written, when the request is missing or no longer pending.
    func deny(requestId: String, at instant: Date) throws -> Bool
}

/// Who is executing an operation. The admission cases are distinct: none is a
/// fallback reached by failing another, and console authority least of all.
public enum Principal: Sendable {
    /// A client presenting the bearer credential of this grant.
    case grant(id: String)
    /// The embedding application's in-process management console. It holds
    /// `koine:manage` without a grant and has no serialized form.
    case localConsole
    /// A client presenting the secret whose digest it submitted with this
    /// request, not yet approved. Status-only: it holds no capabilities and is
    /// not an admitted principal; it reads its own request and nothing else.
    case requester(requestId: String)
    /// No credential at all. Admits one thing: an operation whose only selected
    /// root action is `koineRequestGrant`.
    case anonymous
}
