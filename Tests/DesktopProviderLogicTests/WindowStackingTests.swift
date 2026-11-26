import Testing

@testable import DesktopProviderLogic

/// Plain values for the window-server link and the point answer. The contract is "The window-server link"
/// and "Visibility at a point" in docs/specs/machine.md. Process 10 is TextEdit, and process 20 is Finder.
/// The entries run front to back, as the window server lists them.
private func rect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) -> ScreenRect {
    ScreenRect(x: x, y: y, width: width, height: height)
}

private func entry(
    _ number: UInt32, owner: Int32, _ bounds: ScreenRect?, layer: Int? = 0, alpha: Double? = 1
) -> ServerEntry {
    ServerEntry(number: number, owner: owner, layer: layer, alpha: alpha, bounds: bounds)
}

struct WindowLinkTests {
    let left = rect(0, 25, 720, 450)
    let right = rect(720, 25, 720, 450)

    // MARK: Step 1, the window number

    @Test func theWindowNumberLinksWhenTheBoundsMatchTheFrame() {
        let entries = [entry(5, owner: 20, right), entry(9, owner: 10, left)]
        let links = WindowStacking.links([LinkCandidate(owner: 10, number: 9, frame: left)], entries: entries)
        #expect(links == [1])
    }

    @Test func withAnUnknownFrameTheWindowNumberLinksAlone() {
        let entries = [entry(9, owner: 10, left)]
        #expect(WindowStacking.links([LinkCandidate(owner: 10, number: 9, frame: nil)], entries: entries) == [0])
    }

    @Test func boundsWithinTwoPointsOfTheFrameMatchAndBoundsFurtherAwayDoNot() {
        let entries = [entry(9, owner: 10, rect(2, 23, 722, 448))]
        #expect(WindowStacking.links([LinkCandidate(owner: 10, number: 9, frame: left)], entries: entries) == [0])
        let far = [entry(9, owner: 10, rect(2.5, 25, 720, 450), layer: 3)]
        #expect(WindowStacking.links([LinkCandidate(owner: 10, number: 9, frame: left)], entries: far) == [nil])
    }

    // MARK: Step 2, owner and bounds

    /// The lookup disagrees with the list: its number is not there under this owner. So the one layer-0 entry
    /// of the same owner with matching bounds decides.
    @Test(arguments: [UInt32?.none, 77, 5])
    func whereTheLookupDisagreesOwnerAndBoundsDecide(number: UInt32?) {
        let entries = [entry(5, owner: 20, left), entry(9, owner: 10, left)]
        let links = WindowStacking.links([LinkCandidate(owner: 10, number: number, frame: left)], entries: entries)
        #expect(links == [1], "number 5 belongs to Finder, so it is no link for TextEdit")
    }

    @Test func aNumberWhoseBoundsDisagreeFallsBackToOwnerAndBounds() {
        let entries = [entry(9, owner: 10, right), entry(4, owner: 10, left)]
        let links = WindowStacking.links([LinkCandidate(owner: 10, number: 9, frame: left)], entries: entries)
        #expect(links == [1])
    }

    @Test func onlyALayerZeroEntryLinksByBounds() {
        let entries = [entry(9, owner: 10, left, layer: 3), entry(4, owner: 10, left, layer: nil)]
        #expect(WindowStacking.links([LinkCandidate(owner: 10, number: nil, frame: left)], entries: entries) == [nil])
    }

    @Test func twoMatchingEntriesLinkNeither() {
        let entries = [entry(9, owner: 10, left), entry(4, owner: 10, left)]
        #expect(WindowStacking.links([LinkCandidate(owner: 10, number: nil, frame: left)], entries: entries) == [nil])
    }

    @Test func withAnUnknownFrameAndNoNumberThereIsNoLink() {
        let entries = [entry(9, owner: 10, left)]
        #expect(WindowStacking.links([LinkCandidate(owner: 10, number: nil, frame: nil)], entries: entries) == [nil])
    }

    /// Two TextEdit windows with equal bounds stay apart only through their window numbers.
    @Test func twoWindowsOfOneApplicationWithEqualBoundsLinkByNumberOnly() {
        let entries = [entry(4, owner: 10, left), entry(9, owner: 10, left)]
        let numbered = [LinkCandidate(owner: 10, number: 9, frame: left), LinkCandidate(owner: 10, number: 4, frame: left)]
        #expect(WindowStacking.links(numbered, entries: entries) == [1, 0])
        let lookupFailed = [LinkCandidate(owner: 10, number: nil, frame: left), LinkCandidate(owner: 10, number: nil, frame: left)]
        #expect(WindowStacking.links(lookupFailed, entries: [entry(9, owner: 10, left)]) == [nil, nil])
    }

