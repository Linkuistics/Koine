# settings-keepalive-raw-controls-k127

**Reviews:** settings-keepalive-raw-controls-k122

## Goal
Adversarially review the raw-output control design against the complete inherited contracts.

## Context
Read the producer commit identified by its stable handle.
The artifact is docs/verification/settings-activation/KEEPALIVE-RAW-CONTROLS.md,
its owner-spec link and the changed visual discussion.
The owner, producer, record and qualification contracts remain authoritative.

## Done when
- Check every original R obligation against its named case, approved seam and decisive oracle.
- Challenge reachability of exact prefixes, R3 release ordering, accepted-byte telemetry and process-loss observations.
- Challenge the distinction between missing-executable setup failure and actual loader diagnostics.
- Check process/descriptor overlap, synthetic startup costs and the measured-only byte arithmetic.
- Check that unknown native bounds and unfilled executable manifests remain unavailable.
- Check that no new collector substitution, execution authority or requirement relaxation is inferred.
- Report actionable findings with source locations and consequences.
- If findings warrant integration, create the matching integration before the next live sibling.

## Notes
This is scoped review of the R-control design, not whole-design acceptance.
No coordinator or native control runs. Do not require results before implementation exists.
The original k119 charter remains open through k123–k126.
Re-derive findings from the artifact and contracts. The producer's framing is not a verdict.

## Decisions (running log)

- 2026-11-01: Adopt the mandated review leaf in the jj workspace at clean parent 716caad9.
  Read the k122 commit and its whole diff. Read the design, the owner spec, the contract,
  the schema, the plan, the report and the receipt. Read the glossary, the view, the manifest
  and the README. Read the k122 to k126 bodies and the whole brief chain from the root to k119.
- 2026-11-01: Run no test, build, image, VM or coordinator command on the artifact.
  Run only the prose checker, on this file, on the integration body and once on the design for a count.
  The graph was not consulted. Every claim below is a direct read of the working copy at 716caad9.
- 2026-11-01: This file passed the prose checker as the producer left it, so no preparatory commit is needed.
  No in-session reviewer runs. This leaf is the adversarial read.
- 2026-11-01: Recompute the case count, the controlled byte total, the extent envelope, the charge expression and the process inventory.
  Trace each R obligation of the plan to its row, seam and oracle. The arithmetic and the approved R3/R5 scope hold.
  One obligation leaves the closed list, five oracles are unobservable or unstated, and four narrower defects remain.
- 2026-11-01: The P1 and P2 findings change what k123 to k126 may treat as covered, so they must resolve before k123 consumes the design.
  Insert the integration before k123, the first later sibling with live work. The cut is settings-keepalive-raw-controls-k128 at position 03.
  K123 to k126 move up one position with no content change. The body carries this review's handle, not the findings.
  No Creator line applies, because this leaf finishes no producer. Retire this leaf only. K119 and its ancestors keep live work.

## Findings

Severity: P1 means a consumer following the design would violate an inherited contract.
P2 means a material omission or inconsistency inside this slice that k123 to k126 must not consume as settled.
P3 means a narrower precision, seam or legibility defect.
No finding supplies a queue bound, a storage result or a mechanism result. Each one concerns the design itself.

Line numbers refer to commit 716caad9, which the working copy equalled at adoption.
"The design" is docs/verification/settings-activation/KEEPALIVE-RAW-CONTROLS.md.
"The owner spec" is docs/specs/settings-keepalive-owner.md.
"The contract" is docs/specs/settings-capture-resource-contract.md.
"The schema" is docs/specs/settings-keepalive-records.md.

"The plan" is docs/verification/settings-activation/KEEPALIVE-QUALIFICATION.md.
"The report" is docs/verification/settings-activation/KEEPALIVE-RESOURCES.md.
"The receipt" is docs/verification/settings-activation/ordering-keepalive-raw-controls/verification.json.
"The view" is docs/design/architecture/settings-activation/keepalive-raw-controls.mmd.
"The README" is docs/design/architecture/settings-activation/README.md.

### P1-1. R4-exec-missing drops the loader-output obligation, and the closed-list claim hides the loss

