import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// The real workspace provider over a substituted native adapter: its mapping of path
/// validation, target inspection, the refusal policy, handler choice, native acknowledgment
/// and observation onto `workspaceOpenPath`'s results. Metadata and callbacks are controlled;
/// nothing is opened and no file is read.
@Suite struct OpenPathTests {
    static let document = "/Users/test/notes.txt"
    static let folder = "/Users/test/config"
    static let zed = "dev.zed.Zed"

    static func request(_ path: ProviderValue? = .string(document), application: ProviderValue? = nil) -> ResolutionRequest {
        var arguments: [String: ProviderValue] = [:]
        if let path { arguments["path"] = path }
        if let application { arguments["application"] = application }
        return ResolutionRequest(resolverId: "openPath", arguments: arguments, parent: nil)
    }

    static func named(_ identifier: String = zed, path: String? = nil) -> ProviderValue {
        .object(["bundleIdentifier": .string(identifier), "applicationPath": path.map(ProviderValue.string) ?? .null])
    }

    /// A provider over a native with a text file and a folder that have default handlers, Zed
    /// installed, and a running application whose observation rule holds.
    static func bench(
        bound: Duration = .seconds(30), capacity: Int = 16
    ) -> (native: FakeNative, provider: WorkspaceProvider) {
        let (native, provider) = LaunchTests.bench(bound: bound, capacity: capacity)
        native.document(document)
        native.installDocumentHandler(for: document)
        native.document(folder, directory: true, type: "public.folder")
        native.installDocumentHandler(for: folder, "com.apple.finder", at: "/System/Library/CoreServices/Finder.app")
        native.install(zed, at: "/Applications/Zed.app", file: "zed")
        return (native, provider)
    }

    static func dependencyReason(_ fields: [String: ProviderValue]) -> ProviderValue? {
        guard case .object(let dependency)? = fields["dependency"] else { return nil }
        return dependency["reason"]
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
        #expect(native.pathOpens.count == 1)
        #expect(native.launches.isEmpty && native.opens.isEmpty, "a path open is neither a launch nor a URL open")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func anAcknowledgmentWithNoApplicationHasNoProcess() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["value"] == .object(["process": .null]))
    }

