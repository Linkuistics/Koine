import Darwin
import Foundation

/// A fresh directory with every fixture built component by component from held handles: no whole-path
/// `mkdir`, `open` or `symlink` ever addresses a long location.
public final class WalkTree: @unchecked Sendable {
    /// The real (link-free) path of the fixture root.
    public let root: String

    /// A directory name of exactly 245 bytes, distinct for each index.
    public static func segment(_ index: Int) -> String {
        let label = "d\(index)-"
        return label + String(repeating: "x", count: 245 - label.utf8.count)
    }

    public init() throws {
        // `realpath`, not Foundation's `resolvingSymlinksInPath`, which leaves `/var` for `/private/var`.
        guard let resolved = realpath(NSTemporaryDirectory(), nil) else { throw WalkTreeError.call("realpath", errno) }
        defer { free(resolved) }
        let base = String(cString: resolved)
        var template = Array((base + "/koine-k174-XXXXXX").utf8CString)
        guard mkdtemp(&template) != nil else { throw WalkTreeError.call("mkdtemp", errno) }
        root = String(cString: template)
    }

    public func path(_ parts: [String]) -> String { ([root] + parts).joined(separator: "/") }

    // MARK: Building

    /// Opens `parts` under the root, one component at a time, and runs `body` with the directory handle.
    private func withDirectory<T>(_ parts: [String], _ body: (Int32) throws -> T) throws -> T {
        var handle = open(root, O_RDONLY | O_DIRECTORY)
        guard handle >= 0 else { throw WalkTreeError.call("open", errno) }
        defer { close(handle) }
        for part in parts {
            let next = openat(handle, part, O_RDONLY | O_DIRECTORY)
            guard next >= 0 else { throw WalkTreeError.call("openat \(part.prefix(20))", errno) }
            close(handle)
            handle = next
        }
        return try body(handle)
    }

    public func makeDirectories(_ parts: [String]) throws {
        var handle = open(root, O_RDONLY | O_DIRECTORY)
        guard handle >= 0 else { throw WalkTreeError.call("open", errno) }
        defer { close(handle) }
        for part in parts {
            if mkdirat(handle, part, 0o755) != 0, errno != EEXIST { throw WalkTreeError.call("mkdirat", errno) }
            let next = openat(handle, part, O_RDONLY | O_DIRECTORY)
            guard next >= 0 else { throw WalkTreeError.call("openat", errno) }
            close(handle)
            handle = next
        }
    }

    public func makeFile(_ parts: [String], contents: [UInt8] = [], mode: mode_t = 0o644) throws {
        guard let name = parts.last else { return }
        try withDirectory(Array(parts.dropLast())) { directory in
            let file = openat(directory, name, O_CREAT | O_WRONLY | O_EXCL, mode)
            guard file >= 0 else { throw WalkTreeError.call("openat create", errno) }
            defer { close(file) }
            var written = 0
            while written < contents.count {
                let count = contents[written...].withUnsafeBytes { write(file, $0.baseAddress, $0.count) }
                guard count > 0 else { throw WalkTreeError.call("write", errno) }
                written += count
            }
            // The creation mode is masked by the umask; the fixture's mode is exact.
            guard fchmod(file, mode) == 0 else { throw WalkTreeError.call("fchmod", errno) }
        }
    }

    /// A file whose whole path, the root's included, is exactly `length` bytes: 245-byte directories (`segment`)
    /// and then a name of 1 to 255 bytes. The parts are returned.
    public func makeFile(pathLength length: Int, contents: [UInt8] = [], mode: mode_t = 0o644) throws -> [String] {
        var directories = (length - root.utf8.count - 2) / 246
        while directories >= 0 {
            let name = length - root.utf8.count - directories * 246 - 1
            if (1...255).contains(name) {
                let parts = (0..<directories).map { Self.segment($0) } + [String(repeating: "f", count: name)]
                try makeDirectories(Array(parts.dropLast()))
                try makeFile(parts, contents: contents, mode: mode)
                return parts
            }
            directories -= 1
        }
        throw WalkTreeError.call("no chain of length \(length)", 0)
    }

    public func makeLink(_ text: String, at parts: [String]) throws {
        guard let name = parts.last else { return }
        try withDirectory(Array(parts.dropLast())) { directory in
            guard symlinkat(text, directory, name) == 0 else { throw WalkTreeError.call("symlinkat", errno) }
        }
    }

    public func hardLink(_ existing: [String], to new: [String]) throws {
        guard let from = existing.last, let to = new.last else { return }
        try withDirectory(Array(existing.dropLast())) { source in
            try withDirectory(Array(new.dropLast())) { destination in
                // Without AT_SYMLINK_FOLLOW: the link itself gets a second entry.
                guard linkat(source, from, destination, to, 0) == 0 else { throw WalkTreeError.call("linkat", errno) }
            }
        }
    }

    public func chmod(_ parts: [String], _ mode: mode_t) throws {
        guard let name = parts.last else { return }
        try withDirectory(Array(parts.dropLast())) { directory in
            guard fchmodat(directory, name, mode, 0) == 0 else { throw WalkTreeError.call("fchmodat", errno) }
        }
    }

    /// The device and inode of the object `parts` names, by component-relative calls.
    public func fileKey(_ parts: [String], followLink: Bool = true) -> FileKey? {
        guard let name = parts.last else { return nil }
        return try? withDirectory(Array(parts.dropLast())) { directory in
            var status = stat()
            guard fstatat(directory, name, &status, followLink ? 0 : AT_SYMLINK_NOFOLLOW) == 0 else {
                throw WalkTreeError.call("fstatat", errno)
            }
            return FileKey(device: status.st_dev, inode: UInt64(status.st_ino))
        }
    }

    // MARK: Removing

    public func remove() {
        let handle = open(root, O_RDONLY | O_DIRECTORY)
        guard handle >= 0 else { return }
        Self.empty(handle)
        close(handle)
        rmdir(root)
    }

    /// Empties a directory, by handle, so a long tree needs no whole-path call to go away.
    private static func empty(_ directory: Int32) {
        fchmod(directory, 0o755)
        guard let stream = fdopendir(dup(directory)) else { return }
        var names: [String] = []
        rewinddir(stream)
        while let entry = readdir(stream) {
            let name = withUnsafePointer(to: &entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(entry.pointee.d_namlen) + 1) { String(cString: $0) }
            }
            if name != "." && name != ".." { names.append(name) }
        }
        closedir(stream)
        for name in names {
            var status = stat()
            guard fstatat(directory, name, &status, AT_SYMLINK_NOFOLLOW) == 0 else { continue }
            if (status.st_mode & S_IFMT) == S_IFDIR {
                fchmodat(directory, name, 0o755, 0)
                let child = openat(directory, name, O_RDONLY | O_DIRECTORY)
                if child >= 0 {
                    empty(child)
                    close(child)
                }
                unlinkat(directory, name, AT_REMOVEDIR)
            } else {
                unlinkat(directory, name, 0)
            }
        }
    }
}

/// The device and inode of an object, as the filesystem names it.
public struct FileKey: Hashable, Sendable {
    public let device: Int32
    public let inode: UInt64
}

public enum WalkTreeError: Error { case call(String, Int32) }
