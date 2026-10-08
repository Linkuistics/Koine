import Darwin
import Foundation

// Resolving an action location component by component, as the kernel would and with no whole-path call
// (docs/specs/workspace-launch-and-open.md "Resolving an action location",
// docs/adr/filesystem-access-is-descriptor-relative.md). Every step is one single-component call from a
// held search-only directory handle, so an error names its component. The walk lists nothing and opens no
// file, holds at most two handles (the current directory and the next) and closes both before it returns,
// and has no recovery branch: a failed step is the outcome.
//
// It works in bytes, never in `String`: a link's text and a name are handed to the next call exactly as the
// filesystem gave them, so no spelling is normalized, repaired or rewritten.
//
// First-use prompts: this call sequence (`openat` with `O_SEARCH`, `fstatat`, `readlinkat`) was measured
// prompt-free on Desktop, Documents and Downloads (docs/verification/descriptor-walk-prompt.md).

/// An errno from a native call, kept apart from a value so a failure cannot be read as one.
struct WalkErrno: Error, Equatable, Sendable {
    let code: Int32
    var message: String { String(cString: strerror(code)) }
}

/// A file object as the filesystem names it: the device and the inode, never a path.
struct ObjectIdentity: Hashable, Sendable {
    let device: Int32
    let inode: UInt64
}

enum ObjectType: Equatable, Sendable {
    case directory, symbolicLink, regularFile
    /// Any other file type, by its `st_mode` type bits.
    case other(UInt16)

    init(mode: UInt16) {
        switch mode & UInt16(S_IFMT) {
        case UInt16(S_IFDIR): self = .directory
        case UInt16(S_IFLNK): self = .symbolicLink
        case UInt16(S_IFREG): self = .regularFile
        default: self = .other(mode & UInt16(S_IFMT))
        }
    }
}

struct WalkStatus: Equatable, Sendable {
    let identity: ObjectIdentity
    let type: ObjectType
}

/// What the walk asks of the filesystem. Each call takes one component (or one handle), so it is the
/// seam where a test supplies what no host fixture can: a name limit that cannot be read, a link whose
/// text changes between two reads.
protocol WalkSystem {
    /// A search-only handle (`O_SEARCH`) on the filesystem root.
    func openRoot() -> Result<Int32, WalkErrno>
    /// A search-only handle (`O_SEARCH`) on the directory `name` in `directory`. Grants lookup, never listing.
    func openDirectory(in directory: Int32, name: [UInt8]) -> Result<Int32, WalkErrno>
    /// `fstatat(directory, name, AT_SYMLINK_NOFOLLOW)`: the entry itself, a link included.
    func status(in directory: Int32, name: [UInt8]) -> Result<WalkStatus, WalkErrno>
    /// `fstat` of a held handle.
    func status(of directory: Int32) -> Result<WalkStatus, WalkErrno>
    /// `readlinkat`: the link's own text, exactly.
    func linkText(in directory: Int32, name: [UInt8]) -> Result<[UInt8], WalkErrno>
    /// `fpathconf(directory, _PC_NAME_MAX)`; nil when the filesystem will not say (`-1`).
    func nameLimit(of directory: Int32) -> Int?
    func close(_ handle: Int32)
}

/// The real filesystem.
struct DarwinWalkSystem: WalkSystem {
    /// `O_SEARCH` is `O_EXEC | O_DIRECTORY`: lookup permission, no read of the directory.
    private static let searchOnly = O_SEARCH

    private static func name(_ bytes: [UInt8]) -> [CChar] { bytes.map { CChar(bitPattern: $0) } + [0] }

    func openRoot() -> Result<Int32, WalkErrno> {
        errno = 0
        let handle = openat(AT_FDCWD, "/", Self.searchOnly)
        return handle >= 0 ? .success(handle) : .failure(WalkErrno(code: errno))
    }

    func openDirectory(in directory: Int32, name: [UInt8]) -> Result<Int32, WalkErrno> {
        errno = 0
        let handle = openat(directory, Self.name(name), Self.searchOnly)
        return handle >= 0 ? .success(handle) : .failure(WalkErrno(code: errno))
    }

    func status(in directory: Int32, name: [UInt8]) -> Result<WalkStatus, WalkErrno> {
        var buffer = stat()
        errno = 0
        guard fstatat(directory, Self.name(name), &buffer, AT_SYMLINK_NOFOLLOW) == 0 else {
            return .failure(WalkErrno(code: errno))
        }
        return .success(Self.status(buffer))
    }

