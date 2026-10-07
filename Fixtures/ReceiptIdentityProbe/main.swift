import AppKit
import Darwin
import Foundation

// The receipt-identity probe: the workspace provider's own sources (Providers/WorkspaceProvider/Logic and
// Sources, compiled as build.sh compiles them) with this one entry point, so the shipped adapter's two
// executable identities run against the real kernel, `NSRunningApplication` and filesystem. It exists because
// the signed bundle reaches observation only after a launch, which a host test must not make: the test starts
// this process itself, owns it, and asks it for what the shipped code answers. Test material, never shipped
// (scripts/build-app.sh does not build it).
//
// usage:
//   receipt-identity-probe self      this process's live and retained identities, as the receipt reads them
//   receipt-identity-probe unlinked  the same, after the probe unlinked its own executable
//   receipt-identity-probe url PATH  the retained route's identity for the file URL PATH names
//   receipt-identity-probe running   every application already running on this host, read and never launched or
//                                    touched: the walk's verdict on each against the route the walk replaced
//
// Each prints one JSON object: {"pid": n, "live": ID, "retained": ID, "livePathBytes": n, "executableURLBytes": n}, or {"retained": ID} for `url`, where ID
// is {"device": d, "inode": i} or null; `running` prints
// {"applications": n, "both": n, "equal": n, "disagreeing": [description]}.

func render(_ identity: ObjectIdentity?) -> Any {
    identity.map { ["device": Int($0.device), "inode": String($0.inode)] as [String: Any] } ?? NSNull()
}

func emit(_ object: [String: Any]) {
    let data = try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    print(String(decoding: data, as: UTF8.self))
}

/// This process as an application object, the way the platform answers for one: a `prohibited` activation
/// policy makes `NSRunningApplication` report an `executableURL` for a command-line program, with no window,
/// no Dock tile and no activation.
@MainActor func retainedSelf() -> RunningApplication {
    NSApplication.shared.setActivationPolicy(.prohibited)
    return RunningApplication(NSRunningApplication.current)
}

/// The lengths of the two paths the identities are read from: what the kernel reports for this process and what the
/// platform reports as its object's executable URL. They need not be the same spelling.
func pathLengths() -> [String: Any] {
    var buffer = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
    let live = proc_pidpath(getpid(), &buffer, UInt32(buffer.count))
    let reported = NSRunningApplication.current.executableURL?.withUnsafeFileSystemRepresentation { $0.map { strlen($0) } }
    return ["livePathBytes": Int(live), "executableURLBytes": reported.map { Int($0) } ?? NSNull()]
}

@MainActor func receiptIdentities() -> [String: Any] {
    let application = retainedSelf()
    return [
        "pid": Int(getpid()),
        "live": render(NativeWorkspace().liveExecutableIdentity(of: getpid())),
        "retained": render(application.executableIdentity),
    ].merging(pathLengths()) { current, _ in current }
}

/// The identity the receipt compared before the walk (`fileIdentity(ofPath:)`): the platform's volume and file
/// resource identifiers of the symlink-resolved URL. Observer only; nothing in the provider uses it.
func legacyIdentity(of url: URL) -> (volume: NSObjectProtocol, file: NSObjectProtocol)? {
    let resolved = url.resolvingSymlinksInPath()
    guard let values = try? resolved.resourceValues(forKeys: [.volumeIdentifierKey, .fileResourceIdentifierKey]),
        let volume = values.volumeIdentifier, let file = values.fileResourceIdentifier
    else { return nil }
    return (volume, file)
}

/// Whether the route the walk replaced called the live process's executable and the object's the same file; nil
/// when it could not tell (an identity unavailable, as the walk's own rule would also say).
func legacyVerdict(of running: NSRunningApplication) -> Bool? {
    var buffer = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
    guard proc_pidpath(running.processIdentifier, &buffer, UInt32(buffer.count)) > 0,
        let executable = running.executableURL,
        let live = legacyIdentity(of: URL(fileURLWithPath: String(cString: buffer))),
        let retained = legacyIdentity(of: executable)
    else { return nil }
    return live.volume.isEqual(retained.volume) && live.file.isEqual(retained.file)
}

let arguments = CommandLine.arguments.dropFirst()
switch arguments.first {
case "self":
    emit(receiptIdentities())
case "unlinked":
    // The retained object keeps the URL it had; the kernel no longer has a path for the live process.
    let application = retainedSelf()
    var buffer = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
    guard proc_pidpath(getpid(), &buffer, UInt32(buffer.count)) > 0, unlink(buffer) == 0 else {
        FileHandle.standardError.write(Data("could not unlink the probe's own executable\n".utf8))
        exit(2)
    }
    emit([
        "pid": Int(getpid()),
        "live": render(NativeWorkspace().liveExecutableIdentity(of: getpid())),
        "retained": render(application.executableIdentity),
    ])
case "url":
    guard arguments.count == 2, let path = arguments.last else { exit(64) }
    emit(["retained": render(identityOfExecutable(at: URL(fileURLWithPath: path)))])
case "running":
    // What the receipt compared before the walk, on what the real system reports: the sealed system volume, the
    // cryptex, firmlinks, bundles in the user's own tree. For every running application that reports both
    // identities, the walk's verdict (same file or not) is set against the verdict of the route it replaced,
    // kept here as the independent observer: a symlink-resolving URL and the platform's volume and file resource
    // identifiers. The walk may not change one verdict.
    var both = 0
    var equal = 0
    var disagreeing: [String] = []
    let applications = NSWorkspace.shared.runningApplications
    for running in applications where running.processIdentifier > 0 {
        let live = NativeWorkspace().liveExecutableIdentity(of: running.processIdentifier)
        let retained = RunningApplication(running).executableIdentity
        guard let live, let retained else { continue }
        both += 1
        let same = live == retained
        if same { equal += 1 }
        if let before = legacyVerdict(of: running), before != same {
            disagreeing.append("\(running.bundleIdentifier ?? "pid \(running.processIdentifier)"): walk \(same), before \(before)")
        }
    }
    emit(["applications": applications.count, "both": both, "equal": equal, "disagreeing": disagreeing])
default:
    FileHandle.standardError.write(Data("usage: receipt-identity-probe self | unlinked | url PATH | running\n".utf8))
    exit(64)
}
