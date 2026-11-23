# settings-scenario-baseline-controls-k175

## Goal

Add reusable controls that pin the complete scenario to its protocol baseline
and pin the empty-field read. This closes duties D026, D029, D065, D099, D106
and D262 of the reconciliation ledger.

## Context

Read `docs/verification/settings-activation/ORDERING-RECONCILIATION.md`, the
section "Later ordinary assertions and the baseline" of
`ORDERING-PREFIX-RESULTS.md`, and the six ledger rows.

The baseline is commit `f019161b`. k62 and k163 compared the scenario with it by
reading. No suite, fixture or Taskfile entry cites it. The prefix check compares
the prefix only with the current scenario, so it misses a wait that changes in
both files.

A text search of the baseline scenario finds these waits, in seconds:
`2 6 3 2 8 1 1 1 1 1 2 4 4 2 30 5 5`. The k62 list does not name the first four.

`ordering-reconciliation-evidence/wait-mutations.txt` shows the present coverage.
Seven waits after the TextEdit quit changed, and 113 tests still passed. Other
waits fail a control only because a test depends on their literal text.

## Done when

- A control derives the ordered inputs, explicit waits, poll bounds and later
  assertions of the complete scenario. It compares them with a retained record
  of baseline `f019161b`.
- Each difference from the baseline has a named class and a cited reason. The
  four early baseline waits are each matched to current code or explained.
- A changed input, wait, bound or assertion in the scenario or a facade fails the
  control. A recorded mutation shows each failure.
- A scenario control omits AXValue at `shortcut-emptied` and proves that the read
  is unavailable and is not an empty value.
- The six ledger rows are `met`, or a precise new leaf owns the remainder.
  `task check:settings-duty-ledger` and each affected harness check pass.

## Notes

If the comparison finds a real change of input, wait or bound, do not adjust the
record to match. Stop and report it, because the protocol freezes those values.
The native empty AXValue stays an accepted limit. Add no read, wait or retry.

## Decisions (running log)

**The control runs both scenarios.** The real baseline script of `f019161b` runs
against a simulated CLI over the existing guest model. The current scenario runs
against the same model. A text comparison cannot see a facade's wait or bound,
but a run records them in order.

**Exhaustion cases pin the poll bounds.** Each case keeps one poll false, so its
stream holds the complete read and wait pattern of that poll. The curl, snapshot
and OCR limits do not appear as waits, so source statements pin them.

**The comparison found no real change of input, wait or bound on a passing
path.** The only event difference is on a failed menu comparison. The baseline
sent Escape and waited one second. The protocol forbids corrective input after a
failed assertion, and k168 removed it. The record keeps the baseline events, and
the classification names this removal.

**The four early waits are helpers.** They are `await_koine` (2), `await_settled`
(6), `expect_stopped` (3) and the TextEdit poll (2). Each one matches a current
statement in the wait table.

**No adversarial review leaf.** The control adds no scenario behaviour, and 19
recorded mutations show that it fails on each kind of change. The whole-harness
review k172 already challenged the scenario that this control pins. The remaining
limits are stated in `ORDERING-BASELINE-RESULTS.md`.
