# callback-publication-transport-k190

**Reviews:** callback-publication-transport-k185

## Goal
Challenge the completed k186–k189 publication transport contract as one design,
including all k183 findings and the original k185 criteria, before executable k182.

## Context
Read the full k185 brief and terminal k186–k189 leaves, k183 findings and k184
integration dispositions. Review these committed artifacts together:

- `docs/verification/callback-native-capture/transport-lanes.md`
- `docs/verification/callback-native-capture/transport-evidence.md`
- `docs/verification/callback-native-capture/publication-lifecycle.md`
- `docs/verification/callback-native-capture/publication-capacity.md`
- Both recorder contracts' proposed-publication sections, the native baseline
  budget distinction, and `docs/verification/callback-capture-transfer.md`.
- All eight views named by `docs/design/architecture/diagrams.json`, their editable
  sources and captions, README and k189 render/presentation evidence.
- `publication_budget.py`, Taskfile's design:measure-publication-budget task and
  k189 census/check/preservation evidence, including the compressed per-case and
  input-hash archives. Census arithmetic is not executable transport conformance.

## Done when
- Challenge shared auxiliary framing, exact routes/identity/PID provenance,
  original coordinates, five physical lanes versus four protocol roles, cuts,
  and collector permutations against the current Trace seam and legacy corpus.
- Exercise decisive closure, mixed-hop F/U/I folding, every supported edge
  despite aggregate U/I, independent local/controller/resource diagnostics and
  the observable reply-ingress-before-egress-result cycle. A hand-supplied
  opposing edge in k181's illustration is not the required executable witness.
- Challenge every M01–M33 publication/drain choice, pending buffer ownership,
  permanent seal with late completion, queued/new mandatory commits, safe
  stopped-reader bytes, and external bounds without fabricated returns/exits.
- Challenge E01–E24, L01–L34 and B01–B20 with adjacent valid controls and expected
  independent outcomes, including malformed calls/results/offsets/completions,
  both truncated tails, excluded results, stalled auxiliary traffic and locally
  correct/incorrect controller decisions under impossible/unverified attribution.
- Recompute encoding/census/reserve arithmetic and challenge actual representation
  feasibility, independent caps, auxiliary/post-seal accounting, overflow and
  unavailable evidence. Verify that old limits and frozen inputs/reports remain
  unchanged and that k182 still owns actual serialization and falsification.
- Reconcile all nine original k185 criteria and twelve k183 findings itemwise.
  Report concrete findings at committed file/line positions, or an evidenced
  no-findings result, without editing the reviewed design. Any necessary findings
  integration must be inserted immediately before k182.

## Notes
Inspection only. No new causal engine or native/product/permission claim.
K182 retains full schema/version/Trace/falsification/permutation/corpus renewal;
k180 every-phase loss; k177 full sampler/non-stopped cancellation; k143 targets;
k144 controller deadlines/time reserve/review; k126 native audit/private-loop/
source servicing, actual exits/containment and every original k124/k121 duty.
Rendering/viewing only in a disposable TestAnyware clone.

## Findings

Read against k189 commit `774081f` (jj `qpvwornx`). Prefixes: `L:` transport-lanes.md,
`E:` transport-evidence.md, `Y:` publication-lifecycle.md, `P:` publication-capacity.md
(all under `docs/verification/callback-native-capture/`), `N:` that directory's
contract.md, `A:` callback-causal-fixture/analyze.py. Nothing was run except
read-only parsing of the committed k189 census archive. Severity order.

