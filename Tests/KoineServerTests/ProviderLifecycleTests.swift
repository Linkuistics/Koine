import Foundation
import KoineProviderAPI
import KoineSQLiteStore
import Testing

@testable import KoineCore
@testable import KoineServer

/// An in-test provider that records what the host does to it. `held` resolves
/// wait until the host requests their cancellation, as an OS wait would.
private final class RecordingProvider: Provider, @unchecked Sendable {
    struct StartFailure: Error {}

    private let lock = NSLock()
    private var log: [String] = []
    private var inFlight = 0
    private var mostInFlight = 0
    private let failsStart: Bool

    init(failsStart: Bool = false) { self.failsStart = failsStart }

    var events: [String] { lock.withLock { log } }
    var mostOverlapping: Int { lock.withLock { mostInFlight } }
    private func record(_ event: String) { lock.withLock { log.append(event) } }

    func start() async throws {
        record("start")
        if failsStart { throw StartFailure() }
    }

    func stop() async { record("stop") }

    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        lock.withLock {
            inFlight += 1
            mostInFlight = max(mostInFlight, inFlight)
        }
        defer { lock.withLock { inFlight -= 1 } }
        switch request.resolverId {
        case "Query.recHeld":
            record("held")
            while !Task.isCancelled { try? await Task.sleep(nanoseconds: 5_000_000) }
            record("cancelled")
            return .failure(ProviderFailure(kind: .failed, message: "Cancelled."))
        case "Query.recPair":
            // Returns once a second resolve is in flight beside it.
            for _ in 0..<1_000 where mostOverlapping < 2 {
                try? await Task.sleep(nanoseconds: 5_000_000)
            }
            return .success(.string("pair"))
        default:
            return .success(.string("ok"))
        }
    }

    func active() -> ActiveProvider {
        ActiveProvider(
            descriptor: ProviderDescriptor(
                providerId: "rec", graphQLPrefix: "Rec",
                schemaSDL: "extend type Query { recValue: String recHeld: String recPair: String }",
                fields: ["Query.recValue", "Query.recHeld", "Query.recPair"].map {
                    ProviderFieldRegistration(coordinate: $0, resolverId: $0, authority: .read)
                }
            ),
            provider: self, version: "2.1.0", schemaVersion: "2.0.0"
        )
    }
}

@Suite struct ProviderLifecycleTests {
    /// An engine over a throwaway store, and a principal holding `rec:read`.
    private static func engine(_ provider: RecordingProvider) async throws -> (Engine, Principal) {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-lifecycle-\(UUID().uuidString).sqlite").path
        let engine = try Engine(
            store: try SQLiteGrantStore(path: path), instanceId: "lifecycle",
            providers: [provider.active()]
        )
        let created = try await run(
            engine, Harness.createGrant, variables: ["label": "r", "capabilities": ["rec:read"]],
            as: .localConsole
        )
        let json = try JSONSerialization.jsonObject(with: Data(created.body.utf8)) as? [String: Any]
        let grant = ((json?["data"] as? [String: Any])?["koineCreateGrant"] as? [String: Any])?["grant"]
        let id = try #require((grant as? [String: Any])?["grantId"] as? String)
        return (engine, .grant(id: id))
    }

    /// What a test reads of a response; a JSON dictionary cannot cross tasks.
    private struct Reply: Sendable {
        let body: String
        /// The first error's classification.
        let kind: String?
    }

    private static func run(
        _ engine: Engine, _ query: String, variables: [String: Any] = [:], as principal: Principal
    ) async throws -> Reply {
        let request = try EngineRequest(jsonBody: try Harness.requestBody(query, variables: variables))
        let body = await engine.execute(request, as: principal).body
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        let error = (json?["errors"] as? [[String: Any]])?.first
        return Reply(
            body: String(decoding: body, as: UTF8.self),
            kind: (error?["extensions"] as? [String: Any])?["kind"] as? String
        )
    }

    @Test func resolvesOverlapOnceStartHasSucceeded() async throws {
        let provider = RecordingProvider()
        let (engine, reader) = try await Self.engine(provider)
        await engine.startProviders()

        async let first = Self.run(engine, "{ recPair }", as: reader)
        async let second = Self.run(engine, "{ recPair }", as: reader)
        let replies = try await [first, second]

        #expect(provider.mostOverlapping == 2)
        #expect(replies.allSatisfy { $0.kind == nil && $0.body.contains("\"pair\"") })
        await engine.stopProviders()
    }

