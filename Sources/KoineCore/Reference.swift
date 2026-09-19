import GraphQL

/// The envelope of a resource reference, `koine://<provider>/<remainder>`
/// (docs/adr/machine-references-as-uris.md). The engine validates the envelope
/// and reads only the provider; the remainder is the provider's alone.
struct ReferenceEnvelope {
    static let scheme = "koine://"

    let provider: String

    /// Nil when `text` is not a canonical reference: another scheme or letter
    /// case, an authority that is not a bare provider identifier (so no
    /// userinfo, port or host syntax), no `/` after it, a fragment, or a
    /// remainder that is not URI path-and-query text.
    init?(_ text: String) {
        guard text.hasPrefix(Self.scheme) else { return nil }
        let rest = text.utf8.dropFirst(Self.scheme.utf8.count)
        guard let slash = rest.firstIndex(of: UInt8(ascii: "/")) else { return nil }
        let provider = String(Substring(rest[..<slash]))
        guard isProviderIdentifier(provider) else { return nil }
        guard Self.isPathAndQuery(Array(rest[rest.index(after: slash)...])) else { return nil }
        self.provider = provider
    }

    /// RFC 3986 `pchar`, `/` and `?`, with every `%` followed by two hex digits.
    /// https://www.rfc-editor.org/rfc/rfc3986#section-3.3
    private static func isPathAndQuery(_ bytes: [UInt8]) -> Bool {
        let allowed = Set("-._~!$&'()*+,;=:@/?".utf8)
        var index = 0
        while index < bytes.count {
            let byte = bytes[index]
            if byte == UInt8(ascii: "%") {
                guard index + 2 < bytes.count, isHex(bytes[index + 1]), isHex(bytes[index + 2])
                else { return false }
                index += 3
                continue
            }
            guard isAlphanumeric(byte) || allowed.contains(byte) else { return false }
            index += 1
        }
        return true
    }

    private static func isHex(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
            || (UInt8(ascii: "a")...UInt8(ascii: "f")).contains(byte)
            || (UInt8(ascii: "A")...UInt8(ascii: "F")).contains(byte)
    }

    private static func isAlphanumeric(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
            || (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(byte)
            || (UInt8(ascii: "A")...UInt8(ascii: "Z")).contains(byte)
    }
}

/// A provider identifier: a lower-case letter, then lower-case letters and
/// digits. It is a URI authority and the prefix of the provider's capabilities.
func isProviderIdentifier(_ text: String) -> Bool {
    guard let first = text.utf8.first, (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(first)
    else { return false }
    return text.utf8.allSatisfy {
        (UInt8(ascii: "a")...UInt8(ascii: "z")).contains($0)
            || (UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0)
    }
}

let referenceScalarName = "Reference"

/// The shared `Reference` scalar. The library fixes a scalar's coercion when the
/// type is constructed, so the core's SDL extends a schema that already holds it.
func makeReferenceScalar() throws -> GraphQLScalarType {
    let malformed = "A Reference is a koine://<provider>/<remainder> URI with no userinfo, port or fragment."
    return try GraphQLScalarType(
        name: referenceScalarName,
        // The design SDL's text, docs/design/desktop-schema.graphql.
        description: "Opaque koine:// URI string. Pass it unchanged; only its provider interprets the remainder.",
        serialize: { value in
            guard let text = value as? String, ReferenceEnvelope(text) != nil else {
                throw GraphQLError(message: malformed)
            }
            return .string(text)
        },
        parseValue: { value in
            guard case .string(let text) = value, ReferenceEnvelope(text) != nil else {
                throw GraphQLError(message: malformed)
            }
            return value
        },
        parseLiteral: { literal in
            guard let text = (literal as? StringValue)?.value, ReferenceEnvelope(text) != nil else {
                throw GraphQLError(message: malformed)
            }
            return .string(text)
        }
    )
}
