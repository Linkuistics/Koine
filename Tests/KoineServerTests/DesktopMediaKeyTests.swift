import Foundation
import KoineCore
import KoineServer
import Testing

/// The media keys of the real desktop bundle, loaded by the native loader and asked over loopback HTTP
/// (docs/specs/machine.md, "Media keys"). Only what posts nothing is asked here: the authority of the new root and
/// the served descriptions. No test here asks for a key with a desktop:control grant, because the key would change
/// the music or the volume of this host. The post itself is the VM acceptance (`pointer-media-acceptance-k5`).
/// `task test` builds the bundle.
@Suite struct DesktopMediaKeyTests {
    /// `PostDesktopMediaKey`, as docs/design/desktop-pointer-media-operations.graphql has it.
    static let post = "mutation PostDesktopMediaKey($key: DesktopMediaKey!) { desktopPostMediaKey(key: $key) { key } }"

    static let keys = ["PLAY_PAUSE", "NEXT", "PREVIOUS", "VOLUME_UP", "VOLUME_DOWN", "MUTE"]

    // MARK: Authority

    /// A read-only grant cannot act: each key is refused before the provider is asked, so the test posts nothing.
    /// A grant with no capability is refused the same way.
    @Test(arguments: [["desktop:read"], [String]()])
    func aKeyWithoutDesktopControlIsRefusedBeforeTheProviderIsAsked(capabilities: [String]) async throws {
        let harness = try await DesktopProviderTests.harness()
        let reader = try await harness.consoleGrant(label: "reader", capabilities: capabilities)
        for key in Self.keys {
            let reply = try await harness.post(Self.post, variables: ["key": key], authorization: "Bearer \(reader)")
            #expect(reply.data?["desktopPostMediaKey"] == nil || reply.data?["desktopPostMediaKey"] is NSNull, "\(key)")
            let extensions = try #require(reply.errors.first?["extensions"] as? [String: Any], "\(key)")
            #expect(extensions["kind"] as? String == "permission", "\(key)")
            #expect(extensions["permissionClass"] as? String == "capability", "\(key)")
            #expect(extensions["requiredCapability"] as? String == "desktop:control", "\(key)")
        }
        await harness.stop()
    }

    // MARK: Descriptions

    /// The served description states the reach of the root: the Now Playing app, the launch of Music, the output
    /// volume, no keystroke, and an earlier grant. The receipt states its control authority, carries the key alone
    /// and makes no claim about the player.
    @Test func theNewDescriptionsDiscloseTheWiderReach() async throws {
        let harness = try await DesktopProviderTests.harness()
        let anyone = try await harness.consoleGrant(label: "anyone", capabilities: [])
        let reply = try await harness.post(
            """
            { m: __type(name: "Mutation") { fields { name description args { name type { kind ofType { name } } } } } \
            key: __type(name: "DesktopMediaKey") { description enumValues { name } } \
            receipt: __type(name: "DesktopMediaKeyReceipt") { description fields { name description } } }
            """,
            authorization: "Bearer \(anyone)"
        )
        #expect(reply.errors.isEmpty)
        let mutations = (reply.data?["m"] as? [String: Any])?["fields"] as? [[String: Any]] ?? []
        let root = try #require(mutations.first { $0["name"] as? String == "desktopPostMediaKey" })
        let description = try #require(root["description"] as? String)
        #expect(description.hasPrefix("desktop:control. Posts one media key, down and then up"))
        #expect(description.contains("macOS sends PLAY_PAUSE, NEXT and PREVIOUS to the Now Playing app"))
        #expect(description.contains("macOS can open Music for PLAY_PAUSE and bring it to the front"))
        #expect(description.contains("VOLUME_UP, VOLUME_DOWN and MUTE change the output volume of the Mac."))
        #expect(description.contains("No media key is a keystroke, and no media key types into the front app."))
        #expect(description.contains("A desktop:control grant from an earlier Koine version can do this too."))
        let arguments = root["args"] as? [[String: Any]] ?? []
        #expect(arguments.map { $0["name"] as? String } == ["key"])
        let type = try #require(arguments.first?["type"] as? [String: Any])
        #expect(type["kind"] as? String == "NON_NULL")
        #expect((type["ofType"] as? [String: Any])?["name"] as? String == "DesktopMediaKey")

        let key = try #require(reply.data?["key"] as? [String: Any])
        #expect((key["enumValues"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String } == Self.keys)
        #expect((key["description"] as? String)?.contains("These three go to the Now Playing app.") == true)

        let receipt = try #require(reply.data?["receipt"] as? [String: Any])
        let summary = try #require(receipt["description"] as? String)
        #expect(summary.hasPrefix("Control-authorized output. It says that Koine posted the key, down and then up."))
        #expect(summary.contains("It does not say which app received the key or what changed"))
        let fields = receipt["fields"] as? [[String: Any]] ?? []
        #expect(fields.compactMap { $0["name"] as? String } == ["key"], "the receipt carries no read data")
        #expect(
            fields.first?["description"] as? String == "The submitted key, under the mutation's control authority.")
        await harness.stop()
    }
}
