import Foundation

/// The process incarnation an acknowledged launch may carry in its receipt.
struct ObservedProcess: Equatable, Sendable {
    var pid: Int32
    var start: ProcessStart
}

/// The receipt's observation rule, for the application object the completion
/// callback delivered (docs/specs/workspace-launch-and-open.md, "Results and
/// failure boundary"):
///
/// 1. The retained object has a positive PID and is not terminated.
/// 2. The kernel's start instant of that PID is read.
/// 3. The live process's executable and the object's executable are the same file.
/// 4. The start instant is read again and must be the same.
/// 5. A fresh native lookup of the PID finds an application equal to the retained
///    object, whose PID and non-terminated state are checked again.
///
/// Every unavailable value or mismatch is nil. There is no PID-only identity, no
/// launch-date substitute and no foreground fallback. This is an observation, not
/// an atomic binding of the effect to a process: the process can be replaced
/// between reads, and can exit at any time afterwards.
func observeProcess(of application: LaunchedApplication, native: some WorkspaceNative) -> ObservedProcess? {
    let pid = application.processIdentifier
    guard pid > 0, !application.isTerminated else { return nil }
    guard case .running(let first) = native.processStart(of: pid) else { return nil }
    guard let claimed = application.executableIdentity, let live = native.liveExecutableIdentity(of: pid),
        claimed == live
    else { return nil }
    guard case .running(let second) = native.processStart(of: pid), second == first else { return nil }
    guard application.freshLookupEqualsSelf(pid: pid) else { return nil }
    guard application.processIdentifier == pid, !application.isTerminated else { return nil }
    return ObservedProcess(pid: pid, start: first)
}
