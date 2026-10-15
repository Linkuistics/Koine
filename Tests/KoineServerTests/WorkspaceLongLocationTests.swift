import Foundation
import Testing
import WorkspaceTestSupport

/// N for the long-location resolution (docs/specs/workspace-launch-and-open.md "Resolving an action location",
/// "Application hand-off limit"): the independently built, signed workspace bundle, loaded by the real loader
/// and asked over loopback HTTP to reveal or open a location on this host's filesystem, at short depth and at
/// about 1,500 bytes. Every fixture is built component by component, so no whole-path call ever addressed a
/// long location in the test either. Each row is asked of both operations, which share the target stage.
///
/// **Nothing is revealed or opened on this host.** A reveal is sent only rows whose answer is decided before
/// submission: an absence, a failure naming its component and cause, or a present location whose spelling
/// reaches 1,024 bytes. A refusal follows a complete resolution, so it shows the walk reached its object (a
/// chain that resolved, a final directory without search permission, a multibyte or combining name) and names
/// the spelling and its byte count. A present location within the limit would be revealed in this host's
/// Finder, so none is sent: those outcomes, and the reveal root decision, are observed at V by their effect
/// (`target-locations-vm`). An open is always named to an application nobody has registered, so it can never
/// reach a handler even if a decision were wrong: a present target within the limit that the payload policy
/// lets through then answers `APPLICATION_NOT_INSTALLED`, which shows the walk resolved it and its metadata
/// was read, with nothing opened. `task test` builds the bundle. The walk's own source is also tested directly
/// in `LocationWalkTests`, which supports this suite and closes nothing here.
@Suite struct WorkspaceLongLocationTests {
    enum Depth: CaseIterable, CustomTestStringConvertible {
        case short, deep
        var testDescription: String { self == .short ? "short" : "about 1,500 bytes" }
        /// Six 245-byte directories under the fixture root: every location below is over 1,500 bytes.
        var base: [String] { self == .short ? [] : (0..<6).map { WalkTree.segment($0) } }
    }

    enum Operation: CaseIterable, CustomTestStringConvertible {
        case reveal, open
        var testDescription: String { self == .reveal ? "reveal" : "open" }
    }

    /// What the bundle answered for one action.
    enum Answer: Equatable, CustomStringConvertible {
        /// `settled` is an open's `APPLICATION_NOT_INSTALLED`: the target resolved, within the limit, its metadata
        /// was read and the payload policy let it through, and only then was the unregistered application missing.
        case notFound, settled, failed(String), refused(String), rejected(String), available, unexpected(String)
        var description: String {
            switch self {
            case .notFound: "PATH_NOT_FOUND"
            case .settled: "APPLICATION_NOT_INSTALLED"
            case .failed(let message): "failed: \(message)"
            case .refused(let message): "refused: \(message)"
            case .rejected(let message): "input error: \(message)"
            case .available: "AVAILABLE"
            case .unexpected(let text): "unexpected: \(text)"
            }
        }
    }

    /// The signed bundle and a credential holding both controls the actions need.
    struct Bench {
        /// No application is registered under this identifier, so an open never reaches a handler.
        static let unregistered = "com.example.koine.k175.unregistered"

        let harness: Harness
        let credential: String
        let operation: Operation

        init(_ operation: Operation) async throws {
            self.operation = operation
            harness = try await DesktopProviderTests.harness()
            credential = try await harness.consoleGrant(label: "c", capabilities: WorkspaceProviderTests.controls)
        }

