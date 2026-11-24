# settings-clone-provenance-k181

**Reviews:** settings-clone-provenance-k180

## Goal

Try to break the clone provenance and declared executable binding before k54
freezes a subject. Report findings, and change no artifact.

## Context

The artifact is the commit of `settings-clone-provenance-k180`. Its source
changes are in `scripts/vm-guest-exec.py`, `scripts/vm-guest-exec-lib.sh`,
`scripts/vm-settings-scenario-lib.sh`, `scripts/settings-ordering-sequence.py`
and `scripts/check-settings-baseline.py`. Its record is
`docs/verification/settings-activation/ORDERING-PROVENANCE-RESULTS.md`.

The contract is the k180 task file, the first item of the k54 `Done when` and
finding P3-3 of the k58 review. Each guest transport of a slot must bind to the
exact spec path, its digest and its agent endpoint. A bare argv VM name is not
endpoint provenance. Each attempt must run the CLI and jq that the caller
declares. The change may add no guest read, wait, retry or wider tolerance.

Read the tagged upstream source with `git -C ../TestAnyware show v3.0.0:<path>`.
Do not edit that clone. The installed tool is
`/opt/homebrew/Cellar/testanyware/3.0.0/bin/testanyware`.

## Done when

- Each question below has an answer with evidence from the tagged source or a
  control.
  - Can a guest transport reach an endpoint other than the one that the
    recorded spec names, without a refusal?
  - Does the resolution of the state directory and the configuration file
    differ from the tagged CLI or app for any input that the harness accepts?
  - Can a changed, replaced or undeclared executable run an attempt that keeps
    a clean receipt?
  - Can a slot qualify, or a recurrence reject the repair, without a valid
    provenance record?
  - Does a new refusal turn a test-driver failure into a Koine failure, or stop
    the exact stop and the inventory of a clone?
  - Does a ledger row or the results record claim more than the source and
    controls support?
- Each finding names the file, the failing input and the consequence for k54.
