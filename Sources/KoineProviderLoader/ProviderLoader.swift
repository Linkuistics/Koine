import Foundation
import KoineProviderAPI
import ObjectiveC

/// What the host supplies to providers: the version of the framework it
/// bundles, and its feature set. The framework ships inside Koine, so the host
/// states its version; a test holds it equal to ProviderAPI/Info.plist.
public struct HostCompatibility: Sendable {
    /// Version 1 supports exactly this framework major.
    public static let frameworkMajor = 1
    public static let frameworkMinor = 1

    public let frameworkMajor: Int
    public let frameworkMinor: Int
    public let features: Set<String>

    public init(features: Set<String>) {
        self.init(
            frameworkMajor: Self.frameworkMajor, frameworkMinor: Self.frameworkMinor,
            features: features
        )
    }

    init(frameworkMajor: Int, frameworkMinor: Int, features: Set<String>) {
        self.frameworkMajor = frameworkMajor
        self.frameworkMinor = frameworkMinor
        self.features = features
    }
}

public struct LoadedProvider: Sendable {
    public let descriptor: ProviderDescriptor
    public let provider: any Provider
}

/// The native loader. It considers every `*.koineprovider` bundle directly
/// inside a root the host was configured with; it searches nowhere else. One
/// invocation over every root and the sealed catalogue discovers, stages,
/// verifies and selects at most one candidate per identity, and only then loads
/// the frozen selections (docs/specs/machine.md, "Selection before execution").
/// Every check that can be made without running the bundle's code precedes
/// `dlopen`, and every one after the first is made of the staged copy that is
/// loaded.
public enum ProviderLoader {
    public static let bundleExtension = "koineprovider"

    /// The host feature every newly published first-party update declares in its
    /// manifest and descriptor. A selection-aware host supplies it; an earlier
    /// host lacks it and refuses the update before `dlopen`, even when the update
    /// renames its principal class.
    public static let firstPartySelectionFeature = "first-party-selection-v1"

    /// The framework minor that carries each host feature a manifest can require.
    static let featureMinimumMinors = ["additional-capabilities-v1": 1]

    static let frameworkName = "KoineProviderAPI"
    static let frameworkInstallName =
        "@rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI"
    /// The protocol descriptors of `Provider` and `ProviderFactory`. Only an
    /// image that is the framework defines them; an extension of a framework
    /// type, which a plugin may declare, does not.
    static let frameworkOwnSymbols: Set<String> = [
        "_$s16KoineProviderAPI0B0Mp", "_$s16KoineProviderAPI0B7FactoryMp",
    ]

    /// The one entry point: both roots, the sealed catalogue, and a report for
    /// every candidate. A root that does not exist holds no bundles; one that
    /// exists and cannot be read throws, so there is never a partial discovery
    /// presented as a complete candidate set. A malformed or conflicting
    /// catalogue is a packaging failure: nothing is discovered or loaded, and the
    /// one report says so. Bundles are staged under `staging` before they are
    /// verified or loaded.
    public static func selectAndLoad(
        roots: [ProviderRoot], catalogue: Result<ProviderCatalogue, ProviderCatalogue.Invalid>,
        staging: URL, host: HostCompatibility
    ) throws -> ProviderSelectionResult {
        try selectAndLoad(
            roots: roots, catalogue: catalogue, staging: staging, host: host, seam: Seam()
        )
    }

    /// What a test substitutes while the real verifier and loader run around it.
    /// It has package access: the host's own tests and the package's test hosts
    /// reach it; no client of the library can, and no public test API exists.
    package struct Seam {
        /// The verified Team ID of the running host. Unsigned test hosts have
        /// none; a test supplies one for the identities its bundles are signed with.
        package var hostTeam: @Sendable () -> String? = { ProviderApproval.hostTeamIdentifier }
        /// The order candidates are discovered in, within a root. The outcome
        /// never depends on it, and a test reverses it to show that.
        package var discoveryOrder: @Sendable ([URL]) -> [URL] = { $0 }
        /// Gatekeeper's verdict on a quarantined image: why it refuses, or nil.
        package var assessment: @Sendable (String) -> String? = { Gatekeeper.refusal(of: $0) }
        /// Runs in place of `dlopen` for a frozen selection when set, so a test
        /// can observe which candidates a host would load, or fail one.
        package var load: (@Sendable (LoadAttempt) throws -> LoadedProvider)?

        package init() {}
    }

    /// One frozen selection about to be loaded.
    package struct LoadAttempt: Sendable {
        package let candidateId: String
        package let providerId: String
        package let library: String
        package let version: String
    }

