import Foundation
import KoineCore
import KoineProviderAPI
import Testing

@testable import KoineServer

/// The `Reference` scalar and the provider value contract, over the fixture
/// bundle's items and, for provider defects, in-test providers.
@Suite struct ReferenceRoutingTests {
    static let item = """
        query Item($ref: Reference!) {
          fixtureItem(ref: $ref) { ref name note tags detail { size } }
        }
        """

    private func fixture(_ capabilities: [String]) async throws -> (Harness, String) {
        let harness = try await Harness(providerRoots: [try NativeProviderTests.fixtureRoot()])
        let credential = try await harness.consoleGrant(label: "c", capabilities: capabilities)
        return (harness, "Bearer \(credential)")
    }

    private func kind(_ reply: Harness.Reply) -> String? {
        (reply.errors.first?["extensions"] as? [String: Any])?["kind"] as? String
    }

    @Test func aReturnedReferenceResolvesItsItemWithListsNullsAndNestedValues() async throws {
        let (harness, authorization) = try await fixture(["fixture:read"])
        let listed = try await harness.post(
            "{ fixtureItems { ref name } }", authorization: authorization
        )
        let items = try #require(listed.data?["fixtureItems"] as? [[String: Any]])
        #expect(items.map { $0["name"] as? String } == ["first", "second"])
        let second = try #require(items.last?["ref"] as? String)

        let reply = try await harness.post(
            Self.item, variables: ["ref": second], authorization: authorization
        )
        #expect(reply.errors.isEmpty)
        let item = try #require(reply.data?["fixtureItem"] as? [String: Any])
        #expect(item["ref"] as? String == second)
        #expect(item["note"] is NSNull)
        #expect(item["tags"] as? [String] == ["fixture", "item-2"])
        #expect((item["detail"] as? [String: Any])?["size"] as? Int == 20)
        await harness.stop()
    }

    @Test(arguments: [
        "http://fixture/item/1", "Koine://fixture/item/1", "koine://fixture", "koine:///item/1",
        "koine://user@fixture/item/1", "koine://fixture:80/item/1", "koine://fixture/item/1#top",
        "koine://Fixture/item/1", "koine://fixture/item 1", "koine://fixture/item/%zz", "",
    ])
    func aMalformedEnvelopeIsAnInputCoercionError(_ reference: String) async throws {
        let (harness, authorization) = try await fixture(["fixture:read"])
        let variable = try await harness.post(
            Self.item, variables: ["ref": reference], authorization: authorization
        )
        #expect(variable.status == 400)
        #expect(variable.data == nil)

        let literal = try await harness.post(
            "{ fixtureItem(ref: \"\(reference)\") { name } }", authorization: authorization
        )
        #expect(literal.status == 400)
        await harness.stop()
    }

    @Test func aProviderRootHasAnEmptyRemainder() async throws {
        let (harness, authorization) = try await fixture(["fixture:read"])
        let reply = try await harness.post(
            Self.item, variables: ["ref": "koine://fixture/"], authorization: authorization
        )
        // Well-formed, so it reaches the provider, which has no such item.
        #expect(reply.status == 200)
        #expect(kind(reply) == "unavailable")
        await harness.stop()
    }

    @Test func anUnregisteredProviderIsUnknownProviderAfterTheCapabilityCheck() async throws {
        let (harness, reader) = try await fixture(["fixture:read"])
        let reply = try await harness.post(
            Self.item, variables: ["ref": "koine://nobody/x"], authorization: reader
        )
        #expect(reply.status == 200)
        #expect(reply.data?["fixtureItem"] is NSNull)
        #expect(kind(reply) == "unknown-provider")
        #expect(reply.errors.first?["path"] as? [String] == ["fixtureItem"])

        let stranger = try await harness.consoleGrant(label: "s", capabilities: [])
        let denied = try await harness.post(
            Self.item, variables: ["ref": "koine://nobody/x"], authorization: "Bearer \(stranger)"
        )
        #expect(kind(denied) == "permission")
        await harness.stop()
    }

    @Test(arguments: ["koine://fixture/item/99", "koine://fixture/bogus", "koine://fixture/item/x"])
    func aGoneTargetOrMalformedRemainderIsUnavailable(_ reference: String) async throws {
        let (harness, authorization) = try await fixture(["fixture:read", "fixture:control"])
        let read = try await harness.post(
            Self.item, variables: ["ref": reference], authorization: authorization
        )
        #expect(read.data?["fixtureItem"] is NSNull)
        #expect(kind(read) == "unavailable")

        let action = try await harness.post(
            "mutation($ref: Reference!) { fixtureRenameItem(ref: $ref, name: \"n\") { ref } }",
            variables: ["ref": reference], authorization: authorization
        )
        #expect(kind(action) == "unavailable")
        await harness.stop()
    }

    @Test func aRootMutationActionRunsUnderControlAndReturnsItsReceipt() async throws {
        let (harness, authorization) = try await fixture(["fixture:read", "fixture:control"])
        let reference = "koine://fixture/item/1"
        let action = try await harness.post(
            "mutation($ref: Reference!) { fixtureRenameItem(ref: $ref, name: \"renamed\") { ref } }",
            variables: ["ref": reference], authorization: authorization
        )
        #expect(action.errors.isEmpty)
        #expect((action.data?["fixtureRenameItem"] as? [String: Any])?["ref"] as? String == reference)

        let read = try await harness.post(
            Self.item, variables: ["ref": reference], authorization: authorization
        )
        #expect((read.data?["fixtureItem"] as? [String: Any])?["name"] as? String == "renamed")

        let reader = try await harness.consoleGrant(label: "r", capabilities: ["fixture:read"])
        let denied = try await harness.post(
            "mutation { fixtureRenameItem(ref: \"\(reference)\", name: \"x\") { ref } }",
            authorization: "Bearer \(reader)"
        )
        #expect(denied.status == 403)
        await harness.stop()
    }

