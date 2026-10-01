import Foundation
import Testing

@testable import KoineServer

/// The workspace provider as an independently built, signed bundle (N): built by
/// its own build definition, sealed with Koine's identity, placed in the in-application
/// root beside desktop, chosen by the sealed catalogue and loaded by the selection-aware
/// loader, then asked over loopback HTTP. `task test` builds it.
///
/// **No launch, open or reveal runs on this host, and no browser is driven.** Every
/// action here is decided before submission: refused for authority, refused as input,
/// or answered by the real native adapter's inspection as an absent or mismatched
/// application. A well-formed URL is never sent from this host, since its answer
/// would be a real browser opening it; real launches and opens are the signed VM's.
@Suite struct WorkspaceProviderTests {
    static let controls = ["workspace:control", "desktop:control"]

    static func launch(_ identifier: String, path: String? = nil) -> String {
        let path = path.map { #", applicationPath: "\#($0)""# } ?? ""
        return """
            mutation { launch: workspaceLaunchApplication(application: { bundleIdentifier: "\(identifier)"\(path) }) {
              status value { process { pid startedAt } } dependency { reason guidance } } }
            """
    }

    /// The URL travels as a variable, so every byte of it reaches the field as written.
    static let openURL = """
        mutation($url: String!) { open: workspaceOpenURL(url: $url) {
          status value { process { pid startedAt } } dependency { reason guidance } } }
        """

    // MARK: Loading

    @Test func theSignedBundleLoadsBesideDesktopFromTheInApplicationRoot() async throws {
        let harness = try await DesktopProviderTests.harness()
        #expect(harness.server.providerDiagnostics.isEmpty)
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let reply = try await harness.post(
            "{ koineManagement { providers { provider version schemaVersion state origin selection reason } } }",
            authorization: "Bearer \(manager)"
        )
        #expect(reply.errors.isEmpty)
        let rows = try #require((reply.data?["koineManagement"] as? [String: Any])?["providers"] as? [[String: Any]])
        for identity in ["desktop", "workspace"] {
            let row = try #require(rows.first { $0["provider"] as? String == identity }, "\(identity) is missing")
            #expect(row["state"] as? String == "ACTIVE", "\(identity)")
            #expect(row["origin"] as? String == "BUNDLED", "\(identity)")
            #expect(row["selection"] as? String == "SELECTED", "\(identity)")
            #expect(row["version"] as? String == "1.0.0" && row["schemaVersion"] as? String == "1.0.0")
            #expect(row["reason"] is NSNull, "a healthy shipped row carries no reason")
        }
        #expect(rows.count == 2, "no reserved-only or missing row: \(rows)")
        await harness.stop()
    }

    @Test func itsCapabilitiesArePublishedBesideDesktops() async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let reply = try await harness.post(
            "{ koine { availableCapabilities } }", authorization: "Bearer \(credential)")
        let available = try #require((reply.data?["koine"] as? [String: Any])?["availableCapabilities"] as? [String])
        // Every provider publishes both classes; which one a field needs is the field's registration.
        for capability in ["workspace:control", "workspace:read", "desktop:control", "desktop:read"] {
            #expect(available.contains(capability), "\(capability)")
        }
        await harness.stop()
    }

    // MARK: The served contribution

