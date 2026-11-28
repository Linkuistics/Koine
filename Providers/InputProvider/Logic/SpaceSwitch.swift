/// The steps of `inputSwitchSpace` (docs/specs/app-input.md, "Space switching"). The provider passes the consent
/// checks, the two reads, the event creation, the front app and the post as closures. The reads arrive as plain
/// property-list values, so `swift test` holds every check, the form of each reply included, without a post. A post on
/// a host would switch the Space of the developer, or type Control and a digit into the front app.

/// A property-list value as CFPreferences or SkyLight return it, reduced to the forms that the two reads use. The
/// provider converts the native value. A form that neither read uses is `other`.
indirect enum PropertyValue: Equatable, Sendable {
    case boolean(Bool)
    case integer(Int)
    case string(String)
    case array([PropertyValue])
    case dictionary([String: PropertyValue])
    case other
}

/// The values of `InputSpaceSwitchOutcome`.
enum SpaceSwitchOutcome: String, Equatable, Sendable {
    case posted = "POSTED"
    case shortcutOff = "SHORTCUT_OFF"
    case shortcutRemapped = "SHORTCUT_REMAPPED"
    case noSuchDesktop = "NO_SUCH_DESKTOP"
    case protectedFrontApp = "PROTECTED_FRONT_APP"
}

/// Why a Space switch failed. In each case, Koine posted nothing.
enum SpaceSwitchFailure: Error, Equatable, Sendable {
    /// The number is outside 1 to 9. Koine attempted nothing.
    case invalidNumber
    /// A consent check failed. The value is the message of `PostingConsent.refusal`.
    case permission(String)
    /// The shortcut table or the entry for the number has another form.
    case shortcutUnreadable
    /// A SkyLight symbol is missing, or the SkyLight reply has another form.
    case desktopsUncountable
    /// macOS did not create every event.
    case eventNotCreated
}

/// The app that macOS reports as active, as `NSWorkspace.frontmostApplication` gives it.
struct FrontApp: Equatable, Sendable {
    let pid: Int32
    let bundleIdentifier: String?
}

/// The "Switch to Desktop N" shortcut of Mission Control: entry 117 + N of `AppleSymbolicHotKeys` in the preferences
/// domain `com.apple.symbolichotkeys`. Apple does not document the domain, so the route probe is the evidence for its
/// form (docs/verification/keystroke-route-vm.md). An entry holds `enabled` and `value.parameters`, which are the
/// character, the key code and the modifier mask.
enum DesktopShortcut {
    /// The mask of Control alone, `NSEvent.ModifierFlags.control`. The entry must hold exactly this mask.
    static let controlMask = 262_144

    /// The verdict of the shortcut entry for desktop `number`, from the whole `AppleSymbolicHotKeys` value. Nil means
    /// that the entry is on and holds Control and the digit. `table` is nil when the domain holds no such key.
    ///
    /// - An absent table or entry acts as a disabled one: `SHORTCUT_OFF`.
    /// - A table or an entry in another form is `shortcutUnreadable`. `enabled` must be a boolean.
    /// - A disabled entry is `SHORTCUT_OFF`, whatever its parameters hold.
    /// - The parameters must be three integers. Otherwise the entry is `shortcutUnreadable`.
    /// - The key code must be the digit's, and the mask must equal `controlMask`. Otherwise `SHORTCUT_REMAPPED`. The
    ///   character is ignored.
    static func verdict(table: PropertyValue?, number: Int, digit: InputKey)
        -> Result<SpaceSwitchOutcome?, SpaceSwitchFailure>
    {
        guard let table else { return .success(.shortcutOff) }
        guard case .dictionary(let entries) = table else { return .failure(.shortcutUnreadable) }
        guard let entry = entries[String(117 + number)] else { return .success(.shortcutOff) }
        guard case .dictionary(let fields) = entry, case .boolean(let enabled)? = fields["enabled"] else {
            return .failure(.shortcutUnreadable)
        }
        guard enabled else { return .success(.shortcutOff) }
        guard case .dictionary(let value)? = fields["value"], case .array(let list)? = value["parameters"],
            list.count == 3
        else { return .failure(.shortcutUnreadable) }
        var parameters: [Int] = []
        for item in list {
            guard case .integer(let parameter) = item else { return .failure(.shortcutUnreadable) }
            parameters.append(parameter)
        }
        guard parameters[1] == Int(digit.keyCode), parameters[2] == controlMask else {
            return .success(.shortcutRemapped)
        }
        return .success(nil)
    }
}

