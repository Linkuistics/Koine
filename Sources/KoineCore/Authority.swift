import Foundation

/// What a field requires of the principal, by schema coordinate.
enum FieldAuthority: Sendable {
    /// Any admitted principal: an active grant or the local console.
    case admitted
    case capability(String)
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
        case .anonymous:
            return nil
        }
    }

    func check(_ requirement: FieldAuthority, for principal: Principal) throws {
        let held: Set<String>?
        do { held = try capabilities(of: principal) } catch {
            throw DomainError.failed("The grant store is unavailable.")
        }
        switch requirement {
        case .admitted:
            guard held != nil else { throw DomainError.capabilityDenied(nil) }
        case .capability(let name):
            guard let held, held.contains(name) else { throw DomainError.capabilityDenied(name) }
        }
    }

    /// Resolves a presented bearer credential to its active grant. Every stored
    /// digest is compared, in constant time and without an early exit.
    func authenticate(bearer: String) throws -> Principal? {
        guard let digest = Credential.digest(ofPresented: bearer) else { return nil }
        var match: GrantRecord?
        for grant in try boundary.withLock({ try store.grants() })
        where Credential.constantTimeEqual(grant.credentialDigest, digest) {
            match = grant
        }
        guard let match, match.state == .active else { return nil }
        return .grant(id: match.id)
    }
}
