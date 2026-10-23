import Foundation
import KoineCore
import KoineProviderAPI
import KoineProviderLoader
import Testing

@testable import KoineServer
@testable import WorkspaceProviderLogic

/// The special-locations query through the embedded server (G) with the real provider over a native adapter that
/// answers location lookups and nothing else, and through the loader with the real signed bundle (N's neighbour:
/// it loads nothing). No location is read, resolved or listed here.
@Suite struct WorkspaceSpecialLocationsTests {
    static let read = ["workspace:read"]

    /// A native adapter for the query alone: it gives the ten default values and counts every call that is
    /// not a location lookup, which a read must never make.
    final class LocationsOnly: WorkspaceNative, @unchecked Sendable {
        private let lock = NSLock()
        private var lookups: [LocationPair] = []
        private var others = 0

        var looked: [LocationPair] { lock.withLock { lookups } }
        var otherCalls: Int { lock.withLock { others } }
        private func other() { lock.withLock { others += 1 } }

        func specialLocationValues(_ pair: LocationPair) -> [String] {
            lock.withLock { lookups.append(pair) }
            switch (pair.kind, pair.domain) {
            case (.home, _): return ["/Users/test"]
            case (.applications, .user): return ["/Users/test/Applications"]
            case (.applications, .local): return ["/Applications"]
            case (.applications, .system): return ["/System/Applications"]
            default: return ["/Users/test/\(pair.kind.rawValue.capitalized)"]
            }
        }
        func accountIdentifier() -> String { "501" }

        func registeredApplication(bundleIdentifier: String) -> URL? { other(); return nil }
        func registeredApplications(bundleIdentifier: String) -> [URL] { other(); return [] }
        func readApplicationBundle(of location: ResolvedLocation) -> BundleRead { other(); return .notApplication }
        func launchApplication(
            at url: URL, substitutingRunningCopy: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void
        ) { other() }
        func defaultApplication(forWebScheme scheme: WebURL.Scheme) -> URL? { other(); return nil }
        func openWebURL(
            _ url: URL, withApplicationAt application: URL, completion: @escaping @Sendable (LaunchCompletion) -> Void
        ) { other() }
        func readPathFacts(of location: ResolvedLocation) -> PathInspection { other(); return .absent }
        func resolveLocation(_ path: String) -> LocationResolution { other(); return .absent(.missing(component: path)) }
        func isFilesystemRoot(literalPath path: String) -> FilesystemRootDecision { other(); return .notRoot }
        func contentType(_ identifier: String, conformsTo ancestor: String) -> Bool { other(); return false }
        func defaultApplication(toOpen url: URL) -> URL? { other(); return nil }
        func openPath(
            _ url: URL, withApplicationAt application: URL, substitutingRunningCopy: Bool,
            completion: @escaping @Sendable (LaunchCompletion) -> Void
        ) { other() }
        func revealPath(_ path: String, filesystemRoot: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void) {
            other()
        }
        func processStart(of pid: Int32) -> ProcessLookup { other(); return .absent }
        func liveExecutableIdentity(of pid: Int32) -> ObjectIdentity? { other(); return nil }
    }

    /// Every field of the result and everything it reaches, so a grant is tested against the whole surface.
    static let everyField = """
        query($requests: [WorkspaceLocationRequest!]) {
          locations: workspaceSpecialLocations(requests: $requests) {
            status
            items { kind domain accountIdentifier location contentsAvailability sources }
            sources {
              source declaredDomain availability observations category examined
              diagnostics {
                source reason subject affectsCoverage guidance
                permission { permission target event consent }
              }
            }
            resultsTruncated
          }
        }
        """

    static func bench() async throws -> (WorkspaceCompositionTests.Bench, LocationsOnly) {
        let native = LocationsOnly()
        return (try await WorkspaceCompositionTests.Bench(provider: WorkspaceProvider(native: native)), native)
    }

    // MARK: Authority

    @Test func workspaceReadAloneReadsEveryFieldTheQueryReaches() async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(Self.everyField, as: client.principal)

