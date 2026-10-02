import Foundation

/// A value decided once. The first `complete` wins; every later one is ignored,
/// so a native callback that arrives after the bound, after cancellation or a
/// second time cannot publish anything.
final class OneShot<Value: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var decided: Value?
    private var waiter: CheckedContinuation<Value, Never>?

    /// True if this call decided the outcome.
    @discardableResult
    func complete(_ value: Value) -> Bool {
        let resume: CheckedContinuation<Value, Never>?
        lock.lock()
        guard decided == nil else {
            lock.unlock()
            return false
        }
        decided = value
        resume = waiter
        waiter = nil
        lock.unlock()
        resume?.resume(returning: value)
        return true
    }

    /// Suspends until decided. Never cancels anything and never blocks a thread.
    func wait() async -> Value {
        await withCheckedContinuation { continuation in
            lock.lock()
            if let decided {
                lock.unlock()
                continuation.resume(returning: decided)
            } else {
                waiter = continuation
                lock.unlock()
            }
        }
    }
}

/// The bound on native submissions still outstanding. A submission counts from
/// before it is made until its native callback runs, so a call that timed out
/// and has not answered still counts: the provider never learns that the system
/// has abandoned it. Exhausted capacity refuses before any submission.
final class SubmissionLimit: @unchecked Sendable {
    private let lock = NSLock()
    private var outstanding = 0
    let capacity: Int

    init(capacity: Int) { self.capacity = capacity }

    var inFlight: Int { lock.withLock { outstanding } }

    /// A slot the caller releases exactly once (a second release is ignored), or nil.
    func reserve() -> Slot? {
        lock.withLock {
            guard outstanding < capacity else { return nil }
            outstanding += 1
            return Slot(limit: self)
        }
    }

    final class Slot: @unchecked Sendable {
        private let limit: SubmissionLimit
        private let released = OneShot<Void>()

        fileprivate init(limit: SubmissionLimit) { self.limit = limit }

        func release() {
            guard released.complete(()) else { return }
            limit.lock.withLock { limit.outstanding -= 1 }
        }
    }
}

/// How one native submission ended, as far as the action can tell.
enum Acknowledgment: Sendable {
    case acknowledged(LaunchedApplication?)
    /// The system's error or negative acknowledgment.
    case refused(String)
    case timedOut
    case cancelled
    /// Nothing was submitted: capacity was exhausted or the request was already cancelled.
    case notSubmitted(String)
}

/// One asynchronous, one-shot submission with a bounded wait.
///
/// The wait ends at the first of the native callback, the bound, and the
/// provider's cancellation. Whichever comes first is the outcome; the native
/// request is neither cancelled nor replayed, and the wait is never a wait *for* a
/// late callback (cancellation cleanup does not block on one). The callback's
/// closure holds only the one-shot and the slot, never a resolver or a credential.
func submitOnce(
    _ submit: (@escaping @Sendable (LaunchCompletion) -> Void) -> Void,
    limit: SubmissionLimit, bound: Duration
) async -> Acknowledgment {
    guard !Task.isCancelled else { return .notSubmitted("Cancelled before the request was submitted.") }
    guard let slot = limit.reserve() else {
        return .notSubmitted("Too many native requests are still outstanding; none was submitted.")
    }
    let outcome = OneShot<Acknowledgment>()
    submit { completion in
        // The slot is held until the system answers, however late that is.
        slot.release()
        switch completion {
        case .acknowledged(let application): outcome.complete(.acknowledged(application))
        case .refused(let reason): outcome.complete(.refused(reason))
        }
    }
    let timer = Task {
        try? await Task.sleep(for: bound)
        outcome.complete(.timedOut)
    }
    defer { timer.cancel() }
    return await withTaskCancellationHandler {
        await outcome.wait()
    } onCancel: {
        outcome.complete(.cancelled)
    }
}
