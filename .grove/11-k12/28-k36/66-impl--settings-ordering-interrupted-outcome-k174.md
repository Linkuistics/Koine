# settings-ordering-interrupted-outcome-k174

## Goal

Keep an interrupted attempt separate from unavailable evidence in the finite
caller's classification. This closes duty D181 of the reconciliation ledger.

## Context

Read `docs/verification/settings-activation/ORDERING-RECONCILIATION.md` and row
D181 of `ordering-reconciliation-evidence/duties.json`.

`classify_root` in `scripts/settings-ordering-sequence.py` builds `signals` only
from `scenario-signal-SIG` receipts and refused signal records. A local wait can
fail with a signal status and leave a receipt with outcome `interrupted` and no
signal record. The control "a failed settling wait after a clean held point
stops input and release without a trap" reaches that state. The classifier then
reports `unavailable`.

## Done when

- A control fails on the current source for a root whose first failure is an
  `interrupted` receipt with no signal record.
- The classifier reports that root as `interrupted`, and the control passes.
- The slot still cannot qualify. The repair changes no other classification,
  settlement or exit status. A control or a mutation shows each guard.
- Row D181 is `met`, with its source and control. `task check:settings-duty-ledger`
  and each affected harness check pass.

## Notes

This defect cannot produce an acceptance. The slot settles `unresolved` today.
The repair changes the reported outcome only. It establishes no Koine failure.
A changed caller reopens the affected checks before k54 consumes them. Decide
whether the change earns a review, and record the reason.
