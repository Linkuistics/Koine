import Darwin
import Foundation
import Testing
import WorkspaceTestSupport

@testable import WorkspaceProviderLogic

extension WalkTree {
    /// The object `parts` names, in the walk's own terms.
    func identity(_ parts: [String], followLink: Bool = true) -> ObjectIdentity? {
        fileKey(parts, followLink: followLink).map { ObjectIdentity(device: $0.device, inode: $0.inode) }
    }
}

/// The walk's own shared source (`LocationWalk`, the file the provider ships) on real host fixtures, built
/// component by component so no whole-path call ever addresses a long location, at short depth and at about
/// 1,500 bytes. **Supporting evidence, never N**: these tests do not show that the built provider includes,
/// invokes and consumes the walk (`WorkspaceProviderTests` does, through the signed bundle). Each check is
/// seen to fail against a mutated walk: `scripts/check-location-walk-mutations.py`.
@Suite struct LocationWalkTests {
    @Test(arguments: ["./", "/"])
    func aMegabyteOfRedundantComponentsResolvesWithinALinearCostBound(_ component: String) throws {
        let path = "/" + String(repeating: component, count: 1_000_000 / component.utf8.count)
        let root = try #require(Self.present(LocationWalk.resolve("/")))
        let clock = ContinuousClock()
        let start = clock.now
        let outcome = LocationWalk.resolve(path)
        let elapsed = start.duration(to: clock.now)
        let location = try #require(Self.present(outcome))
        #expect(location.literal.text == path)
        #expect(location.resolved == root.resolved)
        #expect(location.identity == root.identity)
        #expect(location.expansions.isEmpty)
        #expect(elapsed < .seconds(2), "a roughly 1 MiB path must not shift or copy its remainder per component")
    }

    // MARK: Fixtures

    /// How deep a row is built: directly under the fixture root, or under six 245-byte directories.
    enum Depth: CaseIterable, CustomTestStringConvertible {
        case short, deep
        var testDescription: String { self == .short ? "short" : "about 1,500 bytes" }
        var base: [String] { self == .short ? [] : (0..<6).map { WalkTree.segment($0) } }
    }

    static func resolve(_ tree: WalkTree, _ parts: [String], trailing: String = "") -> LocationResolution {
        LocationWalk.resolve(tree.path(parts) + trailing)
    }

    static func present(_ resolution: LocationResolution) -> ResolvedLocation? {
        if case .present(let location) = resolution { return location }
        return nil
    }

    // MARK: Presence, type and the resolved spelling

