# settings-scenario-outcomes-k162

**Integrates:** settings-scenario-outcomes-k161


## Goal
Triage the findings from the named review's commit against the agreed contract.
Apply the real issues and verify the resulting complete Settings scenario
before k62 consumes it.



## Context
Read the review's committed artifact,
`docs/verification/settings-activation/ORDERING-OUTCOMES-REVIEW.md`, and the
producer's `ORDERING-OUTCOMES-RESULTS.md` in the same directory. The review
names the inspected producer commit and its evidence. The k67 charter, k36
brief and ordering protocol retain their authority.

## Done when
- Classify every finding under the integration procedure's acceptance and
  material-risk threshold. Record evidence for each disposition.
- Apply and verify the accepted repairs inline. Preserve every original
  scenario duty, transport distinction, physical action, read count, wait and
  bound, except for observations the protocol requires.
- Retain meaningful controls for accepted repairs and run the applicable
  Taskfile checks. Keep the durable results and the k62 handoff current. <!-- tc: depart synonym-rotation because "Taskfile checks" names the project's check tasks, not the verification action -->

## Notes
This integration is the flat sibling before k62, because its result directly
unblocks consumption of the reviewed scenario. Do not copy the findings into
this charter. No VM, candidate, freeze or runtime slot is authorised here.
The k62, k57 and k54 duties and all ancestor acceptance remain live.

## Decisions (running log)

- 2026-11-23: F1 is a real issue, so the artifact changes. The protocol's "No
  open menu" row names an enumeration of the menus under the TextEdit and
  Koine items, with a count for each item. The source reads `selected`
  instead. The System Events dictionary defines the `menu` elements of a menu
  bar item, and no Apple source equates selection with an open menu. Two new
  reads replace the two selection reads. `menu-bar-menus` serves the setup,
  and `koine-menus` serves the closed-menu check. A closed-menu check after
  the TextEdit quit cannot read TextEdit, so it reads the Koine item only.
- 2026-11-23: F1 trade-off, accepted visibly. No Apple source states when a
  menu bar item exposes its menu either. The new oracle is the protocol's
  oracle, and it stays natively unqualified. If a closed application menu
  exposes its menu in the guest, each setup fails cleanly at E01. That
  failure stops the evaluation. The k36 brief's hold before E01 is the route
  for a new decision. The k57 and k54 handoff carries this risk.
- 2026-11-23: F1 parser bound. An empty enumeration of TextEdit's menu bar
  items is unavailable, because the menu bar of a running application has at
  least the Apple menu. Each item's list must be a list of names.
- 2026-11-23: F2 is a real issue, so the artifact changes. An unavailable
  title audit keeps its status when the front predicate is a clean false. The
  reopen route still takes its untouched failure observations first. The
  resize focus checks the audit's status before it classifies `not-front`.
- 2026-11-23: Red record. The new controls first ran against the unchanged
  source in this tree. The F1 and F2 scenario cases also ran in a scratch
  copy whose backend answers the retired selection reads with false. There,
  the exposed-menu setup and the open menu after a click both ended PASSED,
  and both untitled-behind cases exited 1 as `not-front`.
- 2026-11-23: No host osascript read is evidence. One read-only probe of
  Finder's menus timed out with error -1712, and it did not run again.
- 2026-11-23: Backend scope. After the red runs, the closed-menu read of the
  previous return also saw the Koine setup flag. The flag now acts on the
  setup read only. `red-tree-shim.diff` and a comparison with the final
  backend show that this scope change is the only other backend difference.
  The red runs did not depend on the flag.
- 2026-11-23: No further review round. The repair is concrete, but k62
  already owes the whole shared-scenario review before k57. That review gives
  the independent challenge. No review names this leaf, and the session has no
  provider evidence, so no Creator line applies.
- 2026-11-23: Final verification. All eighteen affected Taskfile checks pass,
  with 317 passing tests and no failure. None of the 4,512 subjects changed
  during the run. The final manifest matches the current bytes of each changed
  file. The records are in
  `docs/verification/settings-activation/ordering-outcomes-integration-evidence/`.
