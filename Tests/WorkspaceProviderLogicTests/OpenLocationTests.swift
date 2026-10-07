import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// L: the planner's mapping of every resolution row for an open's target, of the application hand-off
/// limit, and of reading the target's metadata from the resolved spelling, over the substituted private
/// adapter. The adapter answers what the walk would find, including what no fixture can build (an
/// over-limit target, a name limit that cannot be read), and records every call, so "no metadata read, no
/// handler lookup, no submission" is observed rather than inferred. The walk is `LocationWalkTests`, reveal's
/// use of it `RevealLocationTests`, and the built provider `WorkspaceLongLocationTests`.
@Suite struct OpenLocationTests {
    static let target = OpenPathTests.document

    /// A path of exactly `count` bytes: `/` and then `a`s.
    static func path(_ count: Int) -> String { "/" + String(repeating: "a", count: count - 1) }

    /// A present target whose spellings are as given: `literal` is the caller's text, and `resolved` the
    /// physical path the metadata is read from.
    static func present(
        literal: String = target, expansions: [Int] = [], resolved: String = target, directory: Bool = false
    ) -> LocationResolution {
        .present(
            ResolvedLocation(
                literal: Spelling(bytes: Array(literal.utf8)),
                expansions: expansions.map { Spelling(bytes: Array(path($0).utf8)) },
                resolved: Spelling(bytes: Array(resolved.utf8)),
                identity: ObjectIdentity(device: 1, inode: 7), type: directory ? .directory : .regularFile))
    }

    /// A bench whose target resolves as arranged and whose resolved object has plain-text metadata.
    static func open(
        _ resolution: LocationResolution, application: ProviderValue? = nil, path: String = target
    ) async throws -> (native: FakeNative, provider: WorkspaceProvider, result: ResolutionResult) {
        let (native, provider) = OpenPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.location(path, as: resolution)
        if case .present(let found) = resolution { native.document(found.resolved.text) }
        native.installDocumentHandler(for: path)
        return (native, provider, await provider.resolve(OpenPathTests.request(.string(path), application: application)))
    }

    /// Nothing was read, looked up or submitted after a refusal or an absence.
    static func nothingElseWasAsked(_ native: FakeNative) {
        #expect(native.pathInspected.isEmpty, "no metadata was read")
        #expect(native.documentLookups.isEmpty && native.handlerLookups.isEmpty, "no handler lookup")
        #expect(native.inspected.isEmpty && native.registrationLookups.isEmpty, "no application was looked at")
        #expect(native.rootChecks.isEmpty)
        #expect(native.pathOpens.isEmpty && native.launches.isEmpty && native.opens.isEmpty && native.reveals.isEmpty)
    }

    // MARK: Absence

    @Test(
        arguments: [
            Absence.missing(component: "gone"), .notDirectory(component: "notes.txt"),
            .impossibleComponent(component: String(repeating: "n", count: 300)), .cycle(link: "loop-a"),
        ], [nil, OpenPathTests.named()])
    func everyAbsenceIsPathNotFoundForTheDefaultAndANamedApplicationAndNothingElseIsAsked(
        _ absence: Absence, application: ProviderValue?
    ) async throws {
        let (native, provider, result) = try await Self.open(.absent(absence), application: application)
        let fields = try #require(LaunchTests.value(result))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(fields["value"] == .null)
        #expect(OpenPathTests.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.resolved == [Self.target])
        Self.nothingElseWasAsked(native)
        #expect(provider.submissionsInFlight == 0)
    }

    // MARK: Failure

    @Test(
        arguments: [
            ("chain-33", "more than 32 symbolic links had to be followed"),
            ("a-long-name", "File name too long"),
            ("n", "its name is too long and the filesystem's name limit cannot be read"),
            ("again", "the link's text changed while it was being resolved"),
            ("closed", "Permission denied"),
        ], [nil, OpenPathTests.named()])
    func everyUnestablishedStepIsFailedNamingTheComponentAndTheCause(
        _ row: (String, String), application: ProviderValue?
    ) async throws {
        let (component, cause) = row
        let (native, provider, result) = try await Self.open(
            .failed(component: component, cause: cause), application: application)
        let failure = try #require(LaunchTests.failure(result))
        #expect(failure.kind == .failed, "never a dependency")
        #expect(failure.message.contains("\"\(component)\""), "names the component: \(failure.message)")
        #expect(failure.message.contains(cause), "and the cause: \(failure.message)")
        Self.nothingElseWasAsked(native)
        #expect(provider.submissionsInFlight == 0)
    }