The plan's R4 row names a missing-executable loader error (plan :291).
It requires loader output captured under the Q boundary, with no assumed text size (plan :291).
The design defines the case as absence at the assigned path, with "actual setup failure and actual raw bytes" as its outcome (design :99).
It states that absence can fail before the loader runs, so an empty stream is possible (design :110-112).
It states that the case cannot qualify loader diagnostics and defers that subject to the native evidence proposal (design :113-114).

Under the contracts, an unbound executable is a launcher setup refusal with zero external invocations (owner spec :1020, contract :230).
Such a case reaches no pipe path.
It repeats the approved setup-result substitution with a real absence and exercises none of R4's raw-capture duty.
The plan instead binds descriptors before launch so that loader failures use the pipe route (plan :217-219).
The design does not fix which detection point the case exercises.
A backend refusal before any spawn and an intermediary whose exec fails give different facts, and the stated outcome admits both.

Consequence: the design claims a closed case list for these R obligations (design :107), while the plan still claims loader-output coverage under R4.
The two documents disagree. K125 or k126 could read :107 as closure and never name the loader subject.
The parent charter forbids inferring such a relaxation. A mutant that fabricates either detection outcome passes the row as written.

Smallest correction: state at :107 that the plan's loader-output obligation is outside the 17 cases and remains an open R obligation.
One candidate subject is a present executable whose declared linked image is absent, so the loader writes through the bound pipes.
Fix which detection point R4-exec-missing exercises. List its exact facts: invocation count, incarnations, both retained lengths and the setup record.
Reconcile plan :291 so both documents state the same coverage. Dropping the loader case is a human choice with costs, not a design inference.

### P2-1. R3's accepted-byte oracle has no observation route for a killed blocked writer

The plan requires R3 to record accepted writes and to prove that all actually accepted bytes survive when writers resolve (plan :290).
The design takes accepted counts from the emitter's per-syscall telemetry (design :44-48).
It states that actual syscall results later establish known accepted totals (design :130).
It also requires release while a writer is blocked, and the first excess opens containment (design :132-133).
Containment signals established writers (plan :244).
A writer killed inside a blocked write never returns, so its accepted count never reaches the control channel.

Consequence: in the one schedule R3 exists to exercise, the outcome at :98 has no independent accepted count to compare against.
The design's own rule then classifies the total as unknown (design :48).
The mutant row at :281 claims detection that the case can only report as unknown.
K126 cannot reconcile the control with the plan's obligation.

Smallest correction: name a kernel-side observation of the bytes queued in each pipe, taken after writers are resolved and before the one remainder drain.
The plan already asks for accepted or queued observations and the unknown remainder (plan :270-272).
Require the drained remainder to equal that count and the retained total to equal the ordinary prefix plus that count.
State that emitter telemetry supplies accepted counts only for writes that returned.

### P2-2. Whether R3 blocks a writer depends on the unknown Q, and the case records no return observation

With pipe capacity at or above 8192 bytes per pipe, both writes return before release and the emitter exits.
The collector then sees complete streams with EOF, no writer blocks, and the release rule is never exercised.
With smaller capacity, the writers block. Q is unknown (design :252, plan :259-267).
The harness records write-call entry notifications only (design :126-129).

Consequence: one case has two schedules with different oracles, and the design cannot say which one ran.
A clean R3 result may be the unblocked schedule, which proves nothing about release ordering.
The deadlock mutant at :281 is discriminated only by the blocked schedule.

Smallest correction: require the emitter to notify write return as well as entry.
Require the R3 result to state, per write, whether it returned before barrier release.
State both outcomes as named sub-results and that the mutant at :281 needs the blocked one.
Let the manifest choose burst sizes once Q exists, or accept the conditional coverage explicitly.

### P2-3. The zero-invocation sentinel is not reconciled with the real containment path's collection commands

An expected raw failure reaches the real backend and owner (design :55-56).
The harness then submits one sentinel scenario request, and the emitter must receive zero invocations for it (design :57-58).
The design states that no case submits an automatic collection operation (design :62).
It also states that failed cases follow the real failure-containment and final-outcome path (design :64).
On that path the owner performs the untouched failure observer, agent-window list and screenshot after holder resolution (owner spec :516-518).
Those are CLI commands through the same external seam that selects the emitter (design :28).

