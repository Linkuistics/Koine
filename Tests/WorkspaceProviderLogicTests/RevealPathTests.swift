import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// The real workspace provider over a substituted native adapter: its mapping of path
/// validation, target inspection, the Finder prerequisite, Finder's boolean acknowledgment and
/// the bounded wait onto `workspaceRevealPath`'s results. Metadata and callbacks are controlled;
/// nothing is revealed and no file is read.
@Suite struct RevealPathTests {
    static let document = "/Users/test/notes.txt"
    static let folder = "/Users/test/config"
    static let finderPath = "/System/Library/CoreServices/Finder.app"

    static func request(_ path: ProviderValue? = .string(document)) -> ResolutionRequest {
        var arguments: [String: ProviderValue] = [:]
        if let path { arguments["path"] = path }
        return ResolutionRequest(resolverId: "revealPath", arguments: arguments, parent: nil)
    }

    /// A provider over a native with a document and a folder present and Finder installed.
    static func bench(
        bound: Duration = .seconds(30), capacity: Int = 16
    ) -> (native: FakeNative, provider: WorkspaceProvider) {
        let (native, provider) = LaunchTests.bench(bound: bound, capacity: capacity)
        native.document(document)
        native.document(folder, directory: true, type: "public.folder")
        native.install(finderBundleIdentifier, at: finderPath, file: "finder")
        return (native, provider)
    }

    static func dependencyReason(_ fields: [String: ProviderValue]) -> ProviderValue? {
        guard case .object(let dependency)? = fields["dependency"] else { return nil }
        return dependency["reason"]
    }

    static func guidance(_ fields: [String: ProviderValue]) -> String? {
        guard case .object(let dependency)? = fields["dependency"], case .string(let text)? = dependency["guidance"] else { return nil }
        return text
    }

    // MARK: Results

