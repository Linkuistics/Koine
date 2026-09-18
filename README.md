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
full introspection. The resident application, providers and the desktop path
are later increments. The agreed design:

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
```

The tests embed the server over a temporary data directory; they never touch
`~/Library/Application Support/Koine`.

## Package layout

| Target | Role |
|---|---|
| `KoineCore` | The Machine core: principals, credentials, the `GrantStore` contract and GraphQL execution with per-field authorization, bounded by the versioned `RequestPolicy` limits. No macOS, client or provider dependency; the GraphQL library is private to it. |
| `KoineSQLiteStore` | The durable `GrantStore`: one SQLite file, fully synchronised commits, fails closed. |
| `KoineHTTP` | An HTTP/1.1 listener bound to `127.0.0.1` on an OS-assigned port. Knows nothing of GraphQL. |
| `KoineServer` | The embeddable composition: data directory, single-instance lock, descriptor lifecycle, the HTTP transport rules, bearer authentication, and the in-process `LocalConsole`. |

An application embeds it as the tests do: `KoineServer(dataDirectory:)`, then
`start()`. `server.console` is the local-console principal; it has no wire form.

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
