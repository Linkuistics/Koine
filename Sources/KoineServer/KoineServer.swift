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

    /// Every provider status, with the candidate fields the loader fills, as the
    /// selection tests read them ahead of management serving them.
    package var providerStatuses: [ProviderStatus] {
        get async { await engine.providerStatuses }
    }

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
    /// Providers are selected from `providerRoots` under the sealed
    /// `providerCatalogue` and composed into the schema here, once; nothing else
    /// is searched. One invocation discovers, stages, verifies and selects at
    /// most one candidate per reserved identity before any provider code loads
    /// (docs/specs/machine.md, "First-party provider selection"). A bundle that
    /// is refused is reported as provider status and contributes nothing; a root
    /// that cannot be read throws. A catalogue that is malformed or conflicts with
    /// itself admits no provider: the schema is the core alone, with one
    /// diagnostic. The default catalogue reserves `desktop` and designates no
    /// bundle, so no per-user bundle can take the desktop identity and an
    /// in-application root under it admits none. Verifying a
    /// signature blocks on work the Security framework dispatches: construct on
    /// the main thread or a thread of your own, not on many Swift concurrency
    /// threads at once. Each bundle is staged under `providerStaging`, by
    /// default `ProviderStaging` in the data directory, and loaded from there.
    ///
    /// `osPermissions` is the host's read of the OS permissions it owns, served
    /// as `koineManagement.osPermissions`. The server has no platform of its own.
    ///
    /// `now` is where the server reads the time for request expiry, retention
    /// and the enrollment rate limit. A host has no reason to pass it: it is a
    /// construction parameter so that tests can move time, and nothing a client
    /// or the environment supplies reaches it.
    public convenience init(
        dataDirectory: URL, policy: RequestPolicy = .version1, providerRoots: [ProviderRoot] = [],
        providerCatalogue: Result<ProviderCatalogue, ProviderCatalogue.Invalid> = .success(.reservingDesktop),
        providerStaging: URL? = nil, osPermissions: @escaping OSPermissionSource = { [] },
        now: @escaping TimeSource = { Date() }
    ) throws {
        try self.init(
            dataDirectory: dataDirectory, policy: policy, providerRoots: providerRoots,
            providerCatalogue: providerCatalogue, providerStaging: providerStaging,
            osPermissions: osPermissions, now: now, additionalProviders: [],
            loaderSeam: ProviderLoader.Seam()
        )
    }

    /// The per-user installed root, `Providers` in the data directory. Its
    /// approval records are files the user places there; see README.md.
    public static func installedProviderRoot(in dataDirectory: URL) -> ProviderRoot {
        .installed(dataDirectory.appendingPathComponent("Providers", isDirectory: true))
    }

    /// `additionalProviders` are composed with the loaded ones, and `loaderSeam`
    /// substitutes what a test controls while the real verifier and loader run.
    /// Both have package access: the package's tests and test hosts reach them;
    /// nothing public carries either.
    package init(
        dataDirectory: URL, policy: RequestPolicy, providerRoots: [ProviderRoot],
        providerCatalogue: Result<ProviderCatalogue, ProviderCatalogue.Invalid>,
        providerStaging: URL? = nil, osPermissions: @escaping OSPermissionSource = { [] },
        now: @escaping TimeSource = { Date() }, additionalProviders: [ActiveProvider],
        loaderSeam: ProviderLoader.Seam
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
        let host = HostCompatibility(features: koineHostFeatures)
        let staging =
            providerStaging
            ?? dataDirectory.appendingPathComponent("ProviderStaging", isDirectory: true)
        // One invocation over both roots and the sealed catalogue: the loader
        // owns discovery, staging, verification and selection, and returns a
        // report for every candidate and only the selected providers.
        let selection = try ProviderLoader.selectAndLoad(
            roots: providerRoots, catalogue: providerCatalogue, staging: staging, host: host,
            seam: loaderSeam
        )
        var unloaded: [ProviderStatus] = []
        for report in selection.reports {
            let state: ProviderStatus.State
            let diagnostic: String
            switch report.outcome {
            case .loaded: continue
            case .incompatible(let reason): (state, diagnostic) = (.incompatible, reason)
            case .rejected(let reason): (state, diagnostic) = (.rejected, reason)
            }
            // A frozen choice that fails while loading keeps the earlier refusals
            // that led to it in its diagnostic.
            let explained = report.note.map { "\(diagnostic) \($0)" } ?? diagnostic
            unloaded.append(
                ProviderStatus(
                    provider: report.provider, version: report.version,
                    schemaVersion: report.schemaVersion, state: state, diagnostic: explained,
                    candidateId: report.candidateId, origin: report.origin.map(Self.origin),
                    selection: Self.selection(report.selection),
                    selectedCandidateId: report.selectedCandidateId, reason: report.reason
                )
            )
        }
        // Published in canonical order: shipped identities by identifier, then
        // ordinary per-user ones. A shipped selection of either origin is the
        // identity's owner; physical origin decides no authority.
        let loaded: [ActiveProvider] = selection.publication.compactMap { report in
            guard case .loaded(let provider) = report.outcome, let candidateId = report.candidateId,
                let origin = report.origin
            else { return nil }
            return ActiveProvider(
                descriptor: provider.descriptor, provider: provider.provider,
                origin: report.isShipped ? .bundled : .external, version: report.version,
                schemaVersion: report.schemaVersion,
                candidate: ActiveProvider.Candidate(
                    candidateId: candidateId, origin: Self.origin(origin), reason: report.reason,
                    note: report.note
                )
            )
        }
        var reserved: [ReservedIdentity] = []
        if case .success(let catalogue) = providerCatalogue {
            reserved = catalogue.entries.map {
                ReservedIdentity(providerId: $0.providerId, graphQLPrefix: $0.graphQLPrefix)
            }
        }
        let engine = try Engine(
            store: store, instanceId: instanceId, policy: policy,
            providers: loaded + additionalProviders, unloadedProviders: unloaded,
            reservedIdentities: reserved, osPermissions: osPermissions, now: now
        )
        self.engine = engine
        console = LocalConsole(engine: engine)
    }

    private static func origin(_ origin: ProviderCandidateReport.Origin) -> ProviderStatus.Origin {
        switch origin {
        case .bundled: .bundled
        case .perUser: .perUser
        }
    }

    private static func selection(
        _ selection: ProviderCandidateReport.Selection
    ) -> ProviderStatus.Selection {
        switch selection {
        case .selected: .selected
        case .notSelected: .notSelected
        case .unavailable: .unavailable
        }
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
        var headers: [String: String] = [:]
        switch response.outcome {
        case .executed: status = 200
        // https://www.rfc-editor.org/rfc/rfc6585#section-4
        case .enrollmentRateLimited(let retryAfterSeconds):
            status = 429
            headers["Retry-After"] = String(retryAfterSeconds)
        case .invalidRequest: status = 400
        case .unauthenticated: return unauthorized
        case .forbidden: status = 403
        }
        let modern = "application/graphql-response+json"
        let accepted = (request.headers["accept"] ?? "").split(separator: ",")
            .map { mediaType(String($0)) }
        return HTTPResponse(
            status: status,
            headers: headers.merging(
                ["Content-Type": accepted.contains(modern) ? modern : "application/json"]
            ) { _, new in new },
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
