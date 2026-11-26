import Testing

@testable import DesktopProviderLogic

/// A primary display of 1440 by 900 points with a 25-point menu bar and a
/// 70-point Dock, and a second display of 1920 by 1080 to its left, 200 points
/// lower. AppKit rectangles have their origin at the bottom-left corner of the
/// primary screen, with y upward.
struct DisplayGeometryTests {
    let primary = ActiveDisplay(id: 1, bounds: ScreenRect(x: 0, y: 0, width: 1440, height: 900))
    let left = ActiveDisplay(id: 7, bounds: ScreenRect(x: -1920, y: 200, width: 1920, height: 1080))
    var primaryScreen: AppKitScreen {
        AppKitScreen(
            number: 1, frame: ScreenRect(x: 0, y: 0, width: 1440, height: 900),
            visibleFrame: ScreenRect(x: 0, y: 70, width: 1440, height: 805)
        )
    }
    var leftScreen: AppKitScreen {
        // Its top edge is 200 points below the primary display's top edge: 900 - 200 = 700.
        AppKitScreen(
            number: 7, frame: ScreenRect(x: -1920, y: -380, width: 1920, height: 1080),
            visibleFrame: ScreenRect(x: -1920, y: -380, width: 1920, height: 1080)
        )
    }

    @Test func theVisibleFrameIsFlippedIntoScreenCoordinates() {
        let displays = DisplayGeometry.displays(active: [primary], main: 1, screens: [primaryScreen])
        #expect(displays == [
            Display(
                id: 1, frame: primary.bounds,
                visibleFrame: ScreenRect(x: 0, y: 25, width: 1440, height: 805), primary: true
            )
        ])
    }

    @Test func aDisplayLeftOfThePrimaryHasNegativeCoordinatesAndComesFirst() {
        let displays = DisplayGeometry.displays(
            active: [primary, left], main: 1, screens: [primaryScreen, leftScreen]
        )
        #expect(displays.map(\.id) == [7, 1])
        #expect(displays[0].visibleFrame == ScreenRect(x: -1920, y: 200, width: 1920, height: 1080))
        #expect(displays[0].primary == false)
        #expect(displays[1].primary)
    }

    @Test func displaysWithTheSameXValueRunTopToBottom() {
        let below = ActiveDisplay(id: 3, bounds: ScreenRect(x: 0, y: 900, width: 1440, height: 900))
        let above = ActiveDisplay(id: 9, bounds: ScreenRect(x: 0, y: -900, width: 1440, height: 900))
        let displays = DisplayGeometry.displays(active: [below, primary, above], main: 1, screens: [])
        #expect(displays.map(\.id) == [9, 1, 3])
    }

    @Test func theFlagFollowsTheMainDisplayIdentifierNotTheFirstScreen() {
        let displays = DisplayGeometry.displays(
            active: [primary, left], main: 7, screens: [primaryScreen, leftScreen]
        )
        #expect(displays.filter(\.primary).map(\.id) == [7])
    }

    @Test func aDisplayWithEmptyBoundsLeftDuringTheReadAndIsLeftOut() {
        let gone = ActiveDisplay(id: 5, bounds: ScreenRect(x: 0, y: 0, width: 0, height: 0))
        let displays = DisplayGeometry.displays(active: [primary, gone], main: 1, screens: [primaryScreen])
        #expect(displays.map(\.id) == [1])
    }

    /// The first null case: no AppKit screen has the identifier. A screen
    /// without a number matches nothing, and no zero identifier stands in.
    @Test func withNoMatchingAppKitScreenTheVisibleFrameIsNull() {
        let unnumbered = AppKitScreen(number: nil, frame: leftScreen.frame, visibleFrame: leftScreen.visibleFrame)
        let displays = DisplayGeometry.displays(
            active: [primary, left], main: 1, screens: [primaryScreen, unnumbered]
        )
        #expect(displays.first { $0.id == 7 }?.visibleFrame == nil)
        #expect(displays.first { $0.id == 1 }?.visibleFrame != nil)
        #expect(DisplayGeometry.displays(active: [primary], main: 1, screens: []).first?.visibleFrame == nil)
    }

    /// The second null case: the two readings disagree, as during a display
    /// change, so the converted frame is not inside the display's frame.
    @Test func aConvertedFrameOutsideTheDisplayFrameIsNull() {
        let moved = AppKitScreen(
            number: 1, frame: primaryScreen.frame,
            visibleFrame: ScreenRect(x: 100, y: 70, width: 1440, height: 805)
        )
        #expect(DisplayGeometry.displays(active: [primary], main: 1, screens: [moved]).first?.visibleFrame == nil)
    }
}

/// The resize repeat, with the window's size as a scripted sequence of reads.
struct FrameWritesTests {
    struct Failed: Equatable { let code: Int }

    func run(
        reads: [(width: Double, height: Double)?], failAt: Int? = nil
    ) -> (outcome: FrameWrites.Outcome<Failed>, waits: Int) {
        var writes = 0
        var reads = reads[...]
        var waits = 0
        let outcome = FrameWrites.apply(
            width: 1000, height: 800,
            write: { () -> Failed? in
                writes += 1
                return writes == failAt ? Failed(code: -25200) : nil
            },
            size: { reads.popFirst() ?? nil },
            wait: { waits += 1 }
        )
        return (outcome, waits)
    }

    @Test func aSizeThatMatchesAtOnceNeedsOneWrite() {
        let (outcome, waits) = run(reads: [(1000, 800)])
        #expect(outcome.writes == 1 && outcome.failure == nil && waits == 0)
    }

    @Test func aSizeWithinTwentyPointsMatches() {
        let (outcome, _) = run(reads: [(1020, 780)])
        #expect(outcome.writes == 1)
    }

    @Test func aClampedSizeIsWrittenAgainUntilItMatches() {
        let (outcome, waits) = run(reads: [(1000, 500), (1000, 600), (1000, 800)])
        #expect(outcome.writes == 3 && outcome.failure == nil && waits == 2)
    }

    @Test func itStopsAfterEightWrites() {
        let (outcome, waits) = run(reads: Array(repeating: (300, 300), count: 20))
        #expect(outcome.writes == 8 && outcome.failure == nil && waits == 7)
    }

    @Test func aSizeThatCannotBeReadEndsTheRepeat() {
        let (outcome, waits) = run(reads: [(300, 300), nil])
        #expect(outcome.writes == 2 && outcome.failure == nil && waits == 1)
    }

    @Test func aFailedWriteEndsTheRepeatWithItsFailure() {
        let (outcome, _) = run(reads: [(300, 300), (300, 300)], failAt: 2)
        #expect(outcome.writes == 2 && outcome.failure == Failed(code: -25200))
    }
}

struct WindowVisibilityTests {
    /// Unknown in place of visible: public facts can say off screen, never on screen.
    @Test(arguments: [
        (true, false, WindowVisibility.offScreen), (false, true, .offScreen), (nil, true, .offScreen),
        (false, false, .unknown), (nil, false, .unknown),
    ] as [(Bool?, Bool, WindowVisibility)])
    func publicFactsGiveOffScreenOrUnknown(minimised: Bool?, hidden: Bool, expected: WindowVisibility) {
        #expect(WindowVisibility.fromPublicFacts(minimised: minimised, applicationHidden: hidden) == expected)
    }
}
