import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// L: the planner's mapping of every resolution row for a reveal's target, and of the application
/// hand-off limit, over the substituted private adapter. The adapter answers what the walk would find,
/// including the cases no fixture can build (an over-limit target, a name limit that cannot be read), and
/// records every call, so "no metadata read, no registration or Finder lookup, no request" is observed
/// rather than inferred. The walk itself is `LocationWalkTests`; the built provider is
/// `WorkspaceProviderTests`.
@Suite struct RevealLocationTests {
    static let target = "/Users/test/notes.txt"

    /// A path of exactly `count` bytes: `/` and then `a`s.
    static func spelling(_ count: Int) -> Spelling { Spelling(bytes: [UInt8(ascii: "/")] + Array(repeating: UInt8(ascii: "a"), count: count - 1)) }

    static func present(literal: Int = 40, expansions: [Int] = [], resolved: Int = 40) -> LocationResolution {
        .present(
            ResolvedLocation(
                literal: spelling(literal), expansions: expansions.map(spelling), resolved: spelling(resolved),
                identity: ObjectIdentity(device: 1, inode: 7), type: .regularFile))
    }

    static func reveal(_ resolution: LocationResolution, path: String = target) async throws
        -> (native: FakeNative, provider: WorkspaceProvider, result: ResolutionResult)
    {
        let (native, provider) = RevealPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.location(path, as: resolution)
        return (native, provider, await provider.resolve(RevealPathTests.request(.string(path))))
    }

    /// What no request, lookup or metadata read was made after a refusal or an absence.
    static func nothingElseWasAsked(_ native: FakeNative) {
        #expect(native.rootChecks.isEmpty, "no whole-path call addresses the location")
        #expect(native.inspected.isEmpty, "no application was inspected")
        #expect(native.registrationLookups.isEmpty, "no registration lookup, so no Finder lookup")
        #expect(native.pathInspected.isEmpty, "no metadata was read")
        #expect(native.documentLookups.isEmpty && native.handlerLookups.isEmpty)
        #expect(native.reveals.isEmpty && native.launches.isEmpty && native.opens.isEmpty && native.pathOpens.isEmpty)
    }

    // MARK: Absence

    @Test(arguments: [
        Absence.missing(component: "gone"), .notDirectory(component: "notes.txt"),
        .impossibleComponent(component: String(repeating: "n", count: 300)), .cycle(link: "loop-a"),
    ])
    func everyAbsenceIsPathNotFoundForATargetAndNothingElseIsAsked(_ absence: Absence) async throws {
        let (native, provider, result) = try await Self.reveal(.absent(absence))
        let fields = try #require(LaunchTests.value(result))
        #expect(fields["status"] == .string("DEPENDENCY_UNAVAILABLE"))
        #expect(fields["value"] == .null)
        #expect(RevealPathTests.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.resolved == [Self.target])
        Self.nothingElseWasAsked(native)
        #expect(provider.submissionsInFlight == 0)
    }

    // MARK: Failure

    @Test(arguments: [
        ("chain-33", "more than 32 symbolic links had to be followed"),
        ("a", "more than 32 symbolic links had to be followed"),
        ("a-long-name", "File name too long"),
        ("n", "its name is too long and the filesystem's name limit cannot be read"),
        ("again", "the link's text changed while it was being resolved"),
        ("closed", "Permission denied"),
    ])
    func everyUnestablishedStepIsFailedNamingTheComponentAndTheCause(_ component: String, _ cause: String) async throws {
        let (native, provider, result) = try await Self.reveal(.failed(component: component, cause: cause))
        let failure = try #require(LaunchTests.failure(result))
        #expect(failure.kind == .failed, "never a dependency")
        #expect(failure.message.contains("\"\(component)\""), "names the component: \(failure.message)")
        #expect(failure.message.contains(cause), "and the cause: \(failure.message)")
        Self.nothingElseWasAsked(native)
        #expect(provider.submissionsInFlight == 0)
    }

    /// The walk found the location; a later platform answer about it is a failure, never absence.
    @Test(arguments: ["No such file or directory", "Too many levels of symbolic links", "File name too long"])
    func aLaterPlatformAbsenceAboutALocationTheWalkFoundIsFailed(_ reason: String) async throws {
        let (native, provider) = RevealPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.location(Self.target, as: Self.present())
        native.filesystemRoot(Self.target, as: .failed(reason))
        let failure = try #require(LaunchTests.failure(await provider.resolve(RevealPathTests.request())))
        #expect(failure.kind == .failed)
        #expect(failure.message.contains(reason))
        #expect(native.reveals.isEmpty && native.inspected.isEmpty, "nothing was submitted, and Finder was not asked")
    }

