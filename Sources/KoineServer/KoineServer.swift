import Foundation
import KoineCore
import KoineHTTP
import KoineSQLiteStore

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

    private let dataDirectory: URL
    private let engine: Engine
    private let listener = ListenerBox()

    /// Opens the grant store in `dataDirectory`, creating the directory
    /// user-only (0700). A store that cannot be opened throws; the server does
    /// not start over a replacement.
    public init(dataDirectory: URL) throws {
        self.dataDirectory = dataDirectory
        try FileManager.default.createDirectory(
            at: dataDirectory, withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o700], ofItemAtPath: dataDirectory.path
        )
        let store = try SQLiteGrantStore(
            path: dataDirectory.appendingPathComponent("grants.sqlite").path
        )
        engine = try Engine(store: store, instanceId: instanceId)
        console = LocalConsole(engine: engine)
    }

    /// Binds loopback and, once the listener is ready, publishes the descriptor.
    /// Returns the bound port.
    @discardableResult
    public func start() async throws -> Int {
        let engine = engine
        let bound = try await LoopbackListener { request in
            await Self.respond(to: request, engine: engine)
        }
        await listener.set(bound)
        try EndpointDescriptor(
            instanceId: instanceId, pid: ProcessInfo.processInfo.processIdentifier,
            port: bound.port, contractVersion: koineContractVersion
        ).publish(in: dataDirectory)
        return bound.port
    }

    public func stop() async {
        await listener.take()?.stop()
    }

    // MARK: HTTP

    /// Authenticates, then executes. The only principals this path can produce
    /// come from a presented bearer credential; nothing here names the console.
    private static func respond(to request: HTTPRequest, engine: Engine) async -> HTTPResponse {
        guard request.path == "/graphql" else { return HTTPResponse(status: 404) }
        guard request.method == "POST" else {
            return HTTPResponse(status: 405, headers: ["Allow": "POST"])
        }
        let bearerPrefix = "Bearer "
        guard let authorization = request.headers["authorization"],
            authorization.hasPrefix(bearerPrefix),
            let principal = engine.authenticate(
                bearer: String(authorization.dropFirst(bearerPrefix.count))
            )
        else {
            return HTTPResponse(status: 401, headers: ["WWW-Authenticate": "Bearer"])
        }
        guard let graphQLRequest = try? EngineRequest(jsonBody: Data(request.body)) else {
            return HTTPResponse(status: 400)
        }

        let response = await engine.execute(graphQLRequest, as: principal)
        let status: Int
        switch response.outcome {
        case .executed: status = 200
        case .invalidRequest: status = 400
        case .unauthenticated: status = 401
        case .forbidden: status = 403
        }
        let modern = "application/graphql-response+json"
        let accepted = request.headers["accept"] ?? ""
        return HTTPResponse(
            status: status,
            headers: [
                "Content-Type": accepted.contains(modern) ? modern : "application/json",
                "Cache-Control": "no-store",
            ],
            body: [UInt8](response.body)
        )
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

private actor ListenerBox {
    private var listener: LoopbackListener?
    func set(_ new: LoopbackListener) { listener = new }
    func take() -> LoopbackListener? {
        defer { listener = nil }
        return listener
    }
}
