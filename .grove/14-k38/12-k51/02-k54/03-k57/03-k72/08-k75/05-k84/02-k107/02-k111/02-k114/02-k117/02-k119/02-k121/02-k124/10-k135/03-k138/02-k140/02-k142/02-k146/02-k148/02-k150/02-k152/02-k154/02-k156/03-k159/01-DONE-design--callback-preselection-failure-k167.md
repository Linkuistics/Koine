# callback-preselection-failure-k167

## Goal
Specify and falsify a complete failure-initiated sampler exchange before a
callback is selected, including real invocation results and truthful cleanup.

## Context
Consume v14 armed cancellation and v19 reached guards. Neither supplies this
branch: no cancellation receipt or selected callback may be fabricated.

## Done when
- Define preselection timeout, finished/handled-source returns, disabled tap and
  observed nesting/reentry; preserve first fault and any later unexpected return.
- Preserve healthy startup, readiness/armed publication, one invocation and its
  actual return. No source/capture/returned or sample-complete on this branch.
- Pair failure, controller abort, actual deferred receipt and clean/unresolved
  replies, with every known release attempted once. Exercise no trigger and a
  posted trigger whose independent input receipt is in flight, for all eight cells.
- Version semantics, falsify omissions/order/raw-ledger/FIFO/prefix-loss boundaries,
  preserve all v1-v19 input bytes and reports, renew the complete frozen corpus.
- Reconcile both contracts, assessment and rendered view; name exact pending waits
  and the live k168/k169 residue. This is no complete sampler or native result.

## Notes
The transcript seam and Trace own causality. Targets remain wire projections.
Byte/schema and partial candidate recovery remain unsupported. Render/view only
in a disposable clone; native k126 gates and every k124/k121 criterion remain.

## Decisions (running log)

- A sampler-side failure is published only after observing the actual invocation
  return. An observed guard stops new work and requests stop; a timed-out or
  unexpected native return records its real result instead. First loop cause
  survives subsequent unexpected return. Cleanup and host return precede the
  independently observed abort receipt. This avoids inventing selected callback
  evidence and keeps failure/cleanup messages separate from actual process exit.

- The executable transcript seam is the design instrument: existing Loop and
  Ledger retain independent local facts and Trace alone supplies cross-process
  edges. No standalone formal model or public test hook is needed for this
  bounded exchange; neither could establish native source servicing.
- One fresh-context review found three actionable gaps: available input causality
  lost after unrelated sampler loss, unavailable controller suffix influencing
  local selection, and optional-trigger logic leaking into v19. Each was
  reproduced red and repaired green. Keep available prefix joins, filter v20
  selection at first controller loss, and confine optional receipt semantics to
  v20. Narrow fixes settle these findings; k144's fresh whole-tree review remains.

- Final evidence: Ruff/strict Pyright and 5,288 tests pass; 4,772 frozen controls
  match, 1,423 full-report arrival comparisons agree, all 4,397 earlier reports/
  manifest entries and 8,794 fixture files are unchanged. The 9,593 measured
  inputs still match the final run. Both contracts, assessment criterion map and
  rendered view agree; the disposable presentation clone is stopped. Promote
  only the bounded v20 interface to k159. K168/k169 remain live, preventing any
  ancestor closure or complete sampler/native claim.
