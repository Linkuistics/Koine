# settings-scenario-adoption-k159

**Reviews:** settings-scenario-adoption-k76

## Goal

Try to break the strict adoption of the complete ordinary Settings scenario.
Report findings, not fixes. Find the commit of the reviewed leaf from its
handle, and read that diff against the current source.

## Context

The artifact is these files:

- `scripts/vm-verify-menu-bar.sh`, the scenario.
- `scripts/vm-settings-scenario-lib.sh`, its strict layer.
- `Tests/scripts/vm-settings-scenario.bats` and
  `Tests/scripts/fixtures/settings-scenario-backend.py`, the new controls.
- The adapted suites `Tests/scripts/vm-verify-start.bats`,
  `Tests/scripts/vm-window-resize.bats` and `Tests/scripts/vm-input-evidence.bats`.
- `docs/verification/settings-activation/ORDERING-SCENARIO-RESULTS.md` and its
  `ordering-scenario-evidence/` directory.

`ordering-scenario-evidence/scenario-before.sh` is the pre-adoption scenario.
Compare the adopted scenario with it line by line.

The contract is the k76 task file, the k36 brief and its shared harness
obligations. It also includes the archived k71 and k66 charters in
`docs/verification/grove-tree-structure/original-briefs/`. Each helper report
under `docs/verification/settings-activation/ORDERING-*-RESULTS.md` holds a
caller table and adoption duties. The ordering protocol is
`ORDERING-EVALUATION-PLAN.md`. The ADR
`settings-harness-takes-no-keepalive-captures` applies.

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

1. Can any transport still bypass the root? Look for dynamic calls, functions
   from the shared libraries, traps and paths that run before
   `settings_begin` or after the end.
2. Does each strict call keep the legacy action, read count, wait and poll
   bound? Does it keep the failure message? The adoption names some departures
   deliberately. Judge each against the contract: the failure-path list, the
   added protocol reads and the port loop.
3. Do the exit statuses and the receipts separate three outcomes? These are a
   Koine failure, a test-driver failure and an assertion that did not run.
4. Does the INT, TERM and HUP handling work under macOS `/bin/bash` 3.2? Look
   at signals inside command substitutions and inside redirected calls. Also
   look at a signal while the backend holds the writer lock, and while a
   subshell may continue.
5. Can a release or other input follow a signal or a latch? Check both
   held-pointer cases and the reported held-pointer state against the receipts.
6. Can any new control pass whatever the scenario does? Look at the simulated
   backend, the fault list, the caller inventory pattern and the signal
   fixtures.
7. Do the exclusive writes, the work directory and the secret-bearing root meet
   the privacy and retention duties?

The k67, k62, k57 and k54 duties stay with their owners. The review creates no
VM, candidate or freeze.

## Decisions (running log)

- 2026-11-22: Inspect producer commit `83175695a0923b3c6498e1b56ecba0069f850599`
  and the current source. This review runs no tests, builds, lint, format or
  guest commands. Source derivations support its findings. Retained control
  transcripts supply historical evidence only.
- 2026-11-22: The conditional physical-helper calls lose failed sleep statuses.
  Required request-label evidence can omit its value. Evidence-root creation
  establishes no private permissions, and transcript creation can overwrite an
  earlier run. These risks meet the integration threshold. Record their source
  cases in `docs/verification/settings-activation/ORDERING-SCENARIO-REVIEW.md`
  and place integration before k67. Keep every later owner and runtime hold.
