import Foundation
import Testing
import WorkspaceTestSupport

/// N for the supplied-application stage (docs/specs/workspace-launch-and-open.md "Order of target and application
/// stages", stage 2): the independently built, signed workspace bundle, loaded by the real loader and asked over
/// loopback HTTP for a constrained launch and for an open named to an installation, where the `applicationPath` is
/// a fixture on this host's filesystem at short depth and at about 1,500 bytes. Every fixture is built component
/// by component, so no whole-path call ever addressed a long location in the test either.
///
/// **Nothing is launched or opened on this host.** The fixture application is a bundle nobody registered, so a
/// request that reaches the end of the stage answers `APPLICATION_NOT_INSTALLED`, and one asked under another
/// identifier answers `APPLICATION_IDENTITY_MISMATCH`: either answer shows the walk resolved the location, the
/// limit passed it and its bundle was read from the resolved spelling, which is how a present outcome is observed
/// here. An absence is `APPLICATION_NOT_INSTALLED` too, so every present row is asked under the other identifier,
/// where only a present bundle gives a mismatch. The registered candidates are Launch Services' and cannot be
/// arranged on a host: the comparison is L's (`ApplicationLocationTests`) and the short workflows beside a long copy
/// are V's (`application-locations-vm`). `task test` builds the bundle.
@Suite struct WorkspaceApplicationLocationTests {
    enum Depth: CaseIterable, CustomTestStringConvertible {
        case short, deep
        var testDescription: String { self == .short ? "short" : "about 1,500 bytes" }
        /// Six 245-byte directories under the fixture root: every location below is over 1,500 bytes.
        var base: [String] { self == .short ? [] : (0..<6).map { WalkTree.segment($0) } }
    }

    enum Operation: CaseIterable, CustomTestStringConvertible {
        case launch, open
        var testDescription: String { self == .launch ? "constrained launch" : "named open" }
    }

    /// What the bundle answered for one action.
    enum Answer: Equatable, CustomStringConvertible {
        case notInstalled, mismatch, failed(String), refused(String), unexpected(String)
        var description: String {
            switch self {
            case .notInstalled: "APPLICATION_NOT_INSTALLED"
            case .mismatch: "APPLICATION_IDENTITY_MISMATCH"
            case .failed(let message): "failed: \(message)"
            case .refused(let message): "refused: \(message)"
            case .unexpected(let text): "unexpected: \(text)"
            }
        }
    }

    static let identifier = "com.example.koine.k176.fixture"
    static let other = "com.example.koine.k176.other"

    static let launchQuery = """
        mutation($application: WorkspaceApplicationInput!) {
          launch: workspaceLaunchApplication(application: $application) {
            status value { process { pid startedAt } } dependency { reason guidance } } }
        """

    /// The signed bundle, a credential holding both controls, and a short text file for an open's target.
    struct Bench {
        let harness: Harness
        let credential: String
        let operation: Operation
        let fixtures: WorkspaceProviderTests.Fixtures

        init(_ operation: Operation) async throws {
            self.operation = operation
            fixtures = try WorkspaceProviderTests.Fixtures()
            harness = try await DesktopProviderTests.harness()
            credential = try await harness.consoleGrant(label: "c", capabilities: WorkspaceProviderTests.controls)
        }

        /// Asks for `path` as the application, under `identifier`: the other one unless a row says otherwise.
        func ask(_ path: String, as identifier: String = WorkspaceApplicationLocationTests.other) async throws -> Answer {
            let application: [String: Any] = ["bundleIdentifier": identifier, "applicationPath": path]
            let field = operation == .launch ? "launch" : "open"
            let reply =
                operation == .launch
                ? try await harness.post(
                    WorkspaceApplicationLocationTests.launchQuery, variables: ["application": application],
                    authorization: "Bearer \(credential)")
                : try await harness.post(
                    WorkspaceProviderTests.openPath, variables: ["path": fixtures.text, "application": application],
                    authorization: "Bearer \(credential)")
            if let error = reply.errors.first {
                let kind = (error["extensions"] as? [String: Any])?["kind"] as? String
                let message = error["message"] as? String ?? "\(error)"
                guard kind == "failed" else { return .unexpected("\(error)") }
                return message.contains("application hand-off") ? .refused(message) : .failed(message)
            }
            guard let result = reply.data?[field] as? [String: Any] else { return .unexpected("\(reply.json)") }
            guard result["status"] as? String == "DEPENDENCY_UNAVAILABLE" else { return .unexpected("\(result)") }
            switch (result["dependency"] as? [String: Any])?["reason"] as? String {
            case "APPLICATION_NOT_INSTALLED": return .notInstalled
            case "APPLICATION_IDENTITY_MISMATCH": return .mismatch
            default: return .unexpected("\(result)")
            }
        }

