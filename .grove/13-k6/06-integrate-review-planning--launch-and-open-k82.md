# launch-and-open-k82

**Integrates:** launch-and-open-k81

## Goal

Triage `launch-and-open-k81`'s findings against the implementation decomposition
produced by `launch-and-open-k29`. Apply the real ones so implementation starts
from a coherent plan.

## Context

- Read the findings in the review leaf and its own commit; this charter does
  not restate them as mandatory work.
- The artifact is k29's committed decomposition: the increment briefs and
  leaves under `launch-and-open-k6`, its node brief, and the root-level
  `alternate-team-signing-k80`.
- The workspace and Machine acceptance matrices, both cited ADRs and the root
  brief govern the plan. Review insertion shifted sibling positions while
  preserving their bodies and stable handles; the review's links use the
  shifted paths.

## Done when

- Each finding is classified as applied, rejected with a reason, or an explicit
  accepted trade-off. A finding is not mandatory merely because the review
  raised it.
- Accepted changes are reconciled across every affected leaf, brief, owner table
  and handoff, while preserving the agreed acceptance and live-pending rules.
- The task tree remains well formed and implementation follows this integration.
  Plan-only changes are checked by reading the resulting tree and diff; they
  do not imply runtime acceptance.

## Notes

This integration owns plan fixes. A change to the settled product design belongs
in a new design/review chain at the appropriate boundary, rather than being
quietly adopted as a planning correction.
