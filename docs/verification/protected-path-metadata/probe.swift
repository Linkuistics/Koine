// Disposable native evidence tool. Launch this signed app only in an isolated VM.
import AppKit
import CoreServices
import Darwin
import Foundation

@MainActor
final class ProbeDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 650, height: 120),
            styleMask: [.titled, .closable], backing: .buffered, defer: false
        )
        window.title = "Koine K73 metadata probe"
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
        try data.write(to: URL(fileURLWithPath: "/tmp/koine-k73-\(suffix).json"), options: .atomic)
    }

    private func run() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        guard arguments.count == 3 else {
            NSApp.terminate(nil)
            return
        }
        let mode = arguments[0]
        let path = arguments[1]
        let identifier = arguments[2]
        var record: [String: Any] = [
            "mode": mode, "path": path, "fixtureIdentifier": identifier,
            "pid": getpid(), "parentPID": getppid(),
            "probeIdentifier": Bundle.main.bundleIdentifier ?? "unknown",
            "startedAt": ISO8601DateFormatter().string(from: Date()),
        ]
        do {
            try write(record, suffix: "begin")
            let url = URL(fileURLWithPath: path)
            switch mode {
            case "lstat", "stat":
                var information = stat()
                let status = mode == "lstat" ? lstat(path, &information) : stat(path, &information)
                let code = errno
                record["return"] = status
                if status == 0 {
                    record["device"] = information.st_dev
                    record["inode"] = information.st_ino
                    record["fileMode"] = information.st_mode
                    record["outcome"] = "value"
                } else {
                    record["outcome"] = "posix-error"
                    record["errno"] = code
                    record["message"] = String(cString: strerror(code))
                }
            case "realpath":
                if let resolved = realpath(path, nil) {
                    record["value"] = String(cString: resolved)
                    record["outcome"] = "value"
                    free(resolved)
                } else {
                    let code = errno
                    record["outcome"] = "posix-error"
                    record["errno"] = code
                    record["message"] = String(cString: strerror(code))
                }
            case "resolve-url":
                record["value"] = url.resolvingSymlinksInPath().path
                record["outcome"] = "value-without-error-channel"
            case "resource-application", "resource-type", "resource-volume", "resource-file", "resource-alias":
                let keys: [String: URLResourceKey] = [
                    "resource-application": .isApplicationKey,
                    "resource-type": .contentTypeKey,
                    "resource-volume": .volumeIdentifierKey,
                    "resource-file": .fileResourceIdentifierKey,
                    "resource-alias": .isAliasFileKey,
                ]
                guard let key = keys[mode] else { preconditionFailure("Missing probe key") }
                let values = try url.resourceValues(forKeys: [key])
                record["key"] = key.rawValue
                record["values"] = values.allValues.mapValues { String(describing: $0) }
                record["outcome"] = values.allValues[key] == nil ? "nil-indeterminate" : "value"
            case "bundle":
                let bundle = Bundle(url: url)
                record["constructed"] = bundle != nil
                record["value"] = bundle?.bundleIdentifier ?? NSNull()
                record["outcome"] = bundle?.bundleIdentifier == nil ? "nil-indeterminate" : "value"
            case "registered-app":
                let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier)
                record["value"] = appURL?.path ?? NSNull()
                record["outcome"] = appURL == nil ? "nil-indeterminate" : "value"
            case "default-handler":
                let appURL = NSWorkspace.shared.urlForApplication(toOpen: url)
                record["value"] = appURL?.path ?? NSNull()
                record["outcome"] = appURL == nil ? "nil-indeterminate" : "value"
            case "content-read-control":
                record["byteCount"] = try Data(contentsOf: url).count
                record["outcome"] = "value"
            default:
                throw NSError(domain: "K73Probe", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown mode"])
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
