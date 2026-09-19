import Foundation
import KoineCore
import KoineServer
import Testing

/// The client-requested grant over loopback HTTP: a client with no credential
/// enrols itself, polls with its own secret, and a manager approves it.
@Suite struct GrantEnrollmentTests {
    /// One operation of docs/design/desktop-operations.graphql, text unchanged.
    static func designOperation(_ name: String) throws -> String {
        let file = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("docs/design/desktop-operations.graphql")
        let blocks = try String(contentsOf: file, encoding: .utf8).components(separatedBy: "\n\n")
        return try #require(blocks.first { $0.contains(" \(name)") })
    }

    static let requests = """
        { koineManagement { requests {
            requestId clientLabel comparisonCode requestedCapabilities state
            grant { grantId clientLabel capabilities state } } } }
        """

    static let ownRequest = """
        { koineGrantRequest {
            requestId clientLabel comparisonCode requestedCapabilities state
            grant { grantId clientLabel capabilities state } } }
        """

    static let approve = """
        mutation Approve($id: ID!, $capabilities: [String!]!) {
          koineApproveGrantRequest(requestId: $id, capabilities: $capabilities) {
            grantId clientLabel capabilities state
          }
        }
        """

    private func managed() async throws -> (Harness, manager: String) {
        let harness = try await Harness()
        return (harness, try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"]))
    }

    private func input(
        _ credential: Credential, label: String = "enrollee",
        capabilities: [String] = ["koine:manage"]
    ) -> [String: Any] {
        ["input": [
            "clientLabel": label, "credentialDigest": credential.digest,
            "capabilities": capabilities,
        ]]
    }

    /// Enrols anonymously with the design's own operation.
    private func enrol(
        _ harness: Harness, _ credential: Credential, label: String = "enrollee",
        capabilities: [String] = ["koine:manage"]
    ) async throws -> (id: String, code: String) {
        let reply = try await harness.post(
            try Self.designOperation("RequestDesktopGrant"),
            variables: input(credential, label: label, capabilities: capabilities),
            authorization: nil
        )
        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        let receipt = try #require(reply.data?["koineRequestGrant"] as? [String: String])
        #expect(Set(receipt.keys) == ["requestId", "comparisonCode"])
        return (try #require(receipt["requestId"]), try #require(receipt["comparisonCode"]))
    }

    private func listed(_ harness: Harness, as bearer: String) async throws -> [[String: Any]] {
        let reply = try await harness.post(Self.requests, authorization: "Bearer \(bearer)")
        let management = try #require(reply.data?["koineManagement"] as? [String: Any])
        return try #require(management["requests"] as? [[String: Any]])
    }

    private static func expectPermission(_ error: [String: Any], path: [String]) throws {
        #expect(error["path"] as? [String] == path)
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
    }

    // MARK: The whole workflow

    @Test func aClientEnrolsIsApprovedAndItsUnchangedSecretBecomesAGrant() async throws {
        let (harness, manager) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrol(harness, secret, capabilities: ["koine:manage"])
        #expect(!receipt.code.isEmpty && receipt.code.count <= 12)

        // Pending: the design's poll, under the secret alone.
        let poll = try Self.designOperation("PollOwnGrantRequest")
        let pending = try await harness.post(poll, authorization: "Bearer \(secret.encoded)")
        #expect(pending.status == 200)
        #expect(pending.errors.isEmpty)
        let status = try #require(pending.data?["koineGrantRequest"] as? [String: Any])
        #expect(status["state"] as? String == "PENDING")
        #expect(status["grant"] is NSNull)

        let full = try await harness.post(Self.ownRequest, authorization: "Bearer \(secret.encoded)")
        let own = try #require(full.data?["koineGrantRequest"] as? [String: Any])
        #expect(own["requestId"] as? String == receipt.id)
        #expect(own["clientLabel"] as? String == "enrollee")
        #expect(own["comparisonCode"] as? String == receipt.code)
        #expect(own["requestedCapabilities"] as? [String] == ["koine:manage"])

        // The manager sees the same request and approves it.
        let listing = try await listed(harness, as: manager)
        #expect(listing.map { $0["requestId"] as? String } == [receipt.id])
        #expect(listing[0]["comparisonCode"] as? String == receipt.code)
        #expect(listing[0]["state"] as? String == "PENDING")

        let approval = try await harness.raw(
            Self.approve, variables: ["id": receipt.id, "capabilities": ["koine:manage"]],
            bearer: manager
        )
        #expect(approval.status == 200)
        #expect(approval.errors.isEmpty)
        let grant = try #require(
            (approval.json["data"] as? [String: Any])?["koineApproveGrantRequest"] as? [String: Any]
        )
        #expect(grant["clientLabel"] as? String == "enrollee")
        #expect(grant["capabilities"] as? [String] == ["koine:manage"])
        #expect(grant["state"] as? String == "ACTIVE")
        let text = String(decoding: approval.body, as: UTF8.self)
        #expect(!text.contains(secret.encoded) && !text.contains(secret.digest))

        // The unchanged secret is now an ordinary grant.
        let approved = try await harness.raw(poll, bearer: secret.encoded)
        let after = try #require(
            (approved.json["data"] as? [String: Any])?["koineGrantRequest"] as? [String: Any]
        )
        #expect(after["state"] as? String == "APPROVED")
        let metadata = try #require(after["grant"] as? [String: Any])
        #expect(metadata["grantId"] as? String == grant["grantId"] as? String)
        #expect(metadata["capabilities"] as? [String] == ["koine:manage"])
        let polled = String(decoding: approved.body, as: UTF8.self)
        #expect(!polled.contains(secret.encoded) && !polled.contains(secret.digest))

        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(secret.encoded)")
        let ownGrant = try #require((koine.data?["koine"] as? [String: Any])?["ownGrant"] as? [String: Any])
        #expect(ownGrant["grantId"] as? String == grant["grantId"] as? String)
        // The approved capability works: it lists requests itself.
        #expect(try await listed(harness, as: secret.encoded).first?["state"] as? String == "APPROVED")

        // All of it survives a restart on the same data directory.
        try await harness.restart()
        let again = try await harness.post(Self.ownRequest, authorization: "Bearer \(secret.encoded)")
        let survived = try #require(again.data?["koineGrantRequest"] as? [String: Any])
        #expect(survived["requestId"] as? String == receipt.id)
        #expect(survived["comparisonCode"] as? String == receipt.code)
        #expect(survived["state"] as? String == "APPROVED")
        #expect((survived["grant"] as? [String: Any])?["grantId"] as? String == grant["grantId"] as? String)
        await harness.stop()
    }