    /// Another window of the same application with a matching frame blocks the bounds link, even when that
    /// other window is not on screen: equal bounds cannot tell the two apart.
    @Test func anotherWindowOfTheSameApplicationWithTheSameFrameBlocksTheBoundsLink() {
        let entries = [entry(9, owner: 10, left)]
        let candidates = [LinkCandidate(owner: 10, number: nil, frame: left), LinkCandidate(owner: 10, number: 66, frame: rect(1, 26, 720, 450))]
        #expect(WindowStacking.links(candidates, entries: entries) == [nil, nil])
        // A window of another application with the same frame does not block it.
        let other = [LinkCandidate(owner: 10, number: nil, frame: left), LinkCandidate(owner: 20, number: nil, frame: left)]
        #expect(WindowStacking.links(other, entries: entries) == [0, nil])
    }

    // MARK: No shared entry

    @Test func twoWindowsThatClaimOneEntryByNumberLinkNeither() {
        let entries = [entry(9, owner: 10, left)]
        let candidates = [LinkCandidate(owner: 10, number: 9, frame: nil), LinkCandidate(owner: 10, number: 9, frame: nil)]
        #expect(WindowStacking.links(candidates, entries: entries) == [nil, nil])
    }

    @Test func aBoundsLinkToAnEntryThatAnotherWindowHoldsByNumberIsNoLink() {
        let entries = [entry(9, owner: 10, left)]
        let candidates = [LinkCandidate(owner: 10, number: 9, frame: nil), LinkCandidate(owner: 10, number: nil, frame: left)]
        #expect(WindowStacking.links(candidates, entries: entries) == [0, nil])
    }
}

struct WindowOrderTests {
    @Test func theOrderIsThePlaceAmongTheLinkedRowsFrontToBack() {
        // Entry 0 is the menu bar, which no row links to.
        let stacking = WindowStacking.stacking(links: [3, nil, 1, 7], offScreen: [false, false, false, false])
        #expect(stacking == [
            Stacking(order: 1, visibility: .onScreen), Stacking(order: nil, visibility: .unknown),
            Stacking(order: 0, visibility: .onScreen), Stacking(order: 2, visibility: .onScreen),
        ])
    }

    /// A minimised window or a window of a hidden application is off screen with no order, whatever its link.
    @Test func publicFactsPutARowOffScreenWithNoOrder() {
        let stacking = WindowStacking.stacking(links: [2, 4, nil], offScreen: [true, false, true])
        #expect(stacking == [
            Stacking(order: nil, visibility: .offScreen), Stacking(order: 0, visibility: .onScreen),
            Stacking(order: nil, visibility: .offScreen),
        ])
    }

    @Test func rowsWithAKnownOrderComeFirstAndTheOthersKeepTheirListingOrder() {
        let stacking = [
            Stacking(order: nil, visibility: .unknown), Stacking(order: 1, visibility: .onScreen),
            Stacking(order: nil, visibility: .offScreen), Stacking(order: 0, visibility: .onScreen),
        ]
        #expect(WindowStacking.presentation(stacking) == [3, 1, 0, 2])
    }
}

struct WindowOnTopTests {
    let window = rect(100, 100, 400, 300)
    let point = (x: 200.0, y: 200.0)

    func answer(
        _ entries: [ServerEntry], link: Int?, at point: (x: Double, y: Double)? = nil, offScreen: Bool = false,
        dock: Int32? = nil, displays: [Display] = []
    ) -> OnTop {
        WindowStacking.onTop(
            link: link, offScreen: offScreen, point: point ?? self.point, entries: entries, dock: dock,
            displays: displays)
    }

    // The Dock bar rule. The display is 1440 by 900 with a menu bar of 25 points and a Dock of 70 points at the
    // bottom, so its visible frame ends at y = 830. The Dock (process 50) owns one opaque entry with the bounds
    // of the whole display, above every window, as the VM run observed on macOS 27.2.1.
    let display = Display(id: 1, frame: rect(0, 0, 1440, 900), visibleFrame: rect(0, 25, 1440, 805), primary: true)
    var dockEntries: [ServerEntry] {
        [entry(1, owner: 1, rect(0, 0, 1440, 25), layer: 24), entry(2, owner: 50, rect(0, 0, 1440, 900), layer: 20),
         entry(9, owner: 10, rect(100, 100, 400, 790))]
    }

    @Test func theDockCoversNothingInsideTheVisibleFrame() {
        #expect(answer(dockEntries, link: 2, dock: 50, displays: [display]) == .onTop)
    }

