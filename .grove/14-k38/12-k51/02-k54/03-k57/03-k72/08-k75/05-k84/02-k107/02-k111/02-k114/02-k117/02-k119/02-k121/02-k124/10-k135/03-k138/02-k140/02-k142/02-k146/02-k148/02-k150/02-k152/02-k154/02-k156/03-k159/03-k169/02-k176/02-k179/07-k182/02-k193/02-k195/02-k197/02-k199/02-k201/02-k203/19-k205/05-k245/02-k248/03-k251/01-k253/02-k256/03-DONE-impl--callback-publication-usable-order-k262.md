# callback-publication-usable-order-k262

## Goal
Complete the selector with usable order and the stored path-reference total.
Search the unchanged adjacency with the traversal predicate (noncyclic and at
least one clean justification). Settle the accounting rule with its citation,
and time the selector at the scale k254 needs.

## Context
publication-replay.md "Dependency ownership and finite path selection": if raw
is T, a usable forward path gives usable T, and otherwise usable U retains the
raw path and its bad dependencies. If raw is F, the same search runs in
reverse: usable F if found, U otherwise. Raw U stays U. Each selected edge takes
the lowest rule/anchor ID among its clean justifications. Both justification
sequences are kept when the edge sequences coincide but the rules differ. The
replay's max_paths/max_path_edge_refs admission row in "Report admission and
resource failure" says "two paths per ordered endpoint query (raw and usable),
interned by edge plus chosen justification sequence" and "Count empty/no-path
query results too". publication-capacity.md "Edges, paths and dependency
preprocessing" says SCC and dependency witnesses share the limit. K260's raw
BFS and k261's clean bits.

## Done when
- For each query the selector returns raw and usable truth, direction and
  witness, the Trace-SCC and D-SCC witnesses, the bad receipts with their
  reasons, and the stored path-reference total. The usable search is k260's BFS
  under a different predicate, not a filter applied to the raw path.
- Before it runs, these frozen graphs have their expected results written down:
  usable U retaining the raw path and its bad dependencies, usable reverse F, a
  usable T whose path is longer than the unusable raw one, and a raw and usable
  witness with the same edges but different rules. Each result matches.
- The accounting rule is stated in the census with its citation. Each query's
  raw and usable witness is charged separately, even when identical, and empty
  and no-path results are counted. Report the witness references, the Trace-SCC
  references and the dependency references separately, and give the total.
  Settle whether "interned by edge plus chosen justification sequence" lets
  identical witnesses share storage. Record the reading in the node's running
  log, and give the shared-storage total beside the charged one, so that k257
  can check both against the archived 1,033.
- Filtering after the raw BFS instead of before it fails the detour graph and
  the rule-pair graph. The census records which checks failed.
- One synthetic graph at V ≈ 4,138, E ≈ 5,500 with a few thousand distinct
  queries runs in seconds. The time and the graph's shape are recorded.
- `task design:check-publication-profile` is green, with the record under
  evidence/k253. No profile constant or document table changes.

## Notes
Retiring this leaf closes k256. Check the k256 brief's Done when before
retiring, then hand the selector to k257. Do not run it on the real files. That
is k257's archive join. Q is distinct ordered pairs, not the census's
summed-branch Q. The synthetic graph is generated in the census, not committed
as a fixture. Keep it independent of `path_bound`.

## Decisions (running log)

- **A usable U over raw T or F has no path of its own.** It sets `retained` and
  points at the raw witness, which is stored once as the raw record, and lists
  each unclean chosen rule with its bad receipts (or `cyclic-edge`). Its usable
  record is empty and counts as an empty record. The k220 archive agrees in the
  one case it shows: raw cyclic-only U has an empty `usable_path`. Raw U and
  same-vertex F pass through unchanged with an empty usable witness.
- **The filter-after mutation keeps the raw witness if its chosen rules are
  clean.** It does not re-choose rules on the raw path. That is the naive reading
  of "filter applied to the raw path". It fails the detour graph (raw path
  unusable) and the rule-pair graph (raw rule r@1 unclean). It also fails both
  graphs' accounting. Re-choosing the lowest clean rule on the raw path would
  pass the rule-pair graph, so the detour graph is the one that catches that
  variant.
- **Accounting and the interning reading.** The charged total bills each
  query's raw and usable witness separately, one reference per witness edge.
  Every query counts two records toward `paths`, whether empty or not. Trace-SCC
  witness edges and D-SCC witness arcs are added. "Interned by edge plus chosen
  justification sequence" is read as storage. Identical sequences share one
  table entry across the whole report, so `shared_total` is reported beside
  `total`, but admission charges `total`. This matches how the archived 728 and
  1,033 were summed (raw + usable edge counts per query, identical ones
  included). The replay's "retain both justification sequences if the edge
  sequences coincide but their selected rules differ" implies that identical
  ones collapse in storage. Propagation links are not path references; the
  capacity doc charges them to support nodes.
- **All four frozen graphs matched on the first run.** None was changed after
  it ran.
- **Synthetic timing:** `synthetic(seed=262)` has five lanes, V = 4,138,
  E = 5,500 distinct pairs, H = 1,143, D = 1,641 and Q = 3,000. It has 8 Trace
  SCCs and 197 bad receipts, and every raw case appears, including usable U over
  raw T and over raw F. The whole selector took 3.4 s. The census fails above
  10 s. The measured `parse_model` recursion-limit peak moved again (+56 bytes).
  That is memory drift, not a constant.
