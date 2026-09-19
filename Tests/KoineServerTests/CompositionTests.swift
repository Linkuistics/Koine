import Foundation
import KoineCore
import KoineProviderAPI
import Testing

@testable import KoineServer

/// An in-test provider: a descriptor and a resolve closure. A deliberately bad
/// contribution needs no bundle of its own.
final class StubProvider: Provider, @unchecked Sendable {
    typealias Resolve = @Sendable (ResolutionRequest) -> ResolutionResult

    private let handler: Resolve
    private let lock = NSLock()
    private var starts = 0

    init(_ handler: @escaping Resolve) { self.handler = handler }

    var startCount: Int { lock.withLock { starts } }

    func start() async throws { lock.withLock { starts += 1 } }
    func stop() async {}
    func resolve(_ request: ResolutionRequest) async -> ResolutionResult { handler(request) }
}

struct Stub {
    let active: ActiveProvider
    let provider: StubProvider

    /// `fields` are `(coordinate, authority)`; the resolver identifier is the
    /// coordinate. The default resolver answers every field with "ok".
    init(
        id: String, prefix: String, sdl: String,
        fields: [(String, ProviderFieldAuthority)], origin: ActiveProvider.Origin = .external,
        requiredFeatures: [String] = [],
        resolve: @escaping StubProvider.Resolve = { _ in .success(.string("ok")) }
    ) {
        provider = StubProvider(resolve)
        active = ActiveProvider(
            descriptor: ProviderDescriptor(
                providerId: id, graphQLPrefix: prefix, schemaSDL: sdl,
                fields: fields.map {
                    ProviderFieldRegistration(coordinate: $0.0, resolverId: $0.0, authority: $0.1)
                },
                requiredFeatures: requiredFeatures
            ),
            provider: provider, origin: origin
        )
    }

    /// A well-formed provider with one root read field, `<id>Value: String`.
    static func good(_ id: String, description: String = "read.") -> Stub {
        let prefix = id.prefix(1).uppercased() + id.dropFirst()
        return Stub(
            id: id, prefix: prefix,
            sdl: "extend type Query { \"\(description)\" \(id)Value: String }",
            fields: [("Query.\(id)Value", .read)]
        )
    }
}

@Suite struct CompositionTests {
    struct Refused: Sendable, CustomTestStringConvertible {
        let testDescription: String
        let reason: ProviderDiagnostic.Reason
        let id: String
        let prefix: String
        let sdl: String
        let fields: [(String, ProviderFieldAuthority)]
        var requiredFeatures: [String] = []
    }

