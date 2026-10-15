import Darwin
import Foundation

/// One `workspaceOpenURL` argument, validated: the ASCII `URI` grammar of
/// RFC 3986 section 3 restricted to an `http` or `https` URL with a nonempty
/// host (docs/specs/workspace-launch-and-open.md, "URL opening").
///
/// Validation is a decision over the submitted bytes and nothing else. It never
/// trims, repairs, normalizes or percent-encodes: a URL either is exactly what
/// the grammar admits or is an input error, and what is submitted is the same
/// bytes. https://www.rfc-editor.org/rfc/rfc3986#section-3 (the productions
/// named in the comments below are that section's, and 3.2.2 for the host).
struct WebURL: Equatable, Sendable {
    enum Scheme: String, Sendable {
        case http, https
    }

    /// The submitted text, byte for byte.
    let text: String
    let scheme: Scheme

    static func validated(_ text: String) -> Result<WebURL, InputError> {
        switch Parser(bytes: Array(text.utf8)).parse() {
        case .success(let scheme): return .success(WebURL(text: text, scheme: scheme))
        case .failure(let error): return .failure(error)
        }
    }

    /// The URL object the native layer is handed, if Foundation represents these bytes
    /// unchanged. A submission is never "close enough": if the platform's own parser
    /// would normalize or re-encode any byte, there is no URL to submit.
    var url: URL? {
        guard let url = URL(string: text), url.absoluteString == text else { return nil }
        return url
    }
}

// MARK: Grammar

private struct Parser {
    let bytes: [UInt8]

    private static func fail(_ message: String) -> Result<WebURL.Scheme, InputError> {
        .failure(InputError("url \(message)."))
    }

    func parse() -> Result<WebURL.Scheme, InputError> {
        if bytes.isEmpty { return Self.fail("must not be empty") }
        // Raw characters first, so the message names the class a client got wrong. Each is
        // refused wherever it appears, including inside an otherwise valid component.
        for byte in bytes {
            switch byte {
            case 0x00...0x1F, 0x7F: return Self.fail("must not contain a control character")
            case 0x20: return Self.fail("must not contain whitespace")
            case 0x5C: return Self.fail("must not contain a backslash")
            case 0x80...0xFF:
                return Self.fail(
                    "must be ASCII: percent-encode UTF-8 path and query text, and give the host as ASCII IDNA labels")
            default: break
            }
        }

        // scheme = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." ), then ":"
        guard let colon = bytes.firstIndex(of: 0x3A) else { return Self.fail("must be an absolute URL with a scheme") }
        let schemeBytes = bytes[..<colon]
        guard let first = schemeBytes.first, Self.isAlpha(first),
            schemeBytes.allSatisfy({ Self.isAlpha($0) || Self.isDigit($0) || $0 == 0x2B || $0 == 0x2D || $0 == 0x2E })
        else { return Self.fail("must start with a valid scheme") }
        // Scheme names are case-insensitive (RFC 3986 section 3.1); the bytes stay as given.
        let name = String(decoding: schemeBytes, as: UTF8.self).lowercased()
        guard let scheme = WebURL.Scheme(rawValue: name) else {
            return Self.fail("must use the http or https scheme")
        }

        // hier-part = "//" authority path-abempty. Without the authority there is no host.
        let rest = bytes[(colon + 1)...]
        guard rest.starts(with: [0x2F, 0x2F]) else { return Self.fail("must have a host after \"\(name)://\"") }
        let afterSlashes = rest.dropFirst(2)
        let authorityEnd = afterSlashes.firstIndex { $0 == 0x2F || $0 == 0x3F || $0 == 0x23 } ?? afterSlashes.endIndex
        let authority = afterSlashes[..<authorityEnd]
        if let failure = checkAuthority(authority) { return .failure(failure) }

        // path-abempty = *( "/" segment ), then [ "?" query ] [ "#" fragment ]
        var cursor = authorityEnd
        var pathEnd = cursor
        while pathEnd < bytes.endIndex, bytes[pathEnd] != 0x3F, bytes[pathEnd] != 0x23 { pathEnd += 1 }
        if let failure = checkComponent(bytes[cursor..<pathEnd], allowing: [0x2F], named: "path") {
            return .failure(failure)
        }
        cursor = pathEnd
        if cursor < bytes.endIndex, bytes[cursor] == 0x3F {
            var queryEnd = cursor + 1
            while queryEnd < bytes.endIndex, bytes[queryEnd] != 0x23 { queryEnd += 1 }
            if let failure = checkComponent(
                bytes[(cursor + 1)..<queryEnd], allowing: [0x2F, 0x3F], named: "query")
            {
                return .failure(failure)
            }
            cursor = queryEnd
        }
        if cursor < bytes.endIndex {  // bytes[cursor] is "#": the first one begins the fragment
            if let failure = checkComponent(
                bytes[(cursor + 1)...], allowing: [0x2F, 0x3F], named: "fragment")
            {
                return .failure(failure)
            }
        }
        return .success(scheme)
    }

