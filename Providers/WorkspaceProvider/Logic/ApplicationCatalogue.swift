import Foundation
import KoineProviderAPI

// The second query of the read surface: the applications that the one fixed index query reports
// (docs/specs/workspace-search.md, "Application sources and native facts" and "Coverage and frozen publication").
// A choice is what the index said and nothing more. No copy is resolved, registered, launched or inspected.
// The same identifier on two paths is two choices.

/// The most items one query may copy: the search spec's bound on distinct choices. A larger gathering is an
/// overflow. It is never reported as a prefix in the index's order.
let applicationEntryLimit = 2048

private let source = "INDEXED_APPS"
private let applicationBundleType = "com.apple.application-bundle"

private enum CatalogueReason: String {
    case metadataUnknown = "METADATA_UNKNOWN"
    case unrepresentableValue = "UNREPRESENTABLE_VALUE"
    case entryLimit = "ENTRY_LIMIT"
    case timeLimit = "TIME_LIMIT"
    case inspectionFailed = "INSPECTION_FAILED"
}

/// The published bounds of a label (1 to 1,024 UTF-8 bytes) and of an identifier (1 to 512), with no NUL
/// (docs/specs/workspace-search.md, "Input and output validation"). A value outside them is withheld, never shortened.
private func isRepresentable(_ value: String, upTo limit: Int) -> Bool {
    let bytes = value.utf8
    return !bytes.isEmpty && bytes.count <= limit && !bytes.contains(0)
}

/// What one run of the fixed query came to, as the frozen root result the query's nested fields read.
func applicationsResult(native: some WorkspaceNative, wait: Duration) -> ProviderValue {
    switch native.indexedApplications(limit: applicationEntryLimit, wait: wait) {
    case .gathered(let items): return catalogue(of: items)
    case .overLimit:
        return failure(.entryLimit, "The index holds more than \(applicationEntryLimit) applications, so none was reported.")
    case .unfinished:
        return failure(.timeLimit, "The index had not finished gathering its applications in time, so none was reported.")
    case .failed(let reason):
        return failure(.inspectionFailed, "The index query did not start: \(reason)")
    }
}

private func catalogue(of items: [IndexedApplication]) -> ProviderValue {
    if items.isEmpty {
        // A finished gathering that returned nothing is not a healthy empty index: it may be disabled, excluded
        // or rebuilding (docs/verification/native-discovery-acceptance.md, G2).
        return result(
            status: "UNKNOWN", items: [], available: false, observations: "UNKNOWN", examined: 0,
            diagnostics: [
                diagnostic(
                    .metadataUnknown,
                    "The index returned no applications. It may be disabled, excluded or rebuilding, so this is not an empty inventory."
                )
            ])
    }
    var choices: [ProviderValue] = []
    var withheldPaths = 0
    var withheldTypes = 0
    var unnamed = 0
    var unidentified = 0
    for item in items {
        guard let path = item.path, isRepresentableLocation(path) else {
            withheldPaths += 1
            continue
        }
        // The predicate selected on the type tree, so a tree that is present and lacks the type contradicts it.
        if let tree = item.contentTypeTree, !tree.contains(applicationBundleType) {
            withheldTypes += 1
            continue
        }
        var name: ProviderValue = .null
        if let text = item.displayName, isRepresentable(text, upTo: 1024) {
            name = .string(text)
        } else {
            unnamed += 1
        }
        var identifier: ProviderValue = .null
        switch item.bundleIdentifier {
        case nil: break
        case let text? where isRepresentable(text, upTo: 512): identifier = .string(text)
        default: unidentified += 1
        }
        choices.append(
            .object([
                "applicationPath": .string(path), "name": name, "bundleIdentifier": identifier,
                "sources": .list([.string(source)]),
            ]))
    }
    var diagnostics: [ProviderValue] = []
    if withheldPaths > 0 {
        diagnostics.append(
            diagnostic(
                .unrepresentableValue,
                "\(withheldPaths) indexed items gave no usable absolute path, so they were withheld."))
    }
    if withheldTypes > 0 {
        diagnostics.append(
            diagnostic(
                .metadataUnknown,
                "\(withheldTypes) indexed items did not report the application-bundle type that the query selects, so they were withheld."
            ))
    }
    if unnamed > 0 {
        diagnostics.append(
            diagnostic(.metadataUnknown, "\(unnamed) indexed items gave no usable name, so their name is null."))
    }
    if unidentified > 0 {
        diagnostics.append(
            diagnostic(
                .unrepresentableValue,
                "\(unidentified) indexed items gave a bundle identifier that is not usable, so it is null."))
    }
    // Withheld items and withheld facts are an omission. They make the other items neither untrue nor a
    // healthy complete inventory, and when no item remains the answer is a failure, not an empty one.
    if choices.isEmpty {
        return result(
            status: "FAILED", items: [], available: false, observations: "UNKNOWN", examined: items.count,
            diagnostics: diagnostics)
    }
    let omission = !diagnostics.isEmpty
    return result(
        status: omission ? "PARTIAL" : "AVAILABLE", items: choices, available: true,
        observations: omission ? "PARTIAL" : "COMPLETE", examined: items.count, diagnostics: diagnostics)
}

/// A query that produced nothing to report. Items are withheld, and the staged ones are not reported as a prefix.
private func failure(_ reason: CatalogueReason, _ guidance: String) -> ProviderValue {
    result(
        status: "FAILED", items: [], available: false, observations: "UNKNOWN", examined: 0,
        diagnostics: [diagnostic(reason, guidance)])
}

private func result(
    status: String, items: [ProviderValue], available: Bool, observations: String, examined: Int,
    diagnostics: [ProviderValue]
) -> ProviderValue {
    let coverage: ProviderValue = .object([
        "source": .string(source),
        "declaredDomain": .string("indexed local computer applications"),
        "availability": .string(available ? "AVAILABLE" : "UNKNOWN"),
        "observations": .string(observations),
        // Whether the index holds every application is never established here.
        "category": .string("UNKNOWN"),
        "examined": .int(examined),
        "diagnostics": .list(diagnostics),
    ])
    return .object([
        "status": .string(status), "items": items.isEmpty ? .null : .list(items), "sources": .list([coverage]),
        "resultsTruncated": .bool(false),
    ])
}

/// One detail record for a reason and the number of items it concerns. At most four reasons occur in one run, so
/// the detail sink (63 records) cannot fill and no DIAGNOSTIC_LIMIT record is needed. The subject stays null
/// because no location was independently identified.
private func diagnostic(_ reason: CatalogueReason, _ guidance: String) -> ProviderValue {
    .object([
        "source": .string(source), "reason": .string(reason.rawValue), "subject": .null,
        "affectsCoverage": .bool(true), "guidance": .string(guidance), "permission": .null,
    ])
}
