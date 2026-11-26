# window-layout-k9

**Integrates:** window-layout-k8

## Goal

Triage the committed findings of `window-layout-k8` against the agreed window
layout acceptance, and apply the findings that earn repair.

## Context

- Read the findings from the review's own commit. Its durable report is
  `docs/verification/desktop-window-layout-design-review.md`.
- The reviewed producer is `window-layout-k2`. Its design, the root brief and
  the human's decisions in `plan-k1` define the contract.
- This leaf precedes `window-geometry-k3`, so implementation consumes the
  reconciled design.

## Done when

- Each finding is verified and classified under the integration procedure's
  acceptance and material-risk threshold.
- Each accepted repair is applied to the artifact and its affected citations
  and downstream task obligations.
- Relevant post-fix verification is recorded, with native acceptance limits
  preserved.
- Rejected findings and accepted trade-offs have explicit reasons.

## Notes

The findings belong to the review's commit, not this charter. This session
may reject a finding after inspecting its evidence. Substantial redesign
follows the integration procedure's producer-chain rule.
