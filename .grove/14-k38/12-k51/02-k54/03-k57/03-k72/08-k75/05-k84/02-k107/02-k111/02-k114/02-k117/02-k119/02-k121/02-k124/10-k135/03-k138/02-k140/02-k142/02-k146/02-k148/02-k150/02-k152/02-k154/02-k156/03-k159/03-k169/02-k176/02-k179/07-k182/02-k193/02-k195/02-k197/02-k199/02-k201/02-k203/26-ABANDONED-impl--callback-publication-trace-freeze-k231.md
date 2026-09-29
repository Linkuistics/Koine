# callback-publication-trace-freeze-k231

## Goal
Enumerate every individually supported edge with its rule/anchor
justifications, instantiate the one Trace, and call cycle_components once with
the validated canonical physical permutation; report SCCs and per-frame cycle
status.

## Context
transport-evidence.md "Trace edges and contradictions", "Executable graph
interface (k192)", "Observable reply/result cycle and loss variants";
transport-lanes.md "Observable reply before egress result"; publication-
replay.md stage 4, "Selected successor edge rules" and "Counting domains and
closure"; publication-path-controls.md "Edge inventory and ownership" item 5
and "Split contributor control".

## Done when
- Physical local order, contributing begin→receipt (pending included),
  ingress→relay, production→commit and table→use→begin edges; parallel
  justifications kept distinct; no logical send→receive or result→receipt
  edge; no edge added or removed after freeze.
- W-input/W-enter witnesses enumerated before freeze on every V11–V25 base
  from eligible producer endpoints: the raw counting sets of publication-
  replay.md "Counting domains and closure" (physical-coordinate counts, raw
  versus eligible tags), observed count=1 admission, tuple/role/route checks
  and one locally qualified earlier R(armed) from k228; phase violations
  reported separately. Edge-admission parts only: R06 (qualified plus
  undecodable armed adds W-enter, two qualified omit it), R07 (inactive C
  keeps W-input, tuple mismatch removes it), R18 tail enter and R33 duplicate enters/
  inputs (no witness), each with honest neighbour and fixed graph digest. The six
  k217 fixtures' W edges (path-controls item 5) and multi-cycle's exact
  seven-vertex SCC including T35→B25 are asserted here.
- E20–E24 with q and r graded separately through the actual loader, including
  the incorrect-edge edge-selection mutant for E20/E21 and E24's real cycle;
  R20 (valid illegal post-seal interval keeps its edge and violation, ambiguous
  interval adds none); B08 edge retention; R14 (disconnected cycle beside an
  independent local contradiction).
- Graph and SCC digests identical under both collector permutations;
  admission charges max_edges and max_edge_justifications, and the
  witness family's claims/diagnostics.

## Notes
W-input/W-enter admission is here because k232's P-multi and the k217 SCC
digests need it (k243 finding 1). Closure, exact-count/at-least claims and the
suitability/claim columns of those controls stay with k236; the freeze stays
single.
