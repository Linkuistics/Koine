# Koine

A koine is the common language that forms where many dialects meet. Koine is
the Machine server: a standalone application for discovering, querying and
commanding the desktop and applications through a fully introspectable
GraphQL API. Local clients connect over loopback HTTP using capabilities
granted by Koine.

[ModalAnyware](../ModalAnyware) is the first client. The first deliverable
lets it resolve a running application, list its windows and focus one.
Koine holds the OS permissions for those operations, stays resident or is
started by the OS on endpoint access, and provides a native macOS management
UI alongside management through GraphQL. Grants last until explicitly revoked.

Providers are native Swift extensions that contribute to the GraphQL schema.
A stable binary interface must allow compatible providers and the server to
be upgraded independently. The concrete ABI and loading design are still to
be settled; a TypeScript hosting layer is not required.

Broader discovery, including applications that are not running, and an LLM
skill set are deferred until after ModalAnyware is unblocked.

Nothing is built yet. Requirements are agreed; the next step is design.
The inherited detailed interface and diagrams below still need reconciliation
with GraphQL and native extensions:

- [Inherited Machine contract](docs/specs/machine.md): provider-owned URI
  references and desktop behavior; its generic query/execute wire examples
  are inputs to the design, not the required public API
- Decisions: [references as URIs](docs/adr/machine-references-as-uris.md),
  [the server and native providers](docs/adr/koine-server-and-native-providers.md)
- Shared terms: [CONTEXT.md](CONTEXT.md)
- Diagrams: [docs/design/architecture](docs/design/architecture/README.md)

Work is driven as a grove task tree under `.grove/`.