    @Test func aPendingRequestSurvivesARestart() async throws {
        let (harness, manager) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrol(harness, secret)
        try await harness.restart()
        let poll = try await harness.post(Self.ownRequest, authorization: "Bearer \(secret.encoded)")
        let own = try #require(poll.data?["koineGrantRequest"] as? [String: Any])
        #expect(own["requestId"] as? String == receipt.id)
        #expect(own["state"] as? String == "PENDING")
        #expect(try await listed(harness, as: manager).count == 1)
        await harness.stop()
    }

    // MARK: Anonymous admission

    /// Without a bearer, only the single selected `koineRequestGrant` is
    /// admitted. Everything else is 401, and stores nothing.
    @Test(arguments: [
        "mutation($input: KoineRequestGrantInput!) { a: koineRequestGrant(input: $input) { requestId } b: koineRequestGrant(input: $input) { requestId } }",
        "mutation($input: KoineRequestGrantInput!) { koineRequestGrant(input: $input) { requestId } __typename }",
        "mutation($input: KoineRequestGrantInput!) { koineRequestGrant(input: $input) { requestId } koineRevokeGrant(grantId: \"x\") { grantId } }",
        "mutation($input: KoineRequestGrantInput!) { ...F } fragment F on Mutation { koineRequestGrant(input: $input) { requestId } koineCreateGrant(input: { clientLabel: \"x\", capabilities: [] }) { credential } }",
        "mutation($input: KoineRequestGrantInput!) { koineRequestGrant(input: $input) @skip(if: true) { requestId } }",
        "query($input: KoineRequestGrantInput) { koineGrantRequest { state } }",
        "query($input: KoineRequestGrantInput) { koine { contractVersion } }",
        "query($input: KoineRequestGrantInput) { __schema { queryType { name } } }",
        "mutation($input: KoineRequestGrantInput!) { koineRequestGrant(input: $input) { requestId }",
    ])
    func anythingButTheSingleEnrollmentActionIs401WithoutABearer(query: String) async throws {
        let (harness, manager) = try await managed()
        let reply = try await harness.post(
            query, variables: input(.generate()), authorization: nil
        )
        #expect(reply.status == 401)
        #expect(reply.data == nil)
        #expect(try await listed(harness, as: manager).isEmpty)
        await harness.stop()
    }

