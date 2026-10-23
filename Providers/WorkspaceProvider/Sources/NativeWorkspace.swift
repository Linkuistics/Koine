import AppKit
import Darwin
import Foundation
import UniformTypeIdentifiers

/// The real native adapter: NSWorkspace, Launch Services registration, the
/// filesystem's own metadata and libproc. It is exercised by the signed-bundle
/// and VM seams; provider-local tests substitute `WorkspaceNative` instead.
struct NativeWorkspace: WorkspaceNative {
    func registeredApplication(bundleIdentifier: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
    }

    func registeredApplications(bundleIdentifier: String) -> [URL] {
        // https://developer.apple.com/documentation/appkit/nsworkspace/urlsforapplications(withbundleidentifier:)
        NSWorkspace.shared.urlsForApplications(withBundleIdentifier: bundleIdentifier)
    }

    /// The facts of an application bundle the walk resolved, read from its resolved spelling: whether the
    /// platform calls it an application and its identifier. This is the one bundle read, for a location the
    /// caller supplied and for one Launch Services reported (a registered copy, a default handler, Finder). Its
    /// file identity is the walk's own device and inode. The planner applied the hand-off limit first, so this
    /// spelling is under `PATH_MAX`. The object was found a moment ago, so any error here, a missing-file one included, is `unreadable`: absence
    /// of a location is established by the walk alone, and this read never decides it.
    func readApplicationBundle(of location: ResolvedLocation) -> BundleRead {
        let url = fileSystemURL(of: location)
        let values: URLResourceValues
        do {
            values = try url.resourceValues(forKeys: [.isApplicationKey])
        } catch {
            return .unreadable((error as NSError).localizedDescription)
        }
        guard let isApplication = values.isApplication else { return .unreadable("its type metadata is not available") }
        guard isApplication else { return .notApplication }
        let identifier = Bundle(url: url)?.bundleIdentifier
        // `Bundle(url:)` answers nil both for a bundle that declares no identifier and for one whose
        // Info.plist it may not read, and a denial must never read as another identifier. The nil is
        // observed (macOS 26.5), not documented: https://developer.apple.com/documentation/foundation/bundle/init(url:)
        if identifier == nil, let reason = infoPlistDenial(in: url) { return .unreadable(reason) }
        return .application(identifier: identifier)
    }

    /// The URL of the resolved object, built from the resolved spelling's own bytes, so nothing is normalized
    /// or repaired, and typed by the walk.
    private func fileSystemURL(of location: ResolvedLocation) -> URL {
        let representation = location.resolved.bytes.map { CChar(bitPattern: $0) } + [0]
        return representation.withUnsafeBufferPointer {
            URL(
                fileURLWithFileSystemRepresentation: $0.baseAddress!, isDirectory: location.type == .directory,
                relativeTo: nil)
        }
    }

    /// Why the bundle's Info.plist cannot be read, or nil when it can or is not there. Only `stat` and
    /// `access` on the one path: neither opens the file, and `Bundle(url:)` already reads it
    /// (docs/verification/protected-path-metadata.md). Absence (ENOENT, ENOTDIR) is a bundle that declares
    /// no identifier, not a denial. The plist's path is longer than the bundle's, so a bundle whose resolved
    /// spelling is within the limit but whose plist's is not answers `ENAMETOOLONG`, which is a denial here:
    /// `failed`, never a mismatch.
    private func infoPlistDenial(in bundle: URL) -> String? {
        let plist = bundle.appending(path: "Contents/Info.plist").path
        var status = stat()
        errno = 0
        if stat(plist, &status) != 0 {
            return errno == ENOENT || errno == ENOTDIR ? nil : String(cString: strerror(errno))
        }
        errno = 0
        return access(plist, R_OK) == 0 ? nil : String(cString: strerror(errno))
    }

    /// A missing file as Foundation reports it, directly or beneath a POSIX ENOENT, for the metadata of an object
    /// the walk had just found: the planner reads it as a failure, so it never decides that anything is absent.
    private func isMissing(_ error: Error) -> Bool {
        let cocoa = error as NSError
        if cocoa.domain == NSCocoaErrorDomain, cocoa.code == NSFileReadNoSuchFileError { return true }
        if let underlying = cocoa.userInfo[NSUnderlyingErrorKey] as? NSError,
            underlying.domain == NSPOSIXErrorDomain, underlying.code == Int(ENOENT)
        {
            return true
        }
        return false
    }

