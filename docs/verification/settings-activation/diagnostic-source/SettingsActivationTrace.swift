import AppKit

/// Opt-in diagnostic observation. It never requests activation or changes window
/// order. Set KoineSettingsActivationTrace to a file path in a disposable guest.
@MainActor
final class SettingsActivationTrace: NSObject {
    static let shared = SettingsActivationTrace()
    private var output: FileHandle?
    private var sequence = 0
    private var selection = 0

    private override init() {
        super.init()
        guard let path = UserDefaults.standard.string(forKey: "KoineSettingsActivationTrace") else { return }
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
        record("trace.started")
    }

    func beginSelection(_ source: String) {
        guard output != nil else { return }
        selection += 1
        record("callback.\(source)")
    }

    @objc private func observe(_ notification: Notification) {
        let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
        record(notification.name.rawValue, subjectPID: app?.processIdentifier)
    }

    func record(_ event: String, subjectPID: pid_t? = nil) {
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
}
