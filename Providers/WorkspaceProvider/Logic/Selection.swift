import Foundation

/// The closed set of pre-submission prerequisite failures the launch root can
/// report; the raw values are the SDL's `WorkspaceDependencyReason`.
enum DependencyReason: String, Sendable {
    case applicationNotInstalled = "APPLICATION_NOT_INSTALLED"
    case applicationIdentityMismatch = "APPLICATION_IDENTITY_MISMATCH"
    case pathNotFound = "PATH_NOT_FOUND"
    case noDefaultHandler = "NO_DEFAULT_HANDLER"
}

/// One `WorkspaceApplicationInput`, validated.
struct ApplicationRequest: Equatable, Sendable {
    var bundleIdentifier: String
    /// A literal absolute path, or nil for the unconstrained form.
    var applicationPath: String?

    /// Both fields are input, checked before anything is inspected.
    static func validated(bundleIdentifier: String, applicationPath: String?) -> Result<ApplicationRequest, InputError> {
        guard !bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(InputError("application.bundleIdentifier must not be blank."))
        }
        if let path = applicationPath {
            guard !path.isEmpty else { return .failure(InputError("application.applicationPath must not be empty.")) }
            guard !path.utf8.contains(0) else {
                return .failure(InputError("application.applicationPath must not contain a NUL character."))
            }
            guard path.hasPrefix("/") else {
                return .failure(InputError("application.applicationPath must be an absolute path."))
            }
        }
        return .success(ApplicationRequest(bundleIdentifier: bundleIdentifier, applicationPath: applicationPath))
    }
}

struct InputError: Error, Equatable, Sendable {
    var message: String
    init(_ message: String) { self.message = message }
}

enum Selection: Sendable {
    /// The one installation to submit. `substituting` is whether a running copy
    /// at another location may be used instead: never once a path was given.
    case selected(URL, substituting: Bool)
    /// A prerequisite is missing; nothing is submitted.
    case dependency(DependencyReason, guidance: String)
    /// Metadata could not be established. Never read as absence.
    case failed(String)
}

/// Chooses the installation a launch submits, by the contract's rules:
///
/// - Presence is checked on the bundle itself, whatever registration says: a
///   registered copy that is gone is not installed, and a present copy in the
///   Trash is still eligible.
/// - With a path (`selectSuppliedApplication`), the path is resolved by the walk and
///   refused at the hand-off limit, and only a registered copy at that device and
///   inode with the requested identifier is eligible. Another copy is never substituted.
/// - Metadata that cannot be read is `failed`, not absence.
///
/// Without a path, the registered copy is discovered, then resolved by the walk and refused at the limit
/// before its bundle is read (`settleDiscoveredApplication`). Every pathname-based call is one of the
/// prompt-free metadata calls (docs/verification/protected-path-metadata.md), made only after the limit;
/// none looks up a file handler.
/// `action` is what no request did, in the past tense the guidance uses.
func selectInstallation(_ request: ApplicationRequest, forAction action: String, native: some WorkspaceNative) -> Selection {
    if let path = request.applicationPath {
        return selectSuppliedApplication(request, path: path, forAction: action, native: native)
    }
    guard let registered = native.registeredApplication(bundleIdentifier: request.bundleIdentifier) else {
        return notInstalled(request)
    }
    // Discovery found `registered`; it is resolved and limited before its bundle is read (`DiscoveredStage`).
    switch settleDiscoveredApplication(registered, forAction: action, native: native) {
    case .absent: return notInstalled(request)  // stale registration, or no application there
    case .failed(let message): return .failed(message)
    case .application(let identifier):
        guard identifier == request.bundleIdentifier else { return mismatch(request) }
        return .selected(registered, substituting: true)
    }
}

/// What a URL open is sent to: the default handler for the URL's scheme, present as an
/// application bundle when inspected. Registration alone is not presence, as for a launch;
/// the handler's identifier is workspace read data and is neither checked nor reported. The handler is a
/// discovered application like any other: resolved by the walk and refused at the limit before its bundle is
/// read. Only prompt-free metadata calls, and the lookup is by scheme (see `WorkspaceNative`).
func selectWebHandler(_ scheme: WebURL.Scheme, forAction action: String, native: some WorkspaceNative) -> Selection {
    guard let handler = native.defaultApplication(forWebScheme: scheme) else { return noDefaultHandler() }
    switch settleDiscoveredApplication(handler, forAction: action, native: native) {
    case .absent: return noDefaultHandler()  // a stale registration
    case .failed(let message): return .failed(message)
    case .application: return .selected(handler, substituting: true)
    }
}

private func noDefaultHandler() -> Selection {
    .dependency(
        .noDefaultHandler,
        guidance: "No default web browser is registered on this Mac for http and https links, so the link "
            + "was not opened. Choose a default browser in System Settings, then try again."
    )
}

func notInstalled(_ request: ApplicationRequest) -> Selection {
    let where_ = request.applicationPath == nil ? "" : " at the requested location"
    return .dependency(
        .applicationNotInstalled,
        guidance: "No installed application with bundle identifier \(request.bundleIdentifier)\(where_) is registered "
            + "on this Mac. Install it, then try again."
    )
}

func mismatch(_ request: ApplicationRequest) -> Selection {
    .dependency(
        .applicationIdentityMismatch,
        guidance: "The application found does not have bundle identifier \(request.bundleIdentifier). "
            + "No other copy was substituted; choose the application again."
    )
}

func unreadable(_ reason: String) -> String {
    "The application could not be inspected: \(reason)."
}