    // MARK: Authority

    /// authority = [ userinfo "@" ] host [ ":" port ]. Credentials are refused outright:
    /// an "@" in the authority is userinfo, however short.
    private func checkAuthority(_ authority: ArraySlice<UInt8>) -> InputError? {
        if authority.contains(0x40) { return InputError("url must not contain credentials.") }
        if authority.isEmpty { return InputError("url must have a nonempty host.") }

        let host: ArraySlice<UInt8>
        var port: ArraySlice<UInt8>?
        if authority.first == 0x5B {  // IP-literal = "[" ( IPv6address / IPvFuture ) "]"
            guard let close = authority.firstIndex(of: 0x5D) else {
                return InputError("url has an unterminated IP literal host.")
            }
            host = authority[authority.startIndex...close]
            let after = authority[(close + 1)...]
            if !after.isEmpty {
                guard after.first == 0x3A else { return InputError("url has unexpected text after its IP literal host.") }
                port = after.dropFirst()
            }
        } else if let colon = authority.firstIndex(of: 0x3A) {
            host = authority[..<colon]
            port = authority[(colon + 1)...]
        } else {
            host = authority
        }
        if let failure = host.first == 0x5B ? checkIPLiteral(host) : checkDNSHost(host) { return failure }
        // port = *DIGIT. RFC 3986 admits an empty port and sets no range.
        if let port, !port.allSatisfy(Self.isDigit) { return InputError("url has a port that is not digits.") }
        return nil
    }

    private func checkIPLiteral(_ literal: ArraySlice<UInt8>) -> InputError? {
        let inner = Array(literal.dropFirst().dropLast())
        // IPvFuture = "v" 1*HEXDIG "." 1*( unreserved / sub-delims / ":" )
        if inner.first == 0x76 || inner.first == 0x56 {
            let tail = inner.dropFirst()
            guard let dot = tail.firstIndex(of: 0x2E), dot > tail.startIndex,
                tail[..<dot].allSatisfy(Self.isHex), dot + 1 < inner.endIndex,
                inner[(dot + 1)...].allSatisfy({ Self.isUnreserved($0) || Self.isSubDelim($0) || $0 == 0x3A })
            else { return InputError("url has an invalid IP literal host.") }
            return nil
        }
        var address = in6_addr()
        let text = String(decoding: inner, as: UTF8.self)
        // inet_pton alone is too forgiving to be the grammar: Darwin's answers text after a "%",
        // hex groups longer than RFC 3986's `h16` (1*4HEXDIG) and leading zeros in a `dec-octet`.
        // Those are checked here; inet_pton then decides the colon structure.
        guard !inner.isEmpty, inner.allSatisfy({ Self.isHex($0) || $0 == 0x3A || $0 == 0x2E }),
            Self.groupsFit(inner), inet_pton(AF_INET6, text, &address) == 1
        else {
            return InputError("url has an invalid IPv6 literal host.")
        }
        return nil
    }

    /// Each colon-separated group is at most four hex digits, except a last one that holds
    /// an IPv4 tail: four dot-separated `dec-octet`s, 0-255 with no leading zero.
    private static func groupsFit(_ inner: [UInt8]) -> Bool {
        let groups = inner.split(separator: 0x3A, omittingEmptySubsequences: false)
        for (index, group) in groups.enumerated() {
            guard group.contains(0x2E) else {
                if group.count > 4 { return false }
                continue
            }
            let octets = group.split(separator: 0x2E, omittingEmptySubsequences: false)
            guard index == groups.count - 1, octets.count == 4 else { return false }
            for octet in octets {
                guard (1...3).contains(octet.count), octet.allSatisfy(isDigit), octet.count == 1 || octet.first != 0x30,
                    Int(String(decoding: octet, as: UTF8.self)).map({ $0 <= 255 }) == true
                else { return false }
            }
        }
        return true
    }