        #expect(reply.errors.isEmpty, "\(reply.errors)")
        let locations = try #require(reply.data?["locations"] as? [String: Any])
        #expect(locations["status"] as? String == "AVAILABLE" && locations["resultsTruncated"] as? Bool == false)
        let items = try #require(locations["items"] as? [[String: Any]])
        #expect(items.count == 10)
        #expect(items.first?["kind"] as? String == "HOME" && items.last?["domain"] as? String == "SYSTEM")
        #expect(items.allSatisfy { $0["accountIdentifier"] as? String == "501" })
        #expect(items.allSatisfy { $0["contentsAvailability"] as? String == "UNKNOWN" })
        #expect(items.allSatisfy { ($0["sources"] as? [String]) == ["FOUNDATION_LOCATIONS"] })
        let coverage = try #require((locations["sources"] as? [[String: Any]])?.first)
        #expect(coverage["source"] as? String == "FOUNDATION_LOCATIONS" && coverage["examined"] as? Int == 10)
        #expect(native.looked == LocationPair.defaults)
        #expect(native.otherCalls == 0, "a read looked at nothing but the values")
    }

    @Test(arguments: [
        ["workspace:control", "desktop:control"], ["workspace:control"], ["desktop:control"],
        ["desktop:read", "desktop:control"], ["desktop:read"], [],
    ])
    func controlGrantsAloneAreRefusedAtTheRootBeforeAnyLookup(held: [String]) async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(held)
        let reply = try await bench.run(Self.everyField, as: client.principal)

        // A query is denied field by field as it executes, not by whole-operation preflight as a mutation is.
        let extensions = reply.extensions(at: ["locations"])
        #expect(extensions["requiredCapability"] as? String == "workspace:read", Comment(rawValue: "\(reply.json)"))
        #expect(extensions["requiredCapabilities"] == nil, "read alone: no further capability is named")
        #expect(extensions["phase"] as? String == "execution")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(reply.data?["locations"] is NSNull)
        #expect(native.looked.isEmpty && native.otherCalls == 0, "denial precedes the provider")
    }

    @Test func aReadGrantDoesNotLaunchAnything() async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(["workspace:read", "desktop:read"])
        let reply = try await bench.run(WorkspaceCompositionTests.launch, as: client.principal)

        #expect(reply.outcome.isForbidden)
        #expect(reply.extensions(at: ["launch"])["requiredCapabilities"] as? [String] == WorkspaceCompositionTests.controls)
        #expect(native.looked.isEmpty && native.otherCalls == 0)
    }

    /// Each field the query reaches is a register of its own, so a revocation between the root and a nested
    /// field is checked at that field and needs read alone.
    @Test(arguments: [
        "WorkspaceSpecialLocationsResult.status", "WorkspaceSpecialLocationsResult.items",
        "WorkspaceSpecialLocationsResult.sources", "WorkspaceSpecialLocationsResult.resultsTruncated",
        "WorkspaceSpecialLocation.location", "WorkspaceDiscoveryCoverage.diagnostics",
        "WorkspaceDiscoveryDiagnostic.permission",
    ])
    func everyReachableFieldIsRegisteredForReadAlone(coordinate: String) throws {
        let descriptor = workspaceDescriptor(schemaSDL: try WorkspaceCompositionTests.schemaSDL())
        let field = try #require(descriptor.fields.first { $0.coordinate == coordinate })
        #expect(field.authority == .read && field.additionalRequirements.isEmpty)
    }

    // MARK: Requests

    @Test func aRefusedRequestIsAnInputErrorAtTheOriginalPathWithNoKind() async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(
            Self.everyField, ["requests": [["kind": "DOCUMENTS", "domain": "LOCAL"]]], as: client.principal)

        let error = try #require(reply.error(at: ["locations"]))
        #expect((error["extensions"] as? [String: Any])?["kind"] as? String == nil, "no kind of provider failure")
        #expect(native.looked.isEmpty)
    }

    @Test func explicitPairsAreLookedUpInTheOrderGiven() async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(
            Self.everyField,
            ["requests": [["kind": "APPLICATIONS", "domain": "SYSTEM"], ["kind": "HOME", "domain": "USER"]]],
            as: client.principal)

        #expect(reply.errors.isEmpty, "\(reply.errors)")
        let items = try #require((reply.data?["locations"] as? [String: Any])?["items"] as? [[String: Any]])
        #expect(items.compactMap { $0["location"] as? String } == ["/System/Applications", "/Users/test"])
        #expect(native.looked == [LocationPair(kind: .applications, domain: .system), LocationPair(kind: .home, domain: .user)])
    }

    // MARK: The host feature

    /// The served window shows the disclosure catalogue, so a host that advertises the feature serves the read
    /// disclosure beside the control one, and the workspace provider asks for exactly that feature.
    @Test func theHostAdvertisesTheFeatureTheProviderRequiresAndServesTheDisclosure() throws {
        let descriptor = workspaceDescriptor(schemaSDL: try WorkspaceCompositionTests.schemaSDL())
        #expect(descriptor.requiredFeatures.contains("workspace-native-disclosures-v1"))
        #expect(koineHostFeatures.contains("workspace-native-disclosures-v1"))
        #expect(CapabilityDisclosures.all.map(\.capability).contains("workspace:read"))
        let manifest = try #require(
            JSONSerialization.jsonObject(
                with: Data(contentsOf: ProviderCatalogueTests.repository.appendingPathComponent("Providers/WorkspaceProvider/manifest.json"))
            ) as? [String: Any])
        #expect(
            Set(manifest["requiredFeatures"] as? [String] ?? []) == Set(descriptor.requiredFeatures),
            "the manifest and the descriptor name the same features")
    }

    /// A host that does not advertise the feature refuses the real signed workspace bundle before it loads: the
    /// seam that would load it is never reached for it, and the row says which feature is missing.
    @Test func aHostWithoutTheFeatureRefusesTheWorkspaceBundleBeforeItLoads() async throws {
        let recorder = ProviderSelectionTests.Recorder()
        var seam = ProviderLoader.Seam()
        let team = try DesktopProviderTests.team()
        seam.hostTeam = { team }
        seam.load = { try recorder.load($0) }
        seam.assessment = { recorder.assess($0) }
        let root = try DesktopProviderTests.root()
        let catalogue = try DesktopProviderTests.catalogue()
        let without = HostCompatibility(features: koineHostFeatures.subtracting(["workspace-native-disclosures-v1"]))
        let sealed = seam
        let result = try await withCheckedThrowingContinuation { continuation in
            Harness.constructing.async {
                continuation.resume(
                    with: Result {
                        try ProviderLoader.selectAndLoad(
                            roots: [.bundled(root)], catalogue: .success(catalogue),
                            staging: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString),
                            host: without, seam: sealed)
                    })
            }
        }
        let workspace = try #require(result.reports.first { $0.provider == "workspace" })
        guard case .incompatible(let reason) = workspace.outcome else {
            Issue.record("the workspace bundle was not refused as incompatible: \(workspace.outcome)")
            return
        }
        #expect(reason.contains("workspace-native-disclosures-v1"), Comment(rawValue: reason))
        #expect(!recorder.attempts.map(\.providerId).contains("workspace"), "it was never loaded")

        // The control: the same bundle on a host that advertises the feature is not refused for it. Whether the
        // process-wide loader then maps it depends on what earlier tests in this process loaded, so only the
        // absence of this refusal is asserted.
        let control = try await withCheckedThrowingContinuation { continuation in
            Harness.constructing.async {
                continuation.resume(
                    with: Result {
                        try ProviderLoader.selectAndLoad(
                            roots: [.bundled(root)], catalogue: .success(catalogue),
                            staging: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString),
                            host: HostCompatibility(features: koineHostFeatures), seam: sealed)
                    })
            }
        }
        let accepted = try #require(control.reports.first { $0.provider == "workspace" })
        if case .incompatible = accepted.outcome { Issue.record("refused though the host advertises the feature") }
    }
}
