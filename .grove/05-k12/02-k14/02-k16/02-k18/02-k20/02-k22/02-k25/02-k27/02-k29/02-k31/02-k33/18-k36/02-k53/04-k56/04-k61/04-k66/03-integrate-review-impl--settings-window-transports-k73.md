# settings-window-transports-k73

**Integrates:** settings-window-transports-k72

## Goal
Triage the k72 review of the k70 window transport helpers. Apply the real
findings to the library, its controls, the report and the k71 handoff.
Finish before k71 consumes the helpers.

## Context
Read the findings in the k72 review leaf and its commit. The reviewed artifact
is commit 846e0d91. Grade each finding against the k66 charter, the reviewed
ORDERING-EVALUATION-PLAN.md, the legacy scenario and the v2.7.0 source.

## Done when
- Classify each k72 finding as real, a visible trade-off or noise, with a reason.
- Apply each real finding. Show a failing control before each behaviour repair.
  Keep the existing red receipts unchanged.
- Pass the Taskfile checks and record final digests and receipts.
- Bring the report, the k66 brief and the k71 leaf into line with the result.

## Notes
No VM, signed subject, freeze, native acceptance, scope relaxation or ancestor
closure. K71, K67, K62, K57 and K54 keep their duties.
