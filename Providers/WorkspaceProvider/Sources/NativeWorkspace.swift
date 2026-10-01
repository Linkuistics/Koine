import AppKit
import Darwin
import Foundation

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

    /// Only the calls docs/verification/protected-path-metadata.md measured as
    /// prompt-free on first-use Desktop, Documents and Downloads: `realpath`, the
    /// `isApplicationKey`, `volumeIdentifierKey` and `fileResourceIdentifierKey`
    /// resource values, and `Bundle(url:)`. Nothing here asks for a file's default
    /// handler, which prompted, and nothing reads a directory or a file's contents.
    func inspectApplication(at path: String) -> ApplicationInspection {
        errno = 0
        guard let resolved = realpath(path, nil) else {
            // ENOENT is a missing path or a dangling link; ENOTDIR a missing directory in it.
            if errno == ENOENT || errno == ENOTDIR { return .absent }
            return .unreadable(String(cString: strerror(errno)))
        }
        defer { free(resolved) }
        let url = URL(fileURLWithPath: String(cString: resolved))
        let values: URLResourceValues
        do {
            values = try url.resourceValues(forKeys: [
                .isApplicationKey, .volumeIdentifierKey, .fileResourceIdentifierKey,
            ])
        } catch {
            return absentOrUnreadable(error)
        }
        guard values.isApplication == true else { return .notApplication }
        guard let volume = values.volumeIdentifier, let file = values.fileResourceIdentifier else {
            return .unreadable("its file identity is not available")
        }
        return .application(
            ApplicationBundle(
                url: url, bundleIdentifier: Bundle(url: url)?.bundleIdentifier,
                identity: FileIdentity(volume: volume, file: file)
            )
        )
    }

    private func absentOrUnreadable(_ error: Error) -> ApplicationInspection {
        let cocoa = error as NSError
        if cocoa.domain == NSCocoaErrorDomain, cocoa.code == NSFileReadNoSuchFileError { return .absent }
        if let underlying = cocoa.userInfo[NSUnderlyingErrorKey] as? NSError,
            underlying.domain == NSPOSIXErrorDomain, underlying.code == Int(ENOENT)
        {
            return .absent
        }
        return .unreadable(cocoa.localizedDescription)
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
        let configuration = openConfiguration(substitutingRunningCopy: true)
        NSWorkspace.shared.open([url], withApplicationAt: application, configuration: configuration) {
            running, error in
            if let error {
                completion(.refused(error.localizedDescription))
            } else {
                completion(.acknowledged(running.map(RunningApplication.init)))
            }
        }
    }

    func processStart(of pid: Int32) -> ProcessLookup { readKernelProcessStart(of: pid) }

    /// The executable the live process runs, by the kernel's own path for it.
    func liveExecutableIdentity(of pid: Int32) -> FileIdentity? {
        var buffer = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
        guard proc_pidpath(pid, &buffer, UInt32(buffer.count)) > 0 else { return nil }
        let path = String(decoding: buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }, as: UTF8.self)
        return fileIdentity(ofPath: path)
    }
}

/// `ProcessIdentity.swift` is shared as source and names its function
/// `processStart(of:)`, which a member of the same name would shadow.
private func readKernelProcessStart(of pid: Int32) -> ProcessLookup { processStart(of: pid) }

func fileIdentity(ofPath path: String) -> FileIdentity? {
    let url = URL(fileURLWithPath: path).resolvingSymlinksInPath()
    guard let values = try? url.resourceValues(forKeys: [.volumeIdentifierKey, .fileResourceIdentifierKey]),
        let volume = values.volumeIdentifier, let file = values.fileResourceIdentifier
    else { return nil }
    return FileIdentity(volume: volume, file: file)
}

/// The retained native application object.
final class RunningApplication: LaunchedApplication, @unchecked Sendable {
    private let application: NSRunningApplication

    init(_ application: NSRunningApplication) { self.application = application }

    var processIdentifier: Int32 { application.processIdentifier }
    var isTerminated: Bool { application.isTerminated }

    var executableIdentity: FileIdentity? {
        application.executableURL.flatMap { fileIdentity(ofPath: $0.path) }
    }

    /// `isEqual`, not PID comparison, as NSRunningApplication.h directs.
    func freshLookupEqualsSelf(pid: Int32) -> Bool {
        guard let fresh = NSRunningApplication(processIdentifier: pid) else { return false }
        return fresh.isEqual(application)
    }
}
