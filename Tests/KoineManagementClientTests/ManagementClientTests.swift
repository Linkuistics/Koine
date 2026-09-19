import Foundation
import KoineCore
import KoineManagementClient
import KoineServer
import Testing

/// The UI's operations against an embedded server, through the console only.
@Suite struct ManagementClientTests {
    private func withServer<T>(_ body: (Int, ManagementClient) async throws -> T) async throws -> T {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-client-tests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let server = try KoineServer(dataDirectory: directory)
        let port = try await server.start()
        do {
            let result = try await body(port, ManagementClient(console: server.console))
            await server.stop()
            return result
        } catch {
            await server.stop()
            throw error
        }
    }

    @Test func statusReportsTheServiceAndThePermissionsAsTheyAreNow() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-client-tests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let granted = Flag()
        let server = try KoineServer(
            dataDirectory: directory,
            osPermissions: {
                [OSPermissionStatus(permission: "accessibility", owner: "koine", granted: granted.value)]
            }
        )
        try await server.start()
        let client = ManagementClient(console: server.console)

        var status = try await client.status()
        #expect(status.contractVersion == "koine-desktop/1")
        #expect(status.instanceId == server.instanceId)
        #expect(status.providers.isEmpty)
        #expect(status.osPermissions.map(\.permission) == ["accessibility"])
        #expect(status.osPermissions.map(\.owner) == ["koine"])
        #expect(status.osPermissions.map(\.granted) == [false])

        granted.value = true
        status = try await client.status()
        #expect(status.osPermissions.map(\.granted) == [true])
        await server.stop()
    }

    @Test func capabilitiesAreTheServedOnes() async throws {
        let served = try await withServer { _, client in try await client.availableCapabilities() }
        #expect(served == ["koine:manage"])
    }

    @Test func aCreatedGrantsCredentialAuthenticatesOverHTTP() async throws {
        try await withServer { port, client in
            let created = try await client.createGrant(
                label: "script", capabilities: ["koine:manage"]
            )
            #expect(created.grant.clientLabel == "script")
            #expect(created.grant.capabilities == ["koine:manage"])
            #expect(created.grant.state == "ACTIVE")

            let reply = try await Self.post(
                "{ koine { ownGrant { grantId } } }", port: port, bearer: created.credential
            )
            let koine = (reply["data"] as? [String: Any])?["koine"] as? [String: Any]
            let own = koine?["ownGrant"] as? [String: Any]
            #expect(own?["grantId"] as? String == created.grant.grantId)
        }
    }

    @Test func aGraphQLErrorSurfacesItsMessageAndKind() async throws {
        try await withServer { _, client in
            await #expect(throws: ManagementError.rejected(
                messages: ["Unknown capabilities: nope:read."], kind: "failed"
            )) {
                try await client.createGrant(label: "x", capabilities: ["nope:read"])
            }
        }
    }

    @Test func theListShowsCreatedGrantsAndNeverACredential() async throws {
        try await withServer { _, client in
            #expect(try await client.grants().isEmpty)
            let created = try await client.createGrant(label: "script", capabilities: ["koine:manage"])
            #expect(try await client.grants() == [created.grant])
        }
    }

    @Test func revokingEndsTheCredentialAndTheListSaysSo() async throws {
        try await withServer { port, client in
            let created = try await client.createGrant(label: "script", capabilities: ["koine:manage"])
            let revoked = try await client.revokeGrant(id: created.grant.grantId)
            #expect(revoked.grantId == created.grant.grantId)
            #expect(revoked.state == "REVOKED")
            #expect(try await client.grants().map(\.state) == ["REVOKED"])

            let status = try await Self.status(
                "{ koine { contractVersion } }", port: port, bearer: created.credential
            )
            #expect(status == 401)
            // Idempotent: a second revoke of the same grant still succeeds.
            #expect(try await client.revokeGrant(id: created.grant.grantId).state == "REVOKED")
        }
    }

    @Test func revokingAnUnknownGrantIsAFailureNotASilentSuccess() async throws {
        try await withServer { _, client in
            do {
                _ = try await client.revokeGrant(id: "no-such-grant")
                Issue.record("revoking an unknown grant reported success")
            } catch ManagementError.rejected(_, let kind) {
                #expect(kind == "unavailable")
            }
        }
    }

    @Test func aResponseThatIsNotGraphQLIsMalformed() async throws {
        let client = ManagementClient { _ in Data("not json".utf8) }
        await #expect(throws: ManagementError.malformedResponse) {
            try await client.availableCapabilities()
        }
    }

    @Test func aNullMutationResultWithoutErrorsIsMalformed() async throws {
        let client = ManagementClient { _ in Data(#"{"data":{"koineCreateGrant":null}}"#.utf8) }
        await #expect(throws: ManagementError.malformedResponse) {
            try await client.createGrant(label: "x", capabilities: [])
        }
    }

    private static func post(_ query: String, port: Int, bearer: String) async throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: try await send(query, port: port, bearer: bearer).0)
            as? [String: Any] ?? [:]
    }

    private static func status(_ query: String, port: Int, bearer: String) async throws -> Int {
        (try await send(query, port: port, bearer: bearer).1 as? HTTPURLResponse)?.statusCode ?? 0
    }

    private static func send(_ query: String, port: Int, bearer: String) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/graphql")!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        return try await URLSession(configuration: .ephemeral).data(for: request)
    }
}

private final class Flag: @unchecked Sendable {
    private let lock = NSLock()
    private var stored = false
    var value: Bool {
        get { lock.withLock { stored } }
        set { lock.withLock { stored = newValue } }
    }
}
