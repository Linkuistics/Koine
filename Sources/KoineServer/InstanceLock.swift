import Foundation

/// The per-data-directory process lock: whoever holds it is the only Koine
/// instance that may write the grant store or publish the endpoint descriptor.
///
/// It is a BSD `flock` on `instance.lock`. The kernel releases it when the
/// holder exits however it exits, so a crashed instance never blocks the next
/// one and there is no stale-lock case to detect. `flock` belongs to the open
/// file description, so two servers in one process exclude each other exactly as
/// two processes do (unlike `fcntl` record locks, which are per process).
final class InstanceLock: @unchecked Sendable {
    static let fileName = "instance.lock"

    private let lock = NSLock()
    private var descriptor: Int32?

    /// Throws `KoineServerError.alreadyRunning` when another instance holds it.
    init(in directory: URL) throws {
        let path = directory.appendingPathComponent(Self.fileName).path
        let opened = open(path, O_RDWR | O_CREAT | O_CLOEXEC, 0o600)
        guard opened >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        guard flock(opened, LOCK_EX | LOCK_NB) == 0 else {
            let code = errno
            close(opened)
            throw code == EWOULDBLOCK
                ? KoineServerError.alreadyRunning
                : POSIXError(POSIXErrorCode(rawValue: code) ?? .EIO)
        }
        descriptor = opened
    }

    deinit { release() }

    func release() {
        lock.withLock {
            if let descriptor { close(descriptor) }
            descriptor = nil
        }
    }
}