What holds up. `git diff 841ce49 774081f` touches no analyzer, controls, V1–V26
fixture or k178 result; both old-contract hunks are the proposed-publication
sections plus labelled "baseline"/"V3" pointers (N:228-231, N:866-868, N:987-994).
The arithmetic recomputes exactly: 11,609 and 12,973-byte rows; 137 physical
commits; 336 supervisor begins; 737,280 raw buffer bytes; 4,721,299 envelope;
20 of 48 MiB reserved; 2,048-512=1,536 ordinary rows. The archived per-case item
for `v3-...-surplus-after-partial-finish` reproduces 337/114/162/141/815 = 1,569
rows (43+17×15+39, 25+17×8+1, 19×35+150), and the archive holds 8,120 items over
versions 1–26 with no unreadable rows. Reserve tails fit their shares even when
the app's receive images are counted (≈1.96 MB < 2 MiB). The F/U/I fold, decisive
closure, origin-I-survives-missing-ingress rule, supported-edge table and E20/E24
cycles are sound as record-order arguments: every edge is append-time order under
the serialized lane lock or begin-before-visibility/receipt-after-read. M01–M33
covers every version section I checked (V1–V26 incl. V11–V13 startup, helper wait
at N:531-535). All nine k185 criteria and twelve k183 findings have a location
(P:273-293); k182/k180/k177/k144/k126 ownership is intact. The EINTR/EAGAIN
terminal policy is a stated trade-off (fixture contract 2959-2963), not a finding.

### 1. Cycle membership condemns the innocent claims on the cycle — medium

E:198-201 makes any claim whose necessary edge lies on a cycle "causally
impossible" even with an all-F vector. A cycle cannot name its culprit: every
edge on it is equally "on a cycle". In E24 (E:264-266) the moved begin G43 is the
defect, but the cycle S20→S21→S22→G44→G43→S20 also carries S22→G44, the
contributing-begin edge of reply r, whose receipt G44 is entirely genuine. By the
rule r becomes causally impossible too. E24's expectation says only "report
causal impossibility" and names no per-claim outcome, and E:201-202 ("an
unrelated cycle ... without changing another route's byte facts") does not cover
a route that is related only by sharing the cycle. K182 must therefore choose
whether r is impossible — exactly the per-claim status the charter says k182
must not invent. Integration should either give cycle membership its own
status (e.g. `cycle-contradicted`, distinct from byte/join I) or state
explicitly that all claims on a cycle are impossible, and give E24 (and E20's
mutant, E21) exact per-claim expectations for q and r.

### 2. "Reuse Trace's cycle mechanism" is not possible with the Trace that exists — medium

E:163-164 requires reusing Trace's adjacency/reachability/cycle mechanism "not a
second causal engine", while E:196-205 requires non-fail-fast reporting of each
cycle witness, fixed-graph classification of affected edges by reverse
reachability, and continued independent columns. Trace.acyclic (A:639-653) is a
Kahn count that raises `causal-cycle` with no witness, and Trace.create raises on
any fault row or incomplete stream (A:598-604). Nothing in the current mechanism
yields a witness or a per-edge classification, so k182 must add one and then
decide on its own whether that addition is the forbidden "second engine". The
prescribed method ("a reverse reachable path from target to source" per edge,
E:202-203) is also one DFS per necessary edge over lanes of up to 10,240
vertices, beside P:187-188's bound concern. Integration should name the minimal
seam extension (a non-raising cycle/SCC pass on the same adjacency that returns
witnesses; an edge is on a cycle iff both ends share an SCC) as part of the
existing seam.

### 3. Several histories cannot be instantiated for the writer class they describe — medium-low

Y:139-147 records a seal only in the writer owner's lane, and forbids a blocked app
from appending a seal or end (Y:144-146, Y:187-188). It then assigns only L05–L08
to a supervisor writer. But:
- L08 (Y:266) describes app state ("next calling-context native cleanup",
  "earlier source/right obligations", "the app's buffer") under a history `b,X`
  that Y:144-146 says an app cannot record, and its "supervisor seal" is what
  Y:142-143 calls an external request rather than a seal.
- E05 (E:229) puts `lane_end` after a pending begin. Y:186-188 permits that only
  for an owner with another I/O context, i.e. the supervisor. E07 (E:231) seals
  a pending call ("direction abandonment"), and L09 (Y:267) ends with a call
  pending. Neither names its writer class.
If k182 instantiates any of these with an app writer, it builds a history the
contract calls impossible. Integration should name the writer class for every
E/L/B row whose seal or end precedes a return. It should also split L08 into a
supervisor-writer buffer-reuse case and an app case: blocked call, supervisor
external request, then app native cleanup without a result.

### 4. The supported semantic base set is left for k182 to decide — medium-low

