import Foundation
import KoineServer
import Testing

@testable import KoineCore

/// A `GrantStore` a test scripts: it counts calls, fails the operations it is
/// told to, and otherwise behaves as a store. Nothing in the engine knows it.
final class ScriptedStore: GrantStore, @unchecked Sendable {
    enum Operation: Hashable { case insert, grants, grant, revoke, approve, deny }
    struct Failure: Error {}

    private let lock = NSLock()
    private var records: [GrantRecord] = []
    private var requestRecords: [GrantRequestRecord] = []
    private var failing: Set<Operation> = []
    private var calls: [Operation: Int] = [:]
    private var grantReadsAllowed: Int?
    private var collisions = 0

    /// The next `count` grant inserts meet a digest that is already taken.
    func collide(inserts count: Int) { lock.withLock { collisions = count } }

    func fail(_ operations: Operation...) { lock.withLock { failing = Set(operations) } }

    /// The next `count` reads of one grant succeed; the read after them throws.
    func failGrantRead(after count: Int) { lock.withLock { grantReadsAllowed = count } }

    func count(_ operation: Operation) -> Int { lock.withLock { calls[operation] ?? 0 } }

    /// The records as stored, read without counting or failing.
    var stored: [GrantRecord] { lock.withLock { records } }
    var storedRequests: [GrantRequestRecord] { lock.withLock { requestRecords } }

    private func enter(_ operation: Operation) throws {
        calls[operation, default: 0] += 1
        if failing.contains(operation) { throw Failure() }
        if operation == .grant, let allowed = grantReadsAllowed {
            if allowed == 0 { throw Failure() }
            grantReadsAllowed = allowed - 1
        }
    }

    func insert(_ grant: GrantRecord) throws {
        try lock.withLock {
            try enter(.insert)
            if collisions > 0 {
                collisions -= 1
                throw GrantStoreError.duplicateDigest
            }
            try unique(grant.credentialDigest)
            records.append(grant)
        }
    }

    /// A digest names one thing across requests and grants, as in the real store.
    private func unique(_ digest: String) throws {
        guard !records.contains(where: { $0.credentialDigest == digest }),
            !requestRecords.contains(where: { $0.credentialDigest == digest })
        else { throw GrantStoreError.duplicateDigest }
    }

    func grants() throws -> [GrantRecord] {
        try lock.withLock {
            try enter(.grants)
            return records
        }
    }

    func grant(id: String) throws -> GrantRecord? {
        try lock.withLock {
            try enter(.grant)
            return records.first { $0.id == id }
        }
    }

    func revoke(id: String) throws -> GrantRecord? {
        try lock.withLock {
            try enter(.revoke)
            guard let index = records.firstIndex(where: { $0.id == id }) else { return nil }
            let old = records[index]
            records[index] = GrantRecord(
                id: old.id, clientLabel: old.clientLabel, capabilities: old.capabilities,
                credentialDigest: old.credentialDigest, state: .revoked
            )
            return records[index]
        }
    }

    func insertRequest(_ request: GrantRequestRecord) throws {
        try lock.withLock {
            try unique(request.credentialDigest)
            requestRecords.append(request)
        }
    }

    func requests() throws -> [GrantRequestRecord] { lock.withLock { requestRecords } }

    func request(id: String) throws -> GrantRequestRecord? {
        lock.withLock { requestRecords.first { $0.id == id } }
    }

    func approve(requestId: String, as grant: GrantRecord) throws -> Bool {
        try lock.withLock {
            try enter(.approve)
            guard let index = requestRecords.firstIndex(where: { $0.id == requestId }),
                requestRecords[index].state == .pending
            else { return false }
            let old = requestRecords[index]
            requestRecords[index] = GrantRequestRecord(
                id: old.id, clientLabel: old.clientLabel,
                requestedCapabilities: old.requestedCapabilities,
                credentialDigest: old.credentialDigest, comparisonCode: old.comparisonCode,
                state: .approved, grantId: grant.id
            )
            records.append(grant)
            return true
        }
    }

    func deny(requestId: String) throws -> Bool {
        try lock.withLock {
            try enter(.deny)
            guard let index = requestRecords.firstIndex(where: { $0.id == requestId }),
                requestRecords[index].state == .pending
            else { return false }
            let old = requestRecords[index]
            requestRecords[index] = GrantRequestRecord(
                id: old.id, clientLabel: old.clientLabel,
                requestedCapabilities: old.requestedCapabilities,
                credentialDigest: old.credentialDigest, comparisonCode: old.comparisonCode,
                state: .denied, grantId: nil
            )
            return true
        }
    }
}

