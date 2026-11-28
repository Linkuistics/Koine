import AppKit
import ApplicationServices
import Foundation
import KoineProviderAPI

// build.sh generates `inputSchemaSDL` from schema.graphql.

@objc(KoineInputProviderFactory)
final class InputProviderFactory: NSObject, ProviderFactory {
    override required init() { super.init() }

    var descriptor: ProviderDescriptor {
        var fields = [
            ProviderFieldRegistration(coordinate: "Query.inputFrontTarget", resolverId: "frontTarget", authority: .read),
            ProviderFieldRegistration(coordinate: "Query.inputTarget", resolverId: "target", authority: .read),
        ]
        // A nested field's resolver identifier is the key that it reads from its parent.
        fields += ["ref", "name", "bundleIdentifier", "protection"].map {
            ProviderFieldRegistration(coordinate: "InputTarget.\($0)", resolverId: "parent.\($0)", authority: .read)
        }
        // The receipt is read under the authority of the action, not input:read.
        fields += [
            ProviderFieldRegistration(
                coordinate: "Mutation.inputSendKeystroke", resolverId: "sendKeystroke", authority: .control
            ),
            ProviderFieldRegistration(
                coordinate: "InputKeystrokeReceipt.outcome", resolverId: "parent.outcome", authority: .control
            ),
        ]
        // The Space switch and its receipt need input:control and desktop:control (docs/specs/app-input.md,
        // "Authority, consent and failures"). The additional requirement is why the descriptor declares the feature.
        let desktopControl = [ProviderCapabilityRequirement(providerId: "desktop", kind: .control)]
        fields += [
            ProviderFieldRegistration(
                coordinate: "Mutation.inputSwitchSpace", resolverId: "switchSpace", authority: .control,
                additionalRequirements: desktopControl
            ),
            ProviderFieldRegistration(
                coordinate: "InputSpaceSwitchReceipt.outcome", resolverId: "parent.outcome", authority: .control,
                additionalRequirements: desktopControl
            ),
        ]
        return ProviderDescriptor(
            providerId: "input", graphQLPrefix: "Input", schemaSDL: inputSchemaSDL, fields: fields,
            requiredFeatures: [ProviderDescriptor.additionalCapabilitiesFeature]
        )
    }

    func makeProvider() -> any Provider { InputProvider() }
}

/// Every reference is resolved again against the system on each use. The provider keeps no state between calls.
final class InputProvider: Provider, Sendable {
    func start() async throws {}

