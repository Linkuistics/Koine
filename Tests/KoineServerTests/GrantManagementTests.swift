import Foundation
import KoineCore
import KoineSQLiteStore
import KoineServer
import Testing

/// Grant listing and revocation over loopback HTTP. The console only mints the
/// first `koine:manage` grant; everything after is an ordinary client.
@Suite struct GrantManagementTests {
    static let grants = "{ koineManagement { grants { grantId clientLabel capabilities state } } }"

    static let revoke = """
        mutation Revoke($id: ID!) { koineRevokeGrant(grantId: $id) { grantId clientLabel state } }
        """

    /// A harness with one manager grant, and the manager's own grant ID.
    private func managed() async throws -> (Harness, manager: String, managerId: String) {
        let harness = try await Harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let reply = try await harness.post(Harness.koine, authorization: "Bearer \(manager)")
        let koine = try #require(reply.data?["koine"] as? [String: Any])
        let own = try #require(koine["ownGrant"] as? [String: Any])
        return (harness, manager, try #require(own["grantId"] as? String))
    }

    private func create(
        _ harness: Harness, as bearer: String, label: String, capabilities: [String] = []
    ) async throws -> (id: String, credential: String) {
        let reply = try await harness.post(
            Harness.createGrant, variables: ["label": label, "capabilities": capabilities],
            authorization: "Bearer \(bearer)"
        )
        let created = try #require(reply.data?["koineCreateGrant"] as? [String: Any])
        let grant = try #require(created["grant"] as? [String: Any])
        return (try #require(grant["grantId"] as? String), try #require(created["credential"] as? String))
    }

    private func listed(_ harness: Harness, as bearer: String) async throws -> [[String: Any]] {
        let reply = try await harness.post(Self.grants, authorization: "Bearer \(bearer)")
        let management = try #require(reply.data?["koineManagement"] as? [String: Any])
        return try #require(management["grants"] as? [[String: Any]])
    }

    // MARK: Listing

    @Test func aManagerListsEveryGrantWithoutSecrets() async throws {
        let (harness, manager, _) = try await managed()
        let reader = try await create(harness, as: manager, label: "reader")
        let doomed = try await create(harness, as: manager, label: "doomed")
        _ = try await harness.post(
            Self.revoke, variables: ["id": doomed.id], authorization: "Bearer \(manager)"
        )

        let reply = try await harness.raw(Self.grants, bearer: manager)
        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        let grants = try await listed(harness, as: manager)
        #expect(grants.map { $0["clientLabel"] as? String } == ["manager", "reader", "doomed"])
        #expect(grants.map { $0["state"] as? String } == ["ACTIVE", "ACTIVE", "REVOKED"])
        #expect(grants[0]["capabilities"] as? [String] == ["koine:manage"])
        #expect(grants.allSatisfy { Set($0.keys) == ["grantId", "clientLabel", "capabilities", "state"] })

        // Neither a secret nor a digest is anywhere in the response bytes.
        let text = String(decoding: reply.body, as: UTF8.self)
        for credential in [manager, reader.credential, doomed.credential] {
            #expect(!text.contains(credential))
            #expect(!text.contains(try #require(Credential.digest(ofPresented: credential))))
        }
        await harness.stop()
    }

    @Test func listingWithoutManageIsDeniedAndSiblingsStillResolve() async throws {
        let (harness, manager, _) = try await managed()
        let reader = try await create(harness, as: manager, label: "reader")

        let reply = try await harness.post(
            "{ koine { contractVersion } management: koineManagement { grants { grantId } } }",
            authorization: "Bearer \(reader.credential)"
        )
        #expect(reply.status == 200)
        let data = try #require(reply.data)
        #expect((data["koine"] as? [String: Any])?["contractVersion"] as? String == "koine-desktop/1")
        #expect(data["management"] is NSNull)
        #expect(reply.errors.count == 1)
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["management"])
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "koine:manage")
        await harness.stop()
    }

    // MARK: Creation over HTTP

    @Test func createGrantOverHTTPRequiresManage() async throws {
        let (harness, manager, _) = try await managed()
        let reader = try await create(harness, as: manager, label: "reader")
        let works = try await harness.post(Harness.koine, authorization: "Bearer \(reader.credential)")
        #expect(works.status == 200)

        let denied = try await harness.post(
            Harness.createGrant, variables: ["label": "sneaky", "capabilities": ["koine:manage"]],
            authorization: "Bearer \(reader.credential)"
        )
        #expect(denied.status == 403)
        #expect(denied.data == nil)
        let extensions = try #require(denied.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["requiredCapability"] as? String == "koine:manage")
        #expect(extensions["phase"] as? String == "authorization")
        #expect(denied.errors.first?["path"] as? [String] == ["koineCreateGrant"])
        #expect(try await listed(harness, as: manager).count == 2)
        await harness.stop()
    }

    // MARK: Revocation

    @Test func revocationRequiresManage() async throws {
        let (harness, manager, managerId) = try await managed()
        let reader = try await create(harness, as: manager, label: "reader")

        let denied = try await harness.post(
            Self.revoke, variables: ["id": managerId], authorization: "Bearer \(reader.credential)"
        )
        #expect(denied.status == 403)
        let extensions = try #require(denied.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["requiredCapability"] as? String == "koine:manage")
        let stillWorks = try await harness.post(Harness.koine, authorization: "Bearer \(manager)")
        #expect(stillWorks.status == 200)
        await harness.stop()
    }

