# menu-interaction-k2 — brief

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

## Decisions (running log)

- The graph CLI refused access with the same active-generation error recorded
  by plan-k1. Use bounded direct source reads; do not stop other CBM sessions.
- Use the released 0.4.0 zip, downloaded from GitHub, for this diagnosis. Its
  SHA-256 matches the issue's `e1cd1481195e41a042a49cc2131d35fb12e34c0655c3e78375a965f7438af4e8`.
  The other workspace's local bundle is 0.2.0 and is not the subject.
- Reproduced the CLI rejection without a VM: `testanyware input move 100 -1`
  exits with `unexpected argument '-1' found`. Test coordinate arithmetic and
  malformed frames before repairing the helper. Keep the destination unchanged;
  only the synthetic approach point may be bounded to the display.

## Execution plan

1. Extract the pointer helper into a source-only boundary, with failing focused
   tests for the y=7 approach, display edges and invalid frame observations.
2. Repair only the established pointer defect. Capture frame, CLI coordinates,
   menu dismissal, window ordering and System Events focus around one action.
3. Use that evidence to decide whether any focus repair is justified. Check
   every intended reopen, with one action per assertion and no action retries.
4. Freeze the scripts and bundle, run the complete Taskfile scenario, retain
   failed and NOT RUN outcomes, and update the existing verification document.

## Decomposition

The diagnostic guest reproduced a persistent focus failure after a delivered
Settings menu action: the window appeared, but TextEdit remained first and
focused. System Events and the screenshot agree with the agent. This expands
the work beyond the pointer arithmetic repair and rules out treating a longer
window-count wait as an established fix.

- menu-pointer-k5 delivers the bounded coordinate repair, focused controls and
  real-guest input evidence. It also preserves the failed focus observation.
- A following implementation child owns the remaining focus diagnosis and the
  complete scenario, including checking every intended reopen once. The parent
  stays live until its original Done when criteria are met.

## Original acceptance check and handoff

- Coordinate diagnosis/repair: k5 retains the deterministic old-helper path
  from a valid centre at y=7 to a rejected approach at y=-1, edge and malformed
  observation controls, the unchanged destination and actual guest pointer
  evidence. The original historical source frame was not recovered; that limit
  remains explicit. The shared helper's affected consumers and focused checks
  are recorded with its repair.
- Action/focus evidence: k5 retains a real screenshot/agent-order failure; k7
  separates unreliable System Events focus reads from qualified native and
  keyboard evidence. K8 recreates the historical route with native activation,
  independent native window order and visible dismissal before keyboard input.
  That action succeeds; it does not explain the earlier failure. No activation
  workaround or guessed focus wait is claimed as a repair.
- Full scenario: k7 adds an independent assertion after every intended reopen
  and makes launch/reopen operations single-action. K8's one complete frozen
  Taskfile attempt exits 0 through those assertions, silent launch, login launch
  across reboot and final Quit. The host and actual installed-guest endpoint
  inventories match. Resize remains NOT RUN and is neither a pass nor minimum-
  size acceptance; k3 owns it.
- Reusable procedure and accurate record: Taskfile and the scenario now include
  installed-subject inventories; the verification document retains subjects,
  tools, attempted actions, driver failures, limits and outputs. The original
  residual-symptom criterion is met by the precise remaining task in the already
  live menu-bar-samples-k4 leaf: collect qualified native/visible failure state
  before intervention at the first failure in its bounded sample, without
  enlarging the cap. Historical activation remains unresolved even if that
  sample is all green. No external cause or application repair is inferred.

The menu-interaction implementation handoff is complete under that explicit
residual-symptom allowance. This is not closure of issue 14's activation outcome.
The root brief and k4 retain that distinction for the remaining work.
