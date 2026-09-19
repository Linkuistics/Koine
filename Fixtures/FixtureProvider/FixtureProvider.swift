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
                coordinate: "FixtureRenameReceipt.ref", resolverId: "parent.ref",
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

/// Two items, `koine://fixture/item/1` and `koine://fixture/item/2`. A reference
/// is re-resolved on every use; nothing is remembered for a caller.
final class FixtureProvider: Provider, @unchecked Sendable {
    private let lock = NSLock()
    private var names = [1: "first", 2: "second"]

    func start() async throws {}
    func stop() async {}

    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        if request.resolverId.hasPrefix("parent.") {
            let key = String(request.resolverId.dropFirst("parent.".count))
            guard case .object(let parent)? = request.parent, let value = parent[key] else {
                return .failure(ProviderFailure(kind: .failed, message: "No parent value."))
            }
            return .success(value)
        }
        switch request.resolverId {
        case "info":
            return .success(.object(["greeting": .string("hello from the fixture provider")]))
        case "items":
            return .success(.list(lock.withLock { names.keys.sorted().compactMap(item) }))
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
                    return .success(.object(["ref": .reference(Self.reference(number))]))
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
