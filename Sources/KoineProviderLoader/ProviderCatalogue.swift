import Foundation

/// A first-party release or schema version: three decimal components,
/// `major.minor.patch`, each in `0...2147483647`, with no leading zero except
/// `0`, and no sign, suffix or build metadata. It is compared numerically,
/// component by component, so `1.10.0` exceeds `1.9.0`. This is a first-party
/// publication rule; it restricts no other provider's version text
/// (docs/specs/machine.md, "Eligibility and precedence").
public struct ProviderVersion: Sendable, Hashable, Comparable, CustomStringConvertible {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init?(_ text: String) {
        let parts = text.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        var numbers: [Int] = []
        for part in parts {
            let digits = part.utf8
            guard !digits.isEmpty, digits.allSatisfy({ (0x30...0x39).contains($0) }),
                part == "0" || part.first != "0", digits.count <= 10,
                let number = Int(part), number <= Int(Int32.max)
            else { return nil }
            numbers.append(number)
        }
        (major, minor, patch) = (numbers[0], numbers[1], numbers[2])
    }

    public var description: String { "\(major).\(minor).\(patch)" }

    public static func < (left: ProviderVersion, right: ProviderVersion) -> Bool {
        (left.major, left.minor, left.patch) < (right.major, right.minor, right.patch)
    }
}

/// The host-owned catalogue of the identities Koine ships, sealed with the
/// application (docs/specs/machine.md, "Reserved identities"). Every entry
/// reserves its identifier and prefix whether or not a bundle for it exists,
/// loads or starts. An entry is either reserved-only or enabled: an enabled
/// entry names its one designated bundle inside the application, the release and
/// schema versions that bundle carries, and the code-signing identifier its
/// release is signed under.
///
/// The approval Team ID is not here. It derives from the verified running host's
/// own signature, so a separately signed host uses its own team.
public struct ProviderCatalogue: Sendable, Equatable {
    public struct Baseline: Sendable, Equatable {
        /// The designated bundle's directory name inside the in-application root.
        public let bundleName: String
        public let release: ProviderVersion
        public let schema: ProviderVersion
        /// The stable release code-signing identifier, read from the staged
        /// bundle's signature and never from its manifest.
        public let signingIdentifier: String

        public init(
            bundleName: String, release: ProviderVersion, schema: ProviderVersion,
            signingIdentifier: String
        ) {
            self.bundleName = bundleName
            self.release = release
            self.schema = schema
            self.signingIdentifier = signingIdentifier
        }
    }

    public struct Entry: Sendable, Equatable {
        public let providerId: String
        public let graphQLPrefix: String
        /// Nil for a reserved-only entry: it can load from neither root.
        public let baseline: Baseline?

        public init(providerId: String, graphQLPrefix: String, baseline: Baseline? = nil) {
            self.providerId = providerId
            self.graphQLPrefix = graphQLPrefix
            self.baseline = baseline
        }
    }

    /// Why a catalogue is malformed or conflicts with itself. It is a packaging
    /// failure: the host publishes core management alone.
    public struct Invalid: Error, Sendable, Equatable {
        public let reason: String
        public init(reason: String) { self.reason = reason }
    }

    public let entries: [Entry]

    /// A catalogue that reserves nothing: every bundle is an ordinary provider,
    /// and nothing sealed is designated. A host that ships providers never uses it.
    public static let empty = ProviderCatalogue(checked: [])

    /// The one reservation a host makes before it states a catalogue: `desktop`,
    /// reserved-only, so no bundle can replace the desktop provider and none is
    /// admitted as a shipped one. It is the default of an embedding that supplies no
    /// catalogue of its own.
    public static let reservingDesktop = ProviderCatalogue(checked: [
        Entry(providerId: "desktop", graphQLPrefix: "Desktop")
    ])

    private init(checked entries: [Entry]) { self.entries = entries }

    /// Refuses an entry whose names are not well formed and any two that overlap.
    public init(entries: [Entry]) throws {
        var seenBundles: [String: String] = [:]  // by lower-cased name: the file system folds case
        var seenSigners: [String: String] = [:]
        for entry in entries {
            try Self.check(entry)
            if let baseline = entry.baseline {
                if let other = seenBundles.updateValue(
                    entry.providerId, forKey: baseline.bundleName.lowercased()
                ) {
                    throw Invalid(
                        reason: "\(other) and \(entry.providerId) designate the same bundle \(baseline.bundleName)."
                    )
                }
                if let other = seenSigners.updateValue(
                    entry.providerId, forKey: baseline.signingIdentifier
                ) {
                    throw Invalid(
                        reason: "\(other) and \(entry.providerId) share the signing identifier \(baseline.signingIdentifier)."
                    )
                }
            }
        }
        for (index, entry) in entries.enumerated() {
            for other in entries[(index + 1)...] {
                if entry.providerId == other.providerId {
                    throw Invalid(reason: "Provider \(entry.providerId) is listed twice.")
                }
                if let overlap = Self.overlap(Self.names(entry), Self.names(other)) {
                    throw Invalid(
                        reason: "\(entry.providerId) and \(other.providerId) overlap on \(overlap)."
                    )
                }
            }
        }
        self.entries = entries
    }

