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
conflict. The agreed sections record the human's confirmed requirements
from `plan-k1`.

The agreed decisions below supersede the inherited query/execute wire payload
and PluginAnyware hosting requirement. In `desktop-contract-k2`, the human
approved the complete design in `docs/specs/machine.md`, its GraphQL schema and
architecture views. That contract and the ADR set are the implementation
baseline; the inherited notes below explain their starting constraints.

**Inherited contract**, in full in `docs/specs/machine.md`:

- A reference is a URI string, `koine://<provider>/<provider-owned
  remainder>`. The engine reads only the authority to route; the provider
  alone produces and interprets the remainder and re-resolves it on every
  use. A provider's root is a reference with an empty remainder. The scheme
  name follows this project's name, as the inherited placeholder rule requires.
- The inherited domain error vocabulary is `unknown-provider`,
  `unknown-relation`, `unknown-command`, `unavailable`, `permission`,
  `failed`. The agreed spec maps relation/command mistakes to GraphQL
  validation and preserves the other kinds as execution classifications;
  capability refusal remains distinguishable as `permission`.
- The engine caches nothing, refreshes nothing and retries nothing;
  consistency is per call. A provider may keep observation state its platform
  requires.
- The Machine package is Swift, after considering Rust, with no dependency on
  macOS, a concrete application or a client. Providers are written against
  its `Provider` contract.
- The transport and capability model are this project's own design. The
  public payload is now GraphQL, as agreed below.

**Server boundary**, in
`docs/adr/koine-server-and-native-providers.md`:

- No project includes the server. ModalAnyware is a client from its first
  increment with no in-process interim; no provider lives in ModalAnyware.
- Providers are native Swift server plugins, with independent upgrades
  through a stable binary interface. The desktop provider is the first, and the
  only one ModalAnyware's first increment needs: convert an application's
  process identity to a reference, list its windows, focus one, and report
  `unavailable` after a window closes.

**Inherited purpose**, stated by the human in plugin-packages-k6: the
not-running case covers configuration and installation analysis and an
application's parts under `/Library` and the like; third-party applications
can use the server; it ships with an LLM skill set.

## First deliverable (agreed)

The human chose "Unblock ModalAnyware first" in `plan-k1`. Deliver the
complete desktop path with the desktop provider: resolve an application from
its process identity, list its windows and focus one. The transport and
capability checks must be real in this first deliverable. Broader discovery,
including inspection of applications that are not running, is deferred.
The LLM skill set is also deferred until after ModalAnyware is unblocked.

## Native extensions and independent upgrades (agreed)

In `plan-k1`, the human described the intended extensions as purely native,
per-application contributions to a GraphQL schema. This reopens the inherited
requirement to host providers through PluginAnyware, whose current contract
requires a TypeScript or JavaScript entry module.

The human requires "a stable binary interface so that we can upgrade plugins
and the server independently". Compatible plugin/server binaries must not
require rebuilding each other. Compiled-in modules alone cannot satisfy this
extension requirement. In `desktop-contract-k2`, the human chose a shared
resilient Swift framework as the binary interface for native Swift dylibs.
Its public types and protocols carry the compatibility promise, with library
evolution and module stability from the first release. The concrete loading and
version policy is specified by that design. Open-source distribution is still
under discussion.

Plugin authoring is Swift-only initially. Plugins will make significant use
of OS-specific APIs; keep this work separate from APIAnyware. Cross-language
authoring and APIAnyware integration are outside the first version. This
does not relax the requirement for a stable binary interface or independent
plugin/server upgrades.

## Public GraphQL API (agreed)

GraphQL replaces the inherited generic query/execute wire contract. Expose
state through queries and commands through mutations, with native providers
contributing their types and operations to the public schema.

Full introspection is required to enable client code generation and
type-aware tooling. Provider-contributed types and operations must be
described in that schema. The old query/execute payload is not a second
required public API. The agreed `koine-desktop/1` contract specifies the
`Reference` scalar, meaningful nullability, domain errors and capability
checks. ModalAnyware's client handoff targets this contract using standard
GraphQL tooling and a client-owned adapter; no Koine-owned Swift client helper
is required for the first deliverable.

