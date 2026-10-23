import Foundation
import KoineCore
import KoineProviderAPI
import Testing

@testable import KoineServer
@testable import WorkspaceProviderLogic

/// The application catalogue through the embedded server (G) with the real provider over a native adapter that
/// answers the index query and the location lookups and nothing else. No application is registered, resolved,
/// launched or inspected here.
@Suite struct WorkspaceApplicationCatalogueTests {
    static let read = ["workspace:read"]

    /// Every field of the result and everything it reaches, so a grant is tested against the whole surface.
    static let everyField = """
        query {
          apps: workspaceApplications {
            status
            items { applicationPath name bundleIdentifier sources }
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

    static let safari = IndexedApplication(
        path: "/Applications/Safari.app", contentTypeTree: ["com.apple.application-bundle"],
        bundleIdentifier: "com.apple.Safari", displayName: "Safari")
    static let zed = IndexedApplication(
        path: "/Applications/Zed.app", contentTypeTree: ["com.apple.application-bundle"],
        bundleIdentifier: "dev.zed.Zed", displayName: "Zed")

    static func bench(_ read: IndexedApplicationsRead = .gathered([safari, zed])) async throws
        -> (WorkspaceCompositionTests.Bench, WorkspaceSpecialLocationsTests.LocationsOnly)
    {
        let native = WorkspaceSpecialLocationsTests.LocationsOnly()
        native.index = read
        return (try await WorkspaceCompositionTests.Bench(provider: WorkspaceProvider(native: native)), native)
    }

    // MARK: Authority

    @Test func workspaceReadAloneReadsEveryFieldTheQueryReaches() async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(Self.everyField, as: client.principal)

        #expect(reply.errors.isEmpty, "\(reply.errors)")
        let apps = try #require(reply.data?["apps"] as? [String: Any])
        #expect(apps["status"] as? String == "AVAILABLE" && apps["resultsTruncated"] as? Bool == false)
        let items = try #require(apps["items"] as? [[String: Any]])
        #expect(items.compactMap { $0["applicationPath"] as? String } == ["/Applications/Safari.app", "/Applications/Zed.app"])
        #expect(items.compactMap { $0["name"] as? String } == ["Safari", "Zed"])
        #expect(items.compactMap { $0["bundleIdentifier"] as? String } == ["com.apple.Safari", "dev.zed.Zed"])
        #expect(items.allSatisfy { ($0["sources"] as? [String]) == ["INDEXED_APPS"] })
        let coverage = try #require((apps["sources"] as? [[String: Any]])?.first)
        #expect(coverage["source"] as? String == "INDEXED_APPS" && coverage["examined"] as? Int == 2)
        #expect(coverage["availability"] as? String == "AVAILABLE" && coverage["observations"] as? String == "COMPLETE")
        #expect(coverage["category"] as? String == "UNKNOWN")
        #expect(native.indexQueries == 1)
        #expect(native.looked.isEmpty && native.otherCalls == 0, "a read looked at nothing but the index")
    }

    @Test(arguments: [
        ["workspace:control", "desktop:control"], ["workspace:control"], ["desktop:control"],
        ["desktop:read", "desktop:control"], ["desktop:read"], [],
    ])
    func controlGrantsAloneAreRefusedAtTheRootBeforeAnyIndexQuery(held: [String]) async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(held)
        let reply = try await bench.run(Self.everyField, as: client.principal)

        let extensions = reply.extensions(at: ["apps"])
        #expect(extensions["requiredCapability"] as? String == "workspace:read", Comment(rawValue: "\(reply.json)"))
        #expect(extensions["requiredCapabilities"] == nil, "read alone: no further capability is named")
        #expect(extensions["phase"] as? String == "execution")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(reply.data?["apps"] is NSNull)
        #expect(native.indexQueries == 0 && native.otherCalls == 0, "denial precedes the provider")
    }

    /// Each field the query reaches is a register of its own, so a revocation between the root and a nested
    /// field is checked at that field and needs read alone.
    @Test(arguments: [
        "Query.workspaceApplications", "WorkspaceApplicationsResult.status", "WorkspaceApplicationsResult.items",
        "WorkspaceApplicationsResult.sources", "WorkspaceApplicationsResult.resultsTruncated",
        "WorkspaceApplicationChoice.applicationPath", "WorkspaceApplicationChoice.name",
        "WorkspaceApplicationChoice.bundleIdentifier", "WorkspaceApplicationChoice.sources",
    ])
    func everyReachableFieldIsRegisteredForReadAlone(coordinate: String) throws {
        let descriptor = workspaceDescriptor(schemaSDL: try WorkspaceCompositionTests.schemaSDL())
        let field = try #require(descriptor.fields.first { $0.coordinate == coordinate })
        #expect(field.authority == .read && field.additionalRequirements.isEmpty)
    }

    @Test func aReadGrantAloneLaunchesNothingAndAControlGrantAloneListsNothing() async throws {
        let (bench, native) = try await Self.bench()
        let reader = try await bench.grant(["workspace:read", "desktop:read"])
        let launch = try await bench.run(WorkspaceCompositionTests.launch, as: reader.principal)
        #expect(launch.outcome.isForbidden)
        #expect(native.indexQueries == 0 && native.otherCalls == 0)
    }

    // MARK: Meaning of the result

    @Test func anEmptyIndexAnswerIsUnknownWithANullListAndNoError() async throws {
        let (bench, _) = try await Self.bench(.gathered([]))
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(Self.everyField, as: client.principal)

        #expect(reply.errors.isEmpty, "\(reply.errors)")
        let apps = try #require(reply.data?["apps"] as? [String: Any])
        #expect(apps["status"] as? String == "UNKNOWN" && apps["items"] is NSNull)
        let coverage = try #require((apps["sources"] as? [[String: Any]])?.first)
        #expect(coverage["availability"] as? String == "UNKNOWN" && coverage["observations"] as? String == "UNKNOWN")
        let diagnostics = try #require(coverage["diagnostics"] as? [[String: Any]])
        #expect(diagnostics.map { $0["reason"] as? String } == ["METADATA_UNKNOWN"])
        #expect(diagnostics.allSatisfy { $0["source"] as? String == "INDEXED_APPS" && $0["permission"] is NSNull })
    }

    @Test func aLateGatheringIsFailedAndEachSelectedItemsAliasRaisesAtItsOwnPath() async throws {
        let (bench, _) = try await Self.bench(.unfinished)
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(
            """
            query {
              apps: workspaceApplications {
                status
                first: items { applicationPath }
                second: items { applicationPath }
                sources { observations diagnostics { reason } }
              }
            }
            """, as: client.principal)

        let apps = try #require(reply.data?["apps"] as? [String: Any])
        #expect(apps["status"] as? String == "FAILED")
        #expect(reply.error(at: ["apps", "first"]) != nil && reply.error(at: ["apps", "second"]) != nil)
        let coverage = try #require((apps["sources"] as? [[String: Any]])?.first)
        #expect(coverage["observations"] as? String == "UNKNOWN")
        #expect((coverage["diagnostics"] as? [[String: Any]])?.map { $0["reason"] as? String } == ["TIME_LIMIT"])
    }

    @Test func omittingItemsLeavesAFailedResultReadableWithoutAnyError() async throws {
        let (bench, _) = try await Self.bench(.overLimit)
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(
            "query { apps: workspaceApplications { status sources { diagnostics { reason } } resultsTruncated } }",
            as: client.principal)

        #expect(reply.errors.isEmpty, "\(reply.errors)")
        let apps = try #require(reply.data?["apps"] as? [String: Any])
        #expect(apps["status"] as? String == "FAILED" && apps["resultsTruncated"] as? Bool == false)
    }

    @Test func theTwoQueriesAreOneRequestOfTwoRootsEachWithItsOwnObservation() async throws {
        let (bench, native) = try await Self.bench()
        let client = try await bench.grant(Self.read)
        let reply = try await bench.run(
            """
            query {
              locations: workspaceSpecialLocations { status items { kind } }
              apps: workspaceApplications { status items { name } }
            }
            """, as: client.principal)

        #expect(reply.errors.isEmpty, "\(reply.errors)")
        #expect(native.indexQueries == 1 && native.looked == LocationPair.defaults)
    }

    // MARK: The disclosure

    @Test func theReadDisclosureStatesTheReachOfBothQueries() {
        let text = CapabilityDisclosures.workspaceRead
        for fragment in ["special locations", "Spotlight", "bundle identifier", "workspace:control"] {
            #expect(text.contains(fragment), "the read disclosure does not mention \(fragment)")
        }
        #expect(text.contains("reads no file contents") && text.contains("lists no folder"))
    }
}
