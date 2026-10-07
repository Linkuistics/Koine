import Foundation
import Testing
import WorkspaceTestSupport

/// N for the long-location resolution (docs/specs/workspace-launch-and-open.md "Resolving an action location",
/// "Application hand-off limit"): the independently built, signed workspace bundle, loaded by the real loader
/// and asked over loopback HTTP to reveal a location on this host's filesystem, at short depth and at about
/// 1,500 bytes. Every fixture is built component by component, so no whole-path call ever addressed a long
/// location in the test either.
///
/// **Nothing is revealed on this host.** Only rows whose answer is decided before submission are sent: an
/// absence, a failure naming its component and cause, or a present location whose spelling reaches 1,024
/// bytes. A refusal follows a complete resolution, so it shows the walk reached its object (a chain that
/// resolved, a final directory without search permission, a multibyte or combining name) and names the
/// spelling and its byte count. A present location within the limit would be revealed in this host's
/// Finder, so none is sent: those outcomes, and the reveal root decision, are observed at V by their effect
/// (`target-locations-vm`). `task test` builds the bundle. The walk's own source is also tested directly in
/// `LocationWalkTests`, which supports this suite and closes nothing here.
@Suite struct WorkspaceLongLocationTests {
    enum Depth: CaseIterable, CustomTestStringConvertible {
        case short, deep
        var testDescription: String { self == .short ? "short" : "about 1,500 bytes" }
        /// Six 245-byte directories under the fixture root: every location below is over 1,500 bytes.
        var base: [String] { self == .short ? [] : (0..<6).map { WalkTree.segment($0) } }
    }

    /// What the bundle answered for one reveal.
    enum Answer: Equatable, CustomStringConvertible {
        case notFound, failed(String), refused(String), available, unexpected(String)
        var description: String {
            switch self {
            case .notFound: "PATH_NOT_FOUND"
            case .failed(let message): "failed: \(message)"
            case .refused(let message): "refused: \(message)"
            case .available: "AVAILABLE"
            case .unexpected(let text): "unexpected: \(text)"
            }
        }
    }

    /// The signed bundle and a credential holding both controls the reveal needs.
    struct Bench {
        let harness: Harness
        let credential: String

        init() async throws {
            harness = try await DesktopProviderTests.harness()
            credential = try await harness.consoleGrant(label: "c", capabilities: WorkspaceProviderTests.controls)
        }

        func reveal(_ path: String) async throws -> Answer {
            let reply = try await harness.post(
                WorkspaceProviderTests.revealPath, variables: ["path": path], authorization: "Bearer \(credential)")
            if let error = reply.errors.first {
                let kind = (error["extensions"] as? [String: Any])?["kind"] as? String
                let message = error["message"] as? String ?? "\(error)"
                guard kind == "failed" else { return .unexpected("\(error)") }
                return message.contains("application hand-off") ? .refused(message) : .failed(message)
            }
            guard let reveal = reply.data?["reveal"] as? [String: Any] else { return .unexpected("\(reply.json)") }
            switch reveal["status"] as? String {
            case "DEPENDENCY_UNAVAILABLE":
                let reason = (reveal["dependency"] as? [String: Any])?["reason"] as? String
                return reason == "PATH_NOT_FOUND" ? .notFound : .unexpected("\(reveal)")
            case "AVAILABLE": return .available
            default: return .unexpected("\(reveal)")
            }
        }

        func stop() async { await harness.stop() }
    }

    /// Whether `message` is a refusal naming `spelling` and exactly `bytes` bytes.
    static func isRefusal(_ answer: Answer, naming spelling: String, bytes: Int) -> Bool {
        guard case .refused(let message) = answer else { return false }
        return message.contains(spelling) && message.contains("\(bytes) bytes") && message.contains("No request was made")
    }

    // MARK: Absent rows

