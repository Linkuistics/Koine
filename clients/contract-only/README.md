# koine-client

A GraphQL client for Koine's `koine-desktop/1` contract, written entirely from
the published contract documents: `machine-spec.md`, `desktop-operations.graphql`,
`adr-bearer-grants.md`, a captured `introspection.json` and the `capture.json`
metadata read over the same connection. No Koine source was consulted.

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
| `codegen` | `@graphql-codegen/cli` reads `capture/introspection.json` as the schema and the published `docs/design/desktop-operations.graphql` as the documents, **validates** the five operations against that schema, and writes `src/generated/graphql.ts` (types plus `TypedDocumentString` documents, `documentMode: 'string'`, so nothing from `graphql` is needed at runtime) |
| `typecheck` | `tsc --noEmit` under `strict`, `exactOptionalPropertyTypes` and `noUncheckedIndexedAccess` |
| `bundle` | `build.mjs` bakes in graphql-js's own `getIntrospectionQuery({ descriptions: true })` and the digest from `capture/capture.json`, then esbuild bundles `src/cli.ts`; the build fails if anything from `node_modules` reaches the bundle |
| `test` | `test/run.mjs` drives the built bundle against a stub server that replays the wire shapes the spec describes, covering every classification |

Generation reads the published operations document where the contract publishes
it, so there is no copy that can drift from it. All five operations validate
against the captured introspection, and nothing in that document was edited —
the client was made to fit the contract, never the other way round. The
validation has been watched failing: `nonsenseField` added to `DesktopChoices`
stops generation with `Cannot query field "nonsenseField" on type
"DesktopWindow"`.

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
`rate-limited`, `service-unavailable`, `unknown-outcome`.

HTTP status decides first (the spec decides transport and authentication before
execution); then `extensions.kind` with `extensions.permissionClass`; then a
null root value with no error is `absent`. `extensions.reason`,
`requestState`, `requiredCapability`, `osPermission` and `permissionOwner` are
surfaced per error in `errors[]` rather than folded into the classification.

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
