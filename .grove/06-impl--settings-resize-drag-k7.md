# settings-resize-drag-k7

## Goal

Make the corner drag of the menu-bar scenario reach its destination on today's
guest. First, show on a control that Koine does not cause the short stop. Then
attempt 5 of the release check can run the resize and every assertion after it.

## Context

- Attempts 3 and 4 of `release-0-4-1-k4` passed all four Settings selections.
  Both then failed at the resize with the same frame, 681 by 884 at 40, 40. The
  running log of that leaf records the evidence. The evidence roots are
  `.build/vm-verify/menu-bar-20261126T015033-evidence` and
  `.build/vm-verify/menu-bar-20261126T115459-evidence` in this workspace.
- `drag_window_corner` in `scripts/vm-window-resize-lib.sh` sends eleven held
  `mouse-down` points from 3 pixels inside the corner to the destination. It
  waits 0.2 s after the first point and 0.15 s after each later one, then sends
  `mouse-up`. Records 000240 to 000243 of each root show the ninth point, the
  tenth point, the release and the frame read. The CLI answered each request
  cleanly. The frame matches the ninth point, 717, 920.
- The resize step of `scripts/vm-verify-menu-bar.sh` drags to 740, 940 and needs
  a frame of at least 690 by 880. It then drags to 100, 100 and needs the least
  width 440 and the least height 320 plus the title bar.
- The route was qualified on 2026-10-28 with TestAnyware 2.7.0 on macOS 27.0.1.
  It grew the window to 703 by 903. `docs/verification/resize-delivery/README.md`
  and the "Paced fresh-window route" section of
  `docs/verification/menu-bar-vm.md` record it. The harness moved to TestAnyware
  3.0.0 on 2026-11-23 (`a6fbabb6`, k177), and the guest now runs macOS 27.2.1.
  Each request of TestAnyware 3.0.0 takes about 22 ms.
- `Tests/scripts/vm-window-resize.bats` and `Tests/scripts/vm-physical-evidence.bats`
  test the helper. `scripts/check-settings-baseline.py` and its classification
  read the baseline event stream, which holds the drag events.
- Issue #21 records the dropped point.
- The notarised 0.4.1 bundle and its zip are in `.build/app` and
  `.build/release-0.4.1`. Do not run `task app`, because it re-signs the bundle
  and drops the staple. The GitHub release `v0.4.0` holds the 0.4.0 zip, with
  the SHA-256 `e1cd1481195e41a042a49cc2131d35fb12e34c0655c3e78375a965f7438af4e8`.
- A guest run needs `KOINE_TESTANYWARE_CLI` and `KOINE_JQ` as resolved absolute
  paths, and `KOINE_VM_BASE=testanyware-golden-macos-27`. Give each clone its own
  name, and stop it after the run.

## Done when

- A diagnostic guest runs the current drag on today's guest against a control.
  The control is the 0.4.0 bundle, TextEdit or both. The run shows whether the
  short stop belongs to Koine 0.4.1.
- If the 0.4.0 bundle grows to the destination where 0.4.1 stops short, the leaf
  stops and asks Antony. That result is a Koine finding, not a harness repair.
- Otherwise, a diagnostic guest qualifies a revised drag on Koine 0.4.1. The
  grown frame reaches at least 690 by 880, and the drag to 100, 100 still
  reaches the least size.
- The scenario uses the qualified drag. The thresholds of the resize step do
  not change.
- `task check:vm-settings-scenario` and every other Taskfile check that reads
  the helper, the scenario, its backend or the baseline pass.
- The documents that describe the resize route state the change and the
  diagnostic evidence. Issue #21 records the result.

## Notes

Antony chose this repair on 2026-11-26, after attempt 4. One other choice was to
accept the Settings evidence of attempts 3 and 4. The others were to run only
the Koine control first, or to stop with nothing shipped. The running log of
`release-0-4-1-k4` records the choice.

The diagnostic guest is not an acceptance attempt of the release leaf. Keep it
apart from the scenario, as k5 and k6 did with their probes.

One candidate is a second held point at the destination before the release.
Read the ADR `docs/adr/settings-harness-takes-no-keepalive-captures.md` before
a change adds a pause. It governs the waits of the harness.

The delivery rule applies. A finding that does not break the happy path becomes
a GitHub issue.

## Decisions (running log)
