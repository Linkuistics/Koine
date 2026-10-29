# settings-keepalive-scope-k93

## Goal
Resolve the explicit keepalive timing, failure-ordering and resource choices with
Antony after k92's independent review and every earned integration.

## Context
Read the current KEEPALIVE-DESIGN.md under docs/verification/settings-activation,
the spec's keepalive-coordination hold, ORDERING-EVALUATION-PLAN.md and current
capture/shared/click reports. K92 takes its charter's unresolved-scope branch;
its recommendation is not an approved scheduler or resource profile.

## Done when
- Present the concrete trade-offs in Required scope decision. Recommend permission
  to design one serialized command owner with visible scenario admission delays
  and deferred keepalive ticks, preserving whole-capture qualification before
  later input. Compare retaining the current constraints and the distinct weaker
  concurrent-capture/new-transport alternatives. Record Antony's actual answer;
  do not treat design review or silence as agreement.
- Resolve finite resource-profile design versus explicit acceptance of unbounded
  exposure. Recommend a finite profile that retains every produced original and
  partial, with explicit unavailable outcomes. No arbitrary caps, deletion,
  overwrite, downsampling or skipped required evidence. Explain that post-capture
  checks/streaming alone cannot bound the external producer.
- Any accepted timing amendment names what changes: scheduling delay and cadence,
  distinct from unchanged input order, explicit sleeps, poll counts and one-attempt
  transport. Preserve first-failure eligibility, exact VM identity and private
  roots. No native idle interval or collection availability is established.
- Update the existing verification/spec contracts and brief handoffs with the
  exact agreement and complete original-duty comparison. If a replacement is
  authorized for design, cut that precise design ahead of k89; its independent
  review/integrations and planning/implementation/earned review must precede
  k89/k81/k76 consumption. Do not create speculative implementation leaves.
- Keep every k89 file/environment/lifecycle/collection, k81 exec/one-shot,
  k76 adoption/signals/both held-pointer, k67 setup/title/liveness, k62 exact-prefix,
  k57 caller/containment and k54 readiness/freeze/runtime duty. Retain snapshot
  missing-tree/empty-AXValue, OCR substring, held-frame fallback and privacy limits.
  No guest, candidate, freeze, cap expansion or ancestor closure follows.

## Notes
The independent review and every earned integration of
settings-keepalive-coordination-k92 must finish before this decision. Review
findings live with their review, not in this charter. Existing source behavior
and all historical outcomes stay unchanged until an authorized implementation.
