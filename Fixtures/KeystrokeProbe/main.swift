import AppKit
import ApplicationServices
import Darwin

// Keystroke probe: test material for docs/verification/keystroke-route-vm.md.
// Run it only inside a TestAnyware VM. A chord that it sends on a host acts in
// the apps of the developer.
//
// usage: KeystrokeProbe send <pid> <chord> [--out <file>]
//        KeystrokeProbe hid <chord> [--out <file>]
//        KeystrokeProbe shortcuts [--out <file>]
//        KeystrokeProbe spaces [--out <file>]
//
// chord: modifiers and one key, joined by "+", such as cmd+shift+t or ctrl+2.
//        The modifiers are ctrl, shift, alt and cmd. The keys are Modaliser's.
//
// `send` builds the chord as Modaliser's KeystrokeEmitter.swift builds it, and
// posts each event with CGEventPostToPid to the named process (route A). `hid`
// builds the same events and posts them at the HID event tap, as Modaliser
// posts them. Only the post differs. The CGEvent.h header of the macOS SDK
// documents both calls. Each event carries `probeTag` in its source user data,
// so a witness can tell the probe's events from others.
//
// `shortcuts` reads the "Switch to Desktop N" entries, IDs 118 to 126, of the
// preferences domain com.apple.symbolichotkeys with CFPreferences. `spaces`
// counts the Spaces of each display from two sources: the preferences domain
// com.apple.spaces, read with CFPreferences, and the private SkyLight call
// SLSCopyManagedDisplaySpaces. The probe reports each source apart, so the
// record can say which call is public.
//
// Each command prints one JSON line. With --out, it also writes that line to
// the file, because a probe that `open` starts as an app has no terminal. Each
// line says whether this process has Accessibility consent and event posting
// access. The bundle form, KeystrokeProbe.app, runs the same binary as its own
// responsible process, so it does not inherit the consent of the TestAnyware
// agent.

/// The source user data of every event the probe posts: "KSTRPRB" in ASCII.
let probeTag: Int64 = 0x4b53_5452_5052_42

/// Modaliser's key table (KeystrokeEmitter.swift, US ANSI layout), with its
/// named keys.
let keyCodes: [String: CGKeyCode] = [
    "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5,
    "z": 6, "x": 7, "c": 8, "v": 9, "b": 11,
    "q": 12, "w": 13, "e": 14, "r": 15, "y": 16, "t": 17,
    "o": 31, "u": 32, "i": 34, "p": 35,
    "l": 37, "j": 38, "k": 40,
    "n": 45, "m": 46,
    "1": 18, "2": 19, "3": 20, "4": 21, "5": 23, "6": 22,
    "7": 26, "8": 28, "9": 25, "0": 29,
    "=": 24, "-": 27, "]": 30, "[": 33,
    "'": 39, ";": 41, "\\": 42, ",": 43, "/": 44,
    ".": 47, "`": 50,
    "return": 36, "tab": 48, "space": 49, "delete": 51, "escape": 53,
    "left": 123, "right": 124, "down": 125, "up": 126,
    "f1": 122, "f2": 120, "f3": 99, "f4": 118,
    "f5": 96, "f6": 97, "f7": 98, "f8": 100,
    "f9": 101, "f10": 109, "f11": 103, "f12": 111,
]

/// Modaliser's modifier order: control, shift, option, command.
let modifiers: [(name: String, flag: CGEventFlags, code: CGKeyCode)] = [
    ("ctrl", .maskControl, 59),
    ("shift", .maskShift, 56),
    ("alt", .maskAlternate, 58),
    ("cmd", .maskCommand, 55),
]

struct KeyEvent {
    let code: CGKeyCode
    let down: Bool
    let flags: CGEventFlags
    var described: [String: Any] { ["keycode": Int(code), "down": down, "flags": Int(flags.rawValue)] }
}