## Connection scope (agreed)

Local access is sufficient, and the human expects that likely to remain true.
Serve clients on the same machine; remote access is outside the current
plan. The transport is GraphQL over HTTP, bound only to loopback, with client
authentication and capability checks. A Unix-domain socket is not required
for the first version. The agreed spec defines the per-user endpoint descriptor,
literal IPv4 loopback connection and bearer-grant access control; remote support
is not a future requirement.

## Server availability (agreed)

In `desktop-contract-k2`, the human selected one resident, per-user Koine
application containing the native management UI, server and providers. It owns
the OS permissions and keeps management authority in process. Clients do not
own its launch or lifetime; closing the management window leaves the service
and provider observation running. The design supplies the concrete OS login
launch arrangement. Automatic idle retirement is not a requirement.

## OS permissions and client capabilities (agreed)

Koine holds the OS permissions required to perform native provider
operations. ModalAnyware should need minimal OS permissions, limited to its
own functions; it accesses Koine's functionality through capabilities
granted by Koine. Those capabilities are Koine's client security mechanism.

The first version grants clients read and control capabilities per provider.
In `desktop-contract-k2`, the human selected transferable bearer credentials
with live revocation. Each client stores its grant token in Keychain, or a
protected file for scripts, and presents it over the GraphQL connection. Koine
looks up the live grant on every request and uses its capability set to authorize
the operation. Possession of the token confers access; client-key binding and
request signing are not selected. The decision is recorded in
`docs/adr/bearer-grants-and-live-revocation.md`. The agreed contract serializes
revocation and action admission: revocation blocks subsequent actions, while
an action already admitted may finish.

The design must distinguish a client lacking a Koine capability from Koine
lacking an OS permission. Read queries should return partial results where
possible, with authorization denial reported as an explicit error rather
than ordinary absence of a value. Do not make the schema's fields universally
nullable to accommodate denial; preserve meaningful non-null domain types.
Use standard GraphQL execution-error propagation: an error at a non-null
position propagates to the nearest nullable ancestor and may discard a branch
or make all `data` null. The human accepts that consequence. Include the
error's response path and a machine-readable permission classification;
partial data is returned where the schema permits.

Before executing any mutation action, check the capabilities required by all
requested actions. If any requested action is unauthorized, reject the whole
operation before actions begin. This guarantees authorization before actions,
not rollback: a later runtime failure can still occur after an earlier
authorized action completed.

## Management (agreed)

The first version includes a native macOS management UI. Koine must also be
manageable through its own GraphQL interface, under its capability model.
The human clarified that the requested native surface is a UI; an additional
public Swift management API is not required by that request. A CLI alone is
insufficient.

Support both grant workflows: a client requests capabilities for the user to
approve or deny in Koine's UI; or the user creates a grant in the UI and
supplies it to a client manually. The corresponding management functions
also belong to the GraphQL management surface, subject to management
authority. Grants are permanent until explicitly revoked, survive client and
Koine restarts, and do not expire automatically. Existing connections must
observe live revocation. The selected resident application's native UI keeps
its management authority in process; the design specifies bootstrap and the
boundary for work already in flight.

## Test seams (agreed)

The human accepted these boundaries in `plan-k1`:

- The public GraphQL API: introspection, capability enforcement, partial
  results, mutation authorization and grant persistence/revocation.
- The native plugin boundary: independently built server/plugin versions
  demonstrate compatibility across supported ABI versions.
- Real macOS workflows in isolated TestAnyware VMs: both grant workflows in
  the native UI, plus discovering windows, focusing them, closed windows and
  missing OS permissions.

Carry these boundaries into the design's test-seams section. Keep testing
proportionate; prefer exercising shared behavior through these public
boundaries to repeating it at each internal layer.

## Done when (agreed)

