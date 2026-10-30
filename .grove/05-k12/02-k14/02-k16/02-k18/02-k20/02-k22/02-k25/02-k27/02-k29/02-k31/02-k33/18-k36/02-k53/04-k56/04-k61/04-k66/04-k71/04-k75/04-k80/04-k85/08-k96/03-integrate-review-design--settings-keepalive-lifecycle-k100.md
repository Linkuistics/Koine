# settings-keepalive-lifecycle-k100

**Integrates:** settings-keepalive-lifecycle-k99

## Goal
Triage the k99 review of the k97 owner and worker lifecycle design. Apply the
real findings to the spec and the contracts it touches before
settings-keepalive-profile-k98 consumes the lifecycle contract.

## Context
Read the findings in the k99 review leaf and its commit. The reviewed artifact
is commit aa600318. Grade each finding against the k97 charter, the k96 brief,
the k93 scope agreement in KEEPALIVE-DESIGN.md, the product-spec hold and the
ordering protocol. Use the current backend, capture library, legacy loop and
capture controls as source evidence. No in-session reviewer ran in k99.

## Done when
- Classify each k99 finding as real, a visible trade-off, an unclear contract or
  noise, with a reason.
- Convert docs/specs/settings-keepalive-owner.md to controlled English as its own
  preparatory commit before you edit it.
- Apply each real finding inside that spec and the documents it touches. Change
  no production code, lock rule, cadence or ordinary caller.
- If a finding needs a human decision, hand it to k98 as an explicit choice with
  its costs. Do not record it as an approved change.
- Keep adoption, runtime, guests, candidates and freezes held. Keep every k89,
  k81, k76, k67, k62, k57 and k54 duty and every availability and privacy limit.
- Record a receipt for any documentation check you run. Close no ancestor.

## Notes
The findings live with the review, not in this charter. A non-mechanical repair
may spend one narrow in-session reviewer. Substantial redesign goes to a new
producer and review chain beside this leaf, not into it. K98 consumes the
lifecycle contract only after this integration retires.
