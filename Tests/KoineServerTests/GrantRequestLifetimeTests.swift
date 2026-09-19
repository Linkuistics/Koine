import Foundation
import KoineCore
import KoineServer
import KoineSQLiteStore
import Testing

/// Enrollment bounded in time and volume, over loopback HTTP. Time is the
/// server's injected source, moved by the test: nothing here waits.
@Suite struct GrantRequestLifetimeTests {
    private let enrollment = GrantEnrollmentTests()

    private static let hour: TimeInterval = 3_600
    private static let day: TimeInterval = 24 * hour

    private static let deny = """
        mutation Deny($id: ID!) { koineDenyGrantRequest(requestId: $id) { requestId state } }
        """

    private func managed(
        policy: RequestPolicy = .version1
    ) async throws -> (Harness, manager: String, TestClock) {
        let clock = TestClock()
        let harness = try await Harness(policy: policy, clock: clock)
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        return (harness, manager, clock)
    }

    private func decide(
        _ harness: Harness, _ mutation: String, _ variables: [String: Any], as bearer: String
    ) async throws -> Harness.Reply {
        try await harness.post(mutation, variables: variables, authorization: "Bearer \(bearer)")
    }

    private func ownState(_ harness: Harness, _ secret: Credential) async throws -> String? {
        let reply = try await harness.post(
            GrantEnrollmentTests.ownRequest, authorization: "Bearer \(secret.encoded)"
        )
        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        return (reply.data?["koineGrantRequest"] as? [String: Any])?["state"] as? String
    }

    private func states(_ harness: Harness, as manager: String) async throws -> [String?] {
        try await enrollment.listed(harness, as: manager).map { $0["state"] as? String }
    }

    /// The one error of a refused field: its classification and its reason.
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

    /// The requester's poll once its request's status is no longer retained.
    private func expectForgotten(_ harness: Harness, bearer: String) async throws {
        let reply = try await harness.post(
            GrantEnrollmentTests.ownRequest, authorization: "Bearer \(bearer)"
        )
        let refused = try Self.refusal(reply, of: "koineGrantRequest")
        #expect(refused.kind == "unavailable")
        #expect(refused.reason == nil)
    }

    // MARK: Expiry

    @Test func aRequestStillPendingAfter24HoursIsExpiredForEveryone() async throws {
        let (harness, manager, clock) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)

        clock.advance(by: Self.day - 1)
        #expect(try await ownState(harness, secret) == "PENDING")
        #expect(try await states(harness, as: manager) == ["PENDING"])

        clock.advance(by: 1)
        #expect(try await ownState(harness, secret) == "EXPIRED")
        #expect(try await states(harness, as: manager) == ["EXPIRED"])