    // MARK: The limit

    @Test func theLongestSpellingsAreHandedOverAtOneThousandTwentyThreeBytes() async throws {
        let (native, _, result) = try await Self.reveal(Self.present(literal: 1023, expansions: [1023, 1023], resolved: 1023))
        let fields = try #require(LaunchTests.value(result))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.reveals == [Self.target], "the caller's literal path is submitted, as written")
    }

    @Test(arguments: [
        (1024, [Int](), 40, "the path as written", 1024), (1500, [Int](), 40, "the path as written", 1500),
        (40, [1024], 40, "the remaining path after symbolic link 1", 1024),
        (40, [100, 1100], 40, "the remaining path after symbolic link 2", 1100),
        (40, [100], 1024, "the resolved path", 1024), (40, [], 1600, "the resolved path", 1600),
    ])
    func aSpellingOfOneThousandTwentyFourBytesOrMoreIsRefusedAsFailedBeforeAnyRequest(
        _ literal: Int, _ expansions: [Int], _ resolved: Int, _ spelling: String, _ byteCount: Int
    ) async throws {
        let (native, provider, result) = try await Self.reveal(Self.present(literal: literal, expansions: expansions, resolved: resolved))
        let failure = try #require(LaunchTests.failure(result), "an extant location is `failed`, never a dependency")
        #expect(failure.kind == .failed)
        for needed in ["application hand-off", spelling, "\(byteCount) bytes", "No request was made", "nothing was revealed"] {
            #expect(failure.message.contains(needed), "\(needed): \(failure.message)")
        }
        Self.nothingElseWasAsked(native)
        #expect(provider.submissionsInFlight == 0)
    }

    @Test func theFirstSpellingOverTheLimitIsTheOneNamed() async throws {
        let (_, _, result) = try await Self.reveal(Self.present(literal: 1030, expansions: [1040], resolved: 1050))
        #expect(try #require(LaunchTests.failure(result)).message.contains("path as written"))
    }

    /// The accepted order: the target settles before Finder, and the limit before anything addresses the path.
    @Test func anOverLimitTargetIsRefusedBeforeAFinderThatIsAlsoMissing() async throws {
        let native = FakeNative()
        let provider = WorkspaceProvider(native: native)
        native.location(Self.target, as: Self.present(literal: 2000))
        let failure = try #require(LaunchTests.failure(await provider.resolve(RevealPathTests.request())))
        #expect(failure.message.contains("2000 bytes"), "the refusal, not APPLICATION_NOT_INSTALLED")
        #expect(native.registrationLookups.isEmpty)
    }

    // MARK: The accepted order and the root rule

    @Test func aPresentTargetWithinTheLimitKeepsTheAcceptedFinderCheckAndAcknowledgment() async throws {
        let (native, provider, result) = try await Self.reveal(Self.present())
        let fields = try #require(LaunchTests.value(result))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["value"] == .object(["path": .string(Self.target)]))
        #expect(native.rootChecks == [Self.target], "the root rule reads the literal text")
        #expect(native.inspected == [RevealPathTests.finderPath], "Finder is checked after the target")
        #expect(native.reveals == [Self.target])
        #expect(provider.submissionsInFlight == 0)
    }

    @Test(arguments: [
        ("/", true), ("//", true), ("/.", true), ("/..", true), ("/var/..", false), ("/Volumes/Macintosh HD", false),
        ("/Volumes/Macintosh HD/", true),
    ])
    func theRootDecisionIsAskedOfTheLiteralTextAndSubmittedAsItAnswers(_ path: String, _ isRoot: Bool) async throws {
        let (native, provider) = RevealPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        native.location(path, as: Self.present(literal: path.utf8.count, resolved: isRoot ? 1 : 12))
        native.filesystemRoot(path, as: isRoot ? .root : .notRoot)
        let fields = try #require(LaunchTests.value(await provider.resolve(RevealPathTests.request(.string(path)))))
        #expect(fields["value"] == .object(["path": .string(path)]), "echoed as submitted")
        #expect(native.rootChecks == [path], "asked about the literal, never the resolved spelling")
        #expect(native.reveals == [path])
        #expect(native.revealedAsRoot == [isRoot])
    }

    @Test func aFinderThatIsMissingStillReportsAfterAPresentTarget() async throws {
        let native = FakeNative()
        let provider = WorkspaceProvider(native: native)
        native.location(Self.target, as: Self.present())
        let fields = try #require(LaunchTests.value(await provider.resolve(RevealPathTests.request())))
        #expect(RevealPathTests.dependencyReason(fields) == .string("APPLICATION_NOT_INSTALLED"))
        #expect(native.reveals.isEmpty)
    }
}