/// The Mission Control desktops, from the reply of the private SkyLight call `SLSCopyManagedDisplaySpaces`. The reply
/// holds one entry for each display, and each entry lists its Spaces under `Spaces`, each with a `type`. Type 0 is a
/// desktop, and type 4 is a full-screen Space (docs/verification/keystroke-route-vm.md, "How Koine can count Spaces").
enum MissionControlDesktops {
    static let desktopType = 0

    /// The number of Spaces of type 0 on every display, in the order of the reply. Every other type is skipped. Nil
    /// when the reply has another form.
    static func count(_ reply: PropertyValue) -> Int? {
        guard case .array(let displays) = reply else { return nil }
        var desktops = 0
        for display in displays {
            guard case .dictionary(let fields) = display, case .array(let spaces)? = fields["Spaces"] else { return nil }
            for space in spaces {
                guard case .dictionary(let facts) = space, case .integer(let type)? = facts["type"] else { return nil }
                if type == desktopType { desktops += 1 }
            }
        }
        return desktops
    }
}

enum SpaceSwitch {
    /// The digit keys for desktops 1 to 9.
    static let digits: [InputKey] = [.digit1, .digit2, .digit3, .digit4, .digit5, .digit6, .digit7, .digit8, .digit9]

    /// The four events of the switch: Control down, the digit down and up with the Control flag, and Control up. They
    /// are the events of the chord Control and the digit.
    static func events(_ digit: InputKey) -> [ChordEvent] {
        Chord.events(key: digit, modifiers: [.control])
    }

    /// The steps of one Space switch, in the order of the contract:
    ///
    /// 1. A number outside 1 to 9 is invalid. Koine attempts nothing.
    /// 2. When a consent check fails, post nothing.
    /// 3. Read the shortcut entry for the number. When it is off or remapped, post nothing.
    /// 4. Count the Mission Control desktops. When Koine cannot count them, or there are fewer than the number, post
    ///    nothing.
    /// 5. Create the four events. When macOS does not create one, post nothing.
    /// 6. When Koine is the front app, the outcome is `PROTECTED_FRONT_APP`.
    /// 7. Post the four events in order at the HID event tap, with no check between them. The outcome is `POSTED`.
    ///
    /// Every check comes before the first post, so no refusal can leave Control down. `shortcuts` returns the whole
    /// `AppleSymbolicHotKeys` value, or nil when the domain holds no such key. `desktops` returns the SkyLight reply,
    /// or nil when a symbol is missing or the call returns nothing.
    static func perform<Event>(
        number: Int,
        koine: KoineIdentity,
        consent: () -> PostingConsent,
        shortcuts: () -> PropertyValue?,
        desktops: () -> PropertyValue?,
        create: ([ChordEvent]) -> [Event]?,
        front: () -> FrontApp?,
        post: (Event) -> Void
    ) -> Result<SpaceSwitchOutcome, SpaceSwitchFailure> {
        guard (1...9).contains(number) else { return .failure(.invalidNumber) }
        let digit = digits[number - 1]
        if let refusal = consent().refusal { return .failure(.permission(refusal)) }
        switch DesktopShortcut.verdict(table: shortcuts(), number: number, digit: digit) {
        case .failure(let failure): return .failure(failure)
        case .success(let refusal?): return .success(refusal)
        case .success(nil): break
        }
        guard let reply = desktops(), let count = MissionControlDesktops.count(reply) else {
            return .failure(.desktopsUncountable)
        }
        guard count >= number else { return .success(.noSuchDesktop) }
        let chord = events(digit)
        guard let events = create(chord), events.count == chord.count else { return .failure(.eventNotCreated) }
        if let app = front(),
            TargetProtection.of(pid: app.pid, bundleIdentifier: app.bundleIdentifier, koine: koine) == .protected
        {
            return .success(.protectedFrontApp)
        }
        for event in events { post(event) }
        return .success(.posted)
    }
}