    func status(of directory: Int32) -> Result<WalkStatus, WalkErrno> {
        var buffer = stat()
        errno = 0
        guard fstat(directory, &buffer) == 0 else { return .failure(WalkErrno(code: errno)) }
        return .success(Self.status(buffer))
    }

    func linkText(in directory: Int32, name: [UInt8]) -> Result<[UInt8], WalkErrno> {
        // A link's text is at most PATH_MAX - 1 bytes; one more byte than that can only mean a longer link.
        var buffer = [UInt8](repeating: 0, count: Int(PATH_MAX) + 1)
        errno = 0
        let length = buffer.withUnsafeMutableBytes {
            readlinkat(directory, Self.name(name), $0.baseAddress?.assumingMemoryBound(to: CChar.self), $0.count)
        }
        guard length >= 0 else { return .failure(WalkErrno(code: errno)) }
        guard length < buffer.count else { return .failure(WalkErrno(code: ENAMETOOLONG)) }
        return .success(Array(buffer.prefix(length)))
    }

    func nameLimit(of directory: Int32) -> Int? {
        errno = 0
        let limit = fpathconf(directory, _PC_NAME_MAX)
        return limit >= 0 ? limit : nil
    }

    func close(_ handle: Int32) { _ = Darwin.close(handle) }

    private static func status(_ buffer: stat) -> WalkStatus {
        WalkStatus(
            identity: ObjectIdentity(device: buffer.st_dev, inode: UInt64(buffer.st_ino)),
            type: ObjectType(mode: UInt16(buffer.st_mode)))
    }
}

/// A path as bytes. Lengths are the pathname's bytes, never its terminating NUL.
struct Spelling: Equatable, Sendable {
    let bytes: [UInt8]
    var byteCount: Int { bytes.count }
    /// For a message only: invalid UTF-8 is repaired here and nowhere that is submitted.
    var text: String { String(decoding: bytes, as: UTF8.self) }
}

/// What a location is when every component resolves.
struct ResolvedLocation: Equatable, Sendable {
    /// The caller's path, as written.
    let literal: Spelling
    /// What the platform would still have to resolve after each link expansion, in order: the link's text
    /// followed by the exact path that remained after the link.
    let expansions: [Spelling]
    /// The physical path, with every link expanded and every `.` and `..` applied.
    let resolved: Spelling
    let identity: ObjectIdentity
    let type: ObjectType

    /// Every spelling a whole-pathname platform service could be asked to take, in the order the walk met them.
    var spellings: [(kind: SpellingKind, spelling: Spelling)] {
        [(.literal, literal)] + expansions.enumerated().map { (.expanded(number: $0.offset + 1), $0.element) }
            + [(.resolved, resolved)]
    }
}

enum SpellingKind: Equatable, Sendable {
    case literal
    /// The `number`th (from 1) link expansion's remaining path.
    case expanded(number: Int)
    case resolved
}

/// Why a location is not there.
enum Absence: Equatable, Sendable {
    /// A component does not exist, or a dangling link.
    case missing(component: String)
    /// A non-directory sits where a directory is required, a trailing slash after a file included.
    case notDirectory(component: String)
    /// An ASCII name longer than the directory's own name limit: no such name can exist.
    case impossibleComponent(component: String)
    /// The same link was expanded in the same state before: it would recur at any budget.
    case cycle(link: String)

    /// The two absences an application location reports as `failed` rather than as a missing dependency.
    var isImpossibleOrCycle: Bool {
        switch self {
        case .impossibleComponent, .cycle: return true
        case .missing, .notDirectory: return false
        }
    }
}

enum LocationResolution: Equatable, Sendable {
    case present(ResolvedLocation)
    case absent(Absence)
    /// A step could not be completed and nothing says the location is absent. Never read as absence.
    case failed(component: String, cause: String)
}

/// The walk. `resolve` is the whole of it.
enum LocationWalk {
    /// The kernel's own limit on link expansions in one lookup (`MAXSYMLINKS`): up to 32 are allowed.
    static let linkBudget = 32

    static func resolve(_ path: String) -> LocationResolution {
        resolve(Array(path.utf8), using: DarwinWalkSystem())
    }

    static func resolve(_ literal: [UInt8], using system: some WalkSystem) -> LocationResolution {
        var walk = Walk(system: system, literal: literal)
        let outcome = walk.run()
        walk.release()
        return outcome
    }
}

