import Foundation

// Revealing a path in Finder: what is decided before the one native request. The input is the
// same literal absolute path as opening. It is resolved component by component, never by a whole-path
// call (LocationWalk), and refused at the application hand-off when a spelling reaches PATH_MAX
// (HandOffLimit). There is no refusal policy beyond that: revealing an application, an executable or a
// Finder alias selects it and opens nothing, so every present path within the limit is eligible.

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

/// The order the contract fixes, as for opening: the target is resolved first (absent is
/// `PATH_NOT_FOUND`, a resolution failure is `failed`), and an over-limit spelling is refused before
/// anything addresses the path by name. Only then is the root decision read and Finder checked as an
/// installed application bundle by the launch's own selection. Nothing is cached: every action looks
/// afresh, and no handler lookup is made, since the destination is not chosen by the item.
func planReveal(_ path: LocalPath, native: some WorkspaceNative) -> RevealPlan {
    let location: ResolvedLocation
    switch native.resolveLocation(path.text) {
    case .absent:
        return .dependency(
            .pathNotFound,
            guidance: "Nothing exists at the requested path, or it is a link to something that does not, "
                + "so nothing was revealed. Check the path, then try again."
        )
    case .failed(let component, let cause):
        return .failed("The path could not be resolved at \(component.debugDescription): \(cause).")
    case .present(let found): location = found
    }
    if let refusal = HandOffLimit.refusal(of: location, forAction: "revealed") { return .failed(refusal) }
    let filesystemRoot: Bool
    switch native.isFilesystemRoot(literalPath: path.text) {
    case .root: filesystemRoot = true
    case .notRoot: filesystemRoot = false
    case .failed(let reason): return .failed("The path could not be inspected: \(reason).")
    }
    let finder = ApplicationRequest(bundleIdentifier: finderBundleIdentifier, applicationPath: nil)
    switch selectInstallation(finder, native: native) {
    case .selected: return .submit(path: path.text, filesystemRoot: filesystemRoot)
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
