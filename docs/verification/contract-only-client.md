# A client written from the documented contract alone

The spec's "Client handoff" claims that "standard GraphQL tooling plus a small
client-owned adapter" is enough, and that "no Koine-owned Swift client library is
required in the first deliverable". That is a claim about what a **stranger** can
do, and until this run nothing had tested it. `clients/contract-only` is that
stranger's client, and this document is the run in which it obtains a grant,
discovers the endpoint, resolves a running application, lists its windows and
focuses a chosen one against the notarized bundle.

## The discipline, and how it was made real

The client's author was a session with no path into this repository at all. Its
reachable world was five files: `docs/specs/machine.md`,
`docs/design/desktop-operations.graphql`,
`docs/adr/bearer-grants-and-live-revocation.md`, one captured introspection
response, and the `contractVersion` and `Koine.schemaDigest` read over the same
connection as that capture.

Two things were deliberately **withheld**. `Sources/` and `Providers/`, because
one glance at a resolver turns the exercise into theatre. And
`docs/design/desktop-schema.graphql` — the design SDL — because the contract
tells clients to generate from introspection, so handing over the file the digest
is taken from would have answered the question the exercise asks. The operations
file was handed over, because the contract names it as the client's own view.

The value here is a negative property, and a negative property asserted by an
instruction is worth nothing. It was made a property of **reach** instead: the
author worked in a sandbox holding those five files, so "it did not read the
source" is a fact about what existed on its paths rather than a promise it made.

## Procedure

```sh
task app && task app:notarize          # on the host; .build/app/Koine.app, stapled
task client                            # codegen, typecheck, bundle, adapter checks
task app:vm-verify-contract-client     # scripts/vm-verify-contract-client.sh
```

The clean clone, the transcript (`.build/vm-verify/contract-client-<timestamp>.log`),
`KOINE_VM_KEEP=1` and the TestAnyware workarounds are those of
[resident-app-vm.md](resident-app-vm.md). Nothing runs the application on the
host. The golden image has `python3` and `curl` and no `node`, so the run carries
a pinned Node 24.21.0, checked against its published `SHASUMS256.txt` before it
is unpacked or uploaded (`scripts/stage-node-runtime.sh`); the client is bundled
on the host to one dependency-free `.mjs`, so nothing is installed in the guest.

## What the run drives

| Step | What the client is asked | Expectation checked |
|---|---|---|
| No service | `probe`, before Koine is launched | `service-unavailable` — an absent descriptor is unavailability, not denial |
| Discovery | `probe`, after launch | the descriptor is read, `contractVersion` is `koine-desktop/1`, `path` is `/graphql`, and the client builds the literal loopback URL itself |
| Enrolment | `enrol`, then the user's decision in Koine's window | the window shows the client's own label and comparison code; the client's own poll goes `PENDING` → `APPROVED`; no credential is typed, pasted or shown |
| `InspectOwnConnection` | under the reading grant | contract version, instance id, served digest, and the caller's own active grant |
| Introspection | `introspect` | a standard `getIntrospectionQuery` answer, and **the client's own comparison** of the digest served now with the digest it generated against |
| `DesktopChoices`, no consent | before Accessibility is given | `os-permission-denied`, at `["desktopApplication","windows"]`, naming `accessibility` and `koine`, with no consent dialog on screen |
| `DesktopChoices` | after consent | the application and at least two windows under distinct references |
| Absence | a process identity that names nothing | ordinary null with **no** error — `absent`, not denied |
| Capability denial | `focus` under `desktop:read` alone | HTTP 403, `capability-denied`, `requiredCapability: desktop:control`, `phase: authorization` |
| `FocusDesktopWindow` | under a second grant holding `desktop:control` | the receipt is the submitted reference **unchanged**, and the system agrees the chosen window has focus |
| Choosing | the other window of the same application | focus moves to a different window-server id, so the client chose rather than merely activating |
| Gone target | `focus` on a closed window | `unavailable` at the action's path, and focus does not move |
| Stopped service | `probe` and `inspect` after Quit | `service-unavailable` again — a transport state, not a refusal |

