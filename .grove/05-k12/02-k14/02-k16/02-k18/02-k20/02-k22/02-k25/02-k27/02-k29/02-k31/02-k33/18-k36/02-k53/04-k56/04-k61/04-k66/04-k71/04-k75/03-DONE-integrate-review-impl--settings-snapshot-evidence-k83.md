# settings-snapshot-evidence-k83

**Integrates:** settings-snapshot-evidence-k82

## Goal
Triage the k82 review of the k79 snapshot and element readers. Apply the real
findings to the library, its controls, the report and the k75 handoff. Finish
before k80, k81 or k76 consumes the readers.

## Context
Read the findings in the k82 review leaf and its commit. The reviewed artifact
is commit d5e917ca. Grade each finding against the k75, k71 and k66 charters,
the reviewed ORDERING-EVALUATION-PLAN.md, the legacy callers and the v2.7.0
CLI, protocol and macOS agent sources.

## Done when
- Classify each k82 finding as real, a visible trade-off or noise, with a reason.
- Apply each real finding. Show a failing control before each behaviour repair.
  Keep the existing red receipts unchanged.
- Pass the Taskfile checks and record final digests and receipts.
- Bring the report, the k75 brief and the k80, k81 and k76 leaves into line
  with the result.

## Notes
No VM, candidate freeze, signal qualification or acceptance. Ordinary caller
bytes stay unchanged unless a real finding requires a change. K75, k76, k67,
k62, k57 and k54 keep their complete duties. Secret-bearing consent roots stay
private.

## Decisions (running log)

- 2026-10-29: Adopt k83 in the clean jj workspace and read findings from k82's
  commit d9a941f8 against k79 d5e917ca. Tier 2 graph generation
  2026-10-29T08:40:50Z supplies bounded discovery/traces; partial shell ranges
  and untracked Bats metadata are checked directly. No completeness claim.
- 2026-10-29: P2-1 is real: the four modes cannot qualify on_screen's optional
  match plus y/height or the required y-only calibration/reveal reads. Add
  optional-vertical and position-y requirements with one receipt/read each;
  keep zero height valid, missing required attributes unavailable, and caller
  bytes unchanged. Write failing controls before the production repair.
- 2026-10-29: P3-1 and P3-2 are real documentation gaps around visible strict
  trade-offs. Keep all-tree validation and required string value, recording that
  any missing tree refuses positives and stops the first settling read; an
  AXValue omission after cut is native-unverified and unavailable, never empty.
- 2026-10-29: P3-3 is a contract stated too broadly: selector evaluation depends
  on candidate data and syntax errors are discovered after dispatch. Narrow the
  claim and retain explicit characterization controls; do not invent a general
  jq selector validator for the current single-boolean caller predicates.
- 2026-10-29: P3-4 is real provenance debt. Explain the prior final baseline,
  docs-final receipt and the divergent test-16 baseline branch explicitly. Keep
  every existing receipt unchanged. Carry all limits into k75/k80/k81/k76.
- 2026-10-29: Before production edits, all three new vertical controls fail
  against k79's library: optional absence and y-only positives are rejected;
  invalid-mode refusal does not dispatch the required attribute-check read.
  The first filter accidentally omitted the y-only test; retain that two-test
  receipt separately and the corrected three-test receipt. Subject hashes are
  stable within both runs. Repair only the two requirement branches.
- 2026-10-29: The focused Taskfile check passes all 21 UI controls after the
  two-mode repair, including missing-tree positive/poll refusal and data-dependent
  selector characterization. These unchanged behaviors need no production fix.
  The narrow P2 repair is conclusively checked at the executable seam; spend no
  in-session reviewer and add no redesign/review chain. Final recorded checks
  follow completion of report/handoff edits. No architectural decision or ADR
  change is earned by this repair of the already reviewed evidence contract.
- 2026-10-29: Final recorded Taskfile runs pass: UI 21, shared guest adapter
  37, window 20, input 21 and physical 16 controls, with syntax/lint/format and
  the adapter's Python checks. Every named subject digest is stable within the
  recorded run and still matches afterwards. Each original k79 receipt equals
  its k82-commit bytes; all three ordinary caller files equal k79's hashes.
  check:docs exits 201 only for the two previously recorded missing archive
  links owned by k23; retain the failed check without clearing or expanding it.
- 2026-10-29: All five k82 findings have explicit dispositions in the durable
  report, the P2 repair has pre-repair red evidence, and k75/k80/k81/k76 carry
  the repaired interface plus native/selector limits. Retire k83 only. K80 and
  k81 remain live in k75, so there is no parent close cascade. K76/k67/k62/k57/
  k54 and every original/runtime duty remain live; no VM/candidate/freeze,
  signal qualification or acceptance. No live review names k83 as its producer,
  so this retirement owes no Creator line.