/// An engine over a scripted store, with the ordering hook set per test.
private final class Bench: @unchecked Sendable {
    let store = ScriptedStore()
    private(set) var engine: Engine!
    private let lock = NSLock()
    private var hook: OrderingHook = { _ in }
    private var seen: [OrderingPoint] = []

    init() throws {
        engine = try Engine(store: store, instanceId: "bench-instance", policy: .version1) {
            [unowned self] point in
            let hook = self.lock.withLock {
                self.seen.append(point)
                return self.hook
            }
            await hook(point)
        }
    }

    var points: [OrderingPoint] { lock.withLock { seen } }

    /// Runs `body` the first time execution reaches `point`.
    func when(_ point: OrderingPoint, _ body: @escaping @Sendable () async -> Void) {
        let fired = Fired()
        lock.withLock {
            hook = { reached in
                guard reached == point, fired.first() else { return }
                await body()
            }
        }
    }

    struct Reply {
        let outcome: EngineResponse.Outcome
        let body: String
        let json: [String: Any]
        var data: [String: Any]? { json["data"] as? [String: Any] }
        var errors: [[String: Any]] { json["errors"] as? [[String: Any]] ?? [] }
        func kind(at path: [String]) -> String? {
            let error = errors.first { $0["path"] as? [String] == path }
            return (error?["extensions"] as? [String: Any])?["kind"] as? String
        }
    }

    func run(
        _ query: String, variables: [String: Any] = [:], as principal: Principal
    ) async throws -> Reply {
        let request = try EngineRequest(
            jsonBody: try Harness.requestBody(query, variables: variables)
        )
        let response = await engine.execute(request, as: principal)
        return Reply(
            outcome: response.outcome, body: String(decoding: response.body, as: UTF8.self),
            json: try JSONSerialization.jsonObject(with: response.body) as? [String: Any] ?? [:]
        )
    }

    /// A grant minted by the console: its ID, credential and principal.
    func grant(_ label: String, _ capabilities: [String] = ["koine:manage"]) async throws
        -> (id: String, credential: String, principal: Principal)
    {
        let reply = try await run(
            Harness.createGrant, variables: ["label": label, "capabilities": capabilities],
            as: .localConsole
        )
        let created = try #require(reply.data?["koineCreateGrant"] as? [String: Any])
        let id = try #require((created["grant"] as? [String: Any])?["grantId"] as? String)
        lock.withLock { seen = [] }  // `points` records the test's own operation only
        return (id, try #require(created["credential"] as? String), .grant(id: id))
    }

    /// Revokes through the real management action, as the console.
    func revoke(_ id: String) async {
        let reply = try? await run(RevocationOrderingTests.revoke, variables: ["id": id], as: .localConsole)
        #expect(reply?.errors.isEmpty == true)
    }

    func state(of id: String) -> GrantState? { store.stored.first { $0.id == id }?.state }
}

private final class Fired: @unchecked Sendable {
    private let lock = NSLock()
    private var done = false
    func first() -> Bool {
        lock.withLock {
            defer { done = true }
            return !done
        }
    }
}

private func isOutcome(_ outcome: EngineResponse.Outcome, _ expected: EngineResponse.Outcome) -> Bool {
    switch (outcome, expected) {
    case (.executed, .executed), (.invalidRequest, .invalidRequest),
        (.unauthenticated, .unauthenticated), (.forbidden, .forbidden):
        return true
    default:
        return false
    }
}

/// The serialized authority boundary under forced ordering, and the store
/// failure cases. Orders are forced at the engine's internal ordering points by
/// running the real revocation there; no thread races and nothing is sampled.
/// Revocation between two actions of one operation, and revocation seen on a
/// keep-alive connection and after restart, are `GrantManagementTests`'.
@Suite struct RevocationOrderingTests {
    static let revoke = "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { __typename } }"
    static let createLate = """
        mutation { koineCreateGrant(input: { clientLabel: "late", capabilities: [] }) { __typename } }
        """

    // MARK: Ordering

    @Test func revocationBetweenPreflightAndDispatchPreventsTheDispatch() async throws {
        let bench = try Bench()
        let client = try await bench.grant("client")
        bench.when(.preflightPassed) { await bench.revoke(client.id) }

        let reply = try await bench.run(Self.createLate, as: client.principal)

        // Preflight admitted the operation, so it executed; the action did not.
        #expect(isOutcome(reply.outcome, .executed))
        #expect(reply.data?["koineCreateGrant"] is NSNull)
        #expect(reply.kind(at: ["koineCreateGrant"]) == "permission")
        #expect(!bench.points.contains(.admitted("Mutation.koineCreateGrant")))
        #expect(bench.store.stored.map(\.clientLabel) == ["client"])
    }

