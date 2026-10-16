import Foundation
import KoineServer

/// A grant as management operations report it. It never carries a credential.
public struct ManagedGrant: Sendable, Equatable, Decodable {
    public let grantId: String
    public let clientLabel: String
    public let capabilities: [String]
    public let state: String
}

/// The result of creating a grant. `credential` is the only copy of the bearer
/// secret outside the client it is handed to; the caller shows it once and
/// drops it.
public struct CreatedGrant: Sendable, Equatable, Decodable {
    public let grant: ManagedGrant
    public let credential: String
}

/// One provider candidate as `koineManagement.providers` reports it: a bundle
/// found in one of the two roots, or a synthetic row for an enabled slot with
/// nothing to run. The candidate fields are nullable, so a host that predates
/// them still decodes.
public struct ManagedProvider: Sendable, Equatable, Decodable {
    public let provider: String
    public let version: String
    public let state: String
    public let diagnostic: String?
    public let candidateId: String?
    /// `BUNDLED` or `PER_USER`; nil for a synthetic row.
    public let origin: String?
    /// `SELECTED`, `NOT_SELECTED` or `UNAVAILABLE`.
    public let selection: String?
    public let selectedCandidateId: String?
    /// A stable, open code; an unknown one is shown as it is.
    public let reason: String?

    public init(
        provider: String, version: String, state: String, diagnostic: String? = nil,
        candidateId: String? = nil, origin: String? = nil, selection: String? = nil,
        selectedCandidateId: String? = nil, reason: String? = nil
    ) {
        self.provider = provider
        self.version = version
        self.state = state
        self.diagnostic = diagnostic
        self.candidateId = candidateId
        self.origin = origin
        self.selection = selection
        self.selectedCandidateId = selectedCandidateId
        self.reason = reason
    }
}

/// Every candidate of one provider identity, the way the window shows them: the
/// running version first, then every copy that was refused, passed over or is
/// missing, each with its own origin and reason.
public struct ManagedProviderGroup: Sendable, Equatable, Identifiable {
    public let provider: String
    /// The frozen choice, whatever became of it afterwards: a selected copy that
    /// failed is still the one Koine chose, and is shown as failed. Without
    /// candidate fields (a host that predates them, or a provider composed in
    /// process), the active row.
    public let running: ManagedProvider?
    /// Every other row for the identity, in the order the host served them.
    public let others: [ManagedProvider]

    public var id: String { provider }

    /// Whether anything about this identity is not a plain success. A success
    /// indication never stands alone beside one of these.
    public var hasRefusals: Bool {
        guard let running else { return true }
        return running.state != "ACTIVE" || running.reason != nil || !others.isEmpty
    }

    /// Groups rows by provider identity, keeping the host's order of both.
    public static func grouping(_ rows: [ManagedProvider]) -> [ManagedProviderGroup] {
        var order: [String] = []
        var byProvider: [String: [ManagedProvider]] = [:]
        for row in rows {
            if byProvider[row.provider] == nil { order.append(row.provider) }
            byProvider[row.provider, default: []].append(row)
        }
        return order.map { provider in
            let members = byProvider[provider] ?? []
            let chosen =
                members.firstIndex { $0.selection == "SELECTED" }
                ?? members.firstIndex { $0.selection == nil && $0.state == "ACTIVE" }
            var others = members
            let running = chosen.map { others.remove(at: $0) }
            return ManagedProviderGroup(provider: provider, running: running, others: others)
        }
    }
}

extension ManagedProvider {
    /// Where the copy is installed, in words. Never inferred from its position.
    public var originLabel: String {
        switch origin {
        case "BUNDLED": "In Koine.app"
        case "PER_USER": "Installed for you"
        case nil: "Not installed"
        default: origin ?? ""
        }
    }

    public var selectionLabel: String {
        switch selection {
        case "SELECTED": "Chosen"
        case "NOT_SELECTED": "Not used"
        case "UNAVAILABLE": "Nothing to run"
        case nil: ""
        default: selection ?? ""
        }
    }
}

/// One OS permission as `koineManagement.osPermissions` reports it.
public struct ManagedOSPermission: Sendable, Equatable, Decodable {
    public let permission: String
    public let owner: String
    public let granted: Bool

    public init(permission: String, owner: String, granted: Bool) {
        self.permission = permission
        self.owner = owner
        self.granted = granted
    }
}

/// A client's enrollment request as `koineManagement.requests` reports it. The
/// requested capabilities are the request's own and never change.
public struct ManagedGrantRequest: Sendable, Equatable, Decodable {
    public let requestId: String
    public let clientLabel: String
    public let comparisonCode: String
    public let requestedCapabilities: [String]
    public let state: String

