import Foundation
import KoineProviderAPI

// Test material: the independently built provider the native seam is exercised
// with. build.sh generates `fixtureSchemaSDL` from schema.graphql.

@objc(KoineFixtureProviderFactory)
final class FixtureProviderFactory: NSObject, ProviderFactory {
    override required init() { super.init() }

    var descriptor: ProviderDescriptor {
        let read = [
            "Query.fixtureInfo": "info", "Query.fixtureItems": "items", "Query.fixtureItem": "item",
            "Query.fixtureProbe": "probe", "Query.fixtureCalls": "calls",
            "Query.fixtureAwaitCancellation": "awaitCancellation",
            "FixtureCall.resolver": "call.resolver", "FixtureCall.count": "call.count",
        ]
        // A nested field's resolver identifier is the key it reads from its parent.
        let outputs = [
            "FixtureInfo": ["greeting"],
            "FixtureItem": ["ref", "name", "note", "tags", "detail"],
            "FixtureItemDetail": ["size"],
        ]
        var fields = read.map {
            ProviderFieldRegistration(coordinate: $0.key, resolverId: $0.value, authority: .read)
        }
        for (type, names) in outputs {
            fields += names.map {
                ProviderFieldRegistration(
                    coordinate: "\(type).\($0)", resolverId: "parent.\($0)", authority: .read
                )
            }
        }
        fields += [
            ProviderFieldRegistration(
                coordinate: "Mutation.fixtureRenameItem", resolverId: "renameItem",
                authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "Mutation.fixtureCloseGate", resolverId: "closeGate", authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "Mutation.fixtureOpenGate", resolverId: "openGate", authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "FixtureRenameReceipt.ref", resolverId: "parent.ref",
                authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "FixtureRenameReceipt.affected", resolverId: "parent.affected",
                authority: .control
            ),
        ]
        return ProviderDescriptor(
            providerId: "fixture", graphQLPrefix: "Fixture", schemaSDL: fixtureSchemaSDL,
            fields: fields, requiredFeatures: []
        )
    }

    func makeProvider() -> any Provider { FixtureProvider() }
}

/// A principal class that is no `ProviderFactory`, for a manifest to name.
@objc(KoineFixtureNotAFactory)
final class FixtureNotAFactory: NSObject {}

struct FixtureStartFailure: Error, CustomStringConvertible {
    var description: String { "built to fail its start" }
}

/// Two items, `koine://fixture/item/1` and `koine://fixture/item/2`. A reference
/// is re-resolved on every use; nothing is remembered for a caller.
///
/// A test cannot reach into this image, so what it observes and controls is
/// served as fields: `fixtureCalls` counts every call by resolver identifier,
/// and a closed gate holds the named resolver's calls, already counted, until
/// `fixtureOpenGate`. The counters, the gate and their own fields are neither
/// counted nor held.
final class FixtureProvider: Provider, @unchecked Sendable {
    private let lock = NSLock()
    private var names = [1: "first", 2: "second"]
    private var calls: [String: Int] = [:]
    private var gated: Set<String> = []
    private var held: [CheckedContinuation<Void, Never>] = []

    func start() async throws {
        #if FIXTURE_FAILS_START
            throw FixtureStartFailure()
        #endif
        #if FIXTURE_NEEDS_NEWER_FRAMEWORK
            // A declaration this host's framework does not have: the manifest
            // claims minor 0, and the dynamic loader finds the lie.
            koineProviderFrameworkFutureAddition()
        #endif
    }

    // scripts/build-compat-pairs.sh builds the later revisions of this provider
    // for the binary compatibility pairs: FIXTURE_REVISION_2 is newer source
    // that uses only the baseline framework, and FIXTURE_USES_MINOR_1 also
    // uses the declarations its evidence-only framework minor 1 adds.
    private static var greeting: String {
        #if FIXTURE_USES_MINOR_1
            koineProviderMinor1Greeting(revision: 2)
        #elseif FIXTURE_REVISION_2
            "hello from the fixture provider, revision 2"
        #else
            "hello from the fixture provider"
        #endif
    }

