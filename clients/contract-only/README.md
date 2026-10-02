# koine-client

A GraphQL client for Koine's `koine-desktop/1` contract, written entirely from
the published contract documents: the Machine, workspace-launch-and-open and
workflow-provider specs, the client guide, `desktop-operations.graphql` and
`workspace-operations.graphql`, the bearer-grants decision, a captured
`introspection.json` and the `capture.json` metadata read over the same
connection. No Koine source was consulted. The `launch` command was added by a
second pass under a stricter reading restriction; every place that pass had to
guess is in
[`docs/verification/launch-contract-client-findings.md`](../../docs/verification/launch-contract-client-findings.md).
`open-url` and `search` were added by a third pass under the same restriction;
its guesses are in
[`docs/verification/open-url-contract-client-findings.md`](../../docs/verification/open-url-contract-client-findings.md).
`open-path` was added by a fourth pass under the same restriction; its guesses are in
[`docs/verification/open-path-contract-client-findings.md`](../../docs/verification/open-path-contract-client-findings.md).

## Regenerated against

`capture/` holds the response of the signed Koine.app serving **core + desktop +
workspace**, where the workspace part is the launch, URL and path roots
(`workspaceLaunchApplication`, `workspaceOpenURL`, `workspaceOpenPath` and the types
they reach: `WorkspaceApplicationInput`, `WorkspaceOpenResult`,
`WorkspaceOperationStatus`, `WorkspaceOpenReceipt`, `WorkspaceProcessIdentity`,
`WorkspaceDependencyUnavailable`, `WorkspaceDependencyReason`). Contract
`koine-desktop/1`, schema digest
`f98a3862c3bb77417c38eef9fe4edccd16e0bf76b6f4b8fc7bdf6708190be32d`. The remaining
workspace root (`workspaceRevealPath`) is designed but not served, so it is not in the
captured schema.

It builds to one dependency-free ES module, `dist/koine-client.mjs`, which runs
on macOS arm64 under Node 24 with nothing installed beside it.

## Build

```sh
npm install
npm run build        # codegen -> typecheck -> bundle -> adapter tests
node dist/koine-client.mjs probe
```

`npm run build` runs four steps:

| step | what it does |
|---|---|
| `codegen` | `@graphql-codegen/cli` reads `capture/introspection.json` as the schema and, as the documents, the published `docs/design/desktop-operations.graphql` (whole: five operations) and the operations this client uses from the published `docs/design/workspace-operations.graphql` (see below), **validates** them against that schema, and writes `src/generated/graphql.ts` (types plus `TypedDocumentString` documents, `documentMode: 'string'`, so nothing from `graphql` is needed at runtime) |
| `typecheck` | `tsc --noEmit` under `strict`, `exactOptionalPropertyTypes` and `noUncheckedIndexedAccess` |
| `bundle` | `build.mjs` bakes in graphql-js's own `getIntrospectionQuery({ descriptions: true })` and the digest from `capture/capture.json`, then esbuild bundles `src/cli.ts`; the build fails if anything from `node_modules` reaches the bundle |
| `test` | `test/run.mjs` drives the built bundle against a stub server that replays the wire shapes the spec describes, covering every classification; the launch answers are in `test/launch-stubs.mjs` (the URL root's, in `test/open-url-stubs.mjs`, with the suggestion sources `search` talks to in `test/suggestion-stubs.mjs`; the path root's, in `test/open-path-stubs.mjs`), each transcribed from the workspace spec's own tables (dependency results, both receipt shapes, preflight and execution-phase capability denials with `requiredCapabilities`, `failed` at the action's path and at the deadline, an input error, suppressed status/value/process/dependency branches, and the invariant violations), with one request asserted per launch, per open and per search |

Generation reads the published operations documents where the contract publishes
them, so there is no copy that can drift from them. All five desktop operations,
`LaunchInstalledApplication`, `OpenSearchURL` and `OpenDocumentOrDirectory` validate against the captured introspection, and
nothing in those documents was edited — the client was made to fit the contract,
never the other way round. The validation has been watched failing: `nonsenseField`
added to `DesktopChoices` stops generation with `Cannot query field
"nonsenseField" on type "DesktopWindow"`, and adding `RevealPath`
to the used list stops it with `Cannot query field "workspaceRevealPath" on type
"Mutation"` (before `workspaceOpenURL` and `workspaceOpenPath` were served,
`OpenSearchURL` and `OpenDocumentOrDirectory` stopped it the same way).

