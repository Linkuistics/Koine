# settings-keepalive-lifecycle-k99

**Reviews:** settings-keepalive-lifecycle-k97

## Goal
Inspect the proposed owner and worker lifecycle independently against the agreed
keepalive scope and the full k96 contract. Report material findings without fixes.

## Context
Read the producer's committed diff and docs/specs/settings-keepalive-owner.md.
Read KEEPALIVE-DESIGN.md and ORDERING-EVALUATION-PLAN.md under
docs/verification/settings-activation. Read the binding product-spec hold and the
editable owner and lifecycle views.

K97 is the first design slice of k96. K98 owns
numerical scheduling and deadline policy and enforceable resource completion. No
coordinator is implemented, resource-qualified or adopted. The producer's coverage
and link receipts are evidence with stated limits, not concurrency proofs.

## Done when
- Read the artifact independently against the actual k93 scope and the original
  duties. Challenge whether one owner can process failure or stop while children
  hold the dispatch domain. Challenge whether the owner checks eligibility at
  actual dispatch.
- Inspect the distinction between submission, commitment and actual launch.
  Inspect the stop races before and after each boundary. Inspect the validation,
  delivery and publication order. Decide whether cancellation or a later clean
  result can conceal a required failure.
- Challenge exact worker and owner identity and the acknowledgement, exit and reap
  joins. Challenge the final publication and receiver limits, prior latches and
  signals. Challenge inherited or orphan holders, collection-only takeover and
  both held-pointer cases. Find assumptions that allow false normal completion,
  later input or unproved containment.
- Check that the agreed sleep20 semantics, the untouched collection order, the
  originals, the private roots and every downstream duty survive. Review the
  test-seam and control discrimination. Review the correspondence of the diagrams
  to the spec.
- Distinguish an explicit k98 numerical or resource obligation from an
  inconsistency that already breaks this lifecycle slice. Do not accept the
  complete coordinator or select limits merely because its abstract profile
  inputs are mandatory.
- Report findings with source locations and consequences, or state that none is
  supported. If findings warrant integration, cut it before k98 with this review's
  handle. Do not transcribe the findings as its charter. Spend no competing
  in-session reviewer.

## Notes
Inspection only. Whole-design review still follows the completed profile, before
planning, implementation and earned review and integration. K89, k81 and k76
consumption, readiness, freeze, runtime and every E/A slot remain held. All
ancestors stay open.
