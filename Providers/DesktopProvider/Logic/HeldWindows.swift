/// What an element that is held but was not listed says of itself when asked.
enum Unlisted: Equatable, Sendable {
    /// Still its own window, with this title now.
    case window(title: String)
    /// Answers, but cannot be shown to be its own window now: kept, not reported.
    case notShown
    /// Answered that it no longer exists.
    case ended
    /// Did not answer: what was last seen of it stands.
    case unanswered
}

/// One window of a listing. `remembered` is a window this run has seen that the
/// application's current enumeration omits, as it does a window on another Space.
struct WindowRow: Equatable, Sendable {
    let token: UInt64
    let title: String
    let remembered: Bool
}

/// The windows this provider run has seen, by process incarnation: each held
/// element, the token that names it in references, and the title last read from
/// it. `same` says whether two elements are one window, so a window keeps its
/// token for as long as it is held. Nothing here matches a title.
struct HeldWindows<Element> {
    private struct Entry {
        let token: UInt64
        let element: Element
        var title: String
    }

    private let same: (Element, Element) -> Bool
    private var next: UInt64 = 1
    private var held: [ProcessIncarnation: [Entry]] = [:]

    init(same: @escaping (Element, Element) -> Bool) { self.same = same }

    /// The rows of `process` after it enumerated `listed`: those windows in
    /// order, their titles refreshed, then each window held from before that the
    /// enumeration omitted, which `ask` is put to. One that ended is dropped; one
    /// that does not answer is reported as it was last seen.
    mutating func rows(
        listing listed: [(element: Element, title: String)], of process: ProcessIncarnation,
        ask: (Element) -> Unlisted
    ) -> [WindowRow] {
        var entries = held[process] ?? []
        var rows: [WindowRow] = []
        for window in listed {
            let token: UInt64
            if let index = entries.firstIndex(where: { same($0.element, window.element) }) {
                token = entries[index].token
                // An application that lists one window twice has one window.
                guard !rows.contains(where: { $0.token == token }) else { continue }
                entries[index].title = window.title
            } else {
                token = next
                next += 1
                entries.append(Entry(token: token, element: window.element, title: window.title))
            }
            rows.append(WindowRow(token: token, title: window.title, remembered: false))
        }
        let current = Set(rows.map(\.token))
        var kept: [Entry] = []
        for var entry in entries {
            if !current.contains(entry.token) {
                switch ask(entry.element) {
                case .window(let title):
                    entry.title = title
                    rows.append(WindowRow(token: entry.token, title: title, remembered: true))
                case .unanswered:
                    rows.append(WindowRow(token: entry.token, title: entry.title, remembered: true))
                case .notShown: break
                case .ended: continue
                }
            }
            kept.append(entry)
        }
        held[process] = kept
        return rows
    }

    /// The held element `token` names, if this run holds one for `process`.
    func element(_ token: UInt64, of process: ProcessIncarnation) -> Element? {
        held[process]?.first { $0.token == token }?.element
    }

    /// Drops a token whose window ended.
    mutating func retire(_ token: UInt64, of process: ProcessIncarnation) {
        held[process]?.removeAll { $0.token == token }
    }

    /// Drops the entry holding `element`, which the system reported destroyed.
    mutating func retire(element: Element, of process: ProcessIncarnation) {
        held[process]?.removeAll { same($0.element, element) }
    }

    /// Forgets every process `isGone` names, and returns them.
    @discardableResult
    mutating func forget(where isGone: (ProcessIncarnation) -> Bool) -> [ProcessIncarnation] {
        let gone = held.keys.filter(isGone)
        for process in gone { held[process] = nil }
        return gone
    }
}
