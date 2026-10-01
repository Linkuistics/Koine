import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// The real workspace provider over a substituted native adapter: its mapping of URL
/// validation, default-handler resolution, native acknowledgment and observation onto
/// `workspaceOpenURL`'s results. Callbacks are controlled; no browser exists.
@Suite struct OpenURLTests {
    static let search = "https://www.google.com/search?q=koine%20plugins&hl=en#results"
    static let safari = URL(fileURLWithPath: "/Applications/Safari.app")

    static func request(_ url: ProviderValue? = .string(search)) -> ResolutionRequest {
        ResolutionRequest(resolverId: "openURL", arguments: url.map { ["url": $0] } ?? [:], parent: nil)
    }

    /// A provider over a native with a default browser installed and a running application
    /// whose observation rule holds, unless a test changes it.
    static func bench(
        bound: Duration = .seconds(30), capacity: Int = 16, browser: Bool = true
    ) -> (native: FakeNative, provider: WorkspaceProvider) {
        let (native, provider) = LaunchTests.bench(bound: bound, capacity: capacity)
        if browser { native.installBrowser() }
        return (native, provider)
    }

    // MARK: Results

    @Test func anAcknowledgedOpenIsAvailableWithTheObservedProcess() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(FakeApplication())) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))

        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["dependency"] == .null)
        #expect(
            fields["value"]
                == .object([
                    "process": .object(["pid": .int(4242), "startedAt": .string("2027-01-15T08:00:00.123456Z")])
                ]))
        #expect(native.opens.count == 1)
        #expect(native.launches.isEmpty, "a URL open is not an application launch")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func anAcknowledgmentWithNoApplicationHasNoProcess() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["value"] == .object(["process": .null]))
    }

    @Test func theSubmittedBytesAreTheReceivedBytesAddressedToTheResolvedBrowser() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        for input in WebURLTests.accepted {
            _ = await provider.resolve(Self.request(.string(input)))
        }
        #expect(native.opens.map(\.url.absoluteString) == WebURLTests.accepted)
        #expect(native.opens.allSatisfy { $0.application == Self.safari })
    }

    // MARK: The default handler is resolved by the scheme alone

    @Test func theHandlerIsLookedUpByTheSchemeAndNothingFromTheURL() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        for input in [
            "https://maps.apple.com/?q=cafe", "http://example.com/", "HTTPS://example.com/Universal/Link",
            "http://xn--bcher-kva.example:8080/x#y",
        ] {
            _ = await provider.resolve(Self.request(.string(input)))
        }
        // The lookup's only parameter is the scheme, so no host, path, query or fragment can reach it.
        #expect(native.handlerLookups == [.https, .http, .https, .http])
        #expect(native.opens.count == 4)
    }

    @Test func aDifferentHandlerPerSchemeIsHonouredAndNeverFallsBackAcrossSchemes() async throws {
        let (native, provider) = Self.bench(browser: false)
        native.installBrowser("org.mozilla.firefox", at: "/Applications/Firefox.app", schemes: [.https])
        native.onLaunch = { $0(.acknowledged(nil)) }
        _ = await provider.resolve(Self.request(.string("https://example.com/")))
        let http = try #require(LaunchTests.value(await provider.resolve(Self.request(.string("http://example.com/")))))
        #expect(native.opens.map(\.application.path) == ["/Applications/Firefox.app"])
        #expect(http["status"] == .string("DEPENDENCY_UNAVAILABLE"), "no http handler: no fallback to https's")
    }

    @Test func aDefaultChangedAfterResolutionNeitherRetargetsNorReplaysThatAction() async throws {
        let (native, provider) = Self.bench()
        let firefox = URL(fileURLWithPath: "/Applications/Firefox.app")
        native.onLaunch = { completion in
            // The user changes the default while the open is outstanding, then the system answers.
            native.setWebHandler(.https, to: firefox)
            completion(.acknowledged(nil))
        }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.handlerLookups == [.https], "resolved once")
        #expect(native.opens.map(\.application) == [Self.safari], "the resolved browser, once")

        // The next action resolves afresh; nothing was cached.
        native.install("org.mozilla.firefox", at: "/Applications/Firefox.app", file: "firefox")
        native.onLaunch = { $0(.acknowledged(nil)) }
        _ = await provider.resolve(Self.request())
        #expect(native.handlerLookups == [.https, .https])
        #expect(native.opens.map(\.application) == [Self.safari, firefox])
    }

    // MARK: Absence

    @Test func anAbsentHandlerIsDependencyAbsenceAndSubmitsNothing() async throws {
        let (native, provider) = Self.bench(browser: false)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(fields["value"] == .null)
        guard case .object(let dependency)? = fields["dependency"] else {
            Issue.record("a dependency is named")
            return
        }
        #expect(dependency["reason"] == .string("NO_DEFAULT_HANDLER"))
        guard case .string(let guidance)? = dependency["guidance"] else {
            Issue.record("guidance is text")
            return
        }
        #expect(!guidance.contains("google"), "the URL is not echoed")
        #expect(native.opens.isEmpty && native.launches.isEmpty, "no chooser, no fallback, no action")
        #expect(native.handlerLookups == [.https])
        #expect(provider.submissionsInFlight == 0)
    }

    @Test(arguments: [ApplicationInspection.absent, .notApplication])
    func aRegisteredHandlerWhoseBundleIsGoneIsNoHandler(inspection: ApplicationInspection) async throws {
        let (native, provider) = Self.bench()
        native.inspect("/Applications/Safari.app", as: inspection)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        guard case .object(let dependency)? = fields["dependency"] else {
            Issue.record("a dependency is named")
            return
        }
        #expect(dependency["reason"] == .string("NO_DEFAULT_HANDLER"))
        #expect(native.opens.isEmpty)
    }

    @Test func handlerMetadataThatCannotBeReadIsFailedNeverAbsence() async throws {
        let (native, provider) = Self.bench()
        native.inspect("/Applications/Safari.app", as: .unreadable("Operation not permitted"))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Operation not permitted"))
        #expect(native.opens.isEmpty)
    }

    // MARK: Input, before anything is inspected

    @Test(arguments: [
        "", " https://example.com", "https://example.com/a b", "https://example.com\\evil", "https://user@example.com/",
        "ftp://example.com/", "file:///etc/hosts", "javascript:alert(1)", "https://example.com/%zz",
        "https://example.com/café", "https://bücher.example/", "https://xn--abc-.example/", "example.com", "https://",
    ])
    func invalidInputActsOnNothing(_ input: String) async throws {
        let (native, provider) = Self.bench()
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(.string(input)))))
        #expect(failure.kind == .invalidInput)
        #expect(native.opens.isEmpty && native.handlerLookups.isEmpty && native.inspected.isEmpty)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aMissingOrNonStringURLIsInput() async throws {
        let (native, provider) = Self.bench()
        for argument: ProviderValue? in [nil, .null, .int(1), .bool(true), .object([:])] {
            let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(argument))))
            #expect(failure.kind == .invalidInput)
        }
        #expect(native.opens.isEmpty && native.handlerLookups.isEmpty)
    }

    // MARK: The bounded acknowledgment

    @Test func aNegativeAcknowledgmentIsFailedWithNoReplay() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.refused("The application can't be opened")) }
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("The application can't be opened"))
        #expect(native.opens.count == 1, "the open is never repeated")
        #expect(native.handlerLookups == [.https], "and no other handler is tried")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aMissingCallbackEndsAtTheBoundAsFailed() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(80))
        let started = ContinuousClock.now
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("did not acknowledge"))
        #expect(ContinuousClock.now - started < .seconds(5))
        #expect(native.opens.count == 1)
        #expect(provider.submissionsInFlight == 1, "the system was not cancelled and has not answered")
    }

    @Test func aLateAcknowledgmentIsIgnoredAndReleasesItsSlot() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(60))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(provider.submissionsInFlight == 1)

        // The slow open completes after the bound, and a second answer follows it.
        native.answer(with: .acknowledged(FakeApplication()))
        native.answer(with: .refused("and again"))
        #expect(provider.submissionsInFlight == 0, "released once, and never below zero")
        #expect(native.opens.count == 1, "nothing was replayed")
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
        while native.opens.isEmpty { try await Task.sleep(for: .milliseconds(5)) }
        task.cancel()
        let failure = try #require(LaunchTests.failure(await task.value))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Cancelled"))
        #expect(ContinuousClock.now - started < .seconds(10))
        #expect(provider.submissionsInFlight == 1, "the native call is outstanding until it answers")
        native.answer(with: .acknowledged(FakeApplication()))
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aRequestCancelledBeforeAnythingHappensLooksUpAndSubmitsNothing() async throws {
        let (native, provider) = Self.bench()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return await provider.resolve(Self.request())
        }
        let failure = try #require(LaunchTests.failure(await task.value))
        #expect(failure.kind == .failed)
        #expect(native.opens.isEmpty && native.handlerLookups.isEmpty)
    }

    @Test func exhaustedCapacityRefusesBeforeSubmissionAndIsRestoredByACallback() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(40), capacity: 2)
        for _ in 0..<2 { _ = await provider.resolve(Self.request()) }
        #expect(native.opens.count == 2 && provider.submissionsInFlight == 2)

        let refused = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(refused.kind == .failed)
        #expect(refused.message.contains("outstanding"))
        #expect(native.opens.count == 2, "a refused request is never submitted")

        native.answer(0, with: .acknowledged(nil))
        #expect(provider.submissionsInFlight == 1)
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.opens.count == 3)
    }

    @Test func launchesAndURLOpensShareOneBoundOnOutstandingSubmissions() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(40), capacity: 1)
        _ = await provider.resolve(LaunchTests.request())  // outstanding: no callback
        #expect(provider.submissionsInFlight == 1)
        let refused = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(refused.message.contains("outstanding"))
        #expect(native.opens.isEmpty)
    }

    @Test func aDependencyOrInputRefusalNeverUsesCapacity() async throws {
        let (native, provider) = Self.bench(capacity: 1, browser: false)
        _ = await provider.resolve(Self.request())
        _ = await provider.resolve(Self.request(.string("ftp://example.com/")))
        #expect(provider.submissionsInFlight == 0 && native.opens.isEmpty)
    }
}
