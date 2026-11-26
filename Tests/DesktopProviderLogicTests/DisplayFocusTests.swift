import Testing

@testable import DesktopProviderLogic

/// Plain values for display focus. The contract is "Display focus" in docs/specs/machine.md. Two displays
/// sit side by side: the primary display on the left and a second display on the right.
private func rect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) -> ScreenRect {
    ScreenRect(x: x, y: y, width: width, height: height)
}

private func onScreen(_ frame: ScreenRect?, order: Int) -> FocusRow {
    FocusRow(frame: frame, stacking: Stacking(order: order, visibility: .onScreen))
}

private func offScreen(_ frame: ScreenRect?) -> FocusRow {
    FocusRow(frame: frame, stacking: Stacking(order: nil, visibility: .offScreen))
}

private func unknown(_ frame: ScreenRect?) -> FocusRow {
    FocusRow(frame: frame, stacking: Stacking(order: nil, visibility: .unknown))
}

private let primary = rect(0, 0, 1440, 900)
private let second = rect(1440, 0, 1920, 1080)
private let onPrimary = rect(100, 100, 800, 600)
private let onSecond = rect(1600, 100, 800, 600)

struct FrontWindowTests {
    // MARK: A display with a window

    @Test func theFrontWindowIsTheOnScreenRowOnTheDisplayWithTheLowestOrder() {
        let rows = [onScreen(onSecond, order: 0), onScreen(onPrimary, order: 2), onScreen(onPrimary, order: 1)]
        #expect(DisplayFocus.front(of: primary, rows: rows) == .window(2))
        #expect(DisplayFocus.front(of: second, rows: rows) == .window(0))
    }

    @Test func aWindowThatIsOffScreenIsNeverTheFrontWindow() {
        let rows = [offScreen(onPrimary), onScreen(onPrimary, order: 3)]
        #expect(DisplayFocus.front(of: primary, rows: rows) == .window(1))
    }

    /// The centre decides, as in Modaliser: a window that reaches across the edge belongs to the display that
    /// holds its centre. The left and top edges of a display contain a centre, and its right and bottom edges
    /// do not.
    @Test func theCentreOfTheFrameDecidesTheDisplay() {
        let across = rect(1000, 100, 1000, 600)  // centre x 1500, on the second display
        #expect(DisplayFocus.front(of: primary, rows: [onScreen(across, order: 0)]) == FrontWindow.none)
        #expect(DisplayFocus.front(of: second, rows: [onScreen(across, order: 0)]) == .window(0))
        let onTheEdge = rect(1240, 100, 400, 600)  // centre x 1440, the left edge of the second display
        #expect(DisplayFocus.front(of: second, rows: [onScreen(onTheEdge, order: 0)]) == .window(0))
        #expect(DisplayFocus.front(of: primary, rows: [onScreen(onTheEdge, order: 0)]) == FrontWindow.none)
    }

    // MARK: A display with no window

    @Test func aDisplayWithNoListedWindowHasNoFrontWindow() {
        #expect(DisplayFocus.front(of: second, rows: []) == FrontWindow.none)
        #expect(DisplayFocus.front(of: second, rows: [onScreen(onPrimary, order: 0)]) == FrontWindow.none)
        #expect(DisplayFocus.front(of: second, rows: [offScreen(onSecond)]) == FrontWindow.none)
    }

    // MARK: An unknown front window

    /// A row with an unknown visibility on the display could be in front, so Koine raises nothing, whatever
    /// the other rows say. Koine never treats unknown as on screen.
    @Test func aRowOnTheDisplayWithAnUnknownVisibilityMakesTheFrontWindowUnknown() {
        let rows = [onScreen(onPrimary, order: 0), unknown(onPrimary)]
        #expect(DisplayFocus.front(of: primary, rows: rows) == .unknown)
        #expect(DisplayFocus.front(of: primary, rows: [unknown(onPrimary)]) == .unknown)
        #expect(DisplayFocus.front(of: second, rows: rows) == FrontWindow.none, "the unknown row is on the other display")
    }

    /// A row with an unknown frame could be on any display, so the front window is unknown on every display.
    /// An off-screen row with an unknown frame cannot be in front, so it does not count.
    @Test func aRowThatIsNotOffScreenWithAnUnknownFrameMakesTheFrontWindowUnknownEverywhere() {
        for row in [onScreen(nil, order: 0), unknown(nil)] {
            #expect(DisplayFocus.front(of: primary, rows: [onScreen(onPrimary, order: 1), row]) == .unknown)
            #expect(DisplayFocus.front(of: second, rows: [row]) == .unknown)
        }
        #expect(DisplayFocus.front(of: primary, rows: [onScreen(onPrimary, order: 0), offScreen(nil)]) == .window(0))
    }
}

