import Foundation
import GraphQL
import KoineConformanceCheck
import KoineCore
import KoineProviderAPI
import Testing

@testable import KoineServer
@testable import WorkspaceProviderLogic

/// The instrument `task conformance` runs on, pinned here.
///
/// The VM run says the schema Koine serves is the profile's design SDL
/// (`docs/design/desktop-schema-extension-host.graphql`).
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
        // changed, which is what mutating the profile's design SDL
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

    private static func desktopStub() throws -> Stub {
        let sdl = try repositoryFile("Providers/DesktopProvider/schema.graphql")
        // The coordinates the real descriptor registers; the schema does not
        // depend on their authority, only on their being complete.
        return Stub(
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
    }

    /// The workspace bundle's real descriptor and the SDL it ships, with a
    /// provider that is never asked anything: only the schema is composed here.
    private static func workspaceProvider() throws -> ActiveProvider {
        ActiveProvider(
            descriptor: workspaceDescriptor(
                schemaSDL: try repositoryFile("Providers/WorkspaceProvider/schema.graphql")),
            provider: WorkspaceCompositionTests.ScriptedWorkspace(WorkspaceCompositionTests.Script()),
            origin: .bundled
        )
    }

    private func composed(_ providers: [ActiveProvider]) async throws -> (canonical: String, digest: String) {
        let harness = try await Harness(providers: providers)
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

    private func composed() async throws -> (canonical: String, digest: String) {
        try await composed([Self.desktopStub().active])
    }

    /// Two claims at once, because either alone can be satisfied by a schema
    /// that is wrong in the way the other catches: the difference report is
    /// empty, which says the served types, fields, arguments, nullability,
    /// defaults, deprecations and descriptions are the design file's and says
    /// where when they are not; and the digest of the canonically printed design
    /// file is the one Koine served, which additionally covers declared order —
    /// invisible to the report — and needs nothing from introspection.
    @Test func theServedSchemaIsTheDesignContract() async throws {
        let design = try Self.repositoryFile("docs/design/desktop-schema-extension-host.graphql")
        let (canonical, digest) = try await composed()
        let found = SchemaComparison(
            served: try parse(source: canonical),
            design: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: design))
        ).differences()
        #expect(found.isEmpty, Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        // Declared order too, which the report above cannot see.
        #expect(try CanonicalSchemaText.digest(ofSDL: design) == digest)
    }

    /// The core alone, which a host serves when every provider it was given is refused
    /// or removed before publication: the cascade profile's design file, the same two
    /// claims as above.
    @Test func theServedCoreAloneIsItsDesignContract() async throws {
        let design = try Self.repositoryFile("docs/design/core-schema-extension-host.graphql")
        let (canonical, digest) = try await composed([])
        let found = SchemaComparison(
            served: try parse(source: canonical),
            design: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: design))
        ).differences()
        #expect(found.isEmpty, Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        #expect(try CanonicalSchemaText.digest(ofSDL: design) == digest)
    }

    // MARK: core + desktop + workspace

    /// The same two claims for the third profile: the bundles' own SDL, composed
    /// with the core through the engine, is the workspace profile's design file,
    /// declared order included.
    /// The bundle in the tree is workspace 1.0.1, so what it serves is the repaired composition;
    /// the retained 1.0.0 composition is held to the retained bundle (`task compat:workspace-baseline-verify`).
    @Test func theServedCoreDesktopWorkspaceSchemaIsItsDesignContract() async throws {
        let design = try Self.repositoryFile("docs/design/desktop-workspace-repair-schema-extension-host.graphql")
        let (canonical, digest) = try await composed([Self.desktopStub().active, Self.workspaceProvider()])
        let found = SchemaComparison(
            served: try parse(source: canonical),
            design: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: design))
        ).differences()
        #expect(found.isEmpty, Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        #expect(try CanonicalSchemaText.digest(ofSDL: design) == digest)
    }

    /// The repair is visible to the one thing a client compares: the schema the 1.0.1 bundle serves differs
    /// from the retained 1.0.0 composition in exactly the three action descriptions, and so in digest, on
    /// the same host and printer. Neither claim alone would do: the digest differs for any change at all.
    @Test func theRepairDiffersFromTheRetainedCompositionInExactlyTheThreeActionDescriptions() async throws {
        let retained = try Self.repositoryFile("docs/design/desktop-workspace-schema-extension-host.graphql")
        let (canonical, digest) = try await composed([Self.desktopStub().active, Self.workspaceProvider()])
        let found = SchemaComparison(
            served: try parse(source: canonical),
            design: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: retained))
        ).differences()
        #expect(
            Set(found.map(\.coordinate)) == [
                "Mutation.workspaceLaunchApplication", "Mutation.workspaceOpenPath", "Mutation.workspaceRevealPath",
            ], Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        #expect(found.allSatisfy { $0.aspect == .description })
        #expect(try CanonicalSchemaText.digest(ofSDL: retained) != digest)
    }

    /// What is not implemented yet: nothing. The last root has landed, so the profile's file is
    /// the complete workspace design. A root added to the design later that this set does not
    /// name turns the next test red, and the set grows only for a root that has not landed.
    static let workspaceCoordinatesNotYetImplemented: Set<String> = []

    /// The workspace part of the profile is the design SDL, never reworded: against the
    /// desktop design plus the complete workspace design, the profile's file lacks exactly the
    /// roots not implemented (none now) and the types only they reach, and every coordinate it
    /// does declare is identical — text, nullability, arguments and all.
    @Test func theWorkspaceProfileIsTheWorkspaceDesignRestrictedVerbatim() throws {
        let profile = try Self.repositoryFile("docs/design/desktop-workspace-schema-extension-host.graphql")
        let complete = try Self.repositoryFile("docs/design/desktop-schema-extension-host.graphql")
            + "\n" + (try Self.repositoryFile("docs/design/workspace-schema.graphql"))
        let found = SchemaComparison(
            served: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: profile)),
            design: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: complete))
        ).differences()
        #expect(
            Set(found.map(\.coordinate)) == Self.workspaceCoordinatesNotYetImplemented,
            Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        #expect(found.allSatisfy { $0.aspect == .presence })
        // The shipped SDL is that same restriction: nothing implemented is missing from it.
        let implemented = try CanonicalSchemaText.canonicalText(ofSDL: profile)
        for root in ["workspaceLaunchApplication", "workspaceOpenURL", "workspaceOpenPath", "workspaceRevealPath"] {
            #expect(implemented.contains(root), "\(root) is implemented and must be declared")
        }
    }

    /// The 1.0.1 composition is the repair SDL restricted the same way: every workspace coordinate of the
    /// profile is the repair design's, text and all, so the shipped contribution is never reworded.
    @Test func theRepairProfileIsTheRepairDesignRestrictedVerbatim() throws {
        let profile = try Self.repositoryFile("docs/design/desktop-workspace-repair-schema-extension-host.graphql")
        let complete = try Self.repositoryFile("docs/design/desktop-schema-extension-host.graphql")
            + "\n" + (try Self.repositoryFile("docs/design/workspace-action-repair-schema.graphql"))
        let found = SchemaComparison(
            served: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: profile)),
            design: try parse(source: try CanonicalSchemaText.canonicalText(ofSDL: complete))
        ).differences()
        #expect(
            Set(found.map(\.coordinate)) == Self.workspaceCoordinatesNotYetImplemented,
            Comment(rawValue: found.map(\.report).joined(separator: "\n")))
    }
}

