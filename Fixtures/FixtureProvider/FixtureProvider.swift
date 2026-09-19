import Foundation
import KoineProviderAPI

// Test material: the independently built provider the native seam is exercised
// with. build.sh generates `fixtureSchemaSDL` from schema.graphql.

@objc(KoineFixtureProviderFactory)
final class FixtureProviderFactory: NSObject, ProviderFactory {
    override required init() { super.init() }

    var descriptor: ProviderDescriptor {
        ProviderDescriptor(
            providerId: "fixture",
            graphQLPrefix: "Fixture",
            schemaSDL: fixtureSchemaSDL,
            fields: [
                ProviderFieldRegistration(
                    coordinate: "Query.fixtureInfo", resolverId: "info", authority: .read
                ),
                ProviderFieldRegistration(
                    coordinate: "FixtureInfo.greeting", resolverId: "info.greeting", authority: .read
                ),
            ]
        )
    }

    func makeProvider() -> any Provider { FixtureProvider() }
}

final class FixtureProvider: Provider {
    func start() async throws {}
    func stop() async {}

    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        switch request.resolverId {
        case "info":
            return .success(.object(["greeting": .string("hello from the fixture provider")]))
        case "info.greeting":
            guard case .object(let info)? = request.parent, let greeting = info["greeting"] else {
                return .failure(ProviderFailure(kind: .failed, message: "No parent value."))
            }
            return .success(greeting)
        default:
            return .failure(ProviderFailure(kind: .failed, message: "Unknown resolver."))
        }
    }
}
