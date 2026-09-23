# Koine desktop contract

**The desktop contract Koine implements.** The human approved this design,
including the shared resilient Swift framework, one resident Koine application
and bearer credentials with live revocation, and Koine 0.1.0 implements it. The
served schema matches [the design schema](../design/desktop-schema.graphql)
under a repeatable check, and the platform behavior is verified on the notarized
build in Gatekeeper-enforcing VMs. "Test seams and acceptance" says, case by
case, what is established and by which evidence, and what is still open. One
part of the contract is being replaced before the first public release: process
identity and the native effect promise, detailed in "Public GraphQL contract"
and "Native targeting discussion". Client authors start at the
[client guide](../client-guide.md).

## Purpose and ownership

Koine owns the Machine server contract. Its first deliverable lets a local
client obtain a grant, resolve the running application captured at interaction
start, list that application's windows, and focus a selected window. The native
macOS management UI and GraphQL management operations ship in that deliverable.
ModalAnyware owns its interaction, configuration facade and Machine client.

The [server boundary](../adr/koine-server-and-native-providers.md),
[provider framework](../adr/resilient-provider-framework.md),
[opaque references](../adr/machine-references-as-uris.md) and
[bearer grants](../adr/bearer-grants-and-live-revocation.md) record the accepted
decisions. The [architecture views](../design/architecture/README.md) explain the
contract. The Machine core remains a Swift
package without macOS, client or concrete-provider dependencies.

## Application composition and availability

One resident, per-user Koine application process contains the native
management UI, HTTP listener, Machine core, native loader and loaded providers.
The UI closes without terminating the listener or observers. Explicit Quit
stops Koine and makes the endpoint unavailable. A client never launches Koine,
waits for an on-demand plugin process, or owns its lifetime.

Use the signed Koine application as a login item through
`SMAppService.mainApp`. The user starts Koine and enables login launch during
setup; the OS starts it on subsequent logins. If the user disables login
launch, logs out, quits Koine or Koine crashes, clients report service
unavailability. This first arrangement does not promise automatic crash
relaunch. It requires macOS 26 or later on Apple Silicon. That is the supported
OS/CPU release matrix, narrowed at release acceptance to what was actually run
rather than to what a deployment target could be set to: Koine is verified on
macOS 26 on arm64 and claims nothing about any other OS or architecture.
Evidence: [latency-and-support-matrix.md](../verification/latency-and-support-matrix.md).

A single process gives Accessibility a clear owner and supplies a native local
management console without a separately bootstrapped management application.
Resident observation also preserves the desktop provider's knowledge of windows
seen on other Spaces. Socket activation saves idle residency but adds cold
startup and loses observation while absent; neither saving is a requirement.
These are the composition's rationale, not measured latency claims.

Koine calls the platform's Accessibility trust check in its own process. Only
its UI requests OS consent and explains which application needs permission.
Remote GraphQL callers may inspect permission status with the appropriate
capability, but cannot trigger an OS consent dialog through a read. ModalAnyware
receives `permission` with the OS-permission classification and directs the
user to Koine; it does not request Koine's permissions for itself.

Of the desktop fields, `DesktopApplication.windows` and `desktopWindow` need
Accessibility consent. An application's `ref`, `name` and `bundleIdentifier`
resolve without it, as does every `unavailable` that the reference, the process
incarnation or the provider run already decides. The provider's trust check has
no prompt option.

Apple documents [main-app login launch](https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp)
and [the current-process Accessibility trust check](https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions).
Login launch with no client installed and the Accessibility attribution of the
notarized application are verified in Gatekeeper-enforcing VMs:
[release-acceptance-vm.md](../verification/release-acceptance-vm.md) and
[notarized-release-vm.md](../verification/notarized-release-vm.md).

## Local transport and discovery

The listener binds only IPv4 `127.0.0.1`, requesting an available port from the
OS. After loading the schema and becoming ready, Koine atomically publishes a
version-1 endpoint descriptor at
`~/Library/Application Support/Koine/endpoint.json`. Its containing directory
is user-only (0700), and the descriptor is user-readable/writable only (0600).
It is a JSON object of `descriptorVersion` (the number `1`), `instanceId` (a
string), `pid` and `port` (numbers), `path` equal to `/graphql`, and
`contractVersion` equal to `koine-desktop/1`. It contains no credential. A client
that does not know the `descriptorVersion` must not use the file, and one that
does not target the `contractVersion` must not proceed: that is an incompatible
service, not an unavailable one. `pid` is Koine's own diagnostic, and clients
ignore it. Clients construct the literal loopback URL; they do not follow an
arbitrary host or scheme from a file. Shutdown removes only its own descriptor.
A process lock prevents a second Koine instance from becoming a second writer:
an instance holds an exclusive BSD `flock` on `instance.lock` in the same
directory from before it opens the grant store until it has withdrawn its
descriptor, and a second instance fails to start. The OS releases the lock when
its holder exits for any reason, so there is no stale lock to detect. The lock
holder deletes any descriptor it finds before it starts: under the lock such a
descriptor was left by a dead instance, and its `pid` and `port` are not
evidence of anything.

A client reads the descriptor on connection and again after connection failure.
It may reconnect for a subsequent request; it never automatically replays a
mutation whose result was lost. An absent/stale descriptor is service
unavailability, not a cue to launch Koine. `instanceId` distinguishes server
runs; it is neither authentication nor a reference lifetime guarantee, but a
changed `instanceId` does mean every window reference a client holds is
`unavailable` ("Resource references and desktop behavior"). These rules assume
a non-browser HTTP client: one that adds an `Origin` header cannot be used. The
file and plain loopback HTTP trust the logged-in user's machine and account;
they do not protect against malicious code running as that user. HTTP cannot
prove the executable identity represented by a client-supplied label.

Accept one JSON GraphQL request per HTTP POST to `/graphql`, with `query`,
`variables` and, when needed, `operationName`. Require `Content-Type:
application/json` and support `Accept: application/graphql-response+json`.
No GET operations, batching, subscriptions, uploads or incremental delivery are
part of version 1. Reject browser `Origin` requests, including `Origin: null`,
and validate Host against the literal bound loopback address and port. Do not
use cookies, query-string credentials, redirects or wildcard CORS. These rules
keep websites from driving a local native-control endpoint; they do not isolate
local native programs from each other.

