import Foundation

/// The anonymous enrollment rate limit: at most `maximumEnrollmentsPerWindow`
/// admissions in any `enrollmentWindow`, for the whole server. It is held in
/// memory: a restart is the user's act, and refills it.
final class EnrollmentBudget: @unchecked Sendable {
    private let lock = NSLock()
    private let maximum: Int
    private let window: TimeInterval
    private var admitted: [Date] = []

    init(policy: RequestPolicy) {
        maximum = policy.maximumEnrollmentsPerWindow
        window = policy.enrollmentWindow.timeInterval
    }

    /// Nil when this enrollment is admitted, and it is then spent. Otherwise
    /// the whole seconds until one would be, and nothing is spent.
    func spend(at now: Date) -> Int? {
        lock.withLock {
            admitted.removeAll { $0 <= now - window }
            guard admitted.count >= maximum else {
                admitted.append(now)
                return nil
            }
            guard let oldest = admitted.min() else { return Int(window.rounded(.up)) }
            return max(1, Int((oldest + window).timeIntervalSince(now).rounded(.up)))
        }
    }
}
