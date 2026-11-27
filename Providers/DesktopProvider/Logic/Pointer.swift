/// The pure rules of the pointer position and the pointer nudge (docs/specs/machine.md, "Pointer and media"). The
/// provider reads the AppKit position, the screens, the two consent checks and the pointer buttons, and it passes
/// them here as plain values. So `swift test` holds the conversion and the order of the nudge steps without a
/// pointer, a display or Accessibility consent. Nothing here posts an event.

/// A point in screen coordinates: points from the top-left corner of the primary display, with x to the right and
/// y downward.
struct ScreenPoint: Equatable, Sendable {
    var x: Double
    var y: Double
}

/// The values of `DesktopPointerNudgeOutcome`.
enum PointerNudgeOutcome: String, Equatable, Sendable {
    case nudged = "NUDGED"
    case pointerButtonHeld = "POINTER_BUTTON_HELD"
}

/// The two checks that come before Koine posts an event: `AXIsProcessTrusted` for Accessibility consent, and
/// `CGPreflightPostEventAccess` for posting access. A device management profile can allow one and deny the other.
struct PostingConsent: Equatable, Sendable {
    let accessibility: Bool
    let posting: Bool

    /// The message of the `os-permission` failure, which names the access that macOS withholds. Nil when both
    /// checks pass. The error identifier stays `accessibility`, because that is the one OS permission that Koine
    /// owns (docs/specs/machine.md, "Grants, consent and failures").
    var refusal: String? {
        switch (accessibility, posting) {
        case (true, true):
            return nil
        case (false, false):
            return "Koine needs Accessibility access and event posting access to post events. "
                + "macOS withholds both."
        case (false, true):
            return "Koine needs Accessibility access to post events. macOS withholds Accessibility access."
        case (true, false):
            return "Koine needs event posting access to post events. macOS reports Accessibility access, "
                + "but it withholds event posting access."
        }
    }
}

/// Why the nudge failed. In each case, Koine posted nothing.
enum PointerNudgeFailure: Error, Equatable, Sendable {
    /// A consent check failed. The value is the message of `PostingConsent.refusal`.
    case permission(String)
    /// Koine cannot establish the start position.
    case positionUnknown
    /// macOS did not create both mouse-moved events.
    case eventNotCreated
}

enum PointerPosition {
    /// The pointer position in screen coordinates, from one AppKit reading, as Modaliser converts it.
    ///
    /// `location` is `NSEvent.mouseLocation`. Its origin is the bottom-left corner of the primary screen, and its
    /// y value grows upward. `firstScreenHeight` is the full height of the first screen in the same
    /// `NSScreen.screens` reading, and AppKit puts the primary screen first. The y value flips against that
    /// height. With no screen, Koine cannot convert the position, so the result is nil. Koine never invents a
    /// position.
    static func screenPoint(appKit location: (x: Double, y: Double), firstScreenHeight: Double?) -> ScreenPoint? {
        guard let height = firstScreenHeight else { return nil }
        return ScreenPoint(x: location.x, y: height - location.y)
    }
}

enum PointerNudge {
    /// The two points of the nudge: one point to the right of the start, and then the start.
    static func path(from start: ScreenPoint) -> [ScreenPoint] {
        [ScreenPoint(x: start.x + 1, y: start.y), start]
    }

    /// The steps of the nudge, in the order that the contract gives:
    ///
    /// 1. When a consent check fails, post nothing.
    /// 2. When a pointer button is held, post nothing. A pointer move then would be a drag.
    /// 3. Read the start position. When it is unknown, post nothing.
    /// 4. Create both mouse-moved events. When macOS does not create both, post nothing.
    /// 5. Post the two events in the order of `path`.
    ///
    /// No step clicks. `create` returns the event at a point, or nil. `post` posts one event.
    static func perform<Event>(
        consent: () -> PostingConsent,
        buttonHeld: () -> Bool,
        start: () async -> ScreenPoint?,
        create: (ScreenPoint) -> Event?,
        post: (Event) -> Void
    ) async -> Result<PointerNudgeOutcome, PointerNudgeFailure> {
        if let refusal = consent().refusal { return .failure(.permission(refusal)) }
        if buttonHeld() { return .success(.pointerButtonHeld) }
        guard let start = await start() else { return .failure(.positionUnknown) }
        var events: [Event] = []
        for point in path(from: start) {
            guard let event = create(point) else { return .failure(.eventNotCreated) }
            events.append(event)
        }
        events.forEach(post)
        return .success(.nudged)
    }
}
