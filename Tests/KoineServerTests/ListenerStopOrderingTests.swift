import Foundation
import Testing

@testable import KoineHTTP

/// One-shot latch a test opens from another task; waiters suspend until it is.
private actor Latch {
    private var opened = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        if opened { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func open() {
        opened = true
        for waiter in waiters { waiter.resume() }
        waiters = []
    }
}

/// The listener's contract: "A request already received is answered first, on a
/// connection that then closes." The orders are forced at the listener's two
/// ordering points rather than sampled, as `RevocationOrderingTests` does for
/// the grant paths.
@Suite struct ListenerStopOrderingTests {
    private static let request = Data(
        "POST /graphql HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Length: 2\r\n\r\n{}".utf8
    )

    @Test func aResponseReadyWhenStopClosesIdleConnectionsIsStillWritten() async throws {
        let ready = Latch()
        let idleClosed = Latch()
        let listener = try await LoopbackListener(
            maximumBodyBytes: 1024,
            handler: { _ in HTTPResponse(status: 200, body: Array("held".utf8)) }
        ) { point in
            switch point {
            case .responseReady:
                // The handler has answered; stop begins and closes what is idle
                // before this response is written.
                await ready.open()
                await idleClosed.wait()
            case .idleClosed:
                await idleClosed.open()
            }
        }
        let port = listener.port
        let reply = Task {
            try await offPool {
                let connection = try RawConnection(port: port)
                connection.send(Self.request)
                return try connection.readResponse()
            }
        }
        await ready.wait()
        await listener.stop()

        let answered = try await reply.value
        #expect(answered.status == 200)
        #expect(String(decoding: answered.body, as: UTF8.self) == "held")
        // The response was the connection's last.
        #expect(answered.headers["connection"] == "close")
    }

    @Test func aRequestInHandWhenStopBeginsIsAnsweredOnAConnectionThatThenCloses() async throws {
        let inHandler = Latch()
        let release = Latch()
        let listener = try await LoopbackListener(
            maximumBodyBytes: 1024,
            handler: { _ in
                await inHandler.open()
                await release.wait()
                return HTTPResponse(status: 200, body: Array("held".utf8))
            }
        ) { point in
            // Stop has closed the idle connections; only now may the handler finish.
            if point == .idleClosed { await release.open() }
        }
        let port = listener.port
        let reply = Task {
            try await offPool {
                let connection = try RawConnection(port: port)
                connection.send(Self.request)
                return try connection.readResponse()
            }
        }
        await inHandler.wait()
        await listener.stop()

        let answered = try await reply.value
        #expect(answered.status == 200)
        #expect(answered.headers["connection"] == "close")
    }
}
