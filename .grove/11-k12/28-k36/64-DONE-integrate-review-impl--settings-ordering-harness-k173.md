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
finding with the actual source and the k36 brief. Also compare it with the
accepted spec and `ORDERING-EVALUATION-PLAN.md`. The conclusions of the review
are not the charter of this task.

## Done when

- Each finding has a source-grounded disposition under the integration
  procedure, including visible accepted trade-offs and rejected noise.
- Each earned repair has meaningful failing controls. After the repair, the
  existing Taskfile entries verify it.
- The handoff identifies the source and control evidence that k171 must
  reconcile, with no claim of native behaviour or runtime acceptance.

## Notes

This task precedes `settings-ordering-reconciliation-k171` and
`settings-ordering-qualification-k54`. Run no VM, clone or signed subject here.
Preserve the accepted finite caps, first-failure rules, private originals and
all surviving original duties. No protocol relaxation or product/causal
ancestor closure follows from integration alone.

## Decisions (running log)

- R1 is a real issue. The old source settled a forged E01 as `qualified`, with
  cleanup `confirmed`. The `settle` verb now takes no phases.
- R2 is a real issue. A wrong build or bundle produced `rejected`. A separate
  `subject` phase now guards the rejection, and later failures cannot erase it.
- R3 is a real issue. A lost guest stream left the audit `passed`. The audit now
  takes the required files from each attempt's transport and outcome.
- A recurrence in a run that lost its caller stays `unresolved`, because that run
  has no screenshot audit. This trade-off is visible in the integration record.
- The repairs earn no new review chain. They are bounded, they change no protocol
  and a control detected each of 22 mutations.
- The dispositions and the k171 handoff are in `ORDERING-HARNESS-INTEGRATION.md`.