    /// The caller's location by the descriptor walk: search-only, single-component calls from held directory
    /// handles, measured prompt-free on first-use Desktop, Documents and Downloads
    /// (docs/verification/descriptor-walk-prompt.md). No whole-path call addresses the location, so a long
    /// one is never reported missing; the application hand-off limit is applied by the planner before any
    /// call below addresses it by name.
    func resolveLocation(_ path: String) -> LocationResolution { LocationWalk.resolve(path) }

    /// Reveal's root rule, kept on the literal text: `lstat` does not follow a final link unless the kernel's
    /// own lookup does, as it does for a trailing slash, so a link to `/` is the link and `/Volumes/<name>/`
    /// is the root; `..` is physical, so `/var/..` is `/private`. A whole-path call, made only after the
    /// limit passed the literal, and any failure of it is a failure, never absence (`lstat` was measured
    /// prompt-free: docs/verification/protected-path-metadata.md).
    func isFilesystemRoot(literalPath path: String) -> FilesystemRootDecision {
        var named = stat()
        var root = stat()
        errno = 0
        guard lstat(path, &named) == 0 else { return .failed(String(cString: strerror(errno))) }
        errno = 0
        guard lstat("/", &root) == 0 else { return .failed(String(cString: strerror(errno))) }
        return named.st_dev == root.st_dev && named.st_ino == root.st_ino ? .root : .notRoot
    }

    /// The three resource values of the resolved object, measured prompt-free
    /// (docs/verification/protected-path-metadata.md). The walk already followed every link, so the resolved
    /// spelling names the object itself: a link to an application is the application, and an alias file,
    /// which is not a link, is identified as itself. The URL is built from the resolved spelling's own bytes,
    /// so nothing is normalized or repaired, and its type comes from the walk. The planner applied the
    /// hand-off limit first, so this spelling is under `PATH_MAX`. No whole-path `stat` or `realpath`
    /// addresses the caller's location, and nothing reads contents or lists a directory.
    func readPathFacts(of location: ResolvedLocation) -> PathInspection {
        let isDirectory = location.type == .directory
        let url = fileSystemURL(of: location)
        let values: URLResourceValues
        do {
            values = try url.resourceValues(forKeys: [.isApplicationKey, .contentTypeKey, .isAliasFileKey])
        } catch {
            return isMissing(error) ? .absent : .unreadable((error as NSError).localizedDescription)
        }
        // A value the platform did not supply is a failed inspection, not a "no".
        guard let isApplication = values.isApplication, let isAliasFile = values.isAliasFile else {
            return .unreadable("its type metadata is not available")
        }
        return .present(
            PathFacts(
                isDirectory: isDirectory, isApplication: isApplication, isAliasFile: isAliasFile,
                contentType: values.contentType?.identifier
            )
        )
    }

    /// https://developer.apple.com/documentation/uniformtypeidentifiers/uttype/conforms(to:)
    func contentType(_ identifier: String, conformsTo ancestor: String) -> Bool {
        guard let type = UTType(identifier) else { return identifier == ancestor }
        guard let parent = UTType(ancestor) else { return identifier == ancestor }
        return type.conforms(to: parent)
    }

    /// The configuration every open request carries, as the contract fixes it: activation on,
    /// no new instance, no printing or hiding, no arguments, environment or Apple event, and
    /// no ordinary error or authentication UI. Recent-item behavior stays the default.
    /// A running copy at another location is used only when `substitutingRunningCopy`.
    /// Gatekeeper's dialog is not suppressible by `promptsUserIfNeeded`, so the
    /// callback can come long after the provider's wait ended.
    /// https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/createsnewapplicationinstance
    /// https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/allowsrunningapplicationsubstitution
    /// https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/promptsuserifneeded
    /// (Each is confirmed against the SDK's NSWorkspace.h, macOS 26.)
    private func openConfiguration(substitutingRunningCopy: Bool) -> NSWorkspace.OpenConfiguration {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = false
        configuration.allowsRunningApplicationSubstitution = substitutingRunningCopy
        configuration.hides = false
        configuration.hidesOthers = false
        configuration.isForPrinting = false
        configuration.promptsUserIfNeeded = false
        configuration.arguments = []
        configuration.environment = [:]
        configuration.appleEvent = nil
        return configuration
    }

