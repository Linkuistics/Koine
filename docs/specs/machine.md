# Koine desktop contract

**The shared Machine and desktop contract.** Koine 0.1.0 implements the baseline:
the shared resilient Swift framework, one resident Koine application and bearer
credentials with live revocation. The
served schema matches [the design schema](../design/desktop-schema-extension-host.graphql)
(and, for hosts that predate the candidate diagnostics, the
[original](../design/desktop-schema.graphql)) under a repeatable check, and the platform behavior is verified on the notarized
build in Gatekeeper-enforcing VMs. "Test seams and acceptance" says, case by
case, what is established and by which evidence, and what is open. Process
identity is a PID plus its kernel start instant; the races public Accessibility
leaves open are accepted and listed in "Native targeting discussion". Client authors start at the
[client guide](../client-guide.md).

The [workflow-provider extension](workflow-providers.md) adds agreed launch,
native location/catalogue discovery, input, menu and tool workflows. Its pending
native discovery targets macOS 26+ and named application/System Settings categories;
clients own raw filesystem search. The
[ownership decision](../adr/raw-filesystem-search-belongs-to-clients.md) governs
that boundary. Sections explicitly marked **extension** below are obligations for
that work, not claims about 0.1.0 or its acceptance. The [native discovery design](workspace-search.md) now defines its API, selected
sources and exact new profiles. Mandatory review and G/N/V acceptance remain
pending; earlier raw-search and action-only captures supply no catalogue pass.

## Purpose and ownership

Koine owns the Machine server contract. It lets a local client obtain a grant,
resolve the running application captured at interaction start, list that
application's windows, and focus a selected window. The native macOS management
UI and GraphQL management operations are part of it.
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
unavailability. Koine does not promise automatic crash relaunch.
It requires macOS 26 or later on Apple Silicon. That is the supported OS/CPU
matrix, set by what has actually run rather than by what a deployment target
could be set to: Koine is verified on macOS 26 on arm64 and claims nothing about
any other OS or architecture.
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

Bound parsing and execution: 1 MiB request bodies, depth 16, 1,000
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

`koine-desktop/1` names the public contract, separately from plugin ABI
versions. The [schema](../design/desktop-schema-extension-host.graphql) states exact
types and nullability (the [original schema](../design/desktop-schema.graphql)
is the old-host profile, kept as released, see "Conformance profiles"); the [client operations](../design/desktop-operations.graphql)
show the handoff's requests. The schema Koine serves matches the schema file,
checked by `task conformance`, for each profile against the host that serves it
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
client's in the served baseline: desktop offers no lookup by name or bundle
identifier. The designed [workspace launch/open extension](workspace-launch-and-open.md)
can return an observed process incarnation after an explicit action; it does
not change desktop's lookup input or reference contract.

This identity is the `koine-desktop/1` contract. The
[capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md)
records why Koine does not use an identity without the start instant.

