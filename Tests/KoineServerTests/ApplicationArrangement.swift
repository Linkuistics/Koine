import Foundation

@testable import WorkspaceProviderLogic

/// How a test arranges an application location: the object at a path, as the filesystem would answer for it.
/// Test vocabulary only; the provider reads a bundle by `readApplicationBundle(of:)`.
struct ApplicationBundle: Sendable {
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