    /// Launch or activate.
    /// https://developer.apple.com/documentation/appkit/nsworkspace/openapplication(at:configuration:completionhandler:)
    func launchApplication(
        at url: URL, substitutingRunningCopy: Bool,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    ) {
        let configuration = openConfiguration(substitutingRunningCopy: substitutingRunningCopy)
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { application, error in
            if let error {
                completion(.refused(error.localizedDescription))
            } else {
                completion(.acknowledged(application.map(RunningApplication.init)))
            }
        }
    }

    /// The default handler of a web scheme, asked about the scheme and nothing else. The URL
    /// handed to the lookup is the scheme with no authority, path, query or fragment, so no
    /// part of a submitted URL reaches Launch Services' handler discovery, universal links
    /// included. A web scheme's answer is the default browser; a lookup of a non-file URL
    /// is not one of the file-URL lookups that prompted (protected-path-metadata.md).
    /// https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication(toopen:)-7qkzf
    /// (Confirmed against the SDK's NSWorkspace.h, macOS 26: `URLForApplicationToOpenURL:`.)
    func defaultApplication(forWebScheme scheme: WebURL.Scheme) -> URL? {
        guard let schemeOnly = URL(string: "\(scheme.rawValue):") else { return nil }
        return NSWorkspace.shared.urlForApplication(toOpen: schemeOnly)
    }

    /// Open a URL in an explicitly chosen application. The system is not asked which
    /// application should receive it, so a URL that is a universal link cannot be routed
    /// to a native app instead, and `requiresUniversalLinks` stays at its default (NO).
    /// https://developer.apple.com/documentation/appkit/nsworkspace/open(_:withapplicationat:configuration:completionhandler:)
    /// (Confirmed against the SDK's NSWorkspace.h, macOS 26: `openURLs:withApplicationAtURL:...`.)
    func openWebURL(
        _ url: URL, withApplicationAt application: URL,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    ) {
        submitOpen(url, withApplicationAt: application, substitutingRunningCopy: true, completion: completion)
    }

    /// The one request that opens a URL or a path in a chosen application.
    /// https://developer.apple.com/documentation/appkit/nsworkspace/open(_:withapplicationat:configuration:completionhandler:)
    private func submitOpen(
        _ url: URL, withApplicationAt application: URL, substitutingRunningCopy: Bool,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    ) {
        let configuration = openConfiguration(substitutingRunningCopy: substitutingRunningCopy)
        NSWorkspace.shared.open([url], withApplicationAt: application, configuration: configuration) {
            running, error in
            if let error {
                completion(.refused(error.localizedDescription))
            } else {
                completion(.acknowledged(running.map(RunningApplication.init)))
            }
        }
    }

    /// The default application for a document or directory: the file-URL lookup, which is the
    /// one route to this answer. It prompted for Files and Folders consent for documents on
    /// first-use Desktop, Documents and Downloads, and returned a handler even after the
    /// dialog was denied (protected-path-metadata.md); a directory's did not prompt. No
    /// consent is added for it, so protected default opening is a pending limit.
    /// https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication(toopen:)-7qkzf
    /// (Confirmed against the SDK's NSWorkspace.h, macOS 26: `URLForApplicationToOpenURL:`.)
    func defaultApplication(toOpen url: URL) -> URL? {
        NSWorkspace.shared.urlForApplication(toOpen: url)
    }

    /// Open a document or directory in an explicitly chosen application, with the shared
    /// configuration: nothing asks the system which application should receive it.
    func openPath(
        _ url: URL, withApplicationAt application: URL, substitutingRunningCopy: Bool,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    ) {
        submitOpen(url, withApplicationAt: application, substitutingRunningCopy: substitutingRunningCopy, completion: completion)
    }