    public init(
        requestId: String, clientLabel: String, comparisonCode: String,
        requestedCapabilities: [String], state: String
    ) {
        self.requestId = requestId
        self.clientLabel = clientLabel
        self.comparisonCode = comparisonCode
        self.requestedCapabilities = requestedCapabilities
        self.state = state
    }
}

/// What the window polls, from one request: all of it describes the same
/// moment.
public struct ManagementStatus: Sendable, Equatable {
    public let contractVersion: String
    public let instanceId: String
    /// Every request the server still serves, decided ones included.
    public let requests: [ManagedGrantRequest]
    public let providers: [ManagedProvider]
    public let osPermissions: [ManagedOSPermission]

    public init(
        contractVersion: String, instanceId: String, requests: [ManagedGrantRequest] = [],
        providers: [ManagedProvider] = [], osPermissions: [ManagedOSPermission] = []
    ) {
        self.contractVersion = contractVersion
        self.instanceId = instanceId
        self.requests = requests
        self.providers = providers
        self.osPermissions = osPermissions
    }
}

public enum ManagementError: Error, Equatable, LocalizedError {
    /// The operation answered with GraphQL errors. `kind` is the first error's
    /// `extensions.kind`, when it has one. `reason` and `requestState` are its
    /// `extensions.reason` and `extensions.requestState`, which tell the request
    /// outcomes that share a kind apart.
    case rejected(
        messages: [String], kind: String?, reason: String? = nil, requestState: String? = nil
    )
    /// The response was not the GraphQL JSON the operation promises.
    case malformedResponse

    public var errorDescription: String? {
        switch self {
        case .rejected(let messages, _, _, _): messages.joined(separator: "\n")
        case .malformedResponse: "Koine returned a response that could not be read."
        }
    }
}

/// The management operations the native UI performs, as GraphQL over an
/// in-process executor. It is the whole of what the UI knows about the server:
/// it holds no store, engine or credential.
public struct ManagementClient: Sendable {
    private let execute: @Sendable (Data) async throws -> Data

    /// `execute` takes a `{"query", "variables"}` JSON request and returns the
    /// GraphQL JSON response.
    public init(execute: @escaping @Sendable (Data) async throws -> Data) {
        self.execute = execute
    }

    public init(console: LocalConsole) {
        self.init { try await console.execute(jsonBody: $0) }
    }

    /// The capability names the server offers right now, as served.
    public func availableCapabilities() async throws -> [String] {
        struct Reply: Decodable {
            struct Koine: Decodable { let availableCapabilities: [String] }
            let koine: Koine
        }
        let reply: Reply = try await run("{ koine { availableCapabilities } }", variables: [:])
        return reply.koine.availableCapabilities
    }

