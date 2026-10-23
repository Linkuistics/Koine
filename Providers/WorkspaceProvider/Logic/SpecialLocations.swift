import Foundation
import KoineProviderAPI

// The first query of the read surface: Foundation's value for each named account and domain
// pair (docs/specs/workspace-search.md, "Special locations" and "Input and output validation").
// A lookup returns values and nothing else: no location is resolved, listed, opened or
// inspected, so a returned value promises neither presence nor access nor consent.

enum LocationKind: String, CaseIterable, Sendable {
    case home = "HOME"
    case desktop = "DESKTOP"
    case documents = "DOCUMENTS"
    case downloads = "DOWNLOADS"
    case movies = "MOVIES"
    case music = "MUSIC"
    case pictures = "PICTURES"
    case applications = "APPLICATIONS"
}

enum LocationDomain: String, CaseIterable, Sendable {
    case user = "USER"
    case local = "LOCAL"
    case system = "SYSTEM"
}

struct LocationPair: Hashable, Sendable {
    var kind: LocationKind
    var domain: LocationDomain

    /// The seven account folders have a user value alone; the applications folder has all three.
    var isSupported: Bool { kind == .applications || domain == .user }

    /// The ten pairs an omitted request names, in the order the result lists them.
    static let defaults: [LocationPair] =
        LocationKind.allCases.filter { $0 != .applications }.map { LocationPair(kind: $0, domain: .user) }
        + LocationDomain.allCases.map { LocationPair(kind: .applications, domain: $0) }

    static let requestLimit = 10

    /// Omitted or null is the default set; otherwise a nonempty list of at most ten distinct supported pairs, kept in
    /// the order given. Every refusal is made before any lookup.
    static func validated(_ argument: ProviderValue?) -> Result<[LocationPair], InputError> {
        switch argument {
        case nil, .null?: return .success(defaults)
        case .list(let entries)?:
            guard !entries.isEmpty else { return .failure(InputError("requests must name at least one location.")) }
            guard entries.count <= requestLimit else {
                return .failure(InputError("requests names more than \(requestLimit) locations."))
            }
            var pairs: [LocationPair] = []
            for entry in entries {
                guard case .object(let fields) = entry, case .string(let kind)? = fields["kind"],
                    case .string(let domain)? = fields["domain"],
                    let pair = LocationKind(rawValue: kind).flatMap({ kind in
                        LocationDomain(rawValue: domain).map { LocationPair(kind: kind, domain: $0) }
                    })
                else { return .failure(InputError("each request needs a kind and a domain.")) }
                guard pair.isSupported else {
                    return .failure(InputError("\(pair.kind.rawValue) has no \(pair.domain.rawValue) location."))
                }
                guard !pairs.contains(pair) else {
                    return .failure(
                        InputError("requests names \(pair.kind.rawValue) in \(pair.domain.rawValue) more than once."))
                }
                pairs.append(pair)
            }
            return .success(pairs)
        default: return .failure(InputError("requests must be a list."))
        }
    }
}

/// The published bounds of a native string (docs/specs/workspace-search.md, "Input and output validation"):
/// an absolute local path of at most 8,192 UTF-8 bytes. A value outside them is withheld, never shortened into another
/// location.
func isRepresentableLocation(_ value: String) -> Bool {
    let bytes = value.utf8
    return !bytes.isEmpty && bytes.count <= 8192 && value.hasPrefix("/") && !bytes.contains(0)
}

/// What one lookup of the pairs came to, as the frozen root result the query's nested fields read.
func specialLocationsResult(
    for pairs: [LocationPair], explicit: Bool, native: some WorkspaceNative
) -> ProviderValue {
    let account = native.accountIdentifier()
    var items: [ProviderValue] = []
    var diagnostics: [ProviderValue] = []
    var withheld = false
    var absent = false
    for pair in pairs {
        let values = native.specialLocationValues(pair)
        if values.isEmpty {
            absent = true
            diagnostics.append(
                diagnostic(
                    .noNativeValue,
                    "The system gave no value for \(pair.kind.rawValue) in the \(pair.domain.rawValue) domain."))
            continue
        }
        var unrepresentable = false
        for value in values {
            guard isRepresentableLocation(value) else {
                unrepresentable = true
                continue
            }
            items.append(
                .object([
                    "kind": .string(pair.kind.rawValue), "domain": .string(pair.domain.rawValue),
                    "accountIdentifier": .string(account), "location": .string(value),
                    "contentsAvailability": .string("UNKNOWN"), "sources": .list([.string(source)]),
                ]))
        }
        if unrepresentable {
            withheld = true
            diagnostics.append(
                diagnostic(
                    .unrepresentableValue,
                    "A value for \(pair.kind.rawValue) in the \(pair.domain.rawValue) domain is not a usable absolute path, so it was withheld."
                ))
        }
    }
    // Withheld values are a failure-class omission and an absent value is an unestablished one; neither makes
    // the others untrue, and neither is read as a healthy empty filesystem.
    let omission = withheld || absent
    let status: String
    switch (items.isEmpty, withheld) {
    case (false, _): status = omission ? "PARTIAL" : "AVAILABLE"
    case (true, true): status = "FAILED"
    case (true, false): status = "UNKNOWN"
    }
    let coverage: ProviderValue = .object([
        "source": .string(source),
        "declaredDomain": .string(explicit ? "requested special locations" : "default special locations"),
        "availability": .string(items.isEmpty ? "UNKNOWN" : "AVAILABLE"),
        "observations": .string(items.isEmpty ? "UNKNOWN" : omission ? "PARTIAL" : "COMPLETE"),
        // Whether any directory holds what, or anything, is never established here.
        "category": .string("UNKNOWN"),
        "examined": .int(pairs.count),
        "diagnostics": .list(diagnostics),
    ])
    return .object([
        "status": .string(status), "items": items.isEmpty ? .null : .list(items), "sources": .list([coverage]),
        "resultsTruncated": .bool(false),
    ])
}

private let source = "FOUNDATION_LOCATIONS"

private enum SpecialLocationReason: String {
    case noNativeValue = "NO_NATIVE_VALUE"
    case unrepresentableValue = "UNREPRESENTABLE_VALUE"
}

/// A detail record. At most one is made per requested pair and a request names at most ten, so the detail sink
/// (63 records) cannot fill and no DIAGNOSTIC_LIMIT record is ever needed. The subject stays null because no
/// location was independently identified.
private func diagnostic(_ reason: SpecialLocationReason, _ guidance: String) -> ProviderValue {
    .object([
        "source": .string(source), "reason": .string(reason.rawValue), "subject": .null,
        "affectsCoverage": .bool(true), "guidance": .string(guidance), "permission": .null,
    ])
}
