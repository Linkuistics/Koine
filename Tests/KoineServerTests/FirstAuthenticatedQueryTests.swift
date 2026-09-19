import Foundation
import KoineCore
import KoineSQLiteStore
import KoineServer
import Testing

@Suite struct FirstAuthenticatedQueryTests {
    @Test func descriptorIsPublishedUserOnlyWithoutACredential() async throws {
        let harness = try await Harness()
        let descriptor = try harness.descriptor()

        #expect(Set(descriptor.keys) == [
            "descriptorVersion", "instanceId", "pid", "port", "path", "contractVersion",
        ])
        #expect(descriptor["descriptorVersion"] as? Int == 1)
        #expect(descriptor["path"] as? String == "/graphql")
        #expect(descriptor["contractVersion"] as? String == "koine-desktop/1")
        #expect(descriptor["pid"] as? Int32 == ProcessInfo.processInfo.processIdentifier)
        #expect(descriptor["instanceId"] as? String == harness.server.instanceId)

        let files = FileManager.default
        let directoryMode = try files.attributesOfItem(atPath: harness.directory.path)
        let fileMode = try files.attributesOfItem(atPath: harness.descriptorURL.path)
        #expect(directoryMode[.posixPermissions] as? Int == 0o700)
        #expect(fileMode[.posixPermissions] as? Int == 0o600)
        await harness.stop()
    }

    @Test func listenerIsReachableOnlyOnIPv4Loopback() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])
        let reply = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        #expect(reply.status == 200)
        await #expect(throws: (any Error).self) {
            _ = try await harness.post(
                Harness.koine, authorization: "Bearer \(credential)", host: "[::1]"
            )
        }
        await harness.stop()
    }

    @Test func consoleGrantStoresOnlyTheDigest() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])

        #expect(credential.count == 43)
        #expect(credential.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || "-_".contains($0)) })
        let digest = try #require(Credential.digest(ofPresented: credential))
        #expect(digest.count == 64)

        await harness.stop()
        let stored = try SQLiteGrantStore(
            path: harness.directory.appendingPathComponent("grants.sqlite").path
        ).grants()
        #expect(stored.map(\.credentialDigest) == [digest])
        #expect(stored.first?.clientLabel == "reader")
        #expect(stored.first?.state == .active)
        for file in try FileManager.default.contentsOfDirectory(atPath: harness.directory.path) {
            let bytes = try Data(contentsOf: harness.directory.appendingPathComponent(file))
            #expect(bytes.range(of: Data(credential.utf8)) == nil, "\(file) holds the secret")
        }
    }

    @Test func authenticatedCallerReadsKoine() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])
        let reply = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")

        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        #expect((reply.headers["Content-Type"] as? String) == "application/graphql-response+json")
        #expect((reply.headers["Cache-Control"] as? String) == "no-store")
        let koine = try #require(reply.data?["koine"] as? [String: Any])
        #expect(koine["contractVersion"] as? String == "koine-desktop/1")
        #expect(koine["instanceId"] as? String == harness.server.instanceId)
        #expect((koine["schemaDigest"] as? String)?.count == 64)
        #expect(koine["availableCapabilities"] as? [String] == ["koine:manage"])
        let ownGrant = try #require(koine["ownGrant"] as? [String: Any])
        #expect(ownGrant["clientLabel"] as? String == "reader")
        #expect(ownGrant["capabilities"] as? [String] == [])
        #expect(ownGrant["state"] as? String == "ACTIVE")
        await harness.stop()
    }

    @Test(arguments: [
        nil,
        "",
        "Basic dXNlcjpwYXNz",
        "Bearer ",
        "Bearer not-a-credential",
        "Bearer AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",  // well formed, unknown
        "Bearer AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",  // padded
        "Bearer AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB",  // non-zero trailing bits
        "Bearer AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",  // 35 bytes
    ] as [String?])
    func requestsWithoutAnActiveGrantGet401(authorization: String?) async throws {
        let harness = try await Harness()
        let reply = try await harness.post(Harness.koine, authorization: authorization)
        #expect(reply.status == 401)
        #expect(reply.data == nil)
        await harness.stop()
    }

    @Test func onlyCanonical32ByteCredentialsHaveADigest() {
        let zeros = String(repeating: "A", count: 43)
        #expect(Credential.digest(ofPresented: zeros)
            == "66687aadf862bd776c8fc18b8e9f8e20089714856ee233b3902a591d0d5f2925")
        #expect(Credential.digest(ofPresented: String(zeros.dropLast()) + "B") == nil)
        #expect(Credential.digest(ofPresented: zeros + "=") == nil)
        #expect(Credential.digest(ofPresented: String(zeros.dropLast(2)) + "+/") == nil)
        #expect(Credential.digest(ofPresented: String(zeros.dropLast())) == nil)
        #expect(Credential.constantTimeEqual("abc", "abc"))
        #expect(!Credential.constantTimeEqual("abc", "abd"))
    }

    @Test func createGrantWithoutManageIsRefusedBeforeAnyAction() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])
        let reply = try await harness.post(
            """
            mutation { first: koineCreateGrant(input: { clientLabel: "x", capabilities: [] }) {
              credential } }
            """,
            authorization: "Bearer \(credential)"
        )

        #expect(reply.status == 403)
        #expect(reply.json.keys.contains("data") == false)
        let error = try #require(reply.errors.first)
        #expect(reply.errors.count == 1)
        #expect(error["path"] as? [String] == ["first"])
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["phase"] as? String == "authorization")

        await harness.stop()
        let stored = try SQLiteGrantStore(
            path: harness.directory.appendingPathComponent("grants.sqlite").path
        ).grants()
        #expect(stored.count == 1, "the refused action created nothing")
    }

    @Test func skippedDeniedActionDoesNotBlockTheOperation() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])
        let query = """
            mutation M($skip: Boolean!) {
              __typename
              ...Denied @skip(if: $skip)
            }
            fragment Denied on Mutation {
              koineCreateGrant(input: { clientLabel: "x", capabilities: [] }) { credential }
            }
            """
        let skipped = try await harness.post(
            query, variables: ["skip": true], authorization: "Bearer \(credential)"
        )
        #expect(skipped.status == 200)
        #expect(skipped.data?["__typename"] as? String == "Mutation")
        let selected = try await harness.post(
            query, variables: ["skip": false], authorization: "Bearer \(credential)"
        )
        #expect(selected.status == 403)
        await harness.stop()
    }

    @Test func managerCreatesAGrantOverHTTP() async throws {
        let harness = try await Harness()
        let manager = try await harness.consoleGrant(
            label: "manager", capabilities: ["koine:manage"]
        )
        let reply = try await harness.post(
            Harness.createGrant, variables: ["label": "script", "capabilities": []],
            authorization: "Bearer \(manager)"
        )
        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        let created = try #require(reply.data?["koineCreateGrant"] as? [String: Any])
        let credential = try #require(created["credential"] as? String)

        let asScript = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        let koine = try #require(asScript.data?["koine"] as? [String: Any])
        #expect((koine["ownGrant"] as? [String: Any])?["clientLabel"] as? String == "script")

        let unknown = try await harness.post(
            Harness.createGrant, variables: ["label": "bad", "capabilities": ["desktop:fly"]],
            authorization: "Bearer \(manager)"
        )
        #expect(unknown.status == 200)
        #expect(unknown.errors.first?["path"] as? [String] == ["koineCreateGrant"])
        await harness.stop()
    }

    @Test func grantWithNoCapabilitiesIntrospectsTheWholeSchema() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "codegen", capabilities: [])
        let reply = try await harness.post(
            Harness.introspection, authorization: "Bearer \(credential)"
        )
        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        let schema = try #require(reply.data?["__schema"] as? [String: Any])
        let types = try #require(schema["types"] as? [[String: Any]])
        let byName = Dictionary(uniqueKeysWithValues: types.map { ($0["name"] as! String, $0) })
        for name in ["Query", "Mutation", "Koine", "KoineGrant", "KoineGrantState",
                     "KoineCreatedGrant", "KoineCreateGrantInput", "KoineManagement"] {
            #expect(byName[name] != nil, "\(name) is introspectable")
        }
        let queryFields = try #require(byName["Query"]?["fields"] as? [[String: Any]])
        #expect(queryFields.map { $0["name"] as? String } == ["koine", "koineGrantRequest", "koineManagement"])
        #expect((queryFields[0]["description"] as? String)?.contains("Authenticated") == true)
        // Only what is implemented is served; `GrantManagementTests` pins the mutations.
        #expect(byName["DesktopWindow"] == nil)
        await harness.stop()
    }

    @Test func grantsSurviveARestart() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])
        let before = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        try await harness.restart()
        let after = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")

        #expect(after.status == 200)
        let first = try #require(before.data?["koine"] as? [String: Any])
        let second = try #require(after.data?["koine"] as? [String: Any])
        #expect(first["instanceId"] as? String != second["instanceId"] as? String)
        #expect(first["schemaDigest"] as? String == second["schemaDigest"] as? String)
        #expect(
            (first["ownGrant"] as? [String: Any])?["grantId"] as? String
                == (second["ownGrant"] as? [String: Any])?["grantId"] as? String
        )
        await harness.stop()
    }

    @Test func unreadableStoreFailsClosed() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data("not a database, and long enough to be read as a header".utf8)
            .write(to: directory.appendingPathComponent("grants.sqlite"))
        #expect(throws: (any Error).self) { try KoineServer(dataDirectory: directory) }
    }
}
