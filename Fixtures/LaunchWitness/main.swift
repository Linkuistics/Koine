import AppKit
import Darwin
import Foundation

// Test material, never shipped: the independent native witness of
// docs/verification/launch-vm.md. It says what the system itself reports of the
// applications and processes a launch involves, with no Koine code, no Koine
// grant and no Accessibility: NSWorkspace and NSRunningApplication for who is in
// front and what runs, libproc for a process's kernel start instant, kqueue for
// its exit. Nothing here can be satisfied by an acknowledgment.
//
// usage: LaunchWitness frontmost
//        LaunchWitness instances <bundle identifier>
//        LaunchWitness process <pid>
//        LaunchWitness watch <seconds>
//        LaunchWitness exit <pid> <seconds>
//
// `watch` prints one JSON line for the state it starts in and one for every
// application the system reports launched, activated or terminated, stamped with
// the guest's clock in milliseconds since the epoch, so that a request's send and
// answer times (the guest client stamps them from the same clock) place the
// activation between them. `exit` blocks until the process is gone or the time
// passes, and reports when.

func nowMs() -> Int { Int((Date().timeIntervalSince1970 * 1000).rounded()) }

/// The kernel's start instant of a process in the contract's canonical UTC form,
/// whole microseconds: what `proc_pidinfo(PROC_PIDTBSDINFO)` says, read here
/// independently of Koine's own reading of it.
func kernelStart(_ pid: pid_t) -> String? {
    var info = proc_bsdinfo()
    let size = Int32(MemoryLayout<proc_bsdinfo>.size)
    guard proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, size) == size else { return nil }
    let seconds = Int(info.pbi_start_tvsec)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let date = Date(timeIntervalSince1970: TimeInterval(seconds))
    return formatter.string(from: date) + String(format: ".%06dZ", Int(info.pbi_start_tvusec))
}

func describe(_ application: NSRunningApplication) -> [String: Any] {
    [
        "pid": Int(application.processIdentifier),
        "bundleIdentifier": application.bundleIdentifier ?? NSNull(),
        "name": application.localizedName ?? NSNull(),
        "startedAt": kernelStart(application.processIdentifier) ?? NSNull(),
        "executable": application.executableURL?.path ?? NSNull(),
        "bundle": application.bundleURL?.path ?? NSNull(),
        "isActive": application.isActive,
        "isTerminated": application.isTerminated,
    ]
}

func emit(_ object: [String: Any]) {
    let data = try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    FileHandle.standardOutput.write(data + Data("\n".utf8))
}

func frontmostState() -> [String: Any] {
    // The window server's frontmost ordinary window is a second, independent
    // witness of which application is in front.
    let front = (CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
        as? [[String: Any]] ?? []).first { ($0[kCGWindowLayer as String] as? Int) == 0 }
    return [
        "atMs": nowMs(),
        "application": NSWorkspace.shared.frontmostApplication.map(describe) ?? NSNull(),
        "frontCGWindow": front.map {
            ["windowNumber": $0[kCGWindowNumber as String] ?? NSNull(), "pid": $0[kCGWindowOwnerPID as String] ?? NSNull()]
        } ?? NSNull(),
    ]
}

let arguments = CommandLine.arguments
switch (arguments.count, arguments.count > 1 ? arguments[1] : "") {
case (2, "frontmost"):
    emit(frontmostState())
case (3, "instances"):
    emit([
        "atMs": nowMs(),
        "instances": NSRunningApplication.runningApplications(withBundleIdentifier: arguments[2]).map(describe),
    ])
case (3, "process"):
    guard let pid = pid_t(arguments[2]) else { exit(2) }
    let live = NSRunningApplication(processIdentifier: pid)
    emit([
        "atMs": nowMs(), "pid": Int(pid), "startedAt": kernelStart(pid) ?? NSNull(),
        "application": live.map(describe) ?? NSNull(),
    ])
case (3, "watch"):
    guard let seconds = Double(arguments[2]) else { exit(2) }
    var initial = frontmostState()
    initial["event"] = "initial"
    emit(initial)
    let center = NSWorkspace.shared.notificationCenter
    for (name, event) in [
        (NSWorkspace.didLaunchApplicationNotification, "launched"),
        (NSWorkspace.didActivateApplicationNotification, "activated"),
        (NSWorkspace.didTerminateApplicationNotification, "terminated"),
    ] {
        center.addObserver(forName: name, object: nil, queue: nil) { note in
            guard let application = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
            emit(["event": event, "atMs": nowMs(), "application": describe(application)])
        }
    }
    let began = Date()
    while Date().timeIntervalSince(began) < seconds { CFRunLoopRunInMode(.defaultMode, 0.05, false) }
    emit(["event": "end", "atMs": nowMs()])
case (4, "exit"):
    guard let pid = pid_t(arguments[2]), let seconds = Double(arguments[3]) else { exit(2) }
    let queue = kqueue()
    var change = kevent(
        ident: UInt(pid), filter: Int16(EVFILT_PROC), flags: UInt16(EV_ADD | EV_ONESHOT),
        fflags: UInt32(NOTE_EXIT), data: 0, udata: nil)
    var event = kevent()
    var limit = timespec(tv_sec: Int(seconds), tv_nsec: Int((seconds - Double(Int(seconds))) * 1e9))
    let started = nowMs()
    let count = kevent(queue, &change, 1, &event, 1, &limit)
    if count == 1, event.fflags & UInt32(NOTE_EXIT) != 0 {
        emit(["pid": Int(pid), "exited": true, "waitedFromMs": started, "atMs": nowMs()])
    } else if count == -1 && errno == ESRCH {
        emit(["pid": Int(pid), "exited": true, "alreadyGone": true, "atMs": nowMs()])
    } else {
        emit(["pid": Int(pid), "exited": false, "waitedFromMs": started, "atMs": nowMs()])
    }
default:
    FileHandle.standardError.write(
        Data("usage: LaunchWitness frontmost | instances <bundle id> | process <pid> | watch <seconds> | exit <pid> <seconds>\n".utf8))
    exit(2)
}