**Selecting the served operations.** `workspace-operations.graphql` also declares
`RevealPath`, whose root the captured server does not serve, so the file cannot be
validated whole. The
documents do not say how a client picks the served subset; `codegen.ts` decides:
it lists, by name, the operations the client uses
(`WORKSPACE_OPERATIONS_USED`), cuts each one's text out of the published file by
source location together with every fragment it spreads (transitively), and hands
that to codegen. A listed name the file no longer declares fails generation;
a listed operation that does not validate fails generation; an unlisted operation
is reported on stderr with whether its root is served, and never generated.
`CaptureOpenedApplication` is served but not generated: it is `DesktopChoices`
under another name, which `choices` already sends.

`capture/` holds the other generation input: the introspection response this
client was generated against, and the `contractVersion` and `Koine.schemaDigest`
read over the same connection in the same session. The digest is baked into the
bundle so that `introspect` can report, as the spec says a client should, whether
the schema it generated against is still the one being served.

## Commands

Every command prints **exactly one JSON object on exactly one line to stdout**
and exits 0 whenever it printed that line, including for error results. The
answer is in the JSON, never in the exit code. Diagnostics go to stderr.

Every result carries `command`, `ok`, `classification`, `endpoint`, `http`,
`response` (the raw GraphQL response body), `errors`, `transport` and
`outcomeUnknown`.

| command | does |
|---|---|
| `probe` | Reports the endpoint descriptor and whether the service answers, with no credential. |
| `enrol --secret <p> --label <l> --capability <c>...` | Makes or reuses the secret, then requests a grant anonymously. Prints `requestId` and `comparisonCode`. |
| `poll --secret <p>` | This client's own request state and, once approved, its grant metadata. |
| `inspect --secret <p>` | `InspectOwnConnection`: contract version, instance id, served schema digest and own grant. |
| `introspect --secret <p> --out <path>` | Sends the standard introspection query, writes the raw body to `<path>`, and prints `byteCount`, `servedSchemaDigest`, `generatedAgainstSchemaDigest` and `schemaDigestsEqual`. |
| `choices --secret <p> --application <name>` | Finds the named running process, captures its process identity, runs `DesktopChoices`. |
| `choices --secret <p> --pid <n> --started-at <instant>` | The same operation with the process identity given literally. |
| `focus --secret <p> --ref <reference>` | `FocusDesktopWindow` on that reference, byte-for-byte. |
| `launch --secret <p> --bundle-identifier <id> [--application-path <absolute path>]` | `LaunchInstalledApplication`, sent **once**; needs `workspace:control` and `desktop:control` (no read capability). See "Launch" below. |
| `open-url --secret <p> (--url <text> \| --url-file <path>)` | `OpenSearchURL` with the text as the one literal variable, byte-for-byte, sent **once**; same two controls. See "Open URL" below. |
| `open-path --secret <p> (--path <text> \| --path-file <file>) [--bundle-identifier <id>] [--application-path <absolute path>]` | `OpenDocumentOrDirectory` with the path as a literal variable, byte-for-byte, sent **once**; same two controls. See "Open path" below. |
| `search --secret <p> --query <text> [--engine-template <url with one %s>] [--suggestions-url <url with one %s>]` | The client-owned search flow: optionally ask a suggestion source, then build the typed-query URL and open it with `OpenSearchURL`, once. See "Search" below. |

Any `--name value` may also be written `--name=value`; that is the only way to give
a value that itself begins with `--` (a query, or a URL under test).

### Launch

`launch` sends the published `LaunchInstalledApplication` mutation exactly once
with literal variables (`{"application": {"bundleIdentifier": ..., "applicationPath": ...}}`;
`applicationPath` only when given, never expanded or checked client-side: a
relative or blank value is refused by the provider as an input error). A launch
is not safe to repeat: the client never replays it, and a lost answer is
`unknown-outcome`. Besides the common fields it prints:

