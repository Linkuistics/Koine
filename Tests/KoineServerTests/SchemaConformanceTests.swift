import Foundation
import GraphQL
import KoineConformanceCheck
import KoineCore
import Testing

@testable import KoineServer

/// The instrument `task conformance` runs on, pinned here.
///
/// The VM run says the schema Koine serves is `docs/design/desktop-schema.graphql`.
/// A clean report and a misaddressed comparison look identical, and so do a
/// faithful capture and one that quietly dropped what it could not carry — so
/// what this suite establishes is what the instrument can and cannot see, by
/// measurement against a running engine rather than from the library's source.
@Suite struct SchemaConformanceTests {
    /// A contribution built to exercise the canonical printer rather than to be
    /// realistic: descriptions in every position the grammar allows one,
    /// arguments with defaults, a deprecated field, a deprecated enum value, an
    /// input object with a default of its own, a described argument (which the
    /// printer lays out over several lines), and a type described across a
    /// newline.
    private static let richSDL = """
        "A type whose description has\\na newline in it."
        type RichThing {
          "The identifier."
          id: ID!
          tally(
            "How many, at most."
            limit: Int = 10
            deep: [[String!]] = [["a"]]
            flag: Boolean = false
          ): Int!
          legacy: String @deprecated(reason: "Use id.")
          mood: RichMood!
        }

        "How it feels."
        enum RichMood {
          CALM
          "Not used any more."
          LOUD @deprecated
        }

        input RichFilter {
          "Only these."
          names: [String!]! = []
          since: String
        }
        """

    private static func rich() -> Stub {
        Stub(
            id: "rich", prefix: "Rich",
            sdl: richSDL + """


                extend type Query {
                  "read. Descriptions are part of the contract."
                  richThing(filter: RichFilter): RichThing
                }
                """,
            fields: [
                ("Query.richThing", .read), ("RichThing.id", .read), ("RichThing.tally", .read),
                ("RichThing.legacy", .read), ("RichThing.mood", .read),
            ]
        )
    }

    /// What the provider declared, as a schema document of its own. The
    /// comparison below is restricted to these coordinates, so the core's types
    /// are simply not in it.
    private static let richDesign = """
        schema { query: Query }

        type Query {
          "read. Descriptions are part of the contract."
          richThing(filter: RichFilter): RichThing
        }

        """ + richSDL

