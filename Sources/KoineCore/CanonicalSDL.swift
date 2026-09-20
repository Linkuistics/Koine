import Crypto
import Foundation
import GraphQL

/// The canonical SDL text and digest defined by `docs/specs/machine.md`,
/// "Schema digest": every custom directive definition sorted by name, then every
/// named type sorted by name, each printed in the graphql-js `printSchema`
/// format with its description, joined by one blank line. Introspection types,
/// built-in scalars, built-in directives and the `schema` definition are
/// omitted; fields, arguments and enum values keep their declared order.
///
/// It lives here, and not inside `Engine`, because two callers must agree to the
/// byte: the served digest `Koine.schemaDigest` reports, and the conformance
/// check (`task conformance`) that prints the same text for a schema built from
/// an SDL file. A second printer would make its own disagreements with this one
/// look like schema drift.
enum CanonicalSDL {
    /// Order-independent by construction: definitions are sorted by name, so the
    /// text does not depend on the order contributions were composed in.
    static func text(of schema: GraphQLSchema) -> String {
        let builtInScalars: Set = ["String", "Int", "Float", "Boolean", "ID"]
        let builtInDirectives: Set = ["skip", "include", "deprecated", "specifiedBy", "oneOf"]
        let directives = schema.directives
            .filter { !builtInDirectives.contains($0.name) }
            .sorted { $0.name < $1.name }
            .map { printDirective(directive: $0) }
        let types = schema.typeMap.values
            .filter { !$0.name.hasPrefix("__") && !builtInScalars.contains($0.name) }
            .sorted { $0.name < $1.name }
            .map { printType(type: $0) }
        return (directives + types).joined(separator: "\n\n")
    }

    static func digest(of schema: GraphQLSchema) -> String {
        hex(SHA256.hash(data: Data(text(of: schema).utf8)))
    }
}

/// What the conformance check needs from this module without reaching a
/// GraphQL-library type: KoineCore's public interface never carries one
/// (README, "Dependencies"), so a caller hands over SDL text and gets text back.
public enum CanonicalSchemaText {
    /// The canonical text of the schema `sdl` defines. `sdl` must be a complete
    /// schema document, root operation types included.
    public static func canonicalText(ofSDL sdl: String) throws -> String {
        CanonicalSDL.text(of: try buildSchema(source: sdl))
    }

    /// The digest of that canonical text — the value `Koine.schemaDigest` serves
    /// for the same schema, computed by the same code.
    public static func digest(ofSDL sdl: String) throws -> String {
        CanonicalSDL.digest(of: try buildSchema(source: sdl))
    }

    /// The digest of an already-canonical text, for a caller that printed it.
    public static func digest(ofCanonicalText text: String) -> String {
        hex(SHA256.hash(data: Data(text.utf8)))
    }
}
