# callback-publication-path-bound-k249

## Goal
Replace the crude 2Q(V−1) per-case argument with a proven per-query path
bound that the census computes, and use it to show the maximal-edge file
attains its edge and query-work boundaries while fitting the admitted path
limit.

## Context
The k248 brief (its Notes are leads, not results). publication-replay.md
"Orders, cycles and independent support" and "Dependency ownership and finite
path selection" (BFS-shortest raw/usable witnesses, the reverse-refuter
search, local edges needing no receipt dependency). publication-lifecycle.md
M01–M33 ("Check L before h using local physical order"). publication-capacity.md
"Rules, claims and queries", "Edges, paths and dependency preprocessing" and
"Per-dimension coverage". publication-path-controls.md "Rule-issued query
census" (Q01–Q41). publication_profile.py `fit()`, `case_queries()` and the
FAMILIES table. The k240 body.

## Done when
- Every query family (the legacy per-base order polynomial terms and each
  successor family with a Queries entry) is classified by endpoint lanes,
  with the argument for each class's path bound: same-lane witnesses bounded
  by the lane span, and a stated bound for cross-lane ones. Acyclic and cyclic
  constructions are both covered, or the bound states its acyclicity premise.
- The milestone query charge (5 per commit, 177 fixed) is reconciled with the
  k220 Q01–Q41 inventory, and the census charges what the reconciliation finds.
- The census computes the bound per construction and rechecks the lifted
  V11–V25 corpus and the six path-control files with it.
- The maximal-edge file has a stated anchor vector on a named base: all 5,499
  edges and justifications, the query-work model at exactly 4,699,080, every
  other dimension inside the profile, and path references under the admitted
  limit by the new bound. The census checks this.
- The max_edges, max_edge_justifications and max_query_work_bytes coverage
  rows and the k240 edge/query-work bullets agree. If a constant changes, this
  leaf publishes the next profile version.

## Notes
The admitted limit stays 2^23 here unless the bound forces a change. Exact-path
attainment is k251's, and the full stress table is k250's.

## Decisions (running log)

- **Decomposed k248** into k249 (bound + maximal-edge file), k250 (stress
  table) and k251 (exact path). Every part needs a bound tighter than
  2Q(V−1), so the bound comes first.
- **Same-lane lemma.** Take a query whose endpoints are in one lane at
  positions i < j (either direction), where the lane segment between them has
  no cyclic local edge. Then each retained witness (raw and usable, forward
  or reverse) has at most j − i edges. The reason: the segment's local edges
  are noncyclic and have no receipt dependency, so it is a path in both the
  noncyclic and the usable view. A forward path j → i would close a cycle
  through the segment, so the reverse direction resolves as F with the
  segment as its refuter. BFS returns shortest witnesses. A cross-lane
  witness keeps the V − 1 bound. On the six k220 files, all 384 same-lane
  witnesses with an acyclic segment obey the lemma. All 12 that exceed their
  span (Q34–Q36 raw and usable in both multi-cycle files) cross a cyclic
  local edge, so the premise is necessary.
- **Milestone reconciliation.** Every milestone operand pair lies in one
  owner's lane. Lifecycle checks them by "local physical order" and never
  installs an L→R edge. Where an operand pair is a semantic coordinate pair,
  it is the legacy producer pair that k220 lists under its legacy consumer
  (Q03–Q13: activation, settle, armed, finished and input replies). The
  K-before-begin and synchronous L rules are stage-2 local facts, which k220
  says issue no query. The census's 5 per commit and 177 fixed queries
  therefore charge these pairs a second time. That is a safe upper bound, so
  the charge stays, classified same-lane in any lane. No constant changes.
- **Lane classes.** The census tags every legacy order site reachable from the
  three base entries with its pairs' lane classes (tgt, smp, ctl, app, cross).
  L1703's activity→B-input call counts as cross even though it is same-lane
  for a B activity. Successor families are classed as follows. Milestones are
  any-lane. Membership is tgt. Candidate (6) and fixed sample-state (17)
  orders are cross. An activity's two B-input comparisons are same-lane in B
  only for a B activity. Acquisition order is smp. The per-case bound charges
  2 × queries × witness bound, plus V + H + D witnesses. Without an
  acyclicity premise every witness is V − 1. The lifted corpus is worst at
  4,364,675 (v18 live-status) under any cycles, or 1,737,805 if acyclic.
- **Maximal-edge file.** It uses the V11 preheld startup-failure base, with no
  legacy order site, 5 lanes and V = 4,138. Supervisor has 1,428 rows,
  controller 717, sampler 678, B 660 and C 655. Every edge class is at its
  maximum: local 4,133, contributing 1,281, relay 65, production 10,
  table/use 6, W-input 3 and W-enter 1, for 5,499. Each same-lane join is
  placed non-adjacent, so it adds a distinct pair. Query work is exactly
  4,699,080. The bound is 3,676,590 references acyclic. It is 12.6M without
  the lemma, so the lemma is necessary. The kind maxima force malformed
  content. Reaching 1,281 begins under 640 call IDs per owner and 8 attempts
  per frame needs ≥ 81 app frames, so 86 protocol origins (21 unrelayed)
  exceed the origin cap. App protocol frames carry null embeddings, and the
  one embedded receive is R(armed), so raw semantic stays at 1,028. That
  leaves 65 non-semantic local rows (18 surplus budget_stop in B). The origin
  and local anchors feed no charged dimension; local feeds only V.
- **Neighbour.** One surplus local row becomes a contributing begin joined to
  the B01 orphan result, so V is unchanged and E = 5,500. The per-begin
  families (2 claims, 2 obligations, 15 diagnostics, 19 nodes, 13 refs) are
  stage-2 records. They fit inside the stage-5-and-later shares, which are
  still unused at stage 3. A justification is charged before its pair is
  interned, so the neighbour reports max_edge_justifications. max_edges can
  never be the first to overflow at the same limit, so its +1 side is
  primitive only.
- **Verification.** The census is green with the unchanged `/2` profile, and
  its record is now evidence/k249. I mutated each new check on a scratch copy
  and saw it fail: lemma without the cyclic premise, no same-lane query, a
  stale site, an unclassified base site, a wrong arity, a family count, a
  row short, a missing W-enter, the file without the lemma, and a 9-attempt
  frame.
