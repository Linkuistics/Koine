# URL opening and search: what a client written from the contract alone had to guess

The contract-only client (`clients/contract-only/`) was extended with two commands:
`open-url`, for `Mutation.workspaceOpenURL` (published as `OpenSearchURL`), and
`search`, the client-owned flow the documents describe around it. It was
regenerated against the introspection of the signed Koine.app serving core +
desktop + workspace (schema digest
`1815b52f078ff4a1c7ca08d284ccfd50c03422d47055c8b926500391a1569d19`, the workspace
part being the launch root and the URL root). This is the record of every place
that pass had to guess, infer, or could not settle from the documents it was
allowed to read. It follows
[launch-contract-client-findings.md](launch-contract-client-findings.md).

**Read:** `docs/client-guide.md` (the headings and a search for `url`/`search` across
the whole file; in full from "Generating a client" to the end, which includes
"Reading an answer", "Mutations", "Launching an application", "Opening a URL" and
"What version 1 does not do"), `docs/specs/workspace-launch-and-open.md` (whole),
`docs/specs/machine.md` (the headings; "Local transport and discovery", "Mutation
preflight and revocation" and "Errors and partial data" in full; a search for
`workspaceOpenURL`, `input error`, `search`, `suggest`),
`docs/design/workspace-operations.graphql`, `docs/design/workspace-schema.graphql`,
`docs/verification/launch-contract-client-findings.md`, and everything the task
named under `clients/contract-only/` (`src/cli.ts`, `src/adapter/launch.ts`,
`classification.ts`, `transport.ts`, `codegen.ts`, `build.mjs`, `package.json`,
`README.md`, `test/launch-stubs.mjs`, `test/run.mjs`, `test/stub-server.mjs`,
`capture/capture.json`, and `capture/introspection.json` only through a script that
listed the `Mutation` fields and their argument types). **Not read:** `Sources/`,
`Providers/`, `Tests/`, `Tools/`, `Fixtures/`, `scripts/`, `.grove/`, any other
`docs/verification/` file, `docs/design/profiles/`, `docs/adr/`,
`docs/design/desktop-operations.graphql`. Nothing was run against Koine, a VM or
the host desktop: every Koine answer in the tests is a stub transcribed from the
specs' own tables and every suggestion source is a local stand-in, so **no claim
below was checked against the real wire**.

