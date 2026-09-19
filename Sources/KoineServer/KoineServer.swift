import Foundation
import KoineCore
import KoineHTTP
import KoineProviderLoader
import KoineSQLiteStore

public enum KoineServerError: Error, Equatable {
    /// Another Koine instance holds this data directory's instance lock.
    case alreadyRunning
    /// `start()` was called on a server that has started or stopped. A server
    /// object is one run; a new run is a new object with a new `instanceId`.
    case alreadyStarted
}

/// The embeddable Koine server. The resident application and the tests embed it
/// the same way: construct it over a data directory, start it, and use
/// `console` for in-process management.
public final class KoineServer: Sendable {
    /// `~/Library/Application Support/Koine`, the location the contract names.
    public static var userDataDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Koine", isDirectory: true)
    }

    public let instanceId = UUID().uuidString.lowercased()
    public let console: LocalConsole

    /// Refusals and provider defects, until management serves provider status.
    var providerDiagnostics: [ProviderDiagnostic] { engine.providerDiagnostics }

    private let dataDirectory: URL
    private let engine: Engine
    private let policy: RequestPolicy
    private let instanceLock: InstanceLock
    private let run = Run()

    /// Takes the data directory's instance lock, then opens the grant store in
    /// it, creating the directory user-only (0700). Throws `alreadyRunning`
    /// when another instance holds the lock. A store that cannot be opened
    /// throws; the server does not start over a replacement.
    ///
    /// Providers are loaded from `providerRoots` and composed into the schema
    /// here, once; nothing else is searched. A bundle that is refused is
    /// reported as provider status and contributes nothing; a root that cannot
    /// be read throws. Verifying a signature blocks on work the Security
    /// framework dispatches: construct on the main thread or a thread of your
    /// own, not on many Swift concurrency threads at once. Each bundle is staged under `providerStaging`, by
    /// default `ProviderStaging` in the data directory, and loaded from there.
    ///
    /// `osPermissions` is the host's read of the OS permissions it owns, served
    /// as `koineManagement.osPermissions`. The server has no platform of its own.
    public convenience init(
        dataDirectory: URL, policy: RequestPolicy = .version1, providerRoots: [ProviderRoot] = [],
        providerStaging: URL? = nil, osPermissions: @escaping OSPermissionSource = { [] }
    ) throws {
        try self.init(
            dataDirectory: dataDirectory, policy: policy, providerRoots: providerRoots,
            providerStaging: providerStaging, osPermissions: osPermissions, additionalProviders: []
        )
    }

    /// The per-user installed root, `Providers` in the data directory. Its
    /// approval records are files the user places there; see README.md.
    public static func installedProviderRoot(in dataDirectory: URL) -> ProviderRoot {
        .installed(dataDirectory.appendingPathComponent("Providers", isDirectory: true))
    }

    /// `additionalProviders` are composed with the loaded ones. It is internal:
    /// tests reach it with `@testable` to contribute a descriptor without a
    /// bundle; nothing public carries it.
    init(
        dataDirectory: URL, policy: RequestPolicy, providerRoots: [ProviderRoot],
        providerStaging: URL? = nil, osPermissions: @escaping OSPermissionSource = { [] },
        additionalProviders: [ActiveProvider]
    ) throws {
        self.dataDirectory = dataDirectory
        self.policy = policy
        try FileManager.default.createDirectory(
            at: dataDirectory, withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o700], ofItemAtPath: dataDirectory.path
        )
        instanceLock = try InstanceLock(in: dataDirectory)
        // Under the lock, a descriptor already here was left by a dead
        // instance. It is replaced, never consulted.
        EndpointDescriptor.removeStale(in: dataDirectory)
        let store = try SQLiteGrantStore(
            path: dataDirectory.appendingPathComponent("grants.sqlite").path
        )
        var loaded: [ActiveProvider] = []
        var unloaded: [ProviderStatus] = []
        let host = HostCompatibility(features: koineHostFeatures)
        let staging =
            providerStaging
            ?? dataDirectory.appendingPathComponent("ProviderStaging", isDirectory: true)
        // A provider's origin is its root's: only the in-application root may
        // supply the identifiers reserved to Koine's own providers.
        let reports = try providerRoots.flatMap { root in
            try ProviderLoader.loadProviders(in: root, staging: staging, host: host)
                .map { (report: $0, origin: root.isBundled ? ActiveProvider.Origin.bundled : .external) }
        }
        for (report, origin) in reports {
            let state: ProviderStatus.State
            let diagnostic: String
            switch report.outcome {
            case .loaded(let provider):
                loaded.append(
                    ActiveProvider(
                        descriptor: provider.descriptor, provider: provider.provider,
                        origin: origin, version: report.version, schemaVersion: report.schemaVersion
                    )
                )
                continue
            case .incompatible(let reason): (state, diagnostic) = (.incompatible, reason)
            case .rejected(let reason): (state, diagnostic) = (.rejected, reason)
            }
            unloaded.append(
                ProviderStatus(
                    provider: report.provider, version: report.version,
                    schemaVersion: report.schemaVersion, state: state, diagnostic: diagnostic
                )
            )
        }
        let engine = try Engine(
            store: store, instanceId: instanceId, policy: policy,
            providers: loaded + additionalProviders, unloadedProviders: unloaded,
            osPermissions: osPermissions
        )
        self.engine = engine
        console = LocalConsole(engine: engine)
    }

    /// Binds loopback and, once the listener is ready, publishes the descriptor.
    /// Returns the bound port.
    @discardableResult
    public func start() async throws -> Int {
        let engine = engine
        try await run.begin()
        await engine.startProviders()
        let bound = try await LoopbackListener(maximumBodyBytes: policy.maximumBodyBytes) {
            request in await Self.respond(to: request, engine: engine)
        }
        await run.set(bound)
        try EndpointDescriptor(
            instanceId: instanceId, pid: ProcessInfo.processInfo.processIdentifier,
            port: bound.port, contractVersion: koineContractVersion
        ).publish(in: dataDirectory)
        return bound.port
    }

    /// Withdraws this instance's own descriptor, stops listening and releases
    /// the instance lock. A descriptor some other instance published is left.
    public func stop() async {
        EndpointDescriptor.remove(publishedBy: instanceId, in: dataDirectory)
        // Providers first: the listener waits for requests in flight, and a
        // request in flight may be waiting on a provider that finishes only
        // when stop requests its cancellation.
        await engine.stopProviders()
        await run.take()?.stop()
        instanceLock.release()
    }

    // MARK: HTTP

    /// Authenticates, then executes. The only principals this path can produce
    /// come from a presented bearer credential, or from presenting none;
    /// nothing here names the console.
    ///
    /// The transport rules run first and in this order, so a request a website
    /// could cause is refused before its credential is even looked at.
    private static func respond(to request: HTTPRequest, engine: Engine) async -> HTTPResponse {
        // Browsers attach Origin to every cross-origin request and to every
        // POST; native clients have no reason to. `Origin: null` is a value.
        guard request.headers["origin"] == nil else { return HTTPResponse(status: 403) }
        // A rebinding website reaches this socket under its own host name.
        guard request.headers["host"] == request.boundAuthority else {
            return HTTPResponse(status: 421)
        }
        // The whole target: a query string is not part of the endpoint.
        guard request.path == "/graphql" else { return HTTPResponse(status: 404) }
        guard request.method == "POST" else {
            return HTTPResponse(status: 405, headers: ["Allow": "POST"])
        }
        guard mediaType(request.headers["content-type"]) == "application/json" else {
            return HTTPResponse(status: 415)
        }
        // No Authorization header at all is the anonymous principal, which the
        // engine admits for enrollment alone. A header that does not name a
        // live credential is refused here: it is never retried as anonymous.
        let unauthorized = HTTPResponse(status: 401, headers: ["WWW-Authenticate": "Bearer"])
        let bearerPrefix = "Bearer "
        let principal: Principal
        if let authorization = request.headers["authorization"] {
            guard authorization.hasPrefix(bearerPrefix),
                let presented = engine.authenticate(
                    bearer: String(authorization.dropFirst(bearerPrefix.count))
                )
            else { return unauthorized }
            principal = presented
        } else {
            principal = .anonymous
        }
        // One JSON object per POST; a batch array does not decode.
        guard let graphQLRequest = try? EngineRequest(jsonBody: Data(request.body)) else {
            if case .anonymous = principal { return unauthorized }
            return HTTPResponse(status: 400)
        }

        let response = await engine.execute(graphQLRequest, as: principal)
        let status: Int
        switch response.outcome {
        case .executed: status = 200
        case .invalidRequest: status = 400
        case .unauthenticated: return unauthorized
        case .forbidden: status = 403
        }
        let modern = "application/graphql-response+json"
        let accepted = (request.headers["accept"] ?? "").split(separator: ",")
            .map { mediaType(String($0)) }
        return HTTPResponse(
            status: status,
            headers: ["Content-Type": accepted.contains(modern) ? modern : "application/json"],
            body: [UInt8](response.body)
        )
    }

    /// The `type/subtype` of a media-type header value, without parameters.
    private static func mediaType(_ value: String?) -> String? {
        value?.split(separator: ";").first?.trimmingCharacters(in: .whitespaces).lowercased()
    }
}

/// The in-process management console principal. It runs operations through the
/// same engine, authorization and store as HTTP callers. It exists only as this
/// object: no token, header, URL or resolver produces it.
public struct LocalConsole: Sendable {
    let engine: Engine

    /// Executes a `{"query", "variables", "operationName"}` JSON request and
    /// returns the GraphQL JSON response.
    public func execute(jsonBody: Data) async throws -> Data {
        await engine.execute(try EngineRequest(jsonBody: jsonBody), as: .localConsole).body
    }
}

private actor Run {
    private var begun = false
    private var listener: LoopbackListener?

    func begin() throws {
        guard !begun else { throw KoineServerError.alreadyStarted }
        begun = true
    }

    func set(_ new: LoopbackListener) { listener = new }

    func take() -> LoopbackListener? {
        begun = true
        defer { listener = nil }
        return listener
    }
}
