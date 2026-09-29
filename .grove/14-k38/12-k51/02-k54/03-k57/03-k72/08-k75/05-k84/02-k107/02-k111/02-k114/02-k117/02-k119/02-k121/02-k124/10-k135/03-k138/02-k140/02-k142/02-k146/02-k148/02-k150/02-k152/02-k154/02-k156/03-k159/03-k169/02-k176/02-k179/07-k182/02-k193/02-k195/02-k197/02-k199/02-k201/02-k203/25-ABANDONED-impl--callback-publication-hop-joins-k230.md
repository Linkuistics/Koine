# callback-publication-hop-joins-k230

## Goal
Stage-3 exact joins and cross-hop grades: embedded producer and protocol
payload joins, auxiliary admission/PID/production/table/use provenance, and
per-frame O/J/E/D or P/E/D requirements with F/U/I aggregates.

## Context
transport-evidence.md "Independent requirements and cross-hop grades",
"Auxiliary routes and candidate provenance"; transport-lanes.md "Owners,
sockets and auxiliary traffic", "Candidate attribution through the supervisor"
and "Histories that distinguish the topology"; publication-protocol.md;
publication-auxiliary.md.

## Done when
- Protocol input/active/failure payloads joined to their exact original sender
  observation (cause, tuple, ordinal); auxiliary admissions, peer PIDs, unique
  origins, table production/receipt/use and native argument joins; both hops
  and supervisor-origin routes graded independently with reasons.
- Controls: topology histories (admission/table/sample-release ordinals, queued
  sample-release, controller-origin claiming B, sampler frame bound to
  supervisor PID, swapped B/C table, argument mismatch with tail unavailable,
  same-origin FIFO reversal, changed independent ingress order) and E08–E15,
  E17 (FIFO with shared ordinals and an auxiliary frame between commits).
- Impossible origins and false identity joins omitted while local order and
  each exact physical-hop fact survive; no guessed PID.

## Notes
Edges and the Trace belong to k231; receipt bundles to k232.
