import AppKit
import ApplicationServices
import Foundation

// Test material, never shipped: gathers the evidence of
// docs/verification/desktop-window-identity.md. It holds accessibility elements
// across the steps of a scenario, as the desktop provider's window table does,
// and reports for each candidate identity mechanism what it says of every window:
//
//   A  the held AXUIElement, compared with CFEqual            (public)
//   B  the CGWindowID from _AXUIElementGetWindow               (PRIVATE; here as
//      an independent witness of which window an element is, and nowhere else)
//   C  CGWindowListCopyWindowInfo's window numbers and bounds  (public)
//   D  the AXIdentifier attribute                              (public)
//
// usage: WindowIdentityProbe serve <directory>
//        WindowIdentityProbe focused
//        WindowIdentityProbe windows <pid>
//        WindowIdentityProbe observe <pid> <seconds>
// A command is a file <name>.cmd holding `list <pid>` or `held`; the answer is
// written to <name>.json. `stop.cmd` ends the process. `focused` holds nothing: it
// prints which window has focus now, as the system says and not as Koine does,
// for docs/verification/desktop-focus-vm.md. `windows` holds nothing either: the
// windows an application lists now, so that one in the background can be seen to
// be minimised, or absent from the current Space, before Koine is asked to focus it.
// `observe` asks to be told of the destruction of every window the application
// lists now, waits until it is told of one or the seconds pass, and prints what it
// was told, for
// docs/verification/desktop-remembered-windows-vm.md: whether the notification the
// desktop provider relies on arrives, and for which window.

@_silgen_name("_AXUIElementGetWindow")
func _AXUIElementGetWindow(_ element: AXUIElement, _ id: UnsafeMutablePointer<CGWindowID>) -> AXError

func copy(_ element: AXUIElement, _ name: String) -> (AXError, AnyObject?) {
    var value: AnyObject?
    return (AXUIElementCopyAttributeValue(element, name as CFString, &value), value)
}

func rect(_ element: AXUIElement) -> [Int] {
    var point = CGPoint.zero
    var size = CGSize.zero
    if let value = copy(element, kAXPositionAttribute).1 { AXValueGetValue(value as! AXValue, .cgPoint, &point) }
    if let value = copy(element, kAXSizeAttribute).1 { AXValueGetValue(value as! AXValue, .cgSize, &size) }
    return [Int(point.x), Int(point.y), Int(size.width), Int(size.height)]
}

/// The provider's canonicality check: is the element the one its own first child
/// names as its window? Null when there is no child, or the child names none.
func isItsOwnWindow(_ element: AXUIElement) -> Any {
    guard let child = (copy(element, kAXChildrenAttribute).1 as? [AXUIElement])?.first,
        let window = copy(child, kAXWindowAttribute).1
    else { return NSNull() }
    return CFEqual(window, element)
}

var nextToken = 1
var held: [(token: Int, pid: pid_t, element: AXUIElement)] = []

func describe(_ element: AXUIElement) -> [String: Any] {
    let (error, role) = copy(element, kAXRoleAttribute)
    var windowId: CGWindowID = 0
    let witness = _AXUIElementGetWindow(element, &windowId)
    return [
        "axError": error.rawValue, "role": role as? String ?? NSNull(),
        "subrole": copy(element, kAXSubroleAttribute).1 as? String ?? NSNull(),
        "title": copy(element, kAXTitleAttribute).1 as? String ?? NSNull(),
        "minimized": copy(element, kAXMinimizedAttribute).1 as? Bool ?? NSNull(),
        "axIdentifier": copy(element, kAXIdentifierAttribute).1 as? String ?? NSNull(),
        "isItsOwnWindow": isItsOwnWindow(element),
        "rect": rect(element), "privateWindowId": witness == .success ? Int(windowId) : NSNull(),
        "privateError": witness.rawValue,
    ]
}