    @Test func theDockCoversItsBarOutsideTheVisibleFrame() {
        #expect(answer(dockEntries, link: 2, at: (x: 200, y: 850), dock: 50, displays: [display]) == .notOnTop)
        #expect(answer(dockEntries, link: 2, at: (x: 200, y: 829), dock: 50, displays: [display]) == .onTop,
                "the last row of the visible frame is inside it")
        #expect(answer(dockEntries, link: 2, at: (x: 200, y: 830), dock: 50, displays: [display]) == .notOnTop,
                "the bottom edge of the visible frame is outside it")
    }

    /// Where Modaliser assumes visible, Koine reports unknown.
    @Test func aDockEntryWithAnUnknownVisibleFrameOrNoDisplayMakesTheAnswerUnknown() {
        let unknown = Display(id: 1, frame: rect(0, 0, 1440, 900), visibleFrame: nil, primary: true)
        #expect(answer(dockEntries, link: 2, dock: 50, displays: [unknown]) == .unknown)
        #expect(answer(dockEntries, link: 2, dock: 50, displays: []) == .unknown)
        // A known cover still decides.
        let covered = [entry(3, owner: 20, rect(150, 150, 100, 100))] + dockEntries
        #expect(answer(covered, link: 3, dock: 50, displays: [unknown]) == .notOnTop)
    }

    /// The rule names the Dock process alone. Another owner's entry of the same shape still covers.
    @Test func anotherOwnersFullDisplayEntryStillCovers() {
        #expect(answer(dockEntries, link: 2, dock: 51, displays: [display]) == .notOnTop)
        #expect(answer(dockEntries, link: 2, dock: nil, displays: [display]) == .notOnTop)
    }

    @Test func aTranslucentDockEntryCoversNothing() {
        let tinted = [entry(2, owner: 50, rect(0, 0, 1440, 900), alpha: 0.5), entry(9, owner: 10, rect(100, 100, 400, 790))]
        #expect(answer(tinted, link: 1, at: (x: 200, y: 850), dock: 50, displays: [display]) == .onTop,
                "an alpha below 1 covers nothing, even over the Dock bar")
    }

    @Test func aWindowThatNothingCoversIsOnTop() {
        #expect(answer([entry(1, owner: 1, rect(0, 0, 1440, 25), layer: 24), entry(9, owner: 10, window)], link: 1) == .onTop)
    }

    @Test func anOffScreenWindowIsNotOnTopAndAWindowWithoutALinkIsUnknown() {
        let entries = [entry(9, owner: 10, window)]
        #expect(answer(entries, link: 0, offScreen: true) == .notOnTop)
        #expect(answer(entries, link: nil) == .unknown)
    }

    /// Entries of every layer and every owner cover, Koine's own window included.
    @Test(arguments: [(20 as Int32, 0 as Int?), (10, 0), (1, 25), (99, nil)])
    func anOpaqueEntryInFrontCovers(owner: Int32, layer: Int?) {
        let entries = [entry(3, owner: owner, rect(150, 150, 100, 100), layer: layer), entry(9, owner: 10, window)]
        #expect(answer(entries, link: 1) == .notOnTop)
    }

    @Test func anEntryWithAnAlphaBelowOneCoversNothingAndAnEntryWithNoAlphaCovers() {
        let tint = [entry(3, owner: 30, rect(0, 0, 1440, 900), alpha: 0.4), entry(9, owner: 10, window)]
        #expect(answer(tint, link: 1) == .onTop)
        let noAlpha = [entry(3, owner: 30, rect(0, 0, 1440, 900), alpha: nil), entry(9, owner: 10, window)]
        #expect(answer(noAlpha, link: 1) == .notOnTop)
    }

    @Test func anEntryBehindTheWindowCoversNothing() {
        #expect(answer([entry(9, owner: 10, window), entry(3, owner: 20, rect(0, 0, 1440, 900))], link: 0) == .onTop)
    }

    @Test func anEntryInFrontThatMissesThePointCoversNothing() {
        #expect(answer([entry(3, owner: 20, rect(300, 300, 100, 100)), entry(9, owner: 10, window)], link: 1) == .onTop)
    }

    /// The bounds of the linked entry decide, not the window frame. The bounds can be up to 2 points smaller.
    @Test func thePointMustLieInsideTheBoundsOfTheLinkedEntry() {
        let entries = [entry(9, owner: 10, rect(102, 102, 396, 296))]
        #expect(answer(entries, link: 0, at: (x: 101, y: 200)) == .notOnTop)
        #expect(answer(entries, link: 0, at: (x: 102, y: 200)) == .onTop)
    }

    @Test func aRectangleContainsItsTopAndLeftEdgesButNotItsBottomAndRightEdges() {
        let entries = [entry(9, owner: 10, window)]
        #expect(answer(entries, link: 0, at: (x: 100, y: 100)) == .onTop)
        #expect(answer(entries, link: 0, at: (x: 500, y: 200)) == .notOnTop)
        #expect(answer(entries, link: 0, at: (x: 200, y: 400)) == .notOnTop)
        let edge = [entry(3, owner: 20, rect(0, 0, 200, 900)), entry(9, owner: 10, window)]
        #expect(answer(edge, link: 1, at: (x: 200, y: 200)) == .onTop, "the right edge of the cover is outside it")
    }

    /// Where Modaliser assumes visible, Koine reports unknown.
    @Test func boundsThatTheListDoesNotGiveMakeTheAnswerUnknown() {
        #expect(answer([entry(9, owner: 10, nil)], link: 0) == .unknown)
        let front = [entry(3, owner: 20, nil), entry(9, owner: 10, window)]
        #expect(answer(front, link: 1) == .unknown)
        // A known cover still decides.
        let covered = [entry(3, owner: 20, nil), entry(4, owner: 20, window), entry(9, owner: 10, window)]
        #expect(answer(covered, link: 2) == .notOnTop)
        // A translucent entry with no bounds covers nothing in any case.
        #expect(answer([entry(3, owner: 20, nil, alpha: 0.5), entry(9, owner: 10, window)], link: 1) == .onTop)
    }
}
