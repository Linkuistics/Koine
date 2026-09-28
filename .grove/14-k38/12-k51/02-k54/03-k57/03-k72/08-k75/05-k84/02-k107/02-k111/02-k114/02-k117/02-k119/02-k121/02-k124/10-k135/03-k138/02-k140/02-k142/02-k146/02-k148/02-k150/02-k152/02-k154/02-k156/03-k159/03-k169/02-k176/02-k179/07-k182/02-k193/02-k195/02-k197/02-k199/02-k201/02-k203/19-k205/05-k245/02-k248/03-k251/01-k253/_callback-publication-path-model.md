# callback-publication-path-model-k253 — brief

## Goal
Give the census an executable version of the replay's raw/usable order
selection over an abstract graph, with the capacity doc's stored path-reference
accounting. Check it item by item against the k220 derivation archive, so that
k254 can compute the actual references of a generated file rather than bound
them.

## Context
publication-replay.md "Orders, cycles and independent support" and "Dependency
ownership and finite path selection" (the procedure, the traversal predicate
and tie-breaking). publication-capacity.md "Edges, paths and dependency
preprocessing" (two paths per query, SCC and dependency witnesses).
publication-path-controls.md "Rule-issued query census" and "Upstream join
controls". evidence/k220/query-derivation.json.gz with its manifest (the
`method` field names the derivation). The six path-controls/ files. The
unchanged loader `load_publication`, and `Trace.cycle_components` in
callback-causal-fixture/publication_files.py. publication_profile.py
`control_bound`, which currently reads archived witnesses.

## Done when
- A census function takes an abstract graph and returns, for each query, the
  raw and usable truth, direction and witness (edge plus justification
  sequence). It also returns the Trace-SCC and dependency-SCC witnesses and the
  stored path-reference total. The graph is lane-ordered rows, edges each with
  justifications (rule/anchor ID and mandatory receipt dependencies), receipt
  bundles with upstream arcs, and eligible distinct ordered queries.
- A small graph for each branch has its expected result frozen before it runs.
  The branches are noncyclic T, cyclic-only U, reverse F, disconnected U,
  usable U retaining the raw path, usable reverse F, crossing a cyclic-SCC
  vertex without a cyclic edge, same-vertex F, and canonical neighbour and
  rule-ID tie-breaking.
- All six k220 files match the archive item by item: truths, direction and
  physical witness sequences, plus SCCs and bad receipts. `control_bound` then
  uses computed witnesses. The computed totals are the archived 728 (four
  files) and 1,033 (both multi-cycle files), or the difference is explained
  and every document citing the figure is corrected.
- The accounting rule is stated with its citation: each query's raw and usable
  witness is charged separately, even when they are identical, as the archived
  1,033 does. If the capacity text's "interned by edge plus chosen
  justification sequence" is read to share storage, the leaf settles that
  reading and records it. For each file, the census checks that k250's per-case
  bound stays an upper bound on the model's total.
- Each new check fails under a deliberate mutation. `task
  design:check-publication-profile` is green, its record is under
  evidence/k253, and no profile constant or document table changes, apart from
  a corrected figure.

## Notes
The archive holds witnesses, not edges. The k220 session derived each file's
edge census in scratch code. Rebuild it from the committed files, the unchanged
loader and the replay's "Selected successor edge rules". If that rebuild alone
fills a session, decompose, and put the edge census first. Duplicated consumers
share one ordered-pair result (41 distinct queries per file). So a model's Q is
distinct ordered pairs, not the census's summed-branch Q, which k249 showed
charges the milestone pairs twice. K254 needs the model to run V ≈ 4,138,
E ≈ 5,500 and a few thousand queries in seconds. A BFS per query is enough.
Keep the model independent of `path_bound`, so that one can check the other.

## Decomposition

This node covers three separate artefacts. The first is the real-file edge
census that k220 kept only in scratch code. The second is the selector itself. The third is the item-by-item
join against the archive. Each child leaves the census green and has its own
check. As k251's Notes asked, the edge census comes first.

- callback-publication-edge-census-k255: the six files' abstract graphs from
  the unchanged loader and Trace. Checked against the archive's topology,
  endpoints and witness edges, with no selector involved.
- callback-publication-path-selector-k256: the raw/usable selector and the
  accounting rule, proved on small frozen graphs, one per branch. It is
  independent of k255 and of `path_bound`.
- callback-publication-path-archive-k257: the selector on k255's graphs, matched
  against the archive item by item. `control_bound` switches to computed
  witnesses, the 728 and 1,033 totals are settled, and the k250 bound is checked
  per file. Retiring this leaf closes this node.

Every child's census record goes under evidence/k253, as this brief's Done when
requires.

## Promoted from k255 (edge census closed)

The input shape is `publication_edges.build(case)`. It gives `edges`, rule
instances with stable IDs `<class>@<anchor row>`. It gives `justifications`,
keyed by edge ID, each with a rule, receipt dependencies and observations. It
gives `bundles`, keyed by receipt vertex, each with direct edge IDs and upstream
arcs. It also gives the 41 `queries`. The archive's `edges` counts distinct
ordered pairs, and the Trace adjacency is that set. D has no SCC. The
structural bad receipts (`bad_receipts(graph)`) already equal the archive's in
all six files. So k257's archive join can attribute any usable-order
disagreement to the selector rather than to the input. No archive error was
found.
