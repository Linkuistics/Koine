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
// each with the `<providerId>.approval.json` beside it that names the Team ID it
// is signed by. A host of this release is purpose-built around what it finds
// there, as a released application is around its sealed catalogue: the catalogue
// designates each bundle with the release, schema and code-signing identifier it
// carries, and the running host's own team is the record's, since this host is
// not itself signed. A host of an earlier release takes the data directory alone,
// and loads such bundles as the provider `desktop` is reserved to.
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

/// The code-signing identifier a bundle carries, as `codesign` reports it.
func signingIdentifier(of bundle: URL) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
    process.arguments = ["-dvv", bundle.path]
    let output = Pipe()
    process.standardError = output
    process.standardOutput = output
    try process.run()
    let text = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    process.waitUntilExit()
    guard let line = text.split(separator: "\n").first(where: { $0.hasPrefix("Identifier=") }) else {
        throw HostFailure(description: "\(bundle.lastPathComponent) carries no signing identifier.")
    }
    return String(line.dropFirst("Identifier=".count))
}

guard (2...3).contains(CommandLine.arguments.count) else {
    FileHandle.standardError.write(
        Data("usage: KoineCompatibilityHost <data directory> [<in-application root>]\n".utf8)
    )
    exit(2)
}
let dataDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
var roots = [KoineServer.installedProviderRoot(in: dataDirectory)]
var catalogue = ProviderCatalogue.empty
var seam = ProviderLoader.Seam()
if CommandLine.arguments.count == 3 {
    let bundled = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
    let records = try FileManager.default.contentsOfDirectory(
        at: bundled, includingPropertiesForKeys: nil
    ).filter { $0.lastPathComponent.hasSuffix(".approval.json") }
    var entries: [ProviderCatalogue.Entry] = []
    var team: String?
    for record in records {
        let approval = try JSONDecoder().decode(ProviderApproval.self, from: Data(contentsOf: record))
        team = approval.teamIdentifier
        for bundle in try FileManager.default.contentsOfDirectory(
            at: bundled, includingPropertiesForKeys: nil
        ) where bundle.pathExtension == ProviderLoader.bundleExtension {
            let manifest = try JSONSerialization.jsonObject(
                with: Data(contentsOf: bundle.appendingPathComponent("manifest.json"))
            ) as? [String: Any] ?? [:]
            guard manifest["providerId"] as? String == approval.providerId else { continue }
            entries.append(
                ProviderCatalogue.Entry(
                    providerId: approval.providerId,
                    graphQLPrefix: manifest["graphQLPrefix"] as? String ?? "",
                    baseline: ProviderCatalogue.Baseline(
                        bundleName: bundle.lastPathComponent,
                        release: ProviderVersion(manifest["version"] as? String ?? "") ?? ProviderVersion("1.0.0")!,
                        schema: ProviderVersion(manifest["schemaVersion"] as? String ?? "") ?? ProviderVersion("1.0.0")!,
                        signingIdentifier: try signingIdentifier(of: bundle)
                    )
                )
            )
        }
    }
    catalogue = try ProviderCatalogue(entries: entries)
    let hostTeam = team
    seam.hostTeam = { hostTeam }
    roots.insert(.bundled(bundled), at: 0)
}
// On the main thread: verifying a signature blocks on work Security dispatches.
let server = try KoineServer(
    dataDirectory: dataDirectory, policy: .version1, providerRoots: roots,
    providerCatalogue: .success(catalogue), providerStaging: nil, osPermissions: { [] },
    now: { Date() }, additionalProviders: [], loaderSeam: seam
)

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