    /// The shape rule must read a skip condition as execution will. The library
    /// coerces a number to a Boolean, so `0` does not skip the second action.
    @Test(arguments: ["0", "1", "null", "\"x\""])
    func aSkipConditionThatIsNotABooleanNeverHidesASecondAction(value: String) async throws {
        let (harness, manager) = try await managed()
        let digests = [Credential.generate().digest, Credential.generate().digest]
        let body = """
            {"query": "mutation($a: KoineRequestGrantInput!, $b: KoineRequestGrantInput!, $s: Boolean = true) { koineRequestGrant(input: $a) { requestId } b: koineRequestGrant(input: $b) @skip(if: $s) { requestId } }",
             "variables": {"s": \(value),
               "a": {"clientLabel": "a", "credentialDigest": "\(digests[0])", "capabilities": []},
               "b": {"clientLabel": "b", "credentialDigest": "\(digests[1])", "capabilities": []}}}
            """
        let reply = try await harness.raw(bearer: nil, body: Data(body.utf8))
        #expect(reply.status == 401)
        #expect(try await listed(harness, as: manager).isEmpty)
        await harness.stop()
    }

    /// Nothing about the schema reaches a caller with no credential: a
    /// well-shaped enrollment that fails validation is 401 like the rest, and
    /// several operations with none named select nothing.
    @Test(arguments: [
        "mutation { koineRequestGrant(input: { clientLabel: \"x\", credentialDigest: \"\", capabilities: [] }) { requestId ... on KoineManagemen { x } } }",
        "mutation A($input: KoineRequestGrantInput!) { koineRequestGrant(input: $input) { requestId } } query B { koine { instanceId } }",
    ])
    func validationTellsAnAnonymousCallerNothing(query: String) async throws {
        let (harness, manager) = try await managed()
        let reply = try await harness.raw(query, variables: input(.generate()), bearer: nil)
        #expect(reply.status == 401)
        #expect(reply.body.isEmpty)
        #expect(try await listed(harness, as: manager).isEmpty)
        await harness.stop()
    }

