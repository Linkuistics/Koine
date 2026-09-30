import Foundation
import KoineProviderLoader
import KoineServer
import MachO

// Test material for the binary compatibility pairs (docs/verification/
// binary-compatibility.md): a headless host that runs alone, so an old host can
// be kept while a plugin is upgraded. It embeds the server as the resident
// application does, over the given data directory and that directory's per-user
// provider root, and adds no API: a driver reaches it as any client does, over
// loopback HTTP with a grant.
//
// usage: KoineCompatibilityHost <data directory> [<in-application root>]
//
// The second argument stands in for `Contents/PlugIns`: a directory of bundles,
// each approved by the `<providerId>.approval.json` beside it, that load as the
// bundled provider the identifier `desktop` is reserved to. A host of an earlier
// release takes the data directory alone.
//
// Prints one JSON line when ready (port, a credential holding every available
// capability, and the KoineProviderAPI images mapped into this process), serves
// until standard input ends, then stops and prints how long stopping took.

func emit(_ object: [String: Any]) {
    let data = try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    FileHandle.standardOutput.write(data + Data("\n".utf8))
}

func console(_ server: KoineServer, _ query: String, _ variables: [String: Any] = [:]) async throws
    -> [String: Any]
{
    let body = try JSONSerialization.data(withJSONObject: ["query": query, "variables": variables])
    let reply = try JSONSerialization.jsonObject(with: try await server.console.execute(jsonBody: body))
    guard let data = (reply as? [String: Any])?["data"] as? [String: Any] else {
        throw HostFailure(description: "The console answered \(reply).")
    }
    return data
}

struct HostFailure: Error, CustomStringConvertible { let description: String }

guard (2...3).contains(CommandLine.arguments.count) else {
    FileHandle.standardError.write(
        Data("usage: KoineCompatibilityHost <data directory> [<in-application root>]\n".utf8)
    )
    exit(2)
}
let dataDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
var roots = [KoineServer.installedProviderRoot(in: dataDirectory)]
if CommandLine.arguments.count == 3 {
    let bundled = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
    let records = try FileManager.default.contentsOfDirectory(
        at: bundled, includingPropertiesForKeys: nil
    ).filter { $0.lastPathComponent.hasSuffix(".approval.json") }
    roots.insert(
        .bundled(
            bundled,
            approvals: try records.map {
                try JSONDecoder().decode(ProviderApproval.self, from: Data(contentsOf: $0))
            }
        ), at: 0
    )
}
// On the main thread: verifying a signature blocks on work Security dispatches.
let server = try KoineServer(dataDirectory: dataDirectory, providerRoots: roots)

Task {
    do {
        let port = try await server.start()
        let koine = try await console(server, "{ koine { availableCapabilities } }")
        let capabilities = (koine["koine"] as? [String: Any])?["availableCapabilities"] ?? []
        let created = try await console(
            server,
            """
            mutation Create($capabilities: [String!]!) {
              koineCreateGrant(input: { clientLabel: "compatibility driver", capabilities: $capabilities }) {
                credential
              }
            }
            """, ["capabilities": capabilities]
        )
        let credential = (created["koineCreateGrant"] as? [String: Any])?["credential"] ?? ""
        // Every mapped image of the framework, by the path dyld loaded it from.
        let frameworkImages = (0..<_dyld_image_count()).compactMap { index in
            _dyld_get_image_name(index).map { String(cString: $0) }
        }.filter { URL(fileURLWithPath: $0).lastPathComponent.contains("KoineProviderAPI") }
        emit(["port": port, "credential": credential, "frameworkImages": frameworkImages])
    } catch {
        emit(["error": "\(error)"])
        exit(1)
    }
    // Blocks its own thread, not the cooperative pool, until the driver closes the pipe.
    let ended = DispatchSemaphore(value: 0)
    Thread.detachNewThread {
        _ = FileHandle.standardInput.readDataToEndOfFile()
        ended.signal()
    }
    await withCheckedContinuation { continuation in
        DispatchQueue.global().async {
            ended.wait()
            continuation.resume()
        }
    }
    let clock = ContinuousClock()
    let took = await clock.measure { await server.stop() }
    emit(["stopped": true, "stopMilliseconds": Int(took / .milliseconds(1))])
    exit(0)
}
dispatchMain()
