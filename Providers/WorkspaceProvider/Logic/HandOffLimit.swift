import Foundation

// The application hand-off limit (docs/specs/workspace-launch-and-open.md "Application hand-off limit"):
// macOS applications, registration and handler services take a whole pathname and fail at the SDK's
// `PATH_MAX`, so a location whose spelling reaches it is refused before any request is made. Only
// submission was measured at the exact boundary (docs/verification/long-action-route-prototype.md):
// 1,023 bytes was delivered, 1,024 and 1,025 failed.

enum HandOffLimit {
    /// `PATH_MAX` is the buffer size including the NUL, so the longest spelling handed over is one less.
    static let pathMax = 1024
    static var longestHandedOver: Int { pathMax - 1 }

    /// The first spelling the platform would need that is `PATH_MAX` bytes or more, in the order the walk met
    /// them: the literal path, each remaining path after a link expansion, then the resolved path. Bytes
    /// are counted without the terminating NUL.
    static func firstOverLimit(_ location: ResolvedLocation) -> (kind: SpellingKind, byteCount: Int)? {
        for (kind, spelling) in location.spellings where spelling.byteCount >= pathMax {
            return (kind, spelling.byteCount)
        }
        return nil
    }

    /// Guidance for a refused location: it names the hand-off stage, the spelling and its byte count, and says
    /// no request was made. It is a `failed` outcome, never a dependency: the location exists.
    static func refusal(of location: ResolvedLocation, forAction action: String) -> String? {
        guard let (kind, byteCount) = firstOverLimit(location) else { return nil }
        let spelling: String
        switch kind {
        case .literal: spelling = "the path as written"
        case .expanded(let number): spelling = "the remaining path after symbolic link \(number)"
        case .resolved: spelling = "the resolved path"
        }
        return "The application hand-off was refused: \(spelling) is \(byteCount) bytes, and a path of "
            + "\(pathMax) bytes or more cannot be handed to an application (\(longestHandedOver) is the most, "
            + "not counting the terminating NUL). No request was made, so nothing was \(action)."
    }
}
