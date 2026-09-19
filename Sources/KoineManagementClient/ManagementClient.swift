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

/// One provider bundle as `koineManagement.providers` reports it.
public struct ManagedProvider: Sendable, Equatable, Decodable {
    public let provider: String
    public let version: String
    public let state: String
    public let diagnostic: String?
}

/// One OS permission as `koineManagement.osPermissions` reports it.
public struct ManagedOSPermission: Sendable, Equatable, Decodable {
    public let permission: String
    public let owner: String
    public let granted: Bool
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
                providers { provider version state diagnostic }
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
