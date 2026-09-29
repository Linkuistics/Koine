# callback-publication-milestones-k235

## Goal
The complete publication/drain milestone inventory at original coordinates:
K/L/R for every producer obligation, receiver gates, drains and exits.

## Context
publication-lifecycle.md "Milestones and original coordinates", "Complete
producer obligation inventory", "Discriminating histories and independent
expectations".

## Done when
- M01–M33 each mapped and reported with its K/L/R facts and first causes.
- Controls: L20–L31 and L33 with neighbours/mutants/permutations; graceful
  boundary without actual-exit credit (L31); every M03–M13 receiver gate
  refused when replaced by sender K or L (L30).
- No cleanup, exit or native credit inferred from transport facts.

## Notes
K180 composes all phases from these implemented milestones. M32/M33 pending
obligations are local records in `lifecycle`. M01–M31 issue order queries and
belong to `milestones`, which is not sidecar-eligible.
