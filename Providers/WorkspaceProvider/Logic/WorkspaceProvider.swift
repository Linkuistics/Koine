import Foundation
import KoineProviderAPI

// The contribution: the launch root and every type it reaches, under
// workspace:control AND desktop:control. Later roots extend this list with their
// own leaves; the SDL (schema.graphql) is served verbatim from the design file.

/// The provider's whole authority, for every field it serves: control of its own
/// class, and additionally control of desktop, since bringing an application
/// forward is an allowed effect. The set is unconditional and neither read
/// capability is part of it.
let workspaceAdditionalRequirements = [ProviderCapabilityRequirement(providerId: "desktop", kind: .control)]

func workspaceDescriptor(schemaSDL: String) -> ProviderDescriptor {
    // A nested field's resolver identifier is the key it reads from its parent.
    let nested = [
        "WorkspaceOpenResult": ["status", "value", "dependency"],
        "WorkspaceOpenReceipt": ["process"],
        "WorkspaceProcessIdentity": ["pid", "startedAt"],
        "WorkspaceDependencyUnavailable": ["reason", "guidance"],
    ]
    var fields = [
        ProviderFieldRegistration(
            coordinate: "Mutation.workspaceLaunchApplication", resolverId: "launchApplication",
            authority: .control, additionalRequirements: workspaceAdditionalRequirements
        )
    ]
    for (type, names) in nested.sorted(by: { $0.key < $1.key }) {
        fields += names.map {
            ProviderFieldRegistration(
                coordinate: "\(type).\($0)", resolverId: "parent.\($0)", authority: .control,
                additionalRequirements: workspaceAdditionalRequirements
            )
        }
    }
    return ProviderDescriptor(
        providerId: "workspace", graphQLPrefix: "Workspace", schemaSDL: schemaSDL, fields: fields,
        requiredFeatures: [ProviderDescriptor.additionalCapabilitiesFeature]
    )
}

/// Launches or reactivates an installed application by bundle identity. Nothing
/// is cached between calls: the installation is inspected on every action, and
/// the one thing held is the bound on native submissions still outstanding.
final class WorkspaceProvider: Provider, @unchecked Sendable {
    /// Below the core's five-second request ceiling, which can still win first.
    static let defaultAcknowledgmentBound = Duration.seconds(3)
    static let defaultSubmissionCapacity = 16

    private let native: any WorkspaceNative
    private let bound: Duration
    private let limit: SubmissionLimit
    /// Inspection reads the filesystem, which can block: it never runs on Swift's
    /// cooperative threads.
    private let queue = DispatchQueue(label: "dev.antony.Koine.provider.workspace", attributes: .concurrent)

    init(
        native: any WorkspaceNative, acknowledgmentBound: Duration = WorkspaceProvider.defaultAcknowledgmentBound,
        submissionCapacity: Int = WorkspaceProvider.defaultSubmissionCapacity
    ) {
        self.native = native
        self.bound = acknowledgmentBound
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
        case "launchApplication": return await launch(request.arguments["application"])
        default: return .failure(ProviderFailure(kind: .unknownResolver, message: "No such resolver."))
        }
    }

    private func onQueue<Value: Sendable>(_ work: @escaping @Sendable () -> Value) async -> Value {
        await withCheckedContinuation { continuation in
            queue.async { continuation.resume(returning: work()) }
        }
    }

    // MARK: Launch

    private func launch(_ argument: ProviderValue?) async -> ResolutionResult {
        let request: ApplicationRequest
        switch parse(argument) {
        case .success(let parsed): request = parsed
        case .failure(let error): return .failure(ProviderFailure(kind: .invalidInput, message: error.message))
        }
        guard !Task.isCancelled else { return failed("Cancelled before the application was inspected.") }
        let native = native
        let selection = await onQueue { selectInstallation(request, native: native) }
        switch selection {
        case .dependency(let reason, let guidance): return .success(dependency(reason, guidance))
        case .failed(let message): return failed(message)
        case .selected(let url, let substituting):
            // Inspection was a read; from here on an effect may have begun.
            return await submit(url, substituting: substituting)
        }
    }

    private func submit(_ url: URL, substituting: Bool) async -> ResolutionResult {
        let native = native
        let acknowledgment = await submitOnce(
            { completion in
                native.launchApplication(at: url, substitutingRunningCopy: substituting, completion: completion)
            },
            limit: limit, bound: bound
        )
        switch acknowledgment {
        case .notSubmitted(let reason): return failed(reason)
        case .refused(let reason): return failed("The system did not launch or activate the application: \(reason)")
        case .timedOut:
            return failed(
                "The system did not acknowledge the launch within \(bound.components.seconds) seconds. "
                    + "It may still complete; the request was not repeated."
            )
        case .cancelled:
            return failed("Cancelled while waiting for the system to acknowledge the launch.")
        case .acknowledged(let application):
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

    private func failed(_ message: String) -> ResolutionResult {
        .failure(ProviderFailure(kind: .failed, message: message))
    }
}
