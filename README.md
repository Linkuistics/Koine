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
installed workflow is verified in a clean VM. Providers and
the desktop path are later increments. The agreed design:

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

## Building and testing

Requires Swift 6.2 or later on macOS 13 or later (developed with Swift 6.4).

```sh
task           # build, then test (needs https://taskfile.dev)
task build     # swift build, then stage KoineProviderAPI.framework
task test      # build, stage, build the fixture provider and its variants, then the suites over real loopback HTTP
task fixture   # stage the framework, build the fixture provider outside the package, sign and approve it
task fixture:variants  # build, sign and approve the bundles the native loader must refuse, and the few good ones
task compat    # build and run the binary compatibility pairs; compat:build and compat:verify are its halves
task app       # assemble and sign .build/app/Koine.app
task app:verify  # codesign --verify --strict, hardened runtime, designated requirement
task app:vm-verify  # the installed workflow in a clean TestAnyware macOS VM
```

Use `task test`, not a bare `swift test`: every host image links the provider
framework by its framework install name, which resolves only once the framework
is staged ("Provider framework" below), `NativeProviderTests` needs the fixture
bundle and `ProviderLoaderTests` needs its variants. The fixtures are signed
with the identity `task app` uses (`KOINE_SIGNING_IDENTITY` overrides it), since
the loader admits only signed, approved bundles; there is no ad-hoc fallback.

The tests embed the server over a temporary data directory; they never touch
`~/Library/Application Support/Koine`.

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
application's own signature) and which is empty until the desktop provider
exists, and the per-user root.

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
ships no provider yet: `Contents/PlugIns`, its in-application provider root, is
present and empty, which `scripts/verify-app.sh` checks.

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
documented delegate behaviour rather than SwiftUI scene behaviour, which on the
macOS 13 floor offers no dependable way to re-show a single closed window:

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