    /// The catalogue's sealed form, `ProviderCatalogue.json`: an object whose
    /// `identities` array holds `providerId` and `graphQLPrefix`, and for an
    /// enabled entry also `bundle`, `release`, `schema` and `signingIdentifier`.
    /// A key it does not know is refused, so a misspelt one cannot quietly leave
    /// an entry reserved-only.
    public init(json: Data) throws {
        guard let root = try? JSONSerialization.jsonObject(with: json) as? [String: Any],
            root.keys.sorted() == ["identities"], let identities = root["identities"] as? [[String: Any]]
        else { throw Invalid(reason: "The catalogue is not an object holding an identities array.") }
        let known: Set = ["providerId", "graphQLPrefix", "bundle", "release", "schema", "signingIdentifier"]
        let enabled: Set = ["bundle", "release", "schema", "signingIdentifier"]
        // A catalogue that lists nothing would unreserve every shipped identity: a
        // truncated one is malformed, not empty.
        guard !identities.isEmpty else { throw Invalid(reason: "The catalogue lists no identity.") }
        var entries: [Entry] = []
        for identity in identities {
            func text(_ key: String) throws -> String {
                guard let value = identity[key] as? String, !value.isEmpty else {
                    throw Invalid(reason: "An identity's \(key) is missing or is not text.")
                }
                return value
            }
            if let stray = Set(identity.keys).subtracting(known).sorted().first {
                throw Invalid(reason: "An identity has an unknown key, \(stray).")
            }
            let providerId = try text("providerId")
            let present = enabled.intersection(identity.keys)
            var baseline: Baseline?
            if !present.isEmpty {
                guard present == enabled else {
                    throw Invalid(
                        reason: "Provider \(providerId) states part of a baseline; an enabled identity needs \(enabled.sorted().joined(separator: ", "))."
                    )
                }
                guard let release = ProviderVersion(try text("release")),
                    let schema = ProviderVersion(try text("schema"))
                else {
                    throw Invalid(
                        reason: "Provider \(providerId) has a release or schema that is not major.minor.patch."
                    )
                }
                baseline = Baseline(
                    bundleName: try text("bundle"), release: release, schema: schema,
                    signingIdentifier: try text("signingIdentifier")
                )
            }
            entries.append(
                Entry(
                    providerId: providerId, graphQLPrefix: try text("graphQLPrefix"),
                    baseline: baseline
                )
            )
        }
        try self.init(entries: entries)
    }

    /// The catalogue at `url`, or why it cannot be used. An absent or unreadable
    /// file is as malformed as one that does not parse: nothing is invented from
    /// the bundles found instead.
    public static func load(from url: URL) -> Result<ProviderCatalogue, Invalid> {
        guard let data = try? Data(contentsOf: url) else {
            return .failure(Invalid(reason: "The catalogue \(url.lastPathComponent) cannot be read."))
        }
        do { return .success(try ProviderCatalogue(json: data)) } catch {
            return .failure(error as? Invalid ?? Invalid(reason: "The catalogue is malformed."))
        }
    }

    public func entry(for providerId: String) -> Entry? {
        entries.first { $0.providerId == providerId }
    }

    // MARK: Names

    private static func check(_ entry: Entry) throws {
        let id = entry.providerId
        guard let first = id.utf8.first, (0x61...0x7A).contains(first),
            id.utf8.allSatisfy({ (0x61...0x7A).contains($0) || (0x30...0x39).contains($0) })
        else {
            throw Invalid(reason: "\(id) is not a provider identifier: lower-case letters and digits.")
        }
        let prefix = entry.graphQLPrefix
        guard let head = prefix.utf8.first, (0x41...0x5A).contains(head),
            prefix.utf8.allSatisfy({
                (0x41...0x5A).contains($0) || (0x61...0x7A).contains($0) || (0x30...0x39).contains($0)
            })
        else {
            throw Invalid(reason: "\(prefix) is not a prefix: a capitalised GraphQL name.")
        }
        // The core's identifier prefix is the core's alone.
        if let claimed = overlap(names(entry), ["koine"]) {
            throw Invalid(reason: "\(id) claims \(claimed), which the core owns.")
        }
        if let baseline = entry.baseline {
            guard baseline.bundleName.hasSuffix(".\(ProviderLoader.bundleExtension)"),
                !baseline.bundleName.contains("/"), !baseline.bundleName.hasPrefix(".")
            else {
                throw Invalid(
                    reason: "\(id) designates \(baseline.bundleName), which is not a bundle name."
                )
            }
        }
    }

    /// The lower-case names an entry reserves: its identifier and its prefix.
    static func names(_ entry: Entry) -> [String] {
        [entry.providerId, entry.graphQLPrefix.lowercased()]
    }

    /// A name in `left` and one in `right` where either is a prefix of the other.
    static func overlap(_ left: [String], _ right: [String]) -> String? {
        for a in left {
            for b in right where a.hasPrefix(b) || b.hasPrefix(a) { return a.count <= b.count ? a : b }
        }
        return nil
    }
}