    // MARK: Provider defects and failures

    /// `Query.oddValue: <type>` resolved by `resolve`, under `odd:read`.
    private func odd(
        _ type: String, _ resolve: @escaping StubProvider.Resolve
    ) async throws -> (Harness, Harness.Reply) {
        let stub = Stub(
            id: "odd", prefix: "Odd", sdl: "extend type Query { oddValue: \(type) }",
            fields: [("Query.oddValue", .read)], resolve: resolve
        )
        let harness = try await Harness(providers: [stub.active])
        let credential = try await harness.consoleGrant(label: "c", capabilities: ["odd:read"])
        let reply = try await harness.post("{ oddValue }", authorization: "Bearer \(credential)")
        return (harness, reply)
    }

    static let malformed: [(String, ProviderValue)] = [
        ("String", .int(1)), ("Int", .string("1")), ("Int", .int(1 << 40)), ("String!", .null),
        ("[String!]", .list([.string("a"), .null])), ("[String!]", .string("a")),
        ("Reference", .string("koine://odd/x")), ("Reference", .reference("not a reference")),
        ("Float", .double(.infinity)),
    ]

    @Test(arguments: malformed)
    func malformedProviderOutputIsFailed(_ type: String, _ value: ProviderValue) async throws {
        let (harness, reply) = try await odd(type) { _ in .success(value) }
        #expect(kind(reply) == "failed")
        #expect(reply.errors.first?["path"] as? [String] == ["oddValue"])
        #expect(reply.errors.count == 1)
        await harness.stop()
    }

    @Test func aResolverRegistrationMismatchIsFailedWithADiagnostic() async throws {
        let (harness, reply) = try await odd("String") { _ in
            .failure(ProviderFailure(kind: .unknownResolver, message: "native detail"))
        }
        #expect(kind(reply) == "failed")
        #expect(reply.errors.first?["message"] as? String != "native detail")
        let diagnostics = harness.server.providerDiagnostics
        #expect(diagnostics.map(\.reason) == [.resolverMismatch])
        #expect(diagnostics.first?.providerId == "odd")
        await harness.stop()
    }

    @Test func aMissingPlatformConsentIsAnOSPermissionError() async throws {
        let (harness, reply) = try await odd("String") { _ in
            .failure(.osPermission("accessibility", message: "Koine needs Accessibility access."))
        }
        let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "os-permission")
        #expect(extensions["osPermission"] as? String == "accessibility")
        #expect(extensions["permissionOwner"] as? String == "koine")
        #expect(extensions["requiredCapability"] == nil)
        await harness.stop()
    }

    @Test func argumentsArriveCoercedAndReferencesArriveTyped() async throws {
        let seen = Seen()
        let stub = Stub(
            id: "odd", prefix: "Odd",
            sdl: """
                extend type Query { oddEcho(ref: Reference!, input: OddInput!, count: Int = 3): String }
                input OddInput { refs: [Reference!]! flag: Boolean! }
                """,
            fields: [("Query.oddEcho", .read)],
            resolve: { request in
                seen.set(request)
                return .success(.null)
            }
        )
        let harness = try await Harness(providers: [stub.active, Stub.good("good").active])
        // A reference to `good`'s resource needs `good:read` as well.
        let credential = try await harness.consoleGrant(
            label: "c", capabilities: ["odd:read", "good:read"]
        )
        let reply = try await harness.post(
            "{ oddEcho(ref: \"koine://odd/a\", input: { refs: [\"koine://good/b\"], flag: true }) }",
            authorization: "Bearer \(credential)"
        )
        #expect(reply.errors.isEmpty)
        let request = try #require(seen.request)
        #expect(request.resolverId == "Query.oddEcho")
        #expect(request.parent == nil)
        #expect(!request.requestId.isEmpty)
        #expect(
            request.arguments == [
                "ref": .reference("koine://odd/a"), "count": .int(3),
                "input": .object(["refs": .list([.reference("koine://good/b")]), "flag": .bool(true)]),
            ]
        )

        // A variable arrives as the declared type; a fraction is not an Int,
        // and the provider is not called with one.
        let echo = "query($n: Int) { oddEcho(ref: \"koine://odd/a\", input: { refs: [], flag: false }, count: $n) }"
        _ = try await harness.post(echo, variables: ["n": 5], authorization: "Bearer \(credential)")
        #expect(seen.request?.arguments["count"] == .int(5))
        let fraction = try await harness.post(
            echo, variables: ["n": 5.5], authorization: "Bearer \(credential)"
        )
        #expect(!fraction.errors.isEmpty)
        #expect(seen.request?.arguments["count"] == .int(5))

        // A reference nested in an input object is routed like any other.
        let unknown = try await harness.post(
            "{ oddEcho(ref: \"koine://odd/a\", input: { refs: [\"koine://nobody/b\"], flag: true }) }",
            authorization: "Bearer \(credential)"
        )
        #expect(kind(unknown) == "unknown-provider")
        await harness.stop()
    }
}

private final class Seen: @unchecked Sendable {
    private let lock = NSLock()
    private var value: ResolutionRequest?

    var request: ResolutionRequest? { lock.withLock { value } }
    func set(_ request: ResolutionRequest) { lock.withLock { value = request } }
}
