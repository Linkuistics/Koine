/// The keys and the modifiers of a chord (docs/specs/app-input.md, "The keys"). The key codes are Modaliser's key
/// table, `KeystrokeEmitter.swift`, for the US ANSI layout. A key code is a key position, not a character.

/// The values of `InputKey`, each with its virtual key code. The raw value is the GraphQL enum value, which the core
/// passes to the provider as a string.
enum InputKey: String, CaseIterable, Equatable, Sendable {
    case a = "A", b = "B", c = "C", d = "D", e = "E", f = "F", g = "G", h = "H", i = "I", j = "J", k = "K", l = "L"
    case m = "M", n = "N", o = "O", p = "P", q = "Q", r = "R", s = "S", t = "T", u = "U", v = "V", w = "W", x = "X"
    case y = "Y", z = "Z"
    case digit0 = "DIGIT_0", digit1 = "DIGIT_1", digit2 = "DIGIT_2", digit3 = "DIGIT_3", digit4 = "DIGIT_4"
    case digit5 = "DIGIT_5", digit6 = "DIGIT_6", digit7 = "DIGIT_7", digit8 = "DIGIT_8", digit9 = "DIGIT_9"
    case minus = "MINUS", equal = "EQUAL", leftBracket = "LEFT_BRACKET", rightBracket = "RIGHT_BRACKET"
    case backslash = "BACKSLASH", semicolon = "SEMICOLON", quote = "QUOTE", comma = "COMMA", period = "PERIOD"
    case slash = "SLASH", grave = "GRAVE"
    case space = "SPACE", `return` = "RETURN", tab = "TAB", delete = "DELETE", escape = "ESCAPE"
    case left = "LEFT", right = "RIGHT", down = "DOWN", up = "UP"
    case f1 = "F1", f2 = "F2", f3 = "F3", f4 = "F4", f5 = "F5", f6 = "F6"
    case f7 = "F7", f8 = "F8", f9 = "F9", f10 = "F10", f11 = "F11", f12 = "F12"

    /// The virtual key code, as Modaliser's `characterToKeyCode` and `namedKeyToKeyCode` give it.
    var keyCode: UInt16 {
        switch self {
        case .a: 0
        case .s: 1
        case .d: 2
        case .f: 3
        case .h: 4
        case .g: 5
        case .z: 6
        case .x: 7
        case .c: 8
        case .v: 9
        case .b: 11
        case .q: 12
        case .w: 13
        case .e: 14
        case .r: 15
        case .y: 16
        case .t: 17
        case .digit1: 18
        case .digit2: 19
        case .digit3: 20
        case .digit4: 21
        case .digit6: 22
        case .digit5: 23
        case .equal: 24
        case .digit9: 25
        case .digit7: 26
        case .minus: 27
        case .digit8: 28
        case .digit0: 29
        case .rightBracket: 30
        case .o: 31
        case .u: 32
        case .leftBracket: 33
        case .i: 34
        case .p: 35
        case .return: 36
        case .l: 37
        case .j: 38
        case .quote: 39
        case .k: 40
        case .semicolon: 41
        case .backslash: 42
        case .comma: 43
        case .slash: 44
        case .n: 45
        case .m: 46
        case .period: 47
        case .tab: 48
        case .space: 49
        case .grave: 50
        case .delete: 51
        case .escape: 53
        case .f5: 96
        case .f6: 97
        case .f7: 98
        case .f3: 99
        case .f8: 100
        case .f9: 101
        case .f11: 103
        case .f10: 109
        case .f12: 111
        case .f4: 118
        case .f2: 120
        case .f1: 122
        case .left: 123
        case .right: 124
        case .down: 125
        case .up: 126
        }
    }
}

/// The values of `InputModifier`, in the order that Koine presses them: Control, Shift, Option and Command. This is
/// the order of Modaliser's `modifierKeyCodes(in:)`.
enum InputModifier: String, CaseIterable, Equatable, Sendable {
    case control = "CONTROL"
    case shift = "SHIFT"
    case option = "OPTION"
    case command = "COMMAND"

    /// The virtual key code of the left modifier key, as Modaliser posts it.
    var keyCode: UInt16 {
        switch self {
        case .control: 59
        case .shift: 56
        case .option: 58
        case .command: 55
        }
    }

    /// The bit of the modifier in the flags of an event. The values are `kCGEventFlagMaskShift`,
    /// `kCGEventFlagMaskControl`, `kCGEventFlagMaskAlternate` and `kCGEventFlagMaskCommand` in the SDK header
    /// `CoreGraphics.framework/Headers/CGEventTypes.h`, which defines them from the `NX_*MASK` values of `IOLLEvent.h`.
    var flag: UInt64 {
        switch self {
        case .shift: 0x0002_0000
        case .control: 0x0004_0000
        case .option: 0x0008_0000
        case .command: 0x0010_0000
        }
    }

    /// The modifiers of a list as a set, in the order of the presses. A value that the list holds twice counts once,
    /// and the order of the list does not matter.
    static func set(_ list: [InputModifier]) -> [InputModifier] {
        allCases.filter(list.contains)
    }
}
