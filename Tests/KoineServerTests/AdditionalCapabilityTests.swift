import Foundation
import KoineProviderAPI
import Testing

@testable import KoineCore

/// The "Additional capability requirements" extension of docs/specs/machine.md,
/// through the engine every transport executes through. The providers are
/// in-test contributions: `acts` declares the additional requirements, and the
/// three owners it names exist only to be named. What `acts` was asked to do is
/// read back from its own call log, so "no action ran" is observed, not inferred.
///
/// The framework and loader halves — the manifest's minimum minor, the
/// declaration in the descriptor and an old host's refusal — are
/// `ProviderLoaderTests`' and the independently built pairs' (`task compat`).
@Suite struct AdditionalCapabilityTests {
    // MARK: Fixture contributions

    /// What the `acts` provider was asked to resolve, by resolver identifier.
    final class CallLog: @unchecked Sendable {
        private let lock = NSLock()
        private var calls: [String] = []
        func record(_ resolver: String) { lock.withLock { calls.append(resolver) } }
        var all: [String] { lock.withLock { calls } }
        func count(_ resolver: String) -> Int { all.filter { $0 == resolver }.count }
    }

    typealias Requirement = ProviderCapabilityRequirement

    static let acts = """
        input ActsTarget { ref: Reference! more: [Reference!] backup: Reference = "koine://zed/7" }
        type ActsReceipt { name: String! }
        extend type Query {
          actsPeek(ref: Reference): String
          actsPlainRead: String
        }
        extend type Mutation {
          actsPlain: ActsReceipt
          actsStop(name: String!): ActsReceipt
          actsLaunch(name: String!, ref: Reference = "koine://ledger/9"): ActsReceipt
          actsAim(target: ActsTarget!): ActsReceipt
        }
        """

    /// The registrations, deliberately not in code-point order: the host orders.
    static func registrations(
        _ additional: [String: [Requirement]] = [
            "Query.actsPeek": [
                Requirement(providerId: "zed", kind: .read),
                Requirement(providerId: "ledger", kind: .read),
            ],
            "Mutation.actsStop": [Requirement(providerId: "sink", kind: .control)],
            "Mutation.actsLaunch": [
                Requirement(providerId: "zed", kind: .control),
                Requirement(providerId: "sink", kind: .control),
                Requirement(providerId: "ledger", kind: .read),
            ],
            "Mutation.actsAim": [Requirement(providerId: "sink", kind: .control)],
        ]
    ) -> [ProviderFieldRegistration] {
        let authorities: [(String, ProviderFieldAuthority)] = [
            ("Query.actsPeek", .read), ("Query.actsPlainRead", .read),
            ("Mutation.actsPlain", .control), ("Mutation.actsStop", .control),
            ("Mutation.actsLaunch", .control), ("Mutation.actsAim", .control),
            ("ActsReceipt.name", .control),
        ]
        return authorities.map {
            ProviderFieldRegistration(
                coordinate: $0.0, resolverId: $0.0, authority: $0.1,
                additionalRequirements: additional[$0.0] ?? []
            )
        }
    }

    static func actsProvider(
        log: CallLog, declares: Bool = true, fields: [ProviderFieldRegistration] = registrations()
    ) -> ActiveProvider {
        let provider = StubProvider { request in
            log.record(request.resolverId)
            switch request.resolverId {
            case "ActsReceipt.name": return .success(.string("receipt"))
            case let action where action.hasPrefix("Mutation."):
                return .success(.object(["name": .string(action)]))
            default: return .success(.string("ok"))
            }
        }
        return ActiveProvider(
            descriptor: ProviderDescriptor(
                providerId: "acts", graphQLPrefix: "Acts", schemaSDL: acts, fields: fields,
                requiredFeatures: declares ? [ProviderDescriptor.additionalCapabilitiesFeature] : []
            ),
            provider: provider
        )
    }

    static func owners(_ names: [String] = ["ledger", "sink", "zed"]) -> [ActiveProvider] {
        names.map { Stub.good($0).active }
    }

