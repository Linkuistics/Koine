# providers-k46

**Reviews:** providers-k3

## Goal

Adversarially read `providers-k3`'s decomposition before any design runs.
Several months of increments build on its ordering, boundaries and charters.
Report findings; do not fix them.

## Context

- `providers-k3`'s commit: the root brief's decomposition and coverage table,
  every new node brief and leaf body, and the running log in the retired
  planning leaf.
- `docs/requirements/modaliser-workflows.md` is the agreed scope and
  acceptance. `plan-k4` holds the narrowed baseline and its decisions.
- `docs/specs/machine.md` and the ADRs define the contract the increments
  extend.

## Done when

A findings report anchored to the planning commit separates real
decomposition defects from accepted trade-offs and noise. Worthwhile findings
reach an adjacent integration leaf through the review kind's procedure. An
empty review cuts nothing.

## Notes

Test these doubts in particular:

- **Working increments.** Does each increment node leave Koine working and
  deliver behavior a standalone client can demonstrate? Is any increment
  really a horizontal layer, or two stages that cannot be green apart, or too
  large to be one stage?
- **Ordering.** The questions are:
  - Is `provider-architecture` rightly first and rightly scoped? It covers
    capability separation, the cross-provider reference rule, error
    classification, scope and clipboard allocation.
  - Is `launch-and-open` the right pathfinder?
  - Does the interaction lifecycle belong in `held-interactions`, ahead of
    `context-menus`?
  - Does `iterm` rightly precede `herdr`?
  - Is placing `account-acceptance` late acceptable, given it is HITL?
- **Coverage.** Does every inventory row, label and list-state requirement,
  menu scenario, interaction requirement and acceptance bullet map to an
  increment and a client responsibility? Check this against the requirements
  themselves, not only the root brief's table.
- **Evidence discipline.** Is every evidence leaf bounded to one named decision,
  with an explicit stop? Are any native-feasibility questions missing, or
  placed after the design that depends on them? Candidates include the signing
  posture, VM display count, TCC-protected search and media routing.
- **Laziness.** Is any leaf speculative? Is any precise question from the
  planning leaf's notes lost, left as fog, or placed where no session will meet
  it?
