# callback-publication-path-fit-k248 — brief

## Goal
Repair k243 finding 4. Before any consumer leaf, prove that every required
stress/boundary construction fits the admitted path-reference limit, and that
the maximal-edge and exact-path production boundaries are attainable, or
reclassify them with an argument. Resolve the limit itself if the proof needs it.

## Context
The k245 brief's Fit bullet; `publication-profile-review-k243.md` finding 4;
k247's profile (read its running log); publication-capacity.md "Edges, paths
and dependency preprocessing", "Per-dimension coverage" and "Complete
discriminator ledger" (B01–B20); publication-lifecycle.md (L01–L34, M01–M33);
publication-replay.md R01–R35 and "Report admission"; publication-path-controls.md
(Q01–Q41 witnesses); publication_profile.py `fit()`; k225/k229/k240 bodies.

## Done when
- A census-checked table lists every required construction: B01–B20
  (B12/B13/B18/B19 and both reserves included), L/M/E/R/topology stress, and
  the maximal-edge and exact-path files. Each row gives its base, anchor
  counts, V, per-base Q and path bound. Each bound fits the limit, or the row
  gives a smaller-base construction that keeps its boundary, or a stated
  tighter bound. Base variants of lifted histories carry a per-base headroom.
- The maximal-edge file has a stated anchor vector and completes: every other
  dimension fits, and the query work is exact at the frozen value.
- The exact-path file's boundary is shown attainable, or the coverage row is
  reclassified with an infeasibility argument and a labelled primitive. This
  is not deferred to k240, and no control is dropped or weakened to
  incomplete-resource.
- If the admitted limit or any other constant changes, publish the next
  profile version, rerun the census, and update the coverage and drift rows.
- The k225 fit gate, k229 envelope bullet, k240 path/edge/query-work bullets
  and the k205 plan table agree with the result.

## Notes
The k245 session found these; use them as leads, not results.
- At V = 4,138 the crude bound 2Q(V−1) fits 2^23 only when Q ≤ 1,013. A
  startup-base (V11) maximal-edge file needs fixed 200 + 5×161 commits + 5×3
  W-input members = 1,020 queries. That gives 8,439,480, just over 2^23. W-input
  and W-enter are uniform across V11–V25 (replay "Selected successor edge rules").
- A lane-local bound looks provable. In an acyclic construction, a same-lane
  query's raw and usable paths are no longer than the lane chain, and the loader
  caps a lane at 2,048 rows. M01/M07/M29 per-frame K/L/R orders, acquisition→enter,
  and the activity→input, activity→closed comparisons all appear to be
  same-lane; check each.
- Exact attainment of 2^23 is not evident. Forced (bypass-free) same-lane
  chains give each activity only 3 long queries. At V ≤ 4,138 that totals
  about 5.2M, and the queries toward S:29 are not forced long. The census family
  table charges 5 milestone queries per commit, while the k220 Q01–Q41
  inventory lists none. Reconcile this before exact arithmetic depends on it.

## Decomposition

The crude 2Q(V−1) bound is the obstacle in every part of this node, so a
tighter, proven per-query bound comes first. Each child leaves the census
green and the documents consistent.

- callback-publication-path-bound-k249: the per-query path bound (query
  families classified by endpoint lanes, BFS-shortest witnesses, the milestone
  query inventory reconciled) as a census bound function, and the maximal-edge
  file as its first real use: anchor vector, every dimension fitting, exact
  edge and query-work values. Coverage rows and k240 edge/query-work bullets.
- callback-publication-stress-fit-k250: the census-checked table of every
  other required construction, with smaller-base constructions or per-base
  headroom where the bound needs them. The k225 fit gate and k229 envelope
  bullet.
- callback-publication-exact-path-k251: the exact-path boundary, attained or
  reclassified with its infeasibility argument and labelled primitive. Any
  profile version the limit needs, with the census and k250 table rerun. The
  max_path_edge_refs coverage and drift rows, the k240 path bullet and the
  k205 plan table.
