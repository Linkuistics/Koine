import AppKit
import ApplicationServices
import Foundation
import KoineProviderAPI

// build.sh generates `desktopSchemaSDL` from schema.graphql.

@objc(KoineDesktopProviderFactory)
final class DesktopProviderFactory: NSObject, ProviderFactory {
    override required init() { super.init() }

    var descriptor: ProviderDescriptor {
        // A nested field's resolver identifier is the key it reads from its parent.
        let outputs = [
            "DesktopApplication": ["ref", "name", "bundleIdentifier"],
            "DesktopWindow": ["ref", "title", "observation"],
        ]
        var fields = [
            ProviderFieldRegistration(
                coordinate: "Query.desktopApplication", resolverId: "application", authority: .read
            ),
            ProviderFieldRegistration(
                coordinate: "Query.desktopApplicationByReference", resolverId: "applicationByReference",
                authority: .read
            ),
            ProviderFieldRegistration(
                coordinate: "Query.desktopWindow", resolverId: "window", authority: .read
            ),
            ProviderFieldRegistration(
                coordinate: "DesktopApplication.windows", resolverId: "windows", authority: .read
            ),
        ]
        for (type, names) in outputs {
            fields += names.map {
                ProviderFieldRegistration(
                    coordinate: "\(type).\($0)", resolverId: "parent.\($0)", authority: .read
                )
            }
        }
        return ProviderDescriptor(
            providerId: "desktop", graphQLPrefix: "Desktop", schemaSDL: desktopSchemaSDL,
            fields: fields, requiredFeatures: []
        )
    }

    func makeProvider() -> any Provider { DesktopProvider() }
}

/// Every reference is re-resolved against the OS on each use. The one thing kept
/// between calls is the window table: the platform's window identity is an
/// element that has to be held to be compared.
final class DesktopProvider: Provider, @unchecked Sendable {
    /// Accessibility calls are synchronous IPC to the target application. They
    /// run here, one at a time, off Swift's cooperative threads.
    private let queue = DispatchQueue(label: "dev.antony.Koine.provider.desktop")
    private let table = WindowTable()