    static let refused: [Refused] = [
        Refused(
            testDescription: "reserved type name", reason: .reservedName, id: "bad", prefix: "Bad",
            sdl: "type Subscription { badTick: String }",
            fields: [("Subscription.badTick", .read)]
        ),
        Refused(
            testDescription: "core-owned type prefix", reason: .reservedName, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badThing: KoineThing } type KoineThing { a: String }",
            fields: [("Query.badThing", .read), ("KoineThing.a", .read)]
        ),
        Refused(
            testDescription: "core-owned root field prefix", reason: .reservedName, id: "bad",
            prefix: "Bad", sdl: "extend type Query { koineBackdoor: String }",
            fields: [("Query.koineBackdoor", .read)]
        ),
        Refused(
            testDescription: "the koine identifier", reason: .reservedName, id: "koine",
            prefix: "Bad", sdl: "extend type Query { badValue: String }",
            fields: [("Query.badValue", .read)]
        ),
        Refused(
            testDescription: "the desktop identifier from an external provider",
            reason: .reservedName, id: "desktop", prefix: "Desktop",
            sdl: "extend type Query { desktopValue: String }",
            fields: [("Query.desktopValue", .read)]
        ),
        Refused(
            testDescription: "type without the prefix", reason: .missingPrefix, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badThing: Thing } type Thing { a: String }",
            fields: [("Query.badThing", .read), ("Thing.a", .read)]
        ),
        Refused(
            testDescription: "root field without the prefix", reason: .missingPrefix, id: "bad",
            prefix: "Bad", sdl: "extend type Query { thing: String }",
            fields: [("Query.thing", .read)]
        ),
        Refused(
            testDescription: "missing resolver", reason: .missingResolver, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badOne: String badTwo: String }",
            fields: [("Query.badOne", .read)]
        ),
        Refused(
            testDescription: "registration for a field not contributed",
            reason: .unknownCoordinate, id: "bad", prefix: "Bad",
            sdl: "extend type Query { badOne: String }",
            fields: [("Query.badOne", .read), ("Query.koine", .read)]
        ),
        Refused(
            testDescription: "action classified as a read", reason: .unclassifiedField, id: "bad",
            prefix: "Bad", sdl: "extend type Mutation { badAct: String }",
            fields: [("Mutation.badAct", .read)]
        ),
        Refused(
            testDescription: "invalid SDL", reason: .invalidSDL, id: "bad", prefix: "Bad",
            sdl: "extend type Query { badOne: ", fields: []
        ),
        Refused(
            testDescription: "SDL naming an undefined type", reason: .invalidSDL, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badOne: BadMissing }",
            fields: [("Query.badOne", .read)]
        ),
        Refused(
            testDescription: "SDL replacing the schema definition", reason: .invalidSDL, id: "bad",
            prefix: "Bad", sdl: "extend schema { subscription: BadSub } type BadSub { a: String }",
            fields: [("BadSub.a", .read)]
        ),
        Refused(
            testDescription: "extension of a core type", reason: .foreignTypeExtension, id: "bad",
            prefix: "Bad", sdl: "extend type KoineGrant { badSecret: String }",
            fields: [("KoineGrant.badSecret", .read)]
        ),
        Refused(
            testDescription: "action on the Query root", reason: .actionOutsideMutation, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badAct: String }",
            fields: [("Query.badAct", .control)]
        ),
        Refused(
            testDescription: "action nested under a query", reason: .actionOutsideMutation,
            id: "bad", prefix: "Bad",
            sdl: "extend type Query { badSpace: BadSpace } type BadSpace { focus: String }",
            fields: [("Query.badSpace", .read), ("BadSpace.focus", .control)]
        ),
        Refused(
            testDescription: "input default that expands through its own type",
            reason: .invalidSDL, id: "bad", prefix: "Bad",
            sdl: "input BadIn { a: BadIn = {} } extend type Query { badValue(i: BadIn): String }",
            fields: [("Query.badValue", .read)]
        ),
        Refused(
            testDescription: "SDL nested deeper than the parser is allowed", reason: .invalidSDL,
            id: "bad", prefix: "Bad",
            sdl: "extend type Query { badValue: "
                + String(repeating: "[", count: 5_000) + "Int" + String(repeating: "]", count: 5_000)
                + " }",
            fields: [("Query.badValue", .read)]
        ),
        Refused(
            testDescription: "field typed as a core object", reason: .invalidSDL, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badGrant: KoineGrant }",
            fields: [("Query.badGrant", .read)]
        ),
        Refused(
            testDescription: "schema that fails validation", reason: .invalidSDL, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badEmpty: BadEmpty } type BadEmpty",
            fields: [("Query.badEmpty", .read)]
        ),
        Refused(
            testDescription: "output list of nullable elements", reason: .invalidSDL, id: "bad",
            prefix: "Bad", sdl: "extend type Query { badList: [String] }",
            fields: [("Query.badList", .read)]
        ),
        Refused(
            testDescription: "directive applied to a core root type",
            reason: .foreignTypeExtension, id: "bad", prefix: "Bad",
            sdl: "directive @badMark on OBJECT extend type Query @badMark { badValue: String }",
            fields: [("Query.badValue", .read)]
        ),
        Refused(
            testDescription: "required feature the host lacks", reason: .unsupportedFeature,
            id: "bad", prefix: "Bad", sdl: "extend type Query { badValue: String }",
            fields: [("Query.badValue", .read)], requiredFeatures: ["time-travel"]
        ),
    ]

    /// The whole contribution is refused with its diagnostic, nothing of it is
    /// published or started, and a sibling's contribution is served intact.
    @Test(arguments: refused)
    func badContributionIsRefusedWhole(_ bad: Refused) async throws {
        let stub = Stub(
            id: bad.id, prefix: bad.prefix, sdl: bad.sdl, fields: bad.fields,
            requiredFeatures: bad.requiredFeatures
        )
        let harness = try await Harness(providers: [stub.active, Stub.good("good").active])

        let diagnostics = harness.server.providerDiagnostics
        #expect(diagnostics.map(\.reason) == [bad.reason])
        #expect(diagnostics.first?.providerId == bad.id)
        #expect(stub.provider.startCount == 0)

        let credential = try await harness.consoleGrant(label: "c", capabilities: ["good:read"])
        let sibling = try await harness.post("{ goodValue }", authorization: "Bearer \(credential)")
        #expect(sibling.data?["goodValue"] as? String == "ok")

        let names = try await schemaNames(harness, credential)
        let served = ["Query", "Mutation", "KoineGrant", "koine"]
        let contributed = Set(bad.fields.flatMap { $0.0.split(separator: ".").map(String.init) })
            .subtracting(served)
        #expect(Set(names).isDisjoint(with: contributed), "\(names)")
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        let available = (koine.data?["koine"] as? [String: Any])?["availableCapabilities"]
        #expect(available as? [String] == ["koine:manage", "good:read", "good:control"])
        await harness.stop()
    }

    /// Every type name and every root field name in the served schema.
    private func schemaNames(_ harness: Harness, _ credential: String) async throws -> [String] {
        let reply = try await harness.post(
            Harness.introspection, authorization: "Bearer \(credential)"
        )
        #expect(reply.errors.isEmpty)
        let types = (reply.data?["__schema"] as? [String: Any])?["types"] as? [[String: Any]] ?? []
        return types.flatMap { type -> [String] in
            let name = type["name"] as? String ?? ""
            let fields = ["Query", "Mutation"].contains(name)
                ? (type["fields"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
                : []
            return [name] + fields
        }
    }

    @Test func twoProvidersClaimingOneIdentifierAreBothRefused() async throws {
        let first = Stub.good("twin")
        let second = Stub(
            id: "twin", prefix: "Other", sdl: "extend type Query { otherValue: String }",
            fields: [("Query.otherValue", .read)]
        )
        let harness = try await Harness(
            providers: [first.active, second.active, Stub.good("good").active]
        )

        let diagnostics = harness.server.providerDiagnostics
        #expect(diagnostics.map(\.reason) == [.duplicateIdentifier, .duplicateIdentifier])
        #expect(first.provider.startCount == 0 && second.provider.startCount == 0)
        let credential = try await harness.consoleGrant(label: "c", capabilities: ["good:read"])
        let names = try await schemaNames(harness, credential)
        #expect(!names.contains("twinValue") && !names.contains("otherValue"))
        #expect(names.contains("goodValue"))
        await harness.stop()
    }

    @Test func twoProvidersDefiningOneNameAreBothRefused() async throws {
        let git = Stub(
            id: "git", prefix: "Git",
            sdl: "extend type Query { gitHubRepo: GitHubRepo } type GitHubRepo { a: String }",
            fields: [("Query.gitHubRepo", .read), ("GitHubRepo.a", .read)]
        )
        let gitHub = Stub(
            id: "github", prefix: "GitHub",
            sdl: "extend type Query { gitHubMine: GitHubRepo } type GitHubRepo { b: String }",
            fields: [("Query.gitHubMine", .read), ("GitHubRepo.b", .read)]
        )
        for order in [[git, gitHub], [gitHub, git]] {
            let harness = try await Harness(providers: order.map(\.active))
            let diagnostics = harness.server.providerDiagnostics
            #expect(diagnostics.map(\.reason) == [.nameCollision, .nameCollision])
            await harness.stop()
        }
    }

    @Test func onlyTheBundledProviderOwnsDesktop() async throws {
        func desktop(_ origin: ActiveProvider.Origin) -> Stub {
            Stub(
                id: "desktop", prefix: "Desktop", sdl: "extend type Query { desktopValue: String }",
                fields: [("Query.desktopValue", .read)], origin: origin
            )
        }
        let bundled = desktop(.bundled)
        let impostor = desktop(.external)
        let harness = try await Harness(providers: [impostor.active, bundled.active])

        #expect(harness.server.providerDiagnostics.map(\.reason) == [.reservedName])
        #expect(bundled.provider.startCount == 1 && impostor.provider.startCount == 0)
        let credential = try await harness.consoleGrant(label: "c", capabilities: ["desktop:read"])
        let reply = try await harness.post("{ desktopValue }", authorization: "Bearer \(credential)")
        #expect(reply.data?["desktopValue"] as? String == "ok")
        await harness.stop()
    }

    @Test func aMutationReceiptMayRequireControl() async throws {
        let stub = Stub(
            id: "act", prefix: "Act",
            sdl: "extend type Mutation { actDo: ActReceipt } type ActReceipt { done: String }",
            fields: [("Mutation.actDo", .control), ("ActReceipt.done", .control)],
            resolve: { $0.parent == nil ? .success(.object([:])) : .success(.string("yes")) }
        )
        let harness = try await Harness(providers: [stub.active])
        #expect(harness.server.providerDiagnostics.isEmpty)

        let credential = try await harness.consoleGrant(label: "c", capabilities: ["act:control"])
        let reply = try await harness.post(
            "mutation { actDo { done } }", authorization: "Bearer \(credential)"
        )
        #expect((reply.data?["actDo"] as? [String: Any])?["done"] as? String == "yes")
        await harness.stop()
    }

    // MARK: Schema digest

    private func digest(_ providers: [Stub]) async throws -> String {
        let harness = try await Harness(providers: providers.map(\.active))
        #expect(harness.server.providerDiagnostics.isEmpty)
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let reply = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        await harness.stop()
        return try #require((reply.data?["koine"] as? [String: Any])?["schemaDigest"] as? String)
    }

    @Test func digestIgnoresCompositionOrderAndSeesADifference() async throws {
        let forward = try await digest([Stub.good("alpha"), Stub.good("beta")])
        let backward = try await digest([Stub.good("beta"), Stub.good("alpha")])
        #expect(forward == backward)

        let changed = try await digest([Stub.good("alpha"), Stub.good("beta", description: "x")])
        #expect(changed != forward)
        #expect(try await digest([Stub.good("alpha")]) != forward)
    }

    // MARK: Introspection admission

    private func large() -> Stub {
        let fields = (0..<400).map { "\"\(String(repeating: "d", count: 80))\" bigField\($0)(a: [[Int]] = 1, b: Float = 2): String" }
        return Stub(
            id: "big", prefix: "Big", sdl: "extend type Query { \(fields.joined(separator: " ")) }",
            fields: (0..<400).map { ("Query.bigField\($0)", .read) }
        )
    }

    private func introspectionBytes(_ providers: [Stub]) async throws -> Int {
        let harness = try await Harness(providers: providers.map(\.active))
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let reply = try await harness.raw(Harness.introspection, bearer: credential)
        #expect(reply.errors.isEmpty)
        await harness.stop()
        return reply.body.count
    }

    @Test func contributionThatWouldBreakFullIntrospectionIsRefused() async throws {
        let served = try await introspectionBytes([large()])
        let coreAlone = try await introspectionBytes([])
        #expect(served > coreAlone * 2)

        // One byte short of what the composed schema's introspection needs.
        var policy = RequestPolicy.version1
        policy.maximumResponseBytes = served - 1
        let harness = try await Harness(policy: policy, providers: [large().active])
        #expect(harness.server.providerDiagnostics.map(\.reason) == [.introspectionLimit])

        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let reply = try await harness.raw(Harness.introspection, bearer: credential)
        #expect(reply.status == 200 && reply.errors.isEmpty)
        #expect(reply.body.count == coreAlone)
        await harness.stop()
    }

    @Test func contributionWithinTheLimitIsAdmitted() async throws {
        let served = try await introspectionBytes([large()])
        var policy = RequestPolicy.version1
        policy.maximumResponseBytes = served * 2
        let harness = try await Harness(policy: policy, providers: [large().active])
        #expect(harness.server.providerDiagnostics.isEmpty)
        await harness.stop()
    }
}