        func stop() async {
            fixtures.remove()
            await harness.stop()
        }
    }

    // MARK: Fixtures

    /// An application bundle `name` under `directory`, with an Info.plist declaring `identifier`; its path parts.
    @discardableResult
    static func makeBundle(
        under directory: [String], name: String = "Fixture.app", identifier: String? = identifier, in tree: WalkTree
    ) throws -> [String] {
        let bundle = directory + [name]
        try tree.makeDirectories(bundle + ["Contents"])
        if let identifier {
            let plist = """
                <?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict>
                <key>CFBundleIdentifier</key><string>\(identifier)</string>
                <key>CFBundleName</key><string>Fixture</string><key>CFBundlePackageType</key><string>APPL</string>
                <key>CFBundleExecutable</key><string>Fixture</string></dict></plist>
                """
            try tree.makeFile(bundle + ["Contents", "Info.plist"], contents: Array(plist.utf8))
        }
        return bundle
    }

    /// An application bundle whose own path is exactly `length` bytes, under 245-byte directories.
    static func makeBundle(of length: Int, in tree: WalkTree, identifier: String? = identifier) throws -> [String] {
        var segments = (length - tree.root.utf8.count - 2) / 246
        while true {
            let remainder = length - tree.root.utf8.count - segments * 246 - 1
            if (5...255).contains(remainder) {
                let directory = (0..<segments).map { WalkTree.segment($0) }
                let name = String(repeating: "b", count: remainder - 4) + ".app"
                return try makeBundle(under: directory, name: name, identifier: identifier, in: tree)
            }
            segments -= 1
        }
    }

    /// Whether `answer` is a refusal naming `spelling` and exactly `bytes` bytes, as `operation` would have it.
    static func isRefusal(_ answer: Answer, naming spelling: String, bytes: Int, _ operation: Operation) -> Bool {
        guard case .refused(let message) = answer else { return false }
        let undone = operation == .launch ? "nothing was launched" : "nothing was opened"
        return message.contains(spelling) && message.contains("\(bytes) bytes") && message.contains("No request was made")
            && message.contains(undone)
    }

    // MARK: Absent rows

    @Test(arguments: Depth.allCases, Operation.allCases)
    func everyAbsentRowIsNotInstalledAndAnonexistentLongPathIsNeverAnErrorOfLength(_ depth: Depth, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeFile(depth.base + ["file.txt"])
        try tree.makeLink("no-such-target", at: depth.base + ["dangling"])
        let bench = try await Bench(operation)
        var rows: [(String, String)] = [
            ("a missing name", tree.path(depth.base + ["Missing.app"])),
            ("a dangling link", tree.path(depth.base + ["dangling"])),
            ("a name below a file", tree.path(depth.base + ["file.txt", "Below.app"])),
            ("a file with a trailing slash", tree.path(depth.base + ["file.txt"]) + "/"),
            ("a file with a trailing dot", tree.path(depth.base + ["file.txt"]) + "/."),
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
            #expect(answer == .notInstalled, Comment(rawValue: "\(what) at \(depth.testDescription): \(answer)"))
        }
        await bench.stop()
    }

    // MARK: Failed rows

    /// An impossible name and a cycle at an application location are `failed`, where a target's are absent: the
    /// accepted application inspection treated them so, and nothing here says the application is missing.
    @Test(arguments: Depth.allCases, Operation.allCases)
    func anImpossibleNameAndEveryCycleAreFailedAndNeverAMissingApplication(_ depth: Depth, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(depth.base)
        try tree.makeLink("loop-b", at: depth.base + ["loop-a"])
        try tree.makeLink("loop-a", at: depth.base + ["loop-b"])
        try tree.makeLink("self", at: depth.base + ["self"])
        try tree.makeLink("slash/", at: depth.base + ["slash"])
        let impossible = String(repeating: "n", count: 300)
        let bench = try await Bench(operation)
        let rows: [(String, String, String)] = [
            ("an established two-link cycle", tree.path(depth.base + ["loop-a"]), "loop-a"),
            ("a cycle through a directory component", tree.path(depth.base + ["loop-a", "Below.app"]), "loop-a"),
            ("a link to itself", tree.path(depth.base + ["self"]), "self"),
            ("a cycle whose link text ends in a slash", tree.path(depth.base + ["slash"]), "slash"),
            ("an impossible 300-byte ASCII component", tree.path(depth.base + [impossible]), "longer than the filesystem allows"),
            ("an impossible component as a directory", tree.path(depth.base + [impossible, "Below.app"]), "longer than the filesystem allows"),
        ]
        for (what, path, mentions) in rows {
            let answer = try await bench.ask(path)
            guard case .failed(let message) = answer else {
                Issue.record("\(what) at \(depth.testDescription) is `failed`, never a dependency: \(answer)")
                continue
            }
            #expect(message.contains("could not be resolved"), Comment(rawValue: "\(what): \(message)"))
            #expect(message.contains(mentions), Comment(rawValue: "\(what) says why: \(message)"))
        }
        await bench.stop()
    }

