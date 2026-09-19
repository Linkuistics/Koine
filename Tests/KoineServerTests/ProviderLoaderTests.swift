import Foundation
import KoineProviderLoader
import KoineServer
import Testing

/// The native loader's refusals and the status it reports, over real bundles:
/// `task test` builds them with Fixtures/FixtureProvider/build-variants.sh, one
/// provider root per case. Everything is observed as a management client would
/// observe it, except whether a dylib's initializers ran, which the fixture
/// records in a log (Fixtures/FixtureProvider/initializer.c).
@Suite struct ProviderLoaderTests {
    // MARK: Material

    /// Set before any bundle of this suite can load; read by the fixture's
    /// initializer.
    static let initializerLog: URL = {
        let log = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-initializers-\(UUID().uuidString).log")
        setenv("KOINE_FIXTURE_INITIALIZER_LOG", log.path, 1)
        return log
    }()

    static func variantRoot(_ name: String) throws -> URL {
        _ = initializerLog
        let root = try NativeProviderTests.fixtureRoot().deletingLastPathComponent()
            .appendingPathComponent("FixtureVariants/\(name)", isDirectory: true)
        try #require(
            FileManager.default.fileExists(atPath: root.path),
            "No fixture variant at \(root.path). Run `task test`, which builds them."
        )
        return root
    }

    /// Whether any image under `root` ran its initializers in this process.
    static func initializersRan(under root: URL) -> Bool {
        let log = (try? String(contentsOf: initializerLog, encoding: .utf8)) ?? ""
        return log.split(separator: "\n").contains { $0.contains("/FixtureVariants/\(root.lastPathComponent)/") }
    }

    struct Status: Equatable {
        let provider: String
        let version: String
        let schemaVersion: String
        let state: String
        let diagnostic: String?
    }

    static let providers = "{ koineManagement { providers { provider version schemaVersion state diagnostic } } }"

    static func statuses(_ harness: Harness) async throws -> [Status] {
        let body = try Harness.requestBody(providers, variables: [:])
        let json = try JSONSerialization.jsonObject(
            with: try await harness.server.console.execute(jsonBody: body)
        ) as? [String: Any]
        let management = (json?["data"] as? [String: Any])?["koineManagement"] as? [String: Any]
        let rows = try #require(management?["providers"] as? [[String: Any]])
        return rows.map {
            Status(
                provider: $0["provider"] as? String ?? "", version: $0["version"] as? String ?? "",
                schemaVersion: $0["schemaVersion"] as? String ?? "",
                state: $0["state"] as? String ?? "", diagnostic: $0["diagnostic"] as? String
            )
        }
    }

    /// The root fields of `Query` and `Mutation`, from introspection.
    static func rootFields(_ harness: Harness) async throws -> Set<String> {
        let credential = try await harness.consoleGrant(label: "tooling", capabilities: [])
        let reply = try await harness.post(
            "{ q: __type(name: \"Query\") { fields { name } } m: __type(name: \"Mutation\") { fields { name } } }",
            authorization: "Bearer \(credential)"
        )
        var names: Set<String> = []
        for root in ["q", "m"] {
            let fields = (reply.data?[root] as? [String: Any])?["fields"] as? [[String: Any]] ?? []
            names.formUnion(fields.compactMap { $0["name"] as? String })
        }
        return names
    }

    static let coreRootFields: Set<String> = [
        "koine", "koineManagement", "koineCreateGrant", "koineRevokeGrant",
    ]

    // MARK: Refused before dlopen

    struct Refusal: Sendable, CustomTestStringConvertible {
        let variant: String
        let state: String
        /// A fragment of the management diagnostic.
        let diagnostic: String
        var provider = "fixture"
        var version = "1.0.0"
        var testDescription: String { variant }
    }

    static let refusedBeforeLoading: [Refusal] = [
        Refusal(
            variant: "malformed-manifest", state: "REJECTED", diagnostic: "framework is missing",
            provider: "Fixture", version: "unknown"
        ),
        Refusal(variant: "unsupported-major", state: "INCOMPATIBLE", diagnostic: "framework major 2"),
        Refusal(variant: "unavailable-minor", state: "INCOMPATIBLE", diagnostic: "1.99 or later"),
        Refusal(variant: "missing-feature", state: "INCOMPATIBLE", diagnostic: "time-travel"),
        Refusal(variant: "foreign-architecture", state: "INCOMPATIBLE", diagnostic: "is built for"),
        Refusal(variant: "newer-os", state: "INCOMPATIBLE", diagnostic: "requires macOS 99.0"),
        Refusal(variant: "newer-runtime", state: "INCOMPATIBLE", diagnostic: "Swift runtime 99.0"),
        Refusal(variant: "understated-os", state: "REJECTED", diagnostic: "was built for macOS 13.0"),
        Refusal(variant: "principal-collision", state: "REJECTED", diagnostic: "already registered"),
        Refusal(variant: "library-outside-bundle", state: "REJECTED", diagnostic: "outside the bundle"),
        Refusal(variant: "architecture-mismatch", state: "REJECTED", diagnostic: "but libFixtureProvider.dylib holds"),
        Refusal(variant: "bundled-framework", state: "REJECTED", diagnostic: "own copy of the provider framework"),
        Refusal(
            variant: "static-framework", state: "REJECTED", diagnostic: "statically linked copy",
            provider: "fixturest"
        ),
        Refusal(
            variant: "foreign-dependency", state: "REJECTED",
            diagnostic: "/opt/koine-fixture/libElsewhere.dylib", provider: "fixturefd"
        ),
        // The manifest lies about the framework it needs; the checks pass and
        // the dynamic loader refuses, before any initializer.
        Refusal(
            variant: "newer-framework", state: "REJECTED", diagnostic: "The dynamic loader refused",
            provider: "fixturenf"
        ),
    ]

    @Test(arguments: refusedBeforeLoading)
    func aRefusedBundleRunsNoCodeAndContributesNothing(_ refusal: Refusal) async throws {
        let root = try Self.variantRoot(refusal.variant)
        let harness = try await Harness(providerRoots: [root])

        let statuses = try await Self.statuses(harness)
        #expect(statuses.count == 1)
        let status = try #require(statuses.first)
        #expect(status.provider == refusal.provider)
        #expect(status.version == refusal.version && status.schemaVersion == refusal.version)
        #expect(status.state == refusal.state)
        #expect(
            status.diagnostic?.contains(refusal.diagnostic) == true,
            "diagnostic was: \(status.diagnostic ?? "nil")"
        )
        #expect(!Self.initializersRan(under: root))
        #expect(try await Self.rootFields(harness) == Self.coreRootFields)
        await harness.stop()
    }

    // MARK: Loaded

    /// The control for `initializersRan`: a bundle that loads is seen to run its
    /// initializers, by the same instrument that sees the refused ones did not.
    @Test func aValidatedPrivateDependencyInsideTheBundleLoads() async throws {
        let root = try Self.variantRoot("private-dependency")
        let harness = try await Harness(providerRoots: [root])

        #expect(
            try await Self.statuses(harness) == [
                Status(
                    provider: "fixturepd", version: "1.0.0", schemaVersion: "1.0.0", state: "ACTIVE",
                    diagnostic: nil
                )
            ]
        )
        #expect(Self.initializersRan(under: root))
        let credential = try await harness.consoleGrant(label: "r", capabilities: ["fixturepd:read"])
        let reply = try await harness.post(
            "{ fixturePdInfo { greeting } }", authorization: "Bearer \(credential)"
        )
        #expect(reply.errors.isEmpty)
        #expect((reply.data?["fixturePdInfo"] as? [String: Any])?["greeting"] != nil)
        await harness.stop()
    }

    struct Failure: Sendable, CustomTestStringConvertible {
        let variant: String
        let provider: String
        let diagnostic: String
        var testDescription: String { variant }
    }

    @Test(arguments: [
        Failure(variant: "missing-principal", provider: "fixturemp", diagnostic: "registers no class named"),
        Failure(variant: "not-a-factory", provider: "fixturent", diagnostic: "does not conform to ProviderFactory"),
        Failure(variant: "descriptor-disagrees", provider: "somethingelse", diagnostic: "disagrees with its manifest"),
    ])
    func aProviderThatFailsAfterLoadingStaysMappedAndContributesNothing(_ failure: Failure) async throws {
        let root = try Self.variantRoot(failure.variant)
        let harness = try await Harness(providerRoots: [root])

        let status = try #require(try await Self.statuses(harness).first)
        #expect(status.provider == failure.provider && status.state == "REJECTED")
        #expect(
            status.diagnostic?.contains(failure.diagnostic) == true,
            "diagnostic was: \(status.diagnostic ?? "nil")"
        )
        #expect(Self.initializersRan(under: root))
        #expect(try await Self.rootFields(harness) == Self.coreRootFields)
        let koine = try await harness.post(
            Harness.koine,
            authorization: "Bearer \(try await harness.consoleGrant(label: "c", capabilities: []))"
        )
        let available = (koine.data?["koine"] as? [String: Any])?["availableCapabilities"]
        #expect(available as? [String] == ["koine:manage"])
        await harness.stop()
    }

    @Test func aFailedStartIsReportedWithManagementStillAvailable() async throws {
        let harness = try await Harness(providerRoots: [try Self.variantRoot("failed-start")])

        let status = try #require(try await Self.statuses(harness).first)
        #expect(
            status.provider == "fixturefs" && status.state == "FAILED",
            "status was: \(status)"
        )
        #expect(status.diagnostic?.contains("built to fail its start") == true)

        let credential = try await harness.consoleGrant(
            label: "both", capabilities: ["koine:manage", "fixturefs:read"]
        )
        let reply = try await harness.post(
            "{ koineManagement { grants { clientLabel } } fixtureFsInfo { greeting } }",
            authorization: "Bearer \(credential)"
        )
        #expect(reply.status == 200)
        #expect((reply.data?["koineManagement"] as? [String: Any])?["grants"] != nil)
        #expect(reply.data?["fixtureFsInfo"] is NSNull)
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["fixtureFsInfo"])
        #expect((error["extensions"] as? [String: Any])?["kind"] as? String == "unavailable")
        await harness.stop()
    }

    // MARK: Status

    @Test func everyBundleFoundHasAStatusActiveOrNot() async throws {
        let harness = try await Harness(providerRoots: [
            try NativeProviderTests.fixtureRoot(), try Self.variantRoot("unsupported-major"),
            try Self.variantRoot("malformed-manifest"),
        ])

        let statuses = try await Self.statuses(harness)
        #expect(statuses.map(\.provider) == ["Fixture", "fixture", "fixture"])
        #expect(Set(statuses.map(\.state)) == ["REJECTED", "ACTIVE", "INCOMPATIBLE"])
        let active = try #require(statuses.first { $0.state == "ACTIVE" })
        #expect(active.version == "1.0.0" && active.schemaVersion == "1.0.0")
        #expect(active.diagnostic == nil)
        #expect(try await Self.rootFields(harness).contains("fixtureInfo"))
        await harness.stop()
    }

    @Test func providerStatusRequiresTheManageCapability() async throws {
        let harness = try await Harness(providerRoots: [try NativeProviderTests.fixtureRoot()])
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["fixture:read"])
        let denied = try await harness.post(Self.providers, authorization: "Bearer \(reader)")

        #expect(denied.data?["koineManagement"] is NSNull)
        let extensions = try #require(denied.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["requiredCapability"] as? String == "koine:manage")

        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let served = try await harness.post(Self.providers, authorization: "Bearer \(manager)")
        #expect(served.errors.isEmpty)
        let rows = (served.data?["koineManagement"] as? [String: Any])?["providers"] as? [[String: Any]]
        #expect(rows?.map { $0["state"] as? String } == ["ACTIVE"])
        await harness.stop()
    }

    /// The host states its framework version; the framework's own Info.plist
    /// is what ships. They are one fact.
    @Test func theHostStatesTheVersionOfTheFrameworkItBundles() throws {
        let plist = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("ProviderAPI/Info.plist")
        let info = try #require(
            try PropertyListSerialization.propertyList(from: Data(contentsOf: plist), format: nil)
                as? [String: Any]
        )
        let version = try #require(info["CFBundleShortVersionString"] as? String)
        #expect(
            version.hasPrefix("\(HostCompatibility.frameworkMajor).\(HostCompatibility.frameworkMinor).")
        )
    }
}
