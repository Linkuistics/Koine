# callback-publication-computed-bound-k264

## Goal
Make `control_bound` take its witnesses from k263's computed selections, not
from the archive. Check each file's k250 per-case bound against the model's
total. Settle the 728 and 1,033 figures in every document that cites them.

## Context
K263's running log and its per-file selections. publication_profile.py
`control_bound` and its callers: `fit` builds `path_controls`, and `main` runs
the lemma-violation, beyond-span and 88-edge checks. `stress_fit` and
`document_fit` consume `path_controls`. publication-capacity.md "Per-case
bound": the bound is 2 × the per-query witness bound, plus V + H + D. The
sentence there gives 5,664 to 9,576, 728 and 1,033, and the 88-edge Q34 usable
witness. publication-replay.md R30/R31 in "Report admission and resource
failure". The k257 brief's running log gives the probe's `total` per file.

## Done when
- `control_bound` reads the raw and usable witness lengths from the computed
  selection. The archive stays only as k263's oracle. `derived_path_refs`
  (renamed if the name now misleads) is still 728 or 1,033. The same-lane lemma
  still has no violations. The beyond-span list is still Q34 to Q36, raw and
  usable, in both multi-cycle files, and the longest witness is still 88.
- For each file the census checks that k250's per-case bound is at least the
  model's `total`, Trace-SCC and D-SCC refs included. That bound is the
  per-query lane bound plus V + H + D, with H and D taken from the built
  graph's bundles and upstream arcs. Both figures are recorded.
- The figures are settled. If the computed totals equal 728 and 1,033, as the
  probe found, the documents keep them. Sweep every citation of the figures,
  including any R30/R31 text, the other verification docs and `.grove/`
  briefs, and state that they are computed witness totals, not archived
  derivations. A figure that differs is explained and corrected wherever it is
  cited.
- Each new or changed check fails under a deliberate mutation: for example, a
  per-case bound that omits V + H + D against an inflated total, or a witness
  source swapped back to a truncated archive path. `task
  design:check-publication-profile` is green with its record under
  evidence/k253. No profile constant or document table changes, apart from a
  corrected figure.

## Notes
Retiring this leaf closes k257, and then k253. Check both briefs' Done when
before retiring, and promote to the k251 brief what k254 needs: the computed
per-file totals, the entry point, and the fact that `control_bound` no longer
reads the archive. Keep the model independent of `path_bound`, since each
checks the other.

## Decisions (running log)

- **`control_bound` takes the file's `Graph`, its Trace-SCC member sets, per-query
  witness lengths and the selector's charged `total`.** `fit` feeds it
  `publication_archive.selection(case)`: the SCCs from `Selection.sccs` and the
  lengths from `computed_lengths` (each query's raw and usable `witness.steps`).
  `fit` no longer opens the k220 archive. The profile now reads the archive only
  in one mutation. `derived_path_refs` is renamed `witness_refs`, the selector's
  own name for the same sum.
- **The per-case bound is `case_path_refs` = lane bound + V + H + D.** V is
  `len(Graph.canonical)`, which the census also checks against the observation
  rows. H is `len(Graph.bundles)` and D is the bundles' upstream arcs. The bound
  is checked against `model_total`, the selector's `total`, which includes the
  Trace-SCC and D-SCC refs. Recorded per file (V/H/D, lane, case bound,
  witness_refs, total): clean and upstream-cycle are 333/52/24, 5,664, 6,073,
  728, and 728 or 730. multi-clean and multi-clean-turn0 are 335/52/24, 5,696,
  6,107, 728, 728. Both multi-cycle files are 335/52/24, 9,576, 9,987, 1,033,
  1,040. `path_bound` is untouched and not called.
- **The checks moved into `control_checks`, and two are now exact.** The
  beyond-span list must equal Q34 to Q36, raw and usable, in both multi-cycle
  files and be empty elsewhere (it was only required to be non-empty). The
  longest witness must be 88 in the multi-cycle files and 44 elsewhere.
  `witness_refs` must equal publication_archive's `FIGURES`.
- **Mutations** (recorded as `path_control_mutations`; each check must be reached):
  lengths from the archive with Q34's usable path truncated (longest,
  witness_refs). The per-case bound without V + H + D against a total with every
  witness at its lane bound plus the SCC refs, in upstream-cycle (case_bound).
  The full bound is asserted to cover that total. Also: no Trace SCCs (lemma,
  beyond_span), one query missing (census, witness_refs), and a total one above
  the bound (case_bound). As a control, the untruncated archive lengths equal the
  computed ones in all six files, so only the truncation bites.
- **Figures settled: 728 and 1,033 stand as computed witness totals.** In
  publication-capacity.md "Per-case bound" they are reworded as computed, and the
  per-case bounds and charged totals are added. **One corrected figure:** the
  max_path_edge_refs row's R30/R31 stress cell said "multi-cycle (1,033
  derived)". Admission charges `total`, and the Trace-SCC edges share the limit.
  So the stress file's measured usage is 1,040 (1,033 witness + 7 Trace-SCC). The
  cell now says so. R30/R31 in publication-replay.md cite no figure. The other
  verification docs have no citation, and publication-path-controls.md gives only
  the conservative 27,388. Live `.grove/` briefs: the k251 brief's "1,033 that
  R30/R31 cite" is corrected. DONE leaves and the closing k253/k256/k257 briefs are
  left as history.