    @Test(arguments: Depth.allCases, Operation.allCases)
    func theLinkBudgetAndEveryOtherUnestablishedStepAreFailedNamingTheComponentAndTheCause(_ depth: Depth, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try Self.makeBundle(under: depth.base + ["closed"], in: tree)
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
            ("a directory without search permission", tree.path(depth.base + ["closed", "Fixture.app"]), "closed", "denied"),
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
        await bench.stop()
    }

    // MARK: Over the limit: refused after the walk, before any metadata read

    @Test(arguments: [1024, 1025, 1500], Operation.allCases)
    func anExtantBundleOfOneThousandTwentyFourBytesOrMoreIsRefusedAtItsLiteralSpelling(_ length: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try Self.makeBundle(of: length, in: tree)
        let bench = try await Bench(operation)
        let path = tree.path(parts)
        #expect(path.utf8.count == length)
        // Under either identifier: the refusal precedes the identifier comparison.
        for identifier in [Self.other, Self.identifier] {
            let answer = try await bench.ask(path, as: identifier)
            #expect(Self.isRefusal(answer, naming: "the application path as written", bytes: length, operation), Comment(rawValue: "\(answer)"))
        }
        await bench.stop()
    }

    /// The limit comes before the metadata: an over-limit file that is no application, and a bundle whose
    /// Info.plist is not there, are refused and not read, so neither is a dependency.
    @Test(arguments: Operation.allCases) func anOverLimitLocationIsRefusedWhateverItIsBecauseNothingIsReadFirst(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let bare = try Self.makeBundle(of: 1100, in: tree, identifier: nil)
        let directory = (0..<5).map { WalkTree.segment($0) + "-plain" }
        try tree.makeDirectories(directory)
        let bench = try await Bench(operation)
        for path in [tree.path(bare), tree.path(directory), tree.path(directory) + "/"] {
            let answer = try await bench.ask(path)
            guard case .refused = answer else {
                Issue.record("an over-limit location is refused: \(answer)")
                continue
            }
        }
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func aShortLiteralWithALongExpansionIsRefusedAtTheExpandedSpelling(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<3).map { WalkTree.segment($0) }
        let name = String(repeating: "f", count: 246) + ".app"
        try Self.makeBundle(under: directory, name: name, in: tree)
        try tree.makeLink(tree.path(directory), at: ["jump"])
        let bench = try await Bench(operation)
        let path = tree.path(["jump", name])
        #expect(path.utf8.count < 1024, "the literal is short")
        let expanded = tree.path(directory).utf8.count + 1 + name.utf8.count
        let answer = try await bench.ask(path)
        #expect(
            Self.isRefusal(answer, naming: "the remaining application path after symbolic link 1", bytes: expanded, operation),
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
        try Self.makeBundle(under: first + second, in: tree)
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(["A", "B", "Fixture.app"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved application path", bytes: tree.path(first + second + ["Fixture.app"]).utf8.count, operation),
            Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    /// A short literal whose chain of links ends at a deep bundle: the resolved spelling is what is refused, so
    /// the refusal proves every link of the chain resolved, and a 33-link chain is the budget (above).
    @Test(arguments: [1, 31, 32], Operation.allCases)
    func aResolvingChainOfLinksIsRefusedAtTheResolvedSpellingNeverAsTheBudget(_ links: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let directory = (0..<4).map { WalkTree.segment($0) }
        let bundle = try Self.makeBundle(under: directory, in: tree)
        try tree.makeLink(bundle.joined(separator: "/"), at: ["chain-1"])
        if links > 1 { for index in 2...links { try tree.makeLink("chain-\(index - 1)", at: ["chain-\(index)"]) } }
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(["chain-\(links)"]))
        #expect(
            Self.isRefusal(answer, naming: "the resolved application path", bytes: tree.path(bundle).utf8.count, operation),
            Comment(rawValue: "\(links) links: \(answer)"))
        await bench.stop()
    }

    @Test(arguments: [31, 32], Operation.allCases)
    func aResolvingChainAtAboutFifteenHundredBytesIsRefusedAtItsLiteralSpelling(_ links: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = Depth.deep.base
        try Self.makeBundle(under: base, in: tree)
        try tree.makeLink("Fixture.app", at: base + ["chain-1"])
        for index in 2...links { try tree.makeLink("chain-\(index - 1)", at: base + ["chain-\(index)"]) }
        let bench = try await Bench(operation)
        let path = tree.path(base + ["chain-\(links)"])
        let answer = try await bench.ask(path)
        #expect(Self.isRefusal(answer, naming: "the application path as written", bytes: path.utf8.count, operation), Comment(rawValue: "\(answer)"))
        await bench.stop()
    }

    // MARK: Present, within the limit: shown by the mismatch (and by the identifier the bundle declares)

    /// A bundle that resolved, was within the limit and whose identifier was read: under another identifier it is a
    /// mismatch (absence would be `APPLICATION_NOT_INSTALLED`), and under its own it is an unregistered copy.
    func expectSettles(_ bench: Bench, _ path: String, _ what: String) async throws {
        let mismatch = try await bench.ask(path)
        #expect(mismatch == .mismatch, Comment(rawValue: "\(what) is present and another identifier is a mismatch: \(mismatch)"))
        let unregistered = try await bench.ask(path, as: Self.identifier)
        #expect(unregistered == .notInstalled, Comment(rawValue: "\(what) declares the identifier and nobody registered it: \(unregistered)"))
    }

    @Test(arguments: [0, 3], Operation.allCases)
    func aBundleReachedByLinkChainsAtShortAndAboutNineHundredByteDepthIsReadFromTheResolvedSpelling(_ depth: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<depth).map { WalkTree.segment($0) }
        let bundle = try Self.makeBundle(under: base, in: tree)
        let bench = try await Bench(operation)
        try await expectSettles(bench, tree.path(bundle), "the bundle itself")
        // A link to the bundle, a link to its folder, and chains of 2, 31 and 32 links ending at the bundle. A
        // link is not an application by its own metadata, so only the resolved spelling's read finds the bundle.
        try tree.makeLink(tree.path(bundle), at: ["chain-1"])
        for index in 2...32 { try tree.makeLink("chain-\(index - 1)", at: ["chain-\(index)"]) }
        for links in [1, 2, 31, 32] { try await expectSettles(bench, tree.path(["chain-\(links)"]), "a chain of \(links) link(s)") }
        try tree.makeLink(tree.path(base.isEmpty ? [] : base), at: ["folder"])
        try await expectSettles(bench, tree.path(["folder", "Fixture.app"]), "a link to the folder")
        await bench.stop()
    }

