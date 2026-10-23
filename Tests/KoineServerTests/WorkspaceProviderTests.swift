import Foundation
import Testing

@testable import KoineServer

/// The workspace provider as an independently built, signed bundle (N): built by
/// its own build definition, sealed with Koine's identity, placed in the in-application
/// root beside desktop, chosen by the sealed catalogue and loaded by the selection-aware
/// loader, then asked over loopback HTTP. `task test` builds it.
///
/// **No launch, open or reveal runs on this host, and no browser or document is driven.**
/// Every action here is decided before submission: refused for authority, refused as
/// input, or answered by the real native adapter's inspection as an absent or mismatched
/// application, a missing path or a refused payload. A well-formed URL, or a path that
/// would be opened, is never sent from this host, since its answer would be a real
/// application opening it; real launches and opens are the signed VM's.
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

    /// The path and the optional application travel as variables, so every byte of the path
    /// reaches the field as written.
    static let openPath = """
        mutation($path: String!, $application: WorkspaceApplicationInput) {
          open: workspaceOpenPath(path: $path, application: $application) {
            status value { process { pid startedAt } } dependency { reason guidance } } }
        """

    /// The reveal's path travels as a variable too.
    static let revealPath = """
        mutation($path: String!) {
          reveal: workspaceRevealPath(path: $path) { status value { path } dependency { reason guidance } } }
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
            // The workspace bundle is 1.0.2, the first cut of native discovery; the desktop provider is still 1.0.0.
            let expected = identity == "workspace" ? "1.0.2" : "1.0.0"
            #expect(row["version"] as? String == expected && row["schemaVersion"] as? String == expected, "\(identity)")
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

    /// The bundle serves the complete design of the cut: everything after the two files' header
    /// comments is identical, so every definition is a block of the design file, verbatim, and no
    /// root is missing or reworded. The four action roots and the types they reach are the repair design's,
    /// unchanged.
    @Test func theServedSDLIsTheCompleteWorkspaceDesignVerbatim() throws {
        let served = try WorkspaceCompositionTests.schemaSDL()
        func read(_ name: String) throws -> String {
            try String(contentsOf: Self.repository.appending(path: "docs/design/\(name)"), encoding: .utf8)
        }
        let design = try read("workspace-discovery-schema.graphql")
        let repair = try read("workspace-action-repair-schema.graphql")
        func body(_ text: String) -> String {
            text.components(separatedBy: "\n\n").dropFirst().joined(separator: "\n\n")
        }
        #expect(body(served) == body(design), "the served contribution is not the design file's body")
        let blocks = served.components(separatedBy: "\n\n").filter { $0.contains("\"\"\"") }
        #expect(blocks.count == 10 + 8, "ten action blocks, and the eight described blocks of the queries and their types")
        for block in blocks where !block.hasPrefix("extend type") {
            #expect(design.contains(block), "not verbatim from the design file: \(block.prefix(60))")
        }
        // The action part is the repair design's, block for block.
        for block in body(repair).components(separatedBy: "\n\n") {
            #expect(served.contains(block), "an action block changed: \(block.prefix(60))")
        }
        // The roots are a documentation line and a field line each, in the design's order.
        let lines = try #require(blocks.first { $0.hasPrefix("extend type Mutation") })
            .components(separatedBy: "\n").filter { !$0.isEmpty }.dropFirst().dropLast()
        try #require(lines.count == 8, "four roots, each a documentation line and a field line")
        let roots = Array(lines)
        for pair in stride(from: 0, to: roots.count, by: 2) {
            #expect(design.contains(roots[pair] + "\n" + roots[pair + 1]), "not verbatim: \(roots[pair + 1])")
        }
        #expect(
            roots[1].hasPrefix("  workspaceLaunchApplication(") && roots[3].hasPrefix("  workspaceOpenURL(")
                && roots[5].hasPrefix("  workspaceOpenPath(") && roots[7].hasPrefix("  workspaceRevealPath("))
        for reached in ["WorkspaceRevealResult", "WorkspaceRevealReceipt"] {
            #expect(served.contains("type \(reached) {"), "\(reached) is reached by the last action root")
        }
        // The two query roots, and only they, are declared on Query, and their types are the search design's.
        let query = try #require(blocks.first { $0.hasPrefix("extend type Query") })
        let rootLines = query.components(separatedBy: "\n").filter { $0.hasPrefix("  workspace") }
        #expect(
            rootLines == [
                "  workspaceSpecialLocations(requests: [WorkspaceLocationRequest!]): WorkspaceSpecialLocationsResult",
                "  workspaceApplications: WorkspaceApplicationsResult",
            ])
        let search = try read("workspace-search-schema.graphql")
        func definition(_ name: String) throws -> String {
            let type = try #require(served.range(of: "type \(name) {")).lowerBound
            return String(served[type...].prefix(through: try #require(served[type...].range(of: "\n}")).upperBound))
        }
        for name in [
            "WorkspaceSpecialLocationsResult", "WorkspaceSpecialLocation", "WorkspaceDiscoveryCoverage",
            "WorkspaceApplicationsResult",
        ] {
            #expect(search.contains(try definition(name)), "\(name) is not the search design's")
        }
        // The application choice serves the fields that the index fills, with the design's name and type for each
        // and the descriptions of this release. The design's other fields wait for the cut that fills them.
        func fields(_ text: String) -> [String] {
            text.components(separatedBy: "\n").filter { $0.hasPrefix("  ") && !$0.hasPrefix("  \"\"\"") }
        }
        let designed = fields(try {
            let start = try #require(search.range(of: "type WorkspaceApplicationChoice {")).lowerBound
            return String(search[start...].prefix(through: try #require(search[start...].range(of: "\n}")).upperBound))
        }())
        let offered = fields(try definition("WorkspaceApplicationChoice"))
        #expect(offered == ["  applicationPath: String!", "  name: String", "  bundleIdentifier: String", "  sources: [WorkspaceDiscoverySource!]!"])
        for field in offered { #expect(designed.contains(field), "not the design's field: \(field)") }
    }

    @Test func theLoadedProviderServesAllFourRootsAndNoOther() async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let reply = try await harness.post(
            """
            { m: __type(name: "Mutation") { fields { name description args { name type { kind name ofType { name } } } } }
              o: __type(name: "WorkspaceOpenResult") { fields { name } }
              r: __type(name: "WorkspaceRevealResult") { fields { name } }
              p: __type(name: "WorkspaceRevealReceipt") { fields { name } } }
            """, authorization: "Bearer \(credential)")
        let fields = try #require(
            ((reply.data?["m"] as? [String: Any])?["fields"] as? [[String: Any]]))
        let workspace = fields.filter { ($0["name"] as? String)?.hasPrefix("workspace") == true }
        #expect(
            workspace.compactMap { $0["name"] as? String }
                == ["workspaceLaunchApplication", "workspaceOpenPath", "workspaceOpenURL", "workspaceRevealPath"])
        for field in workspace {
            let description = try #require(field["description"] as? String)
            #expect(description.hasPrefix("Requires workspace:control AND desktop:control."))
        }
        // The URL root takes one required string.
        let url = try #require(workspace.first { $0["name"] as? String == "workspaceOpenURL" })
        let args = try #require(url["args"] as? [[String: Any]])
        #expect(args.count == 1 && args[0]["name"] as? String == "url")
        let type = try #require(args[0]["type"] as? [String: Any])
        #expect(type["kind"] as? String == "NON_NULL" && (type["ofType"] as? [String: Any])?["name"] as? String == "String")
        // The path root takes a required string and an optional application input.
        let path = try #require(workspace.first { $0["name"] as? String == "workspaceOpenPath" })
        let pathArgs = try #require(path["args"] as? [[String: Any]])
        #expect(pathArgs.compactMap { $0["name"] as? String } == ["path", "application"])
        let pathType = try #require(pathArgs[0]["type"] as? [String: Any])
        #expect(pathType["kind"] as? String == "NON_NULL" && (pathType["ofType"] as? [String: Any])?["name"] as? String == "String")
        let applicationType = try #require(pathArgs[1]["type"] as? [String: Any])
        #expect(applicationType["kind"] as? String == "INPUT_OBJECT" && applicationType["name"] as? String == "WorkspaceApplicationInput")
        #expect((reply.data?["o"] as? [String: Any])?["fields"] is [Any])
        // The reveal root takes one required string and answers the reveal result, whose receipt is the path.
        let reveal = try #require(workspace.first { $0["name"] as? String == "workspaceRevealPath" })
        let revealArgs = try #require(reveal["args"] as? [[String: Any]])
        #expect(revealArgs.compactMap { $0["name"] as? String } == ["path"])
        let revealType = try #require(revealArgs[0]["type"] as? [String: Any])
        #expect(revealType["kind"] as? String == "NON_NULL" && (revealType["ofType"] as? [String: Any])?["name"] as? String == "String")
        let result = try #require((reply.data?["r"] as? [String: Any])?["fields"] as? [[String: Any]])
        #expect(Set(result.compactMap { $0["name"] as? String }) == ["status", "value", "dependency"])
        let receipt = try #require((reply.data?["p"] as? [String: Any])?["fields"] as? [[String: Any]])
        #expect(receipt.compactMap { $0["name"] as? String } == ["path"])
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

    // MARK: Installations through the real adapter (application-installations-k78)

    /// Where a real system bundle is reached through other spellings: a link to the bundle, a link
    /// to its folder, and the same links named with composed and decomposed Unicode. A named
    /// identifier that is not the bundle's makes each a mismatch, which is only reachable if the
    /// real adapter resolved the spelling to the bundle itself: nothing is ever submitted.
    struct Spellings {
        let directory: URL
        init() throws {
            let manager = FileManager.default
            directory = URL(fileURLWithPath: NSTemporaryDirectory())
                .appending(path: "koine-k78-\(UUID().uuidString)").resolvingSymlinksInPath()
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "link-to-notes.app").path,
                withDestinationPath: "/System/Applications/Notes.app")
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "link-to-applications").path, withDestinationPath: "/System/Applications")
            // The link is created under its decomposed name and asked for under its composed one.
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "Cafe\u{301}.app").path, withDestinationPath: "/System/Applications/Notes.app")
            // A program that is not a bundle.
            try manager.createSymbolicLink(atPath: directory.appending(path: "program").path, withDestinationPath: "/bin/ls")
            // A bundle that declares no identifier (no Info.plist at all), and one whose contents nobody
            // may read: `Bundle(url:)` answers nil for both, and only the second is a denial.
            try manager.createDirectory(
                at: directory.appending(path: "NoIdentifier.app/Contents"), withIntermediateDirectories: true)
            try manager.createDirectory(
                at: directory.appending(path: "Sealed.app/Contents"), withIntermediateDirectories: true)
            try Data("<plist version=\"1.0\"><dict/></plist>".utf8).write(
                to: directory.appending(path: "Sealed.app/Contents/Info.plist"))
            try manager.setAttributes(
                [.posixPermissions: 0], ofItemAtPath: directory.appending(path: "Sealed.app/Contents").path)
            // A folder nobody may enter, and a path inside it.
            try manager.createDirectory(at: directory.appending(path: "locked"), withIntermediateDirectories: true)
            try manager.setAttributes([.posixPermissions: 0], ofItemAtPath: directory.appending(path: "locked").path)
        }
        func path(_ name: String) -> String { directory.appending(path: name).path }
        func remove() {
            for name in ["locked", "Sealed.app/Contents"] {
                try? FileManager.default.setAttributes(
                    [.posixPermissions: 0o755], ofItemAtPath: directory.appending(path: name).path)
            }
            try? FileManager.default.removeItem(at: directory)
        }
    }

    @Test func everySpellingOfARealBundleIsResolvedToTheBundleItselfNotCompared() async throws {
        let notes = "/System/Applications/Notes.app"
        try #require(FileManager.default.fileExists(atPath: notes), "Notes is not installed at its system path.")
        let spellings = try Spellings()
        defer { spellings.remove() }
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        // The composed spelling of the name the link was created under: the file system treats them as one.
        let composed = spellings.directory.path + "/Caf\u{E9}.app"
        for path in [
            spellings.path("link-to-notes.app"), spellings.path("link-to-applications") + "/Notes.app", composed,
            spellings.path("Cafe\u{301}.app"),
        ] {
            let reply = try await harness.post(
                Self.launch("com.example.koine.not-notes", path: path), authorization: "Bearer \(credential)")
            let launch = try #require(reply.data?["launch"] as? [String: Any], Comment(rawValue: "\(path) \(reply.errors)"))
            #expect(launch["status"] as? String == "DEPENDENCY_UNAVAILABLE", Comment(rawValue: path))
            #expect(
                (launch["dependency"] as? [String: Any])?["reason"] as? String == "APPLICATION_IDENTITY_MISMATCH",
                Comment(rawValue: path))
            let open = try await harness.post(
                Self.openPath,
                variables: ["path": fixtures.text, "application": ["bundleIdentifier": "com.example.koine.not-notes", "applicationPath": path]],
                authorization: "Bearer \(credential)")
            let opened = try #require(open.data?["open"] as? [String: Any], Comment(rawValue: "\(path) \(open.errors)"))
            #expect(
                (opened["dependency"] as? [String: Any])?["reason"] as? String == "APPLICATION_IDENTITY_MISMATCH",
                Comment(rawValue: path))
        }
        await harness.stop()
    }

    @Test func aBundleLessProgramHasNoSelectorRouteAndAnUnreadableFolderIsFailedNotAbsence() async throws {
        let spellings = try Spellings()
        defer { spellings.remove() }
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)

        // A program is present and is not an application bundle: not installed, whatever identifier it is offered under.
        for identifier in ["com.apple.Notes", "com.example.koine.program"] {
            let reply = try await harness.post(
                Self.launch(identifier, path: spellings.path("program")), authorization: "Bearer \(credential)")
            let launch = try #require(reply.data?["launch"] as? [String: Any], Comment(rawValue: "\(reply.errors)"))
            #expect((launch["dependency"] as? [String: Any])?["reason"] as? String == "APPLICATION_NOT_INSTALLED")
            let open = try await harness.post(
                Self.openPath,
                variables: ["path": fixtures.text, "application": ["bundleIdentifier": identifier, "applicationPath": spellings.path("program")]],
                authorization: "Bearer \(credential)")
            let opened = try #require(open.data?["open"] as? [String: Any], Comment(rawValue: "\(open.errors)"))
            #expect((opened["dependency"] as? [String: Any])?["reason"] as? String == "APPLICATION_NOT_INSTALLED")
        }

        // A bundle that declares no identifier is a mismatch; one whose contents cannot be read is a denial,
        // which is a failure and never a different identifier.
        let anonymous = try await harness.post(
            Self.launch("com.apple.Notes", path: spellings.path("NoIdentifier.app")), authorization: "Bearer \(credential)")
        let anonymousLaunch = try #require(anonymous.data?["launch"] as? [String: Any], Comment(rawValue: "\(anonymous.errors)"))
        #expect((anonymousLaunch["dependency"] as? [String: Any])?["reason"] as? String == "APPLICATION_IDENTITY_MISMATCH")
        let sealed = try await harness.post(
            Self.launch("com.apple.Notes", path: spellings.path("Sealed.app")), authorization: "Bearer \(credential)")
        #expect(sealed.data?["launch"] is NSNull, "an unreadable bundle is not a mismatch")
        #expect((sealed.errors.first?["extensions"] as? [String: Any])?["kind"] as? String == "failed")

        // Nobody may enter the folder: the inspection is denied, which is a failure and never absence.
        let denied = spellings.path("locked") + "/Fixture.app"
        let launch = try await harness.post(
            Self.launch("com.apple.Notes", path: denied), authorization: "Bearer \(credential)")
        #expect(launch.data?["launch"] is NSNull)
        let error = try #require(launch.errors.first)
        #expect(error["path"] as? [String] == ["launch"])
        #expect((error["extensions"] as? [String: Any])?["kind"] as? String == "failed")
        let open = try await harness.post(
            Self.openPath, variables: ["path": fixtures.text, "application": ["bundleIdentifier": "com.apple.Notes", "applicationPath": denied]],
            authorization: "Bearer \(credential)")
        #expect(open.data?["open"] is NSNull)
        #expect((open.errors.first?["extensions"] as? [String: Any])?["kind"] as? String == "failed")
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

    // MARK: The path root through the real bundle

    @Test(arguments: [
        ["workspace:control"], ["desktop:control"], ["desktop:read"], ["workspace:read", "desktop:read"], [],
    ])
    func eitherControlAloneIsRefusedForThePathRootBeforeAnythingIsInspected(held: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: held)
        // A path that exists and would be opened, so a missing refusal would reach a real handler.
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let reply = try await harness.post(
            Self.openPath, variables: ["path": fixtures.text], authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["open"])
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["phase"] as? String == "authorization")
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(reply.data == nil, "preflight refuses the whole request; nothing ran")
        await harness.stop()
    }

    /// Disposable fixtures, each of which the real adapter classifies without anything being
    /// opened: a text file, a folder, a missing path, a dangling link, links to an application
    /// and to a program, a real Finder alias, a Windows executable, and a file whose name has
    /// spaces and shell punctuation.
    struct Fixtures {
        let directory: URL
        var text: String { directory.appending(path: "notes.txt").path }
        var missing: String { directory.appending(path: "gone.txt").path }

        init() throws {
            let manager = FileManager.default
            // Resolved up front: the system's temporary directory is reached through /var.
            directory = URL(fileURLWithPath: NSTemporaryDirectory())
                .appending(path: "koine-k75-\(UUID().uuidString)").resolvingSymlinksInPath()
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            try Data("hello".utf8).write(to: directory.appending(path: "notes.txt"))
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "dangling").path, withDestinationPath: "no-such-target")
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "to-notes-app").path,
                withDestinationPath: "/System/Applications/Notes.app")
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "to-ls").path, withDestinationPath: "/bin/ls")
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "loop-a").path, withDestinationPath: "loop-b")
            try manager.createSymbolicLink(
                atPath: directory.appending(path: "loop-b").path, withDestinationPath: "loop-a")
            try manager.createDirectory(at: directory.appending(path: "folder"), withIntermediateDirectories: true)
            try Data([0x4D, 0x5A, 0, 0]).write(to: directory.appending(path: "setup.exe"))
            let bookmark = try URL(fileURLWithPath: text).bookmarkData(options: .suitableForBookmarkFile)
            try URL.writeBookmarkData(bookmark, to: directory.appending(path: "alias-to-notes"))
        }

        func path(_ name: String) -> String { directory.appending(path: name).path }
        func remove() { try? FileManager.default.removeItem(at: directory) }
    }

    @Test func aMissingPathADanglingLinkAFileWithATrailingSlashAndALoopArePathNotFoundAndNothingIsSubmitted() async throws {
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        // The named application is not installed either, so the order matters: the target is reported first.
        for application: [String: String]? in [nil, ["bundleIdentifier": "com.example.koine.no-such-app"]] {
            // `realpath` alone accepts `notes.txt/` and `notes.txt/.`; the open would not.
            for path in [
                fixtures.missing, fixtures.path("dangling"), fixtures.path("notes.txt/below-a-file"),
                fixtures.text + "/", fixtures.text + "//", fixtures.text + "/.", fixtures.path("loop-a"),
                fixtures.path(String(repeating: "n", count: 300)),
            ] {
                var variables: [String: Any] = ["path": path]
                variables["application"] = application
                let reply = try await harness.post(
                    Self.openPath, variables: variables, authorization: "Bearer \(credential)")
                let open = try #require(reply.data?["open"] as? [String: Any], Comment(rawValue: "\(reply.errors)"))
                #expect(open["status"] as? String == "DEPENDENCY_UNAVAILABLE", Comment(rawValue: path))
                #expect(open["value"] is NSNull)
                #expect((open["dependency"] as? [String: Any])?["reason"] as? String == "PATH_NOT_FOUND", Comment(rawValue: path))
            }
        }
        await harness.stop()
    }

    @Test func aNamedApplicationThatIsAbsentOrTheWrongOneIsDependencyAbsenceForARealFileAndNothingIsSubmitted() async throws {
        let notes = "/System/Applications/Notes.app"
        try #require(FileManager.default.fileExists(atPath: notes), "Notes is not installed at its system path.")
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        let cases: [(application: [String: String], reason: String)] = [
            (["bundleIdentifier": "com.example.koine.no-such-app"], "APPLICATION_NOT_INSTALLED"),
            (["bundleIdentifier": "com.apple.Notes", "applicationPath": "/Users/koine-test/no such/Notes.app"], "APPLICATION_NOT_INSTALLED"),
            (["bundleIdentifier": "com.example.koine.not-notes", "applicationPath": notes], "APPLICATION_IDENTITY_MISMATCH"),
        ]
        for (application, reason) in cases {
            for path in [fixtures.text, fixtures.path("folder")] {
                let reply = try await harness.post(
                    Self.openPath, variables: ["path": path, "application": application],
                    authorization: "Bearer \(credential)")
                let open = try #require(reply.data?["open"] as? [String: Any], Comment(rawValue: "\(reply.errors)"))
                #expect(open["status"] as? String == "DEPENDENCY_UNAVAILABLE")
                #expect((open["dependency"] as? [String: Any])?["reason"] as? String == reason, Comment(rawValue: "\(application)"))
            }
        }
        await harness.stop()
    }

    @Test(arguments: [
        ("to-notes-app", "a link to an application bundle"), ("to-ls", "a link to a Mach-O program"),
        ("alias-to-notes", "a Finder alias to a document"), ("setup.exe", "a Windows executable"),
    ])
    func aRefusedPayloadIsAnInputErrorAtTheOriginalPathWithNoKindForTheDefaultAndANamedApplication(
        _ name: String, _ why: String
    ) async throws {
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        // A named application that is installed would receive it if the policy let it through.
        for application: [String: String]? in [nil, ["bundleIdentifier": "com.apple.Notes"]] {
            var variables: [String: Any] = ["path": fixtures.path(name)]
            variables["application"] = application
            let reply = try await harness.post(
                Self.openPath, variables: variables, authorization: "Bearer \(credential)")
            let error = try #require(reply.errors.first, Comment(rawValue: "\(why) was accepted"))
            #expect(error["path"] as? [String] == ["open"], Comment(rawValue: why))
            #expect((error["extensions"] as? [String: Any])?["kind"] == nil, "an input error carries no kind")
            #expect(reply.data?["open"] is NSNull, Comment(rawValue: why))
        }
        await harness.stop()
    }

    @Test(arguments: [
        "", "relative/notes.txt", "./notes.txt", "~/notes.txt", "$HOME/notes.txt", "file:///etc/hosts", " /etc/hosts",
        "/Users/koine-test/a\u{0}b",
    ])
    func anUnusablePathIsAnInputErrorAtTheOriginalPathWithNoKind(_ path: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        let reply = try await harness.post(
            Self.openPath, variables: ["path": path], authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first, Comment(rawValue: "\(path.debugDescription) was accepted"))
        #expect(error["path"] as? [String] == ["open"])
        #expect((error["extensions"] as? [String: Any])?["kind"] == nil, "an input error carries no kind")
        #expect(reply.data?["open"] is NSNull)
        await harness.stop()
    }

    @Test(arguments: [
        ["bundleIdentifier": "  "], ["bundleIdentifier": "dev.zed.Zed", "applicationPath": ""],
        ["bundleIdentifier": "dev.zed.Zed", "applicationPath": "relative/Zed.app"],
    ])
    func anUnusableApplicationIsAnInputErrorBeforeThePathIsInspected(_ application: [String: String]) async throws {
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        // The path is missing, so inspecting it first would have answered PATH_NOT_FOUND instead.
        let reply = try await harness.post(
            Self.openPath, variables: ["path": fixtures.missing, "application": application],
            authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["open"])
        #expect((error["extensions"] as? [String: Any])?["kind"] == nil)
        #expect(reply.data?["open"] is NSNull)
        await harness.stop()
    }

    static var repository: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    // MARK: The reveal root through the real bundle

    @Test(arguments: [
        ["workspace:control"], ["desktop:control"], ["desktop:read"], ["workspace:read", "desktop:read"], [],
    ])
    func eitherControlAloneIsRefusedForTheRevealRootBeforeAnythingIsInspected(held: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: held)
        // A path that exists, so a missing refusal would select it in this host's Finder.
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let reply = try await harness.post(
            Self.revealPath, variables: ["path": fixtures.text], authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["reveal"])
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["phase"] as? String == "authorization")
        #expect(extensions["requiredCapabilities"] as? [String] == Self.controls)
        #expect(reply.data == nil, "preflight refuses the whole request; nothing ran")
        await harness.stop()
    }

    @Test func aMissingPathADanglingLinkAFileWithATrailingSlashAndALoopAreNotFoundForRevealAndNothingIsSubmitted() async throws {
        let fixtures = try Fixtures()
        defer { fixtures.remove() }
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        // The same inspection as opening: `realpath` alone accepts `notes.txt/` and `notes.txt/.`.
        for path in [
            fixtures.missing, fixtures.path("dangling"), fixtures.path("notes.txt/below-a-file"),
            fixtures.text + "/", fixtures.text + "//", fixtures.text + "/.", fixtures.path("loop-a"),
            fixtures.path(String(repeating: "n", count: 300)),
        ] {
            let reply = try await harness.post(
                Self.revealPath, variables: ["path": path], authorization: "Bearer \(credential)")
            let reveal = try #require(reply.data?["reveal"] as? [String: Any], Comment(rawValue: "\(reply.errors)"))
            #expect(reveal["status"] as? String == "DEPENDENCY_UNAVAILABLE", Comment(rawValue: path))
            #expect(reveal["value"] is NSNull)
            #expect((reveal["dependency"] as? [String: Any])?["reason"] as? String == "PATH_NOT_FOUND", Comment(rawValue: path))
        }
        await harness.stop()
    }

    @Test(arguments: [
        "", "relative/notes.txt", "./notes.txt", "~/notes.txt", "$HOME/notes.txt", "file:///etc/hosts", " /etc/hosts",
        "/Users/koine-test/a\u{0}b",
    ])
    func anUnusableRevealPathIsAnInputErrorAtTheOriginalPathWithNoKind(_ path: String) async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: Self.controls)
        let reply = try await harness.post(
            Self.revealPath, variables: ["path": path], authorization: "Bearer \(credential)")
        let error = try #require(reply.errors.first, Comment(rawValue: "\(path.debugDescription) was accepted"))
        #expect(error["path"] as? [String] == ["reveal"])
        #expect((error["extensions"] as? [String: Any])?["kind"] == nil, "an input error carries no kind")
        #expect(reply.data?["reveal"] is NSNull)
        await harness.stop()
    }
}
