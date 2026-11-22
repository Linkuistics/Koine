# settings-exhausted-poll-observations-k168

**Integrates:** settings-exhausted-poll-observations-k167

## Goal

Triage the committed k167 review against the failure-observation contract and
apply the bounded repairs that meet the acceptance and material-risk threshold.
Finish before k164 consumes the shared scenario.

## Context

Read the findings from the review's own commit, including
`docs/verification/settings-activation/ORDERING-EXHAUSTED-POLL-REVIEW.md`.
Re-derive them against k166 `9f5126aa`, k165 `bd8fa49f`, the current source,
the k36 brief and `ORDERING-EVALUATION-PLAN.md`, especially lines 187–193.
The review's task body is a pointer, not the integration's work list.

## Done when

- Classify each finding against the source and agreed contract. Apply the
  necessary bounded repairs and accept any genuine trade-off visibly.
- Use the existing simulator and fixture seams for meaningful controls. Show
  that the controls detect their faults, then run the appropriate reusable
  Taskfile checks and retain the verification evidence.
- Preserve successful input, read counts, waits, bounds, signal statuses,
  private originals and the first unavailable reason. Keep test-driver failure,
  Koine failure and assertions NOT RUN distinct.
- Reconcile `ORDERING-PREFIX-RESULTS.md` and the k164/k57 handoff with what
  the source and controls deliver. If leading scenario bytes change, extract
  and check the prefix again. Decide whether any substantial changed work
  earns a new review; a routine repair does not itself require another chain.

## Notes

This is one adjacent sibling because it directly unblocks the shared
failure-observation duty before the existing controls and reconciliation
owners consume it. No VM, clone, signed subject or runtime slot is authorised
here. k57 retains complete pre-runtime reconciliation; k54 retains freeze and
runtime. No retry, wait, empirical budget or acceptance amendment is granted.