    /// `..` is the physical parent of what a link led to; the location is found as the kernel would find it.
    @Test(arguments: Operation.allCases) func aDotDotAfterALinkIsPhysicalAndFindsTheBundle(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let deep = (0..<3).map { WalkTree.segment($0) }
        try tree.makeDirectories(deep + ["child"])
        try Self.makeBundle(under: deep, in: tree)
        try tree.makeLink(deep.joined(separator: "/"), at: ["jump"])
        let bench = try await Bench(operation)
        try await expectSettles(bench, tree.path(["jump", "child", "..", "Fixture.app"]), "a bundle after a dot-dot")
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func oneLinkInodeWithEntriesInTwoDirectoriesAndADotLinkAreFound(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<3).map { WalkTree.segment($0) }
        try tree.makeDirectories(base + ["dA", "sub"])
        try tree.makeDirectories(base + ["dB", "sub"])
        try tree.makeLink("sub", at: base + ["dA", "L"])
        try tree.makeLink(".", at: base + ["dot"])
        try Self.makeBundle(under: base + ["dB", "sub"], in: tree)
        let bench = try await Bench(operation)
        try await expectSettles(bench, tree.path(base + ["dot", "dot", "dot", "dB", "sub", "Fixture.app"]), "a repeated dot-link")
        if (try? tree.hardLink(base + ["dA", "L"], to: base + ["dB", "L"])) != nil {
            // `L` in dA leads to dA/sub, and in dB to dB/sub: the same link inode, two directories, a finite path.
            try await expectSettles(bench, tree.path(base + ["dB", "L", "Fixture.app"]), "one link inode in two directories")
        } else {
            print("NOT BUILT: this filesystem does not hard-link a symbolic link")
        }
        await bench.stop()
    }