// MARK: Profiles

/// The two profiles `task conformance` holds a host to. The old-host profile is
/// the released contract and must stay byte-for-byte what it was; the
/// extension-host profile is that contract plus the candidate diagnostics and
/// nothing else. Candidates are pinned apart from both, because an identical
/// digest cannot prove which binary ran.
@Suite struct ConformanceProfileTests {
    private static func url(_ path: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: path)
    }

    private static func profile(_ name: String) throws -> (profile: ConformanceProfile, design: URL) {
        try ConformanceProfile.load(from: url("docs/design/profiles/\(name).json"))
    }

    private static func row(
        _ overrides: [String: String?] = [:], extended: Bool = true
    ) -> [String: String?] {
        var row: [String: String?] = [
            "provider": "desktop", "version": "1.0.0", "schemaVersion": "1.0.0",
            "state": "ACTIVE", "diagnostic": nil,
        ]
        if extended {
            row.merge([
                "candidateId": "c1", "origin": "BUNDLED", "selection": "SELECTED",
                "selectedCandidateId": "c1", "reason": nil,
            ]) { $1 }
        }
        return row.merging(overrides) { $1 }
    }

    // MARK: The design files

    @Test func theOldHostProfileIsTheReleasedContractPlusNothingBut() throws {
        let old = try Self.profile("core-desktop-old-host")
        let extended = try Self.profile("core-desktop-extension-host")
        #expect(old.profile.management == .baseline && extended.profile.management == .extended)
        #expect(old.design.lastPathComponent == "desktop-schema.graphql")
        #expect(extended.design.lastPathComponent == "desktop-schema-extension-host.graphql")

        let oldText = try CanonicalSchemaText.canonicalText(
            ofSDL: try String(contentsOf: old.design, encoding: .utf8))
        let extendedText = try CanonicalSchemaText.canonicalText(
            ofSDL: try String(contentsOf: extended.design, encoding: .utf8))
        let found = SchemaComparison(
            served: try parse(source: extendedText), design: try parse(source: oldText)
        ).differences()

        // Exactly the additions: five nullable fields and the two enums they use, and the
        // capability disclosures (one management field and the type it returns).
        #expect(
            Set(found.map(\.coordinate)) == [
                "KoineProviderStatus.candidateId", "KoineProviderStatus.origin",
                "KoineProviderStatus.selection", "KoineProviderStatus.selectedCandidateId",
                "KoineProviderStatus.reason", "KoineProviderOrigin", "KoineProviderSelection",
                "KoineManagement.capabilityDisclosures", "KoineCapabilityDisclosure",
            ], Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        #expect(found.allSatisfy { $0.aspect == .presence })
        // The two profiles are two schemas: their digests differ.
        #expect(
            try CanonicalSchemaText.digest(ofSDL: String(contentsOf: old.design, encoding: .utf8))
                != CanonicalSchemaText.digest(ofSDL: String(contentsOf: extended.design, encoding: .utf8)))
    }

    /// The workspace profile is the extension-host profile plus the workspace
    /// contribution and its candidate, and nothing else: against the desktop-only
    /// design file it adds the workspace coordinates and changes no other.
    @Test func theWorkspaceProfileAddsTheWorkspaceContributionAndNothingElse() throws {
        let extended = try Self.profile("core-desktop-extension-host")
        let workspace = try Self.profile("core-desktop-workspace-extension-host")
        #expect(workspace.profile.management == .extended)
        #expect(workspace.design.lastPathComponent == "desktop-workspace-schema-extension-host.graphql")
        let extendedText = try CanonicalSchemaText.canonicalText(
            ofSDL: try String(contentsOf: extended.design, encoding: .utf8))
        let workspaceText = try CanonicalSchemaText.canonicalText(
            ofSDL: try String(contentsOf: workspace.design, encoding: .utf8))
        let found = SchemaComparison(
            served: try parse(source: workspaceText), design: try parse(source: extendedText)
        ).differences()
        #expect(
            Set(found.map(\.coordinate)) == [
                "Mutation.workspaceLaunchApplication", "Mutation.workspaceOpenURL", "Mutation.workspaceOpenPath",
                "Mutation.workspaceRevealPath", "WorkspaceApplicationInput",
                "WorkspaceOperationStatus", "WorkspaceDependencyReason",
                "WorkspaceDependencyUnavailable", "WorkspaceProcessIdentity",
                "WorkspaceOpenReceipt", "WorkspaceOpenResult", "WorkspaceRevealReceipt", "WorkspaceRevealResult",
            ], Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        #expect(found.allSatisfy { $0.aspect == .presence })
        #expect(workspace.profile.providers.map { $0.fields["provider"] ?? nil } == ["desktop", "workspace"])
    }

    /// The cascade profile's design is the extension-host core + desktop design with the
    /// desktop contribution taken out and nothing else changed: every coordinate it lacks
    /// is one of desktop's, and every one it has is identical.
    @Test func theCoreAloneDesignIsTheDesktopDesignLessDesktop() throws {
        let cascade = try Self.profile("selection-cascade-extension-host")
        #expect(cascade.profile.management == .extended)
        #expect(cascade.design.lastPathComponent == "core-schema-extension-host.graphql")
        let extended = try Self.profile("core-desktop-extension-host")
        let coreText = try CanonicalSchemaText.canonicalText(
            ofSDL: try String(contentsOf: cascade.design, encoding: .utf8))
        let desktopText = try CanonicalSchemaText.canonicalText(
            ofSDL: try String(contentsOf: extended.design, encoding: .utf8))
        let found = SchemaComparison(
            served: try parse(source: coreText), design: try parse(source: desktopText)
        ).differences()
        #expect(
            Set(found.map(\.coordinate)) == [
                "Query.desktopApplication", "Query.desktopApplicationByReference", "Query.desktopWindow",
                "Mutation.desktopFocusWindow", "DesktopProcessStart", "DesktopProcessIdentity",
                "DesktopApplication", "DesktopWindow", "DesktopObservation", "DesktopFocusReceipt",
            ], Comment(rawValue: found.map(\.report).joined(separator: "\n")))
        #expect(found.allSatisfy { $0.aspect == .presence })
        #expect(
            try CanonicalSchemaText.digest(ofSDL: String(contentsOf: cascade.design, encoding: .utf8))
                != CanonicalSchemaText.digest(ofSDL: String(contentsOf: extended.design, encoding: .utf8)))
    }

    private static func cascadeRow(
        _ provider: String, _ version: String, schema: String, origin: String, selection: String, reason: String,
        _ id: String
    ) -> [String: String?] {
        [
            "provider": provider, "version": version, "schemaVersion": schema, "state": "REJECTED",
            "diagnostic": "x", "candidateId": id, "origin": origin, "selection": selection,
            "selectedCandidateId": selection == "SELECTED" ? id : "other", "reason": reason,
        ]
    }

    private static var cascadeServed: [[String: String?]] {
        [
            cascadeRow("fixturesh", "2.0.0", schema: "1.1.0", origin: "PER_USER", selection: "SELECTED", reason: "invalid-sdl", "a"),
            cascadeRow("fixturesh", "1.0.0", schema: "1.1.0", origin: "BUNDLED", selection: "NOT_SELECTED", reason: "superseded-candidate", "b"),
            cascadeRow("fixturesk", "1.1.0", schema: "1.0.0", origin: "PER_USER", selection: "SELECTED", reason: "missing-capability-owner", "c"),
            cascadeRow("fixturesk", "1.0.0", schema: "1.0.0", origin: "BUNDLED", selection: "NOT_SELECTED", reason: "superseded-candidate", "d"),
            cascadeRow("fixtureod", "1.0.0", schema: "1.0.0", origin: "PER_USER", selection: "SELECTED", reason: "missing-capability-owner", "e"),
        ]
    }

    /// The absent/rejected profile pins every row the cascade leaves: the refused desktop stand-in and
    /// its superseded baseline, the two providers removed for a missing owner, and their reasons.
    @Test func theCascadeProfilePinsEveryRejectedRowExactly() throws {
        let cascade = try Self.profile("selection-cascade-extension-host").profile
        #expect(cascade.providers.count == 5)
        #expect(cascade.problems(inServed: Self.cascadeServed).isEmpty)
        // Served in any order.
        #expect(cascade.problems(inServed: Self.cascadeServed.reversed()).isEmpty)
    }

    @Test(arguments: [
        ("a provider that was not removed", 4, ["state": "ACTIVE", "reason": nil]),
        ("a removal for another reason", 4, ["reason": "principal-collision"]),
        ("the third removed as not selected", 4, ["selection": "NOT_SELECTED"]),
        ("another release of the refused desktop", 0, ["version": "2.0.1"]),
        ("a refused desktop with another reason", 0, ["reason": "load-failed"]),
    ] as [(String, Int, [String: String?])])
    func aCascadeThatDiffersFromTheProfileIsNamed(what: String, index: Int, changes: [String: String?]) throws {
        let cascade = try Self.profile("selection-cascade-extension-host").profile
        var served = Self.cascadeServed
        served[index].merge(changes) { $1 }
        let problems = cascade.problems(inServed: served)
        #expect(!problems.isEmpty, Comment(rawValue: "\(what) passed the profile"))
        #expect(problems.contains { $0.contains("is not served as expected") }, Comment(rawValue: "\(problems)"))
    }

    @Test func aCascadeMissingARowOrHoldingAnExtraOneFailsTheProfile() throws {
        let cascade = try Self.profile("selection-cascade-extension-host").profile
        let missing = cascade.problems(inServed: Array(Self.cascadeServed.dropLast()))
        #expect(missing.count == 1 && missing[0].contains("required fixtureod 1.0.0") && missing[0].contains("is missing"))
        let stray = Self.cascadeRow(
            "workspace", "1.0.0", schema: "1.0.0", origin: "BUNDLED", selection: "SELECTED", reason: "x", "f")
        let extra = cascade.problems(inServed: Self.cascadeServed + [stray])
        #expect(extra.count == 1 && extra[0].contains("unexpected row workspace"))
    }

    // MARK: Candidates

    @Test func theExactPinnedCandidateHoldsTheProfile() throws {
        let extended = try Self.profile("core-desktop-extension-host").profile
        #expect(extended.problems(inServed: [Self.row()]).isEmpty)
        let old = try Self.profile("core-desktop-old-host").profile
        #expect(old.problems(inServed: [Self.row(extended: false)]).isEmpty)
    }

    private static func workspaceRow(_ overrides: [String: String?] = [:]) -> [String: String?] {
        row(["provider": "workspace", "candidateId": "c2", "selectedCandidateId": "c2"].merging(overrides) { $1 })
    }

    @Test func bothPinnedCandidatesHoldTheWorkspaceProfile() throws {
        let workspace = try Self.profile("core-desktop-workspace-extension-host").profile
        #expect(workspace.problems(inServed: [Self.row(), Self.workspaceRow()]).isEmpty)
        // The order the host reports them in is not the profile's to fix.
        #expect(workspace.problems(inServed: [Self.workspaceRow(), Self.row()]).isEmpty)
    }

    /// The repair's profile is the retained one with the workspace candidate and the design moved to the
    /// repair's, and nothing else: the pins say which binary ran, so 1.0.0 and 1.0.1 each fail the other's.
    @Test func theRepairProfilePinsWorkspace101AndNotTheRetainedRelease() throws {
        let retained = try Self.profile("core-desktop-workspace-extension-host")
        let repair = try Self.profile("core-desktop-workspace-repair-extension-host")
        #expect(repair.profile.management == .extended)
        #expect(repair.design.lastPathComponent == "desktop-workspace-repair-schema-extension-host.graphql")
        #expect(repair.profile.providers.map { $0.fields["provider"] ?? nil } == ["desktop", "workspace"])
        let desktop = Self.row()
        let workspace101 = Self.workspaceRow(["version": "1.0.1", "schemaVersion": "1.0.1"])
        #expect(repair.profile.problems(inServed: [desktop, workspace101]).isEmpty)
        #expect(repair.profile.problems(inServed: [workspace101, desktop]).isEmpty)
        // The retained workspace is not the repair, and the repair is not the retained workspace.
        let retainedServed = repair.profile.problems(inServed: [desktop, Self.workspaceRow()])
        #expect(retainedServed.contains { $0.contains("required workspace 1.0.1") && $0.contains("is not served as expected") })
        #expect(retained.profile.problems(inServed: [desktop, workspace101]).contains {
            $0.contains("required workspace 1.0.0") && $0.contains("is not served as expected")
        })
        // Release and schema are pinned separately: neither number stands in for the other.
        for changes in [["schemaVersion": "1.0.0"], ["version": "1.0.0"]] {
            let problems = repair.profile.problems(
                inServed: [desktop, Self.workspaceRow(["version": "1.0.1", "schemaVersion": "1.0.1"].merging(changes) { $1 })])
            #expect(problems.contains { $0.contains("is not served as expected") }, "\(changes)")
        }
        // The two profiles' designs are two schemas: their digests differ.
        #expect(
            try CanonicalSchemaText.digest(ofSDL: String(contentsOf: retained.design, encoding: .utf8))
                != CanonicalSchemaText.digest(ofSDL: String(contentsOf: repair.design, encoding: .utf8)))
    }

    @Test func aMissingRequiredWorkspaceFailsTheWorkspaceProfile() throws {
        let workspace = try Self.profile("core-desktop-workspace-extension-host").profile
        let problems = workspace.problems(inServed: [Self.row()])
        #expect(problems.count == 1, Comment(rawValue: "\(problems)"))
        #expect(problems[0].contains("required workspace 1.0.0") && problems[0].contains("is missing"))
        // And an extension-host profile with no workspace fails a host that serves one.
        let desktopOnly = try Self.profile("core-desktop-extension-host").profile
        let stray = desktopOnly.problems(inServed: [Self.row(), Self.workspaceRow()])
        #expect(stray.count == 1 && stray[0].contains("unexpected row workspace"))
    }

    @Test(arguments: [
        ("a different workspace release", ["version": "1.1.0"]),
        ("a different workspace schema", ["schemaVersion": "2.0.0"]),
        ("a workspace that failed", ["state": "FAILED"]),
        ("a per-user workspace", ["origin": "PER_USER"]),
        ("a workspace that was not selected", ["selection": "NOT_SELECTED"]),
    ] as [(String, [String: String?])])
    func aWorkspaceThatDiffersFromThePinIsNamedWithWhatIsServed(
        what: String, changes: [String: String?]
    ) throws {
        let workspace = try Self.profile("core-desktop-workspace-extension-host").profile
        let problems = workspace.problems(inServed: [Self.row(), Self.workspaceRow(changes)])
        // The pinned row is named with what is served instead, and the served row the
        // profile did not expect is reported beside it.
        #expect(
            problems.contains {
                $0.contains("required workspace 1.0.0") && $0.contains("is not served as expected")
            }, Comment(rawValue: "\(what): \(problems)"))
        #expect(problems.contains { $0.contains("unexpected row workspace") })
        #expect(problems.count == 2, Comment(rawValue: "\(what): \(problems)"))
    }

    @Test func aRequiredProviderThatIsOmittedFailsTheProfileRatherThanShrinkingIt() throws {
        let extended = try Self.profile("core-desktop-extension-host").profile
        let problems = extended.problems(inServed: [])
        #expect(problems.count == 1 && problems[0].contains("required desktop 1.0.0"))
        #expect(problems[0].contains("is missing"))
    }

    @Test(arguments: [
        ("a different release", ["version": "1.1.0"]),
        ("a different schema", ["schemaVersion": "1.1.0"]),
        ("another state", ["state": "FAILED"]),
        ("another origin", ["origin": "PER_USER"]),
        ("not selected", ["selection": "NOT_SELECTED"]),
        ("a reason where none is expected", ["reason": "selected-with-refusals"]),
    ] as [(String, [String: String?])])
    func aCandidateThatDiffersFromThePinIsNamedWithWhatIsServed(
        what: String, changes: [String: String?]
    ) throws {
        let extended = try Self.profile("core-desktop-extension-host").profile
        let problems = extended.problems(inServed: [Self.row(changes)])
        #expect(!problems.isEmpty, Comment(rawValue: "\(what) passed the profile"))
        #expect(problems.contains { $0.contains("is not served as expected") }, Comment(rawValue: "\(problems)"))
    }

    @Test func aRowTheProfileDidNotExpectFailsIt() throws {
        let extended = try Self.profile("core-desktop-extension-host").profile
        let stray = Self.row(["provider": "workspace", "candidateId": "c2", "selectedCandidateId": "c2"])
        let problems = extended.problems(inServed: [Self.row(), stray])
        #expect(problems.count == 1 && problems[0].contains("unexpected row workspace"))
    }

    @Test func anExtensionHostMustServeTheCandidateFieldsOnEveryRow() throws {
        let extended = try Self.profile("core-desktop-extension-host").profile
        let problems = extended.problems(inServed: [Self.row(extended: false)])
        #expect(problems.contains { $0.contains("does not carry the candidate fields") })
    }

    @Test func aSelectedRowMustNameItself() throws {
        let extended = try Self.profile("core-desktop-extension-host").profile
        let problems = extended.problems(inServed: [Self.row(["selectedCandidateId": "elsewhere"])])
        #expect(problems.contains { $0.contains("does not name itself") })
    }

    @Test func aProfileNeedsItsFourPinnedFields() throws {
        let text = #"{ "name": "x", "design": "d.graphql", "management": "baseline", "providers": [ { "provider": "desktop" } ] }"#
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(ConformanceProfile.self, from: Data(text.utf8))
        }
    }

    @Test func servedRowsReadFromAResponseOrABareArray() throws {
        let rows = #"[ { "provider": "desktop", "reason": null } ]"#
        let wrapped = #"{ "data": { "koineManagement": { "providers": \#(rows) } } }"#
        let fromWrapped = try ConformanceProfile.servedRows(fromJSON: Data(wrapped.utf8))
        let fromBare = try ConformanceProfile.servedRows(fromJSON: Data(rows.utf8))
        #expect(fromWrapped == fromBare && fromBare.count == 1)
        // A null is kept, distinct from an absent key.
        #expect(fromBare[0]["reason"] != nil && (fromBare[0]["reason"] ?? "x") == nil)
        #expect(fromBare[0]["origin"] == nil)
    }
}
