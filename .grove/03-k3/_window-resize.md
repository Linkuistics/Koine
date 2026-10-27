# window-resize-k3 — brief

## Goal

Establish a valid user-input route for the settings window's resize assertions
in the affected guest, or produce a minimal reproducer and precise external
limitation while keeping resize explicitly NOT RUN.

## Context

- `docs/verification/menu-bar-vm.md`: the macOS 26.5/Koine 0.3.0 drag evidence and
  the macOS 27.0.1/TestAnyware 2.7.0 limitation for both Koine versions.
- `scripts/vm-verify-menu-bar.sh`: title-bar delivery probe, corner resizing,
  minimum-size assertion, screenshots and scroll reachability.
- `scripts/vm-verify-lib.sh`: `drag_window_corner`, window observations and
  reusable VM lifecycle.
- `Taskfile.yml`, `app:vm-verify-menu-bar`.

## Done when

- Inspect the current TestAnyware command surface and environment, then isolate
  title-bar and corner input delivery. Include an independent ordinary window
  control where needed: two Koine releases failing the same way does not by
  itself isolate the guest from behaviour shared by both releases.
- If a working route exists, use it to grow the real settings window, attempt
  shrinking below its limit, observe the resulting minimum size and reach its
  controls by scrolling at that size. Preserve the existing width/height and
  content requirements; an Accessibility frame assignment alone is insufficient.
- If delivery remains unavailable, retain the NOT RUN outcome with the precise
  tested environment, attempted routes and control observations. Prepare a
  minimal reproducer and a reviewable upstream report if the defect belongs to
  TestAnyware; record any existing matching issue. Do not turn an input failure
  into either a Koine failure or a successful resize assertion.
- Keep the task output, screenshots and verification record consistent. A
  screenshot after a skipped resize must say what size was actually observed;
  scroll reachability at another size does not establish least-size reachability.
- Validate any local repair and the complete menu-bar scenario through the
  agreed seams, preserving the original input and observation evidence.

## Notes

Use a disposable TestAnyware guest. Do not change the host's pointer, foreground
application or permission state. Antony accepted an explicitly unresolved
resize outcome when an external input limitation remains; it does not establish
resize acceptance.

The established product contract need not change to repair the test route.
TestAnyware implementation work belongs to its own repository, not this grove.

## Decisions (running log)

The graph CLI remains unavailable with the same pre-coordination/unverified
generation refusal as k1. Use bounded source reads; do not terminate other
sessions to obtain graph access.

The existing agreed repair scope and seams remain the implementation plan:
isolate input on Koine and TextEdit; put the corner helper behind a source-only
test seam; demonstrate a failing request-level regression check; repair the
helper and remove the title-bar skip gate; run focused checks, then freeze the
actual subjects for one complete scenario attempt; retain every outcome and
update the existing verification record. No product design, release or new ADR
is needed for this verification-route repair.

In the exploratory macOS 27.0.1/2.7.0 guest, a combined corner drag resized
TextEdit and Koine while the title-bar probe did not move either window. Koine
grew to 703×903 and stopped shrinking at 440×352 with a prepared pointer,
three-pixel corner inset and 100 interpolation steps. At the same grown corner,
the former separate mouse-down/mouse-up route left the frame unchanged; the
combined route then reached the minimum. Select the demonstrated combined
route, retain the unchanged dimension/content assertions, and fail a missing
growth rather than using title-bar movement as a proxy for resize delivery.
The failed title-bar drag is not an established TestAnyware defect: issue 12's
closed input-reset problem is distinct, and no external repair is needed to
exercise this leaf's resize contract.

The four request-level Bats controls failed against the former down/up helper
and pass against the repaired helper; syntax, ShellCheck, formatting and eight
existing pointer controls also pass. The actual source-only helper grew and
shrunk Koine and grew TextEdit in the exploratory clone. One fresh-context
review inspected error propagation, geometry, skip handling and integration,
with no findings. The exploratory clone was stopped. The one full scenario
attempt is now running against frozen scripts and the unchanged signed 0.4.0
bundle, with the guest retained for observation-only failure capture if needed.

That sole complete attempt stopped on Settings reopen 3, before resize. Fresh
native activation and CoreGraphics order, agent windows and a screenshot were
collected before keyboard/focus intervention: all agree TextEdit was in front
and Koine inactive behind it. This is a reproduced activation failure, not an
observer disagreement. Its cause remains k4's existing investigation. Preserve
the failed attempt and every assertion it did not reach; do not repeat complete
attempts to obtain a green result. Qualify this leaf's resize/scroll segment
once in a separate clean guest using the exact current scenario segment. That
focused attempt cannot turn the failed complete scenario into a pass.

The first focused attempt also failed: its 480×712 frame did not grow. Keep
that frozen failure. A follow-up geometry investigation initially sent input
before setup completed; those calls establish no corner result. After setup
and explicit focus, an eight-pixel inset grew/shrank the window; after an AX
reset used only to prepare the initial size, explicit focus and the original
three-pixel path also grew it. These trials do not isolate inset necessity or
the original fresh-window cause. Select an explicit focus setup/check for the
resize phase, retain the three-pixel helper, and make one fresh focused attempt
against the revised recipe. This is a changed-subject qualification, not a
repetition of the full-scenario sample. No focus intervention is added to the
earlier menu-reopen assertions. No second review is spent: this setup change
is checked at the existing focus seam and by the actual native attempt.

The revised focused attempt also failed to grow its fresh 480×712 window;
minimum-size scrolling was NOT RUN. All guests are stopped. This leaf proved
larger than one focused session, so it is now a node: resize-input-evidence-k9
owns the retained instruments/positive and negative evidence delivered here;
resize-input-delivery-k10 owns the fresh-context delivery/timing investigation
and the original remaining qualification. This is ordinary decomposition,
not a predeclared repetition series. No native minimum-size claim is closed.


## K10 contract closure

The original criteria are met by a qualified user-input route. K10 inspected
2.7.0's command/source semantics and matched fresh Koine/TextEdit starting frames
and focus. Unpaced corner input failed fresh Koine at both tested insets but
worked on TextEdit; separate paced held-button points grew both. This establishes
a useful recipe without separating delay, point count and connection lifecycle
or assigning an upstream defect. The title-bar failures remain recorded and
supply no skip gate.

The final focused qualification and one final complete scenario used frozen
actual subjects and the unchanged signed 0.4.0 bundle. Both grew to 703×903,
attempted shrinking to (100,100), stopped at 440×352 with 320 measured content
pixels and reached the required controls by scrolling. The complete scenario
exited 0 through final Quit, with no intended assertion NOT RUN. Host and installed
bundle endpoint inventories match and all investigation guests stopped. Nine
resize request/error/guard controls and eight pointer controls pass. No product
change or release was needed.

The verification record now describes the actual paced path, failed candidates,
exact environment, screenshots and guard checks. No upstream report is warranted
without defect ownership. K4 retains the broader sample and historical activation
cause, including k3's reproduced failure; the one positive k10 scenario does not
resolve it. This outcome is promoted to the root brief and k4's handoff.