    /// The host as a DNS name: dot-separated labels of letters, digits, hyphens and
    /// underscores, internationalized names as ASCII A-labels. A host written with
    /// percent escapes or any other character is not an ASCII IDNA host, however
    /// RFC 3986's `reg-name` might read it.
    private func checkDNSHost(_ host: ArraySlice<UInt8>) -> InputError? {
        var name = Array(host)
        if name.isEmpty { return InputError("url must have a nonempty host.") }
        if name.last == 0x2E { name.removeLast() }  // a rooted name: "example.com."
        if name.isEmpty || name.count > 253 { return InputError("url has a host that is empty or too long.") }
        if name.contains(0x25) {
            return InputError("url must give its host as ASCII IDNA labels, not percent escapes.")
        }
        for label in name.split(separator: 0x2E, omittingEmptySubsequences: false) {
            if let failure = checkLabel(label) { return failure }
        }
        return nil
    }

    private func checkLabel(_ label: ArraySlice<UInt8>) -> InputError? {
        let text = String(decoding: label, as: UTF8.self)
        guard !label.isEmpty, label.count <= 63 else {
            return InputError("url has a host label that is empty or longer than 63 characters.")
        }
        guard label.allSatisfy({ Self.isAlpha($0) || Self.isDigit($0) || $0 == 0x2D || $0 == 0x5F }) else {
            return InputError("url has a host label with a character a host name cannot have: \(text).")
        }
        let lowered = text.lowercased()
        if !lowered.hasPrefix("xn--"), label.first == 0x2D || label.last == 0x2D {
            return InputError("url has a host label that starts or ends with a hyphen: \(text).")
        }
        if lowered.hasPrefix("xn--") {
            // An A-label is Punycode that decodes to something with a non-ASCII character and
            // encodes back to the very same letters (RFC 5891 sections 4.2 and 5.4).
            let payload = String(lowered.dropFirst(4))
            guard let decoded = Punycode.decode(payload), decoded.contains(where: { !$0.isASCII }),
                !decoded.contains(where: { $0.properties.generalCategory == .control }),
                Punycode.encode(decoded) == payload
            else { return InputError("url has an invalid IDNA label: \(text).") }
            return nil
        }
        // "--" in the third and fourth positions is reserved for A-labels (RFC 5891 section 4.2.3.1).
        if label.count >= 4, lowered.dropFirst(2).hasPrefix("--") {
            return InputError("url has an invalid IDNA label: \(text).")
        }
        return nil
    }

    // MARK: Components

    /// *( pchar / extra ) with the characters `extra` adds; pchar = unreserved / pct-encoded /
    /// sub-delims / ":" / "@". Anything else, a stray "%" or a second "#" included, is invalid.
    private func checkComponent(_ component: ArraySlice<UInt8>, allowing extra: Set<UInt8>, named name: String)
        -> InputError?
    {
        var index = component.startIndex
        while index < component.endIndex {
            let byte = component[index]
            if byte == 0x25 {
                guard index + 2 < component.endIndex, Self.isHex(component[index + 1]), Self.isHex(component[index + 2])
                else { return InputError("url has an invalid percent escape in its \(name).") }
                index += 3
                continue
            }
            guard Self.isUnreserved(byte) || Self.isSubDelim(byte) || byte == 0x3A || byte == 0x40 || extra.contains(byte)
            else { return InputError("url has a character in its \(name) that RFC 3986 does not allow.") }
            index += 1
        }
        return nil
    }

    // MARK: Character classes

    static func isAlpha(_ byte: UInt8) -> Bool { (0x41...0x5A).contains(byte) || (0x61...0x7A).contains(byte) }
    static func isDigit(_ byte: UInt8) -> Bool { (0x30...0x39).contains(byte) }
    static func isHex(_ byte: UInt8) -> Bool {
        isDigit(byte) || (0x41...0x46).contains(byte) || (0x61...0x66).contains(byte)
    }
    static func isUnreserved(_ byte: UInt8) -> Bool {
        isAlpha(byte) || isDigit(byte) || byte == 0x2D || byte == 0x2E || byte == 0x5F || byte == 0x7E
    }
    static func isSubDelim(_ byte: UInt8) -> Bool { "!$&'()*+,;=".utf8.contains(byte) }
}

