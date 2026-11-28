import AppKit
import ApplicationServices
import Foundation
import KoineCore
import Testing

@testable import KoineServer

/// The input provider as an independently built, signed bundle (G): built by its own build definition, sealed with
/// Koine's identity, placed in the in-application root beside desktop and workspace, chosen by the sealed catalogue
/// and loaded by the selection-aware loader, then asked over loopback HTTP (docs/specs/app-input.md). `task test`
/// builds it.
///
/// **No chord reaches an app of this host, in front or in the background.** A test asks for a chord only where Koine
/// refuses before it sends: without the capability, without consent, for a stale target, for a reference of another
/// provider, for a process that is not an app, and for the Koine process itself. In the test runner, the Koine process
/// is this test process, and Koine recognises it by its process identifier. Route A keeps even a mistaken send inside
/// the one named process. The sends themselves are the VM acceptance (`app-input-acceptance-k6`).
///
/// **No test switches a Space.** A test asks for a Space switch only where Koine refuses before the provider reads
/// anything: without both control capabilities, with a revoked grant, and with a number outside 1 to 9.
@Suite struct InputProviderTests {
    static let send = """
        mutation($target: Reference!) {
          inputSendKeystroke(target: $target, key: T, modifiers: [COMMAND, SHIFT]) { outcome } }
        """

    static let switchSpace = "mutation($n: Int!) { inputSwitchSpace(number: $n) { outcome } }"

    static let switchControls = ["input:control", "desktop:control"]

    static let captured = """
        query($process: InputProcessIdentity!) {
          inputTarget(process: $process) { ref name bundleIdentifier protection } }
        """

    static let front = "{ inputFrontTarget { ref name bundleIdentifier protection } }"

    /// The start instant of a process in whole microseconds, by `sysctl`, as a client captures it.
    static func startMicroseconds(_ pid: pid_t) throws -> Int64 {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.size
        var name = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        try #require(sysctl(&name, 4, &info, &size, nil, 0) == 0 && size > 0)
        let start = info.kp_proc.p_starttime
        return Int64(start.tv_sec) * 1_000_000 + Int64(start.tv_usec)
    }

    /// The reference that a client could build for an incarnation. A client can build one for any incarnation.
    static func reference(_ pid: pid_t, start: Int64) -> String { "koine://input/target/\(pid)/\(start)" }

    /// Whether this process holds both consents that a send checks first. Without them, every send in this file
    /// reports `os-permission`, and the provider looks at nothing else.
    static var consented: Bool { AXIsProcessTrusted() && CGPreflightPostEventAccess() }