    // MARK: Bench

    private final class Bench: @unchecked Sendable {
        let store = ScriptedStore()
        let log = CallLog()
        private(set) var engine: Engine!
        private let lock = NSLock()
        private var hook: OrderingHook = { _ in }

        init(providers: ((CallLog) -> [ActiveProvider])? = nil) async throws {
            let log = log
            engine = try Engine(
                store: store, instanceId: "bench", policy: .version1,
                providers: providers?(log) ?? ([AdditionalCapabilityTests.actsProvider(log: log)]
                    + AdditionalCapabilityTests.owners())
            ) { [unowned self] point in
                let hook = self.lock.withLock { self.hook }
                await hook(point)
            }
            await engine.startProviders()
        }

        func when(_ point: OrderingPoint, _ body: @escaping @Sendable () async -> Void) {
            let fired = NSLock()
            nonisolated(unsafe) var done = false
            lock.withLock {
                hook = { reached in
                    guard reached == point else { return }
                    let first = fired.withLock { defer { done = true }; return !done }
                    if first { await body() }
                }
            }
        }

        struct Reply {
            let outcome: EngineResponse.Outcome
            let json: [String: Any]
            var data: [String: Any]? { json["data"] as? [String: Any] }
            var errors: [[String: Any]] { json["errors"] as? [[String: Any]] ?? [] }

            func error(at path: [String]) -> [String: Any]? {
                errors.first { $0["path"] as? [String] == path }
            }
            func extensions(at path: [String]) -> [String: Any] {
                error(at: path)?["extensions"] as? [String: Any] ?? [:]
            }
        }

        func run(
            _ query: String, _ variables: [String: Any] = [:], as principal: Principal
        ) async throws -> Reply {
            let request = try EngineRequest(
                jsonBody: try Harness.requestBody(query, variables: variables)
            )
            let response = await engine.execute(request, as: principal)
            return Reply(
                outcome: response.outcome,
                json: try JSONSerialization.jsonObject(with: response.body) as? [String: Any] ?? [:]
            )
        }

        func grant(_ capabilities: [String]) async throws -> (id: String, principal: Principal) {
            let reply = try await run(
                Harness.createGrant, ["label": "c", "capabilities": capabilities],
                as: .localConsole
            )
            let created = try #require(reply.data?["koineCreateGrant"] as? [String: Any])
            let id = try #require((created["grant"] as? [String: Any])?["grantId"] as? String)
            return (id, .grant(id: id))
        }

        func revoke(_ id: String) async {
            let reply = try? await run(
                "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { __typename } }",
                ["id": id], as: .localConsole
            )
            #expect(reply?.errors.isEmpty == true)
        }
    }

    /// The order the contract states for `actsLaunch(ref: "koine://ledger/1")`:
    /// the field's own, the additional set in code-point order, then the
    /// argument's owner, whose `sink` twin is the duplicate that is dropped.
    static let launchSet = [
        "acts:control", "ledger:read", "sink:control", "zed:control", "ledger:control",
    ]
    static let launch = #"mutation { actsLaunch(name: "n", ref: "koine://ledger/1") { __typename } }"#

    // MARK: Order and the complete set

    @Test func theFirstUnmetMemberIsNamedAndTheWholeOrderedSetIsCarried() async throws {
        let bench = try await Bench()
        for held in 0..<Self.launchSet.count {
            let client = try await bench.grant(Array(Self.launchSet.prefix(held)))
            let reply = try await bench.run(Self.launch, as: client.principal)

            #expect(reply.outcome.isForbidden)
            let extensions = reply.extensions(at: ["actsLaunch"])
            #expect(extensions["requiredCapability"] as? String == Self.launchSet[held])
            #expect(extensions["requiredCapabilities"] as? [String] == Self.launchSet)
            #expect(extensions["phase"] as? String == "authorization")
            #expect(extensions["permissionClass"] as? String == "capability")
        }
        #expect(bench.log.all.isEmpty)

        let client = try await bench.grant(Self.launchSet)
        let reply = try await bench.run(Self.launch, as: client.principal)
        #expect(reply.errors.isEmpty)
        #expect(bench.log.all == ["Mutation.actsLaunch"])
    }