    /// A refusal a substitute `load` throws, to fail a frozen selection as the
    /// dynamic loader or the principal-class checks would.
    package static func loadRefusal(_ message: String) -> any Error {
        Refusal.rejected(ProviderReason.loadFailed, message)
    }

    /// One candidate's readiness to load: what the frozen selection needs.
    private struct Prepared {
        let manifest: ProviderManifest
        let library: String
    }

    package static func selectAndLoad(
        roots: [ProviderRoot], catalogue: Result<ProviderCatalogue, ProviderCatalogue.Invalid>,
        staging: URL, host: HostCompatibility, seam: Seam
    ) throws -> ProviderSelectionResult {
        let sealed: ProviderCatalogue
        switch catalogue {
        case .success(let valid): sealed = valid
        case .failure(let invalid):
            return ProviderSelectionResult(reports: [
                syntheticReport(
                    provider: ProviderCandidateReport.unidentified,
                    reason: ProviderReason.catalogueInvalid,
                    message: "The host's sealed provider catalogue is unusable, so no provider is admitted: \(invalid.reason) This is a packaging failure; reinstall Koine."
                )
            ])
        }

        // Discovery and every check that needs no provider code. Nothing loads.
        var discovered: [SelectionCandidate] = []
        var prepared: [String: Prepared] = [:]
        var seen: Set<String> = []
        let hostTeam = sealed.entries.contains { $0.baseline != nil } ? seam.hostTeam() : nil
        for root in roots {
            guard FileManager.default.fileExists(atPath: root.location.path) else { continue }
            let bundles = try FileManager.default
                .contentsOfDirectory(at: root.location, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == bundleExtension }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            for bundle in seam.discoveryOrder(bundles) {
                // Directory aliases resolving to one canonical bundle are one
                // candidate; distinct canonical directories remain distinct.
                let installed = canonicalPath(bundle.path) ?? bundle.standardizedFileURL.path
                let id = CandidateIdentity.id(origin: root.origin, installed: installed)
                guard seen.insert(id).inserted else { continue }
                let verified = verify(
                    bundle: bundle, installed: installed, id: id, in: root, catalogue: sealed,
                    hostTeam: hostTeam, staging: staging, host: host, seam: seam
                )
                discovered.append(verified.candidate)
                prepared[id] = verified.prepared
            }
        }

        // Select before anything loads: one frozen choice per identity.
        let plan = ProviderSelection.plan(catalogue: sealed, candidates: discovered)
        let byId = Dictionary(uniqueKeysWithValues: discovered.map { ($0.id, $0) })
        let selectedIds = discovered.map(\.id).filter {
            if case .selected? = plan.verdicts[$0] { true } else { false }
        }

        // The selected manifests' principal names are checked as a batch, before
        // any dlopen. A refusal here never reopens selection.
        let collisions = principalCollisions(
            selectedIds.compactMap { id in prepared[id].map { (byId[id]!, $0) } }
        )

        // Load the frozen selections in canonical composition order.
        var outcomes: [String: ProviderCandidateReport.Outcome] = [:]
        var reasons: [String: String] = [:]
        let loadOrder = selectedIds.sorted {
            let (left, right) = (byId[$0]!, byId[$1]!)
            return (left.role == .ordinary ? 1 : 0, left.claim?.providerId ?? "", left.id)
                < (right.role == .ordinary ? 1 : 0, right.claim?.providerId ?? "", right.id)
        }
        for id in loadOrder {
            if let collision = collisions[id] {
                outcomes[id] = .rejected(collision)
                reasons[id] = ProviderReason.principalCollision
                continue
            }
            guard let ready = prepared[id] else { continue }
            do {
                let attempt = LoadAttempt(
                    candidateId: id, providerId: ready.manifest.providerId,
                    library: ready.library, version: ready.manifest.version
                )
                let loaded = try seam.load?(attempt) ?? load(ready.library, manifest: ready.manifest)
                outcomes[id] = .loaded(loaded)
            } catch let refusal as Refusal {
                outcomes[id] = refusal.kind == .incompatible
                    ? .incompatible(refusal.message) : .rejected(refusal.message)
                reasons[id] = refusal.reason
            } catch {
                outcomes[id] = .rejected("The provider could not be loaded: \(error)")
                reasons[id] = ProviderReason.loadFailed
            }
        }

        // One report per candidate, immutable from here on.
        var reports: [ProviderCandidateReport] = []
        for candidate in discovered {
            let claim = candidate.claim
            let name = (candidate.installed as NSString).lastPathComponent
            let identified = claim.map { $0.providerId } ?? ProviderCandidateReport.unidentified
            func message(_ text: String) -> String {
                claim == nil ? "\(name): \(text)" : text
            }
            let outcome: ProviderCandidateReport.Outcome
            let selection: ProviderCandidateReport.Selection
            var reason: String?
            var note: String?
            switch plan.verdicts[candidate.id] {
            case .selected(let planned, let planNote)?:
                selection = .selected
                outcome = outcomes[candidate.id] ?? .rejected("The provider was not loaded.")
                reason = reasons[candidate.id] ?? planned
                note = planNote
            case .notSelected(let refusal)?:
                selection = .notSelected
                outcome = refusal.kind == .incompatible
                    ? .incompatible(message(refusal.message)) : .rejected(message(refusal.message))
                reason = refusal.reason
            case nil:
                selection = .notSelected
                outcome = .rejected(message("The candidate was not considered."))
                reason = ProviderReason.checkFailed
            }
            reports.append(
                ProviderCandidateReport(
                    candidateId: candidate.id, origin: candidate.origin, provider: identified,
                    version: claim?.version ?? "unknown",
                    schemaVersion: claim?.schemaVersion ?? "unknown", outcome: outcome,
                    selection: selection,
                    selectedCandidateId: claim.flatMap { plan.chosen[$0.providerId] },
                    reason: reason, note: note, isShipped: candidate.role != .ordinary,
                    location: candidate.installed
                )
            )
        }
        for row in plan.synthetics {
            reports.append(
                syntheticReport(
                    provider: row.providerId, reason: row.reason, message: row.message,
                    selectedCandidateId: row.selectedCandidateId
                )
            )
        }
        return ProviderSelectionResult(
            reports: reports.sorted {
                (
                    $0.provider, $0.candidateId == nil ? 1 : 0, $0.origin?.rawValue ?? "",
                    $0.candidateId ?? ""
                )
                    < (
                        $1.provider, $1.candidateId == nil ? 1 : 0, $1.origin?.rawValue ?? "",
                        $1.candidateId ?? ""
                    )
            }
        )
    }

