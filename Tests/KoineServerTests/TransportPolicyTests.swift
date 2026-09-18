import Foundation
import KoineCore
import KoineSQLiteStore
import KoineServer
import Testing

/// The version-1 transport contract (docs/specs/machine.md, "Local transport and
/// discovery"), driven over real loopback HTTP with hand-written requests.
@Suite struct TransportPolicyTests {
    // MARK: Request rules

    @Test func onlyPostToTheExactEndpointIsAccepted() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])

        #expect(try await harness.raw(bearer: bearer).status == 200)
        let get = try await harness.raw(bearer: bearer, method: "GET")
        #expect(get.status == 405)
        #expect(get.headers["allow"] == "POST")
        #expect(try await harness.raw(bearer: bearer, method: "PUT").status == 405)
        // A GET operation, and a credential in the query string, name a
        // different target: neither reaches authentication.
        #expect(try await harness.raw(bearer: nil, method: "GET", target: "/graphql?query=%7Bkoine%7D").status == 404)
        #expect(try await harness.raw(bearer: nil, target: "/graphql?access_token=\(bearer)").status == 404)
        #expect(try await harness.raw(bearer: bearer, target: "/").status == 404)
        await harness.stop()
    }

    @Test func onlyJSONRequestBodiesAreAccepted() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])

        for mediaType in ["text/plain", "application/graphql", "application/x-www-form-urlencoded", nil] {
            let reply = try await harness.raw(bearer: bearer, headers: ["Content-Type": mediaType])
            #expect(reply.status == 415, "\(mediaType ?? "no media type")")
        }
        let parameterised = try await harness.raw(
            bearer: bearer, headers: ["Content-Type": "Application/JSON; charset=utf-8"]
        )
        #expect(parameterised.status == 200)
        await harness.stop()
    }

    @Test func batchedAndMalformedBodiesAreRefused() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        let single = try Harness.requestBody(Harness.koine, variables: [:])
        let batch = Data("[".utf8) + single + Data(",".utf8) + single + Data("]".utf8)

        #expect(try await harness.raw(bearer: bearer, body: batch).status == 400)
        #expect(try await harness.raw(bearer: bearer, body: Data("{".utf8)).status == 400)
        #expect(try await harness.raw(bearer: bearer, body: Data()).status == 400)
        await harness.stop()
    }

    @Test func responseMediaTypeFollowsAccept() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        let modern = "application/graphql-response+json"

        let cases: [(String?, String)] = [
            (modern, modern),
            ("application/json;q=0.5, \(modern); charset=utf-8", modern),
            ("application/json", "application/json"),
            (nil, "application/json"),
        ]
        for (accept, expected) in cases {
            let reply = try await harness.raw(bearer: bearer, headers: ["Accept": accept])
            #expect(reply.status == 200)
            #expect(reply.headers["content-type"] == expected)
        }
        await harness.stop()
    }

    @Test func noResponseIsCacheableOrCarriesBrowserMachinery() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        let oversized = Data(count: RequestPolicy.version1.maximumBodyBytes + 1)

        let replies = [
            try await harness.raw(bearer: bearer),  // 200
            try await harness.raw("{ koine {", bearer: bearer),  // 400
            try await harness.raw(bearer: nil),  // 401
            try await harness.raw(bearer: bearer, headers: ["Origin": "https://example.com"]),  // 403
            try await harness.raw(bearer: bearer, method: "GET"),  // 405
            try await harness.raw(bearer: bearer, body: oversized),  // 413
            try await harness.raw(bearer: bearer, headers: ["Content-Type": "text/plain"]),  // 415
            try await harness.raw(bearer: bearer, headers: ["Host": "example.com"]),  // 421
        ]
        #expect(replies.map(\.status) == [200, 400, 401, 403, 405, 413, 415, 421])
        for reply in replies {
            #expect(reply.headers["cache-control"] == "no-store", "\(reply.status)")
            #expect(reply.headers["set-cookie"] == nil)
            #expect(reply.headers["location"] == nil)
            #expect(!reply.headers.keys.contains { $0.hasPrefix("access-control-") })
        }
        await harness.stop()
    }

    // MARK: Origin and Host

    @Test func anyOriginIsRejectedBeforeAnythingRuns() async throws {
        let harness = try await Harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        let variables: [String: Any] = ["label": "from-a-website", "capabilities": []]

        let origins = ["https://example.com", "null", "http://127.0.0.1:\(harness.port)"]
        for origin in origins {
            let reply = try await harness.raw(
                Harness.createGrant, variables: variables, bearer: manager,
                headers: ["Origin": origin]
            )
            #expect(reply.status == 403, "Origin: \(origin)")
            #expect(reply.body.isEmpty)
        }
        // CORS preflight gets no permission either.
        let preflight = try await harness.raw(
            bearer: nil, method: "OPTIONS",
            headers: ["Origin": "https://example.com", "Access-Control-Request-Method": "POST"]
        )
        #expect(preflight.status == 403)

        await harness.stop()
        #expect(try storedLabels(harness) == ["manager"])
    }

    @Test func hostMustBeTheLiteralBoundAddressAndPort() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])

        let wrong = [
            "localhost:\(harness.port)", "rebound.example.com:\(harness.port)", "127.0.0.1",
            "127.0.0.1:\(harness.port == 1 ? 2 : 1)", "[::1]:\(harness.port)",
        ]
        for host in wrong {
            #expect(try await harness.raw(bearer: bearer, headers: ["Host": host]).status == 421, "\(host)")
        }
        let absent = try await harness.raw(bearer: bearer, version: "HTTP/1.0", headers: ["Host": nil])
        #expect(absent.status == 421)
        await harness.stop()
    }

    // MARK: Status mapping

    @Test func requestErrorsAre400WithErrorsAndNoData() async throws {
        let harness = try await Harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])

        let syntax = try await harness.raw("{ koine { instanceId ", bearer: manager)
        let validation = try await harness.raw("{ koine { noSuchField } }", bearer: manager)
        let coercion = try await harness.raw(
            Harness.createGrant, variables: ["label": 42, "capabilities": []], bearer: manager
        )
        let missingVariable = try await harness.raw(
            Harness.createGrant, variables: ["capabilities": []], bearer: manager
        )
        let ambiguous = try await harness.raw("query A { __typename } query B { __typename }", bearer: manager)
        for reply in [syntax, validation, coercion, missingVariable, ambiguous] {
            #expect(reply.status == 400)
            #expect(!reply.errors.isEmpty)
            #expect(!reply.hasData)
        }
        await harness.stop()
        #expect(try storedLabels(harness) == ["manager"])
    }

    @Test func executedOperationsAre200WhateverTheirErrors() async throws {
        let harness = try await Harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])

        let reply = try await harness.raw(
            Harness.createGrant, variables: ["label": "x", "capabilities": ["no:such"]],
            bearer: manager
        )
        #expect(reply.status == 200)
        #expect(reply.json["data"] as? [String: NSNull] == ["koineCreateGrant": NSNull()])
        let error = try #require(reply.errors.first)
        #expect((error["extensions"] as? [String: Any])?["kind"] as? String == "failed")
        #expect(error["path"] as? [String] == ["koineCreateGrant"])
        await harness.stop()
    }

    @Test func authenticationIsPerRequestNotPerConnection() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        let body = try Harness.requestBody(Harness.koine, variables: [:])
        let authenticated = harness.requestBytes(
            headers: ["Authorization": "Bearer \(bearer)"], body: body
        )
        let anonymous = harness.requestBytes(body: body)

        let connection = try RawConnection(port: harness.port)
        var statuses: [Int] = []
        for request in [authenticated, anonymous, authenticated] {
            let reply = try await offPool {
                connection.send(request)
                return try connection.readResponse()
            }
            statuses.append(reply.status)
            #expect(reply.headers["connection"] == "keep-alive")
        }
        #expect(statuses == [200, 401, 200])
        await harness.stop()
    }

    // MARK: Limits

    @Test func version1PolicyIsTheContractsNumbers() {
        let policy = RequestPolicy.version1
        #expect(policy.version == 1)
        #expect(policy.maximumBodyBytes == 1_048_576)
        #expect(policy.maximumDepth == 16)
        #expect(policy.maximumFieldSelections == 1_000)
        #expect(policy.maximumRootMutationActions == 10)
        #expect(policy.maximumResponseBytes == 8_388_608)
        #expect(policy.executionDeadline == .seconds(5))
    }

    @Test func bodiesOverOneMebibyteNeverReachExecution() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        let limit = RequestPolicy.version1.maximumBodyBytes

        // Exactly at the limit: a valid request padded with a comment.
        let bare = try Harness.requestBody("{ __typename }", variables: [:]).count
        let padded = "{ __typename } #" + String(repeating: "x", count: limit - bare - 2)
        let atLimit = try Harness.requestBody(padded, variables: [:])
        #expect(atLimit.count == limit)
        #expect(try await harness.raw(bearer: bearer, body: atLimit).status == 200)

        let over = try Harness.requestBody(padded + "x", variables: [:])
        #expect(try await harness.raw(bearer: bearer, body: over).status == 413)

        // The same body undeclared: chunked, so only counting catches it.
        let connection = try RawConnection(port: harness.port)
        let chunked =
            harness.requestBytes(
                headers: [
                    "Authorization": "Bearer \(bearer)", "Content-Length": nil,
                    "Transfer-Encoding": "chunked",
                ],
                body: Data("\(String(over.count, radix: 16))\r\n".utf8) + over + Data("\r\n0\r\n\r\n".utf8)
            )
        let reply = try await offPool {
            connection.send(chunked)
            return try connection.readResponse()
        }
        #expect(reply.status == 413)
        await harness.stop()
    }

    @Test func depthIsLimitedToSixteenThroughFragments() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        /// `__schema { types { ofType { … { name } } } }` with `depth` field levels.
        func nested(_ depth: Int) -> String {
            let fields = ["__schema", "types"] + Array(repeating: "ofType", count: depth - 3) + ["name"]
            return "{ " + fields.joined(separator: " { ") + String(repeating: " }", count: depth)
        }

        let atLimit = try await harness.raw(nested(16), bearer: bearer)
        #expect(atLimit.status == 200)
        #expect(atLimit.errors.isEmpty)

        let over = try await harness.raw(nested(17), bearer: bearer)
        #expect(over.status == 400)
        #expect(!over.hasData)

        // Nine levels in the operation, eight more behind a fragment.
        let split = """
            { __schema { types { ofType { ofType { ofType { ofType { ofType { ofType { ofType { ...Rest } } } } } } } } } }
            fragment Rest on __Type { ofType { ofType { ofType { ofType { ofType { ofType { ofType { name } } } } } } } }
            """
        #expect(try await harness.raw(split, bearer: bearer).status == 400)

        // Far past what the parser could recurse through.
        let abusive = String(repeating: "{ a ", count: 100_000)
        #expect(try await harness.raw(abusive, bearer: bearer).status == 400)
        #expect(try await harness.raw(bearer: bearer).status == 200)
        await harness.stop()
    }

    @Test func expandedSelectionsAreLimitedToOneThousand() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        func aliases(_ count: Int) -> String {
            (0..<count).map { "a\($0): instanceId" }.joined(separator: " ")
        }

        // `koine` is itself a selection.
        let atLimit = try await harness.raw("{ koine { \(aliases(999)) } }", bearer: bearer)
        #expect(atLimit.status == 200)
        #expect(atLimit.errors.isEmpty)
        #expect(try await harness.raw("{ koine { \(aliases(1_000)) } }", bearer: bearer).status == 400)

        // Counted as expanded: eleven spreads of a hundred fields.
        let spreads = String(repeating: "...Hundred ", count: 11)
        let expanded = "{ koine { \(spreads)} } fragment Hundred on Koine { \(aliases(100)) }"
        #expect(try await harness.raw(expanded, bearer: bearer).status == 400)
        let tenSpreads = String(repeating: "...Hundred ", count: 9)
        let within = "{ koine { \(tenSpreads)} } fragment Hundred on Koine { \(aliases(100)) }"
        #expect(try await harness.raw(within, bearer: bearer).status == 200)

        // 2^40 selections from forty small fragments, and a cycle: both answer
        // promptly, and neither executes.
        var doubling = "{ koine { ...F0 } } fragment F40 on Koine { instanceId }"
        for level in 0..<40 {
            doubling += " fragment F\(level) on Koine { ...F\(level + 1) ...F\(level + 1) }"
        }
        #expect(try await harness.raw(doubling, bearer: bearer).status == 400)
        let cycle = "{ koine { ...A } } fragment A on Koine { ...B } fragment B on Koine { ...A }"
        let cyclic = try await harness.raw(cycle, bearer: bearer)
        #expect(cyclic.status == 400)
        #expect(!cyclic.hasData)
        await harness.stop()
    }

    @Test func rootMutationActionsAreLimitedToTen() async throws {
        let harness = try await Harness()
        let manager = try await harness.consoleGrant(label: "manager", capabilities: ["koine:manage"])
        func creating(_ count: Int, prefix: String) -> String {
            let actions = (0..<count).map {
                "g\($0): koineCreateGrant(input: { clientLabel: \"\(prefix)\($0)\", capabilities: [] }) { grant { grantId } }"
            }
            return "mutation { \(actions.joined(separator: " ")) }"
        }

        let over = try await harness.raw(creating(11, prefix: "over"), bearer: manager)
        #expect(over.status == 400)
        #expect(!over.hasData)

        let atLimit = try await harness.raw(creating(10, prefix: "ok"), bearer: manager)
        #expect(atLimit.status == 200)
        #expect(atLimit.errors.isEmpty)

        // The limit is a request error even for a caller preflight would deny.
        let reader = try await harness.consoleGrant(label: "reader", capabilities: [])
        #expect(try await harness.raw(creating(11, prefix: "denied"), bearer: reader).status == 400)
        #expect(try await harness.raw(creating(10, prefix: "denied"), bearer: reader).status == 403)

        await harness.stop()
        let labels = try storedLabels(harness)
        #expect(labels.count == 12)
        #expect(!labels.contains { $0.hasPrefix("over") || $0.hasPrefix("denied") })
    }

    @Test func introspectionFitsTheVersion1Limits() async throws {
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        let reply = try await harness.raw(Harness.introspection, bearer: bearer)

        #expect(reply.status == 200)
        #expect(reply.errors.isEmpty)
        #expect(reply.body.count < RequestPolicy.version1.maximumResponseBytes)
        await harness.stop()
    }

    @Test func responsesOverTheCapAreReplacedByAnError() async throws {
        var policy = RequestPolicy.version1
        policy.maximumResponseBytes = 2_000
        let harness = try await Harness(policy: policy)
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])

        #expect(try await harness.raw(bearer: bearer).errors.isEmpty)
        let reply = try await harness.raw(Harness.introspection, bearer: bearer)
        #expect(reply.status == 200)
        #expect(reply.body.count <= policy.maximumResponseBytes)
        #expect(reply.json["data"] is NSNull)
        let kinds = reply.errors.map { ($0["extensions"] as? [String: Any])?["kind"] as? String }
        #expect(kinds == ["failed"])
        await harness.stop()
    }

    @Test func executionPastItsDeadlineIsAnsweredAsFailed() async throws {
        var policy = RequestPolicy.version1
        policy.executionDeadline = .zero
        // The console is bound by the same deadline, so the grant comes first.
        let harness = try await Harness()
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        try await harness.restart(policy: policy)

        // Whichever of the response deadline and the resolver's own admission
        // check notices first, the caller sees the same thing.
        let reply = try await harness.raw(bearer: bearer)
        #expect(reply.status == 200)
        #expect(reply.json["data"] is NSNull)
        let kinds = reply.errors.map { ($0["extensions"] as? [String: Any])?["kind"] as? String }
        #expect(kinds == ["failed"])
        await harness.stop()
    }

    // MARK: Descriptor lifecycle

    @Test func aSecondInstanceCannotPublish() async throws {
        let harness = try await Harness()
        let published = try Data(contentsOf: harness.descriptorURL)

        #expect(throws: KoineServerError.alreadyRunning) {
            _ = try KoineServer(dataDirectory: harness.directory)
        }
        #expect(try Data(contentsOf: harness.descriptorURL) == published)
        let bearer = try await harness.consoleGrant(label: "reader", capabilities: [])
        #expect(try await harness.raw(bearer: bearer).status == 200)

        // Once the first has stopped, the directory is free again.
        await harness.stop()
        let successor = try KoineServer(dataDirectory: harness.directory)
        try await successor.start()
        #expect(try harness.descriptor()["instanceId"] as? String == successor.instanceId)
        await successor.stop()
    }

    @Test func aServerObjectIsOneRun() async throws {
        let harness = try await Harness()
        await #expect(throws: KoineServerError.alreadyStarted) { try await harness.server.start() }
        await harness.stop()
        await #expect(throws: KoineServerError.alreadyStarted) { try await harness.server.start() }
    }

    @Test func shutdownRemovesOnlyItsOwnDescriptor() async throws {
        let own = try await Harness()
        await own.stop()
        #expect(!FileManager.default.fileExists(atPath: own.descriptorURL.path))

        let displaced = try await Harness()
        let foreign = Data(
            #"{"contractVersion":"koine-desktop/1","descriptorVersion":1,"instanceId":"someone-else","path":"/graphql","pid":1,"port":9}"#
                .utf8
        )
        try foreign.write(to: displaced.descriptorURL)
        await displaced.stop()
        #expect(try Data(contentsOf: displaced.descriptorURL) == foreign)
    }

    @Test func aDescriptorLeftByADeadInstanceIsReplaced() async throws {
        // A plausible leftover: well formed, naming a live pid and a port.
        let leftover = Data(
            #"{"contractVersion":"koine-desktop/1","descriptorVersion":1,"instanceId":"dead","path":"/graphql","pid":\#(ProcessInfo.processInfo.processIdentifier),"port":9}"#
                .utf8
        )
        let harness = try await Harness { directory in
            try leftover.write(to: directory.appendingPathComponent("endpoint.json"))
        }
        let descriptor = try harness.descriptor()
        #expect(descriptor["instanceId"] as? String == harness.server.instanceId)
        #expect(descriptor["port"] as? Int != 9)
        let mode = try FileManager.default.attributesOfItem(atPath: harness.descriptorURL.path)
        #expect(mode[.posixPermissions] as? Int == 0o600)
        await harness.stop()
    }

    /// Labels of every stored grant, read from the store after the server stopped.
    private func storedLabels(_ harness: Harness) throws -> Set<String> {
        let store = try SQLiteGrantStore(
            path: harness.directory.appendingPathComponent("grants.sqlite").path
        )
        return Set(try store.grants().map(\.clientLabel))
    }
}