    @Test func whenDispatchWinsTheAdmittedActionFinishes() async throws {
        let bench = try Bench()
        let client = try await bench.grant("client")
        bench.when(.admitted("Mutation.koineCreateGrant")) { await bench.revoke(client.id) }

        let reply = try await bench.run(Self.createLate, as: client.principal)

        // Revoked while in flight: the action still committed and is reported.
        #expect(isOutcome(reply.outcome, .executed))
        #expect(reply.errors.isEmpty)
        #expect((reply.data?["koineCreateGrant"] as? [String: Any])?["__typename"] as? String
            == "KoineCreatedGrant")
        #expect(bench.store.stored.map(\.clientLabel) == ["client", "late"])
        #expect(bench.state(of: client.id) == .revoked)

        // Nothing further starts under the revoked grant.
        let next = try await bench.run(Self.createLate, as: client.principal)
        #expect(isOutcome(next.outcome, .unauthenticated))
        #expect(bench.store.stored.count == 2)
    }

    @Test func aReadRevokedBeforePublicationIsNotPublished() async throws {
        let bench = try Bench()
        let client = try await bench.grant("client", [])
        bench.when(.resolved("Koine.instanceId")) { await bench.revoke(client.id) }

        let reply = try await bench.run("{ koine { instanceId } }", as: client.principal)

        // The value was resolved, then withheld. `koine` is non-null, so the
        // refusal reaches the root.
        #expect(bench.points.contains(.resolved("Koine.instanceId")))
        #expect(!reply.body.contains("bench-instance"))
        #expect(reply.data == nil)
        #expect(reply.kind(at: ["koine", "instanceId"]) == "permission")
    }

    // MARK: Store failure

    @Test func aFailedRevokeCommitReportsFailedAndRevokesNothing() async throws {
        let bench = try Bench()
        let manager = try await bench.grant("manager")
        let reader = try await bench.grant("reader", [])
        bench.store.fail(.revoke)

        let reply = try await bench.run(
            "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { grantId state } }",
            variables: ["id": reader.id], as: manager.principal
        )

        #expect(reply.data?["koineRevokeGrant"] is NSNull)
        #expect(reply.kind(at: ["koineRevokeGrant"]) == "failed")
        #expect(!reply.body.contains("REVOKED"))
        #expect(bench.store.count(.revoke) == 1)

        // Still active, and admitted exactly as before.
        bench.store.fail()
        #expect(bench.state(of: reader.id) == .active)
        guard case .grant(let id)? = bench.engine.authenticate(bearer: reader.credential) else {
            Issue.record("the grant no longer authenticates")
            return
        }
        #expect(id == reader.id)
        let still = try await bench.run(Harness.koine, as: reader.principal)
        #expect(still.errors.isEmpty)
    }

    @Test func aFailedCreateCommitReturnsNoCredential() async throws {
        let bench = try Bench()
        let manager = try await bench.grant("manager")
        bench.store.fail(.insert)

        let reply = try await bench.run(
            Harness.createGrant, variables: ["label": "lost", "capabilities": []],
            as: manager.principal
        )

        #expect(reply.data?["koineCreateGrant"] is NSNull)
        #expect(reply.kind(at: ["koineCreateGrant"]) == "failed")
        #expect(!reply.body.contains("credential\":"))
        #expect(bench.store.count(.insert) == 2)  // the manager's, then this one
        #expect(bench.store.stored.map(\.clientLabel) == ["manager"])
    }

    /// A decision that does not commit reports `failed` and no success, and
    /// leaves the request pending with no grant.
    @Test(arguments: [ScriptedStore.Operation.approve, .deny])
    func aFailedDecisionCommitReportsFailedAndDecidesNothing(operation: ScriptedStore.Operation) async throws {
        let bench = try Bench()
        let manager = try await bench.grant("manager")
        let enrolment = try await bench.run(
            "mutation($input: KoineRequestGrantInput!) { koineRequestGrant(input: $input) { requestId } }",
            variables: ["input": [
                "clientLabel": "enrollee", "credentialDigest": Credential.generate().digest,
                "capabilities": ["koine:manage"],
            ]],
            as: .anonymous
        )
        let id = try #require((enrolment.data?["koineRequestGrant"] as? [String: Any])?["requestId"] as? String)
        bench.store.fail(operation)

        let field = operation == .approve ? "koineApproveGrantRequest" : "koineDenyGrantRequest"
        let reply = try await bench.run(
            operation == .approve
                ? "mutation($id: ID!) { koineApproveGrantRequest(requestId: $id, capabilities: [\"koine:manage\"]) { grantId state } }"
                : "mutation($id: ID!) { koineDenyGrantRequest(requestId: $id) { requestId state } }",
            variables: ["id": id], as: manager.principal
        )

        #expect(reply.data?[field] is NSNull)
        #expect(reply.errors.count == 1)
        #expect(reply.kind(at: [field]) == "failed")
        #expect(!reply.body.contains("ACTIVE") && !reply.body.contains("DENIED"))
        #expect(bench.store.count(operation) == 1)
        #expect(bench.store.storedRequests.map(\.state) == [.pending])
        #expect(bench.store.storedRequests[0].grantId == nil)
        #expect(bench.store.stored.map(\.clientLabel) == ["manager"])
    }

