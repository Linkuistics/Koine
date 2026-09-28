# callback-publication-replay-k215

**Reviews:** callback-publication-replay-k214

## Goal
Adversarially verify the repaired consumer policy and k213 clarifications before
k205 plans implementation and freezes the report profile.

## Context
Read k214's own commit, k212's committed findings and k213 dispositions. Re-derive
results from current artifacts and source, not prior conclusions. The k203 brief
and all original criteria bind. This is inspection only; no policy fixes.

## Done when
- Try to falsify local-lane versus attribution receipt dependencies, multi-begin
  ownership, raw F masking, independent scalar refuters and OR alternatives.
  Challenge positive-order monotonicity with an added shorter path and an
  existing cyclic receipt bundle. Check finite algorithm and report bounds.
- Verify enumerated interpretation checks against ordinary C posts, controller
  tuple mismatch, invalid receipt and armed tail rows. Require a single derived
  state/scope and independent fact columns for each, with honest neighbors.
- Check every acquisition count/absence/ALL domain and both construction paths
  on open tails; derive R25 and preheld-neighbor core values, not only state.
- Check successor vocabulary explicitly differs from legacy where intended;
  resource status is not input refutation and duplicate assertions do not prove
  distinct native callbacks. Check R33/R34 raw versus eligible outcomes.
- Verify the internal test-profile guard, R30/R31 per-dimension isolation and
  R35 production entry controls, distinct actual-frozen-value evidence and
  k205's numeric-freeze ownership. Do not credit substituted test limits as
  attainment of conservative production maxima.
- Check all revised rules/controls agree across contracts, evidence, lanes,
  capacity, assessment, k205 and affected views. Require exact results, honest
  neighbors and isolating mutants. Proposed controls or renders prove neither
  executable successor nor native success; V1–V26 stay frozen.
- Record located falsifiable findings. If needed, insert integration immediately
  before the still-live k205. Preserve every original criterion and named owner.

## Notes
No ancestor closes. No competing in-session reviewer or native experiment.

## Decisions (running log)

- Read k214 at `d8ae29a` (parent `6fa0d26`) against k212's findings and k213's
  dispositions. Inspection only: nothing was run, rendered or regenerated.
  Finding 1 is a structural counterexample to three expected path controls and
  their mutants; findings 2–6 are precision and control-isolation gaps. An
  integration is needed before k205. Cut callback-publication-replay-k216
  immediately before the still-live k205 planning sibling, carrying only this
  review's handle.

## Findings

Read against k214 commit `d8ae29a`. Prefixes: `R:`
docs/verification/callback-native-capture/publication-replay.md, `E:`
transport-evidence.md and `L:` transport-lanes.md beside it, `C:`
publication-capacity.md, `A:` docs/verification/callback-capture-transfer.md,
`Y:` callback-causal-fixture/analyze.py. Documents and source were read only.
Most severe first.

What holds up. Justification-owned dependencies (R:371-386) correctly separate
local lane order from attribution in principle. Parallel rules stay distinct,
and begin→receipt keeps every contributor, so multi-begin ownership is
preserved. Masking raw F before NOT/AND selection (R:464-467, R:498-499) and
composite-owned masking after operand selection (R:494-496) agree with R22/R29
and with the selected_callback turn=0 derivation (R:807-809). The qualified
monotonicity statement (R:425-435, L:228-238) is true as stated. An old
admissible path survives in a filtered BFS, and every invalidating change is
named in the premise. At most four BFS traversals per query and two retained
paths per query are consistent with the raw/usable definitions (R:334-338,
R:410-415, C:211-222). The interpretation partition (R:516-523) resolves k212
finding 2. Legacy's ordinary C post fails `Post outside frozen schedule`
(Y:1506-1507), so trusted becomes false and legacy gives unsupported
(Y:1779-1780). R:536-539 states this correctly. The R34 derivation (R:746-751)
and its two-eligible-R and malformed-tail variants follow from the counting and
closure rules. The R25 constituent table (R:760-765) matches the legacy recipe's
sub-predicates (Y:1676-1698): hint absence and ALL for preheld; exact-one
acquisitions/hints and enter→hint→acquire→f_begin for acquire-resample. The
successor vocabulary and resource status are explicitly distinguished from
legacy (R:583-594). K205 keeps the numeric freeze, and the injected-profile
evidence is explicitly not attainment of production maxima (R:1016-1028).

### 1. The cyclic-contributor counterexample makes every path through r2 cyclic, so the local-crossing and shorter-path controls have wrong results and do not isolate their mutants — high

The path table's setup (R:785-792) stipulates that `b2→r2` is **cyclic**, which
puts r2 in a nontrivial SCC. A controller receipt has exactly one outgoing Trace
edge class: its local successor. E:182-189 gives controller receipts no other
outgoing edge. Begin→receipt edges end at the receipt, and ingress→relay and
table→use edges start at broker/auxiliary receipts, not at controller receipts.
Every cycle through r2 therefore leaves r2 by `r2→succ(r2)`. That edge has both
endpoints in the same SCC, so it is cyclic (E:173-175, R:343-345). A path that
*crosses* r2 can never be noncyclic. That contradicts three rows:

- **R13 local (R:796, R:948):** controller r1(armed)@10 → r2@11 → post@12. The
  only r1→post path uses `r2→post`, which is cyclic. By R:334-337, raw order is
  U/cyclic-only, not T. The armed→post segment of B→armed→post→enter is then U.
  S, core and state become U/U/partial rather than the stated "reached/
  post-return-retention". The same applies to the sampler enter→f_begin variant.
  E:242-243 and L:232-233 repeat the unattainable "local crossing remains T"
  claim.