One observation about the reading restriction itself. The workspace spec is an
allowed document, and its "Evidence so far" section is part of it. That section
names test classes and records behaviour the normative sections do not state (the
scheme is accepted "in any case", ports, IP literals, which IDNA labels pass, the
handler lookup's single parameter). It was read, since the file was whole, and none
of it was used to decide what the client does; where a finding below depends on a
fact that appears only there, it says so (F13).

Each finding has the question as it was met, where the documents were searched,
what the client does instead, and a proposal: either a repair in a named document,
with the sentence, or a decline for version 1 with the reason. The disposition
table at the end gives the recommendation for each. No document was changed by
this pass.

---

## F1. Which response path does an invalid URL's input error carry?

**Question.** Both the spec and the guide say an invalid URL is an input error with
no `kind`. The spec's outcome table says "at the **original response path**"; the
guide ("Opening a URL" item 1) says "at the **field's path**". The error could be at
`["workspaceOpenURL"]`, at the argument, `["workspaceOpenURL","url"]`, or at an
alias of either. Which path does a client look for, and does the depth change what
the client may say about whether anything happened?

**Looked.** `workspace-launch-and-open.md` outcome table ("Invalid input or refused
payload metadata | Existing input error at original response path, no `kind`; this
field does not act"); `client-guide.md` "Opening a URL" and "Reading an answer";
`machine.md` "Errors and partial data" ("the response keeps the original path and
the root field is null when its type allows"); the SDL descriptions. No document
gives an example path for an argument error.

**Did.** The client reads a kind-less error at any non-empty path as an
`input-error` (the existing rule) and reports every path at or below the root in
`resultErrorPaths`. The launch reading counted only an error at a path of length
one as "the action's own" (`actionEffect: none`); an input error one level deeper
at `["workspaceOpenURL","url"]` fell through to `actionEffect: unknown`, which
asserts less than the spec ("this field does not act"). The shared reading
(`src/adapter/workspace-open.ts`) now also treats a kind-less error at the root plus
an argument name (any second segment that is not `status`, `value` or `dependency`)
as the action's own refusal. Both paths are in the stub table
(`input-error`, `input-error-argument-path`) and both come out `input-error`,
`actionEffect: none`, `outcomeUnknown: false`. The real path was not observed. An
alias is not handled specially: the client sends no alias, so the root name is the
path's first segment.

**Proposal.** Repair in `workspace-launch-and-open.md` outcome table and in
`client-guide.md` "Opening a URL": "The path is the root field's response path (its
alias if one was used), for example `["workspaceOpenURL"]`; a provider reports an
argument it found invalid at the field, not below it." (Or, if the argument path is
what is served, say that instead and give the example.) One sentence, one example.

## F2. HTTP 200 or HTTP 400 for an invalid URL?

**Question.** `machine.md` has a table row "Malformed URI scalar or process identity
| GraphQL input coercion; no action", and says variable coercion is HTTP 400 with no
`data`. The URL argument is a `String!`, not a URI scalar (the captured schema's
`workspaceOpenURL(url: String!)`), and the paragraph above the table says only what
the scalars and non-null types reject is coercion. Does an invalid URL arrive as 400
or as 200 with an error?

**Looked.** `machine.md` "Local transport and discovery" and "Errors and partial
data" (both the table and the paragraph); SDL.

**Did.** The client reads both. HTTP 400 is `request-error` with nothing run (the
generic rule); HTTP 200 with a kind-less error at a non-empty path is `input-error`.
Only the 200 shape is tested, from the spec's "original response path". There is no
URI scalar in the captured schema (the only custom scalars are `Reference` and
`DesktopProcessStart`), so the table row does not describe this field; a reader has
to work that out.

**Proposal.** Repair in `machine.md` "Errors and partial data", table: say that
"Malformed URI scalar" has no instance in version 1's served schema, or delete the
row's "URI" and name the fields it does cover. Add to the guide's "Opening a URL":
"A URL the provider refuses is an HTTP 200 execution error, not an HTTP 400."

## F3. How does a client take a URL from a file, and does it strip the trailing newline?

**Question.** The documents say nothing about where a URL comes from: not a file,
not a pipe, not a command line. A command that takes the text from a file must
decide whether the file's final newline belongs to the URL, whether a byte order
mark does, and what to do with bytes that are not UTF-8.

**Looked.** Guide "Opening a URL" ("one string of ASCII", "Koine does not trim,
normalize or re-encode them"); spec ("Do not trim, repair, normalize or silently
percent-encode invalid input"; the grammar has no whitespace); SDL ("Preserve bytes
without repair"). All of these bind Koine. None says anything about a client's own
handling of its input, and whitespace is invalid in the grammar, so a trailing
newline makes the URL invalid whichever way it is read.

**Did.** `--url-file` sends exactly the file's bytes as UTF-8 text: a trailing LF or
CR LF, leading or trailing spaces and a byte order mark are all part of the string,
so a file written by `echo url > f` is sent with its newline and the provider is
left to refuse it (observable, and the point of the client). A file that is not
valid UTF-8 cannot be a GraphQL string and nothing may be repaired with U+FFFD, so
nothing is sent and the result is `classification: failed` with a `clientError`
(the existing shape for a client-side failure). A missing file is the same. The
decision is a guess because the contract is silent; the alternative (strip one
trailing newline) is friendlier but is the very "repair" the contract forbids Koine
to make and would hide the case a tester most needs to see.

**Proposal.** Repair, one sentence in `client-guide.md` "Opening a URL" item 1: "A
client that reads the URL from a file or a pipe sends the text it read: a trailing
newline is whitespace and makes the URL invalid, so a client strips only what its
own caller asked it to." Decline a rule about files themselves for version 1: file
input is a convenience of one client, not of the contract.

## F4. May a client check or tidy the URL before sending it?

**Question.** "The client builds the URL; Koine never repairs it" says who owns a
correct URL, not whether a client library may validate, trim, encode or normalise a
caller's text before it sends, or must send it as given so the provider's refusal is
what the caller sees.

**Looked.** Guide item 1; spec; the operations file header ("Encode Unicode URL data
and IDNA host labels before supplying an HTTP(S) URI").

**Did.** Nothing client-side: no check, trim, case change, scheme default,
encoding, IDNA conversion or `new URL()`. The text goes into the one variable
byte-for-byte, so raw Unicode, whitespace, backslashes, credentials, other schemes
and bad escapes are all sent and the provider's refusal is reported (rawUrls in the
tests: thirteen texts, each sent once and unchanged). This is the launch client's
rule (F3 there) applied again; it is a guess about intent, since "encode ... before
supplying" in the operations header reads as an instruction to a caller.

**Proposal.** Decline: client policy. A sentence in the guide would help ("a client
that exposes the operation to a human or a test sends the text unchanged so the
provider's refusal is visible; a client that builds URLs encodes before it calls").

## F5. The percent-encoding rule is not given

**Question.** "Percent-encode UTF-8 path and query text" does not say which bytes
are encoded, how a space is written, whether `+` stands for a space, which
characters of a query value must be encoded when the value sits after `q=`, whether
`%` itself is encoded, in what case the hex digits are written, or whether typed
text is Unicode-normalised first.

**Looked.** Guide item 1; spec ("Unicode paths/query text must arrive UTF-8
percent-encoded"; "valid percent escapes"); SDL. Only RFC 3986 section 3 is cited.
The words "valid percent escapes" say `%` plus two hex digits is valid; they do not
say what to encode.

**Did.** `search` encodes the query's UTF-8 bytes, every byte outside the RFC 3986
unreserved set (`A-Z a-z 0-9 - . _ ~`) as `%` and two **upper-case** hex digits; a
space is `%20`, never `+`; `%` becomes `%25` (so typed `100%` and typed `%41` stay
what was typed); `/ ? # & = : + ' ( ) * ! $ ;` and quotes and backslash are all
encoded; no normalisation (NFC vs NFD is the user's text). Over-encoding is always
inside the grammar (an escape is valid wherever its byte is), so the choice cannot
produce an invalid URL; the cost is only that some bytes are escaped that an engine
would accept raw. Verified in the tests against hand-written expectations for
`café 日本`, `&`, `#`, `%`, quotes, an emoji, a tab, and `$&` (which would corrupt a
naive `String.replace`).

**Proposal.** Repair in `client-guide.md` "Opening a URL" item 1: "To put typed
text into a query value, percent-encode each UTF-8 byte that is not an unreserved
character (`A-Z a-z 0-9 - . _ ~`) as `%` and two hex digits; a space is `%20`.
Example: `café 日本` becomes `caf%C3%A9%20%E6%97%A5%E6%9C%AC`." A worked example
would also settle upper- against lower-case hex, which the grammar allows either way.

## F6. The engine template, and the default engine, are not defined

**Question.** The documents say a "typed-query fallback" opens a typed query and that
Koine "does not contact Google", which implies Google, but give no engine URL and no
template syntax. How is the engine configured, and what is the default?

**Looked.** Spec ("Query entry, suggestions and typed-query fallback remain
client-owned; Koine does not construct searches or contact Google"; Acceptance "No
Koine Google request"); guide item 4. Nothing defines a template, a placeholder, or
an engine.

**Did.** The `%s` placeholder and the default
`https://www.google.com/search?q=%s` came from the brief for this pass, **not from
the documents**; they are recorded here because a reader of the documents alone
would have had to invent them. The client requires exactly one `%s` (a usage error,
nothing sent, otherwise), fills it by slicing (so `$` in anything is literal) and
does nothing else to the template: no IDNA conversion of its host and no encoding of
anything but the query. A template with a Unicode host or path is therefore refused
by the provider as an input error, which the client reports. The client never
fetches the template's URL, and a test points it at a live local listener and
asserts zero hits.

**Proposal.** Decline for version 1 (the engine is the client's choice by design),
with one repair in the spec's Browser URL acceptance row or the guide: "the engine
template is a client setting; Koine knows no engine and the default is whatever the
client ships". The guide should not leave a client author to wonder whether Google
is part of the contract.

## F7. The suggestion source has no definition at all

**Question.** The documents say suggestions are client-owned. They do not say where
they come from, how they are asked for (method, URL form, headers), what an answer
looks like, how long to wait, what counts as a failed answer, or how large an answer
to read. `suggestions proxy` is excluded by the SDL ("no ... suggestions proxy"),
which says what Koine does not do and nothing about what the client does.

**Looked.** Spec; guide item 4; SDL description of `workspaceOpenURL`; the operations
file header.

**Did.** Every part of this is the client's own decision, and the decisions are
guesses: a plain `GET` of the source URL with the query percent-encoded into its one
`%s` (the same rule as F5); no credential and no custom header; **2 seconds** for
the whole exchange including the body (the figure came from the brief; the
documents give none, and Koine's five-second ceiling is about Koine's own
resolvers); redirects refused, so the client contacts the source and nothing the
source points to; a body larger than 1 MiB is not read; `answered` means HTTP 2xx
and a body that is a JSON array whose second element is a list of strings (the
common `[query, [suggestion, ...]]` form), and every other outcome (refused, reset,
timeout, redirect, non-2xx, not JSON, JSON of another shape) is `failed` with a
`detail`. Nothing the source does is fatal and nothing it says changes the URL. In
the tests, a source that answers, one that answers HTML garbage, a closed port, one
that never answers, one that returns 503 and one that redirects each end in exactly
one `OpenSearchURL` carrying the identical typed-query URL.

**Proposal.** Decline a protocol for version 1: sources and their formats are the
client's. Repair in the spec's Browser URL acceptance row, "Client suggestion
failure still opens typed-query URL": say what failure includes ("refused, timed out
or unreadable"), so that "answers garbage" is not a case a client author must
guess is covered.

## F8. What "typed-query fallback" means precisely

**Question.** "Typed-query fallback" and "Client suggestion failure still opens
typed-query URL" can be read as: (a) when the suggestion request fails, open the
typed query instead of a suggestion; (b) when the user picks no suggestion, open the
typed query; (c) if opening a suggestion's URL fails, open the typed query. They
are different flows with different replay behaviour, and the third would replay an
open the contract says not to replay ("Do not replay failed opens").

**Looked.** Spec Browser URL row and the sentence after "Default changes after
resolution do not retarget or replay this action"; the operations file header ("Do
not replay failed opens"); guide item 4.

**Did.** Reading (a) only, because the CLI has no chooser: whatever the source does,
the typed query is what is opened, once. A suggestion is never opened by this
command, an open that Koine answers with a dependency, an error or an unknown
outcome is never followed by a second open (reading (c) would be a replay), and the
suggestions the source did return are only counted in `detail`. An empty query is
not refused: it opens `...q=`, since nothing says a typed query may not be empty.

**Proposal.** Repair in `client-guide.md` "Opening a URL" item 4: "The fallback is
the choice of what to open, made before the one open request; it is never a second
open after a failed one." One sentence, which also states there is no second
attempt.

## F9. The operation is named `OpenSearchURL` but the root opens any web URL

**Question.** The guide's section is "Opening a URL" and the root is
`workspaceOpenURL`; the published operation is `OpenSearchURL`. Is it only for
opening a search results page, or may a client use it for any URL?

**Looked.** The operations file; guide "Opening a URL" ("publishes it as
`OpenSearchURL`"); the spec ("Required absolute HTTP(S) URL string").

**Did.** `open-url` sends any text through `OpenSearchURL`, since the operation's
body is the generic root and nothing restricts the URL to a search. The only
published operation for the root has that name, so the choice was between using it
and writing a second document, which the client does not do.

**Proposal.** Repair in `workspace-operations.graphql`: a comment on `OpenSearchURL`
("opens any absolute HTTP(S) URL; the name is the search flow's use of it").
Renaming a published operation is not proposed.

## F10. Is opening a URL repeatable, and how should a harness that re-runs commands treat it?

**Question.** The client guide says never replay a mutation automatically and a lost
answer is an unknown outcome. The harness that runs this client re-runs commands it
believes timed out. Is a second `workspaceOpenURL` for the same URL harmless (the
browser is already there) or a second tab and a second page load?

**Looked.** Guide "Mutations" and "Opening a URL" (items 1, 3, 4, 5 apply
"unchanged"); spec ("Default changes after resolution do not retarget or replay
this action"; "no replay or alternate handler"). Nothing says whether a repeat is
idempotent.

**Did.** Treated as not repeatable: sent once, never replayed by the client,
`unknown-outcome` on a lost answer (a connection cut after the request was written
is tested: one request, `actionEffect: unknown`, `outcomeUnknown: true`). A caller
that runs `open-url` or `search` twice opens twice; the client cannot prevent that
and does not try (no state kept between runs).

**Proposal.** Decline: version 1 has no idempotency key, and a browser's reaction to
a second identical URL is the browser's. A sentence in the guide would do ("a second
request is a second open").

## F11. What the receipt's `process` means for a URL

**Question.** The spec's receipt rule says the identity is "the application returned
by this action's completion callback", and the guide says a launch's `value.process`
is the launched or reactivated application. For a URL the application is the default
browser. Does the identity name the browser process, the process that rendered the
page, a window or a tab? How often is it null? What may a client do with it?

**Looked.** Spec "Results and failure boundary" and the Operations table ("URL
submitted to the resolved default browser"); SDL `WorkspaceOpenReceipt.process`;
guide item 6 of "Launching an application" (applied "unchanged").

**Did.** Reported exactly as for a launch: `process` copied unchanged,
`processState` one of `present`, `null-in-receipt`, `suppressed`, `no-receipt`,
`choicesArguments` handed to `choices` unchanged. Nothing is claimed about which
browser, window or tab, or about whether the page loaded. A null `process` after
`AVAILABLE` is `ok` with `processState: null-in-receipt`. The documents say a null is
expected; they do not say a browser that was already running is likely to give one
or the other, and none of that was observed.

**Proposal.** Repair in `client-guide.md` "Opening a URL": "`value.process`, when
present, is the browser that was asked to open the URL. It names no window, tab or
page; a client that wants the browser's windows uses it as for a launch, and the
browser may show the page in any of them."

## F12. Which dependency reasons can a URL open report?

**Question.** The enum has four values. The spec's "Operations" section says
`PATH_NOT_FOUND` and `NO_DEFAULT_HANDLER` "belong to the operations that open a path
or a URL", and the outcome table gives `NO_DEFAULT_HANDLER` for "an existing path or
valid web URL". Can a URL open report anything else (`APPLICATION_NOT_INSTALLED`
for a registered browser whose bundle is gone)?

**Looked.** Spec "Operations", outcome table; guide item 3; SDL (closed enum).

**Did.** `dependency.reason` and `guidance` are reported verbatim as strings, with
no branch on a value and no action on the guidance. Only `NO_DEFAULT_HANDLER` is
stubbed, because it is the only reason the documents attach to a URL.

**Proposal.** Repair as launch's F13 did: add a "Reasons" column to the Operations
table, one row per root.

## F13. Details that are normative only in "Evidence so far"

**Question.** The guide's "Opening a URL" says "an `http` or `https` scheme"; whether
`HTTPS://X` is accepted, whether a port, an IP literal or an empty port is valid,
and how far IDNA validation goes are stated only in the spec's "Evidence so far".
Is that section a contract?

**Looked.** Spec "Evidence so far" ("accepted are an `http` or `https` scheme in any
case, ...").

**Did.** Nothing depends on it: the client sends what it is given and does not
classify URLs. A reader who wanted to build a URL (rather than pass one through)
would need the facts and would find them in an evidence list.

**Proposal.** Repair: move the accepted and refused classes (scheme case, ports, IP
literals, IDNA) from "Evidence so far" into the guide's "Opening a URL" item 1, or
say there that evidence rows are not normative and the grammar is the RFC's.

## F14. Is there a length limit for the URL?

**Question.** The grammar bounds nothing. The Machine limits a request body to 1 MiB
and an over-limit body is 413 (`request-error`). Is there a URL-specific limit, and
what does a very long typed query do?

**Looked.** Spec; `machine.md` "Local transport and discovery" (1 MiB request
bodies, 413).

**Did.** No client-side limit; an over-large body would be the transport's 413 and
classified `request-error` with nothing run. Not exercised.

**Proposal.** Decline: the 413 rule already states the bound for any request.

## F15. Privacy of a suggestion request

**Question.** A suggestion request sends the typed text to a third party before the
user has chosen to search. The documents place this in the client and name no
consent rule.

**Looked.** Spec; guide item 4.

**Did.** The client makes the request only when `--suggestions-url` is given, sends
no credential and no Koine identifier, and reports in the output that it asked and
what the source did.

**Proposal.** Decline: a product decision for the client's author, outside the
contract.

---

## Disposition

The recommendations of the pass that wrote the client, and what became of each. The
repairs were made by the session that ran the V acceptance
([open-url-vm.md](open-url-vm.md)), which also observed the real wire for F1 and F2;
the other answers were checked there where the run could (F3, F5, F7, F8, F10, F11 and
F13 are exercised by the client's own commands against the signed build).

| # | Recommended | Resolution | Where |
|---|---|---|---|
| F1 | Repair | **Repaired.** Observed: every refused input is an error at `["workspaceOpenURL"]` with `kind` null, an execution error in an HTTP 200 answer | [client-guide.md](../client-guide.md#opening-a-url) item 1; [spec outcome table](../specs/workspace-launch-and-open.md#results-and-failure-boundary) |
| F2 | Repair | **Repaired.** The row's "URI scalar" now says version 1 serves none; the guide says a refused URL is HTTP 200, observed for all 18 refused inputs | [machine.md](../specs/machine.md) error table; guide item 1 |
| F3 | Repair (one sentence) | **Repaired**; file handling declined for version 1 | guide item 1, "A client's own handling" |
| F4 | Decline, with a sentence | **Declined**, the sentence added | guide item 1, "A client's own handling" |
| F5 | Repair | **Repaired**: the encode set, `%20`, `%25`, the worked `café 日本` example | guide item 1, "Putting typed text into a query value" |
| F6 | Decline; one sentence | **Declined**, the sentence added: the engine and its template are the client's | guide item 4 |
| F7 | Decline a protocol; repair "failure" | **Declined** (a protocol); "failure" now reads refused, timed out or unreadable | [spec Browser URL row](../specs/workspace-launch-and-open.md#acceptance); guide item 4 |
| F8 | Repair | **Repaired**: the fallback is the choice made before the one open, never a second open | guide item 4; spec Browser URL row |
| F9 | Repair (comment) | **Repaired**: a comment on `OpenSearchURL`; the name is kept | [workspace-operations.graphql](../design/workspace-operations.graphql); guide |
| F10 | Decline; one sentence | **Declined**, the sentence added: a second request is a second open | guide item 5 |
| F11 | Repair | **Repaired**: the receipt names a browser, not a window, tab or page | guide item 5 |
| F12 | Repair | **Repaired** as a sentence rather than a column: `workspaceOpenURL` reports `NO_DEFAULT_HANDLER` and no other reason | [spec, Operations](../specs/workspace-launch-and-open.md#operations); guide item 3 |
| F13 | Repair | **Repaired**: the accepted and refused URL classes are in the guide, and not only in the evidence list | guide item 1, "What is accepted and refused beyond that" |
| F14 | Decline | **Declined**: the 413 rule is the bound | n/a |
| F15 | Decline | **Declined**: a product decision for the client's author | n/a |

## Defects found in the existing client (not document findings)

- `parseArgs` refused any value that began with `--`, so a query or a URL such as
  `--help` or `--x` could not be given at all, and nothing said so. It now also
  accepts `--name=value`, the only way to give such a value; the old `--name value`
  form is unchanged. (A value of the old form that begins with `--` is still read as
  the next option.)
- The launch interpretation was written for one root. It is now
  `interpretWorkspaceOpen(result, rootName)` in `src/adapter/workspace-open.ts`
  (`interpretLaunch` and `interpretOpenURL` are one-line wrappers), the
  `contractViolation` messages name the root actually read, and an input error at the
  root's argument is counted as the action's own refusal (F1). The launch tests are
  unchanged and pass.

## No guess needed

Checked and unambiguous in the documents:

- `workspaceOpenURL` needs `workspace:control` AND `desktop:control` and no read
  capability; a denial reports `requiredCapabilities` as
  `["workspace:control","desktop:control"]` in that order with `requiredCapability` the
  first unmet member; preflight refusal is HTTP 403 with no `data`, `phase:
  authorization`, at the action's path.
- The result is the launch's: `status`, exactly one of `value` and `dependency`
  selected by it absent an error, a published status authoritative when an error
  suppresses its branch, a null root always has an error, `AVAILABLE` is native
  acknowledgment and not rendering, a dependency result is not an error and is not
  success.
- `failed` means effects may have begun, with no replay and no alternate handler; a
  lost answer is unknown even if the browser opened; the answer comes within five
  seconds.
- No URL repair by Koine: it does not trim, normalise or re-encode; it resolves the
  handler by scheme alone; Koine makes no search request and contacts no search
  service.
- A refused URL (other schemes, credentials, whitespace, backslashes, control
  characters, raw Unicode, invalid escapes) is an input error: nothing was looked up
  and nothing opened.
