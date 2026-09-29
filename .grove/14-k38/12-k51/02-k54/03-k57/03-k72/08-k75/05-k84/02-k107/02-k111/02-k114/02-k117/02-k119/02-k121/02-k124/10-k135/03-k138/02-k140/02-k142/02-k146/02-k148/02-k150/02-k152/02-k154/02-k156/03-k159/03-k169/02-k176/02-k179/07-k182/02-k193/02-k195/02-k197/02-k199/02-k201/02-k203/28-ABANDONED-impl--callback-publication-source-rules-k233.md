# callback-publication-source-rules-k233

## Goal
Extract the local source/right/loop transition and value rules once, with a
thin legacy exception adapter proven itemwise equal and a successor claim
adapter over eligible replay domains.

## Context
publication-replay.md "Existing producer families and migration" and
"Producer invariants and replay limits"; the sampler_*, source_calls and
native_ownership modules and their legacy gates.

## Done when
- Shared rule definitions; legacy callers keep version gates, fault/sequence
  cuts, first exception and result fields; every V1–V26 report and all
  multi-defect precedence fixtures are itemwise unchanged.
- Successor adapter: explicit eligible domain, qualification and unknown
  guards; raw consistency outside replay reported separately from stateful
  replay; pending resources/leases never emptied at a cut; first local cause
  per owner; source-selected F/M begin API names; raw wrong values,
  release-before-validation and refusal as independent candidate diagnostics.
- Controls: R17 complete (V15 fault at 9, stateful 1–8, claimed release, bad
  raw tail pair, other roles intact; kill physical-fault conversion, replay
  through fault, global suppression) and the startup/partial_history
  precedence differences (V17–V19/V23–V25 safe prefixes, startup overrides).

## Notes
If a rule cannot be shared, name it and its differing inputs in the replay
contract; that permits a small successor composition, not a second engine.
These modules are wholly local, so their records go in the sidecar-eligible
`source-rules` section. A migrated rule with an order-claim operand places its
records in `ordered-rules` (publication-capacity.md sidecar closure rule).
