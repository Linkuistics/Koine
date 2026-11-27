/// The pure rules of the media keys (docs/specs/machine.md, "Media keys"). The provider creates and posts the
/// system-defined events, and it passes the two consent checks here as plain values. So `swift test` holds the key
/// numbers, the `data1` values and the order of the steps without posting a key. A key posted on a host changes the
/// music or the volume of the developer. Nothing here posts an event.
///
/// The mechanism is Modaliser's `MediaKeyEmitter.swift`. Its comments record the source of each number: the SDK
/// headers `ev_keymap.h` for the key numbers and `IOLLEvent.h` for the states and the subtype, both under
/// `IOKit.framework/Versions/A/Headers/hidsystem/` of the macOS SDK.

/// The values of `DesktopMediaKey`, each with its `NX_KEYTYPE_*` key number.
enum MediaKey: String, CaseIterable, Equatable, Sendable {
    case playPause = "PLAY_PAUSE"
    case next = "NEXT"
    case previous = "PREVIOUS"
    case volumeUp = "VOLUME_UP"
    case volumeDown = "VOLUME_DOWN"
    case mute = "MUTE"

    /// The key number in `data1`. The numbers for next and previous are Modaliser's choice, `NX_KEYTYPE_FAST` and
    /// `NX_KEYTYPE_REWIND`. The header also defines `NX_KEYTYPE_NEXT` (17) and `NX_KEYTYPE_PREVIOUS` (18). In the VM
    /// acceptance, Music honoured 19 and 20, so these numbers stay (docs/verification/desktop-pointer-media-vm.md).
    var number: Int {
        switch self {
        case .playPause: return 16  // NX_KEYTYPE_PLAY
        case .next: return 19  // NX_KEYTYPE_FAST
        case .previous: return 20  // NX_KEYTYPE_REWIND
        case .volumeUp: return 0  // NX_KEYTYPE_SOUND_UP
        case .volumeDown: return 1  // NX_KEYTYPE_SOUND_DOWN
        case .mute: return 7  // NX_KEYTYPE_MUTE
        }
    }
}

/// The state of a key in `data1`: `NX_KEYDOWN` (10) and `NX_KEYUP` (11).
enum MediaKeyState: Int, CaseIterable, Equatable, Sendable {
    case down = 0xA
    case up = 0xB
}

/// Why a media key failed. In each case, Koine posted nothing.
enum MediaKeyFailure: Error, Equatable, Sendable {
    /// A consent check failed. The value is the message of `PostingConsent.refusal`.
    case permission(String)
    /// macOS did not create both events.
    case eventNotCreated
}

enum MediaKeyPress {
    /// `NX_SUBTYPE_AUX_CONTROL_BUTTONS`: the subtype of a system-defined event that carries a media key.
    static let subtype: Int16 = 8

    /// The `data2` value of each event. Modaliser posts -1.
    static let data2 = -1

    /// The `data1` value of one key in one state: the key number in bits 16 to 23 and the state in bits 8 to 15.
    /// The low byte is the repeat count, and it is 0, because a posted key is never a repeat.
    static func data1(_ key: MediaKey, _ state: MediaKeyState) -> Int {
        (key.number << 16) | (state.rawValue << 8)
    }

    /// The `data1` values of one press, in the order of the posts: down, and then up.
    static func sequence(_ key: MediaKey) -> [Int] {
        [data1(key, .down), data1(key, .up)]
    }

    /// The steps of one press, in the order that the contract gives:
    ///
    /// 1. When a consent check fails, post nothing.
    /// 2. Create both events. When macOS does not create both, post nothing.
    /// 3. Post the two events in the order of `sequence`.
    ///
    /// `create` returns the event with a `data1` value, or nil. `post` posts one event.
    static func perform<Event>(
        _ key: MediaKey,
        consent: () -> PostingConsent,
        create: (Int) -> Event?,
        post: (Event) -> Void
    ) -> Result<MediaKey, MediaKeyFailure> {
        if let refusal = consent().refusal { return .failure(.permission(refusal)) }
        var events: [Event] = []
        for data1 in sequence(key) {
            guard let event = create(data1) else { return .failure(.eventNotCreated) }
            events.append(event)
        }
        events.forEach(post)
        return .success(key)
    }
}
