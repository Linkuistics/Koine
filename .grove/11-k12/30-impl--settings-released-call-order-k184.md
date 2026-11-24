# settings-released-call-order-k184

## Goal

Return the Settings call order on this branch to the order that 0.4.0 shipped.
`showSettingsWindow` then requests the key and front window first, and it
requests activation second. The branch merges with no unaccepted behaviour
change in that operation.

## Context

`settings-ordering-next-decision-k183` holds the decisions. Antony closed the
Settings repair as unresolved after the E01 setup stop. GitHub issue #15 brings
the evaluation back. Antony left the call order to k183, and k183 chose the
released order. The spec requires complete ordinary acceptance for the
candidate, and the candidate has none.

The k52 change "settings-ordering-application-k52: implement reviewed Settings
call order" made the swap, as commit `561dbf6c`. It changed only
`Sources/KoineApp/AppDelegate.swift`: the doc comment, a comment block and the
order of the two requests with their trace records. `main` holds the released
form. Return that one hunk to the released form, and keep each trace record
beside its call.

Keep the dormant diagnostics: the trace, the menu probe and their hooks. They
stay off unless a defaults key or an environment variable enables them. Issue
#15 needs them.

## Done when

- `showSettingsWindow` holds the released order: one key and front request, then
  one activation request. Each trace record stays beside its call. The comment
  names the released order and points to issue #15 and the spec.
- `mise exec -- task build` and `mise exec -- task check:settings-activation-interval`
  pass. Keep their outputs beside the application record. These checks cannot
  observe focus, and the record says so.
- The spec, `ORDERING-APPLICATION-RESULTS.md` and the visual discussion state the
  returned order. The alternatives table of the spec no longer calls the
  candidate implemented. The candidate stays in the history and in issue #15.
- The visual discussion and `docs/verification/settings-activation/README.md`
  state the current status. E01 stopped at a setup read, the repair is
  unresolved, and issue #15 brings it back. Both still say that no signed subject
  was built or run, and the node N of `scope-choice.mmd` says the same. The index
  fails the writing rules, so convert it first as its own change. Check that the
  changed diagram renders through `mise exec -- task design:serve`.
- k12 closes by the four steps of a node close. Promote the Settings outcome
  into the root brief: the repair is unresolved, and issue #15 owns the next
  evaluation.

## Notes

The change returns released code, so it earns no review leaf. No guest runs in
this leaf. The duty ledger keeps its 37 rows, with k12 as their owner. The
release check keeps the strict front read until issue #15 changes it.
