import Foundation
import KoineProviderAPI

/// One provider instance's active lifetime, as the host keeps it
/// (docs/specs/machine.md, "Native extensions"). Start and stop are serialized;
/// resolves overlap once start has succeeded; stop admits no new resolution,
/// requests cancellation and waits for outstanding work.
///
/// An actor is reentrant at every suspension, so nothing here is held across
/// provider code: a resolve suspended in the provider blocks no other call.
actor ProviderLifecycle {
    private enum State {
        case idle
        case started
        case failed(String)
        case stopped
    }

    private let providerId: String
    private let provider: any Provider
    private var state = State.idle
    /// The latest start or stop; the next one waits for it.
    private var transition: Task<Void, Never>?
    private var outstanding: [UUID: Task<ResolutionResult, Never>] = [:]

    init(providerId: String, provider: any Provider) {
        self.providerId = providerId
        self.provider = provider
    }

    /// Why start failed, when it did.
    var failure: String? {
        if case .failed(let reason) = state { reason } else { nil }
    }

    func start() async {
        await serialized { await self.performStart() }
    }

    func stop() async {
        await serialized { await self.performStop() }
    }

    private func performStart() async {
        guard case .idle = state else { return }
        do {
            try await provider.start()
            state = .started
        } catch {
            state = .failed("The provider failed to start: \(error)")
        }
    }

    private func performStop() async {
        guard case .started = state else { return }
        // From here no resolution is admitted.
        state = .stopped
        let tasks = Array(outstanding.values)
        for task in tasks { task.cancel() }
        for task in tasks { _ = await task.value }
        await provider.stop()
    }

    /// A provider that is not running has nothing to resolve with.
    func resolve(_ request: ResolutionRequest) async -> ResolutionResult {
        guard case .started = state else {
            return .failure(
                ProviderFailure(
                    kind: .unavailable, message: "The \(providerId) provider is not running."
                )
            )
        }
        let provider = provider
        let id = UUID()
        // Its own task, so stop can request its cancellation and wait for it.
        let task = Task { await provider.resolve(request) }
        outstanding[id] = task
        let result = await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
        outstanding[id] = nil
        return result
    }

    private func serialized(_ operation: @escaping @Sendable () async -> Void) async {
        let previous = transition
        let next = Task {
            await previous?.value
            await operation()
        }
        transition = next
        await next.value
    }
}
