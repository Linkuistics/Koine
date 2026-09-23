# callback-partial-history-k139


## Goal
Preserve independently detectable controller/protocol malformation when a
schema-readable transcript is truncated, unmatched or fault-bearing.

## Context
Use the existing immutable transcript seam and Trace graph. V4/v5's shared
reader returns before prefix replay on these histories. Version the repair.

## Done when
- Define intact local prefixes and partial message/FIFO limits; never renumber
  gaps, synthesize replies/end records, or infer absence from an unread suffix.
- Keep the original structural result beside independently established prefix,
  activation-producer or FIFO malformation. Partial evidence earns no sample or
  native credit; complete inputs retain v5's independent sample columns.
- Falsify malformed-plus-loss and legal pending prefixes across all eight cells,
  including faults, unmatched messages, gaps, duplicates and arrival permutations.
- Run the full frozen corpus; compare every prior report and canonical input
  itemwise. Update both contracts, assessment and a verified design view.
- Keep k140's full producer/review obligations live; close no native criterion.

## Notes
Parsing failures remain unsupported. Diagnostic design only, with presentation
rendering/viewing restricted to disposable TestAnyware clones.

## Decisions (running log)
- Check positive malformation in intact prefixes without repairing an incomplete
  trace. Keep its strict structural result separate. Partial candidate recovery
  remains k140's; this slice cannot claim it.
- A two-fault permutation control exposed arrival-order-dependent diagnostic
  selection. V6 selects diagnostics in fixed role/local-sequence order without
  adding chronological edges; older versions remain unchanged.
