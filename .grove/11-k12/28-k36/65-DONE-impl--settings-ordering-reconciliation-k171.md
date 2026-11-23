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

The whole-harness integration is in `ORDERING-HARNESS-INTEGRATION.md`. It names
the changed source and controls that this reconciliation must consume.

k57 found that `bash -n A B` parses only A, and 18 Taskfile lines use that form.
`shellcheck` still parses those files. Record a disposition for the harness
files among them.

## Decisions (running log)

**Enumerate, then classify.** The ledger holds every distinct sentence of the
eight contracts. A sampled duty list could omit a duty without any signal.

**The k62 comparison is a guide.** k165 to k173 changed its subjects, so each
duty is classified again against the current source.

**Three gaps become three sibling leaves before k54.** k174 owns the interrupted
outcome, k175 the baseline and AXValue controls, and k176 the storage plan and
private path guard. They share the k36 scope, so no new node earns its place.

**The wait gap is measured.** A first mutation failed three controls, so the
claim that any wait can change was wrong. Seven later waits changed with all 113
tests passing, and the report states only that result.

**The `bash -n A B` lines stay.** `shellcheck` in the same task parses each
skipped harness file. A direct repair would reject valid Bats files.

**No review chain is cut for this leaf.** It changes no harness behaviour. Its
ledger check has its own failing controls, and k174 to k176 decide their own
reviews.
