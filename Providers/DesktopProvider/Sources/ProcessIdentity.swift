import Darwin

enum ProcessLookup {
    case running(ProcessStart)
    case absent
    case unreadable(String)
}

/// Where the provider reads a start instant: the kernel's record of the process,
/// through `proc_pidinfo(PROC_PIDTBSDINFO)` of the public <libproc.h>, as
/// `pbi_start_tvsec` and `pbi_start_tvusec`, whole microseconds. `sysctl` with
/// `KERN_PROC_PID` reports the same record as `kp_proc.p_starttime`. A client
/// captures one of these; `NSRunningApplication.launchDate` is a different,
/// later instant and never matches.
func processStart(of pid: Int32) -> ProcessLookup {
    var info = proc_bsdinfo()
    let size = Int32(MemoryLayout<proc_bsdinfo>.size)
    errno = 0
    guard proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, size) == size else {
        // ESRCH is no such process. Another account's process answers EPERM:
        // it is none of this desktop's applications either.
        if errno == ESRCH || errno == EPERM { return .absent }
        return .unreadable(String(cString: strerror(errno)))
    }
    return .running(
        ProcessStart(seconds: Int64(info.pbi_start_tvsec), microseconds: Int64(info.pbi_start_tvusec))
    )
}
