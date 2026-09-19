import Foundation
import KoineCore
import KoineProviderLoader
@testable import KoineServer

/// A running server over a throwaway data directory, plus the client's view of
/// it: everything a client knows comes from the published descriptor.
final class Harness {
    let directory: URL
    private(set) var server: KoineServer

    private var policy: RequestPolicy
    private let providerRoots: [ProviderRoot]
    private let providers: [ActiveProvider]
    private let osPermissions: OSPermissionSource
    private let clock: TestClock?

    /// One staging directory for the process. Every server here stages the same
    /// fixture to the same path, so dyld maps it once; per-server staging would
    /// load a second copy of its classes.
    static let providerStaging = FileManager.default.temporaryDirectory
        .appendingPathComponent("koine-test-staging-\(UUID().uuidString)", isDirectory: true)

    /// `providerRoots` are per-user installed roots, approval records included;
    /// `bundledRoots` are read before them.
    /// `seed` runs on the data directory before the server first opens it.
    /// `providers` are in-test contributions, composed with the loaded ones.
    /// `clock` is the server's time source; without one it reads the wall clock.
    init(
        policy: RequestPolicy = .version1, providerRoots: [URL] = [],
        bundledRoots: [ProviderRoot] = [], providers: [ActiveProvider] = [],
        seed: ((URL) throws -> Void)? = nil, osPermissions: @escaping OSPermissionSource = { [] },
        clock: TestClock? = nil
    ) async throws {
        self.osPermissions = osPermissions
        self.clock = clock
        self.providerRoots = bundledRoots + providerRoots.map(ProviderRoot.installed)
        self.providers = providers
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-tests-\(UUID().uuidString)", isDirectory: true)
        self.policy = policy
        if let seed {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try seed(directory)
        }
        server = try await Self.makeServer(directory, policy, self.providerRoots, providers, osPermissions, clock)
        try await server.start()
    }

    /// Off the cooperative pool, and one at a time: verifying a signature blocks
    /// on work the Security framework dispatches to the global queues, and a pool
    /// whose every thread is a test blocked there starves it. That holds for the
    /// global dispatch pool too, whose threads are bounded: enough suites
    /// constructing at once hung the run there. The application constructs once,
    /// on the main thread.
    private static let constructing = DispatchQueue(label: "dev.antony.Koine.tests.constructing")

    private static func makeServer(
        _ directory: URL, _ policy: RequestPolicy, _ roots: [ProviderRoot], _ providers: [ActiveProvider],
        _ osPermissions: @escaping OSPermissionSource, _ clock: TestClock?
    ) async throws -> KoineServer {
        let now: TimeSource
        if let clock { now = clock.source } else { now = { Date() } }
        return try await withCheckedThrowingContinuation { continuation in
            constructing.async {
                continuation.resume(
                    with: Result {
                        try KoineServer(
                            dataDirectory: directory, policy: policy,
                            providerRoots: roots,
                            providerStaging: providerStaging, osPermissions: osPermissions,
                            now: now, additionalProviders: providers
                        )
                    }
                )
            }
        }
    }

    deinit { try? FileManager.default.removeItem(at: directory) }

    func restart(policy: RequestPolicy? = nil) async throws {
        if let policy { self.policy = policy }
        await server.stop()
        server = try await Self.makeServer(directory, self.policy, providerRoots, providers, osPermissions, clock)
        try await server.start()
    }

    func stop() async { await server.stop() }

    var descriptorURL: URL { directory.appendingPathComponent("endpoint.json") }

