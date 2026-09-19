import Foundation
import KoineCore
import Testing

@testable import KoineServer

/// The "Public GraphQL authorization" acceptance row, for provider fields, over
/// loopback HTTP against the fixture bundle. What the fixture did is read back
/// through its own `fixtureCalls`, and orders are forced with its gate: a held
/// call stays held until the test opens it, so nothing races and nothing is
/// sampled. Core-field equivalents are not repeated here: forced orders at the
/// engine's internal points are `RevocationOrderingTests`', `unknown-provider`
/// after the capability check and provider defects are `ReferenceRoutingTests`'.
@Suite struct ProviderAuthorizationTests {
    static let first = "koine://fixture/item/1"
    static let second = "koine://fixture/item/2"

    /// A server with the fixture, and an operator who may watch and gate it.
    private final class Bench: @unchecked Sendable {
        let harness: Harness
        private(set) var operatorCredential = ""
        private var issued: [String] = []

        init(providers: [ActiveProvider] = []) async throws {
            harness = try await Harness(
                providerRoots: [try NativeProviderTests.fixtureRoot()], providers: providers
            )
            operatorCredential = try await grant(["fixture:read", "fixture:control"]).credential
        }

        func grant(_ capabilities: [String]) async throws -> (id: String, credential: String) {
            let body = try Harness.requestBody(
                Harness.createGrant, variables: ["label": "c", "capabilities": capabilities]
            )
            let json = try JSONSerialization.jsonObject(
                with: try await harness.server.console.execute(jsonBody: body)
            )
            let created = try #require(
                ((json as? [String: Any])?["data"] as? [String: Any])?["koineCreateGrant"]
                    as? [String: Any]
            )
            let credential = try #require(created["credential"] as? String)
            issued.append(credential)
            return (
                try #require((created["grant"] as? [String: Any])?["grantId"] as? String), credential
            )
        }

        func revoke(_ id: String) async throws {
            let body = try Harness.requestBody(
                "mutation($id: ID!) { koineRevokeGrant(grantId: $id) { __typename } }",
                variables: ["id": id]
            )
            _ = try await harness.server.console.execute(jsonBody: body)
        }

        /// Posts as `credential`. No reply may carry any credential issued here.
        func post(
            _ query: String, _ variables: [String: Any] = [:], as credential: String
        ) async throws -> Harness.Reply {
            let reply = try await harness.post(
                query, variables: variables, authorization: "Bearer \(credential)"
            )
            let text = String(
                decoding: try JSONSerialization.data(withJSONObject: reply.json), as: UTF8.self
            )
            for secret in issued { #expect(!text.contains(secret)) }
            return reply
        }

        func asOperator(_ query: String, _ variables: [String: Any] = [:]) async throws
            -> Harness.Reply
        {
            let reply = try await post(query, variables, as: operatorCredential)
            #expect(reply.errors.isEmpty)
            return reply
        }

        /// The fixture's resolver calls so far, by resolver identifier.
        func calls() async throws -> [String: Int] {
            let reply = try await asOperator("{ fixtureCalls { resolver count } }")
            let listed = try #require(reply.data?["fixtureCalls"] as? [[String: Any]])
            return Dictionary(
                uniqueKeysWithValues: listed.compactMap {
                    guard let name = $0["resolver"] as? String, let count = $0["count"] as? Int
                    else { return nil }
                    return (name, count)
                }
            )
        }

        func names() async throws -> [String] {
            let reply = try await asOperator("{ fixtureItems { name } }")
            return (reply.data?["fixtureItems"] as? [[String: Any]] ?? []).compactMap {
                $0["name"] as? String
            }
        }

        /// Returns once a call of `resolver` is inside the fixture, held or not.
        func waitForCall(of resolver: String) async throws {
            for _ in 0..<500 {
                if try await calls()[resolver] ?? 0 > 0 { return }
                try await Task.sleep(for: .milliseconds(10))
            }
            Issue.record("No call of \(resolver) reached the fixture.")
        }
    }

