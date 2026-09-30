import CryptoKit
import Foundation

/// What became of one discovered provider candidate: a canonical bundle in one
/// of the two roots, or a synthetic row for an enabled slot no bundle fills
/// (docs/specs/machine.md, "Candidate diagnostics and schema identity").
///
/// One report per candidate, and it is what every later phase reads. Nothing is
/// merged by provider identifier: a refusal belongs to the copy it refused.
public struct ProviderCandidateReport: Sendable {
    public enum Origin: String, Sendable {
        case bundled = "BUNDLED"
        case perUser = "PER_USER"
    }

    public enum Selection: String, Sendable {
        case selected = "SELECTED"
        case notSelected = "NOT_SELECTED"
        /// A synthetic row for a slot with nothing to run.
        case unavailable = "UNAVAILABLE"
    }

    public enum Outcome: Sendable {
        /// The frozen choice, loaded. It is not yet published: the core still
        /// validates its descriptor, schema and authority.
        case loaded(LoadedProvider)
        /// An honest bundle this host cannot run. None of its code was loaded.
        case incompatible(String)
        /// A malformed, contradictory, refused or unloadable candidate. If its
        /// initializers ran, its image stays mapped.
        case rejected(String)
    }

    /// Opaque identity of origin plus canonical installed location, unique within
    /// this startup. Nil only for a synthetic row.
    public let candidateId: String?
    /// Nil only for a synthetic row. Never inferred from composition position.
    public let origin: Origin?
    /// The manifest's provider identifier, a claim; `(unknown)` when the bundle
    /// names none; the catalogue's identity for a synthetic row.
    public let provider: String
    public let version: String
    public let schemaVersion: String
    public let outcome: Outcome
    public let selection: Selection
    /// The frozen choice for the same provider identity, or nil if there is none.
    /// A selected candidate names itself, even when it is later refused.
    public let selectedCandidateId: String?
    /// A stable, open diagnostic code; nil for a healthy selected candidate with
    /// no competing refusal and no missing-bundle diagnostic.
    public let reason: String?
    /// Competing refusals, missing-bundle causes and recovery, of a selected
    /// candidate whose own outcome is healthy.
    public let note: String?
    /// Whether the candidate owns a shipped slot, bundled or per-user: shipped
    /// selections publish before ordinary ones, by identifier.
    public let isShipped: Bool
    /// The canonical installed location, for diagnostics behind management
    /// authority. Nil only for a synthetic row.
    public let location: String?

    /// The provider identifier used for a bundle that names none. It is not a
    /// valid identifier, so it can never be a provider's own.
    public static let unidentified = "(unknown)"
}

/// The reports of one startup's selection, and what publishes.
public struct ProviderSelectionResult: Sendable {
    /// Every candidate and synthetic row, sorted by provider, origin and
    /// candidate identifier in Unicode order, synthetic rows last for a provider.
    public let reports: [ProviderCandidateReport]
    /// The selected, loaded providers in composition order: shipped identities
    /// sorted by identifier, then ordinary per-user identities sorted by
    /// identifier. The core follows them.
    public var publication: [ProviderCandidateReport] {
        reports.filter { if case .loaded = $0.outcome { true } else { false } }
            .sorted {
                ($0.isShipped ? 0 : 1, $0.provider) < ($1.isShipped ? 0 : 1, $1.provider)
            }
    }
}

