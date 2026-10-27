# window-resize-k3

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
