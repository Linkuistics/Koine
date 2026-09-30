import Foundation
import KoineProviderLoader
import KoineServer
import MachO

// Test material for the selection acceptance (docs/verification/selection-decisions.md):
// a headless host that is a real signed application in everything selection reads.
// scripts/build-selection-hosts.sh assembles it as `<name>.app`, puts a purpose-built
// `Contents/Resources/ProviderCatalogue.json` and `Contents/PlugIns` inside, and
// signs the whole with a chosen identity: the catalogue is sealed before the
// signature, as the application's is, so a defective catalogue is a file that was
// wrong when it was signed and never a broken seal.
//
// Nothing here stands in for the host's trust. The catalogue is read from the
// bundle exactly as Sources/KoineApp/AppDelegate.swift reads its own, the
// in-application root is the bundle's PlugIns, and the approval Team ID derives
// from this process's verified signature; a host signed ad hoc, or not at all,
// has none. The one private seam it uses is the discovery order, so a driver can
// reverse it while the real verifier and loader run.
//
// A second private seam, for a restart that changes the assessment verdict: the environment
// variable KOINE_FIXTURE_ASSESSMENT is `accept` or `refuse`, and replaces Gatekeeper's verdict on
// a quarantined image with that one, so a driver can flip it between two runs of one data
// directory (scripts/verify-selection-failures.py). Unset, the real Gatekeeper answers.
//
// usage: KoineSelectionHost <data directory> [--reverse-discovery]
//
// Prints one JSON line when ready (port, a credential holding every available
// capability, the team this process verified, and the KoineProviderAPI images
// mapped), serves until standard input ends, then stops and prints how long that took.

/// A class registered by this host's own image, for a fixture manifest to name as its
/// principal class: the loader's check that a selected provider's principal class name is
/// free in the host as it already is (scripts/verify-selection-failures.py).
@objc(KoineSelectionHostClass) final class SelectionHostClass: NSObject {}

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
        struct Failure: Error, CustomStringConvertible { let description: String }
        throw Failure(description: "The console answered \(reply).")
    }
    return data
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard let dataPath = arguments.first, Set(arguments.dropFirst()).isSubset(of: ["--reverse-discovery"]) else {
    FileHandle.standardError.write(
        Data("usage: KoineSelectionHost <data directory> [--reverse-discovery]\n".utf8)
    )
    exit(2)
}
let dataDirectory = URL(fileURLWithPath: dataPath, isDirectory: true)
// <name>.app/Contents/MacOS/<executable>: the bundle's own Contents.
let contents = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
    .deletingLastPathComponent().deletingLastPathComponent()
var seam = ProviderLoader.Seam()
if arguments.contains("--reverse-discovery") { seam.discoveryOrder = { $0.reversed() } }
switch ProcessInfo.processInfo.environment["KOINE_FIXTURE_ASSESSMENT"] {
case "accept": seam.assessment = { _ in nil }
case "refuse": seam.assessment = { _ in "the injected verdict refuses it, and" }
default: break
}
// On the main thread: verifying a signature blocks on work Security dispatches.
// A root the host cannot enumerate stops startup here, and the driver reads why.
let server: KoineServer
do {
    server = try KoineServer(
        dataDirectory: dataDirectory, policy: .version1,
        providerRoots: [
            .bundled(contents.appendingPathComponent("PlugIns", isDirectory: true)),
            KoineServer.installedProviderRoot(in: dataDirectory),
        ],
        providerCatalogue: ProviderCatalogue.load(
            from: contents.appendingPathComponent("Resources/ProviderCatalogue.json")
        ),
        providerStaging: nil, osPermissions: { [] }, now: { Date() }, additionalProviders: [],
        loaderSeam: seam
    )
} catch {
    emit(["error": "\(error)"])
    exit(1)
}

Task {
    do {
        let port = try await server.start()
        let koine = try await console(server, "{ koine { availableCapabilities } }")
        let capabilities = (koine["koine"] as? [String: Any])?["availableCapabilities"] ?? []
        let created = try await console(
            server,
            """
            mutation Create($capabilities: [String!]!) {
              koineCreateGrant(input: { clientLabel: "selection acceptance driver", capabilities: $capabilities }) {
                credential
              }
            }
            """, ["capabilities": capabilities]
        )
        let credential = (created["koineCreateGrant"] as? [String: Any])?["credential"] ?? ""
        let frameworkImages = (0..<_dyld_image_count()).compactMap { index in
            _dyld_get_image_name(index).map { String(cString: $0) }
        }.filter { URL(fileURLWithPath: $0).lastPathComponent.contains("KoineProviderAPI") }
        emit([
            "port": port, "credential": credential, "frameworkImages": frameworkImages,
            "hostTeam": ProviderApproval.hostTeamIdentifier ?? NSNull(),
        ])
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
