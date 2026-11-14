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

## Decisions (running log)

- 2026-10-29: Adopt k95 in the clean jj workspace. Read k94's findings from
  commit 79b6b340, against k92's 5ce8a16e artifact and current contracts. Tier 2
  graph generation 2026-10-29T10:51:10Z locates the backend; direct reads cover
  the shell parse gap at line 175 and untracked Bats/task metadata. Unrelated
  Swift/trace call edges are not evidence. Tagged TestAnyware reads use 65bc05c9.
- 2026-10-29: P2-1 and P2-3 are real design omissions. P2-2 is an unclear
  contract: scheduling delay must explicitly reopen the excluded driver-wait
  class. Add the normal-stop choice and separate liveness-only option to k93's
  decision surface without approving them. Preserve every required failure.
- 2026-10-29: P3-1, P3-2 and P3-3 are real precision omissions. Add transport
  classes, the tagged viewer/recorder and the two-sided ownership argument.
  Qualify two review claims: five seconds bounds message readiness, not a
  whole capture; agent snapshot with open-menu also uses VNC. A liveness-only
  worker adds no intentional scenario wait but cannot promise unchanged timing.
- 2026-10-29: P3-4 is a real maintenance defect. Keep the proposal in the design
  and its editable discussion views. Reduce the spec, protocol, capture summary
  and live handoffs to binding holds and pointers. No settled design decision
  earns an ADR. No production code, cadence, lock rule or ordinary caller changes.
- 2026-10-29: Spend the one narrow in-session reviewer on the repaired normal-stop,
  first-failure and authority contract. The fresh reader reports no issue after
  examining those sections and the spec hold. This is one aimed review, not a
  second independent whole-design sample. No cross-model review or redesign is
  requested. The concrete implementation remains k93's later, conditional work.
- 2026-10-29: The final documentation check returns Task exit 201 for only the
  two existing k23 archive targets, context-predicate.txt and
  context-qualify-filter.sh. The 210 measured source files and source membership
  stay unchanged through the check and final browser inspection. Both edited
  Mermaid views render and their screenshots are legible after replacing the
  sequence note's semicolon delimiter. Exact results, coverage and digests are
  retained in ordering-keepalive-integration-evidence. No production tests run;
  the jj diff contains no script, test, product or Taskfile change.
- 2026-10-29: All seven k94 findings have explicit dispositions in the design.
  The spec/protocol keep only the binding hold and pointers; the decision surface
  and live k93/k89 handoffs agree. Retire k95 only. K93 and k89 remain live, so
  k85 and every ancestor stay open. No producer review needs a Creator receipt
  from this integration. No scope approval, implementation or runtime follows.