func list(_ pid: pid_t) -> [String: Any] {
    let application = AXUIElementCreateApplication(pid)
    AXUIElementSetMessagingTimeout(application, 2)
    let (error, value) = copy(application, kAXWindowsAttribute)
    let elements = value as? [AXUIElement] ?? []
    let windows: [[String: Any]] = elements.map { element in
        var row = describe(element)
        let matches = held.filter { CFEqual($0.element, element) }
        if let known = matches.first {
            row["token"] = known.token
        } else {
            AXUIElementSetMessagingTimeout(element, 1)
            held.append((nextToken, pid, element))
            row["token"] = nextToken
            nextToken += 1
        }
        row["heldElementsEqualToThis"] = max(matches.count, 1)
        return row
    }
    let cg = (CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? [])
        .filter { ($0[kCGWindowOwnerPID as String] as? Int).map(pid_t.init) == pid }
        .map { info -> [String: Any] in
            let bounds = info[kCGWindowBounds as String] as? [String: Any] ?? [:]
            return [
                "windowNumber": info[kCGWindowNumber as String] ?? NSNull(),
                "layer": info[kCGWindowLayer as String] ?? NSNull(),
                "name": info[kCGWindowName as String] ?? NSNull(),
                "onScreen": info[kCGWindowIsOnscreen as String] ?? false,
                "rect": ["X", "Y", "Width", "Height"].map { (bounds[$0] as? NSNumber)?.intValue ?? -1 },
            ]
        }
    let running = NSRunningApplication(processIdentifier: pid)
    return [
        "pid": Int(pid), "application": running?.localizedName ?? NSNull(),
        "windowsAXError": error.rawValue, "axWindows": windows, "cgWindows": cg,
    ]
}

/// Every element ever listed, asked again now. `equalHeldTokens` names any other
/// held element CFEqual says is the same: two tokens for one window, or one
/// element answering for two, would show here.
func heldNow() -> [String: Any] {
    [
        "held": held.map { entry -> [String: Any] in
            var row = describe(entry.element)
            row["token"] = entry.token
            row["pid"] = Int(entry.pid)
            row["equalHeldTokens"] = held.filter {
                $0.token != entry.token && CFEqual($0.element, entry.element)
            }.map(\.token)
            return row
        }
    ]
}

/// The frontmost application as the workspace reports it to this fresh process,
/// and that application's focused window, asked of the application itself. The
/// system-wide element's focused application is recorded and not relied on: from
/// a command-line tool in the VM it answered kAXErrorCannotComplete with an
/// application plainly in front. The window server's frontmost ordinary window
/// is a second, independent witness of which application is in front.
func focusedNow() -> [String: Any] {
    var answer: [String: Any] = ["application": NSNull(), "window": NSNull()]
    let system = AXUIElementCreateSystemWide()
    AXUIElementSetMessagingTimeout(system, 2)
    answer["systemWideFocusedApplicationAXError"] = copy(system, kAXFocusedApplicationAttribute).0.rawValue
    if let front = NSWorkspace.shared.frontmostApplication {
        let pid = front.processIdentifier
        answer["application"] = ["pid": Int(pid), "name": front.localizedName as Any? ?? NSNull()]
        let application = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(application, 2)
        let (windowError, window) = copy(application, kAXFocusedWindowAttribute)
        answer["focusedWindowAXError"] = windowError.rawValue
        if let window { answer["window"] = describe(window as! AXUIElement) }
    }
    let front = (CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
        as? [[String: Any]] ?? []).first { ($0[kCGWindowLayer as String] as? Int) == 0 }
    answer["frontCGWindow"] = front.map {
        ["windowNumber": $0[kCGWindowNumber as String] ?? NSNull(), "pid": $0[kCGWindowOwnerPID as String] ?? NSNull()]
    } ?? NSNull()
    answer["trusted"] = AXIsProcessTrusted()
    return answer
}

nonisolated(unsafe) var watched: [(element: AXUIElement, described: [String: Any])] = []
nonisolated(unsafe) var destroyed: [[String: Any]] = []

