import AppKit
import KoineAppDiagnostics

/// Opt-in diagnostic observation. It never requests activation or changes window
/// order. Set KoineSettingsActivationTrace to a file path in a disposable guest.
@MainActor
final class SettingsActivationTrace: NSObject {
    static let shared = SettingsActivationTrace()
    private var output: FileHandle?
    private var sequence = 0
    private var selection = 0
    private var bufferPath: String?
    private var buffer: SettingsEventBuffer<EventRecord>?
    private var dumpRequested = false

    private struct EventRecord: Encodable {
        let sequence: Int
        let selection: Int
        let event: String
        let uptime: Double
        let unixTime: Double
        let pid: Int32
        let active: Bool
        let keyWindow: Int
        let mainWindow: Int
        let settingsWindow: Int
        let settingsVisible: Bool
        let subjectPID: Int32
        let runLoopMode: String
        let currentEvent: EventContext?
    }

    private struct EventContext: Encodable {
        let type: UInt
        let timestamp: Double
        let windowNumber: Int?
        let modifierFlags: UInt

        init(_ event: NSEvent) {
            type = event.type.rawValue
            // Seconds since startup, comparable to the record's uptime.
            // https://developer.apple.com/documentation/appkit/nsevent/timestamp
            timestamp = event.timestamp
            // Reading windowNumber for periodic events is undefined.
            // https://developer.apple.com/documentation/appkit/nsevent/windownumber
            windowNumber = event.type == .periodic ? nil : event.windowNumber
            modifierFlags = event.modifierFlags.rawValue
        }
    }

    private override init() {
        super.init()
        let path = UserDefaults.standard.string(forKey: "KoineSettingsActivationTrace")
        bufferPath = UserDefaults.standard.string(forKey: "KoineSettingsEventBuffer")
        guard path == nil || bufferPath == nil else {
            bufferPath = nil
            fputs("Settings diagnostics refuse simultaneous file and memory modes\n", stderr)
            return
        }
        guard path != nil || bufferPath != nil else { return }
        if let path {
            do {
                if !FileManager.default.fileExists(atPath: path) {
                    guard FileManager.default.createFile(atPath: path, contents: nil) else {
                        throw CocoaError(.fileWriteUnknown)
                    }
                }
                output = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
                try output?.seekToEnd()
            } catch {
                fputs("Settings activation trace unavailable: \(error)\n", stderr)
                return
            }
        }
        if bufferPath != nil {
            buffer = SettingsEventBuffer(capacity: 4096)
            // Delivered on the main run loop; delivery may be delayed or dropped.
            // The notification carries no path or other trusted data. Dump only
            // after scenario observations; never post this from the call path.
            // https://developer.apple.com/documentation/foundation/distributednotificationcenter
            DistributedNotificationCenter.default().addObserver(
                self, selector: #selector(dumpBuffer(_:)),
                name: Notification.Name("dev.antony.Koine.dumpSettingsEvents"), object: nil
            )
        }
        // Notifications report native transitions; they do not request them.
        // https://developer.apple.com/documentation/appkit/nsapplication/didbecomeactivenotification
        for name in [
            NSApplication.willBecomeActiveNotification, NSApplication.didBecomeActiveNotification,
            NSApplication.willResignActiveNotification, NSApplication.didResignActiveNotification,
            NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification,
            NSWindow.didBecomeMainNotification, NSWindow.didResignMainNotification,
            NSWindow.willCloseNotification,
        ] {
            NotificationCenter.default.addObserver(self, selector: #selector(observe(_:)), name: name, object: nil)
        }
        for name in [NSWorkspace.didActivateApplicationNotification, NSWorkspace.didDeactivateApplicationNotification] {
            NSWorkspace.shared.notificationCenter.addObserver(
                self, selector: #selector(observe(_:)), name: name, object: nil
            )
        }
        record(bufferPath == nil ? "trace.started" : "buffer.started")
    }

    func beginSelection(_ source: String) {
        guard output != nil || bufferPath != nil else { return }
        selection += 1
        record("callback.\(source)")
    }

    @objc private func observe(_ notification: Notification) {
        let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
        record(notification.name.rawValue, subjectPID: app?.processIdentifier)
    }

    func record(_ event: String, subjectPID: pid_t? = nil) {
        if bufferPath != nil {
            guard !dumpRequested else { return }
            sequence += 1
            let window = NSApp.windows.first { $0.title == "Koine Settings" }
            // Last retrieved event, not proof of input origin/activation authority.
            // https://developer.apple.com/documentation/appkit/nsapplication/currentevent
            let current = NSApp.currentEvent.map(EventContext.init)
            buffer?.append(EventRecord(
                sequence: sequence, selection: selection, event: event,
                uptime: ProcessInfo.processInfo.systemUptime, unixTime: Date().timeIntervalSince1970,
                pid: ProcessInfo.processInfo.processIdentifier, active: NSApp.isActive,
                keyWindow: NSApp.keyWindow?.windowNumber ?? -1,
                mainWindow: NSApp.mainWindow?.windowNumber ?? -1,
                settingsWindow: window?.windowNumber ?? -1, settingsVisible: window?.isVisible ?? false,
                subjectPID: subjectPID ?? -1, runLoopMode: RunLoop.current.currentMode?.rawValue ?? "",
                currentEvent: current
            ))
            return
        }
        guard let output else { return }
        sequence += 1
        let front = NSWorkspace.shared.frontmostApplication
        let row: [String: Any] = [
            "sequence": sequence, "selection": selection, "event": event,
            "uptime": ProcessInfo.processInfo.systemUptime, "unixTime": Date().timeIntervalSince1970,
            "pid": ProcessInfo.processInfo.processIdentifier,
            "active": NSApp.isActive, "keyWindow": NSApp.keyWindow?.windowNumber ?? -1,
            "mainWindow": NSApp.mainWindow?.windowNumber ?? -1,
            "frontPID": front?.processIdentifier ?? -1, "frontBundle": front?.bundleIdentifier ?? "",
            "subjectPID": subjectPID ?? -1,
            "runLoopMode": RunLoop.current.currentMode?.rawValue ?? "",
            "windows": NSApp.windows.filter { $0.title == "Koine Settings" }.map {
                ["number": $0.windowNumber, "visible": $0.isVisible, "key": $0.isKeyWindow,
                 "main": $0.isMainWindow] as [String: Any]
            },
        ]
        do {
            var data = try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys])
            data.append(0x0A)
            try output.write(contentsOf: data)
        } catch {
            fputs("Settings activation trace write failed: \(error)\n", stderr)
            self.output = nil
        }
    }

    @objc private func dumpBuffer(_ notification: Notification) {
        guard let bufferPath, !dumpRequested else { return }
        record("buffer.dump")
        dumpRequested = true
        do {
            try buffer?.write(to: URL(fileURLWithPath: bufferPath))
            try Data("KOINE_SETTINGS_EVENTS_COMPLETE\n".utf8).write(
                to: URL(fileURLWithPath: bufferPath + ".complete"), options: .withoutOverwriting
            )
        } catch {
            fputs("Settings event buffer dump failed: \(error)\n", stderr)
        }
    }
}
