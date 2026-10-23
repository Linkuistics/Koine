import Foundation
import KoineProviderAPI

// The contribution: the launch, URL, path and reveal roots, and the special-locations and application queries,
// with every type they reach. The SDL (schema.graphql) is served verbatim from the design file.

/// The host feature that says the host's grant views and management catalogue state the reach of
/// `workspace:read` (docs/adr/native-workspace-requires-disclosure-capable-host.md). A host without it
/// refuses the provider before it loads, so no grant is shown with less than its reach.
let workspaceNativeDisclosuresFeature = "workspace-native-disclosures-v1"

/// The authority of every action field: control of its own class, and additionally control of desktop, since
/// bringing an application forward is an allowed effect. Neither read capability is part of it.
let workspaceAdditionalRequirements = [ProviderCapabilityRequirement(providerId: "desktop", kind: .control)]

func workspaceDescriptor(schemaSDL: String) -> ProviderDescriptor {
    // A nested field's resolver identifier is the key it reads from its parent.
    let nested = [
        "WorkspaceOpenResult": ["status", "value", "dependency"],
        "WorkspaceOpenReceipt": ["process"],
        "WorkspaceRevealResult": ["status", "value", "dependency"],
        "WorkspaceRevealReceipt": ["path"],
        "WorkspaceProcessIdentity": ["pid", "startedAt"],
        "WorkspaceDependencyUnavailable": ["reason", "guidance"],
    ]
    // The roots, in the order the contribution declares them.
    var fields = [
        ("Mutation.workspaceLaunchApplication", "launchApplication"),
        ("Mutation.workspaceOpenURL", "openURL"),
        ("Mutation.workspaceOpenPath", "openPath"),
        ("Mutation.workspaceRevealPath", "revealPath"),
    ].map { coordinate, resolverId in
        ProviderFieldRegistration(
            coordinate: coordinate, resolverId: resolverId,
            authority: .control, additionalRequirements: workspaceAdditionalRequirements
        )
    }
    for (type, names) in nested.sorted(by: { $0.key < $1.key }) {
        fields += names.map {
            ProviderFieldRegistration(
                coordinate: "\(type).\($0)", resolverId: "parent.\($0)", authority: .control,
                additionalRequirements: workspaceAdditionalRequirements
            )
        }
    }
    // The read surface: workspace:read and nothing else, on the root and on every field it reaches. Objects
    // never cross the two sets, so no control grant reads, and no read grant acts.
    let discovery = [
        "WorkspaceSpecialLocationsResult": ["status", "items", "sources", "resultsTruncated"],
        "WorkspaceSpecialLocation": ["kind", "domain", "accountIdentifier", "location", "contentsAvailability", "sources"],
        "WorkspaceDiscoveryCoverage": [
            "source", "declaredDomain", "availability", "observations", "category", "examined", "diagnostics",
        ],
        "WorkspaceDiscoveryDiagnostic": ["source", "reason", "subject", "affectsCoverage", "guidance", "permission"],
        "WorkspaceDiscoveryPermissionHint": ["permission", "target", "event", "consent"],
        "WorkspaceApplicationsResult": ["status", "items", "sources", "resultsTruncated"],
        "WorkspaceApplicationChoice": ["applicationPath", "name", "bundleIdentifier", "sources"],
    ]
    fields += [
        ProviderFieldRegistration(
            coordinate: "Query.workspaceSpecialLocations", resolverId: "specialLocations", authority: .read),
        ProviderFieldRegistration(
            coordinate: "Query.workspaceApplications", resolverId: "applications", authority: .read),
    ]
    for (type, names) in discovery.sorted(by: { $0.key < $1.key }) {
        fields += names.map {
            // A failed lookup raises at `items`, so that one field of each result has a resolver of its own.
            let resolverId =
                switch (type, $0) {
                case ("WorkspaceSpecialLocationsResult", "items"): "frozen.items"
                case ("WorkspaceApplicationsResult", "items"): "frozen.applicationItems"
                default: "parent.\($0)"
                }
            return ProviderFieldRegistration(
                coordinate: "\(type).\($0)", resolverId: resolverId, authority: .read)
        }
    }
    return ProviderDescriptor(
        providerId: "workspace", graphQLPrefix: "Workspace", schemaSDL: schemaSDL, fields: fields,
        requiredFeatures: [ProviderDescriptor.additionalCapabilitiesFeature, workspaceNativeDisclosuresFeature]
    )
}

