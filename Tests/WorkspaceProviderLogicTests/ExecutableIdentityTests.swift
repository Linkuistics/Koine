import Darwin
import Foundation
import Testing
import WorkspaceTestSupport

@testable import WorkspaceProviderLogic

/// Observation's own resolution rule (`ExecutableIdentity`; docs/specs/workspace-launch-and-open.md "Resolving an
/// action location", last sentence of its absence paragraph), on the shipped walk and real host fixtures built
/// component by component. **Supporting evidence, never N**: this tests the rule's source, not that the built
/// provider consumes it (`ReceiptExecutableIdentityTests` does, through an independently built copy of the shipped
/// adapter). The rule: a present executable of any length yields the walk's device and inode, and every other
/// outcome yields none, so the receipt's existing null process and never a refusal. Each check is seen to fail
/// against a mutated source: `scripts/check-location-walk-mutations.py`.
@Suite struct ExecutableIdentityTests {
    static func identity(_ tree: WalkTree, _ parts: [String]) -> ObjectIdentity? {
        ExecutableIdentity.of(path: Array(tree.path(parts).utf8))
    }

    // MARK: Present, at any length

    /// The hand-off limit is `PATH_MAX` (1,024) and applies to a request. Observation has no limit: 1,023, 1,024,
    /// 1,025, about 1,500 and far beyond what the kernel will run all yield the object's own device and inode.
    @Test(arguments: [100, 1_023, 1_024, 1_025, 1_500, 4_096, 4_200])
    func aPresentExecutableOfAnyLengthYieldsItsDeviceAndInode(length: Int) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let parts = try tree.makeFile(pathLength: length)
        #expect(tree.path(parts).utf8.count == length)
        let expected = try #require(tree.identity(parts))
        #expect(Self.identity(tree, parts) == expected)
    }

    @Test func aPathReachedThroughLinksYieldsTheObjectsIdentityAndNotTheLinks() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        let base = (0..<6).map { WalkTree.segment($0) }
        try tree.makeDirectories(base + ["real"])
        try tree.makeFile(base + ["real", "program"])
        try tree.makeLink("real", at: base + ["directory-link"])
        try tree.makeLink("real/program", at: base + ["file-link"])
        // A link's text is at most 1,023 bytes, so an absolute link at depth points up the tree.
        let shallow = Array(base.prefix(3)) + ["shallow"]
        try tree.makeDirectories(shallow)
        try tree.makeFile(shallow + ["program"])
        try tree.makeLink(tree.path(shallow), at: base + ["absolute-link"])
        let expected = try #require(tree.identity(base + ["real", "program"]))
        let linkItself = try #require(tree.identity(base + ["file-link"], followLink: false))
        #expect(linkItself != expected, "the fixture's link is a different object")
        #expect(Self.identity(tree, base + ["directory-link", "program"]) == expected)
        #expect(Self.identity(tree, base + ["file-link"]) == expected, "the final link is followed")
        #expect(
            Self.identity(tree, base + ["absolute-link", "program"]) == tree.identity(shallow + ["program"]),
            "an absolute link restarts at the root")
    }

    /// The kernel's own budget (`MAXSYMLINKS`, 32) holds here as everywhere the walk is used: a chain that is
    /// within it resolves, and one link more yields none.
    @Test(arguments: [(31, true), (32, true), (33, false)])
    func aLinkChainWithinTheBudgetResolvesAndOneBeyondItYieldsNone(links: Int, resolves: Bool) throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeFile(["program"])
        try tree.makeLink("program", at: ["l1"])
        for number in 2...links { try tree.makeLink("l\(number - 1)", at: ["l\(number)"]) }
        let expected = try #require(tree.identity(["program"]))
        #expect(Self.identity(tree, ["l\(links)"]) == (resolves ? expected : nil))
    }

    /// The same file is the same identity under any spelling, a hard link included, and another file is another one: a
    /// copy of the bytes is a mismatch, which is what the receipt's third step exists to tell.
    @Test func theSameFileIsOneIdentityAndACopyIsAnother() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeFile(["program"], contents: [1, 2, 3])
        try tree.hardLink(["program"], to: ["second-name"])
        try tree.makeFile(["copy"], contents: [1, 2, 3])
        let program = try #require(Self.identity(tree, ["program"]))
        #expect(Self.identity(tree, ["second-name"]) == program)
        #expect(Self.identity(tree, ["copy"]) != nil && Self.identity(tree, ["copy"]) != program)
    }

    // MARK: Every other outcome yields none

    @Test func aMissingNameADanglingLinkAndANameBelowAFileYieldNone() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeFile(["file"])
        try tree.makeLink("no-such-target", at: ["dangling"])
        #expect(Self.identity(tree, ["missing"]) == nil)
        #expect(Self.identity(tree, ["dangling"]) == nil)
        #expect(Self.identity(tree, ["file", "below"]) == nil)
    }

    @Test func aCycleAndAnImpossibleNameYieldNone() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeLink("b", at: ["a"])
        try tree.makeLink("a", at: ["b"])
        try tree.makeLink("self", at: ["self"])
        #expect(Self.identity(tree, ["a"]) == nil)
        #expect(Self.identity(tree, ["self"]) == nil)
        #expect(Self.identity(tree, [String(repeating: "n", count: 300)]) == nil, "no such name can exist")
    }

    @Test func aDirectoryWithoutSearchPermissionYieldsNoneAndItsNeighbourStillResolves() throws {
        try #require(geteuid() != 0, "root is not denied")
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeDirectories(["locked"])
        try tree.makeFile(["locked", "program"])
        try tree.makeFile(["open-program"])
        try tree.chmod(["locked"], 0o000)
        #expect(Self.identity(tree, ["locked", "program"]) == nil, "a denial is no identity and never another outcome")
        #expect(Self.identity(tree, ["open-program"]) != nil)
    }

    @Test func aStepThatFailsForAnyOtherReasonYieldsNone() throws {
        let tree = try WalkTree()
        defer { tree.remove() }
        try tree.makeFile(["program"])
        let path = Array(tree.path(["program"]).utf8)
        #expect(ExecutableIdentity.of(path: path, using: DarwinWalkSystem()) != nil)
        #expect(ExecutableIdentity.of(path: path, using: Failing(failing: .status)) == nil)
        #expect(ExecutableIdentity.of(path: path, using: Failing(failing: .root)) == nil)
    }

    @Test(arguments: ["", "program", "./program", "a/b/c"])
    func aSpellingThatIsNotAbsoluteIsUnavailableAndIsNeverReadFromTheRoot(spelling: String) {
        #expect(ExecutableIdentity.of(path: Array(spelling.utf8)) == nil)
    }

    /// The real filesystem, except one call: a stand-in for a step that fails for a reason with no meaning of its own.
    struct Failing: WalkSystem {
        enum Call { case root, status }
        let failing: Call
        private let real = DarwinWalkSystem()

        func openRoot() -> Result<Int32, WalkErrno> {
            failing == .root ? .failure(WalkErrno(code: EIO)) : real.openRoot()
        }
        func openDirectory(in directory: Int32, name: [UInt8]) -> Result<Int32, WalkErrno> {
            real.openDirectory(in: directory, name: name)
        }
        func status(in directory: Int32, name: [UInt8]) -> Result<WalkStatus, WalkErrno> {
            failing == .status ? .failure(WalkErrno(code: EIO)) : real.status(in: directory, name: name)
        }
        func status(of directory: Int32) -> Result<WalkStatus, WalkErrno> { real.status(of: directory) }
        func linkText(in directory: Int32, name: [UInt8]) -> Result<[UInt8], WalkErrno> {
            real.linkText(in: directory, name: name)
        }
        func nameLimit(of directory: Int32) -> Int? { real.nameLimit(of: directory) }
        func close(_ handle: Int32) { real.close(handle) }
    }
}
