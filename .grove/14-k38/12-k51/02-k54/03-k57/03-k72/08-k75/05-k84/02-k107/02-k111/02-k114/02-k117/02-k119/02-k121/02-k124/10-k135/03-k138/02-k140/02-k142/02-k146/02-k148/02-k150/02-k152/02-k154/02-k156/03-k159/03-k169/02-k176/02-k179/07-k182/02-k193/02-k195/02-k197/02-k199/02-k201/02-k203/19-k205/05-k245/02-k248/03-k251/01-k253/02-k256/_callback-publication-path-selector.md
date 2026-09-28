# callback-publication-path-selector-k256 — brief

## Goal
Add the census function that the k253 brief's first Done-when bullet names. It
runs the replay's raw/usable order selection over an abstract graph and does the
capacity doc's stored path-reference accounting. It is proved on small frozen
graphs, one for each branch, before it meets any real file.

## Context
publication-replay.md "Orders, cycles and independent support" and
"Dependency ownership and finite path selection": the procedure, the traversal
predicate, rule-ID and canonical-neighbour tie-breaking, the dependency SCC pass
with backward badness propagation and a first-discovery predecessor forest.
publication-capacity.md "Edges, paths and dependency preprocessing" and the
replay's max_path_edge_refs admission row ("two paths per ordered endpoint
query ... interned by edge plus chosen justification sequence"). K255's graph
shape. `Trace.cycle_components` gives the Trace-SCC semantics to match.

## Done when
- For each query the function returns raw and usable truth, direction and
  witness, each witness an edge sequence plus a justification sequence. It also
  returns the Trace-SCC and dependency-SCC witnesses, the bad receipts with
  their propagation reasons, and the stored path-reference total. It uses one
  BFS per query and a view of the adjacency, never graph mutation.
- Before it runs, one small graph per branch has its expected result frozen:
  noncyclic T, cyclic-only U, reverse F, disconnected U, usable U retaining the
  raw path, usable reverse F, crossing a cyclic-SCC vertex without a cyclic
  edge, same-vertex F, canonical-neighbour tie-breaking, and rule-ID
  tie-breaking (including a raw and usable witness with the same edges but
  different rules). Add a dependency-relation SCC and one badness propagated
  through an upstream arc.
- The accounting rule is stated in the census with its citation: each query's
  raw and usable witness is charged separately, even when they are identical,
  and empty or no-path results are counted. If the admission row's "interned
  by edge plus chosen justification sequence" is read to share storage, settle
  that reading here and record it in the running log. K257 then checks it
  against the archived 1,033.
- Each branch check fails under a deliberate mutation of the selector: filter
  after the raw BFS rather than before it, drop the cyclic-edge predicate,
  and reverse the tie order. `task design:check-publication-profile` is green,
  with its record under evidence/k253. No profile constant or document table
  changes.

## Notes
Keep it independent of `path_bound` and of k255's builder, and do not import
archive witnesses. K254 needs V ≈ 4,138, E ≈ 5,500 and a few thousand queries
in seconds. Time one synthetic graph of that size and record it. Q is distinct
ordered pairs: duplicated consumers share one result.

## Decomposition

The selector has three layers, and the replay states them as separate steps.
Raw order is a BFS over the frozen adjacency with only the cyclic-edge
predicate. The dependency pass is one SCC pass over the receipt relation D,
with backward badness propagation. It ends in a clean bit per justification.
Usable order is the raw search again, over the view those clean bits admit. The
first two layers are independent, and each has its own frozen graphs and its own
mutations. The third needs both, and it is the only one that produces a stored
path-reference total. So the accounting rule and the timing go there.

- callback-publication-raw-order-k260: the selector module, its input shape, the
  Trace-SCC witnesses and raw order with raw rule-ID choice. Frozen graphs:
  noncyclic T, cyclic-only U, reverse F, disconnected U, crossing a cyclic-SCC
  vertex without a cyclic edge, same-vertex F, and the canonical-neighbour and
  rule-ID ties. Mutations: drop the cyclic-edge predicate, reverse the tie
  order.
- callback-publication-dependency-pass-k261: the D-SCC witnesses, bad receipts
  with first-discovery propagation reasons, and the per-justification clean bit.
  Frozen graphs: a dependency-relation SCC, and badness propagated through an
  upstream arc. It is independent of k260's BFS.
- callback-publication-usable-order-k262: usable order over the clean view, the
  full per-query result, the stored path-reference total with its cited
  accounting rule and the interning reading, and the V ≈ 4,138 timing. Frozen
  graphs: usable U retaining the raw path, usable reverse F, a usable detour
  longer than the raw path, and the same-edges/different-rules witness pair.
  Mutation: filter after the raw BFS. Retiring this leaf closes this node.

Every child's record goes in the census under evidence/k253.

## Decisions (running log)

- **Three increments, split by the replay's own steps.** Raw order and the
  dependency pass share no computation. Each can be proved on frozen graphs and
  leave the census green. Usable order consumes both, so it comes last. Raw
  order comes first because it creates the module and the input shape.
- **The filter-after mutation needs a detour graph.** Of the listed branches,
  only the rule-ID pair (same edges, different rules) tells a filtered BFS from
  a raw path that is checked afterwards. A graph whose shortest raw path is
  unusable but a longer usable path exists is added, so the mutation fails on a
  path shape as well as on a rule choice.
- **Children are `impl`.** Each writes census code and evidence, not more tree.
