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

## Decisions (running log)

- 2026-10-30: Adopt k100 in the clean jj workspace at 08808cc9. Read k99's
  findings from that commit against k97, the brief chain and the agreed scope.
  Tier 2 coverage uses generation 2026-10-30T10:25:42Z. Direct reads resolve
  partial shell and diagram coverage and untracked Bats metadata.
- 2026-10-30: P2-1 is an unclear contract. The existing worker waits for capture
  completion before another sleep. State that rule and enumerate its phases.
  P2-2 is a real schema and allocator gap. Keep one owner-assigned ordinal and
  add immutable commitment, launch and result records with explicit writers.
- 2026-10-30: P3-1 is an unclear contract. The backend retains its receipt and
  latch writes under owner authority. P3-2 is a real identity and supervision
  gap. Specify process topology, caller identity and parent-channel loss.
- 2026-10-30: P3-3 is a real control-enablement gap. Distinguish external CLI
  and sleep controls from internal test barriers. Carry any unapproved seam
  choice to k98. P3-4 is a real organisation and vocabulary gap. Repair both
  without creating an ADR for this incomplete, readily reversible design.
- 2026-10-30: Commit the prose conversion separately as 078f1d3b. Its final
  checker result has no hard findings. Retain every earlier check receipt.
- 2026-10-30: Repair the lifecycle within the existing owner design. Distinguish
  backend emission, payload acknowledgement, terminal publication and completion.
  The narrow doubt claim is that this sequence has no circular wait or false
  completion join. One fresh reviewer inspects that contract and finds no
  material violation. No second reviewer runs.
- 2026-10-30: K98 must settle the proposed internal test barriers before treating
  them as agreed. The current spec and KEEPALIVE-LIFECYCLE-REVIEW.md carry the
  recommendation, alternatives and costs. All numerical and resource duties,
  downstream holds and original obligations remain. No ancestor closes.
- 2026-10-30: Inspect both rendered diagrams and repair the stale exclusive-writer
  caption. The browser reports no errors. The link check retains exactly the two
  known archived k23 missing targets. Retain the initial and final check receipts.
  K98 remains live for the complete profile, so this retirement closes no node.
