import Foundation
import Network

// Test material, never shipped: the positive control of scripts/vm-verify-network.sh.
// It makes outbound requests by the two stacks an application like Koine would use,
// URLSession (HTTP/3 where the server offers it) and Network.framework, and is compiled in
// the guest under the name `Koine`, so the capture's process attribution for a process of
// that name is seen to work for both before the real application is looked at.
let done = DispatchSemaphore(value: 0)
URLSession.shared.dataTask(with: URL(string: "https://example.com/")!) { _, response, error in
    print("URLSession:", (response as? HTTPURLResponse)?.statusCode ?? -1, error.map { "\($0)" } ?? "")
    done.signal()
}.resume()
_ = done.wait(timeout: .now() + 20)
let connection = NWConnection(host: "example.com", port: 443, using: .tcp)
let ready = DispatchSemaphore(value: 0)
connection.stateUpdateHandler = { state in
    if case .ready = state { print("NWConnection: ready"); ready.signal() }
    if case .failed(let e) = state { print("NWConnection failed", e); ready.signal() }
}
connection.start(queue: .global())
_ = ready.wait(timeout: .now() + 20)
connection.cancel()
