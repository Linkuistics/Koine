import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// L: the planner's mapping of the supplied-application stage (docs/specs/workspace-launch-and-open.md "Order of
/// target and application stages", stage 2) over the substituted private adapter. A constrained launch and a named
/// open resolve `applicationPath` by the walk, refuse an over-limit spelling before any registration lookup or
/// metadata read, and compare the chosen copy with the registered candidates by device and inode alone. The
/// adapter answers what the walk would find, including what no fixture can build (a 1,500-byte copy, a candidate
/// whose name limit cannot be read), and records every call, so "no metadata read, no registration lookup" and
/// "not examined" are observed rather than inferred. The walk is `LocationWalkTests`, and the built provider
/// `WorkspaceLongLocationTests`.
@Suite struct ApplicationLocationTests {
    static let notes = "com.apple.Notes"
    static let chosen = "/Users/a/Apps/Notes.app"
    static let chosenInode: UInt64 = 100

    /// A path of exactly `count` bytes ending in `.app`, beneath `/Long`.
    static func long(_ count: Int, _ label: String = "x") -> String {
        let suffix = "/\(label).app"
        return "/Long" + String(repeating: "d", count: count - suffix.utf8.count - 5) + suffix
    }

    static func present(
        _ literal: String, inode: UInt64 = chosenInode, device: Int32 = 1, expansions: [Int] = [], resolved: String? = nil
    ) -> LocationResolution {
        .present(
            ResolvedLocation(
                literal: Spelling(bytes: Array(literal.utf8)),
                expansions: expansions.map { Spelling(bytes: Array(long($0, "e").utf8)) },
                resolved: Spelling(bytes: Array((resolved ?? literal).utf8)),
                identity: ObjectIdentity(device: device, inode: inode), type: .directory))
    }

    static func request(path: String? = chosen, identifier: String = notes) -> ApplicationRequest {
        ApplicationRequest(bundleIdentifier: identifier, applicationPath: path)
    }

