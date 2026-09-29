# callback-publication-write-evidence-k228

## Goal
Stage-2 local transport facts per writer and reader, reported independently:
calls, intervals, byte supply and feasible receipt before return, with
post-boundary results excluded from both support and refutation.

## Context
transport-evidence.md "Trusted boundaries and decisive closure"; publication-
lifecycle.md "Writer seals, buffers and late results" and "Stopped readers and
buffered suffixes"; publication-replay.md evaluation stage 2.

## Done when
- Per direction: begins/results/completions, offsets, serialization, known and
  possible ranges, contributing begins (pending included), permanence after
  zero/-1/abandonment/seal; per reader: receipts, snapshots, next ordinal,
  read_stop versus read_loss(EOF/error). Buffered bytes never become receipts.
- Feasible receipt before return/recorded result from byte supply; results
  beyond a boundary excluded from support and refutation with coordinates and
  reasons retained; decisive source exclusion (I) distinguished from an
  uncollected tail (U).
- Real-file controls with neighbours, mutants and permutations: B01–B08 local
  outcomes (B08's edge retention is k231's), B11, B15, E01–E07, E16, E18, E19,
  L01–L04, L09, L10, L16–L19 local parts, R21 (receipt-before-result, ±result
  after boundary, closed insufficiency I versus open tail U).
- Audit every caller of the codec's available/peek/consume: consume only after
  a validated receipt is appended; no buffered-receipt inference.

## Notes
Native buffer admission/lifetime remains k126. Charge local facts/diagnostics.
