# Koine

A koine is the common language that forms where many dialects meet. Koine is
the Machine server: a standalone application for discovering, querying and
commanding the desktop and applications through a fully introspectable
GraphQL API. Local clients connect over loopback HTTP using capabilities
granted by Koine.

[ModalAnyware](../ModalAnyware) is the first client. The first deliverable
lets it resolve a running application, list its windows and focus one.
One resident Koine application holds the OS permissions and contains the server,
providers and native macOS management UI. It also exposes management through
GraphQL. Clients present bearer credentials backed by live grants, which last
until explicitly revoked.

Providers are native Swift extensions that contribute to the GraphQL schema.
A shared resilient Swift framework lets compatible providers and the server
be upgraded independently. Its published Swift contract is the stable binary
interface; a TypeScript hosting layer is not required.

Broader discovery, including applications that are not running, and an LLM
skill set are deferred until after ModalAnyware is unblocked.

The first increment is built: an embeddable server that binds loopback,
publishes its endpoint descriptor, authenticates bearer credentials against a
durable grant store and answers `Query.koine`, `Mutation.koineCreateGrant` and
full introspection. The second increment is built too: a signed resident
`Koine.app` embeds that server and creates grants from its window, and a
`koine:manage` grant lists grants with `Query.koineManagement { grants }` and
revokes one with `Mutation.koineRevokeGrant`. Revocation is a durable commit
made inside the same serialized authority boundary that admits every action, so
a revoked credential gets 401 on its next request, keep-alive or not. The
window also lists and revokes grants and enables login launch, and the
installed workflow is verified in a clean VM. Native providers load through one
loader, and the desktop path has begun: the bundled desktop provider resolves a
running application from its process identity, lists its windows, those it has
seen on other Spaces included, looks an application or window reference up again
and focuses exactly the window chosen ("Desktop provider" below). A client can
also enrol itself ("Client-requested grants" below). The agreed design:

- [Desktop contract](docs/specs/machine.md): GraphQL, native providers,
  grants, service availability and the ModalAnyware handoff
- [GraphQL schema](docs/design/desktop-schema.graphql) and
  [client operations](docs/design/desktop-operations.graphql)
- Decisions: [references as URIs](docs/adr/machine-references-as-uris.md),
  [the server and native providers](docs/adr/koine-server-and-native-providers.md),
  [the resilient provider framework](docs/adr/resilient-provider-framework.md),
  [bearer grants and live revocation](docs/adr/bearer-grants-and-live-revocation.md)
- Shared terms: [CONTEXT.md](CONTEXT.md)
- Diagrams: [docs/design/architecture](docs/design/architecture/README.md)

The [visual overview](http://127.0.0.1:8772/#discussion) explains the agreed
contract and its implementation acceptance boundaries.
That local URL requires the diagram server described in the views' README.

## Client-requested grants

A client with no credential enrols itself over the public API, and the user
decides in Koine's window ("Request review" under "Resident application"
below), or a `koine:manage` client decides over GraphQL. This is how the first
management client comes to exist without a credential being typed, pasted or
shown.

1. The client generates its own 32-byte secret, keeps it, and sends
   `Mutation.koineRequestGrant` with the secret's digest (64 lower-case hex), a
   label and the capabilities it wants, each one `availableCapabilities` lists.
   It sends no `Authorization` header. Without one, Koine admits exactly this:
   an operation whose only selected root action is `koineRequestGrant`. A second
   action, an alias repeating it, `__typename` beside it or any query is HTTP
   401, as every other request without a credential still is, and nothing is
   stored; so is an enrollment that fails validation, whose messages would name
   the schema. A `@skip` or `@include` condition that is not a JSON boolean
   counts as included, here and in mutation preflight. A header that names no live credential is 401 too; it is never
   retried as anonymous. The receipt is a request ID and a comparison code: eight
   random characters as `XXXX-XXXX`, independent of the digest, for the user to
   compare by eye with what the client shows.

   A client whose response was lost sends the same request again. The same
   digest with the same label and the same capability set, order and duplicates
   ignored, returns the original request ID and code and stores nothing,
   whatever has been decided since. The same digest with a different label or
   set is refused as `failed` with `extensions.reason` `enrollment-conflict`. A
   digest names one thing for ever: one that belongs to a grant, active or
   revoked, is refused with `credential-in-use`, and after a denial the client
   needs a fresh secret to ask again.
2. The client polls `Query.koineGrantRequest` with its secret as the bearer.
   While the request is pending, and after it is denied, that secret is a
   status-only principal: it reads
   its own request and nothing else. `koine`, `koineManagement`, provider fields
   `__schema`, `__type` and every mutation refuse it with the ordinary
   `permission` error, alone or beside `koineGrantRequest`, so it cannot approve itself or see another
   request.
3. A manager reads `koineManagement.requests` and calls
   `Mutation.koineApproveGrantRequest(requestId:capabilities:)` with a subset of
   what was requested. Approval goes through the same serialized authority
   boundary as revocation, and one durable commit marks the request `APPROVED`
   and inserts the grant bound to the submitted digest. An empty subset is
   valid, as it is for `koineCreateGrant`: the grant authenticates and holds
   nothing. `Mutation.koineDenyGrantRequest(requestId:)` commits `DENIED` the
   same way and returns the request. Neither changes anything when it refuses:
   a request ID that names nothing is `unavailable`; a request already decided
   is `failed` with `extensions.reason` `already-decided` and its state in
   `extensions.requestState`; a capability that was not requested is `failed`
   with `invalid-subset`. A decided request is never decided again, so a denied
   request, or one whose grant was revoked, is not resurrected. A commit that
   fails is `failed`, and the request is still pending.
