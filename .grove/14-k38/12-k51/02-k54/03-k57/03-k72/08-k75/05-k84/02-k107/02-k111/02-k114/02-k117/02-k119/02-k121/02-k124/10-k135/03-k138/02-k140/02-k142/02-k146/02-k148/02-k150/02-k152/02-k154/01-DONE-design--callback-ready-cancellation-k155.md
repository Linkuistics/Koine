# callback-ready-cancellation-k155

## Goal
Specify and falsify cancellation after sampler readiness publication but before
sample-release, including readiness in flight at the controller ready deadline.

## Context
Consume v11 failure and v12 early-cancel exchanges, their frozen evidence and
the full ancestor charters. Reuse Ledger and Trace at the transcript seam.

## Done when
- Define healthy readiness prerequisites for both constructions, safe abort
  receipt, exactly-once cleanup and clean versus unresolved response.
- Define controller ready-timeout with a genuinely missing ready receipt,
  immediate abort, late readiness draining and per-peer FIFO. Cover sampler
  readiness consumed while a different peer is still missing and readiness
  crossing the abort send. No activation or sample-release on this branch.
- Version the contract; falsify readiness/order/cleanup and partial failures,
  preserving raw and controller findings independently and all prior bytes and
  reports itemwise in a renewed frozen full corpus.
- Reconcile both contracts, assessment and browser view, exact k144 waits and
  the remaining live k154/k156 obligations. No ancestor closes on this slice.

## Work plan
1. Add failing CLI controls for the two ready-timeout receipt states and false
   readiness/cleanup/order. Keep the v12 fixture generator frozen.
2. Extend the existing startup replay under a new v13 ready-cancel manifest;
   reuse raw Ledger and Trace. Add corpus generator and Taskfile test coverage.
3. Reconcile diagnostic contracts and a sequence view. Run lint/types/tests,
   renew the full frozen corpus and compare every old fixture/report itemwise.
4. Review the narrow exchange, render/view only in a disposable clone, preserve
   evidence and limitations, retire this child and seal its focused jj change.

## Notes
No callback/source/host invocation or native capture. K156 retains armed and
selected-callback failures, transport/blocked paths and all original reconciliation;
k143 targets, k144 complete composition/deadlines/partial evidence/fresh review,
k126 native audit/coverage/preparation/exits/containment and one attempt per cell.

## Decisions (running log)

- Use v13 ready-cancel to preserve v11/v12 meanings. Readiness sent is a local
  fact, readiness consumed is a controller fact. A ready-timeout is allowed only
  while at least one peer readiness remains unconsumed; after the timeout the
  abort is irreversible and late readiness must be drained before that peer's
  response. No additional IPC message or public test seam is needed.

- Healthy publication is the sampler boundary, consumed readiness is the
  controller boundary. The same checker retains v11/v12 meanings; raw Ledger
  and Trace remain the ownership and causal authorities. Neither readiness nor
  a terminal reply establishes native acceptance, actual exit or containment.
- The full frozen corpus matches 2,191 cases, including 75 v13 controls and
  190 arrival-order pairs. All 2,116 earlier report records, 4,232 fixture files
  and 2,116 manifest entries are preserved itemwise. Ruff, strict Pyright and
  2,235 tests pass. The bounded adversarial review found no material violation.
- Both contracts, assessment and the readiness view name the exact partial
  k144 waits and k156's remaining work. Original ancestor criteria remain live;
  the existing ADR set needs no change. Evidence/k155 binds the delivered
  inputs and records presentation limits; this is synthetic design evidence.