A client that knows nothing of the server's internals can use the fully
introspectable loopback GraphQL API to resolve a running application, list its
windows and focus one through the desktop provider. Koine enforces the
agreed capability and error behavior and holds the required OS permissions.
ModalAnyware's Machine client can be written against a stated version of
that public contract.

Koine is available independently of its clients. Its native macOS UI and
GraphQL management surface support both agreed grant workflows, with grants
persisting until explicitly revoked. Native Swift providers and the server
can be upgraded independently across supported ABI versions. Broader
application discovery and an LLM skill set are outside this first completion
target.

## Decomposition

`plan-k1` established the requirements and `desktop-contract-k2` produced the
complete design, now approved by the human. `desktop-delivery-k3` plans its
implementation as small, independently useful working increments. The design
is the baseline for that decomposition, including the three agreed test seams
and the ModalAnyware client handoff.

`desktop-delivery-k3` found six working increments, ordered by dependency and
then by risk. Each leaves Koine working with more useful, verifiable behaviour
than before:

1. `authenticated-endpoint-k4` — a client with a grant finds the loopback
   endpoint and introspects it. Cut into impl leaves.
2. `resident-app-manual-grants-k7` — the signed resident application; a user
   creates, lists and revokes grants; live revocation.
3. `native-provider-contribution-k8` — independently built native providers
   contribute schema under enforced capabilities; binary compatibility evidence.
4. `desktop-path-k9` — resolve, list and focus through the real desktop
   provider, starting with the native window-identity evidence.
5. `grant-enrollment-k10` — the client-requested grant workflow and its UI.
6. `release-acceptance-handoff-k11` — whole-contract conformance, signed-build
   VM acceptance, supported matrix and the ModalAnyware handoff.

Only the first is cut into impl leaves. Each later stage is a `planning` leaf
carrying its charter, acceptance cases and open questions; it is cut when
reached, with what the stages before it actually built. Stage 5 depends only on
stage 2 and can move earlier at no cost. Each stage serves only the schema
fields it makes real; stage 6 checks the composed schema against the design SDL.

No research, prototype or review stage is added automatically. Open-source
licensing/distribution remains undecided and is not a condition of the first
deliverable.

## Pointers

- Contract: `docs/specs/machine.md`. ADRs:
  `docs/adr/machine-references-as-uris.md`,
  `docs/adr/koine-server-and-native-providers.md`,
  `docs/adr/resilient-provider-framework.md`,
  `docs/adr/bearer-grants-and-live-revocation.md`.
- Glossary: `CONTEXT.md`.
- Views: `docs/design/architecture/` (its README has the build commands).
- The inherited hosting candidate: `../PluginAnyware`, contract in
  `../PluginAnyware/docs/specs/plugin-framework.md`. Its TypeScript/JavaScript
  entry-module contract conflicts with the agreed purely native extension
  direction; it is not an assumed hosting dependency for the revised design.
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

Cross-provider identity, atomic snapshots, transactional command rollback and
automatic retry remain outside the agreed first desktop contract. GraphQL
supplies client field selection; the current spec defines its execution and
error semantics.

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

The human chose a root `Taskfile.yml` as the workflow tool in
`first-authenticated-query-k5`. It wraps `swift build` and `swift test`; later
stages add their build and verification commands to it.

`authenticated-endpoint-k4` is complete. What later stages build on: the
embeddable `KoineServer(dataDirectory:policy:)` is one run per object and holds
the data directory's instance lock from `init` to `stop()`, so the resident
application must `stop()` it to hand over; every request/response limit is a
value of `RequestPolicy` in `KoineCore`, and a stage that adds schema keeps
introspection inside it. "Serve only what is implemented" and "keep the GraphQL
library private to the engine" (that node's notes) continue to bind.

The seed records ModalAnyware paused at `first-increment-k7`, waiting for
Koine and, separately, PluginAnyware. That does not make PluginAnyware a
dependency of Koine. One of that leaf's hand-offs is ModalAnyware's Machine
client against this server's public contract.