    /// A row for an enabled slot no candidate fills, or for a catalogue that
    /// cannot be used. It has no candidate identity, origin or location.
    private static func syntheticReport(
        provider: String, reason: String, message: String, selectedCandidateId: String? = nil
    ) -> ProviderCandidateReport {
        ProviderCandidateReport(
            candidateId: nil, origin: nil, provider: provider, version: "unknown",
            schemaVersion: "unknown", outcome: .rejected(message), selection: .unavailable,
            selectedCandidateId: selectedCandidateId, reason: reason, note: nil, isShipped: false,
            location: nil
        )
    }

    // MARK: Discovery and verification

    /// Everything that can be checked of one candidate without running its code.
    /// Its refusal, if any, excludes this candidate alone.
    private static func verify(
        bundle: URL, installed: String, id: String, in root: ProviderRoot,
        catalogue: ProviderCatalogue, hostTeam: String?, staging: URL, host: HostCompatibility,
        seam: Seam
    ) -> (candidate: SelectionCandidate, prepared: Prepared?) {
        let bundleName = (installed as NSString).lastPathComponent
        // The bundle a catalogue designates is that slot's, however it fails: a
        // refusal before its manifest is read is still the slot's refusal.
        let designated: SlotRole =
            root.isBundled
            ? catalogue.entries.first { $0.baseline?.bundleName == bundleName }.map(SlotRole.slot)
                ?? .ordinary
            : .ordinary
        func refused(
            _ refusal: Refusal, claim: ManifestClaim? = nil, role: SlotRole? = nil
        ) -> (candidate: SelectionCandidate, prepared: Prepared?) {
            let role = role.flatMap { $0 == .ordinary ? nil : $0 } ?? designated
            return (
                SelectionCandidate(
                    id: id, origin: root.origin, bundleName: bundleName, installed: installed,
                    claim: claim, role: role, refusal: refusal, release: nil, schema: nil
                ), nil
            )
        }
        // A link out of the root is a bundle from somewhere Koine does not own.
        guard let rootPath = canonicalPath(root.location.path), installed.hasPrefix(rootPath + "/")
        else {
            return refused(
                .rejected(
                    ProviderReason.locationOutsideRoot,
                    "The bundle's location resolves outside its provider root."
                )
            )
        }
        guard
            let staged = try? ProviderStaging.stage(
                bundleAt: installed, origin: root.origin, under: staging
            )
        else {
            return refused(
                .rejected(
                    ProviderReason.stagingFailed, "The bundle could not be staged for verification."
                )
            )
        }
        let manifest: ProviderManifest
        do { manifest = try ProviderManifest(bundle: staged) } catch {
            return refused(
                .rejected(
                    ProviderReason.manifestInvalid,
                    (error as? ProviderManifest.Invalid)?.reason ?? "manifest.json is malformed."
                )
            )
        }
        let claim = ManifestClaim(
            providerId: manifest.providerId, graphQLPrefix: manifest.graphQLPrefix,
            version: manifest.version, schemaVersion: manifest.schemaVersion
        )
        let role: SlotRole
        do {
            role = try classify(claim, bundleName: bundleName, in: root, catalogue: catalogue)
        } catch let refusal as Refusal {
            return refused(refusal, claim: claim)
        } catch {
            return refused(.rejected(ProviderReason.checkFailed, "The bundle could not be checked."), claim: claim)
        }

        var release: ProviderVersion?
        var schema: ProviderVersion?
        do {
            // Trust before anything else the bundle says is believed.
            let approval = try approval(for: manifest, role: role, in: root, hostTeam: hostTeam)
            try checkSignature(of: staged.path, named: "The bundle", approvedBy: approval)
            if case .slot(let entry) = role, let baseline = entry.baseline {
                // A per-user first-party update states the selection feature, so
                // an earlier host refuses it before dlopen. The designated bundle
                // may be an independently compiled older provider without it.
                if root.origin == .perUser,
                    !manifest.requiredFeatures.contains(firstPartySelectionFeature)
                {
                    throw Refusal.incompatible(
                        ProviderReason.selectionFeatureRequired,
                        "A per-user update of \(entry.providerId) must declare \(firstPartySelectionFeature) in its manifest; this one does not."
                    )
                }
                // The identifier is read from the verified signature, not the manifest.
                let signer = CodeSignature.identifier(of: staged.path)
                guard signer == baseline.signingIdentifier else {
                    throw Refusal.rejected(
                        ProviderReason.signingIdentifierMismatch,
                        "The bundle is signed under \(signer ?? "no identifier"); this Koine admits \(baseline.signingIdentifier) for \(entry.providerId)."
                    )
                }
                guard let claimedRelease = ProviderVersion(manifest.version),
                    let claimedSchema = ProviderVersion(manifest.schemaVersion)
                else {
                    throw Refusal.rejected(
                        ProviderReason.invalidVersion,
                        "A first-party release and schema version are three decimal components, major.minor.patch; this one claims release \(manifest.version), schema \(manifest.schemaVersion)."
                    )
                }
                (release, schema) = (claimedRelease, claimedSchema)
            }
            try checkCompatibility(of: manifest, with: host)
            let (library, images) = try verifiedLibrary(of: manifest, in: staged)
            // The seal names a nested image by hash, which says who sealed it,
            // not who signed it: each image answers for itself.
            for image in images.sorted() {
                try checkSignature(
                    of: image, named: (image as NSString).lastPathComponent, approvedBy: approval
                )
            }
            // The bundled root's quarantine is the application's, judged when
            // it was first opened.
            if !root.isBundled {
                try checkGatekeeper(images, installed: installed, staged: staged.path, seam: seam)
            }
            return (
                SelectionCandidate(
                    id: id, origin: root.origin, bundleName: bundleName, installed: installed,
                    claim: claim, role: role, refusal: nil, release: release, schema: schema
                ), Prepared(manifest: manifest, library: library)
            )
        } catch let refusal as Refusal {
            return refused(refusal, claim: claim, role: role)
        } catch {
            return refused(
                .rejected(ProviderReason.checkFailed, "The bundle could not be checked."),
                claim: claim, role: role
            )
        }
    }

