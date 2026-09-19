import CryptoKit
import Foundation
import KoineCore
import KoineManagementClient
import KoineServer
import Testing

/// The UI's operations against an embedded server, through the console only.
@Suite struct ManagementClientTests {
    private func withServer<T>(
        now: @escaping TimeSource = { Date() },
        _ body: (Int, ManagementClient) async throws -> T
    ) async throws -> T {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-client-tests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let server = try KoineServer(dataDirectory: directory, now: now)
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
            } catch ManagementError.rejected(_, let kind, _, _) {
                #expect(kind == "unavailable")
            }
        }
    }

    @Test func aClientsRequestArrivesWithTheStatusExactlyAsItAsked() async throws {
        try await withServer { port, client in
            #expect(try await client.status().requests.isEmpty)
            let enrolled = try await Self.enrol("editor", ["koine:manage"], port: port)
            let requests = try await client.status().requests
            #expect(requests == [ManagedGrantRequest(
                requestId: enrolled.requestId, clientLabel: "editor",
                comparisonCode: enrolled.comparisonCode,
                requestedCapabilities: ["koine:manage"], state: "PENDING"
            )])
        }
    }

    @Test func approvingASubsetMakesTheClientsOwnSecretAGrantForIt() async throws {
        try await withServer { port, client in
            let enrolled = try await Self.enrol("editor", ["koine:manage"], port: port)
            let grant = try await client.approveGrantRequest(id: enrolled.requestId, capabilities: [])
            #expect(grant.clientLabel == "editor")
            #expect(grant.capabilities.isEmpty)
            #expect(grant.state == "ACTIVE")
            #expect(try await client.status().requests.map(\.state) == ["APPROVED"])
            #expect(try await client.grants() == [grant])

            let reply = try await Self.post(
                "{ koine { ownGrant { grantId } } }", port: port, bearer: enrolled.secret
            )
            let koine = (reply["data"] as? [String: Any])?["koine"] as? [String: Any]
            #expect((koine?["ownGrant"] as? [String: Any])?["grantId"] as? String == grant.grantId)
        }
    }

    @Test func denyingReturnsTheRequestAsDenied() async throws {
        try await withServer { port, client in
            let enrolled = try await Self.enrol("editor", ["koine:manage"], port: port)
            let denied = try await client.denyGrantRequest(id: enrolled.requestId)
            #expect(denied.requestId == enrolled.requestId)
            #expect(denied.state == "DENIED")
            #expect(try await client.status().requests == [denied])
            #expect(try await client.grants().isEmpty)
        }
    }

    @Test func decidingADecidedRequestSaysWhichStateItIsIn() async throws {
        try await withServer { port, client in
            let enrolled = try await Self.enrol("editor", ["koine:manage"], port: port)
            _ = try await client.denyGrantRequest(id: enrolled.requestId)
            let refusal = ManagementError.rejected(
                messages: ["This request has already been decided."], kind: "failed",
                reason: "already-decided", requestState: "DENIED"
            )
            await #expect(throws: refusal) {
                try await client.approveGrantRequest(id: enrolled.requestId, capabilities: [])
            }
            await #expect(throws: refusal) { try await client.denyGrantRequest(id: enrolled.requestId) }
        }
    }

    @Test func decidingAnExpiredRequestSaysItExpired() async throws {
        let clock = Clock()
        try await withServer(now: { clock.now }) { port, client in
            let enrolled = try await Self.enrol("editor", ["koine:manage"], port: port)
            clock.advance(by: 25 * 60 * 60)
            #expect(try await client.status().requests.map(\.state) == ["EXPIRED"])
            do {
                _ = try await client.approveGrantRequest(
                    id: enrolled.requestId, capabilities: ["koine:manage"]
                )
                Issue.record("approving an expired request reported success")
            } catch ManagementError.rejected(_, _, let reason, let state) {
                #expect(reason == "already-decided")
                #expect(state == "EXPIRED")
            }
        }
    }

    @Test func approvingWhatWasNotAskedForIsAnInvalidSubset() async throws {
        try await withServer { port, client in
            let enrolled = try await Self.enrol("editor", [], port: port)
            do {
                _ = try await client.approveGrantRequest(
                    id: enrolled.requestId, capabilities: ["koine:manage"]
                )
                Issue.record("approving an unrequested capability reported success")
            } catch ManagementError.rejected(_, let kind, let reason, _) {
                #expect(kind == "failed")
                #expect(reason == "invalid-subset")
            }
            #expect(try await client.status().requests.map(\.state) == ["PENDING"])
        }
    }

    @Test func decidingAnUnknownRequestIsUnavailable() async throws {
        try await withServer { _, client in
            do {
                _ = try await client.denyGrantRequest(id: "no-such-request")
                Issue.record("denying an unknown request reported success")
            } catch ManagementError.rejected(_, let kind, let reason, _) {
                #expect(kind == "unavailable")
                #expect(reason == nil)
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

    /// Enrols as a client does: anonymously over HTTP, with a secret of its own.
    private static func enrol(
        _ label: String, _ capabilities: [String], port: Int
    ) async throws -> (secret: String, requestId: String, comparisonCode: String) {
        let bytes = (0..<32).map { _ in UInt8.random(in: .min ... .max) }
        let secret = Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        let digest = SHA256.hash(data: Data(bytes)).map { String(format: "%02x", $0) }.joined()
        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/graphql")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "query": """
                mutation Enrol($input: KoineRequestGrantInput!) {
                  koineRequestGrant(input: $input) { requestId comparisonCode }
                }
                """,
            "variables": ["input": [
                "clientLabel": label, "credentialDigest": digest, "capabilities": capabilities,
            ]],
        ])
        let (data, _) = try await URLSession(configuration: .ephemeral).data(for: request)
        let reply = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let receipt = (reply?["data"] as? [String: Any])?["koineRequestGrant"] as? [String: Any]
        return (
            secret, try #require(receipt?["requestId"] as? String),
            try #require(receipt?["comparisonCode"] as? String)
        )
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

private final class Clock: @unchecked Sendable {
    private let lock = NSLock()
    private var instant = Date(timeIntervalSince1970: 1_800_000_000)
    var now: Date { lock.withLock { instant } }
    func advance(by interval: TimeInterval) { lock.withLock { instant += interval } }
}

private final class Flag: @unchecked Sendable {
    private let lock = NSLock()
    private var stored = false
    var value: Bool {
        get { lock.withLock { stored } }
        set { lock.withLock { stored = newValue } }
    }
}