    @Test func aBaselineRegistrationKeepsItsErrorExactly() async throws {
        let bench = try await Bench()
        let client = try await bench.grant([])
        // `actsPlain` declares nothing additional, so it is the old contract.
        let reply = try await bench.run(
            "mutation { actsPlain { __typename } }", as: client.principal
        )
        let extensions = reply.extensions(at: ["actsPlain"])
        #expect(extensions["requiredCapability"] as? String == "acts:control")
        #expect(extensions["requiredCapabilities"] == nil)
        #expect(Set(extensions.keys) == ["kind", "permissionClass", "phase", "requiredCapability"])
        #expect(bench.log.all.isEmpty)
    }

    // MARK: Whole-mutation preflight

    static let twoActions = """
        mutation Two($skip: Boolean = false) {
          fine: actsPlain { __typename }
          stopped: actsStop(name: "x") @skip(if: $skip) { __typename }
        }
        """

    @Test func anyDeniedActionMeansZeroActionCalls() async throws {
        let bench = try await Bench()
        // The own capability only: `actsStop` also needs sink:control.
        let client = try await bench.grant(["acts:control"])

        let denied = try await bench.run(Self.twoActions, as: client.principal)
        #expect(denied.outcome.isForbidden)
        #expect(denied.data == nil)
        #expect(denied.errors.count == 1)
        let extensions = denied.extensions(at: ["stopped"])
        #expect(extensions["requiredCapability"] as? String == "sink:control")
        #expect(extensions["requiredCapabilities"] as? [String] == ["acts:control", "sink:control"])
        #expect(bench.log.all.isEmpty, "no action of the operation may begin")

        // A skipped action does not count.
        let skipped = try await bench.run(Self.twoActions, ["skip": true], as: client.principal)
        #expect(skipped.errors.isEmpty)
        #expect(bench.log.all == ["Mutation.actsPlain"])
    }

