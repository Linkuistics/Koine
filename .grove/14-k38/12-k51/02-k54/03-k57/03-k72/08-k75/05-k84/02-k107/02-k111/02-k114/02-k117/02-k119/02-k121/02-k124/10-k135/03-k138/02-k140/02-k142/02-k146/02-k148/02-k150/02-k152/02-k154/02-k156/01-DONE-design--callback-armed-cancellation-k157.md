# callback-armed-cancellation-k157

## Goal
Specify and falsify the complete armed-timeout cancellation exchange after
sample-release and before callback selection, including real loop unwind and
truthful per-reference cleanup.

## Context
Consume v8 loop, v9 ownership, v10 source and v11-v13 startup contracts. This
branch requires B activation/settle/input before sample-release. Targets remain
explicit wire projections pending k143. Use existing Trace and raw Ledger.

## Done when
- Define timeout on unconsumed armed, immediate abort and late armed draining
  without a trigger; FIFO cannot erase a published reply.
- Require host/sample-release/armed/run invocation, dedicated-mode socket receipt,
  matching stop/return and restored baseline before cleanup reply. No invented
  selected callback, returned, source work or sample credit.
- Attempt each reference once after unwind; failed release remains unresolved.
  Missing calls, replies, gaps, faults and blocked releases cannot complete.
- Falsify both sources, constructions and schedule labels, clean/failed releases,
  in-flight armed, queued nonselected input, wrong order/context and simultaneous
  independent defects. Preserve all earlier bytes/reports itemwise, renew corpus.
- Reconcile both contracts, assessment, visual view and exact k144 waits. Keep
  every remaining k156 and ancestor criterion live in k158/k159; no parent close.

## Notes
Diagnostic design at the existing immutable transcript seam. Render/view only
in a disposable clone. No native matrix, product or permission changes.

## Decisions (running log)

- Keep published armed separate from its controller receipt. The selected branch
  is armed-timeout before any trigger post; a late armed frame is drained after
  abort commitment. The sampler consumes queued commands in FIFO order, enters
  its one invocation, services cancellation in that mode, and observes unwind
  before releasing references. No same-thread interrupt or callback is invented.
- Reuse the existing loop checker, Ledger and Trace rather than a second
  cross-process engine. A narrow exchange checker supplies branch ordering and
  truthful terminal replies. K143 retains real target notification lifecycle;
  k144 retains numeric deadlines/reserve, full composition and mandatory review.

- The sole fresh reviewer found suffix cleanup after a transport fault in three
  independent projections. V14 now stops loop/source/native replay at that
  boundary; the red regression and frozen control retain two unresolved rights.
  Late armed may interleave with peer abort writes; document this legal socket
  interleaving while preserving per-peer FIFO and immediate abort commitment.
- Frozen evidence/k157 matches 2,270 controls and 210 arrival permutations, with
  79 new cases. All 2,191 prior reports, 4,382 case/trace files and 2,191 manifest
  entries remain itemwise unchanged. Ruff, strict Pyright and 2,329 tests pass.
  Both contracts, assessment and current Mermaid view agree on this branch.
  Every original criterion and pending k144 wait is mapped in the assessment.
  K158/k159 remain live; this child closes no ancestor and changes no ADR.
