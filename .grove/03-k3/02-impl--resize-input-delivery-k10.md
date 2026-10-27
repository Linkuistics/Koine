# resize-input-delivery-k10


## Goal
Isolate why the combined corner recipe works in exploratory interactions but
fails to grow a fresh Koine window, then qualify a useful user-input route or
document the precise remaining limitation under the original parent contract.

## Context

- `docs/verification/menu-bar-vm.md`, User-input corner route, is the current
  outcome. The older macOS 26/Koine 0.3.0 run remains the minimum-size acceptance.
- `docs/verification/window-resize/README.md`, `focused.log`, `revised.log` and
  their inventories preserve the unsuccessful candidates as well as positives.
- The official TestAnyware 2.7.0 source is retained in
  `docs/verification/window-resize/exploratory/upstream-input.rs`; `drag` sends
  interpolation points with a held button and no per-step delay. Ordinary move
  sends mask zero. CLI capabilities are saved beside it. Timing is a lead, not
  a measured cause, and separate CLI move calls are not a held-button path.
- The current source-only helper and complete scenario deliberately fail a
  missing growth; they are an unqualified candidate, not an accepted repair.

## Done when

- Declare a bounded comparison before input: fresh-guest readiness, actual
  front/focused state, exact start geometry, held-button path/timing and an
  independent ordinary-window control. Do not issue input before setup ends.
- Distinguish pointer hit geometry, input delivery/timing and application
  behavior through observations of actual effects. Do not infer delivery from
  exit zero. A persistent-connection paced route is one possible control if
  the installed CLI cannot express timing; no route is prescribed as the cause.
- If a useful route is established, grow the signed settings window, attempt
  shrinking below its 440-wide/320-content-high limit and reach the existing
  required controls by scrolling at the observed minimum, using frozen actual
  subjects. AX frame assignment supplies no resize acceptance.
- If no useful route qualifies, keep resize/minimum-size scrolling explicitly
  NOT RUN, identify the exact failed controls/environment and provide a minimal
  reproducer plus a reviewable upstream report if ownership is established.
  TestAnyware issue 12 was closed for a different input-reset fault; do not
  reopen it or file a new report merely from similar symptoms.
- Settle the reusable script and verification record. Validate the complete
  scenario through its existing seam, retaining any activation failure and all
  assertions not run. K4 owns the broader finite sample and activation cause;
  do not grow a retry cap to seek a passing scenario.

## Notes

Use disposable guests; preserve the host's pointer, foreground and permissions.
A past green exploratory frame does not qualify a new attempt.
All new attempts need exact operands, outcomes, cleanup and honest limits.
