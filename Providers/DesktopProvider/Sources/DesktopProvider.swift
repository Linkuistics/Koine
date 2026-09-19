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
        // The receipt is read under the action's own authority, not desktop:read.
        fields += [
            ProviderFieldRegistration(
                coordinate: "Mutation.desktopFocusWindow", resolverId: "focusWindow", authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "DesktopFocusReceipt.ref", resolverId: "parent.ref", authority: .control
            ),
        ]
        return ProviderDescriptor(
            providerId: "desktop", graphQLPrefix: "Desktop", schemaSDL: desktopSchemaSDL,
            fields: fields, requiredFeatures: []
        )
    }

    func makeProvider() -> any Provider { DesktopProvider() }
}

/// Every reference is re-resolved against the OS on each use. The one thing kept
/// between calls is the window table: the platform's window identity is an
/// element that has to be held to be compared. From `start()` to `stop()` the
/// table is also what is remembered of windows an application no longer
/// enumerates, as it does not those on another Space, and the system's word that a
/// window or an application ended empties it at once.
final class DesktopProvider: Provider, @unchecked Sendable {
    /// Accessibility calls are synchronous IPC to the target application. They
    /// run here, one at a time, off Swift's cooperative threads.
    private let queue = DispatchQueue(label: "dev.antony.Koine.provider.desktop")
    private let table = WindowTable()
    private var observation: WindowObservation?

    func start() async throws {
        let observation = WindowObservation(
            queue: queue,
            windowEnded: { [weak self] element, process in self?.table.retire(element: element, of: process) },
            // The notice can arrive after its PID names a successor: ask the kernel.
            applicationEnded: { [weak self] pid in
                guard let self else { return }
                self.forget { $0.pid == pid && !self.isRunning($0) }
            }
        )
        await onQueue {
            observation.start()
            self.observation = observation
        }
    }

    /// Nothing here waits on another process, so the lifecycle's wait is not used.
    func stop() async {
        await onQueue {
            self.observation?.stop()
            self.observation = nil
            self.forget { _ in true }
        }
    }

