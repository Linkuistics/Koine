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

## Regenerated against

`capture/` holds the response of the signed Koine.app serving **core + desktop +
workspace**, where the workspace part is the launch root alone
(`workspaceLaunchApplication` and the types it reaches: `WorkspaceApplicationInput`,
`WorkspaceOpenResult`, `WorkspaceOperationStatus`, `WorkspaceOpenReceipt`,
`WorkspaceProcessIdentity`, `WorkspaceDependencyUnavailable`,
`WorkspaceDependencyReason`). Contract `koine-desktop/1`, schema digest
`a56a3387c7bef91758e31713fd9a7f632855c2b3a9eaaf5f8e5cce1b66d49aea`. The other three
workspace roots (`workspaceOpenURL`, `workspaceOpenPath`, `workspaceRevealPath`)
are designed but not served, so they are not in the captured schema.

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
| `test` | `test/run.mjs` drives the built bundle against a stub server that replays the wire shapes the spec describes, covering every classification; the launch answers are in `test/launch-stubs.mjs`, each transcribed from the workspace spec's own tables (dependency results, both receipt shapes, preflight and execution-phase capability denials with `requiredCapabilities`, `failed` at the action's path and at the deadline, an input error, suppressed status/value/process/dependency branches, and the invariant violations), with one request asserted per launch |

Generation reads the published operations documents where the contract publishes
them, so there is no copy that can drift from them. All five desktop operations
and `LaunchInstalledApplication` validate against the captured introspection, and
nothing in those documents was edited — the client was made to fit the contract,
never the other way round. The validation has been watched failing: `nonsenseField`
added to `DesktopChoices` stops generation with `Cannot query field
"nonsenseField" on type "DesktopWindow"`, and adding `OpenSearchURL` to the used
list stops it with `Cannot query field "workspaceOpenURL" on type "Mutation"`.

**Selecting the served operations.** `workspace-operations.graphql` also declares
`OpenSearchURL`, `OpenDocumentOrDirectory` and `RevealPath`, whose roots the
captured server does not serve, so the file cannot be validated whole. The
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
