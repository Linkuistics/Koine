import Foundation

/// The introspection result of a running Koine, turned back into SDL text.
///
/// Nothing here decides what the canonical text is: this reconstructs the SDL a
/// schema document would have had, and `KoineCore.CanonicalSchemaText` then
/// prints it through the server's own printer. The reconstruction is checked
/// rather than trusted — the caller compares the digest of the printed text with
/// the digest the server served, and a difference means this file lost
/// something, not that the schema drifted.
public enum IntrospectionSDL {
    public struct Failure: Error, CustomStringConvertible {
        public let description: String
    }

    public static func sdl(fromIntrospectionResponse data: Data) throws -> String {
        let root = try JSONSerialization.jsonObject(with: data)
        guard let object = root as? [String: Any] else {
            throw Failure(description: "The introspection response is not a JSON object.")
        }
        if let errors = object["errors"] as? [[String: Any]], !errors.isEmpty {
            let messages = errors.compactMap { $0["message"] as? String }.joined(separator: "; ")
            throw Failure(description: "The introspection request returned errors: \(messages)")
        }
        guard
            let payload = object["data"] as? [String: Any],
            let schema = payload["__schema"] as? [String: Any]
        else {
            throw Failure(description: "The introspection response carries no data.__schema.")
        }
        return try render(schema: schema)
    }

    // MARK: Rendering

    private static let builtInScalars: Set<String> = ["String", "Int", "Float", "Boolean", "ID"]
    private static let builtInDirectives: Set<String> = [
        "skip", "include", "deprecated", "specifiedBy", "oneOf",
    ]

    private static func render(schema: [String: Any]) throws -> String {
        var blocks: [String] = []

        // The schema definition. It is not part of the canonical text, but
        // buildSchema needs the root operation types to name the same types the
        // server's own document named.
        var roots: [String] = []
        for (keyword, key) in [
            ("query", "queryType"), ("mutation", "mutationType"),
            ("subscription", "subscriptionType"),
        ] {
            if let root = schema[key] as? [String: Any], let name = root["name"] as? String {
                roots.append("  \(keyword): \(name)")
            }
        }
        guard !roots.isEmpty else {
            throw Failure(description: "The introspected schema declares no root operation type.")
        }
        blocks.append("schema {\n" + roots.joined(separator: "\n") + "\n}")

        for directive in (schema["directives"] as? [[String: Any]]) ?? [] {
            guard let name = directive["name"] as? String, !builtInDirectives.contains(name) else {
                continue
            }
            blocks.append(try renderDirective(directive, name: name))
        }
        for type in (schema["types"] as? [[String: Any]]) ?? [] {
            guard let name = type["name"] as? String else {
                throw Failure(description: "An introspected type has no name.")
            }
            if name.hasPrefix("__") || builtInScalars.contains(name) { continue }
            blocks.append(try renderType(type, name: name))
        }
        return blocks.joined(separator: "\n\n") + "\n"
    }

    private static func renderDirective(_ directive: [String: Any], name: String) throws -> String {
        let locations = (directive["locations"] as? [String]) ?? []
        guard !locations.isEmpty else {
            throw Failure(description: "Directive @\(name) is introspected with no locations.")
        }
        let repeatable = (directive["isRepeatable"] as? Bool) == true ? " repeatable" : ""
        return description(of: directive)
            + "directive @\(name)"
            + renderArguments((directive["args"] as? [[String: Any]]) ?? [], indent: "")
            + repeatable + " on " + locations.joined(separator: " | ")
    }

    private static func renderType(_ type: [String: Any], name: String) throws -> String {
        let head = description(of: type)
        switch type["kind"] as? String {
        case "SCALAR":
            let specifiedBy = (type["specifiedByURL"] as? String).map {
                " @specifiedBy(url: \(quoted($0)))"
            }
            return head + "scalar \(name)" + (specifiedBy ?? "")
        case "OBJECT", "INTERFACE":
            let keyword = (type["kind"] as? String) == "OBJECT" ? "type" : "interface"
            let interfaces = ((type["interfaces"] as? [[String: Any]]) ?? [])
                .compactMap { $0["name"] as? String }
            let implements =
                interfaces.isEmpty ? "" : " implements " + interfaces.joined(separator: " & ")
            return head + "\(keyword) \(name)" + implements
                + block(try ((type["fields"] as? [[String: Any]]) ?? []).map(renderField))
        case "UNION":
            let members = ((type["possibleTypes"] as? [[String: Any]]) ?? [])
                .compactMap { $0["name"] as? String }
            return head + "union \(name)"
                + (members.isEmpty ? "" : " = " + members.joined(separator: " | "))
        case "ENUM":
            let values = ((type["enumValues"] as? [[String: Any]]) ?? []).map { value -> String in
                indented(description(of: value)) + "  " + ((value["name"] as? String) ?? "")
                    + deprecation(of: value)
            }
            return head + "enum \(name)" + block(values)
        case "INPUT_OBJECT":
            let oneOf = (type["isOneOf"] as? Bool) == true ? " @oneOf" : ""
            let fields = try ((type["inputFields"] as? [[String: Any]]) ?? []).map {
                indented(description(of: $0)) + "  " + (try renderInputValue($0))
            }
            return head + "input \(name)" + oneOf + block(fields)
        case let kind:
            throw Failure(description: "Type \(name) has unsupported kind \(kind ?? "(none)").")
        }
    }

