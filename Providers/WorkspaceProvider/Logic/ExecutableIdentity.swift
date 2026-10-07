import Foundation

/// The identity the receipt's observation rule compares: the device and inode of an executable, acquired by the
/// descriptor walk (docs/specs/workspace-launch-and-open.md "Resolving an action location", the last sentence of
/// its absence paragraph; docs/adr/filesystem-access-is-descriptor-relative.md). The live process's executable
/// (`proc_pidpath`) and the retained application object's executable (`executableURL`) both come through here,
/// so they have one representation, `ObjectIdentity`, which a Foundation resource identifier can never equal.
///
/// **Observation's resolution rule is not the hand-off rule.** The action was already acknowledged, so the
/// hand-off limit (`HandOffLimit`) is never applied: a present executable of any length yields its identity.
/// Every other walk outcome (absent, a cycle, an impossible name, the link budget, a denial, any other failure)
/// yields none, and so the retained rule's existing null process. Nothing here can refuse or fail an action.
enum ExecutableIdentity {
    /// The identity of the object `path` names, or nil when the walk finds nothing it can name. A relative
    /// spelling is unavailable, not read from `/`: both sources report absolute paths.
    static func of(path: [UInt8]) -> ObjectIdentity? {
        of(path: path, using: DarwinWalkSystem())
    }

    static func of(path: [UInt8], using system: some WalkSystem) -> ObjectIdentity? {
        guard path.first == UInt8(ascii: "/") else { return nil }
        guard case .present(let location) = LocationWalk.resolve(path, using: system) else { return nil }
        return location.identity
    }
}
