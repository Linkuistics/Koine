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

## Decisions (running log)

**The step and the read (2026-11-26).** In each reopen, the scenario adds two
operations after the zero-count poll. `reopen-<n>-focus` sends
`window-focus --window TextEdit`. `reopen-<n>-focused` then reads one complete
window list, and the setup judges that list. The setup predicate does not
change. The zero-count poll stays, because it proves that the window closed.

TestAnyware's agent answers `window-focus` in `handleWindowFocus` of
`agents/macos/Sources/testanyware-agent/AgentServer.swift` (the local
checkout). It activates the owning application with
`NSRunningApplication.activate(options: [])`, then sets `AXMain` and
`AXFocused` on the window. The window list reports `focused: true` only for
the main window of the accessibility focused application. So a refused
activation leaves the flag false, and the probe can see it. The screenshot
checks key status independently.

**The qualification run (2026-11-26).** `task app:vm-probe-reopen-focus` ran on
its own clone, `koine-reopen-focus-probe`, and stopped it. The guest ran macOS
27.2.1, build 26B131, with the notarised 0.4.1 bundle. The evidence root is
`.build/vm-verify/reopen-focus-20261125T134025Z`. Three cycles chose Settings…
over TextEdit, closed the window while Koine was active and sent the focus step.

In each cycle, the list after the close showed TextEdit's window first with
`focused: false`, as in attempt 2. The list read at once after the step showed
it first with `focused: true`, and so did a read one second later. The
screenshot `closed-1.png` shows grey close buttons. `focused-1.png` shows
coloured buttons and a caret. The title-bar click was not needed.

Two earlier runs stopped in the probe's own route, and the leaf discarded
them. In the first, Settings… did not open after the two clicks, and the probe
logged no frame. The cause is not established. The probe now logs each frame
and matches the row by a title that starts with "Settings". The second run
failed on the AppleScript grammar of that row read.

**The backend and the baseline (2026-11-26).** The simulated backend now models
the fault. A close of Koine's window while Koine is first leaves no window
focused, until an application comes to the front. The flag `focus-ignored`
makes the step change nothing, and the new scenario test shows that the strict
setup then fails. Two mutated scenarios turn both changed tests red: one with no
focus step, and one that takes the step but judges the zero-count list.

`check:settings-baseline` could classify only removals from the baseline
stream, and the step adds the event `window focus TextEdit`. The narrowest
repair lets a difference row carry an `added` list. `classification.json` adds
the class `reopen-focus-step` and three additions in each of the nine cases
that reach the reopens. A new control drops those rows and sees the check fail.

**The follow-up issue (2026-11-26).** Issue #20 asks whether Koine should give
the focus back when its window closes. The release does not change it.

**The checks (2026-11-26).** One run took 28 Taskfile checks in turn. They are
every check that reads the scenario, its prefix, its library, its backend, the
baseline checker or the documents. A digest of each of the 12 changed files
matched before and after the run.

26 checks passed. `check:docs` failed on a
link in `ORDERING-PROVENANCE-RESULTS.md` to `.grove/11-k12/`, which the parent
commit does not hold either. `check:vm-settings-context-filter` failed on its
retained native streams. This leaf changes neither input.
