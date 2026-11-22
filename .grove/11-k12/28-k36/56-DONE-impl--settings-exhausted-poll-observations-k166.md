# settings-exhausted-poll-observations-k166

## Goal

When a reviewed facade exhausts a poll of the strict scenario, take the
protocol's untouched failure observations before the latch. Change no
successful action, read count, wait or bound.

## Context

The ordering protocol requires one observer read, one window read and one
screenshot after a failed assertion, before other collection. See
`ORDERING-EVALUATION-PLAN.md` lines 187–193. k165 delivered this for the
failures that the scenario library records. Read the "Integration of review
k163" section of `docs/verification/settings-activation/ORDERING-PREFIX-RESULTS.md`
for that pattern and for gap G6.

These facades record their own state-failed exhaustion receipt. That receipt
latches the root, and the latch refuses the System Events observer. The
failure then keeps only the screenshot:

- `await_guest_endpoint` in launch mode, through `settings_await_koine`
- `_sysevents_poll`, through `await_guest_menu_label` and
  `await_guest_menu_frame`
- `await_guest_textedit_window`, whose final assertion follows the poll
- `click_guest_allow`, at its exact-target receipt.

The deferred mode of `await_guest_window_count`, which k67 added and k165
reuses, is the existing model.

## Done when

- Each listed failure takes the observations before its receipt, or a
  reviewed reason records why one observation cannot run there. An Automation
  failure keeps the k165 rule: the observer is NOT RUN before the check passes.
- Each receipt keeps its operation name, its `state-failed` outcome and its
  status 125. The legacy lanes of these facades stay unchanged.
- Controls in each facade suite and in `vm-settings-scenario.bats` fail
  against the current source before the repair.
- Update the duty row and gap G6 in `ORDERING-PREFIX-RESULTS.md` and the k57
  handoff. Rerun the prefix check and the reusable Taskfile checks. Decide
  whether the facade change earns a review before k164. If it does, include
  the k165 library change in that review, because both deliver one duty.

## Notes

No VM, clone or signed subject. A source change before the TextEdit quit in
`scripts/vm-verify-menu-bar.sh` needs a new prefix extraction. A change in the
library or a facade needs none. k164 follows this leaf.

## Decisions (running log)

- 2026-11-23: Each listed facade gets an explicit `deferred` mode, on the model
  of the count poll. Each facade exposes its predicate as a function, so the
  caller's receipt cannot drift from the facade's receipt.
- 2026-11-23: The frame poll already takes an optional title, and a title can
  be any word. Its mode is therefore a fourth argument, and an empty title
  selects the item frame.
- 2026-11-23: The TextEdit poll is called directly from the scenario. Its
  repair changes a line before the TextEdit quit, so the prefix is a new
  extraction of 154 lines.
- 2026-11-23: The restart boot poll stays outside this duty. The scenario
  classifies its exhaustion as a test-driver or guest failure, not a failed
  assertion. `await_guest_element` has no caller.
- 2026-11-23: The facade change earns review k167 before k164, and that review
  includes the k165 library change. The change moves the latch point in four
  reviewed facade families, and the finite runtime slots depend on the
  resulting classification.
- 2026-11-23: Fourteen of the fifteen k166 controls failed before the repair,
  and two mutations were detected. The fifteenth holds an existing property.
  The recorded run of the nineteen Taskfile checks exits 0, with 346 passing
  tests and none of the 4,558 subjects changed. The documentation check keeps
  only the two existing k23 failures. No VM, clone or runtime slot ran.
