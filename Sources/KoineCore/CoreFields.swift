import Foundation
import GraphQL

/// Resolver and authority registrations for the core's own fields, keyed by
/// schema coordinate. Object values travel as dictionaries keyed by field name.
struct CoreFields: Sendable {
    let store: any GrantStore
    let authority: Authority
    let instanceId: String
    let schemaDigest: String
    let providerStatuses: @Sendable () async -> [ProviderStatus]
    let osPermissions: OSPermissionSource
    /// The read and control capabilities of every active provider.
    var providerCapabilities: [String] = []

    typealias Object = [String: any Sendable]

    var registrations: [String: FieldRegistration] {
        var all: [String: FieldRegistration] = [
            "Query.koine": FieldRegistration(authority: .admitted) { input in
                try koine(for: input.principal)
            },
            "Mutation.koineCreateGrant": FieldRegistration(
                authority: .capability(CoreCapability.manage)
            ) { input in
                try createGrant(input.arguments["input"])
            },
            "Mutation.koineRequestGrant": FieldRegistration(authority: .anonymousEnrollment) {
                input in try requestGrant(input.arguments["input"])
            },
            "Query.koineGrantRequest": FieldRegistration(authority: .requestStatus) { input in
                try ownRequest(of: input.principal)
            },
            "Mutation.koineApproveGrantRequest": FieldRegistration(
                authority: .capability(CoreCapability.manage)
            ) { input in
                // Through the authority boundary, like revocation.
                object(
                    try authority.approve(
                        requestId: input.arguments["requestId"].string ?? "",
                        capabilities: (input.arguments["capabilities"].array ?? [])
                            .compactMap(\.string)
                    )
                )
            },
            "Query.koineManagement": FieldRegistration(
                authority: .capability(CoreCapability.manage)
            ) { _ in
                [
                    "requests": try readStore { try store.requests().map(object) },
                    "grants": try readStore { try store.grants() }.map(object),
                    "providers": await providerStatuses().map(object),
                    "osPermissions": osPermissions().map(object),
                ] as Object
            },
            "Mutation.koineRevokeGrant": FieldRegistration(
                authority: .capability(CoreCapability.manage)
            ) { input in
                try revokeGrant(id: input.arguments["grantId"].string ?? "")
            },
        ]
        // Output fields read their parent object. Their authority is that of
        // the field that produced the parent, rechecked per field.
        let outputs: [(String, [String], FieldAuthority)] = [
            ("Koine", ["contractVersion", "instanceId", "schemaDigest", "ownGrant",
                       "availableCapabilities"], .admitted),
            ("KoineGrant", ["grantId", "clientLabel", "capabilities", "state"], .admitted),
            ("KoineCreatedGrant", ["grant", "credential"], .capability(CoreCapability.manage)),
            ("KoineGrantRequestReceipt", ["requestId", "comparisonCode"], .anonymousEnrollment),
            ("KoineGrantRequest", ["requestId", "clientLabel", "comparisonCode",
                                   "requestedCapabilities", "state", "grant"], .requestStatus),
            ("KoineManagement", ["requests", "grants", "providers", "osPermissions"],
             .capability(CoreCapability.manage)),
            ("KoineProviderStatus", ["provider", "version", "schemaVersion", "state", "diagnostic"],
             .capability(CoreCapability.manage)),
            ("KoineOSPermission", ["permission", "owner", "granted"],
             .capability(CoreCapability.manage)),
        ]
        for (type, names, authority) in outputs {
            for name in names {
                all["\(type).\(name)"] = FieldRegistration(authority: authority) { input in
                    (input.parent as? Object)?[name]
                }
            }
        }
        return all
    }

    private var availableCapabilities: [String] { [CoreCapability.manage] + providerCapabilities }

    private func koine(for principal: Principal) throws -> Object {
        var ownGrant: Object?
        if case .grant(let id) = principal {
            ownGrant = try readStore { try store.grant(id: id) }.map(object)
        }
        return [
            "contractVersion": koineContractVersion,
            "instanceId": instanceId,
            "schemaDigest": schemaDigest,
            "ownGrant": ownGrant,
            "availableCapabilities": availableCapabilities,
        ]
    }