    private static func renderField(_ field: [String: Any]) throws -> String {
        guard let name = field["name"] as? String else {
            throw Failure(description: "An introspected field has no name.")
        }
        return indented(description(of: field)) + "  " + name
            + renderArguments((field["args"] as? [[String: Any]]) ?? [], indent: "  ")
            + ": " + (try typeReference(field["type"])) + deprecation(of: field)
    }

    /// Arguments print on one line unless one carries a description — the rule
    /// the server's printer uses, reproduced so that a described argument is not
    /// reported as a difference in layout.
    private static func renderArguments(_ arguments: [[String: Any]], indent: String) -> String {
        guard !arguments.isEmpty else { return "" }
        let rendered = arguments.map { (try? renderInputValue($0)) ?? "" }
        if arguments.allSatisfy({ $0["description"] is NSNull || $0["description"] == nil }) {
            return "(" + rendered.joined(separator: ", ") + ")"
        }
        let lines = zip(arguments, rendered).map { argument, text in
            indented(description(of: argument), by: "  " + indent) + "  " + indent + text
        }
        return "(\n" + lines.joined(separator: "\n") + "\n" + indent + ")"
    }

    private static func renderInputValue(_ value: [String: Any]) throws -> String {
        guard let name = value["name"] as? String else {
            throw Failure(description: "An introspected input value has no name.")
        }
        // Introspection reports a default as the GraphQL literal it prints as,
        // so it is emitted verbatim rather than re-encoded from a Swift value.
        let defaulted = (value["defaultValue"] as? String).map { " = \($0)" } ?? ""
        return name + ": " + (try typeReference(value["type"])) + defaulted + deprecation(of: value)
    }

    private static func typeReference(_ type: Any?) throws -> String {
        guard let type = type as? [String: Any] else {
            throw Failure(description: "An introspected position has no type.")
        }
        switch type["kind"] as? String {
        case "NON_NULL": return (try typeReference(type["ofType"])) + "!"
        case "LIST": return "[" + (try typeReference(type["ofType"])) + "]"
        default:
            guard let name = type["name"] as? String else {
                throw Failure(description: "An introspected named type has no name.")
            }
            return name
        }
    }

    // MARK: Pieces

    private static func block(_ items: [String]) -> String {
        items.isEmpty ? "" : " {\n" + items.joined(separator: "\n") + "\n}"
    }

    private static func description(of node: [String: Any]) -> String {
        guard let text = node["description"] as? String else { return "" }
        return quoted(text) + "\n"
    }

    private static func indented(_ text: String, by indent: String = "  ") -> String {
        text.isEmpty ? "" : indent + text
    }

    private static func deprecation(of node: [String: Any]) -> String {
        guard (node["isDeprecated"] as? Bool) == true else { return "" }
        guard let reason = node["deprecationReason"] as? String else { return " @deprecated" }
        return reason == "No longer supported"
            ? " @deprecated" : " @deprecated(reason: \(quoted(reason)))"
    }

    /// A single-line GraphQL string literal. The server's printer decides
    /// afterwards whether the same text prints as a block string, so escaping
    /// here only has to survive the parser.
    private static func quoted(_ text: String) -> String {
        var out = "\""
        for character in text.unicodeScalars {
            switch character {
            case "\"": out += "\\\""
            case "\\": out += "\\\\"
            case "\n": out += "\\n"
            case "\r": out += "\\r"
            case "\t": out += "\\t"
            default:
                if character.value < 0x20 {
                    out += String(format: "\\u%04X", character.value)
                } else {
                    out.unicodeScalars.append(character)
                }
            }
        }
        return out + "\""
    }
}
