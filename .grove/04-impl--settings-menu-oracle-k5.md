# settings-menu-oracle-k5

## Goal

Replace the two open-menu checks of the shared Settings scenario with a signal
that a real guest qualifies. Then the release check can run past the setup of the
first Settings selection.

## Context

- Attempt 1 of `release-0-4-1-k4` stopped at the setup of the first selection.
  The running log of that leaf records the evidence. The raw evidence root is
  `.build/vm-verify/menu-bar-20261125T165452-evidence` in this workspace.
- The `menu-bar-menus` read in `scripts/vm_exec_reads.py` asks System Events for
  `name of every menu of every menu bar item`. On the guest, it named one menu
  under each closed TextEdit item and the menu "Koine" under the closed Koine
  item. The failure screenshot `000088/screen.png` shows no open menu.
- `settings_expect_setup` in `scripts/vm-settings-scenario-lib.sh` requires that
  read to name no menu (`<selection>-setup-menus`). `settings_menu_closed` requires
  the `koine-menus` read to name no menu after each selection
  (`<selection>-menu-closed`). Both assumptions fail on a real guest.
- The comment on the read states that no Apple source says when an item exposes
  its menu. `docs/verification/settings-activation/ORDERING-OUTCOMES-RESULTS.md`
  records why k162 replaced the `selected` reads: no Apple source supported them.
  No guest showed them wrong.
- The simulated backend `Tests/scripts/fixtures/settings-scenario-backend.py`
  answers a closed menu with an empty list. `Tests/scripts/vm-settings-scenario.bats`
  (the k162 test) and `Tests/scripts/vm-sysevents-evidence.bats` pin the reads.
- The notarised 0.4.1 bundle and its zip are in `.build/app` and
  `.build/release-0.4.1`. Do not run `task app`, because it re-signs the bundle
  and drops the staple.
- A scenario run needs `KOINE_TESTANYWARE_CLI` and `KOINE_JQ` as resolved
  absolute paths, and `KOINE_VM_BASE=testanyware-golden-macos-27`. The scenario
  sends no VM stop, so the caller stops each clone.

## Done when

- A diagnostic guest qualifies one signal for an open menu. For each TextEdit
  menu bar item that the setup names, and for the Koine item, the read is
  available. It reports closed when no menu is open, and open while that menu is
  open. A screenshot of each state agrees with the read.
- The setup check and the closed-menu check use that signal. A clean open state
  is a failure of the check, as now. A missing or unreadable value is unavailable
  evidence.
- The simulated backend answers the new read in both states.
  `task check:vm-settings-scenario` and every other Taskfile check that reads the
  scenario library, its reads or its backend pass.
- The documents that describe the two checks state the new signal and the
  diagnostic evidence.

## Notes

Antony chose this repair on 2026-11-25, instead of removing both checks or
stopping the release. The running log of `release-0-4-1-k4` records the choice.

The first candidate is the `selected` attribute of each menu bar item. Qualify
it first. If it fails for the TextEdit items or the Koine item, try another
public signal. Cite its source at the decision site. If no signal qualifies,
ask Antony before you change the scenario.

The diagnostic guest is not an acceptance attempt of the release leaf. Keep it
apart from the scenario. Give it its own clone name, and stop the clone after it.

Keep the old reads and their own tests. Remove only their use in the scenario,
as k2 did for the front read.

The delivery rule applies. A finding that does not break the happy path becomes
a GitHub issue.