## What a green run is

**All five published operations run unmodified.** `DesktopChoices`,
`FocusDesktopWindow`, `RequestDesktopGrant`, `PollOwnGrantRequest` and
`InspectOwnConnection` are sent as `docs/design/desktop-operations.graphql` has
them. They are also *validated* before they are ever sent: `task client` runs
`@graphql-codegen/cli` with the captured introspection as the schema and that
published file as the documents, so a document that does not validate stops the
build. Generation reads the published file where the contract publishes it, so
there is no copy that can drift from it. That check has been watched failing:
`nonsenseField` added to `DesktopChoices` stops generation with `Cannot query
field "nonsenseField" on type "DesktopWindow"`, and the file is byte-identical
afterwards (`c3d2a827ba7d73e88fa8562a641d5af4c352b835ba20357ba85c8403b69ad4dc`).

**Koine is never its own witness for focus.** Which window actually has focus is
read from the system by `Fixtures/WindowIdentityProbe`, an independently signed
tool, after every focusing action — the same witness
[desktop-focus-vm.md](desktop-focus-vm.md) uses. A receipt is Koine's claim; the
probe is what makes it evidence.

**The digest comparison is the contract's own, not a test fixture.** The spec
says clients "compare it with the digest they generated against to learn that
they should introspect again". `introspect` does exactly that and reports
`schemaDigestsEqual`, so the run checks an obligation the contract already places
on clients instead of inventing one.

**Error classification is exercised in both directions.** A capability denial, an
OS-permission refusal, a gone target, an absent process and a stopped service are
each asked for and each told apart — including the two that are easiest to
conflate, absence and denial, which the contract keeps distinguishable only by
the presence of an error.

## What the stranger fell into

The author's own unedited record is
[contract-only-client-gaps.md](contract-only-client-gaps.md) — it is the leaf's
real deliverable and the input to `documentation-and-handoff-k45`. The findings
that cost the most, ranked by the damage a wrong guess does:

| # | Finding | Why it matters |
|---|---|---|
| 1 | **The process start instant has no documented source.** The contract demands six fractional second digits and never says where a client gets them on macOS. No documented CLI has that precision: `ps -o lstart=` is whole seconds. The only microsecond source is `proc_pidinfo(PROC_PIDTBSDINFO)`, which Node cannot call — so the client compiles a fifteen-line C helper with `/usr/bin/cc` at first use and shells out to it. | A wrong instant makes `desktopApplication` return null for an application that is running, and that null is indistinguishable from "not running". ModalAnyware is TypeScript-fronted and will meet this first. |
| 2 | **Whether enrolment carries an `Authorization` header is never stated.** The author inferred "no" by combining three sentences hundreds of lines apart. | Getting it wrong 401s, and a wrong header and a wrong digest answer identically. |
| 3 | **`DesktopProcessStart` has no grammar.** `Reference` gets a precise one; this scalar gets prose and no `@specifiedBy`. `T`, `Z` and the separator were guessed. | Correct, as this run shows — but guessed. |
| 4 | **The transport rule "invalid credentials return 401" contradicts the status-only poll**, which is specified 300 lines away. | A client implementing the transport section literally cannot poll its own request. |
| 5 | **There is no enumerated `extensions.kind` vocabulary**, and nothing declares the set closed; `phase` appears once and nowhere else; none of it is in the schema. | Every client re-derives the classification table from four scattered places. |
| 6 | **The published `DesktopChoices` cannot read an application's name without consent.** `ref`, `name` and `bundleIdentifier` resolve without Accessibility, but the published operation selects non-null `windows` in the same request, so propagation discards the whole application. | A consent-free operation would be worth publishing. |
| 7 | **A generated client has no standard way to record the digest it generated against.** `Koine.schemaDigest` is an ordinary field, not introspection, so no code generator reads it; the capture step every client needs is unstated. | The one piece of tooling the handoff assumes and does not describe. |
| 8 | **"Never replay a mutation" has no counterpart for recovery.** Nothing says whether resubmitting the same reference to `desktopFocusWindow` is an accepted recovery from an unknown outcome. | The client refuses to retry and reports `unknown-outcome`; whether the operator may is left to the operator. |