Set `Cache-Control: no-store` on every response. Unsupported media
types/methods and malformed HTTP are transport errors. They carry no GraphQL
body and are decided in this order, before the credential is examined: any
`Origin` header, 403; a `Host` other than the literal bound `127.0.0.1:<port>`,
or none, 421; a request target other than exactly `/graphql` (a query string
makes it another target), 404; a method other than POST, 405 with
`Allow: POST`; a `Content-Type` other than `application/json` (parameters
allowed), 415. A body over the size limit is 413 and closes the connection.
After authentication, a body that is not one JSON request object, which includes
a batch array, is 400. The response is `application/graphql-response+json` when
`Accept` lists it and `application/json` otherwise. Authentication is evaluated
for every request; a connection carries no authority from one request to the
next. GraphQL syntax, validation and variable-coercion
failures return HTTP 400 with `errors` and no `data`. A credential that names no active grant and no
request whose status it may read, including a revoked one, returns HTTP 401 with
no body before execution. A pending, denied or expired request's credential is a
status-only principal ("Client-requested grant"): it authenticates, and every
operation but its own status is refused as `permission`. A request without a
credential is anonymous and is 401 unless it is enrollment; enrollment carries no
`Authorization` header, and one presented with any credential is refused.
Anonymous enrollment over its rate limit returns HTTP 429 ("Client-requested
grant"), whose errors carry no `extensions.kind`. An authenticated mutation
rejected by capability preflight returns HTTP 403 with `errors` and no `data`;
a 403 with no body is the `Origin` refusal above. Each denied root action has its
response alias in `path` and carries `extensions.kind: permission`,
`permissionClass: capability`, and `phase: authorization`.
Executed operations return HTTP 200 with
GraphQL `data` and any execution errors, including non-null propagation to
`data: null`. The body, not HTTP success alone, determines the operation result.
This is the selected subset of [GraphQL over HTTP](https://http-spec.graphql.org/draft/).

Bound parsing and execution: initially 1 MiB request bodies, depth 16, 1,000
expanded field selections, and 10 root mutation actions per request. Expand
fragments with cycle detection before counting. Reject over-limit requests
before provider callbacks; cap response materialization at 8 MiB and execution
at 5 seconds. A timeout after an action begins does not prove that it failed.

Depth counts field levels and selections count fields, in every operation of
the document, each fragment counted at every spread and `@skip`/`@include`
ignored. Query text whose brackets nest deeper than 64, or whose fragment
spreads and inline fragments chain deeper than 64, is also over-limit: that
bound is checked before parsing and protects the parser itself. An over-limit
request is a request error: HTTP 400 with `errors` and no `data`, decided before
validation and before capability preflight. A response over its cap and an
execution past its deadline are executed operations: HTTP 200 with `data: null`
and one error with `extensions.kind: failed` and an empty `path`. Neither says whether
a requested action ran. At the deadline Koine answers the caller, cancels execution
cooperatively and starts no further resolver; it does not interrupt a resolver
already running. The values are one named, versioned policy in the Machine core
(`RequestPolicy.version1`).
Provider-native work must use bounded OS calls and cooperative cancellation.
These limits are versioned policy, not a promise to interrupt arbitrary native
code or to undo actions.

## Public GraphQL contract

`koine-desktop/1` names the first public contract, separately from plugin ABI
versions. The [schema](../design/desktop-schema.graphql) states exact
types and nullability; the [client operations](../design/desktop-operations.graphql)
show the handoff's requests. The schema Koine serves matches the schema file,
checked by `task conformance` against the notarized build
([schema-conformance-vm.md](../verification/schema-conformance-vm.md)), and the
five operations run unmodified from a client generated only from the documented
contract ([contract-only-client.md](../verification/contract-only-client.md)).
The operations are the handoff's path, not a complete catalogue: a client may
write its own, and none is published for management. The complete executable schema includes core management types and
all active provider contributions. Every active authenticated grant, including
one with no provider capabilities, can introspect that whole schema; discovery
is not execution authority. Schema descriptions include resource-reference
opacity, field capabilities and permission classifications. Standard GraphQL
code generation consumes introspection; no private schema channel is required.
Schema admission must preserve full standard introspection within the server's
request/response limits. If adding a provider would exceed those limits,
reject the contribution with a management diagnostic instead of exposing a
schema that authenticated code-generation clients cannot fully inspect.

Three limits of the seam are the GraphQL library's rather than this contract's,
measured against a running server in `SchemaConformanceTests` so that a library
that lifts one is noticed here. Koine's own schema exercises none of them, and
the introspection query a standard code generator sends is unaffected.

- `__Type.fields` and `__Type.inputFields` come back **sorted by name**, not in
  declared order. Declared order is therefore not recoverable from introspection,
  which is consistent with clients comparing the schema digest rather than
  recomputing it.
- `__InputValue.isDeprecated` is served as null against a non-null declaration,
  so a query that selects it — what `getIntrospectionQuery` sends under its
  `inputValueDeprecation` option — fails at that position instead of answering.
  No argument or input field in this contract is deprecated.
- An **input-object field's default** is not reported, while an argument's is. No
  input-object field in this contract has a default.

The following signatures define the desktop surface; the management surface's
are in "Management authority and surface", and introspection serves both. `Reference` is a
custom scalar serialized as a URI string; `ID` names management records only.
`DesktopProcessIdentity` contains a positive `pid: Int!` and
`startedAt: DesktopProcessStart!`, the
process start instant in canonical UTC with six fractional second digits. A
client captures both at interaction start. The provider compares both before
resolving; a recycled PID must not select a new application. A missing reliable
start instant is an input error, not permission to silently target by PID alone.
The instant is the kernel's record of the process's start, as
`proc_pidinfo(PROC_PIDTBSDINFO)` reports it in `pbi_start_tvsec` and
`pbi_start_tvusec` (`sysctl` `KERN_PROC_PID` reports the same record as
`kp_proc.p_starttime`), written exactly as `YYYY-MM-DDTHH:MM:SS.ffffffZ` and
compared exactly; any other form is an input error. Locating the process is the
client's: Koine offers no lookup by name or bundle identifier.

**Still open: this identity is to be replaced before the first public release.**
The human rejected time as a process identity, since it cannot guarantee that
two processes never collide, and `process-identity-without-time` designs a
mechanism that does not depend on time. Until it lands, the paragraph above is
what Koine serves, and the input type, the application-reference encoding and the
schema digest are expected to change.

The replacement preserves callback-time foreground capture as defined by the
[capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md) and
expires with the captured OS process, including automatic termination. It must
not follow a restored logical application into a new process. Public Process
Manager serial numbers plus boot identity fail that requirement in the
[native lifetime experiment](../verification/process-serial-lifetime.md).
[The capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md)
records these agreed boundaries; native transfer, reference lifetime across
Koine restart and action binding remain to be designed. The SDL below still
describes the currently served timestamp input, not an approved replacement.

The future effect contract is **endpoint addressing only**, as recorded in the
[effect-boundary decision](../adr/desktop-effects-use-the-admitted-endpoint.md).
Capture/reference expiry remains tied to the original process,
but receiver movement, descriptor reuse, forwarding and queued downstream work
may affect another window in the same live process or another process, including
a restored successor. Read/notification provenance remains required. No behavioral
application-support profile is selected. Authenticated observed closure permanently
retires a window reference; undetected closure/descriptor reuse may still affect
another window. The direct AX endpoint remains unadopted as a shipping
mechanism; it can be evaluated against this revised boundary after design review.
Lifecycle, consent, the complete protocol and first release remain unresolved.

The [native targeting discussion](#native-targeting-discussion) presents the
agreed future boundary and its evidence obligations. The served schema has not
yet changed to implement that agreement.

Retained AX objects are insufficient for that native binding:
[an actual PID-recycling experiment](../verification/retained-ax-binding.md)
made an old held window minimize a replacement process. The original task-name
right had become dead, while the AX object and its held application parent
answered again. That wrapper retention does not establish the unchanged native
destination now required; a task check followed by a fresh PID-addressed action
is still excluded.

| Coordinate | Type / arguments | Meaning and authority |
|---|---|---|
| `Query.koine` | `Koine!` | Server version and caller's grant; authenticated |
| `Query.desktopApplication` | `(process: DesktopProcessIdentity!): DesktopApplication` | `desktop:read`; absent process returns null without error |
| `Query.desktopApplicationByReference` | `(ref: Reference!): DesktopApplication` | `desktop:read`; stale reference is an execution error |
| `Query.desktopWindow` | `(ref: Reference!): DesktopWindow` | `desktop:read`; stale reference is an execution error |
| `DesktopApplication.ref` | `Reference!` | Opaque application reference |
| `DesktopApplication.name` | `String!` | Display name; empty if the OS supplies none |
| `DesktopApplication.bundleIdentifier` | `String` | Ordinary null for a process without one |
| `DesktopApplication.windows` | `[DesktopWindow!]!` | On-demand provider resolution, including remembered windows |
| `DesktopWindow.ref` | `Reference!` | Opaque window reference |
| `DesktopWindow.title` | `String!` | Empty is a legitimate untitled window |
| `DesktopWindow.observation` | `DesktopObservation!` | `CURRENT` or `REMEMBERED`; remembered display data may be stale |
| `Mutation.desktopFocusWindow` | `(ref: Reference!): DesktopFocusReceipt` | `desktop:control`; focus exactly this target or report failure |
| `DesktopFocusReceipt.ref` | `Reference!` | The submitted target, under the mutation's control authority |

The schema file states these coordinates in **composition order** — the core's
own root fields, then the bundled provider's — because the digest is taken over a
canonical text that keeps declared order, and composition is what fixes it. Two
descriptions in that file were reconciled to the implementation against this
section when the whole schema was first checked (`schema-conformance-k40`):
`Koine.schemaDigest` and `KoineManagement.osPermissions` gained the descriptions
the server serves, and `Mutation.desktopFocusWindow` took the row above over the
mutation-preflight sentence it previously carried — preflight is a property of
every mutation, stated under "Mutation preflight and revocation", not of this
one field.

All provider-owned read fields, including references and nested properties,
require `desktop:read`. The receipt is a distinct output type authorized by
`desktop:control`; it does not expose a window's read fields. That sentence is
the type's description and the row above is `ref`'s; both belong in the schema. Read and control
are separate capabilities; neither implies the other. ModalAnyware normally
requests both. Root lookups and the mutation result are naturally nullable:
absence and failure remain distinguishable by the presence of an error.
Domain fields and window list elements retain meaningful non-null types.

The client first resolves the captured process and selects `ref`, `name`, and
`windows { ref title observation }`. It derives and presents choices locally.
When the user chooses, it submits the returned window reference unchanged to
`desktopFocusWindow`. A new reconstruction makes a new query. Introspection
and the provider's read capability do not create a subscription or cache.

### Schema digest

`Koine.schemaDigest` is the SHA-256 digest, as 64 lower-case hexadecimal
characters, of the UTF-8 bytes of a canonical SDL text of the complete executable
schema after composition. The text is every custom directive definition sorted
by name, then every named type sorted by name, each printed in the graphql-js
`printSchema` format with its description, and joined by one blank line. Sorting
is by Unicode code point. Introspection types, built-in scalars, built-in
directives and the `schema` definition are omitted; fields, arguments and enum
values keep their declared order.

One implementation computes this text and this digest, and both callers use it:
the server, for the value `Koine.schemaDigest` reports, and `task conformance`,
which prints the schema file above through the same rules and compares the two.
A second printer would make its own disagreements look like schema drift.
Evidence: [schema-conformance-vm.md](../verification/schema-conformance-vm.md).

The digest is an equality token. It is identical across restarts of one Koine
build with one set of active provider contributions, whatever order they were composed
in, and differs when any served type, field, argument, nullability, default,
deprecation or description differs. Clients compare it with the digest they generated against to learn that they
should introspect again; they do not recompute it. A Koine upgrade may change
the digest of an unchanged schema if its printer changes; that costs a client one
unnecessary introspection and never hides a change.

### Composition and operation placement

A provider registers one immutable identifier and one unique GraphQL prefix.
The bundled provider owns `desktop` and `Desktop`; the core owns `koine` and
`Koine`, root types, shared scalars and policy directives. Plugin bundles
supply SDL plus a resolver/authorization registration for every contributed
field. Each custom type, input, enum and directive has its provider prefix.
Root query and mutation names start with the lower-case prefix. Reject
collisions, reserved names, duplicate ownership, missing resolvers, invalid
SDL and unclassified fields before publishing any contribution from that
plugin. Reject both competing external providers for a duplicate identifier;
never select an arbitrary winner. An external plugin cannot replace `desktop`.

A provider identifier is a lower-case letter followed by lower-case letters and
digits; it is also the reference authority and the prefix of the provider's
capabilities. A prefix is a capitalised alphanumeric GraphQL name. Two prefixes
may overlap (`Git`, `GitHub`); a name two providers both define refuses both.
Each contribution is validated against the core schema alone, so it cannot use
another provider's types, and its refusal never depends on which other providers
loaded. Accepted contributions are composed in a canonical order, the bundled
provider first and then by identifier. A refused provider is not started.

Version 1 narrows what a contribution may hold. It uses only its own types, the
built-in scalars and `Reference`; an extension of `Query` or `Mutation` adds
fields and nothing else. Interfaces, unions, input-object default values and
output lists with nullable elements are refused, because the engine cannot yet
serve them faithfully. Provider SDL is held to the request policy's nesting
limit, and the composed schema must pass GraphQL schema validation.

Version 1 permits adding owned root fields and owned types, not extending
another provider's types or replacing core fields. References may cross through
the shared `Reference` scalar; using one never grants access. Provider-private
custom scalars/enums must be introspectable. Any later shared object interface
or cross-provider field extension requires an explicit composition contract.
This bounds the current composition problem without hiding provider schemas.

Only root Mutation fields may perform domain actions. Query and nested-output
resolvers must be side-effect-free apart from private OS observation.
Composition enforces the part it can see: a root Mutation field must require the
provider's control capability, and no field on `Query`, or on a type a query can
reach, may require it. A type reached only from a mutation result may, as the
desktop receipt does. A nested
`desktop { focusWindow }` mutation namespace is invalid for this contract:
it would move actions outside GraphQL's serial root-mutation semantics.

Store authorization by original schema coordinate and resource-owner authority,
not response alias. Expand fragments, merge fields by GraphQL rules and evaluate
`@skip` / `@include` with coerced variables. Check each read field before calling
its resolver, including scalar defaults and alternate reference lookups. A
field whose arguments hold a reference owned by another registered provider also
requires that owner's capability of the field's own class, read or control; the
owner is read from the reference's authority, never from its remainder. A
reference whose authority is unregistered has no owner to check and is
`unknown-provider` at execution. A
provider cannot mark its fields public or mint management authority. Provider
metadata can require its own read/control capabilities; only core registrations
can designate public enrollment or management authority.

### Mutation preflight and revocation

Before any requested action begins, parse, validate and coerce the selected
operation; collect every selected root mutation action; resolve its static
capability requirements and any reference authorities from its arguments; and
verify all against the presenting principal's current authority. This phase
performs no provider resolution
or OS action. All action requirements must be knowable from schema metadata and
coerced inputs; a plugin requiring runtime-dependent authority cannot register
that action in ABI version 1. Deny the whole operation if any action fails.
Skipped actions and other unselected operations in a document do not count.

After successful preflight, execute root mutations serially in GraphQL order.
Before each action dispatch, recheck the admitted principal: a client grant
must still be active; the in-process local console supplies management
authority without a grant; anonymous enrollment admits only the single
`koineRequestGrant` action. These are distinct, explicit admission cases, not
an HTTP fallback to console authority. Grant
revocation and dispatch admission use the same serialized authority boundary:
if revocation commits first, that action cannot start; if dispatch wins, that
action is in flight and may finish. No subsequent action may start under a
revoked grant. A failing or revoked later action does not undo earlier work.
Provider-owned effects within one admitted action may already be underway;
best-effort cancellation is not rollback or forcible plugin interruption.

For reads, check authority before each protected resolver and again before
publishing its result. Revoke suppresses results not yet admitted for response
publication; bytes already sent cannot be recalled. HTTP keep-alive retains no
authentication decision: every request authenticates and every action dispatch
checks current authority. Disconnection requests cancellation but does not prove
that an already started focus or management mutation was undone.

Management actions in the same operation cannot supply authority to later
actions: preflight uses only the presenting principal's existing authority. Mutation
output reads still use ordinary read authorization and GraphQL propagation;
a denied output field is not evidence that the preceding action did not occur.
The desktop receipt avoids that ambiguity for the common control-only call.

### Errors and partial data

Execution errors carry `message`, standard response `path` (including aliases
and list positions), and `extensions.kind`. Permission errors add
`extensions.permissionClass`, either `capability` or `os-permission`.
Capability errors identify the required capability in
`extensions.requiredCapability`, without revealing protected resource existence. OS errors identify `accessibility` and Koine as the
permission owner, in `extensions.osPermission` and `extensions.permissionOwner`
(`koine`). Capability errors also carry `extensions.phase`: `authorization`
when preflight refused the operation before any action, `execution` when a field
was refused as it ran — a read, or a mutation action whose grant was revoked
after preflight. An unavailable error may echo a reference the caller supplied,
not disclose an otherwise unauthorized resource. Never expose tokens or native
stack traces. Every propagated error retains the original failure path.

`extensions.kind` takes exactly four values in `koine-desktop/1`: `permission`,
`unavailable`, `unknown-provider` and `failed`. The set is closed for this
contract version; it is stated here rather than as a schema enum because
extensions are not part of a GraphQL schema. An execution error with a non-empty
`path` and no `kind` is an argument a provider found invalid, reported as input coercion;
nothing was attempted.

| Condition | Classification |
|---|---|
| Malformed GraphQL, unknown fields or arguments | GraphQL request validation; no domain execution |
| Malformed URI scalar or process identity | GraphQL input coercion; no action |
| Well-formed reference names an unregistered provider | `unknown-provider`, after applicable capability checks |
| Known authority, wrong resource kind, malformed provider remainder, or gone target | `unavailable` |
| Missing client read/control/management authority | `permission`, `capability` |
| Koine lacks platform consent | `permission`, `os-permission` |
| OS operation fails, native timeout or malformed provider output | `failed` |

The inherited `unknown-relation` and `unknown-command` are replaced on the
public surface by GraphQL validation: clients no longer submit relation or
command strings. They are not silently mapped to `unavailable`. ABI resolver
registration mismatches are host/plugin defects and become `failed`, with a
separate management diagnostic. Transport unavailability and an unknown mutation
outcome are client transport states, not invented successful GraphQL results.

A root lookup that is null with no error is absence; one that is null with an
error is that error, whatever deeper path the error carries.
A read denial produces an execution error, not an empty list or ordinary null.
Apply standard non-null propagation: a denied non-null field can discard its
nearest nullable parent, and can make all `data` null. Other branches survive
where their types permit. Successful mutation preflight guarantees authorization
before actions, not a transaction. One response can carry several errors, and
the contract sets no precedence among them. A `failed` mutation is not evidence
that nothing happened: a deadline or response-cap error (an empty `path`) says
nothing about the actions, a deadline can also be met at an action's own path,
and a provider may fail a step after an earlier one took effect, as focus can
fail after activating the application. These rules use the
[GraphQL execution model](https://spec.graphql.org/September2025/#sec-Execution).

## Grants and management

Use opaque bearer credentials. One credential identifies one persistent
grant containing a set of capabilities. Version 1's capabilities are the core's
`koine:manage` and, for each active provider, `<providerId>:read` and
`<providerId>:control` — `desktop:read` and `desktop:control` for the bundled
provider. `Koine.availableCapabilities` lists them to any active grant, and a
name it does not list is refused wherever a capability set is submitted. A client
presents it in `Authorization: Bearer <credential>`. Koine reads the granted set
from its store; an unsigned capability list from the caller supplies no
authority. Version 1 does not combine several grants into one request.

Use 256 random bits encoded as unpadded base64url for bearer secrets. Hash the
decoded 32 bytes; represent the SHA-256 digest as 64 lower-case hexadecimal
characters. Reject noncanonical or incorrectly sized encodings. Store only
these digests in Koine's grant records and compare in constant time. A token
has no expiry, and a grant remains valid until explicitly revoked. The grant
store is an atomic, durable database in Koine's user-only application data
location. Persist immutable grant identity, client label, capabilities, digest
and revocation state. Revoke commits durably before reporting success and
updating admission; storage failure fails the mutation without claiming
revocation. A corrupt/unreadable store fails closed; it is never replaced with
an automatically privileged default.

Clients store secrets in their own Keychain items; Koine's UI does not retrieve
existing bearer secrets from the digest store. Manual credentials are displayed
only on creation and then held by the recipient. Scripts may use a user-only
credential file when Keychain access is impractical. Neither a label, bundle
identifier, user code nor a process ID proves a HTTP client's executable
identity. The UI states what is being approved and lets the user compare a
request code with the requesting application. Loaded native plugins are trusted
server code and can compromise the store; client capabilities are not a sandbox
for them.

### Client-requested grant

The client creates and securely stores its future random bearer secret, then
calls the public `koineRequestGrant` mutation with its digest, a display label
and the requested capabilities. Koine returns a request ID and a short,
non-secret comparison code. The code is random, not derived from the digest,
and is displayed and compared as an opaque string; its alphabet and length are
not contract. Request capabilities must be known — an unknown one is `failed` when
submitted, and nothing is stored — and are fixed once submitted. A pending request conveys no provider or management authority.

Credential digests are globally unique across requests, active grants and
revoked-grant tombstones. An enrollment retry with the same digest, label and
capability set returns the original request ID and code, even after approval;
changed label/capabilities return a conflict. Approval promotes that one request
to at most one grant atomically. An active or revoked digest cannot create a
new request or grant. Denied/expired requests also require a fresh secret to
start again. Manual generation retries a random collision before committing.
Thus a lost response cannot split the identity whose revocation is observed.

The native UI shows the label, code and exact capability set. The user approves
or denies there; alternatively an already authorized management client may make
the same decision through GraphQL. Approval atomically creates an active grant
bound to the submitted digest and the approved subset. The requester polls
`koineGrantRequest` using possession of its proposed bearer secret. It can see
only its own request state and resulting grant metadata; it cannot list other
requests or approve anything. Denial is explicit. No secret travels back in a
poll response, so losing the approval response does not strand the credential.

Persist decisions across Koine restarts. Pending requests expire after 24 hours;
this never expires an approved grant. Proof of the submitted secret authorizes
only the request's own status while pending, denied or expired. After approval,
the active grant still authorizes that same status query. A revoked grant
instead receives HTTP 401. Keep terminal request status for seven days, after
which lookup returns `unavailable`; retain digest uniqueness tombstones so
deletion cannot resurrect authority. Limit unapproved requests and rate-limit
enrollment independently of authenticated execution. Anonymous access is
limited to creating a request. Status-only credentials cannot be mixed with
ordinary operations to acquire extra authority.

A request pending 24 hours after submission is `EXPIRED` to every reader and to
both decisions, which answer `already-decided`; expiry is terminal and starts
its own retention. Retention runs seven days from the decision, or from the
moment of expiry. After it the request leaves `koineManagement.requests`, a
decision on its ID is `unavailable` like an ID that names nothing, and
`koineGrantRequest` raises `unavailable` with a null result, both to the
status-only secret and under the active grant an approved request produced:
null there means no request produced the grant, which would be false. The grant
itself is unaffected, and a secret stays status-only for ever. Submission and
decision instants are stored as wall-clock time, so both periods hold across a
restart. The embedding host may give the server its time source at
construction; no GraphQL field, HTTP header or environment variable reaches it.

At most 16 requests are pending at once. A further `koineRequestGrant` is
refused with `pending-request-limit` and stores nothing; an identical retry of
a stored request is still answered, and a decision or expiry frees a slot.
Anonymous enrollment has its own budget, 10 operations in any 60 seconds for
the whole server, since every local process shares the loopback address. It is
spent by each operation admitted as anonymous enrollment, retries included,
after parsing and before validation. Over budget the answer is HTTP 429 with
`Retry-After` in seconds, `errors` and no `data`: no action began, so there is
no action path to carry a GraphQL execution error. Nothing else spends or is
refused by that budget: authenticated clients, status-only polls, the local
console, and requests without a credential that are not enrollment, which stay
401. These four values and the two periods belong to `RequestPolicy.version1`.

### User-created grant

From the native UI, the user chooses a label and capability set and creates a
grant. Koine generates the random bearer secret, commits its digest and displays
the secret once for manual delivery. The equivalent `koineCreateGrant` mutation
requires `koine:manage` and returns the one-time secret to that caller. Existing
grant queries never return secrets. If delivery is lost, revoke that grant and
create another; do not make a secret readable indefinitely for recovery.

### Management authority and surface

The native UI has a private local-console principal created in process. It
executes the same GraphQL management operations through the same authorization
and storage path, with `koine:manage`. This principal has no serialized token,
HTTP header, URL, or public resolver that can create it. Direct user interaction
with the installed Koine UI supplies the initial trust; an incoming request
cannot impersonate a button click. A single native app means no privileged
helper credential has to be exported for bootstrap. Recovery from lost manager
credentials uses this UI, not an unauthenticated reset endpoint.

Ordinary loopback HTTP management still requires an explicitly approved
`koine:manage` grant. Approval of that capability is shown prominently because
it permits issuing and revoking other grants. A requester without it cannot
approve itself. There is no automatic first-client administrator and no shared
master token in the endpoint descriptor.

| Surface | Authority and result |
|---|---|
| `Query.koine` | Active grant; contract version, instance ID and own grant metadata |
| `Query.koineGrantRequest` | Request-secret proof or its resulting active grant; only its own request status within retention |
| `Query.koineManagement` | `koine:manage`; requests, grants, provider status and OS permission status |
| `Mutation.koineRequestGrant` | Anonymous enrollment, one request per operation |
| `Mutation.koineApproveGrantRequest` / `koineDenyGrantRequest` | `koine:manage`; approve a subset or deny a pending request |
| `Mutation.koineCreateGrant` | `koine:manage`; durable grant plus one-time credential |
| `Mutation.koineRevokeGrant` | `koine:manage`; durable, idempotent revocation |

`koineRevokeGrant` returns the grant as committed, with state `REVOKED`;
repeating it returns the same result. A grant ID that names no grant raises
`unavailable` at the action's path with a null result, rather than ordinary
null: the caller asked to end an authority, and must not mistake a mistyped ID
for a completed revocation. A grant may revoke itself. The revoked principal is
no longer admitted, so output fields of that action selected under it are
refused like any other read; the revocation still stands.

Core management types use the `Koine` prefix. Management errors use the same
permission vocabulary and propagation as provider errors. Record missing,
already-decided and invalid-subset request outcomes explicitly; approval cannot
resurrect a denied, expired or revoked request.

Request outcomes raise an execution error at the action's path with a null
result and change nothing. Those that share a `kind` are told apart by
`extensions.reason`, which is additive to the error shape above and absent from
every other error:

| Outcome | `kind` | `extensions.reason` |
|---|---|---|
| Approve or deny a request ID that names nothing | `unavailable` | none |
| Approve or deny a request that is approved, denied or expired, including one whose grant was since revoked | `failed` | `already-decided`, with the request's state in `extensions.requestState` |
| Approve a capability that was not requested | `failed` | `invalid-subset` |
| `koineRequestGrant` with a known digest and a different label or capability set | `failed` | `enrollment-conflict` |
| `koineRequestGrant` with the digest of a grant no request produced, active or revoked, or of a request whose status is past retention; or approval of a request whose digest a grant already holds | `failed` | `credential-in-use` |
| `koineRequestGrant` with a new digest while the most pending requests allowed are waiting | `failed` | `pending-request-limit` |
| Store or commit failure | `failed` | none; the request is still pending |

An empty approved subset is valid: it creates a grant that authenticates and
holds no capability, as `koineCreateGrant` does for an empty set; denial is how a
manager refuses. An identical enrollment retry returns the original receipt in
every state of its request, denied included, and never starts a second request.
It is answered on the digest, label and set alone, so the receipt, like the
comparison code in it, is not secret; capability sets compare
without order or duplicates. A conflict discloses nothing of the request it
met. Native UI affordances cover
request review, manual creation, grant listing/revocation, service status and
OS-permission guidance. Plugin installation/trust is a local user operation,
not an extra meaning of a client's `desktop:control` grant.

## Resource references and desktop behavior

The `Reference` scalar accepts canonical `koine://<provider>/<remainder>` URI
strings, with no userinfo, port or fragment. The scheme is lower-case, the
authority is exactly a provider identifier, and the remainder is URI path and
query text with well-formed percent escapes. The engine validates the envelope
and routes by authority only. After the capability check it reads the provider
of every reference among a field's arguments; a reference naming another
registered provider still reaches the field's own provider, which reports
`unavailable`. Providers own percent encoding, resource kind
and remainder interpretation. A provider root has an empty remainder. The
scalar maps to an opaque string wrapper in client bindings; clients cannot
construct desktop resource references from PIDs or window titles.

The following reference/focus behavior describes the served timestamp design.
Its exact-target guarantee is not established across native PID reuse, and the
agreed [future endpoint-addressing contract](#native-targeting-discussion)
replaces that effect promise before release. Its wire shape and restart rules
are still pending; the existing focus receipt must not silently acquire the
weaker meaning.

The desktop provider encodes a process incarnation in application and window
references. A window reference additionally carries its native window identity
and provider-owned discrimination information. Each use re-resolves the target;
a matching PID alone or another window with the same title is insufficient.
Title fallback may be used only when the provider can establish the same target
unambiguously. If that cannot be established after closure, PID reuse, restart
or ambiguous native identity, return `unavailable`; never focus a substitute.
Do not promise every window reference survives a provider/server restart.
References with sufficient stable identity may resolve again; others explicitly
become unavailable. The engine maintains no handle table.

Enumerate real windows of the requested application. Empty titles are valid.
Do not manufacture window rows for applications with no known windows. Include
provider-remembered windows from other Spaces with `REMEMBERED` observation;
current enumeration refreshes observations and known destruction/termination
removes them. The remembered list is incomplete if Koine has never observed a
Space and may include a window whose disappearance is not yet observable.
A selection always revalidates; remembered display information is not proof
that a window exists. This preserves useful observation across Spaces without
claiming complete current knowledge.

The provider may activate the owning application to bring a known target into
view as part of focusing it. Check consent and identity before that action,
report OS failures rather than swallowing them, and acknowledge that later
steps can fail after activation. A successful focus receipt means the native
focus/raise operation completed against the resolved window; applications may
subsequently change focus. A stale target produces `unavailable`, never silent
success. The served design uses the window's
accessibility element, held by the provider and named in the reference by the
provider run and a token, as recorded in
[desktop window identity is a held element](../adr/desktop-window-identity-is-a-held-element.md)
with its [evidence](../verification/desktop-window-identity.md). A window
reference therefore does not survive a restart of Koine, and title fallback is
never used. An application reference encodes the process incarnation alone, so it
resolves again after a restart of Koine for as long as that incarnation runs. Modaliser's private window-number lookup and title fallback are not
proof of identity and are not used.

The engine caches no graph results, refreshes nothing and retries nothing.
Provider OS observations are private state, not retained snapshots for callers.
One GraphQL operation can resolve multiple fields at different instants; it
establishes no atomic snapshot across fields, calls or providers.

## Native extensions — shared resilient Swift framework

The selected binary interface is a shared Swift framework, as recorded in
[resilient provider framework](../adr/resilient-provider-framework.md).
`KoineProviderAPI` contains provider contracts and resilient value types;
the Machine core uses it without depending on a concrete provider or macOS.
The native host and every provider dynamically link the same framework image,
distributed with Koine. A plugin must not embed another copy, statically link
the framework, or substitute its own framework under the same module identity.

Build the framework with `BUILD_LIBRARY_FOR_DISTRIBUTION=YES` (library evolution
and textual module interfaces) from its first release, in all distributed build
configurations. Give the major-1 framework one stable module and install name:
module `KoineProviderAPI`, install name
`@rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI`. The application
supplies its trusted run path. Plugin bundles contain a Swift
dylib, declarative manifest and schema. Their manifests declare provider ID,
GraphQL prefix, plugin/schema versions, CPU architecture, minimum OS/runtime,
required framework major and minimum minor, required host features, and a unique
Objective-C-visible principal-class name. Their runtime descriptors must agree.

Load-time compatibility precedes executable negotiation. Before loading a
plugin, check its declared framework major/minor and feature requirements
against the host's bundled framework. Version 1 supports exactly framework
major 1; reject an unsupported major, unavailable minor or feature with a
management diagnostic before loading the dylib. An ABI negotiation callback
cannot rescue a plugin already linked against symbols the host lacks.
Dependency validation and dynamic-loader failures remain explicit refusals if a
manifest lies or the binary does not match it.

After verified loading, find the manifest's principal class using
`NSClassFromString` and require conformance to the shared framework's
`ProviderFactory` protocol. The plugin supplies an NSObject-derived, explicitly
named class; its factory produces a `Provider` instance through ordinary Swift
dispatch. Check principal-name collisions and that the loaded class originates
in the verified plugin image. There is no C resolver table or unsafe cast of a
Swift-mangled function symbol. Objective-C runtime lookup supplies only the
macOS loader's class discovery; the provider interface itself is Swift.

| Framework interface | Contract |
|---|---|
| `ProviderFactory` | Class factory that exposes the immutable descriptor and constructs one provider instance; loading/factory work must not perform client actions |
| `ProviderDescriptor` | Resilient value holding schema, field registrations, resolver identifiers, authority requirements and required features |
| `Provider` | Reference-type, Sendable protocol for start, resolve and stop; the host holds the instance for its active lifetime |
| `ResolutionRequest` | Resilient Sendable value: request/resolver identity, coerced argument values and parent value |
| `ResolutionResult` | Success with a framework-owned value or structured provider failure; no complete GraphQL response or host error path |
| `ProviderValue` / `ProviderFailure` | Resilient Sendable domain values with public constructors/accessors; version-1 cases and meanings are fixed |

`ProviderValue` is null, a boolean, an integer, a double, a string, a reference,
a list or an object keyed by field name. The host checks each returned value
against the field's GraphQL type and its depth bound before publishing it; a
value that does not fit is malformed provider output. A nested resolver receives
the object its provider returned, unchanged. `ProviderFailure` is `unavailable`,
`failed`, `osPermission` with the missing consent's name, `unknownResolver`,
the provider's report of a registration mismatch, or `invalidInput`, for an
argument that is no value of a provider-owned type; the host reports that one as
input coercion, with a response path and no domain classification.

Resolvers use Swift async functions and framework-owned result values.
Arguments and results are ordinary owned Swift values under ARC, not borrowed
buffers with foreign release callbacks. Parent values contain scalars, opaque
references or bounded value trees rather than retained OS objects. Keep any
GraphQL implementation library out of public signatures, stored public types
and inlinable code; it is a private dependency of the engine. Swift types do
cross the binary boundary and their published contract is deliberately stable.

The host owns GraphQL execution, authority checks, response paths and non-null
propagation. It invokes a provider only for an authorized field, and supplies
no bearer secrets or grant-management object. Start observation after descriptor
and schema validation. Start/stop calls for one instance are serialized; resolve
calls may overlap once start succeeds. Stop admits no new resolutions, requests
cancellation and waits for outstanding work to finish. Swift task cancellation
is cooperative: an already dispatched OS action may finish. Keep instances and
dylibs alive while tasks use them, and keep all loaded dylibs mapped until
process exit. The host never holds an authority/store lock across provider code.
Providers hop to the thread/actor their OS APIs require and bound native waits.

The major-1 framework's public symbols, signatures, protocol conformances,
isolation/Sendable guarantees and behavior remain compatible across Koine 1.x.
Do not publish frozen structs/enums, implementation-revealing inlinable code or
third-party types as accidental ABI. Favor new declarations over altering old
ones. Never add a required protocol witness without a valid default for existing
plugins; do not change existing requirements' types, async behavior or actor
isolation. ABI compatibility alone is insufficient: a default that silently
omits a newly required action is a semantic break. New mandatory behavior uses
an explicit required feature/minimum version and is refused by older hosts.

Existing compiled plugins continue to use newer compatible major-1 frameworks
without rebuilding. An upgraded plugin can still run on an older host only if
its binary uses symbols/runtime facilities available in that host's supported
baseline and declares no newer requirement. Compile such a plugin against the
oldest framework minor it declares, not only without newer declarations in its
source: a conformance compiled against a newer minor records the defaults of the
protocol requirements that minor added, and an older host's dynamic loader
refuses the binary. Test that direction with the old
host; building with a newer compiler alone does not prove it. A plugin using
newer framework declarations declares the corresponding minimum minor and
cannot run on earlier frameworks. Future incompatible framework majors need a
new module/install identity and an explicit host support policy; they are not
promised by major 1. CPU, OS and Swift-runtime prerequisites still apply.

Swift documents the distinction between
[module stability and library evolution](https://www.swift.org/blog/library-evolution/).
Apple documents [class-name lookup](https://developer.apple.com/documentation/foundation/nsclassfromstring(_:))
and [run-path dependent libraries](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/RunpathDependentLibraries.html).
The loader and the independently built version pairs are verified through the
native binary test seam; `docs/verification/binary-compatibility.md` holds the
evidence, the supported binary baseline, and what release acceptance put out of
scope and left open.

Plugin and server release versions are not ABI versions. ABI compatibility also
does not guarantee GraphQL schema compatibility: a provider must preserve its
published GraphQL fields/types/semantics within its own schema major. Additive
optional fields are compatible; removing fields or changing inputs/nullability
needs a new advertised contract and client coordination. Desktop contract 1 is
stable across Koine 1.x. Report active plugin/schema versions and a schema digest
for diagnostics; clients generate against a stated compatible schema.

### Loading and trust

The native loader admits only explicitly installed, approved bundles from
Koine-owned installation roots, not the current directory or a client's search
path. Verify manifest, canonical bundle location, signature, dependency closure,
architecture and declared compatibility before calling `dlopen`; dylib
initializers run during load, before any entry-point negotiation. Signature
verification after loading is too late. The loader never strips quarantine or
disables OS code-signing checks to make a rejected plugin load; clearing
quarantine is the user's act of approval, below.

There are two installation roots, both supplied to the loader by the resident
application: `Contents/PlugIns` sealed inside `Koine.app`, and the per-user
installed root `~/Library/Application Support/Koine/Providers`. A bundle whose
canonical location is outside its root is refused. There is one loader: a
provider Koine ships, the desktop provider included, is a real plugin bundle in
the in-application root and loads by the same path as an installed one, so the
product itself exercises the native seam. It is never a target linked into the
host.

A provider bundle is a shallow code-signing bundle: an `Info.plist` at its root
names the dylib as its executable, so one signature seals the dylib, the
manifest and the schema. Record approved provider ID plus signing identity, the
signer's Apple Team ID; an update must satisfy the same approved identity and
version policy, or need explicit renewed trust. The in-application root's
records are built into the application, its shipped provider IDs with Koine's
own Team ID, sealed by the application signature. The per-user root's record is
a file the user places, `<providerId>.approval.json` beside the bundle, holding
`providerId` and `teamIdentifier`. Version 1 has no install or approval UI and
no GraphQL operation for it, and Koine writes no approval record itself. An
unapproved, unsigned, ad-hoc signed or differently signed bundle, and one
changed after it was sealed, is `REJECTED` with a diagnostic before any of its
code loads.
Validate private dependencies too, each against the approved identity, and
stage an immutable versioned bundle before verification/loading to prevent an
accidental update race: the loader copies the bundle to a read-only,
content-named directory under `ProviderStaging` in the data directory, and
verifies and loads that copy. A malicious
same-user actor able to rewrite Koine or its approved code is outside this
in-process trust model. Bad descriptors/schema are diagnosed without publishing
partial contributions; a plugin that has already run initializers stays mapped
until process exit even if activation fails.

Version 1 keeps the hardened runtime with no exceptions, so library validation
admits only providers signed by Koine's own Team ID, bundled or per-user;
first-party providers upgrade independently of the host. Independently signed
third-party providers are not loadable in this version: Koine's approval check
refuses one before `dlopen`, and the OS would refuse it after. A later increment
adds the narrowly scoped disable-library-validation entitlement, with its own
signed-build verification, and an install and approval UI; Koine then relies on
its own approval and signature validation. Apple documents this
[third-party plugin requirement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.cs.disable-library-validation).
That UI's approval also clears `com.apple.quarantine` from the bundle before
Koine first stages it, unless its author notarized it, for the reason the next
paragraph gives.

The per-user root carries a platform constraint, and the loader checks it
before `dlopen` rather than meeting it there. A bundle that arrives
quarantined, as a download does, is judged by Gatekeeper on its own when it is
loaded, and on a Gatekeeper-enforcing Mac, the default, a quarantined image
that is not notarized is refused — after Koine's approval record and Team ID
checks have passed, and behind a modal system dialog that would hold the service
from listening, since providers load at startup, until someone dismissed it. So
when an image of a per-user provider's staged copy carries
`com.apple.quarantine`, the loader asks Gatekeeper for its verdict first
(`spctl --assess --type open`, which looks the notarization ticket up online
when this Mac has none cached, and shows nothing), bounded at 30 seconds. A
provider Gatekeeper would refuse, or would not judge in time, is `REJECTED`
before any of its code runs, with a diagnostic naming both ways out: its author
notarizes it, or the user clears the attribute and, with Koine stopped, deletes
the staged copy, whose command the diagnostic gives. The staged copy is what is
checked because it is what is loaded, and it inherits the attribute; clearing
the installed bundle after a refusal is not enough on its own, because the
content-named staged copy is reused and keeps it. The `notarized` code
requirement is not the check: it consults only the local ticket store, and a
provider bundle has nowhere to staple a ticket, so it would refuse a notarized
provider this Mac had not yet looked up. There is no separate admission outcome;
a dynamic-loader failure the check does not foresee is still the ordinary
`REJECTED` carrying the loader's message. The in-application root is not
assessed: its quarantine is the application's, judged when the application was
first opened, and the application's notarization ticket covers
`Contents/PlugIns`. Evidence:
[provider-quarantine-precheck-vm.md](../verification/provider-quarantine-precheck-vm.md),
and for the platform's refusal at `dlopen` without the check,
[notarized-release-vm.md](../verification/notarized-release-vm.md).
The provider shares Koine's address space, OS permissions and failure domain.
Capabilities limit clients, not provider code. Only trusted native code belongs
here; untrusted extensions would require a different process-isolation design.

Load providers and compose the schema at startup. Install/update changes take
effect on restart, with no `dlclose` or live replacement requirement. The UI
reports incompatible providers; their schema contributions are absent. Failure
of the required desktop provider leaves management available but the desktop
path unavailable, clearly reported in provider status. No PluginAnyware hosting
or APIAnyware integration is part of this design.

## Client handoff

Koine's versioned GraphQL contract, reference/error semantics, endpoint descriptor
and grant protocol are authoritative. Runtime introspection supplies the full
schema for generated clients. No Koine-owned Swift client library is required
in the first deliverable: standard GraphQL tooling plus a small client-owned
adapter covers endpoint discovery, credential storage, authorization headers and
error classification. The [client guide](../client-guide.md) is that adapter's
reading path: the contract version and how a client verifies it, and what each
part of this contract means for a client. A future shared helper is justified by repeated real
consumers, not by the existence of a transport. That claim has been exercised
rather than asserted: a TypeScript client written from these documents alone,
with no access to Koine's source, runs the whole obtain-grant, discover, list and
focus path against the notarized build, and the places where these documents left
it guessing are recorded as findings. Each finding is repaired in this document
or declined for version 1 with its reason, as that evidence document records.
Evidence: [contract-only-client.md](../verification/contract-only-client.md).

ModalAnyware must revise its inherited Machine spec, architecture/provider
ownership statements and resident-bridge handoff to target `koine-desktop/1`.
It must capture the process incarnation at interaction start, preserve opaque
references through configuration/effects, store its own credential, and map
capability denial separately from Koine OS-consent guidance. It must distinguish
a missing process from a stale selected window and an unknown mutation outcome.
Its public TypeScript facade can retain convenience operations, but they are
client adapters rather than a second Koine wire contract. Its plugin/framework
choices belong to that repository, and Koine does not edit it; ModalAnyware's
own design may change the exact adapter shape. It reads the
[client guide](../client-guide.md) as any client does.

## Test seams and acceptance

Use the already agreed three seams. This design adds no fourth public testing
interface and does not require mocks of desktop applications.

| Seam | Checkable acceptance cases |
|---|---|
| Public GraphQL | Introspection exposes core and provider types; generated desktop operations validate and run with only the documented contract. Process absent gives ordinary null; a stale reference gives `unavailable`. Meaningful non-null fields propagate permission errors with original alias/list paths. |
| Public GraphQL authorization | Query the same resource by both lookup paths, nested fields, aliases and fragments; every path enforces read authority. Mixed permitted/denied mutation actions, including variable-controlled fragments, produce zero action calls. A skipped denied action does not block a permitted action. Revocation between preflight and dispatch prevents dispatch; revocation between actions prevents the later action without undoing the earlier one. |
| Public GraphQL management | Both request/approval and manual-grant workflows persist across restart. A pending requester cannot approve itself, enumerate others, or use provider operations. Revoked credentials fail on an existing keep-alive connection and after restart. Store/commit failure never reports a successful durable approval or revocation. Lost manual-secret delivery requires revoke/recreate. |
| Native binary interface | Keep an old compiled framework-major-1 provider while upgrading the host and its framework; keep an old host while upgrading a plugin built for its supported baseline. Check shared framework identity, factory casts, ARC ownership, async resolution, cancellation and observation startup. Reject unsupported majors/minors/features and bundled duplicate frameworks before loading; reject schema/ownership collisions before activation. Test mismatched signing identities before code is loaded. |
| Isolated TestAnyware macOS VMs | Signed installation and login launch without ModalAnyware; both native-UI grant workflows; first management bootstrap and revocation; Accessibility attributed to Koine; absent/revoked consent; app resolution, current/remembered windows across Spaces, focus, closure, duplicate titles, PID reuse and restart behavior. Closing management windows leaves service/observation running. |

Measure warm query-to-choices and selection-to-focus latency in the real keyboard
workflow, reporting machine, OS, application and observed distribution. Residence
is not evidence of meeting a numeric latency target. A cold login/crash is a
separate availability case. The measurement is a report and sets no target.
Evidence: [latency-and-support-matrix.md](../verification/latency-and-support-matrix.md).

Verify the signed release build's entitlement and permission behavior rather than
extrapolating from an unsigned development run.

The native identity guarantee and signed binary compatibility rest on these
seams, not on diagrams or source inspection, to the extent "Acceptance status"
records. Authorization invariants have
explicit admission points and are exercised with controlled ordering at the
public boundary. A formal model is not a deliverable of this design; this
protocol is not model-checked.

### Acceptance status

Every obligation above, each marked **established**, with the evidence that
establishes it, or **open**. Test suites named here are in
`Tests/KoineServerTests` and run under `task test`; documents are under
`docs/verification/`. The desktop-path VM runs used the Developer ID signed
bundle; those from release acceptance on used the notarized 0.1.0 bundle on a
Gatekeeper-enforcing clone; each document says which.

| Obligation | Status and evidence |
|---|---|
| Introspection exposes core and provider types | **Established.** `SchemaConformanceTests`, `CompositionTests`; the notarized build's whole schema against the design file, [schema-conformance-vm.md](../verification/schema-conformance-vm.md). |
| Generated desktop operations validate and run with only the documented contract | **Established**, with the findings it recorded settled in [contract-only-client.md](../verification/contract-only-client.md). Resolving an application needed the process start instant, which the contract has since stated; the identity itself is **open** below. |
| Absent process is ordinary null; a stale reference is `unavailable` | **Established.** `DesktopProviderTests`; [desktop-application-and-windows-vm.md](../verification/desktop-application-and-windows-vm.md), [desktop-references-and-permission-vm.md](../verification/desktop-references-and-permission-vm.md), [release-acceptance-vm.md](../verification/release-acceptance-vm.md). |
| Non-null permission errors propagate with original alias and list paths | **Established.** `ProviderAuthorizationTests`. |
| Read authority on every path: both lookups, nested fields, aliases, fragments | **Established.** `ProviderAuthorizationTests`. |
| Mixed permitted/denied mutations make zero action calls; a skipped denied action does not block | **Established.** `ProviderAuthorizationTests`. |
| Revocation between preflight and dispatch, and between actions | **Established**, each order forced rather than raced: `RevocationOrderingTests`. |
| Both grant workflows persist across restart | **Established.** `GrantManagementTests`, `GrantEnrollmentTests`, `GrantDecisionTests`; in the window on the Gatekeeper-enforcing release build, [grant-workflow-acceptance-vm.md](../verification/grant-workflow-acceptance-vm.md). |
| A pending requester cannot approve itself, enumerate others or use provider operations | **Established.** `GrantEnrollmentTests`; [grant-workflow-acceptance-vm.md](../verification/grant-workflow-acceptance-vm.md). |
| Revoked credentials fail on an existing keep-alive connection and after restart | **Established.** `GrantManagementTests`, `GrantDecisionTests`; on the very connection a credential was served on, [grant-workflow-acceptance-vm.md](../verification/grant-workflow-acceptance-vm.md). |
| Store/commit failure never reports a durable approval or revocation | **Established** at the public seam over a scripted store: `RevocationOrderingTests`, `GrantDecisionTests`. Not induced in a VM, which cannot make the store fail on demand. |
| Lost manual-secret delivery requires revoke and recreate | **Established.** `GrantManagementTests` finds no credential or digest in any management response; the window's accessibility tree likewise, [grant-workflow-acceptance-vm.md](../verification/grant-workflow-acceptance-vm.md). |
| An old provider on an upgraded host and framework; an old host with an upgraded provider built for its baseline; framework identity, factory casts, ARC, async resolution, cancellation, observation startup | **Established** for independently built pairs on unsigned hosts, [binary-compatibility.md](../verification/binary-compatibility.md), with `NativeProviderTests` and `ProviderLifecycleTests`. The signed, hardened application loads independently built same-team providers, [signed-app-provider-vm.md](../verification/signed-app-provider-vm.md), and its bundled provider from a quarantined notarized bundle, [notarized-release-vm.md](../verification/notarized-release-vm.md). A pair across two framework minors under the signed application was not run. |
| Unsupported majors, minors and features, and bundled duplicate frameworks, refused before loading; schema and ownership collisions refused before activation | **Established.** `ProviderLoaderTests`, `CompositionTests`; [signed-app-provider-vm.md](../verification/signed-app-provider-vm.md). |
| Mismatched signing identities refused before code is loaded | **Established** for another Team ID in the approval record, an ad-hoc signature and none: `ProviderLoaderTests`, [signed-app-provider-vm.md](../verification/signed-app-provider-vm.md). **Open**: a bundle signed by a second real Developer ID team, which needs a second certificate, and what the kernel does with one behind Koine's check. |
| Signed installation and login launch without a client | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [resident-app-vm.md](../verification/resident-app-vm.md); a quarantined first launch, [notarized-release-vm.md](../verification/notarized-release-vm.md). **Open**: login-item approval waiting on the user (`requiresApproval`) has never been observed; registration went straight to enabled in every run. |
| Both native-UI grant workflows; first management bootstrap and revocation | **Established.** [grant-workflow-acceptance-vm.md](../verification/grant-workflow-acceptance-vm.md), [grant-enrollment-vm.md](../verification/grant-enrollment-vm.md). **Open**: that a user actually compares the comparison code; the run shows the window's code equals the client's. |
| Accessibility attributed to Koine | **Established** on the notarized build: [notarized-release-vm.md](../verification/notarized-release-vm.md), [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [accessibility-status-and-consent-vm.md](../verification/accessibility-status-and-consent-vm.md). |
| Absent and revoked consent | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [desktop-references-and-permission-vm.md](../verification/desktop-references-and-permission-vm.md). |
| Application resolution; current and remembered windows across Spaces; focus | **Established.** [desktop-application-and-windows-vm.md](../verification/desktop-application-and-windows-vm.md), [desktop-remembered-windows-vm.md](../verification/desktop-remembered-windows-vm.md), [desktop-focus-vm.md](../verification/desktop-focus-vm.md), the mechanism in [desktop-window-identity.md](../verification/desktop-window-identity.md). |
| Closure, duplicate titles and restart behavior | **Established for served behavior.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [desktop-focus-vm.md](../verification/desktop-focus-vm.md). **Open for the replacement:** authenticated observed closure permanently retires a reference; undetected closure/descriptor reuse may affect another window. Observation, non-reuse and all agreed restart behavior need renewed evidence under the [future boundary](#native-targeting-discussion). |
| PID reuse | **Established** for rejecting a mismatched timestamp input in [release-acceptance-vm.md](../verification/release-acceptance-vm.md). An [actual PID-recycling diagnostic](../verification/retained-ax-binding.md) showed a held AX window acting on the replacement process. This is platform evidence, not a Koine acceptance pass. **Open** for the replacement: establish unchanged native destination and capture/reference expiry under the agreed endpoint-addressing contract; receiver/descriptor/downstream no-substitution is explicitly excluded. |
| Closing management windows leaves service and observation running | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [desktop-remembered-windows-vm.md](../verification/desktop-remembered-windows-vm.md). |
| Warm latency reported in the real keyboard workflow | **Established** as a report: [latency-and-support-matrix.md](../verification/latency-and-support-matrix.md), measured on the signed build of the macOS 26 floor, whose image digests the notarized bundle is to be checked against. |
| The signed release build's entitlements and permission behavior | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [notarized-release-vm.md](../verification/notarized-release-vm.md). |
| The native identity guarantee | **Established** only for the served design's within-process and ordinary-restart cases in [desktop-window-identity.md](../verification/desktop-window-identity.md). Held AX objects can retarget after actual PID reuse, as [the diagnostic](../verification/retained-ax-binding.md) and [current decision record](../adr/desktop-window-identity-is-a-held-element.md) explain. **Open** for the agreed future endpoint-addressing and focus-attempt contract; its explicit exclusions are not stronger guarantees awaiting proof. |

**Open, and not a case above:**

- **The process identity is to be replaced before the first public release**,
  because time cannot guarantee non-collision ("Public GraphQL contract").
- **Provider install and trust renewal.** There is no UI to install a provider,
  show its signer, approve it or renew trust, and no library-validation
  entitlement, so independently signed third-party providers do not load.
  Deferred with the human; approval is a file the user places.
- **Only macOS 26.5 on arm64 has run.** The floor is declared at macOS 26; nothing
  ran on 26.0 to 26.4. Intel, earlier macOS releases, a provider built by a
  different compiler than its host, and older framework minors are out of scope
  for this release, as [binary-compatibility.md](../verification/binary-compatibility.md)
  records.
- **Expiry and retention of grant requests** are shown with a test clock
  (`GrantRequestLifetimeTests`), not in a VM.

## Scope and agreement

Deferred: non-running applications, broad installation/configuration discovery,
LLM skills, remote networking, cross-language plugin authoring, live plugin
replacement, subscriptions, automatic retry and rollback, and cross-provider
identity or atomic snapshots. Open-source licensing and distribution are settled
and do not change this desktop design: Koine is published under Apache-2.0 and
installed from a Homebrew cask carrying the notarized bundle
([open-source release and distribution](../adr/open-source-release-and-distribution.md)).

The whole contract is agreed and implemented: a shared resilient Swift
framework, one resident application with in-process native management,
transferable bearer credentials with live revocation, the precise
revocation/admission boundary, GraphQL desktop identity, the client-owned adapter
and the operational policies described here. Platform behavior and native binary
compatibility are established by the evidence in "Acceptance status", which also
lists what is still open; the process identity is agreed to be replaced before
the first public release.

## Native targeting discussion

**Agreed future contract: endpoint addressing only.** The timestamp input
and current SDL above remain the served behavior. This agreement sets the effect
boundary; it adopts no shipping mechanism and authorizes no release. The
[guarantee-boundary view](../design/architecture/index.html#diagram-process-target-contract)
shows where each promise ends.

The [capture ADR](../adr/desktop-capture-preserves-the-process-incarnation.md)
records capture and process lifetime; the
[effect-boundary ADR](../adr/desktop-effects-use-the-admitted-endpoint.md)
records the targeting trade-off. The future contract preserves non-time process identity,
fresh foreground capture in the client's native callback, public client APIs and client-owned adapters, Koine-owned Accessibility
consent, and no injection, helper or target modification/cooperation. A restored
application is a new incarnation; an old reference is never rebound to it.

The effect-boundary ADR records why restricted target profiles and the original strict
effect promise were not selected, and what would reopen them. The
[adoption synthesis](../verification/ax-endpoint-adoption.md#original-feasibility-criteria-reconciled)
separates existing bounded observations from the evidence still needed for this
contract. Agreement to its effect boundary does not establish that the current
direct adapter can ship.

### The exact addressing boundary

Endpoint admission must attribute the continuously retained process identity to the fresh
callback-time sample and authenticate the endpoint's responder against that
identity. This is distinct from grant/dispatch admission at the serialized
authority boundary: neither check substitutes for the other. After endpoint
admission, Koine holds the actual rights and copied descriptor
values; numeric port names alone are not identity. All target AX reads, requested
effects, confirmation requests and target observation registrations use that
retained endpoint. There is no fresh
PID, PSN or logical-application destination lookup under an old capture, and no
automatic mutation retry. The adapter owns this protocol and its cleanup;
clients supply opaque references, not native addresses.

Death or exec ends the old capture and withdraws its references. Before each native
primitive, Koine validates the held identity and refuses endpoint admission or subsequent
sends when it is dead, invalid or ambiguous. An identity check does not atomically enclose a send: a request that races death,
or was already accepted, may still execute. This option explicitly accepts that
limit rather than claiming the check prevents every post-death effect.

For windows, authenticated observed closure permanently retires the reference
and subsequent use returns `unavailable`. The retired reference is never reused
or revived, even if the descriptor later reappears. This does not guarantee
detecting every closure before descriptor reuse: an undetected closure/reuse
may cause an old reference's attempt to affect another window in the same live
process. That is the agreed qualification of the inherited unconditional
closed-window refusal. Missing from an enumeration alone is not proof of closure
(a window may be on another Space); uncertain observation cannot be promoted
into a current, confirmed or remembered window. The full protocol must establish
authenticated closure attribution, ordering with sends and late notifications,
permanent retirement/non-reuse and the handling of insufficient observation.
No notification or endpoint protocol satisfying this obligation is yet adopted.

Calling this **delivery to the captured receiver** would promise too much. The
admission exchange authenticates a responder at that time; it does not make a
receive right immovable. Koine preserves the addressed port object, not permanent
ownership of its receive right. It excludes Koine selecting a new
destination, while no longer excluding these wrong-target effects:

- A moved receive right lets another process receive a later request.
- A reused descriptor or custom handler selects another window or forwards work
  to another process, even while the originally captured process remains alive.
- A service executes queued logical-application activation after the original
  process ends and brings a restored successor forward.

Every reply used for endpoint admission, window enumeration, reference creation
or confirmation must be authenticated against the retained process identity.
For the audited-Mach candidate the required order is a fresh reply right, the
actual request and kernel-authenticated reply trailer, then a live comparison
with the continuously retained task. Cached PID/pidversion values alone do not
satisfy this rule. The [admission evidence](../verification/ax-endpoint-adoption.md#original-feasibility-criteria-reconciled)
and [liveness argument](../research/native-process-bound-effects-a.md#1-binding-an-effect-acquisition-attribution-dispatch-downstream)
bound that ordering; they do not establish a complete production protocol.

Notification delivery must independently establish its source, capture and
window attribution, freshness and registration lifetime before changing reference
or remembered-window state. A PID-only termination event or an old queued
notification is not such proof. Authenticate asynchronous delivery using an
evidenced registration/delivery protocol; a synchronous reply bracket cannot
simply be assumed to apply. The full protocol must establish this observation
path or refuse operations that depend on it.

Missing, ambiguous or mismatched provenance supplies no accepted listing,
reference or confirmation and stops later primitives. Authenticating a sender
does not prove the truth of arbitrary handler data or permanent descriptor
ownership; read freshness and attribution need their own evidence. Reply
authentication cannot undo an effect. A timeout, cancellation, disconnect or
detected death stops later primitives and reports uncertainty where work may
have been sent. A refusal before any native send establishes that this operation
sent nothing; earlier accepted work may still act. After a possible send, a
failure or lost response does not establish no effect. A later observation does not prove that no other
effect happened, nor that focus persists after the observation.

The future public operation and its introspection descriptions must expose
**focus attempt**, separating request acceptance from an observed result. It must
not claim the existing exact-target success guarantee. A claimed observation
needs established freshness/provenance; otherwise report that confirmation is
unavailable, not success. Exact wire fields belong to the remaining protocol
design, before implementation. The weaker meaning cannot be hidden behind an
unchanged description or a client opt-in default. Contract-version framing is
still a separate explicit agreement before publication.

### Observation and retirement protocol proposal

**Proposed construction, not an adopted native mechanism.** This section
implements the agreed observed-closure rule at the design level. It does not
establish that AX exposes the required registration or delivery semantics.
The [reference-lifetime view](../design/architecture/index.html#diagram-process-observation)
shows this proposal. The current SDL remains the served contract; the complete
protocol agreement must settle this proposal's availability cost before adoption.

#### Ownership and evidence boundary

The desktop provider's native adapter owns the retained task and endpoint,
registration resources, request reply rights, descriptor copies and reference
lifetime. One serialized owner decides publication, withdrawal, retirement and
each native send's initiation. It does not wait for a native reply while holding
the owner: waits retain their own resource pins and return candidate results.
The engine continues to own grant/dispatch admission. An admitted action may
finish after revocation under that existing rule; native identity or observation
failure still stops its remaining primitives.

The adapter authenticates individual notifications using the first five
obligations below. Completeness/loss detection and publication order qualify
the stream and dependent reads; an individually attributed closure may retire
a reference even if the stream's completeness is unknown.

| Evidence | What must be established |
|---|---|
| Source | The native delivery path authenticates the sender or an evidenced intermediary chain back to the captured process. A body PID or local callback context alone is insufficient. |
| Registration | This delivery belongs to the continuously owned registration for this capture, with a known start and end. Reusing a numeric receive-port name or a callback pointer is not continuity. |
| Window | The event belongs to the particular registered descriptor lifetime. A raw descriptor equal to one used by a later window is insufficient. |
| Freshness | The native generation/delivery ordering relates the event to that registration and window lifetime. Receipt time and a locally assigned sequence number cannot date the target's event. |
| Capture | The retained identity still attributes this data to the original incarnation. A synchronous request/reply liveness bracket cannot simply be applied to queued asynchronous delivery. |
| Completeness or loss detection | Establish which missing deliveries the native path detects, including suppressed emission, queue saturation and send failure. Local sequence numbers and registration success cannot prove completeness. |
| Publication order | Establish how closure evidence preceding a read is accounted for before publication across separate notification and reply channels. Local receive order supplies no native ordering. |

These are native proof obligations, not fields that Koine can add to a message
and trust. The endpoint-addressing effect relaxation does not waive them. An
authenticated target can still supply false data; the protocol must describe its
native attribution and ordering guarantees without promising arbitrary handler
truthfulness.

Synchronous candidate reads separately require a fresh reply right, an actual
request, the kernel trailer and a subsequent live comparison against the held
task. They also need request correlation, freshness and descriptor attribution.
Passing sender authentication alone cannot turn an old reply into a current
listing, nor establish a notification's generation time.

Equal descriptor bytes do not attribute a new read to an existing record's
window lifetime. CURRENT, REMEMBERED and focus confirmation require an evidenced
lifetime discriminator or equivalent complete, ordered observation. Otherwise
the dependent read is unavailable even if the sender is authentic. The agreed
effect relaxation does not authorize reporting a replacement window's data under
the old reference. If native evidence cannot support this distinction, the
complete protocol agreement must explicitly decide that read consequence;
it remains unagreed here.

Withdrawal on observation loss means **detected** loss. A closure never emitted
or silently dropped cannot itself trigger a local transition. The native
investigation must identify detectable and residual silent losses, not infer
completeness from silence. Where lifetime attribution depends on complete
observation and completeness cannot be established, refuse dependent publication,
listing or confirmation rather than call the registration intact. Independent
lifetime evidence may support reads despite incomplete observation; it must be
demonstrated. Undetected closure may still permit the agreed wrong-window effect.

#### Publication and permanent non-revival

Each local window record has one of the following states. These names describe
private ownership, not new GraphQL enum values:

| State | Permitted behavior | Exit |
|---|---|---|
| Preparing | Hold a candidate descriptor and registration resources; expose no reference and perform no focus effect. | Publish as usable only after all evidence and publication premises succeed. Attributed closure becomes ClosedBeforePublication; missing provenance, failed registration or capture death/exec becomes Failed. |
| ClosedBeforePublication | No reference was published. Authenticated, lifetime-attributed closure permits omission of this closed candidate. | Terminal; release through bounded cleanup. |
| Failed | No reference was published. Fail the affected listing as unavailable with an explanation; do not silently omit this candidate. | Terminal; release through bounded cleanup. |
| Usable | Resolve the opaque reference; perform qualified reads and attempts through the retained endpoint. | Authenticated closure retires it; detected loss of required observation or capture death/exec withdraws it. |
| Retired | Every later use is unavailable. Known closure never reverses; reason detail is bounded as below. | None. Late data and descriptor reappearance cannot revive this reference. |
| Withdrawn | Every later use is unavailable without inventing closure. Report the actual reason while retained; after reclamation report generic unavailable. | None. Recovery creates new records and references as below, never revives this one. |

`CURRENT` and `REMEMBERED` are presentation facts about usable records, not
lifetime states. Missing from a listing alone changes neither lifetime nor
closure knowledge. A remembered row requires a previously attributed window,
an observation registration satisfying the evidenced loss/order requirements and a freshly authenticated read that
supports the window's continued existence and attribution. An unanswered read
does not justify a remembered row under this proposal. If the affected listing
cannot establish the required facts, it fails as unavailable with an explanation;
it does not silently drop uncertain windows or present the remainder as complete.
This costs availability compared with the served unanswered-read behavior and
requires agreement with the complete protocol.

Before publication, install local delivery ownership, register through the
already admitted endpoint and establish the native boundary between registration,
enumeration and queued closure. Buffer candidate notifications under bounded
ownership while this happens; validate and apply them before publishing. If
closure is established first, publish nothing. Registration success followed by
an arbitrary re-read is not proof that the gap is covered: a descriptor can be
reused between them. The native investigation must establish a registration
barrier, lifetime identifier or equivalent ordering that discriminates that
schedule. Without it the operation is unavailable; do not invent such a token.

There are two candidate orders, neither adopted. Application-scope registration
before enumeration must bridge asynchronous closure delivery and a later
per-request reply. Per-element registration after enumeration additionally
needs evidence that the enumerated lifetime survived until registration; equal
descriptor bytes and an acknowledgment cannot bridge reuse in that interval.
For both, buffered arrivals are insufficient if an older closure remains in
transit on another channel. Evidence must establish a native barrier, lifetime
discriminator or equivalent protocol that accounts for that schedule before
publication. The same premise applies to re-enumeration and confirmation of
already usable records. In its absence refuse the dependent result; a local
drain, arbitrary re-read or receipt timestamp cannot manufacture native order.

After retirement, seeing equal descriptor bytes cannot revive the reference.
Issuing a different reference for those bytes requires evidence of a distinct
window/registration lifetime and isolation from old deliveries. If the protocol
cannot distinguish them, refuse that affected listing, including any claimed
complete result. This is an observation restriction, not a new promise that
undetected descriptor reuse cannot produce a wrong-window effect.

No reference identifier is allocated twice. The proposed finite allocator is
shared by all captures in one provider run, never reset by withdrawal, relisting
or capture replacement. Record reclamation must preserve
non-reuse and rejection of old identifiers without requiring an unbounded
tombstone set. A finite local allocator must refuse before exhaustion, never
wrap. Specific terminal reasons survive only within the bounded record budget.
After reclamation old identifiers remain unavailable, without a promised
closure-versus-withdrawal reason. Non-revival needs no unbounded reason history.
The maintained resource policy must bound registration/relisting churn and
allocation rate, state exhaustion refusal and recovery, and prevent restart
from bypassing non-reuse. The full capture/reference design still owes a non-time namespace across
provider, Koine and boot restarts; a random run value alone is not a proof of
non-collision. This proposal does not choose that grammar or revoke the served
application-reference restart guarantee by implication.

#### Ordering with sends and late completion

The local ordering point is the serialized owner's final state check and actual
native send initiation, not a prior queue insertion or a permission token handed
to another worker. No owner operation may intervene between that check and
initiation. Initiation is a nonblocking enqueue attempt with a native bound;
the owner never waits for queue space or a reply. No worker handoff is selected:
a transport requiring one needs a separately evidenced ordering construction
before adoption. Send/wait resources and the initiation bound remain obligations
of the maintained adapter profile. The ordering does not enclose native execution or downstream
work, and it does not make observed closure instantaneous with physical closure.

Before the final check, take a cut of deliveries already admitted to the local
ingress queue and validate/commit that finite prefix within the adapter's budget.
If it cannot be processed within the budget, refuse this dispatch; do not skip
evidence to send. Established loss withdraws dependent records. A closure still
in native transit or arriving after the cut may race initiation. A received
message is not yet authenticated observation; observation commits in the owner.
This scheduling boundary needs explicit agreement with the full protocol and
does not satisfy the cross-channel publication premise above.

| Native initiation outcome | Meaning for this operation |
|---|---|
| Local refusal before initiation | This primitive sent nothing. Claim the operation sent nothing only if every preceding primitive also has proven no-send status. |
| Native result proven not enqueued | This primitive sent nothing; preserve uncertainty from earlier possible sends. Record the native result and ownership evidence supporting this classification. |
| Enqueued | Submission only, not execution or observed focus. Cancellation cannot retract it; later failures retain uncertainty. |
| Ambiguous result, timeout or interruption without proof of non-enqueue | Possibly sent. Stop later primitives and retain uncertainty; never automatically replay. |

The native investigation must map actual send results, including full queues,
invalid/dead destinations and interruption, to these classes and their cleanup
obligations. Do not infer no-send from an error name or a missing reply.

| Interleaving | Required result |
|---|---|
| Closure is authenticated and committed before the next send initiation | Retire first; that send and later primitives do not begin. A queued action must check again. |
| Send initiates before retirement | It may act, even after retirement. Stop later primitives; preserve uncertainty about this send and any earlier accepted work. |
| Reply is received, then closure commits before publication | Do not publish a new reference, usable row or focus confirmation from that reply. Retirement wins over the candidate result. |
| A result was published before closure was observed | It remains a per-call observation, never a promise that focus or window existence persists. Subsequent use refuses after retirement. |
| A cancelled request's reply arrives after another request starts | Its distinct reply ownership cannot complete the new request. Destroy/release it according to the native ownership ledger. |
| An old registration delivers after a new registration exists | Match retained registration identity before interpreting the body; it cannot update or retire the newer record. Ambiguous attribution is insufficient evidence. |

Do not disable lifecycle observation merely because a focus request was
cancelled: per-request reply waits and capture-lifetime registrations have
different owners. Cancellation stops later request primitives and candidate
result publication; it cannot retract a possible send. Resource teardown first
closes local admission, then detaches the delivery path, and releases callback
contexts/rights only after the native delivery and local queued-work ownership
have drained. If no bounded drain can be established, the adapter's cleanup
design is incomplete, not permission to leak or free a live callback context.

Unauthenticated, foreign or demonstrably obsolete events are discarded with
their owned resources; arrival on a delivery port alone authorizes no state
change. Only after source authentication and current-registration attribution
does malformed or window-unattributable input withdraw records dependent on
that registration. If no window can be identified, that means all its records;
a lifetime-attributed window failure is confined to that window. Failure of
shared capture observation affects all dependent registrations. Capture end
withdraws all its published records and fails all preparation. Independently
detected delivery loss follows the same dependency scope, even if malicious
traffic caused overflow; an untrusted body itself cannot trigger withdrawal.
Any listing requiring an uncertain record fails as a whole; confirmation fails
for that record and later dependent primitives stop. No partial remainder is
presented as a complete listing.

A subsequent good event does not restore withdrawn references. Recovery may
register/list anew under the same still-live authenticated capture if new
lifetime evidence and isolation from old delivery are established. Otherwise
refuse; require a new capture only when the capture itself ended or cannot
satisfy admission. Neither recapture nor relisting repairs a missing native
premise. Refusal-triggering behaviors include failed registration, authentic
malformed events, delivery loss, unreadable windows on other Spaces, ambiguous
descriptor reuse and missing cross-channel order. The full agreement must name
which observed applications/workflows these exclude and obtain agreement to
that availability/support consequence; this proposal approves no restriction.

A PID-only process notification may prompt validation of
the retained task; it cannot by itself end a capture. Confirmed held-task
death/exec ends that capture independently of notification delivery.

#### Alternatives and discriminator

The recommended construction keeps observation and retirement inside the same
adapter that owns dispatch. Leaving the current PID observer beside a retained
endpoint would force callers to reconcile two identity systems and would not
supply the required provenance. Polling alone cannot distinguish closure from
absence on another Space or undetected descriptor reuse. Polling can supplement
an evidenced registration protocol; it is not an assumed replacement for one.

The next native question is narrow: **can registration through the retained
endpoint deliver a closure attributable to the captured window lifetime, and
can that delivery be isolated across registration retirement and reuse, with
loss detection and ordering sufficient for attributed publication?**
Inspect actual registration and delivery layouts before choosing an encoder.
The [pinned wire inspection](../verification/native-observation.md) identifies
separate registration and notification paths, supplied cookie context and a
zero-timeout post. It establishes neither a native window generation nor a
publication barrier or observer loss detector; the required runtime evidence
remains outstanding.
The [layout dossier](../verification/native-observation-layout.md) supplies
byte-offset and reply-check evidence. The subsequent
[request-decoder inspection](../verification/native-observation-requests.md)
matches header constants and server decoding; the
[connection inspection](../verification/native-observation-connection.md)
traces local connection ownership, audit policy and scalar/flag semantics.
The [receive-envelope inspection](../verification/native-observation-receive.md)
traces native voucher adoption, injected observer context and separate success/
error cleanup. Actual execution context, authenticated receive, bounded OOL
acquisition and cleanup controls remain prerequisites. No owned exchange is
established.
Then use a signed diagnostic in an isolated VM, with an independent window and
process witness, to distinguish live closure from Space absence, queued old
delivery, registration failure and death/exec/reuse. Exercise closure during
publication and both sides of the local send boundary. Validate a deliberate
wrong-source or old-registration event is rejected and a genuine closure is
accepted. Synthetic faults establish local rejection only; they do not establish
native source authentication or actual descriptor/PID reuse.

Freeze controls for suppressed emission, saturated queues and failed delivery;
show whether a missing closure is detected, with an independent closure witness
and deliberate failure of the detector. Identify residual silent loss. Delay
an older notification past a later enumeration/confirmation reply, and test
both registration orders' gaps, including reuse before per-element registration.
Evidence read-lifetime attribution despite undetected reuse, or report its
absence. Exercise bounded initiation with full queues and each native send-result
class; distinguish proven non-enqueue from ambiguous sends. Controls test native
premises separately from synthetic local fault handling; a successful fixture
schedule does not prove arbitrary-handler completeness.

If an authenticated native lifetime cannot be established, report the specific
missing premise before adopting this protocol. Refusing every window is not a
successful desktop path. No broader application-support restriction is approved
by these refusal rules. Separately retain ordinary live effects, per-reply
authentication, callback capture/transfer, consent and lifecycle evidence as
requirements of the complete design.

Use the existing public GraphQL seam for visible refusal and non-revival, the
native plugin seam for ownership/lifetime integration and the isolated VM seam
for native attribution. An internal controlled adapter can schedule local
ordering and cleanup faults at its composition point; it adds no public API.
No formal model is claimed here: serialization makes the proposed local order
explicit, while the unresolved native barrier and attribution cannot be proved
by assuming them in a model. Revisit modelling if the evidenced adapter requires
multiple owners or a transferable send permit.

### Remaining evidence and protocol work

A private-adapter **OS/protocol compatibility profile** identifies exact platform
bytes and accepted protocol/descriptor forms; it is not a behavioral
application-support profile. The latter was not selected. Unsupported forms,
unknown forms or exceeded representation bounds fail the affected operation as
`unavailable`, with an unsupported-adapter/protocol explanation, rather than
silently omitting windows, returning a complete-looking partial listing or
asking for consent. Exact wire detail and any explicit partial-result contract
belong to the full protocol agreement. The diagnostic inline-only subset and
its quotas are evaluation limits, not approved product coverage.

No shipping mechanism or private-adapter OS/protocol compatibility profile is
approved. Native capture, actual right transfer, discovery/authentication,
reference grammar/non-reuse, restart policy and prepublication version framing
remain to be agreed. Internal entry points and an owned wire encoder both
require recurring OS verification; the currently served timestamp mechanism
is not approved for the first public release.

Use the existing GraphQL and isolated native-VM seams. Capture/transfer evidence
must cover a delayed callback after an app switch, a switch after capture,
death/PID reuse around sampling, null/dead rights and policy denial. Native
evidence must separate the lifetime of the addressed object, its receiver, the
descriptor and downstream work; a passed test at one boundary does not prove
the others. Deliberately moved receivers or forwarding handlers are
negative controls for an excluded guarantee, not passing exact-target behavior.

AX-contact inhibition is a separate lifecycle policy question. The effect
guarantee does not permit keeping targets alive indefinitely by implication.
Establish inhibition/release behavior and decide its product acceptability;
do not count target nontermination as a passed restoration schedule. Separate
Koine consent, denied/revoked consent, bounded resources, late replies,
cancellation uncertainty, maintained private-protocol support and notarized
launch remain required. No private-adapter OS build is approved by this choice.

The window-qualified activation proposal addresses a separate service through
logical application/window identifiers and is outside the agreed same-endpoint
path. It is not a fallback or a necessary proof of an excluded end-to-end promise;
that diagnostic has been explicitly abandoned. No native execution is implied
by the agreement.
The full capture, transfer, authorization, reference and restart contract remains
to be designed and reviewed before implementation.