    /// The candidate's place in the catalogue, from its claim alone: an exact
    /// enabled pair contests a slot; anything else that overlaps a reserved name
    /// is refused alone, and can never evict its owner.
    private static func classify(
        _ claim: ManifestClaim, bundleName: String, in root: ProviderRoot,
        catalogue: ProviderCatalogue
    ) throws -> SlotRole {
        if root.isBundled {
            // The sealed root holds the designated bundles and nothing else.
            guard
                let entry = catalogue.entries.first(where: { $0.baseline?.bundleName == bundleName }),
                let baseline = entry.baseline
            else {
                throw Refusal.rejected(
                    ProviderReason.unexpectedBundledCandidate,
                    "\(bundleName) is not a bundle this Koine's catalogue designates. The application's sealed root holds the designated bundles only, and an unexpected one never replaces a designated bundle."
                )
            }
            guard claim.providerId == entry.providerId, claim.graphQLPrefix == entry.graphQLPrefix,
                ProviderVersion(claim.version) == baseline.release,
                ProviderVersion(claim.schemaVersion) == baseline.schema
            else {
                throw Refusal.rejected(
                    ProviderReason.catalogueBundleMismatch,
                    "\(bundleName) claims \(claim.providerId)/\(claim.graphQLPrefix) release \(claim.version), schema \(claim.schemaVersion); the catalogue designates it for \(entry.providerId)/\(entry.graphQLPrefix) release \(baseline.release), schema \(baseline.schema)."
                )
            }
            return .slot(entry)
        }
        if let entry = catalogue.entries.first(where: {
            $0.providerId == claim.providerId && $0.graphQLPrefix == claim.graphQLPrefix
        }) {
            guard entry.baseline != nil else {
                throw Refusal.rejected(
                    ProviderReason.reservedOnly,
                    "\(entry.providerId) is reserved for a provider Koine has not shipped yet; it cannot load from either root."
                )
            }
            return .slot(entry)
        }
        let claimed = [claim.providerId, claim.graphQLPrefix.lowercased()]
        if let entry = catalogue.entries.first(where: {
            ProviderCatalogue.overlap(claimed, ProviderCatalogue.names($0)) != nil
        }) {
            throw Refusal.rejected(
                ProviderReason.reservedIdentity,
                "\(claim.providerId)/\(claim.graphQLPrefix) overlaps the reserved identity \(entry.providerId)/\(entry.graphQLPrefix). Only that exact pair, as a shipped provider, may use it."
            )
        }
        return .ordinary
    }