    @Test(arguments: Depth.allCases)
    func everyAbsentRowIsPathNotFoundAndANonexistentLongPathIsNeverAnErrorOfLength(_ depth: Depth) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeFile(depth.base + ["file.txt"])
        try tree.makeLink("no-such-target", at: depth.base + ["dangling"])
        try tree.makeLink("loop-b", at: depth.base + ["loop-a"])
        try tree.makeLink("loop-a", at: depth.base + ["loop-b"])
        try tree.makeLink("self", at: depth.base + ["self"])
        try tree.makeLink("slash/", at: depth.base + ["slash"])
        let impossible = String(repeating: "n", count: 300)
        let bench = try await Bench()
        var rows: [(String, String)] = [
            ("a missing name", tree.path(depth.base + ["missing"])),
            ("a dangling link", tree.path(depth.base + ["dangling"])),
            ("a name below a file", tree.path(depth.base + ["file.txt", "below"])),
            ("a file with a trailing slash", tree.path(depth.base + ["file.txt"]) + "/"),
            ("a file with a trailing dot", tree.path(depth.base + ["file.txt"]) + "/."),
            ("an established two-link cycle", tree.path(depth.base + ["loop-a"])),
            ("a cycle through a directory component", tree.path(depth.base + ["loop-a", "below"])),
            ("a link to itself", tree.path(depth.base + ["self"])),
            ("a cycle whose link text ends in a slash", tree.path(depth.base + ["slash"])),
            ("an impossible 300-byte ASCII component", tree.path(depth.base + [impossible])),
            ("an impossible component as a directory", tree.path(depth.base + [impossible, "below"])),
        ]
        if depth == .deep {
            // Absence of a location whose spelling is at, below and above the limit is absence, not length.
            let parts = (0..<3).map { WalkTree.segment($0) }
            try tree.makeDirectories(parts)
            for length in [1022, 1023, 1024, 1025] {
                let name = String(repeating: "m", count: length - tree.path(parts).utf8.count - 1)
                rows.append(("a missing name at \(length) bytes", tree.path(parts + [name])))
                #expect(tree.path(parts + [name]).utf8.count == length)
            }
        }
        for (what, path) in rows {
            let answer = try await bench.reveal(path)
            #expect(answer == .notFound, Comment(rawValue: "\(what) at \(depth.testDescription): \(answer)"))
        }
        await bench.stop()
    }

    // MARK: Failed rows

    @Test(arguments: Depth.allCases)
    func theLinkBudgetAndEveryOtherUnestablishedStepAreFailedNamingTheComponentAndTheCause(_ depth: Depth) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base + ["closed"])
        try tree.makeFile(depth.base + ["closed", "inside"])
        try tree.makeFile(depth.base + ["target"])
        try tree.makeLink("target", at: depth.base + ["chain-1"])
        for index in 2...33 { try tree.makeLink("chain-\(index - 1)", at: depth.base + ["chain-\(index)"]) }
        try tree.makeLink("a/x", at: depth.base + ["a"])
        try tree.chmod(depth.base + ["closed"], 0o600)
        let nonAscii = String(repeating: "\u{E9}", count: 400)
        let bench = try await Bench()
        let rows: [(String, String, String, String)] = [
            ("a 33-link chain, the budget", tree.path(depth.base + ["chain-33"]), "chain-1", "32 symbolic links"),
            ("a self-extending link, the budget", tree.path(depth.base + ["a"]), "\"a\"", "32 symbolic links"),
            ("a directory without search permission", tree.path(depth.base + ["closed", "inside"]), "closed", "denied"),
            ("a non-ASCII name the lookup refuses as too long", tree.path(depth.base + [nonAscii]), nonAscii, "too long"),
        ]
        for (what, path, component, cause) in rows {
            let answer = try await bench.reveal(path)
            guard case .failed(let message) = answer else {
                Issue.record("\(what) at \(depth.testDescription) is `failed`, never a dependency: \(answer)")
                continue
            }
            #expect(message.contains(component), Comment(rawValue: "\(what) names its component: \(message)"))
            #expect(message.contains(cause), Comment(rawValue: "\(what) names its cause: \(message)"))
        }
        // A 32-link chain is not the budget: it resolves, which a refusal after resolution shows (below).
        await bench.stop()
    }

    // MARK: Present rows, shown by the refusal that follows resolution

    /// Builds a file whose full path is exactly `length` bytes under 245-byte directories.
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

    @Test(arguments: [1024, 1025, 1500])
    func anExtantFileOfOneThousandTwentyFourBytesOrMoreIsRefusedAtItsLiteralSpelling(_ length: Int) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try Self.file(of: length, in: tree)
        let bench = try await Bench()
        let answer = try await bench.reveal(tree.path(parts))
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: length), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func aDirectoryOverTheLimitIsRefusedWithAndWithoutATrailingSlash() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<5).map { WalkTree.segment($0) }
        try tree.makeDirectories(directory)
        let bench = try await Bench()
        let path = tree.path(directory)
        for (spelling, bytes) in [(path, path.utf8.count), (path + "/", path.utf8.count + 1)] {
            let answer = try await bench.reveal(spelling)
            #expect(Self.isRefusal(answer, naming: "the path as written", bytes: bytes), Comment(rawValue: "\(answer)"))
        }
        await bench.stop()
    }

    @Test func aShortLiteralWithALongExpansionIsRefusedAtTheExpandedSpelling() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<3).map { WalkTree.segment($0) }
        let name = String(repeating: "f", count: 250)
        try tree.makeDirectories(directory)
        try tree.makeFile(directory + [name])
        try tree.makeLink(tree.path(directory), at: ["jump"])
        let bench = try await Bench()
        let path = tree.path(["jump", name])
        #expect(path.utf8.count < 1024, "the literal is short")
        let expanded = tree.path(directory).utf8.count + 1 + name.utf8.count
        let answer = try await bench.reveal(path)
        #expect(
            Self.isRefusal(answer, naming: "the remaining path after symbolic link 1", bytes: expanded),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func aShortLiteralAndShortExpansionsWithALongResolvedSpellingAreRefusedAtTheResolvedSpelling() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let first = (0..<3).map { WalkTree.segment($0) }
        let second = (3..<6).map { WalkTree.segment($0) }
        try tree.makeDirectories(first + second)
        try tree.makeLink(first.joined(separator: "/"), at: ["A"])
        try tree.makeLink(second.joined(separator: "/"), at: first + ["B"])
        try tree.makeFile(first + second + ["f"])
        let bench = try await Bench()
        let answer = try await bench.reveal(tree.path(["A", "B", "f"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(first + second + ["f"]).utf8.count),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// A short literal whose chain of links ends at a deep target: the resolved spelling is what is refused, so
    /// the refusal proves every link of the chain resolved, and a 33-link chain is the budget.
    @Test(arguments: [1, 31, 32])
    func aResolvingChainOfLinksIsRefusedAtTheResolvedSpellingNeverAsTheBudget(_ links: Int) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<4).map { WalkTree.segment($0) }
        try tree.makeDirectories(directory)
        try tree.makeFile(directory + ["target"])
        try tree.makeLink(directory.joined(separator: "/") + "/target", at: ["chain-1"])
        if links > 1 { for index in 2...links { try tree.makeLink("chain-\(index - 1)", at: ["chain-\(index)"]) } }
        let bench = try await Bench()
        let answer = try await bench.reveal(tree.path(["chain-\(links)"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(directory + ["target"]).utf8.count),
            Comment(rawValue: "\(links) links: \(answer)"))
        await bench.stop()
    }

    @Test(arguments: [31, 32])
    func aResolvingChainAtAboutFifteenHundredBytesIsRefusedAtItsLiteralSpelling(_ links: Int) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base)
        try tree.makeFile(base + ["target"])
        try tree.makeLink("target", at: base + ["chain-1"])
        for index in 2...links { try tree.makeLink("chain-\(index - 1)", at: base + ["chain-\(index)"]) }
        let bench = try await Bench()
        let path = tree.path(base + ["chain-\(links)"])
        let answer = try await bench.reveal(path)
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// The retained finite repeated dot-link: the same link expands three times, each with a shorter pending suffix,
    /// so no state repeats. Resolved at depth, so the refusal that follows proves it was not read as a cycle.
    @Test func aDotLinkRepeatedOnAFinitePathIsPresentAtDepth() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base)
        try tree.makeFile(base + ["f"])
        try tree.makeLink(".", at: base + ["dot"])
        let bench = try await Bench()
        let path = tree.path(base + ["dot", "dot", "dot", "f"])
        let answer = try await bench.reveal(path)
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// `..` is the physical parent of what a link led to. The literal is short and the expansion short; the resolved
    /// spelling is refused, so its byte count shows the walk dropped exactly the directory `..` leaves.
    @Test func aDotDotAfterALinkIsPhysicalAndShowsInTheResolvedSpelling() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let deep = (0..<4).map { WalkTree.segment($0) }
        try tree.makeDirectories(deep + ["child"])
        try tree.makeFile(deep + ["f"])
        try tree.makeLink(deep.joined(separator: "/"), at: ["jump"])
        let bench = try await Bench()
        let answer = try await bench.reveal(tree.path(["jump", "child", "..", "f"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(deep + ["f"]).utf8.count),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// An absolute link restarts at the root, whatever directory held it: the resolved spelling is the target's
    /// own, with nothing of the directory that contained the link.
    @Test func anAbsoluteLinkRestartsAtTheRootAndShowsInTheResolvedSpelling() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let first = (0..<3).map { WalkTree.segment($0) }
        let second = (3..<6).map { WalkTree.segment($0) }
        try tree.makeDirectories(["holder"])
        try tree.makeDirectories(first + second)
        try tree.makeLink(tree.path(first), at: ["holder", "abs"])
        try tree.makeLink(second.joined(separator: "/"), at: first + ["B"])
        try tree.makeFile(first + second + ["f"])
        let bench = try await Bench()
        let answer = try await bench.reveal(tree.path(["holder", "abs", "B", "f"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(first + second + ["f"]).utf8.count),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func aFinalDirectoryWithoutSearchPermissionIsPresentAndRefusedAtDepth() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base + ["closed"])
        try tree.chmod(base + ["closed"], 0o600)
        let bench = try await Bench()
        let path = tree.path(base + ["closed"])
        // Present and never opened: the refusal follows. (Inside it, the walk is denied: the failed row above.)
        let answer = try await bench.reveal(path)
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func oneLinkInodeWithEntriesInTwoDirectoriesIsPresentAtDepth() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base + ["dA", "sub"])
        try tree.makeDirectories(base + ["dB", "sub"])
        try tree.makeLink("sub", at: base + ["dA", "L"])
        guard (try? tree.hardLink(base + ["dA", "L"], to: base + ["dB", "L"])) != nil else {
            print("NOT BUILT: this filesystem does not hard-link a symbolic link")
            return
        }
        try tree.makeLink("../../dB/L/z", at: base + ["dA", "sub", "z"])
        try tree.makeFile(base + ["dB", "sub", "z"])
        let bench = try await Bench()
        let path = tree.path(base + ["dA", "L", "z"])
        let answer = try await bench.reveal(path)
        // The link `L` and its pending suffix recur on this finite path; the refusal follows a complete resolution.
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func extantMultibyteAndCombiningNamesAreResolvedAtDepth() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base)
        let names = [
            String(repeating: "\u{65E5}", count: 100), "cafe\u{301}-" + String(repeating: "e\u{301}", count: 20),
            "\u{1F600}-emoji",
        ]
        let bench = try await Bench()
        var checked = 0
        for name in names {
            guard (try? tree.makeFile(base + [name])) != nil else {
                print("NOT BUILT: this filesystem does not admit \(name.utf8.count)-byte name")
                continue
            }
            let path = tree.path(base + [name])
            let answer = try await bench.reveal(path)
            #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
            checked += 1
        }
        #expect(checked >= 1)
        await bench.stop()
    }

    // MARK: Existing short outcomes

    @Test func shortAbsentAndRefusedInputOutcomesAreUnchanged() async throws {
        let bench = try await Bench()
        #expect(try await bench.reveal("/definitely/not/here/\(UUID().uuidString)") == .notFound)
        #expect(try await bench.reveal("/private/var/../does-not-exist-\(UUID().uuidString)") == .notFound)
        await bench.stop()
    }
}