    @Test func anAcknowledgedRevealIsAvailableAndEchoesTheSubmittedPath() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))

        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["dependency"] == .null)
        #expect(fields["value"] == .object(["path": .string(Self.document)]))
        #expect(native.reveals == [Self.document])
        #expect(native.launches.isEmpty && native.opens.isEmpty && native.pathOpens.isEmpty, "a reveal opens nothing")
        #expect(native.documentLookups.isEmpty && native.handlerLookups.isEmpty, "no handler is looked up for a reveal")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func theReceiptCarriesNoObservedProcessWhateverTheCallbackDelivers() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(FakeApplication())) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["value"] == .object(["path": .string(Self.document)]), "path only: no process, no installed path")
    }

    @Test func aDirectoryIsSubmittedByItsLiteralPathToBeSelectedInItsParent() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        for path in [Self.folder, Self.folder + "/"] {
            native.document(path, directory: true, type: "public.folder")
            let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string(path)))))
            #expect(fields["value"] == .object(["path": .string(path)]))
        }
        #expect(native.reveals == [Self.folder, Self.folder + "/"])
    }

    @Test(arguments: [
        "/Users/test/a b/c  d.txt", "/Users/test/$HOME/`x`;rm -rf *.txt", "/Users/test/it's \"quoted\" & (more)?.txt",
        "/Users/test/100%25 caf\u{e9} \u{1f600}.txt", "/Users/test/../test/./x.txt", "/Users/test/ leading and trailing ",
    ])
    func spacesAndShellPunctuationStayLiteral(_ path: String) async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.document(path)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string(path)))))
        #expect(fields["value"] == .object(["path": .string(path)]))
        #expect(native.pathInspected == [path], "inspected as written")
        #expect(native.reveals == [path], "and submitted as written")
    }

    /// The root view is decided by the inspection, from the filesystem: a spelling that is the root
    /// (`/`, `//`, `/.`, `/..`) is submitted as written with the root flag the inspection reported, and a
    /// spelling that merely looks like it (`/var/..` is `/private`) is an ordinary item.
    @Test(arguments: [("/", true), ("//", true), ("/.", true), ("/..", true), ("/var/..", false), ("/Users/test/..", false)])
    func theRootViewFollowsTheInspectionAndNotTheSpelling(_ path: String, _ isRoot: Bool) async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.document(path, directory: true, type: "public.folder", root: isRoot)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string(path)))))
        #expect(fields["value"] == .object(["path": .string(path)]), "echoed as submitted")
        #expect(native.reveals == [path], "submitted as written")
        #expect(native.revealedAsRoot == [isRoot])
    }

    @Test func anOrdinaryItemIsNeverTheRootView() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        _ = await provider.resolve(Self.request(.string(Self.document)))
        _ = await provider.resolve(Self.request(.string(Self.folder)))
        #expect(native.revealedAsRoot == [false, false])
    }

    // MARK: Nothing is refused for being what it is

    @Test(arguments: [
        ("an application bundle", true, false, "com.apple.application-bundle"),
        ("an executable program", false, false, "public.unix-executable"),
        ("a Windows executable", false, false, "com.microsoft.windows-executable"),
        ("a Finder alias", false, true, "com.apple.alias-file"),
    ])
    func anApplicationAnExecutableOrAnAliasIsSelectedNotOpenedOrRefused(
        _ what: String, application: Bool, alias: Bool, type: String
    ) async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.document("/Users/test/thing", application: application, alias: alias, type: type)
        let fields = try #require(
            LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/thing")))), Comment(rawValue: what))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.reveals == ["/Users/test/thing"])
        #expect(native.pathOpens.isEmpty && native.launches.isEmpty)
    }

    // MARK: Input

    @Test(arguments: [
        "", "relative/path.txt", "./x", "~", "~/notes.txt", "$HOME/x", "file:///Users/test/notes.txt", " /Users/test/notes.txt",
        "/Users/test/a\u{0}b",
    ])
    func anUnusablePathIsInputAndActsOnNothing(_ path: String) async throws {
        let (native, provider) = Self.bench()
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(.string(path)))))
        #expect(failure.kind == .invalidInput)
        #expect(native.pathInspected.isEmpty && native.inspected.isEmpty && native.reveals.isEmpty)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aMissingOrNonStringPathIsInput() async throws {
        let (native, provider) = Self.bench()
        for argument: ProviderValue? in [nil, .null, .int(3), .bool(true), .object([:])] {
            let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(argument))))
            #expect(failure.kind == .invalidInput)
        }
        #expect(native.pathInspected.isEmpty && native.reveals.isEmpty)
    }

    // MARK: Prerequisites

    @Test func aMissingPathIsPathNotFoundAndFinderIsNotEvenLookedUp() async throws {
        let (native, provider) = Self.bench()
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/gone.txt")))))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(fields["value"] == .null)
        #expect(Self.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.pathInspected == ["/Users/test/gone.txt"])
        #expect(native.inspected.isEmpty, "no application was inspected")
        #expect(native.reveals.isEmpty)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func theTargetIsReportedBeforeAFinderThatIsAlsoMissing() async throws {
        let native = FakeNative()
        let provider = WorkspaceProvider(native: native)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/gone.txt")))))
        #expect(Self.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
    }

    @Test func aDanglingLinkIsAMissingPath() async throws {
        let (native, provider) = Self.bench()
        // The adapter reports what `stat` after symlink resolution found: nothing.
        native.inspectPath("/Users/test/dangling", as: .absent)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/dangling")))))
        #expect(Self.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.reveals.isEmpty)
    }

    @Test func inspectionDenialIsFailedNeverAbsenceAndNothingIsSubmitted() async throws {
        let (native, provider) = Self.bench()
        native.inspectPath(Self.document, as: .unreadable("Permission denied"))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Permission denied"))
        #expect(native.reveals.isEmpty && native.inspected.isEmpty)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aFinderThatIsNotRegisteredIsApplicationNotInstalledAndNothingIsSubmitted() async throws {
        let native = FakeNative()
        native.document(Self.document)
        let provider = WorkspaceProvider(native: native)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(Self.dependencyReason(fields) == .string("APPLICATION_NOT_INSTALLED"))
        #expect(Self.guidance(fields)?.contains("Finder") == true, "the guidance names the application")
        #expect(native.reveals.isEmpty)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test(arguments: [ApplicationInspection.absent, .notApplication])
    func aRegistrationWhoseBundleIsGoneIsNoFinder(inspection: ApplicationInspection) async throws {
        let (native, provider) = Self.bench()
        native.inspect(Self.finderPath, as: inspection)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(Self.dependencyReason(fields) == .string("APPLICATION_NOT_INSTALLED"))
        #expect(native.reveals.isEmpty)
    }

    @Test func aRegisteredBundleThatIsNotFinderIsNotFinder() async throws {
        let (native, provider) = Self.bench()
        native.inspect(
            Self.finderPath,
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: Self.finderPath), bundleIdentifier: "com.example.NotFinder",
                    identity: FakeNative.identity("finder"))))
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(Self.dependencyReason(fields) == .string("APPLICATION_NOT_INSTALLED"), "reveal reports only absence and path loss")
        #expect(native.reveals.isEmpty)
    }

    @Test func finderMetadataThatCannotBeReadIsFailedNeverAbsence() async throws {
        let (native, provider) = Self.bench()
        native.inspect(Self.finderPath, as: .unreadable("Permission denied"))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(native.reveals.isEmpty)
    }

    @Test func finderIsLookedUpAfreshOnEveryAction() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let first = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(first["status"] == .string("AVAILABLE"))
        native.inspect(Self.finderPath, as: .absent)  // removed between actions: no readiness cache
        let second = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(Self.dependencyReason(second) == .string("APPLICATION_NOT_INSTALLED"))
        #expect(native.reveals.count == 1)
    }

    // MARK: The bounded acknowledgment

    @Test func aFalseAcknowledgmentIsFailedWithNoReplayOrFallback() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.refused("Finder did not acknowledge selecting the item.")) }
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Finder did not acknowledge"))
        #expect(native.reveals.count == 1, "the reveal is never repeated")
        #expect(native.pathOpens.isEmpty && native.launches.isEmpty, "and nothing else is tried")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aMissingCallbackEndsAtTheBoundAsFailed() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(80))
        let started = ContinuousClock.now
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("did not acknowledge"))
        #expect(ContinuousClock.now - started < .seconds(5))
        #expect(native.reveals.count == 1)
        #expect(provider.submissionsInFlight == 1, "Finder was not cancelled and has not answered")
    }

    @Test func aLateAcknowledgmentIsIgnoredAndReleasesItsSlot() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(60))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(provider.submissionsInFlight == 1)

        native.answer(with: .acknowledged(nil))
        native.answer(with: .refused("and again"))
        #expect(provider.submissionsInFlight == 0, "released once, and never below zero")
        #expect(native.reveals.count == 1, "nothing was replayed")
    }

    @Test func anAcknowledgmentBeforeTheBoundWinsAndALaterOneChangesNothing() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(200))
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        native.answer(with: .refused("late"))
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func cancellationEndsTheWaitOnceAndNeverWaitsForTheCallback() async throws {
        let (native, provider) = Self.bench(bound: .seconds(60))
        let started = ContinuousClock.now
        let task = Task { await provider.resolve(Self.request()) }
        while native.reveals.isEmpty { try await Task.sleep(for: .milliseconds(5)) }
        task.cancel()
        let failure = try #require(LaunchTests.failure(await task.value))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Cancelled"))
        #expect(ContinuousClock.now - started < .seconds(10))
        #expect(provider.submissionsInFlight == 1, "the native call is outstanding until it answers")
        native.answer(with: .acknowledged(nil))
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aRequestCancelledBeforeAnythingHappensInspectsAndSubmitsNothing() async throws {
        let (native, provider) = Self.bench()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return await provider.resolve(Self.request())
        }
        let failure = try #require(LaunchTests.failure(await task.value))
        #expect(failure.kind == .failed)
        #expect(native.pathInspected.isEmpty && native.reveals.isEmpty)
    }

    @Test func exhaustedCapacityRefusesBeforeSubmissionAndIsRestoredByACallback() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(40), capacity: 2)
        for _ in 0..<2 { _ = await provider.resolve(Self.request()) }
        #expect(native.reveals.count == 2 && provider.submissionsInFlight == 2)

        let refused = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(refused.kind == .failed)
        #expect(refused.message.contains("outstanding"))
        #expect(native.reveals.count == 2, "a refused request is never submitted")

        native.answer(0, with: .acknowledged(nil))
        #expect(provider.submissionsInFlight == 1)
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.reveals.count == 3)
    }

    @Test func allFourSubmittingRootsShareOneBoundOnOutstandingSubmissions() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(40), capacity: 1)
        _ = await provider.resolve(LaunchTests.request())  // outstanding: no callback
        #expect(provider.submissionsInFlight == 1)
        let refused = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(refused.message.contains("outstanding"))
        #expect(native.reveals.isEmpty)
    }

    @Test func aDependencyRefusalOrInputErrorNeverUsesCapacity() async throws {
        let (native, provider) = Self.bench(capacity: 1)
        _ = await provider.resolve(Self.request(.string("/Users/test/gone.txt")))
        _ = await provider.resolve(Self.request(.string("relative")))
        native.inspect(Self.finderPath, as: .absent)
        _ = await provider.resolve(Self.request())
        #expect(provider.submissionsInFlight == 0 && native.reveals.isEmpty)
    }
}
