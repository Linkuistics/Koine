# callback-causal-analysis-k116


## Goal

Deliver and falsify the executable causal analyzer before the native callback
fixture depends on it.



## Context

The callback witness protocol in `docs/verification/callback-capture-transfer.md`
owns the evidence boundary. Guest inspection leaves actual F/M producer freshness
unresolved. This child supplies no native sampling result.

## Done when

- Define bounded per-process transcripts with local sequence and matched causal
  IDs, independent input-receipt witnesses, callback and right-ownership events.
  Never infer cross-process order from timestamps or ingestion order.
- Analyze both constructions and a later C switch while retaining B. Distinguish
  incomplete schedules, contradictory evidence, consistent bounded observations
  and malformed input; never grade call order as actual source freshness.
- Run frozen raw positive and broken controls through the CLI: missing/wrong
  acknowledgment, outside-callback sample, arrival permutation, stale F/M with
  live PID equality and early release. Assert exact exits and reason codes.
- Add root Taskfile commands; record source/input digests before/after, per-case
  results and instrument limits in the existing assessment and view.
- Leave all native fixture, permissions, gate and reachability obligations in
  k117. No new production interface or client consent requirement.

## Notes

Use the existing native evidence seam and a pure host-side analyzer. The running
plan is: define the trace contract and failing controls; implement the smallest
causal/ownership checker; run and preserve controls; update evidence and view.
Grove owns the plan location, retirement and single focused commit.

## Decisions (running log)

- Use a pure offline acceptance-path analyzer behind an immutable trace seam.
  Local process sequence, matched message IDs and independently delivered input
  markers supply graph edges. Never infer order from clocks or record arrival.
  Acquisition tokens carry a continuous-ownership ledger; numeric port equality
  cannot supply it. Keep source freshness explicitly false in every report.
- Keep reached schedule and candidate validity separate: stale F/M with a live
  matching wrong-process right is a reached false attribution, while missing
  evidence or an outside-callback sample cannot claim the intended order. The
  recorded tests first exposed the report conflation and now check both fields.
- Limit the first schema to one accepted callback, the two candidate pairs and
  four causal schedules. Refusal, withheld-loop, lifetime, native policy and
  actual gate behavior need native recorder evidence and explicit schema/control
  extensions; none is silently converted into acceptance. k117 owns that work
  before k115 uses the fixture. No additional public seam is introduced.
- One fresh-context adversarial reviewer inspected graph construction, ownership,
  schedule checks and malformed input against the trace contract. It reported
  no actionable findings or reproducible invalid accepted trace. This is bounded
  review evidence, not proof of completeness or of a native recorder. No second
  reviewer or automatic review chain is warranted by that result.