Three of these are the contract saying less than it knows (1, 3, 7); two are the
contract contradicting itself across distance (2, 4); the rest are shape. **None
of them is a defect in the served schema** — the schema conformance check
([schema-conformance-vm.md](schema-conformance-vm.md)) already covers that, and
this run found nothing it had missed.

The author also recorded what the contract got **right**, which is the honest
other half: the enrolment retry rule, the anonymous-budget scoping sentence, the
"transport unavailability and unknown mutation outcome are client transport
states" sentence, the transport-refusal ordering, reference opacity, and the
introspection-sorting paragraph that stopped it trying to recompute the digest.

## How each finding was settled

Every entry in [contract-only-client-gaps.md](contract-only-client-gaps.md),
by its section number there, settled in `documentation-and-handoff-k45`. A
**repair** is a statement now in [the spec](../specs/machine.md) or the
[client guide](../client-guide.md) that answers it. A **decline** leaves the
contract as it is for `koine-desktop/1`, with the reason. The human chose to
repair in prose and decline every change to the served schema or its
behaviour, since each would move the schema digest, or change what the release
evidence observed, after that evidence was taken.

| § | Finding | Settled |
|---|---|---|
| 1.1 | The start instant has no documented source | **Repaired.** The spec now names the source, `proc_pidinfo(PROC_PIDTBSDINFO)`, and states the comparison is exact. The human first rejected time as a process identity, then kept it for `koine-desktop/1` when the non-time replacement proved out of proportion to the release ([capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md)). |
| 1.2 | `DesktopProcessStart` has no grammar | **Repaired**: `YYYY-MM-DDTHH:MM:SS.ffffffZ`, exactly, in the spec and the guide. An example or `@specifiedBy` in the schema is **declined** (digest). |
| 1.3 | Nothing says how to turn a name into a pid | **Repaired**: locating the process is the client's; Koine has no lookup by name or bundle identifier. |
| 1.4 | `DesktopChoices` reads nothing without consent | **Repaired** in the guide, which says which fields resolve without consent and that a client may write its own operation. A second published operation is **declined**: the published operations are the handoff's path, not a catalogue. |
| 2.1 | Whether enrollment carries a credential | **Repaired**: it carries none, and one presented with any credential is refused (401 for a credential naming nothing, `permission` for a live one). |
| 2.2 | "Invalid credentials return 401" contradicts the status-only poll | **Repaired**: the transport section now names the status-only principal. |
| 2.3 | Capability names only readable under a grant | **Repaired**: the version-1 set is stated, and an unknown name is refused at submission rather than put to the user. Anonymous `availableCapabilities` is **declined** (behaviour change). |
| 2.4 | Keychain or file | **Repaired**: the handoff says credential storage, and the guide says both. |
| 3.1 | No enumerated `kind` vocabulary | **Repaired**: the four values, stated closed for version 1, plus the input error that carries none. A schema enum is **declined**: extensions are not part of a GraphQL schema. |
| 3.2 | No precedence among errors | **Repaired**: the contract sets none, and says so. |
| 3.3 | "Null root with no error is absence" never said | **Repaired**, in one sentence in "Errors and partial data". |
| 3.4 | Caller-fixable enrollment outcomes are `failed` | **Declined** (behaviour change): `extensions.reason` tells them apart. |
| 3.5 | A deadline cannot be told from an OS failure | **Repaired** from what is already served: a deadline or response-cap error has an empty `path`, which is sufficient but not necessary — a deadline can also be met at an action's path — so the guide tells clients to treat every `failed` mutation as unconfirmed, which is what this client already did. A dedicated marker is **declined**. |
| 3.6 | 403 has two meanings | **Repaired**: a 403 with no body is the `Origin` refusal. |
| 3.7 | Does a 429 body carry a `kind` | **Repaired**: it does not. |
| 4.1 | Descriptor re-reading has no policy | **Repaired** in the guide: re-read once, and reconnect only if the port changed. |
| 4.2 | Descriptor types and version mismatch | **Repaired**: JSON types stated; an unknown `descriptorVersion` or a different `contractVersion` is an incompatible service, not an unavailable one. |
| 4.3 | `instanceId` and reference lifetime never joined | **Repaired**: a changed `instanceId` means every window reference is `unavailable`. |
| 4.4 | Origin and Host only right by the library's luck | **Repaired**: use a non-browser HTTP client. |
| 4.5 | Descriptor `pid` is unusable | **Repaired**: clients ignore it. |
| 5.2 | Scalars have no machine-readable mapping | **Repaired** in the guide: both are strings. `@specifiedBy` is **declined** (digest). |
| 5.3 | No standard way to record the generated-against digest | **Repaired**: read `koine { schemaDigest }` beside introspection and store it with the generated code. |
| 5.4 | Safe introspection options implied | **Repaired**: every `getIntrospectionQuery` option but `inputValueDeprecation`, which is what `task conformance` sends. |
| 5.6 | The coordinate table is only the desktop half | **Repaired**: the spec's desktop table now points at the management surface's own, and the spec and the guide say the published operations are not a catalogue. |
| 5.7 | Every spec link points outside the handout | **Declined**: the handout was the exercise's; the repository the links resolve in is published with the release. |
| 6.1 | No warning against URL-normalising a reference | **Repaired** in the guide. |
| 6.2 | Is re-submitting a focus a recovery | **Repaired**: no automatic replay; re-submitting is a new request, the caller's to choose. |
| 6.3 | Three kinds of "not running" answer the same | **Declined**, deliberately: each is "that application is not running", and the spec now says so. |
| 6.4 | No published management operations | **Repaired**: stated, with why a client cannot approve itself. |