    /// Every definition the bundle serves is a block of the design file, verbatim, and the
    /// only roots are the launch and URL ones: each later root lands with its leaf.
    @Test func theServedSDLIsTheLaunchAndURLRootsAndTheirReachVerbatimFromTheDesignFile() throws {
        let served = try WorkspaceCompositionTests.schemaSDL()
        let design = try String(
            contentsOf: Self.repository.appending(path: "docs/design/workspace-schema.graphql"), encoding: .utf8)
        let blocks = served.components(separatedBy: "\n\n").filter { $0.contains("\"\"\"") }
        #expect(blocks.count == 8)
        for block in blocks where !block.hasPrefix("extend type Mutation") {
            #expect(design.contains(block), "not verbatim from the design file: \(block.prefix(60))")
        }
        // The roots are a documentation line and a field line each, in the design's order.
        let lines = try #require(blocks.first { $0.hasPrefix("extend type Mutation") })
            .components(separatedBy: "\n").filter { !$0.isEmpty }.dropFirst().dropLast()
        try #require(lines.count == 4, "two roots, each a documentation line and a field line")
        let roots = Array(lines)
        for pair in stride(from: 0, to: roots.count, by: 2) {
            #expect(design.contains(roots[pair] + "\n" + roots[pair + 1]), "not verbatim: \(roots[pair + 1])")
        }
        #expect(roots[1].hasPrefix("  workspaceLaunchApplication(") && roots[3].hasPrefix("  workspaceOpenURL("))
        for later in ["workspaceOpenPath", "workspaceRevealPath", "WorkspaceRevealResult", "WorkspaceRevealReceipt"] {
            #expect(!served.contains(later), "\(later) has not landed")
        }
    }

