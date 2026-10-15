# reference-evidence-open-bracket-selection-k351

**Reviews:** reference-evidence-open-bracket-selection-k350


## Goal

Adversarially inspect k350's complete open-bracket selection design, with the whole
inter-checkpoint entry and its first consumers, before reference-evidence-construction-k269.

## Context

Find k350's closing commit by stable handle and read its complete artifact, R's record of it
and its new whole membership. Read k332's original findings (e398d7df2b0a), k349's
integration and its report section k332-integration-and-open-bracket-repair, S's selected
k348 clause and comparison row, C's durable-disarm, publication-join, repeatable-trust,
failed-boundary host and hosted-recovery contracts, K/P controls and the seven views. K344's
reference-checkpoint-recovery-membership.json and k349's membership are historical subjects,
never current proof.

## Review focus

Run every multi-batch bracket the contracts require or permit: successive disarms in one
correction cycle, a fresh disarm after a hosted disposition, any admitted interleaving of
disarm, close and revalidation, and their refusals. Try failed, partial, mis-bound, disposed
and root-changed earlier batches and check the cut's extent, host and absence of deadlock. Check
that no comparison against cp01.source/trust.continuity root identities, BRACKET_VERIFIED
result or trust record happens between checkpoints, that every checkpoint visit retains its
root identity and classifications, and that selection is not circular. Check the accepted-limit
wording against S's cooperative limit and that no new checkpoint/authority/record kind slipped
in. Check every k349-listed doubt, R's classification and the summary/view layers for drift.

## Done when

Record grounded prioritized findings with exact source coordinates, consequence and smallest
useful correction, or explicitly none. Any earned integrate-review-design is inserted
immediately before k269 with this review's bare stem and an Integrates line naming this
review; it reads findings from this review's own commit. Do not fix artifacts.

## Notes

Inspection only. No in-session reviewer, implementation/control execution, provisioning/
initialization/authority act, target query/contents/protected/topology/process/terminal probe
or posture change. K244/k242 remain live, pass unused, full k246/k247/useful/supported-VM/
native/private/product obligations retained. Creator is supplied only by the session that
actually finishes k350.

## Findings

Reviewed producer: **reference-evidence-open-bracket-selection-k350**, committed at
`0150fea961129a1aba7c267f44e307fa8557adff`. Its parent is k349's integration at
`1c4070f4`; the working change was empty when this review began. The producer's closing
launch supplied no Creator evidence. This is Grove's inspection-only review, applying
codebase-design's state, interface, ordering and first-consumer criteria.

All coordinates below refer to that producer commit. **C** is
`docs/verification/application-reference-evidence.md`, **K** is
`docs/verification/application-reference-contact-boundary.md`, **P** is
`docs/verification/application-reference-packaging-runtime.md`, **R** is
`docs/verification/application-reference-input-partition.md`, **S** is
`docs/verification/application-population-metadata-shape.md`, and **M** is
`docs/verification/reference-open-bracket-selection-membership.json`.

### G1 — The slot-based batch partition does not cover pre-intent publication (medium)

C:2257–2259 defines a batch's members as its publication slot plus slots whose intents
bind that publication.intent, and requires its terminal to list exactly those. Selection
step 2 then partitions **each slot** from purpose/kind/intent bindings alone
(C:2283–2284; R:135; M:8170, 8179). This is stronger than simply associating the new
inter-checkpoint writers with their earlier publication intent.

Two retained routes cannot supply that association:

- At initial CP01 the seed's disarm.intent/event.result is finalized before the first
  publication intent exists (C:806–820, 1160–1167). Its immutable intent cannot bind
  that later record. Nevertheless release-events/0 is a reachable slot at the next
  traversal, where E3.2 asks for every slot's batch.
- A hosted recovery writes failure.disposition in **existing** failed slots, including
  the two carrier tails before the recovery publication intent exists
  (C:1548–1579). Those slots' original intents still bind the failed batches. They
  cannot be rewritten to bind the hosting checkpoint batch. Even non-prefix
  dispositions retain their old slot intents.

