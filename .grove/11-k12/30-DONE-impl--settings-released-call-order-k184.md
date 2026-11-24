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

## Decisions (running log)

- 2026-11-25: This session adopted the mandated leaf on the empty jj change
  `wxuznmyo`, with parent `9161aa01`. It read the glossary, the brief chain, the
  keepalive ADR and the k183 decision log.
- 2026-11-25: The index and two Settings records landed as preparatory
  conversions. The menu-bar record carries the same stale claim, so its opening
  section converted too, and a pending marker holds the rest.
- 2026-11-25: `showSettingsWindow` holds the released order again. The file
  differs from the parent of `561dbf6c` only by a new comment, which names the
  released order, issue #15 and the spec. The doc comment is the released text.
- 2026-11-25: `mise exec -- task build` exits 0, and
  `mise exec -- task check:settings-activation-interval` exits 0 with nine tests.
  The outputs and the input digests before and after are under
  `ordering-application-evidence/returned-*`. The digests match.
- 2026-11-25: The spec, the application record, the index, the menu-bar record
  and the visual discussion state the returned order and the current status. The
  spec section "Scope after no candidate" also said that no signed subject
  exists, so it converted as its own change and now names the k54 freeze.
- 2026-11-25: The index sentence about unadopted window helpers was stale,
  because k76 adopted them. The scope diagram dropped its stale ownership-wait
  label, as the keepalive ADR decides.
- 2026-11-25: `mise exec -- task design:serve` served the presentation. The
  changed diagrams render as SVG without a parse error in the local discussion
  and in the parent outline. Node N shows the new status.
- 2026-11-25: `task check:docs` exits 201 with only the two archived targets
  that k23 owns. `task check:settings-duty-ledger` reports 37 owned rows and 0
  findings.
- 2026-11-25, k12 close: this leaf is the last live leaf of k12. The brief
  allows the close, because Antony closed the repair as unresolved and issue #15
  holds the next decision. Each native uncertainty stays explicitly unresolved.
  The root brief now holds the Settings outcome. No live review names k12, and
  no ADR or glossary change is due.
