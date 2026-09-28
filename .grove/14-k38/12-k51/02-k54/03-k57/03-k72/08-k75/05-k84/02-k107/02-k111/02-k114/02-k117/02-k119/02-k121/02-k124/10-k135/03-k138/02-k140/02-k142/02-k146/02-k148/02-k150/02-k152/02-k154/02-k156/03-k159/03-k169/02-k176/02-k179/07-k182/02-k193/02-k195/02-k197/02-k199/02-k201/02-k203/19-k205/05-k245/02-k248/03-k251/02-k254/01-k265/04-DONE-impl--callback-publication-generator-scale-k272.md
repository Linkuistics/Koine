# callback-publication-generator-scale-k272

## Goal
Run the generator at production scale and check it against the profile's
counts and bounds.

## Context
The k265 brief (Done when, scale bullet and Notes). `query_classes`,
`path_bound`, `Construction` and `BASE_ENTRY` (V18 → analyze_selected) in
publication_profile.py. The k249 double-charged milestone pairs.

## Done when
- At V ≈ 4,138 with thousands of queries, the generated queries per lane
  class equal `query_classes` for the matching `Construction`. Any difference
  is explained family by family, and k249's double-charged milestone pairs
  are the expected one.
- The model's `total` is at most `path_bound`'s per-case bound. The run time
  is recorded.
- The loader oracle is decided. Either the generator writes a real
  observations file that the unchanged `load_publication` and `build` read, or
  the leaf records why the abstract graph stands in for it.
- The census is green under evidence/k254, and k253's record stays
  byte-identical. No profile constant or document table changes.

## Decisions (running log)
- Two production-scale vectors (`SCALE`, built by `at_scale`): the clean and
  multi-cycle cycle vectors, each grown until B, C and the sampler reach the
  eligible producer seq 256 (200 activities and 38/47 members per target, 202
  acquisitions). Case commits reach 161 at nine begins each, with no app past
  80 frames, and neutral supervisor rows make up V = 4,138. Each run issues
  2,413 queries.
- The matching `Construction` comes from the generated history itself: lane
  rows, producer rows per role, all 161 frames, the actual activities and
  members, acquisitions, bundles and upstream arcs, and acyclic iff the
  selector finds no Trace SCC. The base entry is `BASE_ENTRY[18]`.
- `query_classes` is now the sum of `query_sources` (the legacy polynomial,
  then each `QUERY_LANES` family). Its values are unchanged, and k253's record
  is byte-identical.
- Each distinct generated query is charged to its first recipe's family, or
  to the legacy sites when the recipe has no family. Its lane class is that
  family's class (b-input for a B-lane activity pair), or the one tag its
  legacy sites share. A source may not exceed its charge in any class. It must
  equal its charge unless `SCALE_DIFFERENCES` states why not. A stated reason
  on a source that matches its charge also fails.
- k269's `acquisition` recipe is split. The per-acquire acquire->f_begin
  (site 1687) is now owned by the per-acquisition family, and the hint chain
  (site 1697) stays with the fixed family. A pair issued once per acquisition
  cannot belong to a fixed count. The issue order is unchanged, so all six
  reproductions hold. Two caveats: legacy orders only the *matching*
  acquisition (analyze.py 1678-1686), and the family's name says
  acquire->enter (site 1691, the preheld branch). Both issue one sampler
  query per acquisition.
- Result, family by family, at both runs: comparisons 404 b-input + 1,204
  cross, membership 489 and per-acquisition 203 equal their charges. The
  expected difference is the milestones (805 + 177 `any`, none issued), from
  k249's double charge. Also explained: fixed-6 gives 5 (the base posts no C
  marker), fixed-17 gives 8 (six enclosure pairs plus the hint chain's first
  two), and legacy gives 7 app + 4 smp + 89 tgt against its per-row polynomial.
- Bounds. Clean at scale: total 583,486, per-query case bound 10,255,609,
  path_bound 25,432,387. Multi-cycle at scale: total 805,366 (one Trace SCC;
  806 witnesses run beyond their span on the cyclic segment), per-query
  13,524,421, path_bound 72,716,235. Runs take about 2.2-2.3 s to select and
  under 0.1 s to generate; the census records both.
- Mutations caught: dropping the comparison recipe (activities differ with no
  reason); a reason stated for membership (stale reason); the cyclic run
  bounded without its SCCs (1,612 lemma violations).
- Loader oracle: the abstract graph stands in for a real file.
  (1) The scaled activity, input and acquire records are not V18 producer
  rows: `parse_record_lines` rejects each with "Unexpected or missing
  fields", while all 109 base records parse. The census records this and
  fails if it stops being true. (2) An added app frame has no producer send,
  which the loader reports as a message-producer finding. (3) `build` takes
  its queries from the doc's Q01-Q41 table, so it cannot check a recipe's
  query. Making the insertions loader-legal is new work, and is cut as its
  own leaf ahead of k267, whose attained file must be a legal history.
