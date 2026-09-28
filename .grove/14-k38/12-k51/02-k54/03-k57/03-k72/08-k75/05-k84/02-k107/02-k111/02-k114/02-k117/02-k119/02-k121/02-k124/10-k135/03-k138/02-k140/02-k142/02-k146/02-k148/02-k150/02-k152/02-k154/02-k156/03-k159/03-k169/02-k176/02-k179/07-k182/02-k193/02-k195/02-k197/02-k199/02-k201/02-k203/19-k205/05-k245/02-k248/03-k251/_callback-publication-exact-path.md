# callback-publication-exact-path-k251 — brief

## Goal
Settle the max_path_edge_refs production boundary: show a real file attains
the admitted limit exactly (and the next reference fails), or reclassify the
coverage row with an infeasibility argument and a labelled primitive.

## Context
The k248 brief; k249 and k250's running logs, bound function and fit table.
publication-capacity.md "Per-dimension coverage"; publication-replay.md
"Report admission and resource failure"; the k240 body and the k205 plan table
in callback-capture-transfer.md.

## Done when
- The exact-path boundary is attained by a stated construction, or the row is
  reclassified with its infeasibility argument and a labelled primitive. It is
  not deferred to k240, and no control is dropped or weakened.
- If the admitted limit or another constant changes, the next profile version
  is published, and the census and the k250 table are rerun.
- The max_path_edge_refs coverage and drift rows, the k240 path bullet, the
  k225/k229 bullets if affected, and the k205 plan table agree with the result.

## Decomposition

Both outcomes need something the census lacks: the actual stored path
references of a concrete graph, rather than an upper bound on them. Every
census value so far is a bound. It is 2Q(V−1) per case, with the same-lane
lemma only where the case is acyclic. An exact 2^23 file, its +1 neighbour, or
a proof that no file fitting the other dimensions reaches 2^23 all depend on
actual BFS witnesses. Those come from the replay's raw/usable selection with
its dependency masks, so the instrument comes first.

- callback-publication-path-model-k253: an executable raw/usable path selector
  in the census, over an abstract row/edge/justification/receipt graph, with
  the capacity doc's stored-reference accounting. It is checked per item
  against the k220 derivation archive. The census stays green and no document
  changes. On its own it turns the archived "derived" counts into computed
  ones, including the multi-cycle 1,033 witness edges behind the R30/R31
  stress file's 1,040 charged references.
- callback-publication-path-attainment-k254: uses the model to settle the
  boundary, as either a generated construction at exactly 2^23 with a +1
  neighbour, or an infeasibility proof and a primitive. It then carries the
  result through the coverage and drift rows, the k240 path bullet,
  k225/k229 if affected, and the k205 plan table.

## Notes
The k248 Notes estimate that forced same-lane chains give each activity only
three long queries, about 5.2M at V ≤ 4,138. Treat it as a lead. That
estimate assumes no cycles, and cycles are the lead the other way. In
multi-cycle, a cyclic local edge in B and a bad input-B-2 ingress bundle push
the Q34–Q36 usable witnesses through the whole sampler lane: 88/87/76 edges
against spans of 23/22/11 (publication-path-controls.md, "Rule-issued query
census"). Each activity also carries four outside/overlap comparisons toward
S:29, which are about 50 edges even in those small files. The coverage row's
own premise, 256 activity rows per target with long lane paths, is this
mechanism at scale. Neither lead is a result.

## Promoted from k253 (path model closed)

The model is `publication_paths.select_orders(vertices, edges, bundles,
justifications, queries)`, which returns a `Selection`. For a real file,
`publication_archive.selection(case)` builds `publication_edges.build(case)` and
selects over its query pairs. `Selection.accounting["total"]` is what admission
charges: each query's raw and usable witness separately, plus Trace-SCC edges and
dependency-SCC arcs. `shared_total` interns identical witnesses and is reported
only. The selector matches the k220 archive item by item in all six files. The
archive is now only that join's oracle: `control_bound` in publication_profile.py
takes its witnesses from the selection. The computed per-file figures
(witness_refs / total / k250 per-case bound = lane bound + V + H + D) are: clean
728 / 728 / 6,073, upstream-cycle 728 / 730 / 6,073, multi-clean and
multi-clean-turn0 728 / 728 / 6,107, and both multi-cycle files 1,033 / 1,040 /
9,987. The R30/R31 multi-cycle stress figure for max_path_edge_refs is 1,040. The
selector runs 3,000 queries at V = 4,138 in about 3.4 s. It is independent of
`path_bound`, so each checks the other.