/// The events of one chord, in Modaliser's order. Each modifier goes down with
/// the flags so far. The key goes down and up with all flags. Then each
/// modifier goes up in reverse order.
func chordEvents(_ chord: String) -> [KeyEvent]? {
    let parts = chord.lowercased().split(separator: "+", omittingEmptySubsequences: false).map(String.init)
    guard let keyName = parts.last, let key = keyCodes[keyName] else { return nil }
    let names = Set(parts.dropLast())
    guard names.isSubset(of: modifiers.map(\.name)) else { return nil }
    let held = modifiers.filter { names.contains($0.name) }
    let all = held.reduce(CGEventFlags()) { $0.union($1.flag) }
    var events: [KeyEvent] = []
    var flags = CGEventFlags()
    for modifier in held {
        flags.insert(modifier.flag)
        events.append(KeyEvent(code: modifier.code, down: true, flags: flags))
    }
    events.append(KeyEvent(code: key, down: true, flags: all))
    events.append(KeyEvent(code: key, down: false, flags: all))
    for modifier in held.reversed() {
        flags.remove(modifier.flag)
        events.append(KeyEvent(code: modifier.code, down: false, flags: flags))
    }
    return events
}

/// Builds one event as Modaliser does, then hands it to the given post.
func post(_ events: [KeyEvent], with deliver: (CGEvent) -> Void) -> Bool {
    for keyEvent in events {
        let source = CGEventSource(stateID: .combinedSessionState)
        guard let event = CGEvent(keyboardEventSource: source, virtualKey: keyEvent.code, keyDown: keyEvent.down)
        else { return false }
        event.flags = keyEvent.flags
        event.setIntegerValueField(.eventSourceUserData, value: probeTag)
        deliver(event)
    }
    return true
}

func access() -> [String: Any] {
    ["trusted": AXIsProcessTrusted(), "postAccess": CGPreflightPostEventAccess(),
     "listenAccess": CGPreflightListenEventAccess(), "probePid": Int(getpid())]
}

func front() -> Any {
    guard let app = NSWorkspace.shared.frontmostApplication else { return NSNull() }
    return ["pid": Int(app.processIdentifier), "name": app.localizedName ?? "", "bundle": app.bundleIdentifier ?? ""]
}

func name(of pid: pid_t) -> Any {
    guard let app = NSRunningApplication(processIdentifier: pid) else { return NSNull() }
    return app.localizedName ?? ""
}

// MARK: - Shortcut settings

/// The CFPreferences value of one key, read again from disk.
func preference(_ key: String, _ domain: String) -> Any? {
    CFPreferencesAppSynchronize(domain as CFString)
    return CFPreferencesCopyAppValue(key as CFString, domain as CFString)
}

/// The Control modifier bit of a symbolic hotkey, NSEvent.ModifierFlags.control.
let controlMask = 262_144
/// The modifier bits a symbolic hotkey can carry: shift, control, option, command.
let modifierMask = 131_072 | 262_144 | 524_288 | 1_048_576

func shortcuts() -> [String: Any] {
    let table = preference("AppleSymbolicHotKeys", "com.apple.symbolichotkeys") as? [String: Any]
    var entries: [[String: Any]] = []
    for digit in 1...9 {
        let id = 117 + digit
        let code = Int(keyCodes[String(digit)]!)
        var entry: [String: Any] = ["desktop": digit, "id": id, "digitKeycode": code]
        guard let raw = table?[String(id)] as? [String: Any] else {
            entry["present"] = false
            entries.append(entry)
            continue
        }
        entry["present"] = true
        entry["enabled"] = (raw["enabled"] as? NSNumber)?.boolValue ?? NSNull()
        let value = raw["value"] as? [String: Any]
        let parameters = (value?["parameters"] as? [NSNumber])?.map(\.intValue) ?? []
        entry["type"] = value?["type"] ?? NSNull()
        entry["parameters"] = parameters
        entry["controlDigit"] =
            parameters.count == 3 && parameters[1] == code && parameters[2] & modifierMask == controlMask
        entries.append(entry)
    }
    return ["command": "shortcuts", "domainReadable": table != nil, "entries": entries]
}

// MARK: - Spaces

