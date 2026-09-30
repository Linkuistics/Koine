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

/// An application bundle as inspected, after symlinks were resolved.
struct ApplicationBundle: Sendable {
    /// The resolved location of the bundle.
    var url: URL
    /// Nil for a bundle that declares none.
    var bundleIdentifier: String?
    var identity: FileIdentity
}

enum ApplicationInspection: Sendable {
    /// Nothing at the path after symlink resolution: missing, or a dangling link.
    case absent
    /// Present, and not an application bundle.
    case notApplication
    case application(ApplicationBundle)
    /// The metadata could not be read; this is never absence.
    case unreadable(String)
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
    /// Prompt-free metadata inspection (docs/verification/protected-path-metadata.md):
    /// `realpath`, resource values and `Bundle(url:)`, never a default-handler lookup.
    func inspectApplication(at path: String) -> ApplicationInspection

    /// Submits one launch-or-activate request. `completion` may run once, on any
    /// thread, at any time, or never; the caller neither waits on it nor retries.
    /// A running copy at another URL is used only when `substitutingRunningCopy`.
    func launchApplication(
        at url: URL, substitutingRunningCopy: Bool,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    )

    /// The kernel's record of the process.
    func processStart(of pid: Int32) -> ProcessLookup
    /// The file identity of the executable the live process `pid` is running.
    func liveExecutableIdentity(of pid: Int32) -> FileIdentity?
}
