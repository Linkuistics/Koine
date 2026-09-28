# callback-publication-dependency-pass-k261

## Goal
Add the replay's dependency preprocessing to the selector. That is one SCC pass
over the receipt-dependency relation D, and backward badness propagation with a
first-discovery predecessor forest. It ends in the dependency-clean bit for
each justification. Prove it on small frozen graphs.

## Context
publication-replay.md "Dependency ownership and finite path selection": D is
the finite directed receipt-dependency relation. One iterative SCC pass marks
dependency cycles. Badness propagates backward from those receipts and from any
receipt owning a cyclic Trace edge, in canonical receipt/arc order, with one
witness per dependency SCC. A direct edge reference does not recurse; only
upstream-receipt references do. A justification is dependency-clean iff none of
its explicit receipt dependencies is bad and none of its own mandatory edges is
cyclic. publication-capacity.md "Edges, paths and dependency preprocessing":
the dependency witnesses cost O(H+D). K260's module and its Trace-SCC result
(the cyclic edges).

## Done when
- The selector returns the dependency-SCC witnesses and the bad receipts. Each
  bad receipt carries its reason: the cyclic edge it owns, its D-SCC, or the
  upstream arc through which it inherited badness, with the first-discovery
  predecessor. Each justification gets a clean bit. Each receipt and arc is
  visited a bounded number of times, and no transitive union is materialised.
- Before the pass runs, these frozen graphs have their expected results
  written down: a dependency-relation SCC, badness propagated through an
  upstream arc to a downstream receipt, a direct edge reference that does not
  recurse into its own justification's dependencies, and a clean receipt beside
  a bad one. Each result matches, including the propagation reasons.
- Each check fails under a deliberate mutation. Propagate forward instead of
  backward. Skip the D-SCC marking. Let a direct edge reference recurse. The
  census records which checks each mutation failed.
- `task design:check-publication-profile` is green, with the record under
  evidence/k253. No profile constant or document table changes.

## Notes
Do not call publication_edges.py's `bad_receipts` or `dependency_sccs`. The
structural set there is the oracle k257 compares against, so this pass must be
written from the replay text. The real files have no D-SCC, so only a frozen
graph exercises one. It is independent of k260's BFS. It needs only the set of
cyclic edges, so a test may give that set directly.

## Decisions (running log)

- **D's arcs run receipt → upstream receipt; badness runs against them.** Only
  `Bundle.upstream` makes an arc. `Bundle.edges` never does, so a contributor
  justification that depends on its own receipt cannot form a self-loop. The
  pass takes the cyclic edge IDs as a set, and `cyclic_edge_ids(view)` derives
  that set from k260's view. That is how k262 connects the two layers.
- **Canonical order and reasons.** Receipts go in vertex-list order, and each
  receipt's arcs in its upstream receipts' order. Seeds are a multi-source BFS
  in canonical order. A seed that is in a D-SCC reports the SCC (named by its
  first member) before any cyclic edge it owns. Otherwise it reports the
  lowest-ID cyclic edge it owns. An inherited receipt reports its
  first-discovery predecessor, and the arc is (receipt, predecessor). The D-SCC
  witness is the shortest cycle, taken in canonical order, from the SCC's
  first member back to itself. A self-loop counts as an SCC.
- **The SCC pass is written here, as an iterative Tarjan.** It does not reuse
  `Trace.cycle_components`, because the replay says D gets "not another causal
  engine or a second Trace pass". A scratch check against
  `Trace.cycle_components` and a naive badness fixpoint matched on 3,000
  random relations. It is not in the census. At H = 4,200 with 3 arcs per
  receipt, the pass took 9 ms.
- **The clean bit's "own mandatory edges" is the justification's own edge.**
  An abstract justification names exactly one edge (its ID). Cyclic edges
  elsewhere in its bundles reach it through bad receipts.
- **One frozen graph was changed after its first run.** In the D-SCC graph, the
  SCC member R2 also owned a cyclic edge. Skipping the D-SCC marking then left
  every member bad, so no clean bit could change, and the required
  "clean bits" catch was mis-stated. The graph input (not the pass) was changed
  to a pure D-SCC. The SCC-before-cyclic-edge rule moved to a new graph, "D-SCC
  seed owning a cyclic edge", whose expectation was written before it ran.
- **Mutations are keyword flags on the pass.** The three mutations change the
  algorithm itself (direction, seeding, arc set), not view data. With
  recursion enabled, "bounded visits" also fails. That happens because the
  mutation adds arcs beyond the input's D, and the census lists it as such.
