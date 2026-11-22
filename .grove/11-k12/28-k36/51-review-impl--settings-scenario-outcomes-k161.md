# settings-scenario-outcomes-k161

**Reviews:** settings-scenario-outcomes-k67

## Goal

Try to break the positive setup, the title audit and the outcome classes of the
complete ordinary Settings scenario. Report findings, not fixes. Find the
commit of the reviewed leaf from its handle, and read that diff against the
current source.

## Context

The artifact is these files:

- `scripts/vm-verify-menu-bar.sh`, the scenario.
- `scripts/vm-settings-scenario-lib.sh`, its strict layer.
- `scripts/vm_exec_reads.py`, the six new checked reads.
- `scripts/vm-window-evidence-lib.sh`, the deferred count poll.
- `Tests/scripts/vm-settings-scenario.bats` and
  `Tests/scripts/fixtures/settings-scenario-backend.py`, the scenario controls.
- The new controls in `Tests/scripts/vm-window-evidence.bats`,
  `Tests/scripts/vm-sysevents-evidence.bats`,
  `Tests/scripts/vm-exec-one-shot-evidence.bats` and
  `Tests/scripts/vm-exec-one-shot-host.bats`.
- `docs/verification/settings-activation/ORDERING-OUTCOMES-RESULTS.md` and its
  `ordering-outcomes-evidence/` directory.

The contract is the k67 task file and the k36 brief. It also includes the
archived k53, k56 and k61 charters in
`docs/verification/grove-tree-structure/original-briefs/`. The ordering
protocol is `ORDERING-EVALUATION-PLAN.md`. Its sections "Matched observable
setup" and "Input and observation qualification" are the closest clauses.
`ORDERING-REVIEW.md` explains the setup, title and liveness amendments.

## Done when

- Each doubt below has a finding, or the reviewer records that no defect was
  found for it.
- Each finding names the file and line, a concrete failure scenario, and the
  contract clause that it breaks.
- Real controls or source reading support the findings. A simulated pass is
  not evidence of guest behaviour.
- If a finding is worth acting on, cut `integrate-review-impl` with the bare
  stem. Place it where `pick` reaches it next, as the Grove decomposition
  procedure directs.

## Notes

Examine these doubts:

1. Do the System Events oracles observe what the protocol names? Judge each
   AppleScript against the System Events dictionary and Apple's accessibility
   documentation. Ask whether a closed menu, a dialog or a sheet could read as
   clean, or a clean state as failed.
2. Can any read report a missing value, a partial enumeration or a script error
   as a negative state?
3. Does the deferred count poll keep the reads, the waits and the bounds of the
   existing poll? Can any input run between a deferred exhaustion and its
   receipt?
4. Does each failed return keep the protocol's order and distinctions? Look at
   the liveness, the observer, the window list, the screenshot, the closed menu
   and the receipts. Separate a recurrence, a lost process, another assertion
   failure and unavailable evidence.
5. Does the title audit judge the same list as the front predicate, for every
   return?
6. Does the positive setup use the zero-count list and the recorded PID and
   frame? Does it add a wait or input, and does any failed setup still open a
   menu?
7. Do the successful paths keep every earlier action, read count, wait and
   bound? Only the observations that the protocol requires may join them.
8. Can any new control pass whatever the scenario does? Look at the simulated
   backend's flags and the red record.

The k62, k57 and k54 duties stay with their owners. The review creates no VM,
candidate or freeze.