    // MARK: Before dlopen

    private static func approval(
        for manifest: ProviderManifest, role: SlotRole, in root: ProviderRoot, hostTeam: String?
    ) throws -> ProviderApproval {
        guard case .slot(let entry) = role else { return try record(for: manifest, in: root) }
        // A shipped identity is approved for the running host's own team, never
        // for a hard-coded publisher. Unsigned and ad-hoc hosts have none.
        guard let hostTeam else {
            throw Refusal.rejected(
                ProviderReason.hostTeamUnavailable,
                "This Koine is unsigned or ad-hoc signed, so it has no Team ID and admits no shipped provider candidate; \(entry.providerId) stays reserved."
            )
        }
        // Built-in approval never substitutes for a per-user approval record.
        guard !root.isBundled else {
            return ProviderApproval(providerId: manifest.providerId, teamIdentifier: hostTeam)
        }
        let approval = try record(for: manifest, in: root)
        guard approval.teamIdentifier == hostTeam else {
            throw Refusal.rejected(
                ProviderReason.approvalTeamMismatch,
                "The approval record names Team ID \(approval.teamIdentifier); a first-party update of \(entry.providerId) must be signed by this Koine's own Team ID, \(hostTeam)."
            )
        }
        return approval
    }

    private static func record(
        for manifest: ProviderManifest, in root: ProviderRoot
    ) throws -> ProviderApproval {
        do { return try root.approvalRecord(for: manifest.providerId) } catch {
            throw Refusal.rejected(
                ProviderReason.notApproved,
                (error as? ProviderRoot.Unapproved)?.reason ?? "The provider is not approved."
            )
        }
    }

    private static func checkSignature(
        of path: String, named name: String, approvedBy approval: ProviderApproval
    ) throws {
        if let reason = CodeSignature.refusal(of: path, approvedBy: approval) {
            throw Refusal.rejected(ProviderReason.signatureRefused, "\(name) is refused: \(reason)")
        }
    }

    /// A quarantined image Gatekeeper would refuse is refused here, before
    /// `dlopen` raises the platform's modal dialog for it. The loader never
    /// clears the attribute; the diagnostic says who can. The assessment is of
    /// this candidate's own staged copy on every start, never a cached or
    /// inherited verdict.
    private static func checkGatekeeper(
        _ images: Set<String>, installed: String, staged: String, seam: Seam
    ) throws {
        for image in images.sorted() where Gatekeeper.isQuarantined(image) {
            guard let reason = seam.assessment(image) else { continue }
            throw Refusal.rejected(
                ProviderReason.quarantineRefused,
                "\((image as NSString).lastPathComponent) is quarantined and \(reason) macOS would refuse to load it. Its author can notarize it; or clear the attribute with `xattr -dr \(Gatekeeper.quarantineAttribute) \(quoted(installed))` and, with Koine stopped, delete its staged copy with `chmod -R u+w \(quoted(staged)) && rm -rf \(quoted(staged))`."
            )
        }
    }

