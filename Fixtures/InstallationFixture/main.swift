import AppKit
import Foundation

// Test material, never shipped: the registered application of
// docs/verification/application-installations-vm.md. It is built once and copied to several
// locations, so that one bundle identifier names several installed copies, and each copy
// writes down which copy it is and what it was handed. It holds no Koine code, needs no
// account, no network and no Accessibility, and does nothing but record.
//
// Each line of the log is JSON:
//   {"atMs": <ms since the epoch>, "event": "launched" | "reopen" | "open",
//    "label": "<the copy's own name, from its Info.plist>", "bundlePath": "<where this copy
//    is>", "pid": <pid>, "path": "<document>"?}
// "launched" is the copy's own start, "reopen" is the system asking a running copy to come
// forward again (what a launch or an open of a running application becomes), and "open" is
// a document handed to it. The log is $HOME/install-fixture.jsonl, or INSTALL_FIXTURE_LOG.

func nowMs() -> Int { Int((Date().timeIntervalSince1970 * 1000).rounded()) }

let logPath = ProcessInfo.processInfo.environment["INSTALL_FIXTURE_LOG"]
    ?? (NSHomeDirectory() + "/install-fixture.jsonl")

func record(_ event: String, path: String? = nil) {
    var object: [String: Any] = [
        "atMs": nowMs(), "event": event, "bundlePath": Bundle.main.bundlePath,
        "label": (Bundle.main.object(forInfoDictionaryKey: "KoineCopyLabel") as? String) ?? "?",
        "pid": Int(ProcessInfo.processInfo.processIdentifier),
    ]
    if let path { object["path"] = path }
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]) else { return }
    let line = data + Data("\n".utf8)
    if let handle = FileHandle(forWritingAtPath: logPath) {
        handle.seekToEndOfFile()
        handle.write(line)
        try? handle.close()
    } else {
        FileManager.default.createFile(atPath: logPath, contents: line)
    }
}

final class Delegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let label = (Bundle.main.object(forInfoDictionaryKey: "KoineCopyLabel") as? String) ?? "?"
        let window = NSWindow(
            contentRect: NSRect(x: 240, y: 240, width: 460, height: 90),
            styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "InstallationFixture \(label)"
        let text = NSTextField(labelWithString: "Copy \(label), at \(Bundle.main.bundlePath)")
        text.frame = NSRect(x: 12, y: 30, width: 436, height: 24)
        window.contentView?.addSubview(text)
        window.makeKeyAndOrderFront(nil)
        self.window = window
        record("launched")
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { record("open", path: url.path) }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        record("reopen")
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

let application = NSApplication.shared
let delegate = Delegate()
application.delegate = delegate
application.setActivationPolicy(.regular)
application.run()
