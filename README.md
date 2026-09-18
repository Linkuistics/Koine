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

Nothing is built yet. The complete desktop design is agreed and ready for
implementation planning:

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

Work is driven as a grove task tree under `.grove/`.