    private func introspect(_ providers: [Stub]) async throws -> (response: Data, digest: String) {
        let harness = try await Harness(providers: providers.map(\.active))
        #expect(harness.server.providerDiagnostics.isEmpty)
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let introspection = try await harness.post(
            IntrospectionQuery.text, authorization: "Bearer \(credential)"
        )
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        await harness.stop()
        #expect(introspection.status == 200)
        #expect(introspection.errors.isEmpty)
        let digest = try #require(
            (koine.data?["koine"] as? [String: Any])?["schemaDigest"] as? String)
        return (try JSONSerialization.data(withJSONObject: introspection.json), digest)
    }

    private func canonicalIntrospected(_ providers: [Stub]) async throws -> (String, String) {
        let (response, digest) = try await introspect(providers)
        let sdl = try IntrospectionSDL.sdl(fromIntrospectionResponse: response)
        return (try CanonicalSchemaText.canonicalText(ofSDL: sdl), digest)
    }

    private func differences(served: String, design: String) throws -> [SchemaDifference] {
        SchemaComparison(served: try parse(source: served), design: try parse(source: design))
            .differences()
    }

    // MARK: What the seam carries

    /// Measured, not assumed. Each of these is a limit of
    /// GraphQLSwift/GraphQL 4.2.0's introspection types, and each one shapes the
    /// check: a library upgrade that lifts one should fail this test, which is
    /// the point of pinning it.
    @Test func introspectionSortsFieldsAndCannotCarryAnInputFieldDefault() async throws {
        let harness = try await Harness(providers: [Self.rich().active])
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        func names(_ query: String, _ path: String) async throws -> [String] {
            let reply = try await harness.post(query, authorization: "Bearer \(credential)")
            let type = try #require(reply.data?["__type"] as? [String: Any])
            return ((type[path] as? [[String: Any]]) ?? []).compactMap { $0["name"] as? String }
        }

        // Declared contractVersion, instanceId, schemaDigest, ownGrant,
        // availableCapabilities. Introspection answers in name order, so the
        // canonical text cannot be recomputed from it.
        #expect(
            try await names("{ __type(name: \"Koine\") { fields { name } } }", "fields")
                == [
                    "availableCapabilities", "contractVersion", "instanceId", "ownGrant",
                    "schemaDigest",
                ])
        // Declared names, since.
        #expect(
            try await names(
                "{ __type(name: \"RichFilter\") { inputFields { name } } }", "inputFields")
                == ["names", "since"])

        // An input-object field's default is dropped; an argument's is served.
        let filter = try await harness.post(
            "{ __type(name: \"RichFilter\") { inputFields { name defaultValue } } }",
            authorization: "Bearer \(credential)")
        let inputFields = try #require(
            (filter.data?["__type"] as? [String: Any])?["inputFields"] as? [[String: Any]])
        #expect(
            inputFields.allSatisfy { $0["defaultValue"] is NSNull || $0["defaultValue"] == nil })

        // And asking for input-value deprecation errors rather than answering.
        let deprecation = try await harness.post(
            "{ __type(name: \"RichFilter\") { inputFields { name isDeprecated } } }",
            authorization: "Bearer \(credential)")
        #expect(
            deprecation.errors.contains {
                ($0["message"] as? String)?.contains("__InputValue.isDeprecated") == true
            })
        await harness.stop()
    }

    /// Everything else survives the round trip, and the one thing that does not
    /// is named rather than tolerated: `RichFilter.names`' default. If the
    /// rebuild ever loses a description, a nullability marker, an argument
    /// default or a deprecation, this stops being one difference.
    @Test func aRebuiltSchemaKeepsEverythingTheSeamCanCarry() async throws {
        let (canonical, _) = try await canonicalIntrospected([Self.rich()])
        let mine = try differences(served: canonical, design: Self.richDesign)
            .filter { $0.coordinate.hasPrefix("Rich") || $0.coordinate == "Query.richThing" }
        #expect(mine.count == 1, Comment(rawValue: "\(mine.map(\.report))"))
        #expect(mine.first?.coordinate == "RichFilter.names")
        #expect(mine.first?.aspect == .defaultValue)
        #expect(mine.first?.served == "none")
        #expect(mine.first?.design == "[]")
    }

    @Test func aSchemaComparedWithItselfReportsNothing() async throws {
        let (canonical, _) = try await canonicalIntrospected([Self.rich()])
        #expect(try differences(served: canonical, design: canonical).isEmpty)
    }

    // MARK: The positive control

    /// A difference report that finds nothing looks the same whether the
    /// schemas agree or the comparison is misaddressed. Each aspect the check
    /// claims to report is mutated into the design side and watched to appear,
    /// by aspect and at the right coordinate.
    @Test(arguments: [
        (
            "a description removed", "\"The identifier.\"\n  id: ID!", "id: ID!",
            "RichThing.id", SchemaDifference.Aspect.description
        ),
        (
            "a nullability marker removed", "id: ID!", "id: ID",
            "RichThing.id", SchemaDifference.Aspect.type
        ),
        (
            "an argument default changed", "limit: Int = 10", "limit: Int = 25",
            "RichThing.tally(limit:)", SchemaDifference.Aspect.defaultValue
        ),
        (
            "an argument removed", "flag: Boolean = false\n  ): Int!", "): Int!",
            "RichThing.tally(flag:)", SchemaDifference.Aspect.presence
        ),
        (
            "an argument's description removed", "\"How many, at most.\"\n    limit", "limit",
            "RichThing.tally(limit:)", SchemaDifference.Aspect.description
        ),
        (
            "a deprecation reason changed", "@deprecated(reason: \"Use id.\")",
            "@deprecated(reason: \"Gone.\")",
            "RichThing.legacy", SchemaDifference.Aspect.deprecation
        ),
        (
            "an enum value's description removed", "\"Not used any more.\"\n  LOUD", "LOUD",
            "RichMood.LOUD", SchemaDifference.Aspect.description
        ),
        (
            "an enum value removed", "  CALM\n", "", "RichMood.CALM",
            SchemaDifference.Aspect.presence
        ),
        (
            "a type's description removed", "\"How it feels.\"\nenum RichMood", "enum RichMood",
            "RichMood", SchemaDifference.Aspect.description
        ),
        (
            "a whole field removed", "  mood: RichMood!\n", "", "RichThing.mood",
            SchemaDifference.Aspect.presence
        ),
        (
            "two arguments transposed", "deep: [[String!]] = [[\"a\"]]\n    flag: Boolean = false",
            "flag: Boolean = false\n    deep: [[String!]] = [[\"a\"]]",
            "RichThing.tally", SchemaDifference.Aspect.declaredOrder
        ),
    ])
    func aMutatedContractIsReportedByAspectAndCoordinate(
        _ mutation: (
            what: String, from: String, to: String, coordinate: String,
            aspect: SchemaDifference.Aspect
        )
    ) async throws {
        let (canonical, _) = try await canonicalIntrospected([Self.rich()])
        // The design side is the provider's own declaration with one thing
        // changed, which is what mutating docs/design/desktop-schema.graphql
        // does in the VM run.
        #expect(
            Self.richDesign.contains(mutation.from),
            "the mutation's anchor is no longer in the design text")
        let mutated = Self.richDesign.replacingOccurrences(
            of: mutation.from, with: mutation.to)
        let found = try differences(served: canonical, design: mutated)
        #expect(
            found.contains {
                $0.coordinate.hasPrefix(mutation.coordinate) && $0.aspect == mutation.aspect
            },
            Comment(
                rawValue: "\(mutation.what) was not reported as \(mutation.aspect.rawValue) at "
                    + "\(mutation.coordinate): \(found.map(\.report))")
        )
    }

    /// The half of the contract the difference report cannot see, and the reason
    /// the check also compares digests: transposing two fields changes nothing
    /// the introspected text carries, and changes the digest.
    @Test func transposedFieldsAreInvisibleToTheReportAndMoveTheDigest() async throws {
        let transposed = Self.richDesign.replacingOccurrences(
            of: "  legacy: String @deprecated(reason: \"Use id.\")\n  mood: RichMood!",
            with: "  mood: RichMood!\n  legacy: String @deprecated(reason: \"Use id.\")"
        )
        #expect(transposed != Self.richDesign)

        let (canonical, _) = try await canonicalIntrospected([Self.rich()])
        let before = try differences(served: canonical, design: Self.richDesign)
        let after = try differences(served: canonical, design: transposed)
        #expect(before.map(\.report) == after.map(\.report))

        #expect(
            try CanonicalSchemaText.digest(ofSDL: Self.richDesign)
                != CanonicalSchemaText.digest(ofSDL: transposed))
    }
}

