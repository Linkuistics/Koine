/// What a field requires of the principal, by schema coordinate.
enum FieldAuthority: Sendable {
    /// Any admitted principal: an active grant or the local console.
    case admitted
    case capability(String)
}

/// A refusal or failure with the contract's machine-readable classification.
struct DomainError: Error {
    enum Kind: String { case permission, failed, unavailable }

    let kind: Kind
    let message: String
    var requiredCapability: String?

    static func capabilityDenied(_ capability: String?) -> DomainError {
        DomainError(
            kind: .permission,
            message: capability.map { "This operation requires the \($0) capability." }
                ?? "This operation requires an active grant.",
            requiredCapability: capability
        )
    }

    static func failed(_ message: String) -> DomainError {
        DomainError(kind: .failed, message: message)
    }
}

/// The single place a principal's current authority is read. Grants are looked
/// up live on every check, so nothing authenticated earlier is remembered.
struct Authority: Sendable {
    let store: any GrantStore

    /// The capabilities the principal holds now, or nil when it is not admitted.
    /// A store failure throws: the caller refuses, it never assumes authority.
    func capabilities(of principal: Principal) throws -> Set<String>? {
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
        for grant in try store.grants()
        where Credential.constantTimeEqual(grant.credentialDigest, digest) {
            match = grant
        }
        guard let match, match.state == .active else { return nil }
        return .grant(id: match.id)
    }
}
