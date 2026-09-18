# Koine — brief

## Goal

Build the Machine server as a standalone application: unified discovery and
scriptability over the machine and each application on it, running or not,
served to scripts, LLM agents and other applications through one uniform
contract, guarded by a capability model, with an LLM skill set. ModalAnyware
is its first client, and ModalAnyware's first increment waits on it.

## Where this starts from

Everything below marked **inherited** was agreed or stated by the human in
`../ModalAnyware` and is carried here, not reopened without a concrete
conflict. Everything marked **to confirm** is this seed's reading of what the
project needs; `plan-k1` replaces it with the human's own words.

**Inherited contract**, in full in `docs/specs/machine.md`:

- A reference is a URI string, `machine://<provider>/<provider-owned
  remainder>`. The engine reads only the authority to route; the provider
  alone produces and interprets the remainder and re-resolves it on every
  use. A provider's root is a reference with an empty remainder. The scheme
  name was agreed as a placeholder that follows this project's name.
- Two uniform calls: `query(target, relation, args?)` returns a snapshot of
  items, each with its reference and provider-defined fields;
  `execute(target, command, args?)` returns the provider's result.
- A closed JSON error set: `unknown-provider`, `unknown-relation`,
  `unknown-command`, `unavailable`, `permission`, `failed`. A capability
  refusal surfaces as `permission`.
- The engine caches nothing, refreshes nothing and retries nothing;
  consistency is per call. A provider may keep observation state its platform
  requires.
- The Machine package is Swift, after considering Rust, with no dependency on
  macOS, a concrete application or a client. Providers are written against
  its `Provider` contract.
- This contract is the server's wire payload. The transport and the
  capability model that carry it are this project's own design.

**Inherited shape**, from
`docs/adr/machine-server-and-shared-plugin-framework.md`:

- No project includes the server. ModalAnyware is a client from its first
  increment with no in-process interim; no provider lives in ModalAnyware.
- Providers are the server's plugins, hosted through the shared plugin
  framework (`../PluginAnyware`). The desktop provider is the first, and the
  only one ModalAnyware's first increment needs: convert an application's
  process identity to a reference, list its windows, focus one, and report
  `unavailable` after a window closes.

**Inherited purpose**, stated by the human in plugin-packages-k6: the
not-running case covers configuration and installation analysis and an
application's parts under `/Library` and the like; third-party applications
can use the server; it ships with an LLM skill set.

## Done when (to confirm)

A client that knows nothing of the server's internals can reach it over its
transport with a capability, run the agreed chooser example against real
applications through the desktop provider, and be refused by the capability
model when it lacks the capability. An LLM agent can do the same through the
shipped skill set. ModalAnyware's Machine client can be written against a
stated version of the transport.

## Decomposition

`plan-k1` establishes the requirements with the human. Nothing else is cut
yet, and no further stage is implied.

## Pointers

- Contract: `docs/specs/machine.md`. ADRs:
  `docs/adr/machine-references-as-uris.md`,
  `docs/adr/machine-server-and-shared-plugin-framework.md`.
- Glossary: `CONTEXT.md`.
- Views: `docs/design/architecture/` (its README has the build commands).
- The plugin framework the server embeds: `../PluginAnyware`, contract in
  `../PluginAnyware/docs/specs/plugin-framework.md`. It is being built in
  parallel and does not exist yet.
- The first client's side: `../ModalAnyware/docs/specs/architecture.md`
  (project locations), `../ModalAnyware/docs/specs/native-plugins.md`
  (providers are not a ModalAnyware contribution) and
  `../ModalAnyware/docs/specs/configuration-ui.md` (the resident bridge whose
  query and execute the Machine client carries here).
- Existing desktop behaviour to preserve, in `../Modaliser/Sources/Modaliser/`:
  `WindowEnumerator.swift`, `WindowCache.swift` (windows remembered across
  spaces), `WindowManipulator.swift`, `WindowLibrary.swift`, `AppScanner.swift`,
  `AccessibilityLibrary.swift`.

## On the horizon

The human's larger purpose, recorded as context for the server's requirements
and not as work for this grove: a virtual IDE composed from individual
applications, mediated by LLMs and scripts. The human has an earlier project,
an LLM-coordination blackboard and tool integration platform, of which this
server could be an important part.

Open contracts the inherited spec names and leaves open: identity across
providers, an atomic instant across calls or providers, command atomicity and
retry, and field selection within a query.

## Notes

Carried from ModalAnyware because the human stated them as how they want to
work; `plan-k1` confirms they hold here. Check each composition and process
decision with the human. One concrete question at a time, with a
recommendation and its trade-off. Avoid rabbit holes, speculative modules and
scope creep. Do not add research, prototype, review or other stages
automatically. Keep testing proportionate, and exercise real desktop and
application behaviour through TestAnyware in isolated VMs; application mocks
are not a prerequisite. Prefer small, composable modules with narrow
interfaces that can be tested and documented in isolation.

ModalAnyware's grove is paused at `first-increment-k7` until this project and
PluginAnyware exist. One of that leaf's hand-offs is ModalAnyware's Machine
client against this server's transport.