    /// A path as one shell word: the per-user root is under "Application Support".
    private static func quoted(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    /// What the manifest asks of the host. A negotiation after loading cannot
    /// rescue a binary already linked against symbols the host lacks.
    private static func checkCompatibility(
        of manifest: ProviderManifest, with host: HostCompatibility
    ) throws {
        guard manifest.framework.major == host.frameworkMajor else {
            throw Refusal.incompatible(
                ProviderReason.frameworkIncompatible,
                "The provider requires provider framework major \(manifest.framework.major); this Koine supplies major \(host.frameworkMajor)."
            )
        }
        guard manifest.framework.minimumMinor <= host.frameworkMinor else {
            throw Refusal.incompatible(
                ProviderReason.frameworkIncompatible,
                "The provider requires provider framework \(manifest.framework.major).\(manifest.framework.minimumMinor) or later; this Koine supplies \(host.frameworkMajor).\(host.frameworkMinor)."
            )
        }
        let missing = Set(manifest.requiredFeatures).subtracting(host.features).sorted()
        guard missing.isEmpty else {
            throw Refusal.incompatible(
                ProviderReason.featureUnavailable,
                "The provider requires host features this Koine lacks: \(missing.joined(separator: ", "))."
            )
        }
        // A feature is carried by a framework minor, and the manifest states both:
        // one that names the feature under an older minimum minor says less than
        // the binary needs, and is refused as the inconsistent manifest it is.
        for (feature, minor) in Self.featureMinimumMinors
        where manifest.requiredFeatures.contains(feature) && manifest.framework.minimumMinor < minor {
            throw Refusal.rejected(
                ProviderReason.manifestInvalid,
                "The manifest requires \(feature) but declares framework minimum minor \(manifest.framework.minimumMinor); the feature needs \(manifest.framework.major).\(minor)."
            )
        }
        guard manifest.architectures.contains(HostPlatform.architecture) else {
            throw Refusal.incompatible(
                ProviderReason.architectureIncompatible,
                "The provider is built for \(manifest.architectures.joined(separator: ", ")); this Koine runs as \(HostPlatform.architecture)."
            )
        }
        // Validated when the manifest was read.
        let minimumOS = MachOImage.Version(manifest.minimumOS)!
        guard minimumOS <= HostPlatform.operatingSystem else {
            throw Refusal.incompatible(
                ProviderReason.osIncompatible,
                "The provider requires macOS \(minimumOS); this is macOS \(HostPlatform.operatingSystem)."
            )
        }
        let minimumRuntime = MachOImage.Version(manifest.minimumSwiftRuntime)!
        guard minimumRuntime <= HostPlatform.swiftRuntime else {
            throw Refusal.incompatible(
                ProviderReason.runtimeIncompatible,
                "The provider requires Swift runtime \(minimumRuntime); macOS \(HostPlatform.operatingSystem) supplies \(HostPlatform.swiftRuntime)."
            )
        }
    }

    /// The canonical path of the bundle's library, and of every image in its
    /// dependency closure inside the bundle, once the binary has been shown to
    /// match the manifest and to depend only on what it may.
    private static func verifiedLibrary(
        of manifest: ProviderManifest, in bundle: URL
    ) throws -> (library: String, images: Set<String>) {
        guard let bundlePath = canonicalPath(bundle.path) else {
            throw image("The bundle's location cannot be resolved.")
        }
        if let copy = try frameworkCopy(in: bundlePath) {
            throw image(
                "The bundle contains its own copy of the provider framework (\(copy)); a provider links the one Koine supplies."
            )
        }
        let library = try path(manifest.library, from: bundlePath, inside: bundlePath, what: "library")
        let main = try machO(at: library, named: manifest.library)
        let held = main.slices.map(\.architecture)
        guard Set(held) == Set(manifest.architectures) else {
            throw image(
                "The manifest declares \(manifest.architectures.joined(separator: ", ")) but \(manifest.library) holds \(held.joined(separator: ", "))."
            )
        }
        let slice = try hostSlice(of: main, named: manifest.library)
        if let built = slice.minimumOS, built > MachOImage.Version(manifest.minimumOS)! {
            throw image(
                "The manifest declares macOS \(manifest.minimumOS) but \(manifest.library) was built for macOS \(built) or later."
            )
        }
        guard slice.dependencies.contains(frameworkInstallName) else {
            throw image(
                "\(manifest.library) does not link the provider framework Koine supplies (\(frameworkInstallName))."
            )
        }
        var validated: Set<String> = []
        try checkDependencies(
            of: slice, at: library, named: manifest.library, inside: bundlePath,
            validated: &validated
        )
        return (library, validated)
    }

    private static func image(_ message: String) -> Refusal {
        .rejected(ProviderReason.imageInvalid, message)
    }

    /// Every dependency is the host's framework image, a system library or a
    /// validated private dependency inside the bundle.
    private static func checkDependencies(
        of slice: MachOImage.Slice, at imagePath: String, named name: String,
        inside bundlePath: String, validated: inout Set<String>
    ) throws {
        guard validated.insert(imagePath).inserted else { return }
        guard slice.definedExternalSymbols.isDisjoint(with: frameworkOwnSymbols) else {
            throw image(
                "\(name) defines the provider framework's own symbols: it carries a statically linked copy."
            )
        }
        for runPath in slice.runPaths where !isSystemPath(runPath) {
            _ = try path(runPath, from: imagePath, inside: bundlePath, what: "run path")
        }
        for dependency in slice.dependencies {
            if dependency == frameworkInstallName || isSystemPath(dependency) { continue }
            guard (dependency as NSString).lastPathComponent != frameworkName else {
                throw image("\(name) links a substitute for the provider framework: \(dependency).")
            }
            let resolved = try path(dependency, from: imagePath, inside: bundlePath, what: "dependency")
            let dependencyImage = try machO(at: resolved, named: dependency)
            try checkDependencies(
                of: try hostSlice(of: dependencyImage, named: dependency), at: resolved, named: dependency,
                inside: bundlePath, validated: &validated
            )
        }
    }

    private static func isSystemPath(_ path: String) -> Bool {
        let components = (path as NSString).pathComponents
        guard !components.contains("..") else { return false }
        return path.hasPrefix("/usr/lib/") || path.hasPrefix("/System/Library/")
    }

    /// A path the bundle names, resolved to an existing file or directory that
    /// is canonically inside the bundle. `@loader_path` is the naming image's
    /// directory; a bare relative path is relative to the bundle.
    private static func path(
        _ named: String, from origin: String, inside bundlePath: String, what: String
    ) throws -> String {
        let loaderPrefix = "@loader_path"
        let candidate: String
        if named == loaderPrefix || named.hasPrefix(loaderPrefix + "/") {
            candidate = (origin as NSString).deletingLastPathComponent + named.dropFirst(loaderPrefix.count)
        } else if what == "library", !named.hasPrefix("/"), !named.hasPrefix("@") {
            candidate = (bundlePath as NSString).appendingPathComponent(named)
        } else {
            throw image(
                "The \(what) \(named) is neither a system library, the provider framework nor inside the bundle."
            )
        }
        guard let resolved = canonicalPath(candidate) else {
            throw image("The \(what) \(named) does not exist.")
        }
        guard resolved == bundlePath || resolved.hasPrefix(bundlePath + "/") else {
            throw image("The \(what) \(named) resolves outside the bundle.")
        }
        return resolved
    }

    private static func machO(at path: String, named name: String) throws -> MachOImage {
        do { return try MachOImage(contentsOf: URL(fileURLWithPath: path)) } catch {
            let reason = (error as? MachOImage.Malformed)?.reason ?? "it cannot be read"
            throw image("\(name) is not a loadable image: \(reason).")
        }
    }

    private static func hostSlice(of file: MachOImage, named name: String) throws -> MachOImage.Slice {
        let slices = file.slices.filter { $0.architecture == HostPlatform.architecture }
        guard let slice = slices.first else {
            throw image("\(name) holds no \(HostPlatform.architecture) image.")
        }
        // Which of two the dynamic loader maps is its choice; what was checked
        // must be what is mapped.
        guard slices.count == 1 else {
            throw image("\(name) holds more than one \(HostPlatform.architecture) image.")
        }
        return slice
    }

    /// Anything in the bundle named as the framework is named: a plugin must
    /// not embed another copy, whatever its run paths say.
    /// Names are compared without case, as the file system compares them.
    private static func frameworkCopy(in bundlePath: String) throws -> String? {
        guard let entries = try? FileManager.default.subpathsOfDirectory(atPath: bundlePath) else {
            throw image("The bundle's contents cannot be listed.")
        }
        let names = [frameworkName.lowercased(), "\(frameworkName).framework".lowercased()]
        return entries.first { names.contains(($0 as NSString).lastPathComponent.lowercased()) }
    }

    /// realpath(3): `URL.resolvingSymlinksInPath` rewrites `/private` away, so
    /// it does not compare equal to the path dyld reports.
    private static func canonicalPath(_ path: String) -> String? {
        guard let resolved = realpath(path, nil) else { return nil }
        defer { free(resolved) }
        return String(cString: resolved)
    }

    // MARK: Principal names, as a batch

    /// The frozen selections' principal names, checked together before any of
    /// them loads: mutually unique, and free in the host as it already is. A name
    /// another image has registered is a collision, and is known before loading;
    /// the same image already loaded by an earlier server in this process is not
    /// one. A shipped selection contests only another shipped selection, and a
    /// non-shipped claimant of a shipped name is refused alone; among non-shipped
    /// selections every claimant is. No refusal reopens selection.
    private static func principalCollisions(
        _ selected: [(SelectionCandidate, Prepared)]
    ) -> [String: String] {
        var refused: [String: String] = [:]
        var byName: [String: [(SelectionCandidate, Prepared)]] = [:]
        for entry in selected { byName[entry.1.manifest.principalClass, default: []].append(entry) }
        for (name, group) in byName {
            for (candidate, ready) in group {
                if let existing = objc_lookUpClass(name), imagePath(of: existing) != ready.library {
                    refused[candidate.id] =
                        "The principal class name \(name) is already registered by another image."
                }
            }
            guard group.count > 1 else { continue }
            let shipped = group.filter { $0.0.role != .ordinary }
            let others = group.filter { $0.0.role == .ordinary }
            let places = group.map(\.0.installed).sorted().joined(separator: ", ")
            let message =
                "The principal class name \(name) is claimed by more than one selected provider (\(places)); the frozen selections that contest it are refused and none is retried."
            for (candidate, _) in others { refused[candidate.id] = refused[candidate.id] ?? message }
            if shipped.count > 1 {
                for (candidate, _) in shipped { refused[candidate.id] = refused[candidate.id] ?? message }
            }
        }
        return refused
    }

    private static func imagePath(of type: AnyClass) -> String? {
        class_getImageName(type).flatMap { canonicalPath(String(cString: $0)) }
    }

    // MARK: dlopen and after

    private static func load(_ library: String, manifest: ProviderManifest) throws -> LoadedProvider {
        // An absolute path: dlopen never searches for a provider. The image is
        // never closed; a loaded provider stays mapped until process exit,
        // whatever becomes of it below.
        guard dlopen(library, RTLD_NOW | RTLD_LOCAL) != nil else {
            let reason = dlerror().map { String(cString: $0) } ?? "unknown"
            throw Refusal.rejected(
                ProviderReason.loadFailed,
                "The dynamic loader refused \(manifest.library): \(reason)"
            )
        }
        // https://developer.apple.com/documentation/foundation/nsclassfromstring(_:)
        guard let principal = NSClassFromString(manifest.principalClass) else {
            throw Refusal.rejected(
                ProviderReason.principalClassMissing,
                "\(manifest.library) registers no class named \(manifest.principalClass)."
            )
        }
        guard imagePath(of: principal) == library else {
            throw Refusal.rejected(
                ProviderReason.principalClassInvalid,
                "The principal class \(manifest.principalClass) does not originate in \(manifest.library)."
            )
        }
        guard let factoryType = principal as? any ProviderFactory.Type else {
            throw Refusal.rejected(
                ProviderReason.principalClassInvalid,
                "The principal class \(manifest.principalClass) does not conform to ProviderFactory."
            )
        }
        let factory = factoryType.init()
        let descriptor = factory.descriptor
        guard descriptor.providerId == manifest.providerId,
            descriptor.graphQLPrefix == manifest.graphQLPrefix,
            Set(descriptor.requiredFeatures) == Set(manifest.requiredFeatures)
        else {
            throw Refusal.rejected(
                ProviderReason.descriptorMismatch,
                "The provider's runtime descriptor disagrees with its manifest about its identifier, prefix or required features."
            )
        }
        return LoadedProvider(descriptor: descriptor, provider: factory.makeProvider())
    }
}

/// The platform this process runs on, as the manifest's requirements name it.
enum HostPlatform {
    static var architecture: String {
        #if arch(arm64)
            "arm64"
        #elseif arch(x86_64)
            "x86_64"
        #else
            "unsupported"
        #endif
    }

    static var operatingSystem: MachOImage.Version {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return MachOImage.Version([version.majorVersion, version.minorVersion, version.patchVersion])
    }

    /// On macOS the Swift runtime is an OS component and nothing reports its
    /// version, so it follows from the OS. The Swift project's own table:
    /// https://github.com/swiftlang/swift/blob/main/utils/availability-macros.def
    /// (the `SwiftStdlib` lines; read 2026-09-19). An OS newer than the table
    /// supplies at least its last entry.
    static var swiftRuntime: MachOImage.Version {
        let table: [(os: [Int], runtime: [Int])] = [
            ([13, 0], [5, 7]), ([13, 3], [5, 8]), ([14, 0], [5, 9]), ([14, 4], [5, 10]),
            ([15, 0], [6, 0]), ([15, 4], [6, 1]), ([26, 0], [6, 2]), ([26, 4], [6, 3]),
            ([27, 0], [6, 4]),
        ]
        let os = operatingSystem
        let supplied = table.last { MachOImage.Version($0.os) <= os }
        return MachOImage.Version(supplied?.runtime ?? [5, 7])
    }
}
