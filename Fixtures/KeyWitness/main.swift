import AppKit

// Key witness: test material for docs/verification/keystroke-route-vm.md. Run
// it only inside a TestAnyware VM.
//
// usage: open KeyWitness.app --args <log file>
//
// A regular app with one window titled "Key Witness". It activates itself at
// launch. It records each key-down, key-up and modifier change that reaches
// it as one JSON line in the log file. Each line holds the key code, the
// modifier flags, whether the app was active, and the process and source user
// data that the event carries. So a caller can see which keys reached the
// front app, in what order, and from which sender.
//
// The witness swallows each key, so a chord that reaches it does nothing
// else. It shares no code with the keystroke probe.

let logPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : NSHomeDirectory() + "/keywitness.jsonl"
FileManager.default.createFile(atPath: logPath, contents: nil)
let log = FileHandle(forWritingAtPath: logPath)!

func record(_ event: NSEvent) {
    let kind: String
    switch event.type {
    case .keyDown: kind = "keyDown"
    case .keyUp: kind = "keyUp"
    default: kind = "flagsChanged"
    }
    var entry: [String: Any] = [
        "kind": kind, "keycode": Int(event.keyCode),
        "flags": Int(event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue),
        "active": NSApp.isActive, "time": Date().timeIntervalSince1970,
    ]
    if let cgEvent = event.cgEvent {
        entry["sourcePid"] = Int(cgEvent.getIntegerValueField(.eventSourceUnixProcessID))
        entry["sourceUserData"] = Int(cgEvent.getIntegerValueField(.eventSourceUserData))
    }
    let line = String(decoding: try! JSONSerialization.data(withJSONObject: entry, options: [.sortedKeys]),
                      as: UTF8.self)
    log.seekToEndOfFile()
    log.write(Data((line + "\n").utf8))
}

final class Delegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(contentRect: NSRect(x: 200, y: 300, width: 420, height: 160),
                              styleMask: [.titled], backing: .buffered, defer: false)
        window.title = "Key Witness"
        let label = NSTextField(labelWithString: "Records every key that reaches this app.")
        label.frame = NSRect(x: 20, y: 70, width: 380, height: 20)
        window.contentView?.addSubview(label)
        window.makeKeyAndOrderFront(nil)
        self.window = window
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { event in
            record(event)
            return nil
        }
        NSApp.activate()
    }
}

let app = NSApplication.shared
let delegate = Delegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
