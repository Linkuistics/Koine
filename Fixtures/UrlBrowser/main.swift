import AppKit
import Foundation

// Test material, never shipped: the alternate default browser of
// docs/verification/open-url-vm.md. It is a browser to the system - it declares the http
// and https schemes and HTML documents, so the system lists it, lets it be made the default
// browser and hands it web URLs - and it does nothing with them but write down exactly what
// it was handed. It holds no Koine code, needs no account, no network and no Accessibility,
// and shows no page, so what it records is the system's own delivery of the URL to the
// application a client asked for, byte for byte, with the guest's clock.
//
// Two routes are recorded because a URL can arrive either way: the classic GetURL Apple
// event, whose payload is the string as it was sent, and the open-URLs delegate call, whose
// payload is an NSURL (the system may have parsed it). Each line is JSON:
//   {"atMs": <ms since the epoch>, "route": "getURL" | "openURLs", "url": "<string>"}
// The log is $HOME/url-browser.jsonl, or the path in URL_BROWSER_LOG.

func nowMs() -> Int { Int((Date().timeIntervalSince1970 * 1000).rounded()) }

let logPath = ProcessInfo.processInfo.environment["URL_BROWSER_LOG"]
    ?? (NSHomeDirectory() + "/url-browser.jsonl")

func record(route: String, url: String) {
    let object: [String: Any] = ["atMs": nowMs(), "route": route, "url": url]
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

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Registered before the launch finishes, so a URL that started the application is seen.
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURL(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL))
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 420, height: 120),
            styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "UrlBrowser"
        let label = NSTextField(labelWithString: "A test browser: it records the URLs it is handed and shows none.")
        label.frame = NSRect(x: 12, y: 50, width: 396, height: 24)
        window.contentView?.addSubview(label)
        window.makeKeyAndOrderFront(nil)
        self.window = window
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func handleGetURL(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        let text = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue ?? ""
        record(route: "getURL", url: text)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { record(route: "openURLs", url: url.absoluteString) }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

let application = NSApplication.shared
let delegate = Delegate()
application.delegate = delegate
application.setActivationPolicy(.regular)
application.run()
