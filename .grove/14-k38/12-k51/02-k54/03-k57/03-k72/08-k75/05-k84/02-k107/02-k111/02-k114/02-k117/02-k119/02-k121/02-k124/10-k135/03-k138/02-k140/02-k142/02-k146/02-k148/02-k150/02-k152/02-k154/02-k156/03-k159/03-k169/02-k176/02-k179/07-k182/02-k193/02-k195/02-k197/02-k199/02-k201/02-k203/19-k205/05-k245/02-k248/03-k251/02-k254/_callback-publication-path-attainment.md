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
- callback-publication-generator-legal-k273 (inserted by k272): makes the
  scaled insertions loader-legal and writes real observations files that the
  unchanged loader and `build` read. It sits before k267, whose attained file
  must be a legal history.
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

## Promoted from k265 (closed by k272)

- The instrument is `generate(BASE, RECIPES, vector, envelope)` in
  publication_generator.py. Its `Vector` holds the cycle parameters (`splits`,
  `upstream`) and the scaling parameters (`rows`, `activities`, `members`,
  `commits`, `begins`, `acquisitions`). It reproduces all six k220 files.
  Every history it generates is checked against `envelope_violations`.
- At production scale (`SCALE`: V = 4,138 and 2,413 queries), the model's
  total is 583,486 acyclic and 805,366 with multi-cycle's cycle. The
  per-query lane bound is 10.3M and 13.5M, and `path_bound` gives 25.4M and
  72.7M. Selection takes about 2.3 s. The V18 lift reaches under a tenth of
  2^23, so k266 must force much longer witnesses than a lift's recipes give.
- Queries per source and lane class equal the charge for comparisons,
  membership and per-acquisition. The rest are stated differences (profile
  `SCALE_DIFFERENCES`): the milestones (k249's double charge, none issued), the
  fixed-6 and fixed-17 families (5 and 8 issued), and the legacy per-row
  polynomial.
- Legality is envelope-only so far. The scaled producer records are not V18
  rows, and added app frames have no producer send. See k273.

## Promoted from k266

- Outcome: 2^23 is not reached on any candidate tried. The best is
  `CANDIDATES["combined"]` in publication_generator.py, at 5,906,808 stored
  refs (70.4 %, V = 3,585, Q = 2,466). It combines target frames 54/55 at 9
  begins after each finish-X receipt, multi-cycle's split, 202 sampler neutral
  rows after m_end in place of the acquisitions, and 228 controller neutral rows
  plus 46 supervisor local rows after the controller's finished-sampler receipt.
  Comparisons carry about 97 % of every total.
- Mechanism for k267's proof: per-target charge. A target interior row (its
  lane after the finish-X receipt) is charged only by its own target's
  activities (8 each). A witness crosses at most 2 rows of the other interior,
  the first pad frame's commit and begin, and then exits by the contributor
  edge. Connector rows count only when exit-free (neutral or local rows),
  because frames leak through their exits. The supervisor lane bypasses every
  other hop, and wider cycles empty the usable witnesses. At the envelope's
  maxima the conjectured bound is 7,657,312, below 2^23 by about 0.73M. Reading
  the two interiors as one shared funnel gives 12.8M. So the proof must show
  that no witness charges both targets' interiors: the only route between them
  exits early through a frame's contributor edge into the supervisor lane.
- The census (`path_candidates`) checks the premise on every witness and the
  bound on every candidate. It uses two candidate-only caps beyond
  `envelope_violations`: producer seq ≤ 256 per app and case local rows ≤
  LOCAL_ROWS. The envelope check itself caps local rows only at 2,048 per lane,
  and k272's SCALE uses 829 supervisor local rows. k273 and k267 should decide
  whether local rows beyond 64 are legal. The candidates hold them to 64.
- Not yet charged at candidate scale: claims, diagnostics, support and query
  work by k249's method. If k267 settles "infeasible", its checked worst
  constructions are these candidates.

## Promoted from k274 (legal records)

- Every inserted record is now a V18 producer row, and every added app frame
  commits a producer send (`ADDED_FRAME`, unrelayed). Graphs, pairs and model
  totals are unchanged. See the k274 log for the rules.
- A frame costs a producer seq, and the loader caps each app at 256. A
  target's activities and its interior frames therefore share one budget of
  256 minus its base rows (B 238, C 247). The same holds for the sampler's
  acquisitions or funnel rows and its frames, and for the controller's
  neutral rows and its frames. No padded k266 candidate, and neither SCALE
  run, can be written legally (census `LOADER_SEQ_OVER`). The per-target
  conjecture's envelope figure (7,657,312) assumes n = 240/247 activities
  *and* 2,679 interior rows. A legal file cannot have both, so that bound is
  loose. k267's attained file, or its worst constructions, must pass
  `loader_seq_over`.
