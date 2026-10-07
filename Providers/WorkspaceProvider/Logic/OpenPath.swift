import Foundation

// Opening a document or directory: the input, the metadata refusal policy, and the choice
// of the application that receives it. The target is resolved component by component and refused at
// the hand-off limit first (`settleTarget`). Everything here reads only through the private native
// adapter, and only through the prompt-free metadata calls
// (docs/verification/protected-path-metadata.md), with one exception the spec names: the
// default handler of a document is found by the file-URL lookup, which prompted on
// protected locations in that evidence and stays a pending limit (see `selectPathHandler`).

/// One literal absolute local path, validated. Not a file URL, a glob, a tilde or an
/// environment substitution: spaces and shell punctuation are ordinary characters.
struct LocalPath: Equatable, Sendable {
    var text: String

    static func validated(_ text: String) -> Result<LocalPath, InputError> {
        guard !text.isEmpty else { return .failure(InputError("path must not be empty.")) }
        guard !text.utf8.contains(0) else { return .failure(InputError("path must not contain a NUL character.")) }
        guard text.hasPrefix("/") else { return .failure(InputError("path must be an absolute path.")) }
        return .success(LocalPath(text: text))
    }
}

/// What the platform's resource metadata says about the resolved object.
struct PathFacts: Equatable, Sendable {
    var isDirectory: Bool
    /// The native resource metadata identifies an application bundle (`isApplicationKey`).
    var isApplication: Bool
    /// The native resource metadata identifies a Finder alias file (`isAliasFileKey`).
    var isAliasFile: Bool
    /// The content type identifier, when the platform reports one.
    var contentType: String?
}

enum PathInspection: Sendable {
    /// The metadata reports nothing there. The walk had just found the object, so the planner reads this
    /// as a failure, never as absence.
    case absent
    case present(PathFacts)
    /// The metadata could not be read; this is never absence.
    case unreadable(String)
}

/// The content types whose conformance refuses a document. Deliberately not the broad
/// `public.executable` or `public.script` ancestors: ordinary source and script documents
/// (a shell script, JavaScript, a `.command` file) must reach their editor.
enum RefusedType {
    static let applicationBundle = "com.apple.application-bundle"
    static let unixExecutable = "public.unix-executable"
    static let windowsExecutable = "com.microsoft.windows-executable"
    static let aliasFile = "com.apple.alias-file"
    static let payloads = [applicationBundle, unixExecutable, windowsExecutable]
}

/// Why a document is not opened, or nil if it may be. A metadata check and nothing more: it
/// does not prove the contents cannot execute, reads no content, and cannot see a
/// replacement made after it. Permission bits play no part.
func refusalReason(for facts: PathFacts, native: some WorkspaceNative) -> String? {
    func conforms(to ancestor: String) -> Bool {
        guard let type = facts.contentType else { return false }
        return native.contentType(type, conformsTo: ancestor)
    }
    // A Finder alias is refused before any handler is chosen, in both forms: this API does
    // not resolve it, so it cannot be used to carry an application past the check below.
    if facts.isAliasFile || conforms(to: RefusedType.aliasFile) {
        return "The path is a Finder alias, which this operation does not open or resolve."
    }
    if facts.isApplication || conforms(to: RefusedType.applicationBundle) {
        return "The path is an application bundle, which this operation does not open."
    }
    if conforms(to: RefusedType.unixExecutable) || conforms(to: RefusedType.windowsExecutable) {
        return "The path is an executable program, which this operation does not open."
    }
    return nil
}

/// What a path open does, decided before anything is submitted.
enum PathPlan: Sendable {
    /// Submit `target` to `handler`. `substituting` is whether a running copy at another
    /// location may be used instead: never once the caller constrained the installation.
    case submit(target: URL, handler: URL, substituting: Bool)
    /// A prerequisite is missing; nothing is submitted.
    case dependency(DependencyReason, guidance: String)
    /// Refused payload metadata: an input error, not a prerequisite.
    case refused(String)
    /// Metadata could not be established. Never read as absence.
    case failed(String)
}

/// The order the contract fixes: the target is settled first, so a missing file is never conflated with a
/// missing handler (a native lookup answers nil for either): it is resolved component by component and an
/// over-limit spelling is refused (`settleTarget`), and only then are its type, application and alias flags
/// read, from the resolved spelling, and the payload policy applied. Then the application that receives it
/// is chosen, the default handler or the named installation. Nothing is cached: every action inspects afresh.
func planPathOpen(_ path: LocalPath, application: ApplicationRequest?, native: some WorkspaceNative) -> PathPlan {
    let location: ResolvedLocation
    switch settleTarget(path, unaccomplished: "opened", native: native) {
    case .absent(let guidance): return .dependency(.pathNotFound, guidance: guidance)
    case .failed(let message): return .failed(message)
    case .resolved(let found): location = found
    }
    let facts: PathFacts
    switch native.readPathFacts(of: location) {
    case .absent:
        // The walk found it a moment ago: a later platform absence is a failure, never absence.
        return .failed("The path could not be inspected: it was resolved, but its metadata reports nothing there.")
    case .unreadable(let reason): return .failed("The path could not be inspected: \(reason).")
    case .present(let found): facts = found
    }
    if let reason = refusalReason(for: facts, native: native) { return .refused(reason) }
    // Location-based: the literal path is submitted, and the handler follows any link as usual.
    let target = URL(fileURLWithPath: path.text, isDirectory: facts.isDirectory)

    let selection: Selection
    if let application {
        selection = selectInstallation(application, forAction: "opened", native: native)
    } else {
        selection = selectPathHandler(target, native: native)
    }
    switch selection {
    case .selected(let handler, let substituting): return .submit(target: target, handler: handler, substituting: substituting)
    case .dependency(let reason, let guidance): return .dependency(reason, guidance: guidance)
    case .failed(let message): return .failed(message)
    }
}

/// The default handler of a document or directory, present as an application bundle when
/// inspected. Registration alone is not presence, as for a launch; the handler's identifier
/// is neither required nor reported, since a handler without one can still receive a document.
///
/// **Pending limit.** The system's file-URL handler lookup is the only route to this answer,
/// and for a document it prompted for Files and Folders consent on first-use Desktop,
/// Documents and Downloads, handing back a handler even after the dialog was denied
/// (docs/verification/protected-path-metadata.md). A directory's lookup did not prompt. This
/// operation adds no consent and no fallback, so it is accepted for unprotected locations
/// only; default opening of a protected document stays pending Antony's decision.
func selectPathHandler(_ target: URL, native: some WorkspaceNative) -> Selection {
    guard let handler = native.defaultApplication(toOpen: target) else { return noPathHandler() }
    switch native.inspectApplication(at: handler.path) {
    case .absent, .notApplication: return noPathHandler()  // a stale registration
    case .unreadable(let reason): return .failed("The application could not be inspected: \(reason).")
    case .application: return .selected(handler, substituting: true)
    }
}

private func noPathHandler() -> Selection {
    .dependency(
        .noDefaultHandler,
        guidance: "No application is registered on this Mac to open this item, so it was not opened. "
            + "Choose an application to open it with, or set a default for this kind of item in Finder."
    )
}
