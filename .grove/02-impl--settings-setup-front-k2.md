# settings-setup-front-k2

## Goal

Remove the System Events front read from the positive setup of the shared
Settings scenario. The setup judges the front application from the `focused`
flag of the window list that it already holds.

## Context

- `settings_expect_setup` in `scripts/vm-settings-scenario-lib.sh` makes the
  `front-process` read of `scripts/vm_exec_reads.py`. Its list argument is the
  zero-count list of the close check, so the flag costs no new read.
- `settings_koine_in_front` in the same file shows the pattern. It takes the first
  window that is not Notification Center and requires `.focused == true`.
- In E01, the agent list showed the TextEdit window first, with `focused: true`.
  The read of that list came less than 0.1 s after the close. The System Events
  read came about 750 ms later and returned AppleScript error -1728.
- The setup is the only scenario caller of `front-process`. The read has its own
  tests in `Tests/scripts/vm-sysevents-evidence.bats`. The simulated backend
  `Tests/scripts/fixtures/settings-scenario-backend.py` answers it.
- `task check:vm-settings-scenario` runs the scenario against that backend. Its
  tests name `first-selection-setup-front`, and one test injects a fault at
  `reopen-1-selection-setup-front`.

## Done when

- Before each of the four Settings selections, the setup requires one condition
  in the list that it holds. The first window that is not Notification Center is
  the TextEdit window, with `focused: true`.
- A clean mismatch is a failed setup. A list without the flag is unavailable
  evidence.
- The setup adds no read and no wait, and it makes no System Events front read.
- `task check:vm-settings-scenario` passes. Its tests cover the pass, the clean
  mismatch and the missing flag.
- Every Taskfile check that reads the scenario library or its backend passes.
- `docs/verification/menu-bar-vm.md` and the spec describe the new setup check
  wherever they describe the old read.

## Notes

Keep the `front-process` read and its own tests. Remove only the use in the
setup.

The tooling of the closed protocol stays in the repository, unused. A check that
breaks gets the narrowest repair that keeps it green. Do not remove the tooling.

No review leaf exists in advance. At the end, cut one only if the change turns
out to need an adversarial read.
