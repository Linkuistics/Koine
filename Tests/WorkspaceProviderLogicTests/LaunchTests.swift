import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// The real workspace provider over a substituted native adapter: its mapping of
/// selection, native acknowledgment and observation onto the launch root's
/// results. Callbacks are controlled, never awaited from real applications.
@Suite struct LaunchTests {
    static let notes = "com.apple.Notes"

    static func request(_ identifier: String = notes, path: String? = nil) -> ResolutionRequest {
        ResolutionRequest(
            resolverId: "launchApplication",
            arguments: [
                "application": .object([
                    "bundleIdentifier": .string(identifier),
                    "applicationPath": path.map(ProviderValue.string) ?? .null,
                ])
            ],
            parent: nil
        )
    }

    /// A provider over a native with Notes installed and a running application
    /// whose observation rule holds, unless a test changes it.
    static func bench(
        bound: Duration = .seconds(30), capacity: Int = 16
    ) -> (native: FakeNative, provider: WorkspaceProvider) {
        let native = FakeNative()
        native.install(notes, at: "/System/Applications/Notes.app", file: "notes")
        native.processStarts(4242, [.running(ProcessStart(microsecondsSinceEpoch: 1_800_000_000_123_456))])
        native.executable(4242, FakeNative.identity("exe"))
        return (native, WorkspaceProvider(native: native, acknowledgmentBound: bound, submissionCapacity: capacity))
    }

    static func failure(_ result: ResolutionResult) -> ProviderFailure? {
        if case .failure(let failure) = result { return failure }
        return nil
    }

    static func value(_ result: ResolutionResult) -> [String: ProviderValue]? {
        if case .success(.object(let fields)) = result { return fields }
        return nil
    }

    // MARK: Results