/// Launches or reactivates an installed application by bundle identity, opens a web URL in
/// the default browser, opens a document or directory in its default or a named
/// application, asks Finder to reveal a path, and reports the system's special locations and the applications that the
/// index lists. Nothing is cached between calls: the installation is inspected on every action, and
/// the one thing held is the bound on native submissions still outstanding.
final class WorkspaceProvider: Provider, @unchecked Sendable {
    /// Below the core's five-second request ceiling, which can still win first.
    static let defaultAcknowledgmentBound = Duration.seconds(3)
    static let defaultSubmissionCapacity = 16
    /// How long one application query waits for the index's initial gathering: the same bound as an acknowledgment.
    static let defaultIndexWait = Duration.seconds(3)

    private let native: any WorkspaceNative
    private let bound: Duration
    private let indexWait: Duration
    private let limit: SubmissionLimit
    /// Inspection reads the filesystem, which can block: it never runs on Swift's
    /// cooperative threads.
    private let queue = DispatchQueue(label: "dev.antony.Koine.provider.workspace", attributes: .concurrent)

    init(
        native: any WorkspaceNative, acknowledgmentBound: Duration = WorkspaceProvider.defaultAcknowledgmentBound,
        submissionCapacity: Int = WorkspaceProvider.defaultSubmissionCapacity,
        indexWait: Duration = WorkspaceProvider.defaultIndexWait
    ) {
        self.native = native
        self.bound = acknowledgmentBound
        self.indexWait = indexWait
        self.limit = SubmissionLimit(capacity: submissionCapacity)
    }

    var submissionsInFlight: Int { limit.inFlight }

    func start() async throws {}

