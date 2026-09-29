# launch-and-open-k54

**Integrates:** launch-and-open-k53


## Goal

Triage the findings of `launch-and-open-k53` against the workspace launch/open
design from `launch-and-open-k18`. Apply the real ones to the design artifacts,
so `launch-and-open-k29` cuts implementation from a settled contract.

## Context

- The review's findings live in its own leaf and commit, anchored to producer
  commit `16598f4fade8`. Read them there; this charter deliberately does not
  restate them.
- The artifact: `docs/specs/workspace-launch-and-open.md`,
  `docs/design/workspace-schema.graphql` and
  `docs/design/workspace-operations.graphql`, the launch/open rows of
  `docs/specs/workflow-providers.md`, the workspace note in `docs/specs/machine.md`,
  and the two workspace views in `docs/design/architecture/` with their captions.
- Some findings touch shared contracts rather than only the workspace spec: the
  control-receipt rule in `machine.md#additional-capability-requirements`, and
  the grant-disclosure ownership in `workflow-providers.md`. Any change there
  must stay consistent with `docs/adr/provider-authority-follows-effects.md`.
- The node brief's `Design handoff` and `launch-and-open-k29`'s concrete design
  obligations restate parts of this design. Reconcile them with whatever changes.

## Done when

- Each finding is classified as applied, rejected with a reason, or a stated
  accepted limit. None is mandatory merely because the review raised it.
- Accepted changes are consistent across the spec, SDL descriptions, examples,
  trace rows, views, node brief and the k29 handoff. `task design:workspace-check`
  and `task check:docs` pass. Re-render the views with `task design:workspace-render`
  if their sources change.
- A native limit this design would now state, or any new consent, entitlement or
  signing posture, has been raised with Antony before it is relied on.

## Notes

The review found no reason to change the architecture. Substantial redesign
belongs in a new design review chain beside this leaf, not here. Platform
predictions remain acceptance work for the assigned seams; the integration
settles what the design promises and which seam observes each prediction.