    @Test func anAcknowledgedLaunchIsAvailableWithTheObservedProcess() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(FakeApplication())) }
        let result = await provider.resolve(Self.request())

        let fields = try #require(Self.value(result))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["dependency"] == .null)
        #expect(
            fields["value"]
                == .object([
                    "process": .object([
                        "pid": .int(4242), "startedAt": .string("2027-01-15T08:00:00.123456Z"),
                    ])
                ])
        )
        #expect(native.launches.count == 1)
        #expect(native.launches[0].url.path == "/System/Applications/Notes.app")
        #expect(native.launches[0].substituting, "an unconstrained launch reuses a running copy")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func anAcknowledgmentWithNoApplicationHasNoProcess() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(Self.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["value"] == .object(["process": .null]))
    }

    @Test func aConstrainedLaunchSubmitsTheChosenCopyAndForbidsSubstitution() async throws {
        let (native, provider) = Self.bench()
        native.install(Self.notes, at: "/Users/a/Apps/Notes.app", file: "mine", isDefault: false)
        native.onLaunch = { $0(.acknowledged(nil)) }
        _ = await provider.resolve(Self.request(path: "/Users/a/Apps/Notes.app"))
        #expect(native.launches.map(\.url.path) == ["/Users/a/Apps/Notes.app"])
        #expect(native.launches.map(\.substituting) == [false])
    }

    @Test func aMissingApplicationIsDependencyAbsenceAndSubmitsNothing() async throws {
        let (native, provider) = Self.bench()
        let fields = try #require(Self.value(await provider.resolve(Self.request("com.example.Absent"))))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(fields["value"] == .null)
        guard case .object(let dependency)? = fields["dependency"] else {
            Issue.record("a dependency is named")
            return
        }
        #expect(dependency["reason"] == .string("APPLICATION_NOT_INSTALLED"))
        guard case .string(let guidance)? = dependency["guidance"] else {
            Issue.record("guidance is text")
            return
        }
        #expect(guidance.contains("com.example.Absent"))
        #expect(native.launches.isEmpty)
    }

    @Test func anIdentityMismatchNamesNoInstalledIdentifierAndSubmitsNothing() async throws {
        let (native, provider) = Self.bench()
        native.install("com.example.Other", at: "/Users/a/Apps/Other.app", file: "other")
        let fields = try #require(
            Self.value(await provider.resolve(Self.request(path: "/Users/a/Apps/Other.app"))))
        guard case .object(let dependency)? = fields["dependency"] else {
            Issue.record("a dependency is named")
            return
        }
        #expect(dependency["reason"] == .string("APPLICATION_IDENTITY_MISMATCH"))
        // The identifier found is workspace read data, not a control receipt's.
        guard case .string(let guidance)? = dependency["guidance"] else { return }
        #expect(!guidance.contains("com.example.Other"))
        #expect(native.launches.isEmpty)
    }

    @Test func anInspectionFailureIsFailedAndSubmitsNothing() async throws {
        let (native, provider) = Self.bench()
        native.inspect("/System/Applications/Notes.app", as: .unreadable("Operation not permitted"))
        let failure = try #require(Self.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Operation not permitted"))
        #expect(native.launches.isEmpty)
    }

    // MARK: Input, before anything is inspected

    @Test(arguments: [
        ("", nil), ("  ", nil), (LaunchTests.notes, ""), (LaunchTests.notes, "relative.app"),
        (LaunchTests.notes, "/Applications/N\u{0}otes.app"),
    ] as [(String, String?)])
    func invalidInputActsOnNothing(identifier: String, path: String?) async throws {
        let (native, provider) = Self.bench()
        let failure = try #require(Self.failure(await provider.resolve(Self.request(identifier, path: path))))
        #expect(failure.kind == .invalidInput)
        #expect(native.launches.isEmpty && native.inspected.isEmpty)
    }

    @Test func aMalformedApplicationArgumentIsInput() async throws {
        let (native, provider) = Self.bench()
        for argument: ProviderValue? in [nil, .null, .string("Notes"), .object([:]), .object(["bundleIdentifier": .int(1)])] {
            let request = ResolutionRequest(
                resolverId: "launchApplication", arguments: argument.map { ["application": $0] } ?? [:], parent: nil)
            let failure = try #require(Self.failure(await provider.resolve(request)))
            #expect(failure.kind == .invalidInput)
        }
        #expect(native.launches.isEmpty && native.inspected.isEmpty)
    }

    // MARK: The bounded acknowledgment

    @Test func aNegativeAcknowledgmentIsFailedWithNoReplay() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.refused("The application can't be opened")) }
        let failure = try #require(Self.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("The application can't be opened"))
        #expect(native.launches.count == 1, "the launch is never repeated")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aMissingCallbackEndsAtTheBoundAsFailed() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(80))
        let started = ContinuousClock.now
        let failure = try #require(Self.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("did not acknowledge"))
        #expect(ContinuousClock.now - started < .seconds(5))
        #expect(native.launches.count == 1)
        // The system was not cancelled and has not answered: it still counts.
        #expect(provider.submissionsInFlight == 1)
    }

    @Test func aLateCallbackIsIgnoredAndReleasesItsSlot() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(60))
        let failure = try #require(Self.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(provider.submissionsInFlight == 1)

        // Gatekeeper is dismissed after the bound: the native request completes.
        native.answer(with: .acknowledged(FakeApplication()))
        native.answer(with: .refused("and again"))  // and a second time, for good measure
        #expect(provider.submissionsInFlight == 0, "released once, and never below zero")
        #expect(native.launches.count == 1, "nothing was replayed")
    }

    @Test func aCallbackBeforeTheBoundWinsAndALaterOneChangesNothing() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(200))
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(Self.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        native.answer(with: .refused("late"))
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func cancellationEndsTheWaitOnceBeforeTheBoundAndNeverWaitsForTheCallback() async throws {
        let (native, provider) = Self.bench(bound: .seconds(60))
        let started = ContinuousClock.now
        let task = Task { await provider.resolve(Self.request()) }
        while native.launches.isEmpty { try await Task.sleep(for: .milliseconds(5)) }
        task.cancel()
        let failure = try #require(Self.failure(await task.value))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Cancelled"))
        #expect(ContinuousClock.now - started < .seconds(10))
        #expect(provider.submissionsInFlight == 1, "the native call is outstanding until it answers")
        native.answer(with: .acknowledged(FakeApplication()))
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aRequestCancelledBeforeSubmissionSubmitsNothing() async throws {
        let (native, provider) = Self.bench()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return await provider.resolve(Self.request())
        }
        let failure = try #require(Self.failure(await task.value))
        #expect(failure.kind == .failed)
        #expect(native.launches.isEmpty)
    }

    @Test func exhaustedCapacityRefusesBeforeSubmission() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(40), capacity: 2)
        for _ in 0..<2 { _ = await provider.resolve(Self.request()) }
        #expect(native.launches.count == 2 && provider.submissionsInFlight == 2)

        let refused = try #require(Self.failure(await provider.resolve(Self.request())))
        #expect(refused.kind == .failed)
        #expect(refused.message.contains("outstanding"))
        #expect(native.launches.count == 2, "a refused request is never submitted")

        // One outstanding call answers; capacity returns.
        native.answer(0, with: .acknowledged(nil))
        #expect(provider.submissionsInFlight == 1)
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(Self.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.launches.count == 3)
    }

    @Test func aDependencyOrInputRefusalNeverUsesCapacity() async throws {
        let (native, provider) = Self.bench(capacity: 1)
        _ = await provider.resolve(Self.request("com.example.Absent"))
        _ = await provider.resolve(Self.request(""))
        #expect(provider.submissionsInFlight == 0 && native.launches.isEmpty)
    }

    // MARK: Resolvers

    @Test func nestedFieldsReadTheirParentAndAnUnknownResolverIsNamed() async throws {
        let (_, provider) = Self.bench()
        let parent = ProviderValue.object(["status": .string("AVAILABLE")])
        let read = await provider.resolve(
            ResolutionRequest(resolverId: "parent.status", arguments: [:], parent: parent))
        guard case .success(.string("AVAILABLE")) = read else {
            Issue.record("a nested field reads its key from its parent")
            return
        }
        let missing = await provider.resolve(
            ResolutionRequest(resolverId: "parent.value", arguments: [:], parent: parent))
        #expect(Self.failure(missing)?.kind == .failed)
        let unknown = await provider.resolve(ResolutionRequest(resolverId: "nope", arguments: [:], parent: nil))
        #expect(Self.failure(unknown)?.kind == .unknownResolver)
    }
}