    func descriptor() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: Data(contentsOf: descriptorURL)) as! [String: Any]
    }

    /// Bootstraps a grant through the in-process console and returns its credential.
    func consoleGrant(label: String, capabilities: [String]) async throws -> String {
        let body = try Self.requestBody(
            Self.createGrant, variables: ["label": label, "capabilities": capabilities]
        )
        let response = try JSONSerialization.jsonObject(
            with: try await server.console.execute(jsonBody: body)
        ) as! [String: Any]
        let created = (response["data"] as! [String: Any])["koineCreateGrant"] as! [String: Any]
        return created["credential"] as! String
    }

    struct Reply {
        let status: Int
        let headers: [AnyHashable: Any]
        let json: [String: Any]

        var data: [String: Any]? { json["data"] as? [String: Any] }
        var errors: [[String: Any]] { json["errors"] as? [[String: Any]] ?? [] }
    }

    /// POSTs to the endpoint the descriptor names, as a client would.
    func post(
        _ query: String, variables: [String: Any] = [:], authorization: String?,
        host: String = "127.0.0.1"
    ) async throws -> Reply {
        let descriptor = try descriptor()
        let url = URL(string: "http://\(host):\(descriptor["port"]!)\(descriptor["path"]!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try Self.requestBody(query, variables: variables)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/graphql-response+json", forHTTPHeaderField: "Accept")
        if let authorization {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)
        let http = response as! HTTPURLResponse
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
        return Reply(status: http.statusCode, headers: http.allHeaderFields, json: json)
    }

    static func requestBody(_ query: String, variables: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: ["query": query, "variables": variables])
    }

    static let createGrant = """
        mutation Create($label: String!, $capabilities: [String!]!) {
          koineCreateGrant(input: { clientLabel: $label, capabilities: $capabilities }) {
            credential
            grant { grantId clientLabel capabilities state }
          }
        }
        """

    static let koine = """
        { koine { contractVersion instanceId schemaDigest availableCapabilities
                  ownGrant { grantId clientLabel capabilities state } } }
        """

    /// graphql-js `getIntrospectionQuery()` with descriptions, the query
    /// standard code generators send.
    static let introspection = """
        query IntrospectionQuery {
          __schema {
            description
            queryType { name } mutationType { name } subscriptionType { name }
            types { ...FullType }
            directives { name description locations args { ...InputValue } }
          }
        }
        fragment FullType on __Type {
          kind name description
          fields(includeDeprecated: true) {
            name description args { ...InputValue } type { ...TypeRef }
            isDeprecated deprecationReason
          }
          inputFields { ...InputValue }
          interfaces { ...TypeRef }
          enumValues(includeDeprecated: true) { name description isDeprecated deprecationReason }
          possibleTypes { ...TypeRef }
        }
        fragment InputValue on __InputValue {
          name description type { ...TypeRef } defaultValue
        }
        fragment TypeRef on __Type {
          kind name ofType { kind name ofType { kind name ofType { kind name ofType {
            kind name ofType { kind name ofType { kind name ofType { kind name } } } } } } }
        }
        """
}

/// The time a test gives the server. It moves only when the test moves it.
final class TestClock: @unchecked Sendable {
    private let lock = NSLock()
    private var instant = Date(timeIntervalSince1970: 1_800_000_000)

    var now: Date { lock.withLock { instant } }
    var source: TimeSource {
        let read: TimeSource = { self.now }
        return read
    }

    func advance(by interval: TimeInterval) { lock.withLock { instant += interval } }
}

// MARK: Raw HTTP

/// One HTTP response as it came off the socket. Header names are lower-cased.
struct RawResponse: Sendable {
    let status: Int
    let headers: [String: String]
    let body: Data

    var json: [String: Any] {
        (try? JSONSerialization.jsonObject(with: body)) as? [String: Any] ?? [:]
    }
    var errors: [[String: Any]] { json["errors"] as? [[String: Any]] ?? [] }
    var hasData: Bool { json.keys.contains("data") }
}

/// A plain TCP connection to the loopback endpoint. The transport rules are
/// about exact request bytes — Host, Origin, method, framing, connection reuse —
/// which URLSession rewrites or forbids, so these tests write them by hand.
final class RawConnection: @unchecked Sendable {
    private let socket: Int32
    private var buffer = Data()

