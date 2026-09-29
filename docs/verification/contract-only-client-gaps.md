<!--
The unedited record of the author who wrote clients/contract-only from the
published contract alone. It is the primary evidence for
docs/verification/contract-only-client.md, which ranks these findings and gives
each one's disposition. Below the note under the title it is kept as written: it
is a stranger's account of reading Koine's documents, which is the one thing here
that cannot be reproduced, and editing it for tone or to match the current
contract would destroy that.
-->

# GAPS

> Each finding's disposition — answered by the [spec](../specs/machine.md) or the
> [client guide](../client-guide.md), or declined for `koine-desktop/1` with its
> reason — is in
> [contract-only-client.md](contract-only-client.md#disposition-of-each-finding).
> The record below quotes the contract as its author read it.

What the published Koine contract did and did not tell a stranger writing a
client against it. Written from `machine-spec.md`, `desktop-operations.graphql`,
`adr-bearer-grants.md`, `introspection.json` and `capture.json` only; the Koine
implementation was never opened.

Entries are grouped by area. Each says what I needed, what the documents say,
what I did, and how I would have liked it stated. Areas where I found no gap are
recorded too, because "this was fine" is also a finding.

---

## 1. Process identity

### 1.1 Nothing says how to obtain the start instant on macOS — and the precision it demands is not available from any documented command-line tool

**Needed.** A value for `DesktopProcessIdentity.startedAt` that matches what
Koine's desktop provider captured for the same process.

**Documents.** The spec: "`DesktopProcessIdentity` contains a positive
`pid: Int!` and `startedAt: DesktopProcessStart!`, the process start instant in
canonical UTC with six fractional second digits. A client captures both at
interaction start. The provider compares both before resolving; a recycled PID
must not select a new application. A missing reliable start instant is an input
error, not permission to silently target by PID alone." The scalar's own
description: "UTC instant with exactly six fractional second digits, captured
from the process start time."

That is all. The contract never names an OS source. It never says whether the
provider compares the rendered string or a parsed instant, and it never states a
tolerance — the phrase "compares both" reads as exact.

**What I did.** I established by experiment that no documented macOS CLI reports
sub-second process start time. `ps -p <pid> -o lstart=` gives whole seconds
("Sun 20 Sep 21:55:51 2026"); `lsappinfo`'s "checkin time" is a LaunchServices
event, not process start, and is also printed to the second. The only
microsecond source I could find is `proc_pidinfo(PROC_PIDTBSDINFO)`'s
`pbi_start_tvsec` / `pbi_start_tvusec` (equivalently `sysctl` `KERN_PROC`'s
`kp_proc.p_starttime`), and Node 24 has no stable FFI with which to call it.

So the client does something I am not happy about and want on the record: **on
first use it compiles a fifteen-line C program with `/usr/bin/cc` into a cache
directory under the temp dir and shells out to it.** `src/adapter/process-identity.ts`
holds the source. If `cc` is absent — a machine without the Command Line Tools —
it falls back to `ps -o lstart=`, renders `.000000` for the fraction, and reports
`"startedAtPrecision": "second"` plus a note in the result, because that value is
almost certainly wrong in its last six digits and will make the provider's
comparison fail. The `choices` result always states which source was used, so a
harness can tell a genuine "no such process" from a precision failure.

**How I would have liked it stated.** One sentence in the spec, next to the
`DesktopProcessIdentity` paragraph: "On macOS the instant is
`proc_pidinfo(PROC_PIDTBSDINFO)`'s `pbi_start_tvsec.pbi_start_tvusec`, rendered
as `YYYY-MM-DDTHH:MM:SS.ffffffZ`." That single sentence removes the sharpest
problem in the whole task. If the comparison is in fact tolerant, or is made on
whole seconds, saying so would remove it just as well and let a client use `ps`.

### 1.2 "Canonical UTC" has no grammar

**Needed.** The exact lexical form of a `DesktopProcessStart`.

**Documents.** "canonical UTC with six fractional second digits" and the scalar
description above. The `Reference` scalar gets a precise grammar four sections
later ("canonical `koine://<provider>/<remainder>` URI strings, with no
userinfo, port or fragment"); `DesktopProcessStart` gets none. The introspected
scalar carries no `specifiedByURL`.

**What I did.** Guessed RFC 3339 with `T` and `Z`:
`2026-09-19T07:38:06.015720Z`. Date separator, time separator, offset spelling
(`Z` versus `+00:00`) and whether a leading `+` year is permitted are all
unverified.

**How I would have liked it stated.** One example value in the scalar's
description, or a `@specifiedBy(url: "https://www.rfc-editor.org/rfc/rfc3339")`.
The description field is already being used for prose; an example costs nothing.

### 1.3 Nothing says how a client turns an application name into a pid

**Needed.** `choices --application Finder` has to find a pid.

**Documents.** Silent. `Query` offers `desktopApplication(process:)` and
`desktopApplicationByReference(ref:)` — no lookup by name or bundle identifier.
"Deferred: non-running applications, broad installation/configuration
discovery" implies application discovery is client-owned but never says so.

**What I did.** `ps -Ao pid=,comm=` with a tiered match: exact basename inside a
`/<name>.app/Contents/MacOS/` path first, then any such bundle path, then exact
basename, then prefix. The chosen pid and every candidate are reported in the
result so an operator can see what was picked and why. On a real desktop
`Finder` resolves to pid 697 at tier 0 with a Google Drive Finder extension
correctly ranked below it.

**How I would have liked it stated.** An explicit sentence in "Client handoff":
"Locating the process is the client's responsibility; Koine offers no discovery
by name or bundle identifier." It would have stopped me hunting for a coordinate
that does not exist.

### 1.4 The published operation cannot read an application's name without Accessibility consent

Not a gap so much as a consequence worth recording. The spec says
"`DesktopApplication.windows` and `desktopWindow` need Accessibility consent. An
application's `ref`, `name` and `bundleIdentifier` resolve without it". But the
published `DesktopChoices` selects `windows { ... }` in the same request, and
`windows` is `[DesktopWindow!]!`. So without consent the non-null field errors,
propagation discards `desktopApplication`, and a client using the published
operation learns nothing at all — not even the name that would have resolved.
The client reports `os-permission-denied` with `permissionOwner: koine`, which
is the right thing to show a user, but a second consent-free operation selecting
only `ref name bundleIdentifier` would be a useful thing for the contract to
publish.

---

## 2. Authentication and enrollment

### 2.1 Whether to present the credential when enrolling is never stated

**Needed.** Does `koineRequestGrant` go out with `Authorization: Bearer <the
secret I am about to have granted>` or without?

**Documents.** Three statements that have to be combined. "Invalid or revoked
bearer credentials return HTTP 401 before execution." "`Mutation.koineRequestGrant`
— Anonymous enrollment, one request per operation." "Status-only credentials
cannot be mixed with ordinary operations to acquire extra authority." Nowhere
does it say "send no Authorization header on enrollment."

**What I did.** Send no header. The reasoning: on a *first* enrollment the digest
is unknown, so the header would be an invalid credential and answered 401 before
the mutation could execute; on a *retry* the digest names a pending request, so
the header would authenticate as a status-only principal and the mutation would
be an ordinary operation that principal cannot reach. Either way the header
breaks it, and the retry case would have broken exactly the repeat-safety the
harness depends on.

This inference is load-bearing and it cost me real time to be confident in it.

**How I would have liked it stated.** In the enrollment section: "The request
carries no `Authorization` header; a credential of any kind on this operation is
refused." A client author gets it wrong once and cannot tell a wrong header from
a wrong digest, because both answer 401.

### 2.2 One secret authenticates for one operation and 401s for every other, and the two rules that say so are 300 lines apart

**Needed.** `poll` presents the same secret that `inspect` presents. Before
approval, `poll` must work and `inspect` must not.

**Documents.** The transport section states a flat rule: "Invalid or revoked
bearer credentials return HTTP 401 before execution." Read alone, a not-yet-
granted secret is invalid and `poll` is impossible. The grants section supplies
the exception: "The requester polls `koineGrantRequest` using possession of its
proposed bearer secret" and "Proof of the submitted secret authorizes only the
request's own status while pending, denied or expired."

**What I did.** Implemented both: `poll` always sends the header; `inspect`,
`choices` and `focus` send it and will legitimately see 401 until the grant is
approved. The client reports `unauthenticated` and does not treat it as fatal.

**How I would have liked it stated.** The transport sentence amended to
"Credentials that are invalid, revoked, or presented for an operation their
principal cannot reach return HTTP 401 before execution", with a pointer to the
status-only principal. As written, the transport section reads as absolute and
contradicts the grants section.

### 2.3 Capability names can only be discovered by a client that already has a grant

**Needed.** Valid spellings for `--capability`.

**Documents.** The spec names `desktop:read`, `desktop:control` and
`koine:manage` in prose and states the shape ("A provider identifier … is also
… the prefix of the provider's capabilities"), but never enumerates them as a
closed list. The schema has `Koine.availableCapabilities: [String!]!` — "Names
available to request. Listing them supplies no authority." — but `Query.koine`
is "Authenticated caller metadata", so you need a grant to read the list of
things you may ask a grant for.

**What I did.** Passed `--capability` through verbatim, validated nothing, and
let the server answer. A misspelled capability becomes an enrollment the user is
asked to approve, which is a poor place to discover a typo.

**How I would have liked it stated.** Either make `availableCapabilities`
readable by anonymous enrollment (it "supplies no authority" by its own
description), or state the version-1 capability set in the spec as contract.

### 2.4 Keychain versus file

The "Client handoff" paragraph lists "Keychain storage" as one of the four
things the client-owned adapter covers. The grants section permits the
alternative: "Scripts may use a user-only credential file when Keychain access
is impractical." A non-interactive CLI is such a script, so I used a 0600 file
in a 0700 directory. No gap — but the handoff sentence and the permission live
far apart, and the handoff sentence is the one a client author reads first.

### 2.5 Things the enrollment protocol got exactly right

Recorded because they are unusually well specified and I want the contrast on
the page:

- Retry idempotence is stated precisely: "An enrollment retry with the same
  digest, label and capability set returns the original request ID and code,
  even after approval; changed label/capabilities return a conflict." This is
  what makes the whole harness-repeats-everything requirement tractable, and I
  did not have to guess any of it.
- "No secret travels back in a poll response, so losing the approval response
  does not strand the credential" answered the question I was about to ask.
- The anonymous-enrollment budget is scoped explicitly: "Nothing else spends or
  is refused by that budget: authenticated clients, status-only polls, the local
  console, and requests without a credential that are not enrollment, which stay
  401." That sentence is the direct reason `probe` is implemented as a
  credential-free `{ __typename }` query — it is provably free to repeat.
- The comparison code's "alphabet and length are not contract" saves a client
  from validating it. I treat it as an opaque string.

---

## 3. Error classification

### 3.1 There is no single enumerated vocabulary

**Needed.** The closed set of `extensions.kind` values.

**Documents.** Four places. The "Errors and partial data" condition table yields
`unknown-provider`, `unavailable`, `permission` (with `permissionClass` of
`capability` or `os-permission`) and `failed`. The transport section adds
`extensions.kind: permission, permissionClass: capability, phase: authorization`
for a 403 preflight denial — `phase` appears there and nowhere else, and is not
in the error-shape paragraph. Prose adds "A response over its cap and an
execution past its deadline are … one error with `extensions.kind: failed`."
The management table adds `extensions.reason` values under `kind: failed` and
`unavailable`. Nothing declares the set exhaustive, and none of it is in the
schema as an enum.

**What I did.** Built the closed client vocabulary in
`src/adapter/classification.ts` from those four places plus the two client
transport states the spec names, and mapped an unrecognised `kind` to `failed`
(the safest classification: it asserts nothing about the resource and, for a
mutation, nothing about whether the action ran).

**How I would have liked it stated.** One table, or better, a GraphQL enum in
the schema whose values are the `kind` vocabulary, so a generated client gets it
for free and a new value is a digest change rather than a silent surprise.

### 3.2 Precedence among several execution errors is never stated

**Needed.** One response can carry several errors on different branches — the
spec says so ("Other branches survive where their types permit"). Which one
decides the single `classification` the harness reads?

**Documents.** Silent.

**What I did.** Invented an order, wrote it down in the source with its reason,
and reported every error individually in `errors[]` so nothing is lost:
`os-permission-denied` > `capability-denied` > `unauthenticated` >
`rate-limited` > `request-error` > `unknown-provider` > `unavailable` >
`failed`. Permission outranks everything because it is the only class that
routes a human to a different action.

**How I would have liked it stated.** A sentence saying either "a client may
choose" (which would at least tell me I was not missing a rule) or a stated
precedence.

### 3.3 "Null root with no error is absence" is true but never said in one place

**Needed.** Telling an ordinary absent result from a refusal.

**Documents.** Assembled from: "absent process returns null without error";
"absence and failure remain distinguishable by the presence of an error"; "A
read denial produces an execution error, not an empty list or ordinary null";
and the non-null propagation rules, which mean a denied `windows` nulls
`desktopApplication` *with* an error attached. The rule is derivable and is
correct — but it is derived.

**What I did.** `absentIfNullRoot`: a null root value counts as `absent` only
when the response carried no error at all.

**How I would have liked it stated.** "A root lookup that is null with no error
is absence; a root lookup that is null with an error is that error, whatever
path it carries."

### 3.4 An enrollment conflict is a client input error classified as `failed`

The management-outcome table gives `enrollment-conflict`, `credential-in-use`,
`invalid-subset`, `already-decided` and `pending-request-limit` all as `kind:
failed`, told apart only by `extensions.reason`. Three of those are things the
*caller* did wrong and could fix. A client classifying on `kind` alone reports
them as generic failures. I surface `reason` and `requestState` per error, as
the spec's "additive to the error shape above" invites, but the top-level
`classification` for an enrollment conflict is `failed`, which understates it.

I would have preferred `kind: request-error` (or a dedicated `conflict`) for the
three caller-fixable outcomes.

### 3.5 A mutation's `failed` cannot be told from a deadline

**Needed.** Whether a focus that returned `kind: failed` might nevertheless have
run.

**Documents.** "A timeout after an action begins does not prove that it failed",
and a deadline answers "HTTP 200 with `data: null` and one error with
`extensions.kind: failed`. Neither says whether a requested action ran." But an
ordinary OS failure is *also* `kind: failed`, and that one definitely did not
focus anything.

**What I did.** Conservatively set `outcomeUnknown: true` on **every** mutation
classified `failed`. This over-reports: a plain OS failure is now flagged as
possibly-ran. I chose over-reporting because the opposite error — telling a
caller a focus definitely did not happen when it did — is the one the spec
spends a paragraph warning about.

**How I would have liked it stated.** A distinguishing extension on the deadline
and response-cap errors, e.g. `extensions.outcome: "unknown"`. Then a client
could be precise instead of pessimistic.

### 3.6 HTTP 403 has two meanings and the body is the only discriminator

The transport section returns 403 for a browser `Origin` header (a transport
error, "no GraphQL body") and 403 for capability preflight ("with `errors` and
no `data`"). A client sees one status. I branch on whether a GraphQL body with
`errors` came back, and classify a bodiless 403 as `request-error`. It works,
but the contract never tells a client to do it.

### 3.7 Does a 429 body carry a `kind`?

The spec says over-budget enrollment is "HTTP 429 with `Retry-After` in seconds,
`errors` and no `data`: no action began, so there is no action path to carry a
GraphQL execution error." I read that as: the errors carry no `kind`. I classify
`rate-limited` from the status before looking at the body, so it does not matter
either way — but I guessed, and the sentence is doing a lot of work for a client
that classifies body-first.

### 3.8 Things the error model got exactly right

- Naming the two client-side states explicitly — "Transport unavailability and
  an unknown mutation outcome are client transport states, not invented
  successful GraphQL results" — is the single sentence that made the whole
  classification design fall out. It told me the vocabulary has a client half
  and that I was expected to build it.
- "The body, not HTTP success alone, determines the operation result."
- "An `unavailable` error may echo a reference the caller supplied, not disclose
  an otherwise unauthorized resource" — tells a client the echoed reference is
  safe to log.
- The ordering of transport refusals (403/421/404/405/415/413) is given
  explicitly and before authentication. I implemented it directly.

---

## 4. Endpoint and transport

### 4.1 Descriptor re-reading has no policy

**Needed.** How to behave when the connection fails.

**Documents.** "A client reads the descriptor on connection and again after
connection failure. It may reconnect for a subsequent request; it never
automatically replays a mutation whose result was lost."

**What I did.** Re-read once; retry only if the constructed URL actually changed
(otherwise retrying is just a second identical failure). No backoff, no loop.
The "never replay" rule is honoured: the retry only happens when the *first*
attempt never reached a server, and for mutations a connect failure is the only
case that is provably unsent.

**How I would have liked it stated.** "Re-read once and retry only if the port
changed" would have matched what I built and saved the reasoning.

### 4.2 The descriptor has no stated failure vocabulary or field types

"It contains `descriptorVersion`, `instanceId`, `pid`, `port`, `path` equal to
`/graphql`, and `contractVersion` equal to `koine-desktop/1`." No JSON types, no
statement about unknown fields, and no guidance on what a client should do when
`contractVersion` is something else. I validate strictly (`descriptorVersion`
must be `1`, `port` a positive integer ≤ 65535, `path` exactly `/graphql`,
`contractVersion` exactly `koine-desktop/1`) and report any mismatch as
`service-unavailable` with a detail string. Treating a version mismatch as
unavailability rather than as a distinct classification is my guess.

### 4.3 `instanceId` and reference lifetime are two facts the spec never joins

The transport section: "`instanceId` distinguishes server runs; it is neither
authentication nor a reference lifetime guarantee." The references section: "A
window reference therefore does not survive a restart of Koine". Those combine
into something a client very much wants: *a changed `instanceId` means every
window reference you hold is dead.* The spec never says it. I report
`endpoint.instanceId` on every result so a caller can notice, but the inference
is mine.

### 4.4 Origin, Host and redirects worked out, but only by luck of the library

The spec rejects any `Origin` header including `Origin: null`, validates `Host`
against the literal bound address, and forbids redirects. Node's `fetch` sends
no `Origin` for a non-browser request and sets `Host` from the URL, and undici
forbids setting `Host` manually — so if it had been wrong I could not have fixed
it. I set `redirect: 'error'` explicitly. A client author using a browser-shaped
HTTP library would be refused with 403 and no body and would have a bad
afternoon. A note in "Client handoff" saying "do not use a browser HTTP stack"
would be cheap.

### 4.5 `pid` in the descriptor is unusable and the spec half-says so

"under the lock such a descriptor was left by a dead instance, and its `pid` and
`port` are not evidence of anything." A client cannot take the lock, so it can
never be in the position where that reasoning applies — it just has a `pid` it
must not trust. I report it and never use it. Saying "clients should ignore
`pid`" would be clearer than leaving a field in the descriptor that only the
server may reason about.

### 4.6 No gaps found in

Media types, the one-request-per-POST rule, `Cache-Control: no-store`, the
request-policy limits (1 MiB, depth 16, 1000 selections, 10 root actions,
8 MiB response, 5 second execution) and `Accept:
application/graphql-response+json`. All stated in numbers, all directly
implementable, none ambiguous.

---

## 5. Schema, digest and code generation

### 5.1 All five operations validate — no finding

`@graphql-codegen/cli` validated `desktop-operations.graphql` against
`introspection.json` and generated all five without a single error or warning.
I confirmed the validation is real rather than vacuous by temporarily adding a
`nonsenseField` to `DesktopChoices`, which failed generation with "Cannot query
field \"nonsenseField\" on type \"DesktopWindow\"", and then restored the byte
copy. The published operations file was never edited.

### 5.2 The custom scalars have no machine-readable mapping

`Reference` and `DesktopProcessStart` are custom scalars with prose
descriptions and no `@specifiedBy`. With `strictScalars: true` codegen refuses
to guess, so the mapping to `string` is a hand-written line in `codegen.ts`
justified by prose ("serialized as a URI string", "maps to an opaque string
wrapper in client bindings"). It is correct, but it is a guess encoded in build
configuration rather than something the contract carries. `@specifiedBy` on both
scalars would let a generator do it.

### 5.3 A generated client has no standard way to record the digest it generated against

**Needed.** The `introspect` command has to print "the digest this client was
generated against."

**Documents.** "Clients compare it with the digest they generated against to
learn that they should introspect again; they do not recompute it." Which is
correct and clear about the *comparison*. But nothing describes the *capture*:
standard code generation consumes an introspection response, and no
`@graphql-codegen` plugin reads `Koine.schemaDigest`, because it is an ordinary
field on `Query.koine` and not part of introspection at all.

**What I did.** Took it from `capture.json`, which is a handout of this exercise
and not a contract artifact, and baked it into the bundle at build time
(`build.mjs`). In the real world a client's generation step would have to make a
second authenticated request alongside introspection and store the result
itself. That is a small, unstated piece of tooling every client has to invent.

**How I would have liked it stated.** "A generating client reads
`koine { schemaDigest }` over the same connection as introspection and records
it beside the generated code" — one sentence in "Client handoff", and ideally a
worked `task`-style example.

### 5.4 The introspection query's safe option set is implied, not stated

**Needed.** Which `getIntrospectionQuery` options the `introspect` command may
send.

**Documents.** The spec flags one landmine precisely: "`__InputValue.isDeprecated`
is served as null against a non-null declaration, so a query that selects it —
what `getIntrospectionQuery` sends under its `inputValueDeprecation` option —
fails at that position instead of answering." It says nothing about
`specifiedByUrl`, `directiveIsRepeatable`, `schemaDescription` or `oneOf`.

**What I did.** `getIntrospectionQuery({ descriptions: true })` and otherwise
graphql-js defaults, which happen to leave `inputValueDeprecation` off. That is
a version-dependent safety: if a future graphql-js or codegen release flips a
default, generation against a live Koine breaks in a way whose cause is a
sentence buried in a limits section.

**How I would have liked it stated.** A positive statement of the supported
query — "Koine answers `getIntrospectionQuery` with default options plus
`descriptions: true`; other options are not supported in version 1" — rather
than only naming the one that fails.

### 5.5 The documented limits pre-empted a mistake I was making

Credit where due. I started reasoning about whether the client could verify the
served digest by recomputing it from introspection. The spec stops that cold:
"`__Type.fields` and `__Type.inputFields` come back **sorted by name**, not in
declared order. Declared order is therefore not recoverable from introspection,
which is consistent with clients comparing the schema digest rather than
recomputing it." That is a genuinely excellent paragraph — it names the library
limit, its consequence, and why the design is unaffected.

### 5.6 The schema contains coordinates the spec's table does not

`Koine.availableCapabilities`, `KoineGrant.clientLabel`,
`KoineGrantRequest.requestedCapabilities` / `clientLabel` / `comparisonCode`,
the whole `KoineManagement` subtree, `KoineOSPermission`, `KoineProviderStatus`,
`KoineCreatedGrant` and every management mutation are in introspection but not
in the spec's "following signatures define the desktop surface" table. The table
says "the desktop surface", so this is consistent — but a reader arriving at the
table looking for the complete contract finds only half of it, and the
management half is described in prose and a separate surface table with no
types. Cross-references between the two tables would help.

### 5.7 Every document link in the spec points outside the handout

`../adr/koine-server-and-native-providers.md`, `../design/desktop-schema.graphql`,
`../design/architecture/index.html`, `../verification/schema-conformance-vm.md`,
`../adr/desktop-window-identity-is-a-held-element.md` and a dozen more. Only
`adr-bearer-grants.md` was included. The one I most wanted was
`../design/desktop-schema.graphql`, because it states declared order and is what
the digest is taken over. In the end that did not matter — the spec tells clients
to generate from introspection, which is what I did — but I spent time deciding
whether I was missing something essential. A contract package published to
clients should either inline what clients need or say "these links are internal".

---

## 6. References and mutations

### 6.1 Reference opacity is well specified — no gap

"Opaque `koine://` URI string. Pass it unchanged; only its provider interprets
the remainder", plus "clients cannot construct desktop resource references from
PIDs or window titles", plus the scalar grammar. I never parse, decode,
normalise or construct one, and deliberately never let a reference near
`new URL()`, which would silently normalise percent-escapes and case. The one
thing I would add: an explicit warning that URL-normalising a reference breaks
it, because `new URL(ref).toString()` is exactly what a careless client does.

### 6.2 "Never replay a mutation" and "every command must be safe to run again" are in tension

The spec: a client "never automatically replays a mutation whose result was
lost." The harness driving this client re-runs commands it believes timed out,
which is a replay.

I resolved it by keeping the *client* honest — it never retries a mutation
itself, it returns `classification: "unknown-outcome"` and stops — and letting
the operator re-run. That works for the two mutations in play only because of
facts outside the client: `koineRequestGrant` is explicitly idempotent on
(digest, label, capability set), and `desktopFocusWindow` re-focusing an
already-focused window has the same observable end state.

But the contract never says `desktopFocusWindow` is safe to repeat. It says the
opposite of a guarantee: "A successful focus receipt means the native
focus/raise operation completed against the resolved window; applications may
subsequently change focus." I would have liked one sentence stating whether
re-submitting the same reference is an accepted recovery from an unknown
outcome. As it stands, the safest reading of the contract forbids the thing the
harness requires, and I had to decide that the *effect* being idempotent is
enough.

### 6.3 The non-existent-process case is an inference

Asking about a process that does not exist: `pid` is positive and `startedAt` is
well-formed, so nothing is an input error, and "absent process returns null
without error" should apply — ordinary `absent`. But a pid that exists with a
*wrong* `startedAt` is, by the same rules, also an ordinary null, and so is a
pid belonging to a process the provider cannot see. Three different situations,
one answer. The client reports `absence: "server-null"` versus
`absence: "no-such-running-application"` (resolved entirely client-side) so at
least the local half is distinguishable.

### 6.4 The five published operations do not cover the management half

`desktop-operations.graphql` publishes enrollment, polling, inspection, choices
and focus. There is no published operation for `koineManagement`,
`koineApproveGrantRequest` or `koineRevokeGrant`. This client therefore cannot
approve its own grant — which is correct and deliberate ("A requester without it
cannot approve itself") — but it does mean an end-to-end run needs a human at
Koine's UI or a second, differently generated manager client. Worth stating in
the handoff, since "the five client operations the contract publishes" reads
like the complete client surface.

---

## 7. Things I added that the contract does not sanction

Disclosed rather than buried.

- **`KOINE_ENDPOINT_DESCRIPTOR`.** An environment override for the descriptor
  path, used only so the client can be driven against the stub server in
  `test/`. Unset, the published path is used. The contract fixes one location
  and I did not want to write a fake descriptor into the real one.
- **The compiled C helper** (§1.1). Shelling out to `/usr/bin/cc` at runtime is
  not something a published client should do, and I would replace it with a
  prebuilt native addon or a documented `ps`-precision agreement the moment the
  contract said which instant the provider compares.
- **`command`, `ok`, `absence`, `startedAtSource`, `startedAtPrecision`,
  `candidates`, `outcomeUnknown`, `receiptRefMatchesSubmitted`.** Client-owned
  output fields with no contract meaning, added so a harness can see what the
  client decided locally as against what Koine answered.

---

## 8. Summary of guesses

Ranked by how much damage a wrong guess does.

1. The process start instant's source and exact rendering (§1.1, §1.2). Wrong ⇒
   `desktopApplication` silently returns null for a running application, and the
   null is indistinguishable from "not running".
2. Sending no `Authorization` header on enrollment (§2.1). Wrong ⇒ enrollment
   401s and retries are unrecoverable.
3. `enrollment-conflict` and friends classified `failed` rather than as input
   errors (§3.4).
4. Every `failed` mutation flagged `outcomeUnknown` (§3.5). Over-reports.
5. Error precedence within one response (§3.2).
6. Descriptor `contractVersion` mismatch treated as `service-unavailable` rather
   than its own classification (§4.2).
7. A bodiless 403 classified `request-error` (§3.6).
8. `Reference` and `DesktopProcessStart` mapped to `string` in codegen (§5.2).
9. `getIntrospectionQuery` option set (§5.4).
10. Re-read the descriptor once, retry only on a changed URL (§4.1).
