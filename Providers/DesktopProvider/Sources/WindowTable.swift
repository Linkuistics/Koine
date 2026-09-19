import ApplicationServices

/// The native window identity: the accessibility element itself, held for as
/// long as it names a window. Public API gives an element no number that can be
/// written into a reference, so the reference carries this table's token and the
/// table keeps the element. `CFEqual` says whether a newly listed element is one
/// already held, so a window keeps its token, and so its reference, for as long
/// as this provider runs. docs/verification/desktop-window-identity.md holds the
/// evidence for that, and what it cannot do. Private observation state: nothing
/// a caller queried is kept. Used from the provider's one queue.
final class WindowTable {
    /// Names this provider run in every window reference it produces.
    let session: String
    private var next: UInt64 = 1
    private var held: [ProcessIncarnation: [(token: UInt64, element: AXUIElement)]] = [:]

    init() {
        var generator = SystemRandomNumberGenerator()
        let text = String(generator.next() as UInt64, radix: 16)
        session = String(repeating: "0", count: 16 - text.count) + text
    }

    /// The tokens of `elements`, in order. An element held for `process` but not
    /// listed now is kept unless it has definitely ended: a window on another
    /// Space is not listed, and an application too busy to answer has closed
    /// nothing.
    func tokens(for elements: [AXUIElement], of process: ProcessIncarnation) -> [UInt64] {
        var entries = held[process] ?? []
        let tokens = elements.map { element in
            if let known = entries.first(where: { CFEqual($0.element, element) }) {
                return known.token
            }
            defer { next += 1 }
            entries.append((next, element))
            return next
        }
        let listed = Set(tokens)
        held[process] = entries.filter { listed.contains($0.token) || !hasEnded($0.element) }
        return tokens
    }

    /// The held element `token` names, if this run holds one for `process`.
    func element(_ token: UInt64, of process: ProcessIncarnation) -> AXUIElement? {
        held[process]?.first { $0.token == token }?.element
    }

    /// Drops a token whose element has answered that its window ended.
    func retire(_ token: UInt64, of process: ProcessIncarnation) {
        held[process]?.removeAll { $0.token == token }
    }

    /// Forgets every process that is no longer running as the same incarnation.
    func forget(where isGone: (ProcessIncarnation) -> Bool) {
        for process in held.keys where isGone(process) { held[process] = nil }
    }

    private func hasEnded(_ element: AXUIElement) -> Bool {
        switch read(element, kAXRoleAttribute, as: String.self) {
        case .value(let role): role != kAXWindowRole
        case .gone: true
        case .absent, .failed: false
        }
    }
}

/// One attribute read. An error is never turned into data: only the two answers
/// that mean "this element has no such value" are `absent`.
enum AttributeRead<Value> {
    case value(Value)
    case absent
    /// The element no longer exists (`kAXErrorInvalidUIElement`).
    case gone
    case failed(AXError)
}

/// Bounds every call on one element, in seconds. A timeout set on an element
/// holds for that object alone, not for others equal to it, so it is set on each:
/// AXUIElement.h, AXUIElementSetMessagingTimeout.
let messagingTimeout: Float = 2

func read<Value>(_ element: AXUIElement, _ name: String, as type: Value.Type) -> AttributeRead<Value> {
    AXUIElementSetMessagingTimeout(element, messagingTimeout)
    var value: AnyObject?
    switch AXUIElementCopyAttributeValue(element, name as CFString, &value) {
    case .success: return (value as? Value).map(AttributeRead.value) ?? .absent
    case .noValue, .attributeUnsupported: return .absent
    case .invalidUIElement: return .gone
    case let error: return .failed(error)
    }
}
