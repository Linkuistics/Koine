/// The input target and its protection (docs/specs/app-input.md, "Targets"). The provider reads the process, the app
/// facts and the identity of Koine, and it passes them here as plain values. Nothing here reads the system.

/// One run of one process: a process identifier names it only together with its start instant.
struct ProcessIncarnation: Equatable, Hashable, Sendable {
    let pid: Int32
    let startMicroseconds: Int64
}

/// The remainder of a `koine://input/…` reference, which only this provider reads. An input target is its process
/// incarnation, `koine://input/target/<pid>/<start>`, with the start instant in whole microseconds since the Unix
/// epoch. It is not a desktop reference, and the two cannot be converted.
enum InputReference {
    static func uri(_ process: ProcessIncarnation) -> String {
        "koine://input/target/\(process.pid)/\(process.startMicroseconds)"
    }

    /// Nil unless `uri` is exactly a text that `uri(_:)` produces.
    static func process(_ uri: String) -> ProcessIncarnation? {
        let prefix = "koine://input/target/"
        guard uri.hasPrefix(prefix) else { return nil }
        let parts = uri.dropFirst(prefix.count).split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2, let pid = Int32(parts[0]), pid > 0, let start = Int64(parts[1]), start >= 0 else {
            return nil
        }
        let process = ProcessIncarnation(pid: pid, startMicroseconds: start)
        // No leading zeros, signs or spaces: one incarnation has one reference.
        guard self.uri(process) == uri else { return nil }
        return process
    }
}

/// How Koine recognises itself: the process identifier of the Koine process and the bundle identifier of Koine. A
/// host with no bundle identifier, such as a test runner, is recognised by its process identifier alone.
struct KoineIdentity: Equatable, Sendable {
    let pid: Int32
    let bundleIdentifier: String?
}

/// The values of `InputTargetProtection`.
enum TargetProtection: String, Equatable, Sendable {
    case addressable = "ADDRESSABLE"
    case protected = "PROTECTED"

    /// Koine refuses one protected target, Koine itself: its own process, and any process with the bundle identifier
    /// of Koine. A chord to the Settings window of Koine could approve the grant request of the client that sends it.
    /// Every other app is a target under the capabilities.
    static func of(pid: Int32, bundleIdentifier: String?, koine: KoineIdentity) -> TargetProtection {
        if pid == koine.pid { return .protected }
        if let own = koine.bundleIdentifier, bundleIdentifier == own { return .protected }
        return .addressable
    }
}

/// The facts of an app process, as `NSRunningApplication` reports them.
struct AppFacts: Equatable, Sendable {
    let localizedName: String?
    let executableName: String?
    let bundleIdentifier: String?

    /// The localised name that macOS reports. When macOS reports none, the name of the executable.
    var name: String { localizedName ?? executableName ?? "" }
}

/// What the provider found for a process incarnation.
enum TargetLookup: Equatable, Sendable {
    /// The incarnation is live. `app` is nil when macOS does not report the process as an app.
    case live(app: AppFacts?)
    /// No process has this process identifier and start instant.
    case gone
    /// The kernel did not answer for the process. The value is the reason.
    case unreadable(String)
}

/// An input target, as `InputTarget` serves it.
struct InputTarget: Equatable, Sendable {
    /// Nil exactly when the protection is `protected`.
    let ref: String?
    let name: String
    let bundleIdentifier: String?
    let protection: TargetProtection

    /// The target for a capture. Nil when the process is not an app, because a target is always an app. A protected
    /// target has no reference, so Koine refuses itself before it issues one.
    static func capture(_ process: ProcessIncarnation, app: AppFacts?, koine: KoineIdentity) -> InputTarget? {
        guard let app else { return nil }
        let protection = TargetProtection.of(pid: process.pid, bundleIdentifier: app.bundleIdentifier, koine: koine)
        return InputTarget(
            ref: protection == .addressable ? InputReference.uri(process) : nil,
            name: app.name, bundleIdentifier: app.bundleIdentifier, protection: protection
        )
    }
}
