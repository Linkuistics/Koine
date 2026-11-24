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

## Decisions (running log)

The setup judges the first window that is not Notification Center in the
zero-count list. It records the decision as the local state
`<selection>-setup-front-state`. The new condition replaces the old
`<selection>-setup-front` read at the same position.

A missing `focused` flag on that window is a local failure record named
`<selection>-setup-focus`. The check runs beside the title check, before any
state decision. This follows the title pattern, because jq reads a missing key
as `null`, and the predicate would then report a clean mismatch.

The backend gets two setup flags. `textedit-not-focused` gives the clean
mismatch, and `textedit-no-focus` removes the flag. Both act only after the
first close, as `textedit-no-title` does. The `front-other-pid` flag and the
`front-process` answer stay in the backend, because the read keeps its own
tests.

The transport-family fault test named the removed read. It now names
`first-selection-setup-sheets`, which is still a System Events read of the
same setup. The other fault cases name `-setup-front-state`, because the
backend can fault a local poll record.

`check:settings-baseline` pins the ordered state predicates of a complete
run in `ordering-baseline-evidence/classification.json`. The pin named the
old read before each of the four selections. The repair replaces only that
`predicates` list with the output of `--print-predicates`. Each old read and
state pair becomes one state entry, and no other entry moves. The `.subjects`
digest files record past measurements, so they keep the old digest.
