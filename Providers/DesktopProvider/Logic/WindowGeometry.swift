/// The pure rules of window layout (docs/specs/machine.md, "Window layout"). The
/// provider reads the native values and passes them here as plain values, so
/// `swift test` holds every rule without a display or Accessibility consent.

/// A rectangle in screen coordinates: points from the top-left corner of the
/// primary display, with x to the right and y downward.
struct ScreenRect: Equatable, Sendable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    /// True when this rectangle lies inside `other`. A shared edge counts as inside.
    func isInside(_ other: ScreenRect) -> Bool {
        x >= other.x && y >= other.y && x + width <= other.x + other.width
            && y + height <= other.y + other.height
    }

    var isEmpty: Bool { width <= 0 || height <= 0 }
}

// MARK: Displays

/// One identifier from `CGGetActiveDisplayList`, with its `CGDisplayBounds`.
struct ActiveDisplay: Equatable, Sendable {
    let id: UInt32
    let bounds: ScreenRect
}

/// One AppKit screen from one `NSScreen.screens` reading. Its rectangles use
/// AppKit's coordinates, with the origin at the bottom-left corner of the
/// primary screen and y upward. `number` is its `NSScreenNumber`, when it has one.
struct AppKitScreen: Equatable, Sendable {
    let number: UInt32?
    let frame: ScreenRect
    let visibleFrame: ScreenRect
}

/// One row of `desktopDisplays`.
struct Display: Equatable, Sendable {
    let id: UInt32
    let frame: ScreenRect
    /// Nil when Koine cannot establish it: no AppKit screen has the identifier,
    /// or the converted frame is not inside `frame`.
    let visibleFrame: ScreenRect?
    let primary: Bool
}

enum DisplayGeometry {
    /// The display list from one Core Graphics reading and one AppKit reading.
    /// A display with empty bounds left during the read, so the list leaves it
    /// out. The list runs left to right by the x value of the frame, then top to
    /// bottom.
    static func displays(active: [ActiveDisplay], main: UInt32, screens: [AppKitScreen]) -> [Display] {
        active.filter { !$0.bounds.isEmpty }.map { display in
            Display(
                id: display.id, frame: display.bounds,
                visibleFrame: visibleFrame(of: display, screens: screens),
                primary: display.id == main
            )
        }
        .sorted { ($0.frame.x, $0.frame.y, $0.id) < ($1.frame.x, $1.frame.y, $1.id) }
    }

    /// The visible frame of the screen whose number is the identifier, flipped
    /// against the full height of the first screen in the same reading, as
    /// Modaliser flips it. AppKit puts the primary screen first. A screen without
    /// a number matches no display.
    static func visibleFrame(of display: ActiveDisplay, screens: [AppKitScreen]) -> ScreenRect? {
        guard let first = screens.first, let screen = screens.first(where: { $0.number == display.id })
        else { return nil }
        let appKit = screen.visibleFrame
        let converted = ScreenRect(
            x: appKit.x, y: first.frame.height - appKit.y - appKit.height,
            width: appKit.width, height: appKit.height
        )
        // The two readings disagree: the visible frame is unknown.
        return converted.isInside(display.bounds) ? converted : nil
    }
}

// MARK: Frame setting

/// Modaliser's resize repeat (`reapplyFrameUntilMatch` in its
/// WindowManipulator.swift). macOS limits a new size to the old display until
/// the window moves to the new one, so a move to a larger display writes again.
enum FrameWrites {
    /// A size within this many points of the request matches.
    static let tolerance = 20.0
    /// The first write and at most 7 repeats.
    static let maximumWrites = 8
    /// The wait before each repeat, in nanoseconds.
    static let interval: UInt64 = 50_000_000

    struct Outcome<Failure> {
        let writes: Int
        /// The failure of the last write, when one failed.
        let failure: Failure?
    }

    /// Writes the position and the size, reads the size back, and writes again
    /// until the size matches or 8 writes are done. `write` returns the failure
    /// of one position-and-size write, or nil. `size` returns the size read back,
    /// or nil when it cannot be read, which ends the repeat: the writes completed.
    static func apply<Failure>(
        width: Double, height: Double, write: () -> Failure?, size: () -> (width: Double, height: Double)?,
        wait: () -> Void
    ) -> Outcome<Failure> {
        var writes = 0
        while true {
            writes += 1
            if let failure = write() { return Outcome(writes: writes, failure: failure) }
            guard writes < maximumWrites, let read = size(),
                abs(read.width - width) > tolerance || abs(read.height - height) > tolerance
            else { return Outcome(writes: writes, failure: nil) }
            wait()
        }
    }
}

// MARK: Window list

/// The values of `DesktopWindowVisibility`.
enum WindowVisibility: String, Equatable, Sendable {
    case onScreen = "ON_SCREEN"
    case offScreen = "OFF_SCREEN"
    case unknown = "UNKNOWN"

    /// The visibility from public facts alone, before any window-server link: a
    /// minimised window, or a window of a hidden application, is off screen.
    /// Every other window is unknown, never on screen.
    static func fromPublicFacts(minimised: Bool?, applicationHidden: Bool) -> WindowVisibility {
        applicationHidden || minimised == true ? .offScreen : .unknown
    }
}
