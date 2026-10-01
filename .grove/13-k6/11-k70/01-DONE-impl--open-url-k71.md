# open-url-k71

## Goal

Serve `workspaceOpenURL` complete to its design, verified at L, G and N.

## Context

- `docs/specs/workspace-launch-and-open.md`: the URL paragraphs, "Results and
  failure boundary" and the Browser URL and Input boundary rows.
- RFC 3986 section 3: the `URI` production, including its optional fragment.

## Done when

- Input validation accepts exactly the spec's ASCII grammar:
  - an `http` or `https` scheme and a nonempty host;
  - valid percent escapes;
  - no credentials, whitespace, backslashes or control characters.
  Other schemes, raw Unicode and IDNA violations are input errors at the
  original path. Nothing is trimmed, repaired or re-encoded. Valid path, query
  and fragment bytes are preserved.
- The default handler is resolved by scheme alone, never by passing the
  submitted URL to universal-link-aware discovery. The URL is submitted
  explicitly to that application, with the same activation, no-new-instance,
  prompt and one-shot acknowledgment bounds as launch.
- A missing handler is `NO_DEFAULT_HANDLER`. Default changes after resolution do
  not retarget or replay.
- L: with the adapter substituted, cover the absent handler, false or late
  acknowledgment, cancellation and capacity exhaustion.
- G: composition tests cover the URL field's authority, branches and
  multi-action behavior. Grammar positives and negatives include encoded query
  and fragment, IDNA labels, and each refused class.
- N: the real bundle serves the widened contribution. No browser is driven on
  the host.
- The served contribution adds the URL root verbatim from the design file.

## Decisions (running log)

- **Handler lookup by a scheme-only URL.** `NSWorkspace.urlForApplication(toOpen:)` is given
  `http:` or `https:` (the scheme, nothing else), never a part of the submitted URL. Read
  on this host: `https:`, `https://`, a maps.apple.com URL and example.com all answer the same
  default browser, so the scheme-only form loses nothing. The submission is
  `NSWorkspace.open(_:withApplicationAt:configuration:completionHandler:)` to that app, with the
  launch's ten configuration settings (one shared `openConfiguration` helper), so a universal-link
  candidate cannot be routed to a native app. Both signatures confirmed against the SDK's
  NSWorkspace.h and Apple's published documentation.
- **Grammar.** RFC 3986 section 3 over the submitted bytes, http/https case-insensitively, `//`
  authority with a nonempty host, no `@` in the authority, ports as `*DIGIT` with no range (the
  grammar sets none), path/query/fragment as pchar (`[`, `]`, `"`, `<`, `>`, `{`, `}`, `|`, `^` and
  a backtick are refused: RFC 3986 does not allow them). Percent escapes need two hex digits;
  decoded octets are not required to be UTF-8, since query values may be binary.
- **Host.** The host must be an IP literal (IPv6 via `inet_pton` after a character check, since
  Darwin's `inet_pton` accepted `::1%25en0`; IPvFuture by its production) or a DNS name: labels of
  letters, digits, hyphens and underscores (underscore tolerated, as browsers do), 1-63 long, no
  leading or trailing hyphen, at most 253 with an optional trailing dot. A percent escape in the
  host is refused: an internationalized host must arrive as ASCII A-labels. An IDNA violation is
  an `xn--` label that is not Punycode, decodes to ASCII only, or does not re-encode to its own
  letters (RFC 3492, written here and tested against its published vectors), and `--` in the
  third and fourth positions of any other label. **Not checked:** whether the decoded code points
  are valid in an IDNA 2008 label (the tables); the browser owns that.
- **Nothing is repaired, including by Foundation.** `WebURL.url` is `URL(string:)` only when its
  `absoluteString` equals the submitted text, else the open is `failed` before any lookup (nothing
  submitted). Every grammar positive is tested to round-trip, so the guard is a safeguard, not a
  case that occurs for valid input.
- **Handler presence** is checked as launch's is: the registered handler's bundle is inspected by
  the prompt-free metadata route; a stale registration is `NO_DEFAULT_HANDLER`, unreadable
  metadata is `failed`. The handler's identifier is neither read nor reported.
- **Substitution** is enabled for the URL open (no path constraint exists on this root), the same
  as launch and named-app opening without `applicationPath`.
- **One bound on outstanding submissions** is shared by launches and URL opens: the limit is the
  provider's, not an operation's.
- **In-session review (the leaf's one allowance), on the grammar.** A fresh context ran a
  2M-input differential against an independent regex of the contract, and compared Punycode
  with Python's codec. Valid findings, fixed with tests: Darwin's `inet_pton` accepts an IPv4
  tail with leading zeros (`[::1.02.3.4]`) and hex groups over four digits (`[::00001]`, and
  unboundedly long ones), so the IPv6 literal is now group-checked (`h16` is at most four hex
  digits, `dec-octet` has no leading zero and is at most 255) before `inet_pton` decides the
  colon structure. Taken from its observations: an A-label decoding to a control character
  (`xn--a`, U+0080) is refused. Accepted as a visible trade-off: an upper-case code point
  in a lower-cased payload, and IDNA 2008 code-point validity generally, are the browser's.
  Nothing else could be broken: no crash, no credential or host confusion, every accepted
  input round-trips through `URL(string:)`.
- **A flaky existing test, not this leaf's:** `WorkspaceCompositionTests.denialInsideADependency
  WithholdsItsNonNullFieldAndSoTheDependency` fails intermittently in a full run (about two in
  five here) and passes alone; it asserts which of two concurrently resolved sibling fields is
  reported after a revocation. A run at the parent revision to attribute it could not load the
  test frameworks, so it is unattributed. Filed as its own leaf.
