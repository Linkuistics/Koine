import Foundation
import KoineCore
import KoineSQLiteStore
import KoineServer
import SQLite3
import Testing

/// What constrains the client-requested grant: denial, the explicit decision
/// outcomes, idempotent retry and conflict, and a credential digest that names
/// at most one thing for ever. Store failures during a decision are
/// `RevocationOrderingTests`'.
@Suite struct GrantDecisionTests {
    static let deny = """
        mutation Deny($id: ID!) {
          koineDenyGrantRequest(requestId: $id) {
            requestId clientLabel comparisonCode requestedCapabilities state
            grant { grantId }
          }
        }
        """

    private let enrollment = GrantEnrollmentTests()

    private func decide(
        _ harness: Harness, _ mutation: String, _ variables: [String: Any], as bearer: String
    ) async throws -> Harness.Reply {
        try await harness.post(mutation, variables: variables, authorization: "Bearer \(bearer)")
    }

    private func states(_ harness: Harness, as manager: String) async throws -> [String?] {
        try await enrollment.listed(harness, as: manager).map { $0["state"] as? String }
    }

    private func grantCount(_ harness: Harness, as manager: String) async throws -> Int {
        let reply = try await harness.post(GrantManagementTests.grants, authorization: "Bearer \(manager)")
        let grants = (reply.data?["koineManagement"] as? [String: Any])?["grants"] as? [[String: Any]]
        return try #require(grants).count
    }