/// The order of the steps, with each native effect recorded. The failure type stands for the provider's
/// failure result.
struct DisplayFocusStepTests {
    struct Failure: Error, Equatable { let message: String }

    final class Recorder {
        var steps: [String] = []
        var buttons: [Bool]
        init(buttons: [Bool]) { self.buttons = buttons }

        func perform(
            front: Result<FrontWindow, Failure> = .success(.none), focus: Failure? = nil, move: Failure? = nil
        ) async -> Result<DisplayFocusReceipt, Failure> {
            await DisplayFocus.perform(
                buttonHeld: {
                    steps.append("buttons")
                    return buttons.removeFirst()
                },
                choose: {
                    steps.append("list")
                    return front
                },
                focus: { position in
                    steps.append("focus \(position)")
                    return focus
                },
                move: {
                    steps.append("move")
                    return move
                }
            )
        }
    }

    // MARK: Both cases

    @Test func onADisplayWithAWindowItFocusesThatWindowAndThenMovesThePointer() async {
        let recorder = Recorder(buttons: [false, false])
        let result = await recorder.perform(front: .success(.window(3)))
        #expect(result == .success(DisplayFocusReceipt(outcome: .windowFocused, pointerMoved: true)))
        #expect(recorder.steps == ["buttons", "list", "focus 3", "buttons", "move"])
    }

    @Test func onADisplayWithNoWindowItRaisesNothingAndMovesThePointer() async {
        let recorder = Recorder(buttons: [false, false])
        let result = await recorder.perform(front: .success(.none))
        #expect(result == .success(DisplayFocusReceipt(outcome: .noWindow, pointerMoved: true)))
        #expect(recorder.steps == ["buttons", "list", "buttons", "move"])
    }

    @Test func withAnUnknownFrontWindowItRaisesNothingAndMovesThePointer() async {
        let recorder = Recorder(buttons: [false, false])
        let result = await recorder.perform(front: .success(.unknown))
        #expect(result == .success(DisplayFocusReceipt(outcome: .frontWindowUnknown, pointerMoved: true)))
        #expect(recorder.steps == ["buttons", "list", "buttons", "move"])
    }

    // MARK: Both button checks

    /// A pointer move while a button is held would be a drag. So Koine reads nothing, raises nothing and
    /// moves nothing.
    @Test func whileAButtonIsHeldAtTheStartItDoesNothing() async {
        let recorder = Recorder(buttons: [true])
        let result = await recorder.perform(front: .success(.window(0)))
        #expect(result == .success(DisplayFocusReceipt(outcome: .pointerButtonHeld, pointerMoved: false)))
        #expect(recorder.steps == ["buttons"])
    }

    /// The second check comes after the focus step. The outcome still says what happened to the windows.
    @Test(arguments: [
        (FrontWindow.window(1), DisplayFocusOutcome.windowFocused), (.none, .noWindow), (.unknown, .frontWindowUnknown),
    ])
    func whenAButtonIsHeldJustBeforeTheMoveItLeavesThePointerWhereItIs(
        front: FrontWindow, outcome: DisplayFocusOutcome
    ) async {
        let recorder = Recorder(buttons: [false, true])
        let result = await recorder.perform(front: .success(front))
        #expect(result == .success(DisplayFocusReceipt(outcome: outcome, pointerMoved: false)))
        #expect(!recorder.steps.contains("move"))
        #expect(recorder.steps.last == "buttons")
    }

    // MARK: Failures

    @Test func whenFocusFailsItReportsTheFailureAndDoesNotMoveThePointer() async {
        let recorder = Recorder(buttons: [false, false])
        let result = await recorder.perform(front: .success(.window(0)), focus: Failure(message: "no focus"))
        #expect(result == .failure(Failure(message: "no focus")))
        #expect(recorder.steps == ["buttons", "list", "focus 0"])
    }

    @Test func whenTheWindowListFailsItRaisesNothingAndDoesNotMoveThePointer() async {
        let recorder = Recorder(buttons: [false, false])
        let result = await recorder.perform(front: .failure(Failure(message: "no list")))
        #expect(result == .failure(Failure(message: "no list")))
        #expect(recorder.steps == ["buttons", "list"])
    }

    @Test func whenThePointerMoveFailsItReportsTheFailure() async {
        let recorder = Recorder(buttons: [false, false])
        let result = await recorder.perform(front: .success(.none), move: Failure(message: "no move"))
        #expect(result == .failure(Failure(message: "no move")))
        #expect(recorder.steps == ["buttons", "list", "buttons", "move"])
    }
}
