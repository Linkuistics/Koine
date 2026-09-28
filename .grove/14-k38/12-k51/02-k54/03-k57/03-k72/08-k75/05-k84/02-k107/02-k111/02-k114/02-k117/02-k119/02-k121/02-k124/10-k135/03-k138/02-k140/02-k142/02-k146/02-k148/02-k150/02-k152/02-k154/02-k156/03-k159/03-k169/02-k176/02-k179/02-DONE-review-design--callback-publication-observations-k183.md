# callback-publication-observations-k183

**Reviews:** callback-publication-observations-k181


## Goal
Adversarially inspect the revised publication observation contract before k182
builds a versioned transport diagnostic around it.



## Context
Read k181's committed artifact, proposed-publication sections in both recorder
contracts, assessment and exact limits of the supplied-edge Trace demonstration.
The full k179/k176/k169 charters bind. The first in-session review and its
dispositions are evidence, not this review's required findings.

## Done when
- Check that feasible/impossible/unverified receipt is consistent across loss
  boundaries, later raw results, both broker hops, controller transitions and
  candidate attribution. Challenge the intact covering-attempt case.
- Check immutable buffer lifetime through actual return/externally established
  termination, partial offsets, zero/error/abandonment, serialization and FIFO.
- Challenge schema/budget/coordinate and legacy-projection feasibility without
  inventing a second causal engine or suppressing reached independent diagnostics.
- Distinguish a coherent proposed contract from executable/native evidence and
  verify every unmet k179 criterion remains owned by k182/k180. Report findings
  only; if warranted, place integration before k182, not after it.

## Notes
No implementation or native experiment. Inspect all relevant claims, not only
the two earlier findings. Render/view only in a disposable TestAnyware clone.

## Findings

Read against k181's commit `6ff5dd8` (jj `lqssyyzx`). Sources: the proposed
section of `docs/verification/callback-causal-fixture/contract.md` (`C:`
lines), the native handoff in `docs/verification/callback-native-capture/contract.md`
(`N:` lines), the k181 assessment in `callback-capture-transfer.md`, both new
`.mmd` views, `publication_order.py` with its `evidence/k181` records, and
`analyze.py` (`Trace`, `partial_history`, `ROLES`, `MAX_RECORDS`, `MAX_LINE`).
Nothing was run. Findings are in severity order.

What holds up: three facts are kept apart — commit, attempt/result and receipt
(C:2885-2891). The begin→receipt edge is sound, because the begin row is
recorded before the syscall can expose any byte. Rejecting result-before-receipt
(C:3047-3048) is right. The known-prefix-plus-one-pending-call rule (C:2962-2966)
is a small, checkable interval test, and it needs no new ordering engine.
Keeping the buffer until actual return or externally established termination
(C:2921, N:1354-1356) closes the reuse hazard the in-session review found. The
assessment and captions do not overclaim: they call the Trace script
supplied-edge ordering examples and claim no executable, native or
corpus-renewal result. Every unmet k179 criterion has an owner. k182's Done when
carries k179.1 (raw observations, joins, pending writes) and k179.2 (feasibility,
FIFO, forged completion, mixed diagnostics, first cause). It also carries k179.3
(versioning, whole-corpus renewal, itemwise preservation, the k180 handoff).
k180 keeps phase composition and k176. Column independence and the fact that
receipt alone repairs nothing are stated plainly (C:2994-2995, C:3025-3026).

### 1. "Intact writer history" is undefined for a contiguous but truncated tail, so the two "impossible" rows can misclassify loss — high

The contract classifies a receipt as impossible "on an intact writer history
with no covering committed/attempted byte source" (C:2958). Its prefix rule ends
replay at a gap, a duplicate or a fault (C:2950-2951). A stream whose tail was
simply never collected has none of these: it is contiguous and just stops. In
that case the covering attempt may lie in the lost tail. Two table rows then
come out wrong:
- "Commit only, receipt on intact streams → Impossible" (C:3008).
- "N-1 accepted, no suffix attempt, receipt → Impossible" (C:3009).

Take a sender whose last collected row is the N-1 short result. The suffix
begin would be its very next row. Nothing in the evidence excludes it, yet the
table says impossible where C:2956 says unverified. This is exactly the loss
case k180 must compose at every phase. The existing Trace separates a full
stream (`start`…`end`, `Trace.create`) from a prefix (`partial_history`). The
contract never says which of the two "intact" means.

Integration must define when a writer's evidence is **decisive** for a frame.
Examples: the stream reaches `end`; or the inspected prefix contains a later
row that excludes the missing attempt, such as the next frame's begin, a
`write_loss` for that direction, or a row Trace orders after the receipt.
Absent that, the frame is unverified. Restate both rows under that condition,
and add a discriminator in which the same history ends right after the short
result and grades unverified.

### 2. The contract never says whether a row past the replay boundary can refute feasibility — high