/// The resolver state for one location. A class-free value: nothing outlives `resolve`.
private struct Walk<System: WalkSystem> {
    /// The resolver's state at a link expansion: the containing directory, the link's text and the path
    /// pending after it, a run of slashes counted as one. What follows an expansion depends on nothing else, so a repeated state
    /// would recur at any budget.
    private struct LinkState: Hashable {
        let directory: ObjectIdentity
        let text: [UInt8]
        let suffix: [UInt8]
    }

    private static var slash: UInt8 { UInt8(ascii: "/") }
    private static var dot: UInt8 { UInt8(ascii: ".") }

    let system: System
    let literal: [UInt8]
    /// The one directory handle held between steps; nil once closed.
    private var current: Int32?
    /// The physical path of `current`, component by component.
    private var stack: [[UInt8]] = []
    private var pending: [UInt8]
    /// Bytes already consumed from `pending`; only a link expansion replaces the array.
    private var pendingIndex = 0
    private var expansions: [[UInt8]] = []
    private var visited: Set<LinkState> = []
    private var linkTexts: [ObjectIdentity: [UInt8]] = [:]

    init(system: System, literal: [UInt8]) {
        self.system = system
        self.literal = literal
        self.pending = literal
    }

    mutating func release() {
        if let handle = current { system.close(handle) }
        current = nil
    }

    // MARK: Walking

    mutating func run() -> LocationResolution {
        switch system.openRoot() {
        case .success(let handle): current = handle
        case .failure(let error): return .failed(component: "/", cause: error.message)
        }
        while true {
            // The kernel's own parse: any run of slashes separates, a leading run is skipped.
            while pendingIndex < pending.count, pending[pendingIndex] == Self.slash { pendingIndex += 1 }
            guard pendingIndex < pending.count else { return finishAtCurrentDirectory() }
            let start = pendingIndex
            while pendingIndex < pending.count, pending[pendingIndex] != Self.slash { pendingIndex += 1 }
            let name = Array(pending[start..<pendingIndex])
            let rest = pending[pendingIndex...]
            // Nothing but slashes (or nothing) follows the name: this is the final component, and a slash
            // after it demands a directory.
            let isFinal = rest.allSatisfy { $0 == Self.slash }
            let demandsDirectory = !rest.isEmpty && isFinal
            guard let handle = current else { return .failed(component: Self.text(name), cause: "no directory is open") }

            if name == [Self.dot] {
                guard !isFinal else { return finishAtCurrentDirectory() }
                continue
            }
            if name == [Self.dot, Self.dot] {
                if isFinal { return finishAtParent(of: handle) }
                switch system.openDirectory(in: handle, name: name) {
                case .success(let parent):
                    system.close(handle)
                    current = parent
                    if !stack.isEmpty { stack.removeLast() }
                    continue
                case .failure(let error): return classify(error, component: name, in: handle)
                }
            }

            let status: WalkStatus
            switch system.status(in: handle, name: name) {
            case .success(let found): status = found
            case .failure(let error): return classify(error, component: name, in: handle)
            }
            switch status.type {
            case .symbolicLink:
                if let outcome = expandLink(name, in: handle, status: status, rest: rest) { return outcome }
            case .directory where isFinal:
                // Examined and never opened: a final directory needs no search permission of its own.
                return present(status, finalName: name)
            case .directory:
                switch system.openDirectory(in: handle, name: name) {
                case .success(let next):
                    system.close(handle)
                    current = next
                    stack.append(name)
                case .failure(let error): return classify(error, component: name, in: handle)
                }
            default:
                guard isFinal, !demandsDirectory else { return .absent(.notDirectory(component: Self.text(name))) }
                return present(status, finalName: name)
            }
        }
    }

