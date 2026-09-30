import Foundation

/// A conformance profile: the design schema a host of one kind serves, and,
/// separately from it, the exact provider candidates that host is expected to
/// be running.
///
/// The schema and its digest cannot say which binary ran: an identical
/// contribution selected from another root, or another release of the same
/// provider, prints the same SDL (docs/specs/machine.md, "Candidate diagnostics
/// and schema identity"). So a profile pins the versions and selection of every
/// row `koineManagement.providers` serves, and the set is explicit: a required
/// provider that is absent fails the profile, and so does a row the profile did
/// not expect. Neither shrinks what is expected.
public struct ConformanceProfile: Decodable, Sendable, Equatable {
    /// Which management schema the host serves. `baseline` hosts predate the
    /// candidate fields; an `extended` host serves them on every row.
    public enum Management: String, Decodable, Sendable {
        case baseline
        case extended
    }

    /// One expected row. `provider`, `version`, `schemaVersion` and `state` are
    /// always required; any other key present is compared exactly, and a JSON
    /// null means the served field must be null.
    public struct Candidate: Decodable, Sendable, Equatable {
        public let fields: [String: String?]

        public init(from decoder: Decoder) throws {
            fields = try decoder.singleValueContainer().decode([String: String?].self)
            for key in ConformanceProfile.pinned where (fields[key] ?? nil) == nil {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "an expected candidate needs a non-null \(key)"
                    )
                )
            }
        }

        public init(_ fields: [String: String?]) { self.fields = fields }

        var summary: String {
            let text = { (key: String) in self.fields[key].flatMap { $0 } ?? "?" }
            return "\(text("provider")) \(text("version")) (schema \(text("schemaVersion")), \(text("state")))"
        }
    }

    public let name: String
    /// The design SDL, relative to the profile file (or absolute).
    public let design: String
    public let management: Management
    public let providers: [Candidate]

    public init(name: String, design: String, management: Management, providers: [Candidate]) {
        self.name = name
        self.design = design
        self.management = management
        self.providers = providers
    }

    /// What every expected candidate names, whichever host serves it.
    static let pinned = ["provider", "version", "schemaVersion", "state"]

    /// What an extended host serves on every row, null or not.
    public static let candidateFields = [
        "candidateId", "origin", "selection", "selectedCandidateId", "reason",
    ]

    /// The provider rows `koineManagement.providers` served, one object per row
    /// with string or null values. Empty when the profile holds.
    public func problems(inServed served: [[String: String?]]) -> [String] {
        var problems: [String] = []
        var unmatched = Array(served.indices)

        if management == .extended {
            for (index, row) in served.enumerated() {
                let missing = Self.candidateFields.filter { row[$0] == nil }
                if !missing.isEmpty {
                    problems.append(
                        "row \(index + 1) (\(describe(row))) does not carry the candidate fields "
                            + "\(missing.joined(separator: ", ")); an extension host serves all of them on every row"
                    )
                }
            }
        }

        for expected in providers {
            let matching = unmatched.first { index in
                expected.fields.allSatisfy { key, value in
                    guard let served = served[index][key] else { return false }
                    return served == value
                }
            }
            if let matching {
                unmatched.removeAll { $0 == matching }
                continue
            }
            let provider = expected.fields["provider"].flatMap { $0 } ?? ""
            let nearest = served.filter { ($0["provider"] ?? nil) == provider }
            problems.append(
                nearest.isEmpty
                    ? "required \(expected.summary) is missing: the host serves no row for provider \(provider)"
                    : "required \(expected.summary) is not served as expected; the host serves "
                        + nearest.map(describe).joined(separator: "; ")
            )
        }

        for index in unmatched {
            problems.append("unexpected row \(describe(served[index])): the profile does not expect it")
        }

        if management == .extended {
            for row in served {
                // A selected row points to itself, even after a later failure.
                if (row["selection"] ?? nil) == "SELECTED",
                    (row["selectedCandidateId"] ?? nil) != (row["candidateId"] ?? nil)
                {
                    problems.append(
                        "a SELECTED row (\(describe(row))) does not name itself as selectedCandidateId"
                    )
                }
            }
        }
        return problems
    }

    private func describe(_ row: [String: String?]) -> String {
        let text = { (key: String) in row[key].flatMap { $0 } ?? "null" }
        var parts = "\(text("provider")) \(text("version")) schema \(text("schemaVersion")) \(text("state"))"
        if management == .extended {
            parts += " \(text("origin")) \(text("selection")) reason \(text("reason"))"
        }
        return parts
    }

    /// Reads a profile file; its design path resolves against the file's directory.
    public static func load(from url: URL) throws -> (profile: ConformanceProfile, design: URL) {
        let profile = try JSONDecoder().decode(ConformanceProfile.self, from: Data(contentsOf: url))
        let directory = url.deletingLastPathComponent()
        let design = profile.design.hasPrefix("/")
            ? URL(fileURLWithPath: profile.design)
            : directory.appendingPathComponent(profile.design)
        return (profile, design.standardizedFileURL)
    }

    /// The rows of a `{ koineManagement { providers { … } } }` response, or of a
    /// bare array of them.
    public static func servedRows(fromJSON data: Data) throws -> [[String: String?]] {
        struct Envelope: Decodable {
            struct Data: Decodable {
                struct Management: Decodable { let providers: [[String: String?]] }
                let koineManagement: Management
            }
            let data: Data
        }
        if let envelope = try? JSONDecoder().decode(Envelope.self, from: data) {
            return envelope.data.koineManagement.providers
        }
        return try JSONDecoder().decode([[String: String?]].self, from: data)
    }
}