Replay stops before the first gap, and "missing data after that boundary cannot
complete a write" (C:2950-2953). The contract also says "a later observed
short/error result constrains the same call … it can make the claimed receipt
impossible" (C:2967-2969). What it does not decide is what happens when that
result was collected but lies past the writer's gap or fault. `partial_history`
counts such rows as `excluded_records` and never reads them. So the case "intact
covering begin, gap, then a collected `write_result(-1)` for that call" has two
readings:
- feasible, ignoring a recorded contradiction; or
- impossible, trusting a row the prefix rule calls untrusted.

The covering-attempt clarification from the in-session review (C:2953-2955)
lands exactly on this case. It is still unresolved, and the table has no row
for it. Integration must state one asymmetric rule, for example: post-boundary
rows can never support, and may refute only if they are separately trusted.
Name the outcome (a separate `contradicted-after-loss` status, or unverified
with the raw row preserved), and add the history to the table.

### 3. Audit-only helper and relay frames share the serialized connections the transport lane governs — high

The successor keeps "activation helpers and PID relays … audit-only"
(C:2978-2979, N:1342). Yet those frames travel on the same role↔supervisor byte
streams:
- controller activation requests go to the supervisor;
- the admitted candidate-PID table goes to the sampler "in bounded auxiliary
  audit frames" (N:864-866, N:228-229).

The contract gives each connection a serialized writer: "no next frame
overtakes a partial one", nothing is sent after terminal loss (C:2894,
C:2935), frame ordinals are counted at receipt (C:2925), and message IDs are
unique (C:2917). Each of these either covers the auxiliary frames, which then
stop being audit-only, or leaves unaccounted bytes and ordinals in the very
streams whose reassembly and FIFO it checks. A stalled relay write to the
sampler also blocks later causal frames on that connection. That outcome is
real, and the contract has no way to report it.

Candidate attribution runs through this chain: admission receipt → broker frame
→ sampler receipt → acquisition argument (N:866). C:2996 says an unverified
receipt cannot justify candidate scope, but relay receipts carry no feasibility
classification at all. Separately, the envelope check ties `sender` to "bound
connection identity" (C:2905-2906). That works on the ingress hop. On the
broker→destination hop, `sender` is the origin role, and supervisor-originated
frames have no origin hop at all.

Integration must decide one of two things. Either auxiliary frames are
transport frames — with IDs, envelopes, feasibility, and their own column for
the attribution chain — or they need separate connections. Then state the
egress-hop sender check as a join through broker ingress.

### 4. "Unverified receipt cannot justify a controller transition" mixes up two questions: did the controller decide correctly, and did the sender really send — medium

A controller transition depends on the controller's own validated receipt. That
is a local observation, recorded before dispatch (C:2925). C:2996-2997 marks the
transition unsupported whenever the receipt is unverified — including when the
reason is loss in the *sender's* stream. So an unrelated sampler tail loss
would downgrade a correct controller column. That contradicts "keep …
controller … results independent when another column fails" (C:2994-2995) and
the earlier rule that available input causality survives unrelated sampler loss
(k167 handoff). C:3024-3025 adds that feasibility is not proof of "receipt
authenticity". That suggests the receiver's own record is not trusted either,
although the cooperative fixture treats each role's rows as trusted.

Integration should grade two things separately:
- the controller's decision against its own receipt; and
- the cross-role attribution of that receipt, as feasible, impossible or
  unverified.

Only the second should depend on sender evidence. Say which one C:2996 governs.

### 5. Stream and coordinate granularity is left open, and it decides which Trace edges exist — medium

"Bounded, uniquely sequenced local streams … recording owner and local
sequence" (C:2914-2915) leaves two things unfixed.

(a) Whether app transport rows share the role's causal sequence. If they do, a
lost `write_result` truncates the role's causal prefix. That is sound, but it
is stricter than any legacy projection of the same history. If they don't, the
commit↔causal-row order that phase checks need (for example, a publication
before `host_end`) requires an explicit join.

(b) Whether the broker lane is one sequence for all connections or one per
connection. A single broker sequence adds real-time local-order edges between
unrelated peers. These are sound as real time, but they conflict with "do not
order messages on unrelated peer connections" (C:2984). They also change
reachability and permutation equivalence against V1–V26. Before this can be
fed to Trace, the lane also needs rules for `Trace.create`'s `ROLES`,
`start`/`end` and unique-PID invariants (analyze.py `ROLES`, `Trace.create`).
`publication_order.py` avoids all of this by building `Trace` by hand.

Integration should fix both choices and state their effect on legacy-projection
comparison.

### 6. Three-valued receipt status has no combination rule across hops and writers, and none for edges on non-feasible receipts — medium

