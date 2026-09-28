# callback-publication-generator-cycles-k270

## Goal
Add the cycle parameters to k269's generator: extra contributing begins at
stated supervisor-lane positions (each a cyclic local edge) and the bad
bundles they cause. Reproduce the cycle files.

## Context
The k265 brief. The k269 generator and its reproduction check. multi-cycle
differs from multi-clean only by where G's second armed-relay begin (call 640)
sits: after the input-B-2 ingress in multi-cycle, and before it in
multi-clean. upstream-cycle reverses the ready-C ingress and relay rows.
publication-path-controls.md "Upstream join controls" and "Split contributor
control".

## Done when
- A parameter vector expresses multi-clean, multi-cycle and upstream-cycle,
  and each generated graph equals that file's `build`, checked with k269's
  field comparison. For each file no vector expresses, the leaf records the
  reason.
- multi-cycle reproduces 1,033 witness refs and a total of 1,040.
- A cyclic edge at the wrong position fails the reproduction check.
- The census is green under evidence/k254, and k253's record stays
  byte-identical.

## Notes
The turn0 files change only `enter.turn`, which the graph does not see. Check
whether they need anything beyond the multi-* vectors.

## Decisions (running log)
- The cycle parameters are a `Vector` of two groups. A `Split` names a relayed
  message whose supervisor egress write takes a second, last-byte begin, and the
  later ingresses hoisted to sit before that begin. Each hoisted ingress gives
  the cyclic local edge ingress→begin. `upstream` names relayed messages whose
  relay commit precedes its own ingress (the reversed identity join). A position
  is named by message, not by row number: the V18 base's send messages are
  unique, and a name survives k271's row scaling where a number would not.
- The oracle files map to vectors: clean (none), multi-clean (split armed),
  multi-cycle (split armed, hoisting input-B-2), upstream-cycle (upstream
  ready-C). The turn0 files take their multi-* vectors unchanged: `enter.turn`
  is in no `Graph` field, so their builds equal the multi-* builds. Every file
  has a vector, so none needs a recorded reason.
- Bad bundles are not a parameter. They follow from the cycles, so the check
  compares `bad_receipts` of the generated graph with the oracle's.
- The wrong-position mutants each move one of their file's own cycle
  parameters: hoist sample-complete instead of input-B-2, split sample-complete
  instead of armed, reverse ready-B instead of ready-C. Each must fail on
  `edges`. The first closes a 45-vertex SCC through the whole sampler enclosure
  (416 / 461), which the doc says the real file never does.