    @Test func fragmentsAndAliasesAreExpandedBeforeTheyAreChecked() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["acts:control"])
        let document = """
            mutation($on: Boolean!) {
              first: actsPlain { __typename }
              ...Later @include(if: $on)
            }
            fragment Later on Mutation {
              ... on Mutation { renamed: actsStop(name: "x") { __typename } }
            }
            """
        let denied = try await bench.run(document, ["on": true], as: client.principal)
        #expect(denied.outcome.isForbidden)
        // The original response path is the alias; the requirement is the field's.
        #expect(denied.extensions(at: ["renamed"])["requiredCapability"] as? String == "sink:control")
        #expect(bench.log.all.isEmpty)

        let hidden = try await bench.run(document, ["on": false], as: client.principal)
        #expect(hidden.errors.isEmpty)
        #expect(bench.log.all == ["Mutation.actsPlain"])
    }

    @Test func anArgumentDefaultNamesItsOwnerButAnExplicitNullDoesNot() async throws {
        let bench = try await Bench()
        // Everything but ledger:control, which only the default reference needs.
        let client = try await bench.grant(
            ["acts:control", "ledger:read", "sink:control", "zed:control"]
        )
        let defaulted = try await bench.run(
            #"mutation { actsLaunch(name: "n") { __typename } }"#, as: client.principal
        )
        let extensions = defaulted.extensions(at: ["actsLaunch"])
        #expect(extensions["requiredCapability"] as? String == "ledger:control")
        #expect(extensions["requiredCapabilities"] as? [String] == Self.launchSet)
        #expect(bench.log.all.isEmpty)

        let explicit = try await bench.run(
            #"mutation { actsLaunch(name: "n", ref: null) { __typename } }"#, as: client.principal
        )
        #expect(explicit.errors.isEmpty)
        #expect(bench.log.all == ["Mutation.actsLaunch"])
    }

    @Test func nestedReferenceInputsNameTheirOwnersAfterTheAdditionalSet() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["acts:control", "sink:control"])
        let aim = """
            mutation($t: ActsTarget!) { actsAim(target: $t) { __typename } }
            """
        let denied = try await bench.run(
            aim, ["t": ["ref": "koine://zed/1", "more": ["koine://ledger/2"]]],
            as: client.principal
        )
        let extensions = denied.extensions(at: ["actsAim"])
        #expect(extensions["requiredCapability"] as? String == "ledger:control")
        #expect(
            extensions["requiredCapabilities"] as? [String]
                == ["acts:control", "sink:control", "ledger:control", "zed:control"]
        )
        #expect(bench.log.all.isEmpty)
    }

    @Test func whatPreflightReadsIsWhatDispatchWouldRead() async throws {
        // Each input hides a reference owner from an untyped reading of the
        // request and shows it to execution: a variable's own default, a lone
        // value for a list, an input field left to its default. Preflight must
        // see all three, or a later action would be refused after an earlier one ran.
        let bench = try await Bench()
        let aim = "actsAim(target: %@) { __typename }"
        // Lacks ledger:control, which the three inputs below each name.
        let noLedger = try await bench.grant(["acts:control", "sink:control", "zed:control"])
        // Lacks zed:control, which only the input field's default names.
        let noZed = try await bench.grant(["acts:control", "sink:control", "ledger:control"])
        let cases: [(String, [String: Any], Principal, String)] = [
            (
                "mutation($r: Reference = \"koine://ledger/1\") { first: actsPlain { __typename } second: "
                    + String(format: aim, "{ ref: $r }") + " }",
                [:], noLedger.principal, "ledger:control"
            ),
            (
                "mutation { first: actsPlain { __typename } second: "
                    + String(format: aim, #"{ ref: "koine://sink/1", more: "koine://ledger/1" }"#) + " }",
                [:], noLedger.principal, "ledger:control"
            ),
            (
                "mutation { first: actsPlain { __typename } second: "
                    + String(format: aim, #"{ ref: "koine://ledger/1" }"#) + " }",
                [:], noZed.principal, "zed:control"
            ),
        ]
        for (document, variables, principal, missing) in cases {
            let reply = try await bench.run(document, variables, as: principal)
            #expect(reply.outcome.isForbidden, "\(document)")
            #expect(reply.extensions(at: ["second"])["requiredCapability"] as? String == missing)
            #expect(reply.extensions(at: ["second"])["phase"] as? String == "authorization")
        }
        #expect(bench.log.all.isEmpty, "no action of any refused operation may begin")

        // A supplied variable is a value, and a supplied null names no owner.
        let given = try await bench.run(
            "mutation($r: Reference = \"koine://ledger/1\") { actsLaunch(name: \"n\", ref: $r) { __typename } }",
            ["r": NSNull()],
            as: try await bench.grant(["acts:control", "ledger:read", "sink:control", "zed:control"]).principal
        )
        #expect(given.errors.isEmpty)
    }

    @Test func argumentOwnersOfAFieldWithASetFollowCodePointOrderOfTheirCapabilities() async throws {
        // `zed1:control` sorts before `zed:control` ('1' precedes ':'), although
        // the identifier `zed` sorts before `zed1`.
        let bench = try await Bench { log in
            [Self.actsProvider(log: log)] + Self.owners(["ledger", "sink", "zed", "zed1"])
        }
        let client = try await bench.grant(["acts:control", "sink:control"])
        let reply = try await bench.run(
            #"mutation { actsAim(target: { ref: "koine://ledger/1", more: ["koine://zed/1", "koine://zed1/1"] }) { __typename } }"#,
            as: client.principal
        )
        #expect(
            reply.extensions(at: ["actsAim"])["requiredCapabilities"] as? [String]
                == ["acts:control", "sink:control", "ledger:control", "zed1:control", "zed:control"]
        )
    }

    // MARK: Dispatch admission

    @Test func revocationBetweenActionsStopsTheNextActionWithTheSameSet() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["acts:control", "sink:control"])
        bench.when(.admitted("Mutation.actsPlain")) { await bench.revoke(client.id) }

        let reply = try await bench.run(
            """
            mutation {
              first: actsPlain { __typename }
              second: actsStop(name: "x") { __typename }
            }
            """, as: client.principal
        )

        // Preflight passed, the first action was in flight and finished, and the
        // second was refused as it was about to start, at its own path.
        #expect(reply.outcome.isExecuted)
        #expect((reply.data?["first"] as? [String: Any])?["__typename"] as? String == "ActsReceipt")
        #expect(reply.data?["second"] is NSNull)
        let extensions = reply.extensions(at: ["second"])
        #expect(extensions["phase"] as? String == "execution")
        #expect(extensions["requiredCapabilities"] as? [String] == ["acts:control", "sink:control"])
        #expect(bench.log.all == ["Mutation.actsPlain"])
    }

    @Test func aRevokedAdditionalCapabilityStopsTheActionEvenWhenTheOwnOneRemains() async throws {
        let bench = try await Bench()
        // A grant that lacks only the additional member is refused at dispatch
        // exactly as at preflight, and the provider is never entered.
        let client = try await bench.grant(["acts:control"])
        let reply = try await bench.run(
            #"mutation { actsStop(name: "x") { __typename } }"#, as: client.principal
        )
        #expect(reply.extensions(at: ["actsStop"])["requiredCapability"] as? String == "sink:control")
        #expect(bench.log.all.isEmpty)
    }

    // MARK: Reads

    @Test func aReadRequiresTheWholeSetBeforeItsResolverRuns() async throws {
        let bench = try await Bench()
        let readSet = ["acts:read", "ledger:read", "zed:read"]
        for held in 0..<readSet.count {
            let client = try await bench.grant(Array(readSet.prefix(held)))
            let reply = try await bench.run(
                #"{ peek: actsPeek(ref: "koine://ledger/1") }"#, as: client.principal
            )
            #expect(reply.data?["peek"] is NSNull)
            let extensions = reply.extensions(at: ["peek"])
            #expect(extensions["requiredCapability"] as? String == readSet[held])
            #expect(extensions["requiredCapabilities"] as? [String] == readSet)
            #expect(extensions["phase"] as? String == "execution")
        }
        #expect(bench.log.all.isEmpty)

        let client = try await bench.grant(readSet)
        let reply = try await bench.run(
            #"{ peek: actsPeek(ref: "koine://ledger/1") }"#, as: client.principal
        )
        #expect(reply.data?["peek"] as? String == "ok")
        #expect(bench.log.all == ["Query.actsPeek"])
    }

    @Test func aReadRevokedBeforePublicationIsWithheldUnderTheSameSet() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["acts:read", "ledger:read", "zed:read"])
        bench.when(.resolved("Query.actsPeek")) { await bench.revoke(client.id) }

        let reply = try await bench.run(#"{ actsPeek }"#, as: client.principal)

        #expect(bench.log.all == ["Query.actsPeek"], "the resolver ran, then its value was withheld")
        #expect(reply.data?["actsPeek"] is NSNull)
        let extensions = reply.extensions(at: ["actsPeek"])
        #expect(extensions["requiredCapabilities"] as? [String] == ["acts:read", "ledger:read", "zed:read"])
    }

    @Test func aReadOfABaselineFieldIsUnchangedByTheFeature() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["acts:read"])
        let reply = try await bench.run("{ actsPlainRead }", as: client.principal)
        #expect(reply.data?["actsPlainRead"] as? String == "ok")
    }

    // MARK: Composition

    /// The diagnostic reasons of an engine's refusals, by provider.
    private static func refusals(_ engine: Engine) -> [String: ProviderDiagnostic.Reason] {
        Dictionary(
            engine.providerDiagnostics.map { ($0.providerId, $0.reason) }, uniquingKeysWith: { $1 }
        )
    }

    private static func engine(_ providers: [ActiveProvider]) throws -> Engine {
        try Engine(store: ScriptedStore(), instanceId: "compose", providers: providers)
    }

    @Test func aDescriptorUsingTheSetWithoutDeclaringTheFeatureIsRefused() throws {
        let log = CallLog()
        let engine = try Self.engine(
            [Self.actsProvider(log: log, declares: false)] + Self.owners()
        )
        #expect(Self.refusals(engine)["acts"] == .undeclaredFeature)
        #expect(log.all.isEmpty)
    }

    @Test func aDescriptorWithoutTheSetNeedsNoDeclaration() throws {
        let log = CallLog()
        let fields = Self.registrations([:])
        let engine = try Self.engine(
            [Self.actsProvider(log: log, declares: false, fields: fields)]
        )
        #expect(engine.providerDiagnostics.isEmpty)
    }

    static let refusedSets: [(String, [String: [Requirement]], ProviderDiagnostic.Reason)] = [
        (
            "core management authority",
            ["Mutation.actsStop": [Requirement(providerId: "koine", kind: .control)]],
            .invalidCapabilityRequirement
        ),
        (
            "an identifier no provider can have",
            ["Mutation.actsStop": [Requirement(providerId: "Bad Id", kind: .control)]],
            .invalidCapabilityRequirement
        ),
        (
            "an identifier under the core's prefix",
            ["Mutation.actsStop": [Requirement(providerId: "koinemanage", kind: .read)]],
            .invalidCapabilityRequirement
        ),
        (
            "additional control on a query-reachable field",
            ["Query.actsPeek": [Requirement(providerId: "sink", kind: .control)]],
            .invalidCapabilityRequirement
        ),
    ]

    @Test(arguments: refusedSets)
    func aForbiddenRequirementRefusesTheWholeContribution(
        _ refused: (String, [String: [Requirement]], ProviderDiagnostic.Reason)
    ) throws {
        let log = CallLog()
        let engine = try Self.engine(
            [Self.actsProvider(log: log, fields: Self.registrations(refused.1))] + Self.owners()
        )
        #expect(Self.refusals(engine)["acts"] == refused.2, "\(refused.0)")
        #expect(engine.providerDiagnostics.count == 1)
    }

    @Test func aReceiptFieldReachedOnlyByAMutationMayAddControl() throws {
        let log = CallLog()
        var additional = Self.registrations().reduce(into: [String: [Requirement]]()) {
            $0[$1.coordinate] = $1.additionalRequirements
        }
        additional["ActsReceipt.name"] = [Requirement(providerId: "sink", kind: .control)]
        let engine = try Self.engine(
            [Self.actsProvider(log: log, fields: Self.registrations(additional))] + Self.owners()
        )
        #expect(engine.providerDiagnostics.isEmpty)
    }

    @Test func aMissingOwnerRemovesTheContributionAndNamesIt() async throws {
        let log = CallLog()
        let engine = try Self.engine(
            [Self.actsProvider(log: log)] + Self.owners(["ledger", "zed"])  // no sink
        )
        let diagnostics = engine.providerDiagnostics
        #expect(diagnostics.map(\.providerId) == ["acts"])
        #expect(diagnostics.first?.reason == .missingCapabilityOwner)
        #expect(diagnostics.first?.message.contains("sink") == true)

        let statuses = await engine.providerStatuses
        #expect(statuses.first { $0.provider == "acts" }?.state == .rejected)
        #expect(statuses.first { $0.provider == "acts" }?.diagnostic?.contains("sink") == true)

        // Nothing of it is published: not its fields, not its capabilities.
        let reply = try await Console.run(engine, "{ koine { availableCapabilities } }")
        let available = ((reply.data?["koine"] as? [String: Any])?["availableCapabilities"] as? [String]) ?? []
        #expect(!available.contains { $0.hasPrefix("acts:") })
        let field = try await Console.run(engine, "{ actsPlainRead }")
        #expect(field.outcome.isInvalid)
    }

    @Test func removalRepeatsUntilTheAdmittedSetStopsChanging() throws {
        // `chain` needs acts, which needs sink, which is absent: sink's absence
        // removes acts, and acts' removal removes chain.
        let log = CallLog()
        let chain = Stub(
            id: "chain", prefix: "Chain", sdl: "extend type Query { chainValue: String }",
            fields: [("Query.chainValue", .read)],
            additional: ["Query.chainValue": [Requirement(providerId: "acts", kind: .read)]]
        )
        let engine = try Self.engine(
            [chain.active, Self.actsProvider(log: log)] + Self.owners(["ledger", "zed"])
        )
        let refusals = Self.refusals(engine)
        #expect(refusals["acts"] == .missingCapabilityOwner)
        #expect(refusals["chain"] == .missingCapabilityOwner)
        #expect(refusals["ledger"] == nil && refusals["zed"] == nil)
        #expect(chain.provider.startCount == 0)
    }

    @Test func aRefusedOwnerRemovesItsDependents() throws {
        let log = CallLog()
        // `sink` is offered and refused (its SDL is invalid), so it is not admitted.
        let broken = Stub(
            id: "sink", prefix: "Sink", sdl: "extend type Query { sinkValue: ",
            fields: []
        )
        let engine = try Self.engine(
            [Self.actsProvider(log: log), broken.active] + Self.owners(["ledger", "zed"])
        )
        let refusals = Self.refusals(engine)
        #expect(refusals["sink"] == .invalidSDL)
        #expect(refusals["acts"] == .missingCapabilityOwner)
    }

    @Test func aRemovalDoesNotReadmitAnythingAlreadyRefused() async throws {
        // `big` is refused for introspection size because `acts`, composed first,
        // used the budget. Removing `acts` for its missing owner frees that
        // budget, and `big` stays refused: the cascade only removes.
        func big() -> Stub {
            let fields = (0..<400).map {
                "\"\(String(repeating: "d", count: 80))\" bigField\($0): String"
            }
            return Stub(
                id: "big", prefix: "Big", sdl: "extend type Query { \(fields.joined(separator: " ")) }",
                fields: (0..<400).map { ("Query.bigField\($0)", .read) }
            )
        }
        func introspectionBytes(_ engine: Engine) async throws -> Int {
            let request = try EngineRequest(
                jsonBody: try Harness.requestBody(Harness.introspection, variables: [:])
            )
            return await engine.execute(request, as: .localConsole).body.count
        }
        let alone = try await introspectionBytes(Self.engine([big().active]))

        // Room for `big` beside the core, not beside `acts` as well.
        var policy = RequestPolicy.version1
        policy.maximumResponseBytes = alone + 64
        let log = CallLog()
        let engine = try Engine(
            store: ScriptedStore(), instanceId: "budget", policy: policy,
            providers: [Self.actsProvider(log: log), big().active] + Self.owners(["ledger", "zed"])
        )
        var reasons = Self.refusals(engine)
        #expect(reasons["big"] == .introspectionLimit)
        #expect(reasons["acts"] == .missingCapabilityOwner)
        reasons["big"] = nil
        reasons["acts"] = nil
        #expect(reasons.isEmpty)
        let served = try await introspectionBytes(engine)
        #expect(served < alone, "neither `acts` nor `big` is in the schema")
    }

    @Test func aDependencyCycleSurvives() async throws {
        let first = Stub(
            id: "alpha", prefix: "Alpha", sdl: "extend type Query { alphaValue: String }",
            fields: [("Query.alphaValue", .read)],
            additional: ["Query.alphaValue": [Requirement(providerId: "beta", kind: .read)]]
        )
        let second = Stub(
            id: "beta", prefix: "Beta", sdl: "extend type Query { betaValue: String }",
            fields: [("Query.betaValue", .read)],
            additional: ["Query.betaValue": [Requirement(providerId: "alpha", kind: .read)]]
        )
        let engine = try Self.engine([first.active, second.active])
        #expect(engine.providerDiagnostics.isEmpty)
        await engine.startProviders()
        #expect(first.provider.startCount == 1 && second.provider.startCount == 1)
        await engine.stopProviders()
    }

    @Test func aSetThatOnlyRepeatsTheFieldsOwnCapabilityIsTheBaselineAndErrsAsIt() async throws {
        let own = Stub(
            id: "selfish", prefix: "Selfish",
            sdl: "extend type Mutation { selfishAct: String }",
            fields: [("Mutation.selfishAct", .control)],
            additional: ["Mutation.selfishAct": [Requirement(providerId: "selfish", kind: .control)]]
        )
        let engine = try Self.engine([own.active])
        let request = try EngineRequest(
            jsonBody: try Harness.requestBody("mutation { selfishAct }", variables: [:])
        )
        // Nobody holds selfish:control, and the console holds no provider capability.
        let reply = await engine.execute(request, as: .localConsole)
        let json = try JSONSerialization.jsonObject(with: reply.body) as? [String: Any]
        let extensions = ((json?["errors"] as? [[String: Any]])?.first?["extensions"]) as? [String: Any]
        #expect(extensions?["requiredCapability"] as? String == "selfish:control")
        #expect(extensions?["requiredCapabilities"] == nil)
    }

    @Test func aProviderNamingItselfAddsNothingToAnyoneElse() throws {
        let own = Stub(
            id: "selfish", prefix: "Selfish",
            sdl: "extend type Mutation { selfishAct: String }",
            fields: [("Mutation.selfishAct", .control)],
            additional: ["Mutation.selfishAct": [Requirement(providerId: "selfish", kind: .read)]]
        )
        let engine = try Self.engine([own.active])
        #expect(engine.providerDiagnostics.isEmpty)
    }

    @Test func aProviderThatFailsToStartKeepsItsPublicationAndRemovesNobody() async throws {
        let failing = FailingStartProvider()
        let owner = ActiveProvider(
            descriptor: ProviderDescriptor(
                providerId: "sink", graphQLPrefix: "Sink",
                schemaSDL: "extend type Query { sinkValue: String }",
                fields: [ProviderFieldRegistration(
                    coordinate: "Query.sinkValue", resolverId: "Query.sinkValue", authority: .read
                )]
            ),
            provider: failing
        )
        let log = CallLog()
        let engine = try Self.engine(
            [Self.actsProvider(log: log), owner] + Self.owners(["ledger", "zed"])
        )
        await engine.startProviders()

        // The owner failed startup after publication: it and its capability names
        // stay, and `acts`, which only names them, is neither removed nor unready.
        #expect(engine.providerDiagnostics.isEmpty)
        let statuses = await engine.providerStatuses
        #expect(statuses.first { $0.provider == "sink" }?.state == .failed)
        #expect(statuses.first { $0.provider == "acts" }?.state == .active)

        let reply = try await Console.run(engine, "{ koine { availableCapabilities } }")
        let available = ((reply.data?["koine"] as? [String: Any])?["availableCapabilities"] as? [String]) ?? []
        #expect(available.contains("sink:control") && available.contains("acts:control"))
        await engine.stopProviders()
    }
}

private final class FailingStartProvider: Provider, @unchecked Sendable {
    struct Failure: Error {}
    func start() async throws { throw Failure() }
    func stop() async {}
    func resolve(_ request: ResolutionRequest) async -> ResolutionResult { .success(.null) }
}

extension EngineResponse.Outcome {
    fileprivate var isForbidden: Bool { if case .forbidden = self { true } else { false } }
    fileprivate var isExecuted: Bool { if case .executed = self { true } else { false } }
    fileprivate var isInvalid: Bool { if case .invalidRequest = self { true } else { false } }
}

extension AdditionalCapabilityTests {
    fileprivate enum Console {
        /// A query as the local console, which holds management authority alone.
        static func run(_ engine: Engine, _ query: String) async throws -> (
            outcome: EngineResponse.Outcome, data: [String: Any]?
        ) {
            let request = try EngineRequest(jsonBody: try Harness.requestBody(query, variables: [:]))
            let response = await engine.execute(request, as: .localConsole)
            let json = try JSONSerialization.jsonObject(with: response.body) as? [String: Any]
            return (response.outcome, json?["data"] as? [String: Any])
        }
    }
}