    /// Expands the link `name` in `directory`, or the outcome that ends the walk. Nil means the link was
    /// spliced into `pending` and the walk goes on.
    private mutating func expandLink(
        _ name: [UInt8], in directory: Int32, status: WalkStatus, rest: ArraySlice<UInt8>
    ) -> LocationResolution? {
        let text: [UInt8]
        switch system.linkText(in: directory, name: name) {
        case .success(let read): text = read
        case .failure(let error): return classify(error, component: name, in: directory)
        }
        // One link read twice with different text is a changed observation.
        if let before = linkTexts[status.identity], before != text {
            return .failed(component: Self.text(name), cause: "the link's text changed while it was being resolved")
        }
        linkTexts[status.identity] = text
        // An empty link is no name at all, as for the kernel.
        guard !text.isEmpty else { return .absent(.missing(component: Self.text(name))) }

        let containing: ObjectIdentity
        switch system.status(of: directory) {
        case .success(let found): containing = found.identity
        case .failure(let error): return .failed(component: Self.text(name), cause: error.message)
        }
        let state = LinkState(directory: containing, text: text, suffix: Self.collapsingSlashes(rest))
        if visited.contains(state) { return .absent(.cycle(link: Self.text(name))) }
        guard expansions.count < LocationWalk.linkBudget else {
            return .failed(
                component: Self.text(name),
                cause: "more than \(LocationWalk.linkBudget) symbolic links had to be followed")
        }
        visited.insert(state)
        let remainder = text + Array(rest)
        expansions.append(remainder)
        if text.first == Self.slash {
            // Absolute: back to the root, with the handle on the link's own directory closed first.
            system.close(directory)
            current = nil
            switch system.openRoot() {
            case .success(let root): current = root
            case .failure(let error): return .failed(component: "/", cause: error.message)
            }
            stack = []
        }
        pending = remainder
        pendingIndex = 0
        return nil
    }

    // MARK: Ending

    /// The location is the directory the walk stands in: `/`, a trailing `.`, or a path of slashes.
    private mutating func finishAtCurrentDirectory() -> LocationResolution {
        guard let handle = current else { return .failed(component: "/", cause: "no directory is open") }
        switch system.status(of: handle) {
        case .success(let status): return present(status, finalName: nil)
        case .failure(let error): return .failed(component: Self.text(Array(stack.last ?? [Self.slash])), cause: error.message)
        }
    }

    /// A final `..`: the parent is examined from the current directory and not opened, so it needs no
    /// search permission of its own.
    private mutating func finishAtParent(of handle: Int32) -> LocationResolution {
        switch system.status(in: handle, name: [Self.dot, Self.dot]) {
        case .success(let status):
            if !stack.isEmpty { stack.removeLast() }
            return present(status, finalName: nil)
        case .failure(let error): return classify(error, component: [Self.dot, Self.dot], in: handle)
        }
    }

    private mutating func present(_ status: WalkStatus, finalName: [UInt8]?) -> LocationResolution {
        var components = stack
        if let finalName { components.append(finalName) }
        let resolved = [Self.slash] + Array(components.joined(separator: [Self.slash]))
        return .present(
            ResolvedLocation(
                literal: Spelling(bytes: literal), expansions: expansions.map { Spelling(bytes: $0) },
                resolved: Spelling(bytes: resolved), identity: status.identity, type: status.type))
    }

    // MARK: Errors

    /// What a failed step means. A name that is not there is absent. A name too long for its directory is
    /// absent only where the comparison cannot depend on the filesystem's unit (an ASCII name, whose bytes,
    /// UTF-16 units and characters agree under every normal form) and the directory itself gave the limit;
    /// every other name-length refusal is a failure. A denial is a failure and never absence.
    private func classify(_ error: WalkErrno, component name: [UInt8], in directory: Int32) -> LocationResolution {
        let component = Self.text(name)
        switch error.code {
        case ENOENT: return .absent(.missing(component: component))
        case ENOTDIR: return .absent(.notDirectory(component: component))
        case ENAMETOOLONG:
            guard let limit = system.nameLimit(of: directory) else {
                return .failed(component: component, cause: "its name is too long and the filesystem's name limit cannot be read")
            }
            if name.allSatisfy({ $0 < 0x80 }), name.count > limit { return .absent(.impossibleComponent(component: component)) }
            return .failed(component: component, cause: error.message)
        default: return .failed(component: component, cause: error.message)
        }
    }

    /// The kernel reads a run of slashes as one, so `a/` and `a//` resume the walk identically. A link whose
    /// text ends in a slash gains one on every lap (`a` -> `a/`), which is a cycle and no new state.
    private static func collapsingSlashes(_ bytes: ArraySlice<UInt8>) -> [UInt8] {
        var collapsed: [UInt8] = []
        for byte in bytes where !(byte == slash && collapsed.last == slash) { collapsed.append(byte) }
        return collapsed
    }

    private static func text(_ bytes: [UInt8]) -> String { String(decoding: bytes, as: UTF8.self) }
}
