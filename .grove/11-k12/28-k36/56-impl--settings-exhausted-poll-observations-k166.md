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