§2.5, §3.8, §4.6, §5.1 and §5.5 record what worked and need
nothing. §7 lists what the client added on its own, which binds no one. §8 ranks
the guesses above; each is settled in its own row.

## What this does and does not show

- **It does not show that the documents are sufficient** — it shows they are
  sufficient *with* the eight guesses above, ten of which the author ranked. A
  second stranger guessing differently on finding 1 would have a client that
  silently sees no applications.
- **The compiled C helper is a finding, not a solution.** A published client
  should not invoke `/usr/bin/cc` at runtime. It is in the tree because removing
  it would hide the gap that produced it; it goes when the time-based identity
  it serves is replaced (§1.1 above).
- **This is not a Gatekeeper run.** The clone is the ordinary golden, whose
  assessments are disabled, and the bundle is installed unquarantined. The bundle
  is the notarized, stapled one; the enforcing posture is
  [notarized-release-vm.md](notarized-release-vm.md)'s.
- **Only one of the two grant workflows is driven here.** The client-requested
  one, because that is the one a stranger's client drives itself; the published
  operations contain nothing for management, so this client *cannot* approve
  itself, which is correct and deliberate. Both workflows end to end are
  `grant-workflow-acceptance-k43`'s.
- **The client is not a Koine deliverable.** It is evidence. Nothing ships it,
  and no ModalAnyware decision is bound by its shape.

## Evidence

Run of 2026-09-20, transcript `contract-client-20260920T222140.log`, against
`.build/app/Koine.app` version **0.1.0**, signed `Developer ID Application:
Antony Blakey (TA43A4RUP3)`, notarized and stapled. VM: clone of
`testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64. Client bundle
`clients/contract-only/dist/koine-client.mjs` under Node v24.21.0
(`6239d4cf…`, matching its published digest). Contract version
`koine-desktop/1`.

**The served schema is the one this client was generated against:
`ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf`** — the value
[schema-conformance-vm.md](schema-conformance-vm.md) establishes, here read back
by a client that compared it for itself.

```
== Launch Koine; the client finds the endpoint from the descriptor alone
Endpoint the client built for itself: http://127.0.0.1:49152/graphql
  descriptor 0600, descriptorVersion 1, path /graphql, contractVersion koine-desktop/1

