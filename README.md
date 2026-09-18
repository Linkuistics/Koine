# Koine

A koine is the common language that forms where many dialects meet. Koine is
the Machine server: a standalone application that gives scripts, LLM agents
and other applications one uniform way to discover, query and command the
machine and each application on it, running or not, while every provider keeps
its own vocabulary. Access is guarded by a capability model, and the project
ships an LLM skill set for using it.

No project includes Koine; they are its clients.
[ModalAnyware](../ModalAnyware) is the first. Providers are Koine's plugins,
hosted through [PluginAnyware](../PluginAnyware); the desktop provider is the
first.

Nothing is built yet. The contract this project starts from was agreed in
ModalAnyware's architecture design, under the working name "Machine server",
and is carried here:

- [Machine contract](docs/specs/machine.md): URI references, two uniform
  calls, a closed error set
- Decisions: [references as URIs](docs/adr/machine-references-as-uris.md),
  [the server and the shared plugin framework](docs/adr/machine-server-and-shared-plugin-framework.md)
- Shared terms: [CONTEXT.md](CONTEXT.md)
- Diagrams: [docs/design/architecture](docs/design/architecture/README.md)

Work is driven as a grove task tree under `.grove/`.
