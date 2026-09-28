# callback-publication-replay-k206


## Goal
Adversarially review the publication replay integration proposal against its
source consumers and every inherited requirement before complete delivery planning.

**Reviews:** callback-publication-replay-k204



## Context
Read the producer commit through its stable handle, publication-replay.md and
the k203 brief with the complete original ancestor criteria. The producer's
coverage and presentation records explicitly limit their claims. No executable
successor was delivered. The review's scope is the proposed integration and its
delivery boundary, not a repeat of the entire earlier transport survey.

## Done when
- Review the producer's committed artifact and requirements with fresh context,
  producing located, falsifiable findings rather than implementation changes.
- Challenge the physical/semantic maps and qualified local-receipt decisions,
  frozen witness/Trace lifecycle, SCC/per-claim support policy, legacy predicate
  extraction and complete V11–V25/V26 dispatch coverage. Use concrete counterexamples.
- Check that both contracts, assessment, view and k205 preserve every original
  k203/ancestor criterion, exact controls/budgets/renewals and final k180 handoff.
  Check the actual evidence limits; no design or browser result is native proof.
- Follow review-design's ordinary finding/integration handoff. If integration
  is needed, insert it before the still-live callback-publication-evidence-k205.

## Notes
Inspection only. No fixes, implementation or rewritten legacy expectations.
Render/view only in a disposable clone if further browser inspection is needed.

## Findings

Read against k204 commit `7770396` (jj `lwtoproz`). Prefixes: `R:` publication-replay.md,
`E:` transport-evidence.md, `Y:` publication-lifecycle.md (all under
`docs/verification/callback-native-capture/`), `A:` callback-causal-fixture/analyze.py,
`C:` docs/verification/callback-capture-transfer.md. Current source reads only;
nothing was run. Most severe first.

