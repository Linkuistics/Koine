# grove-tree-structure-k142

**Integrates:** grove-tree-structure-k141

## Goal

Triage the k141 review findings and apply the real ones to the retained Grove briefs and the live task bodies.

## Context

Read the findings from the k141 review's commit, not from this body. The artifacts are `.grove/_BRIEF.md`, the k12, k36 and k96 briefs, the pending task supplements and `docs/verification/grove-tree-structure/README.md`. The original briefs in `docs/verification/grove-tree-structure/original-briefs/` stay byte-identical. The product evidence, closed budgets and runtime holds stay unchanged.

## Done when

- Classify each finding as a contract stated unclearly, a real issue, a visible trade-off or noise. Record each classification in this task.
- Apply each accepted correction to the live brief or task that must own it. Add no level, and do not edit any archived original.
- Update the README ownership table where a correction moves an owner.
- Recheck that all 110 leaf keys, names, kinds and order still match. Run the repository documentation check and report the two known k23 links separately.
- Retire only this leaf.

## Notes

Structure and documents only. No guest, native study, external message, cap expansion, freeze, acceptance or ancestor closure. Product work resumes at k125 after this leaf.

## Decisions (running log)

- 2026-11-15: Read k141's findings from its committed review at c58525ce and
  compare the retained briefs, pending supplements and exact original contracts.
  Finding 1 is a real issue: k36's final reconciliation occurs after k54's finite
  runtime, so it cannot replace the removed nodes' pre-runtime closing checks.
  Assign k62 the shared-scenario comparison before k57; assign k57 the complete
  source/control reconciliation of k53/k56/k61/k66/k71/k75/k80/k85 before k54.
  k54 must consume that completed, reviewed reconciliation before freeze or any
  clone request. Missing duties earn precise leaves before runtime; add no level.
- 2026-11-15: Finding 2 is a real issue: the active owners omit the original
  separation of Koine failure, test-driver failure and an assertion that did not
  run, and the primary-source/API decision-site citation duty. Restore the
  distinction in the root/Settings/evaluation handoff and k54 reporting. Put the
  k52 API/source check in k57's pre-runtime reconciliation and k36 completion;
  this planning correction does not assert those product checks already passed.
- 2026-11-15: Finding 3 is a contract stated unclearly: k36 and k96 already state
  joint completion, but the heading obscures the retirement check. Give each an
  explicit Done when section while preserving its completion text. The other
  review observations require no change: preserved identities/archives, flat
  chains, reading reduction and the separate k23 link task remain supported.

## Verification

- 2026-11-15: Compared the identity map's 110 original leaves in order with the
  current tree: keys, names, kinds and outcomes match, allowing only k140's
  expected DONE transition. The only added identities are k141/k142. All 98
  original terminal bodies remain byte-identical; the other 11 pending original
  bodies remain exact prefixes of their current bodies. Original bytes were
  checked against their recorded SHA-256 values and revision 688bc187.
- All 31 archived briefs match their recorded SHA-256 values and headings, with
  the archive file set unchanged. Swapping ordered identities and altering an
  archived byte in memory both fail the corresponding comparisons. Digests of
  the identity map, every current Grove Markdown file and every archived brief
  (148 subjects) were unchanged before/after verification.
- Grove's brief-chain reader accepts both this leaf and k125: four retained
  briefs and at most three ancestor directories. k125 remains the next live
  product leaf after k142. Enumerating Reviews lines found only terminal reviews;
  no live review names this producer, so no Creator line needs updating.
- `mise exec -- task check:docs` reports only the two known k23 missing targets:
  `context-predicate.txt` and `context-qualify-filter.sh`, both linked from
  `docs/verification/settings-activation/context-initial-inputs/CONTEXT-PLAN.md`.
  The command exits with failure for those existing links; it is not a clean
  documentation-check result. Their repair stays with k23.
- Index coverage reports no recorded gaps for the evidence paths and bounded
  Grove/archive scopes at generation 2026-11-14T14:42:32Z. Changed Markdown is
  verified directly from source/diff rather than inferred from that index.
