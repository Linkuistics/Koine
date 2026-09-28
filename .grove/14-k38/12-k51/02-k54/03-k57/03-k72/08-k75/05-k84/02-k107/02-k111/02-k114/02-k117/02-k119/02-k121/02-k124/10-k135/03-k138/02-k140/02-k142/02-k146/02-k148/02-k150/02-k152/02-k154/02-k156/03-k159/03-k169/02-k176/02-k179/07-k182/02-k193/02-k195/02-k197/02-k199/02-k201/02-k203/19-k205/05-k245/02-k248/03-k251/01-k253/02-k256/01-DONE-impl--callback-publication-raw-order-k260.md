# callback-publication-raw-order-k260

## Goal
Create the path selector and give it raw order. For each distinct ordered
query over an abstract graph, return raw truth, direction and witness (edge
sequence plus justification sequence), and the Trace-SCC witnesses. Prove it
on small frozen graphs before it meets any real file.

## Context
publication-replay.md "Orders, cycles and independent support": raw order is
BFS over noncyclic edges forward (T), then a full-graph forward path
(U/cyclic-only), then a noncyclic reverse path (F), then U/disconnected.
Witnesses are shortest, then canonical-neighbour order. Same-vertex strict
precedence is F by identity. A path may cross a vertex of a cyclic SCC if it
uses no cyclic edge. "Dependency ownership and finite path selection": the raw
witness takes the lowest rule/anchor ID on each edge, without the dependency
filter. `Trace.cycle_components` in callback-causal-fixture/analyze.py gives the
SCC and cyclic-edge semantics. publication_edges.py's `Edge`, `Justification`,
`Bundle`, `Query` and `Graph` are the plain data shape k257 will feed in.

## Done when
- A selector module takes lane-ordered vertices, rule-instance edges with IDs,
  and distinct ordered queries. It returns each query's raw truth (T, F, or U
  with the reason cyclic-only or disconnected), direction and witness. Each
  witness is a vertex-pair sequence plus the justification ID chosen per edge.
  Reverse witnesses are stored in edge direction. It also returns the Trace SCCs
  with their witnesses. It runs at most one BFS for each raw case of a query,
  over a view of the adjacency. It never enumerates paths and never mutates
  the graph.
- Before the selector runs, these frozen graphs have their expected results
  written down: noncyclic T, cyclic-only U, reverse F, disconnected U, crossing
  a cyclic-SCC vertex without a cyclic edge (T, or the result the rules give),
  same-vertex F, canonical-neighbour tie-breaking, and rule-ID tie-breaking on a
  parallel pair. Each result matches.
- Each check fails under a deliberate mutation. Drop the cyclic-edge predicate,
  and cyclic-only U turns T. Reverse the tie order, and both tie graphs change.
  The census records which checks each mutation failed.
- `task design:check-publication-profile` is green, with the selector's record
  in the census under evidence/k253. The Taskfile task's ruff and pyright steps
  cover the new module. No profile constant, `path_bound`, `control_bound` or
  document table changes.

## Notes
Keep the module apart from k255's builder. It may import the plain dataclasses,
but not `build`, `cycles` or `bad_receipts`. It must not import `path_bound` or
archive witnesses either. The graph, the selector and the archive are three
separate oracles for k257. Leave a slot for the per-justification clean bit that
k261 supplies, so the usable search can reuse this BFS with a different
traversal predicate rather than a copy of it. Define canonical-neighbour order
once, for example by index in the lane-ordered vertex list, and state it.
Duplicated consumers share one query.

## Decisions (running log)

- **Canonical-neighbour order is the vertex's index in the lane-ordered list.**
  For all six k220 files the flattened `Graph.lanes` equals `Graph.canonical`
  (checked in-session), so this is also the permutation `cycle_components`
  takes. Rule/anchor order is code-point order of the justification ID; the
  replay names no other ID order. Both orders are fixed once, in the view.
- **The witness is the first-discovery BFS path.** With neighbours visited in
  canonical order, that is the shortest path whose vertex sequence is
  lexicographically least from the source. Reverse (F) witnesses come from the
  same forward BFS started at the query's target, so they are in edge direction
  without reversal.
- **The usable slot is a `clean(justification ID)` predicate on the one BFS.**
  A step is admitted when its pair is noncyclic (unless the full-graph case)
  and some justification is clean; it takes the lowest clean ID. Raw order
  passes every ID. k262 passes k261's bit to the same function.
- **Mutations act on the view's data, not on selector branches.** Dropping the
  cyclic-edge predicate empties the view's cyclic set; reversing the tie order
  reverses every neighbour list and every justification tuple. Only the two
  named mutations run, plus one view mutation that vetoes every pair touching a
  cyclic-SCC vertex, so the crossing check has a mutation of its own.
  Disconnected U, same-vertex F, the direction checks and the SCC lists are not
  reached by any view mutation; the census lists them under
  `checks_no_mutation_reaches` rather than adding code knobs to kill them.
- **The census's `parse_model` tracemalloc peak moved (+56 bytes).** It is a
  measured memory figure that shifts with the loaded modules, not a profile
  constant; its checks still pass and no constant or table changed.