    /// The library resolves introspection outside every field's authority check.
    @Test(arguments: [
        "{ __schema { types { name } } }",
        "{ koineGrantRequest { state } s: __schema { queryType { name } } }",
        "{ __type(name: \"KoineManagement\") { fields { name } } }",
        "{ ...F } fragment F on Query { __typename }",
    ])
    func aPendingSecretCannotIntrospect(query: String) async throws {
        let (harness, _) = try await managed()
        let secret = Credential.generate()
        _ = try await enrol(harness, secret)
        let reply = try await harness.raw(query, bearer: secret.encoded)
        #expect(reply.status == 403)
        #expect(!reply.hasData)
        try Self.expectPermission(try #require(reply.errors.first), path: [
            query.contains("s: __schema") ? "s" : query.contains("__type(") ? "__type"
                : query.contains("__typename") ? "__typename" : "__schema"
        ])
        // Nested under its own request, a meta-field discloses nothing.
        let nested = try await harness.post(
            "{ koineGrantRequest { __typename state } }", authorization: "Bearer \(secret.encoded)"
        )
        #expect(nested.errors.isEmpty)
        await harness.stop()
    }

    /// Skipped fields and unselected operations do not count, as for preflight.
    @Test func skippedFieldsAndUnselectedOperationsDoNotCount() async throws {
        let (harness, manager) = try await managed()
        let document = """
            mutation Enrol($input: KoineRequestGrantInput!) {
              koineRequestGrant(input: $input) { requestId comparisonCode }
              koineRevokeGrant(grantId: "x") @skip(if: true) { grantId }
            }
            query Other { koine { contractVersion } }
            """
        var body = input(.generate())
        let data = try JSONSerialization.data(
            withJSONObject: ["query": document, "variables": body, "operationName": "Enrol"]
        )
        let admitted = try await harness.raw(bearer: nil, body: data)
        #expect(admitted.status == 200)
        #expect(admitted.errors.isEmpty)
        #expect(try await listed(harness, as: manager).count == 1)

        // The same document, selecting the query, is not enrollment.
        body = input(.generate())
        let other = try JSONSerialization.data(
            withJSONObject: ["query": document, "variables": body, "operationName": "Other"]
        )
        #expect(try await harness.raw(bearer: nil, body: other).status == 401)
        #expect(try await listed(harness, as: manager).count == 1)
        await harness.stop()
    }

    /// A header that names no live credential is refused, never retried as anonymous.
    @Test func aBadBearerIsNotAnonymous() async throws {
        let (harness, manager) = try await managed()
        let enrolment = try Self.designOperation("RequestDesktopGrant")
        for authorization in ["Bearer not-a-credential", "Bearer \(Credential.generate().encoded)", "Basic x"] {
            let reply = try await harness.post(
                enrolment, variables: input(.generate()), authorization: authorization
            )
            #expect(reply.status == 401)
        }
        // Enrollment is anonymous only: an admitted client is refused in preflight.
        let reply = try await harness.post(
            enrolment, variables: input(.generate()), authorization: "Bearer \(manager)"
        )
        #expect(reply.status == 403)
        try Self.expectPermission(try #require(reply.errors.first), path: ["koineRequestGrant"])
        #expect(try await listed(harness, as: manager).isEmpty)
        await harness.stop()
    }

    // MARK: What a request must be

    @Test(arguments: [
        String(repeating: "A", count: 64),
        String(repeating: "a", count: 63),
        String(repeating: "a", count: 65),
        String(repeating: "g", count: 64),
        "",
    ])
    func aNoncanonicalDigestIsRefused(digest: String) async throws {
        let (harness, manager) = try await managed()
        let reply = try await harness.post(
            try Self.designOperation("RequestDesktopGrant"),
            variables: ["input": ["clientLabel": "x", "credentialDigest": digest, "capabilities": []]],
            authorization: nil
        )
        #expect(reply.data?["koineRequestGrant"] is NSNull)
        #expect(reply.errors.count == 1)
        #expect(try await listed(harness, as: manager).isEmpty)
        await harness.stop()
    }

    @Test func everyRequestedCapabilityMustBeAvailableAndTheSetIsStoredAsSubmitted() async throws {
        let (harness, manager) = try await managed()
        let reply = try await harness.post(
            try Self.designOperation("RequestDesktopGrant"),
            variables: input(.generate(), capabilities: ["koine:manage", "nonesuch:read"]),
            authorization: nil
        )
        #expect(reply.data?["koineRequestGrant"] is NSNull)
        #expect(try await listed(harness, as: manager).isEmpty)

        _ = try await enrol(harness, .generate(), label: "  As Typed ", capabilities: ["koine:manage"])
        let stored = try await listed(harness, as: manager)
        #expect(stored[0]["clientLabel"] as? String == "  As Typed ")
        #expect(stored[0]["requestedCapabilities"] as? [String] == ["koine:manage"])
        await harness.stop()
    }

    // MARK: The status-only principal

    @Test func aPendingSecretReadsItsOwnRequestAndNothingElse() async throws {
        let (harness, manager) = try await managed()
        let secret = Credential.generate()
        _ = try await enrol(harness, secret)
        let other = try await enrol(harness, .generate(), label: "other")
        let bearer = "Bearer \(secret.encoded)"

        // Mixed into the same operation as its own status, each is refused.
        let reply = try await harness.post(
            """
            { koineGrantRequest { clientLabel state grant { grantId } }
              management: koineManagement { requests { requestId } grants { grantId } } }
            """,
            authorization: bearer
        )
        #expect(reply.status == 200)
        let data = try #require(reply.data)
        #expect((data["koineGrantRequest"] as? [String: Any])?["clientLabel"] as? String == "enrollee")
        #expect(data["management"] is NSNull)
        #expect(reply.errors.count == 1)
        try Self.expectPermission(try #require(reply.errors.first), path: ["management"])

        // `koine` is non-null, so its refusal takes all of `data`; alone or mixed.
        for query in ["{ koine { contractVersion } }", "{ koineGrantRequest { state } koine { instanceId } }"] {
            let refused = try await harness.post(query, authorization: bearer)
            #expect(refused.status == 200)
            #expect(refused.json["data"] is NSNull)
            try Self.expectPermission(try #require(refused.errors.first), path: ["koine"])
        }

        // Every mutation is refused in preflight, its own approval included.
        let mutations: [(String, [String: Any], String)] = [
            (Self.approve, ["id": other.id, "capabilities": []], "koineApproveGrantRequest"),
            (Harness.createGrant, ["label": "x", "capabilities": []], "koineCreateGrant"),
            (GrantManagementTests.revoke, ["id": "x"], "koineRevokeGrant"),
            (try Self.designOperation("RequestDesktopGrant"), input(.generate()), "koineRequestGrant"),
        ]
        for (mutation, variables, field) in mutations {
            let refused = try await harness.post(mutation, variables: variables, authorization: bearer)
            #expect(refused.status == 403)
            #expect(refused.data == nil)
            try Self.expectPermission(try #require(refused.errors.first), path: [field])
        }
        let selfApproval = try await harness.post(
            Self.approve,
            variables: ["id": try await listed(harness, as: manager)[0]["requestId"] as Any, "capabilities": ["koine:manage"]],
            authorization: bearer
        )
        #expect(selfApproval.status == 403)

        // Nothing changed: two pending requests, one grant.
        #expect(try await listed(harness, as: manager).map { $0["state"] as? String } == ["PENDING", "PENDING"])
        let still = try await harness.post(Harness.koine, authorization: bearer)
        #expect(still.json["data"] is NSNull)
        await harness.stop()
    }

    @Test func aGrantNoRequestProducedHasNoRequest() async throws {
        let (harness, manager) = try await managed()
        _ = try await enrol(harness, .generate())
        let reply = try await harness.post(Self.ownRequest, authorization: "Bearer \(manager)")
        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        #expect(reply.data?["koineGrantRequest"] is NSNull)
        await harness.stop()
    }

    // MARK: Management

    @Test func listingAndApprovingRequireManage() async throws {
        let (harness, manager) = try await managed()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: [])
        let receipt = try await enrol(harness, .generate())

        let listing = try await harness.post(Self.requests, authorization: "Bearer \(reader)")
        #expect(listing.data?["koineManagement"] is NSNull)
        let error = try #require(listing.errors.first)
        try Self.expectPermission(error, path: ["koineManagement"])
        #expect((error["extensions"] as? [String: Any])?["requiredCapability"] as? String == "koine:manage")

        let approval = try await harness.post(
            Self.approve, variables: ["id": receipt.id, "capabilities": []],
            authorization: "Bearer \(reader)"
        )
        #expect(approval.status == 403)
        #expect(try await listed(harness, as: manager)[0]["state"] as? String == "PENDING")

        // The local console lists them too.
        let console = try JSONSerialization.jsonObject(
            with: try await harness.server.console.execute(
                jsonBody: try Harness.requestBody(Self.requests, variables: [:])
            )
        ) as? [String: Any]
        let management = (console?["data"] as? [String: Any])?["koineManagement"] as? [String: Any]
        #expect((management?["requests"] as? [[String: Any]])?.count == 1)
        await harness.stop()
    }

    @Test func approvalGrantsTheApprovedSubsetOnly() async throws {
        let (harness, manager) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrol(harness, secret, capabilities: ["koine:manage"])
        let approval = try await harness.post(
            Self.approve, variables: ["id": receipt.id, "capabilities": []],
            authorization: "Bearer \(manager)"
        )
        #expect(approval.errors.isEmpty)
        let denied = try await harness.post(Self.requests, authorization: "Bearer \(secret.encoded)")
        #expect(denied.data?["koineManagement"] is NSNull)
        let own = try await harness.post(Self.ownRequest, authorization: "Bearer \(secret.encoded)")
        let request = try #require(own.data?["koineGrantRequest"] as? [String: Any])
        #expect(request["requestedCapabilities"] as? [String] == ["koine:manage"])
        #expect((request["grant"] as? [String: Any])?["capabilities"] as? [String] == [])
        await harness.stop()
    }

    /// Made precise by a later leaf; here each must refuse and change nothing.
    @Test func approvalRefusesAMissingRequestACapabilityNotRequestedAndASecondDecision() async throws {
        let (harness, manager) = try await managed()
        let receipt = try await enrol(harness, .generate(), capabilities: [])
        func approve(_ id: String, _ capabilities: [String]) async throws -> Harness.Reply {
            try await harness.post(
                Self.approve, variables: ["id": id, "capabilities": capabilities],
                authorization: "Bearer \(manager)"
            )
        }
        for refused in [try await approve("no-such-request", []), try await approve(receipt.id, ["koine:manage"])] {
            #expect(refused.data?["koineApproveGrantRequest"] is NSNull)
            #expect(refused.errors.count == 1)
        }
        #expect(try await listed(harness, as: manager)[0]["state"] as? String == "PENDING")

        #expect(try await approve(receipt.id, []).errors.isEmpty)
        let second = try await approve(receipt.id, [])
        #expect(second.data?["koineApproveGrantRequest"] is NSNull)
        #expect(second.errors.count == 1)
        // One grant from the one approval, plus the manager.
        let reply = try await harness.post(GrantManagementTests.grants, authorization: "Bearer \(manager)")
        let listedGrants = (reply.data?["koineManagement"] as? [String: Any])?["grants"] as? [[String: Any]]
        #expect(listedGrants?.count == 2)
        await harness.stop()
    }

    /// A request whose digest already belongs to a grant never becomes a second
    /// identity: the secret stays that grant's, and approval fails whole.
    @Test func approvingADigestThatIsAlreadyAGrantCreatesNothing() async throws {
        let (harness, manager) = try await managed()
        let existing = try await harness.consoleGrant(label: "existing", capabilities: [])
        let digest = try #require(Credential.digest(ofPresented: existing))
        let reply = try await harness.post(
            try Self.designOperation("RequestDesktopGrant"),
            variables: ["input": ["clientLabel": "twin", "credentialDigest": digest, "capabilities": ["koine:manage"]]],
            authorization: nil
        )
        guard let receipt = reply.data?["koineRequestGrant"] as? [String: String],
            let id = receipt["requestId"]
        else { await harness.stop(); return }  // refusing the request outright is as safe

        // The secret is still the existing grant, not a requester.
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(existing)")
        #expect(((koine.data?["koine"] as? [String: Any])?["ownGrant"] as? [String: Any])?["clientLabel"] as? String == "existing")

        let approval = try await harness.post(
            Self.approve, variables: ["id": id, "capabilities": ["koine:manage"]],
            authorization: "Bearer \(manager)"
        )
        #expect(approval.data?["koineApproveGrantRequest"] is NSNull)
        #expect(approval.errors.count == 1)
        #expect(try await listed(harness, as: manager)[0]["state"] as? String == "PENDING")
        let denied = try await harness.post(Self.requests, authorization: "Bearer \(existing)")
        #expect(denied.data?["koineManagement"] is NSNull)
        await harness.stop()
    }
}
