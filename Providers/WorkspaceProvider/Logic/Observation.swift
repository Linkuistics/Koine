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
/// 3. The live process's executable and the object's executable are the same file: the same device and
///    inode, each acquired by the descriptor walk and never limited in length (`ExecutableIdentity`).
/// 4. The start instant is read again and must be the same.
/// 5. A fresh native lookup of the PID finds an application equal to the retained
///    object, whose PID and non-terminated state are checked again. Only this
///    lookup is retried, for at most `settle`: on a cold launch the callback can
///    arrive before the system's own record of the new application is complete,
///    and the first fresh lookup then finds an object that is not equal to the
///    retained one. In a signed VM that was seen on three of the first four cold
///    launches, and the next lookup, at most 5 ms later, was always equal
///    (docs/verification/launch-vm.md). A lookup that is still not equal after
///    `settle` is a mismatch like any other.
///
/// Every unavailable value or mismatch is nil. There is no PID-only identity, no
/// launch-date substitute and no foreground fallback. This is an observation, not
/// an atomic binding of the effect to a process: the process can be replaced
/// between reads, and can exit at any time afterwards.
func observeProcess(
    of application: LaunchedApplication, native: some WorkspaceNative,
    settle: Duration = .milliseconds(250)
) -> ObservedProcess? {
    let pid = application.processIdentifier
    guard pid > 0, !application.isTerminated else { return nil }
    guard case .running(let first) = native.processStart(of: pid) else { return nil }
    guard let claimed = application.executableIdentity, let live = native.liveExecutableIdentity(of: pid),
        claimed == live
    else { return nil }
    guard case .running(let second) = native.processStart(of: pid), second == first else { return nil }
    guard freshLookupEqualsSelf(application, pid: pid, settle: settle) else { return nil }
    guard application.processIdentifier == pid, !application.isTerminated else { return nil }
    return ObservedProcess(pid: pid, start: first)
}

/// The step-5 lookup, tried again every 5 ms until it is equal or `settle` has passed.
private func freshLookupEqualsSelf(_ application: LaunchedApplication, pid: Int32, settle: Duration) -> Bool {
    let deadline = ContinuousClock.now + settle
    while true {
        if application.freshLookupEqualsSelf(pid: pid) { return true }
        guard ContinuousClock.now < deadline else { return false }
        Thread.sleep(forTimeInterval: 0.005)
    }
}