        let approval = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": ["koine:manage"]], as: manager
        )
        let approved = try Self.refusal(approval, of: "koineApproveGrantRequest")
        #expect(approved.kind == "failed")
        #expect(approved.reason == "already-decided")
        #expect(approved.requestState == "EXPIRED")

        let denial = try await decide(harness, Self.deny, ["id": receipt.id], as: manager)
        let denied = try Self.refusal(denial, of: "koineDenyGrantRequest")
        #expect(denied.reason == "already-decided")
        #expect(denied.requestState == "EXPIRED")

        // Nothing was decided, and the secret is still status-only.
        #expect(try await ownState(harness, secret) == "EXPIRED")
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(secret.encoded)")
        #expect(!koine.errors.isEmpty)
        await harness.stop()
    }

    @Test func expiryHoldsAcrossARestartThatSpansTheDeadline() async throws {
        let (harness, manager, clock) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        clock.advance(by: Self.day - Self.hour)
        #expect(try await ownState(harness, secret) == "PENDING")

        await harness.stop()
        clock.advance(by: 2 * Self.hour)
        try await harness.restart()

        #expect(try await ownState(harness, secret) == "EXPIRED")
        #expect(try await states(harness, as: manager) == ["EXPIRED"])
        let approval = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": []], as: manager
        )
        #expect(try Self.refusal(approval, of: "koineApproveGrantRequest").requestState == "EXPIRED")
        await harness.stop()
    }

    @Test func anApprovedGrantNeverExpiresHoweverOldItsRequest() async throws {
        let (harness, manager, clock) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        clock.advance(by: Self.day - 1)
        let approval = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": ["koine:manage"]], as: manager
        )
        #expect(approval.errors.isEmpty)

        clock.advance(by: 2)
        #expect(try await ownState(harness, secret) == "APPROVED")

        clock.advance(by: 400 * Self.day)
        try await harness.restart()
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(secret.encoded)")
        #expect(koine.status == 200)
        let own = (koine.data?["koine"] as? [String: Any])?["ownGrant"] as? [String: Any]
        #expect(own?["state"] as? String == "ACTIVE")
        #expect(own?["capabilities"] as? [String] == ["koine:manage"])
        await harness.stop()
    }

    // MARK: Retention

    @Test func sevenDaysAfterADenialItsStatusIsUnavailableAndUnlisted() async throws {
        let (harness, manager, clock) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        clock.advance(by: Self.hour)
        #expect(try await decide(harness, Self.deny, ["id": receipt.id], as: manager).errors.isEmpty)

        clock.advance(by: 7 * Self.day - 1)
        #expect(try await ownState(harness, secret) == "DENIED")
        #expect(try await states(harness, as: manager) == ["DENIED"])

        clock.advance(by: 1)
        try await expectForgotten(harness, bearer: secret.encoded)
        #expect(try await states(harness, as: manager) == [])

        // A decision on it meets nothing, and the secret gained nothing.
        let denial = try await decide(harness, Self.deny, ["id": receipt.id], as: manager)
        #expect(try Self.refusal(denial, of: "koineDenyGrantRequest").kind == "unavailable")
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(secret.encoded)")
        #expect(!koine.errors.isEmpty)

        try await harness.restart()
        try await expectForgotten(harness, bearer: secret.encoded)
        await harness.stop()
    }

    @Test func anExpiredRequestIsRetainedSevenDaysFromItsExpiry() async throws {
        let (harness, manager, clock) = try await managed()
        let secret = Credential.generate()
        _ = try await enrollment.enrol(harness, secret)

        clock.advance(by: Self.day + 7 * Self.day - 1)
        #expect(try await ownState(harness, secret) == "EXPIRED")
        #expect(try await states(harness, as: manager) == ["EXPIRED"])

        clock.advance(by: 1)
        try await expectForgotten(harness, bearer: secret.encoded)
        #expect(try await states(harness, as: manager) == [])
        await harness.stop()
    }

    /// The spec's lookup rule has no exception for the grant: after retention the
    /// request is `unavailable` under it too. Null would say no request produced
    /// this grant, which is false. The grant is untouched.
    @Test func afterRetentionAnApprovedRequestIsUnavailableUnderItsActiveGrant() async throws {
        let (harness, manager, clock) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        _ = try await decide(
            harness, GrantEnrollmentTests.approve,
            ["id": receipt.id, "capabilities": ["koine:manage"]], as: manager
        )

        clock.advance(by: 7 * Self.day - 1)
        #expect(try await ownState(harness, secret) == "APPROVED")
        clock.advance(by: 1)
        try await expectForgotten(harness, bearer: secret.encoded)
        #expect(try await states(harness, as: manager) == [])

        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(secret.encoded)")
        #expect(koine.errors.isEmpty)
        let own = (koine.data?["koine"] as? [String: Any])?["ownGrant"] as? [String: Any]
        #expect(own?["state"] as? String == "ACTIVE")

        // A grant no request produced still reads null, not an error.
        let plain = try await harness.post(
            GrantEnrollmentTests.ownRequest, authorization: "Bearer \(manager)"
        )
        #expect(plain.errors.isEmpty)
        #expect(plain.data?["koineGrantRequest"] is NSNull)
        await harness.stop()
    }

    // MARK: Tombstones

    @Test(arguments: ["DENIED", "EXPIRED"])
    func aDigestOutlivesItsRequestsRetainedStatus(state: String) async throws {
        let (harness, manager, clock) = try await managed()
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret, label: "first")
        if state == "DENIED" {
            _ = try await decide(harness, Self.deny, ["id": receipt.id], as: manager)
        }
        clock.advance(by: 9 * Self.day)
        try await expectForgotten(harness, bearer: secret.encoded)

        // Neither the identical submission nor a changed one starts a request.
        for label in ["first", "second"] {
            let again = try await harness.post(
                try GrantEnrollmentTests.designOperation("RequestDesktopGrant"),
                variables: enrollment.input(secret, label: label), authorization: nil
            )
            let refused = try Self.refusal(again, of: "koineRequestGrant")
            #expect(refused.kind == "failed")
            #expect(refused.reason == "credential-in-use")
        }
        #expect(try await states(harness, as: manager) == [])

        // Nor can it become a manual grant: the store still holds the digest.
        await harness.stop()
        let store = try SQLiteGrantStore(
            path: harness.directory.appendingPathComponent("grants.sqlite").path
        )
        #expect(throws: GrantStoreError.duplicateDigest) {
            try store.insert(
                GrantRecord(
                    id: "manual", clientLabel: "x", capabilities: [],
                    credentialDigest: secret.digest, state: .active
                )
            )
        }
    }

    // MARK: The pending cap

    @Test func atTheCapANewRequestIsRefusedUntilADecisionOrExpiryFreesASlot() async throws {
        var policy = RequestPolicy.version1
        policy.maximumPendingRequests = 2
        policy.maximumEnrollmentsPerWindow = 100
        let (harness, manager, clock) = try await managed(policy: policy)
        let first = Credential.generate()
        let firstReceipt = try await enrollment.enrol(harness, first, label: "first")
        clock.advance(by: Self.hour)
        let second = try await enrollment.enrol(harness, Credential.generate(), label: "second")

        func attempt(_ credential: Credential) async throws -> Harness.Reply {
            try await harness.post(
                try GrantEnrollmentTests.designOperation("RequestDesktopGrant"),
                variables: enrollment.input(credential, label: "late"), authorization: nil
            )
        }
        let late = Credential.generate()
        let refused = try Self.refusal(try await attempt(late), of: "koineRequestGrant")
        #expect(refused.kind == "failed")
        #expect(refused.reason == "pending-request-limit")
        #expect(try await states(harness, as: manager) == ["PENDING", "PENDING"])
        // Nothing was stored: the refused secret is no principal at all.
        let poll = try await harness.post(
            GrantEnrollmentTests.ownRequest, authorization: "Bearer \(late.encoded)"
        )
        #expect(poll.status == 401)

        // A retry of a request that holds a slot is still answered.
        let retried = try await enrollment.enrol(harness, first, label: "first")
        #expect(retried.id == firstReceipt.id && retried.code == firstReceipt.code)

        // A decision frees a slot.
        _ = try await decide(harness, Self.deny, ["id": second.id], as: manager)
        _ = try await enrollment.enrol(harness, late, label: "late")
        #expect(try await attempt(Credential.generate()).errors.count == 1)

        // So does expiry: the first request is now a day old.
        clock.advance(by: 23 * Self.hour)
        #expect(try await states(harness, as: manager) == ["EXPIRED", "DENIED", "PENDING"])
        _ = try await enrollment.enrol(harness, Credential.generate(), label: "after expiry")
        await harness.stop()
    }

    // MARK: The enrollment rate limit

    @Test func anExhaustedEnrollmentBudgetRefusesOnlyAnonymousEnrollment() async throws {
        var policy = RequestPolicy.version1
        policy.maximumEnrollmentsPerWindow = 3
        policy.enrollmentWindow = .seconds(60)
        let (harness, manager, clock) = try await managed(policy: policy)
        let secret = Credential.generate()
        let receipt = try await enrollment.enrol(harness, secret)
        // A retry spends the budget like any other anonymous enrollment.
        _ = try await enrollment.enrol(harness, secret)
        clock.advance(by: 20)
        _ = try await enrollment.enrol(harness, Credential.generate(), label: "other")

        let operation = try GrantEnrollmentTests.designOperation("RequestDesktopGrant")
        let refusedSecret = Credential.generate()
        let refused = try await harness.raw(
            operation, variables: enrollment.input(refusedSecret), bearer: nil
        )
        #expect(refused.status == 429)
        #expect(refused.headers["retry-after"] == "40")
        #expect(!refused.hasData)
        #expect(refused.errors.count == 1)
        // A request error: it names no action, because none began.
        #expect((refused.errors.first?["path"] as? [Any])?.isEmpty == true)
        // Even the retry of a stored request is refused, and nothing was stored.
        #expect(try await harness.raw(operation, variables: enrollment.input(secret), bearer: nil).status == 429)
        #expect(try await states(harness, as: manager).count == 2)

        // At the same moment everyone else is served.
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(manager)")
        #expect(koine.status == 200 && koine.errors.isEmpty)
        #expect(try await ownState(harness, secret) == "PENDING")
        _ = try await harness.consoleGrant(label: "from the console", capabilities: [])
        let approval = try await decide(
            harness, GrantEnrollmentTests.approve, ["id": receipt.id, "capabilities": []], as: manager
        )
        #expect(approval.errors.isEmpty)
        // And a request without a credential that is not enrollment is still 401.
        #expect(try await harness.raw(Harness.koine, bearer: nil).status == 401)

        // The budget follows the server's time source.
        clock.advance(by: 39)
        #expect(try await harness.raw(operation, variables: enrollment.input(refusedSecret), bearer: nil).status == 429)
        clock.advance(by: 1)
        _ = try await enrollment.enrol(harness, refusedSecret)
        await harness.stop()
    }
}
