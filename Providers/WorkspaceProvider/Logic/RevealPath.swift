import Foundation

// Revealing a path in Finder: what is decided before the one native request. The input is the
// same literal absolute path as opening, inspected by the same prompt-free metadata calls
// (docs/verification/protected-path-metadata.md), but there is no refusal policy: revealing an
// application, an executable or a Finder alias selects it and opens nothing, so every present
// path is eligible.

/// What a reveal does, decided before anything is submitted.
enum RevealPlan: Sendable {
    /// Ask Finder to select `path`, exactly as submitted, or, when `filesystemRoot`, to show the
    /// root as a root view: the root has no parent to select it in.
    case submit(path: String, filesystemRoot: Bool)
    /// A prerequisite is missing; nothing is submitted.
    case dependency(DependencyReason, guidance: String)
    /// Metadata could not be established. Never read as absence.
    case failed(String)
}

/// Finder's bundle identifier: the reveal's one named application.
let finderBundleIdentifier = "com.apple.finder"

/// The order the contract fixes, as for opening: the target is inspected first (absent is
/// `PATH_NOT_FOUND`, unreadable is `failed`), then Finder is checked as an installed
/// application bundle by the launch's own selection. Nothing is cached: every action looks
/// afresh, and no handler lookup is made, since the destination is not chosen by the item.
func planReveal(_ path: LocalPath, native: some WorkspaceNative) -> RevealPlan {
    let facts: PathFacts
    switch native.inspectPath(path.text) {
    case .absent:
        return .dependency(
            .pathNotFound,
            guidance: "Nothing exists at the requested path, or it is a link to something that does not, "
                + "so nothing was revealed. Check the path, then try again."
        )
    case .unreadable(let reason): return .failed("The path could not be inspected: \(reason).")
    case .present(let found): facts = found
    }
    let finder = ApplicationRequest(bundleIdentifier: finderBundleIdentifier, applicationPath: nil)
    switch selectInstallation(finder, native: native) {
    case .selected: return .submit(path: path.text, filesystemRoot: facts.isFilesystemRoot)
    case .failed(let message): return .failed(message)
    case .dependency:
        // Whether Finder is unregistered, gone or not Finder at all, there is no Finder to ask.
        return .dependency(
            .applicationNotInstalled,
            guidance: "Finder (bundle identifier \(finderBundleIdentifier)) is not available on this Mac, "
                + "so nothing was revealed."
        )
    }
}
