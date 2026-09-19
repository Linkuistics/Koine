import NIOConcurrencyHelpers
import NIOCore
import NIOHTTP1
import NIOPosix

public struct HTTPRequest: Sendable {
    public let method: String
    public let path: String
    /// Header names are lower-cased; the first value wins.
    public let headers: [String: String]
    public let body: [UInt8]
    /// The literal `address:port` this listener is bound to, which is what a
    /// legitimate client's `Host` header carries.
    public let boundAuthority: String
}

public struct HTTPResponse: Sendable {
    public var status: Int
    public var headers: [String: String]
    public var body: [UInt8]

    public init(status: Int, headers: [String: String] = [:], body: [UInt8] = []) {
        self.status = status
        self.headers = headers
        self.body = body
    }
}

/// An HTTP/1.1 listener bound to IPv4 loopback on an OS-assigned port. It knows
/// nothing of GraphQL: each complete request goes to `handler`.
public final class LoopbackListener: Sendable {
    public typealias Handler = @Sendable (HTTPRequest) async -> HTTPResponse
    typealias Connection = NIOAsyncChannel<HTTPServerRequestPart, HTTPPart<HTTPResponseHead, ByteBuffer>>

    public static let host = "127.0.0.1"
    public let port: Int
    private let serverChannel: NIOAsyncChannel<Connection, Never>
    private let acceptLoop: Task<Void, Never>
    private let connections = Connections()

    /// Binds and starts accepting. The listener is ready when this returns. A
    /// request whose body exceeds `maximumBodyBytes` is answered 413 and its
    /// connection closed; it never reaches `handler`.
    public init(maximumBodyBytes: Int, handler: @escaping Handler) async throws {
        // Async bootstrap as in swift-nio's Sources/NIOWebSocketServer/Server.swift:
        // https://github.com/apple/swift-nio/blob/2.103.0/Sources/NIOWebSocketServer/Server.swift
        let channel = try await ServerBootstrap(group: MultiThreadedEventLoopGroup.singleton)
            .bind(host: Self.host, port: 0) { channel in
                channel.eventLoop.makeCompletedFuture {
                    try channel.pipeline.syncOperations.configureHTTPServerPipeline()
                    try channel.pipeline.syncOperations.addHandler(ByteBufferResponseHandler())
                    return try Connection(wrappingChannelSynchronously: channel)
                }
            }
        guard let port = channel.channel.localAddress?.port else {
            throw IOError(errnoCode: EADDRNOTAVAIL, reason: "listener has no local port")
        }
        self.port = port
        serverChannel = channel
        acceptLoop = Task { [connections] in
            try? await channel.executeThenClose { accepted in
                for try await connection in accepted {
                    connections.serve(connection.channel) { id in
                        try? await Self.serve(
                            connection, id: id, in: connections, authority: "\(Self.host):\(port)",
                            maximumBodyBytes: maximumBodyBytes, handler: handler
                        )
                    }
                }
            }
        }
    }

    /// Stops accepting and closes the listening socket. A request already
    /// received is answered first, on a connection that then closes; a
    /// connection between requests is closed at once.
    public func stop() async {
        try? await serverChannel.channel.close()
        await acceptLoop.value
        await connections.drain()
    }

    private static func serve(
        _ connection: Connection, id: Int, in connections: Connections, authority: String,
        maximumBodyBytes: Int, handler: @escaping Handler
    ) async throws {
        try await connection.executeThenClose { inbound, outbound in
            var head: HTTPRequestHead?
            var body: [UInt8] = []
            for try await part in inbound {
                switch part {
                case .head(let requestHead):
                    head = requestHead
                    body = []
                    let declared = requestHead.headers.first(name: "Content-Length").flatMap(Int.init)
                    if let declared, declared > maximumBodyBytes {
                        try await write(
                            HTTPResponse(status: 413), keepAlive: false, to: outbound
                        )
                        return
                    }
                case .body(var buffer):
                    body += buffer.readBytes(length: buffer.readableBytes) ?? []
                    if body.count > maximumBodyBytes {
                        try await write(
                            HTTPResponse(status: 413), keepAlive: false, to: outbound
                        )
                        return
                    }
                case .end:
                    guard let requestHead = head, connections.beginRequest(id) else { return }
                    head = nil
                    var headers: [String: String] = [:]
                    for (name, value) in requestHead.headers where headers[name.lowercased()] == nil {
                        headers[name.lowercased()] = value
                    }
                    let response = await handler(
                        HTTPRequest(
                            method: requestHead.method.rawValue, path: requestHead.uri,
                            headers: headers, body: body, boundAuthority: authority
                        )
                    )
                    let keepAlive = connections.endRequest(id) && requestHead.isKeepAlive
                    try await write(response, keepAlive: keepAlive, to: outbound)
                    if !keepAlive { return }
                }
            }
        }
    }

