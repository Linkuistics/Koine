import AppKit
import Darwin
import KoineAppDiagnostics

/// Opt-in observation for a disposable guest. It never selects, highlights,
/// activates, suppresses or replaces an event. Ordinary operation creates no
/// probe files, timer or event monitor.
@MainActor
final class SettingsMenuProbe: NSObject {
    struct Input: Encodable {
        let menuSession: Int
        let requestUUID: String
        let inputSerial: Int
        let type: UInt
        let keyCode: UInt16?
        let modifierFlags: UInt
        let isARepeat: Bool
        let highlightedSettings: Bool
        var sameEvent: Bool
    }

    private let directory: URL?
    private weak var menu: NSMenu?
    private weak var settings: NSMenuItem?
    private var timer: Timer?
    private var monitor: Any?
    private var polls = 0
    private var session = 0
    private var serial = 0
    private var served: String?
    private var requests = SettingsMenuProbeRequests()
    private var lastEvent: NSEvent?
    private var lastInput: Input?

    override init() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "KoineSettingsEventBuffer") != nil,
           defaults.string(forKey: "KoineSettingsActivationTrace") == nil,
           defaults.bool(forKey: "KoineSettingsMenuProbe") {
            directory = URL(fileURLWithPath: "/Users/admin/settings-menu-probe", isDirectory: true)
        } else {
            directory = nil
        }
        super.init()
    }

    func open(_ menu: NSMenu, settings: NSMenuItem?) {
        guard directory != nil else { return }
        close()
        self.menu = menu
        self.settings = settings
        session += 1
        served = nil
        lastEvent = nil
        lastInput = nil
        polls = 0
        // Local monitors receive actual event arguments before dispatch. Return
        // the identical event. Coverage of menu tracking needs guest qualification.
        // https://developer.apple.com/documentation/appkit/nsevent/addlocalmonitorforevents(matching:handler:)
        monitor = NSEvent.addLocalMonitorForEvents(matching: [
            .keyDown, .keyUp, .flagsChanged, .leftMouseDown, .leftMouseUp,
            .rightMouseDown, .rightMouseUp, .otherMouseDown, .otherMouseUp,
        ]) { [weak self] event in
            self?.observeInput(event)
            return event
        }
        let timer = Timer(timeInterval: 0.1, target: self, selector: #selector(sample),
                          userInfo: nil, repeats: true)
        self.timer = timer
        // Read highlightedItem while the system menu is tracking. No default-
        // mode delivery assumption and no AXSelected-to-highlight equivalence.
        // https://developer.apple.com/documentation/foundation/runloop/mode/eventtracking
        RunLoop.main.add(timer, forMode: .eventTracking)
    }

    func close() {
        timer?.invalidate()
        timer = nil
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        menu = nil
        settings = nil
        // Keep lastEvent until the action: menuDidClose can precede its callback.
    }

    func invocation() -> Input? {
        guard var input = lastInput else { return nil }
        input.sameEvent = lastEvent === NSApp.currentEvent
        return input
    }

    private func observeInput(_ event: NSEvent) {
        guard let menu, let served, serial < 128 else { return }
        serial += 1
        let key = event.type == .keyDown || event.type == .keyUp
        let input = Input(
            menuSession: session, requestUUID: served, inputSerial: serial,
            type: event.type.rawValue, keyCode: key ? event.keyCode : nil,
            modifierFlags: event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue,
            isARepeat: key ? event.isARepeat : false,
            highlightedSettings: settings != nil && menu.highlightedItem === settings, sameEvent: true
        )
        lastEvent = event
        lastInput = input
        SettingsActivationTrace.shared.record("menu.input", menuProbe: input)
    }

    @objc private func sample() {
        guard let directory, let menu else { return }
        polls += 1
        defer { if polls >= 80 { timer?.invalidate(); timer = nil } }
        guard served == nil else { return }
        do {
            let data = try Data(contentsOf: directory.appendingPathComponent("request"))
            guard data.count <= 37, let text = String(data: data, encoding: .utf8),
                  let request = SettingsMenuProbeRequest(text: text), requests.consume(request) else { return }
            let nonce = request.id.uuidString
            // This is the actual AppKit highlight getter, not a willHighlight
            // prediction, selected/checkmark attribute or pointer hit-test.
            // https://developer.apple.com/documentation/appkit/nsmenu/highlighteditem
            let highlighted = settings != nil && menu.highlightedItem === settings && settings?.isEnabled == true
            let receipt: [String: Any] = [
                "format": "koine-menu-probe/1", "requestUUID": nonce,
                "pid": ProcessInfo.processInfo.processIdentifier, "menuSession": session,
                "sampleTicks": String(mach_continuous_time()), "highlightedSettings": highlighted,
            ]
            let output = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys])
            try output.write(to: directory.appendingPathComponent(nonce + ".json"), options: .withoutOverwriting)
            served = nonce
            timer?.invalidate()
            timer = nil
        } catch {
            // Missing request is normal until the host supplies one. Other I/O
            // failures also leave no usable receipt and expire at the fixed cap.
        }
    }
}
