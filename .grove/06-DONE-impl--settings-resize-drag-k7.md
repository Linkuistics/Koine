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

**What the tenth point is not (2026-11-26).** TestAnyware 3.0.0 waits after
each input until Tart's VNC server shows that it read the input
(`confirm_input_read`, research note `tart-vnc-reset-drops-input-macos-27` in
the local TestAnyware checkout). Without that sign, the CLI prints a warning.
The installed binary holds the warning, and the stderr of records 000241 and
000242 is empty. So the server read the tenth point, and the guest did not
apply it before the release. Issue 12 of TestAnyware, a reset that drops
input, is not the cause.

**The revised drag and the probe (2026-11-26).** The revised drag adds point
11, a second held point at the destination. A wait of one second follows it,
and then the release. The point is named `resize-down-11`, because the held
state of the evidence backend counts every `resize-down-` operation. The ADR
on keepalive captures governs gaps of 60 seconds or more between VNC clients.
A one-second hold is far below that, so the ADR does not bind it.

`scripts/vm-probe-resize-drag.sh` (`task app:vm-probe-resize-drag`) runs on
its own clone with one bundle. It drags TextEdit's window and then the first
Settings window with the frozen drag from before the hold. Then it drags two
reopened Settings windows with the revised drag. Each trial reads the frame at
once and two seconds later.

The frozen drag is
`docs/verification/resize-drag/before-source/vm-window-resize-lib.sh`, and a
stub run showed that it sends the points of attempt 4. The probe writes no
receipts, so its requests come about 65 ms closer together than the
scenario's. The probe runs once with 0.4.1 and once with the 0.4.0 zip of the
`v0.4.0` release, whose SHA-256 matched.

**The first probe run (2026-11-26).** The 0.4.1 run
(`.build/vm-verify/resize-drag-041-20261126T010608Z`) settles the Koine
question. TextEdit's Untitled window, dragged from 480 by 712 with the frozen
drag, stopped at 679 by 884. Koine's first Settings window stopped at 681 by
884. Both frames match the ninth point, and the frames read two seconds later
did not change. So the guest drops the last point for an Apple application too.
The short stop does not belong to Koine.

The hold did not repair it. The reopened window kept the least frame, 440 by
352, and grew to 677 by 848, which again matches its ninth point. Points 10 and
11 had the same coordinates, and neither took effect. A model that fits every
read so far: the guest applies a held point only when a held point at another
position follows it. The next candidate replaces the hold with a trailing held
point one pixel past the destination. The probe also resizes each reopened
window to 480 by 712 first, so every trial starts where the scenario starts.

**The 0.4.0 control (2026-11-26).** The 0.4.0 run
(`.build/vm-verify/resize-drag-040-20261126T010747Z`) gave the frames of 0.4.1
in every trial. TextEdit stopped at 679 by 884 and the first Settings window at
681 by 884. Each hold trial stopped at 677 by 848. So the 0.4.0 bundle stops short where 0.4.1 does.
The short stop is not a Koine finding, and the leaf goes on with the repair.

**The trailing point failed too (2026-11-26).** A held point one pixel past
the destination (`.build/vm-verify/resize-drag-041-trail-20261126T011034Z`)
grew both reopened windows to 682 by 885 only. A diagnostic then read the
screen's visible frame: it ends at y 990, so the Dock does not limit the
drag. Drags to 740, 900, to 740, 960 and to 800, 700 each stopped one step
short (`.build/vm-verify/visible-frame-diag-*`).

**The cause (2026-11-26).** A diagnostic read the frame after each held
point while the button stayed down (`.build/vm-verify/midrag-diag-*`). The
frame did not change at point 1. From point 2 on, the corner followed the
pointer exactly, 19 by 16 pixels behind it. That offset is the first step of
22 by 19, less the 3-pixel inset. So the resize measures from the first held
movement, and the step from the press to point 1 is lost.

The steps are equal, so the lost first step looked like a lost last step. The
model predicts every frame of the earlier runs. That includes the one pixel of
the trailing point and the 677 by 848 of the hold trials.

**The repair and its qualification (2026-11-26).** Point 1 is now an anchor,
one pixel from the press toward the destination. The ten points after it
carry the same one-pixel shift, and the release comes at the last of them. The
model predicts a grown frame of 703 by 903, the frame of the 27.0.1
qualification.

The probe (`.build/vm-verify/resize-drag-041-anchor-20261126T011701Z`)
grew both reopened windows from 480 by 712 to exactly 703 by 903, and both
reached the least size, 440 by 352. The reads two seconds later matched, and
the screenshot shows the grown window. The frozen drag in the same guest
stopped at 679 by 884 for TextEdit and at 681 by 884 for Koine.

**The tests and the backend (2026-11-26).** The helper tests pin the anchored
path: point 1 at 518, 750 and the release at 741, 941 for the drag to 740, 940.
A new test checks the anchor of a shrinking drag, at 739, 939. The containment
test covers a fault at `resize-down-11`. A control ran both helper suites
against the frozen drag, and nine tests failed.

The simulated backend now loses
the step from the press to the first held movement. A new scenario test passes
with the anchored drag at 703 by 903 and fails with the frozen drag at 681 by
884. A mutated backend without the model turns that test red.

The baseline review adds the class `anchored-drag`. It replaces the held points
and the release of each drag in the nine cases that reach the resize, 17 rows.

**The documents (2026-11-26).** The section "The anchor point" of
`docs/verification/menu-bar-vm.md` records the cause, the repair, the runs and
their limits. `docs/verification/resize-drag/` keeps the frames, the subject
digests, both diagnostics and one screenshot, because `.build/` is not
committed. The route summary of that document and the 2026-10-28 records, such
as `docs/verification/resize-delivery/README.md`, are dated history in a
pending region. The new section states that they describe the drag from before
the anchor, so this leaf leaves them unchanged.

**The baseline derivation (2026-11-26).** The first check pass failed one
baseline test. The derivation runs the baseline script against the current
backend, and the modelled lost step stopped that drag short. The narrowest
repair makes the model opt-in through the flag `first-step-lost`, which the new
scenario test sets. Without the flag, the corner follows the release, so the
second drag starts at 741, 941. The 17 rows of `anchored-drag` now replace
each drag from its preparation move through its release.

**The checks (2026-11-26).** One serial pass ran 24 Taskfile checks. They are
every check that reads the helper, the scenario, its backend, the baseline
checker, the sequence scripts or the verification documents. A digest of each
changed file matched before and after the pass.

22 checks passed. `check:docs` failed on the link to `.grove/11-k12/` in
`ORDERING-PROVENANCE-RESULTS.md`, and `check:vm-settings-context-filter` failed
on its retained native streams. k6 recorded both failures, and this leaf
changes neither input.

**Issue #21 (2026-11-26).** The comment
https://github.com/Linkuistics/Koine/issues/21#issuecomment-7181044111
records the cause, the repair and the evidence. The issue stays open: attempt 5
of `release-0-4-1-k4` runs the anchored drag in the full scenario.