    /// What a person must be told about each capability's reach, keyed by
    /// capability name. Only a capability with a disclosure is a key. The text is
    /// the server's, so the window and any other `koine:manage` client show the
    /// same words; a host that predates the field rejects the query.
    public func capabilityDisclosures() async throws -> [String: String] {
        struct Reply: Decodable {
            struct Entry: Decodable { let capability, disclosure: String }
            struct Management: Decodable { let capabilityDisclosures: [Entry] }
            let koineManagement: Management?
        }
        let reply: Reply = try await run(
            "{ koineManagement { capabilityDisclosures { capability disclosure } } }", variables: [:]
        )
        guard let management = reply.koineManagement else { throw ManagementError.malformedResponse }
        return Dictionary(
            management.capabilityDisclosures.map { ($0.capability, $0.disclosure) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    public func createGrant(label: String, capabilities: [String]) async throws -> CreatedGrant {
        struct Reply: Decodable { let koineCreateGrant: CreatedGrant? }
        let reply: Reply = try await run(
            """
            mutation Create($label: String!, $capabilities: [String!]!) {
              koineCreateGrant(input: { clientLabel: $label, capabilities: $capabilities }) {
                credential
                grant { grantId clientLabel capabilities state }
              }
            }
            """,
            variables: ["label": label, "capabilities": capabilities]
        )
        guard let created = reply.koineCreateGrant else { throw ManagementError.malformedResponse }
        return created
    }

    /// Every grant, revoked ones included. No operation here re-reads a
    /// credential: lost delivery is handled by revoking and creating again.
    public func grants() async throws -> [ManagedGrant] {
        struct Reply: Decodable {
            struct Management: Decodable { let grants: [ManagedGrant] }
            let koineManagement: Management?
        }
        let reply: Reply = try await run(
            "{ koineManagement { grants { grantId clientLabel capabilities state } } }",
            variables: [:]
        )
        guard let management = reply.koineManagement else { throw ManagementError.malformedResponse }
        return management.grants
    }

    /// The served contract, provider states and OS permissions as they are now.
    /// The permissions are read by the server on this request, without a prompt.
    public func status() async throws -> ManagementStatus {
        struct Reply: Decodable {
            struct Koine: Decodable { let contractVersion, instanceId: String }
            struct Management: Decodable {
                let requests: [ManagedGrantRequest]
                let providers: [ManagedProvider]
                let osPermissions: [ManagedOSPermission]
            }
            let koine: Koine
            let koineManagement: Management?
        }
        let reply: Reply = try await run(
            """
            { koine { contractVersion instanceId }
              koineManagement {
                requests { requestId clientLabel comparisonCode requestedCapabilities state }
                providers {
                  provider version state diagnostic
                  candidateId origin selection selectedCandidateId reason
                }
                osPermissions { permission owner granted }
              } }
            """,
            variables: [:]
        )
        guard let management = reply.koineManagement else { throw ManagementError.malformedResponse }
        return ManagementStatus(
            contractVersion: reply.koine.contractVersion, instanceId: reply.koine.instanceId,
            requests: management.requests, providers: management.providers, osPermissions: management.osPermissions
        )
    }

    /// Revokes durably and returns the grant as committed. An unknown grant is
    /// `rejected` with kind `unavailable`; revoking twice succeeds.
    public func revokeGrant(id: String) async throws -> ManagedGrant {
        struct Reply: Decodable { let koineRevokeGrant: ManagedGrant? }
        let reply: Reply = try await run(
            """
            mutation Revoke($id: ID!) {
              koineRevokeGrant(grantId: $id) { grantId clientLabel capabilities state }
            }
            """,
            variables: ["id": id]
        )
        guard let revoked = reply.koineRevokeGrant else { throw ManagementError.malformedResponse }
        return revoked
    }

    /// Approves `capabilities`, a subset of what the request asked for, into one
    /// grant for the requester's own secret. A request already decided or
    /// expired is `rejected` with reason `already-decided` and its state; a
    /// capability it did not ask for is `invalid-subset`.
    public func approveGrantRequest(id: String, capabilities: [String]) async throws -> ManagedGrant {
        struct Reply: Decodable { let koineApproveGrantRequest: ManagedGrant? }
        let reply: Reply = try await run(
            """
            mutation Approve($id: ID!, $capabilities: [String!]!) {
              koineApproveGrantRequest(requestId: $id, capabilities: $capabilities) {
                grantId clientLabel capabilities state
              }
            }
            """,
            variables: ["id": id, "capabilities": capabilities]
        )
        guard let grant = reply.koineApproveGrantRequest else { throw ManagementError.malformedResponse }
        return grant
    }

    /// Denies a pending request and returns it as committed. Refusals are those
    /// of `approveGrantRequest`.
    public func denyGrantRequest(id: String) async throws -> ManagedGrantRequest {
        struct Reply: Decodable { let koineDenyGrantRequest: ManagedGrantRequest? }
        let reply: Reply = try await run(
            """
            mutation Deny($id: ID!) {
              koineDenyGrantRequest(requestId: $id) {
                requestId clientLabel comparisonCode requestedCapabilities state
              }
            }
            """,
            variables: ["id": id]
        )
        guard let denied = reply.koineDenyGrantRequest else { throw ManagementError.malformedResponse }
        return denied
    }

    /// Any GraphQL error fails the whole operation: the UI's operations have no
    /// use for partial data.
    private func run<Reply: Decodable>(_ query: String, variables: [String: Any]) async throws -> Reply {
        let body = try JSONSerialization.data(
            withJSONObject: ["query": query, "variables": variables]
        )
        let response = try await execute(body)
        guard let envelope = try? JSONDecoder().decode(Envelope<Reply>.self, from: response) else {
            throw ManagementError.malformedResponse
        }
        if let errors = envelope.errors, !errors.isEmpty {
            throw ManagementError.rejected(
                messages: errors.map(\.message), kind: errors[0].extensions?.kind,
                reason: errors[0].extensions?.reason,
                requestState: errors[0].extensions?.requestState
            )
        }
        guard let data = envelope.data else { throw ManagementError.malformedResponse }
        return data
    }
}

private struct Envelope<Reply: Decodable>: Decodable {
    struct Failure: Decodable {
        struct Extensions: Decodable { let kind, reason, requestState: String? }
        let message: String
        let extensions: Extensions?
    }
    let data: Reply?
    let errors: [Failure]?
}