/// One display's Spaces, as either source reports them: type 0 is a desktop
/// and type 4 a full-screen Space.
func summarise(_ monitors: [[String: Any]]) -> [[String: Any]] {
    monitors.map { monitor in
        let spaces = (monitor["Spaces"] as? [[String: Any]]) ?? []
        let types = spaces.map { ($0["type"] as? NSNumber)?.intValue ?? -1 }
        let ids = spaces.map { ($0["ManagedSpaceID"] as? NSNumber)?.intValue ?? -1 }
        let current = ((monitor["Current Space"] as? [String: Any])?["ManagedSpaceID"] as? NSNumber)?.intValue
        return [
            "display": monitor["Display Identifier"] ?? NSNull(),
            "spaceIDs": ids, "types": types, "desktops": types.filter { $0 == 0 }.count,
            "currentSpaceID": current ?? NSNull(),
            "currentDesktop": current.flatMap { id in
                let desktops = zip(ids, types).filter { $0.1 == 0 }.map(\.0)
                return desktops.firstIndex(of: id).map { $0 + 1 }
            } ?? NSNull(),
        ]
    }
}

typealias MainConnection = @convention(c) () -> Int32
typealias CopySpaces = @convention(c) (Int32) -> Unmanaged<CFArray>?
typealias ActiveSpace = @convention(c) (Int32) -> UInt64

func spaces() -> [String: Any] {
    let configuration = preference("SpacesDisplayConfiguration", "com.apple.spaces") as? [String: Any]
    let management = configuration?["Management Data"] as? [String: Any]
    let preferenceMonitors = (management?["Monitors"] as? [[String: Any]]) ?? []
    var answer: [String: Any] = [
        "command": "spaces",
        "preferences": ["public": "CFPreferences is public; the domain and its format are not documented",
                        "readable": configuration != nil, "displays": summarise(preferenceMonitors)],
    ]
    var skylight: [String: Any] = ["public": "SLSCopyManagedDisplaySpaces is private"]
    let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY)
    if let handle, let main = dlsym(handle, "SLSMainConnectionID"), let copy = dlsym(handle, "SLSCopyManagedDisplaySpaces"),
        let active = dlsym(handle, "SLSGetActiveSpace")
    {
        let connection = unsafeBitCast(main, to: MainConnection.self)()
        let displays = unsafeBitCast(copy, to: CopySpaces.self)(connection)?.takeRetainedValue() as? [[String: Any]]
        skylight["readable"] = displays != nil
        skylight["displays"] = summarise(displays ?? [])
        skylight["activeSpaceID"] = Int(unsafeBitCast(active, to: ActiveSpace.self)(connection))
    } else {
        skylight["readable"] = false
    }
    answer["skylight"] = skylight
    return answer
}

// MARK: - Main

var arguments = Array(CommandLine.arguments.dropFirst())
var outFile: String?
if let index = arguments.firstIndex(of: "--out"), index + 1 < arguments.count {
    outFile = arguments[index + 1]
    arguments.removeSubrange(index...(index + 1))
}

func usage() -> Never {
    FileHandle.standardError.write(
        Data("usage: KeystrokeProbe send <pid> <chord> | hid <chord> | shortcuts | spaces [--out <file>]\n".utf8))
    exit(2)
}

var answer: [String: Any]
switch arguments.first {
case "send" where arguments.count == 3:
    guard let pid = pid_t(arguments[1]), let events = chordEvents(arguments[2]) else { usage() }
    let frontBefore = front()
    let posted = post(events) { $0.postToPid(pid) }
    answer = ["command": "send", "route": "CGEventPostToPid", "pid": Int(pid), "target": name(of: pid),
              "chord": arguments[2], "events": events.map(\.described), "frontBefore": frontBefore,
              "posted": posted]
case "hid" where arguments.count == 2:
    guard let events = chordEvents(arguments[1]) else { usage() }
    let frontBefore = front()
    let posted = post(events) { $0.post(tap: .cghidEventTap) }
    answer = ["command": "hid", "route": "CGEventPost(kCGHIDEventTap)", "chord": arguments[1],
              "events": events.map(\.described), "frontBefore": frontBefore, "posted": posted]
case "shortcuts" where arguments.count == 1:
    answer = shortcuts()
case "spaces" where arguments.count == 1:
    answer = spaces()
default:
    usage()
}
answer.merge(access()) { first, _ in first }
answer["time"] = Date().timeIntervalSince1970
let line = String(decoding: try JSONSerialization.data(withJSONObject: answer, options: [.sortedKeys]), as: UTF8.self)
print(line)
if let outFile {
    try (line + "\n").write(toFile: outFile, atomically: true, encoding: .utf8)
}
