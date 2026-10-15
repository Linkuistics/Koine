import Foundation

@testable import WorkspaceProviderLogic

/// How a test arranges an application location: the object at a path, as the filesystem would answer for it.
/// Test vocabulary only; the provider reads a bundle by `readApplicationBundle(of:)`.
struct ApplicationBundle: Sendable {
    var url: URL
    /// Nil for a bundle that declares none.
    var bundleIdentifier: String?
    var identity: ObjectIdentity
}

extension ObjectIdentity {
    /// The object a test calls `file`: the same name is always the same inode on a device (FNV-1a over its bytes).
    static func named(_ file: String, device: Int32 = 1) -> ObjectIdentity {
        let inode = Array(file.utf8).reduce(UInt64(0xcbf2_9ce4_8422_2325)) { ($0 ^ UInt64($1)) &* 0x100_0000_01b3 }
        return ObjectIdentity(device: device, inode: inode)
    }
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
