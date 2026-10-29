# settings-keepalive-coordination-k95

**Integrates:** settings-keepalive-coordination-k94

## Goal
Triage the k94 review of the k92 keepalive coordination design. Apply the real
findings to the design and the contracts it touches before
settings-keepalive-scope-k93 decides.

## Context
Read the findings in the k94 review leaf and its commit. The reviewed artifact
is commit 5ce8a16e. Grade each finding against the k92 charter, the k85, k80,
k75, k71 and k66 charters, the accepted spec and the ordering protocol. Use the
current backend, capture library, capture controls and the TestAnyware v2.7.0
tag at commit 65bc05c9 as source evidence. No in-session reviewer ran in k94.

## Done when
- Classify each k94 finding as real, a visible trade-off, an unclear contract or
  noise, with a reason.
- Apply each real finding inside the design document and the contracts it
  touches. Change no production code, lock rule, cadence or ordinary caller.
- If a finding needs a human decision, hand it to settings-keepalive-scope-k93
  as an explicit choice with its costs. Do not record it as an approved change.
- Keep adoption, runtime, guests, candidates and freezes held. Keep every
  k89/k81/k76/k67/k62/k57/k54 duty and every availability and privacy limit.
- Record a receipt for any documentation check you run. Close no ancestor.

## Notes
The findings live with the review, not in this charter. A non-mechanical repair
may spend one narrow in-session reviewer. Substantial redesign goes to a new
producer and review chain beside this leaf, not into it.
