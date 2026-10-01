import Foundation
import KoineProviderAPI
import Testing

@testable import KoineCore
@testable import WorkspaceProviderLogic

/// The workspace launch and URL roots at the composition point (G): the real descriptor and
/// the SDL the bundle serves, composed through the engine every transport executes
/// through, with the provider a scripted stand-in. What is asserted is the core's
/// and the client's handling: authority, preflight, revocation, publication and the
/// deadline. Workspace's own mapping is `WorkspaceProviderLogicTests`'; a real
/// binary and a real application are the N and V seams'. No launch or open happens
/// here; the URL grammar is held through the engine with the real provider over a
/// native stand-in that records what reached it.
@Suite struct WorkspaceCompositionTests {
    // MARK: The contribution as composed

    static func schemaSDL() throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(
            contentsOf: root.appending(path: "Providers/WorkspaceProvider/schema.graphql"), encoding: .utf8)
    }

    /// What the provider was asked, in order, and what it answers.
    final class Script: @unchecked Sendable {
        private let lock = NSLock()
        private var asked: [String] = []
        private var behavior: @Sendable (ResolutionRequest) async -> ResolutionResult = { _ in
            .success(WorkspaceCompositionTests.available(pid: 4242))
        }

        var log: [String] { lock.withLock { asked } }
        func record(_ resolver: String) { lock.withLock { asked.append(resolver) } }
        func answer(_ handler: @escaping @Sendable (ResolutionRequest) async -> ResolutionResult) {
            lock.withLock { behavior = handler }
        }
        func run(_ request: ResolutionRequest) async -> ResolutionResult {
            let handler = lock.withLock { behavior }
            return await handler(request)
        }
    }

    final class ScriptedWorkspace: Provider, @unchecked Sendable {
        let script: Script
        init(_ script: Script) { self.script = script }
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
            script.record(request.resolverId)
            return await script.run(request)
        }
    }

    static func available(pid: Int?) -> ProviderValue {
        .object([
            "status": .string("AVAILABLE"),
            "value": .object([
                "process": pid.map {
                    .object(["pid": .int($0), "startedAt": .string("2027-01-15T08:00:00.123456Z")])
                } ?? .null
            ]),
            "dependency": .null,
        ])
    }

    static let dependency = ProviderValue.object([
        "status": .string("DEPENDENCY_UNAVAILABLE"),
        "value": .null,
        "dependency": .object([
            "reason": .string("APPLICATION_NOT_INSTALLED"), "guidance": .string("Install it."),
        ]),
    ])

    // MARK: Bench

    final class Bench: @unchecked Sendable {
        let script = Script()
        private(set) var engine: Engine!
        private let lock = NSLock()
        private var hook: OrderingHook = { _ in }

        /// `provider` replaces the scripted stand-in with a real one.
        init(policy: RequestPolicy = .version1, owners: [String] = ["desktop"], provider: (any Provider)? = nil)
            async throws
        {
            let workspace = ActiveProvider(
                descriptor: workspaceDescriptor(schemaSDL: try WorkspaceCompositionTests.schemaSDL()),
                provider: provider ?? ScriptedWorkspace(script), origin: .bundled
            )
            engine = try Engine(
                store: ScriptedStore(), instanceId: "workspace-bench", policy: policy,
                providers: [workspace] + owners.map { Self.owner($0) }
            ) { [unowned self] point in
                let hook = self.lock.withLock { self.hook }
                await hook(point)
            }
            await engine.startProviders()
        }

        /// The capability owner the workspace set names: desktop, with the read and
        /// the control capability its real contribution has.
        static func owner(_ id: String) -> ActiveProvider {
            let prefix = id.prefix(1).uppercased() + id.dropFirst()
            return Stub(
                id: id, prefix: prefix,
                sdl: "extend type Query { \(id)Value: String } extend type Mutation { \(id)Act: String }",
                fields: [("Query.\(id)Value", .read), ("Mutation.\(id)Act", .control)],
                origin: .bundled
            ).active
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
                errors.first { ($0["path"] as? [Any])?.map { "\($0)" } == path }
            }
            func extensions(at path: [String]) -> [String: Any] {
                error(at: path)?["extensions"] as? [String: Any] ?? [:]
            }
            var paths: [[String]] { errors.map { (($0["path"] as? [Any]) ?? []).map { "\($0)" } } }
        }

        func run(_ query: String, _ variables: [String: Any] = [:], as principal: Principal) async throws -> Reply {
            let request = try EngineRequest(jsonBody: try Harness.requestBody(query, variables: variables))
            let response = await engine.execute(request, as: principal)
            return Reply(
                outcome: response.outcome,
                json: try JSONSerialization.jsonObject(with: response.body) as? [String: Any] ?? [:]
            )
        }

        func grant(_ capabilities: [String]) async throws -> (id: String, principal: Principal) {
            let reply = try await run(
                Harness.createGrant, ["label": "c", "capabilities": capabilities], as: .localConsole)
            let created = try #require(
                reply.data?["koineCreateGrant"] as? [String: Any], "\(reply.errors)")
            let id = try #require((created["grant"] as? [String: Any])?["grantId"] as? String)
            return (id, .grant(id: id))
        }

        func revoke(_ id: String) async {
            _ = try? await run(
                "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { __typename } }", ["id": id],
                as: .localConsole)
        }
    }

    static let controls = ["workspace:control", "desktop:control"]
    static let launch = """
        mutation { launch: workspaceLaunchApplication(application: { bundleIdentifier: "com.apple.Notes" }) {
          status value { process { pid startedAt } } dependency { reason guidance } } }
        """

    static let openURL = """
        mutation { open: workspaceOpenURL(url: "https://example.com/search?q=koine%20plugins#top") {
          status value { process { pid startedAt } } dependency { reason guidance } } }
        """
    static let openURLWithVariable = """
        mutation($url: String!) { open: workspaceOpenURL(url: $url) {
          status value { process { pid } } dependency { reason guidance } } }
        """

    // MARK: Composition

    @Test func theContributionComposesAndServesTheLaunchAndURLRootsOnly() async throws {
        let bench = try await Bench()
        #expect(bench.engine.providerDiagnostics.isEmpty)
        let root = try await bench.grant([])
        let types = try await bench.run(
            """
            { m: __type(name: "Mutation") { fields { name } } r: __type(name: "WorkspaceRevealResult") { name } }
            """, as: root.principal)
        let names = ((types.data?["m"] as? [String: Any])?["fields"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
        #expect(names.filter { $0.hasPrefix("workspace") } == ["workspaceLaunchApplication", "workspaceOpenURL"])
        #expect(types.data?["r"] is NSNull, "a root that has not landed is not served")
    }

    @Test func aMissingDesktopOwnerRemovesWorkspaceAndNamesIt() async throws {
        let bench = try await Bench(owners: [])
        let diagnostics = bench.engine.providerDiagnostics
        #expect(diagnostics.map(\.providerId) == ["workspace"])
        #expect(diagnostics.first?.reason == .missingCapabilityOwner)
        #expect(diagnostics.first?.message.contains("desktop") == true)
    }

    // MARK: Authority

    @Test func bothControlsWithoutReadsAreEnough() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.launch, as: client.principal)

        #expect(reply.errors.isEmpty)
        let launch = try #require(reply.data?["launch"] as? [String: Any])
        #expect(launch["status"] as? String == "AVAILABLE")
        let process = try #require(((launch["value"] as? [String: Any])?["process"]) as? [String: Any])
        #expect(process["pid"] as? Int == 4242)
        #expect(launch["dependency"] is NSNull, "an available result carries no dependency")
        #expect(bench.script.log == ["launchApplication"])
    }

    @Test(arguments: [
        ["workspace:control"], ["desktop:control"], ["workspace:read", "desktop:read"],
        ["workspace:read", "desktop:control"], ["desktop:read", "desktop:control"], [],
    ])
    func eitherControlAloneIsRefusedBeforeAnythingIsInspected(held: [String]) async throws {
        let bench = try await Bench()
        let client = try await bench.grant(held)
        let reply = try await bench.run(Self.launch, as: client.principal)

        #expect(reply.outcome.isForbidden)
        let extensions = reply.extensions(at: ["launch"])
        // The field's own control first, then the additional set.
        let expected = held.contains("workspace:control") ? "desktop:control" : "workspace:control"
        #expect(extensions["requiredCapability"] as? String == expected)
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(extensions["phase"] as? String == "authorization")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(bench.script.log.isEmpty, "denial precedes inspection: the provider is never entered")
    }

    @Test func everyServedFieldRequiresTheSameSet() throws {
        let descriptor = workspaceDescriptor(schemaSDL: try Self.schemaSDL())
        #expect(descriptor.requiredFeatures == [ProviderDescriptor.additionalCapabilitiesFeature])
        let served = Set(descriptor.fields.map(\.coordinate))
        #expect(
            served == [
                "Mutation.workspaceLaunchApplication", "Mutation.workspaceOpenURL",
                "WorkspaceOpenResult.status", "WorkspaceOpenResult.value", "WorkspaceOpenResult.dependency",
                "WorkspaceOpenReceipt.process",
                "WorkspaceProcessIdentity.pid", "WorkspaceProcessIdentity.startedAt",
                "WorkspaceDependencyUnavailable.reason", "WorkspaceDependencyUnavailable.guidance",
            ])
        for field in descriptor.fields {
            #expect(field.authority == .control, "\(field.coordinate)")
            #expect(
                field.additionalRequirements == [ProviderCapabilityRequirement(providerId: "desktop", kind: .control)],
                "\(field.coordinate)")
        }
    }

    // MARK: Result branches

    @Test func aDependencyResultHasItsDependencyOnly() async throws {
        let bench = try await Bench()
        bench.script.answer { _ in .success(Self.dependency) }
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.launch, as: client.principal)

        #expect(reply.errors.isEmpty)
        let launch = try #require(reply.data?["launch"] as? [String: Any])
        #expect(launch["status"] as? String == "DEPENDENCY_UNAVAILABLE")
        #expect(launch["value"] is NSNull)
        let dependency = try #require(launch["dependency"] as? [String: Any])
        #expect(dependency["reason"] as? String == "APPLICATION_NOT_INSTALLED")
        #expect(dependency["guidance"] as? String == "Install it.")
    }

    @Test func anAbsentProcessIsNullNotAnError() async throws {
        let bench = try await Bench()
        bench.script.answer { _ in .success(Self.available(pid: nil)) }
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.launch, as: client.principal)
        #expect(reply.errors.isEmpty)
        let value = try #require(((reply.data?["launch"] as? [String: Any])?["value"]) as? [String: Any])
        #expect(value["process"] is NSNull)
    }

    @Test func aFailureIsAnErrorAtTheActionsOwnPathWithNoKindOfDependency() async throws {
        let bench = try await Bench()
        bench.script.answer { _ in .failure(ProviderFailure(kind: .failed, message: "The system refused.")) }
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.launch, as: client.principal)
        #expect(reply.data?["launch"] is NSNull)
        #expect(reply.extensions(at: ["launch"])["kind"] as? String == "failed")
    }

    @Test func invalidInputIsAnInputErrorAtTheOriginalPathWithNoKind() async throws {
        let bench = try await Bench()
        bench.script.answer { _ in .failure(ProviderFailure(kind: .invalidInput, message: "blank")) }
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.launch, as: client.principal)
        #expect(reply.data?["launch"] is NSNull)
        #expect((reply.extensions(at: ["launch"]))["kind"] == nil)
    }

    // MARK: Publication denied part-way

    /// A request selecting one `WorkspaceOpenResult` branch.
    static func selecting(_ selection: String) -> String {
        """
        mutation { launch: workspaceLaunchApplication(application: { bundleIdentifier: "com.apple.Notes" }) {
          \(selection) } }
        """
    }

    /// The action has run. Revoking as `point` is reached denies that field's
    /// publication and every later one, with the same set as preflight: a control
    /// receipt's fields are each checked as they are published, not once with the
    /// action. Each scenario selects a single branch, because sibling fields resolve
    /// concurrently and their order against a revocation is not the contract's; a
    /// child is always published after its parent.
    private func revoked(
        at point: OrderingPoint, selecting selection: String,
        answer: ProviderValue = WorkspaceCompositionTests.available(pid: 4242)
    ) async throws -> (Bench.Reply, Bench) {
        let bench = try await Bench()
        bench.script.answer { _ in .success(answer) }
        let client = try await bench.grant(Self.controls)
        bench.when(point) { await bench.revoke(client.id) }
        return (try await bench.run(Self.selecting(selection), as: client.principal), bench)
    }

    private func expectDenied(_ reply: Bench.Reply, at path: [String], sourceLocation: SourceLocation = #_sourceLocation) {
        let extensions = reply.extensions(at: path)
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls, sourceLocation: sourceLocation)
        #expect(extensions["permissionClass"] as? String == "capability", sourceLocation: sourceLocation)
        #expect(extensions["phase"] as? String == "execution", sourceLocation: sourceLocation)
    }

    @Test func denialAtStatusWithholdsTheWholeResultAtTheStatusPath() async throws {
        let (reply, bench) = try await revoked(at: .admitted("WorkspaceOpenResult.status"), selecting: "status")
        #expect(bench.script.log == ["launchApplication"], "the action ran; its result was withheld")
        // `status` is non-null, so its denial removes the result that holds it.
        #expect(reply.data?["launch"] is NSNull)
        #expect(reply.paths == [["launch", "status"]])
        expectDenied(reply, at: ["launch", "status"])
    }

    @Test func denialAtValueWithholdsItAtItsPathAndLeavesTheResultStanding() async throws {
        let (reply, _) = try await revoked(
            at: .admitted("WorkspaceOpenResult.value"), selecting: "value { process { pid } }")
        let launch = try #require(reply.data?["launch"] as? [String: Any])
        #expect(launch["value"] is NSNull)
        #expect(reply.paths == [["launch", "value"]])
        expectDenied(reply, at: ["launch", "value"])
    }

    @Test func denialAtProcessKeepsThePublishedValueAndWithholdsTheProcessAtItsPath() async throws {
        let (reply, _) = try await revoked(
            at: .admitted("WorkspaceOpenReceipt.process"), selecting: "value { process { pid startedAt } }")
        let value = try #require(((reply.data?["launch"] as? [String: Any])?["value"]) as? [String: Any])
        #expect(value["process"] is NSNull)
        #expect(reply.paths == [["launch", "value", "process"]])
        expectDenied(reply, at: ["launch", "value", "process"])
    }

    @Test func denialAtANonNullProcessFieldRemovesTheProcessAndNamesThatField() async throws {
        let (reply, _) = try await revoked(
            at: .admitted("WorkspaceProcessIdentity.pid"), selecting: "value { process { pid startedAt } }")
        let value = try #require(((reply.data?["launch"] as? [String: Any])?["value"]) as? [String: Any])
        #expect(value["process"] is NSNull, "pid is non-null: its denial removes the process, not the receipt")
        #expect(reply.error(at: ["launch", "value", "process", "pid"]) != nil)
        #expect(reply.paths.allSatisfy { $0.starts(with: ["launch", "value", "process"]) })
        expectDenied(reply, at: ["launch", "value", "process", "pid"])
    }

    @Test func denialAtADependencyWithholdsItAtItsPathAndLeavesTheResultStanding() async throws {
        let (reply, _) = try await revoked(
            at: .admitted("WorkspaceOpenResult.dependency"), selecting: "dependency { reason guidance }",
            answer: Self.dependency)
        let launch = try #require(reply.data?["launch"] as? [String: Any])
        #expect(launch["dependency"] is NSNull)
        #expect(reply.paths == [["launch", "dependency"]])
        expectDenied(reply, at: ["launch", "dependency"])
    }

    @Test func denialInsideADependencyWithholdsItsNonNullFieldAndSoTheDependency() async throws {
        let (reply, _) = try await revoked(
            at: .admitted("WorkspaceDependencyUnavailable.reason"), selecting: "dependency { reason guidance }",
            answer: Self.dependency)
        let launch = try #require(reply.data?["launch"] as? [String: Any])
        #expect(launch["dependency"] is NSNull)
        #expect(reply.error(at: ["launch", "dependency", "reason"]) != nil)
        #expect(reply.paths.allSatisfy { $0.starts(with: ["launch", "dependency"]) })
    }

    @Test func aPublishedStatusIsNotChangedByAnActionsLaterOutcome() async throws {
        // No revocation: the two branches are exclusive, and a client reads the status to choose.
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        for (answer, status) in [(Self.available(pid: 7), "AVAILABLE"), (Self.dependency, "DEPENDENCY_UNAVAILABLE")] {
            bench.script.answer { _ in .success(answer) }
            let reply = try await bench.run(Self.launch, as: client.principal)
            let launch = try #require(reply.data?["launch"] as? [String: Any])
            #expect(launch["status"] as? String == status)
            #expect((launch["value"] is NSNull) == (status == "DEPENDENCY_UNAVAILABLE"))
            #expect((launch["dependency"] is NSNull) == (status == "AVAILABLE"))
        }
    }

    // MARK: Several actions

    static let twoLaunches = """
        mutation {
          first: workspaceLaunchApplication(application: { bundleIdentifier: "com.apple.Notes" }) { status }
          second: workspaceLaunchApplication(application: { bundleIdentifier: "com.apple.Mail" }) { status }
        }
        """

    @Test func anyDeniedActionMeansNoActionBegins() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["workspace:control"])
        let reply = try await bench.run(Self.twoLaunches, as: client.principal)
        #expect(reply.outcome.isForbidden)
        #expect(reply.data == nil)
        // The first unmet member and the complete set, at each denied action's own path.
        #expect(reply.extensions(at: ["first"])["requiredCapability"] as? String == "desktop:control")
        #expect(reply.extensions(at: ["second"])["requiredCapabilities"] as? [String] == Self.controls)
        #expect(bench.script.log.isEmpty)
    }

    @Test func revocationBetweenActionsStopsTheSecondWithTheSameSet() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        bench.when(.admitted("Mutation.workspaceLaunchApplication")) { await bench.revoke(client.id) }
        let reply = try await bench.run(Self.twoLaunches, as: client.principal)

        #expect(reply.outcome.isExecuted)
        #expect(bench.script.log == ["launchApplication"], "the second action is never entered")
        let extensions = reply.extensions(at: ["second"])
        #expect(extensions["phase"] as? String == "execution")
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(reply.data?["second"] is NSNull)
    }

    @Test func aliasesAndSkippedActionsAreHonouredByPreflight() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["workspace:control"])
        let document = """
            mutation($skip: Boolean!) {
              renamed: workspaceLaunchApplication(application: { bundleIdentifier: "a" }) @skip(if: $skip) { status }
            }
            """
        let denied = try await bench.run(document, ["skip": false], as: client.principal)
        #expect(denied.error(at: ["renamed"]) != nil, "the original response path is the alias")
        let skipped = try await bench.run(document, ["skip": true], as: client.principal)
        #expect(skipped.errors.isEmpty)
        #expect(bench.script.log.isEmpty)
    }

    // MARK: The URL root

    @Test func bothControlsWithoutReadsAreEnoughForTheURLRoot() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.openURL, as: client.principal)

        #expect(reply.errors.isEmpty)
        let open = try #require(reply.data?["open"] as? [String: Any])
        #expect(open["status"] as? String == "AVAILABLE")
        #expect((((open["value"] as? [String: Any])?["process"]) as? [String: Any])?["pid"] as? Int == 4242)
        #expect(open["dependency"] is NSNull)
        #expect(bench.script.log == ["openURL"], "the URL root reaches its own resolver")
    }

    @Test(arguments: [
        ["workspace:control"], ["desktop:control"], ["workspace:read", "desktop:read"],
        ["workspace:read", "desktop:control"], ["desktop:read", "desktop:control"], [],
    ])
    func eitherControlAloneIsRefusedForTheURLRootBeforeAnythingIsLookedUp(held: [String]) async throws {
        let bench = try await Bench()
        let client = try await bench.grant(held)
        let reply = try await bench.run(Self.openURL, as: client.principal)

        #expect(reply.outcome.isForbidden)
        let extensions = reply.extensions(at: ["open"])
        let expected = held.contains("workspace:control") ? "desktop:control" : "workspace:control"
        #expect(extensions["requiredCapability"] as? String == expected)
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(extensions["phase"] as? String == "authorization")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(bench.script.log.isEmpty, "denial precedes the handler lookup: the provider is never entered")
    }

    @Test func aMissingDefaultBrowserIsTheDependencyBranchOnly() async throws {
        let bench = try await Bench()
        bench.script.answer { _ in
            .success(
                .object([
                    "status": .string("DEPENDENCY_UNAVAILABLE"), "value": .null,
                    "dependency": .object(["reason": .string("NO_DEFAULT_HANDLER"), "guidance": .string("Choose a browser.")]),
                ]))
        }
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.openURL, as: client.principal)

        #expect(reply.errors.isEmpty)
        let open = try #require(reply.data?["open"] as? [String: Any])
        #expect(open["status"] as? String == "DEPENDENCY_UNAVAILABLE")
        #expect(open["value"] is NSNull)
        let dependency = try #require(open["dependency"] as? [String: Any])
        #expect(dependency["reason"] as? String == "NO_DEFAULT_HANDLER")
        #expect(dependency["guidance"] as? String == "Choose a browser.")
    }

    @Test func aURLFailureIsAnErrorAtItsOwnPathAndInvalidInputCarriesNoKind() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        bench.script.answer { _ in .failure(ProviderFailure(kind: .failed, message: "The system refused.")) }
        let failed = try await bench.run(Self.openURL, as: client.principal)
        #expect(failed.data?["open"] is NSNull)
        #expect(failed.extensions(at: ["open"])["kind"] as? String == "failed")

        bench.script.answer { _ in .failure(ProviderFailure(kind: .invalidInput, message: "url bad")) }
        let invalid = try await bench.run(Self.openURL, as: client.principal)
        #expect(invalid.data?["open"] is NSNull)
        #expect(invalid.extensions(at: ["open"])["kind"] == nil)
    }

    @Test func denialAtTheURLResultsStatusWithholdsTheWholeResultAtTheStatusPath() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        bench.when(.admitted("WorkspaceOpenResult.status")) { await bench.revoke(client.id) }
        let reply = try await bench.run(
            "mutation { open: workspaceOpenURL(url: \"https://example.com/\") { status } }", as: client.principal)
        #expect(bench.script.log == ["openURL"], "the open ran; its result was withheld")
        #expect(reply.data?["open"] is NSNull)
        #expect(reply.paths == [["open", "status"]])
        expectDenied(reply, at: ["open", "status"])
    }

    // MARK: Several actions, the URL among them

    static let launchThenOpen = """
        mutation {
          first: workspaceLaunchApplication(application: { bundleIdentifier: "com.apple.Notes" }) { status }
          second: workspaceOpenURL(url: "https://example.com/") { status }
        }
        """

    @Test func anyDeniedActionMeansNoActionBeginsWhateverTheRoot() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["workspace:control"])
        let reply = try await bench.run(Self.launchThenOpen, as: client.principal)
        #expect(reply.outcome.isForbidden)
        #expect(reply.data == nil)
        #expect(reply.extensions(at: ["first"])["requiredCapability"] as? String == "desktop:control")
        #expect(reply.extensions(at: ["second"])["requiredCapabilities"] as? [String] == Self.controls)
        #expect(bench.script.log.isEmpty)
    }

    @Test func actionsOfBothRootsRunInOrderUnderTheSameGrant() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.launchThenOpen, as: client.principal)
        #expect(reply.errors.isEmpty)
        #expect(bench.script.log == ["launchApplication", "openURL"])
    }

    @Test func revocationBetweenAURLAndTheNextActionStopsTheNextWithTheSameSet() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(Self.controls)
        bench.when(.admitted("Mutation.workspaceOpenURL")) { await bench.revoke(client.id) }
        let reply = try await bench.run(
            """
            mutation {
              first: workspaceOpenURL(url: "https://example.com/a") { status }
              second: workspaceOpenURL(url: "https://example.com/b") { status }
            }
            """, as: client.principal)
        #expect(reply.outcome.isExecuted)
        #expect(bench.script.log == ["openURL"], "the second open is never entered")
        let extensions = reply.extensions(at: ["second"])
        #expect(extensions["phase"] as? String == "execution")
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(reply.data?["second"] is NSNull)
    }

    @Test func aliasesAndSkippedURLOpensAreHonouredByPreflight() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["workspace:control"])
        let document = """
            mutation($skip: Boolean!) {
              renamed: workspaceOpenURL(url: "https://example.com/") @skip(if: $skip) { status }
            }
            """
        let denied = try await bench.run(document, ["skip": false], as: client.principal)
        #expect(denied.error(at: ["renamed"]) != nil, "the original response path is the alias")
        let skipped = try await bench.run(document, ["skip": true], as: client.principal)
        #expect(skipped.errors.isEmpty)
        #expect(bench.script.log.isEmpty)
    }

    @Test func aURLsFailedIsAtItsPathAndLaterActionsStillRun() async throws {
        let bench = try await Bench()
        bench.script.answer { request in
            guard request.resolverId == "openURL" else { return .success(Self.available(pid: nil)) }
            return .failure(ProviderFailure(kind: .failed, message: "The system did not acknowledge."))
        }
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(
            """
            mutation {
              first: workspaceOpenURL(url: "https://example.com/") { status }
              second: workspaceLaunchApplication(application: { bundleIdentifier: "com.apple.Notes" }) { status }
            }
            """, as: client.principal)
        #expect(reply.data?["first"] is NSNull)
        #expect(reply.extensions(at: ["first"])["kind"] as? String == "failed")
        #expect((reply.data?["second"] as? [String: Any])?["status"] as? String == "AVAILABLE")
        #expect(bench.script.log == ["openURL", "launchApplication"])
    }

    @Test func anEarlierCoreDeadlineAnswersTheWholeRequestAndNoLaterURLOpenBegins() async throws {
        var policy = RequestPolicy.version1
        policy.executionDeadline = .milliseconds(150)
        let bench = try await Bench(policy: policy)
        bench.script.answer { _ in
            try? await Task.sleep(for: .seconds(20))
            return .failure(ProviderFailure(kind: .failed, message: "The system did not acknowledge."))
        }
        let client = try await bench.grant(Self.controls)
        let started = ContinuousClock.now
        let reply = try await bench.run(
            """
            mutation {
              first: workspaceOpenURL(url: "https://example.com/a") { status }
              second: workspaceOpenURL(url: "https://example.com/b") { status }
            }
            """, as: client.principal)
        #expect(ContinuousClock.now - started < .seconds(10))
        #expect(reply.json["data"] is NSNull, "the whole response is answered, not one action's path")
        #expect(reply.errors.count == 1 && (reply.errors.first?["path"] as? [Any])?.isEmpty == true)
        #expect((reply.errors.first?["extensions"] as? [String: Any])?["kind"] as? String == "failed")
        try await Task.sleep(for: .milliseconds(100))
        #expect(bench.script.log == ["openURL"])
    }

    // MARK: The URL grammar, through the engine and the real provider

    /// A browser that records what reached it and answers at once; nothing is ever opened.
    final class RecordingBrowser: WorkspaceNative, @unchecked Sendable {
        private let lock = NSLock()
        private var openedURLs: [String] = []
        private var lookedUp: [WebURL.Scheme] = []
        static let browser = URL(fileURLWithPath: "/Applications/Browser.app")

        var opened: [String] { lock.withLock { openedURLs } }
        var lookups: [WebURL.Scheme] { lock.withLock { lookedUp } }

        func registeredApplication(bundleIdentifier: String) -> URL? { nil }
        func registeredApplications(bundleIdentifier: String) -> [URL] { [] }
        func inspectApplication(at path: String) -> ApplicationInspection {
            .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: path), bundleIdentifier: "com.example.browser",
                    identity: FileIdentity(volume: NSNumber(value: 1), file: "browser" as NSString)))
        }
        func launchApplication(
            at url: URL, substitutingRunningCopy: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void
        ) { completion(.refused("a launch is not part of this test")) }
        func defaultApplication(forWebScheme scheme: WebURL.Scheme) -> URL? {
            lock.withLock { lookedUp.append(scheme) }
            return Self.browser
        }
        func openWebURL(
            _ url: URL, withApplicationAt application: URL, completion: @escaping @Sendable (LaunchCompletion) -> Void
        ) {
            lock.withLock { openedURLs.append(url.absoluteString) }
            completion(.acknowledged(nil))
        }
        func processStart(of pid: Int32) -> ProcessLookup { .absent }
        func liveExecutableIdentity(of pid: Int32) -> FileIdentity? { nil }
    }

    static func realProvider() async throws -> (bench: Bench, browser: RecordingBrowser, client: Principal) {
        let browser = RecordingBrowser()
        let bench = try await Bench(provider: WorkspaceProvider(native: browser))
        let client = try await bench.grant(Self.controls)
        return (bench, browser, client.principal)
    }

    @Test(arguments: [
        "https://www.google.com/search?q=hello%20world%2Bmore&hl=en&q=%E2%9C%93+caf%C3%A9#r%20es",
        "https://example.com/a%2Fb?q=%3F%23%26#frag%20ment%3A", "https://xn--bcher-kva.example/",
        "https://xn--mnchen-3ya.de/search?q=m%C3%BCnchen", "https://xn--r8jz45g.xn--zckzah/", "http://localhost:8080/",
        "http://[::1]:8080/p?q#f", "http://127.0.0.1/", "HTTP://Example.COM/Path",
    ])
    func aWellFormedURLReachesTheHandlerAsTheSameBytesAndIsAvailable(_ url: String) async throws {
        let (bench, browser, client) = try await Self.realProvider()
        let reply = try await bench.run(Self.openURLWithVariable, ["url": url], as: client)
        #expect(reply.errors.isEmpty, Comment(rawValue: "\(reply.errors)"))
        #expect((reply.data?["open"] as? [String: Any])?["status"] as? String == "AVAILABLE")
        #expect(browser.opened == [url], "the bytes submitted are the bytes received")
    }

    @Test(arguments: [
        ("", "empty"), ("https://example.com/\u{7}", "control"), ("https://example.com/a\tb", "control"),
        ("https://example.com/a b", "whitespace"), (" https://example.com/", "whitespace"),
        ("https://example.com\\evil.example/", "backslash"), ("https:\\\\example.com", "backslash"),
        ("https://example.com/caf\u{E9}", "Unicode path"), ("https://example.com/?q=\u{2713}", "Unicode query"),
        ("https://b\u{FC}cher.example/", "raw IDNA host"), ("https://\u{4F8B}\u{3048}.jp/", "raw IDNA host"),
        ("https://user:pw@example.com/", "credentials"), ("https://user@example.com/", "credentials"),
        ("ftp://example.com/", "scheme"), ("file:///etc/hosts", "scheme"), ("javascript:alert(1)", "scheme"),
        ("zoommtg://zoom.us/join", "scheme"), ("example.com/search", "no scheme"),
        ("https://", "no host"), ("https:///x", "no host"), ("https://:8080/", "no host"),
        ("https://example.com/%", "escape"), ("https://example.com/%zz", "escape"), ("https://example.com/?q=%4", "escape"),
        ("https://example.com/#%G0", "escape"), ("https://exa%6Dple.com/", "escape in host"),
        ("https://xn--abc-.example/", "IDNA ASCII-only"), ("https://xn--/", "IDNA empty"),
        ("https://xn--9/", "IDNA malformed"), ("https://ab--cd.example/", "IDNA reserved"),
        ("https://example..com/", "label"), ("https://-a.example/", "label"), ("https://example.com:80a/", "port"),
        ("http://[::1/", "literal"), ("http://[1:2:3]/", "literal"), ("https://example.com/#a#b", "fragment"),
    ])
    func aMalformedURLIsAnInputErrorAtTheOriginalPathAndNothingReachesTheHandler(
        _ url: String, _ why: String
    ) async throws {
        let (bench, browser, client) = try await Self.realProvider()
        let reply = try await bench.run(Self.openURLWithVariable, ["url": url], as: client)
        #expect(reply.error(at: ["open"]) != nil, Comment(rawValue: "\(why): \(url.debugDescription) was accepted"))
        #expect(reply.extensions(at: ["open"])["kind"] == nil, "an input error carries no kind")
        #expect(reply.data?["open"] is NSNull)
        #expect(browser.opened.isEmpty && browser.lookups.isEmpty, "nothing was looked up or sent: \(why)")
    }

    @Test func aRefusedURLInAMultiActionRequestStopsOnlyItselfAndTheNextStillRuns() async throws {
        let (bench, browser, client) = try await Self.realProvider()
        let reply = try await bench.run(
            """
            mutation {
              bad: workspaceOpenURL(url: "ftp://example.com/") { status }
              good: workspaceOpenURL(url: "https://example.com/ok") { status }
            }
            """, as: client)
        #expect(reply.data?["bad"] is NSNull)
        #expect(reply.extensions(at: ["bad"])["kind"] == nil)
        #expect((reply.data?["good"] as? [String: Any])?["status"] as? String == "AVAILABLE")
        #expect(browser.opened == ["https://example.com/ok"])
    }


    // MARK: An action's own failure against an earlier core deadline

    @Test func anActionsFailedIsAtItsPathAndLaterActionsStillRun() async throws {
        let bench = try await Bench()
        bench.script.answer { request in
            guard case .object(let application)? = request.arguments["application"],
                case .string("com.apple.Notes")? = application["bundleIdentifier"]
            else { return .success(Self.available(pid: nil)) }
            return .failure(ProviderFailure(kind: .failed, message: "The system did not acknowledge."))
        }
        let client = try await bench.grant(Self.controls)
        let reply = try await bench.run(Self.twoLaunches, as: client.principal)

        #expect(reply.data?["first"] is NSNull)
        #expect(reply.extensions(at: ["first"])["kind"] as? String == "failed")
        #expect((reply.data?["second"] as? [String: Any])?["status"] as? String == "AVAILABLE")
        #expect(bench.script.log == ["launchApplication", "launchApplication"])
    }

    @Test func anEarlierCoreDeadlineAnswersTheWholeRequestAndNoLaterActionBegins() async throws {
        var policy = RequestPolicy.version1
        policy.executionDeadline = .milliseconds(150)
        let bench = try await Bench(policy: policy)
        // The first action waits for its native acknowledgment far past the core's deadline
        // (workspace's own bound is three seconds; the core's is shorter here).
        bench.script.answer { _ in
            try? await Task.sleep(for: .seconds(20))
            return .failure(ProviderFailure(kind: .failed, message: "The system did not acknowledge."))
        }
        let client = try await bench.grant(Self.controls)
        let started = ContinuousClock.now
        let reply = try await bench.run(Self.twoLaunches, as: client.principal)

        #expect(ContinuousClock.now - started < .seconds(10))
        #expect(reply.json["data"] is NSNull, "the whole response is answered, not one action's path")
        #expect(reply.errors.count == 1)
        #expect((reply.errors.first?["path"] as? [Any])?.isEmpty == true)
        #expect((reply.errors.first?["extensions"] as? [String: Any])?["kind"] as? String == "failed")
        // Cooperative cancellation: the second action is never entered.
        try await Task.sleep(for: .milliseconds(100))
        #expect(bench.script.log == ["launchApplication"])
    }
}