    func start() async throws {}
    func stop() async {}

    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        let prefix = "parent."
        if request.resolverId.hasPrefix(prefix) {
            let key = String(request.resolverId.dropFirst(prefix.count))
            guard case .object(let parent)? = request.parent, let value = parent[key] else {
                return .failure(ProviderFailure(kind: .failed, message: "No parent value."))
            }
            return .success(value)
        }
        return await withCheckedContinuation { continuation in
            queue.async { continuation.resume(returning: self.answer(request)) }
        }
    }

    private func answer(_ request: ResolutionRequest) -> ResolutionResult {
        switch request.resolverId {
        case "application": application(request.arguments["process"])
        case "applicationByReference": application(referencedBy: request.arguments["ref"])
        case "window": window(referencedBy: request.arguments["ref"])
        case "windows": windows(of: request.parent)
        default: .failure(ProviderFailure(kind: .unknownResolver, message: "No such resolver."))
        }
    }

    // MARK: Application

    private func application(_ identity: ProviderValue?) -> ResolutionResult {
        guard case .object(let fields)? = identity, case .int(let pid)? = fields["pid"],
            case .string(let text)? = fields["startedAt"]
        else { return invalid("process needs a pid and a startedAt.") }
        guard pid > 0, let pid = Int32(exactly: pid) else {
            return invalid("process.pid must be a positive process identifier.")
        }
        guard let claimed = ProcessStart(canonical: text) else {
            return invalid(
                "process.startedAt must be the process start instant as UTC with six fractional "
                    + "second digits, such as 2026-09-19T01:02:03.000456Z."
            )
        }
        // Both halves are compared: a live PID started at another instant is
        // another process, and absent.
        switch running(pid: pid, startMicroseconds: claimed.microsecondsSinceEpoch) {
        case .value(let application): return .success(application)
        case .absent, .gone: return .success(.null)
        case .failed(let reason): return .failure(ProviderFailure(kind: .failed, message: reason))
        }
    }

    /// A reference that no longer names a running application is `unavailable`,
    /// where an absent process identity is ordinary null: the caller was given
    /// this reference, so its target existed.
    private func application(referencedBy ref: ProviderValue?) -> ResolutionResult {
        guard case .reference(let uri)? = ref, case .application(let process)? = DesktopReference(uri: uri)
        else { return notAnApplication }
        switch running(pid: process.pid, startMicroseconds: process.startMicroseconds) {
        case .value(let application): return .success(application)
        case .absent, .gone: return gone
        case .failed(let reason): return .failure(ProviderFailure(kind: .failed, message: reason))
        }
    }

    private enum Running {
        case value(ProviderValue)
        case absent
        case gone
        case failed(String)
    }

    /// The application fields that need no Accessibility consent, read now. Every
    /// route to an application ends here, so they report the same fields.
    private func running(pid: Int32, startMicroseconds: Int64) -> Running {
        switch processStart(of: pid) {
        case .absent: return .absent
        case .unreadable(let reason): return .failed("The process could not be read: \(reason).")
        case .running(let actual):
            guard actual.microsecondsSinceEpoch == startMicroseconds,
                let running = NSRunningApplication(processIdentifier: pid), !running.isTerminated
            else { return .gone }
            let process = ProcessIncarnation(pid: pid, startMicroseconds: startMicroseconds)
            return .value(
                .object([
                    "ref": .reference(DesktopReference.application(process).uri),
                    "name": .string(running.localizedName ?? ""),
                    "bundleIdentifier": running.bundleIdentifier.map(ProviderValue.string) ?? .null,
                ])
            )
        }
    }

    private func invalid(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .invalidInput, message: message))
    }

    // MARK: Windows

    private func windows(of parent: ProviderValue?) -> ResolutionResult {
        guard case .object(let fields)? = parent, case .reference(let uri)? = fields["ref"],
            case .application(let process)? = DesktopReference(uri: uri)
        else { return .failure(ProviderFailure(kind: .failed, message: "No parent application.")) }
        // The parent was resolved a moment ago, by another call: look again.
        guard isRunning(process) else { return gone }
        guard AXIsProcessTrusted() else { return untrusted }
        let application = AXUIElementCreateApplication(process.pid)
        let listed: [AXUIElement]
        switch read(application, kAXWindowsAttribute, as: [AXUIElement].self) {
        case .value(let elements): listed = elements
        // An application with no window list has no windows to report.
        case .absent: listed = []
        case .gone: return gone
        case .failed(let error): return unanswered(error)
        }
        var real: [(element: AXUIElement, title: String)] = []
        for element in listed {
            switch window(element, of: process.pid) {
            case .value(let title): real.append((element, title))
            // Not a window, or one that closed while it was being read: no row.
            case .absent, .gone: continue
            // An application that stops answering is reported, not read as empty.
            case .failed(let error): return unanswered(error)
            }
        }
        table.forget { $0 != process && !isRunning($0) }
        let tokens = table.tokens(for: real.map(\.element), of: process)
        return .success(
            .list(
                zip(real, tokens).map { window, token in row(process, token: token, title: window.title) }
            )
        )
    }

    /// Re-resolves one window reference. What needs no Accessibility call is
    /// decided first, so a reference that names nothing is `unavailable` with or
    /// without consent; asking the held element needs consent.
    private func window(referencedBy ref: ProviderValue?) -> ResolutionResult {
        guard case .reference(let uri)? = ref,
            case .window(let process, let session, let token)? = DesktopReference(uri: uri)
        else { return notAWindow }
        // Table membership proves nothing about the process: ask the kernel.
        guard isRunning(process) else { return closed }
        guard session == table.session, let element = table.element(token, of: process) else {
            return closed
        }
        guard AXIsProcessTrusted() else { return untrusted }
        // Still a real window, and still its own: the held element is asked
        // again on every use (docs/verification/desktop-window-identity.md).
        switch window(element, of: process.pid) {
        case .value(let title): return .success(row(process, token: token, title: title))
        // No longer a window, or no longer provably its own: not this target.
        case .absent: return closed
        case .gone:
            table.retire(token, of: process)
            return closed
        case .failed(let error):
            // The elements of a process that ended answer kAXErrorCannotComplete.
            return isRunning(process) ? unanswered(error) : closed
        }
    }

    /// Every route to a window ends here, so they report the same fields. The
    /// element answered just now, which is a current observation.
    private func row(_ process: ProcessIncarnation, token: UInt64, title: String) -> ProviderValue {
        .object([
            "ref": .reference(DesktopReference.window(process, session: table.session, token: token).uri),
            "title": .string(title),
            "observation": .string("CURRENT"),
        ])
    }

    private func isRunning(_ process: ProcessIncarnation) -> Bool {
        guard case .running(let start) = processStart(of: process.pid) else { return false }
        return start.microsecondsSinceEpoch == process.startMicroseconds
    }

    /// The title of `element` if it is a real window of `pid`, and `absent` if it
    /// is not one. Only real windows: a window by role, and not one of the
    /// subroles an application uses for its panels and other chrome. A minimised
    /// window is a real window, and an untitled one has an empty title.
    private func window(_ element: AXUIElement, of pid: Int32) -> AttributeRead<String> {
        var owner: pid_t = 0
        guard AXUIElementGetPid(element, &owner) == .success, owner == pid else { return .absent }
        switch read(element, kAXRoleAttribute, as: String.self) {
        case .value(kAXWindowRole): break
        case .value, .absent: return .absent
        case .gone: return .gone
        case .failed(let error): return .failed(error)
        }
        switch read(element, kAXSubroleAttribute, as: String.self) {
        case .value(kAXStandardWindowSubrole), .value(kAXDialogSubrole), .absent: break
        case .value: return .absent
        case .gone: return .gone
        case .failed(let error): return .failed(error)
        }
        switch isItsOwnWindow(element) {
        case .value(true): break
        case .value(false), .absent: return .absent
        case .gone: return .gone
        case .failed(let error): return .failed(error)
        }
        switch read(element, kAXTitleAttribute, as: String.self) {
        case .value(let title): return .value(title)
        case .absent: return .value("")
        case .gone: return .gone
        case .failed(let error): return .failed(error)
        }
    }

    /// Whether the element is the one its own content names as its window. An
    /// application may list an element whose identity is its position, which can
    /// answer as whichever window holds that position now (Finder's desktop did:
    /// docs/verification/desktop-window-identity.md). Such an alias is not
    /// `CFEqual` to the window's own element, so it fails here. A window with no
    /// content to ask is `absent`: its identity cannot be established.
    private func isItsOwnWindow(_ element: AXUIElement) -> AttributeRead<Bool> {
        let child: AXUIElement
        switch read(element, kAXChildrenAttribute, as: [AXUIElement].self) {
        case .value(let children):
            guard let first = children.first else { return .absent }
            child = first
        case .absent: return .absent
        case .gone: return .gone
        case .failed(let error): return .failed(error)
        }
        switch read(child, kAXWindowAttribute, as: AXUIElement.self) {
        case .value(let window): return .value(CFEqual(window, element))
        case .absent: return .absent
        case .gone: return .gone
        case .failed(let error): return .failed(error)
        }
    }

    private var gone: ResolutionResult { unavailable("The application is no longer running.") }
    private var closed: ResolutionResult { unavailable("The window is no longer open.") }
    private var notAnApplication: ResolutionResult {
        unavailable("The reference does not name a desktop application.")
    }
    private var notAWindow: ResolutionResult { unavailable("The reference does not name a desktop window.") }

    private func unavailable(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .unavailable, message: message))
    }

    /// Consent is asked about, never asked for: only Koine's own UI requests it.
    /// `AXIsProcessTrusted` takes no options, so it cannot carry the prompt one.
    /// https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted
    private var untrusted: ResolutionResult {
        .failure(
            .osPermission("accessibility", message: "Koine needs Accessibility access to read windows.")
        )
    }

    private func unanswered(_ error: AXError) -> ResolutionResult {
        // Consent can end while Koine runs, and between the trust check and the call.
        if error == .apiDisabled { return untrusted }
        return .failure(
            ProviderFailure(
                kind: .failed,
                message: "The application did not answer for its windows (AXError \(error.rawValue))."
            )
        )
    }
}