    private static func write(
        _ response: HTTPResponse, keepAlive: Bool,
        to outbound: NIOAsyncChannelOutboundWriter<HTTPPart<HTTPResponseHead, ByteBuffer>>
    ) async throws {
        var headers = HTTPHeaders(response.headers.map { ($0.key, $0.value) })
        headers.replaceOrAdd(name: "Content-Length", value: String(response.body.count))
        // No response of a local native-control endpoint is cacheable.
        headers.replaceOrAdd(name: "Cache-Control", value: "no-store")
        headers.replaceOrAdd(name: "Connection", value: keepAlive ? "keep-alive" : "close")
        let head = HTTPResponseHead(
            version: .http1_1, status: .init(statusCode: response.status), headers: headers
        )
        try await outbound.write(contentsOf: [
            .head(head), .body(ByteBuffer(bytes: response.body)), .end(nil),
        ])
    }
}

/// The connections being served, so that `stop()` has something to wait for.
/// Each is an unstructured task: a task group would keep every finished
/// connection's result for the listener's life (a discarding group needs macOS 14).
private final class Connections: Sendable {
    private struct State {
        var stopping = false
        var nextId = 0
        var open: [Int: (channel: any Channel, task: Task<Void, Never>, busy: Bool)] = [:]
    }

    private let state = NIOLockedValueBox(State())

    /// Runs `work` for a new connection, or closes it if stop has begun.
    func serve(_ channel: any Channel, _ work: @escaping @Sendable (Int) async -> Void) {
        let accepted = state.withLockedValue { state -> Bool in
            guard !state.stopping else { return false }
            let id = state.nextId
            state.nextId += 1
            // Registered under the lock the task's own removal takes, so the
            // removal cannot come first.
            let task = Task {
                await work(id)
                self.state.withLockedValue { $0.open[id] = nil }
            }
            state.open[id] = (channel, task, false)
            return true
        }
        if !accepted { channel.close(promise: nil) }
    }

    /// False once stop has begun: the request is not handled.
    func beginRequest(_ id: Int) -> Bool {
        state.withLockedValue { state in
            guard !state.stopping else { return false }
            state.open[id]?.busy = true
            return true
        }
    }

    /// False once stop has begun: the response is the connection's last.
    func endRequest(_ id: Int) -> Bool {
        state.withLockedValue { state in
            state.open[id]?.busy = false
            return !state.stopping
        }
    }

    /// Closes every connection with no request in hand and waits for the rest
    /// to write their responses.
    func drain() async {
        let open = state.withLockedValue { state in
            state.stopping = true
            return Array(state.open.values)
        }
        for connection in open where !connection.busy { connection.channel.close(promise: nil) }
        for connection in open { await connection.task.value }
    }
}

/// Adapts ByteBuffer response bodies to the HTTP encoder's IOData parts.
private final class ByteBufferResponseHandler: ChannelOutboundHandler {
    typealias OutboundIn = HTTPPart<HTTPResponseHead, ByteBuffer>
    typealias OutboundOut = HTTPServerResponsePart

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        switch Self.unwrapOutboundIn(data) {
        case .head(let head): context.write(Self.wrapOutboundOut(.head(head)), promise: promise)
        case .body(let buffer):
            context.write(Self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: promise)
        case .end(let trailers):
            context.write(Self.wrapOutboundOut(.end(trailers)), promise: promise)
        }
    }
}
