import Foundation

// Stage 1 of the order of stages (docs/specs/workspace-launch-and-open.md "Order of target and application
// stages"), shared by the two operations that have a target: the caller's path is resolved component by
// component, and an over-limit spelling is refused, before anything addresses it by name. Open then reads the
// target's type, application and alias flags from the resolved spelling; reveal then reads its root decision.

/// What settling the target found.
enum TargetOutcome: Sendable {
    /// Every component resolved and every spelling is within the application hand-off limit.
    case resolved(ResolvedLocation)
    /// Absent, an impossible component and an established cycle included: `PATH_NOT_FOUND`.
    case absent(guidance: String)
    /// A step was not established, or the location is over the limit: `failed`, never a dependency.
    case failed(String)
}

/// Resolves `path` and applies the hand-off limit. `unaccomplished` is what no request did, in the past
/// tense the guidance uses ("opened", "revealed"). Nothing is cached: every action resolves afresh.
func settleTarget(_ path: LocalPath, unaccomplished: String, native: some WorkspaceNative) -> TargetOutcome {
    switch native.resolveLocation(path.text) {
    case .absent:
        return .absent(
            guidance: "Nothing exists at the requested path, or it is a link to something that does not, "
                + "so nothing was \(unaccomplished). Check the path, then try again."
        )
    case .failed(let component, let cause):
        return .failed("The path could not be resolved at \(component.debugDescription): \(cause).")
    case .present(let location):
        if let refusal = HandOffLimit.refusal(of: location, forAction: unaccomplished) { return .failed(refusal) }
        return .resolved(location)
    }
}
