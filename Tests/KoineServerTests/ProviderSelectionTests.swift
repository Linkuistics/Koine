import Foundation
import KoineCore
import KoineProviderAPI
import Testing

@testable import KoineProviderLoader

/// The first-party selection decisions, at the native loader (docs/specs/machine.md,
/// "First-party provider selection"): real sealed bundles, staged, verified and
/// selected by the real loader, around the loader's private seam. The seam
/// records which frozen selections would load instead of loading them, so no
/// principal class of these bundles is ever registered in the test process and
/// what a decision refuses is observed by its report, not inferred.
///
/// The whole matrix, with fresh host processes, initializer markers and
/// purpose-built signed hosts, is `selection-acceptance`'s. This suite is the
/// principal decisions, held while the loader is written. `task test` builds the
/// bundles (Fixtures/FixtureProvider/build-selection.sh).
@Suite struct ProviderSelectionTests {
    // MARK: Material

    static func fixture(_ name: String) throws -> URL {
        let root = try NativeProviderTests.fixtureRoot().deletingLastPathComponent()
            .appendingPathComponent("FixtureSelection", isDirectory: true)
        let directory = root.appendingPathComponent(name, isDirectory: true)
        try #require(
            FileManager.default.fileExists(atPath: directory.path),
            "No selection fixture at \(directory.path). Run `task test`, which builds it."
        )
        return try #require(
            FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .first { $0.pathExtension == ProviderLoader.bundleExtension }
        )
    }

    static let releaseIdentifier = "dev.antony.Koine.provider.fixturesl"

    /// The slot the decision cases contest: `fixturesl`, baseline release 1.0.0,
    /// schema 1.1.0. `fixtureqz` is a second shipped slot, and `fixtureinput`
    /// stays reserved-only.
    static func catalogue(
        slot: String = releaseIdentifier, qz: Bool = false, extra: [ProviderCatalogue.Entry] = []
    ) throws -> ProviderCatalogue {
        func enabled(_ id: String, _ prefix: String, _ schema: String, _ signer: String)
            -> ProviderCatalogue.Entry
        {
            ProviderCatalogue.Entry(
                providerId: id, graphQLPrefix: prefix,
                baseline: ProviderCatalogue.Baseline(
                    bundleName: "\(prefix).koineprovider", release: ProviderVersion("1.0.0")!,
                    schema: ProviderVersion(schema)!, signingIdentifier: signer
                )
            )
        }
        var entries = [
            enabled("fixturesl", "FixtureSl", "1.1.0", slot),
            ProviderCatalogue.Entry(providerId: "fixtureinput", graphQLPrefix: "FixtureInput"),
        ]
        if qz { entries.append(enabled("fixtureqz", "FixtureQz", "1.0.0", "dev.antony.Koine.provider.fixtureqz")) }
        return try ProviderCatalogue(entries: entries + extra)
    }

    /// The team the fixtures are signed with: what a signed host would derive.
    static func team() throws -> String { try ProviderLoaderTests.fixtureApproval().teamIdentifier }

    /// One installation: an in-application root and a per-user root, each in a
    /// directory of its own, holding copies of the sealed fixtures.
    final class Installation {
        let directory: URL
        let bundledRoot: URL
        let userRoot: URL

        init() throws {
            directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("koine-selection-\(UUID().uuidString)", isDirectory: true)
            bundledRoot = directory.appendingPathComponent("PlugIns", isDirectory: true)
            userRoot = directory.appendingPathComponent("Providers", isDirectory: true)
            for root in [bundledRoot, userRoot] {
                try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            }
        }

        deinit { try? FileManager.default.removeItem(at: directory) }

        /// The designated bundle, `<Prefix>.koineprovider`, in the sealed root.
        @discardableResult
        func bundle(_ name: String = "baseline", as designated: String = "FixtureSl") throws -> URL {
            let destination = bundledRoot.appendingPathComponent("\(designated).koineprovider")
            try FileManager.default.copyItem(at: try fixture(name), to: destination)
            return destination
        }

        /// A per-user copy, with the approval record its provider needs, unless
        /// `approved` is false or the record is already there.
        @discardableResult
        func install(
            _ name: String, as installed: String, providerId: String = "fixturesl",
            approved: Bool = true, team: String? = nil
        ) throws -> URL {
            let destination = userRoot.appendingPathComponent("\(installed).koineprovider")
            try FileManager.default.copyItem(at: try fixture(name), to: destination)
            if approved {
                let record = userRoot.appendingPathComponent(ProviderRoot.approvalRecordName(for: providerId))
                let team = try team ?? ProviderSelectionTests.team()
                try Data(#"{ "providerId": "\#(providerId)", "teamIdentifier": "\#(team)" }"#.utf8)
                    .write(to: record)
            }
            return destination
        }

        func alias(_ name: String, to target: String) throws {
            try FileManager.default.createSymbolicLink(
                atPath: userRoot.appendingPathComponent("\(name).koineprovider").path,
                withDestinationPath: "\(target).koineprovider"
            )
        }

        var staging: URL { directory.appendingPathComponent("ProviderStaging", isDirectory: true) }
    }

    /// What a run of the loader over an installation did.
    struct Run {
        let reports: [ProviderCandidateReport]
        let attempts: [ProviderLoader.LoadAttempt]
        let assessed: [String]

        /// The report of the candidate installed at `<name>.koineprovider`.
        func row(
            _ name: String, origin: ProviderCandidateReport.Origin = .perUser
        ) throws -> ProviderCandidateReport {
            try #require(
                reports.first {
                    $0.origin == origin
                        && ($0.location.map { ($0 as NSString).lastPathComponent }) == "\(name).koineprovider"
                }, "No report for \(name) in \(reports.map { $0.location ?? "synthetic \($0.provider)" })"
            )
        }

        func synthetic(_ provider: String) -> ProviderCandidateReport? {
            reports.first { $0.candidateId == nil && $0.provider == provider }
        }

        /// The candidates the loader would load, by the bundle name they sit in.
        var loadedNames: [String] {
            attempts.map { attempt in
                reports.first { $0.candidateId == attempt.candidateId }
                    .flatMap { $0.location.map { ($0 as NSString).lastPathComponent } } ?? "?"
            }
        }
    }

    final class Recorder: @unchecked Sendable {
        private let lock = NSLock()
        private var attempted: [ProviderLoader.LoadAttempt] = []
        private var seen: [String] = []
        /// Versions whose load fails, as a dynamic-loader refusal would.
        let failing: Set<String>
        /// Paths, and whether a quarantined image there is refused.
        let refusing: @Sendable (String) -> String?

        init(failing: Set<String> = [], refusing: @escaping @Sendable (String) -> String? = { _ in nil }) {
            self.failing = failing
            self.refusing = refusing
        }

        var attempts: [ProviderLoader.LoadAttempt] { lock.withLock { attempted } }
        var assessed: [String] { lock.withLock { seen } }

        func load(_ attempt: ProviderLoader.LoadAttempt) throws -> LoadedProvider {
            lock.withLock { attempted.append(attempt) }
            if failing.contains(attempt.version) {
                throw ProviderLoader.loadRefusal("built to fail its load")
            }
            return LoadedProvider(
                descriptor: ProviderDescriptor(
                    providerId: attempt.providerId, graphQLPrefix: "Stub", schemaSDL: "", fields: []
                ),
                provider: StubProvider { _ in .success(.null) }
            )
        }

        func assess(_ path: String) -> String? {
            lock.withLock { seen.append(path) }
            return refusing(path)
        }
    }

    /// Verifying a signature blocks on work Security dispatches to the global
    /// queues, so it runs off the cooperative pool and one at a time, as
    /// `Harness` constructs servers: a pool whose every thread is a test blocked
    /// there starves it.
    static func run(
        _ installation: Installation, catalogue: Result<ProviderCatalogue, ProviderCatalogue.Invalid>,
        hostTeam: String?? = .none, reversed: Bool = false, recorder: Recorder = Recorder()
    ) async throws -> Run {
        var seam = ProviderLoader.Seam()
        let team = try hostTeam ?? Self.team()
        seam.hostTeam = { team }
        if reversed { seam.discoveryOrder = { $0.reversed() } }
        seam.load = { try recorder.load($0) }
        seam.assessment = { recorder.assess($0) }
        let roots: [ProviderRoot] = [.bundled(installation.bundledRoot), .installed(installation.userRoot)]
        let staging = installation.staging
        let host = HostCompatibility(features: koineHostFeatures)
        let sealed = seam
        let result = try await withCheckedThrowingContinuation { continuation in
            Harness.constructing.async {
                continuation.resume(
                    with: Result {
                        try ProviderLoader.selectAndLoad(
                            roots: roots, catalogue: catalogue, staging: staging, host: host,
                            seam: sealed
                        )
                    }
                )
            }
        }
        return Run(reports: result.reports, attempts: recorder.attempts, assessed: recorder.assessed)
    }

    static func selected(_ report: ProviderCandidateReport) -> Bool {
        report.selection == .selected && { if case .loaded = report.outcome { true } else { false } }()
    }

    static func state(_ report: ProviderCandidateReport) -> String {
        switch report.outcome {
        case .loaded: "ACTIVE"
        case .incompatible: "INCOMPATIBLE"
        case .rejected: "REJECTED"
        }
    }

    static func message(_ report: ProviderCandidateReport) -> String {
        switch report.outcome {
        case .loaded: report.note ?? ""
        case .incompatible(let text), .rejected(let text): text
        }
    }

    // MARK: Numeric precedence

    /// Release 1.10.0 exceeds 1.9.0: compared as text, 1.9.0 would win. The
    /// outcome is the same whichever order the copies were discovered in.
    @Test(arguments: [false, true])
    func theNumericallyGreatestReleaseWins(reversed: Bool) async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r1.9.0", as: "older")
        try installation.install("r1.10.0", as: "newer")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()), reversed: reversed)

        let winner = try run.row("newer")
        #expect(Self.selected(winner) && winner.reason == nil && winner.note == nil)
        #expect(run.attempts.map(\.version) == ["1.10.0"])
        #expect(run.loadedNames == ["newer.koineprovider"])
        for passedOver in [try run.row("older"), try run.row("FixtureSl", origin: .bundled)] {
            #expect(passedOver.selection == .notSelected)
            #expect(passedOver.reason == ProviderReason.supersededCandidate)
            #expect(Self.state(passedOver) == "REJECTED")
        }
        for report in run.reports.filter({ $0.provider == "fixturesl" }) {
            #expect(report.selectedCandidateId == winner.candidateId)
        }
        #expect(run.reports.filter { $0.candidateId == nil }.isEmpty)
        // The winner is a shipped selection whichever root it came from.
        #expect(winner.isShipped && winner.origin == .perUser)
    }

    // MARK: Ties

    @Test(arguments: [false, true])
    func aTiedGreatestReleaseIsRefusedAndALowerUpdateIsChosen(reversed: Bool) async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "first")
        try installation.install("r2.0.0", as: "second")
        try installation.install("r1.5.0", as: "lower")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()), reversed: reversed)

        for tied in [try run.row("first"), try run.row("second")] {
            #expect(tied.selection == .notSelected && tied.reason == ProviderReason.ambiguousUpdate)
            #expect(Self.state(tied) == "REJECTED")
        }
        let lower = try run.row("lower")
        #expect(Self.selected(lower))
        // Visible: the choice is marked, and its diagnostic names what was refused.
        #expect(lower.reason == ProviderReason.selectedWithRefusals)
        #expect(lower.note?.contains("claims release 2.0.0") == true)
        #expect(lower.note?.contains(ProviderReason.ambiguousUpdate) == true)
        #expect(try run.row("FixtureSl", origin: .bundled).reason == ProviderReason.supersededCandidate)
        // The tied copies never loaded, and nothing else did.
        #expect(run.loadedNames == ["lower.koineprovider"])
    }

    @Test func aTieFallsBackToTheBundledCopy() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "first")
        try installation.install("r2.0.0", as: "second")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        let bundle = try run.row("FixtureSl", origin: .bundled)
        #expect(Self.selected(bundle) && bundle.reason == ProviderReason.selectedWithRefusals)
        #expect(bundle.note?.contains("installed more than once") == true)
        #expect(run.loadedNames == ["FixtureSl.koineprovider"])
    }

    /// Two tied groups: the greatest is refused, then the next greatest, and the
    /// calculation repeats until a unique release, or the bundle, is left. Nothing
    /// is chosen by path: the winner's directory name sorts before every loser's.
    @Test func successiveTiedGroupsAreRefusedInTurn() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r3.0.0", as: "aaa-three-a")
        try installation.install("r3.0.0", as: "aaa-three-b")
        try installation.install("r2.0.0", as: "aaa-two-a")
        try installation.install("r2.0.0", as: "aaa-two-b")
        try installation.install("r1.5.0", as: "zzz-unique")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        for name in ["aaa-three-a", "aaa-three-b", "aaa-two-a", "aaa-two-b"] {
            #expect(try run.row(name).reason == ProviderReason.ambiguousUpdate)
        }
        #expect(run.loadedNames == ["zzz-unique.koineprovider"])
    }

    /// A duplicate of a lower release does not contest a unique higher one.
    @Test func lowerDuplicatesDoNotContestAUniqueHigherWinner() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "winner")
        try installation.install("r1.5.0", as: "lower-a")
        try installation.install("r1.5.0", as: "lower-b")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(run.loadedNames == ["winner.koineprovider"])
        #expect(try run.row("lower-a").reason == ProviderReason.supersededCandidate)
        #expect(try run.row("winner").reason == nil)
    }

    /// Aliases of one canonical bundle are one candidate: had the alias counted
    /// as a second copy of 2.0.0, the release would be a tie and be refused.
    @Test func aCanonicalDirectoryAliasCountsOnce() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "real")
        try installation.alias("alias", to: "real")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(run.reports.filter { $0.origin == .perUser }.count == 1)
        #expect(run.loadedNames == ["real.koineprovider"])
    }

    // MARK: Equal and older copies

    @Test func equalAndOlderCopiesNeverOverrideTheBundle() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r1.0.0", as: "equal")
        try installation.install("r0.9.0", as: "older")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(try run.row("equal").reason == ProviderReason.equalToBundled)
        #expect(try run.row("older").reason == ProviderReason.olderThanBundled)
        let bundle = try run.row("FixtureSl", origin: .bundled)
        #expect(Self.selected(bundle) && bundle.reason == ProviderReason.selectedWithRefusals)
        #expect(run.loadedNames == ["FixtureSl.koineprovider"])
    }

    /// Even when the bundle is missing, an equal or older copy fills nothing: the
    /// slot is unavailable, and says the bundle is missing.
    @Test func equalAndOlderCopiesNeverFillAMissingBundle() async throws {
        let installation = try Installation()
        try installation.install("r1.0.0", as: "equal")
        try installation.install("r0.9.0", as: "older")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(run.attempts.isEmpty)
        let missing = try #require(run.synthetic("fixturesl"))
        #expect(missing.reason == ProviderReason.missingBundled)
        #expect(missing.selection == .unavailable && missing.selectedCandidateId == nil)
        #expect(missing.candidateId == nil && missing.origin == nil)
        #expect(Self.message(missing).contains("FixtureSl.koineprovider"))
        #expect(try run.row("equal").selection == .notSelected)
    }

    /// A valid newer update fills the slot of a missing bundle, and the missing
    /// bundle stays visible as its own synthetic row.
    @Test func aNewerUpdateFillsAMissingBundleWhichStaysVisible() async throws {
        let installation = try Installation()
        try installation.install("r1.5.0", as: "update")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        let update = try run.row("update")
        #expect(Self.selected(update) && update.reason == ProviderReason.selectedWithRefusals)
        let missing = try #require(run.synthetic("fixturesl"))
        #expect(missing.reason == ProviderReason.missingBundled)
        #expect(missing.selectedCandidateId == update.candidateId)
        #expect(run.loadedNames == ["update.koineprovider"])
    }

    // MARK: Refused updates

    @Test func aMissingSelectionFeatureIsRefusedOnAnExtensionHost() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0-no-feature", as: "unmarked")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        let refused = try run.row("unmarked")
        #expect(refused.reason == ProviderReason.selectionFeatureRequired)
        #expect(Self.state(refused) == "INCOMPATIBLE" && refused.selection == .notSelected)
        // The designated baseline is an independently compiled older provider,
        // and declares no such feature: it is not refused for it.
        let bundle = try run.row("FixtureSl", origin: .bundled)
        #expect(Self.selected(bundle) && bundle.reason == ProviderReason.selectedWithRefusals)
        #expect(bundle.note?.contains("first-party-selection-v1") == true)
        #expect(run.loadedNames == ["FixtureSl.koineprovider"])
    }

    /// An approved same-team bundle claiming the reserved pair at a high release
    /// under another signing identifier is refused before it loads, and the valid
    /// baseline stays selected. A test catalogue that lists that identifier admits
    /// it, and the same bundle then wins: only the catalogue decides.
    @Test func aBundleSignedUnderAnotherIdentifierIsRefusedUnlessACatalogueAdmitsIt() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r9.0.0-other-identifier", as: "impostor")

        let production = try await Self.run(installation, catalogue: .success(try Self.catalogue()))
        let refused = try production.row("impostor")
        #expect(refused.reason == ProviderReason.signingIdentifierMismatch)
        #expect(Self.state(refused) == "REJECTED")
        #expect(Self.message(refused).contains("dev.antony.Koine.provider.fixturesl.impostor"))
        #expect(Self.message(refused).contains(Self.releaseIdentifier))
        #expect(production.loadedNames == ["FixtureSl.koineprovider"])

        // The bundled baseline is signed under the production identifier, so a
        // catalogue that admits the impostor's identifier refuses the baseline
        // instead: the identifier is the catalogue's, and nothing else's.
        let purposeBuilt = try await Self.run(
            installation,
            catalogue: .success(
                try Self.catalogue(slot: "dev.antony.Koine.provider.fixturesl.impostor")
            )
        )
        #expect(Self.selected(try purposeBuilt.row("impostor")))
        #expect(try purposeBuilt.row("FixtureSl", origin: .bundled).reason == ProviderReason.signingIdentifierMismatch)
    }

    @Test(arguments: [
        ("r1.9.0-schema2", ProviderReason.schemaIncompatible, "INCOMPATIBLE"),
        ("r1.9.0-schema-regressed", ProviderReason.schemaIncompatible, "INCOMPATIBLE"),
        ("r2.0-malformed", ProviderReason.invalidVersion, "REJECTED"),
        ("r01.0.0-leading-zero", ProviderReason.invalidVersion, "REJECTED"),
    ])
    func aVersionOrSchemaTheSlotCannotTakeIsRefusedWithItsClass(
        fixture: String, reason: String, state: String
    ) async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install(fixture, as: "update")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        let refused = try run.row("update")
        #expect(refused.reason == reason && Self.state(refused) == state)
        #expect(run.loadedNames == ["FixtureSl.koineprovider"])
    }

    // MARK: Reserved names

    /// A claimant of a reserved name that is not the exact pair is refused alone,
    /// before it loads; it never evicts the owner, and it is refused whether the
    /// owner is present or absent.
    @Test(arguments: [
        "claims-other-prefix", "claims-other-identifier", "claims-overlapping-prefix",
        "claims-shorter-prefix",
    ])
    func aReservedClaimantIsRefusedAloneAndNeverEvictsItsOwner(fixture: String) async throws {
        for ownerPresent in [true, false] {
            let installation = try Installation()
            if ownerPresent { try installation.bundle() }
            let provider = fixture == "claims-other-identifier" ? "fixtureother" : "fixturesl"
            try installation.install(fixture, as: "claimant", providerId: provider)
            // A different identifier claiming an ordinary prefix, or the reverse,
            // needs its own approval to be judged at all; the reserved names decide first.
            let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

            let claimant = try run.row("claimant")
            #expect(claimant.reason == ProviderReason.reservedIdentity, "\(fixture) owner \(ownerPresent)")
            #expect(claimant.selection == .notSelected && Self.state(claimant) == "REJECTED")
            if ownerPresent {
                #expect(Self.selected(try run.row("FixtureSl", origin: .bundled)))
                #expect(run.loadedNames == ["FixtureSl.koineprovider"])
            } else {
                #expect(run.attempts.isEmpty)
                #expect(run.synthetic("fixturesl")?.reason == ProviderReason.missingBundled)
            }
        }
    }

    /// The exact pair of an identity that is reserved and not yet shipped can
    /// load from neither root, and enables nothing.
    @Test func aReservedOnlyIdentityCannotLoadFromEitherRoot() async throws {
        let installation = try Installation()
        try installation.install("claims-reserved-only", as: "early", providerId: "fixtureinput")
        try FileManager.default.copyItem(
            at: try Self.fixture("claims-reserved-only"),
            to: installation.bundledRoot.appendingPathComponent("FixtureInput.koineprovider")
        )

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(try run.row("early").reason == ProviderReason.reservedOnly)
        // In the sealed root it is an unexpected bundle: nothing designates it.
        #expect(
            try run.row("FixtureInput", origin: .bundled).reason
                == ProviderReason.unexpectedBundledCandidate
        )
        #expect(run.attempts.isEmpty)
        #expect(run.reports.allSatisfy { $0.selection != .selected })
    }

    // MARK: A frozen choice

    /// Once the choice is frozen, a failure loads nothing else: not the lower
    /// update, not the bundle. The choice stays identifiable.
    @Test func noAlternativeIsRetriedAfterAFrozenFailure() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "frozen")
        try installation.install("r1.5.0", as: "lower")

        let run = try await Self.run(
            installation, catalogue: .success(try Self.catalogue()),
            recorder: Recorder(failing: ["2.0.0"])
        )

        #expect(run.loadedNames == ["frozen.koineprovider"])
        let frozen = try run.row("frozen")
        #expect(frozen.selection == .selected && Self.state(frozen) == "REJECTED")
        #expect(frozen.selectedCandidateId == frozen.candidateId)
        #expect(frozen.reason == ProviderReason.loadFailed)
        #expect(Self.message(frozen).contains("built to fail its load"))
        for alternative in [try run.row("lower"), try run.row("FixtureSl", origin: .bundled)] {
            #expect(alternative.selection == .notSelected)
            #expect(alternative.reason == ProviderReason.supersededCandidate)
            #expect(alternative.selectedCandidateId == frozen.candidateId)
        }
        #expect(run.publicationOrder.isEmpty)
    }

    /// A designated bundle that fails before its manifest can be read is still the
    /// slot's refused candidate: a valid update filling the slot is chosen
    /// with that refusal visible, not as if nothing had gone wrong.
    @Test func aRefusedDesignatedBundleIsAttributedToItsSlot() async throws {
        let installation = try Installation()
        let broken = installation.bundledRoot.appendingPathComponent("FixtureSl.koineprovider")
        try FileManager.default.createDirectory(at: broken, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: broken.appendingPathComponent("manifest.json"))
        try installation.install("r2.0.0", as: "update")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        let bundle = try run.row("FixtureSl", origin: .bundled)
        #expect(bundle.reason == ProviderReason.manifestInvalid && bundle.selection == .notSelected)
        let update = try run.row("update")
        #expect(Self.selected(update) && update.reason == ProviderReason.selectedWithRefusals)
        #expect(update.note?.contains(ProviderReason.manifestInvalid) == true)
        // Present but refused: not reported as missing.
        #expect(run.synthetic("fixturesl") == nil)
    }

    /// A frozen choice that later fails keeps the refusals that led to it in its
    /// report, beside its own failure.
    @Test func aFrozenChoiceThatFailsKeepsTheEarlierRefusals() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "first")
        try installation.install("r2.0.0", as: "second")
        try installation.install("r1.5.0", as: "lower")

        let run = try await Self.run(
            installation, catalogue: .success(try Self.catalogue()),
            recorder: Recorder(failing: ["1.5.0"])
        )

        let frozen = try run.row("lower")
        #expect(frozen.selection == .selected && Self.state(frozen) == "REJECTED")
        #expect(frozen.reason == ProviderReason.loadFailed)
        #expect(frozen.note?.contains(ProviderReason.ambiguousUpdate) == true)
    }

    // MARK: Trust and the host

    @Test func anUnsignedHostAdmitsNoShippedCandidateButStillLoadsOrdinaryProviders() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "update")
        try installation.install("ordinary-a", as: "ordinary", providerId: "fixtureord")

        let run = try await Self.run(
            installation, catalogue: .success(try Self.catalogue()), hostTeam: .some(nil)
        )

        for shipped in [try run.row("update"), try run.row("FixtureSl", origin: .bundled)] {
            #expect(shipped.reason == ProviderReason.hostTeamUnavailable)
            #expect(shipped.selection == .notSelected && Self.state(shipped) == "REJECTED")
        }
        // Reservations and core management remain: the slot is unavailable, not free.
        #expect(run.synthetic("fixturesl")?.reason == ProviderReason.noEligibleCandidate)
        #expect(run.loadedNames == ["ordinary.koineprovider"])
        #expect(Self.selected(try run.row("ordinary")))
    }

    /// A per-user first-party update needs its approval record to name the host's
    /// own Team ID, on top of the signature.
    @Test func aPerUserUpdateIsApprovedForTheHostsTeamAlone() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "update", team: "ZZZZZZZZZZ")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(try run.row("update").reason == ProviderReason.approvalTeamMismatch)
        #expect(run.loadedNames == ["FixtureSl.koineprovider"])
    }

    @Test func aPerUserUpdateWithoutAnApprovalRecordIsRefused() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "update", approved: false)

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(try run.row("update").reason == ProviderReason.notApproved)
        #expect(run.loadedNames == ["FixtureSl.koineprovider"])
    }

    // MARK: The catalogue

    @Test func aMalformedCatalogueAdmitsNoProvider() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("r2.0.0", as: "update")
        try installation.install("ordinary-a", as: "ordinary", providerId: "fixtureord")

        let run = try await Self.run(
            installation, catalogue: .failure(ProviderCatalogue.Invalid(reason: "It is broken."))
        )

        let only = try #require(run.reports.first)
        #expect(run.reports.count == 1)
        #expect(only.provider == "(unknown)" && only.version == "unknown" && only.schemaVersion == "unknown")
        #expect(only.reason == ProviderReason.catalogueInvalid)
        #expect(only.selection == .unavailable && Self.state(only) == "REJECTED")
        #expect(only.candidateId == nil && only.origin == nil && only.selectedCandidateId == nil)
        #expect(Self.message(only).contains("It is broken."))
        #expect(run.attempts.isEmpty)
        // Nothing was staged: no candidate was invented from the bundles found.
        #expect(!FileManager.default.fileExists(atPath: installation.staging.path))
    }

    // MARK: Principal names

    /// A shipped update and another shipped identity's bundle are equal owners of
    /// the name they both claim: both are refused, whichever root each came from,
    /// and nothing loads. Both stay the frozen choice of their own identity.
    @Test func aShippedUpdateAndAnotherShippedBundleRefuseEachOther() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.bundle("qz-baseline", as: "FixtureQz")
        try installation.install("r2.0.0-qz-principal", as: "update")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue(qz: true)))

        for refused in [try run.row("update"), try run.row("FixtureQz", origin: .bundled)] {
            #expect(refused.selection == .selected && Self.state(refused) == "REJECTED")
            #expect(refused.reason == ProviderReason.principalCollision)
            #expect(refused.selectedCandidateId == refused.candidateId)
        }
        // Frozen: the bundled baseline of fixturesl is not retried in the update's place.
        #expect(try run.row("FixtureSl", origin: .bundled).reason == ProviderReason.supersededCandidate)
        #expect(run.attempts.isEmpty)
    }

    /// An ordinary provider that claims a shipped selection's principal name is
    /// refused alone; the shipped owner is unaffected.
    @Test func anOrdinaryProviderContestingAShippedPrincipalIsRefusedAlone() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.install("ordinary-on-shipped-principal", as: "ordinary", providerId: "fixtureord")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        let ordinary = try run.row("ordinary")
        #expect(ordinary.selection == .selected && Self.state(ordinary) == "REJECTED")
        #expect(ordinary.reason == ProviderReason.principalCollision)
        #expect(run.loadedNames == ["FixtureSl.koineprovider"])
    }

    // MARK: Ordinary providers

    @Test func ordinaryDuplicatesRefuseEachOtherBeforeLoading() async throws {
        let installation = try Installation()
        try installation.install("ordinary-a", as: "first", providerId: "fixtureord")
        try installation.install("ordinary-b", as: "second", providerId: "fixtureord")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        for duplicate in [try run.row("first"), try run.row("second")] {
            #expect(duplicate.reason == ProviderReason.manifestCollision)
            #expect(duplicate.selection == .notSelected && duplicate.selectedCandidateId == nil)
        }
        #expect(run.attempts.isEmpty)
    }

    /// A rival that fails a pre-load check does not contest a valid provider: it
    /// cannot evict it by claiming its identifier.
    @Test func aRefusedRivalCannotEvictAValidProvider() async throws {
        let installation = try Installation()
        try installation.install("ordinary-a", as: "valid", providerId: "fixtureord")
        let rival = try installation.install("ordinary-b", as: "tampered", providerId: "fixtureord")
        // Changed after it was sealed.
        let manifest = rival.appendingPathComponent("manifest.json")
        var text = try String(contentsOf: manifest, encoding: .utf8)
        text = text.replacingOccurrences(of: "\"variant\"", with: "\"changed\"")
        try text.write(to: manifest, atomically: true, encoding: .utf8)

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue()))

        #expect(try run.row("tampered").reason == ProviderReason.signatureRefused)
        let valid = try run.row("valid")
        #expect(Self.selected(valid) && valid.reason == nil)
        #expect(valid.selectedCandidateId == valid.candidateId)
        #expect(run.loadedNames == ["valid.koineprovider"])
    }

    // MARK: Publication order

    /// The core follows shipped identities sorted by identifier, then ordinary
    /// per-user identities. The catalogue's listing order decides nothing.
    @Test func selectionsPublishInCanonicalOrder() async throws {
        let installation = try Installation()
        try installation.bundle()
        try installation.bundle("qz-baseline", as: "FixtureQz")
        try installation.install("ordinary-a", as: "ordinary", providerId: "fixtureord")

        let run = try await Self.run(installation, catalogue: .success(try Self.catalogue(qz: true)))

        #expect(run.publicationOrder == ["fixtureqz", "fixturesl", "fixtureord"])
    }

    // MARK: End to end

    /// One real load, through the whole path: an independently compiled baseline
    /// in the sealed root, an independently compiled newer update in the per-user
    /// root, the real loader and dlopen, the core's composition and a client over
    /// loopback HTTP. The update's binary answers, its initializer ran, and the
    /// bundle's never did. `Sm` is loaded in no other test.
    @Test func aSelectedUpdateIsTheOnlyImageThatRunsAndItsOperationsWork() async throws {
        let installation = try Installation()
        let baseline = installation.bundledRoot.appendingPathComponent("FixtureSm.koineprovider")
        try FileManager.default.copyItem(at: try Self.fixture("sm-baseline"), to: baseline)
        let update = try installation.install("sm-update", as: "update", providerId: "fixturesm")
        let catalogue = try ProviderCatalogue(entries: [
            ProviderCatalogue.Entry(
                providerId: "fixturesm", graphQLPrefix: "FixtureSm",
                baseline: ProviderCatalogue.Baseline(
                    bundleName: "FixtureSm.koineprovider", release: ProviderVersion("1.0.0")!,
                    schema: ProviderVersion("1.0.0")!,
                    signingIdentifier: "dev.antony.Koine.provider.fixturesm"
                )
            )
        ])
        _ = ProviderLoaderTests.initializerLog

        let harness = try await Harness(
            providerRoots: [installation.userRoot], bundledRoots: [.bundled(installation.bundledRoot)],
            catalogue: .success(catalogue), hostTeam: try Self.team()
        )

        let statuses = try await ProviderLoaderTests.statuses(harness)
        #expect(statuses.count == 2)
        let running = try #require(statuses.first { $0.state == "ACTIVE" })
        #expect(running.provider == "fixturesm" && running.version == "1.1.0")
        // The refused bundle is visible beside the running version.
        let passedOver = try #require(statuses.first { $0.state == "REJECTED" })
        #expect(passedOver.provider == "fixturesm" && passedOver.version == "1.0.0")
        #expect(passedOver.diagnostic?.contains("Superseded") == true)

        // The candidate fields every phase reads from the one report.
        let rows = await harness.server.providerStatuses
        let selected = try #require(rows.first { $0.state == .active })
        #expect(selected.origin == .perUser && selected.selection == .selected)
        #expect(selected.candidateId != nil && selected.selectedCandidateId == selected.candidateId)
        #expect(selected.reason == nil)
        let superseded = try #require(rows.first { $0.state == .rejected })
        #expect(superseded.origin == .bundled && superseded.selection == .notSelected)
        #expect(superseded.reason == ProviderReason.supersededCandidate)
        #expect(superseded.selectedCandidateId == selected.candidateId)

        let credential = try await harness.consoleGrant(label: "reader", capabilities: ["fixturesm:read"])
        let reply = try await harness.post("{ fixtureSmInfo { greeting } }", authorization: "Bearer \(credential)")
        #expect(reply.errors.isEmpty)
        #expect(
            (reply.data?["fixtureSmInfo"] as? [String: Any])?["greeting"] as? String
                == "hello from the fixturesm provider, revision 2"
        )

        let log = (try? String(contentsOf: ProviderLoaderTests.initializerLog, encoding: .utf8)) ?? ""
        let ran = { (name: String) in log.split(separator: "\n").contains { $0.contains("/\(name)/") } }
        #expect(ran(try ProviderLoaderTests.stagedName(of: update, origin: .perUser)))
        #expect(!ran(try ProviderLoaderTests.stagedName(of: baseline, origin: .bundled)))
        await harness.stop()
    }

    /// A malformed catalogue is a packaging failure: management alone is served,
    /// with one catalogue diagnostic, and no provider is admitted from either root.
    @Test func aMalformedCatalogueServesCoreManagementAlone() async throws {
        let harness = try await Harness(
            providerRoots: [try NativeProviderTests.fixtureRoot()],
            catalogue: .failure(ProviderCatalogue.Invalid(reason: "Two identities overlap."))
        )

        let statuses = try await ProviderLoaderTests.statuses(harness)
        #expect(statuses.count == 1)
        let only = try #require(statuses.first)
        #expect(only.provider == "(unknown)" && only.state == "REJECTED")
        #expect(only.diagnostic?.contains("Two identities overlap.") == true)
        #expect(try await ProviderLoaderTests.rootFields(harness) == ProviderLoaderTests.coreRootFields)
        let rows = await harness.server.providerStatuses
        #expect(rows.first?.reason == ProviderReason.catalogueInvalid)
        #expect(rows.first?.selection == .unavailable && rows.first?.candidateId == nil)
        await harness.stop()
    }

    /// The Team ID a shipped candidate is approved for is the running host's own,
    /// read from its verified signature. This test host is not signed by a team,
    /// so with nothing substituted no shipped candidate is admitted, while
    /// reservations remain.
    @Test func aHostWithNoVerifiedTeamAdmitsNoShippedCandidate() async throws {
        try #require(ProviderApproval.hostTeamIdentifier == nil, "This test needs an unsigned host.")
        let harness = try await Harness(
            bundledRoots: [.bundled(try ProviderLoaderTests.variantRoot("bundled-designated"))],
            catalogue: .success(try ProviderLoaderTests.designatingBundledVariant()),
            loaderSeam: { $0.hostTeam = { ProviderApproval.hostTeamIdentifier } }
        )

        let status = try #require(try await ProviderLoaderTests.statuses(harness).first)
        #expect(status.state == "REJECTED")
        #expect(status.diagnostic?.contains("no Team ID and admits no shipped provider") == true)
        #expect(try await ProviderLoaderTests.rootFields(harness) == ProviderLoaderTests.coreRootFields)
        await harness.stop()
    }

    // MARK: Staging

    /// Equal bytes and equal names in both roots are two candidates with two staged
    /// copies. Discovery in either order stages the same two, and neither is the
    /// legacy content-named entry an earlier release left behind, which is never
    /// reused: it is planted here as a copy that would fail verification.
    @Test(arguments: [false, true])
    func stagedCopiesAreCandidateSpecific(reversed: Bool) async throws {
        let installation = try Installation()
        let bundled = try installation.bundle("r1.0.0")
        let perUser = try installation.install("r1.0.0", as: "FixtureSl")

        // The legacy name: the bundle's name and a digest of its content alone.
        let legacy = installation.staging.appendingPathComponent(
            "FixtureSl-" + (try ProviderStaging.digest(of: bundled))
        )
        try FileManager.default.createDirectory(at: legacy, withIntermediateDirectories: true)
        try Data("not a bundle".utf8).write(to: legacy.appendingPathComponent("manifest.json"))

        let run = try await Self.run(
            installation, catalogue: .success(try Self.catalogue()), reversed: reversed
        )

        let staged = try FileManager.default.contentsOfDirectory(atPath: installation.staging.path).sorted()
        let expected = [
            try ProviderLoaderTests.stagedName(of: bundled, origin: .bundled),
            try ProviderLoaderTests.stagedName(of: perUser, origin: .perUser),
        ]
        #expect(Set(expected).count == 2)
        #expect(Set(staged) == Set(expected).union([legacy.lastPathComponent]))
        // The equal per-user copy never replaces the bundle; the bundle's own copy loads.
        #expect(run.attempts.count == 1)
        let library = try #require(run.attempts.first?.library)
        #expect(library.contains("/\(expected[0])/"))
        #expect(!library.contains(legacy.lastPathComponent))
        #expect(try run.row("FixtureSl").reason == ProviderReason.equalToBundled)
    }

    /// A per-user copy is assessed of its own staged copy on every start; the
    /// bundled copy of identical bytes is not assessed, and does not inherit or
    /// suppress the per-user verdict. A verdict that changes between starts changes
    /// the outcome: nothing is cached.
    @Test func perUserQuarantineIsAssessedEveryStartAndNeverInherited() async throws {
        let installation = try Installation()
        let bundled = try installation.bundle("r1.0.0")
        let update = try installation.install("r2.0.0", as: "update")
        try Self.quarantine(update)
        let refuse: @Sendable (String) -> String? = { path in
            path.contains("/update-") ? "Gatekeeper refuses it (Unnotarized Developer ID)." : nil
        }

        let refused = try await Self.run(
            installation, catalogue: .success(try Self.catalogue()),
            recorder: Recorder(refusing: refuse)
        )

        #expect(try refused.row("update").reason == ProviderReason.quarantineRefused)
        #expect(refused.assessed.count == 1 && refused.assessed[0].contains("/update-"))
        #expect(!refused.assessed.contains { $0.contains("/FixtureSl-") })
        #expect(refused.loadedNames == ["FixtureSl.koineprovider"])
        #expect(try Self.stagedNames(installation).contains(try ProviderLoaderTests.stagedName(of: bundled, origin: .bundled)))

        // Restarted after Gatekeeper's verdict changed: the copy is assessed again.
        let accepted = try await Self.run(
            installation, catalogue: .success(try Self.catalogue()), recorder: Recorder()
        )
        #expect(accepted.assessed.count == 1)
        #expect(Self.selected(try accepted.row("update")))
        #expect(accepted.loadedNames == ["update.koineprovider"])
    }

    static func stagedNames(_ installation: Installation) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: installation.staging.path)
    }

    /// Marks every file of a bundle as a download arrives: the attribute the staged
    /// copy inherits.
    static func quarantine(_ bundle: URL) throws {
        let value = "0181;\(String(Int(Date().timeIntervalSince1970), radix: 16));Safari;\(UUID().uuidString)"
        let paths = try FileManager.default.subpathsOfDirectory(atPath: bundle.path)
            .map { bundle.appendingPathComponent($0).path } + [bundle.path]
        for path in paths {
            try #require(
                setxattr(path, Gatekeeper.quarantineAttribute, value, value.utf8.count, 0, XATTR_NOFOLLOW) == 0
            )
        }
    }
}

extension ProviderSelectionTests.Run {
    /// Provider identifiers of the selections that loaded, in the order they publish.
    var publicationOrder: [String] {
        ProviderSelectionResult(reports: reports).publication.map(\.provider)
    }
}