    /// The walk found the object; a later metadata answer of nothing there is a failure, never absence.
    @Test func aLaterPlatformAbsenceAboutAnObjectTheWalkFoundIsFailed() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.location(Self.target, as: Self.present())
        native.inspectPath(Self.target, as: .absent)
        let failure = try #require(LaunchTests.failure(await provider.resolve(OpenPathTests.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains("could not be inspected"))
        #expect(native.documentLookups.isEmpty && native.inspected.isEmpty && native.pathOpens.isEmpty)
    }

    // MARK: The limit

    @Test func theLongestSpellingsAreHandedOverAtOneThousandTwentyThreeBytes() async throws {
        let long = Self.path(1023)
        let (native, _, result) = try await Self.open(
            Self.present(literal: long, expansions: [1023, 1023], resolved: Self.path(1023)), path: long)
        let fields = try #require(LaunchTests.value(result))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.pathInspected == [Self.path(1023)], "the metadata is read from the resolved spelling")
        #expect(native.pathOpens.map(\.url.path) == [long], "the caller's literal path is submitted, as written")
    }

    static let overLimit: [(Int, [Int], Int, String, Int)] = [
        (1024, [], 40, "the path as written", 1024), (1500, [], 40, "the path as written", 1500),
        (40, [1024], 40, "the remaining path after symbolic link 1", 1024),
        (40, [100, 1100], 40, "the remaining path after symbolic link 2", 1100),
        (40, [100], 1024, "the resolved path", 1024), (40, [], 1600, "the resolved path", 1600),
    ]

    @Test(arguments: OpenLocationTests.overLimit.map(\.3), [nil, OpenPathTests.named()])
    func aSpellingOfOneThousandTwentyFourBytesOrMoreIsRefusedAsFailedBeforeAnyMetadataHandlerOrRequest(
        _ spelling: String, application: ProviderValue?
    ) async throws {
        let (literal, expansions, resolved, _, byteCount) = try #require(Self.overLimit.first { $0.3 == spelling })
        let literalPath = literal > 40 ? Self.path(literal) : Self.target
        let (native, provider, result) = try await Self.open(
            Self.present(literal: literalPath, expansions: expansions, resolved: Self.path(resolved)),
            application: application, path: literalPath)
        let failure = try #require(LaunchTests.failure(result), "an extant location is `failed`, never a dependency")
        #expect(failure.kind == .failed)
        for needed in ["application hand-off", spelling, "\(byteCount) bytes", "No request was made", "nothing was opened"] {
            #expect(failure.message.contains(needed), "\(needed): \(failure.message)")
        }
        Self.nothingElseWasAsked(native)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func theFirstSpellingOverTheLimitIsTheOneNamed() async throws {
        let (_, _, result) = try await Self.open(
            Self.present(literal: Self.path(1030), expansions: [1040], resolved: Self.path(1050)), path: Self.path(1030))
        #expect(try #require(LaunchTests.failure(result)).message.contains("path as written"))
    }

    /// The accepted order: the target settles before anything else, and the limit before any metadata read.
    @Test func anOverLimitTargetIsFailedNotRefusedAsAPayloadAndItsMetadataIsNeverRead() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.location(Self.target, as: Self.present(resolved: Self.path(1100)))
        native.document(Self.path(1100), directory: true, application: true, type: "com.apple.application-bundle")
        let failure = try #require(LaunchTests.failure(await provider.resolve(OpenPathTests.request())))
        #expect(failure.kind == .failed, "the limit, not the payload policy's input error: \(failure.message)")
        #expect(failure.message.contains("1100 bytes"))
        #expect(native.pathInspected.isEmpty)
    }

    @Test func anOverLimitTargetIsRefusedBeforeANamedApplicationThatIsAlsoMissing() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.location(Self.target, as: Self.present(literal: Self.path(2000)))
        let named = OpenPathTests.named("com.example.none")
        let failure = try #require(
            LaunchTests.failure(await provider.resolve(OpenPathTests.request(application: named))))
        #expect(failure.message.contains("2000 bytes"), "the refusal, not APPLICATION_NOT_INSTALLED")
        #expect(native.registrationLookups.isEmpty && native.inspected.isEmpty)
    }

    @Test func anOverLimitTargetIsRefusedBeforeAHandlerLookupThatWouldAnswerNoDefaultHandler() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.location(Self.target, as: Self.present(expansions: [1500]))
        native.document(Self.target, type: "dyn.age80w5xx")
        let failure = try #require(LaunchTests.failure(await provider.resolve(OpenPathTests.request())))
        #expect(failure.message.contains("1500 bytes"), "the refusal, not NO_DEFAULT_HANDLER")
        #expect(native.documentLookups.isEmpty)
    }

    // MARK: The resolved object

    /// The metadata is read from where the walk ended, and the caller's literal text is what is submitted
    /// and what the default handler is asked about.
    @Test func theMetadataIsReadFromTheResolvedSpellingAndTheLiteralTargetIsSubmitted() async throws {
        let link = "/Users/test/link.txt"
        let real = "/Users/test/real/notes.txt"
        let (native, provider) = OpenPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.location(link, as: Self.present(literal: link, expansions: [30], resolved: real))
        native.document(real)
        native.installDocumentHandler(for: link)
        let fields = try #require(LaunchTests.value(await provider.resolve(OpenPathTests.request(.string(link)))))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.pathInspected == [real], "read once, from the resolved spelling")
        #expect(native.documentLookups.map(\.path) == [link], "the default handler is asked about the caller's literal target")
        #expect(native.pathOpens.map(\.url.path) == [link])
    }

    @Test func aTargetResolvingToADirectoryIsSubmittedAsADirectory() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.location(OpenPathTests.folder, as: Self.present(literal: OpenPathTests.folder, resolved: "/real/config", directory: true))
        native.document("/real/config", directory: true, type: "public.folder")
        _ = await provider.resolve(OpenPathTests.request(.string(OpenPathTests.folder)))
        #expect(native.pathInspected == ["/real/config"])
        #expect(native.pathOpens.map(\.url.hasDirectoryPath) == [true])
    }

    /// The payload policy applies to the resolved object at any depth: a payload at the end of a link, or
    /// at a resolved spelling of 1,000 bytes, is refused exactly as a short one is.
    @Test(arguments: OpenPathTests.refused.map { $0.0 }, [nil, OpenPathTests.named()])
    func aPayloadIsRefusedOnTheResolvedObjectAtAnyDepth(label: String, application: ProviderValue?) async throws {
        let (_, facts, ancestors) = try #require(OpenPathTests.refused.first { $0.0 == label })
        for resolvedBytes in [0, 1_000, 1_023] {
            let resolved = resolvedBytes == 0 ? "/Users/test/payload" : Self.path(resolvedBytes)
            let (native, provider) = OpenPathTests.bench()
            native.location(Self.target, as: Self.present(expansions: [30], resolved: resolved))
            native.document(
                resolved, directory: facts.isDirectory, application: facts.isApplication, alias: facts.isAliasFile,
                type: facts.contentType, conformsTo: ancestors)
            let failure = try #require(
                LaunchTests.failure(await provider.resolve(OpenPathTests.request(application: application))))
            #expect(failure.kind == .invalidInput, "\(label) at \(resolved.utf8.count) bytes: \(failure.message)")
            #expect(native.pathInspected == [resolved], "\(label): read from the resolved spelling")
            #expect(native.documentLookups.isEmpty && native.inspected.isEmpty && native.pathOpens.isEmpty)
        }
    }

    /// The accepted order after the target stage stands: a source script's default editor, and the default
    /// handler asked about the caller's literal target.
    @Test func aDocumentThatIsNotAPayloadReachesItsDefaultHandlerAsBefore() async throws {
        let (native, _, result) = try await Self.open(Self.present(resolved: "/real/script.sh"))
        #expect(try #require(LaunchTests.value(result))["status"] == .string("AVAILABLE"))
        #expect(native.documentLookups.map(\.path) == [Self.target])
        #expect(native.pathOpens.map(\.application.lastPathComponent) == ["TextEdit.app"])
    }
}
