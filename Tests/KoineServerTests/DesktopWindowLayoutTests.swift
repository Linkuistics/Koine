import AppKit
import Foundation
import KoineCore
import KoineProviderLoader
import KoineServer
import Testing

/// The window layout reads and frame setting of the real desktop bundle, loaded by the native loader and
/// asked over loopback HTTP (docs/specs/machine.md, "Window layout"). Only what moves nothing is asked here:
/// the display list, the authority of every new field, the window list as far as this host's consent allows,
/// and every frame-setting refusal that comes before an Accessibility write. Moving a real window is the VM
/// acceptance (`window-layout-acceptance-k6`). `task test` builds the bundle.
@Suite struct DesktopWindowLayoutTests {
    static let displays = "{ desktopDisplays { ref frame { x y width height } visibleFrame { x y width height } primary } }"
    static let windows = """
        { desktopWindows { window { ref title observation application { ref name } frame { x y width height } } \
        order visibility } }
        """
    /// `SetDesktopWindowFrame`, as docs/design/desktop-window-layout-operations.graphql has it.
    static let setFrame = """
        mutation SetDesktopWindowFrame($ref: Reference!, $frame: DesktopRectInput!) { \
        desktopSetWindowFrame(ref: $ref, frame: $frame) { ref } }
        """
    /// `DesktopWindowOnTopAt`, as docs/design/desktop-window-layout-operations.graphql has it.
    static let onTop = """
        query DesktopWindowOnTopAt($ref: Reference!, $point: DesktopPointInput!) { \
        desktopWindowOnTop(ref: $ref, point: $point) }
        """
    static let staleWindow = "koine://desktop/window/1000000/5/00ab34cd56ef7890/1"
    static var someFrame: [String: Any] { ["x": 0, "y": 25, "width": 720, "height": 450] }

    // MARK: Displays

    /// The display list needs no Accessibility consent, so the host answers it. It holds every active display,
    /// one of them primary at the origin, each visible frame inside its frame or null.
    @Test func aReaderListsTheActiveDisplaysInScreenCoordinates() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let reply = try await harness.post(Self.displays, authorization: "Bearer \(reader)")
        #expect(reply.errors.isEmpty)
        let displays = try #require(reply.data?["desktopDisplays"] as? [[String: Any]])

        var count: UInt32 = 0
        try #require(CGGetActiveDisplayList(0, nil, &count) == .success)
        #expect(displays.count == Int(count), "every active display, none invented")
        let primary = displays.filter { $0["primary"] as? Bool == true }
        #expect(primary.count == 1)
        let origin = try #require(primary.first?["frame"] as? [String: Double])
        #expect(origin["x"] == 0 && origin["y"] == 0, "the primary display's top-left corner is the origin")
        #expect(origin["width"] == Double(CGDisplayBounds(CGMainDisplayID()).width))
        let xs = try displays.map { try #require(($0["frame"] as? [String: Double])?["x"]) }
        #expect(xs == xs.sorted(), "left to right")
        for display in displays {
            let ref = try #require(display["ref"] as? String)
            #expect(ref.hasPrefix("koine://desktop/display/"))
            let frame = try #require(display["frame"] as? [String: Double])
            guard let visible = display["visibleFrame"] as? [String: Double] else {
                #expect(display["visibleFrame"] is NSNull)
                continue
            }
            let inside = try visible["x"]! >= frame["x"]! && visible["y"]! >= frame["y"]!
                && #require(visible["x"]) + #require(visible["width"]) <= frame["x"]! + frame["width"]!
                && #require(visible["y"]) + #require(visible["height"]) <= frame["y"]! + frame["height"]!
            #expect(inside, "the visible frame lies inside the frame: \(display)")
        }
        await harness.stop()
    }

    // MARK: Authority