== The client introspects, and compares what it generated against with what is served
{"command": "introspect", "classification": "ok", "byteCount": 37195,
 "servedSchemaDigest": "ee17dfd16a7d…", "generatedAgainstSchemaDigest": "ee17dfd16a7d…",
 "schemaDigestsEqual": true, "servedContractVersion": "koine-desktop/1"}

== Without Accessibility consent, the window list is an os-permission refusal
{"classification": "os-permission-denied", "desktopApplication": null,
 "errors": [{"message": "Koine needs Accessibility access to read and focus windows.",
             "path": ["desktopApplication", "windows"], "kind": "permission",
             "permissionClass": "os-permission", "osPermission": "accessibility",
             "permissionOwner": "koine"}]}
no consent dialog on screen (after a read without consent)

== DesktopChoices: the application and its windows
Process identity the client captured:
  {"pid":363,"startedAt":"2026-09-20T12:21:51.246535Z","startedAtSource":"helper",
   "startedAtPrecision":"microsecond"}
Application: {"name":"Finder","ref":"koine://desktop/application/363/1789906911246535"}

== An absent process is ordinary null, and the client says absent rather than denied
{"classification":"absent","absence":"server-null","response":{"data":{"desktopApplication":null}}}
  — HTTP 200, no errors at all

== The reading grant cannot focus: a capability denial
{"classification":"capability-denied","http":{"status":403},"receipt":null,
 "errors":[{"path":["desktopFocusWindow"],"kind":"permission","permissionClass":"capability",
            "requiredCapability":"desktop:control","phase":"authorization"}]}

== FocusDesktopWindow: the chosen window, and the reference comes back unchanged
witness: TextEdit window 57 has focus
{"classification":"ok","submittedRef":"koine://desktop/window/363/…/f6bb3cdbf89a7d3a/1",
 "receipt":{"ref":"koine://desktop/window/363/…/f6bb3cdbf89a7d3a/1"},
 "receiptRefMatchesSubmitted":true}
witness: Finder window 51, titled "Recents"

== The other window, so that the client is choosing rather than activating
{"classification":"ok","submittedRef":"…/f6bb3cdbf89a7d3a/2","receiptRefMatchesSubmitted":true}
witness: Finder window 50, titled "Recents" — not 51

== A window that is gone is unavailable, and focus does not move
{"classification":"unavailable","receipt":null,"http":{"status":200}}
witness before: TextEdit window 57 — witness after: TextEdit window 57

== After Quit, the client says the service is unavailable again
{"command":"probe","classification":"service-unavailable",
 "transport":"no endpoint: endpoint descriptor unreadable (ENOENT)"}

== PASSED
```

**Both Finder windows were titled "Recents".** The client chose between them by
reference alone and the system agreed each time — window 51, then 50, then 51 —
which is the addressing rule doing work rather than being asserted. Closing 51
then made that reference `unavailable` while focus stayed where it was.

The response the client's own introspection brought back is
`.build/contract-client/introspection.json`, 37195 bytes: 26 named types, no
errors, and the same set of named types as the capture in
`clients/contract-only/capture/` that the client was generated from. The two
files are not byte-identical and are not meant to be — they are answers to two
different introspection queries — so the digest, not the bytes, is what says the
schema is the same.

## Tooling note

`scripts/vm-verify-contract-client-trim.py` drops the `response` field from the
one answer that embeds a whole introspection body before that line crosses the
agent's exec channel: it is about 40 kB, far more than the channel carries
reliably, and a truncated line would not parse at all. The body itself is written
to a file in the guest by the client and downloaded whole, so nothing is lost.

One harness failure is worth recording because it will recur. On the first
attempt the second approval clicked into TextEdit: `testanyware agent snapshot`
reads a window's accessibility tree **through** whatever covers it, so the
label and comparison code verified correctly while the click at those screen
coordinates went to the window on top. Any click driven from a snapshot must
raise its window first, and `approve_in_window` now does.
