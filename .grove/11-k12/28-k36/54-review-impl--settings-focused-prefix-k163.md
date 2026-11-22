# settings-focused-prefix-k163

**Reviews:** settings-focused-prefix-k62

## Goal

Review the whole shared Settings scenario adversarially before any consumer.
Try to break the focused prefix, its byte check and the k62 duty comparison.
Report findings, not fixes.

## Context

The artifacts are the k62 commit and these files:

- `scripts/vm-verify-menu-bar-prefix.sh` and `scripts/check-settings-prefix.py`
- `Tests/scripts/vm-settings-prefix.bats` and the Taskfile tasks
  `check:vm-settings-prefix` and `app:vm-verify-menu-bar-prefix`
- `docs/verification/settings-activation/ORDERING-PREFIX-RESULTS.md` and its
  records in `ordering-prefix-evidence/`
- the complete scenario `scripts/vm-verify-menu-bar.sh`, its library
  `scripts/vm-settings-scenario-lib.sh` and the facades that the library
  sources.

The contract is the k62 task file, the k36 brief and the ordering protocol
`ORDERING-EVALUATION-PLAN.md`. It also includes the archived contracts of k56,
k53, k61, k66, k71, k75, k80 and k85 under
`docs/verification/grove-tree-structure/original-briefs/`. Read each contract
yourself. Do not accept a disposition in the comparison without its source line
and its control.

## Done when

- Test the doubts below, and any other doubt that the artifacts raise:
  - Does the boundary rule of the check hold for every scenario shape that a
    later edit could produce? Can a prefix pass the check and still differ from
    what E must run?
  - Do the behavioural controls compare enough? A same-call comparison drops
    the root and the local upload path. Could it hide a difference between the
    prefix and the complete scenario?
  - Is any original duty missing from the comparison, or marked met without a
    real control? Is any shortfall called a limit or an owned duty without a
    written owner or a reviewed decision?
  - Is any later ordinary assertion, action, wait, bound or screenshot changed
    since the protocol's baseline `f019161b` without a cited reason?
  - Are the named gaps precise enough for a later session to close?
- Report each finding with its evidence and its effect on E, A or k57. Classify
  none as fixed.
- Run the reusable Taskfile checks that the findings need. Start no VM.

## Notes

No clone, signed subject or runtime slot exists. Cut an integration only for
findings that pass the acceptance and material-risk threshold. The controls
task `settings-scenario-controls-k164` follows this review. k57 and k54 stay
held.
