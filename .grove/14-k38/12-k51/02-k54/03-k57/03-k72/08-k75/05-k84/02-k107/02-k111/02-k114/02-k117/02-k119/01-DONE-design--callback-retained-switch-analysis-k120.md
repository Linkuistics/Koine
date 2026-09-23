# callback-retained-switch-analysis-k120


## Goal
Make retained B across independently witnessed C input after callback return a
checkable causal transcript, distinct from switching before in-callback validation.



## Context
Consume k116's analyzer and k118's route-only evidence. Current `after-sample`
means M-return → C input → validation/capture; it cannot grade the later switch.

## Done when
- Define an explicit post-return observation and after-callback schedule without
  treating a callback's pre-return log as evidence that it has returned.
- Extend the existing bounded analyzer and raw synthetic corpus for both public
  pairs and both constructions. Require return → C injection/receipt → retained
  validation of the same continuously held B token.
- Falsify missing/wrong C receipts and acknowledgments, early/unobserved return,
  early release, replacement identity and failed retained validation. Verify
  cross-process arrival permutation changes no result.
- Run focused checks and the frozen corpus through Taskfile; preserve exact exits
  and itemwise input digests. Update contract, assessment and served visual view.
- Keep all native recorder, gate, process-exit and freeze obligations in k121/k122;
  this deliverable is synthetic instrument evidence only.

## Notes
No native execution or source-freshness conclusion is required or established by
this child. Existing analyzer/VM seams remain; no product mechanism is adopted.

## Decisions (running log)

- Preserve `after-sample` as the within-callback switch. Add `after-callback`
  and one `returned` observation to the version-1 vocabulary; freeze exact
  analyzer bytes because older analyzers reject the new schedule/event.
- A native `exit` record can precede actual return. Require `returned` from an
  audited enclosing loop boundary before C injection, not a callback-body log
  or queued worker. k121 owns demonstrating that producer and its nesting;
  the offline checker can only validate the declared causal edges.
- The existing ownership ledger already requires retention through the same
  captured token and final balanced cleanup. Reuse it after the C receipt;
  don't add a second identity rule or a clock-based ordering mechanism.
- Use executable disproof for this bounded behavioral change: new controls
  first failed against the unsupported schedule; the completed checker passes
  67 tests and the frozen corpus matches all 65 outcomes. Four scratch mutants
  expose omitted ordering/identity checks. This answers the changed-code doubt
  more directly than another read of the same logic; no in-session reviewer is
  used and no native producer correctness is claimed.
