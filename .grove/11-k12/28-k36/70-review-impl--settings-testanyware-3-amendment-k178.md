# settings-testanyware-3-amendment-k178

**Reviews:** settings-testanyware-3-amendment-k177

## Goal

Try to break the TestAnyware 3.0.0 amendment before k54 freezes a subject. Report
findings, not fixes.

## Context

The artifact is the commit of `settings-testanyware-3-amendment-k177`. Its main
source change is in `scripts/vm-guest-exec.py`. Its record is
`docs/verification/settings-activation/ORDERING-TESTANYWARE-3-RESULTS.md`.

The contract is the k177 task file, the k36 brief and
`docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`. A failed,
partial or retried transport never becomes a clean result. The amendment may add
no read, wait, retry or wider tolerance.

Read the tagged upstream source with `git -C ../TestAnyware.gh-issue-13 show
v3.0.0:<path>`. Another session owns that worktree, so do not edit it or depend on
its working files. The installed tool is
`/opt/homebrew/Cellar/testanyware/3.0.0/bin/testanyware`.

## Done when

- Each question below has an answer with evidence from the tagged source or a
  control.
  - Does any v3.0.0 path report status 0 for a result that the harness must not
    accept, and that the amendment does not classify?
  - Do the exact stderr prefixes cover each such path, including the app route?
  - Does the typed exec check accept a record that it must refuse, or refuse a
    clean record that a real 3.0.0 agent can produce?
  - Do the release behaviours keep the input order, read counts, sleeps and poll
    bounds of the protocol?
  - Does SIGINT, SIGTERM or SIGHUP during an exec or a download leave a state that
    the adapter misreports?
  - Does a ledger row claim more than its changed source and controls support?
- Each finding names the file, the failing input and the consequence for k54.
- If a finding meets the threshold in `references/integrate-review.md`, cut an
  `integrate-review-impl` leaf before k54. Its body names this handle only.

## Notes

Start no guest, clone or golden build. Do not stop `testanyware-setup-dbf7834f`.