    private static func extensions(_ error: [String: Any]?) -> [String: Any] {
        error?["extensions"] as? [String: Any] ?? [:]
    }

    /// Response paths as comparable text: `fixtureItems/0/name`.
    private static func paths(_ reply: Harness.Reply) -> Set<String> {
        Set(reply.errors.map { path($0) })
    }

    private static func path(_ error: [String: Any]) -> String {
        (error["path"] as? [Any] ?? []).map { "\($0)" }.joined(separator: "/")
    }

    // MARK: Reads

    static let everyPath = """
        query Paths($ref: Reference!, $hide: Boolean = true, $show: Boolean!) {
          one: fixtureItem(ref: $ref) { ...Bits }
          ... on Query { again: fixtureItem(ref: $ref) { detail { size } } }
          ...Roots
          hidden: fixtureInfo @skip(if: $hide) { greeting }
          shown: fixtureInfo @include(if: $show) { greeting }
        }
        fragment Bits on FixtureItem { label: name tags }
        fragment Roots on Query { probe: fixtureProbe(outcome: OK) }
        """

    @Test func everyPathToAResourceEnforcesReadAndADeniedResolverIsNeverCalled() async throws {
        let bench = try await Bench()
        // Control is not read: neither grant may read anything of the fixture.
        for capabilities in [[], ["fixture:control"]] {
            let client = try await bench.grant(capabilities).credential
            let reply = try await bench.post(
                Self.everyPath, ["ref": Self.first, "show": true], as: client
            )
            #expect(reply.status == 200)
            // `hidden` is skipped by its variable's coerced default: no error.
            #expect(Self.paths(reply) == ["one", "again", "probe", "shown"])
            for error in reply.errors {
                let extensions = Self.extensions(error)
                #expect(extensions["kind"] as? String == "permission")
                #expect(extensions["permissionClass"] as? String == "capability")
                #expect(extensions["requiredCapability"] as? String == "fixture:read")
            }
            for alias in ["one", "again", "probe", "shown"] { #expect(reply.data?[alias] is NSNull) }
            #expect(reply.data?.keys.contains("hidden") == false)

            // The other lookup path, the list, is non-null: its denial takes `data`.
            let listed = try await bench.post("{ all: fixtureItems { name } }", as: client)
            #expect(Self.paths(listed) == ["all"])
            #expect(listed.data == nil)
        }
        #expect(try await bench.calls().isEmpty)

        // The same document under read authority reaches the item by both paths.
        let reader = try await bench.grant(["fixture:read"]).credential
        let reply = try await bench.post(
            Self.everyPath, ["ref": Self.first, "show": false], as: reader
        )
        #expect(reply.errors.isEmpty)
        #expect((reply.data?["one"] as? [String: Any])?["label"] as? String == "first")
        #expect(reply.data?.keys.contains("shown") == false)
        await bench.harness.stop()
    }

    // MARK: Mutation preflight

    static let mixed = """
        mutation Mixed($ref: Reference!, $extra: Boolean = false) {
          renamed: fixtureRenameItem(ref: $ref, name: "renamed") { ref }
          ...Extra @include(if: $extra)
        }
        fragment Extra on Mutation {
          minted: koineCreateGrant(input: { clientLabel: "x", capabilities: [] }) { credential }
        }
        """

    @Test func aDeniedActionInAVariableControlledFragmentMeansZeroActionCalls() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["fixture:control"]).credential

        let denied = try await bench.post(
            Self.mixed, ["ref": Self.first, "extra": true], as: client
        )
        #expect(denied.status == 403)
        #expect(denied.data == nil)
        #expect(Self.paths(denied) == ["minted"])
        let extensions = Self.extensions(denied.errors.first)
        #expect(extensions["requiredCapability"] as? String == "koine:manage")
        #expect(extensions["phase"] as? String == "authorization")
        #expect(try await bench.calls().isEmpty)
        #expect(try await bench.names() == ["first", "second"])

