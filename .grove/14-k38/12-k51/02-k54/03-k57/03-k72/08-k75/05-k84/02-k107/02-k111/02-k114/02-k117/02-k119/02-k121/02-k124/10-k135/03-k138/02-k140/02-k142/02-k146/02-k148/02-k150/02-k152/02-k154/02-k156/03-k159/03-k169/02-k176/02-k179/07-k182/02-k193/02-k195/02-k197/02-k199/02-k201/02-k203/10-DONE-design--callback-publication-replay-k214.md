# callback-publication-replay-k214

## Goal
Repair the concrete consumer-policy conflicts accepted by k213, so k205 can
plan a determinate report without choosing evidence semantics in implementation.

## Context
Read k212's committed review (85799c2c), k213's assessment dispositions and
publication-replay.md, transport-evidence.md, transport-lanes.md, capacity and
both recorder contracts. K211's proposal is not an assumption of correctness.
The k203 brief and all original ancestor criteria remain binding.

## Done when
- Resolve finding 1 with a bounded receipt-dependency/path algorithm and an
  explicit contract for positive-order monotonicity. Distinguish crossing a
  receipt by local lane order from using its attribution or admission bundle.
  Preserve mandatory multi-begin/frame support; do not fix it by dropping a
  necessary contributor. Derive separate raw/order/frame/composed results for
  the local-intervening-receipt and added-shorter-path counterexamples, plus
  honest neighbors and isolating mutants. Reconcile transport-lanes' promise
  and R02/R10–R13/R22/R23/R29; account for any changed work/storage derivation.
- Enumerate interpretation's controller checks versus claim-local phase/tuple
  failures (finding 2). Give determinate full reports for an ordinary in-replay
  C post, controller C tuple mismatch and malformed local receipt, alongside
  honest controls. Preserve independent columns under earlier summary failure.
  Do not rely on the review's unconditional legacy comparison: sampled_evidence
  keeps callback scope only with trusted=True; the complete controller can fail.
- Assign every acquisition sub-predicate a domain (finding 4): matching/total
  acquisitions, hint absence/count, ALL acquisitions-before-enter and all
  milestone counts/eligible endpoints. State whether each is prefix-relative
  or closure-aware and why. Derive R25 core, each constituent fact and state;
  add preheld open-tail and closed honest neighbors with isolating mutants.
  A partial state alone cannot conceal indeterminate reported fact columns.
- Finish R34's full-report result: distinguish one eligible armed plus a
  decodable post-fault armed row from two eligible armed receipts, including
  whether any raw local check refutes interpretation. Keep k213's explicit
  assertion-count trade-off, R33 coordinate distinction and all diagnostics.
- Reconcile publication-replay, evidence, lanes, both contracts including the
  causal vocabulary, capacity derivations, assessment ownership, k205 and every
  affected replay/claim/state view. Render and inspect changed views only in a
  disposable TestAnyware clone. Each changed rule has determinate expected
  columns/state/scope, an honest neighbor and an isolating mutant through the
  existing real-file seam. Keep k213's R30/R31/R35 profile-isolation obligations.
- Hand the resulting artifact to the already scheduled k215 fresh review,
  before k205. No competing in-session reviewer. V1–V26 inputs/limits/fixtures/
  reports remain unchanged; no analyzer version or native execution claim.

## Notes
This is a bounded repair of identified counterexamples, not another general
survey. K205 retains complete executable delivery and the numeric profile freeze,
not an implementer. Preserve all six k203 criteria, every earlier criterion and
k180/k177/k143/k144/k126 plus every k124/k121 duty. No ancestor closes.

## Decisions (running log)

- K212's local-intervening-receipt and shorter-path counterexamples hold. Replace
  vertex inheritance with explicit edge-justification dependencies and choose
  the shortest dependency-clean path. Keep every contributor for attribution;
  local crossing alone consumes none. State monotonicity for support-preserving
  additions, not additions that create a cycle or invalidate an old dependency.
- Separate controller interpretation (readable, identified local evidence) from
  phase/tuple/decision correctness. A fault opens the collection; it is not by
  itself a positive interpretation refuter. Self-contained malformed receipt
  evidence is a refuter even beyond a semantic cut. Ordinary C posts and C tuple
  mismatch retain independent core/retention columns. No legacy result is changed.
- Acquisition matching/total/hint counts and ALL-acquisitions use raw retained
  assertions with sampler collection closure. Unique observed milestones remain
  prefix-relative with eligible endpoints. R25 therefore has acquisition/core U,
  not T; both construction paths need explicit constituent reports.
- K215 already owns fresh review, so no in-session reviewer is dispatched.
  K205 keeps complete executable delivery and numeric profile freezing; no
  runtime code, legacy fixture or ancestor completion belongs to this repair.

- Completed R34: well-formed armed tail after controller fault leaves interpretation
  U, B/S/X U and core U; malformed local tail R refutes interpretation; two eligible
  armed receipts instead refute selection/core. R33 assertion counting is unchanged.
- Reconciled both contracts, causal vocabulary, evidence, lanes, report capacity,
  assessment, k205 and three views. Path bounds now allow raw plus usable witnesses
  and finite dependency preprocessing; k205 still owns exact numeric freezing.
- Document checks passed with deliberately detected inventory/preservation/state
  mutations and dirty parent policy controls. All changed diagrams/full captions
  were rendered and inspected in a disposable TestAnyware clone at wide light and
  narrow dark sizes; clone stopped. Evidence/k214 records hashes and limitations.
  No successor controls, analyzer/native execution or legacy corpus renewal is claimed.
- Retire only this leaf. K215 fresh review and k205 planning remain live in k203;
  every original ancestor criterion and named native owner remains live. No cascade.
