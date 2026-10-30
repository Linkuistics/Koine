# settings-keepalive-lifecycle-k99

**Reviews:** settings-keepalive-lifecycle-k97

## Goal
Independently inspect the proposed owner/worker lifecycle against the agreed
keepalive scope and the full k96 contract; report material findings without fixes.

## Context
Read the producer's committed diff, docs/specs/settings-keepalive-owner.md,
KEEPALIVE-DESIGN.md and ORDERING-EVALUATION-PLAN.md under
docs/verification/settings-activation, the binding product-spec hold and the
editable owner/lifecycle views. K97 is the first design slice of k96; k98 owns
numerical scheduling/deadline and enforceable resource completion. No coordinator
is implemented, resource-qualified or adopted. The producer's coverage and link
receipts are evidence with stated limits, not concurrency proofs.

## Done when
- Read the artifact independently against actual k93 scope and original duties.
  Challenge whether one owner can process failure/stop while children hold the
  dispatch domain, and whether eligibility is checked at actual dispatch.
- Inspect the distinction between submission, commitment and actual launch;
  stop races before/after each boundary; validation/delivery/publication order;
  and whether cancellation or a later clean result can conceal required failure.
- Challenge exact worker/owner identity, acknowledgement/exit/reap joins, final
  publication/receiver limits, prior latches, signals, inherited/orphan holders,
  collection-only takeover and both held-pointer cases. Find assumptions that
  allow false normal completion, later input or unproved containment.
- Check that the agreed sleep20 semantics, untouched collection order, originals,
  private roots and every downstream duty survive. Review the test-seam/control
  discrimination and correspondence of the diagrams to the spec.
- Distinguish an explicit k98 numerical/resource obligation from an inconsistency
  that already breaks this lifecycle slice. Do not accept the complete coordinator
  or select limits merely because its abstract profile inputs are mandatory.
- Report findings with source locations and consequences, or state none supported.
  If findings warrant integration, cut it before k98 with this review's handle;
  do not transcribe the findings as its charter. No competing in-session reviewer.

## Notes
Inspection only. Whole-design review still follows the completed profile before
planning, implementation and earned review/integration. K89/k81/k76 consumption,
readiness/freeze/runtime and every E/A slot remain held. All ancestors stay open.
