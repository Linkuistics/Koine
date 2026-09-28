# callback-publication-archive-join-k263

## Goal
Run k256's selector on k255's six real-file graphs in the census, and join the
result with the k220 archive item by item. Every archived "derived" path is
then matched by a computed one.

## Context
The k257 brief's running log (the planning probe and its reading of retained
usable U). The k253 brief's promoted k255 and k256 sections give the input and
entry-point shapes. evidence/k220/query-derivation.json.gz gives per-case
`topology` (sccs, bad_receipts) and `rule_queries` (raw, usable, direction,
raw_path, usable_path). publication_paths.py `select_orders`, `Selection` and
its `accounting`. publication_edges.py `build` and its archive checks, which
already cover topology and structural bad receipts.

## Done when
- For all six files the census runs `select_orders` on the built graph, over
  the 41 physical pairs. For every query it checks raw truth, usable truth,
  direction, and the raw and usable witness vertex sequences against the
  archive. A retained usable U matches an empty archived `usable_path`. Every
  witness step is an edge of the graph, and its chosen justification is one of
  that edge's.
- The selector's Trace SCCs equal the archive's `sccs`, as member sets. The
  selector's bad receipts (from its dependency pass, not
  `publication_edges.bad_receipts`) equal the archive's `bad_receipts`. Each
  file's `witness_refs` equals the archive's summed raw and usable path lengths,
  which are 728 or 1,033. Record per file `witness_refs`, `total`,
  `shared_witness_refs` and `shared_total`.
- Any mismatch is attributed to the selector, the graph or the archive, with
  the evidence, and recorded in the running log. An archive error goes to the
  documents, never to the archive.
- Each new check fails under a deliberate mutation that bites on the real
  files, and the census records which checks caught it. Candidates include
  `filter_after=True` (Q34 to Q36 in multi-cycle take a usable detour through
  S), dropping the cyclic-edge predicate (the cyclic files), and one tampered
  archived item on the comparison side. `task design:check-publication-profile`
  is green, with its record under evidence/k253. No profile constant or
  document table changes.

## Notes
The probe found zero mismatches, so expect this to be a check to commit. It
should not turn into an investigation. Keep the join out of `publication_paths`
so that the selector still never imports the builder or archive witnesses. It
can live beside the census wiring in the profile or in a small module of its
own. Expose the per-file `Selection` (or its witnesses) so k264 can reuse it
rather than re-derive it. Do not touch `control_bound`. That is k264.

## Decisions (running log)

- **The join lives in its own module, publication_archive.py**, wired into the
  profile census as `archive_join`. `publication_paths` still imports neither the
  builder's census nor the archive. `selection(case)` is cached and returns the
  file's `Graph` and `Selection`, so k264 can read the computed witnesses without
  re-deriving them.
- **Zero mismatches in all six files**, as the planning probe found. Raw and usable
  truth, direction and both witness vertex sequences agree for every one of the 41
  queries. Every witness step is a graph edge carrying its chosen justification.
  The Trace SCCs and the dependency pass's bad receipts equal the archive's. There
  is nothing to attribute to the selector, the graph or the archive. No real file
  has a dependency-bad retained usable U: the four usable U in each multi-cycle
  file are cyclic-only raw U, and each has an empty usable witness and an empty
  archived `usable_path`.
- **Per-file figures** (witness_refs / total / shared_witness_refs / shared_total):
  clean, multi-clean and multi-clean-turn0 are 728 / 728 / 254 / 254.
  upstream-cycle is 728 / 730 / 254 / 256. Both multi-cycle files are
  1,033 / 1,040 / 582 / 589. `witness_refs` is checked against the archive's
  summed path lengths and against the documents' 728 and 1,033.
- **One census-only keyword on `select_orders`: `drop_cyclic`.** It sits beside
  `filter_after`, because the cyclic-edge predicate lives inside the selector's
  view and no input can remove it. The defaults are unchanged.
- **Mutations, each biting on a real file** (the census records what caught each):
  the selector's `filter_after` (multi-cycle Q34 to Q36 lose their S detour), a
  dropped cyclic predicate (multi-cycle-turn0 and upstream-cycle), a misattributed
  justification and one query left unselected. A shortcut edge that the graph
  lacks covers the graph side. For the archive, one tampered item for each
  compared field. The census fails if any check is reached by no mutation.
  The first archived usable-truth tamper chose Q02, which is already U in
  multi-cycle, so it was a no-op and correctly reported as surviving. It now
  tampers Q34.
