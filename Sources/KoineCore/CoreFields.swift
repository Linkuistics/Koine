import Foundation
import GraphQL

/// Resolver and authority registrations for the core's own fields, keyed by
/// schema coordinate. Object values travel as dictionaries keyed by field name.
struct CoreFields: Sendable {
    let store: any GrantStore
    let instanceId: String
    let schemaDigest: String

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
        ]
        // Output fields read their parent object. Their authority is that of
        // the field that produced the parent, rechecked per field.
        let outputs: [(String, [String], FieldAuthority)] = [
            ("Koine", ["contractVersion", "instanceId", "schemaDigest", "ownGrant",
                       "availableCapabilities"], .admitted),
            ("KoineGrant", ["grantId", "clientLabel", "capabilities", "state"], .admitted),
            ("KoineCreatedGrant", ["grant", "credential"], .capability(CoreCapability.manage)),
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

    private var availableCapabilities: [String] { [CoreCapability.manage] }

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

    private func readStore<T>(_ body: () throws -> T) throws -> T {
        do { return try body() } catch {
            throw DomainError.failed("The grant store is unavailable.")
        }
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
