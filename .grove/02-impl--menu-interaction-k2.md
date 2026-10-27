# menu-interaction-k2

## Goal

Diagnose and repair the menu-bar check's rejected `-1` pointer movement and
intermittent front-window assertions through the existing menu interaction route.
Deliver reproducible evidence, focused checks for any repaired helper logic, and
a complete VM run that exercises the affected behaviour.

## Context

- `docs/verification/menu-bar-vm.md`, especially its 0.4.0 evidence and TextEdit
  first-launch limitation; issue 14 has the original observations.
- `scripts/vm-verify-menu-bar.sh`: Settings reopening, repeated close/reopen,
  request-review opening, and reopening the running application.
- `scripts/vm-verify-lib.sh`: `click_at`, `click_centre`, `open_menu`,
  `choose_menu_item`, `await_windows`, `front_windows`, `koine_in_front` and
  `guest_once`.
- The Taskfile entry is `app:vm-verify-menu-bar`; use the machine environment
  contract and the TestAnyware skill for any guest operation.

## Done when

- Trace a rejected coordinate from its observed source frame through the helper
  to the exact CLI arguments, or establish a deterministic reproducer of the
  same path. Check edge geometry and missing/malformed observations. A valid
  target must remain the same target after the repair; do not conceal an invalid
  target by clamping it onto an unrelated point.
- Capture enough evidence around one menu action to distinguish input delivery,
  window appearance, window ordering and keyboard focus. Establish the cause
  before changing the application or choosing a wait/retry policy.
- Verify the repair through the agreed seams. Repeated observations may wait
  for an effect within a justified bound; repeated actions must not turn a
  failed first action into a hidden success. Keep silent launch and reopen
  semantics distinct.
- A complete menu-bar VM scenario exercises the repair, with every intended
  reopen checked. A resize NOT RUN remains separate evidence for window-resize-k3.
- Update the reusable task and existing verification record as needed, including
  the actual subjects, versions, commands, failures and residual uncertainty.
  An unreproduced historical symptom is not labelled fixed: retain a precise
  follow-up if the new evidence cannot close it.

## Notes

At plan-k1, `click_at` first moves to `(x - 12, y - 8)`, then to `(x, y)`, then
clicks. This is a lead, not an established explanation of the historical `-1`.
`await_windows` waits only for a count; the scenario separately checks the first
non-Notification-Center window and its focused flag. Do not assume either the
observer or Koine caused the historical front-window failures.

The shared VM helper is sourced by other verification scripts. Keep changes
narrow and inspect affected consumers. Avoid making the helper start a VM when
testing its pure logic. Prefer its existing boundary over a new test framework.

No release, product feature or host GUI run is required. If diagnosis expands
beyond one focused session, decompose this leaf and preserve the concrete work.
