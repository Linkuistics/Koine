import Darwin
import Foundation
import Testing
import WorkspaceTestSupport

@testable import WorkspaceProviderLogic

extension WalkTree {
    /// The object `parts` names, in the walk's own terms, by the test's own component-relative calls.
    fileprivate func identity(_ parts: [String]) -> ObjectIdentity? {
        fileKey(parts).map { ObjectIdentity(device: $0.device, inode: $0.inode) }
    }
}

/// N for the receipt's two executable identities (docs/specs/workspace-launch-and-open.md "Resolving an action
/// location", the last sentence of its absence paragraph; docs/verification/receipt-executable-identity.md): the
/// real acquisition, the live process's `proc_pidpath` and the retained application object's `executableURL`, by
/// the descriptor walk, in device and inode, against the real kernel, `NSRunningApplication` and filesystem.
///
/// **How it reaches the shipped code without a launch.** The signed bundle reaches observation only after an
/// acknowledged launch, which a host test must not make, and exports no symbol. So the test builds
/// `Fixtures/ReceiptIdentityProbe` (`task fixture:receipt-identity-probe`): the provider's own `Logic/` and
/// `Sources/` compiled as `build.sh` compiles them, linked with a four-line entry point instead of as the
/// provider's dylib. It is independently built from the shipped sources, never a copy and never a mutation of
/// them. The test **starts the probe itself, as a process it owns** (a copy placed in a fixture, run by the
/// spelling the test chooses), and the probe reports what `NativeWorkspace.liveExecutableIdentity(of:)` and
/// `RunningApplication.executableIdentity` answer for itself. The independent observers are the test's own
/// component-relative `fstatat` of the file it placed and, where the spelling is short enough for it, the
/// kernel's own `stat` of the spelling.
///
/// **What a process cannot show at about 1,500 bytes.** The kernel kills (`SIGKILL`) a process whose
/// executable's physical path is 1,024 bytes or more at exec (and a longer one is refused at spawn), so no
/// running process has a longer path
/// (`aProcessAtOrBeyondThe…`). The deepest running subject is therefore 1,023 bytes, reached through a link
/// chain; a longer acquisition is shown for the retained route's own conversion, the probe's `url` form, which
/// hands `identityOfExecutable(at:)` the file URL of a present executable of any length. That is a real
/// acquisition on a real file and not a running process's, and it is stated as such in the record.
@Suite struct ReceiptExecutableIdentityTests {
    // MARK: The probe