// MARK: Punycode

/// RFC 3492, for checking an IDNA A-label's form. It decides whether a label is
/// well-formed Punycode; whether its code points are valid in an IDNA 2008 label
/// is left to the browser that receives the host.
/// https://www.rfc-editor.org/rfc/rfc3492#section-6
enum Punycode {
    private static let base = 36, tMin = 1, tMax = 26, skew = 38, damp = 700, initialBias = 72, initialN = 128

    private static func adapt(_ delta: Int, _ points: Int, first: Bool) -> Int {
        var delta = first ? delta / damp : delta / 2
        delta += delta / points
        var k = 0
        while delta > ((base - tMin) * tMax) / 2 {
            delta /= base - tMin
            k += base
        }
        return k + (base - tMin + 1) * delta / (delta + skew)
    }

    private static func threshold(_ k: Int, _ bias: Int) -> Int {
        k <= bias + tMin ? tMin : (k >= bias + tMax ? tMax : k - bias)
    }

    /// The code points `payload` (the text after "xn--") encodes, or nil if it is not Punycode.
    static func decode(_ payload: String) -> [Unicode.Scalar]? {
        var output: [UInt32] = []
        let input = Array(payload.utf8)
        var position = 0
        if let delimiter = input.lastIndex(of: 0x2D) {
            for byte in input[..<delimiter] {
                guard byte < 0x80 else { return nil }
                output.append(UInt32(byte))
            }
            position = delimiter + 1
        }
        var n = initialN, bias = initialBias, i = 0
        while position < input.count {
            let previous = i
            var w = 1, k = base
            while true {
                guard position < input.count, let digit = digitValue(input[position]) else { return nil }
                position += 1
                let (product, overflow) = digit.multipliedReportingOverflow(by: w)
                guard !overflow, i <= Int.max - product else { return nil }
                i += product
                let t = threshold(k, bias)
                if digit < t { break }
                let (next, wOverflow) = w.multipliedReportingOverflow(by: base - t)
                guard !wOverflow else { return nil }
                w = next
                k += base
            }
            bias = adapt(i - previous, output.count + 1, first: previous == 0)
            let (carry, remainder) = i.quotientAndRemainder(dividingBy: output.count + 1)
            guard n <= Int(Int32.max) - carry else { return nil }
            n += carry
            i = remainder
            guard let scalar = Unicode.Scalar(UInt32(n)) else { return nil }
            output.insert(scalar.value, at: i)
            i += 1
        }
        return output.compactMap(Unicode.Scalar.init)
    }

    /// The Punycode (lower case) for `code points`.
    static func encode(_ codePoints: [Unicode.Scalar]) -> String? {
        let scalars = codePoints.map(\.value)
        var output = scalars.filter { $0 < 0x80 }.map { UInt8($0) }
        let basic = output.count
        var handled = basic
        if basic > 0 { output.append(0x2D) }
        var n = initialN, delta = 0, bias = initialBias
        while handled < scalars.count {
            guard let m = scalars.filter({ Int($0) >= n }).min() else { return nil }
            let (product, overflow) = (Int(m) - n).multipliedReportingOverflow(by: handled + 1)
            guard !overflow, delta <= Int.max - product else { return nil }
            delta += product
            n = Int(m)
            for scalar in scalars {
                if Int(scalar) < n { delta += 1 }
                if Int(scalar) == n {
                    var q = delta, k = base
                    while true {
                        let t = threshold(k, bias)
                        if q < t { break }
                        output.append(digitByte(t + (q - t) % (base - t)))
                        q = (q - t) / (base - t)
                        k += base
                    }
                    output.append(digitByte(q))
                    bias = adapt(delta, handled + 1, first: handled == basic)
                    delta = 0
                    handled += 1
                }
            }
            delta += 1
            n += 1
        }
        return String(decoding: output, as: UTF8.self)
    }

    private static func digitValue(_ byte: UInt8) -> Int? {
        switch byte {
        case 0x30...0x39: return Int(byte) - 0x30 + 26
        case 0x41...0x5A: return Int(byte) - 0x41
        case 0x61...0x7A: return Int(byte) - 0x61
        default: return nil
        }
    }

    private static func digitByte(_ digit: Int) -> UInt8 {
        digit < 26 ? UInt8(0x61 + digit) : UInt8(0x30 + digit - 26)
    }
}
