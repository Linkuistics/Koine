# settings-exec-evidence-k59

**Integrates:** settings-exec-evidence-k58

## Goal

Triage the k58 review of the k55 strict guest-exec adapter. Apply the real
findings to the adapter, its controls and its report before k56 migrates the
shared scenario onto it.

## Context

Read the findings in the k58 leaf at its review commit. Their line numbers
refer to the k55 producer commit 9ad206f1. Then read `scripts/vm-guest-exec.py`,
`scripts/vm-guest-exec-lib.sh`, `Tests/scripts/vm-guest-exec.bats` and
`docs/verification/settings-activation/ORDERING-TRANSPORT-RESULTS.md`. The
contract is `ORDERING-EVALUATION-PLAN.md` under
`docs/verification/settings-activation`. Read the parent brief chain.

The review ran no test, build, guest or reviewer. The graph server failed to
connect. K55 supplies no ordinary migration, VM, signed subject or acceptance,
and this integration supplies none either.

## Done when

- Each k58 finding has a recorded disposition with its reason, read from the
  review's own commit.
- Each accepted change to the adapter has a control that fails before the
  change and passes after it. This applies in particular to P2-1, where the
  current control passes with the lock removed.
- The report states the adapter's actual exit contract and its interruption
  and orphan limits.
- H-1 reaches k56's Done when as an explicit duty, or the adapter gains the
  operations that it names.
- `mise exec -- task check:vm-guest-exec` passes, with a fresh receipt that
  digests its subjects before and after the run.
- The existing pointer and resize checks still pass.

## Notes

Do not change historical bytes, closed caps or held causal slots. Do not start a
VM or freeze a subject. K56 and k57 stay live behind this leaf. No ancestor
closes here.
