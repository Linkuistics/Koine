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