    /// Manual creation retries a digest the store says is taken, by a grant or
    /// by a request alike, with a fresh secret, and commits once.
    @Test func aManualGrantRetriesADigestCollisionBeforeCommitting() async throws {
        let bench = try Bench()
        let manager = try await bench.grant("manager")
        bench.store.collide(inserts: 2)

        let reply = try await bench.run(
            Harness.createGrant, variables: ["label": "third time", "capabilities": []],
            as: manager.principal
        )

        #expect(reply.errors.isEmpty)
        let created = try #require(reply.data?["koineCreateGrant"] as? [String: Any])
        let credential = try #require(created["credential"] as? String)
        #expect(bench.store.count(.insert) == 4)  // the manager's, two collisions, the commit
        #expect(bench.store.stored.map(\.clientLabel) == ["manager", "third time"])
        #expect(bench.store.stored[1].credentialDigest == Credential.digest(ofPresented: credential))
    }

    @Test func aStoreReadFailureDuringAuthenticationRefuses() async throws {
        let bench = try Bench()
        let client = try await bench.grant("client")
        bench.store.fail(.grants)
        #expect(bench.engine.authenticate(bearer: client.credential) == nil)
        bench.store.fail()
        #expect(bench.engine.authenticate(bearer: client.credential) != nil)
    }

    /// The three authority checks a one-action mutation passes, in order: the
    /// request's admission, preflight, and the action's dispatch.
    @Test(arguments: [0, 1, 2])
    func aStoreReadFailureDuringAnAuthorityCheckNeverAdmits(readsAllowed: Int) async throws {
        let bench = try Bench()
        let client = try await bench.grant("client")
        bench.store.failGrantRead(after: readsAllowed)

        let reply = try await bench.run(Self.createLate, as: client.principal)

        switch readsAllowed {
        case 0:
            #expect(isOutcome(reply.outcome, .unauthenticated))
        case 1:
            #expect(isOutcome(reply.outcome, .forbidden))
            #expect(reply.kind(at: ["koineCreateGrant"]) == "failed")
        default:
            #expect(isOutcome(reply.outcome, .executed))
            #expect(reply.data?["koineCreateGrant"] is NSNull)
            #expect(reply.kind(at: ["koineCreateGrant"]) == "failed")
        }
        #expect(bench.store.count(.grant) == readsAllowed + 1)
        #expect(!bench.points.contains(.admitted("Mutation.koineCreateGrant")))
        #expect(bench.store.stored.map(\.clientLabel) == ["client"])
    }

    @Test func aStoreReadFailureDuringAReadCheckPublishesNothing() async throws {
        let bench = try Bench()
        let client = try await bench.grant("client", [])
        // The store fails exactly at the check before publication.
        bench.when(.resolved("Koine.instanceId")) { bench.store.fail(.grant) }

        let reply = try await bench.run("{ koine { instanceId } }", as: client.principal)

        #expect(!reply.body.contains("bench-instance"))
        #expect(reply.kind(at: ["koine", "instanceId"]) == "failed")
    }

    // MARK: An unusable grants.sqlite

    @Test(arguments: ["corrupt", "unreadable"])
    func anUnusableStoreFileFailsInitAndIsLeftAlone(how: String) async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("grants.sqlite")
        let garbage = Data("this is not a database, and is longer than a SQLite header ".utf8)
            + Data(repeating: 0xA5, count: 4096)
        try garbage.write(to: file)
        if how == "unreadable" {
            try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: file.path)
        }

        for _ in 0..<2 {  // the second attempt meets the same refusal, not a held lock
            #expect(throws: (any Error).self) { try KoineServer(dataDirectory: directory) }
            do { _ = try KoineServer(dataDirectory: directory) } catch {
                #expect(error as? KoineServerError != .alreadyRunning)
            }
        }

        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
        #expect(try Data(contentsOf: file) == garbage)
        // No replacement store, no journal beside it, no descriptor.
        let contents = try FileManager.default.contentsOfDirectory(atPath: directory.path).sorted()
        #expect(contents == ["grants.sqlite", "instance.lock"])
    }
}