Feasible, impossible and unverified are defined for one writer (C:2950-2958). A
destination receipt, though, depends on four things: the origin writer, the
broker's ingress receipt, the broker's commit and the broker's egress writer
(C:2974-2975). The contract does not say what these combine to:
- origin intact and decisive with no attempt, but the broker lane lost before
  ingress — impossible or unverified?
- one hop feasible and the other unverified?

It also does not say whether begin→receipt edges are added when a receipt is
impossible or unverified. That matters for C:3014's "cycle … including with
later loss", because edges left out can hide a cycle. Integration should state
the precedence: impossible if any necessary writer's decisive history excludes
a source (finding 1); otherwise unverified if any necessary evidence is hidden;
otherwise feasible. It should also state which edges are added in each status.

### 7. Mapping existing obligations to commit, completion or receipt is a semantic choice, and the contract defers it — medium

C:2987-2991 maps the send site to commit, says phases "requiring publication
completion must join `write_complete`", and hands k182 the job of adapting the
projections. That choice changes pass/fail for existing obligations such as:
- "reached publications drain before sampler terminal response" (k172);
- after-callback returned-then-failure publication before `host_end` (k166);
- replies that drain before exit commands.

Is each of these commit, local completion, or destination receipt? That is
design, not implementation. Leaving it to k182 means the executable leaf
decides what the frozen producers' obligations now mean. Integration should
give the rule, or the table, for every existing publication-ordering
obligation.

### 8. The lifecycle around abandonment and terminal loss is incomplete in the contract and the state view — medium-low

- `write_loss` may abandon a call that is still outstanding (C:2927). The
  buffer stays owned until the call actually returns (C:2921). But what if that
  return is later recorded, and positive? Is a `write_result` after
  `write_loss` legal? Does it yield `write_complete` or feasibility? It is not
  stated.
- Frames committed behind a terminated direction (C:2935) never get an attempt.
  Is that "unknown"? Is commit even permitted after loss? It is not stated.
- The report needs each connection's "buffered suffix" (C:3022). `read_loss`
  exists only for EOF/error (C:2926). A receiver that stops at its deadline with
  partial bytes buffered has no observation.
- `process-recorder-write-state.mmd` reaches `Lost` only through a zero/error
  result. It has no abandonment edge, no never-attempted-after-loss state and no
  late return. Yet abandonment is exactly the buffer-lifetime repair the
  in-session review made.

### 9. The discriminator table leaves out every forged-completion and local-consistency case — low-medium

k179.2 names forged completion, and k182 must "falsify every discriminator in
the proposed contract". The table (C:3004-3018) has none of these rows:
- `write_complete` without covering results, or with overlapping or surplus
  sums;
- a result greater than the requested count;
- a result with no begin, or a duplicate call ID;
- two outstanding calls on one writer;
- a begin offset that is not the known prefix;
- an offered length other than the whole suffix;
- a zero/-1 followed by another attempt or frame.

The rules exist in prose (C:2922-2924, C:2929-2936). k182's own Done when does
say "contradictory/forged completion", so the obligation is owned. But the
contract's enumerated set understates it.

### 10. The byte and row budgets are not reconciled with the existing analyzer limits — low

The frame cap is 4,096 bytes (C:2903), the same as `MAX_LINE = 4096`. So a
maximum frame cannot be recorded in a `frame_commit` row under any encoding.
The contract defers this to k182 (C:2911-2912), and the frame cap should be
derived from the record budget rather than set equal to it. For rows: the
largest frozen history has 35 messages. At commit, begin, result and complete
plus the ingress receipt, one broker lane would use about 177 of
`MAX_RECORDS = 256`. That is before any short-write rows or auxiliary frames
(finding 3). The per-lane budget should be stated, so that an
incomplete-instrument outcome does not become routine on long cells.

### 11. The demonstration's cycle cases are tautological, so its positive reach is narrower than the assessment's wording — low

`incorrect-result-before-receipt` adds both `receipt→result` and
`result→receipt`. Any graph cycles on that; the case exercises nothing about the
rule. The `receipt→result` "schedule" edge is not observable in a real log
(check.log limits say so). The script also exercises only single-attempt
frames: it has no multiple contributing begins, no FIFO and no
`join_messages`/`partial_history` path. The assessment's scope sentence is
accurate. The name "incorrect-result-before-receipt" and the phrase "produce
`causal-cycle`" read as evidence that the rejected rule fails on real
histories.

A realistic discriminator does exist. On one broker lane, the broker records a
destination reply's ingress before its own egress result. A result→receipt rule
then makes a genuine cycle. k182 should carry that case.

### 12. The broker's own pending writes have no bounding owner outside the supervisor — low

C:3035-3037 has a supervisor on another execution context bound an app's
pending write. On the broker hops the supervisor is itself the blocked writer.
The case watchdog lives in that same process (N:209). The contract should name
the host runner, or another independent context, as the bound for broker egress
and ingress, with the same no-return and no-cleanup rule.

Integration, if warranted, precedes callback-publication-evidence-k182.
