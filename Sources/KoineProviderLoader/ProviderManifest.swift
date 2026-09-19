import Foundation

/// A bundle's declarative manifest, `manifest.json`
/// (docs/specs/machine.md, "Native extensions"). Every field is required; the
/// loader reads nothing else about a bundle before it has decided to load it.
struct ProviderManifest: Decodable {
    struct Framework: Decodable {
        let major: Int
        let minimumMinor: Int
    }

    let providerId: String
    let graphQLPrefix: String
    /// The plugin's release version and its GraphQL schema version. Neither is
    /// an ABI version; both are reported as provider status.
    let version: String
    let schemaVersion: String
    /// The CPU architectures the binary holds, by their `arch` names.
    let architectures: [String]
    let minimumOS: String
    let minimumSwiftRuntime: String
    let framework: Framework
    let requiredFeatures: [String]
    /// The Objective-C-visible name of the bundle's `ProviderFactory` class.
    let principalClass: String
    /// The dylib's path within the bundle.
    let library: String

    struct Invalid: Error {
        let reason: String
    }

    init(bundle: URL) throws {
        let data: Data
        do { data = try Data(contentsOf: bundle.appendingPathComponent("manifest.json")) } catch {
            throw Invalid(reason: "The bundle has no readable manifest.json.")
        }
        do { self = try JSONDecoder().decode(ProviderManifest.self, from: data) } catch {
            throw Invalid(reason: "manifest.json is malformed: \(Self.describe(error))")
        }
        let texts = [
            ("providerId", providerId), ("graphQLPrefix", graphQLPrefix), ("version", version),
            ("schemaVersion", schemaVersion), ("principalClass", principalClass),
            ("library", library),
        ]
        for (name, value) in texts where value.isEmpty {
            throw Invalid(reason: "manifest.json is malformed: \(name) is empty.")
        }
        guard !architectures.isEmpty else {
            throw Invalid(reason: "manifest.json is malformed: architectures is empty.")
        }
        for (name, value) in [("minimumOS", minimumOS), ("minimumSwiftRuntime", minimumSwiftRuntime)]
        where MachOImage.Version(value) == nil {
            throw Invalid(reason: "manifest.json is malformed: \(name) is not a version.")
        }
        guard framework.major >= 1, framework.minimumMinor >= 0 else {
            throw Invalid(reason: "manifest.json is malformed: framework is not a version.")
        }
    }

    private static func describe(_ error: any Error) -> String {
        switch error {
        case DecodingError.keyNotFound(let key, _): "\(key.stringValue) is missing."
        case DecodingError.typeMismatch(_, let context), DecodingError.valueNotFound(_, let context):
            "\(context.codingPath.map(\.stringValue).joined(separator: ".")) has the wrong type."
        default: "it is not a JSON object."
        }
    }
}