        // Skipped, by the coerced default and then explicitly, the denied action
        // does not block the permitted one.
        for variables: [String: Any] in [["ref": Self.first], ["ref": Self.first, "extra": false]] {
            let allowed = try await bench.post(Self.mixed, variables, as: client)
            #expect(allowed.status == 200)
            #expect(allowed.errors.isEmpty)
        }
        #expect(try await bench.calls()["renameItem"] == 2)
        await bench.harness.stop()
    }

    @Test func preflightReadsReferenceOwnersFromArgumentsAndResolvesNothing() async throws {
        let bench = try await Bench(providers: [Stub.good("good").active])
        let client = try await bench.grant(["fixture:control"]).credential
        let crossing = """
            mutation($own: Reference!, $other: Reference!) {
              a: fixtureRenameItem(ref: $own, name: "renamed") { ref }
              b: fixtureRenameItem(ref: $other, name: "renamed") { ref }
            }
            """

        // `good` owns the second reference, and this grant has no control of it.
        let denied = try await bench.post(
            crossing, ["own": Self.first, "other": "koine://good/thing"], as: client
        )
        #expect(denied.status == 403)
        #expect(Self.paths(denied) == ["b"])
        #expect(Self.extensions(denied.errors.first)["requiredCapability"] as? String == "good:control")
        let literal = try await bench.post(
            "mutation { fixtureRenameItem(ref: \"koine://good/thing\", name: \"n\") { ref } }",
            as: client
        )
        #expect(literal.status == 403)
        #expect(try await bench.calls().isEmpty)

        // With the owner's control the reference may cross. Only the fixture
        // reads its remainder, and finds no item there.
        let both = try await bench.grant(["fixture:control", "good:control"]).credential
        let crossed = try await bench.post(
            crossing, ["own": Self.first, "other": "koine://good/thing"], as: both
        )
        #expect(crossed.status == 200)
        #expect(Self.paths(crossed) == ["b"])
        #expect(Self.extensions(crossed.errors.first)["kind"] as? String == "unavailable")
        #expect(try await bench.names() == ["renamed", "second"])

        // No owner is registered for this one: preflight has nothing to check,
        // and the action that names it is `unknown-provider` at dispatch.
        let unknown = try await bench.post(
            crossing, ["own": Self.second, "other": "koine://nobody/x"], as: client
        )
        #expect(unknown.status == 200)
        #expect(Self.extensions(unknown.errors.first)["kind"] as? String == "unknown-provider")
        await bench.harness.stop()
    }

    // MARK: Revocation

    @Test func revocationWhileAnActionIsHeldStopsTheNextActionAndUndoesNothing() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["fixture:control"])
        _ = try await bench.asOperator("mutation { fixtureCloseGate(resolver: \"renameItem\") }")

        // Both actions pass preflight; the first is dispatched and held.
        async let pending = bench.post(
            """
            mutation {
              first: fixtureRenameItem(ref: "\(Self.first)", name: "held") { ref }
              later: fixtureRenameItem(ref: "\(Self.second)", name: "late") { ref }
            }
            """, as: client.credential
        )
        try await bench.waitForCall(of: "renameItem")
        try await bench.revoke(client.id)
        _ = try await bench.asOperator("mutation { fixtureOpenGate }")
        let reply = try await pending

        // The later action passed preflight, and revocation came before its
        // dispatch: it never began. The held action was already admitted and
        // finished. Its receipt is an output read under a grant revoked by then,
        // so it is withheld, which is no evidence that the action did not occur.
        #expect(reply.status == 200)
        #expect(reply.data?["first"] is NSNull)
        #expect(reply.data?["later"] is NSNull)
        #expect(Self.paths(reply) == ["first/ref", "later"])
        for error in reply.errors {
            #expect(Self.extensions(error)["kind"] as? String == "permission")
            #expect(Self.extensions(error)["phase"] as? String == "execution")
        }
        #expect(try await bench.calls()["renameItem"] == 1)
        #expect(try await bench.names() == ["held", "second"])
        await bench.harness.stop()
    }

    @Test func aProviderReadRevokedBeforePublicationIsNotPublished() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["fixture:read"])
        _ = try await bench.asOperator("mutation { fixtureCloseGate(resolver: \"info\") }")

        async let pending = bench.post("{ fixtureInfo { greeting } }", as: client.credential)
        try await bench.waitForCall(of: "info")
        try await bench.revoke(client.id)
        _ = try await bench.asOperator("mutation { fixtureOpenGate }")
        let reply = try await pending

        // The provider answered; the answer was withheld.
        #expect(reply.data?["fixtureInfo"] is NSNull)
        #expect(Self.paths(reply) == ["fixtureInfo"])
        #expect(Self.extensions(reply.errors.first)["kind"] as? String == "permission")
        #expect(try await bench.calls()["parent.greeting"] == nil)
        await bench.harness.stop()
    }

    // MARK: Control without read

    @Test func aControlOnlyGrantReadsItsReceiptAndIsDeniedReadProtectedOutput() async throws {
        let bench = try await Bench()
        let client = try await bench.grant(["fixture:control"]).credential
        let reply = try await bench.post(
            """
            mutation {
              plain: fixtureRenameItem(ref: "\(Self.first)", name: "a") { ref }
              nosy: fixtureRenameItem(ref: "\(Self.second)", name: "b") { ref affected { label: name } }
            }
            """, as: client
        )
        #expect(reply.status == 200)
        #expect((reply.data?["plain"] as? [String: Any])?["ref"] as? String == Self.first)

        // `name`, the item, the list and the receipt's field are all non-null:
        // the denial discards `nosy`, the nearest nullable ancestor, and keeps
        // its own path. The other branch survives.
        #expect(reply.data?["nosy"] is NSNull)
        #expect(Self.paths(reply) == ["nosy/affected/0/label"])
        let extensions = Self.extensions(reply.errors.first)
        #expect(extensions["kind"] as? String == "permission")
        #expect(extensions["permissionClass"] as? String == "capability")
        #expect(extensions["requiredCapability"] as? String == "fixture:read")

        // The denied read was never resolved, and says nothing about the action.
        #expect(try await bench.calls()["parent.name"] == nil)
        #expect(try await bench.names() == ["a", "b"])
        await bench.harness.stop()
    }

    // MARK: Failures the fixture reports

    @Test func theFixtureProducesEachExecutionClassification() async throws {
        let bench = try await Bench()
        let reader = try await bench.grant(["fixture:read"]).credential
        let reply = try await bench.post(
            """
            {
              gone: fixtureProbe(outcome: UNAVAILABLE)
              broken: fixtureProbe(outcome: FAILED)
              consent: fixtureProbe(outcome: OS_PERMISSION)
              fine: fixtureProbe(outcome: OK)
            }
            """, as: reader
        )
        #expect(reply.data?["fine"] as? String == "ok")
        let byPath = Dictionary(
            uniqueKeysWithValues: reply.errors.map { (Self.path($0), Self.extensions($0)) }
        )
        #expect(byPath.keys.sorted() == ["broken", "consent", "gone"])
        #expect(byPath["gone"]?["kind"] as? String == "unavailable")
        #expect(byPath["broken"]?["kind"] as? String == "failed")
        #expect(byPath["consent"]?["kind"] as? String == "permission")
        #expect(byPath["consent"]?["permissionClass"] as? String == "os-permission")
        #expect(byPath["consent"]?["osPermission"] as? String == "accessibility")
        #expect(byPath["consent"]?["permissionOwner"] as? String == "koine")
        #expect(byPath["consent"]?["requiredCapability"] == nil)
        await bench.harness.stop()
    }
}