    static func probe() throws -> URL {
        let url = try DesktopProviderTests.root().deletingLastPathComponent()
            .appendingPathComponent("ReceiptIdentityProbe/receipt-identity-probe")
        try #require(
            FileManager.default.fileExists(atPath: url.path),
            "No receipt-identity probe there. Run `task test`, which builds it.")
        return url
    }

    /// What the probe printed, or how it ended.
    struct Run {
        let status: Int32
        let reason: Process.TerminationReason
        let output: [String: Any]

        var killed: Bool { reason == .uncaughtSignal && status == SIGKILL }
        func identity(_ key: String) -> ObjectIdentity?? {
            guard let value = output[key] else { return .none }
            guard let object = value as? [String: Any], let device = object["device"] as? Int,
                let inode = (object["inode"] as? String).flatMap(UInt64.init)
            else { return .some(nil) }
            return .some(ObjectIdentity(device: Int32(device), inode: inode))
        }
    }

    /// Runs the executable at `spelling`, which the test placed, with `arguments`.
    static func run(_ spelling: String, _ arguments: [String]) throws -> Run {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: spelling)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        return Run(status: process.terminationStatus, reason: process.terminationReason, output: object ?? [:])
    }

    /// A copy of the probe at the file `parts` names, executable.
    static func place(_ probe: Data, at parts: [String], in tree: WalkTree) throws {
        try tree.makeDirectories(Array(parts.dropLast()))
        try tree.makeFile(parts, contents: [UInt8](probe), mode: 0o755)
    }

    /// The device and inode the kernel's own lookup gives the spelling, for a spelling short enough to take.
    static func kernelIdentity(_ spelling: String) -> ObjectIdentity? {
        var status = stat()
        guard stat(spelling, &status) == 0 else { return nil }
        return ObjectIdentity(device: status.st_dev, inode: UInt64(status.st_ino))
    }

    // MARK: A running process, live and retained

    @Test func aRunningProcessIsIdentifiedLiveAndRetainedByTheSameDeviceAndInodeAsItsFile() throws {
        let probe = try Data(contentsOf: Self.probe())
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = ["bin", "receipt-identity-probe"]
        try Self.place(probe, at: parts, in: tree)
        let expected = try #require(tree.identity(parts))

        let run = try Self.run(tree.path(parts), ["self"])
        #expect(run.status == 0 && run.reason == .exit, Comment(rawValue: "\(run.output)"))
        #expect(run.identity("live") == .some(expected), "the kernel's path for the live process, by the walk")
        #expect(run.identity("retained") == .some(expected), "the retained object's executable, by the walk")
        #expect(Self.kernelIdentity(tree.path(parts)) == expected, "the kernel's own lookup agrees")
    }

    /// The deepest a process can be: 1,023 bytes physically, started by a spelling that reaches it through two
    /// links, so what the process reports is the resolved path and the test's spelling is neither it nor
    /// anything the kernel reports. The retained route reads the object's own URL, so it resolves the same file.
    @Test func aRunningProcessAtTheDeepestPathTheKernelRunsIsIdentifiedThroughALinkChain() throws {
        let probe = try Data(contentsOf: Self.probe())
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try tree.makeFile(pathLength: 1_023, contents: [UInt8](probe), mode: 0o755)
        #expect(parts.count >= 4, "three or more 245-byte directories, so two links can reach it")
        let expected = try #require(tree.identity(parts))

        // root/l1 -> d0/d1 (two directories); d1/l2 -> d2/.../(parent of the file); spelled root/l1/l2/<file>.
        let directories = Array(parts.dropLast())
        try tree.makeLink(directories.prefix(2).joined(separator: "/"), at: ["l1"])
        try tree.makeLink(directories.dropFirst(2).joined(separator: "/"), at: Array(directories.prefix(2)) + ["l2"])
        let spelling = tree.path(["l1", "l2", parts.last!])
        #expect(spelling.utf8.count < 1_023 / 2, "a spelling far shorter than the path the kernel reports")
        #expect(Self.kernelIdentity(spelling) == expected, "the chain reaches the file by the kernel's own lookup")

        let run = try Self.run(spelling, ["self"])
        #expect(run.status == 0 && run.reason == .exit, Comment(rawValue: "\(run.output)"))
        #expect(run.identity("live") == .some(expected))
        #expect(run.identity("retained") == .some(expected))
        // Observed, not documented: the platform reports the object's executable as the spelling the process was
        // started by (with a leading `/private` dropped, so 8 bytes shorter), not the kernel's physical path, so the
        // retained walk really goes through the two links. If it ever reports the physical path, this row stops
        // covering that and the `url` rows below are all that does.
        #expect(run.output["livePathBytes"] as? Int == 1_023, "the kernel's path for the process is the deepest that runs")
        let reported = try #require(run.output["executableURLBytes"] as? Int)
        #expect(reported <= spelling.utf8.count && reported < 1_023 / 2, "the object's executable is a link spelling: \(run.output)")
    }

    /// The record's finding, kept as an observation so that a host which lets a longer process run is noticed:
    /// then both identities are required, which is what the rule says of a present executable of any length.
    @Test(arguments: [1_024, 1_025, 1_100])
    func aProcessAtOrBeyondTheLimitIsKilledAtExecOrElseIsIdentified(length: Int) throws {
        let probe = try Data(contentsOf: Self.probe())
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try tree.makeFile(pathLength: length, contents: [UInt8](probe), mode: 0o755)
        let expected = try #require(tree.identity(parts))
        let directories = Array(parts.dropLast())
        try tree.makeLink(directories.prefix(3).joined(separator: "/"), at: ["l1"])
        let spelling = tree.path(["l1"] + directories.dropFirst(3) + [parts.last!])
        try #require(spelling.utf8.count < 1_024, "the spelling itself is startable")

        // The kernel either starts it and kills it (`SIGKILL`, at 1,024 and 1,025 here) or refuses to start it at all
        // (a spawn error, at 1,100 here). Neither is an identity to read.
        let run: Run
        do { run = try Self.run(spelling, ["self"]) } catch { return }
        if run.killed { return }
        #expect(run.status == 0 && run.reason == .exit, Comment(rawValue: "\(run.output)"))
        #expect(run.identity("live") == .some(expected), "a process that runs must be identified at any length")
        #expect(run.identity("retained") == .some(expected))
    }

    // MARK: A path the walk cannot resolve

    @Test func anExecutableThatWasDeletedWhileItRunsYieldsNoLiveAndNoRetainedIdentity() throws {
        let probe = try Data(contentsOf: Self.probe())
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = ["bin", "receipt-identity-probe"]
        try Self.place(probe, at: parts, in: tree)

        let run = try Self.run(tree.path(parts), ["unlinked"])
        #expect(run.status == 0 && run.reason == .exit, Comment(rawValue: "\(run.output)"))
        // The kernel has no path for the process now, and the retained object still holds the URL it had, which
        // the walk finds absent: neither is an identity, so the receipt's process is null.
        #expect(run.identity("live") == .some(nil))
        #expect(run.identity("retained") == .some(nil), "an absent path is no identity, never a stale one")
        #expect(tree.identity(parts) == nil)
    }

    // MARK: What the real system reports

    /// Every application already running on this host is only read: nothing is launched, activated or touched. For each
    /// that reports both identities, the walk's verdict, the same file or not, is set against the verdict of the route it
    /// replaced (a symlink-resolving URL and the platform's resource identifiers), which the probe keeps as its independent
    /// observer. The real system's paths (the sealed system volume, the cryptex, firmlinks, the user's tree) are exactly
    /// what the replaced route had to get right, so the walk may not change one verdict. On this host that includes the
    /// objects the platform reports as another file than the kernel runs (a WebKit content process under enhanced
    /// security), where both routes say "not the same", which is the mismatch the third step exists to catch. Processes
    /// that deny the kernel's path to this one report no live identity and are not counted.
    @Test func theWalkAgreesWithTheRouteItReplacedOnEveryRunningApplicationThatReportsBothIdentities() throws {
        let run = try Self.run(Self.probe().path, ["running"])
        #expect(run.status == 0 && run.reason == .exit, Comment(rawValue: "\(run.output)"))
        let both = try #require(run.output["both"] as? Int)
        let equal = try #require(run.output["equal"] as? Int)
        #expect(both > 0 && equal > 0, "an instrument that saw no application, or no match, observed nothing")
        #expect((run.output["disagreeing"] as? [String]) == [], Comment(rawValue: "\(run.output)"))
    }

    // MARK: The retained route at any length

    enum Row: CaseIterable, CustomTestStringConvertible {
        case lengthBelowTheLimit, lengthAtTheLimit, lengthAboveTheLimit, aboutFifteenHundred, farBeyond
        case relativeLinkAtDepth, absoluteLinkAtDepth, chainOfThirtyTwoLinks, chainOfThirtyThreeLinks
        case absent, cycle, impossibleName

        /// The spelling's exact length, for the rows that are about length.
        var length: Int? {
            switch self {
            case .lengthBelowTheLimit: 1_023
            case .lengthAtTheLimit: 1_024
            case .lengthAboveTheLimit: 1_025
            case .aboutFifteenHundred: 1_500
            case .farBeyond: 4_200
            default: nil
            }
        }

        var testDescription: String {
            switch self {
            case .lengthBelowTheLimit: "a present file of 1,023 bytes"
            case .lengthAtTheLimit: "a present file of 1,024 bytes"
            case .lengthAboveTheLimit: "a present file of 1,025 bytes"
            case .aboutFifteenHundred: "a present file of about 1,500 bytes"
            case .farBeyond: "a present file of 4,200 bytes"
            case .relativeLinkAtDepth: "a relative link at about 1,500 bytes"
            case .absoluteLinkAtDepth: "an absolute link at about 1,500 bytes"
            case .chainOfThirtyTwoLinks: "a chain of 32 links at about 1,500 bytes"
            case .chainOfThirtyThreeLinks: "a chain of 33 links at about 1,500 bytes"
            case .absent: "an absent file at about 1,500 bytes"
            case .cycle: "a cycle at about 1,500 bytes"
            case .impossibleName: "an impossible name at about 1,500 bytes"
            }
        }
    }

    /// `RunningApplication.executableIdentity` is `identityOfExecutable(at:)` of the object's `executableURL`,
    /// and `NSRunningApplication` is never handed a path of 1,024 bytes or more by a process that runs. The
    /// probe's `url` form asks the shipped function the question for a present executable at any length and
    /// through any link, so the retained route's conversion and the walk are shown on the same rows as the live
    /// one's: a present executable yields its device and inode, and every other outcome yields none.
    @Test(arguments: Row.allCases)
    func theRetainedRouteResolvesAPresentExecutableOfAnyLengthAndNothingElse(_ row: Row) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<6).map { WalkTree.segment($0) }
        var parts: [String]
        var resolves = true
        switch row {
        case .lengthBelowTheLimit: parts = try tree.makeFile(pathLength: 1_023)
        case .lengthAtTheLimit: parts = try tree.makeFile(pathLength: 1_024)
        case .lengthAboveTheLimit: parts = try tree.makeFile(pathLength: 1_025)
        case .aboutFifteenHundred: parts = try tree.makeFile(pathLength: 1_500)
        case .farBeyond: parts = try tree.makeFile(pathLength: 4_200)
        case .relativeLinkAtDepth:
            try tree.makeDirectories(base + ["real"])
            try tree.makeFile(base + ["real", "program"])
            try tree.makeLink("real", at: base + ["relative"])
            parts = base + ["relative", "program"]
        case .absoluteLinkAtDepth:
            // A link's text is at most 1,023 bytes, so an absolute link at depth points up the tree.
            try tree.makeDirectories(base)
            let shallow = Array(base.prefix(3)) + ["shallow"]
            try tree.makeDirectories(shallow)
            try tree.makeFile(shallow + ["program"])
            try tree.makeLink(tree.path(shallow), at: base + ["absolute"])
            parts = base + ["absolute", "program"]
        case .chainOfThirtyTwoLinks, .chainOfThirtyThreeLinks:
            let links = row == .chainOfThirtyTwoLinks ? 32 : 33
            try tree.makeDirectories(base)
            try tree.makeFile(base + ["program"])
            try tree.makeLink("program", at: base + ["l1"])
            for number in 2...links { try tree.makeLink("l\(number - 1)", at: base + ["l\(number)"]) }
            parts = base + ["l\(links)"]
            resolves = links == 32
        case .absent:
            try tree.makeDirectories(base)
            parts = base + ["missing"]
            resolves = false
        case .cycle:
            try tree.makeDirectories(base)
            try tree.makeLink("b", at: base + ["a"])
            try tree.makeLink("a", at: base + ["b"])
            parts = base + ["a"]
            resolves = false
        case .impossibleName:
            try tree.makeDirectories(base)
            parts = base + [String(repeating: "n", count: 300)]
            resolves = false
        }
        if let length = row.length {
            #expect(tree.path(parts).utf8.count == length, "the spelling is the length the row names")
        } else {
            #expect(tree.path(parts).utf8.count > 1_024, "the spelling is over the hand-off limit")
        }
        // The expected identity is the object the spelling names: the last real file the fixture placed.
        var expected: ObjectIdentity?
        if resolves { expected = try #require(tree.identity(Self.target(of: row, parts: parts, base: base))) }

        let run = try Self.run(Self.probe().path, ["url", tree.path(parts)])
        #expect(run.status == 0 && run.reason == .exit, Comment(rawValue: "\(run.output)"))
        #expect(run.identity("retained") == .some(expected), Comment(rawValue: row.testDescription))
    }

    /// The parts of the real file a row's spelling reaches.
    static func target(of row: Row, parts: [String], base: [String]) -> [String] {
        switch row {
        case .relativeLinkAtDepth: base + ["real", "program"]
        case .absoluteLinkAtDepth: Array(base.prefix(3)) + ["shallow", "program"]
        case .chainOfThirtyTwoLinks, .chainOfThirtyThreeLinks: base + ["program"]
        default: parts
        }
    }
}