Consequence: on the real path the emitter receives collection invocations, so "zero invocations" is false or collection is suppressed in an unstated way.
A test that counts total emitter invocations cannot attribute one to the sentinel.
A test that suppresses collection departs from the real path without saying how, and k123's S controls inherit the ambiguity.

Smallest correction: state how the synthetic root treats the collection items.
Either they are unavailable because no VM exists, or they run through the CLI seam with their own expected counts and allowance.
Define the sentinel oracle as zero scenario-class invocations attributable to the sentinel's submission.
Have the seam record each invocation's class and submission identity.

### P2-4. No case exercises equality without EOF, and the exact-limit rows state no required result

The plan states that a byte count equal to the limit without EOF is not completion (plan :227).
The design's exact-limit rows say "Exact-limit EOF can be clean. Equality before EOF is insufficient." (design :90, :93).
Every row's emitter closes after its write, so the collector always reaches EOF.
R4-inherited-holder keeps a descriptor open, but at 2048 bytes (design :101).

Consequence: a collector that declares completion when a stream's count reaches 4096 before reading EOF passes R1-out-at and R1-err-at with identical retained bytes.
No case catches it. The mutant table names only the opposite defect (design :278).
"Can be clean" states no required outcome, so a collector that fails every exact-limit stream also passes :90 and :93.

Smallest correction: make R4-inherited-holder's held-open total exactly 4096 stdout bytes, parent 2048 and child 2048.
That turns it into the equality-without-EOF discriminator without changing the count.
State R1-out-at and R1-err-at as raw-clean required, with an actual zero-length read recorded as the EOF observation.
Add the mutant "treat a count equal to the limit as completion" to the table.

### P2-5. The excess rows state no required retained extent

The plan retains the current read prefix at first excess and requires all accepted bytes to survive (plan :241, :290).
The contract retains the real written prefix and lists "drop a partial or truncate an earlier file" as a mutant (contract :178, :268).
The design's below and at rows require exact lengths, for example "exactly 4095" (design :89).
Its excess rows give only a closing or failing clause and no retained length (design :91, :94, :97, :98).

Consequence: an implementation that retains 4096 bytes and discards the excess byte passes R1-out-above as written.
One that retains 8191 of 8192 bytes passes R2-sum-above.
The truncation mutant is not discriminated, and k124 has no per-row expected retained value.

Smallest correction: state, for each excess row, the required retained length per stream as all accepted bytes.
That is 4097 for R1-out-above and R1-err-above, 4096 and 4096 for R2-sum-above, and the ordinary prefix plus the observed queued remainder for R3.
State which bytes are eligible output and which are retention tail.

### P3-1. Constant byte patterns make byte identity a weak oracle

The emitter's stdout pattern is repeated byte 0x4f and its stderr pattern is repeated byte 0x45 (design :38-39).
Every case retains byte identity as an independent fact (design :69).
The mutant row for an invented or overwritten prefix relies on R5 comparing actual original-object bytes (design :285).
A retained object of 1024 bytes of 0x4f is indistinguishable from a fabricated prefix, a duplicated chunk or reordered chunks of the same pattern.

Consequence: the comparison at :285 discriminates length only, and the prefix mutant rests entirely on the copy audit.
Smallest correction: use a position-dependent pattern per stream, for example a byte counter or a declared pseudo-random sequence with a fixed seed.
Keep the pattern in the fixture inventory so a retained prefix identifies its own offsets.

### P3-2. R4-inherited-holder does not say whether containment signals the recorded child

The case uses one declared, cooperating child whose creation and descriptors the backend records (design :149-150).
The test checks failed completion and refused dispatch before teardown (design :155).
Unknown membership prevents signalling (design :158).
Recorded direct-child ownership authorises termination (owner spec :491).
A control that leaves a holder intentionally unresolved is followed only by exact owned-child teardown (plan :305-307).

Consequence: if the child is recorded and owned, the containment window signals it and the case resolves inside the operation.
If the child is kept unresolved by design, the containment policy must be told not to signal it.
Each path has different retained facts: a reap and drain, or unresolved containment that blocks later slots (owner spec :638).
The row's oracle fits both (design :101), so k123's holder controls and this case can double-count or miss the unresolved path.