    @Test(arguments: Depth.allCases)
    func aFileAndADirectoryArePresentWithTheirTypeAndIdentity(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base + ["dir"])
        try tree.makeFile(depth.base + ["file.txt"])
        let file = try #require(Self.present(Self.resolve(tree, depth.base + ["file.txt"])))
        #expect(file.type == .regularFile)
        #expect(file.identity == tree.identity(depth.base + ["file.txt"]))
        #expect(file.literal.text == tree.path(depth.base + ["file.txt"]))
        #expect(file.resolved == file.literal && file.expansions.isEmpty)
        let directory = try #require(Self.present(Self.resolve(tree, depth.base + ["dir"])))
        #expect(directory.type == .directory)
        #expect(directory.identity == tree.identity(depth.base + ["dir"]))
        // A trailing slash demands a directory, and is part of the literal spelling.
        let slashed = try #require(Self.present(Self.resolve(tree, depth.base + ["dir"], trailing: "/")))
        #expect(slashed.identity == directory.identity)
        #expect(slashed.literal.text == tree.path(depth.base + ["dir"]) + "/")
        #expect(slashed.resolved.text == tree.path(depth.base + ["dir"]), "the resolved spelling has no trailing slash")
    }

    @Test(arguments: Depth.allCases)
    func aMissingNameADanglingLinkAndANameBelowAFileAreAbsent(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeFile(depth.base + ["file.txt"])
        try tree.makeLink("no-such-target", at: depth.base + ["dangling"])
        #expect(Self.resolve(tree, depth.base + ["missing"]) == .absent(.missing(component: "missing")))
        #expect(Self.resolve(tree, depth.base + ["dangling"]) == .absent(.missing(component: "no-such-target")))
        #expect(
            Self.resolve(tree, depth.base + ["file.txt", "below"]) == .absent(.notDirectory(component: "file.txt")))
        #expect(
            Self.resolve(tree, depth.base + ["file.txt"], trailing: "/") == .absent(.notDirectory(component: "file.txt")),
            "a trailing slash after a file demands a directory")
        #expect(
            Self.resolve(tree, depth.base + ["file.txt"], trailing: "/.") == .absent(.notDirectory(component: "file.txt")))
    }

    @Test(arguments: Depth.allCases)
    func linksAreExpandedFromTheirOwnTextAndTheFinalLinkIsFollowed(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base + ["real", "inner"])
        try tree.makeFile(depth.base + ["real", "inner", "f"])
        try tree.makeLink("real/inner", at: depth.base + ["relative"])
        // A link's text is at most 1,023 bytes, so an absolute link at depth points up the tree.
        let shallow = Array(depth.base.prefix(3)) + ["shallow"]
        try tree.makeDirectories(shallow + ["inner"])
        try tree.makeFile(shallow + ["inner", "f"])
        try tree.makeLink(tree.path(shallow), at: depth.base + ["absolute"])
        try tree.makeLink("real/inner/f", at: depth.base + ["to-file"])
        let relative = try #require(Self.present(Self.resolve(tree, depth.base + ["relative", "f"])))
        #expect(relative.resolved.text == tree.path(depth.base + ["real", "inner", "f"]))
        #expect(relative.expansions.map(\.text) == ["real/inner/f"], "the link's text, then what remained after it")
        #expect(relative.identity == tree.identity(depth.base + ["real", "inner", "f"]))
        let absolute = try #require(Self.present(Self.resolve(tree, depth.base + ["absolute", "inner", "f"])))
        #expect(absolute.resolved.text == tree.path(shallow + ["inner", "f"]))
        #expect(absolute.expansions.map(\.text) == [tree.path(shallow) + "/inner/f"])
        let followed = try #require(Self.present(Self.resolve(tree, depth.base + ["to-file"])))
        #expect(followed.type == .regularFile, "the final link is followed: the object is the file")
        #expect(followed.resolved.text == tree.path(depth.base + ["real", "inner", "f"]))
        #expect(followed.literal.text == tree.path(depth.base + ["to-file"]), "the literal spelling is never rewritten")
    }

    @Test(arguments: Depth.allCases)
    func dotIsSkippedAndDotDotIsPhysical(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base + ["real", "inner"])
        try tree.makeDirectories(depth.base + ["elsewhere"])
        try tree.makeFile(depth.base + ["real", "sibling"])
        try tree.makeFile(depth.base + ["elsewhere", "sibling"])
        try tree.makeLink("../real/inner", at: depth.base + ["elsewhere", "jump"])
        let dot = try #require(Self.present(Self.resolve(tree, depth.base + ["real", ".", "sibling"])))
        #expect(dot.resolved.text == tree.path(depth.base + ["real", "sibling"]))
        // `jump/..` is the physical parent of `real/inner`, which is `real`, and not `elsewhere`.
        let physical = try #require(Self.present(Self.resolve(tree, depth.base + ["elsewhere", "jump", "..", "sibling"])))
        #expect(physical.resolved.text == tree.path(depth.base + ["real", "sibling"]))
        #expect(physical.identity == tree.identity(depth.base + ["real", "sibling"]))
        let final = try #require(Self.present(Self.resolve(tree, depth.base + ["elsewhere", "jump", ".."])))
        #expect(final.type == .directory)
        #expect(final.resolved.text == tree.path(depth.base + ["real"]))
        let trailingDot = try #require(Self.present(Self.resolve(tree, depth.base + ["real"], trailing: "/.")))
        #expect(trailingDot.resolved.text == tree.path(depth.base + ["real"]))
        let slashes = try #require(Self.present(Self.resolve(tree, depth.base + ["real"], trailing: "///")))
        #expect(slashes.resolved.text == tree.path(depth.base + ["real"]))
    }

    @Test func theFilesystemRootAndItsSpellings() throws {
        var root = stat()
        try #require(lstat("/", &root) == 0)
        let identity = ObjectIdentity(device: root.st_dev, inode: UInt64(root.st_ino))
        for spelling in ["/", "//", "/.", "/..", "/./..", "/../.."] {
            let location = try #require(Self.present(LocationWalk.resolve(spelling)), Comment(rawValue: spelling))
            #expect(location.identity == identity, Comment(rawValue: spelling))
            #expect(location.type == .directory)
            #expect(location.resolved.text == "/")
            #expect(location.literal.text == spelling)
        }
        // `..` is physical: `/var` is a link into `/private`, so `/var/..` is `/private`.
        let up = try #require(Self.present(LocationWalk.resolve("/var/..")))
        #expect(up.resolved.text == "/private")
        #expect(up.identity != identity)
    }

    // MARK: Cycles, the link budget and the states that recur

    @Test(arguments: Depth.allCases)
    func aLinkChainOfThirtyOneOrThirtyTwoResolvesAndThirtyThreeIsTheBudget(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeFile(depth.base + ["target"])
        for length in [31, 32, 33] {
            try tree.makeLink("target", at: depth.base + ["chain\(length)-1"])
            for index in 2...length {
                try tree.makeLink("chain\(length)-\(index - 1)", at: depth.base + ["chain\(length)-\(index)"])
            }
            let chain = Self.resolve(tree, depth.base + ["chain\(length)-\(length)"])
            if length <= 32 {
                let location = try #require(Self.present(chain), Comment(rawValue: "\(length) links"))
                #expect(location.expansions.count == length)
                #expect(location.resolved.text == tree.path(depth.base + ["target"]))
            } else {
                guard case .failed(let component, let cause) = chain else {
                    Issue.record("33 links is the budget, not \(chain)")
                    continue
                }
                #expect(component == "chain33-1" || component.hasPrefix("chain33-"))
                #expect(cause.contains("32"), "the cause names the budget: \(cause)")
            }
        }
    }

    @Test(arguments: Depth.allCases)
    func aTwoLinkCycleAndASelfLinkAreEstablishedCyclesAndNotTheBudget(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeLink("loop-b", at: depth.base + ["loop-a"])
        try tree.makeLink("loop-a", at: depth.base + ["loop-b"])
        try tree.makeLink("self", at: depth.base + ["self"])
        for name in ["loop-a", "loop-b", "self"] {
            guard case .absent(.cycle) = Self.resolve(tree, depth.base + [name]) else {
                Issue.record("\(name) is a cycle: \(Self.resolve(tree, depth.base + [name]))")
                continue
            }
        }
        // A cycle through a directory component is a cycle as well.
        guard case .absent(.cycle) = Self.resolve(tree, depth.base + ["loop-a", "below"]) else {
            Issue.record("a cycle below a loop")
            return
        }
    }

    /// A link whose text ends in a slash gains a slash on each lap, which the kernel reads as the same path.
    @Test(arguments: Depth.allCases)
    func aCycleWhoseLinkTextEndsInASlashIsAnEstablishedCycleAndNotTheBudget(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeLink("a/", at: depth.base + ["a"])
        try tree.makeLink("y/", at: depth.base + ["x"])
        try tree.makeLink("x/", at: depth.base + ["y"])
        for name in ["a", "x", "y"] {
            guard case .absent(.cycle) = Self.resolve(tree, depth.base + [name]) else {
                Issue.record("\(name) is a cycle: \(Self.resolve(tree, depth.base + [name]))")
                continue
            }
        }
    }

    @Test(arguments: Depth.allCases)
    func aDotLinkRepeatedOnAFinitePathResolvesBecauseItsPendingSuffixShrinks(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeFile(depth.base + ["f"])
        try tree.makeLink(".", at: depth.base + ["dot"])
        let location = try #require(Self.present(Self.resolve(tree, depth.base + ["dot", "dot", "dot", "f"])))
        #expect(location.resolved.text == tree.path(depth.base + ["f"]))
        #expect(location.expansions.count == 3)
    }

    @Test(arguments: Depth.allCases)
    func aSelfExtendingLinkIsTheBudgetBecauseItNeverRepeatsAState(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeLink("a/x", at: depth.base + ["a"])
        guard case .failed(_, let cause) = Self.resolve(tree, depth.base + ["a"]) else {
            Issue.record("a -> a/x is the budget: \(Self.resolve(tree, depth.base + ["a"]))")
            return
        }
        #expect(cause.contains("32"))
    }

    /// One symlink inode with entries in two directories, whose same text and same pending suffix recur on a
    /// finite path: not a cycle, because the containing directory differs. Needs a filesystem that hard-links
    /// a symlink; one that does not admits no such path, and the row is then recorded as not built.
    @Test(arguments: Depth.allCases)
    func oneLinkInodeInTwoDirectoriesIsNotACycleWhenTheContainingDirectoryDiffers(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base + ["dA", "sub"])
        try tree.makeDirectories(depth.base + ["dB", "sub"])
        try tree.makeLink("sub", at: depth.base + ["dA", "L"])
        guard (try? tree.hardLink(depth.base + ["dA", "L"], to: depth.base + ["dB", "L"])) != nil else {
            print("NOT BUILT: this filesystem does not hard-link a symbolic link (\(depth.testDescription))")
            return
        }
        try tree.makeLink("../../dB/L/z", at: depth.base + ["dA", "sub", "z"])
        try tree.makeFile(depth.base + ["dB", "sub", "z"])
        // dA/L/z -> dA/sub/z -> dB/L/z -> dB/sub/z: the link L and its pending suffix "/z" recur.
        let location = try #require(Self.present(Self.resolve(tree, depth.base + ["dA", "L", "z"])))
        #expect(location.resolved.text == tree.path(depth.base + ["dB", "sub", "z"]))
        #expect(location.expansions.count == 3)
        let first = tree.identity(depth.base + ["dA", "L"], followLink: false)
        let second = tree.identity(depth.base + ["dB", "L"], followLink: false)
        #expect(first == second, "one link inode")
    }

    // MARK: Search permission, names and the name limit

    @Test(arguments: Depth.allCases)
    func aFinalDirectoryWithoutSearchPermissionIsPresentAndNeverOpened(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base + ["closed"])
        try tree.makeFile(depth.base + ["closed", "inside"])
        try tree.chmod(depth.base + ["closed"], 0o600)
        let present = try #require(Self.present(Self.resolve(tree, depth.base + ["closed"])), "mode 0600 final directory")
        #expect(present.type == .directory)
        #expect(Self.present(Self.resolve(tree, depth.base + ["closed"], trailing: "/")) != nil)
        // Lookup inside it, or `.` of it, needs the search permission it lacks: a denial, never absence.
        for parts in [depth.base + ["closed", "inside"], depth.base + ["closed", "missing"]] {
            guard case .failed(let component, let cause) = Self.resolve(tree, parts) else {
                Issue.record("below a closed directory: \(Self.resolve(tree, parts))")
                continue
            }
            #expect(component == "closed")
            #expect(cause.contains("denied"), "names the cause: \(cause)")
        }
        guard case .failed = Self.resolve(tree, depth.base + ["closed"], trailing: "/.") else {
            Issue.record("`closed/.` needs search permission of closed")
            return
        }
    }

    @Test(arguments: Depth.allCases)
    func anAsciiNameLongerThanTheDirectorysLimitIsImpossibleBesideExtantLongMultibyteNames(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        let impossible = String(repeating: "n", count: 300)
        #expect(Self.resolve(tree, depth.base + [impossible]) == .absent(.impossibleComponent(component: impossible)))
        #expect(
            Self.resolve(tree, depth.base + [impossible, "below"]) == .absent(.impossibleComponent(component: impossible)),
            "also as a directory component")
        // Names over 255 UTF-8 bytes that the filesystem admits are extant: lookup success is presence, and
        // nothing judges the name beforehand.
        let long = String(repeating: "\u{65E5}", count: 100)  // 300 UTF-8 bytes, 100 characters
        let combining = "cafe\u{301}-" + String(repeating: "e\u{301}", count: 20)
        var built: [String] = []
        for name in [long, combining, "\u{1F600}-emoji"] {
            if (try? tree.makeFile(depth.base + [name])) != nil { built.append(name) }
        }
        #expect(built.contains(combining), "a combining-character name is admitted")
        for name in built {
            let location = try #require(Self.present(Self.resolve(tree, depth.base + [name])), Comment(rawValue: name))
            #expect(location.type == .regularFile)
            #expect(location.resolved.bytes == Array(tree.path(depth.base + [name]).utf8), "never normalized or rewritten")
        }
        if !built.contains(long) {
            print("NOT BUILT: this filesystem does not admit a name of 300 UTF-8 bytes (\(depth.testDescription))")
        }
        // A non-ASCII name over the limit is the filesystem's unit to judge, never proof of absence.
        let tooLongMultibyte = String(repeating: "\u{E9}", count: 400)
        guard case .failed(let component, _) = Self.resolve(tree, depth.base + [tooLongMultibyte]) else {
            Issue.record("a non-ASCII name the lookup refuses as too long is a failure: \(Self.resolve(tree, depth.base + [tooLongMultibyte]))")
            return
        }
        #expect(component == tooLongMultibyte)
    }

    // MARK: The limit

    /// A directory chain of 245-byte segments and a final file whose full path is exactly `length` bytes.
    static func file(of length: Int, in tree: WalkTree) throws -> [String] {
        var segments = (length - tree.root.utf8.count - 2) / 246
        while true {
            let remainder = length - tree.root.utf8.count - segments * 246 - 1
            if (1...255).contains(remainder) {
                let parts = (0..<segments).map { WalkTree.segment($0) } + [String(repeating: "f", count: remainder)]
                try tree.makeDirectories(Array(parts.dropLast()))
                try tree.makeFile(parts)
                return parts
            }
            segments -= 1
        }
    }

    @Test(arguments: [1022, 1023, 1024, 1025])
    func theLiteralSpellingIsHandedOverAtOneThousandTwentyThreeBytesAndRefusedAtOneThousandTwentyFour(_ length: Int) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try Self.file(of: length, in: tree)
        #expect(tree.path(parts).utf8.count == length, "the fixture is the length it claims")
        let location = try #require(Self.present(Self.resolve(tree, parts)), "a path of any length resolves")
        #expect(location.literal.byteCount == length, "bytes, never the NUL")
        let over = HandOffLimit.firstOverLimit(location)
        if length <= 1023 {
            #expect(over == nil)
            #expect(HandOffLimit.refusal(of: location, forAction: "revealed") == nil)
        } else {
            #expect(over?.kind == .literal && over?.byteCount == length)
            let guidance = try #require(HandOffLimit.refusal(of: location, forAction: "revealed"))
            #expect(guidance.contains("application hand-off"))
            #expect(guidance.contains("path as written") && guidance.contains("\(length) bytes"))
            #expect(guidance.contains("No request was made"))
        }
    }

    @Test func aShortLiteralWithALongExpansionIsRefusedAtTheExpandedSpelling() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        // The link's own text is an absolute path (a link's text is at most 1,023 bytes), and the name after
        // it takes the remaining path over the limit.
        let directory = (0..<3).map { WalkTree.segment($0) }
        let name = String(repeating: "f", count: 250)
        try tree.makeDirectories(directory)
        try tree.makeFile(directory + [name])
        try tree.makeLink(tree.path(directory), at: ["jump"])
        let target = directory + [name]
        let location = try #require(Self.present(Self.resolve(tree, ["jump", target.last ?? ""])))
        #expect(location.literal.byteCount < 1024, "the literal is within the limit")
        let over = try #require(HandOffLimit.firstOverLimit(location))
        #expect(over.kind == .expanded(number: 1))
        #expect(over.byteCount == tree.path(directory).utf8.count + 1 + (target.last ?? "").utf8.count)
        #expect(over.byteCount >= 1024)
        #expect(HandOffLimit.refusal(of: location, forAction: "revealed")?.contains("symbolic link 1") == true)
    }

    @Test func aShortLiteralAndShortExpansionsWithALongResolvedSpellingAreRefusedAtTheResolvedSpelling() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        // A -> s0/s1/s2, and inside it B -> t0/t1/t2: each remainder is about 740 bytes, the physical path 1,500.
        let first = (0..<3).map { WalkTree.segment($0) }
        let second = (3..<6).map { WalkTree.segment($0) }
        try tree.makeDirectories(first)
        try tree.makeLink(first.joined(separator: "/"), at: ["A"])
        try tree.makeDirectories(first + second)
        try tree.makeLink(second.joined(separator: "/"), at: first + ["B"])
        try tree.makeFile(first + second + ["f"])
        let location = try #require(Self.present(Self.resolve(tree, ["A", "B", "f"])))
        #expect(location.expansions.count == 2)
        #expect(location.literal.byteCount < 1024 && location.expansions.allSatisfy { $0.byteCount < 1024 })
        let over = try #require(HandOffLimit.firstOverLimit(location))
        #expect(over.kind == .resolved)
        #expect(over.byteCount == tree.path(first + second + ["f"]).utf8.count)
    }

    // MARK: What the walk asks of the filesystem

    @Test(arguments: Depth.allCases)
    func theWalkHoldsAtMostTwoHandlesClosesThemAllAndOpensOnlyDirectories(_ depth: Depth) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base + ["real", "inner"])
        try tree.makeFile(depth.base + ["real", "inner", "f"])
        try tree.makeLink("../real/inner", at: depth.base + ["real", "link"])
        try tree.makeDirectories(["shallow", "inner"])
        try tree.makeFile(["shallow", "inner", "f"])
        try tree.makeLink(tree.path(["shallow"]), at: depth.base + ["absolute"])
        for parts in [
            depth.base + ["real", "link", "f"], depth.base + ["absolute", "inner", "f"], depth.base + ["real", "inner", "missing"],
            depth.base + ["real", "link", "..", "inner", "f"], depth.base + ["real", "closed-by-path", "x"],
        ] {
            let system = RecordingSystem()
            _ = LocationWalk.resolve(Array(tree.path(parts).utf8), using: system)
            #expect(system.maximumOpen <= 2, "at most two handles: the current directory and the next")
            #expect(system.open.isEmpty, "every handle is closed before the walk returns")
            #expect(system.calls.allSatisfy { $0.kind != .listing }, "nothing is listed")
        }
        // A file is never opened: a name `status` reported as anything but a directory is not opened.
        let system = RecordingSystem()
        _ = LocationWalk.resolve(Array(tree.path(depth.base + ["real", "inner", "f"]).utf8), using: system)
        #expect(system.opened.last != "f", "the final component is examined, never opened")
        #expect(!system.opened.contains("f"))
    }

    @Test func aFailedStepIsTheOutcomeWithNoRetryAndNoReopen() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(["closed"])
        try tree.chmod(["closed"], 0o600)
        let system = RecordingSystem()
        guard case .failed = LocationWalk.resolve(Array(tree.path(["closed", "x"]).utf8), using: system) else {
            Issue.record("a denial is a failure")
            return
        }
        #expect(system.opened.filter { $0 == "closed" }.count == 1, "the denied open is not retried")
        #expect(system.open.isEmpty)
    }

    // MARK: What no fixture can supply

    @Test func aNameLimitTheFilesystemWillNotStateIsAFailureAndNeverAbsence() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let system = RecordingSystem()
        system.nameLimitAnswer = .some(nil)
        let impossible = String(repeating: "n", count: 300)
        guard case .failed(let component, _) = LocationWalk.resolve(Array(tree.path([impossible]).utf8), using: system) else {
            Issue.record("fpathconf -1 leaves the name unjudged")
            return
        }
        #expect(component == impossible)
    }

    @Test func anAsciiNameTooLongWithinTheReportedLimitIsAFailureAndNeverAbsence() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let system = RecordingSystem()
        system.nameLimitAnswer = .some(1000)  // the filesystem claims a name this long is fine, and refuses it anyway
        let name = String(repeating: "n", count: 300)
        guard case .failed(let component, let cause) = LocationWalk.resolve(Array(tree.path([name]).utf8), using: system) else {
            Issue.record("a refusal the limit cannot explain is not absence")
            return
        }
        #expect(component == name)
        #expect(cause.contains("too long"))
    }

    @Test func oneLinkReadTwiceWithDifferentTextIsAChangedObservationAndFailed() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(["dir"])
        try tree.makeLink("dir/../again", at: ["again"])  // expands to itself once; the second read differs
        let system = RecordingSystem()
        var reads = 0
        system.linkTextOverride = { _ in
            reads += 1
            return .success(Array((reads == 1 ? "dir/../again" : "elsewhere").utf8))
        }
        guard case .failed(_, let cause) = LocationWalk.resolve(Array(tree.path(["again"]).utf8), using: system) else {
            Issue.record("a link whose text changed is a failure")
            return
        }
        #expect(cause.contains("changed"))
    }

    @Test func aStepThatCannotReadItsOwnDirectoryIsAFailureNamingTheCause() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeLink("loop", at: ["loop"])
        let system = RecordingSystem()
        system.directoryStatusFailure = WalkErrno(code: EIO)
        guard case .failed(_, let cause) = LocationWalk.resolve(Array(tree.path(["loop"]).utf8), using: system) else {
            Issue.record("a link whose containing directory cannot be read is a failure")
            return
        }
        #expect(cause.contains("Input/output error"))
    }
}

