import Foundation

/// What a field requires of the principal, by schema coordinate.
enum FieldAuthority: Sendable {
    /// Any admitted principal: an active grant or the local console.
    case admitted
    case capability(String)
    /// An admitted principal, or the status-only principal of a request that
    /// is still pending. Only `koineGrantRequest` and what it returns use it.
    case requestStatus
    /// The anonymous principal and no other. The engine has already held its
    /// operation to the single `koineRequestGrant` action.
    case anonymousEnrollment
}

/// A refusal or failure with the contract's machine-readable classification.
struct DomainError: Error {
    enum Kind: String {
        case permission, failed, unavailable
        case unknownProvider = "unknown-provider"
    }

    let kind: Kind
    let message: String
    var requiredCapability: String?
    /// The platform consent Koine lacks; makes a permission error an
    /// `os-permission` one.
    var osPermission: String?

    static func capabilityDenied(_ capability: String?) -> DomainError {
        DomainError(
            kind: .permission,
            message: capability.map { "This operation requires the \($0) capability." }
                ?? "This operation requires an active grant.",
            requiredCapability: capability
        )
    }

    static let enrollmentIsAnonymous = DomainError(
        kind: .permission,
        message: "koineRequestGrant is anonymous enrollment: send it without credentials, "
            + "as the only root action of its operation."
    )

    static func osPermissionMissing(_ permission: String, message: String) -> DomainError {
        DomainError(kind: .permission, message: message, osPermission: permission)
    }

    /// Echoes the reference the caller supplied, which discloses nothing.
    static func unknownProvider(_ reference: String) -> DomainError {
        DomainError(kind: .unknownProvider, message: "No provider is registered for \(reference).")
    }

    static func unavailable(_ message: String) -> DomainError {
        DomainError(kind: .unavailable, message: message)
    }

    static func failed(_ message: String) -> DomainError {
        DomainError(kind: .failed, message: message)
    }
}

/// A provider refused an argument as no value of its own type. It is input
/// coercion the host could not perform itself, so the error carries a path and
/// no domain classification (docs/specs/machine.md, "Errors and partial data").
struct InputCoercionError: Error {
    let message: String
}

/// The single place a principal's current authority is read, and the single
/// place it is withdrawn. Grants are looked up live on every check, so nothing
/// authenticated earlier is remembered.
///
/// This is the serialized authority boundary of docs/specs/machine.md,
/// "Mutation preflight and revocation": admission checks and the revocation
/// commit take one lock, so they are totally ordered. A check that precedes a
/// revocation admits an action that may finish; one that follows it refuses.
final class Authority: Sendable {
    private let store: any GrantStore
    private let boundary = NSLock()

    init(store: any GrantStore) { self.store = store }

    /// Commits the revocation durably, inside the boundary, before returning.
    /// Nil when no grant has this ID. A store failure throws and revokes nothing.
    func revoke(grantId: String) throws -> GrantRecord? {
        try boundary.withLock { try store.revoke(id: grantId) }
    }

    /// Approval is an authority change, so it is ordered against every
    /// admission like revocation. The request and the grant change in one
    /// durable commit; every refusal leaves both untouched.
    func approve(requestId: String, capabilities: [String]) throws -> GrantRecord {
        try boundary.withLock {
            let request: GrantRequestRecord?
            do { request = try store.request(id: requestId) } catch {
                throw DomainError.failed("The grant store is unavailable.")
            }
            guard let request else { throw DomainError.unavailable("No request has this ID.") }
            guard request.state == .pending else {
                throw DomainError.failed("This request has already been decided.")
            }
            let outside = capabilities.filter { !request.requestedCapabilities.contains($0) }
            guard outside.isEmpty else {
                throw DomainError.failed(
                    "Not among the requested capabilities: \(outside.joined(separator: ", "))."
                )
            }
            let grant = GrantRecord(
                id: UUID().uuidString.lowercased(), clientLabel: request.clientLabel,
                capabilities: Array(Set(capabilities)).sorted(),
                credentialDigest: request.credentialDigest, state: .active
            )
            do {
                guard try store.approve(requestId: requestId, as: grant) else {
                    throw DomainError.failed("This request has already been decided.")
                }
            } catch GrantStoreError.duplicateDigest {
                throw DomainError.failed("This request's credential already belongs to a grant.")
            } catch let refusal as DomainError {
                throw refusal
            } catch {
                throw DomainError.failed("The approval could not be stored.")
            }
            return grant
        }
    }

    /// Whether the engine executes anything for this principal. An anonymous
    /// principal is admitted here and held to its one operation by the engine.
    func admits(_ principal: Principal) throws -> Bool {
        try boundary.withLock {
            switch principal {
            case .anonymous: return true
            case .requester(let id): return try store.request(id: id)?.state == .pending
            case .grant, .localConsole: return try currentCapabilities(of: principal) != nil
            }
        }
    }

    /// The capabilities the principal holds now, or nil when it is not admitted.
    /// A store failure throws: the caller refuses, it never assumes authority.
    func capabilities(of principal: Principal) throws -> Set<String>? {
        try boundary.withLock { try currentCapabilities(of: principal) }
    }

    private func currentCapabilities(of principal: Principal) throws -> Set<String>? {
        switch principal {
        case .grant(let id):
            guard let grant = try store.grant(id: id), grant.state == .active else { return nil }
            return Set(grant.capabilities)
        case .localConsole:
            return [CoreCapability.manage]
        case .requester, .anonymous:
            // Not an empty set: `.admitted` must refuse them too.
            return nil
        }
    }

    func check(_ requirement: FieldAuthority, for principal: Principal) throws {
        let held: Set<String>?
        do { held = try capabilities(of: principal) } catch {
            throw DomainError.failed("The grant store is unavailable.")
        }
        switch requirement {
        case .anonymousEnrollment:
            guard case .anonymous = principal else { throw DomainError.enrollmentIsAnonymous }
        case .requestStatus:
            if case .requester = principal {
                let pending: Bool
                do { pending = try admits(principal) } catch {
                    throw DomainError.failed("The grant store is unavailable.")
                }
                guard pending else { throw DomainError.capabilityDenied(nil) }
            } else {
                guard held != nil else { throw DomainError.capabilityDenied(nil) }
            }
        case .admitted:
            guard held != nil else { throw DomainError.capabilityDenied(nil) }
        case .capability(let name):
            guard let held, held.contains(name) else { throw DomainError.capabilityDenied(name) }
        }
    }

    /// Resolves a presented bearer credential to its active grant, or to the
    /// status-only principal of the pending request it was submitted with.
    /// Every stored digest is compared, in constant time and without an early
    /// exit. A grant with this digest decides alone, whatever its state: a
    /// revoked grant's secret is nothing, never a requester again.
    func authenticate(bearer: String) throws -> Principal? {
        guard let digest = Credential.digest(ofPresented: bearer) else { return nil }
        let (grants, requests) = try boundary.withLock { (try store.grants(), try store.requests()) }
        var grant: GrantRecord?
        for candidate in grants
        where Credential.constantTimeEqual(candidate.credentialDigest, digest) {
            grant = candidate
        }
        var request: GrantRequestRecord?
        for candidate in requests
        where Credential.constantTimeEqual(candidate.credentialDigest, digest) {
            request = candidate
        }
        if let grant { return grant.state == .active ? .grant(id: grant.id) : nil }
        guard let request, request.state == .pending else { return nil }
        return .requester(requestId: request.id)
    }
}
