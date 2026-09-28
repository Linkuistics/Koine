# callback-publication-path-attainment-k254 — brief

## Goal
Settle the max_path_edge_refs production boundary with k253's model. Either a
generated file stores exactly 8,388,608 path references and its neighbour
8,388,609, or a proof shows that no file fitting the other dimensions reaches
2^23 and the row becomes a labelled primitive. Carry the result into every
document that states the row.

## Context
The k251 brief's Notes (both leads). K253's model and its accounting rule.
K249's maximal-edge file and neighbour, which set the pattern for a
census-checked construction and a neighbour that names its dimension. K250's
table, the per-base headroom and the startup ceiling. publication-capacity.md
"Per-dimension coverage" and "Complete discriminator ledger".
publication-replay.md "Report admission and resource failure", including the
stage order in which dimensions are charged. The k240, k225 and k229 bodies;
the k205 plan table in docs/verification/callback-capture-transfer.md.

## Done when
- Attained: a named base and a generated graph (rows, edges, justifications,
  receipt bundles, distinct queries) are in the census. The model's total is
  exactly 8,388,608, every other dimension fits by k249/k250's methods, and the
  graph is a legal history (no content outside the envelope). A neighbour at
  8,388,609 reports incomplete-resource naming max_path_edge_refs, with no
  earlier-charged dimension overflowing first.
- Or infeasible: a stated upper bound on actual stored references holds for
  every file that fits the other dimensions, is below 2^23, and is checked by
  the census against the model on the worst constructions tried. The row
  becomes "No" with that argument and a primitive at 8,388,608, and the R30/R31
  stress column keeps its injected file.
- Nothing is deferred to k240, and no control is dropped or weakened. If the
  admitted limit or any constant changes, the next profile version is
  published, and the census and the k250 table are rerun.
- The max_path_edge_refs coverage row and its drift mutant, the k240 path
  bullet, the k225 fit gate and k229 envelope bullet if affected, and the k205
  plan-table row agree with the result. Each new check fails under a deliberate
  mutation. `task design:check-publication-profile` is green, with its record
  under evidence/k254.

## Notes
Explore before proving. Run the model on the obvious candidates first: long
detours forced by target-lane cycles and bad ingress bundles, at many
activities per target. If the best candidate falls well short, those runs
show where the proof must bite. Exact tuning needs a +1 lever. One candidate
is a single witness whose length can be moved by one row without touching any
other query's witness. Name the lever and show its isolation. A total built
from queries whose witnesses shift together cannot be tuned. If neither
outcome can be settled in one session, decompose.

## Decomposition

Neither outcome can be settled on the six k220 files. The model runs on real
graphs only, and nothing yet produces a graph at production scale. So the first
increment is an instrument: a generator of legal histories at scale. The second
uses it to explore, as the Notes ask, before anything is proved or tuned. The
third settles the boundary, and the fourth carries the result into the
documents. Each child leaves the census green and records under evidence/k254.

- callback-publication-path-generator-k265: a census generator that scales a
  V18 history (the base of all six k220 files) by stated parameters. It emits
  the k253 input shape with every query's endpoints from its rule recipe, and
  it checks the history against the envelope. At the clean file's parameters it
  reproduces that file's graph, 41 queries and 728 witness refs. At scale, its
  counts agree with `query_classes`, and the model's total stays within
  `path_bound`.
- callback-publication-path-candidates-k266: runs the model on the obvious
  candidate families at production scale. It records each candidate's actual
  total and the dimension that stops it growing. It ends in one of two ways. A
  candidate at or above 2^23 comes with a named +1 lever whose isolation is
  shown. Otherwise the leaf names the mechanism an infeasibility proof must
  bite on. No document changes.
- callback-publication-path-boundary-k267: settles the boundary as attained
  (exactly 8,388,608, a +1 neighbour, and the stage order) or infeasible (a
  stated bound below 2^23, checked on the worst constructions). If a constant
  changes, it publishes the next profile version and reruns the census and the
  k250 table. Any document table the census compares changes here too.
- callback-publication-path-coverage-k268: carries the result into the prose.
  That covers the coverage row and its drift mutant, the k240 path bullet,
  k225/k229 if affected, and the k205 plan table. Retiring this leaf closes
  this node, then k251.

## Notes (planning)

Arithmetic worth keeping in view. The limit needs Σ(raw + usable) witness
edges + Trace-SCC edges + D-SCC arcs = 8,388,608. With V ≤ 4,138, and Q ≤
18,042 by the profile's own order-claim count, each witness must average at
least about 232 edges (about 465 per query). The startup base is a poor start.
The maximal-edge file charges 1,520 queries, 982 of them milestone charges, a
family k249 showed can charge a legacy pair twice. Even at 1,520, each witness would need about
2,760 edges, two-thirds of V. So Q has to come from a selected base, at about
25 queries per target row, with witnesses forced long. The two forces are
target-lane cyclic local edges and bad bundles that push usable witnesses
through a long lane. Whatever makes Q large also charges claims, diagnostics,
support and query work. Any of these that the replay's stage order charges
before paths is one the neighbour must not overflow first.