    @Test func aNullApplicationAndAnOmittedOneBothSelectTheDefaultHandler() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        for application: ProviderValue? in [nil, .null] {
            let fields = try #require(
                LaunchTests.value(await provider.resolve(Self.request(application: application))))
            #expect(fields["status"] == .string("AVAILABLE"))
        }
        #expect(native.pathOpens.map(\.application.path) == Array(repeating: "/System/Applications/TextEdit.app", count: 2))
        #expect(native.pathOpens.allSatisfy { $0.substituting }, "the default handler may be a running copy elsewhere")
    }

    @Test func aDirectoryReachesANamedApplicationSuchAsZed() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(
            LaunchTests.value(await provider.resolve(Self.request(.string(Self.folder), application: Self.named()))))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.pathOpens.count == 1)
        #expect(native.pathOpens[0].application.path == "/Applications/Zed.app")
        #expect(native.pathOpens[0].url.path == Self.folder)
        #expect(native.pathOpens[0].url.hasDirectoryPath)
        #expect(native.pathOpens[0].substituting)
        #expect(native.documentLookups.isEmpty, "a named application is not looked up as a default handler")
    }

    @Test func aNamedApplicationAtAPathForbidsSubstitution() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        _ = await provider.resolve(
            Self.request(.string(Self.folder), application: Self.named(path: "/Applications/Zed.app")))
        #expect(native.pathOpens.map(\.substituting) == [false])
        #expect(native.pathOpens.map(\.application.path) == ["/Applications/Zed.app"])
    }

    @Test func theDefaultOfADirectoryAndOfADocumentAreEachLookedUpForThatItem() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        _ = await provider.resolve(Self.request(.string(Self.document)))
        _ = await provider.resolve(Self.request(.string(Self.folder)))
        #expect(native.documentLookups.map(\.path) == [Self.document, Self.folder])
        #expect(native.pathOpens.map(\.application.lastPathComponent) == ["TextEdit.app", "Finder.app"])
    }

    // MARK: Paths are literal

    @Test(arguments: [
        "/Users/test/a b/c  d.txt", "/Users/test/$HOME/`x`;rm -rf *.txt", "/Users/test/it's \"quoted\" & (more)?.txt",
        "/Users/test/~/x", "/Users/test/*.txt", "/Users/test/caf\u{E9}/\u{4F8B}.txt", "/Users/test/a%20b.txt",
        "/Users/test/trailing space ", "/Users/test/../test/dot-dot.txt",
    ])
    func spacesAndShellPunctuationStayLiteral(_ path: String) async throws {
        let (native, provider) = Self.bench()
        native.document(path)
        native.installDocumentHandler(for: path)
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string(path)))))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.pathInspected == [path], "inspected as written, never expanded or normalized")
        #expect(native.pathOpens.map(\.url.path) == [path])
    }

    @Test(arguments: [
        "", "relative/file.txt", "./file.txt", "../file.txt", "~/file.txt", "$HOME/file.txt", "file:///Users/test/notes.txt",
        "notes.txt", " /Users/test/notes.txt", "\n/Users/test/notes.txt", "/Users/test/a\u{0}b.txt", "\u{0}",
    ])
    func anUnusablePathIsInputAndActsOnNothing(_ path: String) async throws {
        let (native, provider) = Self.bench()
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(.string(path)))))
        #expect(failure.kind == .invalidInput)
        #expect(native.pathInspected.isEmpty && native.inspected.isEmpty && native.documentLookups.isEmpty)
        #expect(native.pathOpens.isEmpty && native.registeredApplications(bundleIdentifier: Self.zed).count == 1)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aMissingOrNonStringPathIsInput() async throws {
        let (native, provider) = Self.bench()
        for argument: ProviderValue? in [nil, .null, .int(1), .bool(true), .object([:]), .list([.string(Self.document)])] {
            let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(argument))))
            #expect(failure.kind == .invalidInput)
        }
        #expect(native.pathInspected.isEmpty && native.pathOpens.isEmpty)
    }

    @Test(arguments: [
        ProviderValue.string("com.apple.Notes"), .int(1), .object([:]), .object(["bundleIdentifier": .null]),
        .object(["bundleIdentifier": .string("   ")]), .object(["bundleIdentifier": .string("")]),
        .object(["bundleIdentifier": .string(OpenPathTests.zed), "applicationPath": .string("")]),
        .object(["bundleIdentifier": .string(OpenPathTests.zed), "applicationPath": .string("relative/Zed.app")]),
        .object(["bundleIdentifier": .string(OpenPathTests.zed), "applicationPath": .string("/Applications/Z\u{0}ed.app")]),
        .object(["bundleIdentifier": .string(OpenPathTests.zed), "applicationPath": .int(3)]),
    ])
    func anUnusableApplicationIsInputBeforeTheTargetIsInspected(_ application: ProviderValue) async throws {
        let (native, provider) = Self.bench()
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(application: application))))
        #expect(failure.kind == .invalidInput)
        #expect(native.pathInspected.isEmpty && native.inspected.isEmpty && native.pathOpens.isEmpty)
    }

    // MARK: Absence: the target first, then the handler

    @Test(arguments: [nil, OpenPathTests.named()])
    func aMissingPathIsPathNotFoundAndNothingElseIsLookedUp(application: ProviderValue?) async throws {
        let (native, provider) = Self.bench()
        let fields = try #require(
            LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/gone.txt"), application: application))))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(fields["value"] == .null)
        #expect(Self.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.resolved == ["/Users/test/gone.txt"])
        #expect(native.pathInspected.isEmpty, "an absent target has no metadata to read")
        #expect(native.documentLookups.isEmpty && native.inspected.isEmpty, "a missing file is not conflated with a missing handler")
        #expect(native.pathOpens.isEmpty && provider.submissionsInFlight == 0)
    }

    @Test func aDanglingLinkIsAMissingPath() async throws {
        let (native, provider) = Self.bench()
        // The native layer resolves symlinks, so a dangling one inspects as nothing there.
        native.inspectPath("/Users/test/dangling", as: .absent)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/dangling")))))
        #expect(Self.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.pathOpens.isEmpty)
    }

    @Test func theTargetIsReportedBeforeANamedApplicationThatIsAlsoMissing() async throws {
        let (native, provider) = Self.bench()
        let fields = try #require(
            LaunchTests.value(
                await provider.resolve(Self.request(.string("/Users/test/gone.txt"), application: Self.named("com.example.none")))))
        #expect(Self.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.inspected.isEmpty)
    }

    @Test func anExistingPathWithNoDefaultHandlerIsNoDefaultHandler() async throws {
        let (native, provider) = Self.bench()
        native.document("/Users/test/odd.xyz", type: "dyn.age80w5xx")
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/odd.xyz")))))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(Self.dependencyReason(fields) == .string("NO_DEFAULT_HANDLER"))
        guard case .object(let dependency)? = fields["dependency"], case .string(let guidance)? = dependency["guidance"] else {
            Issue.record("guidance is text")
            return
        }
        #expect(!guidance.contains("odd.xyz"), "the path is not echoed")
        #expect(native.documentLookups.map(\.path) == ["/Users/test/odd.xyz"])
        #expect(native.pathOpens.isEmpty, "no chooser, no fallback application")
    }

    @Test(arguments: [ApplicationInspection.absent, .notApplication])
    func aRegisteredHandlerWhoseBundleIsGoneIsNoDefaultHandler(inspection: ApplicationInspection) async throws {
        let (native, provider) = Self.bench()
        native.inspect("/System/Applications/TextEdit.app", as: inspection)
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(Self.dependencyReason(fields) == .string("NO_DEFAULT_HANDLER"))
        #expect(native.pathOpens.isEmpty)
    }

    @Test func handlerMetadataThatCannotBeReadIsFailedNeverAbsence() async throws {
        let (native, provider) = Self.bench()
        native.inspect("/System/Applications/TextEdit.app", as: .unreadable("Operation not permitted"))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Operation not permitted"))
        #expect(native.pathOpens.isEmpty)
    }

    @Test func aNamedApplicationThatIsNotInstalledOrIsTheWrongOneIsDependencyAbsenceWithNoFallback() async throws {
        let (native, provider) = Self.bench()
        let missing = try #require(
            LaunchTests.value(await provider.resolve(Self.request(application: Self.named("com.example.none")))))
        #expect(Self.dependencyReason(missing) == .string("APPLICATION_NOT_INSTALLED"))

        native.install("com.example.other", at: "/Applications/Other.app", file: "other")
        let mismatch = try #require(
            LaunchTests.value(
                await provider.resolve(Self.request(application: Self.named(Self.zed, path: "/Applications/Other.app")))))
        #expect(Self.dependencyReason(mismatch) == .string("APPLICATION_IDENTITY_MISMATCH"))

        #expect(native.pathOpens.isEmpty, "neither the default handler nor another copy stood in")
        #expect(native.documentLookups.isEmpty)
    }

    // MARK: Named selection and default handlers are distinct (application-installations-k78)

    @Test func aDefaultHandlerThatDeclaresNoBundleIdentifierStillReceivesTheDocument() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        // The registered handler is present as an application bundle and has no identifier:
        // there is no selector route for it, and the default route does not need one.
        native.inspect(
            "/Applications/Anonymous.app",
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: "/Applications/Anonymous.app"), bundleIdentifier: nil,
                    identity: FakeNative.identity("anonymous"))))
        native.setDocumentHandler(for: Self.document, to: URL(fileURLWithPath: "/Applications/Anonymous.app"))
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.pathOpens.map(\.application.path) == ["/Applications/Anonymous.app"])

        // The same bundle is not reachable through the named selector, by any identifier.
        let named = try #require(
            LaunchTests.value(
                await provider.resolve(
                    Self.request(application: Self.named("com.example.anonymous", path: "/Applications/Anonymous.app")))))
        #expect(Self.dependencyReason(named) == .string("APPLICATION_IDENTITY_MISMATCH"))
        #expect(native.pathOpens.count == 1, "the refused named request submitted nothing")
    }

    @Test func aBundleLessProgramNamedAsTheApplicationIsNotInstalledAndTheDefaultIsNotUsedInItsPlace() async throws {
        let (native, provider) = Self.bench()
        native.inspect("/Users/test/bin/tool", as: .notApplication)
        let fields = try #require(
            LaunchTests.value(
                await provider.resolve(Self.request(application: Self.named(Self.zed, path: "/Users/test/bin/tool")))))
        #expect(Self.dependencyReason(fields) == .string("APPLICATION_NOT_INSTALLED"))
        #expect(native.pathOpens.isEmpty)
        #expect(native.documentLookups.isEmpty, "no default handler is looked up as a substitute")
    }

    @Test func aChosenInstallationThatCannotBeReadIsFailedWithNothingSubmitted() async throws {
        let (native, provider) = Self.bench()
        native.inspect("/Users/test/Locked/Zed.app", as: .unreadable("Permission denied"))
        let failure = try #require(
            LaunchTests.failure(
                await provider.resolve(Self.request(application: Self.named(Self.zed, path: "/Users/test/Locked/Zed.app")))))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Permission denied"))
        #expect(native.pathOpens.isEmpty)
        #expect(native.documentLookups.isEmpty)
    }

    // MARK: The refusal policy

    /// Metadata that identifies something the policy refuses, each by its own route.
    static let refused: [(String, PathFacts, [String])] = [
        ("resource metadata says application", PathFacts(isDirectory: true, isApplication: true, isAliasFile: false, contentType: "public.folder"), []),
        ("application-bundle type", PathFacts(isDirectory: true, isApplication: false, isAliasFile: false, contentType: "com.apple.application-bundle"), []),
        ("a subtype of application-bundle", PathFacts(isDirectory: true, isApplication: false, isAliasFile: false, contentType: "com.example.plugin-bundle"), ["com.apple.application-bundle"]),
        ("unix executable", PathFacts(isDirectory: false, isApplication: false, isAliasFile: false, contentType: "public.unix-executable"), []),
        ("a subtype of unix executable", PathFacts(isDirectory: false, isApplication: false, isAliasFile: false, contentType: "com.example.binary"), ["public.unix-executable"]),
        ("windows executable", PathFacts(isDirectory: false, isApplication: false, isAliasFile: false, contentType: "com.microsoft.windows-executable"), []),
        ("a subtype of windows executable", PathFacts(isDirectory: false, isApplication: false, isAliasFile: false, contentType: "com.example.exe"), ["com.microsoft.windows-executable"]),
        ("alias flag", PathFacts(isDirectory: false, isApplication: false, isAliasFile: true, contentType: "public.data"), []),
        ("alias type", PathFacts(isDirectory: false, isApplication: false, isAliasFile: false, contentType: "com.apple.alias-file"), []),
        ("a subtype of alias file", PathFacts(isDirectory: false, isApplication: false, isAliasFile: false, contentType: "com.example.alias"), ["com.apple.alias-file"]),
        ("an alias that is also an application", PathFacts(isDirectory: false, isApplication: true, isAliasFile: true, contentType: nil), []),
        ("application flag with no content type", PathFacts(isDirectory: true, isApplication: true, isAliasFile: false, contentType: nil), []),
    ]

    @Test(arguments: OpenPathTests.refused.map { $0.0 }, [nil, OpenPathTests.named()])
    func refusedMetadataIsAnInputErrorForTheDefaultAndANamedApplicationAlike(
        label: String, application: ProviderValue?
    ) async throws {
        let (native, provider) = Self.bench()
        let (_, facts, ancestors) = try #require(Self.refused.first { $0.0 == label })
        native.document(
            "/Users/test/payload", directory: facts.isDirectory, application: facts.isApplication,
            alias: facts.isAliasFile, type: facts.contentType, conformsTo: ancestors)
        let failure = try #require(
            LaunchTests.failure(await provider.resolve(Self.request(.string("/Users/test/payload"), application: application))),
            Comment(rawValue: label))
        #expect(failure.kind == .invalidInput, Comment(rawValue: label))
        #expect(native.documentLookups.isEmpty && native.inspected.isEmpty, "refused before any handler is chosen: \(label)")
        #expect(native.pathOpens.isEmpty && provider.submissionsInFlight == 0, Comment(rawValue: label))
    }

    @Test func eachRefusalNamesItsOwnReason() async throws {
        let (native, provider) = Self.bench()
        native.document("/Users/test/a.app", directory: true, application: true, type: "com.apple.application-bundle")
        native.document("/Users/test/prog", type: "public.unix-executable")
        native.document("/Users/test/al", alias: true, type: "com.apple.alias-file")
        var messages: [String] = []
        for path in ["/Users/test/a.app", "/Users/test/prog", "/Users/test/al"] {
            messages.append(try #require(LaunchTests.failure(await provider.resolve(Self.request(.string(path))))).message)
        }
        #expect(messages[0].contains("application bundle"))
        #expect(messages[1].contains("executable"))
        #expect(messages[2].contains("alias"))
        #expect(Set(messages).count == 3)
    }

    /// Ordinary source and script documents are not executable content for this policy. Their
    /// types conform to the broad ancestors the policy deliberately does not use.
    @Test(arguments: [
        ("public.shell-script", ["public.script", "public.executable", "public.source-code", "public.text"]),
        ("com.apple.terminal.shell-script", ["public.shell-script", "public.script", "public.executable"]),
        ("com.netscape.javascript-source", ["public.script", "public.executable", "public.source-code"]),
        ("public.python-script", ["public.script", "public.executable"]),
        ("public.plain-text", []), ("public.folder", []), ("com.apple.rtfd", ["public.composite-content", "public.directory"]),
        ("com.apple.web-internet-location", ["public.data"]), ("public.data", []), ("com.example.unknown", []),
    ] as [(String, [String])])
    func ordinaryDocumentsAreNotRefusedForTheBroadExecutableAncestors(type: String, ancestors: [String]) async throws {
        let (native, provider) = Self.bench()
        let path = "/Users/test/script-like"
        native.document(path, directory: type == "public.folder" || type == "com.apple.rtfd", type: type, conformsTo: ancestors)
        native.installDocumentHandler(for: path)
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string(path)))))
        #expect(fields["status"] == .string("AVAILABLE"), Comment(rawValue: type))
        // And to a named application, whatever its permission bits (the metadata has none).
        let named = try #require(
            LaunchTests.value(await provider.resolve(Self.request(.string(path), application: Self.named()))))
        #expect(named["status"] == .string("AVAILABLE"), Comment(rawValue: type))
        #expect(native.pathOpens.count == 2)
    }

    @Test func aDocumentWithNoContentTypeIsNotRefusedOnThatGround() async throws {
        let (native, provider) = Self.bench()
        native.document("/Users/test/untyped", type: nil)
        native.installDocumentHandler(for: "/Users/test/untyped")
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request(.string("/Users/test/untyped")))))
        #expect(fields["status"] == .string("AVAILABLE"))
    }

    // MARK: Inspection that fails

    @Test(arguments: [nil, OpenPathTests.named()])
    func inspectionDenialIsFailedNeverAbsenceAndNothingIsSubmitted(application: ProviderValue?) async throws {
        let (native, provider) = Self.bench()
        native.inspectPath(Self.document, as: .unreadable("Operation not permitted"))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(application: application))))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Operation not permitted"))
        #expect(native.documentLookups.isEmpty && native.inspected.isEmpty && native.pathOpens.isEmpty)
        #expect(provider.submissionsInFlight == 0)
    }

    // MARK: Replacement and handler changes racing submission

    @Test func aReplacementAfterInspectionIsNotReinspectedAndTheInspectedTargetIsSubmittedOnce() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { completion in
            // The file becomes an application while the open is outstanding; the system answers.
            native.document(Self.document, directory: true, application: true, type: "com.apple.application-bundle")
            completion(.acknowledged(nil))
        }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.pathInspected == [Self.document], "inspected once, before submission")
        #expect(native.pathOpens.count == 1, "never replayed")

        // The next action inspects afresh, finds the replacement, and refuses it.
        let next = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(next.kind == .invalidInput)
        #expect(native.pathInspected == [Self.document, Self.document])
        #expect(native.pathOpens.count == 1)
    }

    @Test func aDefaultChangedAfterResolutionNeitherRetargetsNorReplaysThatAction() async throws {
        let (native, provider) = Self.bench()
        let other = URL(fileURLWithPath: "/Applications/Other.app")
        native.onLaunch = { completion in
            native.setDocumentHandler(for: Self.document, to: other)
            completion(.acknowledged(nil))
        }
        _ = await provider.resolve(Self.request())
        #expect(native.documentLookups.count == 1, "resolved once")
        #expect(native.pathOpens.map(\.application.lastPathComponent) == ["TextEdit.app"])

        // The next action resolves afresh; nothing was cached.
        native.install("com.example.other", at: "/Applications/Other.app", file: "other")
        native.onLaunch = { $0(.acknowledged(nil)) }
        _ = await provider.resolve(Self.request())
        #expect(native.documentLookups.count == 2)
        #expect(native.pathOpens.map(\.application.lastPathComponent) == ["TextEdit.app", "Other.app"])
    }

    // MARK: The bounded acknowledgment

    @Test func aNegativeAcknowledgmentIsFailedWithNoReplayOrOtherHandler() async throws {
        let (native, provider) = Self.bench()
        native.onLaunch = { $0(.refused("The application can't open the file")) }
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request(.string(Self.folder), application: Self.named()))))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("The application can't open the file"))
        #expect(native.pathOpens.count == 1, "the open is never repeated")
        #expect(native.documentLookups.isEmpty, "and no fallback handler is tried")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func aMissingCallbackEndsAtTheBoundAsFailed() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(80))
        let started = ContinuousClock.now
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("did not acknowledge"))
        #expect(ContinuousClock.now - started < .seconds(5))
        #expect(native.pathOpens.count == 1)
        #expect(provider.submissionsInFlight == 1, "the system was not cancelled and has not answered")
    }

    @Test func aLateAcknowledgmentIsIgnoredAndReleasesItsSlot() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(60))
        let failure = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(failure.kind == .failed)
        #expect(provider.submissionsInFlight == 1)

        native.answer(with: .acknowledged(FakeApplication()))
        native.answer(with: .refused("and again"))
        #expect(provider.submissionsInFlight == 0, "released once, and never below zero")
        #expect(native.pathOpens.count == 1, "nothing was replayed")
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
        while native.pathOpens.isEmpty { try await Task.sleep(for: .milliseconds(5)) }
        task.cancel()
        let failure = try #require(LaunchTests.failure(await task.value))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("Cancelled"))
        #expect(ContinuousClock.now - started < .seconds(10))
        #expect(provider.submissionsInFlight == 1, "the native call is outstanding until it answers")
        native.answer(with: .acknowledged(FakeApplication()))
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
        #expect(native.pathInspected.isEmpty && native.pathOpens.isEmpty)
    }

    @Test func exhaustedCapacityRefusesBeforeSubmissionAndIsRestoredByACallback() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(40), capacity: 2)
        for _ in 0..<2 { _ = await provider.resolve(Self.request()) }
        #expect(native.pathOpens.count == 2 && provider.submissionsInFlight == 2)

        let refused = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(refused.kind == .failed)
        #expect(refused.message.contains("outstanding"))
        #expect(native.pathOpens.count == 2, "a refused request is never submitted")

        native.answer(0, with: .acknowledged(nil))
        #expect(provider.submissionsInFlight == 1)
        native.onLaunch = { $0(.acknowledged(nil)) }
        let fields = try #require(LaunchTests.value(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.pathOpens.count == 3)
    }

    @Test func allThreeSubmittingRootsShareOneBoundOnOutstandingSubmissions() async throws {
        let (native, provider) = Self.bench(bound: .milliseconds(40), capacity: 1)
        _ = await provider.resolve(LaunchTests.request())  // outstanding: no callback
        #expect(provider.submissionsInFlight == 1)
        let refused = try #require(LaunchTests.failure(await provider.resolve(Self.request())))
        #expect(refused.message.contains("outstanding"))
        #expect(native.pathOpens.isEmpty)
    }

    @Test func aDependencyRefusalOrInputErrorNeverUsesCapacity() async throws {
        let (native, provider) = Self.bench(capacity: 1)
        _ = await provider.resolve(Self.request(.string("/Users/test/gone.txt")))
        _ = await provider.resolve(Self.request(.string("relative")))
        native.document("/Users/test/payload", application: true, type: "com.apple.application-bundle")
        _ = await provider.resolve(Self.request(.string("/Users/test/payload")))
        #expect(provider.submissionsInFlight == 0 && native.pathOpens.isEmpty)
    }
}
