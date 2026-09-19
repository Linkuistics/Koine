import Foundation
import KoineCore
import KoineServer
import Testing

/// `koineManagement.osPermissions` over loopback HTTP. The host's permission
/// source is a test double: what is under test is that the server asks it, when,
/// and for whom.
@Suite struct OSPermissionTests {
    static let osPermissions = "{ koineManagement { osPermissions { permission owner granted } } }"

    /// A permission source whose answer a test changes, and which counts its reads.
    private final class Consent: @unchecked Sendable {
        private let lock = NSLock()
        private var granted = false
        private var reads = 0

        func set(_ value: Bool) { lock.withLock { granted = value } }
        var readCount: Int { lock.withLock { reads } }

        func read() -> [OSPermissionStatus] {
            lock.withLock {
                reads += 1
                return [OSPermissionStatus(permission: "accessibility", owner: "koine", granted: granted)]
            }
        }
    }

    private func listed(_ harness: Harness, as bearer: String) async throws -> [[String: Any]] {
        let reply = try await harness.post(Self.osPermissions, authorization: "Bearer \(bearer)")
        #expect(reply.errors.isEmpty)
        let management = try #require(reply.data?["koineManagement"] as? [String: Any])
        return try #require(management["osPermissions"] as? [[String: Any]])
    }

    @Test func aManagerReadsThePermissionAsItIsOnEachRequest() async throws {
        let consent = Consent()
        let harness = try await Harness(osPermissions: consent.read)
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        // Nothing is read until a request asks.
        #expect(consent.readCount == 0)

        var permissions = try await listed(harness, as: manager)
        #expect(permissions.count == 1)
        #expect(permissions[0]["permission"] as? String == "accessibility")
        #expect(permissions[0]["owner"] as? String == "koine")
        #expect(permissions[0]["granted"] as? Bool == false)

        consent.set(true)
        permissions = try await listed(harness, as: manager)
        #expect(permissions[0]["granted"] as? Bool == true)

        consent.set(false)
        permissions = try await listed(harness, as: manager)
        #expect(permissions[0]["granted"] as? Bool == false)
        #expect(consent.readCount == 3)
        await harness.stop()
    }

    @Test func aGrantWithoutManageCannotReadItAndTheSourceIsNotAsked() async throws {
        let consent = Consent()
        let harness = try await Harness(osPermissions: consent.read)
        let reader = try await harness.consoleGrant(label: "reader", capabilities: [])

        let reply = try await harness.post(
            "{ koine { contractVersion } management: koineManagement { osPermissions { granted } } }",
            authorization: "Bearer \(reader)"
        )
        #expect(reply.status == 200)
        #expect(reply.data?["koine"] != nil)
        #expect(reply.data?["management"] is NSNull)
        let error = try #require(reply.errors.first)
        let extensions = try #require(error["extensions"] as? [String: Any])
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(consent.readCount == 0)
        await harness.stop()
    }

    @Test func aHostWithNoPermissionSourceServesNone() async throws {
        let harness = try await Harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        #expect(try await listed(harness, as: manager).isEmpty)
        await harness.stop()
    }
}
