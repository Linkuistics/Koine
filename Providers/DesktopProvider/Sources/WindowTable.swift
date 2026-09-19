import ApplicationServices

/// The native window identity: the accessibility element itself, held for as
/// long as it names a window. Public API gives an element no number that can be
/// written into a reference, so the reference carries this table's token and the
/// table keeps the element. `CFEqual` says whether a newly listed element is one
/// already held, so a window keeps its token, and so its reference, for as long
/// as this provider runs. docs/verification/desktop-window-identity.md holds the
/// evidence for that, and what it cannot do. Private observation state: the
/// bookkeeping is `HeldWindows`, and nothing a caller queried is kept. Used from
/// the provider's one queue.
final class WindowTable {
    /// Names this provider run in every window reference it produces.
    let session: String
    private var held = HeldWindows<AXUIElement>(same: { CFEqual($0, $1) })

    init() {
        var generator = SystemRandomNumberGenerator()
        let text = String(generator.next() as UInt64, radix: 16)
        session = String(repeating: "0", count: 16 - text.count) + text
    }

    /// The rows of `process` now that it enumerated `listed`, and after them the
    /// windows held from before that it omitted, as a window on another Space is.
    /// `ask` is put to each of those: only an element that answers that it no
    /// longer exists is dropped, since an application too busy to answer has
    /// closed nothing.
    func rows(
        listing listed: [(element: AXUIElement, title: String)], of process: ProcessIncarnation,
        ask: (AXUIElement) -> Unlisted
    ) -> [WindowRow] {
        held.rows(listing: listed, of: process, ask: ask)
    }

    /// The held element `token` names, if this run holds one for `process`.
    func element(_ token: UInt64, of process: ProcessIncarnation) -> AXUIElement? {
        held.element(token, of: process)
    }

    /// Drops a token whose element has answered that its window ended.
    func retire(_ token: UInt64, of process: ProcessIncarnation) {
        held.retire(token, of: process)
    }

    /// Drops the element the system reported destroyed.
    func retire(element: AXUIElement, of process: ProcessIncarnation) {
        held.retire(element: element, of: process)
    }

    /// Forgets every process `isGone` names, and returns them.
    @discardableResult
    func forget(where isGone: (ProcessIncarnation) -> Bool) -> [ProcessIncarnation] {
        held.forget(where: isGone)
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

func set(_ element: AXUIElement, _ name: String, to value: Bool) -> AXError {
    AXUIElementSetMessagingTimeout(element, messagingTimeout)
    return AXUIElementSetAttributeValue(element, name as CFString, value ? kCFBooleanTrue : kCFBooleanFalse)
}

func perform(_ element: AXUIElement, _ action: String) -> AXError {
    AXUIElementSetMessagingTimeout(element, messagingTimeout)
    return AXUIElementPerformAction(element, action as CFString)
}
