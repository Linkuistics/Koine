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

## Decisions (running log)

- 2026-10-29: Adopt k73 in clean jj change yuoronuv. Read k72's findings
  from review commit 142b72b6 against producer 846e0d91. Graph Tier 2,
  generation 2026-10-29T07:22:16Z; direct reads cover the reported shell parse
  gaps and untracked Bats source. All six findings are real within their stated
  bounds; P3-4 is a provenance gap, not a demonstrated false pass.
- 2026-10-29: Preserve the legacy TextEdit loop and its unconditional final
  assertion read, including early-positive paths and the fifteenth negative
  sleep. Let the helper own both; k71 must replace the whole block exactly once.
  Keep Koine's ten-read bound unchanged. Add local poll-step receipts through
  the existing writer domain: record each predicate/status, distinguish exhausted
  state from unavailable evidence, and latch failed/interrupted local steps.
  Preserve signal status. Use equals-form move coordinates, retaining integer
  support. Retain new failing controls and rerun the final baseline beside the
  existing immutable red receipts. These are bounded repairs under the existing
  reviewed contract; no redesign, VM or acceptance is authorized.
- 2026-10-29: The behavior-red receipt shows the new TextEdit boundary,
  poll-state/exhaustion metadata, local failure and equals-coordinate controls
  failing before production edits. All twenty controls pass after repair.
  The shared adapter's original 37 controls also pass. Extend its existing
  orphan-held-lock control to include poll-step recording. Executable red/green
  cases and that lock control are the stronger instrument for these behavioral
  claims; decline a duplicate in-session source reviewer on that basis.
- 2026-10-29: The final formatted control file fails every control under
  KOINE_WINDOW_BASELINE=1. Retain that receipt alongside both unchanged original
  red runs, and explicitly state the original control-digest mismatch. The
  baseline uses a TextEdit list stub, not its complete legacy loop; the production
  behavior-red receipt supplies that pre-repair comparison. The report and k66/
  k71 handoff now own the final-read, structured outcome and local-signal details.
- 2026-10-29: Final Taskfile window (20), shared adapter (37) and physical
  helper (16) controls pass, including the added orphan-lock recording path.
  The docs check reports only the same two missing targets already assigned to
  k23. Keep that outcome unresolved here. Align backend help with the distinct
  state-failed/interrupted outcomes, then remeasure the final subjects. K71/k67/
  k62/k57/k54 and complete shell/held-pointer signal duties remain live. No ADR
  change is earned by these implementation repairs; k66 still has live children,
  so retirement closes no ancestor.