    /// The one error of a refused action: its classification and its reason.
    private static func refusal(
        _ reply: Harness.Reply, of field: String
    ) throws -> (kind: String?, reason: String?, requestState: String?) {
        #expect(reply.status == 200)
        #expect(reply.data?[field] is NSNull)
        #expect(reply.errors.count == 1)
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == [field])
        let extensions = try #require(error["extensions"] as? [String: Any])
        return (
            extensions["kind"] as? String, extensions["reason"] as? String,
            extensions["requestState"] as? String
        )
    }

    // MARK: Denial

    @Test func aManagerDeniesAndTheRequesterSeesItExplicitlyAcrossARestart() async throws {
        let (harness, manager) = try await enrollment.managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)

        let denial = try await decide(harness, Self.deny, ["id": receipt.id], as: manager)
        #expect(denial.status == 200)
        #expect(denial.errors.isEmpty)
        let denied = try #require(denial.data?["koineDenyGrantRequest"] as? [String: Any])
        #expect(denied["requestId"] as? String == receipt.id)
        #expect(denied["comparisonCode"] as? String == receipt.code)
        #expect(denied["state"] as? String == "DENIED")
        #expect(denied["grant"] is NSNull)

        // The design's own poll, under the secret alone.
        let poll = try GrantEnrollmentTests.designOperation("PollOwnGrantRequest")
        for restarted in [false, true] {
            if restarted { try await harness.restart() }
            let reply = try await harness.post(poll, authorization: "Bearer \(secret.encoded)")
            #expect(reply.status == 200)
            #expect(reply.errors.isEmpty)
            let own = try #require(reply.data?["koineGrantRequest"] as? [String: Any])
            #expect(own["state"] as? String == "DENIED")
            #expect(own["grant"] is NSNull)
            #expect(try await states(harness, as: manager) == ["DENIED"])
        }

        // Denied is still status-only, and no grant came of it.
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(secret.encoded)")
        #expect(koine.json["data"] is NSNull)
        let mixed = try await harness.post(
            "{ koineGrantRequest { state } management: koineManagement { requests { requestId } } }",
            authorization: "Bearer \(secret.encoded)"
        )
        #expect(mixed.data?["management"] is NSNull)
        try GrantEnrollmentTests.expectPermission(try #require(mixed.errors.first), path: ["management"])
        let introspection = try await harness.raw("{ __schema { types { name } } }", bearer: secret.encoded)
        #expect(introspection.status == 403)
        let selfApproval = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": ["koine:manage"]], as: secret.encoded
        )
        #expect(selfApproval.status == 403)
        #expect(try await grantCount(harness, as: manager) == 1)

        await harness.stop()
        let stored = try SQLiteGrantStore(
            path: harness.directory.appendingPathComponent("grants.sqlite").path
        ).request(id: receipt.id)
        #expect(stored?.state == .denied)
    }

    @Test func denyingRequiresManage() async throws {
        let (harness, manager) = try await enrollment.managed()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: [])
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        for bearer in [reader, secret.encoded] {
            let refused = try await decide(harness, Self.deny, ["id": receipt.id], as: bearer)
            #expect(refused.status == 403)
            #expect(refused.data == nil)
            try GrantEnrollmentTests.expectPermission(
                try #require(refused.errors.first), path: ["koineDenyGrantRequest"]
            )
        }
        #expect(try await states(harness, as: manager) == ["PENDING"])

        // The local console denies too.
        let console = try JSONSerialization.jsonObject(
            with: try await harness.server.console.execute(
                jsonBody: try Harness.requestBody(Self.deny, variables: ["id": receipt.id])
            )
        ) as? [String: Any]
        #expect(console?["errors"] == nil)
        #expect(try await states(harness, as: manager) == ["DENIED"])
        await harness.stop()
    }

    // MARK: Decision outcomes

    @Test func aRequestIdThatNamesNothingIsUnavailable() async throws {
        let (harness, manager) = try await enrollment.managed()
        _ = try await enrollment.enrol(harness, .generate())
        let approval = try await decide(
            harness, GrantEnrollmentTests.approve, ["id": "no-such-request", "capabilities": []], as: manager
        )
        #expect(try Self.refusal(approval, of: "koineApproveGrantRequest").kind == "unavailable")
        let denial = try await decide(harness, Self.deny, ["id": "no-such-request"], as: manager)
        #expect(try Self.refusal(denial, of: "koineDenyGrantRequest").kind == "unavailable")
        #expect(try await states(harness, as: manager) == ["PENDING"])
        await harness.stop()
    }

    @Test func aCapabilityThatWasNotRequestedIsAnInvalidSubsetAndChangesNothing() async throws {
        let (harness, manager) = try await enrollment.managed()
        let receipt = try await enrollment.enrol(harness, .generate(), capabilities: [])
        let approval = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": ["koine:manage"]], as: manager
        )
        let refusal = try Self.refusal(approval, of: "koineApproveGrantRequest")
        #expect(refusal.kind == "failed")
        #expect(refusal.reason == "invalid-subset")
        #expect(try await states(harness, as: manager) == ["PENDING"])
        #expect(try await grantCount(harness, as: manager) == 1)
        await harness.stop()
    }

    /// Approved, denied, and approved with its grant since revoked: each is
    /// decided, and neither decision moves it again.
    @Test(arguments: ["APPROVED", "DENIED", "REVOKED"])
    func aDecidedRequestIsNeverDecidedAgain(how: String) async throws {
        let (harness, manager) = try await enrollment.managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        if how == "DENIED" {
            #expect(try await decide(harness, Self.deny, ["id": receipt.id], as: manager).errors.isEmpty)
        } else {
            let approval = try await decide(
                harness, GrantEnrollmentTests.approve,
                ["id": receipt.id, "capabilities": ["koine:manage"]], as: manager
            )
            let grant = try #require(approval.data?["koineApproveGrantRequest"] as? [String: Any])
            if how == "REVOKED" {
                let revoked = try await decide(
                    harness, GrantManagementTests.revoke, ["id": try #require(grant["grantId"] as? String)],
                    as: manager
                )
                #expect(revoked.errors.isEmpty)
            }
        }
        let state = how == "DENIED" ? "DENIED" : "APPROVED"
        let grants = try await grantCount(harness, as: manager)

        let approval = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": ["koine:manage"]], as: manager
        )
        let again = try Self.refusal(approval, of: "koineApproveGrantRequest")
        #expect(again.kind == "failed")
        #expect(again.reason == "already-decided")
        #expect(again.requestState == state)
        let denial = try Self.refusal(
            try await decide(harness, Self.deny, ["id": receipt.id], as: manager),
            of: "koineDenyGrantRequest"
        )
        #expect(denial.kind == "failed")
        #expect(denial.reason == "already-decided")
        #expect(denial.requestState == state)

        #expect(try await states(harness, as: manager) == [state])
        #expect(try await grantCount(harness, as: manager) == grants)
        // Nothing was resurrected: the secret is what it was before the attempts.
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(secret.encoded)")
        #expect(koine.status == (how == "REVOKED" ? 401 : 200))
        #expect((koine.json["data"] is NSNull) == (how == "DENIED"))
        await harness.stop()
    }

    // MARK: Retry and conflict

    private func request(
        _ harness: Harness, digest: String, label: String, capabilities: [String]
    ) async throws -> Harness.Reply {
        try await harness.post(
            try GrantEnrollmentTests.designOperation("RequestDesktopGrant"),
            variables: ["input": [
                "clientLabel": label, "credentialDigest": digest, "capabilities": capabilities,
            ]],
            authorization: nil
        )
    }

    @Test(arguments: ["PENDING", "APPROVED", "DENIED", "REVOKED"])
    func anIdenticalRetryReturnsTheOriginalReceiptAndCreatesNothing(state: String) async throws {
        let harness = try await Harness(providerRoots: [try NativeProviderTests.fixtureRoot()])
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(
            harness, secret, capabilities: ["fixture:read", "koine:manage"]
        )
        if state == "APPROVED" || state == "REVOKED" {
            let approval = try await decide(
                harness, GrantEnrollmentTests.approve,
                ["id": receipt.id, "capabilities": ["fixture:read"]], as: manager
            )
            let grant = approval.data?["koineApproveGrantRequest"] as? [String: Any]
            if state == "REVOKED" {
                _ = try await decide(
                    harness, GrantManagementTests.revoke, ["id": try #require(grant?["grantId"] as? String)],
                    as: manager
                )
            }
        } else if state == "DENIED" {
            _ = try await decide(harness, Self.deny, ["id": receipt.id], as: manager)
        }
        let grants = try await grantCount(harness, as: manager)

        // The set is compared: order and duplicates are not part of it.
        let retry = try await request(
            harness, digest: secret.digest, label: "enrollee",
            capabilities: ["koine:manage", "fixture:read", "koine:manage"]
        )
        #expect(retry.status == 200)
        #expect(retry.errors.isEmpty)
        let again = try #require(retry.data?["koineRequestGrant"] as? [String: String])
        #expect(again == ["requestId": receipt.id, "comparisonCode": receipt.code])

        let listing = try await enrollment.listed(harness, as: manager)
        #expect(listing.count == 1)
        #expect(listing[0]["state"] as? String == (state == "REVOKED" ? "APPROVED" : state))
        #expect(listing[0]["requestedCapabilities"] as? [String] == ["fixture:read", "koine:manage"])
        #expect(try await grantCount(harness, as: manager) == grants)
        await harness.stop()
    }

    @Test func theSameDigestWithADifferentLabelOrSetIsAConflictAndChangesNothing() async throws {
        let (harness, manager) = try await enrollment.managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret, capabilities: ["koine:manage"])
        let changed: [(String, [String])] = [("someone else", ["koine:manage"]), ("enrollee", [])]
        for (label, capabilities) in changed {
            let reply = try await request(
                harness, digest: secret.digest, label: label, capabilities: capabilities
            )
            let refusal = try Self.refusal(reply, of: "koineRequestGrant")
            #expect(refusal.kind == "failed")
            #expect(refusal.reason == "enrollment-conflict")
            // A conflict tells the caller nothing of the request it collided with.
            let text = String(describing: reply.json)
            #expect(!text.contains(receipt.id) && !text.contains(receipt.code))
        }
        let listing = try await enrollment.listed(harness, as: manager)
        #expect(listing.count == 1)
        #expect(listing[0]["clientLabel"] as? String == "enrollee")
        #expect(listing[0]["requestedCapabilities"] as? [String] == ["koine:manage"])
        await harness.stop()
    }

    // MARK: Digest uniqueness

    @Test(arguments: [false, true])
    func aDigestThatBelongsToAGrantCannotStartARequest(revoked: Bool) async throws {
        let (harness, manager) = try await enrollment.managed()
        let created = try await decide(
            harness, Harness.createGrant, ["label": "existing", "capabilities": []], as: manager
        )
        let grant = try #require(created.data?["koineCreateGrant"] as? [String: Any])
        let credential = try #require(grant["credential"] as? String)
        if revoked {
            let id = try #require((grant["grant"] as? [String: Any])?["grantId"] as? String)
            _ = try await decide(harness, GrantManagementTests.revoke, ["id": id], as: manager)
        }
        let reply = try await request(
            harness, digest: try #require(Credential.digest(ofPresented: credential)),
            label: "existing", capabilities: []
        )
        let refusal = try Self.refusal(reply, of: "koineRequestGrant")
        #expect(refusal.kind == "failed")
        #expect(refusal.reason == "credential-in-use")
        #expect(try await enrollment.listed(harness, as: manager).isEmpty)
        // The secret is what it was: that grant, or nothing.
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        #expect(koine.status == (revoked ? 401 : 200))
        await harness.stop()
    }

    /// The store owns uniqueness across both tables, in the inserting
    /// transaction, so a manual grant's random collision with a request is the
    /// same `duplicateDigest` its collision with a grant is.
    @Test func theStoreRefusesAGrantWhoseDigestBelongsToARequest() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = try SQLiteGrantStore(path: directory.appendingPathComponent("grants.sqlite").path)
        let digest = Credential.generate().digest
        let request = GrantRequestRecord(
            id: "r", clientLabel: "x", requestedCapabilities: [], credentialDigest: digest,
            comparisonCode: "c", state: .pending, grantId: nil, submittedAt: Date()
        )
        try store.insertRequest(request)
        let twin = GrantRecord(
            id: "g", clientLabel: "x", capabilities: [], credentialDigest: digest, state: .active
        )
        #expect(throws: GrantStoreError.duplicateDigest) { try store.insert(twin) }
        #expect(try store.grants().isEmpty)

        // Approval binds the request's own digest, and only approval may.
        #expect(try store.approve(requestId: "r", as: twin, at: Date()))
        #expect(throws: GrantStoreError.duplicateDigest) {
            try store.insertRequest(
                GrantRequestRecord(
                    id: "r2", clientLabel: "x", requestedCapabilities: [], credentialDigest: digest,
                    comparisonCode: "c", state: .pending, grantId: nil, submittedAt: Date()
                )
            )
        }
        #expect(try store.requests().count == 1)
    }

    /// Approval is one transaction: when the grant cannot be inserted, the
    /// request's move to `APPROVED` rolls back with it. Such a pair predates the
    /// cross-table check, so it is seeded beneath the store.
    @Test func anApprovalWhoseGrantCannotBeInsertedLeavesTheRequestPending() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let path = directory.appendingPathComponent("grants.sqlite").path
        let store = try SQLiteGrantStore(path: path)
        let digest = Credential.generate().digest
        try store.insert(
            GrantRecord(id: "held", clientLabel: "x", capabilities: [], credentialDigest: digest, state: .active)
        )
        var db: OpaquePointer?
        #expect(sqlite3_open(path, &db) == SQLITE_OK)
        #expect(sqlite3_exec(
            db, "INSERT INTO grant_requests VALUES ('r', 'x', '[]', '\(digest)', 'c', 'PENDING', NULL, 0, NULL)",
            nil, nil, nil
        ) == SQLITE_OK)
        sqlite3_close(db)

        #expect(throws: GrantStoreError.duplicateDigest) {
            try store.approve(
                requestId: "r",
                as: GrantRecord(id: "twin", clientLabel: "x", capabilities: [], credentialDigest: digest, state: .active),
                at: Date()
            )
        }
        #expect(try store.request(id: "r")?.state == .pending)
        #expect(try store.request(id: "r")?.grantId == nil)
        #expect(try store.grants().map(\.id) == ["held"])
    }

    // MARK: Revocation of the approved grant

    @Test func afterItsGrantIsRevokedTheSecretIs401ForEverything() async throws {
        let (harness, manager) = try await enrollment.managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        let approval = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": ["koine:manage"]], as: manager
        )
        let grant = try #require(approval.data?["koineApproveGrantRequest"] as? [String: Any])

        let poll = harness.requestBytes(
            headers: ["Authorization": "Bearer \(secret.encoded)"],
            body: try Harness.requestBody(GrantEnrollmentTests.ownRequest, variables: [:])
        )
        let connection = try RawConnection(port: harness.port)
        let exchange: @Sendable () throws -> RawResponse = {
            connection.send(poll)
            return try connection.readResponse()
        }
        let before = try await offPool(exchange)
        #expect(before.status == 200)
        #expect(before.headers["connection"] == "keep-alive")

        _ = try await decide(
            harness, GrantManagementTests.revoke, ["id": try #require(grant["grantId"] as? String)],
            as: manager
        )
        #expect(try await offPool(exchange).status == 401)

        for restarted in [false, true] {
            if restarted { try await harness.restart() }
            for query in [GrantEnrollmentTests.ownRequest, Harness.koine, GrantEnrollmentTests.requests] {
                let reply = try await harness.post(query, authorization: "Bearer \(secret.encoded)")
                #expect(reply.status == 401)
            }
        }
        // The manager still sees what happened.
        let listing = try await enrollment.listed(harness, as: manager)
        #expect(listing[0]["state"] as? String == "APPROVED")
        #expect((listing[0]["grant"] as? [String: Any])?["state"] as? String == "REVOKED")
        await harness.stop()
    }

    // MARK: The acceptance case

    /// docs/specs/machine.md, "Test seams and acceptance", the management row:
    /// a pending requester cannot approve itself, enumerate others, or use
    /// provider operations.
    @Test func aPendingRequesterCannotApproveItselfEnumerateOthersOrUseProviderOperations() async throws {
        let harness = try await Harness(providerRoots: [try NativeProviderTests.fixtureRoot()])
        let manager = try await harness.consoleGrant(
            label: "manager", capabilities: ["koine:manage", "fixture:read"]
        )
        let secret = Credential.generate()
        let own = try await enrollment.enrol(
            harness, secret, capabilities: ["koine:manage", "fixture:read", "fixture:control"]
        )
        _ = try await enrollment.enrol(harness, .generate(), label: "other")
        let bearer = "Bearer \(secret.encoded)"

        let approval = try await harness.post(
            GrantEnrollmentTests.approve,
            variables: ["id": own.id, "capabilities": ["koine:manage"]], authorization: bearer
        )
        #expect(approval.status == 403)
        #expect(approval.data == nil)
        try GrantEnrollmentTests.expectPermission(
            try #require(approval.errors.first), path: ["koineApproveGrantRequest"]
        )

        let listing = try await harness.post(GrantEnrollmentTests.requests, authorization: bearer)
        #expect(listing.data?["koineManagement"] is NSNull)
        try GrantEnrollmentTests.expectPermission(
            try #require(listing.errors.first), path: ["koineManagement"]
        )

        let read = try await harness.post("{ fixtureItems { name } }", authorization: bearer)
        #expect((read.data?["fixtureItems"] as? [Any]) == nil)
        try GrantEnrollmentTests.expectPermission(try #require(read.errors.first), path: ["fixtureItems"])
        let control = try await harness.post(
            "mutation($ref: Reference!) { fixtureRenameItem(ref: $ref, name: \"taken\") { ref } }",
            variables: ["ref": ProviderAuthorizationTests.first], authorization: bearer
        )
        #expect(control.status == 403)
        #expect(control.data == nil)
        try GrantEnrollmentTests.expectPermission(
            try #require(control.errors.first), path: ["fixtureRenameItem"]
        )

        // Nothing moved: both requests pending, the item unrenamed.
        #expect(try await states(harness, as: manager) == ["PENDING", "PENDING"])
        let items = try await harness.post("{ fixtureItems { name } }", authorization: "Bearer \(manager)")
        #expect((items.data?["fixtureItems"] as? [[String: Any]])?.map { $0["name"] as? String } == ["first", "second"])
        await harness.stop()
    }
}
