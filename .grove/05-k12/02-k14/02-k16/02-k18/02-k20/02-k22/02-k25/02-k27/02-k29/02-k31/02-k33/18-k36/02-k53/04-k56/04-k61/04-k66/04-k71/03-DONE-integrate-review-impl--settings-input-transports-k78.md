# settings-input-transports-k78

**Integrates:** settings-input-transports-k77

## Goal
Triage the k77 review of the k74 input facade and caller migration. Apply the
real findings to the callers, their controls, the report and the k71 handoff.
Finish before k75 consumes the input artifact.

## Context
Read the findings in the k77 review leaf and its commit. The reviewed artifact
is commit 16826c12. Grade each finding against the k71 and k66 charters, the
reviewed ORDERING-EVALUATION-PLAN.md, the parent callers and the v2.7.0 source.

## Done when
- Classify each k77 finding as real, a visible trade-off or noise, with a reason.
- Apply each real finding. Show a failing control before each behaviour repair.
  Keep the existing red receipts unchanged.
- Pass the Taskfile checks and record final digests and receipts.
- Bring the report, the k71 brief and the k75 and k76 leaves into line with the
  result.

## Notes
No VM, candidate freeze, signal qualification or acceptance. K75, k76, k67,
k62, k57 and k54 keep their complete duties.

## Decisions (running log)

- 2026-10-29: Adopt k78 in clean jj change puwmwkut. Read k77 findings from
  commit 8d808722 against producer 16826c12. Tier 2 graph generation
  2026-10-29T07:59:11Z has partial shell coverage and untracked Bats metadata;
  use bounded direct reads, including the reported ranges. No graph completeness
  claim. P2-1 is a real caller failure regression; P3-1 is a real control/report
  limitation. Add failing-read controls in plain scenario and conditional contexts,
  then explicitly propagate read failures before later input. Keep successful
  input order, waits and read counts. Preserve original red receipts.
- 2026-10-29: P3-2 is a real retention limitation. Accept full raw consent receipts
  visibly under the existing exact-response contract. They contain the VM password
  and must remain private when it is a secret. Document this in the report and
  downstream collection/adoption handoffs; no redacted operation or weakened
  predicate is introduced. Synthetic controls use only disposable fixture text.

- 2026-10-29: Initial and expanded failing-read controls fail before production
  edits. Explicit guards repair the frame/snapshot/position and menu read chains;
  status 1 is reserved for a clean on-screen negative (failed read 1 maps to 2).
  No successful input, wait, bound or read count changes. The first expanded-final
  comparison exposed test setup limits: Bats lacked scenario pipefail in two
  pipeline controls, and a negative path reached undefined boundaries. Correct
  the setup and retain that first comparison with its limit. All 21 input controls
  now pass. Add a final isolated pre-integration comparison using the exact final
  tests. Executable red/green controls are the stronger instrument for these
  behavioral claims; decline a duplicate fresh source reviewer on that basis.
- 2026-10-29: The report and k71/k75/k76 handoffs now carry all three review
  dispositions, the conditional-baseline limit and secret-bearing receipt rule.
  Existing raw reads remain due for strict migration/latching; no whole-scenario
  failure guarantee or runtime readiness follows. No ADR is earned by these
  bounded implementation repairs or the visible raw-retention trade-off.

- 2026-10-29: Final isolated comparison shows all seven new controls failing
  against 8d808722 with the exact final formatted Bats digest. Final Taskfile
  input (21), shared adapter (37), physical (16), window (20), pointer (8) and
  resize (9) controls all pass: 111 individual results. Subject digests before/
  after match, each retained output digest verifies, and every original input
  evidence file still matches the review commit. The docs check reports exactly
  the two archived target gaps already owned by k23; retain that nonzero result.
- 2026-10-29: Retire k78 only. K71 has live k75/k76 children, so no ancestor
  closes and no provider evidence is due on a newly finished producer review.
  K67/k62/k57/k54 and runtime remain held; no VM, freeze or acceptance ran.