        func ask(_ path: String) async throws -> Answer {
            let field = operation == .reveal ? "reveal" : "open"
            let reply =
                operation == .reveal
                ? try await harness.post(
                    WorkspaceProviderTests.revealPath, variables: ["path": path], authorization: "Bearer \(credential)")
                : try await harness.post(
                    WorkspaceProviderTests.openPath,
                    variables: ["path": path, "application": ["bundleIdentifier": Self.unregistered]],
                    authorization: "Bearer \(credential)")
            if let error = reply.errors.first {
                let kind = (error["extensions"] as? [String: Any])?["kind"] as? String
                let message = error["message"] as? String ?? "\(error)"
                if kind == nil, operation == .open { return .rejected(message) }
                guard kind == "failed" else { return .unexpected("\(error)") }
                return message.contains("application hand-off") ? .refused(message) : .failed(message)
            }
            guard let result = reply.data?[field] as? [String: Any] else { return .unexpected("\(reply.json)") }
            switch result["status"] as? String {
            case "DEPENDENCY_UNAVAILABLE":
                switch (result["dependency"] as? [String: Any])?["reason"] as? String {
                case "PATH_NOT_FOUND": return .notFound
                case "APPLICATION_NOT_INSTALLED" where operation == .open: return .settled
                default: return .unexpected("\(result)")
                }
            case "AVAILABLE": return .available
            default: return .unexpected("\(result)")
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

    @Test(arguments: ["./", "/"], [false, true])
    func aMegabyteOfRedundantComponentsIsResolvedPromptlyByTheSignedProvider(
        _ component: String, _ missing: Bool
    ) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let path = tree.path([]) + "/"
            + String(repeating: component, count: 990_000 / component.utf8.count)
            + (missing ? "missing" : "")
        // A present target is over the hand-off limit, so even reveal never submits an action.
        let bench = try await Bench(.reveal)
        // https://developer.apple.com/documentation/foundation/jsonserialization/writingoptions/withoutescapingslashes
        // Escaping every slash would put the test's request above the 1 MiB transport limit.
        let body = try JSONSerialization.data(
            withJSONObject: ["query": WorkspaceProviderTests.revealPath, "variables": ["path": path]],
            options: [.withoutEscapingSlashes])
        #expect(body.count < 1 << 20)
        let clock = ContinuousClock()
        let start = clock.now
        let reply = try await bench.harness.raw(bearer: bench.credential, body: body)
        let elapsed = start.duration(to: clock.now)
        await bench.stop()
        if missing {
            #expect(reply.status == 200)
            let result = (reply.json["data"] as? [String: Any])?["reveal"] as? [String: Any]
            #expect(result?["status"] as? String == "DEPENDENCY_UNAVAILABLE")
            #expect((result?["dependency"] as? [String: Any])?["reason"] as? String == "PATH_NOT_FOUND")
        } else {
            let error = try #require(reply.errors.first)
            #expect((error["extensions"] as? [String: Any])?["kind"] as? String == "failed")
            let message = try #require(error["message"] as? String)
            #expect(message.contains("application hand-off") && message.contains("\(path.utf8.count) bytes"))
            #expect(message.contains("No request was made"))
        }
        #expect(elapsed < .seconds(2), "the shipped walk must resolve a roughly 1 MiB path promptly")
    }

    @Test(arguments: Depth.allCases, Operation.allCases)
    func everyAbsentRowIsPathNotFoundAndANonexistentLongPathIsNeverAnErrorOfLength(_ depth: Depth, _ operation: Operation) async throws {
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
        let bench = try await Bench(operation)
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
            let answer = try await bench.ask(path)
            #expect(answer == .notFound, Comment(rawValue: "\(what) at \(depth.testDescription): \(answer)"))
        }
        await bench.stop()
    }

    // MARK: Failed rows

