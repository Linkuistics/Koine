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

## Decisions (running log)

**The signal is the size of each menu (2026-11-25).** A debug clone
(`koine-menu-oracle-debug`, macOS 27.2.1 build 26B131, the notarised 0.4.1
bundle) compared two candidates. The `selected` attribute qualified for the
TextEdit items. The File item read true while its menu was open and false after
Escape. It failed for the Koine item: the item read false while a screenshot
showed its menu open. The Koine item is a status item (subrole `AXMenuExtra`) in
menu bar 2.

The size of each menu under an item qualified for both. With no menu open, each
menu under each TextEdit item and under the Koine item read `{0, 0}`. While one
menu was open, only that menu read a non-zero size, such as `{269, 425}` for
File and `{242, 93}` for Koine. After Escape, it read `{0, 0}` again. The leaf
uses the size, because one signal then covers every item.

Apple defines `kAXSizeAttribute` as the dimensions of the object. No Apple
source states what a closed menu reports, so the `{0, 0}` value rests on the
guest observation. The comment at the decision site says so.

A missing menu would make a closed check pass with no evidence. So the new reads
require at least one menu under each item, and a missing size is unavailable.

**The qualification run (2026-11-25).** `task app:vm-probe-menu-open` ran on its
own clone, `koine-menu-oracle-probe`, and stopped it. The guest ran macOS 27.2.1,
build 26B131. It read both candidates for all eight TextEdit items and the Koine
item, in each state, with 19 screenshots. The evidence root is
`.build/vm-verify/menu-oracle-20261125T090709Z`. The values matched the debug
clone, and the screenshots agree with the sizes.

Three earlier probe runs stopped in the probe's own setup, and the leaf discarded
them. They missed the Allow button, and then the first System Events read
exceeded the 30 s exec limit. The probe now waits for an exact Allow and gives
each guest command 90 s.

**The checks (2026-11-25).** Each of the 26 Taskfile checks that read the
scenario library, its reads, its backend or the menu-bar script passed on the
working tree. A digest of each changed file matched before and after the run.
A frozen copy gave the baseline. There, 24 checks passed, and two failed only
because the copy has no Git history. A mutation of the size validator and of
each scenario predicate turned its test red.
