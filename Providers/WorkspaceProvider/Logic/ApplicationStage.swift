import Foundation

// Stage 2 of the order of stages (docs/specs/workspace-launch-and-open.md "Order of target and application
// stages"): the application the caller supplied by `applicationPath`, for a constrained launch or a named open.
// The path is resolved component by component and an over-limit spelling is refused before any registration
// lookup or metadata read addresses it. Launch Services' registered copies are then resolved by the same walk
// and compared with the chosen copy by device and inode alone, so a long copy of the same application on disk
// never stops a workflow whose selected copy is short, and a long copy that is itself the selected one is
// refused at the limit and never replaced by another.

/// Why a walk that established absence of an application location is nonetheless `failed`: an impossible name
/// and a cycle say nothing is missing, only that the location cannot be what was asked for.
func explanation(of absence: Absence) -> String {
    switch absence {
    case .impossibleComponent(let component): "its name \(component.debugDescription) is longer than the filesystem allows"
    case .cycle(let link): "the symbolic link \(link.debugDescription) leads back to itself"
    case .missing(let component), .notDirectory(let component): "\(component.debugDescription) is not there"
    }
}

/// Chooses the installation a constrained launch or a named open submits, by the contract's rules:
///
/// - The caller's path is resolved first: absent is not installed, a failure (an impossible name or a cycle
///   included) is `failed`, an over-limit spelling is refused. Only then is the bundle read, from the resolved
///   spelling: a present non-application is not installed, another or no identifier is a mismatch.
/// - The identifier's registered copies, then its preferred copy if not among them, are each resolved and
///   compared by device and inode alone, in that order, stopping at the first match, and their own metadata is
///   never read. A candidate that is absent or another object is skipped, wherever it is enumerated. One reached
///   before the match whose resolution fails leaves equality unknown and is `failed`; one after it is not examined.
/// - A present chosen copy that matches no candidate is unregistered. The limit applies to the chosen copy and
///   to the matching registration, never to an unequal candidate. Another copy is never substituted.
///
/// `action` is what no request did, in the past tense the guidance uses ("launched", "opened").
func selectSuppliedApplication(
    _ request: ApplicationRequest, path: String, forAction action: String, native: some WorkspaceNative
) -> Selection {
    let chosen: ResolvedLocation
    switch native.resolveLocation(path) {
    case .absent(let absence) where absence.isImpossibleOrCycle:
        return .failed("The application path could not be resolved: \(explanation(of: absence)).")
    case .absent: return notInstalled(request)
    case .failed(let component, let cause):
        return .failed("The application path could not be resolved at \(component.debugDescription): \(cause).")
    case .present(let found):
        if let refusal = HandOffLimit.refusal(of: found, forAction: action, noun: "application path") {
            return .failed(refusal)
        }
        chosen = found
    }
    switch native.readApplicationBundle(of: chosen) {
    case .notApplication: return notInstalled(request)
    case .unreadable(let reason): return .failed(unreadable(reason))
    case .application(let identifier):
        guard identifier == request.bundleIdentifier else { return mismatch(request) }
    }
    // Present with the right identifier: eligible only if Launch Services knows this very copy.
    // Both of its answers are asked, because they were seen to disagree: a registered copy moved
    // to the Trash is returned by the lookup for the identifier and left out of the list of every
    // copy (docs/verification/application-installations-vm.md), and a present registered copy in
    // the Trash stays eligible. Apple documents neither answer's treatment of the Trash
    // (https://developer.apple.com/documentation/appkit/nsworkspace/urlsforapplications(withbundleidentifier:)):
    // this is observed on macOS 26.5, not verified against an official source.
    var candidates = native.registeredApplications(bundleIdentifier: request.bundleIdentifier)
    if let preferred = native.registeredApplication(bundleIdentifier: request.bundleIdentifier),
        !candidates.contains(preferred)
    {
        candidates.append(preferred)
    }
    for registered in candidates {
        switch native.resolveLocation(registered.path) {
        case .present(let copy) where copy.identity == chosen.identity:
            // The selected application: its own spellings are refused at the limit, never swapped for another copy.
            if let refusal = HandOffLimit.refusal(of: copy, forAction: action, noun: "registered application path") {
                return .failed(refusal)
            }
            return .selected(registered, substituting: false)
        case .present:
            continue  // another copy, however long its spelling
        case .absent(let absence) where absence.isImpossibleOrCycle:
            return .failed(unknownEquality("\(explanation(of: absence))"))
        case .absent:
            continue  // a registration whose bundle is gone
        case .failed(let component, let cause):
            // Whether this is the chosen copy is unknown, and guessing either way is wrong.
            return .failed(unknownEquality("it could not be resolved at \(component.debugDescription): \(cause)"))
        }
    }
    return notInstalled(request)
}

private func unknownEquality(_ why: String) -> String {
    "A registered copy of the application could not be compared with the one chosen, so no copy was selected: \(why)."
}