    /// Nothing here waits on another process: an outstanding native callback is
    /// ignored when it comes.
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
        switch request.resolverId {
        case "specialLocations": return await specialLocations(request.arguments["requests"])
        case "frozen.items":
            return frozenItems(
                of: request.parent, failure: "The system gave special-location values that cannot be reported, and none that can.")
        case "applications": return await applications()
        case "frozen.applicationItems":
            return frozenItems(of: request.parent, failure: "The index gave no application list that can be reported.")
        case "launchApplication": return await launch(request.arguments["application"])
        case "openURL": return await openWebURL(request.arguments["url"])
        case "openPath": return await openPath(request.arguments["path"], application: request.arguments["application"])
        case "revealPath": return await revealPath(request.arguments["path"])
        default: return .failure(ProviderFailure(kind: .unknownResolver, message: "No such resolver."))
        }
    }

    private func onQueue<Value: Sendable>(_ work: @escaping @Sendable () -> Value) async -> Value {
        await withCheckedContinuation { continuation in
            queue.async { continuation.resume(returning: work()) }
        }
    }

    // MARK: Special locations

    /// Foundation's value for each requested pair and nothing else. The request is validated first, so a
    /// refused request asks the system nothing.
    private func specialLocations(_ argument: ProviderValue?) async -> ResolutionResult {
        let pairs: [LocationPair]
        switch LocationPair.validated(argument) {
        case .success(let validated): pairs = validated
        case .failure(let error): return .failure(invalid(error.message))
        }
        let explicit: Bool
        switch argument {
        case nil, .null?: explicit = false
        default: explicit = true
        }
        let native = native
        return .success(await onQueue { specialLocationsResult(for: pairs, explicit: explicit, native: native) })
    }

    /// The frozen list, or the failure a FAILED lookup raises at each selected `items`: the list is null for the
    /// other statuses that have none.
    private func frozenItems(of parent: ProviderValue?, failure: String) -> ResolutionResult {
        guard case .object(let fields)? = parent, case .string(let status)? = fields["status"], let items = fields["items"]
        else { return failed("No parent value.") }
        if status == "FAILED" { return failed(failure) }
        return .success(items)
    }

    // MARK: Applications

    /// The applications that the one fixed index query reports, and nothing else: no copy is resolved, registered,
    /// launched or inspected. The query blocks until the initial gathering finishes or the wait ends, so it never runs
    /// on a cooperative thread.
    private func applications() async -> ResolutionResult {
        guard !Task.isCancelled else { return failed("Cancelled before the index was queried.") }
        let native = native
        let wait = indexWait
        return .success(await onQueue { applicationsResult(native: native, wait: wait) })
    }

    // MARK: Launch

    private func launch(_ argument: ProviderValue?) async -> ResolutionResult {
        let request: ApplicationRequest
        switch parse(argument) {
        case .success(let parsed): request = parsed
        case .failure(let error): return .failure(invalid(error.message))
        }
        guard !Task.isCancelled else { return failed("Cancelled before the application was inspected.") }
        let native = native
        let selection = await onQueue { selectInstallation(request, forAction: "launched", native: native) }
        switch selection {
        case .dependency(let reason, let guidance): return .success(dependency(reason, guidance))
        case .failed(let message): return failed(message)
        case .selected(let url, let substituting):
            // Inspection was a read; from here on an effect may have begun.
            return await submit(doing: "launch or activate the application", acknowledging: "launch") { completion in
                native.launchApplication(at: url, substitutingRunningCopy: substituting, completion: completion)
            }
        }
    }

    // MARK: Open URL

    /// Opens a web URL in the default browser, resolved from the URL's scheme alone and
    /// then addressed explicitly: a URL that is a universal link for another application
    /// is still opened by the browser. The bytes submitted are the bytes received.
    private func openWebURL(_ argument: ProviderValue?) async -> ResolutionResult {
        guard case .string(let text)? = argument else { return .failure(invalid("url must be a string.")) }
        let webURL: WebURL
        switch WebURL.validated(text) {
        case .success(let validated): webURL = validated
        case .failure(let error): return .failure(invalid(error.message))
        }
        // Nothing is repaired to fit: bytes the platform would change are not submitted.
        guard let url = webURL.url else {
            return failed("The system cannot represent this URL without changing it, so it was not opened.")
        }
        guard !Task.isCancelled else { return failed("Cancelled before the default browser was looked up.") }
        let native = native
        let selection = await onQueue { selectWebHandler(webURL.scheme, forAction: "opened", native: native) }
        switch selection {
        case .dependency(let reason, let guidance): return .success(dependency(reason, guidance))
        case .failed(let message): return failed(message)
        case .selected(let browser, _):
            // Resolved once. A default changed after this point neither retargets nor replays.
            return await submit(doing: "open the URL", acknowledging: "open request") { completion in
                native.openWebURL(url, withApplicationAt: browser, completion: completion)
            }
        }
    }

    // MARK: Open path

    /// Opens a literal absolute path in its default application or a named one. The target is
    /// resolved and checked against the hand-off limit first (a missing file is never conflated
    /// with a missing handler), refused by the metadata of the resolved object if it is an
    /// application, an executable program or a Finder alias, and only then is the application chosen. The path is submitted as written; the handler follows
    /// links as usual, so this is a request about a location, not a pinned file identity.
    private func openPath(_ pathArgument: ProviderValue?, application argument: ProviderValue?) async -> ResolutionResult {
        guard case .string(let text)? = pathArgument else { return .failure(invalid("path must be a string.")) }
        let path: LocalPath
        switch LocalPath.validated(text) {
        case .success(let validated): path = validated
        case .failure(let error): return .failure(invalid(error.message))
        }
        let named: ApplicationRequest?
        switch argument {
        case .null?, nil: named = nil
        default:
            switch parse(argument) {
            case .success(let parsed): named = parsed
            case .failure(let error): return .failure(invalid(error.message))
            }
        }
        guard !Task.isCancelled else { return failed("Cancelled before the path was inspected.") }
        let native = native
        let plan = await onQueue { planPathOpen(path, application: named, native: native) }
        switch plan {
        case .dependency(let reason, let guidance): return .success(dependency(reason, guidance))
        case .refused(let message): return .failure(invalid(message))
        case .failed(let message): return failed(message)
        case .submit(let target, let handler, let substituting):
            // Resolved once. A handler or file changed after this point neither retargets nor replays.
            return await submit(doing: "open the file or folder", acknowledging: "open request") { completion in
                native.openPath(target, withApplicationAt: handler, substitutingRunningCopy: substituting, completion: completion)
            }
        }
    }

    // MARK: Reveal path

    /// Asks Finder to select a literal absolute path, which is resolved first component by component and
    /// checked against the application hand-off limit (`planReveal`), and submitted as written. The receipt echoes the submitted path and nothing else: it is
    /// Finder's boolean acknowledgment, never an observation that the item is selected.
    private func revealPath(_ pathArgument: ProviderValue?) async -> ResolutionResult {
        guard case .string(let text)? = pathArgument else { return .failure(invalid("path must be a string.")) }
        let path: LocalPath
        switch LocalPath.validated(text) {
        case .success(let validated): path = validated
        case .failure(let error): return .failure(invalid(error.message))
        }
        guard !Task.isCancelled else { return failed("Cancelled before the path was inspected.") }
        let native = native
        let plan = await onQueue { planReveal(path, native: native) }
        switch plan {
        case .dependency(let reason, let guidance): return .success(dependency(reason, guidance))
        case .failed(let message): return failed(message)
        case .submit(let target, let filesystemRoot):
            // Once. A replacement after inspection neither retargets nor replays.
            return await submit(
                doing: "reveal the item in Finder", acknowledging: "reveal request",
                { completion in native.revealPath(target, filesystemRoot: filesystemRoot, completion: completion) },
                receipt: { _ in
                    .object([
                        "status": .string("AVAILABLE"), "value": .object(["path": .string(target)]),
                        "dependency": .null,
                    ])
                })
        }
    }

    /// One native submission under the shared bound, and how it ends as a result. `doing`
    /// completes "The system did not ..." and `acknowledging` names the request in the
    /// timeout and cancellation messages. An acknowledged open or launch reports the observed
    /// process; `receipt` replaces that for a request that has none to observe.
    private func submit(
        doing action: String, acknowledging noun: String,
        _ send: (@escaping @Sendable (LaunchCompletion) -> Void) -> Void,
        receipt: ((LaunchedApplication?) async -> ProviderValue)? = nil
    ) async -> ResolutionResult {
        let native = native
        let acknowledgment = await submitOnce(send, limit: limit, bound: bound)
        switch acknowledgment {
        case .notSubmitted(let reason): return failed(reason)
        case .refused(let reason): return failed("The system did not \(action): \(reason)")
        case .timedOut:
            return failed(
                "The system did not acknowledge the \(noun) within \(bound.components.seconds) seconds. "
                    + "It may still complete; the request was not repeated."
            )
        case .cancelled:
            return failed("Cancelled while waiting for the system to acknowledge the \(noun).")
        case .acknowledged(let application):
            if let receipt { return .success(await receipt(application)) }
            var observed: ObservedProcess?
            if let application { observed = await onQueue { observeProcess(of: application, native: native) } }
            return .success(available(observed))
        }
    }

    // MARK: Values

    private func parse(_ argument: ProviderValue?) -> Result<ApplicationRequest, InputError> {
        guard case .object(let fields)? = argument, case .string(let identifier)? = fields["bundleIdentifier"] else {
            return .failure(InputError("application needs a bundleIdentifier."))
        }
        var path: String?
        switch fields["applicationPath"] {
        case .string(let text)?: path = text
        case .null?, nil: path = nil
        default: return .failure(InputError("application.applicationPath must be a string."))
        }
        return ApplicationRequest.validated(bundleIdentifier: identifier, applicationPath: path)
    }

    private func available(_ process: ObservedProcess?) -> ProviderValue {
        let identity: ProviderValue =
            process.map {
                .object(["pid": .int(Int($0.pid)), "startedAt": .string($0.start.canonical)])
            } ?? .null
        return .object([
            "status": .string("AVAILABLE"),
            "value": .object(["process": identity]),
            "dependency": .null,
        ])
    }

    private func dependency(_ reason: DependencyReason, _ guidance: String) -> ProviderValue {
        .object([
            "status": .string("DEPENDENCY_UNAVAILABLE"),
            "value": .null,
            "dependency": .object(["reason": .string(reason.rawValue), "guidance": .string(guidance)]),
        ])
    }

    private func invalid(_ message: String) -> ProviderFailure {
        ProviderFailure(kind: .invalidInput, message: message)
    }

    private func failed(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .failed, message: message))
    }
}
