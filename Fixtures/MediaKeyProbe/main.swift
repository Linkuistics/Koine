import AppKit
import ApplicationServices

// Media key probe: test material for docs/verification/media-key-music-launch.md.
// Run it only inside a TestAnyware VM. A key posted on a host changes the music
// or the volume of the developer.
//
// usage: MediaKeyProbe post <key>
//        key: play-pause | next | previous | volume-up | volume-down | mute
//
// It posts one media key as Modaliser's MediaKeyEmitter.swift posts it: a
// system-defined event of subtype 8, down and then up, at the HID event tap. The
// key number and the packing of data1 are Modaliser's. Then it prints one JSON
// line: the key, its number, whether this process has Accessibility consent and
// event posting access, and whether both events were posted. A post without
// access is dropped by macOS with no error, so the caller reads the two access
// values before it trusts a result.

/// The NX_KEYTYPE number of each key, as in Modaliser.
let keys: [String: Int] = [
    "play-pause": 16,  // NX_KEYTYPE_PLAY
    "next": 19,  // NX_KEYTYPE_FAST
    "previous": 20,  // NX_KEYTYPE_REWIND
    "volume-up": 0,  // NX_KEYTYPE_SOUND_UP
    "volume-down": 1,  // NX_KEYTYPE_SOUND_DOWN
    "mute": 7,  // NX_KEYTYPE_MUTE
]

/// NX_SUBTYPE_AUX_CONTROL_BUTTONS.
let auxControlButtonsSubtype: Int16 = 8

/// The data1 value for one key in one state: the key number in bits 16 to 23 and the state in bits 8
/// to 15, with NX_KEYDOWN 10 and NX_KEYUP 11. The repeat count in the low byte stays 0.
func data1(code: Int, down: Bool) -> Int { (code << 16) | ((down ? 0xA : 0xB) << 8) }

func post(code: Int, down: Bool) -> Bool {
    guard
        let event = NSEvent.otherEvent(
            with: .systemDefined, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0,
            context: nil, subtype: auxControlButtonsSubtype, data1: data1(code: code, down: down), data2: -1),
        let cgEvent = event.cgEvent
    else { return false }
    cgEvent.post(tap: .cghidEventTap)
    return true
}

let arguments = CommandLine.arguments
guard arguments.count == 3, arguments[1] == "post", let code = keys[arguments[2]] else {
    FileHandle.standardError.write(
        Data("usage: MediaKeyProbe post play-pause|next|previous|volume-up|volume-down|mute\n".utf8))
    exit(2)
}
let down = post(code: code, down: true)
let up = post(code: code, down: false)
let answer: [String: Any] = [
    "key": arguments[2],
    "code": code,
    "trusted": AXIsProcessTrusted(),
    "postAccess": CGPreflightPostEventAccess(),
    "posted": down && up,
]
print(String(decoding: try JSONSerialization.data(withJSONObject: answer, options: [.sortedKeys]), as: UTF8.self))