// MARK: The contract itself

/// The same check `task conformance` makes in a VM against the notarized
/// application, made here against a composition assembled in process: the
/// bundled desktop provider contributes `Providers/DesktopProvider/schema.graphql`
/// verbatim (its `build.sh` compiles that file in), so composing it as the
/// bundled provider gives the schema the real bundle contributes.
///
/// This is the fast guard, not the authority. It cannot see a provider bundle
/// that ships an SDL different from the file in the tree, or a loader that
/// refuses the provider, which is why the VM run exists — but it fails in
/// seconds when a later leaf changes a description or a nullability marker,
/// instead of five leaves later.
@Suite struct DesignContractConformanceTests {
    private static func repositoryFile(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // KoineServerTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repository root
        return try String(contentsOf: root.appending(path: path), encoding: .utf8)
    }

    private func composed() async throws -> (canonical: String, digest: String) {
        let sdl = try Self.repositoryFile("Providers/DesktopProvider/schema.graphql")
        // The coordinates the real descriptor registers; the schema does not
        // depend on their authority, only on their being complete.
        let desktop = Stub(
            id: "desktop", prefix: "Desktop", sdl: sdl,
            fields: [
                ("Query.desktopApplication", .read),
                ("Query.desktopApplicationByReference", .read),
                ("Query.desktopWindow", .read),
                ("Mutation.desktopFocusWindow", .control),
                ("DesktopApplication.ref", .read), ("DesktopApplication.name", .read),
                ("DesktopApplication.bundleIdentifier", .read),
                ("DesktopApplication.windows", .read),
                ("DesktopWindow.ref", .read), ("DesktopWindow.title", .read),
                ("DesktopWindow.observation", .read),
                ("DesktopFocusReceipt.ref", .control),
            ],
            origin: .bundled
        )
        let harness = try await Harness(providers: [desktop.active])
        #expect(harness.server.providerDiagnostics.isEmpty)
        let credential = try await harness.consoleGrant(label: "c", capabilities: [])
        let introspection = try await harness.post(
            IntrospectionQuery.text, authorization: "Bearer \(credential)")
        let koine = try await harness.post(Harness.koine, authorization: "Bearer \(credential)")
        await harness.stop()
        #expect(introspection.errors.isEmpty)
        let digest = try #require(
            (koine.data?["koine"] as? [String: Any])?["schemaDigest"] as? String)
        let response = try JSONSerialization.data(withJSONObject: introspection.json)
        let canonical = try CanonicalSchemaText.canonicalText(
            ofSDL: try IntrospectionSDL.sdl(fromIntrospectionResponse: response))
        return (canonical, digest)
    }

    /// Two claims at once, because either alone can be satisfied by a schema
    /// that is wrong in the way the other catches: the difference report is
    /// empty, which says the served types, fields, arguments, nullability,
    /// defaults, deprecations and descriptions are the design file's and says
    /// where when they are not; and the digest of the canonically printed design
    /// file is the one Koine served, which additionally covers declared order —
    /// invisible to the report — and needs nothing from introspection.
    @Test func theServedSchemaIsTheDesignContract() async throws {
        let design = try Self.repositoryFile("docs/design/desktop-schema.graphql")
        let (canonical, digest) = try await composed()
        let found = SchemaComparison(
            served: try parse(source: canonical),
            design: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: design))
        ).differences()
        #expect(found.isEmpty, Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        // Declared order too, which the report above cannot see.
        #expect(try CanonicalSchemaText.digest(ofSDL: design) == digest)
    }
}
