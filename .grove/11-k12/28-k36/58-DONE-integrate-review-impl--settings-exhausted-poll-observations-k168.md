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

## Decisions (running log)

- P2-1 is a real issue. The real backend exits 1 only on an unhandled failure.
  The repair is at `_guest_evidence_backend`, because every status-1 caller
  shares that seam. The latch and the refusal log keep the original status.
- P2-2 is a real issue. A clean menu mismatch now fails before any Escape or
  wait. A match keeps both.
- The narrowed k55 status rule is recorded in `ORDERING-PREFIX-RESULTS.md`.
  `ORDERING-TRANSPORT-RESULTS.md` stays as the finished k55 record.
- The prefix bytes do not change, so no new extraction is necessary.
- The repair earns no new review chain. It is bounded, it changes no design, and
  a detected mutation supports each behaviour.
- The final record passes all nineteen Taskfile checks, with 351 passing tests
  and no failure. None of its 4,565 subjects changed during the run.
  `check:docs` still reports only the two missing links in `CONTEXT-PLAN.md`,
  which this task did not touch.