4. The unchanged secret now authenticates as that grant. `koineGrantRequest`
   shows `APPROVED` with the grant's metadata, and is null under a grant no
   request produced. After a denial it shows `DENIED` with a null grant. Once
   the grant is revoked the secret is HTTP 401 for everything, this query
   included. No response carries a secret or a digest. Requests, decisions and
   the grants they produce survive a restart.

Enrollment is bounded in time and volume. The values are `RequestPolicy`'s,
beside the transport limits:

| Value | Default | What it bounds |
|---|---|---|
| `pendingRequestLifetime` | 24 hours | A request still pending is `EXPIRED`, to the requester, to `requests` and to a decision (`already-decided`). An approved grant never expires. |
| `requestStatusRetention` | 7 days | From the decision or the expiry. After it the request leaves `requests`, a decision on it is `unavailable`, and `koineGrantRequest` raises `unavailable`, under the secret and under the grant it produced alike. |
| `maximumPendingRequests` | 16 | A new request beyond it is `failed` with `pending-request-limit` and stores nothing. An identical retry is still answered; a decision or expiry frees a slot. |
| `maximumEnrollmentsPerWindow` in `enrollmentWindow` | 10 in 60 seconds | Anonymous enrollment operations, retries included. Over it: HTTP 429 with `Retry-After`. |

The spec fixes the two periods. The cap and the rate are Koine's choice for a
single-user loopback service: a legitimate client enrols once and retries a lost
response a few times, so a user installing several clients together stays well
inside both, while a misbehaving local process can put at most 16 entries in
front of the user and cannot make the store or the per-request credential scan
grow faster than 10 rows a minute. Every local process shares `127.0.0.1`, so
the rate is one budget for the server, not one per peer. It is spent only by
operations admitted as anonymous enrollment, so a client with a grant, a
status-only poll and the management window are served while it is exhausted;
it is held in memory and a restart refills it.

Expiry is not written: `EXPIRED` is what a stored pending request is once
`submitted_at` plus the lifetime has passed, so no read or decision can see an
over-age request as pending, with or without a restart in between. Retention
never deletes the row either. The status stops being served, and the row stays
as the digest's tombstone, in the user-only store file: a denied or expired
secret can never start a request or become a manual grant, and it polls
`unavailable`, not 401. `KoineServer(dataDirectory:policy:…now:)` takes the
time source; it defaults to the wall clock, the application does not set it,
and nothing a client sends or the environment holds reaches it.

## Building and testing

Requires Swift 6.2 or later on macOS 26 or later, Apple Silicon (developed
with Swift 6.4). That floor is the supported matrix, not a lower bound Koine was
never run at: docs/verification/latency-and-support-matrix.md.

```sh
task           # build, then test (needs https://taskfile.dev)
task build     # swift build, then stage KoineProviderAPI.framework
task test      # build, stage, build the fixture provider, its variants and the desktop provider, then the suites over real loopback HTTP
task fixture   # stage the framework, build the fixture provider outside the package, sign and approve it
task fixture:variants  # build, sign and approve the bundles the native loader must refuse, and the few good ones
task desktop-provider  # build the desktop provider by its own build definition, sign and approve it for the loader tests
task compat    # build and run the binary compatibility pairs; compat:build and compat:verify are its halves
task conformance  # the schema the notarized bundle serves, in a VM, against docs/design/desktop-schema.graphql
task app       # assemble and sign .build/app/Koine.app
task app:verify  # codesign --verify --strict, hardened runtime, designated requirement
task app:vm-verify  # the installed workflow in a clean TestAnyware macOS VM
task app:vm-verify-providers  # the signed, hardened bundle loads an approved fixture provider and refuses the others, in a VM
task app:vm-verify-desktop  # the bundled desktop provider resolves a real application, lists its windows, re-resolves references and reports absent or revoked consent, in a VM
task app:vm-verify-desktop-remembered  # a window left on another Space is REMEMBERED, revalidated on selection, and dropped when it or its application ends, in a VM
task app:vm-verify-accessibility  # the window's Accessibility guidance and consent request, provider and service status, and koineManagement.osPermissions following consent given and removed, in a VM
task app:vm-verify-desktop-focus  # desktopFocusWindow focuses exactly the chosen window of real applications, or reports why not and moves nothing, in a VM
task app:vm-verify-enrollment  # a guest client enrols itself, the window shows and decides its request, and the first manager it makes approves another over GraphQL, in a VM
```

Use `task test`, not a bare `swift test`: every host image links the provider
framework by its framework install name, which resolves only once the framework
is staged ("Provider framework" below), `NativeProviderTests` needs the fixture
bundle, `ProviderLoaderTests` needs its variants and `DesktopProviderTests` needs
the desktop provider's bundle. The fixtures are signed
with the identity `task app` uses (`KOINE_SIGNING_IDENTITY` overrides it), since
the loader admits only signed, approved bundles; there is no ad-hoc fallback.

The tests embed the server over a temporary data directory; they never touch
`~/Library/Application Support/Koine`.

### Schema conformance

`task conformance` is the whole-contract check: it launches the **notarized**
bundle in a clean TestAnyware clone, captures the introspection response a
standard code generator would ask for, and compares the schema that describes
with [`docs/design/desktop-schema.graphql`](docs/design/desktop-schema.graphql)
by type, field, argument, nullability, default, deprecation and description. The
comparison itself is host-side (`Tools/Conformance`), so nothing is launched
here. Evidence:
[`docs/verification/schema-conformance-vm.md`](docs/verification/schema-conformance-vm.md).

