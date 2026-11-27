import AppKit
import Foundation
import KoineCore
import KoineProviderLoader
import KoineServer
import Testing

/// The pointer position and the pointer nudge of the real desktop bundle, loaded by the native loader and asked
/// over loopback HTTP (docs/specs/machine.md, "Pointer and media"). Only what moves nothing is asked here: the
/// position read, the authority of every new field, the served descriptions and the host feature. No test here
/// calls the nudge with a desktop:control grant, because the nudge would move the pointer of this host. The nudge
/// itself is the VM acceptance (`pointer-media-acceptance-k5`). `task test` builds the bundle.
@Suite struct DesktopPointerTests {
    /// `DesktopPointerPosition`, as docs/design/desktop-pointer-media-operations.graphql has it.
    static let pointer = "query DesktopPointerPosition { desktopPointer { location { x y } } }"
    /// `NudgeDesktopPointer`, as docs/design/desktop-pointer-media-operations.graphql has it.
    static let nudge = "mutation NudgeDesktopPointer { desktopNudgePointer { outcome } }"

    // MARK: The pointer position

    /// The read needs no Accessibility consent, so the host answers it. The answer is the position that a
    /// null-source Core Graphics event reports, in screen coordinates, within one point. The pointer can move
    /// during the test, so the answer is held to the box of the readings before and after it.
    @Test func aReaderReadsThePointerPositionInScreenCoordinates() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let before = try #require(CGEvent(source: nil)?.location)
        let reply = try await harness.post(Self.pointer, authorization: "Bearer \(reader)")
        let after = try #require(CGEvent(source: nil)?.location)
        #expect(reply.errors.isEmpty)
        guard let answer = reply.data?["desktopPointer"] as? [String: Any] else {
            // Null is the answer only when AppKit lists no screen. Koine never invents a position.
            #expect(reply.data?["desktopPointer"] is NSNull)
            #expect(await MainActor.run { NSScreen.screens.isEmpty }, "null though AppKit lists a screen")
            await harness.stop()
            return
        }
        let location = try #require(answer["location"] as? [String: Double])
        let x = try #require(location["x"])
        let y = try #require(location["y"])
        #expect(x >= min(before.x, after.x) - 1 && x <= max(before.x, after.x) + 1, "x \(x), \(before), \(after)")
        #expect(y >= min(before.y, after.y) - 1 && y <= max(before.y, after.y) + 1, "y \(y), \(before), \(after)")
        await harness.stop()
    }

    // MARK: Authority

    /// The position is read data: a control-only grant cannot read it.
    @Test(arguments: [pointer, "{ desktopPointer { __typename } }"])
    func thePointerReadNeedsDesktopRead(query: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let controller = try await harness.consoleGrant(label: "controller", capabilities: ["desktop:control"])
        let reply = try await harness.post(query, authorization: "Bearer \(controller)")
        #expect(reply.data?["desktopPointer"] == nil || reply.data?["desktopPointer"] is NSNull)
        let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "desktop:read")
        await harness.stop()
    }

    /// A read-only grant cannot act: the nudge is refused before the provider is asked, so the test moves
    /// nothing. A grant with no capability is refused the same way.
    @Test(arguments: [["desktop:read"], [String]()])
    func nudgingWithoutDesktopControlIsRefusedBeforeTheProviderIsAsked(capabilities: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: capabilities)
        let before = CGEvent(source: nil)?.location
        let reply = try await harness.post(Self.nudge, authorization: "Bearer \(reader)")
        #expect(reply.data?["desktopNudgePointer"] == nil || reply.data?["desktopNudgePointer"] is NSNull)
        let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "desktop:control")
        #expect(CGEvent(source: nil)?.location == before, "the pointer did not move")
        await harness.stop()
    }

    // MARK: Descriptions

    /// The served descriptions state the reach of each new root and say that an earlier grant has it too. The
    /// read types state desktop:read. The receipt states its control authority and carries the outcome alone.
    @Test func theNewDescriptionsDiscloseTheWiderReach() async throws {
        let harness = try await DesktopProviderTests.harness()
        let anyone = try await harness.consoleGrant(label: "anyone", capabilities: [])
        let reply = try await harness.post(
            """
            { q: __type(name: "Query") { fields { name description } } \
            m: __type(name: "Mutation") { fields { name description } } \
            pointer: __type(name: "DesktopPointer") { description fields { name } } \
            point: __type(name: "DesktopPoint") { description fields { name } } \
            receipt: __type(name: "DesktopPointerNudgeReceipt") { description fields { name } } \
            outcome: __type(name: "DesktopPointerNudgeOutcome") { enumValues { name } } }
            """,
            authorization: "Bearer \(anyone)"
        )
        #expect(reply.errors.isEmpty)
        var descriptions: [String: String] = [:]
        for key in ["q", "m"] {
            for field in (reply.data?[key] as? [String: Any])?["fields"] as? [[String: Any]] ?? [] {
                descriptions[field["name"] as? String ?? ""] = field["description"] as? String
            }
        }
        let pointer = try #require(descriptions["desktopPointer"])
        #expect(pointer.hasPrefix("desktop:read. Where the pointer is now, in screen coordinates."))
        #expect(pointer.contains("Koine never invents a position."))
        #expect(pointer.contains("This read needs no Accessibility consent."))
        #expect(pointer.contains("A desktop:read grant from an earlier Koine version has this reach too."))
        let nudge = try #require(descriptions["desktopNudgePointer"])
        #expect(nudge.hasPrefix("desktop:control. Nudges the pointer"))
        #expect(nudge.contains("one point to the right and back, with two mouse-moved events"))
        #expect(nudge.contains("The pointer ends where it started."))
        #expect(nudge.contains("It never clicks, and it posts nothing while a pointer button is held."))
        #expect(nudge.contains("A desktop:control grant from an earlier Koine version can do this too."))

        func type(_ key: String) throws -> [String: Any] { try #require(reply.data?[key] as? [String: Any]) }
        func fields(_ key: String) throws -> [String] {
            try (type(key)["fields"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
        }
        #expect((try type("pointer")["description"] as? String)?.hasPrefix("All fields require desktop:read.") == true)
        #expect(try fields("pointer") == ["location"])
        #expect((try type("point")["description"] as? String)?.hasPrefix("All fields require desktop:read.") == true)
        #expect(try fields("point") == ["x", "y"])
        let receipt = try #require(try type("receipt")["description"] as? String)
        #expect(receipt.hasPrefix("Control-authorized output. It carries no pointer position"))
        #expect(try fields("receipt") == ["outcome"], "the receipt carries no read data")
        let outcomes = (try type("outcome")["enumValues"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
        #expect(outcomes == ["NUDGED", "POINTER_BUTTON_HELD"])
        await harness.stop()
    }

    // MARK: Host feature

    /// The core serves both desktop disclosures and advertises both desktop features. The provider requires
    /// desktop-disclosures-v2 alone, because its reach is the reach that the 0.6.0 text states.
    @Test func theHostAdvertisesTheFeatureTheBundleRequiresAndServesTheDisclosures() throws {
        #expect(koineHostFeatures.isSuperset(of: ["desktop-disclosures-v1", "desktop-disclosures-v2"]))
        #expect(desktopDisclosuresFeature == "desktop-disclosures-v1")
        #expect(desktopDisclosuresV2Feature == "desktop-disclosures-v2")
        #expect(CapabilityDisclosures.all.map(\.capability).prefix(2) == ["desktop:control", "desktop:read"])
        let manifest = try #require(
            JSONSerialization.jsonObject(
                with: Data(
                    contentsOf: try DesktopProviderTests.root().appendingPathComponent("Desktop.koineprovider/manifest.json"))
            ) as? [String: Any])
        #expect(manifest["requiredFeatures"] as? [String] == ["desktop-disclosures-v2"])
        #expect(manifest["version"] as? String == "1.0.2" && manifest["schemaVersion"] as? String == "1.0.2")
    }

    /// A host that does not advertise desktop-disclosures-v2 refuses the real desktop bundle before it loads, and
    /// the row names the missing feature. The host here advertises desktop-disclosures-v1, as the released 0.5.0
    /// host does, so that feature does not admit desktop 1.0.2.
    @Test func aHostWithoutTheFeatureRefusesTheDesktopBundleBeforeItLoads() async throws {
        let recorder = ProviderSelectionTests.Recorder()
        var seam = ProviderLoader.Seam()
        let team = try DesktopProviderTests.team()
        seam.hostTeam = { team }
        seam.load = { try recorder.load($0) }
        seam.assessment = { recorder.assess($0) }
        let root = try DesktopProviderTests.root()
        let catalogue = try DesktopProviderTests.catalogue()
        let sealed = seam
        func select(_ host: HostCompatibility) async throws -> ProviderSelectionResult {
            try await withCheckedThrowingContinuation { continuation in
                Harness.constructing.async {
                    continuation.resume(
                        with: Result {
                            try ProviderLoader.selectAndLoad(
                                roots: [.bundled(root)], catalogue: .success(catalogue),
                                staging: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString),
                                host: host, seam: sealed)
                        })
                }
            }
        }
        let released = koineHostFeatures.subtracting(["desktop-disclosures-v2"])
        #expect(released.contains("desktop-disclosures-v1"))
        let result = try await select(HostCompatibility(features: released))
        let desktop = try #require(result.reports.first { $0.provider == "desktop" })
        guard case .incompatible(let reason) = desktop.outcome else {
            Issue.record("the desktop bundle was not refused as incompatible: \(desktop.outcome)")
            return
        }
        #expect(reason.contains("desktop-disclosures-v2"), Comment(rawValue: reason))
        #expect(!reason.contains("desktop-disclosures-v1"), Comment(rawValue: reason))
        #expect(!recorder.attempts.map(\.providerId).contains("desktop"), "it was never loaded")

        // The control: the same bundle on a host that advertises the feature is not refused for it.
        let control = try await select(HostCompatibility(features: koineHostFeatures))
        let accepted = try #require(control.reports.first { $0.provider == "desktop" })
        if case .incompatible = accepted.outcome { Issue.record("refused though the host advertises the feature") }
    }
}
