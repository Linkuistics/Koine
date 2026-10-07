// Disposable native evidence tool. Launch this signed app only in an isolated VM.
// Measures whether the descriptor-relative walk (docs/specs/workspace-launch-and-open.md,
// "Resolving an action location") prompts on first-use Desktop, Documents and Downloads.
import AppKit
import Darwin
import Foundation

/// One native call and what it returned, in the order it was made.
struct Call {
    let name: String
    let argument: String
    let result: Int
    let code: Int32
    var json: [String: Any] {
        var record: [String: Any] = ["call": name, "argument": argument, "return": result]
        if result < 0 { record["errno"] = code; record["message"] = String(cString: strerror(code)) }
        return record
    }
}

/// The walk's call sequence and nothing else: one search-only handle on the current directory,
/// `fstatat` and `readlinkat` of one component at a time, never an open of a file, never a
/// listing. At most two handles are held (the current directory and the next).
struct Walker {
    var calls: [Call] = []
    var links = 0
    var outcome = "unresolved"
    var failure: String?

    private mutating func record(_ name: String, _ argument: String, _ result: Int, _ code: Int32) {
        calls.append(Call(name: name, argument: argument, result: result, code: code))
    }

    private mutating func openSearch(_ directory: Int32, _ name: String) -> Int32 {
        errno = 0
        let handle = openat(directory, name, O_SEARCH)
        record("openat(O_SEARCH)", name, Int(handle), errno)
        return handle
    }

    mutating func walk(_ path: String) {
        var pending = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        let trailingSlash = path.hasSuffix("/")
        var current = openSearch(AT_FDCWD, "/")
        guard current >= 0 else { fail("root", errno); return }
        while !pending.isEmpty {
            let name = pending.removeFirst()
            let isFinal = pending.isEmpty
            if name == "." { continue }
            if name == ".." {
                let parent = openSearch(current, "..")
                close(current)
                guard parent >= 0 else { fail(name, errno); return }
                current = parent
                continue
            }
            var status = stat()
            errno = 0
            let examined = fstatat(current, name, &status, AT_SYMLINK_NOFOLLOW)
            record("fstatat(AT_SYMLINK_NOFOLLOW)", name, Int(examined), errno)
            guard examined == 0 else {
                close(current)
                fail(name, calls.last?.code ?? 0)
                return
            }
            switch status.st_mode & S_IFMT {
            case S_IFLNK:
                links += 1
                var buffer = [CChar](repeating: 0, count: 4096)
                errno = 0
                let length = readlinkat(current, name, &buffer, buffer.count - 1)
                record("readlinkat", name, length, errno)
                guard length >= 0 else { close(current); fail(name, calls.last?.code ?? 0); return }
                let text = String(decoding: buffer.prefix(length).map { UInt8(bitPattern: $0) }, as: UTF8.self)
                let parts = text.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
                if text.hasPrefix("/") {
                    close(current)
                    current = openSearch(AT_FDCWD, "/")
                    guard current >= 0 else { fail("root", errno); return }
                }
                pending = parts + pending
            case S_IFDIR where !isFinal:
                let next = openSearch(current, name)
                close(current)
                guard next >= 0 else { fail(name, errno); return }
                current = next
            case S_IFDIR:
                close(current)
                outcome = "present-directory"
                return
            default:
                close(current)
                if !isFinal || trailingSlash {
                    outcome = "absent-not-a-directory"
                } else {
                    outcome = "present-file"
                }
                return
            }
        }
        close(current)
        if outcome == "unresolved" { outcome = "present-directory" }
    }

    private mutating func fail(_ component: String, _ code: Int32) {
        failure = "\(component): \(String(cString: strerror(code)))"
        outcome = code == ENOENT || code == ENOTDIR ? "absent" : "failed"
    }
}

@MainActor
final class ProbeDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 650, height: 120),
            styleMask: [.titled, .closable], backing: .buffered, defer: false
        )
        window.title = "Koine K174 descriptor-walk probe"
        let label = NSTextField(labelWithString: CommandLine.arguments.dropFirst().joined(separator: " · "))
        label.frame = NSRect(x: 20, y: 20, width: 610, height: 80)
        label.lineBreakMode = .byWordWrapping
        window.contentView?.addSubview(label)
        window.makeKeyAndOrderFront(nil)
        self.window = window
        NSApp.activate(ignoringOtherApps: true)
        Task {
            do { try await Task.sleep(for: .milliseconds(250)) } catch { return }
            run()
        }
    }

    private func write(_ record: [String: Any], suffix: String) throws {
        let data = try JSONSerialization.data(withJSONObject: record, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: URL(fileURLWithPath: "/tmp/koine-k174-\(suffix).json"), options: .atomic)
    }

    private func run() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        guard arguments.count == 2 else {
            NSApp.terminate(nil)
            return
        }
        let mode = arguments[0]
        let path = arguments[1]
        var record: [String: Any] = [
            "mode": mode, "path": path, "pid": getpid(), "parentPID": getppid(),
            "probeIdentifier": Bundle.main.bundleIdentifier ?? "unknown",
            "startedAt": ISO8601DateFormatter().string(from: Date()),
        ]
        do {
            try write(record, suffix: "begin")
            switch mode {
            case "walk":
                var walker = Walker()
                walker.walk(path)
                record["calls"] = walker.calls.map(\.json)
                record["links"] = walker.links
                record["outcome"] = walker.outcome
                record["failure"] = walker.failure ?? NSNull()
            case "open-search", "open-read":
                // The protected directory itself, by one whole-path open: search-only, and the read-mode
                // control that k134's walk used and that prompted at Documents.
                errno = 0
                let flags = mode == "open-search" ? O_SEARCH : (O_RDONLY | O_DIRECTORY)
                let handle = open(path, flags)
                let code = errno
                record["return"] = handle
                if handle >= 0 { close(handle); record["outcome"] = "value" } else {
                    record["outcome"] = "posix-error"
                    record["errno"] = code
                    record["message"] = String(cString: strerror(code))
                }
            case "content-read-control":
                record["byteCount"] = try Data(contentsOf: URL(fileURLWithPath: path)).count
                record["outcome"] = "value"
            default:
                throw NSError(domain: "K174Probe", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown mode"])
            }
        } catch {
            let error = error as NSError
            record["outcome"] = "error"
            record["domain"] = error.domain
            record["code"] = error.code
            record["message"] = error.localizedDescription
        }
        record["finishedAt"] = ISO8601DateFormatter().string(from: Date())
        do { try write(record, suffix: "end") } catch { window?.title = "Evidence output failed: \(error)" }
    }
}

let application = NSApplication.shared
let delegate = ProbeDelegate()
application.delegate = delegate
application.setActivationPolicy(.regular)
application.run()
