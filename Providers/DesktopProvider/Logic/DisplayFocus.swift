/// The pure rules of display focus (docs/specs/machine.md, "Display focus"). The provider reads the
/// pointer buttons, the window list and the display frame, and it passes them here as plain values. So
/// `swift test` holds the choice of the front window and the order of the steps without a display, a
/// pointer or Accessibility consent.

/// The values of `DesktopDisplayFocusOutcome`.
enum DisplayFocusOutcome: String, Equatable, Sendable {
    case windowFocused = "WINDOW_FOCUSED"
    case noWindow = "NO_WINDOW"
    case frontWindowUnknown = "FRONT_WINDOW_UNKNOWN"
    case pointerButtonHeld = "POINTER_BUTTON_HELD"
}

/// One row of the window list, as display focus sees it.
struct FocusRow: Equatable, Sendable {
    /// The Accessibility frame. Nil when Koine cannot read it.
    let frame: ScreenRect?
    let stacking: Stacking
}

/// The window that display focus raises, by its position in the window list.
enum FrontWindow: Equatable, Sendable {
    case window(Int)
    case none
    case unknown
}

/// What display focus reports: its outcome, and whether the pointer moved.
struct DisplayFocusReceipt: Equatable, Sendable {
    let outcome: DisplayFocusOutcome
    let pointerMoved: Bool
}

enum DisplayFocus {
    /// A row is on the display when the centre of its frame is inside the frame of the display. A rectangle
    /// contains its top and left edges, but not its bottom and right edges.
    static func isOn(_ display: ScreenRect, frame: ScreenRect) -> Bool {
        display.contains(centre(of: frame))
    }

    static func centre(of rect: ScreenRect) -> (x: Double, y: Double) {
        (rect.x + rect.width / 2, rect.y + rect.height / 2)
    }

    /// The front window on the display, or why there is none.
    ///
    /// The front window is unknown in two cases. A row that is not `OFF_SCREEN` has an unknown frame, so
    /// Koine cannot say which display it is on. Or a row on the display has an unknown visibility, so Koine
    /// cannot say whether it is in front. Otherwise the front window is the `ON_SCREEN` row on the display
    /// with the lowest order. With no such row, there is no window.
    static func front(of display: ScreenRect, rows: [FocusRow]) -> FrontWindow {
        var front: (position: Int, order: Int)?
        for (position, row) in rows.enumerated() {
            guard let frame = row.frame else {
                if row.stacking.visibility != .offScreen { return .unknown }
                continue
            }
            guard isOn(display, frame: frame) else { continue }
            switch row.stacking.visibility {
            case .unknown: return .unknown
            case .offScreen: continue
            case .onScreen:
                // An on-screen row always has an order. One without would be no known place in front.
                guard let order = row.stacking.order else { return .unknown }
                if front.map({ order < $0.order }) ?? true { front = (position, order) }
            }
        }
        return front.map { .window($0.position) } ?? .none
    }

    /// The steps of display focus, in the order that the contract gives:
    ///
    /// 1. When a pointer button is held, do nothing.
    /// 2. Choose the front window from one reading of the window list. A failed reading ends the action.
    /// 3. Focus the front window, when there is one. A failed focus ends the action before the pointer moves.
    /// 4. Check the pointer buttons again. When a button is held, leave the pointer where it is.
    /// 5. Otherwise move the pointer. A failed move ends the action.
    ///
    /// No step clicks. `choose` returns the front window or the failure of its reading. `focus` and `move`
    /// return their failure, or nil.
    static func perform<Failure: Error>(
        buttonHeld: () -> Bool,
        choose: () async -> Result<FrontWindow, Failure>,
        focus: (Int) async -> Failure?,
        move: () -> Failure?
    ) async -> Result<DisplayFocusReceipt, Failure> {
        if buttonHeld() { return .success(DisplayFocusReceipt(outcome: .pointerButtonHeld, pointerMoved: false)) }
        let outcome: DisplayFocusOutcome
        switch await choose() {
        case .failure(let failure): return .failure(failure)
        case .success(.unknown): outcome = .frontWindowUnknown
        case .success(.none): outcome = .noWindow
        case .success(.window(let position)):
            if let failure = await focus(position) { return .failure(failure) }
            outcome = .windowFocused
        }
        if buttonHeld() { return .success(DisplayFocusReceipt(outcome: outcome, pointerMoved: false)) }
        if let failure = move() { return .failure(failure) }
        return .success(DisplayFocusReceipt(outcome: outcome, pointerMoved: true))
    }
}
