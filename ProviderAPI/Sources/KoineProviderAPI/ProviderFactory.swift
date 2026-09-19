/// The principal class of a provider bundle. The plugin supplies an
/// NSObject-derived class with an explicit Objective-C name; the host finds it
/// by that name and requires this conformance. Constructing the factory,
/// reading its descriptor and making the provider perform no client action.
public protocol ProviderFactory: AnyObject {
    init()
    var descriptor: ProviderDescriptor { get }
    func makeProvider() -> any Provider
}

/// One provider instance, held by the host for its active lifetime. `start` and
/// `stop` are serialized by the host; `resolve` calls may overlap once `start`
/// has returned. The host calls `resolve` only for a field it has authorized.
public protocol Provider: AnyObject, Sendable {
    func start() async throws
    func resolve(_ request: ResolutionRequest) async -> ResolutionResult
    func stop() async
}