What holds up. The V11–V25 dispatch table (R:180-186) matches A:2420-2432
(V14/V20/V22 → active; V15–V19/V23–V25 → selected; V11–V13/V21 → startup; the
active tuple's 23/24 are unreachable). V26's manifest refuses a producer outside
V14–V25 (A:179-187). The claims about `Trace.create`, `join_messages`,
`partial_history` and `cycle_components` are accurate (A:580-620, 636-653,
671-788, 1887-1992). The `sampler_*` exchange modules add no edges and make no
`before` queries; they walk local streams. The local-R / composed-credit split
(R:107-122) agrees with Y:25-28 and E:226-229. For endpoints that share an SCC,
every path between them stays inside it, so "only cyclic paths exist" (R:162)
and "endpoints share a cyclic SCC" (R:153-155) coincide exactly. The two
statements are consistent. For the both-path and multi-contributor questions R:166
asks about, the proposed policy has no internal contradiction: an acyclic
alternate path supports the order, and a cyclic contributing begin still
contradicts the byte-source claim. Finding 5 is that neither case has a control.
The evidence records don't overclaim: preservation.json is byte identity with
`runtime_rerun: false`, and coverage.json records stale/untracked graph metadata.

### 1. The witness-edge inventory is incomplete, and V11–V25 has three conflicting witness policies — medium-high

R:21, R:64-65, R:141-146 and the control at R:238 name only `Trace.witness` as the
non-message edge that is mutated in during checking. R:142 says to preserve "its"
prerequisites, as if there were one policy. The E:189 row also assumes one
("its existing independent prerequisites"). Selected bases V11–V25 actually add
non-message edges at three sites with different rules:

- `Trace.witness` (A:811-820) requires exactly one inject and one input for the
  marker, a session route and the recipient role. It **raises** otherwise. It is
  called from the wire checks (A:2150, 2158, 2288, 2302), each with version and
  schedule conditions, and from `partial_history` (A:1966-1980), but only for
  V20/22/23/24, only when an input exists, and it picks peer C only for V24's
  `marker_c`.
- The local `witness` in `sampled_evidence` (A:1625-1642) also requires ordinal 1,
  `active`, `key_window` and a unicode/keycode match. It returns None
  **silently**.
- inject(trigger)→sampler `enter` (A:1650-1656) is not an input witness at all.
  It is gated on exactly one controller `armed` receive and on the enter marker.

Legacy V1–V5 adds two more: all-delivery post→input edges in `recorder_v3`
(A:1098-1108) and injected→enter (A:2529).

Counterexample: take a V18 after-callback history whose C input has
`active=false`. The wire check (A:2302) adds inject_C→input_C, but the
sampled-evidence witness would refuse it. With the edges enumerated up front, the
successor must decide on its own whether that edge exists. Its answer changes
`retention_order` and every order that passes through it. It is also undecided
whether the `armed` receive gating trigger→enter must be a locally qualified R
(stage 2) or only a producer row.

Integration should tabulate every edge-adding site reachable from V11–V25, with
its conditions, prerequisites and failure behaviour. It should also choose one
successor policy per edge class and state which of its prerequisites use
qualified R. Controls need to cover trigger→enter as well as input witnesses.

### 2. Sharing predicates with complete legacy report equality is unsatisfiable for staged-mutation predicates — medium

R:198-203 and k204's first decision allow a pure extraction only if every legacy
report stays byte-identical. In `analyze_selected`, `sampled_evidence` (A:2312)
receives the Trace after the wire checks' `Trace.witness` calls. Those calls ran
only up to wherever the wire check raised (A:2280-2310). Inside `sampled_evidence`,
the facts through A:1715 (including `activity_order` and `core`) are computed
before the C witness is added at A:1723. A predicate evaluated over one frozen
graph cannot reproduce facts whose legacy values depend on how far the mutation
had got.

Counterexample: a `SelectedFinding` raised before A:2287 leaves out the
`Trace.witness` edge for a marker that the stricter local witness refuses. Or an
activity path that exists only through inject_C→input_C gives
`activity_order=false` in legacy but true on the frozen graph. Either way, a shared
extraction breaks legacy equality, and the reopen trigger at R:259-261 fires
during implementation rather than in design.

The design should name the predicates that can't be shared: `sampled_evidence`,
plus anything that reads the trace after a raising wire check. For each one it
should either split at the mutation points (legacy passes staged graphs, the
successor passes the frozen graph) or declare it successor-only. The resulting
differences are then labelled comparison items (R:219-225).

### 3. Same-role orders compared by original sequence bypass k187 cycle status — medium

R:60-61 says local sequence comparisons use original coordinates within a role.
E:184 makes local order an edge class. E:214-219 gives `cycle-contradicted`
status to any claim whose necessary edge lies on a cycle. R:158-160 requires a
retained path for each successful order.

Counterexample: an incorrect cross edge (a wrong result→receipt edge, or a bad
trigger→enter witness) creates a cycle through the sampler local edge
enter→f_begin. `callback_enclosure` (A:1663-1667) is all same-role. Compared by
`seq`, it passes with no path and no cycle status, while E:214-216 calls it
cycle-contradicted.

The design must pick one of two options. Either same-role orders go through the
graph's local edges, get a retained path and SCC check, and seq is only a
consistency cross-check. Or local-order claims are declared exempt from cycle
status, with the matching amendment to E:212-222.

### 4. The order-status algebra for composite and negated predicates, and cyclic-only reporting, is undefined — medium

R:158-164 gives each required order three results: supported,
cycle-contradicted or unproved. The V11–V25 predicates to be extracted combine
orders as booleans:

- `activity_order` is a disjunction over activities, `before(i,b) or before(m_end,i)` (A:1699-1706).
- `core` is `all(facts)` (A:1715).
- A **negated** fact drives state: `callback_enclosure and not activity_order` selects `ambiguous` (A:1785-1787).

Legacy V3 also uses negated reachability as evidence (A:1186, A:1203) and as a
branch selector (A:1262). With a broker gap, an unproved `activity_order` would
silently become `ambiguous` rather than an unproved state. That is exactly the
"lack of a path" inference R:94 forbids.

Separately, when only cyclic paths exist, R:162-163 says "retain raw
reachability". E:218-219 requires the report to name the participating necessary
edges, their SCC and witness. If two alternative routes go through different
SCCs, no edge is necessary, and no rule picks which edges or SCC to report.

The design should define how the three results combine under and/or/not and
branch conditions. Branching on "unproved" must not select an obligation set.
It should also give a canonical path choice when only cyclic paths exist, and
say exactly which support is reported.

### 5. The support policy the design flags for review has no required control — medium

R:165-167 and k204's third decision say both-path and multi-contributor cases
must be falsified before implementation. The controls table (R:231-243) has no
row for either. The E20/E21/E24 row checks frame vectors and cycle status, not
the acyclic-alternate-path rule. The table needs discriminating controls for:

- (a) An order with both an acyclic and a cyclic path. The retained support must
  be the acyclic path. A first-found DFS path mutant must fail.
- (b) A frame with two contributing begins, one of them cyclic, and the order
  reached through the other. The claim must be cycle-contradicted. A mutant that
  supports the claim from the order path alone must fail.
- (c) Endpoints in different SCCs where every path crosses a cyclic SCC internally.
- (d) A path through a cyclic vertex that uses no cyclic edge. The intended
  outcome must be stated.

Without these rows, k205 will not plan them.

### 6. The legacy comparison entry point and projected manifest are unpinned — low-medium

R:95-97 and R:198-199 retain "the unchanged legacy analyzer" and its complete
result/exception representation. The frozen reports are CLI output from `main`
(A:2628-2720). `main` parses with `producer_version`, maps
OSError/ValueError/`Finding` to results, and post-processes V11 through
startup/sample/partial/marker/loop/native/source slices (A:2641-2718).

Calling `analyze()` in-process on projected rows skips the `parse_records`
validation, the exception mapping and V11's slice fields. A V11 comparison would
then differ from its frozen report with no real successor difference. The
derivation of a legacy case manifest from the publication manifest is also
unspecified.

The design should pin the comparison at the parse → analyze → main
post-processing boundary (or a subprocess over written projected files), and
define how the manifest is projected.

### 7. `Trace.create`'s producer invariants have no successor stage — low

The legacy structural column (A:580-620) enforces:

- exactly one start and one end per role;
- distinct positive PIDs across roles;
- `fault` → `instrument-failure`.

`partial_history` also cuts at a producer `fault` for V14–V25 (A:1902-1906), and
tolerates duplicates only for V17–19/23–25 (A:1916). K200/k202 treat semantic
native faults as ordinary records (publication-files.md:145). The stages at
R:71-99 and the report groups at R:209-213 name no owner for these invariants.

Counterexample: a V15 sampler producer `fault` embedded at producer 9, with no
`recording_fault`. Legacy inspects producer rows 1–8. The successor map
continues, and stage-5 claims run on events after an instrument fault. The
design should state whether a producer `fault` ends the semantic view, and where
start/end/PID invariants are reported.

### 8. Criterion summaries narrowed; small inventory slip — low

The k204 ownership rows C:4666-4671 and k205's enumerated Done-when never name
"feasible receipt before return / recorded result" (k199.3, k195.3, k182.2). They
also omit k182.2's post-boundary exclusion and the distinction between decisive
source exclusion and an uncollected tail. Predecessor rows did name them
(C:4495, C:4604). k182.2 is filed only under the maps/joins row (C:4666), whose
text covers none of this. These criteria survive only through the
"every original criterion" catch-all, and no stage in R:69-99 names where they are
evaluated.

Separately, R:186 says "V11–V13" where the startup family is V11–V13 plus V21
(R:182).