For example, fail D1 in a two-disarm bracket, dispose both batches at CP03, then enter
the required fresh disarm. The new predecessor rule needs to establish that the old
slot was **disposed inside a checkpoint batch** (C:2320–2326). Original slot membership
identifies its failed inter-checkpoint origin, while the recovery terminal must retain
the newly written disposition and prefix originals. The partition does not distinguish
these two publication associations or give the pre-intent exceptions a membership rule.
Treating them as normal intent-bound members demands a future reference or an original
rewrite; omitting them cannot establish the claimed complete partition/join. The earlier
carrier contract correctly permits a later read join, but E3.2's new intent-only rule
does not admit that join as an association source.

Smallest useful correction: distinguish a slot's immutable origin from the batch that
publishes its disposition, and explicitly account for the seed and the finite prefix
through their earlier accepted plan/nonce and later complete archival association.
State what E3.2 reads to establish each association, without a future input, rewritten
original, new location or authority. Reconcile the exact terminal/member-set rule,
predecessor check, R and M. Require isolated positives for initial bootstrap and a fresh
disarm after multi-batch carrier recovery, plus wrong/missing/cross-batch association
negatives. This is a missing documentary interface, not a claim that actual recovery
mechanics have been executed or are impossible.

### G2 — The identity-comparison prohibition also rejects the required entry gate (medium)

K:149–150 requires refusal of **any identity comparison beyond E1i's own** between
checkpoints. P:268 repeats that negative. C:2301–2303 and its positive control at :2366,
R's F6 resolution at :96, and M:8185 repeat the unrestricted claim that E1i is the only
identity comparison.

The same entry expressly runs E4–E8 unchanged, comparing its anchored writer before
execution (C:2187–2191). The holder gate compares original/copy identities, named/held
inode/stamp equality and current peer/image facts (C:1947–1948, 1982–2007). These checks
occur after E1i and are required even for the first disarm in an empty bracket. The new
negative therefore rejects an otherwise correct entry as soon as it performs a required
gate. Removing those checks instead would break the preserved same-gate contract.

Smallest useful correction: scope the prohibition to the deferred **cross-checkpoint
source-root comparison**: do not compare an E1i observation/E8 result with the base
publication.intent's root, cp01.source, trust.continuity or another batch's observation,
and do not produce/write an E3b verdict between checkpoints. Explicitly preserve current
original/copy, chain/slot, named/held and executing-image comparisons. Carry the exact
scope through C/K/P, F6's classification and M. Pair a full E4–E8 positive with a negative
that changes only the forbidden cross-checkpoint comparison. K350's charter specifically
asked F6 to name the forbidden comparison precisely; the blanket wording does not do so.

### G3 — The new recovery routes put disposition writes before their human act (low)

R:154 orders root-break recovery as source re-entry → carrier prefix → H1 → H2 → H3.
R:155 similarly places the carrier prefix **and ordinary envelope** before H1. M's
O_root_break and O_first_failure correction vectors preserve that order
(M:7064–7070, 7086–7091).

H1 is Antony's direct ready non-success act (R:844); H2 is the disposition publication,
including the bounded prefix (R:845). C:1548–1553 permits the first prefix disposition
write only **after** the host's act. Following the newly added arrows literally therefore
writes before its authorization, then asks for that act and performs H2 again. These
are current dependency routes, not locally labelled historical proposals. The report's
unconsumed status limits their authority but does not make their ordering correct for
the planner or independent expected-result author.

Smallest useful correction: show H0's complete ready cut and comparison → H1 → H2's
prefix/ordinary envelope and complete archival join → H3. Update both route vectors
and inspect the corresponding graph/summary routes. No new human act is required;
restore the already specified order.

### G4 — The whole membership still carries the superseded single-batch host route (low)

M:6656–6662's current failed_cut_routes entry `host_bracket` says intact-root failure
uses **the kind host row** and describes H0 as **the batch (wrong binding)**. It is the
entry for C's current host-table row, not an entry in historical memberships. C:1633 and
:2338–2354 now require the first failing batch **and every successor** to be one cut at
its earliest kind host. M's new O_first_failure entry and open_bracket_selection repeat
that new rule, leaving two incompatible current handoffs in the same whole membership.

For failed disarm D followed by carried revalidation V, the retained entry sends D to
its own CP03 host and omits V; the new route sends {D,V} to CP02 (or CP01 if D alters
trust/rules). That is exactly the per-kind wait the redesign intended to remove.

