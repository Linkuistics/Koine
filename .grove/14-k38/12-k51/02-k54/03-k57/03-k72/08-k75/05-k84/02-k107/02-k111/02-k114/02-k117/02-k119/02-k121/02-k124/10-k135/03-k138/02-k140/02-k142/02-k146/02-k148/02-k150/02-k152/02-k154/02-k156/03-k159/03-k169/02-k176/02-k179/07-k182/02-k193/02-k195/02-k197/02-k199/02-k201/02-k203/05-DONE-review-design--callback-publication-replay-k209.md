# callback-publication-replay-k209

**Reviews:** callback-publication-replay-k208

## Goal
Adversarially check the revised frozen-graph producer interface against its
actual consumers before k205 plans complete executable delivery.

## Context
Read k208's own commit, the revised publication-replay.md and all changed
contracts/views against the full k203 and original ancestor criteria. K206's
committed findings and k207's dispositions explain the concrete doubts; neither
is an assumption that the revised design is correct.

## Done when
- Re-derive the edge-site inventory and version/schedule gates from current
  source; challenge inactive/stray input, qualified versus raw armed receipt,
  partial wire failure and witness insertion order with concrete histories.
- Falsify the migration's legacy equality claim, including staged activity/core
  results, CLI parse/exception/exit/V11 fields and projected manifest. Verify
  producer fault/start/end/PID and duplicate-prefix policies have actual owners.
- Challenge same-role SCC handling, AND/OR/NOT and branch obligations, missing
  evidence, canonical cyclic-only support, alternate acyclic paths and multiple
  contributing begins. Require determinate expectations for all k207 controls;
  no reachability-absence inference or whole-column suppression.
- Check one Trace, bounded support storage, all original criteria, both contracts,
  assessment and views, preserved V1–V26 and exact k205/k180 ownership. Design
  examples or browser checks confer no executable or native evidence.
- Record located, falsifiable findings without fixes. If integration is needed,
  insert it immediately before the still-live k205 planning sibling.

## Notes
Fresh inspection only. No implementation or rewriting legacy expectations.
Render/view only in a disposable clone if presentation inspection is needed.
K205 remains complete executable-delivery planning under unchanged k203.

## Findings

Read against k208 commit `b6e55f3` (parent `4c1b10c`). Prefixes: `R:`
docs/verification/callback-native-capture/publication-replay.md, `E:`
transport-evidence.md beside it, `A:` callback-causal-fixture/analyze.py,
`K:` callback-causal-fixture/contract.md. Current source reads only; nothing was
run, rendered or regenerated. Most severe first.

What holds up. Every edge-adding site reachable from the analyzer is in R:158-170;
a whole-directory search finds exactly A:615, 653, 819, 1107, 1641, 1655, 1925,
1947 and 2529, and the `sampler_*`, native, source and pending modules make no
`before`/`order`/edge calls. The version/schedule gates in the inventory match
A:2127-2165 (V20 trigger witness only with a trigger post; 23/24 unreachable in the
active tuple), A:2276-2310 (C only after-callback and V18, or V24 with a C post),
A:1966-1980 (C only for V24 marker_c; skip without input; raise ends the loop),
A:1625-1662 (silent strict B/C; raw-armed trigger→enter; acyclic may raise) and
the fault-cut sets at A:1903, A:2053, sampler_startup.py:196/208,
source_calls.py:353, native_ownership.py:395 and sampler_loop.py:122. Trace.witness
raise order/exits (A:811-820, default exit 3 at A:120) are stated correctly. The
CLI boundary (A:2628-2719) matches R:376-421, including the V11-only slice fields
and `producer_version` parse selection. `parse_manifest`'s ten V11–V25 fields
(A:189-237) match the projected manifest. Legacy MAX_RECORDS/MAX_LINE limits
(A:41-43, 446, 559) make projection-induced size errors possible; R:411/430
already treats them as honest legacy results. The clean/cyclic path rules agree
with `cycle_components`: its cyclic edges are exactly intra-SCC edges (A:753-758),
so endpoints sharing an SCC never have a clean path and the R:228-237 steps
cannot yield both a forward clean and a reverse path. The evidence records claim
byte identity only (`runtime_rerun: false`).

