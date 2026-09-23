# callback-delivered-markers-k141

## Goal
Make lossless native signed-64-bit marker encoding executable, including zero,
negative and repeated stray input. This is a diagnostic slice only.

## Context
Consume k140/k138/k135, current contracts and k134 reproduction. Existing
v3 histories have known lifecycle omissions; marker projections cannot cure them.

## Done when
- Freeze canonical signed-64-bit decimal strings in manifest, posts, delivered
  target input, selected tap, receipts and audit. Only controller post values
  must differ; receipts retain every delivery with its own ordinal.
- Version schema changes; falsify aliases, range/type errors, repeated strays,
  repeated posted markers, missing/misnumbered receipts and boundary values.
- Renew corpus; compare v1–v6 input bytes and reports itemwise. Preserve partial
  history/sample limits and withhold native readiness.
- Update contracts, assessment, visual presentation and k126/k124 handoff.

## Notes
No native matrix or permission change. Final composed review stays k144.

## Decisions (running log)
- Use canonical decimal strings instead of JSON numbers that binary64 consumers
  can round, or symbolic names that hide native zero/repeated values. Preserve
  signed Int64 directly, with no stray nonce or expected-value substitution.
- Reuse Trace and ordinal receipts; introduce no causal engine or uniqueness
  premise. Exact grammar/range and failing transcript tests answer this boundary,
  so no formal model of assumed native delivery is warranted.
- Freeze legacy bytes, show version rejection then missing validation, implement
  v7 parsing, regenerate/run corpus, compare legacy results, inspect the view in
  a disposable clone. This is authorized executable diagnostic design work.

## Evidence and boundary

The current causal contract's Version 7 and capture assessment's Recorder v7
section carry the result. The frozen k141 corpus matches 1,644 controls, with
175 new cases; all 1,469 earlier reports and 2,938 earlier case/trace files are
identical itemwise. Lint/format, strict typing and 1,650 tests pass. A rounding
mutant fails on adjacent values above 2^53. The diagram was rendered and viewed
in the disposable clone; wide labels are readable, narrow labels are small,
and only light appearance was established. The clone is stopped and removed.

No native marker read/write, honest complete producer, sample freshness or
coverage result is claimed. K142/k143/k144 remain live under the original
charter. The final complete artifact, not this schema slice, earns the required
fresh review. No ancestor closes; the product ADR set stays unchanged.