    /// A child process that is not an app. It ends when the test ends.
    static func child() throws -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sleep")
        process.arguments = ["30"]
        try process.run()
        return process
    }

    static func extensions(_ reply: Harness.Reply) throws -> [String: Any] {
        try #require(reply.errors.first?["extensions"] as? [String: Any], "no error: \(reply.json)")
    }

    /// The reply of a send that Koine refused before it sent. Without consent, that is `os-permission`. With consent,
    /// it is `expected`: an `unavailable` error, or the outcome `PROTECTED_TARGET`.
    static func expectRefused(
        _ reply: Harness.Reply, _ expected: Refusal, sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        guard consented else {
            #expect(reply.data?["inputSendKeystroke"] is NSNull, sourceLocation: sourceLocation)
            let extensions = try extensions(reply)
            #expect(extensions["kind"] as? String == "permission", sourceLocation: sourceLocation)
            #expect(extensions["permissionClass"] as? String == "os-permission", sourceLocation: sourceLocation)
            #expect(extensions["osPermission"] as? String == "accessibility", sourceLocation: sourceLocation)
            return
        }
        switch expected {
        case .unavailable:
            #expect(reply.data?["inputSendKeystroke"] is NSNull, sourceLocation: sourceLocation)
            #expect(try extensions(reply)["kind"] as? String == "unavailable", sourceLocation: sourceLocation)
        case .protectedTarget:
            #expect(reply.errors.isEmpty, sourceLocation: sourceLocation)
            let receipt = reply.data?["inputSendKeystroke"] as? [String: Any]
            #expect(receipt?["outcome"] as? String == "PROTECTED_TARGET", sourceLocation: sourceLocation)
        }
    }

    enum Refusal { case unavailable, protectedTarget }

    // MARK: Loading

    @Test func theSignedBundleLoadsBetweenDesktopAndWorkspace() async throws {
        let harness = try await DesktopProviderTests.harness()
        #expect(harness.server.providerDiagnostics.isEmpty)
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let reply = try await harness.post(
            "{ koineManagement { providers { provider version schemaVersion state origin selection reason } } }",
            authorization: "Bearer \(manager)"
        )
        #expect(reply.errors.isEmpty)
        let rows = try #require((reply.data?["koineManagement"] as? [String: Any])?["providers"] as? [[String: Any]])
        let input = try #require(rows.first { $0["provider"] as? String == "input" }, "input is missing: \(rows)")
        #expect(input["state"] as? String == "ACTIVE")
        #expect(input["origin"] as? String == "BUNDLED")
        #expect(input["selection"] as? String == "SELECTED")
        #expect(input["version"] as? String == "1.0.0" && input["schemaVersion"] as? String == "1.0.0")
        #expect(input["reason"] is NSNull, "a healthy shipped row carries no reason")
        await harness.stop()
    }

    @Test func itsCapabilitiesArePublished() async throws {
        let harness = try await DesktopProviderTests.harness()
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let reply = try await harness.post("{ koine { availableCapabilities } }", authorization: "Bearer \(credential)")
        let available = try #require((reply.data?["koine"] as? [String: Any])?["availableCapabilities"] as? [String])
        #expect(available.contains("input:read") && available.contains("input:control"))
        await harness.stop()
    }

    // MARK: The served contribution

    /// The bundle serves the whole design, verbatim: the design body after its header comment, the Space switch
    /// included.
    @Test func theServedSDLIsTheDesign() throws {
        let served = try String(
            contentsOf: WorkspaceProviderTests.repository.appending(path: "Providers/InputProvider/schema.graphql"),
            encoding: .utf8)
        let design = try String(
            contentsOf: WorkspaceProviderTests.repository.appending(path: "docs/design/input-schema.graphql"),
            encoding: .utf8)
        func body(_ text: String) -> [String] {
            text.components(separatedBy: "\n\n").dropFirst().map { $0.trimmingCharacters(in: .newlines) }
        }
        #expect(body(served) == body(design))
        #expect(served.contains("  inputSwitchSpace(number: Int!): InputSpaceSwitchReceipt"))
    }

    /// The served descriptions state the reach and the limits of a chord, and the read type states its capability.
    @Test func theDescriptionsStateTheReachAndTheLimits() async throws {
        let harness = try await DesktopProviderTests.harness()
        let anyone = try await harness.consoleGrant(label: "anyone", capabilities: [])
        let reply = try await harness.post(
            """
            { m: __type(name: "Mutation") { fields { name description } } \
            q: __type(name: "Query") { fields { name description } } \
            target: __type(name: "InputTarget") { description } \
            receipt: __type(name: "InputKeystrokeReceipt") { description fields { name } } \
            switched: __type(name: "InputSpaceSwitchReceipt") { description fields { name } } \
            outcomes: __type(name: "InputSpaceSwitchOutcome") { enumValues { name } } }
            """,
            authorization: "Bearer \(anyone)"
        )
        #expect(reply.errors.isEmpty)
        let mutations = (reply.data?["m"] as? [String: Any])?["fields"] as? [[String: Any]] ?? []
        let send = try #require(mutations.first { $0["name"] as? String == "inputSendKeystroke" }?["description"] as? String)
        #expect(send.hasPrefix("input:control. Sends one chord to this target, whether or not it is the front app."))
        for phrase in [
            "Koine never brings the target to the front.", "So no other app receives the chord",
            "A tap that a process creates for the target process does see it.",
            "An app in the background can ignore a chord, act on a window behind other apps, or come to the front.",
            "A chord sent to a terminal can type and run commands",
            "a chord can answer a consent or security prompt of macOS",
        ] {
            #expect(send.contains(phrase), "\(phrase)")
        }
        let switchSpace = try #require(
            mutations.first { $0["name"] as? String == "inputSwitchSpace" }?["description"] as? String)
        #expect(switchSpace.hasPrefix("input:control AND desktop:control. Switches to this Mission Control desktop"))
        for phrase in [
            "Koine posts Control and the digit at the HID event tap",
            "It posts nothing when the shortcut is off or uses another key or other modifiers.",
            "or while Koine is the front app.",
            "the front app can receive Control and the digit",
            "The keyboard tap of a client sees these events, and their source process is Koine.",
        ] {
            #expect(switchSpace.contains(phrase), "\(phrase)")
        }
        let queries = (reply.data?["q"] as? [String: Any])?["fields"] as? [[String: Any]] ?? []
        for name in ["inputFrontTarget", "inputTarget"] {
            let description = queries.first { $0["name"] as? String == name }?["description"] as? String
            #expect(description?.hasPrefix("input:read. ") == true, "\(name)")
        }
        let target = (reply.data?["target"] as? [String: Any])?["description"] as? String
        #expect(target?.hasPrefix("All fields require input:read.") == true)
        let receipt = try #require(reply.data?["receipt"] as? [String: Any])
        #expect((receipt["description"] as? String)?.hasPrefix("Control-authorized output. It says only whether Koine sent the chord.") == true)
        #expect((receipt["fields"] as? [[String: Any]])?.compactMap { $0["name"] as? String } == ["outcome"])
        let switched = try #require(reply.data?["switched"] as? [String: Any])
        #expect((switched["description"] as? String)?.hasPrefix(
            "Control-authorized output under input:control AND desktop:control. It says only whether Koine posted") == true)
        #expect((switched["fields"] as? [[String: Any]])?.compactMap { $0["name"] as? String } == ["outcome"])
        let outcomes = (reply.data?["outcomes"] as? [String: Any])?["enumValues"] as? [[String: Any]]
        #expect(
            outcomes?.compactMap { $0["name"] as? String }
                == ["POSTED", "SHORTCUT_OFF", "SHORTCUT_REMAPPED", "NO_SUCH_DESKTOP", "PROTECTED_FRONT_APP"])
        await harness.stop()
    }

    /// Management serves the input disclosures beside the others, whether or not a grant holds them. They state the
    /// terminal reach, the consent prompts, the protected target and the limits.
    @Test func managementServesTheInputDisclosures() async throws {
        let harness = try await DesktopProviderTests.harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let reply = try await harness.post(
            "{ koineManagement { capabilityDisclosures { capability disclosure } } }", authorization: "Bearer \(manager)"
        )
        #expect(reply.errors.isEmpty)
        let entries = try #require(
            (reply.data?["koineManagement"] as? [String: Any])?["capabilityDisclosures"] as? [[String: String]])
        let served = Dictionary(uniqueKeysWithValues: entries.compactMap { entry in
            entry["capability"].map { ($0, entry["disclosure"] ?? "") }
        })
        #expect(served["input:read"] == CapabilityDisclosures.inputRead)
        #expect(served["input:control"] == CapabilityDisclosures.inputControl)
        let control = CapabilityDisclosures.inputControl
        for phrase in [
            "So a chord sent to a terminal can type and run commands as the user.",
            "it can answer a consent, password or security prompt of macOS.",
            "it never sends a chord to itself.",
            "An app in the background can ignore a chord, act on a window behind other apps, or come to the front.",
            "The shortcut setting or the Mission Control desktops can change in the instant before macOS reads the chord.",
        ] {
            #expect(control.contains(phrase), "\(phrase)")
        }
        #expect(CapabilityDisclosures.inputRead.contains("It reads no window titles and no window contents, and it sends no keys."))
        await harness.stop()
    }

    // MARK: Authority

    /// Read-only, desktop-only and empty grants cannot send a chord: Koine refuses before it asks the provider, so the
    /// test sends nothing. The reference names this test process, which Koine would refuse anyway.
    @Test(arguments: [["input:read"], ["desktop:read", "desktop:control"], ["workspace:control"], [String]()])
    func aChordWithoutInputControlIsRefusedBeforeTheProviderIsAsked(capabilities: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: capabilities)
        let ref = Self.reference(getpid(), start: try Self.startMicroseconds(getpid()))
        let reply = try await harness.post(Self.send, variables: ["target": ref], authorization: "Bearer \(client)")
        #expect(reply.data?["inputSendKeystroke"] == nil || reply.data?["inputSendKeystroke"] is NSNull)
        let extensions = try Self.extensions(reply)
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "input:control")
        await harness.stop()
    }

    /// Control does not imply read: capture needs input:read.
    @Test(arguments: [["input:control"], ["desktop:read"], [String]()])
    func aCaptureWithoutInputReadIsRefused(capabilities: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: capabilities)
        let reply = try await harness.post(Self.front, authorization: "Bearer \(client)")
        let extensions = try Self.extensions(reply)
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["requiredCapability"] as? String == "input:read")
        await harness.stop()
    }

    /// A grant request that the manager denies gives no grant. Its secret stays status-only, so it cannot send.
    @Test func aDeniedRequestCannotSend() async throws {
        let harness = try await DesktopProviderTests.harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let secret = Credential.generate()
        let receipt = try await GrantEnrollmentTests().enrol(harness, secret, capabilities: ["input:control"])
        let denial = try await harness.post(
            GrantDecisionTests.deny, variables: ["id": receipt.id], authorization: "Bearer \(manager)")
        #expect(denial.errors.isEmpty)
        let ref = Self.reference(getpid(), start: try Self.startMicroseconds(getpid()))
        let reply = try await harness.post(
            Self.send, variables: ["target": ref], authorization: "Bearer \(secret.encoded)")
        #expect(reply.status == 403)
        #expect(reply.data?["inputSendKeystroke"] == nil)
        await harness.stop()
    }

    /// A revoked grant authenticates no longer: its send is a 401, and the provider is not asked.
    @Test func aRevokedGrantCannotSend() async throws {
        let harness = try await DesktopProviderTests.harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let created = try await harness.post(
            Harness.createGrant, variables: ["label": "client", "capabilities": ["input:control"]],
            authorization: "Bearer \(manager)")
        let grant = try #require(created.data?["koineCreateGrant"] as? [String: Any])
        let credential = try #require(grant["credential"] as? String)
        let id = try #require((grant["grant"] as? [String: Any])?["grantId"] as? String)
        let revoked = try await harness.post(
            "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { grantId } }", variables: ["id": id],
            authorization: "Bearer \(manager)")
        #expect(revoked.errors.isEmpty)
        let ref = Self.reference(getpid(), start: try Self.startMicroseconds(getpid()))
        let reply = try await harness.post(Self.send, variables: ["target": ref], authorization: "Bearer \(credential)")
        #expect(reply.status == 401)
        await harness.stop()
    }

    // MARK: Authority of the Space switch

    /// A Space switch needs input:control and desktop:control. Either control alone, read grants and an empty grant
    /// are refused in preflight, before the provider is asked, so the test switches nothing. The error carries the
    /// whole ordered set and names the first member that the grant lacks.
    @Test(arguments: [
        (["input:control"], "desktop:control"),
        (["desktop:control"], "input:control"),
        (["input:read", "desktop:read"], "input:control"),
        (["input:read", "input:control", "desktop:read"], "desktop:control"),
        ([String](), "input:control"),
    ])
    func aSpaceSwitchWithoutBothControlsIsRefusedBeforeTheProviderIsAsked(
        capabilities: [String], missing: String
    ) async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: capabilities)
        let reply = try await harness.post(Self.switchSpace, variables: ["n": 2], authorization: "Bearer \(client)")
        #expect(reply.data == nil, "preflight refuses the whole request; nothing ran")
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["inputSwitchSpace"])
        let extensions = try Self.extensions(reply)
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["phase"] as? String == "authorization")
        #expect(extensions["requiredCapability"] as? String == missing)
        #expect(extensions["requiredCapabilities"] as? [String] == Self.switchControls)
        await harness.stop()
    }

    /// A revoked grant with both controls authenticates no longer: its Space switch is a 401, and the provider is not
    /// asked.
    @Test func aRevokedGrantCannotSwitchASpace() async throws {
        let harness = try await DesktopProviderTests.harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let created = try await harness.post(
            Harness.createGrant, variables: ["label": "client", "capabilities": Self.switchControls],
            authorization: "Bearer \(manager)")
        let grant = try #require(created.data?["koineCreateGrant"] as? [String: Any])
        let credential = try #require(grant["credential"] as? String)
        let id = try #require((grant["grant"] as? [String: Any])?["grantId"] as? String)
        let revoked = try await harness.post(
            "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { grantId } }", variables: ["id": id],
            authorization: "Bearer \(manager)")
        #expect(revoked.errors.isEmpty)
        let reply = try await harness.post(Self.switchSpace, variables: ["n": 2], authorization: "Bearer \(credential)")
        #expect(reply.status == 401)
        await harness.stop()
    }

    /// A number outside 1 to 9 is an invalid argument, an error with no kind, at the field's path. The provider
    /// decides it before the consent checks and before any read, so it holds on any host and switches nothing.
    @Test(arguments: [0, 10, -3])
    func aNumberOutsideOneToNineIsAnInvalidArgument(number: Int) async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: Self.switchControls)
        let reply = try await harness.post(
            Self.switchSpace, variables: ["n": number], authorization: "Bearer \(client)")
        #expect(reply.data?["inputSwitchSpace"] is NSNull)
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["inputSwitchSpace"])
        #expect((error["extensions"] as? [String: Any])?["kind"] == nil)
        #expect((error["message"] as? String)?.contains("from 1 to 9") == true)
        await harness.stop()
    }

    // MARK: Capture

    /// A running app with a Dock icon is an addressable target with a reference. Capture only reads.
    @Test func aRunningAppIsAnAddressableTarget() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["input:read"])
        let running = try #require(
            NSWorkspace.shared.runningApplications.first {
                $0.activationPolicy == .regular && $0.bundleIdentifier != nil && $0.processIdentifier != getpid()
            },
            "No application is running in this session."
        )
        let pid = running.processIdentifier
        let reply = try await harness.post(
            Self.captured,
            variables: ["process": ["pid": Int(pid), "startedAt": try DesktopProviderTests.startedAt(pid)]],
            authorization: "Bearer \(reader)")
        #expect(reply.errors.isEmpty)
        let target = try #require(reply.data?["inputTarget"] as? [String: Any])
        #expect(target["ref"] as? String == Self.reference(pid, start: try Self.startMicroseconds(pid)))
        #expect(target["name"] as? String == running.localizedName)
        #expect(target["bundleIdentifier"] as? String == running.bundleIdentifier)
        #expect(target["protection"] as? String == "ADDRESSABLE")
        await harness.stop()
    }

    /// A child process that is not an app and a live process identifier with another start instant each give null,
    /// with no error.
    @Test func aProcessThatIsNotAnAppOrNotThisIncarnationGivesNull() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["input:read"])
        let child = try Self.child()
        defer { child.terminate() }
        let pid = child.processIdentifier
        for (subject, startedAt) in [
            ("a child that is not an app", try DesktopProviderTests.startedAt(pid)),
            ("another start instant", try DesktopProviderTests.startedAt(pid, addingMicroseconds: 1)),
        ] {
            let reply = try await harness.post(
                Self.captured, variables: ["process": ["pid": Int(pid), "startedAt": startedAt]],
                authorization: "Bearer \(reader)")
            #expect(reply.errors.isEmpty, "\(subject)")
            #expect(reply.data?["inputTarget"] is NSNull, "\(subject)")
        }
        await harness.stop()
    }

    /// Koine refuses itself before it issues a reference. Here the Koine process is this test process. The test runner
    /// loads AppKit, so macOS reports it as an app with no bundle identifier, and capture gives a protected target with
    /// no reference. If macOS reports the runner as no app, capture gives null. Either way, no reference names Koine.
    @Test func theKoineProcessIsAProtectedTargetWithNoReference() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["input:read"])
        let reply = try await harness.post(
            Self.captured,
            variables: ["process": ["pid": Int(getpid()), "startedAt": try DesktopProviderTests.startedAt(getpid())]],
            authorization: "Bearer \(reader)")
        #expect(reply.errors.isEmpty)
        if NSRunningApplication(processIdentifier: getpid()) != nil {
            let target = try #require(reply.data?["inputTarget"] as? [String: Any])
            #expect(target["protection"] as? String == "PROTECTED")
            #expect(target["ref"] is NSNull)
        } else {
            #expect(reply.data?["inputTarget"] is NSNull)
        }
        await harness.stop()
    }

    @Test func aMalformedStartInstantIsAnInputError() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["input:read"])
        let reply = try await harness.post(
            Self.captured, variables: ["process": ["pid": 1, "startedAt": "2026-11-28 01:02:03"]],
            authorization: "Bearer \(reader)")
        #expect(reply.data?["inputTarget"] == nil || reply.data?["inputTarget"] is NSNull)
        #expect(!reply.errors.isEmpty)
        await harness.stop()
    }

    /// The front app reads under input:read. It is null, or a target with every field. Capture only reads.
    @Test func theFrontAppIsATargetOrNull() async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["input:read"])
        let reply = try await harness.post(Self.front, authorization: "Bearer \(reader)")
        #expect(reply.errors.isEmpty)
        if let target = reply.data?["inputFrontTarget"] as? [String: Any] {
            #expect(target["name"] is String)
            let protection = target["protection"] as? String
            #expect(protection == "ADDRESSABLE" || protection == "PROTECTED")
            #expect((target["ref"] is NSNull) == (protection == "PROTECTED"))
        } else {
            #expect(reply.data?["inputFrontTarget"] is NSNull)
        }
        await harness.stop()
    }

    // MARK: Refusals before a send (G safety)

    /// The Koine process is the protected target. Here it is this test process, recognised by its process identifier.
    @Test func theKoineProcessIsRefusedWithProtectedTarget() async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: ["input:control"])
        let ref = Self.reference(getpid(), start: try Self.startMicroseconds(getpid()))
        let reply = try await harness.post(Self.send, variables: ["target": ref], authorization: "Bearer \(client)")
        try Self.expectRefused(reply, .protectedTarget)
        await harness.stop()
    }

    /// A stale target is unavailable. The reference names this test process with another start instant, so no live
    /// process holds it.
    @Test func aStaleTargetIsUnavailable() async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: ["input:control"])
        let ref = Self.reference(getpid(), start: try Self.startMicroseconds(getpid()) + 1)
        let reply = try await harness.post(Self.send, variables: ["target": ref], authorization: "Bearer \(client)")
        try Self.expectRefused(reply, .unavailable)
        await harness.stop()
    }

    /// A process that is not an app is unavailable at a send, as it is null at capture.
    @Test func aProcessThatIsNotAnAppIsUnavailable() async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: ["input:control"])
        let child = try Self.child()
        defer { child.terminate() }
        let pid = child.processIdentifier
        let reply = try await harness.post(
            Self.send, variables: ["target": Self.reference(pid, start: try Self.startMicroseconds(pid))],
            authorization: "Bearer \(client)")
        try Self.expectRefused(reply, .unavailable)
        await harness.stop()
    }

    /// A desktop reference is not an input reference. Using it needs desktop:control too, and then it names no input
    /// target.
    @Test func aDesktopReferenceIsUnavailable() async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: ["input:control", "desktop:control"])
        let ref = "koine://desktop/application/\(getpid())/\(try Self.startMicroseconds(getpid()))"
        let reply = try await harness.post(Self.send, variables: ["target": ref], authorization: "Bearer \(client)")
        try Self.expectRefused(reply, .unavailable)
        await harness.stop()
    }

    /// An unknown key fails GraphQL validation, before any execution.
    @Test func anUnknownKeyFailsValidation() async throws {
        let harness = try await DesktopProviderTests.harness()
        let client = try await harness.consoleGrant(label: "client", capabilities: ["input:control"])
        let reply = try await harness.post(
            "mutation($t: Reference!) { inputSendKeystroke(target: $t, key: SHIFT, modifiers: []) { outcome } }",
            variables: ["t": Self.reference(getpid(), start: 1)], authorization: "Bearer \(client)")
        #expect(reply.data == nil)
        #expect(!reply.errors.isEmpty)
        await harness.stop()
    }
}
