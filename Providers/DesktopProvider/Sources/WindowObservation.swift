import AppKit
import ApplicationServices

/// What the provider watches from `start()` to `stop()`, so that a held window
/// ends when the system says so and not only when it is next asked: the
/// destruction of each held element, and the termination of applications. Both
/// are delivered on the main run loop, which the resident application runs, and
/// handed to the provider's queue, where everything else here is used. A
/// notification that never arrives loses nothing: every use of a held element
/// asks it again. Evidence: docs/verification/desktop-remembered-windows-vm.md.
final class WindowObservation: @unchecked Sendable {
    /// A destruction callback's refcon: whose element it was.
    private final class Watch: @unchecked Sendable {
        let process: ProcessIncarnation
        let observer: AXObserver
        weak var owner: WindowObservation?

        init(process: ProcessIncarnation, observer: AXObserver, owner: WindowObservation) {
            self.process = process
            self.observer = observer
            self.owner = owner
        }
    }

    private struct Ended: @unchecked Sendable {
        let element: AXUIElement
    }

    private let queue: DispatchQueue
    private let windowEnded: @Sendable (AXUIElement, ProcessIncarnation) -> Void
    private let applicationEnded: @Sendable (pid_t) -> Void
    private var watches: [ProcessIncarnation: Watch] = [:]
    private var terminations: (any NSObjectProtocol)?

    /// Both handlers run on `queue`.
    init(
        queue: DispatchQueue,
        windowEnded: @escaping @Sendable (AXUIElement, ProcessIncarnation) -> Void,
        applicationEnded: @escaping @Sendable (pid_t) -> Void
    ) {
        self.queue = queue
        self.windowEnded = windowEnded
        self.applicationEnded = applicationEnded
    }

    func start() {
        let delivery = OperationQueue()
        delivery.underlyingQueue = queue
        // Needs no Accessibility consent.
        // https://developer.apple.com/documentation/appkit/nsworkspace/didterminateapplicationnotification
        terminations = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: delivery
        ) { [applicationEnded] notification in
            let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            if let pid = application?.processIdentifier { applicationEnded(pid) }
        }
    }

    /// Asks to be told when `element`, a window of `process`, is destroyed. Asking
    /// twice is harmless (`kAXErrorNotificationAlreadyRegistered`), and a refusal
    /// is no failure of the listing that held the element.
    func watch(_ element: AXUIElement, of process: ProcessIncarnation) {
        guard let watch = watches[process] ?? makeWatch(of: process) else { return }
        // AXNotificationConstants.h: the destroyed element is the callback's element,
        // no longer valid for accessibility calls but still comparable with CFEqual.
        _ = AXObserverAddNotification(
            watch.observer, element, kAXUIElementDestroyedNotification as CFString,
            Unmanaged.passUnretained(watch).toOpaque()
        )
    }

    private func makeWatch(of process: ProcessIncarnation) -> Watch? {
        var created: AXObserver?
        let callback: AXObserverCallback = { _, element, _, refcon in
            guard let refcon else { return }
            let watch = Unmanaged<Watch>.fromOpaque(refcon).takeUnretainedValue()
            guard let owner = watch.owner else { return }
            let ended = Ended(element: element)
            owner.queue.async { owner.windowEnded(ended.element, watch.process) }
        }
        guard AXObserverCreate(process.pid, callback, &created) == .success, let observer = created else {
            return nil
        }
        // AXUIElement.h: an observer receives nothing until its source is in a run loop.
        CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .commonModes)
        let watch = Watch(process: process, observer: observer, owner: self)
        watches[process] = watch
        return watch
    }

    func forget(_ processes: [ProcessIncarnation]) {
        for process in processes {
            if let watch = watches.removeValue(forKey: process) { retire(watch) }
        }
    }

    /// Released without `stop()`, the sources must still leave the run loop first.
    deinit { stop() }

    func stop() {
        if let terminations { NSWorkspace.shared.notificationCenter.removeObserver(terminations) }
        terminations = nil
        forget(Array(watches.keys))
    }

    /// The source leaves the run loop now. A callback already running on the main
    /// thread still reads its refcon, so the refcon is released from there, after
    /// it. Where no main run loop runs the watch is never released: a leak, not a
    /// crash, and only a process with Accessibility consent ever makes one.
    private func retire(_ watch: Watch) {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(watch.observer), .commonModes)
        DispatchQueue.main.async { withExtendedLifetime(watch) {} }
    }
}
