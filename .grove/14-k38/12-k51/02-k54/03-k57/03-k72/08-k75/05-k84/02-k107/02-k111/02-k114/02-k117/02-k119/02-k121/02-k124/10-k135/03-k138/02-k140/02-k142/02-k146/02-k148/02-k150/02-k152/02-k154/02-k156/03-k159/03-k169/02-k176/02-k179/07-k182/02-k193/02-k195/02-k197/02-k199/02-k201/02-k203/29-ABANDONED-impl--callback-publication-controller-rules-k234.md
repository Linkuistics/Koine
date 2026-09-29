# callback-publication-controller-rules-k234

## Goal
Extract controller/target/FIFO local transitions with legacy equality and
report successor controller decisions on locally qualified receipts, with
guarded obligations under unknown branches.

## Context
publication-replay.md "Controller interpretation" (decision rows), "Composite
truth and obligation branches" (guards), "Existing producer families and
migration"; transport-evidence.md B17/E09 notes.

## Done when
- Legacy raw-receive/sequence interpretation and exception order unchanged,
  itemwise; successor decisions consume only qualified local R and refute only
  their own claim; unknown or invalid R never drives a transition.
- Guarded obligations: U guards record both arms' obligations, identical
  obligations become unconditional, known prior K or qualified R establishes
  a mandatory drain; no default else.
- Controls: R03 (four decisions × origin U/I with a source/right defect), R04,
  R16, B17 (paired with a source/right contradiction), E09's independently
  graded controller decision.

## Notes
Interpretation's integrity partition itself is reported in k236.