    @Test(arguments: [
        "{ desktopDisplays { ref } }", "{ desktopWindows { order } }",
        "{ desktopWindowOnTop(ref: \"\(staleWindow)\", point: { x: 0, y: 0 }) }",
    ])
    func everyReadNeedsDesktopRead(query: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let controller = try await harness.consoleGrant(label: "controller", capabilities: ["desktop:control"])
        let reply = try await harness.post(query, authorization: "Bearer \(controller)")
        let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "desktop:read")
        await harness.stop()
    }

    /// A read-only grant cannot act: the mutation is refused before the provider is asked.
    @Test func settingAFrameWithoutDesktopControlIsRefusedBeforeTheProviderIsAsked() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let reply = try await harness.post(
            Self.setFrame, variables: ["ref": Self.staleWindow, "frame": Self.someFrame],
            authorization: "Bearer \(reader)"
        )
        let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["requiredCapability"] as? String == "desktop:control")
        await harness.stop()
    }

    // MARK: Frame setting

    /// An empty or negative size is an invalid argument, an error with no kind, and Koine attempts nothing: it is
    /// decided before the reference, so even a stale reference gets this error.
    @Test(arguments: [(0.0, 450.0), (720.0, -1.0)])
    func aFrameWithoutAPositiveSizeIsAnInvalidArgument(width: Double, height: Double) async throws {
        let frame: [String: Any] = ["x": 0, "y": 0, "width": width, "height": height]
        let harness = try await DesktopProviderTests.harness()
        let controller = try await harness.consoleGrant(label: "controller", capabilities: ["desktop:control"])
        let reply = try await harness.post(
            Self.setFrame, variables: ["ref": Self.staleWindow, "frame": frame], authorization: "Bearer \(controller)"
        )
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["desktopSetWindowFrame"])
        #expect((error["extensions"] as? [String: Any])?["kind"] == nil)
        #expect((error["message"] as? String)?.contains("greater than zero") == true)
        await harness.stop()
    }

    /// Decided before any Accessibility call, so these hold on the host and move nothing there. The grant has no
    /// desktop:read: the action and its receipt need control alone.
    @Test(arguments: [
        staleWindow, "LIVE-WINDOW-OTHER-SESSION", "LIVE-APPLICATION", "koine://desktop/display/1",
        "koine://desktop/window/412/5/SHORT/7",
    ])
    func settingTheFrameOfAReferenceThatNamesNoHeldWindowIsUnavailable(reference: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let controller = try await harness.consoleGrant(label: "controller", capabilities: ["desktop:control"])
        let pid = try DesktopProviderTests.running().processIdentifier
        let start = try DesktopProviderTests.startMicroseconds(pid)
        let ref =
            switch reference {
            case "LIVE-APPLICATION": "koine://desktop/application/\(pid)/\(start)"
            case "LIVE-WINDOW-OTHER-SESSION": "koine://desktop/window/\(pid)/\(start)/00ab34cd56ef7890/1"
            default: reference
            }
        let reply = try await harness.post(
            Self.setFrame, variables: ["ref": ref, "frame": Self.someFrame], authorization: "Bearer \(controller)"
        )
        try DesktopProviderTests.expectUnavailable(reply, at: "desktopSetWindowFrame")
        await harness.stop()
    }

    // MARK: Visibility at a point

    /// The point query resolves its reference as `desktopWindow` does, so a reference that names no held window
    /// is unavailable. Decided before any Accessibility call, so these hold with or without consent.
    @Test(arguments: [
        staleWindow, "LIVE-WINDOW-OTHER-SESSION", "LIVE-APPLICATION", "koine://desktop/display/1",
        "koine://desktop/window/412/5/SHORT/7",
    ])
    func askingAboutAReferenceThatNamesNoHeldWindowIsUnavailable(reference: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let pid = try DesktopProviderTests.running().processIdentifier
        let start = try DesktopProviderTests.startMicroseconds(pid)
        let ref =
            switch reference {
            case "LIVE-APPLICATION": "koine://desktop/application/\(pid)/\(start)"
            case "LIVE-WINDOW-OTHER-SESSION": "koine://desktop/window/\(pid)/\(start)/00ab34cd56ef7890/1"
            default: reference
            }
        let reply = try await harness.post(
            Self.onTop, variables: ["ref": ref, "point": ["x": 10, "y": 10]], authorization: "Bearer \(reader)"
        )
        try DesktopProviderTests.expectUnavailable(reply, at: "desktopWindowOnTop")
        await harness.stop()
    }

    /// A point outside every display is inside no bounds in the window server's list. So for every listed
    /// window the answer is `NOT_ON_TOP`, or `UNKNOWN` without a link, and never `ON_TOP`. Asking moves
    /// nothing. Without consent for the test process, the list is a permission error and nothing is asked.
    @Test func aPointOutsideEveryDisplayIsNeverOnTop() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let listed = try await harness.post(
            "{ desktopWindows { window { ref } visibility } }", authorization: "Bearer \(reader)")
        guard AXIsProcessTrusted(), listed.errors.isEmpty,
            let rows = listed.data?["desktopWindows"] as? [[String: Any]]
        else {
            await harness.stop()
            return
        }
        for row in rows.prefix(5) {
            let ref = try #require((row["window"] as? [String: Any])?["ref"] as? String)
            let reply = try await harness.post(
                Self.onTop, variables: ["ref": ref, "point": ["x": -1_000_000, "y": -1_000_000]],
                authorization: "Bearer \(reader)"
            )
            // A window can close between the two reads.
            if let error = reply.errors.first {
                #expect((error["extensions"] as? [String: Any])?["kind"] as? String == "unavailable", "\(error)")
                continue
            }
            let answer = try #require(reply.data?["desktopWindowOnTop"] as? String)
            #expect(answer == "NOT_ON_TOP" || answer == "UNKNOWN", "\(row): \(answer)")
            if row["visibility"] as? String == "OFF_SCREEN" { #expect(answer == "NOT_ON_TOP") }
        }
        await harness.stop()
    }

    /// A display reference names no window or application, so the window reads raise unavailable for it.
    @Test(arguments: ["desktopWindow", "desktopApplicationByReference"])
    func aDisplayReferenceIsTheWrongKindForTheWindowReads(field: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let listed = try await harness.post("{ desktopDisplays { ref } }", authorization: "Bearer \(reader)")
        let display = try #require((listed.data?["desktopDisplays"] as? [[String: Any]])?.first?["ref"] as? String)
        let reply = try await harness.post("{ \(field)(ref: \"\(display)\") { ref } }", authorization: "Bearer \(reader)")
        try DesktopProviderTests.expectUnavailable(reply, at: field)
        await harness.stop()
    }

    // MARK: Window list

    /// Without Accessibility consent the list is an OS permission error, never an empty list. With consent,
    /// every row has the designed shape. A row is `ON_SCREEN` exactly when it has an order. The orders are
    /// 0, 1, 2 and onwards, and those rows come first, front to back. Which case holds depends on this host's
    /// consent for the test process.
    @Test func theWindowListIsAPermissionErrorOrRowsWithKnownOrdersFirst() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let reply = try await harness.post(Self.windows, authorization: "Bearer \(reader)")
        if !AXIsProcessTrusted() {
            let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any])
            #expect(extensions["kind"] as? String == "permission")
            #expect(extensions["permissionClass"] as? String == "os-permission")
            // The root is a non-null list, so its error nulls the whole data: never an empty list.
            #expect(reply.data?["desktopWindows"] == nil)
        } else if reply.errors.isEmpty {
            let rows = try #require(reply.data?["desktopWindows"] as? [[String: Any]])
            let orders = rows.map { $0["order"] as? Int }
            let known = orders.prefix { $0 != nil }.compactMap { $0 }
            #expect(known == Array(0..<known.count), "the known orders come first, front to back: \(orders)")
            #expect(orders.dropFirst(known.count).allSatisfy { $0 == nil }, "\(orders)")
            for row in rows {
                let visibility = try #require(row["visibility"] as? String)
                #expect(["ON_SCREEN", "OFF_SCREEN", "UNKNOWN"].contains(visibility))
                #expect((visibility == "ON_SCREEN") == (row["order"] as? Int != nil), "\(row)")
                let window = try #require(row["window"] as? [String: Any])
                #expect((window["ref"] as? String)?.hasPrefix("koine://desktop/window/") == true)
                #expect(window["observation"] as? String == "CURRENT", "windows on other Spaces are not listed")
                #expect(((window["application"] as? [String: Any])?["ref"] as? String)?
                    .hasPrefix("koine://desktop/application/") == true)
            }
        } else {
            // An application that does not answer fails the read with its name, as the contract states.
            let extensions = reply.errors.first?["extensions"] as? [String: Any]
            #expect(extensions?["kind"] as? String == "failed", "\(reply.errors)")
        }
        await harness.stop()
    }

    // MARK: Disclosure

    /// The served descriptions state the reach of each new root and say that an earlier grant has it too.
    @Test func theNewRootDescriptionsDiscloseTheWiderReach() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: [])
        let reply = try await harness.post(
            "{ q: __type(name: \"Query\") { fields { name description } } m: __type(name: \"Mutation\") { fields { name description } } }",
            authorization: "Bearer \(reader)"
        )
        #expect(reply.errors.isEmpty)
        var descriptions: [String: String] = [:]
        for key in ["q", "m"] {
            for field in (reply.data?[key] as? [String: Any])?["fields"] as? [[String: Any]] ?? [] {
                descriptions[field["name"] as? String ?? ""] = field["description"] as? String
            }
        }
        let windows = try #require(descriptions["desktopWindows"])
        #expect(windows.hasPrefix("desktop:read."))
        #expect(windows.contains("every application with a Dock icon, not only the captured application"))
        #expect(windows.contains("A desktop:read grant from an earlier Koine version has this reach too."))
        let onTop = try #require(descriptions["desktopWindowOnTop"])
        #expect(onTop.hasPrefix("desktop:read."))
        #expect(onTop.contains("The answer is UNKNOWN when Koine cannot link the window"))
        let displays = try #require(descriptions["desktopDisplays"])
        #expect(displays.contains("A desktop:read grant from an earlier Koine version has this reach too."))
        let setFrame = try #require(descriptions["desktopSetWindowFrame"])
        #expect(setFrame.hasPrefix("desktop:control."))
        #expect(setFrame.contains("turns off the application's enhanced accessibility setting"))
        #expect(setFrame.contains("A desktop:control grant from an earlier Koine version can do this too."))
        await harness.stop()
    }

    /// The core serves both desktop disclosures, and the provider requires the feature that says so.
    @Test func theHostAdvertisesTheFeatureTheBundleRequiresAndServesTheDisclosures() throws {
        #expect(koineHostFeatures.contains("desktop-disclosures-v1"))
        #expect(desktopDisclosuresFeature == "desktop-disclosures-v1")
        #expect(CapabilityDisclosures.all.map(\.capability).prefix(2) == ["desktop:control", "desktop:read"])
        let manifest = try #require(
            JSONSerialization.jsonObject(
                with: Data(
                    contentsOf: try DesktopProviderTests.root().appendingPathComponent("Desktop.koineprovider/manifest.json"))
            ) as? [String: Any])
        #expect(manifest["requiredFeatures"] as? [String] == ["desktop-disclosures-v1"])
        #expect(manifest["version"] as? String == "1.0.1" && manifest["schemaVersion"] as? String == "1.0.1")
    }

    /// A host that does not advertise the feature refuses the real desktop bundle before it loads, and the row
    /// names the missing feature. This is what the released 0.4.1 host does with desktop 1.0.1.
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
        let result = try await select(HostCompatibility(features: koineHostFeatures.subtracting(["desktop-disclosures-v1"])))
        let desktop = try #require(result.reports.first { $0.provider == "desktop" })
        guard case .incompatible(let reason) = desktop.outcome else {
            Issue.record("the desktop bundle was not refused as incompatible: \(desktop.outcome)")
            return
        }
        #expect(reason.contains("desktop-disclosures-v1"), Comment(rawValue: reason))
        #expect(!recorder.attempts.map(\.providerId).contains("desktop"), "it was never loaded")

        // The control: the same bundle on a host that advertises the feature is not refused for it.
        let control = try await select(HostCompatibility(features: koineHostFeatures))
        let accepted = try #require(control.reports.first { $0.provider == "desktop" })
        if case .incompatible = accepted.outcome { Issue.record("refused though the host advertises the feature") }
    }
}
