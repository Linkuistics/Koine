# settings-ordering-harness-k173

**Integrates:** settings-ordering-harness-k172


## Goal

Triage the committed whole-harness and finite-caller review before k171 consumes
the implementation. Apply findings that meet the agreed acceptance and
material-risk threshold, and verify the resulting implementation.



## Context

Read the findings from the commit of `settings-ordering-harness-k172`. Its
durable report is
`docs/verification/settings-activation/ORDERING-HARNESS-REVIEW.md`. Compare each
finding with the actual source, the k36 brief, the accepted spec and
`ORDERING-EVALUATION-PLAN.md`; the review's conclusions are not this task's
charter.

## Done when

- Each finding has a source-grounded disposition under the integration
  procedure, including visible accepted trade-offs and rejected noise.
- Each earned repair has meaningful failing controls and appropriate post-fix
  verification through the existing Taskfile entries.
- The handoff identifies the source and control evidence that k171 must
  reconcile, with no claim of native behaviour or runtime acceptance.

## Notes

This task precedes `settings-ordering-reconciliation-k171` and
`settings-ordering-qualification-k54`. Run no VM, clone or signed subject here.
Preserve the accepted finite caps, first-failure rules, private originals and
all surviving original duties. No protocol relaxation or product/causal
ancestor closure follows from integration alone.