### 1. The successor has no sample-state classifier, and R15 silently redefines `ambiguous` — medium-high

K:489-495 is the published state vocabulary: unsupported, unreached, partial,
ambiguous ("repeated core milestones **or unordered**/overlapping activity") and
reached. A:1779-1790 implements it by precedence: untrusted wire → unsupported,
then no enter and no F/M/validate → unreached, then ambiguous, then reached or
partial. R:299-317 defines only `activity_order`, `core`, `ambiguous` and reached
scope in T/F/U. It gives no successor rule for:

- `unsupported`: the successor has no wire gate, yet R:314 needs
  "every required attribution/qualification clean";
- `unreached`: this is absence-based. With an open sampler domain it must be U
  under R:293-297, but no rule says so;
- precedence when an earlier arm is U. For example, core=T while ambiguous=U,
  because no duplicate enter was observed on an open sampler tail and R:309
  only names *positive* duplicate evidence. The state is then neither reached
  nor ambiguous by any stated rule.

R15 (R:467) also expects "only inside supports overlap ambiguity, unordered stays
unproved". Legacy (A:1703, 2581-2584) and K:480/495 deliberately make *unordered*
activity ambiguous, as a conservative "cannot certify isolation" verdict rather
than an ordering claim.

Concrete history: all lanes are complete and closed, every hop is F-attributed,
and one B activity has no path to or from B_input and m_end. Legacy reports
`ambiguous`. The successor reports U with the same reason shape as R01's broker
gap, and nothing in R:282-291 distinguishes "complete collection, still
unordered" from missing evidence. The K:495 row is not reconciled, and k126
could never obtain a determinate result for a genuinely concurrent cell.

Integration should:

- define the full state/scope classifier over T/F/U with explicit precedence;
- give reasons that distinguish an evidence gap from unorderable-under-closed-
  collection, and state which one (if either) maps to `ambiguous`;
- reconcile K:489-495 and R15;
- add controls: an open-tail absence of enter (unreached must not be decisive),
  core=T with ambiguous=U, and complete-collection concurrency versus a broker gap.

### 2. W-input, W-enter and duplicate-envelope uniqueness have no stated counting domain — medium

R:174-178 requires witness endpoints inside the stateful replay domain. R:181-200
requires "exactly one matching target input across B/C", a "unique eligible
sampler enter" and "exactly one locally qualified controller R(armed)". It does
not say which rows count *against* uniqueness: only rows inside the replay
domain, or every physically retained row, including the raw tail R:113-127 keeps
after a semantic cut. It also does not say whether an unqualified raw armed
embedding counts.

Concrete histories:

- **(a)** B has a producer fault at 5, input(marker_b) at 3 (in the domain) and
  a physically retained repeated input(marker_b) at 7 (in the tail).
  In-domain counting adds post→input and independent_B can be T. Physical
  counting makes the delivery ambiguous (R:190), gives no edge and refutes
  independent_B.