    @Test func aProviderIsNotResolvedBeforeItStarts() async throws {
        let provider = RecordingProvider()
        let (engine, reader) = try await Self.engine(provider)

        #expect(try await Self.run(engine, "{ recValue }", as: reader).kind == "unavailable")
        #expect(provider.events.isEmpty)
    }

    @Test func stopRequestsCancellationWaitsForOutstandingWorkAndAdmitsNothingNew() async throws {
        let provider = RecordingProvider()
        let (engine, reader) = try await Self.engine(provider)
        await engine.startProviders()

        let held = Task { try await Self.run(engine, "{ recHeld }", as: reader) }
        while !provider.events.contains("held") { try await Task.sleep(nanoseconds: 5_000_000) }
        await engine.stopProviders()

        // The outstanding resolve finished before the provider was stopped.
        #expect(provider.events == ["start", "held", "cancelled", "stop"])
        #expect(try await held.value.kind == "failed")
        #expect(try await Self.run(engine, "{ recValue }", as: reader).kind == "unavailable")
        // Neither transition repeats.
        await engine.startProviders()
        await engine.stopProviders()
        #expect(provider.events == ["start", "held", "cancelled", "stop"])
    }

    @Test func startAndStopForOneInstanceAreSerialized() async throws {
        let provider = RecordingProvider()
        let (engine, _) = try await Self.engine(provider)

        async let starting: Void = engine.startProviders()
        async let stopping: Void = engine.stopProviders()
        _ = await (starting, stopping)
        await engine.stopProviders()

        // Whichever order they were taken in, a stop never precedes its start.
        #expect(provider.events == ["start", "stop"] || provider.events == ["start"] || provider.events.isEmpty)
        #expect(provider.events != ["stop", "start"])
    }

    @Test func aFailedStartIsFailedStatusAndUnavailableFields() async throws {
        let provider = RecordingProvider(failsStart: true)
        let (engine, reader) = try await Self.engine(provider)
        await engine.startProviders()

        let status = try #require(await engine.providerStatuses.first)
        #expect(status.state == .failed)
        #expect(status.provider == "rec" && status.version == "2.1.0" && status.schemaVersion == "2.0.0")
        #expect(status.diagnostic?.contains("failed to start") == true)
        #expect(try await Self.run(engine, "{ recValue }", as: reader).kind == "unavailable")
        await engine.stopProviders()
        #expect(provider.events == ["start"])
    }

    // MARK: Composition refusals as status

    @Test func compositionRefusalsAreServedAsProviderStatus() async throws {
        let good = Stub.good("alpha")
        let reserved = Stub(
            id: "koine", prefix: "Koine", sdl: "extend type Query { koineExtra: String }",
            fields: [("Query.koineExtra", .read)]
        )
        let needy = Stub(
            id: "needy", prefix: "Needy", sdl: "extend type Query { needyValue: String }",
            fields: [("Query.needyValue", .read)], requiredFeatures: ["time-travel"]
        )
        let harness = try await Harness(providers: [needy.active, reserved.active, good.active])

        let statuses = try await ProviderLoaderTests.statuses(harness)
        #expect(statuses.map(\.provider) == ["alpha", "koine", "needy"])
        #expect(statuses.map(\.state) == ["ACTIVE", "REJECTED", "INCOMPATIBLE"])
        #expect(statuses[0].diagnostic == nil)
        #expect(statuses[1].diagnostic?.contains("reserved") == true)
        #expect(statuses[2].diagnostic?.contains("time-travel") == true)
        await harness.stop()
    }

    @Test func aResolverMismatchIsAnActiveProvidersDiagnostic() async throws {
        let stub = Stub(
            id: "beta", prefix: "Beta", sdl: "extend type Query { betaValue: String }",
            fields: [("Query.betaValue", .read)]
        ) { _ in .failure(ProviderFailure(kind: .unknownResolver, message: "No such resolver.")) }
        let harness = try await Harness(providers: [stub.active])
        let credential = try await harness.consoleGrant(label: "r", capabilities: ["beta:read"])
        _ = try await harness.post("{ betaValue }", authorization: "Bearer \(credential)")

        let status = try #require(try await ProviderLoaderTests.statuses(harness).first)
        #expect(status.state == "ACTIVE")
        #expect(status.diagnostic?.contains("Query.betaValue") == true)
        await harness.stop()
    }
}