Koine uses public macOS Accessibility for listing, focus and notifications, and
accepts the wrong-target races and unauthenticated reports that entails; the
[native targeting discussion](#native-targeting-discussion) states the limits.

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
canonical text that keeps declared order, and composition is what fixes it. The
description of `Mutation.desktopFocusWindow` is the row above; it does not state
mutation preflight, which is a property of every mutation, stated under
"Mutation preflight and revocation", not of this one field.

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
build with one set of active provider contributions in the canonical composition
order, and differs when any served type, field, argument, nullability, default,
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
plugin. In the served baseline, reject both competing external providers for a
duplicate identifier; an external plugin cannot replace `desktop`. The designed
extension replaces that rule for reserved first-party identities with
[first-party provider selection](#first-party-provider-selection). Other duplicate
claims still refuse both; directory order never selects a winner.

A provider identifier is a lower-case letter followed by lower-case letters and
digits; it is also the reference authority and the prefix of the provider's
capabilities. A prefix is a capitalised alphanumeric GraphQL name. Two non-reserved
prefixes may overlap (`Git`, `GitHub`); a name two providers both define refuses both.
Each contribution is validated against the core schema alone, so it cannot use
another provider's types, and its SDL validity does not depend on which other
providers loaded. The extension below adds explicit capability dependencies
after that validation. Accepted contributions are composed in a canonical
order: bundled providers first, then per-user providers, each group sorted by
identifier. In the extension this first group is the selected shipped identities,
including approved replacements physically installed in the per-user root.
Other accepted per-user providers follow, sorted by identifier. Sorting uses
Unicode code points. Desktop is the only bundled contribution in the baseline.
A refused provider is not started. Physical origin remains visible in diagnostics;
selection never pretends a per-user bundle was sealed inside the application.

Version 1 narrows what a contribution may hold. It uses only its own types, the
built-in scalars and `Reference`; an extension of `Query` or `Mutation` adds
fields and nothing else. Interfaces, unions, input-object default values and
output lists with nullable elements are refused, because the engine does not
serve them faithfully. Provider SDL is held to the request policy's nesting
limit, and the composed schema must pass GraphQL schema validation.

Version 1 permits adding owned root fields and owned types, not extending
another provider's types or replacing core fields. References may cross through
the shared `Reference` scalar; using one never grants access. Provider-private
custom scalars/enums must be introspectable. Version 1 has no shared object
interface or cross-provider field extension; either would require an explicit
composition contract.
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

#### Additional capability requirements

**Extension — implemented in framework minor 1; the bundled workspace provider
is its first shipped user.** A field may add an immutable set of provider read/control capabilities to
its existing own-class requirement. "Acceptance status" records what has been
shown and what has not.
The [effect-authority decision](../adr/provider-authority-follows-effects.md)
explains why this is necessary. It does not replace the foreign-reference rule
or let a provider make a field public. Root mutation fields still require their
own control; query-reachable fields still require their own read. Additional
requirements on query-reachable fields may only be reads. A control-authorized
mutation receipt may carry the action's additional control requirements without
exposing read-protected resource data. The workspace launch/open receipt's one
observation allowance is an optional PID plus exact kernel start instant for
the application returned by that action's native acknowledgment, following the
workspace matching rule. It permits a later independently authorized desktop
lookup, not application discovery: installed paths, bundle identifiers and
default-handler metadata remain workspace read data. This does not authorize
other resource state in control receipts.

Every additional capability names a provider identifier and `read` or `control`.
Core enrollment/management authority is forbidden. The set is unconditional:
all native paths and fallback mechanisms of one field must fit it. Conditional
effects use the conservative union or separate public fields, never an
authorization decision made after native resolution. Field descriptions state
the complete declared set, and documentation also states the unchanged dynamic
reference-owner rule. Passing a reference as an ordinary string to escape that
rule is not a valid provider contract.

For extension fields using this feature, order requirements with the field's own
capability first, additional capabilities in lexical Unicode-code-point order,
then argument-owner capabilities in that order, omitting duplicates. `requiredCapability` names
the first unmet member in that order. Add `extensions.requiredCapabilities` as
the complete ordered set for the failing field and its coerced arguments, so a
client can request one adequate grant instead of discovering members one denial
at a time. Preflight errors retain each denied action's original response path;
the list describes that action, not successful earlier effects or unrelated
actions. This additive diagnostic does not change baseline registrations' error
order or promise a machine-readable authorization catalogue in introspection.
Descriptions supply the static field set; reference-owner additions still depend
on arguments. Revocation and publication use the same set as preflight.

Old registrations mean an empty additional set. The host computes the union of
the ordinary field requirement, additional requirements and argument-reference
owner requirements. It uses that same union in whole-mutation preflight, live
dispatch admission, and read authorization/publication. The serialized
grant/dispatch admission checks the complete set before provider code starts;
providers never receive a credential or perform these grant checks themselves.
Aliases, fragments, argument defaults, nested reference inputs and skip/include
semantics remain those of the existing contract. No new client action follows
revocation; cleanup of an already admitted interaction follows the separate
workflow lifecycle contract.

Provider SDL is still validated against core alone. Additional capability
dependencies introduce one explicit composition dependency after independent
validation: every named owner must be an admitted provider in the final schema.
After ordinary loader/schema rejection, remove contributions with missing
capability owners and repeat until the admitted set stops changing, in canonical
order. Report the missing owner in management diagnostics; do not weaken a field
or publish a partially protected contribution. Cycles of otherwise valid
capability dependencies are allowed; they are authority names, not initialization
calls: the check is membership of the admitted set, never a walk of the
dependency graph. Providers must not use them to require an order for calling one
another's start methods. A provider failing startup keeps its published schema and
capability names under the existing lifecycle policy, while its own resolvers
report `unavailable`. Naming its authority does not call it or establish a readiness
dependency. Rejection removes its contribution and triggers the missing-owner
cascade; startup failure alone does not. The native seam must cover both cases.

This adds field metadata semantics through a compatible major-1 framework
minor and required feature `additional-capabilities-v1`. Both manifest and
descriptor declare the feature; the manifest declares the implementing minimum
minor, which is 1. Framework 1.1 is the first to advertise the feature; Koine
0.1.0 advertises framework 1.0 and no feature. The new declarations are
`ProviderCapabilityRequirement` (a provider identifier and `read` or `control`),
a `ProviderFieldRegistration` initializer that takes the set, and the feature's
name, `ProviderDescriptor.additionalCapabilitiesFeature`. The set is empty for
every registration made with the old initializer, which is retained with its
behavior. An old host must refuse the new provider before loading. A new host
must reject a descriptor that uses additional requirements without the feature
declaration: `REJECTED`, not `INCOMPATIBLE`, since the descriptor is at fault and
the host lacks nothing. It likewise refuses, whole, a contribution whose set
names an identifier no provider can have (`koine` and everything under its
prefix), adds control to a field a query can reach, or gives a `Reference`
argument or input field a default that is not a reference. A manifest that names
the feature under a minimum minor lower than the one that carries it is refused
before any code loads. Silently ignoring the set is never a compatibility fallback.
Independent old/new binary pairs verify these semantics before release.

Composition does not check that a field's description states its declared set.
Prose cannot be verified faithfully, so that stays a publication rule: a provider
that ships a set tests its own descriptions, and a client that needs the set reads
`extensions.requiredCapabilities`, which is the mechanical statement of it.

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

The two places an action can be refused are told apart by path. A capability error
with `phase: execution` **at a root action's own path** means dispatch admission
refused that action: it did not start, because an admitted action is reported and
never re-checked. A denial that follows an action's acknowledgment can only appear
**below** the action's result, at a nested field, and leaves the action's own
outcome as its published status says.

### Errors and partial data

Execution errors carry `message`, standard response `path` (including aliases
and list positions), and `extensions.kind`. Permission errors add
`extensions.permissionClass`, either `capability` or `os-permission`.
Capability errors identify the required capability in
`extensions.requiredCapability`, without revealing protected resource existence.
OS errors carry the provider's consent string and Koine as permission owner in
`extensions.osPermission` and `extensions.permissionOwner` (`koine`). Served
desktop operations report `accessibility`; generic handling preserves the
[legacy failure mapping](#provider-failure-compatibility), including nil mapped
to an empty string and blank strings unchanged. Capability errors also carry
`extensions.phase`: `authorization`
when preflight refused the operation before any action, `execution` when a field
was refused as it ran — a read, or a mutation action whose grant was revoked
after preflight. An unavailable error may echo a reference the caller supplied,
not disclose an otherwise unauthorized resource. Never expose tokens or native
stack traces. Every propagated error retains the original failure path.

**Workflow extension — consent identifiers, pending implementation.** Baseline desktop operations
retain `osPermission: accessibility` and `permissionOwner: koine`. New provider
operations may report other documented consent identifiers in `osPermission`,
still owned by `koine`. The existing framework carries no error-extension
`permissionTarget` or permission reason. Search's target/reason belongs only to
its typed coverage payload. A future generic failure target/reason transport
requires a separately specified compatible framework minor/required feature,
pre-load refusal and validation/legacy-mapping matrix before any operation
relies on it. Consent identifier strings are extensible on the
new operations, not new `kind` or `permissionClass` values. A client of them must
retain an unfamiliar consent as `os-permission`, show its guidance and direct
the user to Koine; it must not relabel every consent as Accessibility. Owners
must document exact identifiers and scope meaning before adding a consent.
This does not add enum values to existing management permission types or alter
what existing desktop clients receive. Any incompatible change to those types,
or a new consent/entitlement, still requires Antony's decision.

**Native discovery extension — designed, native acceptance pending.**
The [native contract](workspace-search.md#coverage-and-frozen-publication) uses
ordinary ProviderValue objects for status, source provenance, observation/category
completeness, nullable items and bounded diagnostics. Aliases share a frozen
parent; all read fields require workspace:read. No new diagnostic ABI/failure
accessor or reinterpretation of nil/blank consent is introduced. Explicit
preparation carries workspace:control; selected reveal carries both workspace
and desktop control. Conditional Automation setup is an explicit human action
only in Koine's local explaining UI, through a private local-console seam that
GraphQL and bearer management authority cannot reach. It is limited by the recorded
[settings decision](../adr/settings-discovery-uses-app-supplied-objects.md), not
implied by a read or an earlier raw-search permission. Existing live-grant,
lifecycle and publication errors retain their original paths. No global
materialization policy is selected.

All extension reads are prompt-free, including prerequisite and protected-folder
checks. A probe that would prompt is not a permitted read mechanism; report
unknown/blocked readiness or coverage instead. App-side API enablement is a
dependency prerequisite, distinct from OS consent. Protected UI targets use
`unavailable` with `reason: protected-target`.

**Additional capability errors — implemented in framework minor 1.** Every
capability error on a field that has additional requirements, at either phase and
at any nested path below it, carries `extensions.requiredCapabilities`, the
complete ordered set described under additional capability requirements, beside
`requiredCapability`, the first unmet member of that order. The order is the
field's own capability first, so the set is not alphabetical: for
`workspaceLaunchApplication` it is `["workspace:control", "desktop:control"]`, and a
grant holding `desktop:control` alone has `workspace:control` as the first unmet
member, one holding `workspace:control` alone has `desktop:control`. A client never
sorts or filters the list.

`extensions.kind` takes exactly four values in `koine-desktop/1`: `permission`,
`unavailable`, `unknown-provider` and `failed`. The set is closed for this
contract version; it is stated here rather than as a schema enum because
extensions are not part of a GraphQL schema. An execution error with a non-empty
`path` and no `kind` is an argument a provider found invalid; nothing was attempted.
It is an execution error like any other: the response keeps the original path and
the root field is null when its type allows, and only what the schema's scalars and
non-null types reject is variable coercion, HTTP 400 with no `data`. A blank string
is empty or whitespace alone.

| Condition | Classification |
|---|---|
| Malformed GraphQL, unknown fields or arguments | GraphQL request validation; no domain execution |
| Malformed process identity or another custom-scalar value (version 1 serves no URI scalar: a URL is a `String` the provider checks) | GraphQL input coercion; no action |
| Well-formed reference names an unregistered provider | `unknown-provider`, after applicable capability checks |
| Known authority, wrong resource kind, malformed provider remainder, or gone target | `unavailable` |
| Missing client read/control/management authority | `permission`, `capability` |
| Koine lacks platform consent | `permission`, `os-permission` |
| OS operation fails, native timeout or malformed provider output | `failed` |

The public surface has no `unknown-relation` or `unknown-command`: clients
submit no relation or command strings, so GraphQL validation decides what those
kinds classified, and such a request is never mapped to `unavailable`. ABI resolver
registration mismatches are host/plugin defects and become `failed`, with a
separate management diagnostic. Transport unavailability and an unknown mutation
outcome are client transport states, not invented successful GraphQL results.

**Extension — dependency availability.** New workflow fields distinguish absent
applications/handlers/integrations through provider-prefixed schema result
objects, as specified in
[dependency results](workflow-providers.md#dependency-results-and-failure-classification).
They do not add a fifth error kind or overload `unavailable`. An available empty
list is success; a dependency-unavailable branch has no successful value and,
for a mutation, certifies only that this action attempted no domain effect.
Stale issued targets retain `unavailable`; grant and native-consent refusals
retain `permission`; a timeout or ambiguous partially attempted action remains
`failed`. Readiness never replaces checking the dependency on the action path.
These schema-level objects require no new ProviderFailure case or ABI feature.
Existing desktop fields keep their null/error behavior.

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

The workflow extension preserves that direct boundary by refusing Koine's own
process as a target of input, menu and other UI-driving operations, including
preparation and session-directed paths. It also refuses recognized consent and
security UI. These are provider obligations checked before effects, not a claim
that arbitrary application control is a sandbox against same-user software or
that public native APIs eliminate every targeting race. The workflow spec owns
the refusal classification and acceptance cases.

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

The exact-target behavior below is not established across actual native PID
reuse; the [native targeting discussion](#native-targeting-discussion) lists the
accepted limits.

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
and textual module interfaces) in all distributed build configurations. Give the major-1 framework one stable module and install name:
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

### Provider failure compatibility

Native discovery must preserve the following existing baseline failure mapping.
The [native discovery contract](workspace-search.md) specifies typed success
values and exact compatibility subjects without inventing failure accessors.
Historical raw-search fields/profiles are not a catalogue ABI. Public failure construction already permits nil and arbitrary strings;
clients/providers must not infer that a semantically incomplete value was
unconstructible. Nil/blank consent is not a prompt-risk sentinel.

| Existing failure kind | permission nil | permission blank (empty or whitespace-only) | permission named/nonblank |
| --- | --- | --- | --- |
| osPermission | Existing permission/os-permission error, owner koine, osPermission empty string | Same error with the supplied string unchanged, without trimming | Same error with the supplied consent unchanged |
| unavailable | unavailable error; permission ignored | Same | Same |
| failed | failed error; permission ignored | Same | Same |
| invalidInput | Input coercion error with path and no domain kind; permission ignored | Same | Same |
| unknownResolver | failed error and existing resolverMismatch provider diagnostic; permission ignored | Same | Same |

The first row's nil/blank values lack a useful consent identifier; they are
legacy malformed semantic values, not evidence of prompt risk or permission
to change their wire behavior. A client can show the supplied guidance and an
unspecified-consent failure, never synthesize Accessibility or UNKNOWN consent
data from them. No new malformed-provider diagnostic is introduced for those
values. A future unknown kind retains the existing failed fallback; malformed
success trees retain the existing failed malformed-value handling. The host
continues supplying original GraphQL paths and permissionOwner koine.

Native catalogue diagnostics live in their typed frozen success payload;
they cannot be attached to ProviderFailure through invented accessors. Existing
loader feature/version checks and retained action-only compatibility remain
binding. The [native acceptance contract](../verification/native-discovery-acceptance.md#exact-identities-and-posture)
pins workspace 1.2.0/schema 1.1.0, update 1.3.0/schema 1.1.0 and required features
without reusing action-only 1.1.0/schema 1.0.1. Every new native outcome stays
pending independently of retained 1.0.0/1.0.1 evidence.

### Resolution and lifecycle

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
cannot run on earlier frameworks. An incompatible framework major would need a
new module/install identity and an explicit host support policy; major 1
promises none. CPU, OS and Swift-runtime prerequisites still apply.

Swift documents the distinction between
[module stability and library evolution](https://www.swift.org/blog/library-evolution/).
Apple documents [class-name lookup](https://developer.apple.com/documentation/foundation/nsclassfromstring(_:))
and [run-path dependent libraries](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/RunpathDependentLibraries.html).
The loader and the independently built version pairs are verified through the
native binary test seam; [binary-compatibility.md](../verification/binary-compatibility.md)
holds the evidence, the supported binary baseline, and what is out of scope or
open.

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
admits only providers signed by Koine's own Team ID, bundled or per-user.
Independent first-party updates additionally depend on the host's loading policy
for that identity. Independently signed
third-party providers do not load: Koine's approval check
refuses one before `dlopen`, and the OS would refuse it after. Loading one needs
the narrowly scoped disable-library-validation entitlement and an install and
approval UI, and Koine has neither. Apple documents this
[third-party plugin requirement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.cs.disable-library-validation).

The designed extension's [selection policy](#first-party-provider-selection)
implements independent upgrades for identities also shipped inside the application.
It does not relax any trust check above. Koine 0.1.0 retains the baseline duplicate
and desktop-replacement refusals; selection support must ship before the second
bundled provider. Same-team signing alone never authorizes a per-user copy.

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

With the extension, a provider rejected before schema publication also removes
every contribution whose additional-capability owners become unavailable, to a
fixed point. A rejected desktop provider can therefore remove workspace and
other dependent contributions while management remains available. This differs
from a provider that fails startup after publication, as described above.

### First-party provider selection

**Extension — the loader's selection is implemented (`provider-selection`) and
its management fields and window grouping are published (`selection-diagnostics`);
its acceptance is under way: every row assigned to the native loader and public
GraphQL is established, but for the parts that need a second real Developer ID
team's certificate, and the rows assigned to signed isolated VMs are established
on notarized hosts with workspace 1.0.1/schema 1.0.1 as the baseline and
workspace 1.1.0/schema 1.0.1 as its update, except the same second-team parts
(see "Selection acceptance").** The
[selection decision](../adr/first-party-provider-selection.md) owns the trade-off.
The [selection flow](../design/architecture/index.html#diagram-provider-selection)
and [failure boundary](../design/architecture/index.html#diagram-provider-publication)
show this contract. Selection is a startup calculation over one discovered set;
there is no live installation, approval UI, new install root or second loader.

#### Reserved identities

The application seals a host-owned catalogue containing `desktop` / `Desktop`,
`workspace` / `Workspace`, `input` / `Input`, `menus` / `Menus`, `iterm` / `Iterm`
and `herdr` / `Herdr`. Core ownership of `koine` / `Koine` is unchanged.
Reservation never depends on a discovered manifest, successful load, published
schema or successful start. Each catalogue entry is either reserved-only or
enabled. An enabled entry names its one designated bundled bundle, exact bundled
release and schema versions, and a stable release code-signing identifier. Its
approval Team ID is derived from the verified
running host signature, not a hard-coded publisher: a separately signed host
uses its own team. An unsigned or ad-hoc development host has no team and admits
no shipped candidate (`host-team-unavailable`), while reservations and core
management remain. Test hosts must supply real signed identities for trust
acceptance. A reserved-only entry cannot
load from either root; it is enabled by a host release when that provider ships.
The first extension host enables desktop and workspace and reserves the rest.

Only the exact identifier/prefix pair can claim a shipped slot. A different
identifier claiming its prefix, a shipped identifier claiming another prefix,
or a non-shipped prefix overlapping a reserved prefix in either direction is
refused alone. Root-field prefix checks use the corresponding lower-case form.
For example, claimants using `Desk` or `DesktopTools` are refused alone because
they overlap `Desktop`.
Apply this namespace exclusion to declarative SDL names as well as manifest
prefixes; a rejected claimant cannot enter the collision set and evict the
reserved owner. It holds when the owner is absent, rejected or reserved-only.
An exact-pair per-user candidate is considered only under that slot's update
rules, never as an ordinary competing external provider.

The designated bundled candidate must match its catalogue entry, including
release/schema versions (`catalogue-bundle-mismatch` on disagreement). Unexpected
bundles inside the sealed root are refused (`unexpected-bundled-candidate`);
they cannot replace the designated bundle. A missing or refused bundle leaves
the catalogue's baseline intact. An eligible per-user update can still fill that
enabled slot. If neither can, the slot is unavailable and remains reserved.
A malformed or internally conflicting host catalogue is a packaging failure:
publish core management alone with a catalogue diagnostic and admit no provider,
rather than inventing reservations from discovered bundles.

The catalogue is sealed with the application as
`Contents/Resources/ProviderCatalogue.json` (source `App/ProviderCatalogue.json`):
an object whose `identities` array holds `providerId` and `graphQLPrefix` for
every entry and, for an enabled one, `bundle` (the designated bundle's name in
`Contents/PlugIns`), `release`, `schema` and `signingIdentifier`. An unknown key,
a partial baseline, a malformed version, two entries that overlap on an
identifier or prefix in either direction, or a claim on `koine` is a conflicting
catalogue. `task check:provider-catalogue` holds an enabled entry to the signed
packaged bundle's own signature and manifest.

#### Eligibility and precedence

Per-user approval is still the existing provider-ID/Team-ID record. For shipped
identities it authorizes compatible updates subject to the catalogue's release signing
identifier, not a particular path or binary hash. Verify that identifier from
the staged bundle's code signature, not a manifest claim, for both bundled and
per-user shipped candidates; disagreement is `REJECTED` /
`signing-identifier-mismatch`. The catalogue value is a host-owned publication
identity, stable across that provider's compatible releases. Nested private
dependencies retain their own signing identifiers and the existing per-image
team/signature checks; do not require them all to share the provider's identifier.
This explicitly narrows team-wide approval to the intended release identity,
without restricting certificate class or adding entitlements. Apple's
[requirement language](https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements)
supports the identifier check alongside the existing Apple anchor/Team-ID check.

Selection fixtures use distinct code-signing identifiers admitted only by
purpose-built test catalogues. Never sign a fixture under a production provider's
release identifier. A production catalogue must reject such a fixture even when
its manifest claims the reserved pair and a high release and its Team ID is
approved. This prevents accidental fixture admission, not a trusted publisher
deliberately signing other code under the release identifier. Release signing
remains a trusted operation.

Built-in approval never substitutes for a per-user approval record. Verify the staged signature and every
private image against that record and the host's Team ID. Location, staging,
dependency closure, architecture, OS/runtime, framework, feature and quarantine
checks remain mandatory. Claimed metadata on an untrusted bundle cannot affect
another candidate's eligibility or precedence. This also applies to ordinary
non-reserved providers: candidates refused by these pre-load checks do not
contest manifest identifier/prefix collisions.

Every newly published first-party update declares `first-party-selection-v1`
in both manifest and descriptor. A selection-aware host supplies this feature;
a pre-extension host refuses the unsupported feature as `INCOMPATIBLE` before
`dlopen`, even when the update renames its principal class. An extension host
refuses a per-user shipped-identity candidate missing that declaration as
`INCOMPATIBLE` with `selection-feature-required`. Its designated, exact bundled
baseline may be an independently compiled old provider without the feature.
This is a host selection feature, not a new factory witness or a substitute for
`additional-capabilities-v1` where operations require that feature. Previously
published feature-free binaries do not gain a pre-load refusal guarantee on old
hosts retroactively; those hosts can execute their factories before rejecting
external desktop composition.

For reserved identities, release and schema versions are three decimal components
`major.minor.patch`, each in `0...2147483647`, with no leading zero except `0`,
no sign, suffix or build metadata. Compare numerically, component by component;
`1.10.0` exceeds `1.9.0`. This is a first-party publication rule, not a new parser
restriction on existing non-reserved providers. A per-user update must have a
release strictly greater than the sealed bundled baseline, the same schema major,
and a schema version at least that baseline. Release majors do not imply schema
or framework majors. Schema compatibility and every declared runtime/framework
requirement must independently hold. Malformed versions are `REJECTED`; honest
unsupported schema/framework/runtime requirements are `INCOMPATIBLE`.

For each enabled slot, form the eligible per-user set using those checks:

| Eligible candidates | Selected candidate |
| --- | --- |
| No eligible newer per-user copy | The designated bundled copy if it passes verification; otherwise none. |
| One greatest per-user release | That update, even if the bundled copy is absent or refused. |
| Several copies at the greatest eligible per-user release | Refuse that whole release group as `ambiguous-update`, remove it from eligibility, and repeat this calculation. A unique lower update or the verified bundle may be selected with visible refusals. Identical bytes in two installed directories are still an ambiguous installation. |

Do not break a tie by path, discovery order, modification time, schema version
or content hash. Directory aliases resolving to the same canonical bundle are
one discovered candidate; distinct canonical directories remain distinct.
Equal-to-baseline and older copies never override the bundle, even when it is
missing or broken. Multiple lower copies cannot contest a unique higher copy.
Non-reserved providers retain the ordinary duplicate-identifier/prefix/name
refusals; this is not a general multiple-version package resolver.

A pre-load refusal excludes only that candidate. The initial calculation may
therefore select a lower eligible release or the bundled baseline when a newer
copy is incompatible, unapproved, malformed or otherwise refused. This must be
visible both on the refused candidate and in the selected candidate's diagnostic,
with the known refused version and reason; unverifiable version claims are labelled
as claims. It is not a successful update. A malformed unidentified bundle stays
visible as a bundle-level refusal without being assigned authority over a slot.

Once the choice is frozen, **never retry a different version in that process**,
including on load, descriptor, schema, dependency-cascade or startup failure.
Recovery is an operator changing the installed set or fixing approval and
restarting; ambiguity requires removing the extra copy. There is no persistent
highest-seen-version store: removing an update or changing the host may lower the
next startup's selected release, and management reports the newly selected version.
The sealed host baseline is the floor, not an anti-rollback guarantee across host
releases. Client grants remain tied to the provider identity and are not reissued
or widened by selecting a different binary.

Determinism means the same candidate set and verification verdicts give the same
choice. Online quarantine assessment can fail or time out on another restart,
changing the eligible set and chosen release. Discovery, staging and verification
cost grow with installed copies, even superseded ones; the per-image assessment
bound is not a total startup deadline. These are accepted startup limits.

#### Selection before execution

The resident composition supplies both roots and the sealed catalogue in one
invocation. The loader owns discovery, immutable staging, verification and
selection; it returns candidate reports and only the selected native providers.
The loader checks manifest identity/prefix and selected principal collisions;
the Machine core independently validates descriptors, SDL and authority, handles
their remaining collisions, and owns the missing-owner fixed point, schema
publication and lifecycle. Callers
do not reconstruct selection by loading each root separately or by changing a
candidate's physical origin flag. Keep this calculation separate from loading
effects so the existing native seam can substitute candidate sets and observe
initializer/factory/start markers without exposing a public test API.

Each immutable staged copy belongs to one physical origin and canonical installed
location as well as its content digest. Equal bytes or basenames in different
candidates must never share a staged copy, and old shared staging entries must
not be reused under this policy. Preserve extended attributes; assess and load
the same copy. Per-user quarantine cannot be inherited by the bundled copy, nor
can a bundled copy suppress a per-user assessment. Aliases of one canonical
candidate still share its identity. The existing same-candidate quarantine
recovery procedure remains applicable.

Before **any** provider `dlopen`, finish discovery and all declarative checks
needed for selection across both roots. Exclude pre-load refusals and reserved
namespace claimants; check ordinary manifest identifier/prefix collisions among
the remaining eligible candidates, then freeze the choices. Non-selected
copies never reach principal-class lookup, factory construction or start. Check
the selected manifests' principal names as a batch: names must be mutually unique
and free in the already loaded host. A conflicting non-reserved candidate is
refused alone when it contests a shipped candidate; conflicts among shipped
selections, among non-reserved selections, or with an existing host class refuse
the affected selections, with no candidate retry. In particular, a shipped update
and another shipped identity's bundled selection are equal slot owners: both are
refused on a principal conflict, regardless of physical origin. Their dependent
contributions may also disappear. This availability cost is explicit; preferring
the bundled side would make origin decide authority after selection froze.
Unselected alternatives do not
contest principal names. A private image or dependency must not pull an unselected
provider image into the process; bundles may depend on the host framework and
their verified private dependencies, not other provider bundles.

First-party publication must keep Swift module names and Objective-C runtime
class names disjoint across provider identities and from the host, including
private dependencies and explicitly named Objective-C classes. Shared helper
source is compiled under provider-unique module/class names, or supplied once
by a host-owned shared framework under its compatibility contract. Independently
updated bundles must not each embed versions of the same shared module. Release
checks inspect private images and exercise mixed provider releases. The loader's
principal check is not a complete runtime-name inventory; native code outside
that declaration remains trusted, not sandboxed. Launch-and-open owns the first
mixed-release acceptance and the bounded platform confirmation.

Load frozen selections in canonical composition order. Runtime factory class
origin, shared-framework conformance and descriptor agreement are checked after
loading, then SDL and registration/authority validity before publication. A
descriptor may not change the selected identity or prefix. Where a contribution
attempts another identity's reserved names after loading, reject only that
claimant, then perform ordinary collision checks among the remaining non-reserved
contributions. Other
genuine collisions retain the both-refused rule. Missing additional-capability
owners then remove dependents to a fixed point. Neither a late claimant nor a
missing owner reopens selection.

A selected image can run initializers before descriptor/schema refusal; that
image and loaded dependencies remain mapped until exit, though they contribute
no schema and are never started. A dynamic-loader failure may also have mapped
dependencies: do not claim rejection implies no native code ran once `dlopen` was
attempted. Successful publication precedes start. A start failure retains the
published schema/capabilities and reports `FAILED`; its own resolutions are
`unavailable`, and authority dependents are not removed merely because it failed
to start. A pre-publication rejection removes the provider and its dependent
contributions. Core management remains available in either case. Root-enumeration
or core startup failures still fail server startup; there is no partial discovery
presented as a complete candidate set.

#### Candidate diagnostics and schema identity

Extend `KoineManagement.providers` in place, keeping every existing field and
`KoineProviderState` value. It reports each discovered canonical candidate,
including all refused and non-selected copies. An enabled slot whose designated
bundle is missing always has a synthetic `missing-bundled` row, even when an
update fills it; it points to that update through `selectedCandidateId`. Otherwise
an enabled slot with no frozen choice has one synthetic `no-eligible-candidate`
row. Do not add both synthetic rows for the same slot. A frozen selection later
refused remains its actual candidate row and does not create a synthetic row.
Reserved-only entries need no status row unless a bundle claims them.
A catalogue failure has one synthetic
`provider: (unknown)` row with unknown versions, `REJECTED`, `selection: UNAVAILABLE` and
`reason: catalogue-invalid`; it names no provider authority. Existing `provider`,
`version` and `schemaVersion` describe that row's manifest claims. Unidentified
provider claims use `(unknown)`, which is not a valid provider identifier;
unknown versions still use `unknown`. The valid provider ID `unknown` remains
available. Synthetic missing-slot rows name the catalogue's provider identity,
with unknown actual versions; diagnostics give the expected baseline. Only a selected,
published candidate can become `ACTIVE` or `FAILED`.

Add nullable fields on `KoineProviderStatus`; these are additive metadata and
introduce no new provider-framework requirement or error kind:

| Field / GraphQL type | Meaning |
| --- | --- |
| `candidateId: String` | Opaque identity of origin plus canonical installed bundle location, unique within this startup; null only for a synthetic row. Not a resource reference. |
| `origin: KoineProviderOrigin` | New enum: `BUNDLED` or `PER_USER`; null for a synthetic row. Never inferred from composition position. |
| `selection: KoineProviderSelection` | New enum: `SELECTED`, `NOT_SELECTED` or `UNAVAILABLE`. A frozen choice remains `SELECTED` even if later rejected or startup-failed. Synthetic rows are `UNAVAILABLE`. |
| `selectedCandidateId: String` | The frozen choice for the same provider identity, or null if there is none. A selected row points to itself, even on later failure. |
| `reason: String` | Stable, open diagnostic code for a refusal or selection explanation; null for a healthy selected row with no competing refusal or missing-bundle diagnostic. |

Version/prefix claims never determine `candidateId`. Keep one report per candidate
through all phases; do not merge reports by provider ID or attach one candidate's
failure to another copy. Reports sort by provider, origin and candidate ID in
Unicode order, with synthetic rows last for that provider. These fields are filled
on extension-host reports wherever their meaning is known; nullable types preserve
older callers and represent unidentified/synthetic cases. Management authority
continues to protect the entire surface, including locations in human diagnostics.

### Capability disclosures

Grant creation, request approval and the grant list must tell a person a
capability's reach wherever it is granted or held, and a `koine:manage` client
must be able to show the same words. The provider framework carries no
description, and an ordinary provider has no disclosure channel, so the core owns
a small catalogue keyed by capability name. Management serves it as additive
metadata, with no new provider-framework requirement, capability or error kind:

| Field / GraphQL type | Meaning |
| --- | --- |
| `KoineManagement.capabilityDisclosures: [KoineCapabilityDisclosure!]!` | One entry per capability that has a disclosure, in capability order, served whether or not its provider is active, because a grant may hold a capability whose provider failed to load. Requires `koine:manage`; serving it supplies no authority. |
| `KoineCapabilityDisclosure { capability: String!, disclosure: String! }` | The capability name as listed in `availableCapabilities` and held by grants, and plain text stating its reach, including any other capability it needs. |

The extension-host design files carry the field; `desktop-schema.graphql` and the
`core-desktop-old-host` profile do not, because a released host never served it.
A client of an older host gets a GraphQL error for the field and must show its own
fallback rather than treat the absence as "nothing to disclose". The native window
shows each disclosure beside its capability in all three places and shows nothing
for a revoked grant, which holds nothing. `workspace:control` is the first entry;
[workspace disclosure](../verification/workspace-disclosure-vm.md) records the text
and its acceptance. Each later increment that owes a disclosure
([workflow spec](workflow-providers.md#authority-allocation)) adds its capability
here, so the window and every manager change together.

The native workspace release requires corrected core disclosures before the host
advertises `workspace-native-disclosures-v1`. All three native grant views and
management use the same entries:

| Capability | Required native-surface disclosure |
| --- | --- |
| `workspace:read` | Read Koine-account special-location values and native application/System Settings metadata, including fixed application information/name files and direct localization names. Returned locations grant no access to their contents or to the client's filesystem. |
| `workspace:control` | Prepare System Settings in the background without desktop control. Launch applications, open URLs/files and reveal files or selected Settings destinations only with desktop control. Any registered installed application may be launched; a handler can execute scripts or follow location documents to other schemes and targets. Metadata refusal is not a content sandbox. |

The action-only shipped wording and its recorded VM acceptance remain historical
evidence; they do not disclose this native surface. App-and-file-search owns the
actual core catalogue/UI/management implementation and independent acceptance
before that release. OS Automation setup is outside bearer capability reach and
explains consent for the Koine-host/System Settings pair in Koine's UI. The
[host-feature decision](../adr/native-workspace-requires-disclosure-capable-host.md)
refuses native providers on prior hosts before loading, rather than relying on
provider text to correct core-owned surfaces.

Non-selected valid copies use `REJECTED` with a precise reason: `older-than-bundled`,
`equal-to-bundled` or `superseded-candidate`; it means their contribution was refused,
not that their signature failed. Other required reasons include `reserved-identity`,
`reserved-only`, `ambiguous-update`, `invalid-version`, `schema-incompatible`,
`missing-bundled`, `catalogue-bundle-mismatch`, `unexpected-bundled-candidate`,
`catalogue-invalid`, `host-team-unavailable`, `signing-identifier-mismatch`,
`selection-feature-required`,
`no-eligible-candidate`, `manifest-collision`, `principal-collision`,
`missing-capability-owner` and `selected-with-refusals`.
Existing trust/compatibility failures retain their
classification and gain a stable reason at implementation:
`location-outside-root`, `staging-failed`, `manifest-invalid`, `not-approved`,
`approval-team-mismatch`, `signature-refused`, `framework-incompatible`,
`feature-unavailable`, `architecture-incompatible`, `os-incompatible`,
`runtime-incompatible`, `image-invalid`, `quarantine-refused`, `load-failed`,
`principal-class-missing`, `principal-class-invalid`, `descriptor-mismatch` and
`check-failed`. A refusal the core makes after loading carries the
kebab-case form of its diagnostic (`invalid-sdl`, `name-collision`,
`reserved-identity` for a reserved name claimed by a loaded descriptor, and so
on), and a selected provider whose start fails carries `start-failed`. `diagnostic` supplies
the concrete failure, compared versions, affected owner and recovery action.
The native UI groups copies by identity, identifies physical origin and selection,
and shows ignored/refused updates alongside the running version. No success banner
may conceal a refused update. A missing slot is `REJECTED`; an incompatible actual
candidate retains `INCOMPATIBLE`. Multiple causes remain in the human diagnostic.

The same selection values apply to ordinary providers: an eligible unique choice
is `SELECTED`; pre-load refusals and both sides of ordinary manifest collisions
are `NOT_SELECTED`, with no frozen choice for the contested identity. Ordinary
manifest collisions use `manifest-collision`. Later principal or core refusals
retain `SELECTED` and the relevant failure reason. All copies in an ambiguous
release group are `NOT_SELECTED` / `ambiguous-update`; a lower frozen choice is
`SELECTED` / `selected-with-refusals`. Other eligible lower copies are
`NOT_SELECTED` / `superseded-candidate`, including the bundled copy when an update
wins. A refused bundled copy keeps its actual refusal reason. A healthy choice
with any same-identity refused candidate or missing-bundle row uses
`selected-with-refusals`; if it later fails, its own failure takes the reason
field and the earlier refusals remain in its diagnostic and their own rows.
The missing-slot synthetic diagnostic enumerates the causes and recovery even
when its stable reason is `missing-bundled` or `no-eligible-candidate`.

Publish only the admitted selected contributions: core first, shipped identities
sorted by identifier, then ordinary per-user identities sorted by identifier.
Catalogue listing order is not composition order. Missing slots leave no
placeholder fields.
Candidate paths, release numbers and status values do not enter canonical SDL;
an identical contribution selected from another root has the same digest on the
same host/printer. Changed SDL, including these additive management fields, changes
the digest. Conformance profiles identify the exact expected candidate versions
and contributions separately from SDL equality: an identical digest cannot prove
which binary ran. Preserve the original core + desktop profile for old hosts and
add extension-host profiles with the expanded management schema. An omitted required
provider fails the profile instead of shrinking its expected schema.

#### Conformance profiles

A profile is a design SDL plus, separately, the exact provider candidates the host
runs. Profiles live in [`docs/design/profiles/`](../design/profiles/) and
`task conformance` holds the host to one; the check
(`Tools/Conformance --profile … --providers …`) has two halves that neither
substitute for the other, because an identical digest cannot prove which binary ran.

| Profile | Design SDL | Candidates pinned |
| --- | --- | --- |
| `core-desktop-old-host` | [`desktop-schema.graphql`](../design/desktop-schema.graphql), unchanged since 0.1.0 | `desktop` 1.0.0 / schema 1.0.0, `ACTIVE`, over the original five management fields |
| `core-desktop-extension-host` | [`desktop-schema-extension-host.graphql`](../design/desktop-schema-extension-host.graphql) | `desktop` 1.0.0 / schema 1.0.0, `ACTIVE`, `BUNDLED`, `SELECTED`, no reason |
| `core-desktop-workspace-extension-host` | [`desktop-workspace-schema-extension-host.graphql`](../design/desktop-workspace-schema-extension-host.graphql): the workspace design restricted to the implemented roots and the types they reach, verbatim | `desktop` and `workspace`, each 1.0.0 / schema 1.0.0, `ACTIVE`, `BUNDLED`, `SELECTED`, no reason |
| `core-desktop-workspace-repair-extension-host` | [`desktop-workspace-repair-schema-extension-host.graphql`](../design/desktop-workspace-repair-schema-extension-host.graphql): the row above with the action-only repair's three appended descriptions (workspace 1.0.1), so its digest differs on the same host and printer | `desktop` 1.0.0 / schema 1.0.0 and `workspace` 1.0.1 / schema 1.0.1, each `ACTIVE`, `BUNDLED`, `SELECTED`, no reason; the signed application as shipped is held to this one, and the row above to the retained 1.0.0 bundle |

The extension-host SDL is the old one plus exactly the five nullable
`KoineProviderStatus` fields and the `KoineProviderOrigin` and
`KoineProviderSelection` enums; a test compares them and names any other
difference. The set of rows is explicit. A required provider that is not served
fails the profile, and so does a served row the profile does not list, so
neither an omission nor an extra provider can shrink or blur what is expected. An
extension-host profile also requires the candidate fields on every row, and every
`SELECTED` row to name itself. Each profile is checked against the schema a host
serves, and only after its design and pin controls have been seen red: the
old-host profile against the released host running its own desktop provider, the
extension-host profile against this tree's headless host, and the core + desktop +
workspace profile against the signed application in a VM
([schema-conformance-vm.md](../verification/schema-conformance-vm.md),
[launch-contract.md](../verification/launch-contract.md)). The workspace design
file never rewords the workspace design: a test holds it to the complete workspace
design, so that the only differences are the roots not yet implemented and the
types only they reach, and a root that lands is added to the profile verbatim. An
explicit absent/rejected profile is held in the same way:

| Profile | Design SDL | Candidates pinned |
| --- | --- | --- |
| `selection-cascade-extension-host` | [`core-schema-extension-host.graphql`](../design/core-schema-extension-host.graphql): the extension-host core with no provider contribution, which a test holds to `desktop-schema-extension-host.graphql` less exactly the desktop coordinates | five `REJECTED` rows and no `ACTIVE` one: the refused shipped provider (`SELECTED`, `invalid-sdl`) and its superseded bundled baseline, the shipped update removed for a missing capability owner (`SELECTED`, `missing-capability-owner`) and its superseded baseline, and the ordinary provider removed the same way |

It is served by a signed purpose-built host and checked by `task selection:failures`, not
`task conformance`, because it is a failure profile: the fixture providers stand in for the desktop,
workspace and third providers so that nothing in the production catalogue is refused
([selection-failures.md](../verification/selection-failures.md#desktop-rejected-before-publication)).
Its design half is seen red against the wrong design and a mutated copy, and its pin half against a
wrong reason, a wrong selection, a row left out and a provider that is not served. The profiles with
selected updates, and the explicit rejected ones for an update a host refuses, are beside these:

| Profile | Design SDL | Candidates pinned |
| --- | --- | --- |
| `core-desktop-update-extension-host` | [`desktop-schema-extension-host.graphql`](../design/desktop-schema-extension-host.graphql) | desktop 1.1.0 `PER_USER` `SELECTED` and `ACTIVE`; the bundled 1.0.0, the desktop provider of the released revision compiled independently, `superseded-candidate` |
| `core-desktop-workspace-desktop-update-extension-host` | [`desktop-workspace-repair-schema-extension-host.graphql`](../design/desktop-workspace-repair-schema-extension-host.graphql), the workspace 1.0.1 composition | a mixed release: desktop 1.1.0 selected over its superseded 1.0.0, workspace 1.0.1 / schema 1.0.1 bundled and selected |
| `core-desktop-workspace-workspace-update-extension-host` | the same | the other mixed release: desktop 1.0.0 bundled and selected, workspace 1.1.0 / schema 1.0.1 selected over its superseded bundled 1.0.1 |
| `core-desktop-workspace-update-extension-host` | the same | both updated, each over its superseded bundled release |
| `core-desktop-workspace-update-refused-extension-host` | the same | each 1.1.0 update `INCOMPATIBLE` / `selection-feature-required` and `NOT_SELECTED`, each bundled release (desktop 1.0.0, workspace 1.0.1) `ACTIVE` and `SELECTED` with `selected-with-refusals` |
| `core-desktop-workspace-repair-per-user-extension-host` | the same | the retained workspace 1.0.0 bundled, and the repair's 1.0.1 / schema 1.0.1 approved per user stating `first-party-selection-v1`: 1.0.1 `PER_USER` and `SELECTED`, the bundled 1.0.0 `NOT_SELECTED` as `superseded-candidate`; served by the retained revision's host and this tree's, not by `task selection:updates` ([workspace-compatibility.md](../verification/workspace-compatibility.md)) |
| `core-desktop-old-host-update-refused` | [`desktop-schema.graphql`](../design/desktop-schema.graphql), the original core + desktop contract | served by the released host (`management: baseline`): desktop 1.0.0 `ACTIVE`, and a newly published desktop 1.1.0 `INCOMPATIBLE` before it loads |

They are served by signed purpose-built hosts, headless, around the real providers and checked by
`task selection:updates`, not `task conformance`; each is held with its own controls, red against the wrong
design and against the same four mutated pins, and against each workspace row pinned at the retained 1.0.0
([selection-updates.md](../verification/selection-updates.md#conformance-profiles)).

#### Selection acceptance

Launch-and-open owns implementation and acceptance of this entire contract before
shipping workspace. The Evidence column links each row's record; a row without a
link remains **pending**. The seam column assigns the
required evidence: **N** = native loader with real independently built binaries;
**G** = public GraphQL management/introspection/operations; **V** = signed isolated
TestAnyware macOS VM. N uses a fresh host subprocess and fresh initializer/factory/
start log for each scenario, including each alternative selection or order.
Process reuse cannot establish that an image never loaded. A refused-marker
assertion needs a successful-load control proving that binary writes its marker.
Use desktop/workspace pairs sharing the normal principal names across releases,
and a renamed-principal variant where specified.

N can substitute discovered candidate order at the existing private seam, while
still exercising the real verifier and loader; no public test API is added.
For missing, mismatched or unexpected in-app bundles and malformed catalogues,
build purpose-specific test hosts with that content **before** signing them.
Do not modify a notarized app and call the resulting broken seal a catalogue
test. V quarantine cases use an intact notarized host and genuinely quarantined
downloads; where a purpose-built V host is required, sign and notarize that
variant first. Invalid-signature fixtures are intentionally altered only in
the signature-refusal cases. An in-process descriptor substitute cannot close
native loading, signing or V observations.

| Case | Seams | Required observation | Evidence |
| --- | --- | --- | --- |
| Old host + old desktop; new host + independently compiled old designated baseline | N, G, V | Existing desktop operations/errors/grants work; preserve old and extension-host core + desktop profiles (see "Conformance profiles"). Catalogue matches the packaged baseline; no new factory witness. | **Established** at N and G: [old host and new host](../verification/selection-updates.md#old-host-and-new-host-over-an-old-baseline). **V established** on notarized hosts ([selection-vm.md](../verification/selection-vm.md#workspace-101-rerun)) |
| Selection-aware host + compatible newer desktop/workspace update | N, G, V | Separate correct approval; exactly one chosen image/factory/start marker per slot; unselected bundle never loads. Management names the update and real operations work without rebuilding the host. | **Established** at N and G: [compatible newer updates](../verification/selection-updates.md#compatible-newer-updates). **V established** on notarized hosts with workspace 1.0.1/schema 1.0.1 as the bundled baseline and workspace 1.1.0/schema 1.0.1 as its update ([selection-vm.md](../verification/selection-vm.md#workspace-101-rerun)) |
| Pre-extension host + newly published desktop/workspace update, both normal and renamed principal | N, G, V | `first-party-selection-v1` is refused as `INCOMPATIBLE` before load; no update initializer/factory marker. Existing bundled desktop remains usable. On the extension host, a per-user update missing this feature is refused as `selection-feature-required`. | **Established** at N and G: [a host that predates the feature](../verification/selection-updates.md#a-host-that-predates-the-feature). **V established** on notarized hosts ([selection-vm.md](../verification/selection-vm.md#workspace-101-rerun)) |
| Retained workspace 1.0.0 host or bundle + the action-only repair, workspace 1.0.1 (bundled, and approved per user) | N, G | Independently built old and new providers each in each host (the retained revision's own and this tree's), with the exact candidate rows, the profile of the release served and the binary that ran: the retained 1.0.0 stays independent and is not relabelled; the approved per-user 1.0.1 variant is `SELECTED` / `PER_USER` over the bundled 1.0.0 `NOT_SELECTED`; the shipped 1.0.1 without the selection feature is refused and 1.0.0 keeps the slot. The same short and impossible locations give the same outcome in both releases, and the retained revision's own short-path suites pass against 1.0.1. | **Established** at N and G: [workspace-compatibility.md](../verification/workspace-compatibility.md). Not run at V |
| Missing approval, wrong Team ID, unsigned/ad-hoc/tampered seal, escaping location, incompatible framework/feature/OS/architecture, failed quarantine assessment | N, G, V | Each refusal has no initializer marker; eligible lower/bundled selection has visible refusal diagnostics. Real second-team signing stays pending if no certificate is available; mocks cannot close it. Stage/quarantine recovery is exercised. | **Established** at N and G except a bundle signed by a second team, **pending** in `alternate-team-signing`: [trust refusals](../verification/selection-updates.md#trust-refusals). **V established** on notarized hosts, again except a bundle signed by a second team, **pending** in `alternate-team-signing`: ([selection-vm.md](../verification/selection-vm.md#workspace-101-rerun)) |
| Approved same-team fixture claiming a reserved pair/high release under a different signing identifier | N, G, V | Production catalogue refuses it before load as `signing-identifier-mismatch`; valid release candidate remains selected. A purpose-built test catalogue admits its distinct fixture identifier. Correctly identified compatible release needs no new hash approval. Never generate this negative fixture under the production signing identifier. | **Established** at N and G: [a fixture under another signing identifier](../verification/selection-updates.md#a-fixture-under-another-signing-identifier). **V established** on notarized hosts with workspace 1.0.1/schema 1.0.1 as the real baseline and designated test bundle ([selection-vm.md](../verification/selection-vm.md#workspace-101-rerun)) |
| Releases 1.9.0 and 1.10.0; malformed triple; equal/older baseline; schema-major mismatch/regression | N, G | Numeric winner and exact refusal classes; no older/equal takeover; visible fallback when a higher release is ineligible. Reverse candidate discovery order at N with fixed verdicts and preserve the outcome. | **Established** at N and G: [version rows](../verification/selection-decisions.md#version-rows) |
| Greatest tie, successive tied groups, lower duplicates, canonical-directory alias | N, G | Refuse tied highest groups and choose a unique lower update or verified bundle; if neither exists, report the missing slot. Tied candidates never load. Lower duplicates do not contest a unique higher winner. Aliases count once; path renaming and discovery reversal do not change outcomes. | **Established** at N and G: [tie rows](../verification/selection-decisions.md#tie-rows) |
| Reserved identity/prefix/SDL claimant; owner absent/rejected or reserved-only | N, G | Refuse claimant alone; never evict an owner or enable a reserved-only slot. Exercise both pre-load claims and post-load descriptor/SDL mismatch. | **Established** at N and G: [reserved claimants](../verification/selection-decisions.md#reserved-claimants) |
| Missing/refused/mismatched designated bundle, valid newer update, unexpected in-app claimant | N, G | Purpose-built signed hosts retain catalogue floor/reservations. Newer update can fill the slot; equal/older cannot. Missing bundle remains a synthetic diagnostic even with an active update. Exact mismatch/unexpected reasons; never substitute the unexpected bundle. | **Established** at N and G: [designated bundle](../verification/selection-decisions.md#designated-bundle) |
| Equal bytes and basename in both roots; quarantined per-user copy; legacy shared staging entry | N, G, V | Stage in both orders and restart after host catches up to the update. Copies remain candidate-specific; bundled loading never inherits per-user quarantine and per-user assessment is never skipped by cache reuse. No unexpected dialog; record actual assessment and loaded paths. | **Established** at N and G: [equal bytes in both roots](../verification/selection-updates.md#equal-bytes-in-both-roots). **V established** on notarized hosts ([selection-vm.md](../verification/selection-vm.md#workspace-101-rerun)) |
| Frozen update fails principal check, dlopen, descriptor or schema with healthy alternatives | N, G | No alternative loaded/started; choice stays identifiable. Principal refusal precedes load; post-load refusal can leave images mapped. Repair/remove and restart to recover. | **Established** at N and G: [frozen update fails later](../verification/selection-failures.md#frozen-update-fails-later) |
| Shipped update principal conflicts with another shipped bundle; ordinary candidate conflicts with shipped selection or host class | N, G | Both shipped selections refused symmetrically; ordinary claimant alone refused against shipped owner; host-class conflicts refused. No retry. Diagnostics/capability-owner cascade agree. | **Established** at N and G: [principal conflicts](../verification/selection-failures.md#principal-conflicts), and the capability-owner cascade's agreement with them: [the cascade](../verification/selection-failures.md#desktop-rejected-before-publication) |
| Ordinary duplicate identities/prefixes, with unapproved/incompatible rivals | N, G | Only pre-load-eligible rivals contest. Eligible duplicates both refused as `manifest-collision` / `NOT_SELECTED`; a refused untrusted rival cannot evict a valid provider. | **Established** at N and G: [ordinary duplicates](../verification/selection-failures.md#ordinary-duplicates) |
| Desktop rejected before publication; workspace depends on desktop; third provider on workspace | N, G | Fixed-point removal agrees with exact absent/rejected profile, capabilities and diagnostics; management usable. Valid dependency cycle survives. | **Established** at N and G: [desktop rejected before publication](../verification/selection-failures.md#desktop-rejected-before-publication) |
| Desktop published but start fails | N, G | Schema/authority retained; its fields unavailable; workspace not removed solely for this failure; no bundled retry. | **Established** at N and G: [desktop published but start fails](../verification/selection-failures.md#desktop-published-but-start-fails) |
| Same SDL across roots, changed SDL in newer copy, extra ordinary provider | N, G | Same-content replacement preserves digest and identifier-sorted shipped position; changed SDL changes digest. Pin candidate versions separately. Deny management fields without `koine:manage`. Include later enabled identities in purpose-built catalogue to distinguish identifier order from catalogue order. | **Established** at N and G: [same SDL, changed SDL, extra provider](../verification/selection-failures.md#same-sdl-across-roots-changed-sdl-in-a-newer-copy-extra-ordinary-provider) |
| Mixed desktop/workspace releases and reused helper source | N, G, V | Private-image module/runtime-class inventory is disjoint across identities and host except the single host-owned shared framework; each selected provider executes its own expected implementation. Record native observations without claiming loader sandboxing. | **Established** at N and G, with the workspace baseline re-pinned to the repair's 1.0.1: [mixed releases](../verification/selection-updates.md#mixed-releases), [re-pinned](../verification/selection-updates.md#re-pinned-to-workspace-101). **V established** on notarized hosts with workspace 1.0.1/schema 1.0.1 as the bundled baseline and workspace 1.1.0/schema 1.0.1 as its update ([selection-vm.md](../verification/selection-vm.md#workspace-101-rerun)) |
| Restart after update removal or changed baseline; changed assessment verdict; unreadable root | N, G | Recompute without granting authority; no anti-rollback or cross-restart verdict guarantee. Inject verdict changes at N. Root enumeration failure stops startup instead of using a partial set. | **Established** at N and G: [restart](../verification/selection-failures.md#restart) |
| Malformed/conflicting sealed catalogue; unsigned/ad-hoc host; differently team-signed host | N, G; V for alternate team | Purpose-built malformed catalogue runs no provider and reports `catalogue-invalid`. No host team admits no shipped provider with `host-team-unavailable`. Valid alternate-team host derives its own team; certificate-dependent V evidence stays pending until available. | **Established** at N and G except the alternate-team host, **pending** in `alternate-team-signing`: [catalogue and host team](../verification/selection-decisions.md#catalogue-and-host-team) |
| Diagnostic completeness, including a real provider named `unknown` and an unidentified bundle | N, G | Assert every candidate/synthetic row, enum, selection pointer and stable reason; real `unknown` differs from `(unknown)`. Later failure retains frozen identity and competing refusal details. | **Established**: the pre-load rows, [diagnostic completeness](../verification/selection-decisions.md#diagnostic-completeness); the later-failure part: [diagnostic completeness, the later-failure half](../verification/selection-failures.md#diagnostic-completeness-the-later-failure-half) |

Compatibility of a first-party schema is a publisher obligation, not something a
version comparison proves. Old generated desktop operations and native binary
pairs guard that promise; signing attests origin, not behavior. No formal model
is claimed here: the bounded startup decision table is reviewed design, while
actual loading/trust is tested at the native
and VM seams. Revisit a model if persistent rollback history or live replacement
introduces transitions this one-startup contract deliberately avoids.

## Client handoff

Koine's versioned GraphQL contract, reference/error semantics, endpoint descriptor
and grant protocol are authoritative. Runtime introspection supplies the full
schema for generated clients. Koine ships no client library: standard GraphQL
tooling plus a small client-owned
adapter covers endpoint discovery, credential storage, authorization headers and
error classification. The [client guide](../client-guide.md) is that adapter's
reading path: the contract version and how a client verifies it, and what each
part of this contract means for a client. A shared helper would be justified by
repeated real consumers, not by the existence of a transport. That claim is
exercised rather than asserted: a TypeScript client written from these documents
alone, with no access to Koine's source, runs the whole obtain-grant, discover,
list and focus path against the notarized build, and the places where these
documents left it guessing are its findings, each repaired in this document or
declined for version 1 with its reason, as that evidence document records.
Evidence: [contract-only-client.md](../verification/contract-only-client.md).

ModalAnyware, as a client of `koine-desktop/1`, must capture the process incarnation at interaction start, preserve opaque
references through configuration/effects, store its own credential, and map
capability denial separately from Koine OS-consent guidance. It must distinguish
a missing process from a stale selected window and an unknown mutation outcome.
Its public TypeScript facade can retain convenience operations, but they are
client adapters rather than a second Koine wire contract. Its plugin/framework
choices belong to that repository, and Koine does not edit it; ModalAnyware's
own design may change the exact adapter shape. It reads the
[client guide](../client-guide.md) as any client does.

## Test seams and acceptance

Acceptance rests on three seams. There is no fourth public testing interface,
and no mocks of desktop applications.

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
`docs/verification/`. Each VM run used either the Developer ID signed bundle or
the notarized 0.1.0 bundle on a Gatekeeper-enforcing clone; each document says
which.

| Obligation | Status and evidence |
|---|---|
| Introspection exposes core and provider types | **Established.** `SchemaConformanceTests`, `CompositionTests`; the notarized build's whole schema against the design file, [schema-conformance-vm.md](../verification/schema-conformance-vm.md). |
| Generated desktop operations validate and run with only the documented contract | **Established**, with the findings it recorded settled in [contract-only-client.md](../verification/contract-only-client.md). |
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
| Additional capability requirements: one ordered set for whole-mutation preflight, live dispatch admission and read publication; `requiredCapability` names the first unmet member and `extensions.requiredCapabilities` the whole set; a contribution whose capability owner is missing is removed to a fixed point; a descriptor using the set without the feature is refused | **Established** at the public seam over in-test contributions: `AdditionalCapabilityTests` (aliases, fragments, argument defaults, nested reference inputs, `@skip`/`@include`, multi-action preflight with zero action calls, revocation between actions, read republication, cycles, a refused owner, a removal that readmits nothing, a provider that fails startup after publication and is not removed), each watched to fail against a registration that ignores the set. Also in independently built binaries, [binary-compatibility.md](../verification/binary-compatibility.md): the released host refuses a provider requiring the feature before any of its code loads, a provider built against framework 1.0 and the released desktop provider run unchanged on the new host, and the new host refuses an undeclared use and enforces the set. Preflight reads each action's arguments as execution will, so a reference that
arrives by an operation variable's default, as a lone value for a list, or as an
input field's default names its owner before any action. The bundled workspace provider now declares the set (`desktop:control` on the launch root and every field it reaches), and its real descriptor is composed at the public seam and its real signed bundle is loaded by the selection-aware loader beside desktop: `WorkspaceCompositionTests`, `WorkspaceProviderTests`. **Open**: the pair across two framework minors under the signed, hardened application. |
| An old provider on an upgraded host and framework; an old host with an upgraded provider built for its baseline; framework identity, factory casts, ARC, async resolution, cancellation, observation startup | **Established** for independently built pairs on unsigned hosts, [binary-compatibility.md](../verification/binary-compatibility.md), with `NativeProviderTests` and `ProviderLifecycleTests`. The old side is built from the released 0.1.0 sources (`task compat:baseline`), so the pair is across two real framework minors, 1.0 and 1.1. The signed, hardened application loads independently built same-team providers, [signed-app-provider-vm.md](../verification/signed-app-provider-vm.md), and its bundled provider from a quarantined notarized bundle, [notarized-release-vm.md](../verification/notarized-release-vm.md). **Open**: a pair across two framework minors under the signed application. |
| Unsupported majors, minors and features, and bundled duplicate frameworks, refused before loading; schema and ownership collisions refused before activation | **Established.** `ProviderLoaderTests`, `CompositionTests`; [signed-app-provider-vm.md](../verification/signed-app-provider-vm.md). |
| Mismatched signing identities refused before code is loaded | **Established** for another Team ID in the approval record, an ad-hoc signature and none: `ProviderLoaderTests`, [signed-app-provider-vm.md](../verification/signed-app-provider-vm.md). **Open**: a bundle signed by a second real Developer ID team, which needs a second certificate, and what the kernel does with one behind Koine's check. |
| Signed installation and login launch without a client | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [resident-app-vm.md](../verification/resident-app-vm.md); a quarantined first launch, [notarized-release-vm.md](../verification/notarized-release-vm.md); installed, uninstalled and zapped through the published Homebrew cask, [homebrew-install-vm.md](../verification/homebrew-install-vm.md). **Open**: login-item approval waiting on the user (`requiresApproval`) has never been observed; registration went straight to enabled in every run. |
| Both native-UI grant workflows; first management bootstrap and revocation | **Established.** [grant-workflow-acceptance-vm.md](../verification/grant-workflow-acceptance-vm.md), [grant-enrollment-vm.md](../verification/grant-enrollment-vm.md). **Open**: that a user actually compares the comparison code; the run shows the window's code equals the client's. |
| Accessibility attributed to Koine | **Established** on the notarized build: [notarized-release-vm.md](../verification/notarized-release-vm.md), [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [accessibility-status-and-consent-vm.md](../verification/accessibility-status-and-consent-vm.md). |
| Absent and revoked consent | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [desktop-references-and-permission-vm.md](../verification/desktop-references-and-permission-vm.md). |
| Application resolution; current and remembered windows across Spaces; focus | **Established.** [desktop-application-and-windows-vm.md](../verification/desktop-application-and-windows-vm.md), [desktop-remembered-windows-vm.md](../verification/desktop-remembered-windows-vm.md), [desktop-focus-vm.md](../verification/desktop-focus-vm.md), the mechanism in [desktop-window-identity.md](../verification/desktop-window-identity.md). |
| Closure, duplicate titles and restart behavior | **Established for served behavior.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [desktop-focus-vm.md](../verification/desktop-focus-vm.md). Platform-reported withdrawal is permanent but may be mistaken ([accepted limits](#native-targeting-discussion)). |
| PID reuse | **Established** for rejecting a mismatched timestamp input in [release-acceptance-vm.md](../verification/release-acceptance-vm.md). An [actual PID-recycling diagnostic](../verification/retained-ax-binding.md) showed a held AX window acting on the replacement process. This is platform evidence, not a Koine acceptance pass. Wrong-target data and effects in that race are an [accepted limit](#native-targeting-discussion). |
| Closing management windows leaves service and observation running | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [desktop-remembered-windows-vm.md](../verification/desktop-remembered-windows-vm.md). |
| Warm latency reported in the real keyboard workflow | **Established** as a report: [latency-and-support-matrix.md](../verification/latency-and-support-matrix.md), measured on the Developer ID signed build at the macOS 26 floor, not on the notarized bundle. **Open**: that the notarized 0.1.0 bundle carries the image digests that document records. |
| The signed release build's entitlements and permission behavior | **Established.** [release-acceptance-vm.md](../verification/release-acceptance-vm.md), [notarized-release-vm.md](../verification/notarized-release-vm.md). |
| The native identity guarantee | **Established** only for the served design's within-process and ordinary-restart cases in [desktop-window-identity.md](../verification/desktop-window-identity.md). Held AX objects can retarget after actual PID reuse, as [the diagnostic](../verification/retained-ax-binding.md) and [current decision record](../adr/desktop-window-identity-is-a-held-element.md) explain. Across PID reuse this is an [accepted limit](#native-targeting-discussion), not an open obligation. |

**Open, and not a case above:**

- **Provider install and trust renewal.** There is no UI to install a provider,
  show its signer, approve it or renew trust, and no library-validation
  entitlement, so independently signed third-party providers do not load.
  Approval is a file the user places.
- **Only macOS 26.5 on arm64 has run.** The floor is declared at macOS 26; nothing
  ran on 26.0 to 26.4. Intel, earlier macOS releases, a provider built by a
  different compiler than its host, and older framework minors are out of scope,
  as [binary-compatibility.md](../verification/binary-compatibility.md)
  records.
- **Expiry and retention of grant requests** are shown with a test clock
  (`GrantRequestLifetimeTests`), not in a VM.

## Scope

The designed [workflow extension](workflow-providers.md) admits non-running
application discovery/launch, special native locations, named application and
modern System Settings catalogues, file/URL opening, Finder reveal and bounded
integration-prerequisite discovery and explicit setup. Raw filesystem search
belongs to clients; a special-location value is no filesystem proxy or consent.
V1 includes no general OS metadata-query API.
The existing desktop process lookup still resolves
only the captured running incarnation; it does not become a name/bundle lookup.
Other broad installation/configuration discovery remains out of scope, as do
a public arbitrary-shell-execution operation, LLM skills, remote networking,
cross-language plugin authoring, live plugin replacement, subscriptions,
automatic retry and rollback,
general cross-provider identity and atomic snapshots. A scoped, revalidated
iTerm/herdr host association is permitted under the workflow spec's constraints;
it supplies neither shared references nor a universal identity service.
The API exclusion is not a limit on what an authorized application can do:
input to a terminal can execute commands as the user, and menu authority can
invoke destructive application actions. Workspace can launch any registered
installed app; document handlers can execute scripts or follow location files
to other schemes and targets. Its metadata checks are not a content sandbox.
Grant disclosure must state that reach before each surface ships.
Open-source licensing and distribution do not
change this desktop design: Koine is published under Apache-2.0 and
installed from a Homebrew cask carrying the notarized bundle
([open-source release and distribution](../adr/open-source-release-and-distribution.md)).

The baseline served contract is implemented: a shared resilient Swift
framework, one resident application with in-process native management,
transferable bearer credentials with live revocation, the precise
revocation/admission boundary, GraphQL desktop identity, the client-owned adapter
and the operational policies described here. Platform behavior and native binary
compatibility are established by the evidence in "Acceptance status", which also
lists what is open.
The workflow extension and additional-capability feature are design obligations
until their own conformance, binary and VM evidence is recorded; the baseline's
established rows do not establish these additions.

## Native targeting discussion

**The served identity is the `koine-desktop/1` contract.** A client captures a
process as `{ pid, startedAt }` at interaction start. Koine resolves only when both
halves match the live process, and otherwise answers null, never another process.
The [capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md)
records why Koine uses it rather than an identity without the start instant. A collision needs the kernel to
reissue the same PID within the same microsecond of start time. A continuously held
native identity, transferred from the client's callback over an authenticated
channel, is not used, because its capture/transfer protocol, sample attribution and
native evidence cost far more than the residual collision risk.

### Public Accessibility and its accepted limits

The desktop provider uses only public macOS Accessibility for listing, held window
elements, focus and notifications
([public Accessibility decision](../adr/desktop-automation-uses-public-accessibility.md)).
It checks the process identity before AX work. That check narrows, but cannot
close, the race with process or window reuse:

| Area | Accepted limit |
|---|---|
| Data and effects | After actual PID reuse, a held AX element can address the replacement process, as the [PID-recycling diagnostic](../verification/retained-ax-binding.md) shows. A check-then-use race can return another target's data or act on it. |
| Reads and notifications | Replies and framework callbacks are not independently authenticated. A title, presence, focus report or notification may be stale or misattributed. |
| Reference withdrawal | A platform closure report may withdraw a live reference. Withdrawal is still permanent, and identifiers are never reused. |
| Framework AX reception | No Koine-enforced memory or Mach-right bound applies before framework-managed acquisition. Koine bounds its own records and work. |

Koine does not fall back to a private AX endpoint or to window-qualified
activation to narrow these limits.

## Native discovery conformance profiles

**Design only; actual native captures pending.** The additive native API keeps
koine-desktop/1 and the existing ProviderValue/failure ABI. The
[exact acceptance identities](../verification/native-discovery-acceptance.md#exact-identities-and-posture)
separate provider release/schema, complete SDL/digest, selection origin and
host signing posture; identical schemas do not establish identical binaries.

| Profile | Complete SDL and candidate pins | Evidence |
| --- | --- | --- |
| [Bundled native](../design/profiles/core-desktop-workspace-native-extension-host.json) | Extended core management + desktop 1.0.0/1.0.0 + workspace 1.2.0/1.1.0, both BUNDLED/SELECTED/ACTIVE; complete native SDL. | Pending N/G/V. |
| [Native update](../design/profiles/core-desktop-workspace-native-update-extension-host.json) | Same SDL; PER_USER workspace 1.3.0/1.1.0 selected, BUNDLED 1.2.0/1.1.0 REJECTED/NOT_SELECTED/superseded-candidate; desktop baseline remains active. | Pending N/G/V. |
| [Native update refused](../design/profiles/core-desktop-workspace-native-update-refused-extension-host.json) | Repair action SDL; 1.3.0/1.1.0 per-user update missing first-party-selection-v1 INCOMPATIBLE/NOT_SELECTED/selection-feature-required; bundled action-only 1.0.1 selected-with-refusals. | Pending N/G/V, no load/start marker. |
| [Prior disclosure host refuses native update](../design/profiles/core-desktop-workspace-native-disclosure-refused-extension-host.json) | Prior selection-aware host lacks workspace-native-disclosures-v1; native 1.3.0/1.1.0 PER_USER INCOMPATIBLE/NOT_SELECTED/unsupported-feature; retained BUNDLED action-only 1.0.1 ACTIVE/SELECTED/selected-with-refusals. Complete repair action SDL. | Pending N/G/V, no native load/start marker. |

Native 1.2.0/1.3.0 manifests require additional-capabilities-v1,
first-party-selection-v1 and workspace-native-disclosures-v1. The latter is
advertised only after the corrected disclosures above are served everywhere.
Conditional Automation signing posture does not establish that feature.

The complete native SDL also includes explicit nullable application agent/background
declarations and associated running-policy observations under workspace:read.
Application population overflow yields FAILED/null items; it does not publish an
arbitrary source-order sample. G10/N5/V11 accept the real populous catalogue and
call/copy/response accounting. Application admission uses 20 MiB scoped cumulative controlled raw gross and
4,194,304 explicit operations under the [accounting ADR](../adr/application-metadata-accounting-covers-explicit-work.md), without refund.
Settings/location owned-copy gates and the independent core response cap remain
8 MiB; nested aliases charge host completion/encoding, independent roots own jobs. This application
slice awaits complete-producer review. Long metadata has a fixed native indexed
projection, public metadataSource, UNKNOWN installation state and null unsupported
bundle flags; G11/N8/V13 require real L1500 source tuples, identity and unchanged
selected-action refusal. Indexed facts do not bind current inode/bundle contents.
The long indexed projection adds no access/consent/signing or core limit policy;
the separately approved ordinary metadata exception is described below. Settings now
uses two ID-associated pALL/anchor sweeps with a minimum 100 ms gap within three
seconds. RUNNING is process-only; stable positive choices remain PARTIAL with
UNKNOWN lazy completeness, empty panes UNKNOWN/null and empty anchors null.
G4/N4/N5/V12 qualify exact event construction, cost and independent cold/warm
usefulness; all exposed choices remain required. No current native conformance
pass follows. The complete design requires mandatory whole-producer review and
any earned reconciliation before becoming implementation input.

Diagnostic detail saturation does not invalidate a catalogue: 63 detail records
plus DIAGNOSTIC_LIMIT and fixed per-source reason summaries preserve all outcomes
without item loss. The old application arithmetic is historical counterexample evidence. Current
grouped local/source/two-walk conservative enclosures 23,238,610/23,412,717
exceed 20,971,520 before other terms; they prove no useful fit, inevitable native
overflow or impossibility of tighter construction. Full native operands/final
wire stay conditional, so the consumption hold remains. Settings remains 6,094,976 bytes under its unchanged 8 MiB gate. Settings confirmation timeout retains only
uncontradicted complete-first-map positives as PARTIAL/TIME_LIMIT/UNKNOWN;
incomplete-first-map timeout and count/call/copy overflow still give FAILED/null.
Lazy no-such-object at reveal re-resolution is failed/unestablished selection,
never an absence dependency; V12 includes separate unvisited-incarnation reveal.
The selected complete strings/loctable reader uses 131,072-byte regular files and
per-object affected-fact refusal; shared exhaustion remains FAILED/null. The
[complete scoped composition](../verification/application-metadata-composition.md)
supplies conditional expressions, without a useful finite fit. The k215 hold and
mandatory review/earned integration precede k7. Its pathname mechanism is: root resource type through 1,023 bytes, held-directory fixed metadata
files and a bounded direct localization plan. Larger roots use actual indexed
items. The 977 localized control and 978 old-band copy supplement L1500; review
and G11/N8/V13 remain pending. Every explicit operation and controlled raw write/cleanup requires admission;
runtime internals are excluded and real ProviderValue publication stays provider-owned.
No total heap/RSS/peak, host response increase or foreign Bundle fallback follows.
Ordinary 1,004…1,023 metadata does not qualify the action's whole-path plist reader.

Independently retained 1.0.0/1.0.1 and already-used action-only update 1.1.0/1.0.1
profiles/captures are unchanged subjects. New native multi-image guards/loading,
normalization, exact settings event/posture and serviceability checks require
actual new binaries, fresh hosts and declared supported OS subjects. Design
SDL/example validation proves no native call, useful choice or compatibility pass.

## Grouped refinement and retained hold

The [grouped inventory/key refinement](../verification/application-metadata-grouped-storage.md) replaces complete retained key
partitions with independent linked-slab owners, while preserving the selected
reader semantics, scoped gates, every saved association and the full wire. Its
controlled local/source/two-walk enclosure still exceeds 20 MiB before other
terms; it establishes no useful fit or native pass. Earlier independent-block
numbers remain reproducible comparison. The amended private design boundary is complete; whole-producer review and the
advertisement/consumption holds remain. The [selected qualification order](../adr/application-metadata-qualification-precedes-analytic-fit.md) selects ordering only.
Private construction requires the complete [eligibility conjunction](application-metadata-private-qualification.md#eligibility-and-existing-qualification-sequence);
that predicate, rather than an abbreviated ordering summary, governs builds. Advertisement/downstream consumption remain held until full useful
native operands, actual complete selected responses, required witnesses and
independent serviceability qualify. Failed/refused/unknown required useful cases
and unavailable subjects keep those holds and affected acceptance work live.
Existing whole-producer review, all native G/N/V, actual full operands/response,
useful breadth and independent authority/action/Settings/disclosure/compatibility
duties remain. No repeated strict/scoped selection or new capture leaf follows.