let arguments = CommandLine.arguments
if arguments.count == 2, arguments[1] == "focused" {
    print(String(decoding: try JSONSerialization.data(withJSONObject: focusedNow(), options: [.sortedKeys]), as: UTF8.self))
    exit(0)
}
if arguments.count == 3, arguments[1] == "windows", let pid = pid_t(arguments[2]) {
    let application = AXUIElementCreateApplication(pid)
    AXUIElementSetMessagingTimeout(application, 2)
    let (error, value) = copy(application, kAXWindowsAttribute)
    let answer: [String: Any] = [
        "pid": Int(pid), "windowsAXError": error.rawValue, "trusted": AXIsProcessTrusted(),
        "windows": (value as? [AXUIElement] ?? []).map(describe),
    ]
    print(String(decoding: try JSONSerialization.data(withJSONObject: answer, options: [.sortedKeys]), as: UTF8.self))
    exit(0)
}
if arguments.count == 4, arguments[1] == "observe", let pid = pid_t(arguments[2]), let seconds = Double(arguments[3]) {
    let application = AXUIElementCreateApplication(pid)
    AXUIElementSetMessagingTimeout(application, 2)
    let windows = copy(application, kAXWindowsAttribute).1 as? [AXUIElement] ?? []
    // A destroyed element answers nothing, so what it was is read beforehand.
    watched = windows.map { ($0, describe($0)) }
    var observer: AXObserver?
    let created = AXObserverCreate(pid, { _, element, _, _ in
        let known = watched.first { CFEqual($0.element, element) }?.described
        destroyed.append(known ?? ["unknown": true])
    }, &observer)
    var registrations: [Int32] = []
    if let observer {
        CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .commonModes)
        registrations = windows.map {
            AXObserverAddNotification(observer, $0, kAXUIElementDestroyedNotification as CFString, nil).rawValue
        }
    }
    // Ends at the first destruction it is told of, or after `seconds`.
    let began = Date()
    while destroyed.isEmpty, Date().timeIntervalSince(began) < seconds {
        CFRunLoopRunInMode(.defaultMode, 0.25, false)
    }
    let stamp = ISO8601DateFormatter()
    let answer: [String: Any] = [
        "began": stamp.string(from: began), "ended": stamp.string(from: Date()),
        "pid": Int(pid), "trusted": AXIsProcessTrusted(), "observerAXError": created.rawValue,
        "registrationAXErrors": registrations, "watched": watched.map(\.described), "destroyed": destroyed,
    ]
    print(String(decoding: try JSONSerialization.data(withJSONObject: answer, options: [.sortedKeys]), as: UTF8.self))
    exit(0)
}
guard arguments.count == 3, arguments[1] == "serve" else {
    FileHandle.standardError.write(Data("usage: WindowIdentityProbe serve <directory> | focused | windows <pid> | observe <pid> <seconds>\n".utf8))
    exit(2)
}
let directory = URL(fileURLWithPath: arguments[2], isDirectory: true)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
try Data("{\"trusted\": \(AXIsProcessTrusted())}\n".utf8)
    .write(to: directory.appendingPathComponent("ready.json"))
while true {
    let commands = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
    for file in commands.sorted() where file.hasSuffix(".cmd") {
        let url = directory.appendingPathComponent(file)
        let words = (try? String(contentsOf: url, encoding: .utf8))?.split(whereSeparator: \.isWhitespace) ?? []
        try? FileManager.default.removeItem(at: url)
        if file == "stop.cmd" { exit(0) }
        var answer: [String: Any] = ["error": "unknown command"]
        if words.first == "list", words.count == 2, let pid = pid_t(words[1]) { answer = list(pid) }
        if words.first == "held" { answer = heldNow() }
        answer["trusted"] = AXIsProcessTrusted()
        answer["answeredAt"] = ISO8601DateFormatter().string(from: Date())
        let data = try JSONSerialization.data(withJSONObject: answer, options: [.prettyPrinted, .sortedKeys])
        let out = directory.appendingPathComponent(String(file.dropLast(4)) + ".json")
        try data.write(to: out, options: .atomic)
    }
    Thread.sleep(forTimeInterval: 0.2)
}
