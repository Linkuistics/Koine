import Foundation
import Testing

@testable import WorkspaceProviderLogic

/// The URL grammar, as a decision over bytes: the ASCII `URI` production of RFC 3986
/// section 3 restricted to http(s) with a nonempty host, valid escapes, no credentials,
/// whitespace, backslashes or control characters, and IDNA hosts as ASCII A-labels. Every
/// refused class has its own cases, and every positive is also shown to reach the native
/// layer as the very bytes that were validated.
@Suite struct WebURLTests {
    static let accepted: [String] = [
        "http://example.com", "https://example.com/", "https://example.com/path/to?x=1#top",
        // The scheme is case-insensitive; no byte of the submission is changed.
        "HTTPS://EXAMPLE.COM/Path", "Http://example.com",
        // A search URL, with encoded query and fragment text.
        "https://www.google.com/search?q=hello%20world%2Bmore&hl=en&q=%E2%9C%93+caf%C3%A9",
        "https://example.com/a%2Fb/%e2%9c%93?q=%3F%23%26#frag%20ment%3A",
        "https://example.com/?#", "https://example.com?", "https://example.com#", "https://example.com/#a/b?c=d",
        // Unreserved and sub-delimiter characters, ":" and "@" in path, query and fragment.
        "https://example.com/a;b,c!$&'()*+=:@~._-/x?y=1;2,3!$&'()*+=:@/?#z=:@/?",
        // Ports, including the empty one RFC 3986 admits.
        "http://localhost:8080/", "http://host:/", "https://example.com:443",
        // IP hosts.
        "http://127.0.0.1/", "http://127.0.0.1:3000/x", "http://[::1]/", "http://[::1]:8080/p?q#f",
        "http://[2001:db8::7]/", "http://[::ffff:192.0.2.1]/", "http://[v1.x]/", "http://[::1.2.3.0]/",
        "http://[0000:0:0:0:0:0:0:0001]/", "http://[::255.255.255.255]/",
        // Internationalized hosts arrive as ASCII IDNA labels.
        "https://xn--bcher-kva.example/", "https://xn--mnchen-3ya.de/search?q=m%C3%BCnchen",
        "https://xn--r8jz45g.xn--zckzah/", "https://XN--BCHER-KVA.EXAMPLE/",
        // A rooted name, underscores, one label, and "--" outside the third and fourth positions.
        "http://example.com./", "http://my_host.local/", "http://intranet/", "http://a--b.example/",
        "https://sub.domain.example.co.uk/a",
    ]

