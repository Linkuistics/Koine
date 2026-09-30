# launch-and-open-k81

**Reviews:** launch-and-open-k29

## Goal

Adversarially read `launch-and-open-k29`'s implementation decomposition of the
workspace launch-and-open increment before any of it runs. Produce findings,
not fixes.

## Context

- `launch-and-open-k29`'s commit, including its decisions log, the new
  increment nodes and leaves under `launch-and-open-k6`, the updated node
  brief, and the root-level `alternate-team-signing-k80`.
- What the cut must cover:
  - the node brief's `Done when` and "Design handoff";
  - k29's concrete design obligations;
  - `docs/specs/workspace-launch-and-open.md#acceptance`;
  - `docs/specs/machine.md#selection-acceptance`.

## Done when

Each finding is recorded with the leaf or brief it concerns, or the review
states that it found none. An integration step is cut only if a finding is worth
acting on.

## Notes

These are the doubts the producer could not settle alone:

- The charter asked that "the first leaf" deliver one launch path end to end.
  The cut makes that slice a six-leaf node. Is each leaf really verifiable on
  its own, or is the node a horizontal stack whose behavior appears only in its
  last leaf?
- Does every row of both acceptance matrices, and every node `Done when`
  bullet, have a named owner at each assigned seam? The owner tables in the
  node brief and `selection-acceptance`'s brief are the claim to test, against
  the specs rather than against each other.
- The first slice implements the full application input, including the
  installation-path constraint, so that the served SDL stays verbatim.
  Multiple-copy V acceptance then comes late. Is that a dead layer, or a
  justified trade?
- Conformance grows by root, with the design SDL restricted to implemented roots.
  Can that rule let a missing coordinate or description pass?
- Is the order right? The selection matrix runs before the remaining
  operations, and the launcher preparation before URL and path work. Does the
  protected-path probe precede every consumer, including `app-and-file-search`?
- The largest leaves are `workspace-launch`, `provider-selection` and the
  selection harness. Is any of them plainly more than one session at a genuine
  seam that the cut missed?
- Unsigned development and test hosts admit no shipped candidate. Does the cut
  keep the existing suites meaningful through a private seam without creating a
  public test API?
- The certificate-dependent alternate-team cases are placed in a late
  root-level HITL leaf, and the node may close with only them pending. Is that
  consistent with the root brief's rule for pending cases?