Smallest correction: state which path the case exercises and its exact expected facts.
In one, the window signals the recorded child, and the facts include its reap and the remainder drain.
In the other, the child stays outside the signalled set by declared design, and the operation ends with unresolved containment.

### P3-3. R4-collector-loss and R5-prefix-write depend on an unstated collector persistence rule

The collector reads with fixed 4096-byte buffers (plan :217), and accounting covers a partially persisted read buffer (plan :237).
R4-collector-loss observes the retained 1024-byte original before SIGKILL (design :102).
The harness must not guess when 1024 bytes reached storage (design :168).
R5-prefix-write targets the first stdout storage write with data (design :177).
The design leaves the collector's write schedule to the later manifest.

Consequence: a collector that persists a buffer only when full or at EOF never stores 1024 bytes before the emitter pauses.
The R4 prefix then never becomes observable, and the case is permanently unavailable rather than failed.
A collector that persists each read before the next read makes both cases reachable.

Smallest correction: state as a design requirement that the collector issues one storage write per completed read before the next read.
State that the R4-collector-loss observation window follows that write and that R5's first data write is that same per-read write.

### P3-4. The visual discussion pins a session port and labels the general flow with the R3 rule

The README instructs `mise exec -- task design:serve PORT=8816` and links that port (README :70-71, :91, :103, :105).
The task defaults to 8765 (Taskfile.yml :1177-1180), and the earlier instruction used that default.
The view labels the general emit-to-capture edge "4. R3 releases before waiting" (view :18).
Only R3 holds a pre-read barrier (design :120-122), so the graph reads as if every case does.

Consequence: a reader serving on the default port gets dead links, and the view overstates the barrier's scope.
Smallest correction: restore the default-port instruction or state why a port is pinned.
Label the edge with the general step, the collector reading after binding.
Keep the R3 rule in the caption, where it already is.

### Supported items

These claims hold against the inherited contracts and recomputation. They need no correction.

- The 17 cases match the plan's five groups, and the controlled total of 67,586 bytes recomputes from the matrix (design :86-106, :254). The receipt lists the same per-case values.
- The 8.5 MiB extent envelope recomputes to 8,912,896 bytes. The design excludes setup, records and metadata from it (design :237-241).
- The charge expression `8193 + Q` follows the plan's `Lout + Lerr + 1 + Q`. The aggregate limit does not reduce it, and Q stays unassigned (design :243-252, plan :231-233).
- The process inventory is nine with a separate caller and eight when combined. Both exceed six. The R3 threads add no process, and the sleep child counts while the worker is held (design :204-223, report :263-266).
- The R3 and R5 scope is reproduced exactly, and no third collector site, replacement collector or second raw writer appears (design :120-121, :177-196). The R4 SIGKILL ends an owned process once, as the S3 controls do (plan :421). It is not a substitution.
- Setup operations carry their own commitments, charges, raw objects and records, and the worker is not placed into sleep by bypassing startup (design :31-36).
- The R5 rows follow the contract's partial-write rule and never fabricate bytes (design :183-191, contract :245-249).
- Missing evidence stays unavailable. The later manifest list, the unfilled subjects and the rule that no control result precedes the real coordinator hold (design :259-272).
- The owner-spec change is a three-line link (owner spec :563-565) and adds no seam. The schema's R rows are unchanged.
- The source observation holds: `run_locked` opens raw.stdout and raw.stderr with `xb` before `subprocess.run` (scripts/vm-guest-exec.py :327-333).
- The receipt agrees with the design's numbers, records its browser limits and claims no coordinator or native result. Its two expected documentation failures are the known k23 targets.
- TestAnyware issue 13 is read and not relied on (design :317-320).
- The prose checker reports zero hard findings on the design, as the producer recorded.
- No decision earns an ADR. The design selects no irreversible mechanism, and the collector-site alternatives are already recorded in the report.

Evidence limits: no project command ran on the artifact apart from the prose checker.
It ran on this file, on the integration body and once on the design for a count.
The graph was not consulted. Every claim is a direct read of the working copy at 716caad9.