/// The reason codes a candidate's report can carry. Open: a host may meet a new
/// one, and a status consumer treats an unknown code as an opaque explanation.
public enum ProviderReason {
    // Selection (docs/specs/machine.md, "Candidate diagnostics").
    public static let olderThanBundled = "older-than-bundled"
    public static let equalToBundled = "equal-to-bundled"
    public static let supersededCandidate = "superseded-candidate"
    public static let reservedIdentity = "reserved-identity"
    public static let reservedOnly = "reserved-only"
    public static let ambiguousUpdate = "ambiguous-update"
    public static let invalidVersion = "invalid-version"
    public static let schemaIncompatible = "schema-incompatible"
    public static let missingBundled = "missing-bundled"
    public static let catalogueBundleMismatch = "catalogue-bundle-mismatch"
    public static let unexpectedBundledCandidate = "unexpected-bundled-candidate"
    public static let catalogueInvalid = "catalogue-invalid"
    public static let hostTeamUnavailable = "host-team-unavailable"
    public static let signingIdentifierMismatch = "signing-identifier-mismatch"
    public static let selectionFeatureRequired = "selection-feature-required"
    public static let noEligibleCandidate = "no-eligible-candidate"
    public static let manifestCollision = "manifest-collision"
    public static let principalCollision = "principal-collision"
    public static let missingCapabilityOwner = "missing-capability-owner"
    public static let selectedWithRefusals = "selected-with-refusals"
    // Existing trust and compatibility failures, which keep their classification.
    public static let locationOutsideRoot = "location-outside-root"
    public static let stagingFailed = "staging-failed"
    public static let manifestInvalid = "manifest-invalid"
    public static let notApproved = "not-approved"
    public static let approvalTeamMismatch = "approval-team-mismatch"
    public static let signatureRefused = "signature-refused"
    public static let frameworkIncompatible = "framework-incompatible"
    public static let featureUnavailable = "feature-unavailable"
    public static let architectureIncompatible = "architecture-incompatible"
    public static let osIncompatible = "os-incompatible"
    public static let runtimeIncompatible = "runtime-incompatible"
    public static let imageInvalid = "image-invalid"
    public static let quarantineRefused = "quarantine-refused"
    public static let loadFailed = "load-failed"
    public static let principalClassMissing = "principal-class-missing"
    public static let principalClassInvalid = "principal-class-invalid"
    public static let descriptorMismatch = "descriptor-mismatch"
    public static let checkFailed = "check-failed"
}

/// A refusal of one candidate: what its status says, and the stable reason.
struct Refusal: Error {
    enum Kind { case incompatible, rejected }

    let kind: Kind
    let reason: String
    let message: String

    static func incompatible(_ reason: String, _ message: String) -> Refusal {
        Refusal(kind: .incompatible, reason: reason, message: message)
    }

    static func rejected(_ reason: String, _ message: String) -> Refusal {
        Refusal(kind: .rejected, reason: reason, message: message)
    }
}

/// What a bundle's manifest claims, read before trust and believed by nothing
/// but the display of the candidate it came from.
struct ManifestClaim: Sendable, Equatable {
    let providerId: String
    let graphQLPrefix: String
    let version: String
    let schemaVersion: String
}

/// A candidate's place in the catalogue, decided from its claim alone.
enum SlotRole: Sendable, Equatable {
    /// An ordinary provider: contests only manifest collisions.
    case ordinary
    /// The exact identifier/prefix pair of an enabled catalogue entry.
    case slot(ProviderCatalogue.Entry)
}

/// One discovered candidate, with its pre-load verdict. The selection
/// calculation reads only this: no file, no image, no clock.
struct SelectionCandidate: Sendable {
    let id: String
    let origin: ProviderCandidateReport.Origin
    /// The canonical directory's own name: how a designated bundle is recognised.
    let bundleName: String
    let installed: String
    let claim: ManifestClaim?
    let role: SlotRole
    /// The pre-load refusal, or nil for a candidate that passed every check
    /// short of loading.
    let refusal: Refusal?
    /// Verified slot candidates only.
    let release: ProviderVersion?
    let schema: ProviderVersion?

    var isVerified: Bool { refusal == nil }
}

enum CandidateIdentity {
    /// Origin plus canonical location: what a candidate is, whatever its
    /// manifest claims. Opaque, and stable within one installed set.
    static func id(origin: ProviderCandidateReport.Origin, installed: String) -> String {
        let digest = SHA256.hash(data: Data("\(origin.rawValue)\0\(installed)".utf8))
        return "candidate-" + digest.prefix(12).map { String(format: "%02x", $0) }.joined()
    }
}
