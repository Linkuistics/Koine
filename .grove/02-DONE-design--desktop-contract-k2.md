# desktop-contract-k2

## Goal

Design the complete desktop path that unblocks ModalAnyware, using the
requirements confirmed in `plan-k1`. Deliver a coherent current spec and the
minimum ADR set needed to explain its decisions, ready for implementation
planning and the client's GraphQL handoff.

## Context

Read `plan-k1`'s running decision log for the interview and accepted trade-offs.
The root brief is the agreed requirements baseline, including the test seams.
The carried `docs/specs/machine.md` and architecture views still contain
query/execute wire examples and shared plugin-framework assumptions that
conflict with that baseline. Reconcile them; do not preserve a second public
wire API just because the inherited examples use one.

The current boundary decisions are in
`docs/adr/koine-server-and-native-providers.md` and
`docs/adr/machine-references-as-uris.md`. The glossary retains Machine as the
core/abstraction term; the inherited URI naming rule now gives `koine://`.

For client context, consult the relevant contracts in
`../ModalAnyware/docs/specs/architecture.md`, `native-plugins.md` and
`configuration-ui.md`. PluginAnyware's current entry-module contract is in
`../PluginAnyware/docs/specs/plugin-framework.md`; it is not an assumed Koine
dependency. The root brief points to Modaliser's existing desktop behavior.

## Done when

- The current spec describes one first-deliverable path: a client connects
  locally, obtains a grant through either agreed workflow, resolves an
  application from its process identity, lists its windows and focuses one.
  It covers disappearing windows and distinguishes capability refusal from
  missing Koine OS permission. The native macOS UI and GraphQL management
  interface are both included.
- The native extension contract explains schema/resolver contributions,
  independently distributed Swift binaries, ABI compatibility and version
  negotiation, unsupported versions, and the trust/loading boundary.
  Swift dylibs are the proposed mechanism, not an already selected ABI.
  Specify what remains compatible when either side upgrades; independent
  upgrades do not by themselves require unloading or replacing live code.
- The GraphQL contract covers full introspection and code generation,
  schema-name composition, opaque references, errors and meaningful
  nullability. Mutations use valid GraphQL mutation placement. Capabilities
  apply to contributed operations and alternate paths to the same resource,
  including aliases and fragments. Read denial follows the agreed standard
  error propagation; every requested mutation action is authorized before
  any action begins, without promising runtime rollback.
- The capability design defines initial provider read/control grants,
  authenticated presentation of the Koine-granted capability set, both
  grant workflows, persistent storage and explicit revocation, including
  existing connections and in-flight work. It explains how management
  authority is bootstrapped without letting a requester approve itself.
  Plugin trust and client authority are separate questions; client grants
  must not be presented as isolation for native plugin code.
- Local endpoint discovery, loopback-only HTTP and OS-managed availability
  are concrete. Choose residence or OS socket activation with evidence for
  permission ownership, provider observation needs and keyboard interaction
  responsiveness. ModalAnyware does not acquire Koine's OS permissions or
  take ownership of its process lifetime.
- The agreed test seams are carried into the spec, with checkable acceptance
  cases for the public GraphQL API, independently built compatible native
  binaries, and real UI/desktop workflows in isolated TestAnyware VMs.
- Specs, ADRs, glossary, overview and relevant architecture views agree.
  Identify the authoritative Koine contract and the ModalAnyware handoff,
  including whether a Koine-owned Swift client helper is needed alongside
  standard GraphQL tooling. Describe any required sibling-repository changes
  clearly; do not silently rewrite another project's contract.
- The resulting design reaches its agreement point before implementation
  planning. Record any remaining product decision explicitly rather than
  silently weakening an accepted requirement.

## Notes

Synthesize the interview; do not repeat it. Consult the human only for a new
trade-off that the agreed requirements do not settle. Swift-only plugin
authoring is the initial scope; keep APIAnyware separate. Broader discovery,
non-running application inspection and the LLM skill set are deferred.
Open-source licensing/distribution is undecided, not a prerequisite for this
deliverable. Do not automatically add research, prototype or review stages.

Preserve the inherited absence of an engine graph cache, automatic refresh
and retry; provider-owned OS observation state is allowed. Do not imply that
one GraphQL operation establishes an atomic snapshot across providers.

Primary references consulted during requirements, to verify against the
concrete design rather than treating as an implementation selection:

- Swift ABI, module stability and resilience:
  https://www.swift.org/blog/library-evolution/
- Native loading and library validation:
  https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.cs.disable-library-validation
- GraphQL errors and non-null propagation:
  https://spec.graphql.org/September2025/#sec-Handling-Execution-Errors
- OS service/socket activation:
  https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html

A root `Taskfile.yml` has been suggested for concrete build and verification
commands when implementation starts; the workflow-tool choice is unconfirmed.

## Decisions (running log)

**ABI proposal awaiting preference.** The visual discussion compares a small
C-compatible, versioned native boundary behind a Swift authoring SDK with a
shared resilient Swift framework. Both use Swift dylibs; the former keeps Swift
and GraphQL-library types outside the compatibility promise, while adding an
adapter. The human has been asked which trade-off they prefer; no answer or
ABI agreement has been recorded. The current spec's C-compatible contract is
explicitly a proposal, not a settled decision.

**Enrollment proposal clarified during bounded review.** One in-session
adversarial reader examined grant bootstrap and mutation authorization ordering.
Its three findings were actionable ambiguities in the proposed contract, not a
change to the accepted requirements: admission must distinguish active grants,
the local console and anonymous enrollment; own-request polling must continue
across approval/denial; and duplicate digests must not create multiple grants.
The proposal now states those cases and a uniqueness/idempotency rule. No second
review or extra Grove stage has been introduced. The human's design agreement
is still pending.

**Shared resilient Swift framework selected.** The human chose "Shared
resilient Swift framework" for the plugin binary interface. Native Swift
providers and Koine share a binary framework built with library evolution and
module stability from its first release. Its published types and protocol
requirements are part of the compatibility promise. The C-compatible function
table and private-SDK proposal is not selected. Update the spec, ADRs, glossary
and diagrams to this choice; the remaining application-composition and authority
proposals still need agreement.

**One resident application selected.** The human chose "One resident Koine
application (recommended)": the native management UI, server and providers
share one process and OS-permission owner. Management authority stays in
process instead of bootstrapping a separate privileged UI connection. Closing
the management window leaves the service and provider observation running;
clients do not own Koine's lifetime. This settles the process composition.

**Bearer credentials with live revocation selected.** The human chose
"Bearer credentials with live revocation (recommended)". One transferable
opaque secret identifies a persistent grant; clients keep it in Keychain or a
protected file, and Koine checks the live grant on every request. Possession of
the secret confers its grant; client-key binding and request signing are not
selected. The draft's admission/revocation ordering and remaining contract
details will be included in the final whole-design agreement.

**Complete desktop contract approved.** The human answered "approved" to the
final contract presented in `docs/specs/machine.md` and the visual overview.
This settles the complete design, including GraphQL process/window identity,
the precise revocation/admission boundary, the client-owned adapter and the
operational policies. Implementation planning is now authorized. Native
platform behavior and binary compatibility remain implementation acceptance
obligations, not outcomes established by this design session.