    @Test(arguments: Depth.allCases, Operation.allCases)
    func theLinkBudgetAndEveryOtherUnestablishedStepAreFailedNamingTheComponentAndTheCause(_ depth: Depth, _ operation: Operation) async throws {
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
        let bench = try await Bench(operation)
        let rows: [(String, String, String, String)] = [
            ("a 33-link chain, the budget", tree.path(depth.base + ["chain-33"]), "chain-1", "32 symbolic links"),
            ("a self-extending link, the budget", tree.path(depth.base + ["a"]), "\"a\"", "32 symbolic links"),
            ("a directory without search permission", tree.path(depth.base + ["closed", "inside"]), "closed", "denied"),
            ("a non-ASCII name the lookup refuses as too long", tree.path(depth.base + [nonAscii]), nonAscii, "too long"),
        ]
        for (what, path, component, cause) in rows {
            let answer = try await bench.ask(path)
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

    @Test(arguments: [1024, 1025, 1500], Operation.allCases)
    func anExtantFileOfOneThousandTwentyFourBytesOrMoreIsRefusedAtItsLiteralSpelling(_ length: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try Self.file(of: length, in: tree)
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(parts))
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: length), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func aDirectoryOverTheLimitIsRefusedWithAndWithoutATrailingSlash(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<5).map { WalkTree.segment($0) }
        try tree.makeDirectories(directory)
        let bench = try await Bench(operation)
        let path = tree.path(directory)
        for (spelling, bytes) in [(path, path.utf8.count), (path + "/", path.utf8.count + 1)] {
            let answer = try await bench.ask(spelling)
            #expect(Self.isRefusal(answer, naming: "the path as written", bytes: bytes), Comment(rawValue: "\(answer)"))
        }
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func aShortLiteralWithALongExpansionIsRefusedAtTheExpandedSpelling(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<3).map { WalkTree.segment($0) }
        let name = String(repeating: "f", count: 250)
        try tree.makeDirectories(directory)
        try tree.makeFile(directory + [name])
        try tree.makeLink(tree.path(directory), at: ["jump"])
        let bench = try await Bench(operation)
        let path = tree.path(["jump", name])
        #expect(path.utf8.count < 1024, "the literal is short")
        let expanded = tree.path(directory).utf8.count + 1 + name.utf8.count
        let answer = try await bench.ask(path)
        #expect(
            Self.isRefusal(answer, naming: "the remaining path after symbolic link 1", bytes: expanded),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func aShortLiteralAndShortExpansionsWithALongResolvedSpellingAreRefusedAtTheResolvedSpelling(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let first = (0..<3).map { WalkTree.segment($0) }
        let second = (3..<6).map { WalkTree.segment($0) }
        try tree.makeDirectories(first + second)
        try tree.makeLink(first.joined(separator: "/"), at: ["A"])
        try tree.makeLink(second.joined(separator: "/"), at: first + ["B"])
        try tree.makeFile(first + second + ["f"])
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(["A", "B", "f"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(first + second + ["f"]).utf8.count),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// A short literal whose chain of links ends at a deep target: the resolved spelling is what is refused, so
    /// the refusal proves every link of the chain resolved, and a 33-link chain is the budget.
    @Test(arguments: [1, 31, 32], Operation.allCases)
    func aResolvingChainOfLinksIsRefusedAtTheResolvedSpellingNeverAsTheBudget(_ links: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<4).map { WalkTree.segment($0) }
        try tree.makeDirectories(directory)
        try tree.makeFile(directory + ["target"])
        try tree.makeLink(directory.joined(separator: "/") + "/target", at: ["chain-1"])
        if links > 1 { for index in 2...links { try tree.makeLink("chain-\(index - 1)", at: ["chain-\(index)"]) } }
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(["chain-\(links)"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(directory + ["target"]).utf8.count),
            Comment(rawValue: "\(links) links: \(answer)"))
        await bench.stop()
    }

    @Test(arguments: [31, 32], Operation.allCases)
    func aResolvingChainAtAboutFifteenHundredBytesIsRefusedAtItsLiteralSpelling(_ links: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base)
        try tree.makeFile(base + ["target"])
        try tree.makeLink("target", at: base + ["chain-1"])
        for index in 2...links { try tree.makeLink("chain-\(index - 1)", at: base + ["chain-\(index)"]) }
        let bench = try await Bench(operation)
        let path = tree.path(base + ["chain-\(links)"])
        let answer = try await bench.ask(path)
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// The retained finite repeated dot-link: the same link expands three times, each with a shorter pending suffix,
    /// so no state repeats. Resolved at depth, so the refusal that follows proves it was not read as a cycle.
    @Test(arguments: Operation.allCases) func aDotLinkRepeatedOnAFinitePathIsPresentAtDepth(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base)
        try tree.makeFile(base + ["f"])
        try tree.makeLink(".", at: base + ["dot"])
        let bench = try await Bench(operation)
        let path = tree.path(base + ["dot", "dot", "dot", "f"])
        let answer = try await bench.ask(path)
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// `..` is the physical parent of what a link led to. The literal is short and the expansion short; the resolved
    /// spelling is refused, so its byte count shows the walk dropped exactly the directory `..` leaves.
    @Test(arguments: Operation.allCases) func aDotDotAfterALinkIsPhysicalAndShowsInTheResolvedSpelling(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let deep = (0..<4).map { WalkTree.segment($0) }
        try tree.makeDirectories(deep + ["child"])
        try tree.makeFile(deep + ["f"])
        try tree.makeLink(deep.joined(separator: "/"), at: ["jump"])
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(["jump", "child", "..", "f"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(deep + ["f"]).utf8.count),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// An absolute link restarts at the root, whatever directory held it: the resolved spelling is the target's
    /// own, with nothing of the directory that contained the link.
    @Test(arguments: Operation.allCases) func anAbsoluteLinkRestartsAtTheRootAndShowsInTheResolvedSpelling(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let first = (0..<3).map { WalkTree.segment($0) }
        let second = (3..<6).map { WalkTree.segment($0) }
        try tree.makeDirectories(["holder"])
        try tree.makeDirectories(first + second)
        try tree.makeLink(tree.path(first), at: ["holder", "abs"])
        try tree.makeLink(second.joined(separator: "/"), at: first + ["B"])
        try tree.makeFile(first + second + ["f"])
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(["holder", "abs", "B", "f"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved path", bytes: tree.path(first + second + ["f"]).utf8.count),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func aFinalDirectoryWithoutSearchPermissionIsPresentAndRefusedAtDepth(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base + ["closed"])
        try tree.chmod(base + ["closed"], 0o600)
        let bench = try await Bench(operation)
        let path = tree.path(base + ["closed"])
        // Present and never opened: the refusal follows. (Inside it, the walk is denied: the failed row above.)
        let answer = try await bench.ask(path)
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func oneLinkInodeWithEntriesInTwoDirectoriesIsPresentAtDepth(_ operation: Operation) async throws {
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
        let bench = try await Bench(operation)
        let path = tree.path(base + ["dA", "L", "z"])
        let answer = try await bench.ask(path)
        // The link `L` and its pending suffix recur on this finite path; the refusal follows a complete resolution.
        #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func extantMultibyteAndCombiningNamesAreResolvedAtDepth(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try tree.makeDirectories(base)
        let names = [
            String(repeating: "\u{65E5}", count: 100), "cafe\u{301}-" + String(repeating: "e\u{301}", count: 20),
            "\u{1F600}-emoji",
        ]
        let bench = try await Bench(operation)
        var checked = 0
        for name in names {
            guard (try? tree.makeFile(base + [name])) != nil else {
                print("NOT BUILT: this filesystem does not admit \(name.utf8.count)-byte name")
                continue
            }
            let path = tree.path(base + [name])
            let answer = try await bench.ask(path)
            #expect(Self.isRefusal(answer, naming: "the path as written", bytes: path.utf8.count), Comment(rawValue: "\(answer)"))
            checked += 1
        }
        #expect(checked >= 1)
        await bench.stop()
    }

    // MARK: Open: present targets within the limit settle, and payloads are refused on the resolved object

    /// The open is named to an unregistered application, so a present target within the limit that the payload
    /// policy lets through answers `APPLICATION_NOT_INSTALLED` and nothing is opened. That answer shows the walk
    /// resolved the target and its metadata was read, which a reveal's refusal-only rows cannot show.
    @Test(arguments: [1022, 1023])
    func anExtantFileAtTheLongestHandedOverSpellingSettlesForAnOpen(_ length: Int) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try Self.file(of: length, in: tree)
        #expect(tree.path(parts).utf8.count == length)
        let bench = try await Bench(.open)
        let answer = try await bench.ask(tree.path(parts))
        #expect(answer == .settled, Comment(rawValue: "\(length) bytes: \(answer)"))
        await bench.stop()
    }

    /// Present at a literal of about 900 bytes: 31- and 32-link chains, a final directory without search
    /// permission, one link inode in two directories, a finite repeated dot-link, and multibyte and combining
    /// names, each resolved by the walk and read for metadata.
    @Test(arguments: [31, 32])
    func aResolvingChainWithinTheLimitSettlesForAnOpen(_ links: Int) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<3).map { WalkTree.segment($0) }
        try tree.makeDirectories(base)
        try tree.makeFile(base + ["target"])
        try tree.makeLink("target", at: base + ["chain-1"])
        for index in 2...links { try tree.makeLink("chain-\(index - 1)", at: base + ["chain-\(index)"]) }
        let bench = try await Bench(.open)
        let path = tree.path(base + ["chain-\(links)"])
        #expect(path.utf8.count < 1024)
        let answer = try await bench.ask(path)
        #expect(answer == .settled, Comment(rawValue: "\(links) links: \(answer)"))
        await bench.stop()
    }

    @Test func aFinalDirectoryWithoutSearchPermissionKeepsItsAcceptedOpenOutcome() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<3).map { WalkTree.segment($0) }
        try tree.makeDirectories(base + ["closed"])
        try tree.chmod(base + ["closed"], 0o600)
        let bench = try await Bench(.open)
        let path = tree.path(base + ["closed"])
        #expect(path.utf8.count < 1024)
        // Present and never opened by the walk, and its own metadata is read from its parent: it settles.
        let answer = try await bench.ask(path)
        #expect(answer == .settled, Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func oneLinkInodeWithEntriesInTwoDirectoriesSettlesForAnOpen() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<3).map { WalkTree.segment($0) }
        try tree.makeDirectories(base + ["dA", "sub"])
        try tree.makeDirectories(base + ["dB", "sub"])
        try tree.makeLink("sub", at: base + ["dA", "L"])
        guard (try? tree.hardLink(base + ["dA", "L"], to: base + ["dB", "L"])) != nil else {
            print("NOT BUILT: this filesystem does not hard-link a symbolic link")
            return
        }
        try tree.makeLink("../../dB/L/z", at: base + ["dA", "sub", "z"])
        try tree.makeFile(base + ["dB", "sub", "z"])
        let bench = try await Bench(.open)
        let answer = try await bench.ask(tree.path(base + ["dA", "L", "z"]))
        #expect(answer == .settled, Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func aDotLinkRepeatedOnAFinitePathSettlesForAnOpen() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<3).map { WalkTree.segment($0) }
        try tree.makeDirectories(base)
        try tree.makeFile(base + ["f"])
        try tree.makeLink(".", at: base + ["dot"])
        let bench = try await Bench(.open)
        let answer = try await bench.ask(tree.path(base + ["dot", "dot", "dot", "f"]))
        #expect(answer == .settled, Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    @Test func extantMultibyteAndCombiningNamesSettleForAnOpen() async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<2).map { WalkTree.segment($0) }
        try tree.makeDirectories(base)
        let names = [
            String(repeating: "\u{65E5}", count: 100), "cafe\u{301}-" + String(repeating: "e\u{301}", count: 20),
            "\u{1F600}-emoji",
        ]
        let bench = try await Bench(.open)
        var checked = 0
        for name in names {
            guard (try? tree.makeFile(base + [name])) != nil else {
                print("NOT BUILT: this filesystem does not admit \(name.utf8.count)-byte name")
                continue
            }
            let path = tree.path(base + [name])
            #expect(path.utf8.count < 1024, "\(name.utf8.count)-byte name")
            let answer = try await bench.ask(path)
            #expect(answer == .settled, Comment(rawValue: "\(answer)"))
            checked += 1
        }
        #expect(checked >= 1)
        await bench.stop()
    }

    /// A short literal whose chain of 32 links ends at a payload about 900 bytes down: the payload policy applies
    /// to the resolved object, not to what the caller wrote, and is refused as an input error, exactly as a short
    /// one is, with nothing opened.
    enum Payload: CaseIterable, CustomTestStringConvertible {
        case applicationBundle, executable, alias
        var testDescription: String {
            switch self {
            case .applicationBundle: "application bundle"
            case .executable: "executable"
            case .alias: "Finder alias"
            }
        }
        var refusal: String {
            switch self {
            case .applicationBundle: "application bundle"
            case .executable: "executable program"
            case .alias: "Finder alias"
            }
        }

        /// Builds the payload under `deep`, and returns its path parts.
        func build(in tree: WalkTree, under deep: [String]) throws -> [String] {
            switch self {
            case .applicationBundle:
                try tree.makeDirectories(deep + ["Fake.app", "Contents"])
                let plist = """
                    <?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict>
                    <key>CFBundleIdentifier</key><string>com.example.koine.k175.fake</string>
                    <key>CFBundleName</key><string>Fake</string><key>CFBundlePackageType</key><string>APPL</string>
                    <key>CFBundleExecutable</key><string>Fake</string></dict></plist>
                    """
                try tree.makeFile(deep + ["Fake.app", "Contents", "Info.plist"], contents: Array(plist.utf8))
                return deep + ["Fake.app"]
            case .executable:
                // A real Mach-O program, written through a handle: its content type is the system's own answer.
                let program = try [UInt8](Data(contentsOf: URL(fileURLWithPath: "/bin/ls")))
                try tree.makeFile(deep + ["tool"], contents: program, mode: 0o755)
                return deep + ["tool"]
            case .alias:
                // A Finder alias file has its flag set by the system's own writer, so it is written by it, at a path
                // under the limit.
                try tree.makeFile(deep + ["original"])
                let bookmark = try URL(fileURLWithPath: tree.path(deep + ["original"]))
                    .bookmarkData(options: .suitableForBookmarkFile)
                try URL.writeBookmarkData(bookmark, to: URL(fileURLWithPath: tree.path(deep + ["alias"])))
                return deep + ["alias"]
            }
        }
    }

    @Test(arguments: Payload.allCases)
    func aPayloadAtTheEndOfALinkChainAtAboutNineHundredBytesIsRefusedOnTheResolvedObject(_ payload: Payload) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let deep = (0..<3).map { WalkTree.segment($0) }
        try tree.makeDirectories(deep)
        let target = try payload.build(in: tree, under: deep)
        #expect(tree.path(target).utf8.count < 1024)
        try tree.makeLink(tree.path(target), at: ["chain-1"])
        for index in 2...32 { try tree.makeLink("chain-\(index - 1)", at: ["chain-\(index)"]) }
        let bench = try await Bench(.open)
        let answer = try await bench.ask(tree.path(["chain-32"]))
        guard case .rejected(let message) = answer else {
            Issue.record("\(payload.testDescription) is an input error, never opened: \(answer)")
            return
        }
        #expect(message.contains(payload.refusal), Comment(rawValue: "\(message)"))
        // The same payload addressed directly at about 900 bytes, with no link, is refused alike.
        let direct = try await bench.ask(tree.path(target))
        guard case .rejected(let directMessage) = direct else {
            Issue.record("\(payload.testDescription) at depth is an input error: \(direct)")
            return
        }
        #expect(directMessage.contains(payload.refusal), Comment(rawValue: "\(directMessage)"))
        await bench.stop()
    }

    // MARK: Existing short outcomes

    @Test(arguments: Operation.allCases) func shortAbsentAndRefusedInputOutcomesAreUnchanged(_ operation: Operation) async throws {
        let bench = try await Bench(operation)
        #expect(try await bench.ask("/definitely/not/here/\(UUID().uuidString)") == .notFound)
        #expect(try await bench.ask("/private/var/../does-not-exist-\(UUID().uuidString)") == .notFound)
        await bench.stop()
    }
}
