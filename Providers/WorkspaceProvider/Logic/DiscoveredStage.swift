import Foundation

// Stage 3 and the pathname-reading part of stage 4 of the order of stages (docs/specs/workspace-launch-and-open.md
// "Order of target and application stages"): an application the provider discovers itself, rather than one the
// caller supplied. A discovery read (Launch Services' registered copy for an identifier, the default handler
// for a web scheme or for the item opened, Finder's registration) reports a location. This stage resolves that
// location by the walk, refuses an over-limit spelling, and only then reads the bundle: the same order as for a
// supplied application, so no registry-supplied location reaches a whole-path call before the limit. The
// discovery read has already happened, so a refusal here records exactly that read and no request.

/// What a discovered application's location turned out to be.
enum DiscoveredApplication: Sendable {
    /// Resolved, within the limit, and an application bundle; the identifier is nil for one that declares none.
    case application(identifier: String?)
    /// Established absent, or present and not an application: a stale registration, so the caller reports the
    /// dependency its own discovery read stands for (not installed, or no default handler).
    case absent
    /// The location could not be resolved or read, is a cycle or an impossible name, or is over the limit.
    /// Never read as absence.
    case failed(String)
}

/// Resolves the application at `discovered`, refuses it at the hand-off limit, then reads its bundle.
/// `action` is what no request did, in the past tense the guidance uses ("launched", "opened", "revealed").
func settleDiscoveredApplication(
    _ discovered: URL, forAction action: String, native: some WorkspaceNative
) -> DiscoveredApplication {
    let found: ResolvedLocation
    switch native.resolveLocation(discovered.path) {
    case .absent(let absence) where absence.isImpossibleOrCycle:
        // Neither is a missing registration: the location cannot be what discovery reported.
        return .failed(
            "The registered application path could not be resolved: \(explanation(of: absence)).")
    case .absent: return .absent  // a registration whose bundle is gone
    case .failed(let component, let cause):
        return .failed("The registered application path could not be resolved at \(component.debugDescription): \(cause).")
    case .present(let location):
        // The selected application's own spellings are refused here, after the read that found it and before
        // anything addresses it by path; no other copy is substituted.
        if let refusal = HandOffLimit.refusal(of: location, forAction: action, noun: "registered application path") {
            return .failed(refusal)
        }
        found = location
    }
    switch native.readApplicationBundle(of: found) {
    case .notApplication: return .absent
    case .unreadable(let reason): return .failed(unreadable(reason))
    case .application(let identifier): return .application(identifier: identifier)
    }
}