// MARK: - Support

/// The real filesystem, observed: every call and every handle, with the few overrides a test needs for what no
/// fixture can supply.
final class RecordingSystem: WalkSystem, @unchecked Sendable {
    enum Kind { case root, directory, status, directoryStatus, link, limit, listing }
    struct Call { let kind: Kind; let name: String }

    private let lock = NSLock()
    private let base = DarwinWalkSystem()
    private var log: [Call] = []
    private var handles: Set<Int32> = []
    private var mostOpen = 0
    /// `.some(nil)` is `fpathconf` returning -1; `.some(n)` a limit of n; nil is the real answer.
    var nameLimitAnswer: Int?? = nil
    var linkTextOverride: (([UInt8]) -> Result<[UInt8], WalkErrno>)?
    var directoryStatusFailure: WalkErrno?

    var calls: [Call] { lock.withLock { log } }
    var open: Set<Int32> { lock.withLock { handles } }
    var maximumOpen: Int { lock.withLock { mostOpen } }
    /// The names `openDirectory` was asked for, in order.
    var opened: [String] { lock.withLock { log.filter { $0.kind == .directory }.map(\.name) } }

    private func record(_ kind: Kind, _ name: [UInt8] = []) {
        lock.withLock { log.append(Call(kind: kind, name: String(decoding: name, as: UTF8.self))) }
    }

