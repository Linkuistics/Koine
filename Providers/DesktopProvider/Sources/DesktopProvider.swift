import AppKit
import ApplicationServices
import Foundation
import KoineProviderAPI

// build.sh generates `desktopSchemaSDL` from schema.graphql.

/// The host feature that says the host's Settings window and management catalogue
/// disclose the pointer and media reach of desktop:read and desktop:control. The core
/// names the same feature as `desktopDisclosuresV2Feature`. The selection fixtures
/// find the descriptor's feature list by the name of this constant, so the name stays.
let desktopDisclosuresFeature = "desktop-disclosures-v2"

@objc(KoineDesktopProviderFactory)
final class DesktopProviderFactory: NSObject, ProviderFactory {
    override required init() { super.init() }

    var descriptor: ProviderDescriptor {
        // A nested field's resolver identifier is the key it reads from its parent.
        let outputs = [
            "DesktopApplication": ["ref", "name", "bundleIdentifier"],
            "DesktopWindow": ["ref", "title", "observation", "application", "frame"],
            "DesktopWindowStacking": ["window", "order", "visibility"],
            "DesktopDisplay": ["ref", "frame", "visibleFrame", "primary"],
            "DesktopRect": ["x", "y", "width", "height"],
            "DesktopPointer": ["location"],
            "DesktopPoint": ["x", "y"],
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
            ProviderFieldRegistration(
                coordinate: "Query.desktopWindows", resolverId: "windowList", authority: .read
            ),
            ProviderFieldRegistration(
                coordinate: "Query.desktopDisplays", resolverId: "displays", authority: .read
            ),
            ProviderFieldRegistration(
                coordinate: "Query.desktopWindowOnTop", resolverId: "windowOnTop", authority: .read
            ),
            ProviderFieldRegistration(
                coordinate: "Query.desktopPointer", resolverId: "pointer", authority: .read
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
            ProviderFieldRegistration(
                coordinate: "Mutation.desktopSetWindowFrame", resolverId: "setWindowFrame", authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "DesktopFrameReceipt.ref", resolverId: "parent.ref", authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "Mutation.desktopFocusDisplay", resolverId: "focusDisplay", authority: .control
            ),
        ]
        fields += ["ref", "outcome", "pointerMoved"].map {
            ProviderFieldRegistration(
                coordinate: "DesktopDisplayFocusReceipt.\($0)", resolverId: "parent.\($0)", authority: .control
            )
        }
        fields += [
            ProviderFieldRegistration(
                coordinate: "Mutation.desktopNudgePointer", resolverId: "nudgePointer", authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "DesktopPointerNudgeReceipt.outcome", resolverId: "parent.outcome", authority: .control
            ),
        ]
        // A host that cannot disclose the pointer and media reach refuses this release before it loads
        // (docs/specs/machine.md, "Versions and host feature").
        return ProviderDescriptor(
            providerId: "desktop", graphQLPrefix: "Desktop", schemaSDL: desktopSchemaSDL,
            fields: fields, requiredFeatures: [desktopDisclosuresFeature]
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
        if request.resolverId == "focusDisplay" { return await focusDisplay(request.arguments["ref"]) }
        if request.resolverId == "displays" { return await displays() }
        if request.resolverId == "pointer" { return await pointer() }
        if request.resolverId == "nudgePointer" { return await nudgePointer() }
        if request.resolverId == "windowOnTop" {
            // The Dock bar rule needs the visible frames, which AppKit gives on the main actor, so they are
            // read before the queue turn. A failed display list leaves every Dock entry undecided.
            let displays = await readDisplays() ?? []
            let dock = Self.dockProcess()
            return await onQueue {
                self.windowOnTop(request.arguments["ref"], at: request.arguments["point"], dock: dock, displays: displays)
            }
        }
        if request.resolverId == "setWindowFrame" {
            return await setFrame(request.arguments["ref"], to: request.arguments["frame"])
        }
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
        case "windowList": windowList()
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
        switch listing(process) {
        case .rows(let rows):
            let application = ProviderValue.object(fields.filter { ["ref", "name", "bundleIdentifier"].contains($0.key) })
            return .success(
                .list(rows.map { row(process, $0, application: application, frame: $0.element.flatMap(frame(of:))) })
            )
        case .gone: return gone
        case .failed(let error): return unanswered(error)
        }
    }

    /// One window of a listing, with the element that the table holds for it.
    private struct Listed {
        let token: UInt64
        let title: String
        let remembered: Bool
        let element: AXUIElement?
    }

    private enum Listing {
        case rows([Listed])
        case gone
        case failed(AXError)
    }

    /// The rows of one application, by the rule of `DesktopApplication.windows`:
    /// its current Accessibility window list, then the windows held from before
    /// that the list omits. Every route that lists windows starts here, so the
    /// rows use the same held elements and the same references.
    private func listing(_ process: ProcessIncarnation) -> Listing {
        let application = AXUIElementCreateApplication(process.pid)
        let listed: [AXUIElement]
        switch read(application, kAXWindowsAttribute, as: [AXUIElement].self) {
        case .value(let elements): listed = elements
        // An application with no window list has no windows to report.
        case .absent: listed = []
        case .gone: return .gone
        case .failed(let error): return .failed(error)
        }
        var real: [(element: AXUIElement, title: String)] = []
        for element in listed {
            switch window(element, of: process.pid) {
            case .value(let title): real.append((element, title))
            // Not a window, or one that closed while it was being read: no row.
            case .absent, .gone: continue
            // An application that stops answering is reported, not read as empty.
            case .failed(let error): return .failed(error)
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
        return .rows(
            rows.map {
                Listed(
                    token: $0.token, title: $0.title, remembered: $0.remembered,
                    element: table.element($0.token, of: process)
                )
            }
        )
    }

    /// `desktopWindows`: the current windows of every running application with a
    /// Dock icon, which is the regular activation policy. Windows on other Spaces
    /// are not in the list, because the current enumeration leaves them out. The
    /// order and the visibility of every row come from one reading of the window
    /// server's on-screen list, taken after every Accessibility read, through the
    /// links that `WindowStacking` makes.
    private func windowList() -> ResolutionResult {
        let rows: [ListRow]
        switch readWindowList() {
        case .success(let read): rows = read
        case .failure(let failure): return .failure(failure)
        }
        return .success(
            .list(
                WindowStacking.presentation(rows.map(\.stacking)).map { position in
                    .object([
                        "window": rows[position].window,
                        "order": rows[position].stacking.order.map(ProviderValue.int) ?? .null,
                        "visibility": .string(rows[position].stacking.visibility.rawValue),
                    ])
                }
            )
        )
    }

    /// One row of the window list, in listing order: the window value, its frame, and its order and
    /// visibility.
    private struct ListRow {
        let window: ProviderValue
        let frame: ScreenRect?
        let stacking: Stacking
    }

    /// The reading behind `desktopWindows`, which display focus makes too.
    private func readWindowList() -> Result<[ListRow], ProviderFailure> {
        guard AXIsProcessTrusted() else { return .failure(untrustedFailure) }
        var windows: [ProviderValue] = []
        var frames: [ScreenRect?] = []
        var offScreen: [Bool] = []
        var candidates: [LinkCandidate] = []
        for running in NSWorkspace.shared.runningApplications
        where running.activationPolicy == .regular && !running.isTerminated {
            let pid = running.processIdentifier
            // An application that ended during the read has no rows.
            guard case .running(let start) = processStart(of: pid) else { continue }
            let process = ProcessIncarnation(pid: pid, startMicroseconds: start.microsecondsSinceEpoch)
            guard case .value(let application) = self.running(pid: pid, startMicroseconds: process.startMicroseconds)
            else { continue }
            let rows: [Listed]
            switch listing(process) {
            case .rows(let listed): rows = listed.filter { !$0.remembered }
            case .gone: continue
            // One application that does not answer fails the read: a list without
            // its windows would be a false complete list.
            case .failed(let error):
                return .failure(unansweredFailure(error, application: running.localizedName ?? "An application"))
            }
            for listed in rows {
                let frame = listed.element.flatMap(frame(of:))
                windows.append(row(process, listed, application: application, frame: frame))
                frames.append(frame)
                offScreen.append(isOffScreen(listed.element, applicationHidden: running.isHidden))
                candidates.append(link(pid, listed.element, frame: frame))
            }
        }
        let stacking = WindowStacking.stacking(
            links: WindowStacking.links(candidates, entries: windowServerList()), offScreen: offScreen
        )
        return .success(
            windows.indices.map { ListRow(window: windows[$0], frame: frames[$0], stacking: stacking[$0]) }
        )
    }

    /// Whether public facts put the window off screen: it is minimised, or its
    /// application is hidden. A minimised state that cannot be read is no such fact.
    private func isOffScreen(_ element: AXUIElement?, applicationHidden: Bool) -> Bool {
        let minimised: Bool? =
            if let element, case .value(let value) = read(element, kAXMinimizedAttribute, as: Bool.self) {
                value
            } else { nil }
        return WindowVisibility.fromPublicFacts(minimised: minimised, applicationHidden: applicationHidden) == .offScreen
    }

    /// What the window-server link needs of one held window.
    private func link(_ owner: Int32, _ element: AXUIElement?, frame: ScreenRect?) -> LinkCandidate {
        LinkCandidate(owner: owner, number: element.flatMap(windowNumber(of:)), frame: frame)
    }

    /// `desktopWindowOnTop`: whether the window `ref` names is on top at `point`.
    /// The reference resolves as for `desktopWindow`. The link uses the same
    /// candidates as the window list: the current windows of the application, and
    /// this window too when the application does not enumerate it now. So the two
    /// reads link a window in the same way.
    /// Entries of the Dock process follow the Dock bar rule, with `displays` (docs/specs/machine.md,
    /// "Visibility at a point").
    private func windowOnTop(_ ref: ProviderValue?, at point: ProviderValue?, dock: Int32?, displays: [Display])
        -> ResolutionResult
    {
        guard case .object(let fields)? = point, let x = number(fields["x"]), let y = number(fields["y"]) else {
            return invalid("point needs a finite x and y.")
        }
        let process: ProcessIncarnation
        let token: UInt64
        let element: AXUIElement
        switch held(referencedBy: ref) {
        case .window(let heldProcess, let heldToken, let heldElement, _):
            (process, token, element) = (heldProcess, heldToken, heldElement)
        case .not(let result): return result
        }
        guard let running = NSRunningApplication(processIdentifier: process.pid), !running.isTerminated else {
            return gone
        }
        if isOffScreen(element, applicationHidden: running.isHidden) {
            return answer(WindowStacking.onTop(link: nil, offScreen: true, point: (x, y), entries: []))
        }
        var windows: [Listed]
        switch listing(process) {
        case .rows(let rows): windows = rows.filter { !$0.remembered }
        case .gone: return gone
        case .failed(let error): return unanswered(error)
        }
        if !windows.contains(where: { $0.token == token }) {
            windows.append(Listed(token: token, title: "", remembered: true, element: element))
        }
        let candidates = windows.map { link(process.pid, $0.element, frame: $0.element.flatMap(frame(of:))) }
        let entries = windowServerList()
        let links = WindowStacking.links(candidates, entries: entries)
        let own = windows.firstIndex { $0.token == token }.flatMap { links[$0] }
        return answer(
            WindowStacking.onTop(
                link: own, offScreen: false, point: (x, y), entries: entries, dock: dock, displays: displays))
    }

    /// The process identifier of the Dock, or nil when it does not run.
    private static func dockProcess() -> Int32? {
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock")
            .first { !$0.isTerminated }?.processIdentifier
    }

    private func answer(_ onTop: OnTop) -> ResolutionResult { .success(.string(onTop.rawValue)) }

    private func window(referencedBy ref: ProviderValue?) -> ResolutionResult {
        switch held(referencedBy: ref) {
        case .window(let process, let token, let element, let title):
            guard case .value(let application) = running(pid: process.pid, startMicroseconds: process.startMicroseconds)
            else { return gone }
            // Whether the application enumerates it now, as a listing would say.
            let remembered: Bool
            switch read(AXUIElementCreateApplication(process.pid), kAXWindowsAttribute, as: [AXUIElement].self) {
            case .value(let listed): remembered = !listed.contains { CFEqual($0, element) }
            case .absent: remembered = true
            case .gone: return gone
            case .failed(let error): return unanswered(error)
            }
            let listed = Listed(token: token, title: title, remembered: remembered, element: element)
            return .success(row(process, listed, application: application, frame: frame(of: element)))
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
    /// is the last one read, which is no proof that it still exists. The frame is
    /// read now from the held element by the caller, and is null when either attribute cannot be read.
    private func row(
        _ process: ProcessIncarnation, _ listed: Listed, application: ProviderValue, frame: ScreenRect?
    ) -> ProviderValue {
        .object([
            "ref": .reference(DesktopReference.window(process, session: table.session, token: listed.token).uri),
            "title": .string(listed.title),
            "observation": .string(listed.remembered ? "REMEMBERED" : "CURRENT"),
            "application": application,
            "frame": frame.map(value(of:)) ?? .null,
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

    // MARK: Geometry

    /// The position and size that Accessibility reports, in screen coordinates,
    /// or nil when either attribute cannot be read. Koine never invents a frame.
    private func frame(of element: AXUIElement) -> ScreenRect? {
        guard case .value(let position) = read(element, kAXPositionAttribute, as: AXValue.self),
            case .value(let size) = read(element, kAXSizeAttribute, as: AXValue.self)
        else { return nil }
        var point = CGPoint.zero
        var extent = CGSize.zero
        guard AXValueGetValue(position, .cgPoint, &point), AXValueGetValue(size, .cgSize, &extent) else {
            return nil
        }
        return ScreenRect(x: point.x, y: point.y, width: extent.width, height: extent.height)
    }

    private func value(of rect: ScreenRect) -> ProviderValue {
        .object([
            "x": .double(rect.x), "y": .double(rect.y), "width": .double(rect.width),
            "height": .double(rect.height),
        ])
    }

    // MARK: Displays

    /// `desktopDisplays`: one Core Graphics reading of the active displays and one
    /// AppKit reading of the screens, combined by `DisplayGeometry`. Neither needs
    /// Accessibility consent.
    private func displays() async -> ResolutionResult {
        guard let displays = await readDisplays() else { return displayListFailed }
        return .success(
            .list(
                displays.map { display in
                    .object([
                        "ref": .reference(DesktopReference.display(display.id).uri),
                        "frame": value(of: display.frame),
                        "visibleFrame": display.visibleFrame.map(value(of:)) ?? .null,
                        "primary": .bool(display.primary),
                    ])
                }
            )
        )
    }

    /// The display list, or nil when `CGGetActiveDisplayList` fails.
    private func readDisplays() async -> [Display]? {
        // https://developer.apple.com/documentation/coregraphics/1454603-cggetactivedisplaylist
        var count: UInt32 = 0
        guard CGGetActiveDisplayList(0, nil, &count) == .success else { return nil }
        var identifiers = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetActiveDisplayList(count, &identifiers, &count) == .success else { return nil }
        let active = identifiers.prefix(Int(count)).map { id in
            let bounds = CGDisplayBounds(id)
            return ActiveDisplay(
                id: id,
                bounds: ScreenRect(
                    x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height)
            )
        }
        let main = CGMainDisplayID()
        // NSScreen belongs to the main actor. Its reading is at another instant than
        // the Core Graphics one, which DisplayGeometry allows for.
        let screens = await MainActor.run { () -> [AppKitScreen] in
            let key = NSDeviceDescriptionKey("NSScreenNumber")
            return NSScreen.screens.map { screen in
                AppKitScreen(
                    number: (screen.deviceDescription[key] as? NSNumber)?.uint32Value,
                    frame: ScreenRect(screen.frame), visibleFrame: ScreenRect(screen.visibleFrame)
                )
            }
        }
        return DisplayGeometry.displays(active: active, main: main, screens: screens)
    }

    /// An empty list would be a false known value.
    private var displayListFailed: ResolutionResult {
        failed("macOS did not list the active displays.")
    }

    // MARK: Frame setting

    /// `desktopSetWindowFrame`: moves and resizes exactly the window `ref` names,
    /// with Modaliser's mechanism. An invalid frame attempts nothing. Consent and
    /// identity come first, as for focus. The whole action is one turn on the
    /// queue, so nothing comes between confirming identity and the writes, and the
    /// enhanced accessibility setting is always turned on again. The repeat waits
    /// on the queue for at most 7 times 50 ms.
    private func setFrame(_ ref: ProviderValue?, to frame: ProviderValue?) async -> ResolutionResult {
        guard case .object(let fields)? = frame, let x = number(fields["x"]), let y = number(fields["y"]),
            let width = number(fields["width"]), let height = number(fields["height"])
        else { return invalid("frame needs a finite x, y, width and height.") }
        guard width > 0, height > 0 else { return invalid("frame.width and frame.height must be greater than zero.") }
        let request = ScreenRect(x: x, y: y, width: width, height: height)
        return await onQueue { self.writeFrame(ref, request) }
    }

    private func number(_ value: ProviderValue?) -> Double? {
        let number: Double? =
            switch value {
            case .double(let double)?: double
            case .int(let int)?: Double(int)
            default: nil
            }
        return number.flatMap { $0.isFinite ? $0 : nil }
    }

    /// The application attribute that Electron applications honour: while it is on,
    /// they ignore position and size writes. It is not in AXAttributeConstants.h.
    /// Modaliser turns it off for its writes (`withResizableApp` in its
    /// WindowManipulator.swift); no official source documents it, so the VM
    /// acceptance is the proof.
    private static let enhancedUserInterface = "AXEnhancedUserInterface"

    private func writeFrame(_ ref: ProviderValue?, _ request: ScreenRect) -> ResolutionResult {
        let target: AXUIElement
        let pid: Int32
        switch held(referencedBy: ref) {
        case .window(let process, _, let element, _):
            target = element
            pid = process.pid
        case .not(let result): return result
        }
        let application = AXUIElementCreateApplication(pid)
        let enhanced: Bool
        switch read(application, Self.enhancedUserInterface, as: Bool.self) {
        case .value(let on): enhanced = on
        case .absent, .gone, .failed: enhanced = false
        }
        if enhanced {
            let error = set(application, Self.enhancedUserInterface, to: false)
            guard error == .success else {
                return result(stopped("could not have the enhanced accessibility setting of its application turned off", error))
            }
        }
        let outcome = FrameWrites.apply(
            width: request.width, height: request.height,
            write: { write(target, request) },
            size: { frame(of: target).map { (width: $0.width, height: $0.height) } },
            wait: { usleep(useconds_t(FrameWrites.interval / 1_000)) }
        )
        let restored = enhanced ? set(application, Self.enhancedUserInterface, to: true) : .success
        if let error = outcome.failure { return result(stopped("could not be moved or resized", error)) }
        guard restored == .success else {
            return failed(
                "The window was moved and resized, but the enhanced accessibility setting of its application "
                    + "could not be turned on again (AXError \(restored.rawValue))."
            )
        }
        return .success(.object(["ref": ref ?? .null]))
    }

    /// One position write and one size write, in that order. Returns the error of
    /// the first that fails, or nil.
    private func write(_ element: AXUIElement, _ rect: ScreenRect) -> AXError? {
        var point = CGPoint(x: rect.x, y: rect.y)
        var size = CGSize(width: rect.width, height: rect.height)
        guard let position = AXValueCreate(.cgPoint, &point), let extent = AXValueCreate(.cgSize, &size) else {
            return .failure
        }
        AXUIElementSetMessagingTimeout(element, messagingTimeout)
        var error = AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, position)
        guard error == .success else { return error }
        error = AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, extent)
        return error == .success ? nil : error
    }

    private func result(_ step: Step) -> ResolutionResult {
        if case .ended(let result) = step { return result }
        return failed("The window could not be moved or resized.")
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

    // MARK: Display focus

    /// `desktopFocusDisplay`: raises the front window on the display that `ref` names, activates its
    /// application and moves the pointer to the centre of the display. It never clicks. The steps and their
    /// order are `DisplayFocus.perform`. The front window comes from one reading of the window list, as
    /// `desktopWindows` makes it, and it is focused as `desktopFocusWindow` focuses a window: by the reference
    /// of its own row, so the action goes to that row's held element. The receipt names no window.
    private func focusDisplay(_ ref: ProviderValue?) async -> ResolutionResult {
        guard case .reference(let uri)? = ref, case .display(let id)? = DesktopReference(uri: uri) else {
            return notADisplay
        }
        let display: ScreenRect
        switch activeDisplay(id) {
        case .success(let frame?): display = frame
        case .success(nil): return displayGone
        case .failure(let failure): return .failure(failure)
        }
        var references: [ProviderValue] = []
        let centre = DisplayFocus.centre(of: display)
        let result = await DisplayFocus.perform(
            buttonHeld: { Self.pointerButtonHeld() },
            choose: { () async -> Result<FrontWindow, ProviderFailure> in
                let reading = await onQueue { self.readWindowList() }
                return reading.map { rows in
                    references = rows.map { row in
                        if case .object(let fields) = row.window, let ref = fields["ref"] { return ref }
                        return .null
                    }
                    return DisplayFocus.front(
                        of: display, rows: rows.map { FocusRow(frame: $0.frame, stacking: $0.stacking) })
                }
            },
            focus: { position in
                switch await self.focus(references[position]) {
                case .success: return nil
                case .failure(let failure):
                    // Consent stays a consent failure. Any other failure of the focus step is the failure of
                    // display focus, because the reference that the client passed names the display.
                    if failure.kind == .osPermission { return failure }
                    return ProviderFailure(
                        kind: .failed, message: "The front window on the display did not take focus. \(failure.message)"
                    )
                @unknown default:
                    return ProviderFailure(kind: .failed, message: "The front window on the display did not take focus.")
                }
            },
            move: { Self.movePointer(to: centre) }
        )
        switch result {
        case .success(let receipt):
            return .success(
                .object([
                    "ref": .reference(uri),
                    "outcome": .string(receipt.outcome.rawValue),
                    "pointerMoved": .bool(receipt.pointerMoved),
                ])
            )
        case .failure(let failure): return .failure(failure)
        }
    }

    /// The frame of the display while it is active, or nil when it is not active or its bounds come back
    /// empty (docs/specs/machine.md, "Displays").
    private func activeDisplay(_ id: UInt32) -> Result<ScreenRect?, ProviderFailure> {
        // https://developer.apple.com/documentation/coregraphics/1454603-cggetactivedisplaylist
        var count: UInt32 = 0
        let failure = ProviderFailure(kind: .failed, message: "macOS did not list the active displays.")
        guard CGGetActiveDisplayList(0, nil, &count) == .success else { return .failure(failure) }
        var identifiers = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetActiveDisplayList(count, &identifiers, &count) == .success else { return .failure(failure) }
        guard identifiers.prefix(Int(count)).contains(id) else { return .success(nil) }
        let frame = ScreenRect(CGDisplayBounds(id))
        return .success(frame.isEmpty ? nil : frame)
    }

    /// Whether any pointer button is down now. "This returns the state of devices combined with synthesized
    /// events at the moment, independent of which events have been delivered via the event stream."
    /// https://developer.apple.com/documentation/appkit/nsevent/pressedmousebuttons
    private static func pointerButtonHeld() -> Bool { NSEvent.pressedMouseButtons != 0 }

    /// Modaliser's pointer move (`warpMouse` in its WindowManipulator.swift): a warp, and then one mouse-moved
    /// event at the same point. A warp "moves the mouse cursor without generating events", so the event lets
    /// the application under the pointer see it there. No event here presses a button.
    /// https://developer.apple.com/documentation/coregraphics/cgwarpmousecursorposition(_:)
    /// https://developer.apple.com/documentation/coregraphics/cgevent/post(tap:)
    private static func movePointer(to point: (x: Double, y: Double)) -> ProviderFailure? {
        let target = CGPoint(x: point.x, y: point.y)
        let error = CGWarpMouseCursorPosition(target)
        guard error == .success else {
            return ProviderFailure(kind: .failed, message: "macOS did not move the pointer (CGError \(error.rawValue)).")
        }
        guard
            let moved = CGEvent(
                mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: target, mouseButton: .left)
        else {
            return ProviderFailure(
                kind: .failed, message: "The pointer moved, but macOS did not create the mouse-moved event.")
        }
        moved.post(tap: .cghidEventTap)
        return nil
    }

    // MARK: Pointer

    /// The pointer position in screen coordinates, from one AppKit reading, or nil when AppKit lists no screen.
    /// Modaliser reads the position this way (`nudgeMouse` in its CursorLibrary.swift). NSScreen belongs to the
    /// main actor, so the position and the screens are read together there. Neither needs Accessibility consent.
    /// https://developer.apple.com/documentation/appkit/nsevent/mouselocation
    /// https://developer.apple.com/documentation/appkit/nsscreen/screens
    private static func readPointer() async -> ScreenPoint? {
        await MainActor.run {
            let location = NSEvent.mouseLocation
            let height = NSScreen.screens.first.map { Double($0.frame.height) }
            return PointerPosition.screenPoint(appKit: (location.x, location.y), firstScreenHeight: height)
        }
    }

    /// `desktopPointer`: where the pointer is now. Null when Koine cannot establish the position.
    private func pointer() async -> ResolutionResult {
        guard let point = await Self.readPointer() else { return .success(.null) }
        return .success(.object(["location": .object(["x": .double(point.x), "y": .double(point.y)])]))
    }

    /// `desktopNudgePointer`: one point to the right and back, with two mouse-moved events, as Modaliser's
    /// `nudgeMouse` posts them. The steps and their order are `PointerNudge.perform`. It never clicks, and no
    /// event presses a button. The receipt carries the outcome alone, because the position is read data.
    private func nudgePointer() async -> ResolutionResult {
        let result = await PointerNudge.perform(
            consent: { Self.postingConsent() },
            buttonHeld: { Self.pointerButtonHeld() },
            start: { await Self.readPointer() },
            create: { point in
                CGEvent(
                    mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: point.x, y: point.y),
                    mouseButton: .left)
            },
            post: { $0.post(tap: .cghidEventTap) }
        )
        switch result {
        case .success(let outcome): return .success(.object(["outcome": .string(outcome.rawValue)]))
        case .failure(.permission(let message)): return .failure(.osPermission("accessibility", message: message))
        case .failure(.positionUnknown):
            return failed("Koine cannot establish the pointer position, so it posted nothing.")
        case .failure(.eventNotCreated):
            return failed("macOS did not create the mouse-moved events, so Koine posted nothing.")
        }
    }

    /// The two checks before Koine posts an event. Neither asks for consent: no operation calls
    /// `CGRequestPostEventAccess`, which can prompt (docs/specs/machine.md, "Grants, consent and failures").
    /// The SDK header CGEvent.h: CGPreflightPostEventAccess "checks whether the current process already has event
    /// synthesizing access".
    /// https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted
    /// https://developer.apple.com/documentation/coregraphics/cgpreflightposteventaccess()
    private static func postingConsent() -> PostingConsent {
        PostingConsent(accessibility: AXIsProcessTrusted(), posting: CGPreflightPostEventAccess())
    }

    private var notADisplay: ResolutionResult { unavailable("The reference does not name a desktop display.") }
    private var displayGone: ResolutionResult { unavailable("The display is no longer active.") }

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
    private var untrusted: ResolutionResult { .failure(untrustedFailure) }

    private var untrustedFailure: ProviderFailure {
        .osPermission("accessibility", message: "Koine needs Accessibility access to read and focus windows.")
    }

    private func unanswered(_ error: AXError, application: String = "The application") -> ResolutionResult {
        .failure(unansweredFailure(error, application: application))
    }

    private func unansweredFailure(_ error: AXError, application: String) -> ProviderFailure {
        // Consent can end while Koine runs, and between the trust check and the call.
        if error == .apiDisabled { return untrustedFailure }
        return ProviderFailure(
            kind: .failed, message: "\(application) did not answer for its windows (AXError \(error.rawValue))."
        )
    }
}

extension ScreenRect {
    init(_ rect: CGRect) {
        self.init(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
    }
}
