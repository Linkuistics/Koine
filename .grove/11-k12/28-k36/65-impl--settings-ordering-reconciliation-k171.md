# settings-ordering-reconciliation-k171

## Goal

Complete the pre-runtime reconciliation that the k36 brief requires before k54
freezes a subject or requests a clone.

## Context

Read the "Contract ownership after k140" section of
`settings-ordering-caller-k57`. The exact archived contracts are in
`docs/verification/grove-tree-structure/`. Read
`ORDERING-PREFIX-RESULTS.md` for the k62 comparison and
`ORDERING-APPLICATION-RESULTS.md` for k52.

## Done when

- Each original duty of k53, k56, k61, k66, k71, k75, k80 and k85 has a recorded
  disposition, with its source and control evidence.
- The reconciliation consumes the k62 shared-scenario comparison and every
  earned review and integration, including the whole-harness and caller review.
- The applicable public API contracts of k52 are checked against primary
  sources. Each non-obvious call has a citation at its decision site.
- The reviewed preconditions, effects and OS discretion stay intact.
- Missing evidence is not a passed duty. Each precise gap gets a new leaf before
  k54.
- Koine failure, test-driver failure and assertion NOT RUN stay separate.

## Notes

This leaf runs after the whole-harness review and its integration. No freeze or
clone request may precede it. The final k36 outcome comparison is a separate
duty after k54, and it cannot replace this check.

k57 found that `bash -n A B` parses only A, and 18 Taskfile lines use that form.
`shellcheck` still parses those files. Record a disposition for the harness
files among them.
