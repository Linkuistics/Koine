# settings-nonexec-evidence-k64

**Integrates:** settings-nonexec-evidence-k63

## Goal

Triage the k63 review of the k60 shared evidence interface. Apply the real
findings to the adapter, its controls and its report. Finish before k61
migrates the complete scenario onto the interface.

## Context

Read the findings in the k63 leaf at its review commit. Their line numbers
refer to the k60 producer commit 1d9bd4c6. Then read `scripts/vm-guest-exec.py`,
`scripts/vm-guest-exec-lib.sh`, `Tests/scripts/vm-guest-exec.bats` and
`docs/verification/settings-activation/ORDERING-NONEXEC-RESULTS.md`. The
contract is `ORDERING-EVALUATION-PLAN.md` under
`docs/verification/settings-activation`. Read the parent brief chain. The
review read the TestAnyware v2.7.0 tag in the local checkout at
`../TestAnyware`.

The review ran no test, build, guest or reviewer. The graph server failed to
connect. K60 supplies no scenario migration, VM, signed subject or acceptance,
and this integration supplies none either.

## Done when

- Each k63 finding has a recorded disposition with its reason, read from the
  review's own commit.
- Each accepted change to the adapter has a control that fails before the
  change and passes after it.
- Each finding that stays a caller obligation reaches the report and the Done
  when of k61 or k57 as an explicit duty.
- `mise exec -- task check:vm-guest-exec` passes, with a fresh receipt that
  digests its subjects before and after the run.
- The existing pointer and resize checks still pass.

## Notes

Every original k56 duty survives. This integration does not migrate a caller.
