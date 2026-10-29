# settings-click-evidence-k87

**Integrates:** settings-click-evidence-k86

## Goal
Triage the k86 review of the k84 OCR, Allow and element-click helpers. Apply
the real findings to the library, its controls, the report and the k80 handoff.
Finish before k85, k81 or k76 consumes the helpers.

## Context
Read the findings in the k86 review leaf and its commit. The reviewed artifact
is commit e0a7c5b7. Grade each finding against the k80, k75, k71 and k66
charters and the reviewed ORDERING-EVALUATION-PLAN.md. Also use the k83
snapshot contract, the legacy callers and the v2.7.0 CLI and OCR sources.

## Done when
- Classify each k86 finding as real, a visible trade-off or noise, with a reason.
- Apply each real finding. Show a failing control before each behaviour change.
  Keep the existing red receipts unchanged.
- Pass the Taskfile checks and record final digests and receipts.
- Keep every original k80 duty for k85.
- Keep every exec and one-shot consequence for k81.
- Keep complete adoption, signals and both held-pointer cases for k76.
- Keep the missing-tree and empty-AXValue availability limits and private
  secret-bearing roots. Change no ordinary caller.

## Notes
No VM, candidate, freeze, native acceptance or ancestor closure. Redesign
beyond these findings goes to a new producer and review chain beside this leaf.