    private func forget(where isGone: (ProcessIncarnation) -> Bool) {
        // Not one expression: an optional chain on no observation skips its argument.
        let gone = table.forget(where: isGone)
        observation?.forget(gone)
    }

    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        let prefix = "parent."
        if request.resolverId.hasPrefix(prefix) {
            let key = String(request.resolverId.dropFirst(prefix.count))
            guard case .object(let parent)? = request.parent, let value = parent[key] else {
                return .failure(ProviderFailure(kind: .failed, message: "No parent value."))
            }
            return .success(value)
        }
        if request.resolverId == "focusWindow" { return await focus(request.arguments["ref"]) }
        return await onQueue { self.answer(request) }
    }

    private func onQueue<Value: Sendable>(_ work: @escaping @Sendable () -> Value) async -> Value {
        await withCheckedContinuation { continuation in
            queue.async { continuation.resume(returning: work()) }
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
        guard isRunning(process) else {
            forget { $0 == process }
            return gone
        }
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
        forget { $0 != process && !isRunning($0) }
        // A window held from before that is not enumerated now is asked directly:
        // an element answers from another Space, where `AXWindows` omits it.
        let rows = table.rows(listing: real, of: process) { element in
            switch window(element, of: process.pid) {
            case .value(let title): .window(title: title)
            case .absent: .notShown
            case .gone: .ended
            case .failed: .unanswered
            }
        }
        for window in real { observation?.watch(window.element, of: process) }
        return .success(
            .list(
                rows.map { row(process, token: $0.token, title: $0.title, remembered: $0.remembered) }
            )
        )
    }

    private func window(referencedBy ref: ProviderValue?) -> ResolutionResult {
        switch held(referencedBy: ref) {
        case .window(let process, let token, let element, let title):
            // Whether the application enumerates it now, as a listing would say.
            switch read(AXUIElementCreateApplication(process.pid), kAXWindowsAttribute, as: [AXUIElement].self) {
            case .value(let listed):
                let remembered = !listed.contains { CFEqual($0, element) }
                return .success(row(process, token: token, title: title, remembered: remembered))
            case .absent: return .success(row(process, token: token, title: title, remembered: true))
            case .gone: return gone
            case .failed(let error): return unanswered(error)
            }
        case .not(let result): return result
        }
    }

    private enum Held {
        case window(ProcessIncarnation, token: UInt64, AXUIElement, title: String)
        case not(ResolutionResult)
    }

    /// Re-resolves one window reference to the element it names. What needs no
    /// Accessibility call is decided first, so a reference that names nothing is
    /// `unavailable` with or without consent; asking the held element needs
    /// consent. Reading and focusing both start here.
    private func held(referencedBy ref: ProviderValue?) -> Held {
        guard case .reference(let uri)? = ref,
            case .window(let process, let session, let token)? = DesktopReference(uri: uri)
        else { return .not(notAWindow) }
        // Table membership proves nothing about the process: ask the kernel.
        guard isRunning(process) else {
            forget { $0 == process }
            return .not(closed)
        }
        guard session == table.session, let element = table.element(token, of: process) else {
            return .not(closed)
        }
        guard AXIsProcessTrusted() else { return .not(untrusted) }
        // Still a real window, and still its own: the held element is asked
        // again on every use (docs/verification/desktop-window-identity.md).
        switch window(element, of: process.pid) {
        case .value(let title): return .window(process, token: token, element, title: title)
        // No longer a window, or no longer provably its own: not this target.
        case .absent: return .not(closed)
        case .gone:
            table.retire(token, of: process)
            return .not(closed)
        case .failed(let error):
            // The elements of a process that ended answer kAXErrorCannotComplete.
            return .not(isRunning(process) ? unanswered(error) : closed)
        }
    }

    /// Every route to a window ends here, so they report the same fields. A
    /// remembered window is one its application does not enumerate now; its title
    /// is the last one read, which is no proof that it still exists.
    private func row(
        _ process: ProcessIncarnation, token: UInt64, title: String, remembered: Bool
    ) -> ProviderValue {
        .object([
            "ref": .reference(DesktopReference.window(process, session: table.session, token: token).uri),
            "title": .string(title),
            "observation": .string(remembered ? "REMEMBERED" : "CURRENT"),
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

    // MARK: Focus

    /// The element is used only on the provider's queue.
    private struct Target: @unchecked Sendable {
        var pid: Int32
        var element: AXUIElement
    }

    private enum Step: Sendable {
        case target(Target)
        case done
        case pending
        case ended(ResolutionResult)
    }

    /// How long the application has to show the window focused after every
    /// native step succeeded, and how often it is asked.
    private static let focusWait: UInt64 = 3_000_000_000
    private static let focusPoll: UInt64 = 50_000_000

    /// Focuses exactly the window `ref` names. Re-resolution, consent and
    /// identity come first and end the action with nothing activated. Bringing an
    /// application forward is a request the system may not honour, so success is
    /// what the application then reports:
    /// it is frontmost and its focused window is the held element. The wait for
    /// that is bounded, runs off the queue, and ends on cancellation.
    private func focus(_ ref: ProviderValue?) async -> ResolutionResult {
        guard !Task.isCancelled else { return failed("Cancelled before the window was focused.") }
        // One turn on the queue: nothing comes between confirming identity and acting.
        let target: Target
        switch await onQueue({ self.resolveAndAct(ref) }) {
        case .target(let acted): target = acted
        case .ended(let result): return result
        case .done, .pending: return failed("The window could not be resolved.")
        }
        let deadline = DispatchTime.now().uptimeNanoseconds + Self.focusWait
        while true {
            switch await onQueue({ self.hasFocus(target) }) {
            case .done: return .success(.object(["ref": ref ?? .null]))
            case .ended(let result): return result
            case .pending, .target: break
            }
            guard DispatchTime.now().uptimeNanoseconds < deadline else {
                return failed(
                    "The application was asked to activate and the window to raise, but the window "
                        + "did not take focus within 3 seconds."
                )
            }
            guard (try? await Task.sleep(nanoseconds: Self.focusPoll)) != nil else {
                return failed("Cancelled while waiting for the window to take focus.")
            }
        }
    }

    private func resolveAndAct(_ ref: ProviderValue?) -> Step {
        switch held(referencedBy: ref) {
        case .window(let process, _, let element, _):
            let target = Target(pid: process.pid, element: element)
            if case .ended(let result) = act(on: target) { return .ended(result) }
            return .target(target)
        case .not(let result): return .ended(result)
        }
    }

    /// The native steps, in order; the first that fails ends the action and is
    /// reported. The window is made main and raised before its application is
    /// activated, so the application comes forward with this window in front.
    private func act(on target: Target) -> Step {
        let window = target.element
        switch read(window, kAXMinimizedAttribute, as: Bool.self) {
        case .value(true):
            let error = set(window, kAXMinimizedAttribute, to: false)
            guard error == .success else { return stopped("could not be restored from the Dock", error) }
        case .value(false), .absent: break
        case .gone: return .ended(closed)
        case .failed(let error): return stopped("did not answer whether it is minimised", error)
        }
        var error = set(window, kAXMainAttribute, to: true)
        guard error == .success else { return stopped("could not be made the main window", error) }
        error = perform(window, kAXRaiseAction)
        guard error == .success else { return stopped("could not be raised", error) }
        // The application is brought forward through Accessibility, under the consent
        // this action already needs. AppKit's route is closed to a background
        // service: NSRunningApplication.h deprecates activateIgnoringOtherApps as
        // having no effect from macOS 14, -activateFromApplication: needs the active
        // application to yield, and -activateWithOptions: answered NO for Finder in
        // the VM (docs/verification/desktop-focus-vm.md). AXAttributeConstants.h
        // lists AXFrontmost as an application attribute and does not say it can be
        // set; no official source found for that, so the wait below is the proof.
        let application = AXUIElementCreateApplication(target.pid)
        error = set(application, kAXFrontmostAttribute, to: true)
        guard error == .success else {
            return stopped("was raised, but its application could not be brought to the front", error)
        }
        return .pending
    }

    private func hasFocus(_ target: Target) -> Step {
        let application = AXUIElementCreateApplication(target.pid)
        switch read(application, kAXFrontmostAttribute, as: Bool.self) {
        case .value(true): break
        case .value(false), .absent: return .pending
        case .gone: return .ended(failed("The application ended after it was asked to activate."))
        case .failed(let error): return stopped("was raised, but its application did not answer", error)
        }
        switch read(application, kAXFocusedWindowAttribute, as: AXUIElement.self) {
        case .value(let focused): return CFEqual(focused, target.element) ? .done : .pending
        case .absent: return .pending
        case .gone: return .ended(failed("The application ended after it was asked to activate."))
        case .failed(let error): return stopped("was raised, but its application did not answer", error)
        }
    }

    private func stopped(_ what: String, _ error: AXError) -> Step {
        // Consent can end while Koine runs, and between the trust check and the call.
        if error == .apiDisabled { return .ended(untrusted) }
        // The window closed between the identity check and this step.
        if error == .invalidUIElement { return .ended(closed) }
        return .ended(failed("The window \(what) (AXError \(error.rawValue))."))
    }

    private func failed(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .failed, message: message))
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
            .osPermission("accessibility", message: "Koine needs Accessibility access to read and focus windows.")
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
