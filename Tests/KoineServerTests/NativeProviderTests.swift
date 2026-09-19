import Foundation
import KoineServer
import Testing

/// The native path end to end: the fixture bundle, built outside the package
/// against the staged framework, loaded from a configured root and served over
/// loopback HTTP. `task test` builds the fixture; see README.md.
@Suite struct NativeProviderTests {
    /// `KOINE_FIXTURE_PROVIDER_ROOT`, or `FixtureProviders` beside the test bundle.
    static func fixtureRoot() throws -> URL {
        let root: URL
        if let path = ProcessInfo.processInfo.environment["KOINE_FIXTURE_PROVIDER_ROOT"] {
            root = URL(fileURLWithPath: path, isDirectory: true)
        } else {
            root = Bundle(for: TestBundleAnchor.self).bundleURL.deletingLastPathComponent()
                .appendingPathComponent("FixtureProviders", isDirectory: true)
        }
        let bundle = root.appendingPathComponent("Fixture.koineprovider")
        try #require(
            FileManager.default.fileExists(atPath: bundle.path),
            "No fixture provider at \(bundle.path). Run `task test`, which builds it."
        )
        return root
    }

    static let info = "{ fixtureInfo { greeting } }"

    @Test func readFieldIsServedUnderTheFixtureReadCapability() async throws {
        let harness = try await Harness(providerRoots: [try Self.fixtureRoot()])
        let credential = try await harness.consoleGrant(
            label: "reader", capabilities: ["fixture:read"]
        )
        let reply = try await harness.post(Self.info, authorization: "Bearer \(credential)")

        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        let info = reply.data?["fixtureInfo"] as? [String: Any]
        #expect(info?["greeting"] as? String == "hello from the fixture provider")
        await harness.stop()
    }

    @Test func readFieldWithoutTheCapabilityIsACapabilityError() async throws {
        let harness = try await Harness(providerRoots: [try Self.fixtureRoot()])
        let credential = try await harness.consoleGrant(label: "stranger", capabilities: [])
        let reply = try await harness.post(Self.info, authorization: "Bearer \(credential)")

        #expect(reply.status == 200)
        #expect(reply.data?["fixtureInfo"] is NSNull)
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["fixtureInfo"])
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "fixture:read")
        await harness.stop()
    }

    @Test func introspectionAndCapabilitiesShowTheContribution() async throws {
        let harness = try await Harness(providerRoots: [try Self.fixtureRoot()])
        let credential = try await harness.consoleGrant(label: "tooling", capabilities: [])
        let authorization = "Bearer \(credential)"

        let schema = try await harness.post(Harness.introspection, authorization: authorization)
        #expect(schema.errors.isEmpty)
        let types = (schema.data?["__schema"] as? [String: Any])?["types"] as? [[String: Any]] ?? []
        let fixtureInfo = try #require(types.first { $0["name"] as? String == "FixtureInfo" })
        let fields = fixtureInfo["fields"] as? [[String: Any]] ?? []
        #expect(fields.map { $0["name"] as? String } == ["greeting"])

        let koine = try await harness.post(Harness.koine, authorization: authorization)
        let available = (koine.data?["koine"] as? [String: Any])?["availableCapabilities"]
        #expect(available as? [String] == ["koine:manage", "fixture:read", "fixture:control"])
        await harness.stop()
    }

    @Test func withoutAProviderRootTheSchemaIsTheCoreAlone() async throws {
        let harness = try await Harness()
        let credential = try await harness.consoleGrant(label: "reader", capabilities: [])
        let reply = try await harness.post(Self.info, authorization: "Bearer \(credential)")
        #expect(reply.status == 400)
        await harness.stop()
    }
}

private final class TestBundleAnchor {}
