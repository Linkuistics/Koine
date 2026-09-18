# plan-k1

## Goal

Establish with the human what Koine must deliver, and in what order, starting
from the Machine contract already agreed in ModalAnyware and from the purpose
the human stated there.

## Context

The root brief lists what is inherited. Read `docs/specs/machine.md` and both
ADRs before asking anything. The contract's payload is agreed; almost
everything about the *server* is not: ModalAnyware's design deliberately left
the transport, the capability model, provider hosting and the skill set to
this project. This project was seeded on 2026-09-18 by ModalAnyware's
`first-increment-k7` session at the human's direction; nothing in this
repository has been built.

## Done when

The human has confirmed, in their own words, the server's scope and
completion target, the questions below that they consider worth settling now,
and the next step. Record agreed requirements in the root brief and resolved
terms in `CONTEXT.md` as they settle, and agree the next step before growing
the tree.

## Notes

Questions the seed could state but not answer. They are this seed's reading,
not an agenda the human has accepted; ask one at a time, with a
recommendation.

1. **The first slice.** ModalAnyware's first increment needs one provider
   and three operations: the application for a process identity, its windows,
   focus. The stated purpose is far wider (every application, running or not,
   third-party clients, LLM agents). Is the first deliverable exactly what
   unblocks ModalAnyware, with the capability model and transport real but
   minimal?
2. **How a provider is hosted.** Unreconciled in what was inherited: a
   provider is "written against the Swift `Provider` contract", which is an
   in-process protocol, and is also "the server's plugin through the shared
   plugin framework", where a plugin is a TypeScript main module with an
   optional native executable reached over NDJSON pipes. Is a Swift provider
   the native executable of a plugin whose TypeScript module registers it, a
   library the server links, or something else? This decides whether the
   server embeds a script environment at all.
3. **The transport.** What clients connect over, and how they find it: a
   Unix socket, XPC, local HTTP, stdio for an agent. ModalAnyware queries
   during window reconstruction, inside a keyboard interaction, so the
   latency of a query matters to the first client.
4. **The capability model.** What a capability names (a provider, a
   relation, a command, a reference prefix), who issues one, how a client
   presents it, and what a refusal tells the client beyond `permission`.
5. **Process model and lifetime.** A launch agent, a login item, an
   application with a menu bar presence, or started on demand by its first
   client. What happens to a client when the server is not running.
6. **Who holds the platform permissions.** The desktop provider needs
   Accessibility. With the provider outside ModalAnyware, the grant belongs
   to another process, and the inherited spec has the *client* prompting the
   user on a `permission` error. Which process must be granted, and how the
   user is led there, needs checking against how macOS attributes
   responsibility to child processes rather than assuming it.
7. **A client library.** Does this project ship the Swift client that
   ModalAnyware's Machine client module wraps, so the transport has one
   implementation on each side?
8. **The LLM skill set.** What it must let an agent do in the first slice,
   and through what: a CLI over the transport, an MCP server, skills that
   call either.
9. **Names.** The project is Koine. Does the URI scheme become `koine://`
   as the placeholder rule says, and do "Machine package" and "Machine
   abstraction" stay as the terms for the core and the idea?
10. **Which repository owns the contract now.** `machine.md` and the two
    ADRs exist in both repositories. Recommended: this project owns them
    from here, and ModalAnyware's copy reduces to what its client and facade
    do.
11. **The dependency on PluginAnyware.** It is being built in parallel.
    Which of this project's work can proceed before it exists, and what does
    this project need from it first?

## Decisions (running log)

**First deliverable.** The human chose: "Unblock ModalAnyware first
(recommended)". Deliver the complete desktop path: resolve an application
from its process identity, list its windows and focus one, with a real
transport and capability checks. Broader application discovery, including
inspection of applications that are not running, is deferred. This settles
the first slice; provider hosting, the transport, the capability model and
the other server choices remain to be settled.

**Native application extensions; hosting reopened.** The human expected
"purely native plugins" whose purpose is to "extend the graphql schema and
be per-application". They asked whether Koine needs PluginAnyware at all and
raised an open-source product with compiled-in modules as an alternative.
The inherited PluginAnyware dependency is therefore reopened: its TypeScript
entry-module requirement conflicts with the intended native extension model.
The proposed TypeScript wrapper was not accepted. Compiled-in modules,
runtime native plugins and open-source distribution are alternatives under
discussion, not settled choices. The relationship between the intended
GraphQL schema and the inherited query/execute payload also needs to be
resolved before implementing either interface. The agreed first deliverable
remains the desktop path that unblocks ModalAnyware.