- **R02 shorter (R:797, R:937):** a shorter path "using r2 attribution" must
  leave r2 through its cyclic successor. The raw noncyclic BFS already rejects it.
  So k212's canonical-path-then-mask algorithm also returns the longer path and
  T. The named `shortest-before-mask` mutant survives, and the row does not
  discriminate the repaired dependency filter.
- **R10/R11 alternative (R:798):** with only the r2 route left, raw is
  U/cyclic-only, not "Raw T/usable U". `unrestricted-raw-path` is not isolated.

The distinction the repair needs is only realizable if r2 is **dependency-bad
while outside every nontrivial SCC**. For example, its bundle's exact
ingress→relay join (R:355) could be cyclic on the broker lane. That is what
R:785's "exact reversed relay join" would naturally produce (E:187). An order
query that *ends* at the receipt (order(b1,r)) also works for R11 proper. The
setup must name the cycle's vertices and state that r1, r2 and post (or the x→y
shortcut vertices) are outside it. Otherwise the vertex-keyed and
shortest-before-mask mutants pass R13/R02 for a topology reason. The k214
assessment row (A:4993) and k205's handoff consume these controls as isolating.

### 2. The repair-vectors table duplicates inventory rows and leaves R25's and two R34 variants' vectors circular — medium-low

R:741-742 paste the R34 inventory row (R:969) twice into the repair-vectors table
after the R34 vector row at R:740. R:743-744 paste the R25 inventory row (R:960)
twice. The pasted text refers to itself: "Full vectors above" and "fixed by the
repair report vectors". The table header requires "seven constituents / core"
(R:733). R25 therefore has no B,S,E,P,A,X,W vector anywhere, only A/core
(R:760-765) and prose (R:754-756). The derivable vector is T,T,T,T,U,T,T / U. The
malformed-tail variant (expected T/U constituents under interpretation F) and the
two-eligible-R variant (T,F,T,T,T,T,T / F) have no vector row of their own. The
k214 check `R01_R35_unique: true` (evidence/k214/verification.json) passed with
three copies each of the R25 and R34 rows in the file. So the uniqueness
instrument was scoped to the inventory table and never saw this table. Remove the
duplicates. Give each R25 construction/closure and each R34 variant a complete
vector row.

### 3. R25's open-tail mechanism is unspecified, but its ineligible-tail mutants need a semantic cut — low-medium

R:767-777 build the isolating mutants from "tail" acquire/hint rows that "are
ineligible and never acquire state". They name `replay-only-hints` and
`ignored-total-count` as killed. R25's honest neighbour says only "open sampler
tail" (R:743, R:960). A row can be counted but ineligible only if it follows a
semantic cut (R:244-245, R:108-112). The other openness mechanisms used
elsewhere add in-replay rows or no rows at all. A missing lane_end with no
producer fault puts an appended hint inside replay. R24/R26 use physical-cut
openness, where rows beyond the cut count nowhere. In either case a
replay-only-hints mutant still counts the in-replay hint, so the mutant survives,
or the added row cannot appear. Meanwhile the preheld-ALL mutant needs an
*eligible* acquisition after enter (R:773-775). R25 must name its opening event,
for example a sampler producer fault after `retained`. It must also state which
mutant rows sit before or after it, and that the closed neighbour removes that
fault.

### 4. Interpretation's F/U boundary for an unqualified controller receive is undetermined, and R06's lone-row variants have no state — low

R:520 says "A retained self-contained contradiction gives F. Missing evidence
gives U only for a claimed receipt that cannot be locally established." R06
(R:941) lists "a lone wrong-byte/later/embedding-only row" as W-enter omission
controls, but gives none of them an interpretation, state or scope. An
embedding-only armed row is a claimed receipt with no locally established
payload, so both sentences of R:520 apply. The result could be F/unsupported or
U/partial. The later-than-post variant should give interpretation T, S F through
the reverse armed/post order, and partial/core-refuted. That is derivable but not
stated. The brief requires a single derived state/scope for invalid receipt rows.
State which receipt defects are self-contained contradictions and which are
missing evidence, and give each R06 variant its vector.

### 5. Bundle construction still describes a recursive transitive union beside the interned direct-reference representation — low

R:353-367, retained from k211, says bundles "Expand through the exact upstream
receipts" and "Take the least union … with visited receipt IDs. Dependency
recursion terminates …". That reads as a materialized transitive receipt set.
Worst-case storage is quadratic in H. R:388-404 and C:211-222 instead specify
direct edge and upstream-receipt references, one dependency-SCC pass, backward
badness propagation and "Do not expand the transitive union". They charge
O(H+D+S+J). Reports list each claim's "mandatory edges" (R:453). It is not
stated whether those are the direct references or the expanded union, and the
choice changes max_support_refs and the encoded report size k205 must freeze.
Make one representation normative and say how a report exposes a transitive
mandatory edge without serializing the union.

### 6. R35 omits two stated guard obligations — low

R:1010-1013 forbids a "file-selected profile" and says test-profile reports
"cannot be emitted as production-profile results". R35 (R:970) covers CLI flags,
manifest fields and environment variables only. `test-profile leakage` does not
name the falsifier for a test-hook report that is labelled or consumed as a
production result. Add both vectors, or narrow the rule text to what R35 checks.