    #if FIXTURE_USES_MINOR_1
        func describeInstance() -> String { "the fixture provider, revision 2" }
    #endif
    func stop() async {}

    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        let id = request.resolverId
        if !["calls", "closeGate", "openGate"].contains(id), !id.hasPrefix("call.") {
            await enter(id)
        }
        if id == "awaitCancellation" { return await awaitCancellation() }
        return answer(request)
    }

    /// Waits, as an OS wait would, until the host requests cancellation, and
    /// counts having seen it: the count outlives the request that was cancelled.
    private func awaitCancellation() async -> ResolutionResult {
        while !Task.isCancelled { try? await Task.sleep(nanoseconds: 5_000_000) }
        lock.withLock { calls["awaitCancellation.cancelled", default: 0] += 1 }
        return .failure(ProviderFailure(kind: .failed, message: "The fixture saw cancellation."))
    }

    /// Counts the call, then waits while the resolver's gate is closed.
    private func enter(_ resolverId: String) async {
        await withCheckedContinuation { continuation in
            let isHeld = lock.withLock {
                calls[resolverId, default: 0] += 1
                guard gated.contains(resolverId) else { return false }
                held.append(continuation)
                return true
            }
            if !isHeld { continuation.resume() }
        }
    }

    private func answer(_ request: ResolutionRequest) -> ResolutionResult {
        for prefix in ["parent.", "call."] where request.resolverId.hasPrefix(prefix) {
            let key = String(request.resolverId.dropFirst(prefix.count))
            guard case .object(let parent)? = request.parent, let value = parent[key] else {
                return .failure(ProviderFailure(kind: .failed, message: "No parent value."))
            }
            return .success(value)
        }
        switch request.resolverId {
        case "info":
            return .success(.object(["greeting": .string(Self.greeting)]))
        case "items":
            return .success(.list(lock.withLock { names.keys.sorted().compactMap(item) }))
        case "probe":
            switch request.arguments["outcome"] {
            case .string("OK"): return .success(.string("ok"))
            case .string("UNAVAILABLE"): return gone
            case .string("OS_PERMISSION"):
                return .failure(
                    .osPermission("accessibility", message: "Koine needs Accessibility access.")
                )
            case .string("INVALID_INPUT"):
                return .failure(
                    ProviderFailure(kind: .invalidInput, message: "The probe refused its input.")
                )
            default:
                return .failure(ProviderFailure(kind: .failed, message: "The probe failed."))
            }
        case "calls":
            let counted = lock.withLock { calls }
            return .success(
                .list(
                    counted.sorted { $0.key < $1.key }.map {
                        .object(["resolver": .string($0.key), "count": .int($0.value)])
                    }
                )
            )
        case "closeGate":
            guard case .string(let resolver)? = request.arguments["resolver"] else {
                return .failure(ProviderFailure(kind: .failed, message: "No resolver."))
            }
            lock.withLock { _ = gated.insert(resolver) }
            return .success(.bool(true))
        case "openGate":
            let released = lock.withLock {
                gated = []
                defer { held = [] }
                return held
            }
            for continuation in released { continuation.resume() }
            return .success(.bool(true))
        case "item":
            return number(of: request.arguments["ref"]).flatMap { number in
                lock.withLock { item(number) }.map(ResolutionResult.success) ?? gone
            }
        case "renameItem":
            guard case .string(let name)? = request.arguments["name"] else {
                return .failure(ProviderFailure(kind: .failed, message: "No name."))
            }
            return number(of: request.arguments["ref"]).flatMap { number in
                lock.withLock {
                    guard names[number] != nil else { return gone }
                    names[number] = name
                    return .success(
                        .object([
                            "ref": .reference(Self.reference(number)),
                            "affected": .list([item(number)].compactMap { $0 }),
                        ])
                    )
                }
            }
        default:
            return .failure(
                ProviderFailure(kind: .unknownResolver, message: "No such resolver.")
            )
        }
    }

    private var gone: ResolutionResult {
        .failure(ProviderFailure(kind: .unavailable, message: "No item has this reference."))
    }

    private static func reference(_ number: Int) -> String { "koine://fixture/item/\(number)" }

    /// Call with the lock held.
    private func item(_ number: Int) -> ProviderValue? {
        names[number].map { name in
            .object([
                "ref": .reference(Self.reference(number)),
                "name": .string(name),
                "note": number == 1 ? .string("the first item") : .null,
                "tags": .list([.string("fixture"), .string("item-\(number)")]),
                "detail": .object(["size": .int(number * 10)]),
            ])
        }
    }

    /// The item number a reference's remainder names. Only this provider reads
    /// a remainder; one it cannot interpret is `unavailable`.
    private func number(of value: ProviderValue?) -> Result<Int, ProviderFailure> {
        let prefix = "koine://fixture/item/"
        guard case .reference(let reference)? = value, reference.hasPrefix(prefix),
            let number = Int(reference.dropFirst(prefix.count))
        else {
            return .failure(
                ProviderFailure(kind: .unavailable, message: "This is not an item reference.")
            )
        }
        return .success(number)
    }
}

extension Result where Success == Int, Failure == ProviderFailure {
    fileprivate func flatMap(_ body: (Int) -> ResolutionResult) -> ResolutionResult {
        switch self {
        case .success(let number): body(number)
        case .failure(let failure): .failure(failure)
        }
    }
}