L:151-153 says the successor "must preserve" V26's V14–V25 base choice. Y:116-120
says startup V11–V13 obligations keep their own base "when the new successor
supports those paths" and that "K182 versions that extension". So whether the
successor accepts V11–V13 bases is conditional, and k182 decides. M16–M18, M24,
L23 and L24 are dead or alive depending on that choice, and so is k180's
startup-loss handoff. The census counts all versions either way. Integration
should state the supported base set, and reconcile L:151-153 with Y:116-120.

### 5. The legacy comparison has no rule for order that the successor adds — medium-low

The global supervisor lane adds real recording-order edges between unrelated
connections (L:105-111, L:242, E:168). Every legacy send→receive order is also
recovered through commit→begin→ingress→relay→begin→receipt. So on complete
histories the successor graph's reachability is a strict superset of the
legacy graph's. Verdicts that depend on *absence* of order can therefore flip
between the successor and its labelled legacy comparison. An example is
`ambiguous-activity`, reported when activity is "not provably before/after"
(N:550-552). L:194-199 names only "intended loss-policy difference[s]" as
reportable. It does not say whether a difference from added order is expected
or a preservation failure. K183 finding 5(b) asked for exactly this effect on
legacy comparison. Integration should classify the permitted directions of
difference (added supported order vs. lost order outside a physical cut) and
name the affected verdict classes.

### 6. Budget stop leaves supervisor readers unspecified, and the reserve omits their rows — low

P:193-203 stops useful work and new begins at `budget_stop`, but says nothing
about readers. Y:175-176 lets an in-prefix ingress justify a later terminal
egress K, which implies that ingress continues after seals. The supervisor
reserve (P:172-176) counts commits, results, L, seals, stops and 32 local
observations, but no post-stop ingress receipts (7,513 B each). The arithmetic
still fits (≤71 extra receipts), so this is not overflow. It is an unstated rule:
does the owner's `budget_stop` also stop reading (then drains become
unobservable), or does reading continue into reserve? Its reserve line should
match whichever is chosen.

### 7. The supervisor lane's content boundary against the native audit is unstated — low

L:92-96 lists admissions, auxiliary production, ingress and egress. L:51-53 adds
activation helper launch/result. Y:239-240 records registered-app exits and
parent-wait status "where available", without saying where. N:523-524 and
N:1038-1041 also require startup launch helpers (four spawn/wait pairs),
membership snapshots and helper records. The 150-row allowance counts only two
activation helper launches/results, lane boundaries and ten spare slots
(P:104-108). The reserve instead counts "32 admission/helper/exit/bounding
observations" (P:175). N:987-994 keeps a separate 1,024-row supervisor audit.
State which of these observations are successor-lane rows (and therefore counted
and cut with the lane) and which stay in native audit.

### 8. Edge inclusion is unstated for an unambiguous but illegal call — low

E:65-67 excludes malformed intervals from supply. E:170 adds an edge for "every
unambiguous matching call" contributing bytes. A begin after a seal (B08
P:248, L13 Y:271, Y:179-182) is unambiguous but illegal. It is unstated whether
its begin→receipt edge enters Trace. If it is included, a cycle can be found; if
excluded, one can be hidden. State which.

### 9. Encoding and accounting nits — low

- P:41 caps frame ordinals at 1–80. A `read_stop` after an 80th receipt must
  carry next ordinal 81 (Y:195-196, L17), which that range rejects. That matters
  at the exact-limit controls B19/B20.
- P:102 says "controller adds two auxiliary writers (36 rows)", but each app has
  exactly one directed writer (L:21-22); these are two auxiliary *frames*.

### 10. The views omit two lifecycle paths — low

- `process-recorder-write-state.mmd:10-21`: every frame enters at Queued, so a
  mandatory commit on an already-sealed direction (Y:160-167; k183 finding 8,
  second bullet) has no direct terminal-unattempted entry. A short result
  always returns to Queued, with no attempt-limit seal (contrast
  `process-recorder-capacity.mmd:17-18`).
- `process-recorder-reader-stop.mmd:9-18`: EOF/error reaches Closed only from
  Buffered or PendingRead. An EOF with an empty buffer (fixture contract
  "empty EOF is a closed read direction") has no path.

Findings 1–5 change what k182 would implement or expect. Integration precedes
callback-publication-evidence-k182.
