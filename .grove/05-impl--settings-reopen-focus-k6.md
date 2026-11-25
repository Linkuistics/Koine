# settings-reopen-focus-k6

## Goal

Give TextEdit's window focus again before each Settings reopen of the shared
scenario. Then the strict setup check of k2 can pass on a real guest. Attempt 3
of the release check can then run all four Settings selections.

## Context

- Attempt 2 of `release-0-4-1-k4` stopped in the setup of `reopen-1`. The
  running log of that leaf records the evidence and the cause. The raw evidence
  root is `.build/vm-verify/menu-bar-20261125T212057-evidence` in this workspace.
- The first Settings selection passed. The harness then closed the Settings
  window while Koine was the active application. In the next window list
  (000111), TextEdit's window came first with `focused: false`. The failure
  screenshot (000119) shows a TextEdit window with grey close buttons.
- Before the first selection, the harness closes the window while TextEdit is
  active, and TextEdit keeps its focused window. The reopen loop in
  `scripts/vm-verify-menu-bar.sh` (the `for reopen in 1 2 3` loop) has no step
  that gives TextEdit focus again.
- `settings_expect_setup` in `scripts/vm-settings-scenario-lib.sh` judges the
  list that it receives. The loop passes the zero-count list of the close check
  (`SETTINGS_COUNT_LIST`). A list taken before a focus step does not show it.
- `act_guest_window` in `scripts/vm-window-evidence-lib.sh` already accepts
  `window-focus`, and `settings_window` wraps it. Other VM scripts call
  `testanyware agent window-focus --window TextEdit`-style actions.
- `scripts/vm-verify-menu-bar-prefix.sh` holds the exact leading bytes of the
  scenario through the TextEdit quit. A Taskfile check compares the two files.
- The simulated backend `Tests/scripts/fixtures/settings-scenario-backend.py`
  and `Tests/scripts/vm-settings-scenario.bats` pin the scenario reads.
- The notarised 0.4.1 bundle and its zip are in `.build/app` and
  `.build/release-0.4.1`. Do not run `task app`, because it re-signs the bundle
  and drops the staple.
- A guest run needs `KOINE_TESTANYWARE_CLI` and `KOINE_JQ` as resolved absolute
  paths, and `KOINE_VM_BASE=testanyware-golden-macos-27`. The scenario sends no
  VM stop, so the caller stops each clone.

## Done when

- A diagnostic guest shows that the focus step works after the close of an
  active Koine window. After the step, the window list shows TextEdit's window
  first with `focused: true`. A screenshot shows that window with coloured close
  buttons.
- In each reopen, after the close, the scenario gives TextEdit's window focus.
  It then reads the window list again, and the setup judges that new list. The
  setup predicate stays as strict as now.
- The simulated backend answers the new step and read.
  `task check:vm-settings-scenario` and every other Taskfile check that reads
  the scenario, its prefix, its library or its backend pass.
- The documents that describe the reopen setup state the focus step and the
  diagnostic evidence.

## Notes

Antony chose this repair on 2026-11-26, after attempt 2. The other choices were
to relax the reopen setups to the old front read, or to stop with nothing
shipped. The running log of `release-0-4-1-k4` records the choice.

The diagnostic guest is not an acceptance attempt of the release leaf. Keep it
apart from the scenario, as k5 did with its probe. Give it its own clone name,
and stop the clone after it. The probe can open the Settings window from the
Koine menu over a focused TextEdit window, close it, focus TextEdit and read.

If `window-focus` does not leave TextEdit's window focused, try a click on its
title bar with the pointer helpers. If neither works, ask Antony before you
change the scenario.

Do not add a wait to replace the focus step. The ADR
`docs/adr/settings-harness-takes-no-keepalive-captures.md` governs the waits of
the harness.

The delivery rule applies. A finding that does not break the happy path becomes
a GitHub issue. Whether macOS should give focus back to the previous window
after Koine's Settings window closes is such a finding.
