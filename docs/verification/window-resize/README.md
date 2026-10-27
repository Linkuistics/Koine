# Resize input investigation

This directory retains k3's macOS 27 input investigation and complete-scenario
evidence. The result and its acceptance limits are recorded in
[menu-bar-vm.md](../menu-bar-vm.md#user-input-corner-route--2026-10-28).

**Historical k3/k9 result: native resize remained unaccepted.** The exploratory positives
below were followed by two frozen fresh-guest candidates that both failed to
grow the window. The full scenario failed earlier on activation. None establishes
minimum-size scrolling in this environment. The later
[k10 delivery investigation](../resize-delivery/README.md) records the paced
route and its separate native qualification; it does not change these failed
attempts.

## Exploratory sequence

The clone was `koine-resize-k3`, from `testanyware-golden-macos-27`, at
1920×1080. [Installation and environment](exploratory/install.json),
[the later environment read](exploratory/guest-environment.json),
[host tools](exploratory/host-tools.txt), [doctor](exploratory/doctor.json)
and [capabilities](exploratory/capabilities.json) identify it. Doctor reported
matching CLI/app/bundle 2.7.0, working prerequisites and a disabled TestAnyware
login item. That login preference was left unchanged. Actions here were exploratory,
with sequential observations and no complete before/after subject inventory.
They identify candidate input effects; they supply no frozen acceptance sample.

The numbered sequence below identifies the retained observations. Each input
JSON contains the actual command result. Each after JSON is a new agent window
read. Placement and focus actions are setup, not resize evidence.

1. [Initial windows](exploratory/initial-windows.json) showed Koine at 480×712
   and TextEdit at 603×505. TextEdit was moved to `(650,80)`; the
   [initial image](exploratory/initial.png) shows this placement. Its
   [combined title drag](exploratory/textedit-title-drag.json) from
   `(950,92)` to `(1070,172)` left it
   [at the same position and size](exploratory/textedit-title-after.json).
2. [Separate move/down/move/move/up commands](exploratory/textedit-separate-01-move.json),
   with one-second pauses between moves, also left TextEdit
   [unchanged](exploratory/textedit-separate-after.json). The separately retained
   `textedit-separate-02` through `-05` JSON files hold the other actions.
   These are the ordinary `input move` commands, not held-button interpolation.
3. The [combined corner drag](exploratory/textedit-corner-drag.json), 100 steps
   from `(1252,584)` to `(1400,780)`, grew TextEdit
   [to 751×701](exploratory/textedit-corner-after.json).
4. Koine was [placed at `(40,40)`](exploratory/koine-place.json) and
   [focused](exploratory/koine-focus.json). Its
   [title drag](exploratory/koine-title-drag.json) from `(280,52)` to `(400,132)`
   left its [480×712 frame unchanged](exploratory/koine-title-after.json).
   The following [combined corner drag](exploratory/koine-corner-combined.json),
   with the default ten steps, grew it
   [to 701×901](exploratory/koine-corner-after.json).
5. The [outermost-corner shrink](exploratory/koine-shrink.json) left the
   [701×901 frame unchanged](exploratory/koine-shrink-after.json).
   A [title probe at y=64](exploratory/koine-title-24.json) also
   [left it unchanged](exploratory/koine-title-24-after.json).
   Two preparatory moves and another outermost-corner drag likewise
   [did not shrink it](exploratory/koine-shrink-approached-after.json).
6. A [100-step drag from a three-pixel inset](exploratory/koine-shrink-inset.json)
   reached [440×352](exploratory/koine-shrink-inset-after.json).
   A subsequent [ten-step grow without preparation](exploratory/koine-inset-default-grow.json)
   [did not grow it](exploratory/koine-inset-default-grow-after.json).
   The following attempted shrink was therefore outside the window and
   [left it at 440×352, unfocused](exploratory/koine-inset-default-shrink-after.json).
7. After refocusing Koine, pointer preparation and
   [a 100-step inset drag](exploratory/koine-prepared-grow-drag.json)
   [grew it to 703×903](exploratory/koine-prepared-grow-after.json).
   At that frame's `(740,940)` corner, separate mouse-down/mouse-up
   [left it unchanged](exploratory/koine-original-after.json).
   Pointer preparation followed by
   [the combined drag from the same point](exploratory/koine-final-shrink-drag.json)
   then [reached 440×352](exploratory/koine-final-shrink-after.json).
8. The repaired source-only helper itself ran once out and once in.
   [Its log](exploratory/helper.log), [grown frame](exploratory/helper-grown.json),
   [minimum frame](exploratory/helper-minimum.json),
   [grown image](exploratory/helper-grown.png) and
   [440×352 image](exploratory/helper-minimum-440x352.png) retain the result.
   It then grew the independent TextEdit control from
   [751×701](exploratory/control-helper-before.json) to
   [853×823](exploratory/control-helper-after.json), with
   [its own log](exploratory/control-helper.log) and
   [image](exploratory/control-helper-after.png).
9. The [stop result](exploratory/exploratory-stop.json) records clone cleanup.

The resulting frame is measured independently of the pointer destination.
The experiment identifies a candidate preparation/inset/100-step recipe;
it does not separately establish the necessity of each parameter or a universal
title-bar failure. No click was inferred successful from its CLI exit status.

## Source and focused checks

The [former helper](former-helper.txt) is an excerpt of parent `0dbe3608`.
It sent down at the corner and up at the destination, with no held-button path.
TestAnyware's [official v2.7.0 source](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-rfb/src/input.rs#L171-L194)
shows that `drag` sends interpolation points with the button mask held.
The [downloaded source](exploratory/upstream-input.rs) preserves that reading.
Its ordinary `mouse_move` sends mask zero, so separate move commands are not
equivalent to that path.

[Upstream issue 12](https://github.com/Linkuistics/TestAnyware/issues/12) is
closed. Its [saved report](exploratory/upstream-12.json) and
[closure explanation](exploratory/upstream-12-comments.json) concern input dropped
at connection reset, repaired in 2.7.0. The working corner effects here establish
no new TestAnyware defect and do not reopen that report. The
[issue inventory](exploratory/upstream-issues.json) was read during this investigation;
no new report was sent.

The [four red controls](checks-red.txt) fail against the former helper.
The [same controls plus syntax, ShellCheck and formatting](checks-green.txt)
pass after repair. They test request geometry and transport failure propagation;
native effects require the guest. The [eight existing pointer controls](pointer-checks.txt)
also pass. The [one bounded review](review.txt) found no actionable issue and
left native acceptance to the complete scenario.

## Subsequent failures and handoff

The [complete-scenario log](scenario.log) records its activation failure before
resize. The [first focused candidate](focused.log) and
[revised explicit-focus candidate](revised.log) both failed to grow the fresh
480×712 window. The [main record](../menu-bar-vm.md#complete-scenario-failure-retained)
explains every result, freeze and assertion not run. The ordinary-window control
in this directory remains exploratory; it was not matched to those failed fresh
states. The [final VM inventory](vms-after.json) contains no running clone.

At the k9 handoff, the three-pixel unpaced recipe and focus setup remained
unqualified candidate code. Further investigation needed to isolate input delivery/timing and starting state with
a matched ordinary-window control before choosing another repair or assigning
an external defect. The official input implementation's lack of a per-step
delay is only a lead. No new issue was sent, and no full-scenario retry was made
to seek a green result. The request-level tests pass, while native acceptance
remains live under window-resize-k3.