    static let refused: [(input: String, why: String)] = [
        ("", "must not be empty"),
        // Control characters, anywhere.
        ("https://example.com/\u{7}", "control character"), ("https://example.com/\n", "control character"),
        ("https://example.com/a\tb", "control character"), ("https://example.com/\u{0}", "control character"),
        ("https://example.com/\u{7F}", "control character"), ("https://exa\u{1}mple.com/", "control character"),
        // Whitespace, leading, trailing and inside.
        ("https://example.com/a b", "whitespace"), (" https://example.com", "whitespace"),
        ("https://example.com ", "whitespace"), ("https://example.com/?q=a b", "whitespace"),
        ("https://exa mple.com/", "whitespace"),
        // Backslashes, which a browser might read as slashes.
        ("https:\\\\example.com", "backslash"), ("https://example.com/a\\b", "backslash"),
        ("https://example.com\\@evil.example/", "backslash"),
        // Raw Unicode, in the path, query, fragment and host.
        ("https://example.com/café", "ASCII"), ("https://example.com/?q=✓", "ASCII"),
        ("https://example.com/#é", "ASCII"), ("https://bücher.example/", "ASCII"), ("https://例え.jp/", "ASCII"),
        ("https://example.com/\u{FF0F}", "ASCII"),
        // Credentials.
        ("https://user:pass@example.com/", "credentials"), ("https://user@example.com", "credentials"),
        ("https://@example.com/", "credentials"), ("https://example.com@evil.example/", "credentials"),
        // Other schemes.
        ("ftp://example.com/", "http or https"), ("file:///etc/passwd", "http or https"),
        ("javascript:alert(1)", "http or https"), ("mailto:a@example.com", "http or https"),
        ("zoommtg://zoom.us/join", "http or https"), ("data:text/html,x", "http or https"),
        ("httpx://example.com", "http or https"), ("ws://example.com", "http or https"),
        ("x-apple.systempreferences:com.apple.preference", "http or https"),
        // No scheme at all, or a scheme that is not one.
        ("example.com", "scheme"), ("//example.com/x", "scheme"), ("/path/only", "scheme"),
        ("www.google.com/search?q=x", "scheme"), ("1http://example.com", "valid scheme"),
        ("ht tp://example.com", "whitespace"), ("://example.com", "valid scheme"),
        // No host.
        ("https://", "nonempty host"), ("https:///path", "nonempty host"), ("https:example.com", "host"),
        ("http:/example.com", "host"), ("https://?q=1", "nonempty host"), ("https://#f", "nonempty host"),
        ("https://:80/", "nonempty host"), ("https://./", "empty"),
        // Percent escapes that are not.
        ("https://example.com/%", "percent escape"), ("https://example.com/%G1", "percent escape"),
        ("https://example.com/%1", "percent escape"), ("https://example.com/a%zz", "percent escape"),
        ("https://example.com/?q=%", "percent escape"), ("https://example.com/?q=%4", "percent escape"),
        ("https://example.com/#%4", "percent escape"), ("https://example.com/#%", "percent escape"),
        ("https://example.com/%%41", "percent escape"),
        // Characters RFC 3986 does not allow in a component.
        ("https://example.com/a\"b", "RFC 3986"), ("https://example.com/<x>", "RFC 3986"),
        ("https://example.com/?a[]=1", "RFC 3986"), ("https://example.com/{x}", "RFC 3986"),
        ("https://example.com/a|b", "RFC 3986"), ("https://example.com/a^b", "RFC 3986"),
        ("https://example.com/`", "RFC 3986"), ("https://example.com/#a#b", "RFC 3986"),
        // Hosts that are not ASCII IDNA hosts.
        ("https://exa%6Dple.com/", "percent escapes"), ("https://%E4%BE%8B%E3%81%88.jp/", "percent escapes"),
        ("https://example..com/", "label"), ("https://.example.com/", "label"), ("https://-a.example/", "hyphen"),
        ("https://a-.example/", "hyphen"), ("https://exa$mple.com/", "character a host name cannot have"),
        ("https://exa,mple.com/", "character a host name cannot have"),
        ("https://exa'mple.com/", "character a host name cannot have"),
        ("https://\(String(repeating: "a", count: 64)).example/", "63"),
        ("https://\(String(repeating: "a.", count: 127))a/", "too long"),
        // IDNA violations: a malformed or ASCII-only A-label, "--" where only A-labels may have it.
        ("https://xn--/", "IDNA"), ("https://xn--.example/", "IDNA"), ("https://xn--abc-.example/", "IDNA"),
        ("https://xn--9/", "IDNA"), ("https://xn--bcher-kva-.example/", "IDNA"), ("https://ab--cd.example/", "IDNA"),
        ("https://xn--bcher-kv.example/", "IDNA"),
        // Ports.
        ("https://example.com:80a/", "port"), ("https://example.com:-1/", "port"), ("http://a:80:90/", "port"),
        ("http://a:%38%30/", "port"),
        // IP literals.
        ("http://[::1/", "unterminated"), ("http://[::1]x/", "after its IP literal"), ("http://[1:2:3]/", "IPv6"),
        ("http://[::1%25en0]/", "IPv6"), ("http://[]/", "IPv6"), ("http://[v1]/", "IP literal"),
        ("http://[v.x]/", "IP literal"),
        // An IPv4 tail with leading zeros or out of range, and hex groups longer than four digits.
        ("http://[::1.02.3.4]/", "IPv6"), ("http://[::1.2.3.004]/", "IPv6"), ("http://[::1.2.3.00]/", "IPv6"),
        ("http://[::ffff:1.02.3.4]/", "IPv6"), ("http://[::256.1.1.1]/", "IPv6"), ("http://[::1.2.3.4:1]/", "IPv6"),
        ("http://[::00001]/", "IPv6"), ("http://[00000:0:0:0:0:0:0:1]/", "IPv6"),
        ("http://[::\(String(repeating: "0", count: 5000))1]/", "IPv6"),
        // An A-label that decodes to a control character.
        ("https://xn--a.example/", "IDNA"), ("http://[::1]:x/", "port"), ("http://::1/", "nonempty host"),
    ]

    @Test(arguments: accepted) func theGrammarAdmitsIt(_ input: String) throws {
        let url = try #require(try? WebURL.validated(input).get(), "refused: \(input)")
        #expect(url.text == input, "the bytes are the bytes submitted")
        // And the platform represents exactly those bytes, so nothing is repaired on submission.
        #expect(url.url?.absoluteString == input)
    }

    @Test func theSchemeIsRecordedCaseInsensitively() throws {
        #expect(try WebURL.validated("HTTPS://example.com").get().scheme == .https)
        #expect(try WebURL.validated("hTTp://example.com").get().scheme == .http)
    }

    @Test(arguments: refused) func theGrammarRefusesIt(_ input: String, _ why: String) throws {
        switch WebURL.validated(input) {
        case .success: Issue.record("admitted: \(input.debugDescription)")
        case .failure(let error):
            #expect(error.message.hasPrefix("url "), Comment(rawValue: error.message))
            #expect(error.message.contains(why), Comment(rawValue: "\(input.debugDescription): \(error.message)"))
        }
    }

    @Test func eachRefusedClassOfTheSpecIsCovered() {
        let covered = ["control character", "whitespace", "backslash", "ASCII", "credentials", "http or https", "IDNA", "percent escape"]
        for class_ in covered {
            #expect(Self.refused.contains { $0.why.contains(class_) }, "no refused case for \(class_)")
        }
    }

    // MARK: Punycode

    /// RFC 3492 section 7.1 and well-known IDNA labels, both directions.
    @Test(arguments: [
        ("bücher", "bcher-kva"), ("münchen", "mnchen-3ya"), ("例え", "r8jz45g"), ("テスト", "zckzah"),
        ("ليهمابتكلموشعربي؟", "egbpdaj6bu4bxfgehfvwxn"), ("他们为什么不说中文", "ihqwcrb4cv8a8dqg056pqjye"),
    ])
    func punycodeKnownVectors(_ unicode: String, _ encoded: String) throws {
        let scalars = Array(unicode.unicodeScalars)
        #expect(Punycode.encode(scalars) == encoded)
        #expect(Punycode.decode(encoded) == scalars)
    }

    @Test func punycodeRefusesWhatIsNotPunycode() {
        for bad in ["9", "!", "a-b-!", "ü", "zzzzzzzzzzzzzzzzzzzzzzzzzzzz"] {
            #expect(Punycode.decode(bad) == nil, "\(bad)")
        }
    }
}
