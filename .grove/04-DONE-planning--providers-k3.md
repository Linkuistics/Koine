# providers-k3


## Goal

Turn the agreed workflow requirements into small, independently verifiable
increments that deliver the Koine provider support. Establish which scoped
design or native-evidence work is needed before cutting implementation leaves.

## Context

- `docs/requirements/modaliser-workflows.md` is the agreed scope and acceptance.
- Resolve `plan-k1` for the human's decisions and configuration evidence.
- Resolve `plan-k2` for the requirements review; incorporate any integration
  that the review inserted before this leaf.
- Resolve `plan-k4` for the integrated findings and narrowed baseline: no
  Zellij or Neovim support; VS Code screen workflows are deferred while its
  launcher stays. Do not commission design or acceptance for the deferred work.
  Status-item and Dock menus are also deferred.
- `docs/specs/machine.md` and its cited ADRs define the existing GraphQL,
  authorization, reference and native binary contracts.
- `Taskfile.yml` is the entry point for reusable checks and the existing public,
  native and VM test seams.

## Done when

The tree contains the next concrete, independently useful work, with child
charters tying every accepted workflow family to a public capability or an
explicit client responsibility. The order resolves concrete design and native
evidence questions before dependent implementation. The root brief explains
the decomposition and its acceptance coverage; uncertainty that cannot yet be
phrased stays in the brief rather than in speculative implementation leaves.

## Notes

This is a larger workstream, not a one-sitting implementation. Provider count
and boundaries are deliberately unsettled. Plan vertical increments across the
native plugin and public GraphQL seams, so each can demonstrate useful behavior
without ModalAnyware. Do not partition solely by Swift file or horizontal layer.

Questions already precise enough to place include:

- What evidence is needed for dynamic/context-menu discovery, item validation,
  explicit opening and cleanup under the existing public native boundary?
- How should app-targeted input and multi-request interactions preserve target,
  modifier ownership and interruption behavior within the existing framework?
- How will independently grantable input, menu invocation and window focus fit
  the current per-provider capabilities? Assign authority to every effect,
  including explicit menu opening, file/URL opening and integration setup.
- What inactivity bound, cleanup ownership and crash recovery satisfy `plan-k4`'s
  decisions without admitting new actions under a revoked grant? Cover all
  explicitly opened menus as well as Dia; only owned modifier releases may
  reach the newly active app, with no Escape/cancel or focus reclamation.
- Which reusable desktop, launch/search and pointer/media operations serve
  multiple configured workflows, and which app/tool integrations need their own
  native contract or prerequisite setup?
- How will nested iTerm/herdr instances, list state and label-placement geometry
  be demonstrated through the three agreed seams?

Carry forward `plan-k2`'s design questions: distinguish missing dependencies
from stale targets within the closed `koine-desktop/1` error vocabulary; decide
whether passive menu population meets read purity; define screen-point targets
that hit another app or a client overlay; allocate clipboard writes explicitly
between Koine and the client; and define declarations of expected client
presentation without treating display labels as authenticated identity. iTerm
is the required terminal-host baseline. An incompatible contract version change
is Antony's decision.

Use dedicated test accounts/data for Signal, Slack, Telegram, Messages and Mail
in isolated VMs. Missing accounts or data leave the affected acceptance pending;
they are not accepted untested limitations. Include account provisioning in the
acceptance preparation where needed, without using Antony's live desktop.

Reconcile the served spec's Scope and the server-boundary ADR with the agreed
launch, application/file search and prerequisite discovery/setup extension.
Determine whether terminal/herdr context needs shared identity across providers;
the requirements do not decide that. Preserve the observed geometry limitation
in the source as evidence to investigate: herdr labels combine tool layout with
host geometry, and the inherited probe can misplace labels when other host
splits coexist. Reproducing that bug is not acceptance.

Commission a design leaf where an API or provider boundary needs an agreement
point, and a focused prototype/evidence leaf where native feasibility is the
uncertainty. Reuse the current framework unless a concrete requirement proves
it insufficient. Keep the spec and ADR sets current as design settles.

Do not re-interview the workflow scope, menu choices or test seams. Do not
implement or restart Modaliser or ModalAnyware. Tests must use isolated VMs for
real native effects; missing integration prerequisites must not be passed off
as successful empty results. Record any later proposed scope change explicitly
rather than silently reducing the agreed baseline.

## Decisions (running log)

**Stages are increment nodes in this grove.** The planning procedure asks for a
separate grove per working stage. Grove offers one tree per working tree, and
the root brief charters this grove to deliver all of the agreed support. Each
increment is therefore a separate node here. A node leaves the product working,
has its own charter and delivers behavior verified through the three seams.

**Cross-cutting architecture comes first, at the root.** Every new mutation's
authority depends on how input, menu invocation and window focus become
separately grantable. Today a capability is a provider's own `read` or
`control`, and a field taking another provider's reference also needs that
owner's capability of the same class. Error classification, scope
reconciliation and clipboard allocation cut across increments too.
`provider-architecture` settles these once, before any increment designs its
API. The interaction lifecycle (cleanup ownership, inactivity bound, crash
recovery) serves only Dia and explicitly opened menus. It is scoped to the
`held-interactions` increment and reused by `context-menus`.

**Evidence leaves are `design` leaves with one bounded question.** `prototype`
is HITL, and its deliverable is a human's reaction. Native feasibility is
evidence for a decision. The earlier Koine grove produced its native evidence
as `design` leaves, and it nested more than thirty levels deep when evidence was
allowed to chase guarantees public API cannot give. Each evidence leaf here
names the decision it feeds, and states that an unavailable guarantee becomes
an explicit accepted limit or an escalation, not a deeper evidence chain.

**Increment order.** `launch-and-open` is the pathfinder. Its native risk is the
lowest, and it exercises adding provider work end to end: build, in-app
approval, schema conformance, the authority trace, a contract-driven client
and VM acceptance. Next come search, window layout, then pointer and media,
the other low-risk desktop capabilities. App-targeted input follows,
then menu-bar discovery and invocation. Held interactions come after them,
designed with both Dia and opened menus in view. Context menus reuse that
lifecycle. iTerm precedes herdr, which is addressed through the host. Account
provisioning is HITL and depends on human-supplied accounts, so its acceptance
is consolidated late and does not stall AFK work. Its shortcuts are implemented
in `app-input` with account-dependent acceptance recorded as pending. A final
leaf completes the baseline trace.

**Each later increment gets evidence/design leaves now and a trailing
`planning` leaf.** The planning notes already state its evidence and design
questions precisely, so they are leaves rather than horizon notes.
Implementation leaves depend on the settled API, so a `planning` leaf in each
node cuts them after design. A design session does not cut implementation.

**This decomposition gets a `review-planning` leaf, run next.** Several months
of increments build on it. The review is inserted ahead of
`provider-architecture` so that its integration can reshape the tree before
design starts. With review scheduled, this session spends no in-session
reviewer.
