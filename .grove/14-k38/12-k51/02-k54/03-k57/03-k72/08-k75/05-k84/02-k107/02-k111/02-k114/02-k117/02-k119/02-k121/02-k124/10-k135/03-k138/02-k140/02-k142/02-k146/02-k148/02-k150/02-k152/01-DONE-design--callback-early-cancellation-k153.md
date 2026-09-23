# callback-early-cancellation-k153

## Goal
Specify and falsify the complete before-ready cancellation exchange for both
constructions, preserving partial ownership and failed cleanup.

## Context
Consume k151's v11 startup failure exchange, v9 ledger and v10 source projection.
Use the existing immutable transcript/Trace seam and preserve all v1-v11 bytes
and reports itemwise. No new public seam or native execution.

## Done when
- Controller ready-timeout issues exact paired aborts; sampler receives only at
  startup safe points before ready, with no pending native call or summary.
- Cover zero, one and two healthy preheld acquisitions and acquire-resample
  before its callback; cleanup attempts every known reference once and cannot
  report clean cancellation after failed release. No source/host/callback work.
- Version the executable contract, demonstrate honest complete exchanges and
  pending-call/lost-reply/false-clean/order failure controls across both sources
  and schedules; keep structural/controller/raw diagnostics independent.
- Renew the frozen full corpus, compare earlier inputs/reports itemwise, update
  both contracts, assessment and rendered view, and hand exact waits to k154/k144.

## Notes
Rendering/viewing only in a disposable TestAnyware clone. K154 retains the full
remaining k152/k150/k148/k146/k142 charter. No ancestor closes; k143/k144/k126
keep target lifecycle, final composition/review and all native obligations.

## Decisions (running log)

- Receive cancellation at an explicit nonblocking startup poll before the first
  acquisition, between completed acquisition/type units, or before readiness.
  Do not reenter a raw call or suppress its required return/summary/type check.
  The immutable transcript is the existing seam; Ledger owns raw cleanup truth,
  Trace owns causal pairing, and protocol checking stays independent of raw
  defects. Keep the v11 failure branch and all old report bytes unchanged.

- Added v12 as a diagnostic-only successor through the existing immutable Trace
  and raw Ledger seams. Readiness races after a ready-sampler send remain outside
  this branch; k154 names them explicitly. No new product module or native run.
- Seven focused CLI regressions began red. Final Ruff lint/format, strict Pyright
  and all 2,153 tests pass. The renewed frozen run matches 2,116 controls and 166
  arrival pairs. Every prior complete report, case/trace digest and manifest
  entry is preserved itemwise; all 4,262 measured inputs match delivered bytes.
- The one bounded fresh reviewer found no material issue. Producer preservation
  caught a changed v11 error sentence, restored before the final run. Evidence:
  docs/verification/callback-native-capture/evidence/k153/{review.md,preservation.json}.
- Both contracts, assessment and the editable cancellation diagram state the
  exact readiness/abort-write/safe-poll/native-call/response/actual-exit waits.
  Render and browser checks use only disposable clone koine-k153-view; no native
  producer, capture, product permission setup or sibling repository change.
- Done-when audit: controller pairing and immediate timeout abort, all partial
  preparation shapes, per-reference cleanup and negative reply, independent
  diagnostics, failure/partial controls, frozen preservation, contract/view and
  k154/k144 handoff are delivered. K154 is live, so no ancestor closes. The
  capture/public-Accessibility ADR set remains current and unchanged. K143,
  k144, k126 and downstream obligations are not discharged by synthetic evidence.
