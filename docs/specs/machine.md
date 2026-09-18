# Koine desktop contract

**Agreed desktop contract.** The human approved this complete design, including
the shared resilient Swift framework, one resident Koine application and bearer
credentials with live revocation. It is the baseline for implementation planning;
it does not claim that Koine is implemented or its platform behavior has been
verified.

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
decisions. The [visual overview](../design/architecture/index.html#discussion)
explains the agreed contract. The Machine core remains a Swift
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
relaunch. It requires macOS 13 or later. The actual supported OS/CPU release
matrix is a release acceptance item, not a claim that every macOS version has
been verified.

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

Apple documents [main-app login launch](https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp)
and [the current-process Accessibility trust check](https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions).
The attribution of the signed, packaged application is checked in real VMs
before this arrangement is treated as shipped behavior.

## Local transport and discovery

The listener binds only IPv4 `127.0.0.1`, requesting an available port from the
OS. After loading the schema and becoming ready, Koine atomically publishes a
version-1 endpoint descriptor at
`~/Library/Application Support/Koine/endpoint.json`. Its containing directory
is user-only (0700), and the descriptor is user-readable/writable only (0600).
It contains `descriptorVersion`, `instanceId`, `pid`, `port`, `path` equal to
`/graphql`, and `contractVersion` equal to `koine-desktop/1`. It contains no
credential. Clients construct the literal loopback URL; they do not follow an
arbitrary host or scheme from a file. Shutdown removes only its own descriptor.
A process lock prevents a second Koine instance from becoming a second writer.

A client reads the descriptor on connection and again after connection failure.
It may reconnect for a subsequent request; it never automatically replays a
mutation whose result was lost. An absent/stale descriptor is service
unavailability, not a cue to launch Koine. `instanceId` distinguishes server
runs; it is neither authentication nor a reference lifetime guarantee. The
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

Set `Cache-Control: no-store`. Unsupported media types/methods and malformed
HTTP are transport errors. GraphQL syntax, validation and variable-coercion
failures return HTTP 400 with `errors` and no `data`. Invalid or revoked bearer
credentials return HTTP 401 before execution. An authenticated mutation rejected
by capability preflight returns HTTP 403 with `errors` and no `data`. Each denied
root action has its response alias in `path` and carries `extensions.kind:
permission`, `permissionClass: capability`, and `phase: authorization`.
Executed operations return HTTP 200 with
GraphQL `data` and any execution errors, including non-null propagation to
`data: null`. The body, not HTTP success alone, determines the operation result.
This is the selected subset of [GraphQL over HTTP](https://http-spec.graphql.org/draft/).

Bound parsing and execution: initially 1 MiB request bodies, depth 16, 1,000
expanded field selections, and 10 root mutation actions per request. Expand
fragments with cycle detection before counting. Reject over-limit requests
before provider callbacks; cap response materialization at 8 MiB and execution
at 5 seconds. A timeout after an action begins does not prove that it failed.
Provider-native work must use bounded OS calls and cooperative cancellation.
These limits are versioned policy, not a promise to interrupt arbitrary native
code or to undo actions.

## Public GraphQL contract

`koine-desktop/1` names the first public contract, separately from plugin ABI
versions. The [schema](../design/desktop-schema.graphql) states exact
types and nullability; the [client operations](../design/desktop-operations.graphql)
show the handoff's requests. These are design artifacts, not an implemented
server. The complete executable schema includes core management types and
all active provider contributions. Every active authenticated grant, including
one with no provider capabilities, can introspect that whole schema; discovery
is not execution authority. Schema descriptions include resource-reference
opacity, field capabilities and permission classifications. Standard GraphQL
code generation consumes introspection; no private schema channel is required.
Schema admission must preserve full standard introspection within the server's
request/response limits. If adding a provider would exceed those limits,
reject the contribution with a management diagnostic instead of exposing a
schema that authenticated code-generation clients cannot fully inspect.

The following signatures define the desktop surface. `Reference` is a
custom scalar serialized as a URI string; `ID` names management records only.
`DesktopProcessIdentity` contains a positive `pid: Int!` and
`startedAt: DesktopProcessStart!`, the
process start instant in canonical UTC with six fractional second digits. A
client captures both at interaction start. The provider compares both before
resolving; a recycled PID must not select a new application. A missing reliable
start instant is an input error, not permission to silently target by PID alone.

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

All provider-owned read fields, including references and nested properties,
require `desktop:read`. The receipt is a distinct output type authorized by
`desktop:control`; it does not expose a window's read fields. Read and control
are separate capabilities; neither implies the other. ModalAnyware normally
requests both. Root lookups and the mutation result are naturally nullable:
absence and failure remain distinguishable by the presence of an error.
Domain fields and window list elements retain meaningful non-null types.

The client first resolves the captured process and selects `ref`, `name`, and
`windows { ref title observation }`. It derives and presents choices locally.
When the user chooses, it submits the returned window reference unchanged to
`desktopFocusWindow`. A new reconstruction makes a new query. Introspection
and the provider's read capability do not create a subscription or cache.

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

Version 1 permits adding owned root fields and owned types, not extending
another provider's types or replacing core fields. References may cross through
the shared `Reference` scalar; using one never grants access. Provider-private
custom scalars/enums must be introspectable. Any later shared object interface
or cross-provider field extension requires an explicit composition contract.
This bounds the current composition problem without hiding provider schemas.

Only root Mutation fields may perform domain actions. Query and nested-output
resolvers must be side-effect-free apart from private OS observation. A nested
`desktop { focusWindow }` mutation namespace is invalid for this contract:
it would move actions outside GraphQL's serial root-mutation semantics.

Store authorization by original schema coordinate and resource-owner authority,
not response alias. Expand fragments, merge fields by GraphQL rules and evaluate
`@skip` / `@include` with coerced variables. Check each read field before calling
its resolver, including scalar defaults and alternate reference lookups. A
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
Capability errors identify the required capability without revealing protected
resource existence. OS errors identify `accessibility` and Koine as the
permission owner. An unavailable error may echo a reference the caller supplied,
not disclose an otherwise unauthorized resource. Never expose tokens or native
stack traces. Every propagated error retains the original failure path.

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

A read denial produces an execution error, not an empty list or ordinary null.
Apply standard non-null propagation: a denied non-null field can discard its
nearest nullable parent, and can make all `data` null. Other branches survive
where their types permit. Successful mutation preflight guarantees authorization
before actions, not a transaction. These rules use the
[GraphQL execution model](https://spec.graphql.org/September2025/#sec-Execution).

## Grants and management

Use opaque bearer credentials. One credential identifies one persistent
grant containing a set of capabilities, such as `desktop:read`,
`desktop:control`, and the separate core capability `koine:manage`. A client
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
non-secret comparison code. Request capabilities must be known and are fixed
once submitted. A pending request conveys no provider or management authority.

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

Core management types use the `Koine` prefix. Management errors use the same
permission vocabulary and propagation as provider errors. Record missing,
already-decided and invalid-subset request outcomes explicitly; approval cannot
resurrect a denied, expired or revoked request. Native UI affordances cover
request review, manual creation, grant listing/revocation, service status and
OS-permission guidance. Plugin installation/trust is a local user operation,
not an extra meaning of a client's `desktop:control` grant.

## Resource references and desktop behavior

The `Reference` scalar accepts canonical `koine://<provider>/<remainder>` URI
strings, with no userinfo, port or fragment. The engine validates the envelope
and routes by authority only. Providers own percent encoding, resource kind
and remainder interpretation. A provider root has an empty remainder. The
scalar maps to an opaque string wrapper in client bindings; clients cannot
construct desktop resource references from PIDs or window titles.

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
success. Exactly which public/native identity APIs support this guarantee is
an implementation acceptance obligation; Modaliser's private window-number
lookup and title fallback cannot be copied as proof of identity.

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
configurations. Give the major-1 framework one stable module and install name;
the application supplies its trusted run path. Plugin bundles contain a Swift
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
baseline and declares no newer requirement. Test that direction with the old
host; building with a newer compiler alone does not prove it. A plugin using
newer framework declarations declares the corresponding minimum minor and
cannot run on earlier frameworks. Future incompatible framework majors need a
new module/install identity and an explicit host support policy; they are not
promised by major 1. CPU, OS and Swift-runtime prerequisites still apply.

Swift documents the distinction between
[module stability and library evolution](https://www.swift.org/blog/library-evolution/).
Apple documents [class-name lookup](https://developer.apple.com/documentation/foundation/nsclassfromstring(_:))
and [run-path dependent libraries](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/RunpathDependentLibraries.html).
The specific loader and independently built version pairs above remain to be
verified through the agreed native binary test seam.

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
verification after loading is too late. Never strip quarantine or disable OS
code-signing checks to make a rejected plugin load.

Record approved provider ID plus signing identity; an update must satisfy the
same approved identity and version policy, or need explicit renewed trust.
Validate private dependencies too, and stage an immutable versioned bundle
before verification/loading to prevent an accidental update race. A malicious
same-user actor able to rewrite Koine or its approved code is outside this
in-process trust model. Bad descriptors/schema are diagnosed without publishing
partial contributions; a plugin that has already run initializers stays mapped
until process exit even if activation fails.

For independently signed third-party providers, the host needs the narrowly
scoped disable-library-validation entitlement; Koine then performs its own
approval and signature validation. Apple documents this
[third-party plugin requirement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.cs.disable-library-validation).
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
adapter covers endpoint discovery, Keychain storage, authorization headers and
error classification. A future shared helper is justified by repeated real
consumers, not by the existence of a transport.

ModalAnyware must revise its inherited Machine spec, architecture/provider
ownership statements and resident-bridge handoff to target `koine-desktop/1`.
It must capture the process incarnation at interaction start, preserve opaque
references through configuration/effects, store its own credential, and map
capability denial separately from Koine OS-consent guidance. It must distinguish
a missing process from a stale selected window and an unknown mutation outcome.
Its public TypeScript facade can retain convenience operations, but they are
client adapters rather than a second Koine wire contract. Its plugin/framework
choices belong to that repository. This session does not rewrite sibling
contracts; their concurrent design may change the exact adapter shape.

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
separate availability case. Verify the signed release build's entitlement and
permission behavior rather than extrapolating from an unsigned development run.

The native identity guarantee and signed binary compatibility must be proven by
these seams before release; neither is established by diagrams or the current
source inspection. Authorization invariants have explicit admission points and
can be exercised with controlled ordering at the public boundary. A formal model
is not an additional deliverable for this first design; do not describe this
protocol as model-checked.

## Scope and agreement

Deferred: non-running applications, broad installation/configuration discovery,
LLM skills, remote networking, cross-language plugin authoring, live plugin
replacement, subscriptions, automatic retry and rollback, and cross-provider
identity or atomic snapshots. Open-source licensing and distribution business
policy remain undecided and do not gate this desktop design.

The whole contract is agreed: a shared resilient Swift framework, one resident
application with in-process native management, transferable bearer credentials
with live revocation, the precise revocation/admission boundary, GraphQL
desktop/process identity, the client-owned adapter and the operational policies
described here. Implementation planning follows this baseline. Platform behavior
and native binary compatibility remain release acceptance obligations.