    /// Finder's own selection request and its boolean acknowledgment; the filesystem root has
    /// no parent to select it in, so it is the documented root view (a nil item and the root as
    /// the viewer's root). Whether the path is the root was decided from the filesystem
    /// (`isFilesystemRoot(literalPath:)`), never from how the path is spelled. The call
    /// is synchronous and talks to Finder, so it runs on a global queue, never a cooperative
    /// thread, and a late result is ignored by the caller's one-shot.
    /// No Accessibility, keystroke, menu or Apple event check follows it: a true result is the
    /// acknowledgment, not observed selection.
    /// https://developer.apple.com/documentation/appkit/nsworkspace/selectfile(_:infileviewerrootedatpath:)
    /// (Confirmed against the SDK's NSWorkspace.h, macOS 26: `selectFile:inFileViewerRootedAtPath:`;
    /// a nil path shows `rootFullPath` selecting nothing, and an empty root selects in the main viewer.)
    func revealPath(_ path: String, filesystemRoot: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let accepted =
                filesystemRoot
                ? NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "/")
                : NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
            completion(
                accepted ? .acknowledged(nil) : .refused("Finder did not acknowledge selecting the item.")
            )
        }
    }

    /// HOME is `NSHomeDirectory()` and each other name is `FileManager.urls(for:in:)`, which reports the
    /// system's value without creating, resolving or opening anything (it is not the create-enabled
    /// `url(for:in:appropriateFor:create:)`). No official page was fetched for this: the ten pairs were observed
    /// on macOS 27 returning values without creating anything, and the discovery acceptance run checks them again.
    /// https://developer.apple.com/documentation/foundation/filemanager/urls(for:in:)
    func specialLocationValues(_ pair: LocationPair) -> [String] {
        let directory: FileManager.SearchPathDirectory
        switch pair.kind {
        case .home: return [NSHomeDirectory()]
        case .desktop: directory = .desktopDirectory
        case .documents: directory = .documentDirectory
        case .downloads: directory = .downloadsDirectory
        case .movies: directory = .moviesDirectory
        case .music: directory = .musicDirectory
        case .pictures: directory = .picturesDirectory
        case .applications: directory = .applicationDirectory
        }
        let domain: FileManager.SearchPathDomainMask
        switch pair.domain {
        case .user: domain = .userDomainMask
        case .local: domain = .localDomainMask
        case .system: domain = .systemDomainMask
        }
        return FileManager.default.urls(for: directory, in: domain).map(\.path)
    }

    func accountIdentifier() -> String { String(getuid()) }

    func processStart(of pid: Int32) -> ProcessLookup { readKernelProcessStart(of: pid) }

    /// The executable the live process runs: the kernel's own path for it (`proc_pidpath`, whose buffer the
    /// SDK's `PROC_PIDPATHINFO_MAXSIZE` sizes at 4 * `MAXPATHLEN`), resolved by the walk. The path is read as
    /// bytes and never decoded, and its length is never limited: the action was acknowledged already.
    func liveExecutableIdentity(of pid: Int32) -> ObjectIdentity? {
        var buffer = [UInt8](repeating: 0, count: 4 * Int(MAXPATHLEN))
        let length = buffer.withUnsafeMutableBytes { proc_pidpath(pid, $0.baseAddress, UInt32($0.count)) }
        guard length > 0 else { return nil }
        return ExecutableIdentity.of(path: Array(buffer.prefix { $0 != 0 }))
    }
}

/// `ProcessIdentity.swift` is shared as source and names its function
/// `processStart(of:)`, which a member of the same name would shadow.
private func readKernelProcessStart(of pid: Int32) -> ProcessLookup { processStart(of: pid) }

/// The identity of the executable a `file:` URL names, by the walk, from the URL's own filesystem bytes
/// (never `URL.path`, which is a `String` and so a decoded, repaired copy). Nil for a URL that is not a file URL.
/// https://developer.apple.com/documentation/foundation/url/withunsafefilesystemrepresentation(_:)
func identityOfExecutable(at url: URL) -> ObjectIdentity? {
    guard url.isFileURL else { return nil }
    let bytes = url.withUnsafeFileSystemRepresentation { pointer in
        pointer.map { Array(UnsafeBufferPointer(start: UnsafeRawPointer($0).assumingMemoryBound(to: UInt8.self), count: strlen($0))) }
    }
    return bytes.flatMap { ExecutableIdentity.of(path: $0) }
}

/// The retained native application object.
final class RunningApplication: LaunchedApplication, @unchecked Sendable {
    private let application: NSRunningApplication

    init(_ application: NSRunningApplication) { self.application = application }

    var processIdentifier: Int32 { application.processIdentifier }
    var isTerminated: Bool { application.isTerminated }

    /// The object's own `executableURL`, resolved by the walk like the live process's path.
    /// https://developer.apple.com/documentation/appkit/nsrunningapplication/executableurl
    var executableIdentity: ObjectIdentity? {
        application.executableURL.flatMap { identityOfExecutable(at: $0) }
    }

    /// `isEqual`, not PID comparison, as NSRunningApplication.h directs.
    func freshLookupEqualsSelf(pid: Int32) -> Bool {
        guard let fresh = NSRunningApplication(processIdentifier: pid) else { return false }
        return fresh.isEqual(application)
    }
}
