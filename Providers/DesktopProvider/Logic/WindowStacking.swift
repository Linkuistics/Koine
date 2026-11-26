/// The pure rules of order and visibility (docs/specs/machine.md, "The window-server link" and
/// "Visibility at a point"). The provider reads the window server's on-screen list and each held
/// window's number, frame and public facts, and passes them here as plain values. So `swift test`
/// holds every rule without a display or Accessibility consent.

/// One entry of the window server's on-screen list. The list runs front to back.
struct ServerEntry: Equatable, Sendable {
    let number: UInt32
    let owner: Int32
    /// Nil when the entry carries no layer.
    let layer: Int?
    /// Nil when the entry carries no alpha. Such an entry counts as opaque.
    let alpha: Double?
    /// Nil when the entry carries no bounds.
    let bounds: ScreenRect?
}

/// One held window, as the link sees it.
struct LinkCandidate: Equatable, Sendable {
    /// The process identifier of the application that owns the window.
    let owner: Int32
    /// The window number that the private lookup gives. Nil when the lookup fails.
    let number: UInt32?
    /// The Accessibility frame. Nil when Koine cannot read it.
    let frame: ScreenRect?
}

/// The values of `DesktopOnTop`.
enum OnTop: String, Equatable, Sendable {
    case onTop = "ON_TOP"
    case notOnTop = "NOT_ON_TOP"
    case unknown = "UNKNOWN"
}

/// One row of the window list: its place among the rows with a known order, and its visibility.
struct Stacking: Equatable, Sendable {
    let order: Int?
    let visibility: WindowVisibility
}

enum WindowStacking {
    /// Two rectangles match when each edge position and each extent differ by this many points at most,
    /// as in Modaliser's `rectsMatch`.
    static let tolerance = 2.0

    /// The entry index that each candidate links to, or nil. The link has two steps, as in Modaliser:
    ///
    /// 1. **Window number.** The list has the number under the same owner. When the frame is known, the
    ///    bounds of that entry also match it.
    /// 2. **Owner and bounds.** Otherwise, exactly one layer-0 entry of the same owner has bounds that match
    ///    the frame. No other candidate of that owner has a frame that matches those bounds.
    ///
    /// Two candidates never share an entry. When two candidates link to one entry by number, neither has a
    /// link. A link by bounds to an entry that another candidate holds by number is no link.
    static func links(_ candidates: [LinkCandidate], entries: [ServerEntry]) -> [Int?] {
        var byNumber: [Int?] = candidates.map { candidate in
            guard let number = candidate.number,
                let index = entries.firstIndex(where: { $0.number == number && $0.owner == candidate.owner })
            else { return nil }
            guard let frame = candidate.frame else { return index }
            guard let bounds = entries[index].bounds, matches(bounds, frame) else { return nil }
            return index
        }
        // An entry that two candidates claim by number belongs to neither of them.
        let claims = byNumber.compactMap { $0 }
        for (position, link) in byNumber.enumerated() {
            if let link, claims.filter({ $0 == link }).count > 1 { byNumber[position] = nil }
        }
        let held = Set(byNumber.compactMap { $0 })
        return candidates.indices.map { position in
            if let link = byNumber[position] { return link }
            let candidate = candidates[position]
            guard let frame = candidate.frame else { return nil }
            let matching = entries.indices.filter { index in
                let entry = entries[index]
                guard entry.owner == candidate.owner, entry.layer == 0, let bounds = entry.bounds else { return false }
                return matches(bounds, frame)
            }
            guard matching.count == 1, let index = matching.first, !held.contains(index),
                let bounds = entries[index].bounds
            else { return nil }
            // Equal bounds within one application: only the window numbers can tell those windows apart.
            let rival = candidates.indices.contains { other in
                other != position && candidates[other].owner == candidate.owner
                    && (candidates[other].frame.map { matches(bounds, $0) } ?? false)
            }
            return rival ? nil : index
        }
    }