    @Test func revocationIsIdempotent() async throws {
        let (harness, manager, _) = try await managed()
        let reader = try await create(harness, as: manager, label: "reader")

        var results: [[String: String]] = []
        for _ in 0..<2 {
            let reply = try await harness.post(
                Self.revoke, variables: ["id": reader.id], authorization: "Bearer \(manager)"
            )
            #expect(reply.status == 200)
            #expect(reply.errors.isEmpty)
            results.append(try #require(reply.data?["koineRevokeGrant"] as? [String: String]))
        }
        #expect(results[0] == ["grantId": reader.id, "clientLabel": "reader", "state": "REVOKED"])
        #expect(results[1] == results[0])
        await harness.stop()
    }

    @Test func revokingAnUnknownGrantIsUnavailable() async throws {
        let (harness, manager, _) = try await managed()
        let reply = try await harness.post(
            Self.revoke, variables: ["id": "no-such-grant"], authorization: "Bearer \(manager)"
        )
        #expect(reply.status == 200)
        #expect(reply.data?["koineRevokeGrant"] is NSNull)
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["koineRevokeGrant"])
        #expect((error["extensions"] as? [String: Any])?["kind"] as? String == "unavailable")
        await harness.stop()
    }

    @Test func aRevokedCredentialIs401OnAnExistingConnectionAndAfterRestart() async throws {
        let (harness, manager, _) = try await managed()
        let reader = try await create(harness, as: manager, label: "reader")
        let request = harness.requestBytes(
            headers: ["Authorization": "Bearer \(reader.credential)"],
            body: try Harness.requestBody(Harness.koine, variables: [:])
        )
        let connection = try RawConnection(port: harness.port)
        let exchange: @Sendable () throws -> RawResponse = {
            connection.send(request)
            return try connection.readResponse()
        }

        let before = try await offPool(exchange)
        #expect(before.status == 200)
        #expect(before.headers["connection"] == "keep-alive")
        _ = try await harness.post(
            Self.revoke, variables: ["id": reader.id], authorization: "Bearer \(manager)"
        )
        let after = try await offPool(exchange)
        #expect(after.status == 401)

        try await harness.restart()
        let restarted = try await harness.post(
            Harness.koine, authorization: "Bearer \(reader.credential)"
        )
        #expect(restarted.status == 401)
        let states = try await listed(harness, as: manager).map { $0["state"] as? String }
        #expect(states == ["ACTIVE", "REVOKED"])

        // The durable record itself, read by a fresh store.
        await harness.stop()
        let stored = try SQLiteGrantStore(
            path: harness.directory.appendingPathComponent("grants.sqlite").path
        ).grant(id: reader.id)
        #expect(stored?.state == .revoked)
    }

    @Test func aGrantMayRevokeItself() async throws {
        let (harness, manager, managerId) = try await managed()
        let reply = try await harness.post(
            "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { grantId } }",
            variables: ["id": managerId], authorization: "Bearer \(manager)"
        )
        // The action ran; its output is read under a principal no longer
        // admitted, so the read is refused. That is not evidence against the action.
        #expect(reply.status == 200)
        #expect(reply.data?["koineRevokeGrant"] is NSNull)
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["koineRevokeGrant", "grantId"])
        #expect((error["extensions"] as? [String: Any])?["kind"] as? String == "permission")
        let next = try await harness.post(Harness.koine, authorization: "Bearer \(manager)")
        #expect(next.status == 401)
        await harness.stop()
    }

    @Test func noLaterActionStartsUnderARevokedGrant() async throws {
        let (harness, manager, managerId) = try await managed()
        let witness = try await create(harness, as: manager, label: "witness", capabilities: ["koine:manage"])

        let reply = try await harness.post(
            """
            mutation($id: ID!) {
              first: koineRevokeGrant(grantId: $id) { __typename }
              second: koineCreateGrant(input: { clientLabel: "late", capabilities: [] }) { credential }
            }
            """,
            variables: ["id": managerId], authorization: "Bearer \(manager)"
        )
        // Preflight passed, so the operation executed; the second action was
        // refused at dispatch.
        #expect(reply.status == 200)
        #expect(reply.data?["second"] is NSNull)
        let refusal = try #require(reply.errors.first { ($0["path"] as? [String]) == ["second"] })
        let extensions = try #require(refusal["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["phase"] as? String == "execution")

        // The first ran and was not undone; the second never began.
        let grants = try await listed(harness, as: witness.credential)
        #expect(grants.map { $0["clientLabel"] as? String } == ["manager", "witness"])
        #expect(grants.map { $0["state"] as? String } == ["REVOKED", "ACTIVE"])
        await harness.stop()
    }

    // MARK: Schema

    @Test func theServedSchemaGainsOnlyGrantsAndRevocation() async throws {
        let (harness, manager, _) = try await managed()
        let reply = try await harness.post(
            """
            { management: __type(name: "KoineManagement") { fields { name } }
              mutation: __type(name: "Mutation") { fields { name } } }
            """,
            authorization: "Bearer \(manager)"
        )
        func names(_ key: String) -> [String] {
            let fields = (reply.data?[key] as? [String: Any])?["fields"] as? [[String: Any]] ?? []
            return fields.compactMap { $0["name"] as? String }.sorted()
        }
        #expect(names("management") == ["grants"])
        #expect(names("mutation") == ["koineCreateGrant", "koineRevokeGrant"])
        await harness.stop()
    }
}