A green run is two claims, and neither alone would do:

- the canonically printed design file has the **digest Koine served**. The
  canonical text and the digest come from one implementation,
  `KoineCore/CanonicalSDL.swift`, which is also what `Koine.schemaDigest` is
  computed with, so this covers declared order and needs nothing from
  introspection.
- the **difference report** against the introspected schema is empty, which says
  the same thing from the public seam and says *where* when it is not.

Before believing either, the run mutates four copies of the contract — a
description, a nullability marker, an argument default, two transposed root
fields — and requires the check to go red on each, naming which half caught it.
The transposed pair is caught by the digest alone: declared order is exactly
what the introspected text cannot carry (see the spec's "Public GraphQL
contract" for the three limits of that seam).

`DesignContractConformanceTests` makes the same comparison in process, against a
composition that contributes `Providers/DesktopProvider/schema.graphql` as the
bundled provider does, so drift fails `task test` in seconds rather than a VM
run later. It is the fast guard, not the authority: it cannot see a shipped
bundle whose SDL differs from the file in the tree.

Revocation ordering and store failure are tested on an `Engine` over a scripted
`GrantStore` (`RevocationOrderingTests`). The engine calls an internal hook at
the points between its authority checks; a test runs the real revocation there,
so each order is forced rather than raced. The hook is reached with
`@testable` and is not part of any public interface.

## Package layout

| Target | Role |
|---|---|
| `KoineCore` | The Machine core: principals, credentials, the `GrantStore` contract and GraphQL execution with per-field authorization, bounded by the versioned `RequestPolicy` limits. No macOS, client or provider dependency; the GraphQL library is private to it. |
| `KoineSQLiteStore` | The durable `GrantStore`: one SQLite file, fully synchronised commits, fails closed. |
| `KoineHTTP` | An HTTP/1.1 listener bound to `127.0.0.1` on an OS-assigned port. Knows nothing of GraphQL. |
| `KoineServer` | The embeddable composition: data directory, single-instance lock, descriptor lifecycle, the HTTP transport rules, bearer authentication, and the in-process `LocalConsole`. |
| `KoineProviderLoader` | The native loader: finds `*.koineprovider` bundles in the roots the host supplies, stages each, verifies its approval record and signature (the only place the Security framework appears), `dlopen`s it, finds the manifest's principal class with `NSClassFromString` and requires `ProviderFactory`. The only place `dlopen` and Objective-C class lookup appear. |
| `KoineProviderAPI` (package `ProviderAPI/`) | The provider binary interface: `ProviderFactory`, `ProviderDescriptor`, `Provider`, `ResolutionRequest`, `ResolutionResult`, `ProviderValue`, `ProviderFailure`. One dynamic image built with library evolution; no third-party type in its interface. |
| `KoineManagementClient` | What the native UI knows of the server: the management operations as GraphQL through the `LocalConsole`, with GraphQL errors surfaced as `ManagementError`. Foundation only, so it is tested against an embedded server. |
| `KoineApp` | The resident application's executable: AppKit lifecycle, SwiftUI views. The only target that imports platform UI frameworks. |
| `KoineConformanceCheck` | The conformance check's two halves: an introspection response turned back into SDL, and a difference report between two canonical texts. Used by the `KoineConformance` tool (`Tools/Conformance`, `task conformance`) and by the tests. Not shipped in the bundle. |

An application embeds it as the tests do: `KoineServer(dataDirectory:)`, then
`start()`. `server.console` is the local-console principal; it has no wire form.

## Provider framework

`KoineProviderAPI` is the one image the host and every native provider link
(`docs/adr/resilient-provider-framework.md`). Its module name is
`KoineProviderAPI` and its install name is
`@rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI`; both are part
of the major-1 compatibility promise and do not change.

**Build tooling: `swift build` with explicit flags**, not `xcodebuild` on the
package scheme. `ProviderAPI/Package.swift` passes `-enable-library-evolution`
and `-emit-module-interface` to the compiler and the install name to the linker,
in debug and release alike. `xcodebuild BUILD_LIBRARY_FOR_DISTRIBUTION=YES`
would apply library evolution to every dependency in the graph and move the
application build off `Package.swift`; the explicit flags touch the one module
that carries the promise. Three things follow from SwiftPM's rules:

- The framework is a local sub-package, not a target of the root package. A
  target is linked statically into each host image; only a `.dynamic` library
  *product* of another package is one shared image. SwiftPM accepts
  `unsafeFlags` in a local path dependency.
- SwiftPM emits a bare `libKoineProviderAPI.dylib`. `scripts/stage-provider-framework.sh`
  assembles the real `KoineProviderAPI.framework` (image, textual
  `.swiftinterface`, `Info.plist`) into the build's `PackageFrameworks`
  directory, which is already on the run path of everything SwiftPM links.
  That staged framework is both what host images load in development and the
  `-F` directory providers are built against.
- The script refuses to stage unless the emitted interface records
  `-enable-library-evolution`, the image has the install name above, and the
  image exports no direct field offsets. Verified with Swift 6.4: a control
  module built without library evolution exports `field offset for` symbols,
  and the same module built with it exports none, only accessors and dispatch
  thunks.

**Provider bundles** are directories named `<Name>.koineprovider` holding a
Swift dylib, `manifest.json`, `schema.graphql` and an `Info.plist` whose
`CFBundleExecutable` names the dylib. That makes the directory a shallow
code-signing bundle, so `codesign` seals all of it with one signature.
`KoineServer(dataDirectory:policy:providerRoots:providerStaging:)` considers
every bundle directly inside each given `ProviderRoot` at construction and composes the SDL and field
registrations of those it loads into the schema; nothing else is searched. A
provider's fields require `<providerId>:read` or `<providerId>:control`, which
also appear in `koine.availableCapabilities`.

Every manifest field is required (`Fixtures/FixtureProvider/manifest.json` is an
example): `providerId`, `graphQLPrefix`, `version`, `schemaVersion`,
`architectures`, `minimumOS`, `minimumSwiftRuntime`, `framework` (`major`,
`minimumMinor`), `requiredFeatures`, `principalClass` and `library`. The host
states what it supplies: framework 1.0 (`HostCompatibility`, held equal to
`ProviderAPI/Info.plist` by a test) and its feature set (`koineHostFeatures`,
empty in version 1).

**The native loader** (`KoineProviderLoader`) refuses a bundle before any of its
code runs wherever it can, since dylib initializers run inside `dlopen`. Trust
comes first: the bundle's canonical location must lie inside its root; the
bundle is copied to a read-only directory named by its content under
`ProviderStaging` in the data directory, and everything after is checked of,
and loaded from, that copy (`ProviderStaging.swift`); the manifest's provider
must have an approval record; and the copy must carry a valid signature by the
approved Team ID (`ProviderTrust.swift`, the Security framework's static
validation, strict, with the requirement `anchor apple generic and certificate
leaf[subject.OU] = "<team>"`). Koine never strips quarantine or relaxes a
signing check. The loader then reads the binary's bytes itself
(`MachOImage.swift`) and checks, in order: the declared framework major, minimum minor and features, the CPU
architecture, the minimum OS and the Swift runtime that OS supplies; that the
library lies inside the bundle and holds exactly the declared architectures and
a minimum OS no newer than declared; that the bundle contains no copy of the
framework and its image defines none of the framework's own symbols; that every
dependency and run path is the framework's install name, under `/usr/lib/` or
`/System/Library/`, or a recursively validated `@loader_path` file inside the
bundle, each such image signed by the approved identity itself; and that no
other image has registered the principal class name. After
`dlopen` the principal class must originate in that image, conform to
`ProviderFactory`, and produce a descriptor that agrees with the manifest.

An honest bundle this host cannot run is `INCOMPATIBLE`; an unapproved,
unsigned, ad-hoc or differently signed one, one changed after sealing, a
malformed or contradictory one, a `dlopen` failure or a failure after loading is `REJECTED`
(after loading, the image stays mapped and contributes nothing). Neither fails
server construction. `koineManagement.providers`, under `koine:manage`, serves
one status for every bundle found: these, composition's refusals, `FAILED` for a
provider whose start threw, and `ACTIVE`.

**Installing or upgrading a first-party provider.** There is no install UI in
this version. The per-user root is
`~/Library/Application Support/Koine/Providers`; create it if it is absent.

1. Sign the bundle with Koine's identity, inside-out: any private dylib first,
   then `codesign --force --sign "Developer ID Application: …" <Name>.koineprovider`.
2. Copy `<Name>.koineprovider` into the root.
3. Approve it once, by placing `<providerId>.approval.json` beside it:
   `{ "providerId": "<providerId>", "teamIdentifier": "TA43A4RUP3" }`. Koine
   never writes this file, and has no GraphQL operation for it.
4. Restart Koine. `koineManagement.providers` reports the provider `ACTIVE`, or
   `REJECTED`/`INCOMPATIBLE` with the reason.

To upgrade, replace the bundle and restart; the record stands as long as the
new bundle is signed by the same Team ID, and a bundle signed by anyone else is
refused until the user replaces the record. Only providers signed by Koine's own
Team ID can load: the application has no library-validation exception, so an
independently signed third-party provider is not loadable in this version.
Superseded staged copies under `ProviderStaging` are not pruned; with Koine
stopped the directory can be deleted (its contents are read-only, so
`chmod -R u+w` first).

`Koine.app` passes two roots: `Contents/PlugIns` inside the bundle, whose
approvals are built in (the shipped provider IDs with the Team ID of the
application's own signature) and which holds the desktop provider, and the
per-user root. A provider's origin is its root's: the `desktop` identifier and
prefix are reserved to the in-application root.

**Lifecycle** (`KoineCore/ProviderLifecycle.swift`): providers start after
composition; every resolve goes through the provider's lifecycle, which
serializes start and stop, lets resolves overlap, and on stop admits nothing
new, cancels outstanding resolves and waits for them. A provider that is not
running answers `unavailable`; its schema stays published, so `schemaDigest`
does not depend on a start outcome. `KoineServer.stop()` stops providers before
the listener, which waits for requests in flight.

**Composition** (`KoineCore/Composition.swift`) publishes a loaded provider's
contribution whole or refuses it whole, by the rules in the contract's
"Composition and operation placement". A refused provider is never started, the
rest of the schema is served intact, and the refusal is a `ProviderDiagnostic`,
served as that provider's `REJECTED` status.
Providers are composed in a canonical order, so `schemaDigest` does not depend
on load order. The shared `Reference` scalar (`KoineCore/Reference.swift`)
validates the `koine://<provider>/<remainder>` envelope at input coercion; the
engine reads only the provider.

`Fixtures/FixtureProvider/` is test material: a provider built by its own
`build.sh` with `swiftc` against the staged framework's `.swiftinterface` and
image only. It shares no sources with the package, embeds no copy of the
framework, and is not shipped. A test cannot reach into its image, so it serves
what a test needs as fields of its own: `fixtureCalls` counts resolver calls,
`fixtureCloseGate`/`fixtureOpenGate` hold and release a named resolver's calls,
and `fixtureProbe` ends as each failure kind. `ProviderAuthorizationTests` uses
them for the contract's "Public GraphQL authorization" cases.

`Fixtures/FixtureProvider/build-variants.sh` builds one provider root per loader
case under `FixtureVariants/`, since each refusal needs a real binary or
manifest: the plain bundle under an altered manifest, signature or approval
record for what is refused before `dlopen`, and the fixture recompiled under a tag (its own class names and
provider identifier) for what loads. The fixture's `initializer.c` appends its
image path to the file `KOINE_FIXTURE_INITIALIZER_LOG` names; that is how
`ProviderLoaderTests` shows a refused bundle ran no code, with a loaded variant
as the control. `seal.sh` signs a fixture and writes its approval record, as the
steps above do by hand. An ad-hoc signed variant stands for a different
identity, so no second certificate is needed. The tests construct servers off
the Swift concurrency pool and share one staging directory, so dyld maps each
fixture once per process.

### Binary compatibility pairs

`task compat` is the repeatable recipe behind
`docs/verification/binary-compatibility.md`. `scripts/build-compat-pairs.sh`
copies the sources into two trees under `.build/compat/<configuration>/`, each
with its own build directory: `baseline`, as the sources are, and `newer`, the
same sources with an evidence-only framework minor 1 applied
(`Fixtures/CompatibilityPairs/Minor1.swift`, a defaulted `Provider` requirement,
and a host that supplies 1.1). That minor is never part of the shipped
framework. Each tree builds its framework, its fixture and variants, and
`KoineCompatibilityHost` (`Fixtures/CompatibilityHost`), a headless host that
serves one data directory's per-user provider root until its standard input
ends. It is test material: `scripts/build-app.sh` does not ship it and it adds
no API. `later/` holds later revisions of the fixture, each compiled against a
named revision's framework. `CONFIGURATION=release task compat` does the same in
release.

`scripts/verify-compat-pairs.py` makes each pair at run time, by installing one
tree's bundle and approval record under the other tree's host, one host process
per case, and drives it over loopback HTTP with a grant. It digests every binary
before and after, and writes `results.json` beside the trees.

A provider for an older Koine is compiled against that Koine's framework minor,
not only written without newer declarations: a conformance compiled against a
newer minor records the defaults of the requirements that minor added, and an
older host's dynamic loader refuses it.

## Desktop provider

`Providers/DesktopProvider` is the first real provider. It is no target of this
package: `build.sh` compiles it against the staged `KoineProviderAPI.framework`
alone, exactly as the fixture is built, and `task app` seals it in
`Contents/PlugIns`, where the one native loader admits it under the
application's built-in approval. Its pure files (`Logic/`) are also named by the
package target `DesktopProviderLogic`, only so that `swift test` reaches them.
It registers `desktop:read` and `desktop:control`, and serves what is
implemented so far:

```graphql
desktopApplication(process: { pid: 412, startedAt: "2026-09-19T01:02:03.000456Z" }) {
  ref name bundleIdentifier
  windows { ref title observation }
}
desktopApplicationByReference(ref: "koine://desktop/application/…") { … }  # the same fields
desktopWindow(ref: "koine://desktop/window/…") { ref title observation }

mutation { desktopFocusWindow(ref: "koine://desktop/window/…") { ref } }   # desktop:control
```

**Process identity.** Both halves are compared. `startedAt` is the kernel's
start instant for the process, which the provider reads with
`proc_pidinfo(PROC_PIDTBSDINFO)` as `pbi_start_tvsec` and `pbi_start_tvusec`:
whole microseconds, written as UTC with exactly six fractional digits. A client
must capture that same value: from `proc_pidinfo`, or from `sysctl` with
`KERN_PROC_PID` as `kp_proc.p_starttime`, which is the same record
(`DesktopProviderTests` captures it that way). `NSRunningApplication.launchDate`
is a different, later instant and never matches.
`scripts/vm-verify-desktop-client.py` is a complete example. An absent process, a
live PID started at another instant, and a process that is no application are
ordinary null. A `pid` that is not positive, or a `startedAt` in any other form
(whole seconds, another offset, fewer digits), is an input error with a response
path and no `extensions.kind`; it never falls back to the PID alone.

**Windows** are the application's real windows on the current Space, read through
the Accessibility API: role `AXWindow`, subrole standard, dialog or none,
minimised windows included, untitled windows with an empty title, and no row for
anything else an application puts in its window list (Finder lists its desktop).
Koine needs Accessibility consent for this; a read never asks for it, and without
it `windows` is a `permission` / `os-permission` error. `windows` is non-null, so
that error discards the enclosing `desktopApplication`; a query that does not
select `windows` still resolves the application.

**Remembered windows.** An application enumerates the windows of the current
Space alone. The rows it enumerates are `CURRENT`. After them come the windows
Koine saw in an earlier listing that the enumeration omits now, as `REMEMBERED`:
each window once, under the reference it had while current, because a remembered
window is the same held element. Its element is asked again as it is listed, which
works from another Space, so its title is normally fresh; when the application
does not answer, the title is the last one read. `desktopWindow` reports the same
observation a listing would. What is remembered is incomplete by nature: Koine
holds only what a client's listing has seen, so a window on a Space never listed
from is not known, and a window whose application stops answering stays listed
until its end can be seen. Nothing is ever selected from memory: `desktopWindow`
and `desktopFocusWindow` re-resolve a remembered window like any other, and
focusing one switches to its Space.

From `start()` to `stop()` the provider also observes endings, so that a held
element is dropped when the system says its window ended and not only when it is
next asked (`Sources/WindowObservation.swift`): `kAXUIElementDestroyedNotification`
for every window it has listed, through one `AXObserver` per application on the
main run loop, and `NSWorkspace.didTerminateApplicationNotification`, which needs
no consent. Both only ever remove. This is private provider state, reachable
through the provider's resolution alone; the engine still caches nothing. Closing
the management window changes none of it, and `stop()` removes the observers
without waiting on any other process.

**Accessibility consent.** `DesktopApplication.ref`, `name` and
`bundleIdentifier` need none, by either application lookup. `windows` and
`desktopWindow` need it. Without it they fail with `extensions.kind`
`permission`, `permissionClass` `os-permission`, `osPermission` `accessibility`
and `permissionOwner` `koine`, at the field's own response path; a grant without
`desktop:read` gets `permissionClass` `capability` instead, consent or no
consent, because the capability is checked first. The provider asks
`AXIsProcessTrusted`, which has no prompt option, so no read shows the consent
dialog. An Accessibility call that answers `kAXErrorAPIDisabled` is the same
error, for consent that ends while Koine runs.

**References** are opaque to clients. `koine://desktop/application/<pid>/<start µs>`
is a process incarnation; a window adds `/<session>/<token>`, naming the
accessibility element the provider holds for that window during this run of
Koine. Two windows with the same title have different references, a window keeps
its reference across listings, and a window reference from an earlier run of
Koine is `unavailable`.

Every use re-resolves, and the three lookups end in the same reads, so an
application or window reports the same fields however it was reached. A reference
that no longer names its target is an `unavailable` error at the field, never
null without an error and never another target: the process incarnation ended
(by reference that is an error, where an absent process *identity* is null); the
window closed; the held element is no longer a window or no longer provably its
own; the reference names the other resource kind or another provider; or its
remainder is not one this provider produces. What needs no Accessibility call is
decided first, so such a reference is `unavailable` with or without consent.
Across a restart of Koine an application reference resolves again, because the
process incarnation is all it encodes, and every window reference is
`unavailable`; the client lists again. Why that mechanism, the evidence for it with real
applications, and what it cannot distinguish:
[docs/verification/desktop-window-identity.md](docs/verification/desktop-window-identity.md).

**Focus.** `desktopFocusWindow(ref:)` needs `desktop:control` and nothing else:
its receipt, `DesktopFocusReceipt { ref }`, is the submitted reference, read under
the same authority, and has no window field. The provider re-resolves the
reference exactly as `desktopWindow` does, then checks consent, then asks the held
element once more that it is still its own window, and only then acts; a target
that cannot be re-established is `unavailable` and missing consent is
`os-permission`, and neither activates anything or moves focus. The action
restores a minimised window, makes the window main, raises it and brings its
application to the front through the Accessibility API (`AXFrontmost`): AppKit's
activation is closed to a background service, and answered no in the VM. macOS
treats coming forward as a request it may not honour, so a receipt is returned only once the application reports itself frontmost with
that element as its focused window, within three seconds. Every step that fails
is a `failed` error naming the step, including one after the window was raised
or the application activated; a window that closes mid-action is `unavailable`. Applications
may change focus afterwards, and a lost response does not mean the action failed.
The wait ends on cancellation and runs off the provider's queue, so reads are not
held behind it.

`task app:vm-verify-desktop-remembered`
(`scripts/vm-verify-desktop-remembered.sh`), after `task app`, proves the
remembered windows on the signed bundle with TextEdit, whose full-screen window is
a Space of its own: seen, left there, selected, returned, closed, its application
terminated and restarted, and a window opened and moved after the management
window closed. `Fixtures/WindowIdentityProbe observe` is the native witness that
the destruction notification arrives. Evidence:
[docs/verification/desktop-remembered-windows-vm.md](docs/verification/desktop-remembered-windows-vm.md).

`task app:vm-verify-desktop-focus` (`scripts/vm-verify-desktop-focus.sh`), after
`task app`, proves focus on the signed bundle with Finder, TextEdit and Stickies. A
reading grant lists the choices and a separate grant with `desktop:control` alone
focuses, using `DesktopChoices` and `FocusDesktopWindow` exactly as
`docs/design/desktop-operations.graphql` has them. What has focus is read from
the system by `Fixtures/WindowIdentityProbe`, never from Koine: each of two
same-titled windows in both orders, a window of a background application, a
minimised window and a window on another Space; and a closed window, a quit and
a restarted application, a reference that cannot be re-established and revoked
consent, none of which moves focus. Evidence:
[docs/verification/desktop-focus-vm.md](docs/verification/desktop-focus-vm.md).

`task app:vm-verify-desktop` (`scripts/vm-verify-desktop.sh`), after `task app`,
proves the reads on the signed bundle in a clean VM over loopback GraphQL with grants
created in Koine's window: the provider is `ACTIVE`, Finder resolves by `pid` and
`startedAt`, its same-titled windows carry distinct and stable references, a
mismatched `startedAt` and an absent process are null, a malformed one is an
input error, and a grant without `desktop:read` is refused. It gives Koine
Accessibility consent as a user does, in System Settings
(`KOINE_VM_PASSWORD` is the VM account's password, `admin` by default). The same
run covers the references and consent: the lookups agree; wrong-kind and
malformed references, a closed window, an ended process and a window reference
from before a Koine restart are `unavailable`; with consent absent, and revoked
while Koine runs, reads are `os-permission` errors and no dialog appears, which
`Fixtures/ConsentPromptControl` (test material that does ask with the prompt
option) is then seen to show. Evidence:
[docs/verification/desktop-application-and-windows-vm.md](docs/verification/desktop-application-and-windows-vm.md)
and [docs/verification/desktop-references-and-permission-vm.md](docs/verification/desktop-references-and-permission-vm.md).

The provider contract gained one outcome for this: `ProviderFailure.Kind.invalidInput`,
for an argument that is well-formed GraphQL but no value of a provider-owned
type. The host reports it as input coercion.

## Resident application

`Koine.app` is a scripted bundle around the package, not an Xcode project:
`scripts/build-app.sh` builds the `KoineApp` product in release, assembles the
bundle from `App/Info.plist` (bundle identifier `dev.antony.Koine`) and signs it
with the hardened runtime and `App/Koine.entitlements` (deliberately empty).
`KoineProviderAPI.framework` is embedded in `Contents/Frameworks` without its
module interface and signed first, inside-out. The executable's build-tree run
paths are reduced to exactly `/usr/lib/swift` (the OS Swift runtime, which
supplies the `@rpath` back-deployment libraries such as
`libswiftCompatibilitySpan`) and `@executable_path/../Frameworks`. The application
ships one provider: `scripts/build-app.sh` builds `Desktop.koineprovider` with
the provider's own build definition against the staged framework's interface,
places it in `Contents/PlugIns`, the in-application provider root, and signs it
with the hardened runtime before the application that seals it.
`scripts/verify-app.sh` checks that the root holds exactly that bundle, signed by
the same team, linking the framework by its install name and embedding no copy.

Every bundle, from development to release, is signed with
`Developer ID Application: Antony Blakey (TA43A4RUP3)`, so its designated
requirement — and with it TCC and login-item state — never changes across
rebuilds. `KOINE_SIGNING_IDENTITY` names another identity; `KOINE_APP_BUNDLE`
another output path. A missing identity is an error listing the valid ones:
there is no ad-hoc fallback. `scripts/verify-app.sh` checks the signature
strictly, the hardened-runtime flag, that the signing team is the identity's,
that the executable links the embedded framework by its install name through
those run paths and the framework carries the same team, and that the bundle
satisfies `identifier "dev.antony.Koine" and anchor apple generic and
certificate leaf[subject.OU] = "<team>"`. Notarization is a release
concern and is not done here.

**UI framework: AppKit lifecycle, SwiftUI content.** An `NSApplicationDelegate`
owns the process and one `NSWindow` hosting SwiftUI views. It is a regular Dock
application (the [default activation policy](https://developer.apple.com/documentation/appkit/nsapplication/activationpolicy-swift.enum/regular)
for a bundled app), not an accessory. The lifecycle the contract needs is
documented delegate behaviour rather than SwiftUI scene behaviour, which offered
no dependable way to re-show a single closed window on the macOS 13 floor this
was chosen against. The floor is now macOS 26; the choice is not revisited, and
nothing here claims SwiftUI still lacks that route:

- [`applicationShouldTerminateAfterLastWindowClosed`](https://developer.apple.com/documentation/appkit/nsapplicationdelegate/applicationshouldterminateafterlastwindowclosed(_:))
  returns `false`: "control returns to the main event loop and the application
  is not terminated", so the listener keeps answering with no window.
- [`applicationShouldHandleReopen`](https://developer.apple.com/documentation/appkit/nsapplicationdelegate/applicationshouldhandlereopen(_:hasvisiblewindows:))
  is sent "whenever the Finder reactivates an already running application
  because someone double-clicked it again or used the dock to activate it"; it
  re-shows the window.
- `applicationShouldTerminate` answers `.terminateLater`, awaits
  `KoineServer.stop()` (descriptor withdrawn, listener closed, lock released) and
  then replies, so Quit never leaves a descriptor to be found stale.

A second instance over the same data directory meets
`KoineServerError.alreadyRunning`, says so in an alert and exits without
listening. The window executes `koineManagement.grants`, `koineCreateGrant` and
`koineRevokeGrant` through `KoineManagementClient`; its capability choices are
whatever `Query.koine.availableCapabilities` serves. The list is re-read after
every create and revoke and whenever Koine becomes active, so a row shows only
a state the server reported. Revoking asks for confirmation naming the grant; a
failure is shown beside the list. The credential lives only in the sheet that
shows it and is dropped when the sheet is dismissed; nothing re-reads one, and
the window says that a lost credential is handled by revoking and creating
again.

**Request review.** The window's Requests section lists the pending enrollment
requests, which arrive with the status the window already polls every two
seconds (`ManagementClient.status()`, one operation), so a request appears in an
open window without the user doing anything. Each shows the client's label, its
comparison code, to be compared by eye with what the client shows, and a tick
for each capability it asked for. The ticks are the request's own
`requestedCapabilities`, all set, and never `availableCapabilities`: the user can
only narrow. Approve sends the ticked subset to `koineApproveGrantRequest`; Deny
sends `koineDenyGrantRequest`. A request that asks for `koine:manage` carries a
warning that it permits issuing and revoking other grants, and approving it with
that capability still ticked asks for confirmation in a dialog that has no
default button, so Return decides nothing and the approving button must be
chosen. What may be approved is the server's to say. A refusal is
shown beside the list, `already-decided` as the state the request is already in
(another manager decided it, or it expired), and the requests and grants are
re-read after every decision, whatever its outcome. The client's secret never
reaches Koine, so there is nothing here to show or copy.

**Login launch.** The window's Setup section registers and unregisters
[`SMAppService.mainApp`](https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp).
Apple documents that [`register()`](https://developer.apple.com/documentation/servicemanagement/smappservice/register())
makes the main application launch "on subsequent logins" and throws when the
user has not approved it, that [`unregister()`](https://developer.apple.com/documentation/servicemanagement/smappservice/unregister())
leaves the running application alone, and that [`requiresApproval`](https://developer.apple.com/documentation/servicemanagement/smappservice/status-swift.enum/requiresapproval)
means registered but waiting on the user in System Settings, including after
consent is withdrawn. So the model keeps no enabled flag of its own: after every
call, and whenever Koine becomes active, it reads `status` back and shows that,
with a button to Login Items Settings when approval is required. Observed in a
macOS 26.5 VM: a signed bundle that has never registered reads `notFound`, not
`notRegistered`, and registration from there succeeds, so the window words
`notFound` as "not registered" and leaves real failures to the error
`register()` throws.

**Accessibility, provider and service status.** Koine owns its one OS
permission visibly. `koineManagement.osPermissions` reports `accessibility`,
owner `koine` (the value `extensions.permissionOwner` carries) and whether it is
granted, to `koine:manage` alone. `KoineCore` has no platform: the host passes
`KoineServer.init(osPermissions:)` an `OSPermissionSource`, which the
`koineManagement` resolver calls on each request, after the capability check. The
application's source is [`AXIsProcessTrusted`](https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted),
which takes no options and so cannot prompt; a host that supplies none serves an
empty list.

The window's status comes from one operation, `ManagementClient.status()`
(contract version, instance, providers, OS permissions), re-read every two
seconds while the window's view lives, because nothing announces a consent
change. So the window and a managing client cannot disagree, and the status
follows System Settings without a restart. The port is the one fact taken from
the host; the schema has no field for it. Without consent the first section
names Koine as the application that needs it and offers two controls, the only
code that asks for anything: "Request Accessibility Access…" calls
[`AXIsProcessTrustedWithOptions`](https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions)
with the prompt option from Koine's own process, and macOS shows its dialog
naming Koine with its own button to System Settings; "Open Accessibility
Settings…" opens the pane directly. The pane's URL has no official source and is
checked by the VM run. `task app:vm-verify-accessibility`
(`scripts/vm-verify-accessibility.sh`), after `task app`, proves the workflow on
the signed build. Evidence:
[docs/verification/accessibility-status-and-consent-vm.md](docs/verification/accessibility-status-and-consent-vm.md).

A client needs nothing but the descriptor and a credential:

```sh
D="$HOME/Library/Application Support/Koine"
curl -s "http://127.0.0.1:$(jq -r .port "$D/endpoint.json")/graphql" \
  -H 'Content-Type: application/json' -H "Authorization: Bearer $CREDENTIAL" \
  -d '{"query":"{ koine { contractVersion ownGrant { clientLabel capabilities state } } }"}'
```

Run the application in a TestAnyware VM, not on a machine in use: it takes
focus and owns the account's real data directory.

**VM verification.** `task app:vm-verify` (`scripts/vm-verify.sh`) clones the
TestAnyware macOS golden, installs the signed bundle, and drives the real UI:
login launch across a restart with no client, a grant created and its
credential handed to a script, the window closed, the grant revoked (401), and
Quit (descriptor gone). It needs `testanyware` and `jq`, and leaves its
transcript in `.build/vm-verify/`. The procedure, what the route does and does
not show about Gatekeeper, and the recorded evidence are in
[docs/verification/resident-app-vm.md](docs/verification/resident-app-vm.md).

`task app:vm-verify-providers` (`scripts/vm-verify-providers.sh`) is its sibling
for native providers. After `task app`, it installs the signed bundle and, in
turn, three fixture bundles in the per-user provider root with their approval
record: the approved same-team fixture is `ACTIVE` and serves its field to a
client holding `fixture:read`; an ad-hoc signed one is `REJECTED` and one
demanding framework minor 99 is `INCOMPATIBLE`, each with a diagnostic, no
fixture field in introspection, no image mapped, and management still
answering. It records the bundle's empty entitlements, the framework's signature
inside the bundle and the images the process mapped. Evidence:
[docs/verification/signed-app-provider-vm.md](docs/verification/signed-app-provider-vm.md).

## Dependencies

Each was chosen from its repository and manifest at the pinned release
(2026-09-18), not from memory. All support macOS 10.15 or later and Linux.

| Library | Use | Why |
|---|---|---|
| [GraphQLSwift/GraphQL](https://github.com/GraphQLSwift/GraphQL) 4.2 | Execution engine | Separate `parse`/`validate`/`execute`, full introspection, custom scalars, schemas from SDL with settable per-field resolvers, async `Sendable` resolvers. |
| [swift-nio](https://github.com/apple/swift-nio) 2.103 | HTTP listener | Direct control of the HTTP/1.1 rules the contract fixes. Hummingbird 2 was the alternative; it adds a router and a dozen packages this one endpoint does not use. |
| [GRDB.swift](https://github.com/groue/GRDB.swift) 7.11 | Grant store | SQLite transactions and migrations with a maintained Swift 6 API. |
| [swift-crypto](https://github.com/apple/swift-crypto) 5.0 | SHA-256 | CryptoKit's API without binding the core to Apple platforms. |

`KoineCore` has not yet been built on Linux; its imports are Foundation, GraphQL
and Crypto only.

Work is driven as a grove task tree under `.grove/`.
