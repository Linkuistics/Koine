import AppKit
import Foundation
import KoineProviderLoader
import KoineServer
import Testing

/// The desktop provider's bundle, built by its own build definition, loaded by
/// the one native loader and asked over loopback HTTP. Only what needs no
/// Accessibility consent and drives nothing is asked here, of an application
/// that is already running; windows are verified in a VM
/// (docs/verification/desktop-window-identity.md). `task test` builds the bundle.
@Suite struct DesktopProviderTests {
    /// The in-application root, as the application supplies it: `desktop` is
    /// reserved to it, approved for the identity every Koine bundle is signed with.
    static func bundled() throws -> [ProviderRoot] {
        let team = try ProviderLoaderTests.fixtureApproval().teamIdentifier
        return [
            .bundled(try root(), approvals: [ProviderApproval(providerId: "desktop", teamIdentifier: team)])
        ]
    }

    static func root() throws -> URL {
        let root = Bundle(for: TestBundleAnchor.self).bundleURL.deletingLastPathComponent()
            .appendingPathComponent("DesktopProviders", isDirectory: true)
        let bundle = root.appendingPathComponent("Desktop.koineprovider").path
        try #require(
            FileManager.default.fileExists(atPath: bundle),
            "No desktop provider there. Run `task test`, which builds it."
        )
        return root
    }

    /// The start instant by the kernel's other public route, `sysctl`, in the
    /// contract's canonical form: what a client captures.
    static func startedAt(_ pid: pid_t, addingMicroseconds extra: Int = 0) throws -> String {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.size
        var name = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        try #require(sysctl(&name, 4, &info, &size, nil, 0) == 0 && size > 0)
        let start = info.kp_proc.p_starttime
        let micros = Int(start.tv_sec) * 1_000_000 + Int(start.tv_usec) + extra
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let seconds = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(micros / 1_000_000)))
        return seconds + "." + String(format: "%06d", micros % 1_000_000) + "Z"
    }

    static func query(pid: Int, startedAt: String) -> String {
        """
        { desktopApplication(process: { pid: \(pid), startedAt: "\(startedAt)" }) { ref name bundleIdentifier } }
        """
    }

    @Test func aRunningApplicationResolvesOnlyByBothHalvesOfItsIdentity() async throws {
        let harness = try await Harness(bundledRoots: try Self.bundled())
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let running = try #require(
            NSWorkspace.shared.runningApplications.first { $0.activationPolicy == .regular },
            "No application is running in this session."
        )
        let pid = running.processIdentifier

        let found = try await harness.post(
            Self.query(pid: Int(pid), startedAt: try Self.startedAt(pid)),
            authorization: "Bearer \(reader)"
        )
        #expect(found.errors.isEmpty)
        let application = try #require(found.data?["desktopApplication"] as? [String: Any])
        #expect(application["name"] as? String == running.localizedName)
        #expect(application["bundleIdentifier"] as? String == running.bundleIdentifier)
        let ref = try #require(application["ref"] as? String)
        #expect(ref.hasPrefix("koine://desktop/application/\(pid)/"))

        // The same live PID, claimed one microsecond later: another process.
        let other = try await harness.post(
            Self.query(pid: Int(pid), startedAt: try Self.startedAt(pid, addingMicroseconds: 1)),
            authorization: "Bearer \(reader)"
        )
        #expect(other.errors.isEmpty)
        #expect(other.data?["desktopApplication"] is NSNull)
        await harness.stop()
    }

    @Test func anAbsentProcessIsOrdinaryNull() async throws {
        let harness = try await Harness(bundledRoots: try Self.bundled())
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        // Above the kernel's highest PID (99998).
        let reply = try await harness.post(
            Self.query(pid: 1_000_000, startedAt: "2026-09-19T01:02:03.000456Z"),
            authorization: "Bearer \(reader)"
        )
        #expect(reply.errors.isEmpty)
        #expect(reply.data?["desktopApplication"] is NSNull)
        await harness.stop()
    }

    @Test(arguments: [
        (1, "2026-09-19T01:02:03Z"), (1, "2026-09-19T01:02:03.456Z"), (1, "yesterday"), (1, ""),
        (0, "2026-09-19T01:02:03.000456Z"), (-5, "2026-09-19T01:02:03.000456Z"),
    ])
    func aMalformedProcessIdentityIsAnInputError(pid: Int, startedAt: String) async throws {
        let harness = try await Harness(bundledRoots: try Self.bundled())
        let reader = try await harness.consoleGrant(label: "reader", capabilities: ["desktop:read"])
        let reply = try await harness.post(
            Self.query(pid: pid, startedAt: startedAt), authorization: "Bearer \(reader)"
        )
        let error = try #require(reply.errors.first)
        #expect(error["path"] as? [String] == ["desktopApplication"])
        // Input coercion, not a domain classification; never a fallback to the PID.
        #expect((error["extensions"] as? [String: Any])?["kind"] == nil)
        #expect(reply.data?["desktopApplication"] is NSNull)
        await harness.stop()
    }

    @Test func withoutDesktopReadItIsACapabilityError() async throws {
        let harness = try await Harness(bundledRoots: try Self.bundled())
        let stranger = try await harness.consoleGrant(label: "stranger", capabilities: ["desktop:control"])
        let reply = try await harness.post(
            Self.query(pid: 1, startedAt: "2026-09-19T01:02:03.000456Z"),
            authorization: "Bearer \(stranger)"
        )
        let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "desktop:read")
        await harness.stop()
    }
}
