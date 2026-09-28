# callback-publication-path-archive-k257 — brief

## Goal
Run k256's selector on k255's six real-file graphs. Match the k220 archive item
by item, make `control_bound` use computed witnesses, and settle the 728 and
1,033 totals. That turns the archived "derived" path counts into computed ones.

## Context
The k253 brief's third to fifth Done-when bullets. K255's and k256's running
logs (any archive disagreement, and the accounting reading). publication_profile.py
`control_bound` and its caller. publication-capacity.md "Per-case bound" (the
728 / 1,033 sentence) and every other document citing those figures,
including R30/R31 in publication-replay.md "Report admission and resource
failure". K250's per-case bounds.

## Done when
- In all six files, every query matches the archive item by item: raw and usable
  truth, direction, and physical witness sequences. The Trace SCCs and bad
  receipts match too. Any mismatch is resolved to the selector, the graph or
  the archive, with the evidence. An archive error is corrected in the
  documents, not in the archive.
- `control_bound` takes its witnesses from the model rather than from the
  archive. Its same-lane lemma checks and beyond-span list still hold.
- The computed totals equal 728 (four files) and 1,033 (both multi-cycle
  files) under the accounting rule k256 recorded. If they differ, the
  difference is explained, and every document citing the figure is corrected.
- For each file the census checks that k250's per-case bound is an upper bound
  on the model's total.
- Each new check fails under a deliberate mutation. `task
  design:check-publication-profile` is green with its record under
  evidence/k253. No profile constant or document table changes, apart from a
  corrected figure.

## Notes
Retiring this leaf closes k253. Check the k253 brief's Done when before
retiring, then hand the model to k254.

## Decomposition

Two increments, each of which leaves the census green. The first is the join.
The selector runs on k255's six graphs and is checked against the archive,
item by item. The archive stays the oracle, and nothing reads the selector's
results back yet. The second is the switch. `control_bound` takes its
witnesses from that join rather than from the archive. The per-file k250 bound
is checked against the model's total, and the documents are made to agree.
The switch needs the join's per-file selections, so the join comes first.

- callback-publication-archive-join-k263: `select_orders` over the six real
  graphs, joined with the archive per query (raw and usable truth, direction,
  and physical witness vertex sequences), per Trace SCC and per bad receipt.
  The computed `witness_refs` are checked against 728 and 1,033. Mutations
  must bite on the real files.
- callback-publication-computed-bound-k264: `control_bound` reads computed
  witnesses, and its lemma, beyond-span and 88-edge checks still hold. Each
  file's k250 per-case bound (the lane bound plus V + H + D) is checked as an
  upper bound on the model's `total`. The documents that cite 728 and 1,033
  get the settled figure and wording. Retiring this leaf closes this node, and
  with it k253.

## Decisions (running log)

- **Planning probe: the selector already agrees with the archive.** A scratch
  run (not committed) passed each file's `Graph.canonical`, `edges`,
  `bundles`, `justifications` and physical query pairs to `select_orders`. It
  compared every query's raw and usable truth, direction and witness vertex
  sequence with the archive. Retained usable U was read as the archive's empty
  `usable_path`. There were zero mismatches in all six files. `witness_refs`
  is 728 in clean, multi-clean, multi-clean-turn0 and upstream-cycle, and
  1,033 in both multi-cycle files. So the documents' figures stand as computed
  witness totals. `total` also counts Trace-SCC edges: 728 in the three clean
  files, 730 in upstream-cycle and 1,040 in both multi-cycle files. D-SCC refs
  are 0. `shared_witness_refs` is 254 and 582. So the join is a check to
  commit, not a mismatch hunt. That is why it and the switch are separate
  small leaves rather than one leaf with a hidden investigation.
- **Children are `impl`.** Each writes census code and evidence, not more tree.
  Neither artefact earns a review chain. Both are checks inside the census and
  are guarded by their own mutations.
