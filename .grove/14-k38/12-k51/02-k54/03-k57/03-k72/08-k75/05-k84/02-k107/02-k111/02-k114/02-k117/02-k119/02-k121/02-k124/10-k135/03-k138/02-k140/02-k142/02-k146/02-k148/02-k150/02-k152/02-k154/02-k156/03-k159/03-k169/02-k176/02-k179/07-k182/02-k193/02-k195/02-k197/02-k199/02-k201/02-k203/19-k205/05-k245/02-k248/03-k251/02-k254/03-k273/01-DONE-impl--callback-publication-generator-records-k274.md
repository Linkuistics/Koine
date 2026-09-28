# callback-publication-generator-records-k274

## Goal
Make every producer record the generator inserts, and every app frame it adds,
a V18 row that the loader's `parse_record_lines` accepts, without changing any
issued pair, graph or k272 figure. Record, in the census, which vectors fit
the loader's per-app producer seq cap once frames count against it.

## Context
The k273 brief (Goal, Done when bullets 1-2, Decomposition). `scale`, `lift`
and the recipes in publication_generator.py. `rejections`, `LOADER_ORACLE`,
`seq_violations` and `path_candidates` in publication_profile.py. `_producer`
and `_row` in publication_files.py. The allowed events and fields
(`ALLOWED`, `V3_FIELDS`, the LOOP fields) in analyze.py.

## Done when
- Each inserted record is built by a stated rule from a base record of the
  same event, or the leaf states its rule. This covers activities, member
  inputs, acquisitions, neutral rows and added-frame sends. Each one parses
  as V18.
- Each added app frame is a producer send, with the rule for choosing it over
  an auxiliary frame stated. The lift emits the same physical rows for it as
  before.
- All six reproductions hold, and so do k272's two SCALE runs (queries by
  source and class, totals, bounds) and k266's candidate totals. Any recipe
  change is shown to issue identical pairs on all of them.
- The census records the inserted records as parsed and fails if one stops
  parsing. It also records each SCALE and candidate vector's producer seqs
  with the frames counted, and pins the set that exceeds 256. `task
  design:check-publication-profile` is green under evidence/k254. k253's
  record stays byte-identical, and each new check fails under a deliberate
  mutation.

## Notes
The seq finding changes what k267 can attain, so promote it to the k254
brief. A target's activities and its interior frames now share one budget of
256 minus its base rows.

## Decisions (running log)
- Decomposed k273 into records (this leaf) and the writer (k275), at the seam
  the k273 Notes name. The writer's first check is byte identity with the
  committed clean file.
- Record rules (`scale`, `template`): an activity copies the base's first
  activity on its role, else on any role (C has none, so it takes B's
  `activated` row). A member copies the base's first input the same way, with
  marker 1000 + n (B) or 2000 + n (C) and the role's next ordinal. An
  acquisition copies the acquire it follows. The neutral rows are these. The
  controller records `trigger` "scaled", which no recipe reads, and legacy
  reads it only in a delayed-entry schedule. The sampler copies the base's
  first unselected `tap_delivery`. B and C have no event that no recipe reads,
  so a vector that asks them for neutral rows is refused. No vector does.
- Added frames are producer sends, never auxiliary frames. The auxiliary
  grammar gives an app only `aux.activate.1-9`, from the controller, and that
  would name an activation the case never requested. Each app sends one empty
  message that only an after-callback schedule exchanges:
  `retention-release`, `callback-returned`, `switched-B`, `switched-C`
  (`ADDED_FRAME`). So the ordinary base never sends or receives one, and the
  lift keeps it unrelayed. `scale` places the sends where the lift writes their
  frames, and the lift takes each frame's send from a per-role queue. So the
  physical rows are unchanged.
- `peer_reply` now finds a reply by name, from legacy's V18 reply map
  (analyze.py 1339-1348), which is how site 1431 orders it. The old rule read
  the peer's next frame. At the sampler's `end` that is an added send, and the
  old rule issued an extra pair there (the census's mutation catches it).
  Against HEAD's generator, a scratch comparison over the six files, SCALED,
  SCALE, all candidates, sweeps and BEYOND vectors shows the same lanes,
  canonical order, edges, justifications, bundles and query physical pairs.
  Only the producer keys past an inserted send move.
- Producer seq finding. Every added frame now costs a producer seq, and the
  loader caps each app at 256. The census pins the vectors that exceed it
  (`LOADER_SEQ_OVER`):
  - SCALE (sampler 296);
  - SCALED "at the caps" (controller 282, already over on semantic rows);
  - every padded candidate (combined: B 310, C 311);
  - the controller funnel (controller 326 as well);
  - both sweeps.
  None of these can be written as a legal file. k266's candidate check
  (`seq_violations`) still counts only the rows a recipe can read, so its
  figures stand.
- Figures. Generated queries, model totals, per-query bounds and the witness
  figures are unchanged in SCALE and every candidate. The charge side moves:
  the construction now counts the sends as producer rows (SCALE ctl 28 → 97,
  smp 256 → 296), so `path_bound` rises (clean at scale 25,432,387 →
  25,954,183; multi-cycle at scale 72,716,235 → 74,759,913; each padded
  candidate too). That is the construction being correct, not a figure the
  generator changed. It departs from this leaf's Done-when, which listed
  bounds among the unchanged figures.
- Census `path_generator_records`: every inserted record of 22 vectors parses
  as V18. Each added frame's route encodes (`encode_protocol`). Four mutations
  are caught: k272's activity shape ("Unexpected or missing fields"), a send
  routed to the sampler ("route"), uncounted sends (the pinned set collapses
  to "at the caps"), and the old peer-reply rule (1 pair added on clean at
  scale). The loader-oracle record keeps only the Q01-Q41 reason, and marks
  the other two as fixed. Green, and k253 stays byte-identical. The only other
  drift is tracemalloc peaks (a few bytes and 8.5 KB, both within their
  models) and timings.
