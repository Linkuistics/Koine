# desktop-delivery-k3

## Goal

Plan the first working Koine desktop deliverable from the approved contract.
Grow a task tree of small, independently useful increments that together let
ModalAnyware obtain a grant, discover an application's windows and focus one
through the real native provider and loopback GraphQL boundary.

## Context

The human approved the complete design in `desktop-contract-k2`. Read
`docs/specs/machine.md`, `docs/design/desktop-schema.graphql` and
`docs/design/desktop-operations.graphql`. The root brief cites the authoritative
ADRs and client/provider context. `desktop-contract-k2`'s running log records
the accepted trade-offs; do not reopen them without a concrete conflict.

There is no implementation yet. The schema and five example operations were
validated as design artifacts, not against a server. The signed application,
native window identity and old/new plugin binary combinations still require
the acceptance evidence described in the spec. Diagram exports were inspected;
browser layout was unverified because no browser was connected.

## Done when

- The tree covers the approved first deliverable, including the resident native
  UI/server, both grant workflows, live revocation, introspection, native Swift
  provider compatibility/loading and the discover/list/focus path.
- Each implementation leaf is a narrow working increment with concrete inputs,
  completion conditions and verification through an agreed seam. Prefer usable
  paths over layers that remain inert until later leaves land.
- The three seams remain the public GraphQL API, independently compiled native
  host/plugin binaries, and signed UI/desktop workflows in isolated TestAnyware
  VMs. Preserve acceptance cases for process/window identity, capability versus
  OS-permission denial, mutation preflight and revocation ordering.
- Dependencies and unresolved implementation evidence are explicit. In
  particular, plan how the native identity guarantee and supported binary/OS
  baseline are established before claiming the desktop path ships. An
  implementation limitation must not silently weaken the approved contract.
- ModalAnyware's public-contract handoff is identifiable and verifiable. Its
  required adapter/spec changes are owned by that repository; do not silently
  edit sibling projects as part of Koine implementation.
- All required work has a home in the tree, while the deferred wider purpose
  remains outside this first deliverable. No implementation is performed by
  this planning leaf.

## Notes

The human selected a shared resilient Swift framework, one resident Koine
application and transferable bearer credentials with live revocation. Providers
are trusted native Swift dylibs; PluginAnyware and APIAnyware are not assumed
dependencies. Preserve the spec's limits: no live replacement, automatic replay,
transactional rollback, engine graph cache or cross-provider atomic snapshot.

Choose concrete implementation libraries/build tooling from verified primary
sources when the choice is needed. A root `Taskfile.yml` was suggested and the
workflow-tool choice remains unconfirmed; no Taskfile currently exists. Carry
that context forward rather than repeating the suggestion as if it were new.
Do not automatically add research, prototype or review stages.

## Decisions (running log)

**Increments are stages of this tree, not separate groves.** The planning
procedure asks for one grove per working increment, but only the driver creates
a grove and one working tree holds one `.grove/`. Each increment is therefore a
stage at the root: the first a node with its own brief and `Done when`, the
rest `planning` leaves that become nodes when reached.

**Six increments, ordered by dependency and then risk.** Authenticated
endpoint; resident application with manual grants; native provider
contribution; desktop path; grant enrollment; release acceptance and handoff.
The application precedes the desktop path because Accessibility attribution
needs the signed resident process. Enrollment follows the desktop path because
the manual workflow already lets ModalAnyware proceed and window identity is
the larger unproven claim; it depends only on stage 2, so moving it earlier is
free. Rejected: a headless server product or unauthenticated bootstrap to make
an earlier slice demonstrable — `Query.koine` requires a grant, so the smallest
honest slice includes the in-process console principal and `koineCreateGrant`.

**Only the first increment is cut into impl leaves.** Later stages' leaves
depend on choices not yet made (GraphQL/HTTP/store libraries, application build
tooling, signing identity). Their charters list the required behaviour,
seams, acceptance cases and open questions so all required work has a home.

**Evidence obligations have owners.** Native window identity: first leaf of
`desktop-path-k9`, with a stop-and-ask rule if only a private API upholds the
guarantee. Binary/OS baseline and old/new pairs: the compatibility leaf of
`native-provider-contribution-k8`. Signed-build behaviour and the supported
matrix: `release-acceptance-handoff-k11`. Signing identity and application
build tooling are human questions owned by `resident-app-manual-grants-k7`.

**Schema grows with behaviour.** Each stage serves only fields it implements;
the design SDL is the target checked at stage 6, not a stub list.

**No review chain cut.** The human asked that review stages not be added
automatically; the decomposition is lazy, and reordering or recutting a stage
charter is cheap.