    func stop() async {}

    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        let prefix = "parent."
        if request.resolverId.hasPrefix(prefix) {
            let key = String(request.resolverId.dropFirst(prefix.count))
            guard case .object(let parent)? = request.parent, let value = parent[key] else {
                return failed("No parent value.")
            }
            return .success(value)
        }
        switch request.resolverId {
        case "frontTarget": return await frontTarget()
        case "target": return target(request.arguments["process"])
        case "sendKeystroke":
            return sendKeystroke(
                request.arguments["target"], key: request.arguments["key"], modifiers: request.arguments["modifiers"]
            )
        case "switchSpace": return await switchSpace(request.arguments["number"])
        default: return .failure(ProviderFailure(kind: .unknownResolver, message: "No such resolver."))
        }
    }

    // MARK: Targets

    /// How Koine recognises itself: this process, and the bundle identifier of the application that loaded the
    /// provider.
    private static var koine: KoineIdentity {
        KoineIdentity(pid: getpid(), bundleIdentifier: Bundle.main.bundleIdentifier)
    }

    /// `inputFrontTarget`: the app that macOS reports as active, read as Modaliser reads it. AppKit keeps the value
    /// from the activation notices of macOS, on the main actor.
    /// https://developer.apple.com/documentation/appkit/nsworkspace/frontmostapplication
    private func frontTarget() async -> ResolutionResult {
        guard let pid = await MainActor.run(body: { NSWorkspace.shared.frontmostApplication?.processIdentifier })
        else { return .success(.null) }
        switch processStart(of: pid) {
        case .absent: return .success(.null)
        case .unreadable(let reason): return failed("The process could not be read: \(reason).")
        case .running(let start):
            return capture(ProcessIncarnation(pid: pid, startMicroseconds: start.microsecondsSinceEpoch))
        }
    }

    /// `inputTarget(process:)`: both halves of the identity are compared. A live process identifier with another
    /// start instant is another process, and absent.
    private func target(_ identity: ProviderValue?) -> ResolutionResult {
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
        return capture(ProcessIncarnation(pid: pid, startMicroseconds: claimed.microsecondsSinceEpoch))
    }

    private func capture(_ process: ProcessIncarnation) -> ResolutionResult {
        switch Self.lookup(process) {
        case .gone: return .success(.null)
        case .unreadable(let reason): return failed("The process could not be read: \(reason).")
        case .live(let app):
            guard let target = InputTarget.capture(process, app: app, koine: Self.koine) else { return .success(.null) }
            return .success(
                .object([
                    "ref": target.ref.map(ProviderValue.reference) ?? .null,
                    "name": .string(target.name),
                    "bundleIdentifier": target.bundleIdentifier.map(ProviderValue.string) ?? .null,
                    "protection": .string(target.protection.rawValue),
                ])
            )
        }
    }

    /// The incarnation from the kernel's record of the process, and the app facts from `NSRunningApplication`. A
    /// process that `NSRunningApplication` does not report is live but not an app.
    /// https://developer.apple.com/documentation/appkit/nsrunningapplication/init(processidentifier:)
    private static func lookup(_ process: ProcessIncarnation) -> TargetLookup {
        switch processStart(of: process.pid) {
        case .absent: return .gone
        case .unreadable(let reason): return .unreadable(reason)
        case .running(let start):
            guard start.microsecondsSinceEpoch == process.startMicroseconds else { return .gone }
            guard let running = NSRunningApplication(processIdentifier: process.pid), !running.isTerminated else {
                return .live(app: nil)
            }
            return .live(
                app: AppFacts(
                    localizedName: running.localizedName, executableName: running.executableURL?.lastPathComponent,
                    bundleIdentifier: running.bundleIdentifier
                )
            )
        }
    }

    // MARK: Chords

    /// `inputSendKeystroke`: one chord into the event stream of the target process. The steps and their order are
    /// `Keystroke.perform`. The core passes an enum argument as its name, a string.
    private func sendKeystroke(_ ref: ProviderValue?, key: ProviderValue?, modifiers: ProviderValue?)
        -> ResolutionResult
    {
        guard case .string(let name)? = key, let key = InputKey(rawValue: name) else {
            return failed("The argument is not a key, so Koine sent nothing.")
        }
        guard case .list(let values)? = modifiers else {
            return failed("The argument is not a list of modifiers, so Koine sent nothing.")
        }
        var list: [InputModifier] = []
        for value in values {
            guard case .string(let name) = value, let modifier = InputModifier(rawValue: name) else {
                return failed("The argument is not a list of modifiers, so Koine sent nothing.")
            }
            list.append(modifier)
        }
        // The core checks the envelope, so a reference here is a koine:// text. Another provider's reference parses
        // as no input target. The post is CGEventPostToPid, which the SDK header CGEvent.h describes as a post
        // "immediately before any event taps instantiated for the specified process".
        // https://developer.apple.com/documentation/coregraphics/cgevent/posttopid(_:)
        guard case .reference(let uri)? = ref else { return unavailable(Keystroke.malformed) }
        let result = Keystroke.perform(
            reference: uri, key: key, modifiers: list, koine: Self.koine,
            consent: { Self.postingConsent() },
            lookup: { Self.lookup($0) },
            create: { Self.events($0) },
            post: { event, pid in event.postToPid(pid) }
        )
        switch result {
        case .success(let outcome): return .success(.object(["outcome": .string(outcome.rawValue)]))
        case .failure(.permission(let message)): return .failure(.osPermission("accessibility", message: message))
        case .failure(.unavailable(let message)): return unavailable(message)
        case .failure(.unreadable(let reason)): return failed("The process could not be read: \(reason).")
        case .failure(.eventNotCreated):
            return failed("macOS did not create the keyboard events, so Koine sent nothing.")
        }
    }

    /// The keyboard events of a chord, each from one event source with the combined session state, as Modaliser
    /// and the route probe create them. Koine puts no tag in the events. Nil when macOS does not create the source or
    /// an event.
    /// https://developer.apple.com/documentation/coregraphics/cgevent/init(keyboardeventsource:virtualkey:keydown:)
    private static func events(_ chord: [ChordEvent]) -> [CGEvent]? {
        guard let source = CGEventSource(stateID: .combinedSessionState) else { return nil }
        var events: [CGEvent] = []
        for item in chord {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: item.keyCode, keyDown: item.keyDown)
            else { return nil }
            event.flags = CGEventFlags(rawValue: item.flags)
            events.append(event)
        }
        return events
    }

    // MARK: Space switching

    /// `inputSwitchSpace`: Control and a digit at the HID event tap, so that macOS catches the shortcut "Switch to
    /// Desktop N". It never uses `CGEventPostToPid`, which skips the system shortcuts. The steps and their order are
    /// `SpaceSwitch.perform`. They run in one turn of the main actor, so AppKit cannot update the front app between
    /// the check of the front app and the posts.
    /// https://developer.apple.com/documentation/coregraphics/cgevent/post(tap:)
    private func switchSpace(_ argument: ProviderValue?) async -> ResolutionResult {
        guard case .int(let number)? = argument, (1...9).contains(number) else {
            return invalid("number must be a Mission Control desktop from 1 to 9.")
        }
        let koine = Self.koine
        let result = await MainActor.run {
            SpaceSwitch.perform(
                number: number, koine: koine,
                consent: { Self.postingConsent() },
                shortcuts: { symbolicHotKeys() },
                desktops: { managedDisplaySpaces() },
                create: { Self.events($0) },
                front: {
                    NSWorkspace.shared.frontmostApplication.map {
                        FrontApp(pid: $0.processIdentifier, bundleIdentifier: $0.bundleIdentifier)
                    }
                },
                post: { $0.post(tap: .cghidEventTap) }
            )
        }
        switch result {
        case .success(let outcome): return .success(.object(["outcome": .string(outcome.rawValue)]))
        case .failure(.invalidNumber): return invalid("number must be a Mission Control desktop from 1 to 9.")
        case .failure(.permission(let message)): return .failure(.osPermission("accessibility", message: message))
        case .failure(.shortcutUnreadable):
            return failed(
                "The shortcut setting for Mission Control desktop \(number) has a form that Koine does not read, "
                    + "so Koine posted nothing.")
        case .failure(.desktopsUncountable):
            return failed("Koine could not count the Mission Control desktops, so it posted nothing.")
        case .failure(.eventNotCreated):
            return failed("macOS did not create the keyboard events, so Koine posted nothing.")
        }
    }

    /// The two checks before Koine posts an event, as the media keys make them. Neither asks for consent: no
    /// operation calls `CGRequestPostEventAccess`, which can prompt. The route probe established that a post to a
    /// process needs posting access, as the post at the HID event tap does (docs/verification/keystroke-route-vm.md).
    /// https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted
    /// https://developer.apple.com/documentation/coregraphics/cgpreflightposteventaccess()
    private static func postingConsent() -> PostingConsent {
        PostingConsent(accessibility: AXIsProcessTrusted(), posting: CGPreflightPostEventAccess())
    }

    // MARK: Failures

    private func invalid(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .invalidInput, message: message))
    }

    private func unavailable(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .unavailable, message: message))
    }

    private func failed(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .failed, message: message))
    }
}
