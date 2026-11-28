/// The events of a chord (docs/specs/app-input.md, "The events of a chord"). The provider creates and posts the
/// keyboard events, and this file gives their order and their flags as plain values. So `swift test` holds the
/// chord without a post. Nothing here posts an event.

/// One keyboard event of a chord: the key code, whether the key goes down or up, and the flags of the modifiers that
/// the event carries.
struct ChordEvent: Equatable, Sendable {
    let keyCode: UInt16
    let keyDown: Bool
    let flags: UInt64
}

enum Chord {
    /// The events of one chord, as Modaliser's `KeystrokeEmitter.sendKeystroke` builds them with no held modifier:
    ///
    /// 1. A key-down event for each modifier, in the order of `InputModifier.set`. Each event carries the flags of
    ///    the modifiers that are down so far.
    /// 2. A key-down event and a key-up event for the key. Both carry the flags of every modifier of the chord.
    /// 3. A key-up event for each modifier, in the reverse order. Each event carries the flags of the modifiers that
    ///    are still down.
    ///
    /// So a chord has between 2 and 10 events, and it ends with every modifier released.
    static func events(key: InputKey, modifiers list: [InputModifier]) -> [ChordEvent] {
        let modifiers = InputModifier.set(list)
        let all = modifiers.reduce(UInt64(0)) { $0 | $1.flag }
        var events: [ChordEvent] = []
        var down: UInt64 = 0
        for modifier in modifiers {
            down |= modifier.flag
            events.append(ChordEvent(keyCode: modifier.keyCode, keyDown: true, flags: down))
        }
        events.append(ChordEvent(keyCode: key.keyCode, keyDown: true, flags: all))
        events.append(ChordEvent(keyCode: key.keyCode, keyDown: false, flags: all))
        for modifier in modifiers.reversed() {
            down &= ~modifier.flag
            events.append(ChordEvent(keyCode: modifier.keyCode, keyDown: false, flags: down))
        }
        return events
    }
}