    private func track(_ result: Result<Int32, WalkErrno>) -> Result<Int32, WalkErrno> {
        if case .success(let handle) = result {
            lock.withLock {
                handles.insert(handle)
                mostOpen = max(mostOpen, handles.count)
            }
        }
        return result
    }

    func openRoot() -> Result<Int32, WalkErrno> {
        record(.root)
        return track(base.openRoot())
    }

    func openDirectory(in directory: Int32, name: [UInt8]) -> Result<Int32, WalkErrno> {
        record(.directory, name)
        return track(base.openDirectory(in: directory, name: name))
    }

    func status(in directory: Int32, name: [UInt8]) -> Result<WalkStatus, WalkErrno> {
        record(.status, name)
        return base.status(in: directory, name: name)
    }

    func status(of directory: Int32) -> Result<WalkStatus, WalkErrno> {
        record(.directoryStatus)
        if let failure = directoryStatusFailure { return .failure(failure) }
        return base.status(of: directory)
    }

    func linkText(in directory: Int32, name: [UInt8]) -> Result<[UInt8], WalkErrno> {
        record(.link, name)
        if let override = linkTextOverride { return override(name) }
        return base.linkText(in: directory, name: name)
    }

    func nameLimit(of directory: Int32) -> Int? {
        record(.limit)
        if let override = nameLimitAnswer { return override }
        return base.nameLimit(of: directory)
    }

    func close(_ handle: Int32) {
        _ = lock.withLock { handles.remove(handle) }
        base.close(handle)
    }
}
