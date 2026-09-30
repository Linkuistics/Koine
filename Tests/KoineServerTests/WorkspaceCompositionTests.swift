import Foundation
import KoineProviderAPI
import Testing

@testable import KoineCore
@testable import WorkspaceProviderLogic

/// The workspace launch root at the composition point (G): the real descriptor and
/// the SDL the bundle serves, composed through the engine every transport executes
/// through, with the provider a scripted stand-in. What is asserted is the core's
/// and the client's handling: authority, preflight, revocation, publication and the
/// deadline. Workspace's own mapping is `WorkspaceProviderLogicTests`'; a real
/// binary and a real application are the N and V seams'. No launch happens here.
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

        init(policy: RequestPolicy = .version1, owners: [String] = ["desktop"]) async throws {
            let workspace = ActiveProvider(
                descriptor: workspaceDescriptor(schemaSDL: try WorkspaceCompositionTests.schemaSDL()),
                provider: ScriptedWorkspace(script), origin: .bundled
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

    // MARK: Composition

    @Test func theContributionComposesAndServesTheLaunchRootOnly() async throws {
        let bench = try await Bench()
        #expect(bench.engine.providerDiagnostics.isEmpty)
        let root = try await bench.grant([])
        let types = try await bench.run(
            """
            { m: __type(name: "Mutation") { fields { name } } r: __type(name: "WorkspaceRevealResult") { name } }
            """, as: root.principal)
        let names = ((types.data?["m"] as? [String: Any])?["fields"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
        #expect(names.filter { $0.hasPrefix("workspace") } == ["workspaceLaunchApplication"])
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
                "Mutation.workspaceLaunchApplication",
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
