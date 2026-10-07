import Foundation
import KoineCore
import KoineProviderAPI
import Testing

@testable import KoineProviderLoader
@testable import KoineServer

/// The sealed catalogue and the versions it compares (docs/specs/machine.md,
/// "Reserved identities" and "Eligibility and precedence"), and what the core does
/// with the identities it reserves.
@Suite struct ProviderCatalogueTests {
    // MARK: Versions

    @Test(arguments: [
        "0.0.0", "1.0.0", "1.10.0", "2147483647.2147483647.2147483647", "10.20.30",
    ])
    func aFirstPartyVersionIsThreeDecimalComponents(text: String) throws {
        let version = try #require(ProviderVersion(text))
        #expect(version.description == text)
    }

    @Test(arguments: [
        "", "1", "1.0", "1.0.0.0", "01.0.0", "1.00.0", "1.0.00", "-1.0.0", "+1.0.0", "1.0.0-beta",
        "1.0.0+build", "1.0.x", "1..0", " 1.0.0", "1.0.0 ", "2147483648.0.0", "1.0.99999999999",
        "١.٠.٠",
    ])
    func anythingElseIsNotAFirstPartyVersion(text: String) {
        #expect(ProviderVersion(text) == nil)
    }

    /// Numerically, component by component: as text `1.10.0` sorts before `1.9.0`.
    @Test func versionsCompareNumerically() throws {
        let ordered = try ["0.9.9", "1.0.0", "1.9.0", "1.10.0", "2.0.0", "10.0.0"].map {
            try #require(ProviderVersion($0))
        }
        #expect(ordered == ordered.sorted())
        #expect(try #require(ProviderVersion("1.10.0")) > #require(ProviderVersion("1.9.0")))
        #expect("1.10.0" < "1.9.0")
    }

    // MARK: The catalogue

    static let desktop = """
        { "providerId": "desktop", "graphQLPrefix": "Desktop", "bundle": "Desktop.koineprovider",
          "release": "1.0.0", "schema": "1.0.0", "signingIdentifier": "dev.antony.Koine.provider.desktop" }
        """

    static func catalogue(_ identities: String...) -> Data {
        Data("{ \"identities\": [\(identities.joined(separator: ","))] }".utf8)
    }