- **(b)** The controller has one qualified R(armed) and one physically retained
  armed receive whose frame bytes decode wrongly. The R:195 text ("exactly one
  locally qualified") adds W-enter. R06 (R:458) lists "duplicate armed" as
  omitting it. Legacy counts both raw rows (A:1647-1650) and adds nothing.
- **(c)** The sampler has one in-domain enter and a second enter after a
  sampler fault. R:309's "positive duplicate-envelope evidence" is either
  present or absent depending on the domain.

Integration should state the uniqueness domain for each witness and for
duplicate-envelope evidence, say whether unqualified or tail observations defeat
uniqueness, and make R06/R07/R18 name the expected result for each of these
three histories.

### 3. Mandatory support for an order or composed claim that routes through a receipt is undefined; R11 omits the order result — medium

R:247-251 makes every contributing begin mandatory "for each frame claim". R:288-291
says each rule "declares" its own mandatory support. Neither says whether an
order claim whose selected path crosses begin₁→receipt r inherits r's frame
claim contributors. R10 (R:462) says "order T unless own mandatory support
cycles". R11 (R:463) gives the frame result, "no composed credit", but not the
result of the order claim itself. That is the claim k206 finding 5(b) and the
k204 decision ("an alternate path cannot remove a separately necessary cyclic
edge") were about.

Concrete history: frame f (sampler→controller `returned`) has contributing
begins b₁ and b₂. b₂→r is intra-SCC, because a wrong ingress/relay join closes
a cycle through r. r also has an outgoing provenance or local edge that leaves
the SCC. `retention_order` selects returned→…→b₁→r→…→post_C, a clean path that
touches cyclic vertex r without a cyclic edge (R13). Under "own support only",
retention_order is T and post-return scope can be granted. Under
"inherit traversed frames' contributors" it is U. Both readings satisfy the
current text and R10-R13.

Separately, R:265-266 ("cyclic mandatory support has U usable truth even if its
raw value calculation agrees") does not say whether a raw F with cyclic
mandatory support becomes U. That changes NOT and AND-F selection (R:282-285).
For example, `ambiguous` needs F activity_order, and an AND-F operand
masked into U changes the selected refuter.

Integration should define mandatory-support inheritance along selected paths,
state R11's order-claim and composed-claim results, state the F-with-cyclic-
mandatory rule, and add a control for each.

### 4. Activity and observation-window domain closure is unspecified, and `observation_window` has no successor formula — medium-low

R:296-305 says a domain is closed "only by the relevant valid local observation
boundary" and needs "each target's eligible closed observation window". It does
not say whether that boundary is the target's semantic `closed` row, its
producer end, or the physical lane_end. `observation_window` is a core operand
(R:306-308) with no formula. Legacy (A:1707-1713) combines a count (`closed`
exactly once) with ALL(input/activity before closed), and both are
open-domain-sensitive.

Concrete history: B records activity at producer 5 and `closed` at 6. Its
physical lane then has a `recording_fault`, so the lane_end and anything after
it are excluded. The C lane is complete. If `closed` closes the domain,
ALL_activity is evaluable and activity_order can be T. If only lane_end closes
it, the result is U. If an activity after `closed` has been lost, the count
of `closed` and window membership are both unknowable.

R15 asks for "open empty domain and closed empty domain" without fixing what
closes one. Integration should name the closing boundary per domain (activity,
input, envelope and C-post absence for ordinary retention at A:1733-1735). It
should also give the T/F/U formula for `observation_window`, including count
predicates on open domains, and add a cut-after-`closed` control.

### 5. Report/support storage is unbounded by any stated budget or control — low-medium

This review's charter asks for bounded support storage. R:478-484 only asks the
execution owner to "measure report/support storage … under the existing finite
case limits" and to fail explicitly if it does not fit. No claim-count bound is
stated. Each selected path can be O(V), and the activity rules issue up to four
path queries per activity (R:301-305, R:228-237).

publication-capacity.md budgets input rows, lanes, frames and reserve, but has no
report or support entry. None of R01–R21 exercises the "explicit
incomplete/resource failure" path. k205 therefore has no numeric limit or
failure control to plan.

Integration should give a derived bound: the maximum number of claims per case
and the maximum stored path/support size, with interning. Alternatively it
should name the budget k205 must freeze, and add a limit-exceeded control
whose report is explicitly incomplete and truncates nothing silently.

### 6. Small inventory and precision slips — low

- R:137-138 says partial_history "cuts before fault for V14–V20/V22–V25, but not
  V11–V13/V21". partial_history is never called for startup bases:
  analyze_startup builds its own prefix (A:2044-2062), and main adds only
  fallback fields (A:2692-2698). The "not V11–V13/V21" clause describes a gate
  that does not execute, so R:139-143's startup rows are the only real legacy
  startup gates.
- R:195's "earlier physical controller coordinate" is a same-role coordinate
  comparison admitting an edge. R:52-54 and E:231-234 say sequence comparisons
  never certify precedence. The admission use is defensible, because the
  selected-callback claim re-queries B→armed→post→enter on paths. Say so
  explicitly so R06 does not read as a seq-as-proof exception.