Smallest useful correction: refresh the existing host_bracket row to the whole-cut,
earliest-host rule, including the CP01 source override, or remove its duplicated rule
in favor of one unambiguous current route. Reconcile all current route representations;
retain the historical membership bytes. Equality and row-prefix checks alone cannot
detect this semantic drift.

## Evidence and limits

The inspection covered k350's committed changes and complete open-bracket subsection,
its publication/selection/anchor/disarm/host/carrier contracts and first consumers,
k332's original findings, k349's integration and seven recorded doubts, k348's actual
answer and selected S/comparison, the descriptor ADR, R's new classification and routes,
K/P controls, original root/k242/k244 duties and current k245/k246/k247/k269 roll-ups,
glossary, seven D2/SVG/manifest/README surfaces and the new whole membership. The original
producer's frozen verification is recorded evidence; this review does not repeat its
render or browser claims. Taskfile.yml exists; no reusable execution recipe is needed
for an inspection-only findings leaf.

The shared publication ordering, deterministic earliest host and checkpoint intent as
the per-writing-visit root record answer the earlier chain/host/base doubts in their
ordinary cases. Write-nothing visits explicitly consume nothing. Anchor selection is
separated from revalidation classification. Checking admission "at its position" supplies
the historical context for successive batches; this review does not claim another
same-pass circularity merely because the closing record is written later. S retains its
deliberate same-UID/mutate-restore limit; the clarified accepted-limit text does not by
itself require a new permission decision. No ADR was changed, and this inspection adds
no production decision requiring one. G1–G4 are the supported remaining issues in this
bounded read; this is not a complete executable-feasibility verdict.

Tier 2 project: `Users-antony-Development-Koine.add-plugins-for-modaliser-requirements`;
reported graph generation `2026-10-15T06:15:30Z`. Coverage was checked for 56 evidence
paths: 34 are excluded under docs and 22 have no recorded issue; 7 metadata records
are changed and 39 paths are not tracked by that generation. Direct source/data reads
supply the evidence, including the stale/absent metadata paths. No graph-completeness
claim is made.

Before adding these findings, read-only identity comparisons recomputed 80 declared
whole-source/surface/charter/extract identities from M. All matched. The manifest and
52 distinct referenced data files stayed byte-identical during that read. This bounded
check does not validate every embedded historical record or prove route semantics; the
contradictory current routes above are present in the very bytes whose identities match.
The review's own charter was part of that earlier snapshot; its findings necessarily
postdate the comparison and do not refresh the historical membership.

No tests, builds, lint, formatting, rendering, instrument/control execution, provisioning,
initialization, authority act, target/contents/protected/topology/process/terminal probe
or posture command ran. No subagent/reviewer was used. Actual originals, tools, controls,
identities and authority remain missing work. K244/k242 stay live; the pass stays unused;
full k246/k247/useful/additive supported-VM/native/private/product obligations and both
holds remain. A review finding, identity equality or retirement establishes none of them.

## Decisions (running log)

G1 is an actionable gap between slot-origin partition and pre-intent/disposition
publication. G2 is a contradictory control contract. G3 and G4 are current dependency
and host-route drift in the handoff layers. Record their original coordinates and
smallest useful corrections; leave all triage, artifact changes and post-fix verification
to an integrate-review-design inserted immediately before k269. The integration reads
this review's findings from its own commit rather than receiving a transcribed fix list.
No normative artifact, view or membership is changed by this review. Retirement closes
no ancestor: k244 retains construction and its handoffs, and k242 retains its other live
obligations. No review of this review is being created.

Inserted reference-evidence-open-bracket-selection-k352 immediately before k269, with
Integrates naming this review alone. It owns independent triage from this review's
retirement commit and all earned repair/verification. Its coverage metadata is absent;
the generated and completed charter is read directly. The integration charter contains
no transcribed findings. Only this review retires; every ancestor remains live.

Final output verification compared this review's original charter against its parent:
the original bytes remain an exact prefix. All 17 files shifted by the insertion retain
their full parent bytes. The diff contains only this findings record, the new integration
charter and those pure moves. The exact Integrates relationship and completed body were
read, and a whole-line Reviews inventory found no review naming k351; there is no Creator
line for this session to write. The four prioritized findings carry original coordinates,
consequences and bounded corrections. No test/build/lint/format check is claimed or run.
Retire k351 alone and seal this focused jj change; no parent cascade is earned.
