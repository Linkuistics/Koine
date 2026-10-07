import Foundation

// The private native adapter. Everything the workspace provider asks of the
// operating system goes through `WorkspaceNative`: the real one is
// Sources/NativeWorkspace.swift, and provider-local tests substitute their own.
// It is not a public seam and not evidence from a real binary or application.

/// The volume and the file, as the platform names them, compared by the
/// platform's own equality rather than by spelling, Unicode normalization or a
/// path prefix (`volumeIdentifierKey` with `fileResourceIdentifierKey`).
struct FileIdentity: Equatable, @unchecked Sendable {
    let volume: any NSObjectProtocol
    let file: any NSObjectProtocol

    static func == (lhs: FileIdentity, rhs: FileIdentity) -> Bool {
        lhs.volume.isEqual(rhs.volume) && lhs.file.isEqual(rhs.file)
    }
}

/// What reading the application bundle at a resolved location found. There is no absence: the walk had just
/// found the object, so a read that reports nothing there is a failure, never a missing application.
enum BundleRead: Sendable {
    /// Present, and not an application bundle.
    case notApplication
    /// An application bundle; nil when it declares no identifier and its Info.plist is not unreadable.
    case application(identifier: String?)
    /// The metadata could not be read; this is never absence and never another identifier.
    case unreadable(String)
}

enum FilesystemRootDecision: Equatable, Sendable {
    case root
    case notRoot
    /// The platform could not say, about a location the walk had found.
    case failed(String)
}

enum LaunchCompletion: Sendable {
    /// The system's acknowledgment, with the application it answered with, when it did.
    case acknowledged(LaunchedApplication?)
    /// The system's error, or a negative acknowledgment.
    case refused(String)
}

/// The application object the completion callback delivered, retained as the
/// native object itself: the observation rule compares it, never a launch date.
protocol LaunchedApplication: Sendable {
    var processIdentifier: Int32 { get }
    var isTerminated: Bool { get }
    /// The file identity of this application's executable, if the platform reports one.
    var executableIdentity: FileIdentity? { get }
    /// Whether a fresh native lookup of `pid` finds an application that is equal
    /// (`isEqual`, which the platform says to use instead of comparing PIDs) to this object.
    func freshLookupEqualsSelf(pid: Int32) -> Bool
}

protocol WorkspaceNative: Sendable {
    /// Launch Services' registered copy for the identifier, which it may report
    /// although the bundle is gone. Registration is not presence.
    func registeredApplication(bundleIdentifier: String) -> URL?
    /// Every registered copy of the identifier.
    func registeredApplications(bundleIdentifier: String) -> [URL]
    /// Prompt-free metadata of the application bundle the walk resolved, read from its resolved spelling and
    /// never the one Launch Services or the caller named: the `isApplicationKey` resource value and the bundle's identifier
    /// (docs/verification/protected-path-metadata.md). The caller applied the hand-off limit first. The
    /// file identity is the walk's own device and inode, so nothing here reads it. Never reads contents beyond
    /// the bundle's own Info.plist, never lists a directory, never asks for a default handler.
    func readApplicationBundle(of location: ResolvedLocation) -> BundleRead

    /// Submits one launch-or-activate request. `completion` may run once, on any
    /// thread, at any time, or never; the caller neither waits on it nor retries.
    /// A running copy at another URL is used only when `substitutingRunningCopy`.
    func launchApplication(
        at url: URL, substitutingRunningCopy: Bool,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    )

    /// The registered default handler for a web URL scheme, resolved from `scheme` alone
    /// (`http` or `https`): never from the URL being opened, whose host or path could
    /// make a universal-link-aware lookup answer with something other than the browser.
    /// Nil when nothing is registered.
    func defaultApplication(forWebScheme scheme: WebURL.Scheme) -> URL?

    /// Submits one request to open `url` in the application at `application`, which the
    /// caller resolved: the system is never asked to choose. Same one-shot completion
    /// contract as `launchApplication`, with the same activation, no new instance and
    /// no prompting.
    func openWebURL(
        _ url: URL, withApplicationAt application: URL,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    )

    /// Prompt-free metadata of the object the walk resolved, read from its resolved spelling (never the
    /// caller's): the `isApplicationKey`, `contentTypeKey` and `isAliasFileKey` resource values
    /// (docs/verification/protected-path-metadata.md). The caller applied the hand-off limit first. Never
    /// reads contents, never lists a directory, never asks for a default handler; an answer of nothing
    /// there is about a location the walk found, so it is reported and never read as absence.
    func readPathFacts(of location: ResolvedLocation) -> PathInspection

    /// Resolves a caller's location component by component, never by a whole-path call
    /// (`LocationWalk`; docs/specs/workspace-launch-and-open.md "Resolving an action location"). Lists
    /// nothing, opens no file, and answers presence with the device, inode, type and every spelling, absence
    /// with its cause, or a failure naming the component and cause.
    func resolveLocation(_ path: String) -> LocationResolution

    /// Whether the object `lstat` names for the literal `path` is the filesystem root's own device and
    /// inode, whatever the spelling (`lstat` does not follow a final link unless the kernel's lookup does).
    /// A whole-path call: the caller applies the hand-off limit first, and a failure here, about a location
    /// the walk found, is reported and never read as absence.
    func isFilesystemRoot(literalPath path: String) -> FilesystemRootDecision

    /// Whether the content type `identifier` conforms to (or is) `ancestor`.
    func contentType(_ identifier: String, conformsTo ancestor: String) -> Bool

    /// The registered default application for a document or directory at `url`: the
    /// system's file-URL handler lookup, with the limit `selectPathHandler` states (it
    /// prompted for protected documents). Nil when nothing is registered, and for a missing
    /// file too, which is why the caller inspects the target first.
    func defaultApplication(toOpen url: URL) -> URL?

    /// Submits one request to open the document or directory `url` in the application at
    /// `application`, which the caller resolved: the system is never asked to choose. Same
    /// one-shot completion contract and configuration as `launchApplication`; a running copy
    /// at another location is used only when `substitutingRunningCopy`.
    func openPath(
        _ url: URL, withApplicationAt application: URL, substitutingRunningCopy: Bool,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    )

    /// Submits one request that Finder select the item at `path`, which the caller inspected
    /// and which is submitted as written (`selectFile(_:inFileViewerRootedAtPath:)`: Finder's
    /// own boolean acknowledgment, no Accessibility, keystroke or menu check). When
    /// `filesystemRoot`, which the inspection decided from the filesystem and not from the
    /// spelling, the request is the documented root view instead: the root has no parent to
    /// select it in. The call is synchronous natively; the adapter must never run it on a
    /// cooperative thread. `completion` is `.acknowledged(nil)` for a true result and
    /// `.refused` for a false one, and otherwise has the same one-shot contract as
    /// `launchApplication`: it may run once, on any thread, at any time, or never.
    func revealPath(_ path: String, filesystemRoot: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void)

    /// The kernel's record of the process.
    func processStart(of pid: Int32) -> ProcessLookup
    /// The file identity of the executable the live process `pid` is running.
    func liveExecutableIdentity(of pid: Int32) -> FileIdentity?
}