    @Test func theLoadedProviderServesTheLaunchAndURLRootsAndNoOther() async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let reply = try await harness.post(
            """
            { m: __type(name: "Mutation") { fields { name description args { name type { kind ofType { name } } } } }
              o: __type(name: "WorkspaceOpenResult") { fields { name } } }
            """, authorization: "Bearer \(credential)")
        let fields = try #require(
            ((reply.data?["m"] as? [String: Any])?["fields"] as? [[String: Any]]))
        let workspace = fields.filter { ($0["name"] as? String)?.hasPrefix("workspace") == true }
        #expect(
            workspace.compactMap { $0["name"] as? String } == ["workspaceLaunchApplication", "workspaceOpenURL"])
        for field in workspace {
            let description = try #require(field["description"] as? String)
            #expect(description.hasPrefix("Requires workspace:control AND desktop:control."))
        }
        // The URL root takes one required string.
        let url = try #require(workspace.last)
        let args = try #require(url["args"] as? [[String: Any]])
        #expect(args.count == 1 && args[0]["name"] as? String == "url")
        let type = try #require(args[0]["type"] as? [String: Any])
        #expect(type["kind"] as? String == "NON_NULL" && (type["ofType"] as? [String: Any])?["name"] as? String == "String")
        #expect((reply.data?["o"] as? [String: Any])?["fields"] is [Any])
        await harness.stop()
    }

    // MARK: Authority through the real bundle

    @Test(arguments: [
        ["workspace:control"], ["desktop:control"], ["desktop:read"], ["workspace:read", "desktop:read"], [],
    ])
    func eitherControlAloneIsRefusedBeforeInspection(held: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: held)
        let reply = try await harness.post(
            Self.launch("com.example.koine.no-such-app"), authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["launch"])
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["phase"] as? String == "authorization")
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(reply.data == nil, "preflight refuses the whole request; nothing ran")
        await harness.stop()
    }

    // MARK: The real adapter's inspection, which submits nothing

    @Test func bothControlsWithoutReadsReachTheProviderAndAnAbsentApplicationIsDependencyAbsence() async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        let reply = try await harness.post(
            Self.launch("com.example.koine.no-such-app"), authorization: "Bearer \(credential)")
        #expect(reply.errors.isEmpty, Comment(rawValue: "\(reply.errors)"))
        let launch = try #require(reply.data?["launch"] as? [String: Any])
        #expect(launch["status"] as? String == "DEPENDENCY_UNAVAILABLE")
        #expect(launch["value"] is NSNull)
        let dependency = try #require(launch["dependency"] as? [String: Any])
        #expect(dependency["reason"] as? String == "APPLICATION_NOT_INSTALLED")
        #expect((dependency["guidance"] as? String)?.contains("com.example.koine.no-such-app") == true)
        await harness.stop()
    }

    @Test func aConstrainedPathThatDoesNotExistIsNotInstalledEvenForARealIdentifier() async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        // Real identifier, absent path: nothing is substituted, so nothing launches.
        for path in ["/Users/koine-test/no such/Notes.app", "/private/var/empty/dangling.app"] {
            let reply = try await harness.post(
                Self.launch("com.apple.Notes", path: path), authorization: "Bearer \(credential)")
            let launch = try #require(reply.data?["launch"] as? [String: Any], Comment(rawValue: "\(reply.errors)"))
            #expect(launch["status"] as? String == "DEPENDENCY_UNAVAILABLE")
            #expect((launch["dependency"] as? [String: Any])?["reason"] as? String == "APPLICATION_NOT_INSTALLED")
        }
        await harness.stop()
    }

    @Test func aRealBundleWithAnotherIdentifierIsAMismatchAndNothingIsSubstituted() async throws {
        let notes = "/System/Applications/Notes.app"
        try #require(FileManager.default.fileExists(atPath: notes), "Notes is not installed at its system path.")
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        // Notes is present, and is not this identifier; a mismatch is decided before any submission.
        let reply = try await harness.post(
            Self.launch("com.example.koine.not-notes", path: notes), authorization: "Bearer \(credential)")
        let launch = try #require(reply.data?["launch"] as? [String: Any], Comment(rawValue: "\(reply.errors)"))
        #expect(launch["status"] as? String == "DEPENDENCY_UNAVAILABLE")
        let dependency = try #require(launch["dependency"] as? [String: Any])
        #expect(dependency["reason"] as? String == "APPLICATION_IDENTITY_MISMATCH")
        #expect(!(dependency["guidance"] as? String ?? "").contains("com.apple.Notes"), "the installed identifier is not disclosed")
        await harness.stop()
    }

    @Test func aBlankIdentifierAndAnUnusablePathAreInputErrorsAtTheOriginalPathWithNoKind() async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        for query in [Self.launch("  "), Self.launch("com.apple.Notes", path: "relative/Notes.app"),
            Self.launch("com.apple.Notes", path: "")]
        {
            let reply = try await harness.post(query, authorization: "Bearer \(credential)")
            let error = try #require(reply.errors.first)
            #expect(error["path"] as? [String] == ["launch"])
            #expect((error["extensions"] as? [String: Any])?["kind"] == nil, "an input error carries no kind")
            #expect(reply.data?["launch"] is NSNull)
        }
        await harness.stop()
    }

    // MARK: The URL root through the real bundle

    @Test(arguments: [
        ["workspace:control"], ["desktop:control"], ["desktop:read"], ["workspace:read", "desktop:read"], [],
    ])
    func eitherControlAloneIsRefusedForTheURLRootBeforeAnythingIsLookedUp(held: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: held)
        // A well-formed URL, so a missing refusal would send it to a browser; none can.
        let reply = try await harness.post(
            Self.openURL, variables: ["url": "https://example.com/?q=koine"], authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["open"])
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["phase"] as? String == "authorization")
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(reply.data == nil, "preflight refuses the whole request; nothing ran")
        await harness.stop()
    }

    @Test(arguments: [
        "", "ftp://example.com/", "file:///etc/hosts", "javascript:alert(1)", "example.com", "https://",
        "https://example.com/a b", "https://example.com/a\\b", "https://user:pw@example.com/",
        "https://example.com/%zz", "https://example.com/caf\u{E9}", "https://b\u{FC}cher.example/",
        "https://xn--abc-.example/", "https://exa%6Dple.com/", "https://example.com/\u{7}",
    ])
    func aMalformedURLIsAnInputErrorAtTheOriginalPathWithNoKind(_ url: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        let reply = try await harness.post(
            Self.openURL, variables: ["url": url], authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first, Comment(rawValue: "\(url.debugDescription) was accepted"))
        #expect(error["path"] as? [String] == ["open"])
        #expect((error["extensions"] as? [String: Any])?["kind"] == nil, "an input error carries no kind")
        #expect(reply.data?["open"] is NSNull)
        await harness.stop()
    }

    static var repository: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
