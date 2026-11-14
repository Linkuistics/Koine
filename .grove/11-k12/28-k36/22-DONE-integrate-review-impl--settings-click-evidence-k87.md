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

## Decisions (running log)

- 2026-10-29: Adopt k87 in the clean jj workspace and read k86's own
  commit 71acea38 against k84 e0a7c5b7. Tier 2 graph generation
  2026-10-29T09:00:10Z has partial common/desktop shell ranges and unavailable
  Bats freshness metadata; direct bounded source reads cover those paths.
  The graph's jq/read edges are unrelated resolutions, not source evidence.
- 2026-10-29: P2-1 is real. Distinguish a complete OCR payload with no exact
  Allow from unusable geometry: check the exact-target predicate locally,
  record its terminal clean negative with the existing structured exhausted /
  state-failed receipt, and stop without input. The single CLI invocation may
  have ended early on a substring; exhausted describes the helper's terminal
  state, not elapsed time. Add no CLI read, retry, input or wait.
- 2026-10-29: P3-1 is an accepted existing availability trade-off with a real
  documentation omission. Preserve v2.7.0's case-insensitive substring poll and
  subsequent case-sensitive exact selection; carry its early-stop limit to
  k80/k81/k76. No new exact-match polling route is authorized.
- 2026-10-29: P3-2 and P3-4 are real control gaps. Check the entire isolated cwd
  after each invalid-root refusal, including the sibling input control, and
  assert transport/outcome/reason or structured local status on failure receipts.
  Use controlled writes to demonstrate that the cwd controls can fail.
- 2026-10-29: P3-3 is real. Route local query-encoding failures through the
  existing local-failure recorder so interrupted statuses remain exact, with
  no external CLI dispatch. Add red controls before changing production code.
- 2026-10-29: P3-5 is real. Replace the invented nested error fixture with the
  official top-level OCR_TIMEOUT envelope and its nonzero exit; separately
  characterize contradictory zero exit. Qualify the old baseline's test 14
  cause and demonstrate bounds/floor sensitivity with focused mutations.
- 2026-10-29: Work remains within the reviewed design. Use failing executable
  controls as the adversarial instrument for these bounded behavior claims;
  no in-session reviewer is needed to reread the same code. Preserve all old
  receipts and all later k85/k81/k76/k67/k62/k57/k54 duties and runtime holds.

- 2026-10-29: Exact-target red fails at the structured receipt assertion;
  geometry remains a distinct unavailable confirmation. The same two controls
  pass after the local presence check, with stable subject digests. Encoder
  red separately fails signal propagation and ordinary local-exit retention;
  both pass after routing through the existing local-failure recorder.

- 2026-10-29: Isolated mutations demonstrate each repaired cwd/receipt guard
  and coordinate endpoint/rounding control can fail. The eight existing
  Taskfile checks pass all 152 controls against stable before/after digests.
  Ordinary callers, the shared backend and original receipts are unchanged.

- 2026-10-29: Final documentation check reports only the same two missing k23
  archive targets; keep that independent work live. K80 remains open with k85,
  and k81/k76 receive the exact-target classification, substring-stop limit
  and all original holds. These reversible helper repairs require no ADR.
  No substantial redesign or additional review chain is earned by the
  executable evidence. No producer/node is closed by this integration.

## Implementation plan

1. Add exact negative/geometry and local encoder receipt controls; retain their
   failing results before each production repair.
2. Repair exact-target classification and query interruption independently.
3. Repair cwd controls, official fixtures and receipt assertions; demonstrate
   control sensitivity and targeted coordinate mutations in isolated copies.
4. Run the existing Taskfile checks with stable full subject digests, update
   the durable report and k80 handoff, then retire and seal this task.