    /// The chosen copy is present at `path` with the right identifier. Its bundle is read at `resolved`.
    @discardableResult
    static func choose(
        _ native: FakeNative, at path: String = chosen, expansions: [Int] = [], resolved: String? = nil
    ) -> String {
        let spelling = resolved ?? path
        native.location(path, as: present(path, expansions: expansions, resolved: spelling))
        native.inspect(
            spelling,
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: spelling), bundleIdentifier: notes, identity: FakeNative.identity("unused"))))
        return spelling
    }

    /// A registered candidate, listed (and so enumerated, in the order registered) unless `preferred`, which is
    /// Launch Services' answer for the identifier and is enumerated last when the list does not hold it.
    static func register(
        _ native: FakeNative, _ path: String, as resolution: LocationResolution, preferred: Bool = false, listed: Bool = true
    ) {
        native.register(notes, at: URL(fileURLWithPath: path), default: preferred, listed: listed)
        native.location(path, as: resolution)
    }

    static func select(
        _ native: FakeNative, path: String? = chosen, action: String = "launched"
    ) -> Selection {
        selectInstallation(request(path: path), forAction: action, native: native)
    }

    static func failure(_ selection: Selection) -> String? {
        if case .failed(let message) = selection { return message }
        return nil
    }

    static func dependency(_ selection: Selection) -> DependencyReason? {
        if case .dependency(let reason, _) = selection { return reason }
        return nil
    }

    static func selected(_ selection: Selection) -> (path: String, substituting: Bool)? {
        if case .selected(let url, let substituting) = selection { return (url.path, substituting) }
        return nil
    }

    /// Nothing was registered, read or submitted: the stage ended at the chosen path.
    static func nothingElseWasAsked(_ native: FakeNative, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(native.registrationLookups.isEmpty, "no registration lookup", sourceLocation: sourceLocation)
        #expect(native.bundleReads.isEmpty, "no metadata read", sourceLocation: sourceLocation)
        #expect(native.inspected.isEmpty, "no whole-path inspection", sourceLocation: sourceLocation)
        #expect(native.launches.isEmpty && native.pathOpens.isEmpty, "no submission", sourceLocation: sourceLocation)
    }

    // MARK: The chosen path

    @Test(arguments: [Absence.missing(component: "Notes.app"), .notDirectory(component: "Apps")])
    func anAbsentChosenPathIsNotInstalledAndNothingElseIsAsked(_ absence: Absence) {
        let native = FakeNative()
        native.location(Self.chosen, as: .absent(absence))
        #expect(Self.dependency(Self.select(native)) == .applicationNotInstalled)
        #expect(native.resolved == [Self.chosen])
        Self.nothingElseWasAsked(native)
    }

    @Test(arguments: [
        Absence.impossibleComponent(component: String(repeating: "n", count: 300)), .cycle(link: "loop-a"),
    ])
    func anImpossibleNameOrACycleAtTheChosenPathIsFailedNeverAMissingApplication(_ absence: Absence) throws {
        let native = FakeNative()
        native.location(Self.chosen, as: .absent(absence))
        let message = try #require(Self.failure(Self.select(native)), "a dependency would call an extant location missing")
        #expect(message.contains("application path could not be resolved"), Comment(rawValue: message))
        Self.nothingElseWasAsked(native)
    }

    @Test(arguments: [
        ("chain-33", "more than 32 symbolic links had to be followed"), ("closed", "Permission denied"),
        ("a-long-name", "File name too long"), ("again", "the link's text changed while it was being resolved"),
    ])
    func everyUnestablishedStepAtTheChosenPathIsFailedNamingTheComponentAndTheCause(_ row: (String, String)) throws {
        let (component, cause) = row
        let native = FakeNative()
        native.location(Self.chosen, as: .failed(component: component, cause: cause))
        let message = try #require(Self.failure(Self.select(native)))
        #expect(message.contains("\"\(component)\"") && message.contains(cause), Comment(rawValue: message))
        Self.nothingElseWasAsked(native)
    }

    @Test func aPresentNonApplicationIsNotInstalledWhateverIdentifierIsOffered() {
        let native = FakeNative()
        native.location(Self.chosen, as: Self.present(Self.chosen))
        native.inspect(Self.chosen, as: .notApplication)
        #expect(Self.dependency(Self.select(native)) == .applicationNotInstalled)
        #expect(native.bundleReads == [Self.chosen])
        #expect(native.registrationLookups.isEmpty, "the candidates are compared only after the bundle matched")
    }

    @Test(arguments: ["com.example.other", nil] as [String?])
    func anotherIdentifierOrNoneIsAMismatchAndNoCandidateIsResolved(_ identifier: String?) {
        let native = FakeNative()
        native.location(Self.chosen, as: Self.present(Self.chosen))
        native.inspect(
            Self.chosen,
            as: .application(
                ApplicationBundle(url: URL(fileURLWithPath: Self.chosen), bundleIdentifier: identifier, identity: FakeNative.identity("x"))))
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Notes.app"))
        #expect(Self.dependency(Self.select(native)) == .applicationIdentityMismatch)
        #expect(native.resolved == [Self.chosen])
        #expect(native.registrationLookups.isEmpty)
    }

    @Test func aBundleThatCannotBeReadIsFailedNeverAMismatchOrAbsence() throws {
        let native = FakeNative()
        native.location(Self.chosen, as: Self.present(Self.chosen))
        native.inspect(Self.chosen, as: .unreadable("Permission denied"))
        #expect(try #require(Self.failure(Self.select(native))).contains("Permission denied"))
        #expect(native.registrationLookups.isEmpty)
    }

    /// The walk found the object; a later metadata answer of nothing there is a failure, never absence.
    @Test func aLaterPlatformAbsenceAboutAChosenCopyTheWalkFoundIsFailed() throws {
        let native = FakeNative()
        native.location(Self.chosen, as: Self.present(Self.chosen))
        native.inspect(Self.chosen, as: .absent)
        let message = try #require(Self.failure(Self.select(native)))
        #expect(message.contains("could not be inspected"), Comment(rawValue: message))
    }

    @Test func theBundleIsReadFromTheResolvedSpellingNeverTheCallers() {
        let native = FakeNative()
        let resolved = "/Real/Notes.app"
        Self.choose(native, at: "/Users/a/link/Notes.app", expansions: [], resolved: resolved)
        Self.register(native, "/Applications/Notes.app", as: Self.present("/Applications/Notes.app"), preferred: true)
        let picked = Self.selected(Self.select(native, path: "/Users/a/link/Notes.app"))
        #expect(picked?.path == "/Applications/Notes.app")
        #expect(native.bundleReads == [resolved])
    }

    // MARK: The limit

    static let overLimit: [(literal: Int, expansions: [Int], resolved: Int, spelling: String, byteCount: Int)] = [
        (1024, [], 40, "the application path as written", 1024), (1500, [], 40, "the application path as written", 1500),
        (40, [1024], 40, "the remaining application path after symbolic link 1", 1024),
        (40, [100, 1100], 40, "the remaining application path after symbolic link 2", 1100),
        (40, [100], 1024, "the resolved application path", 1024), (40, [], 1600, "the resolved application path", 1600),
    ]

    /// An over-limit chosen path is refused after the walk and before any registration lookup or metadata read,
    /// whatever the object is: a non-application and another identifier are not asked about.
    @Test(arguments: ApplicationLocationTests.overLimit.map(\.spelling))
    func aSpellingOfOneThousandTwentyFourBytesOrMoreIsRefusedAsFailedBeforeAnyRegistrationOrMetadataRead(
        _ spelling: String
    ) throws {
        let row = try #require(Self.overLimit.first { $0.spelling == spelling })
        let literal = row.literal > 40 ? Self.long(row.literal) : Self.chosen
        let native = FakeNative()
        native.location(
            literal,
            as: Self.present(literal, expansions: row.expansions, resolved: row.resolved > 40 ? Self.long(row.resolved) : literal))
        native.inspect(literal, as: .notApplication)
        for action in ["launched", "opened"] {
            let message = try #require(Self.failure(Self.select(native, path: literal, action: action)), "never a dependency")
            for needed in ["application hand-off", spelling, "\(row.byteCount) bytes", "No request was made", "nothing was \(action)"] {
                #expect(message.contains(needed), "\(needed): \(message)")
            }
        }
        Self.nothingElseWasAsked(native)
    }

    @Test func theFirstSpellingOverTheLimitIsTheOneNamed() throws {
        let native = FakeNative()
        let literal = Self.long(1030)
        native.location(literal, as: Self.present(literal, expansions: [1040], resolved: Self.long(1050)))
        #expect(try #require(Self.failure(Self.select(native, path: literal))).contains("application path as written"))
    }

    @Test func theLongestSpellingsAreHandedOverAtOneThousandTwentyThreeBytes() {
        let native = FakeNative()
        let literal = Self.long(1023)
        Self.choose(native, at: literal, expansions: [1023, 1023])
        let copy = Self.long(1023, "y")
        Self.register(native, copy, as: Self.present(copy, expansions: [1023]), preferred: true)
        #expect(Self.selected(Self.select(native, path: literal))?.path == copy, "1,023 is handed over, in every spelling")
    }

    // MARK: Candidates

    /// What sits beside the present chosen copy, and where Launch Services lists it.
    enum Neighbour: CaseIterable, CustomTestStringConvertible {
        case staleAbsent, unequalLong, unequalUnreadable, unequalShort, anotherVolume
        var testDescription: String {
            switch self {
            case .staleAbsent: "a stale absent registration"
            case .unequalLong: "an unequal long candidate"
            case .unequalUnreadable: "an unequal candidate whose metadata cannot be read"
            case .unequalShort: "an unequal short candidate"
            case .anotherVolume: "the same inode on another volume"
            }
        }

        func register(_ native: FakeNative, at path: String) {
            switch self {
            case .staleAbsent: ApplicationLocationTests.register(native, path, as: .absent(.missing(component: path)))
            case .unequalLong:
                ApplicationLocationTests.register(
                    native, path, as: ApplicationLocationTests.present(path, inode: 7, expansions: [1200]))
            case .unequalUnreadable:
                ApplicationLocationTests.register(native, path, as: ApplicationLocationTests.present(path, inode: 7))
                native.inspect(path, as: .unreadable("Permission denied"))
            case .unequalShort: ApplicationLocationTests.register(native, path, as: ApplicationLocationTests.present(path, inode: 7))
            case .anotherVolume:
                ApplicationLocationTests.register(
                    native, path, as: ApplicationLocationTests.present(path, inode: ApplicationLocationTests.chosenInode, device: 2))
            }
        }

        /// The path, which for the long candidate is itself over the limit.
        var path: String { self == .unequalLong ? ApplicationLocationTests.long(1500, "n") : "/Applications/Neighbour-\(self).app" }
    }

    @Test(arguments: Neighbour.allCases)
    func aNeighbourBeforeTheMatchIsSkippedAndTheMatchIsSelectedWithoutReadingAnyCandidatesMetadata(_ neighbour: Neighbour) {
        let native = FakeNative()
        Self.choose(native)
        neighbour.register(native, at: neighbour.path)
        let match = "/Applications/Notes.app"
        Self.register(native, match, as: Self.present(match))
        let picked = Self.selected(Self.select(native))
        #expect(picked?.path == match, "\(neighbour.testDescription): \(String(describing: picked))")
        #expect(picked?.substituting == false)
        #expect(native.resolved == [Self.chosen, neighbour.path, match])
        #expect(native.bundleReads == [Self.chosen], "no candidate's own metadata was read")
        #expect(native.inspected.isEmpty)
    }

    @Test(arguments: Neighbour.allCases)
    func aNeighbourAfterTheMatchIsNotExamined(_ neighbour: Neighbour) {
        let native = FakeNative()
        Self.choose(native)
        let match = "/Applications/Notes.app"
        Self.register(native, match, as: Self.present(match))
        neighbour.register(native, at: neighbour.path)
        #expect(Self.selected(Self.select(native))?.path == match)
        #expect(native.resolved == [Self.chosen, match], "\(neighbour.testDescription) was not examined")
    }

    enum Unknown: CaseIterable, CustomTestStringConvertible {
        case failed, impossible, cycle
        var testDescription: String {
            switch self {
            case .failed: "a failed resolution"
            case .impossible: "an impossible name"
            case .cycle: "a cycle"
            }
        }
        var resolution: LocationResolution {
            switch self {
            case .failed: .failed(component: "closed", cause: "Permission denied")
            case .impossible: .absent(.impossibleComponent(component: String(repeating: "n", count: 300)))
            case .cycle: .absent(.cycle(link: "loop-a"))
            }
        }
    }

    /// Equality is unknown, and a skipped copy would guess it: the stage is `failed`, not the next copy.
    @Test(arguments: Unknown.allCases)
    func aCandidateReachedBeforeTheMatchWhoseResolutionFailsIsFailedAndTheMatchIsNeverReached(_ unknown: Unknown) throws {
        let native = FakeNative()
        Self.choose(native)
        let unknownPath = "/Applications/Unknown.app"
        Self.register(native, unknownPath, as: unknown.resolution)
        let match = "/Applications/Notes.app"
        Self.register(native, match, as: Self.present(match))
        let message = try #require(Self.failure(Self.select(native)), "never a dependency or a skipped copy: \(unknown.testDescription)")
        #expect(message.contains("could not be compared"), Comment(rawValue: message))
        #expect(native.resolved == [Self.chosen, unknownPath])
        #expect(native.bundleReads == [Self.chosen])
    }

    @Test(arguments: Unknown.allCases)
    func aCandidateAfterTheMatchWhoseResolutionWouldFailIsNeverExaminedAndTheMatchIsSelected(_ unknown: Unknown) {
        let native = FakeNative()
        Self.choose(native)
        let match = "/Applications/Notes.app"
        Self.register(native, match, as: Self.present(match))
        let unknownPath = "/Applications/Unknown.app"
        Self.register(native, unknownPath, as: unknown.resolution)
        #expect(Self.selected(Self.select(native))?.path == match, Comment(rawValue: unknown.testDescription))
        #expect(native.resolved == [Self.chosen, match])
    }

    @Test func aPresentChosenCopyMatchingNoCandidateIsUnregistered() {
        let native = FakeNative()
        Self.choose(native)
        let other = "/Applications/Notes.app"
        Self.register(native, other, as: Self.present(other, inode: 7), preferred: true)
        Self.register(native, "/Applications/Gone.app", as: .absent(.missing(component: "Gone.app")))
        #expect(Self.dependency(Self.select(native)) == .applicationNotInstalled)
        #expect(native.resolved == [Self.chosen, other, "/Applications/Gone.app"], "the preferred copy is in the list, and not repeated")
    }

    @Test func aPresentChosenCopyWithNoRegistrationAtAllIsUnregistered() {
        let native = FakeNative()
        Self.choose(native)
        #expect(Self.dependency(Self.select(native)) == .applicationNotInstalled)
        #expect(native.resolved == [Self.chosen])
    }

    @Test func thePreferredCopyOutsideTheListIsComparedLastAndIsTheRegisteredLocationSubmitted() {
        let native = FakeNative()
        Self.choose(native)
        let listed = "/Applications/Listed.app"
        let trashed = "/Users/a/.Trash/Notes.app"
        Self.register(native, listed, as: Self.present(listed, inode: 7))
        Self.register(native, trashed, as: Self.present(trashed), preferred: true, listed: false)
        let picked = Self.selected(Self.select(native))
        #expect(picked?.path == trashed, "the registered location, never the caller's spelling")
        #expect(picked?.substituting == false, "a chosen installation is never replaced by a running copy")
        #expect(native.resolved == [Self.chosen, listed, trashed])
    }

    @Test func anotherSpellingOfTheChosenCopyMatchesByIdentityAndIsTheOneSubmitted() {
        let native = FakeNative()
        Self.choose(native, at: "/Users/a/link/Notes.app", resolved: "/Real/Notes.app")
        let registered = "/Real/Notes.app"
        Self.register(native, registered, as: Self.present(registered), preferred: true)
        #expect(Self.selected(Self.select(native, path: "/Users/a/link/Notes.app"))?.path == registered)
    }

    // MARK: The selected copy is refused at the limit, never replaced

    /// The match itself is long: refused with `failed`, and no other copy, short or running, is substituted.
    @Test(arguments: [1024, 1500])
    func aLongCopyThatIsTheSelectedOneIsRefusedAtTheLimitAndNoOtherCopyIsSubstituted(_ length: Int) throws {
        let native = FakeNative()
        Self.choose(native)
        let short = "/Applications/Other.app"
        let match = Self.long(length, "m")
        let alsoMatching = "/Applications/Notes.app"
        Self.register(native, short, as: Self.present(short, inode: 7))
        Self.register(native, match, as: Self.present(match))
        Self.register(native, alsoMatching, as: Self.present(alsoMatching))
        let message = try #require(Self.failure(Self.select(native)), "never a dependency and never another copy")
        for needed in ["application hand-off", "registered application path as written", "\(length) bytes", "No request was made"] {
            #expect(message.contains(needed), "\(needed): \(message)")
        }
        #expect(native.resolved == [Self.chosen, short, match], "stopped at the first match, which is the one refused")
        #expect(native.launches.isEmpty)
    }

    @Test func aSelectedCopyWhoseExpansionOrResolvedSpellingIsLongIsRefusedAtThatSpelling() throws {
        for (expansions, resolved, spelling) in [
            ([1100], "/Applications/Notes.app", "remaining registered application path after symbolic link 1"),
            ([], Self.long(1300, "r"), "resolved registered application path"),
        ] {
            let native = FakeNative()
            Self.choose(native)
            let match = "/Applications/Notes.app"
            Self.register(native, match, as: Self.present(match, expansions: expansions, resolved: resolved))
            let message = try #require(Self.failure(Self.select(native)))
            #expect(message.contains(spelling), Comment(rawValue: message))
        }
    }

    // MARK: Through the provider

    @Test func aLongUnequalCopyOnDiskDoesNotStopAShortWorkflowForALaunchOrANamedOpen() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        Self.choose(native)
        let long = Self.long(1500, "n")
        Self.register(native, long, as: Self.present(long, inode: 7))
        let match = "/Applications/Notes.app"
        Self.register(native, match, as: Self.present(match), preferred: true)
        let launched = try #require(LaunchTests.value(await provider.resolve(LaunchTests.request(path: Self.chosen))))
        #expect(launched["status"] == .string("AVAILABLE"))
        #expect(native.launches.map(\.url.path) == [match])
        #expect(native.launches.map(\.substituting) == [false])
        let opened = try #require(
            LaunchTests.value(
                await provider.resolve(OpenPathTests.request(application: OpenPathTests.named(Self.notes, path: Self.chosen)))))
        #expect(opened["status"] == .string("AVAILABLE"))
        #expect(native.pathOpens.map(\.application.path) == [match])
    }

    @Test func anOverLimitApplicationPathIsFailedWithGuidanceAtTheResponsePathAndNothingIsSubmitted() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let literal = Self.long(1500)
        native.location(literal, as: Self.present(literal))
        let launch = try #require(LaunchTests.failure(await provider.resolve(LaunchTests.request(path: literal))))
        #expect(launch.kind == .failed)
        #expect(launch.message.contains("1500 bytes") && launch.message.contains("nothing was launched"), Comment(rawValue: launch.message))
        let before = native.registrationLookups.count
        let open = try #require(
            LaunchTests.failure(
                await provider.resolve(OpenPathTests.request(application: OpenPathTests.named(Self.notes, path: literal)))))
        #expect(open.kind == .failed)
        #expect(open.message.contains("1500 bytes") && open.message.contains("nothing was opened"), Comment(rawValue: open.message))
        #expect(native.launches.isEmpty && native.pathOpens.isEmpty)
        #expect(native.registrationLookups.count == before, "no registration lookup for the application")
        #expect(native.bundleReads.isEmpty)
        #expect(provider.submissionsInFlight == 0)
    }

    /// The target settles first: a missing target is `PATH_NOT_FOUND` even beside an over-limit application path.
    @Test func theTargetIsSettledBeforeTheSuppliedApplicationIsResolved() async throws {
        let (native, provider) = OpenPathTests.bench()
        let literal = Self.long(1500)
        native.location(literal, as: Self.present(literal))
        native.location("/Users/test/missing.txt", as: .absent(.missing(component: "missing.txt")))
        let fields = try #require(
            LaunchTests.value(
                await provider.resolve(
                    OpenPathTests.request(.string("/Users/test/missing.txt"), application: OpenPathTests.named(Self.notes, path: literal)))))
        #expect(OpenPathTests.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(!native.resolved.contains(literal), "the application path was not resolved")
    }
}
