import Testing

@testable import InputProviderLogic

/// The keys, the modifiers and the events of a chord. The contract is "Chords" in docs/specs/app-input.md. Nothing here
/// posts an event: a chord posted on this host would act in an app of the developer.
struct KeyTableTests {
    /// Modaliser's key table without its modifier keys and its alternative names, written out, so a changed key code
    /// turns this test red. The order is the order of `InputKey` in the design.
    @Test func eachKeyHasModalisersKeyCode() {
        let table: [(String, UInt16)] = [
            ("A", 0), ("B", 11), ("C", 8), ("D", 2), ("E", 14), ("F", 3), ("G", 5), ("H", 4), ("I", 34), ("J", 38),
            ("K", 40), ("L", 37), ("M", 46), ("N", 45), ("O", 31), ("P", 35), ("Q", 12), ("R", 15), ("S", 1),
            ("T", 17), ("U", 32), ("V", 9), ("W", 13), ("X", 7), ("Y", 16), ("Z", 6),
            ("DIGIT_0", 29), ("DIGIT_1", 18), ("DIGIT_2", 19), ("DIGIT_3", 20), ("DIGIT_4", 21), ("DIGIT_5", 23),
            ("DIGIT_6", 22), ("DIGIT_7", 26), ("DIGIT_8", 28), ("DIGIT_9", 25),
            ("MINUS", 27), ("EQUAL", 24), ("LEFT_BRACKET", 33), ("RIGHT_BRACKET", 30), ("BACKSLASH", 42),
            ("SEMICOLON", 41), ("QUOTE", 39), ("COMMA", 43), ("PERIOD", 47), ("SLASH", 44), ("GRAVE", 50),
            ("SPACE", 49), ("RETURN", 36), ("TAB", 48), ("DELETE", 51), ("ESCAPE", 53),
            ("LEFT", 123), ("RIGHT", 124), ("DOWN", 125), ("UP", 126),
            ("F1", 122), ("F2", 120), ("F3", 99), ("F4", 118), ("F5", 96), ("F6", 97), ("F7", 98), ("F8", 100),
            ("F9", 101), ("F10", 109), ("F11", 103), ("F12", 111),
        ]
        #expect(InputKey.allCases.count == 68)
        #expect(InputKey.allCases.map(\.rawValue) == table.map(\.0))
        #expect(InputKey.allCases.map(\.keyCode) == table.map(\.1))
    }

    /// No two keys share a key code, and no key is a modifier key: a modifier key alone is a held key.
    @Test func keyCodesAreDistinctAndNoneIsAModifierKey() {
        let codes = InputKey.allCases.map(\.keyCode)
        #expect(Set(codes).count == codes.count)
        #expect(Set(codes).isDisjoint(with: InputModifier.allCases.map(\.keyCode)))
    }

    /// A value outside the table is no key. GraphQL validation refuses it first, so this is the provider's own guard.
    @Test(arguments: ["SHIFT", "CONTROL", "a", "ENTER", "F13", ""])
    func anUnknownKeyIsRefused(name: String) {
        #expect(InputKey(rawValue: name) == nil)
    }

    /// The modifiers press in the order Control, Shift, Option and Command, with Modaliser's key codes and the flag
    /// bits of CGEventTypes.h.
    @Test func theModifiersHaveTheirOrderKeyCodesAndFlags() {
        #expect(InputModifier.allCases.map(\.rawValue) == ["CONTROL", "SHIFT", "OPTION", "COMMAND"])
        #expect(InputModifier.allCases.map(\.keyCode) == [59, 56, 58, 55])
        #expect(InputModifier.allCases.map(\.flag) == [0x4_0000, 0x2_0000, 0x8_0000, 0x10_0000])
    }

    /// The list of modifiers is a set: a value held twice counts once, and the order of the list does not matter.
    @Test func theModifiersAreASet() {
        #expect(InputModifier.set([.command, .shift, .command]) == [.shift, .command])
        #expect(InputModifier.set([.option, .control]) == InputModifier.set([.control, .option]))
        #expect(InputModifier.set([]) == [])
    }
}

struct ChordEventTests {
    /// A key with no modifier is one key-down event and one key-up event, with no flags.
    @Test func aKeyAloneIsDownAndUp() {
        #expect(
            Chord.events(key: .escape, modifiers: []) == [
                ChordEvent(keyCode: 53, keyDown: true, flags: 0),
                ChordEvent(keyCode: 53, keyDown: false, flags: 0),
            ])
    }

    /// Safari's "Reopen Closed Tab" row, Command-Shift-T, given as [COMMAND, SHIFT]. Shift presses first, each
    /// modifier event carries the flags of the modifiers down so far, and the release is in the reverse order.
    @Test func commandShiftTFollowsModalisersOrder() {
        let shift: UInt64 = 0x2_0000
        let command: UInt64 = 0x10_0000
        #expect(
            Chord.events(key: .t, modifiers: [.command, .shift]) == [
                ChordEvent(keyCode: 56, keyDown: true, flags: shift),
                ChordEvent(keyCode: 55, keyDown: true, flags: shift | command),
                ChordEvent(keyCode: 17, keyDown: true, flags: shift | command),
                ChordEvent(keyCode: 17, keyDown: false, flags: shift | command),
                ChordEvent(keyCode: 55, keyDown: false, flags: shift),
                ChordEvent(keyCode: 56, keyDown: false, flags: 0),
            ])
    }

    /// With all four modifiers, a chord has ten events, the key carries every flag, and the chord ends with every
    /// modifier released.
    @Test func fourModifiersGiveTenEventsThatEndReleased() {
        let events = Chord.events(key: .l, modifiers: [.command, .option, .shift, .control, .shift])
        #expect(events.count == 10)
        #expect(events.prefix(4).map(\.keyCode) == [59, 56, 58, 55])
        #expect(events.prefix(4).allSatisfy { $0.keyDown })
        #expect(events.prefix(4).map(\.flags) == [0x4_0000, 0x6_0000, 0xE_0000, 0x1E_0000])
        #expect(events[4] == ChordEvent(keyCode: 37, keyDown: true, flags: 0x1E_0000))
        #expect(events[5] == ChordEvent(keyCode: 37, keyDown: false, flags: 0x1E_0000))
        #expect(events.suffix(4).map(\.keyCode) == [55, 58, 56, 59])
        #expect(events.suffix(4).allSatisfy { !$0.keyDown })
        #expect(events.suffix(4).map(\.flags) == [0xE_0000, 0x6_0000, 0x4_0000, 0])
    }

    /// Every chord has between 2 and 10 events, and every key that goes down comes up.
    @Test(arguments: InputKey.allCases)
    func everyKeyGoesDownAndComesUp(key: InputKey) {
        for count in 0...4 {
            let modifiers = Array(InputModifier.allCases.prefix(count))
            let events = Chord.events(key: key, modifiers: modifiers)
            #expect(events.count == 2 + 2 * count)
            #expect(events.filter { $0.keyDown }.map(\.keyCode).sorted() == events.filter { !$0.keyDown }.map(\.keyCode).sorted())
            #expect(events.last?.flags == 0)
        }
    }
}