    /// The order and the visibility of each row. A row that public facts put off screen is `OFF_SCREEN`
    /// with no order, whatever its link. A row with a link is `ON_SCREEN`, and its order is its place among
    /// those rows, front to back. Every other row is `UNKNOWN` with no order, never on screen.
    static func stacking(links: [Int?], offScreen: [Bool]) -> [Stacking] {
        let shown = links.indices.compactMap { position -> (position: Int, entry: Int)? in
            guard !offScreen[position], let entry = links[position] else { return nil }
            return (position, entry)
        }
        var order: [Int: Int] = [:]
        for (place, row) in shown.sorted(by: { $0.entry < $1.entry }).enumerated() { order[row.position] = place }
        return links.indices.map { position in
            if offScreen[position] { return Stacking(order: nil, visibility: .offScreen) }
            guard let place = order[position] else { return Stacking(order: nil, visibility: .unknown) }
            return Stacking(order: place, visibility: .onScreen)
        }
    }

    /// The positions of the rows in the order that the window list serves them. Rows with a known order come
    /// first, front to back. The other rows follow in their listing order.
    static func presentation(_ stacking: [Stacking]) -> [Int] {
        stacking.indices.sorted { a, b in
            switch (stacking[a].order, stacking[b].order) {
            case (let first?, let second?): first < second
            case (.some, nil): true
            case (nil, .some): false
            case (nil, nil): a < b
            }
        }
    }

    /// Whether the window is on top at `point`. A window that public facts put off screen is not on top.
    /// Without a link, the answer is unknown. Otherwise the bounds of the linked entry decide, not the
    /// window frame. Those bounds must contain the point, and no opaque entry in front may contain it.
    ///
    /// An entry in front with an alpha below 1 covers nothing. Entries of every layer and every owner
    /// cover, Koine's own included, because Koine draws no labels. Where Modaliser assumes visible, the
    /// answer is unknown. That is the case when the linked entry has no bounds. It is also the case when an
    /// opaque entry in front has no bounds and no other entry covers the window.
    ///
    /// The entries of the Dock process, `dock`, follow the Dock bar rule. With default settings the Dock
    /// owns an opaque entry with the bounds of the whole display, above every application window
    /// (docs/verification/desktop-window-layout-vm.md). So a Dock entry covers a point only outside the
    /// visible frame of the display in `displays` that contains the point, where the Dock bar is. When no
    /// display contains the point, or its visible frame is unknown, the Dock entry leaves the answer
    /// undecided, as an entry with no bounds does.
    static func onTop(
        link: Int?, offScreen: Bool, point: (x: Double, y: Double), entries: [ServerEntry],
        dock: Int32? = nil, displays: [Display] = []
    ) -> OnTop {
        if offScreen { return .notOnTop }
        guard let link else { return .unknown }
        guard let own = entries[link].bounds else { return .unknown }
        guard own.contains(point) else { return .notOnTop }
        var undecided = false
        for entry in entries[..<link] where (entry.alpha ?? 1) >= 1 {
            guard let bounds = entry.bounds else {
                undecided = true
                continue
            }
            guard bounds.contains(point) else { continue }
            guard let dock, entry.owner == dock else { return .notOnTop }
            switch dockBarContains(point, displays: displays) {
            case true?: return .notOnTop
            case false?: continue
            case nil: undecided = true
            }
        }
        return undecided ? .unknown : .onTop
    }

    /// Whether `point` lies in the Dock bar's area: inside the frame of a display, and outside that
    /// display's visible frame. Nil when no display contains the point, or its visible frame is unknown.
    static func dockBarContains(_ point: (x: Double, y: Double), displays: [Display]) -> Bool? {
        guard let display = displays.first(where: { $0.frame.contains(point) }),
            let visible = display.visibleFrame
        else { return nil }
        return !visible.contains(point)
    }

    static func matches(_ a: ScreenRect, _ b: ScreenRect) -> Bool {
        abs(a.x - b.x) <= tolerance && abs(a.y - b.y) <= tolerance && abs(a.width - b.width) <= tolerance
            && abs(a.height - b.height) <= tolerance
    }
}

extension ScreenRect {
    /// A rectangle contains its top and left edges, but not its bottom and right edges.
    func contains(_ point: (x: Double, y: Double)) -> Bool {
        point.x >= x && point.x < x + width && point.y >= y && point.y < y + height
    }
}