**Native loading candidate.** The human raised Swift dylibs with a fixed
extension-point interface as a runtime plugin mechanism. Include this
alternative in the hosting decision; a native plugin does not imply a
TypeScript wrapper. Whether extensions must be independently installable,
and what binary compatibility Koine promises between releases, remain open.

Questions for the native extension contract, regardless of loading mechanism:
schema names must compose without collisions; side-effecting operations need
valid GraphQL mutation placement; resource identity, nullability and errors
must preserve the client's closed-window behavior; and extension-contributed
fields and operations must participate in capability checks. These are design
questions, not reasons to require a script runtime. Rebuilding Koine to update
a compiled-in extension is the explicit distribution trade-off; dylibs move
that work into a separately versioned binary interface and loading policy.

**Stable binary interface and independent upgrades.** The human required:
"We need a stable binary interface so that we can upgrade plugins and the
server independently". Independently distributed native plugins are now a
requirement, with binary compatibility across supported plugin/server
versions; requiring both to be rebuilt together does not meet it. Compiled-in
modules alone cannot be the extension mechanism. Swift dylibs remain the
proposed loading mechanism. The ABI representation, supported-version policy
and handling of newly required features are still to be designed; a Swift
interface, a C-compatible interface and any particular SDK design have not
been selected.

**Swift-only plugin authoring initially.** The human chose "Swift-only for
now", noting that plugins will make significant use of OS-specific APIs.
APIAnyware already addresses that area, but the human explicitly wants to
keep these concerns separate. Initial plugin authoring is Swift-only;
cross-language authoring and APIAnyware integration are outside this first
version. The stable binary interface and independent-upgrade requirement
still applies. This settles the authoring language, not the detailed ABI or
SDK design.

**Public GraphQL API and full introspection.** The human confirmed that
GraphQL replaces the inherited query/execute wire contract: "yes, I want the
GraphQL API with full introspection to enable code generation and type-aware
tooling for clients." State is exposed through GraphQL queries and commands
through mutations. Native providers contribute to the public schema, and
their types and operations must be available through introspection for client
generation and tooling. The old generic query/execute payload is not a second
required public API. Reconcile the inherited spec and the ModalAnyware client
handoff with this decision; resource references, domain errors and capability
checks still need a concrete GraphQL representation.

**Local access.** The human confirmed: "local access is sufficient, and
likely for the future as well." Koine serves clients on the same machine;
remote access is outside the current plan, not a presumed later milestone.
The local transport and client access controls remain to be settled.

**Local transport.** The human accepted the recommended GraphQL-over-HTTP
transport bound only to loopback. Keep the inherited requirement for client
authentication and capability checks. A Unix-domain socket is not required
for this first version. Endpoint discovery, server lifetime and the concrete
capability model remain to be settled.

**OS permissions belong to Koine; clients receive capabilities.** The human
clarified: "ModalAnyware should need minimal OS permissions - it is Koine
that will need permissions. ModalAnyware *will* need to be granted Koine
capabilities, which is the security mechanism that Koine will use."
Koine holds the OS permissions required for native provider operations.
ModalAnyware reaches those operations through Koine-granted capabilities;
it should require only the OS permissions intrinsic to its own functions.
Capability refusal and missing OS permission in Koine are distinct causes
that the eventual error and permission-guidance design must preserve. The
human has not yet chosen provider-level read/control grants or finer
capability granularity.

**Initial capability granularity and presented capability sets.** The human
accepted provider-level read/control capabilities initially, adding:
"ultimately a set of capabilities will be provided over the GraphQL
connection and Koine will either execute the graphql, maybe partially, or
deny." The model is a set of capabilities granted by Koine and presented by
the client, against which Koine authorizes the requested GraphQL operation.
The first version uses provider-level read/control grants; finer capabilities
may follow. The capability representation and transport attachment remain
open. Partial execution was raised as a possibility, not an agreed policy;
settle authorization failures for queries and mutations explicitly.

