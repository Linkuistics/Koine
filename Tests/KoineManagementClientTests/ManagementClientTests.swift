import Foundation
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
        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/graphql")!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession(configuration: .ephemeral).data(for: request)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}