    @Test(arguments: Operation.allCases) func extantMultibyteAndCombiningNamesAreFound(_ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<2).map { WalkTree.segment($0) }
        try tree.makeDirectories(base)
        let names = [
            String(repeating: "\u{65E5}", count: 90) + ".app", "cafe\u{301}-" + String(repeating: "e\u{301}", count: 20) + ".app",
            "\u{1F600}-emoji.app",
        ]
        let bench = try await Bench(operation)
        var checked = 0
        for name in names {
            guard (try? Self.makeBundle(under: base, name: name, in: tree)) != nil else {
                print("NOT BUILT: this filesystem does not admit \(name.utf8.count)-byte name")
                continue
            }
            let path = tree.path(base + [name])
            #expect(path.utf8.count < 1024, "\(name.utf8.count)-byte name")
            try await expectSettles(bench, path, "the name \(name.utf8.count) bytes long")
            checked += 1
        }
        #expect(checked >= 1)
        await bench.stop()
    }

    // MARK: Present, within the limit: what the bundle's own metadata says

    @Test(arguments: [0, 3], Operation.allCases)
    func theBundlesOwnMetadataIsReadAtDepthAndEveryOutcomeKeepsItsAcceptedMeaning(_ depth: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<depth).map { WalkTree.segment($0) }
        try tree.makeDirectories(base)
        try Self.makeBundle(under: base, name: "NoIdentifier.app", identifier: nil, in: tree)
        try Self.makeBundle(under: base, name: "Sealed.app", in: tree)
        try tree.chmod(base + ["Sealed.app", "Contents"], 0)
        try tree.makeFile(base + ["tool"], contents: Array(Data(contentsOf: URL(fileURLWithPath: "/bin/ls"))), mode: 0o755)
        try tree.makeFile(base + ["text.txt"], contents: Array("hello".utf8))
        try tree.makeDirectories(base + ["folder"])
        let bench = try await Bench(operation)
        // A bundle that declares no identifier is a mismatch, under any identifier.
        #expect(try await bench.ask(tree.path(base + ["NoIdentifier.app"]), as: Self.identifier) == .mismatch)
        // A program, a document and a folder are present and not applications. (A bare folder named `.app` is an
        // application with no identifier to the platform, and so a mismatch, as the bundle above.)
        for name in ["tool", "text.txt", "folder"] {
            let answer = try await bench.ask(tree.path(base + [name]), as: Self.identifier)
            #expect(answer == .notInstalled, Comment(rawValue: "\(name): \(answer)"))
        }
        // A bundle whose contents nobody may read is a denial, which is a failure and never another identifier.
        let sealed = try await bench.ask(tree.path(base + ["Sealed.app"]), as: Self.identifier)
        guard case .failed(let message) = sealed else {
            Issue.record("an unreadable bundle is `failed`: \(sealed)")
            return
        }
        #expect(message.contains("Permission denied") || message.contains("denied"), Comment(rawValue: message))
        await bench.stop()
    }

    // MARK: The bundle's own Info.plist is twenty bytes deeper

    /// The identifier is read from `Contents/Info.plist`, a path 20 bytes longer than the bundle's own. Observed on
    /// this host (macOS 26.5): through 1,004 bytes the platform reads it; from 1,005 bytes it answers
    /// `ENAMETOOLONG`, which is a failed inspection with its cause, never an absence or another identifier. The
    /// bundle itself is within the limit and is not refused at it.
    @Test(arguments: [1004, 1005, 1023], Operation.allCases)
    func aBundleWithinTheLimitWhoseInfoPlistIsTooLongForThePlatformIsFailedNamingTheCause(_ length: Int, _ operation: Operation) async throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try Self.makeBundle(of: length, in: tree)
        let bench = try await Bench(operation)
        let answer = try await bench.ask(tree.path(parts), as: Self.identifier)
        if length <= 1004 {
            #expect(answer == .notInstalled, Comment(rawValue: "\(length) bytes: \(answer)"))
        } else {
            guard case .failed(let message) = answer else {
                Issue.record("\(length) bytes is `failed`, never a refusal at the limit or another answer: \(answer)")
                return
            }
            #expect(message.contains("File name too long"), Comment(rawValue: message))
        }
        await bench.stop()
    }
}