| field | meaning |
|---|---|
| `sentMs`, `receivedMs` | `Date.now()` immediately before the request was handed to the HTTP stack, and immediately after the response body was complete. `receivedMs` is null when the body never completed; both are null when nothing was sent. |
| `status` | The published `status` (`AVAILABLE` or `DEPENDENCY_UNAVAILABLE`), or null when none was published (refusal, failure, propagation removed it). |
| `actionEffect` | What the action did, from the contract: `none` (this action submitted nothing: a dependency result, an input error, a refusal before dispatch), `acknowledged` (native acknowledgment; not proof anything rendered or came to the front), `may-have-begun` (`failed` at the action's path), `unknown` (deadline, lost answer, propagation removed the status, a broken invariant). |
| `receipt`, `process` | The receipt `{process}` or null; the receipt's `{pid, startedAt}` copied unchanged, or null. |
| `processState` | `present`; `null-in-receipt` (the receipt has no process identity: exit, ambiguity, unreadable start time or a mismatch — **not** a failed launch); `suppressed` (an error removed the receipt or its `process`: unknown, not absent); `no-receipt`. |
| `choicesArguments` | `["--pid", n, "--started-at", instant]` when `process` is present, to be handed unchanged to `choices`; else null. |
| `dependency` | `{reason, guidance}` from a typed dependency result, else null. Reasons and guidance are reported verbatim and never acted on. |
| `requiredCapability`, `requiredCapabilities`, `phase` | From the first capability denial: the first unmet member, the **complete ordered set as sent** (never sorted or reduced to the unmet members), and `authorization` or `execution`. The same three facts are on every error in `errors[]`, which is the per-error record. |
| `branchSuppressed`, `resultErrorPaths` | The published status selected a branch that an error left null; and the paths of the errors at or below the launch result. |
| `contractViolation` | A reason string when a response broke a rule the contract states (see below); else null. |

`classification` follows the errors when there are any (the most severe, by the
same order as every command) and the result when there are none. `actionEffect`
follows the published `status` when there is one, because "a published status
remains authoritative if an error suppresses its branch": a capability denial at
`workspaceLaunchApplication.value` with status `AVAILABLE` is classified
`capability-denied` **and** reports `actionEffect: "acknowledged"`, so a caller
does not mistake it for a launch that did not happen. `outcomeUnknown` is true
for `may-have-begun`, `unknown` and any `failed`.

The four outcomes are told apart as follows.

| outcome | `classification` | what to read |
|---|---|---|
| dependency unavailability | `dependency-unavailable` | `dependency.reason`, `dependency.guidance`; `actionEffect: none`; `ok` is false, `errors` is empty |
| capability denial | `capability-denied` | `requiredCapability`, `requiredCapabilities` (per error in `errors[]` too), `phase`; HTTP 403 with no `data` for a preflight refusal |
| `failed` | `failed` | `errors[].path`, `actionEffect: may-have-begun` (action's path) or `unknown` (empty path: deadline); `outcomeUnknown: true`; never replay |
| an absent process | `ok` with `processState: null-in-receipt`, or later `absent` from `choices` | `process` null is not a failed launch; a process that no longer runs is ordinary null from `choices` |

A response that cannot be read under the contract's invariants (a null root with
no error, which the contract says never happens for this field and so is not
absence; both or neither branch present without an error; an unknown status; a
malformed `process`; a body that is not a GraphQL response) is classified
`failed` with `contractViolation` set and `actionEffect: unknown`.

### Open URL

`open-url` sends the published `OpenSearchURL` mutation (`workspaceOpenURL(url:)`)
exactly once, with the URL as one literal variable `{"url": ...}`. A URL open is
not safe to repeat: the client never replays it, and a lost answer is
`unknown-outcome`. The text is sent **byte-for-byte**: nothing is trimmed,
normalised, decoded or percent-encoded, and nothing is validated client-side, so
raw Unicode, whitespace, backslashes, credentials, other schemes and escapes that
are not valid all reach the provider, which refuses what the contract says it
refuses, as an `input-error`, and the refusal is what the command reports.

- `--url <text>` takes the text from the command line. `--url=<text>` is the same
  and the only way to give one that begins with `--`.
- `--url-file <path>` reads the file's bytes as UTF-8 and sends exactly that text:
  a trailing newline, a CR LF, a leading space or a byte order mark are part of it
  (a file written by `echo` therefore ends in a newline the provider will refuse as
  whitespace; write it with `printf %s`). A file that is not valid UTF-8 cannot be
  a GraphQL string: nothing is sent and the result is `failed` with a `clientError`.
- Exactly one of the two is required.

The answer has the shape of a launch's, because the contract gives the URL root the
same result type, invariant and failure table; the interpretation is one module,
`src/adapter/workspace-open.ts`, given the root it reads. Besides the common fields
it prints every field "Launch" lists (`status`, `actionEffect`, `receipt`,
`process`, `processState`, `choicesArguments`, `dependency`, `requiredCapability`,
`requiredCapabilities`, `phase`, `branchSuppressed`, `resultErrorPaths`,
`contractViolation`, `sentMs`, `receivedMs`, `credential`) with `url`, the exact
text that was sent. What differs from a launch:

| outcome | `classification` | what to read |
|---|---|---|
| a browser took the URL | `ok` | `status: AVAILABLE`, `actionEffect: acknowledged` (not proof a page loaded); `process` may be null (`processState: null-in-receipt`), which is not a failure |
| no default browser | `dependency-unavailable` | `dependency.reason` is `NO_DEFAULT_HANDLER` with `guidance`; nothing was submitted |
| a URL the provider refuses | `input-error` | an error with no `kind` at a path under `workspaceOpenURL`, read at the field's path (`["workspaceOpenURL"]`) or at the argument's (`["workspaceOpenURL","url"]`), reported in `resultErrorPaths`; `actionEffect: none` |
| capability denial, `failed`, suppressed branches, invariant violations | as for launch | the same two controls, the same complete ordered set `["workspace:control","desktop:control"]`; a `contractViolation` names `workspaceOpenURL` |

### Open path

`open-path` sends the published `OpenDocumentOrDirectory` mutation
(`workspaceOpenPath(path:, application:)`) exactly once. A path open is not safe to
repeat: the client never replays it, and a lost answer is `unknown-outcome`. The path
goes into the one variable `path` **byte-for-byte**: nothing is validated, trimmed,
expanded (`~`, `$HOME`, globs), resolved, made absolute, normalised or encoded
client-side, so an empty, relative or NUL-containing path, a file URL, a path with a
trailing newline or one that names an application bundle all reach the provider, which
refuses what the contract says it refuses (an `input-error`) or answers
`PATH_NOT_FOUND`, and that answer is what the command reports.

- `--path <text>` takes the text from the command line; `--path=<text>` is the same
  and the only way to give one that begins with `--`. An argument cannot carry a NUL.
- `--path-file <file>` reads the file's bytes as UTF-8 and sends exactly that text:
  a trailing newline (so a file written by `echo` names a path that ends in one; write
  it with `printf %s`), a leading space, a NUL byte, non-ASCII text and a byte order
  mark are all part of the path. A file that is not valid UTF-8 cannot be a GraphQL
  string, so nothing is sent and the result is `failed` with a `clientError`.
- Exactly one of the two is required.
- Without `--bundle-identifier` the `application` variable is **omitted** (the
  contract says omitted and `null` are the same default handler) and the output's
  `application` is `null`. With it the variable is `{bundleIdentifier}` plus
  `applicationPath` when `--application-path` is given, each verbatim (a blank
  identifier is the provider's to refuse). `--application-path` without an identifier
  is a usage error and nothing is sent, because the input type requires the identifier.

Besides the common fields it prints every field "Launch" lists, plus `path` (the exact
text sent) and `application` (the object sent, or null), and nothing else. What differs
from a launch or a URL open:

| outcome | `classification` | what to read |
|---|---|---|
| the handler took the item | `ok` | `status: AVAILABLE`, `actionEffect: acknowledged` (not proof a document rendered); `process`, when present, is whatever the receipt carried and may be null |
| nothing at the path, no default handler, a named application not installed or with another identifier | `dependency-unavailable` | `dependency.reason` is `PATH_NOT_FOUND`, `NO_DEFAULT_HANDLER`, `APPLICATION_NOT_INSTALLED` or `APPLICATION_IDENTITY_MISMATCH`, copied verbatim with `guidance`; every one reads the same way: `actionEffect: none`, nothing was submitted, `outcomeUnknown: false`. `PATH_NOT_FOUND` is not reported as a statement that the path does not exist, and no reason is acted on |
| an input or a payload the provider refuses (empty, relative or NUL path; a blank identifier; an application bundle, program or Finder alias) | `input-error` | an error with no `kind` at the root field's own path (`["workspaceOpenPath"]`); one a level below is read the same way; `actionEffect: none`. The class of refusal is only in the error's `message`, which this client reports and never reads |
| capability denial, `failed`, suppressed branches, invariant violations | as for launch | the same two controls, the same complete ordered set `["workspace:control","desktop:control"]`; a `contractViolation` names `workspaceOpenPath`. A `failed` is never read as a missing path (inspection that is denied is `failed`) |

### Search

`search` is the client-owned flow the documents describe ("query entry,
suggestions and typed-query fallback remain client-owned; Koine does not construct
searches or contact Google"). It does two things, in order:

1. **Ask the suggestion source** (only if `--suggestions-url` is given): one plain
   HTTP GET of that template with the query percent-encoded into its one `%s`, a
   2 second limit on the whole exchange, redirects refused, and nothing it does is
   fatal. The result is `answered` (HTTP 2xx and a body that is a JSON array whose
   second element is a list of strings, the common `[query, [suggestion, ...]]`
   answer) or `failed` (connection refused, timeout, non-2xx, a redirect, a body
   that is not that), with a `detail`; without a source, `not-attempted`.
2. **Build the typed-query URL and open it**, whatever 1 did: the UTF-8 bytes of the
   query percent-encoded into `--engine-template` (default
   `https://www.google.com/search?q=%s`): every byte outside the RFC 3986
   unreserved set (`A-Z a-z 0-9 - . _ ~`) becomes `%` and two upper-case hex digits,
   a space is `%20`. Then one `OpenSearchURL`, exactly as `open-url` sends it.

This command has no chooser, so suggestions never change what is opened: the typed
query is always the URL. The client talks to the Koine endpoint and the suggestion
source only; it never contacts the search engine (the template is text that goes to
Koine), and a suggestion source that redirects is not followed. The output is the
`open-url` output (its `url` is the URL built) plus

```json
"search": { "query": "...", "engineTemplate": "...", "urlBuilt": "...",
            "suggestions": { "attempted": true, "outcome": "not-attempted | answered | failed", "detail": "..." } }
```

A template without exactly one `%s`, or a missing `--query`, is a usage error and
nothing is sent.

### Repeat safety

The harness re-runs commands it believes timed out. Everything here is built for
that: the secret is minted once into its file (with `wx`, so two concurrent runs
cannot mint two identities) and reused; an enrollment retry with the same digest,
label and capability set is answered by Koine with the original receipt; `probe`
sends a credential-free non-enrollment request, which the spec answers 401 and
which spends no anonymous-enrollment budget. The client itself never replays a
mutation whose result was lost — it reports `classification: "unknown-outcome"`
and lets the operator decide.

### Classification

`classification` is one of:

`ok`, `absent`, `capability-denied`, `os-permission-denied`, `unavailable`,
`unknown-provider`, `failed`, `request-error`, `unauthenticated`,
`rate-limited`, `service-unavailable`, `unknown-outcome`, and two added for the
workspace path:

- `dependency-unavailable`: the action submitted no domain request because a
  prerequisite failed (an application that is not installed, or a constrained
  copy with another identifier). The contract calls it a typed result that "is
  not an execution error", so the existing set, which has only error classes,
  cannot express it. `ok` is false.
- `input-error`: an error with a non-empty `path` and **no** `kind`, which the
  client guide defines as an argument a provider found invalid, with nothing
  attempted. Before, it was folded into `failed`, which for a mutation claims
  "effects may have begun"; the contract says the opposite. An error with an empty
  path and no `kind` stays `failed`, as the guide says.

HTTP status decides first (the spec decides transport and authentication before
execution); then `extensions.kind` with `extensions.permissionClass`; then a
null root value with no error is `absent`. `extensions.reason`,
`requestState`, `requiredCapability`, `requiredCapabilities`, `phase`,
`osPermission` and `permissionOwner` are surfaced per error in `errors[]` rather
than folded into the classification.

### Secrets

The bearer secret and its SHA-256 digest never reach stdout or stderr. The
credential file is created 0600 in a 0700 directory and holds the unpadded
base64url secret and nothing else; the whole output line is scanned and redacted
before it is written.

### Opaque references

Every `Reference` the server hands over is stored and resubmitted as the exact
string received. The client never parses, normalises, percent-decodes or
constructs one, and deliberately never passes one through `new URL()`.

### Test affordance

`KOINE_ENDPOINT_DESCRIPTOR` overrides the descriptor path so the client can be
driven against the stub server in `test/`. It is not part of the contract; when
unset, the published path is used.

## What writing this found

The contract's gaps, as the author met them, are in
[`docs/verification/contract-only-client-gaps.md`](../../docs/verification/contract-only-client-gaps.md);
the run that exercised this client against a notarized Koine is in
[`docs/verification/contract-only-client.md`](../../docs/verification/contract-only-client.md).