**Partial read results without weakening domain types.** The human chose
"partial results, but not if that requires the schema to have all nullable
values. This is an error, not a null". Authorization denial must be reported
as an explicit error, distinguishable from ordinary absence of a value.
Preserve meaningful non-null domain fields; do not make all fields nullable
to accommodate capability failures. The precise error-propagation boundary
must be reconciled with GraphQL's non-null semantics. Mutation authorization
failure policy remains open.

**Standard GraphQL propagation accepted.** The human accepted preserving
meaningful schema nullability and applying GraphQL's standard execution-error
propagation. A denial is an explicit error, with its response path and a
machine-readable permission classification; it is not ordinary absence.
An error at a non-null position propagates to the nearest nullable ancestor,
and may discard an enclosing branch or make all `data` null. Partial results
are therefore returned where the schema permits, not guaranteed for every
failure. Do not weaken domain types merely to retain more partial data.

**Mutation authorization before actions.** The human agreed that Koine must
check the capabilities required for every requested mutation action before
executing any action. If any requested action is unauthorized, reject the
whole operation before actions begin. This is an authorization guarantee,
not a transaction or rollback guarantee: later runtime failures, such as a
window closing during execution, may still occur after an earlier authorized
action completed.

**OS-managed availability.** The human agreed that Koine should "stay
resident, or be triggered by the OS's start-on-port-access mechanism".
Clients connect to the local endpoint without owning Koine's launch or
lifetime. A resident per-user service and OS socket activation are both
acceptable; the concrete launch arrangement is a design choice. Preserve the
desktop provider's observation needs and responsiveness during keyboard
interactions when choosing between them. This does not request automatic
idle retirement or another process-management layer in ModalAnyware.

**Native management UI and GraphQL self-management.** The human asked for
native management and for Koine to be "meta-managable via it's own GraphQL
interface", then clarified "native macos ui". The first version needs a
native macOS management UI, and Koine's management functions must also be
available through its own GraphQL API. The native surface means a UI, not an
additional public Swift management API. A CLI alone does not meet this
requirement. Management is subject to Koine's capability model; the client
approval workflow and initial management authority still need to be settled.

**Both capability-grant workflows.** The human chose "Both": clients can
request capabilities for approval or denial in Koine's native UI, and the
user can create grants in the UI and supply them to clients manually. Both
workflows are required; neither replaces the other. The corresponding
management functions also belong to the agreed GraphQL management surface,
subject to management authority. Grant lifetime and bootstrap of that
authority remain design questions.

**Grant lifetime.** The human specified: "grants are permanent until
explicitly revoked." Grants survive client and Koine restarts and do not
expire automatically. Credential storage and how revocation is observed by
an existing connection remain implementation/design questions; those choices
must honor the explicit grant lifetime.

**LLM skill set deferred.** When asked whether the LLM skill set should ship
with the first deliverable or wait until ModalAnyware is unblocked, the human
said "let's delay that". Defer the skill set until after the first deliverable;
it remains part of the broader product purpose, not a condition for unblocking
ModalAnyware. The first completion target covers the server, native desktop
provider, public GraphQL contract, capabilities and native management UI.

**Test seams agreed.** The human accepted the proposed testing boundaries:
the public GraphQL API for introspection, capability enforcement, partial
results, mutation authorization and grant persistence/revocation; the native
plugin boundary for compatibility between independently built server/plugin
versions across supported ABI versions; and real macOS workflows in isolated
TestAnyware VMs for both native-UI grant workflows and desktop discovery,
window focus, closed windows and missing OS permissions. Carry this agreement
into the design's test-seams section. Keep testing proportionate and exercise
shared behavior through these boundaries rather than duplicating it at every
internal layer.

**Requirements confirmed; design next.** The human confirmed the consolidated
requirements baseline and agreed to move to one design task next. That task
will settle the native extension ABI and independent upgrades, the local
GraphQL desktop contract, capability and management mechanics, and service
availability and OS permissions; it will reconcile the inherited specs and
PluginAnyware assumptions and carry the agreed test seams forward.
Implementation planning follows the design. Broader application discovery
and LLM skills remain deferred. This confirms the scope, completion target
and next step required by this leaf.

**Inherited URI naming rule applied.** The inherited contract already says
the placeholder URI scheme follows the project's eventual name. Koine is
that name, so the current glossary and URI decision use `koine://`. This
applies the existing naming rule; it does not select a new reference format
or rename the Machine core/abstraction terms. The inherited interface
examples and views are explicitly handed to `desktop-contract-k2` for
reconciliation with GraphQL and the native extension requirements.