    private func createGrant(_ input: Map) throws -> Object {
        let label = input["clientLabel"].string ?? ""
        let requested = (input["capabilities"].array ?? []).compactMap(\.string)
        let unknown = requested.filter { !availableCapabilities.contains($0) }
        guard unknown.isEmpty else {
            throw DomainError.failed("Unknown capabilities: \(unknown.joined(separator: ", ")).")
        }
        let capabilities = Array(Set(requested)).sorted()

        // A digest collision is retried with a fresh secret before committing.
        for _ in 0..<3 {
            let credential = Credential.generate()
            let grant = GrantRecord(
                id: UUID().uuidString.lowercased(), clientLabel: label,
                capabilities: capabilities, credentialDigest: credential.digest, state: .active
            )
            do {
                try store.insert(grant)
            } catch GrantStoreError.duplicateDigest {
                continue
            } catch {
                throw DomainError.failed("The grant could not be stored.")
            }
            return ["grant": object(grant), "credential": credential.encoded]
        }
        throw DomainError.failed("The grant could not be stored.")
    }

    /// Stores the request as submitted. It confers nothing: the digest names a
    /// status-only principal until a manager approves it.
    private func requestGrant(_ input: Map) throws -> Object {
        let digest = input["credentialDigest"].string ?? ""
        guard Credential.isCanonicalDigest(digest) else {
            throw DomainError.failed("credentialDigest must be 64 lower-case hexadecimal digits.")
        }
        let requested = (input["capabilities"].array ?? []).compactMap(\.string)
        let unknown = requested.filter { !availableCapabilities.contains($0) }
        guard unknown.isEmpty else {
            throw DomainError.failed("Unknown capabilities: \(unknown.joined(separator: ", ")).")
        }
        let request = GrantRequestRecord(
            id: UUID().uuidString.lowercased(), clientLabel: input["clientLabel"].string ?? "",
            requestedCapabilities: requested, credentialDigest: digest,
            comparisonCode: Self.comparisonCode(), state: .pending, grantId: nil
        )
        do { try store.insertRequest(request) } catch {
            throw DomainError.failed("The request could not be stored.")
        }
        return ["requestId": request.id, "comparisonCode": request.comparisonCode]
    }

    /// Random, so it discloses nothing of the digest; short and free of
    /// look-alike characters, so two people can compare it by eye.
    private static func comparisonCode() -> String {
        let alphabet = Array("ABCDEFGHJKMNPQRSTVWXYZ23456789")
        var generator = SystemRandomNumberGenerator()
        let half = { String((0..<4).map { _ in alphabet.randomElement(using: &generator)! }) }
        return "\(half())-\(half())"
    }

    /// The caller's own request: the one its secret was submitted with, or the
    /// one its grant came from. Null for a grant no request produced.
    private func ownRequest(of principal: Principal) throws -> Object? {
        try readStore {
            switch principal {
            case .requester(let id): return try store.request(id: id).map(object)
            case .grant(let id): return try store.requests().first { $0.grantId == id }.map(object)
            case .localConsole, .anonymous: return nil
            }
        }
    }

    /// Revocation goes through the authority boundary, never straight to the
    /// store, so it is ordered against every action admission.
    private func revokeGrant(id: String) throws -> Object {
        let revoked: GrantRecord?
        do { revoked = try authority.revoke(grantId: id) } catch {
            throw DomainError.failed("The revocation could not be stored.")
        }
        guard let revoked else { throw DomainError.unavailable("No grant has this ID.") }
        return object(revoked)
    }

    private func readStore<T>(_ body: () throws -> T) throws -> T {
        do { return try body() } catch {
            throw DomainError.failed("The grant store is unavailable.")
        }
    }

    private func object(_ status: ProviderStatus) -> Object {
        [
            "provider": status.provider,
            "version": status.version,
            "schemaVersion": status.schemaVersion,
            "state": status.state.rawValue,
            "diagnostic": status.diagnostic,
        ]
    }

    private func object(_ status: OSPermissionStatus) -> Object {
        ["permission": status.permission, "owner": status.owner, "granted": status.granted]
    }

    private func object(_ request: GrantRequestRecord) throws -> Object {
        [
            "requestId": request.id,
            "clientLabel": request.clientLabel,
            "comparisonCode": request.comparisonCode,
            "requestedCapabilities": request.requestedCapabilities,
            "state": request.state.rawValue,
            "grant": try request.grantId.flatMap { try store.grant(id: $0) }.map(object),
        ]
    }

    private func object(_ grant: GrantRecord) -> Object {
        [
            "grantId": grant.id,
            "clientLabel": grant.clientLabel,
            "capabilities": grant.capabilities,
            "state": grant.state.rawValue,
        ]
    }
}