    @Test func anEntryIsEnabledOrReservedOnly() throws {
        let catalogue = try ProviderCatalogue(
            json: Self.catalogue(Self.desktop, #"{ "providerId": "input", "graphQLPrefix": "Input" }"#)
        )
        let desktop = try #require(catalogue.entry(for: "desktop"))
        #expect(desktop.graphQLPrefix == "Desktop")
        #expect(desktop.baseline?.bundleName == "Desktop.koineprovider")
        #expect(desktop.baseline?.release == ProviderVersion("1.0.0"))
        #expect(desktop.baseline?.signingIdentifier == "dev.antony.Koine.provider.desktop")
        #expect(try #require(catalogue.entry(for: "input")).baseline == nil)
    }

    @Test(arguments: [
        ("not json", "is not an object"),
        (#"{ "identities": [], "extra": 1 }"#, "is not an object"),
        (#"{ "identities": [] }"#, "lists no identity"),
        (#"{ "identities": [{ "providerId": "input" }] }"#, "graphQLPrefix"),
        (#"{ "identities": [{ "providerId": "Input", "graphQLPrefix": "Input" }] }"#, "not a provider identifier"),
        (#"{ "identities": [{ "providerId": "input", "graphQLPrefix": "input" }] }"#, "not a prefix"),
        (#"{ "identities": [{ "providerId": "input", "graphQLPrefix": "Input", "releese": "1.0.0" }] }"#, "unknown key"),
        (#"{ "identities": [{ "providerId": "input", "graphQLPrefix": "Input", "release": "1.0.0" }] }"#, "part of a baseline"),
        (#"{ "identities": [{ "providerId": "koinex", "graphQLPrefix": "Koinex" }] }"#, "core owns"),
        (#"{ "identities": [{ "providerId": "input", "graphQLPrefix": "Input" }, { "providerId": "input", "graphQLPrefix": "Other" }] }"#, "listed twice"),
        (#"{ "identities": [{ "providerId": "desk", "graphQLPrefix": "Desk" }, { "providerId": "desktop", "graphQLPrefix": "Desktop" }] }"#, "overlap"),
        (#"{ "identities": [{ "providerId": "a", "graphQLPrefix": "Same" }, { "providerId": "b", "graphQLPrefix": "Same" }] }"#, "overlap"),
    ])
    func aMalformedOrConflictingCatalogueIsRefused(text: String, fragment: String) {
        let refusal = #expect(throws: ProviderCatalogue.Invalid.self) {
            _ = try ProviderCatalogue(json: Data(text.utf8))
        }
        #expect(refusal?.reason.contains(fragment) == true, "reason was: \(refusal?.reason ?? "none")")
    }

    @Test(arguments: [
        ("release", "1.0"), ("schema", "01.0.0"), ("bundle", "Desktop"), ("bundle", "a/b.koineprovider"),
    ])
    func anEnabledEntryNeedsWellFormedValues(key: String, value: String) {
        var entry: [String: String] = [
            "providerId": "desktop", "graphQLPrefix": "Desktop", "bundle": "Desktop.koineprovider",
            "release": "1.0.0", "schema": "1.0.0", "signingIdentifier": "dev.antony.Koine.provider.desktop",
        ]
        entry[key] = value
        let data = try! JSONSerialization.data(withJSONObject: ["identities": [entry]])
        #expect(throws: ProviderCatalogue.Invalid.self) { _ = try ProviderCatalogue(json: data) }
    }

    @Test func twoEnabledEntriesNeverShareABundleOrASigner() {
        func entry(_ id: String, _ prefix: String, bundle: String, signer: String) -> String {
            """
            { "providerId": "\(id)", "graphQLPrefix": "\(prefix)", "bundle": "\(bundle)",
              "release": "1.0.0", "schema": "1.0.0", "signingIdentifier": "\(signer)" }
            """
        }
        let sameBundle = Self.catalogue(
            entry("aa", "Aa", bundle: "X.koineprovider", signer: "s.a"),
            entry("bb", "Bb", bundle: "X.koineprovider", signer: "s.b")
        )
        let sameSigner = Self.catalogue(
            entry("aa", "Aa", bundle: "A.koineprovider", signer: "s.a"),
            entry("bb", "Bb", bundle: "B.koineprovider", signer: "s.a")
        )
        for data in [sameBundle, sameSigner] {
            #expect(throws: ProviderCatalogue.Invalid.self) { _ = try ProviderCatalogue(json: data) }
        }
    }

    /// What an embedding gets when it states no catalogue: `desktop` stays reserved.
    @Test func theDefaultCatalogueKeepsDesktopReservedAndDesignatesNothing() {
        let entries = ProviderCatalogue.reservingDesktop.entries
        #expect(entries.map(\.providerId) == ["desktop"] && entries.first?.baseline == nil)
    }

    @Test func anUnreadableCatalogueFileIsAFailureNotAnEmptyCatalogue() {
        let absent = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-no-catalogue-\(UUID().uuidString).json")
        guard case .failure(let invalid) = ProviderCatalogue.load(from: absent) else {
            Issue.record("an absent catalogue was accepted")
            return
        }
        #expect(invalid.reason.contains("cannot be read"))
    }

    // MARK: The shipped catalogue

    static var repository: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    /// What the application seals: desktop and workspace enabled at their packaged
    /// values, and the four later identities reserved and not enabled early. `task
    /// check:provider-catalogue` holds the same file to the signed bundles.
    @Test func theShippedCatalogueEnablesDesktopAndWorkspaceAndReservesTheOtherFour() throws {
        let file = Self.repository.appendingPathComponent("App/ProviderCatalogue.json")
        let catalogue = try ProviderCatalogue(json: Data(contentsOf: file))

        #expect(catalogue.entries.map(\.providerId) == ["desktop", "workspace", "input", "menus", "iterm", "herdr"])
        #expect(
            catalogue.entries.map(\.graphQLPrefix)
                == ["Desktop", "Workspace", "Input", "Menus", "Iterm", "Herdr"]
        )
        let desktop = try #require(catalogue.entry(for: "desktop")?.baseline)
        #expect(desktop.bundleName == "Desktop.koineprovider")
        #expect(desktop.release == ProviderVersion("1.0.0") && desktop.schema == ProviderVersion("1.0.0"))
        #expect(desktop.signingIdentifier == "dev.antony.Koine.provider.desktop")
        let workspace = try #require(catalogue.entry(for: "workspace")?.baseline)
        #expect(workspace.bundleName == "Workspace.koineprovider")
        // 1.0.1 is the action-only long-location repair; the retained 1.0.0 is a separate artifact.
        #expect(workspace.release == ProviderVersion("1.0.1") && workspace.schema == ProviderVersion("1.0.1"))
        #expect(workspace.signingIdentifier == "dev.antony.Koine.provider.workspace")
        for reserved in ["input", "menus", "iterm", "herdr"] {
            #expect(catalogue.entry(for: reserved)?.baseline == nil, "\(reserved) must not be enabled yet")
        }
    }

    /// Each bundled provider's own source states the same identity and versions:
    /// the catalogue is not free to drift from what it designates.
    @Test(arguments: [("desktop", "DesktopProvider"), ("workspace", "WorkspaceProvider")])
    func theShippedCatalogueAgreesWithTheBundledProvidersManifest(identity: String, directory: String) throws {
        let catalogue = try ProviderCatalogue(
            json: Data(contentsOf: Self.repository.appendingPathComponent("App/ProviderCatalogue.json"))
        )
        let entry = try #require(catalogue.entry(for: identity))
        let manifest = try #require(
            JSONSerialization.jsonObject(
                with: Data(contentsOf: Self.repository.appendingPathComponent("Providers/\(directory)/manifest.json"))
            ) as? [String: Any]
        )
        #expect(manifest["providerId"] as? String == entry.providerId)
        #expect(manifest["graphQLPrefix"] as? String == entry.graphQLPrefix)
        #expect(manifest["version"] as? String == entry.baseline?.release.description)
        #expect(manifest["schemaVersion"] as? String == entry.baseline?.schema.description)
        let script = try String(
            contentsOf: Self.repository.appendingPathComponent("Providers/\(directory)/build.sh"), encoding: .utf8
        )
        #expect(script.contains("<key>CFBundleIdentifier</key><string>\(entry.baseline?.signingIdentifier ?? "?")</string>"))
        #expect(script.contains("\(entry.baseline?.bundleName ?? "?")"))
    }

    // MARK: The host's feature

    @Test func theHostSuppliesTheSelectionFeatureTheLoaderNames() {
        #expect(koineHostFeatures.contains(ProviderLoader.firstPartySelectionFeature))
        #expect(ProviderLoader.firstPartySelectionFeature == "first-party-selection-v1")
        #expect(koineHostFeatures.contains(ProviderDescriptor.additionalCapabilitiesFeature))
    }

    // MARK: What the core reserves

    /// Names beneath a reserved identity belong to the shipped provider selected
    /// for it. The core refuses any other claimant of them after loading, alone,
    /// and it does so for every identity the catalogue reserves, not desktop only.
    @Test(arguments: ["desktop", "workspace", "input", "iterm"])
    func onlyTheShippedSelectionOwnsAReservedIdentity(identity: String) async throws {
        let prefix = identity.prefix(1).uppercased() + identity.dropFirst()
        func stub(_ origin: ActiveProvider.Origin) -> Stub {
            Stub(
                id: identity, prefix: prefix,
                sdl: "extend type Query { \(identity)Value: String }",
                fields: [("Query.\(identity)Value", .read)], origin: origin
            )
        }
        let owner = stub(.bundled)
        let impostor = stub(.external)
        let catalogue = ProviderCatalogue.reserving([
            "desktop": "Desktop", "workspace": "Workspace", "input": "Input", "iterm": "Iterm",
        ])
        let harness = try await Harness(providers: [impostor.active, owner.active], catalogue: .success(catalogue))

        #expect(harness.server.providerDiagnostics.map(\.reason) == [.reservedName])
        #expect(owner.provider.startCount == 1 && impostor.provider.startCount == 0)
        await harness.stop()
    }

    /// A shipped provider may not use another identity's names, even when it owns
    /// its own: its refusal is alone, and the other owner is unaffected.
    @Test func aShippedProviderCannotClaimAnotherShippedIdentitysNames() async throws {
        let trespasser = Stub(
            id: "workspace", prefix: "Workspace",
            sdl: "extend type Query { workspaceValue: DesktopThing } type DesktopThing { a: String }",
            fields: [("Query.workspaceValue", .read), ("DesktopThing.a", .read)], origin: .bundled
        )
        let owner = Stub(
            id: "desktop", prefix: "Desktop", sdl: "extend type Query { desktopValue: String }",
            fields: [("Query.desktopValue", .read)], origin: .bundled
        )
        let catalogue = ProviderCatalogue.reserving(["desktop": "Desktop", "workspace": "Workspace"])
        let harness = try await Harness(providers: [trespasser.active, owner.active], catalogue: .success(catalogue))

        #expect(harness.server.providerDiagnostics.map(\.reason) == [.reservedName])
        #expect(owner.provider.startCount == 1 && trespasser.provider.startCount == 0)
        await harness.stop()
    }
}