    init(port: Int) throws {
        socket = Darwin.socket(AF_INET, SOCK_STREAM, 0)
        var timeout = timeval(tv_sec: 20, tv_usec: 0)
        setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        var noSigPipe: Int32 = 1
        setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &noSigPipe, socklen_t(MemoryLayout<Int32>.size))
        var address = sockaddr_in()
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = in_port_t(port).bigEndian
        address.sin_addr.s_addr = inet_addr("127.0.0.1")
        let connected = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(socket, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard connected == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
    }

    deinit { close(socket) }

    /// Writes as much as the peer will take; a server that has already answered
    /// and closed is not an error here.
    func send(_ data: Data) {
        data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let written = Darwin.send(socket, bytes.baseAddress! + offset, bytes.count - offset, 0)
                guard written > 0 else { return }
                offset += written
            }
        }
    }

    func readResponse() throws -> RawResponse {
        let separator = Data("\r\n\r\n".utf8)
        while buffer.range(of: separator) == nil { try fill() }
        let headerEnd = buffer.range(of: separator)!
        let lines = String(decoding: buffer[..<headerEnd.lowerBound], as: UTF8.self)
            .components(separatedBy: "\r\n")
        var headers: [String: String] = [:]
        for line in lines.dropFirst() {
            guard let colon = line.firstIndex(of: ":") else { continue }
            headers[line[..<colon].lowercased()] =
                line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        }
        let length = Int(headers["content-length"] ?? "") ?? 0
        buffer.removeSubrange(..<headerEnd.upperBound)
        while buffer.count < length { try fill() }
        let body = Data(buffer.prefix(length))
        buffer.removeSubrange(..<(buffer.startIndex + length))
        return RawResponse(
            status: Int(lines[0].split(separator: " ")[1]) ?? 0, headers: headers, body: body
        )
    }

    private func fill() throws {
        var chunk = [UInt8](repeating: 0, count: 65_536)
        let count = recv(socket, &chunk, chunk.count, 0)
        guard count > 0 else { throw POSIXError(count == 0 ? .ECONNRESET : .ETIMEDOUT) }
        buffer.append(contentsOf: chunk[..<count])
    }
}

extension Harness {
    var port: Int { (try? descriptor()["port"] as? Int) ?? 0 }

    /// The bytes of one request. `headers` overrides the well-formed defaults;
    /// a nil value removes that header.
    func requestBytes(
        method: String = "POST", target: String = "/graphql", version: String = "HTTP/1.1",
        headers overrides: [String: String?] = [:], body: Data
    ) -> Data {
        var headers: [String: String] = [
            "Host": "127.0.0.1:\(port)",
            "Content-Type": "application/json",
            "Content-Length": String(body.count),
        ]
        for (name, value) in overrides { headers[name] = value }
        var head = "\(method) \(target) \(version)\r\n"
        for (name, value) in headers.sorted(by: { $0.key < $1.key }) {
            head += "\(name): \(value)\r\n"
        }
        return Data((head + "\r\n").utf8) + body
    }

    /// One request on its own connection.
    func raw(
        _ query: String = Harness.koine, variables: [String: Any] = [:], bearer: String?,
        method: String = "POST", target: String = "/graphql", version: String = "HTTP/1.1",
        headers: [String: String?] = [:], body: Data? = nil
    ) async throws -> RawResponse {
        var headers = headers
        if let bearer, headers["Authorization"] == nil {
            headers["Authorization"] = "Bearer \(bearer)"
        }
        let port = port
        let request = requestBytes(
            method: method, target: target, version: version, headers: headers,
            body: try body ?? Self.requestBody(query, variables: variables)
        )
        return try await offPool {
            let connection = try RawConnection(port: port)
            connection.send(request)
            return try connection.readResponse()
        }
    }
}

/// Runs blocking socket I/O on a dispatch thread. The server under test shares
/// this process's cooperative pool; blocking that pool would starve it.
func offPool<T: Sendable>(_ work: @escaping @Sendable () throws -> T) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global().async { continuation.resume(with: Result(catching: work)) }
    }
}
