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
full introspection. The second increment is under way: a signed resident
`Koine.app` embeds that server and creates grants from its window, and a
`koine:manage` grant lists grants with `Query.koineManagement { grants }` and
revokes one with `Mutation.koineRevokeGrant`. Revocation is a durable commit
made inside the same serialized authority boundary that admits every action, so
a revoked credential gets 401 on its next request, keep-alive or not. The
window also lists and revokes grants and enables login launch. Providers and
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
task build     # swift build
task test      # swift test: the public-seam suite over real loopback HTTP
task app       # assemble and sign .build/app/Koine.app
task app:verify  # codesign --verify --strict, hardened runtime, designated requirement
```

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

| `KoineManagementClient` | What the native UI knows of the server: the management operations as GraphQL through the `LocalConsole`, with GraphQL errors surfaced as `ManagementError`. Foundation only, so it is tested against an embedded server. |
| `KoineApp` | The resident application's executable: AppKit lifecycle, SwiftUI views. The only target that imports platform UI frameworks. |

An application embeds it as the tests do: `KoineServer(dataDirectory:)`, then
`start()`. `server.console` is the local-console principal; it has no wire form.

## Resident application

`Koine.app` is a scripted bundle around the package, not an Xcode project:
`scripts/build-app.sh` builds the `KoineApp` product in release, assembles the
bundle from `App/Info.plist` (bundle identifier `dev.antony.Koine`) and signs it
with the hardened runtime and `App/Koine.entitlements` (deliberately empty).
`Contents/Frameworks` arrives with the provider framework and will be signed
inside-out before the bundle.

Every bundle, from development to release, is signed with
`Developer ID Application: Antony Blakey (TA43A4RUP3)`, so its designated
requirement — and with it TCC and login-item state — never changes across
rebuilds. `KOINE_SIGNING_IDENTITY` names another identity; `KOINE_APP_BUNDLE`
another output path. A missing identity is an error listing the valid ones:
there is no ad-hoc fallback. `scripts/verify-app.sh` checks the signature
strictly, the hardened-runtime flag, that the signing team is the identity's,
and that the bundle satisfies `identifier "dev.antony.Koine" and anchor apple
generic and certificate leaf[subject.OU] = "<team>"`. Notarization is a release
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
