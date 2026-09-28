# callback-publication-edge-topology-k258

## Goal
Build each of the six k220 path-control files' vertices, edges and 41 queries
in the census, from the committed rows through the unchanged loader. Check them
against every topology field of the archive and every archived witness edge,
without a selector and before any justification carries dependencies.

## Context
publication-path-controls.md "Edge inventory and ownership": classes 1–5, the
split call's N−1 and 1 contributions, and the list of absent classes.
"Upstream join controls" gives the {G28,G29} SCC, the reversed ready-C join and
the clean neighbour's swap. "Rule-issued query census" gives the Q01–Q41
original pairs and their consumers. publication-replay.md "Selected successor
edge rules" gives the W-input and W-enter admission. The archive's `topology`
and each `rule_queries` entry's `physical`, `raw_path` and `usable_path`.

## Done when
- For each file the census holds lane-ordered vertices, named as the archive
  names them (lane letter plus `observation_seq`: T, S, B, C, G). It holds one
  edge record per rule instance, tagged with its class and a stable
  rule/anchor ID. A local edge parallel to a cross-lane edge stays a separate
  record. The Trace adjacency is the set of distinct pairs.
- The 41 queries come from the documents' original pairs, mapped through the
  loader's producer coordinates to physical pairs. Consumers that share a pair
  share one query. The archive's `original` and `consumer` fields are compared,
  not read as input.
- File by file, these match the archive: vertex count (333 or 335) and edge
  count (386–390). The archive does not say whether it counts distinct pairs
  or rule instances. Settle that from the parallel records and record it in
  the running log. Also match the Trace SCCs from `Trace.cycle_components` over the canonical order,
  `producer_coordinates`, and all 41 physical pairs. Every consecutive pair in
  every archived raw and usable witness is an edge. Reverse witnesses are
  stored in edge direction, e.g. T4→G30's raw path is G30, T4. The upstream-cycle
  G29→G28 join is present and cyclic, and G30→T4 is not cyclic.
- Each check fails under a deliberate mutation: drop one edge class, flip the
  reversed join to G28→G29, and misassign one query's physical pair. The
  census records which check failed for each mutation.
- `task design:check-publication-profile` is green. The census record is under
  evidence/k253. No profile constant, `path_bound`, `control_bound` or
  document table changes.

## Notes
The builder takes only the manifest and observations.jsonl, through
`load_publication`. coordinates.json may cross-check the classes in a test
(the k255 brief lists its suffixes) but never feeds the builder. Keep the
builder apart from `path_bound`, and leave room for k259 to attach dependencies
to each edge record without changing the record's identity. The census now
writes to evidence/k250 through a single `EVIDENCE` constant. Move it so k250's
committed record stays as it is. If the builder ends up in its own module,
extend the Taskfile task's ruff and pyright steps to cover it. A count that
disagrees with the archive is resolved before either side changes. A real
archive error goes in the running log for k257.

## Decisions (running log)

- **The archive's `edges` counts distinct ordered pairs, not rule instances.**
  Rule instances are 412 (clean, upstream-cycle) and 415 (split files). The
  distinct pairs are 386/387/389/390, which is the archive's figure in all six
  files. The difference is exactly the parallel records: three auxiliary joins
  on local edges (T7→T8, G6→G7, G40→G41) and every forward relay join whose
  ingress sits directly before its commit. Upstream-cycle's reversed G29→G28 is
  the one relay pair that is not parallel. The census records both counts, and
  the Trace adjacency is the set of distinct pairs.
- **Builder module `publication_edges.py`**, apart from `path_bound`. Edge
  identity is `<class>@<anchor row>`: the source row for local, begin for
  contributor, commit for relay and auxiliary, input for W-input, and enter for
  W-enter. k259 attaches dependencies by that ID. The Taskfile's ruff and
  pyright steps cover the module. `EVIDENCE` now points to evidence/k253, and
  k250's record is byte-identical. Profile imports need `HERE` on `sys.path`
  because `-I` drops the script directory.
- **Mutations and the checks that caught them:** dropping the relay class
  (upstream-cycle) was caught by edges, sccs and reversed_join. Dropping the
  contributor class (multi-cycle) was caught by edges, sccs and witness_edges.
  Flipping to G28→G29 was caught by edges, sccs and reversed_join. Moving Q01's
  target one row was caught by query_physical, document_physical and
  witness_endpoints. A scratch-only split-contribution tamper tripped
  `contributions`.
- **No archive error found.** Every field matches in all six files. The
  archived witness steps checked total 728 (four files) and 1,033 (both
  multi-cycle files). That is an independent count agreeing with the path totals
  k257 must settle, not a selector result.
