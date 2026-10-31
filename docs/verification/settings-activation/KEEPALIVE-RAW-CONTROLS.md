# Keepalive raw-output control design

## Scope and entry

This design expands the qualification proposal's R1–R5 rows into 17 named cases.
It defines inputs, control sites, required evidence and failure oracles.
It supplies no implemented collector, native result or executable study manifest.

The [raw-output view](../../design/architecture/settings-activation/keepalive-raw-controls.mmd)
shows the distinction between emitted bytes, retained bytes and completed operations.
The [owner contract](../../specs/settings-keepalive-owner.md#test-seams-and-discriminating-controls)
governs transitions and ownership.
The [producer contract](../../specs/settings-capture-resource-contract.md#approved-koine-test-controls)
governs substitutions and mutants.
The [qualification proposal](KEEPALIVE-QUALIFICATION.md#backend-raw-descriptor-capture)
governs the proposed pipe mechanism and its unresolved bounds.

The actual coordinator and collector run only after implementation.
Their tests precede downstream consumption.
Native mechanisms need separate evidence before a row can rely on them.
The 13-case mechanism envelope supplies no budget for these cases.

## Subjects and common observations

Each case uses one fresh synthetic root and one measured ordinary operation commitment.
The real owner assigns its ordinal, charge and backing objects.
The real backend binds pipes, collector, writer inheritance and operation records.
The external CLI seam selects a finite test emitter.
The emitter contacts no VM, native OCR engine or application.

Worker sleep requires the real readiness and clean-start transitions.
The external CLI seam supplies a synthetic start result without creating a VM.
Any setup operations have separate commitments, charges, raw objects and records.
They are outside the measured emission table and its two-object extent arithmetic.
The later manifest must count them before execution.
It cannot place the worker directly into sleep by bypassing startup.

The emitter's stdout pattern is repeated byte 0x4f.
Its stderr pattern is repeated byte 0x45.
Each row gives requested lengths, not assumed successful write counts.
No emitter retries an interrupted or short write to obtain the intended length.
Unexpected short writes make the intended boundary unavailable.

The emitter records each syscall's actual accepted count through a separately
bounded test-control channel.
That channel is not stdout or stderr and cannot replenish their allowances.
Its original messages, handles and memory belong in the later fixture inventory.
Missing telemetry leaves accepted-byte totals unknown.

A raw-clean result requires both streams' EOF, exact retained bytes and a clean collector outcome.
It does not establish a valid producer response, capture artifact or owner completion.
Successful owner-path fixtures also need valid assigned results and any required artifact.
Their actual encodings and sizes depend on the implemented protocol.

An expected raw failure must reach the real backend and owner.
The owner preserves its first failure, original charge and attempt.
The harness then submits one sentinel scenario request through the existing caller interface.
The emitter must receive zero invocations for that sentinel.
The refusal has terminal-record cost but no operation ordinal or charge.

That sentinel is a test observation, not a retry of the failed operation.
The case never submits corrective input or an automatic collection operation.
It requests normal finish only for otherwise complete clean paths.
Failed cases follow the real failure-containment and final-outcome path.

Every case retains these independent facts:

- Requested and accepted bytes, per stream and per syscall.
- Actual retained prefix length, byte identity and object identity.
- EOF observation, producer outcome and collector outcome.
- Original commitment, charge, deadlines and first failure.
- Owned process incarnations, descriptor inventory and observed exits.
- Owner disposition, delivery joins, sentinel refusal and final caller outcome.

An unknown fact remains unknown.
Equal requested and retained lengths alone cannot establish EOF or a successful publication join.
No record claims its own subsequent flush succeeded.

## Fixed case matrix

Unless a row says otherwise, limits are `Lout=Lerr=4096` and `Lsum=8192` bytes.
Each emitter requests the listed bytes once and exits zero.
The separate operation-result fixture must not add raw bytes.
Unexpected bootstrap diagnostics invalidate an exact-length positive case.

| Case | Requested stdout / stderr bytes | Controlled schedule | Required raw outcome |
|---|---:|---|---|
| R1-empty | 0 / 0 | Close both streams without writes. | Clean only after both EOF observations. Retain two known empty originals. |
| R1-out-below | 4095 / 0 | One stdout write, then close. | Retain exactly 4095 stdout bytes and empty stderr. |
| R1-out-at | 4096 / 0 | One stdout write, then close. | Exact-limit EOF can be clean. Equality before EOF is insufficient. |
| R1-out-above | 4097 / 0 | One stdout write, then close. | First excess closes eligibility despite producer exit zero. |
| R1-err-below | 0 / 4095 | One stderr write, then close. | Retain exactly 4095 stderr bytes and empty stdout. |
| R1-err-at | 0 / 4096 | One stderr write, then close. | Exact-limit EOF can be clean. Equality before EOF is insufficient. |
| R1-err-above | 0 / 4097 | One stderr write, then close. | First excess closes eligibility despite producer exit zero. |
| R1-both-one | 1 / 1 | One write per stream, then close. | Retain both originals separately. No cross-stream ordering claim follows. |
| R2-sum-at | 4096 / 4096 | One write per stream. `Lsum=8192`. | Both individual limits and the aggregate fit at EOF. |
| R2-sum-above | 4096 / 4096 | One write per stream. `Lsum=8191`. | Aggregate excess fails although both individual limits fit. |
| R3-queued | 8192 / 8192 | Two emitter threads issue one write each during the approved pre-read hold. | Observe excess, stop ordinary draining and retain accepted bytes after writer resolution where storage permits. |
| R4-exec-missing | No emitter invocation | The declared producer executable is absent at its exact assigned path. | Retain actual setup failure and actual raw bytes. Never fabricate loader text or producer exit. |
| R4-direct-abnormal | 2048 / 1024 | Direct descriptor writes, then exit 7 without a complete operation observation. | Retain actual bytes and exit 7. Raw EOF cannot make the operation clean. |
| R4-inherited-holder | 2048 / 0 total | Parent writes 1024 bytes. Its one declared child writes 1024 and retains the inherited writer descriptors. | Parent exit cannot establish EOF or release the original lock. Expiry remains failure. |
| R4-collector-loss | 1024 / 0 | Emitter pauses after its write. Observe the retained 1024-byte original, then send SIGKILL once to the established collector. | Retain that original and collector death. Missing EOF/result facts prevent clean completion. |
| R5-before-write | 2048 / 0 | Fail the first nonempty stdout storage write before any byte is written. | Retained stdout length is zero. Report accepted but unpersisted bytes separately. |
| R5-prefix-write | 2048 / 0 | The approved first stdout write stores exactly 1024 actual bytes, then reports failure. | Preserve the exact 1024-byte prefix. No invented successful second half or clean disposition follows. |

The matrix expands `8 + 2 + 1 + 4 + 2 = 17` base cases.
It is a closed case list for these R obligations.
It does not enumerate S controls, producer-unit controls or every native loader failure.

R4-exec-missing preserves the proposal's missing-executable case.
Absence of the executable can fail before its loader runs.
An empty raw stream is therefore possible and is not a missing expected error message.
This case cannot qualify actual loader diagnostics.
The native evidence proposal must identify the separate loader subject and route before claiming that coverage.

## Approved controls and precise schedules

### R3: release before waiting for writers

The separately audited collector copy stops after descriptor and buffer binding,
immediately before its first raw read.
The real pipe endpoints and raw objects already exist.
The emitter has two fixed threads with separately accounted stacks and one write each.
Threads add memory obligations but no extra process.

The harness releases the collector after both emitter threads reach their declared
write-call entry notifications.
It does not wait for either write to return.
Those notifications prove the emitter reached the call sites, not how many bytes the kernel accepted.
Actual syscall results later establish known accepted totals.

A blocked writer must not prevent barrier release.
The first excess starts the existing containment window immediately.
The collector stops ordinary draining of both pipes.
Only after all pipe writers become unable to write can the collector drain the finite remainder once.
Collector or storage loss can leave that drain unavailable.

The original operation deadline and any earlier containment deadline still govern.
The test never resets either clock.
A finite burst demonstrates only that case's handling.
It cannot establish the kernel queue and temporary-memory bound Q.

### R4: abnormal processes without new collector substitutions

R4-direct-abnormal uses the approved external CLI emitter seam.
Its missing structured observation stays missing.
Producer exit 7 remains failure even when both raw streams are complete.

R4-inherited-holder uses one declared, cooperating child.
The backend records that child's creation and inherited descriptors.
The child retains both pipe write ends and the original writer descriptor.
It waits on a bounded control channel until exact owned-child teardown.
The owner observes its original deadline with the approved clock seam.

The test checks failed completion and refused later dispatch before teardown.
Teardown cannot turn the case into a clean operation.
No later operation uses that root.
Unknown child membership prevents signalling or recovery.

R4-collector-loss requires no additional copied collector barrier.
The controlled emitter writes only 1024 stdout bytes, then waits without further writes.
A bounded external observation checks the real raw object's identity, size and exact bytes.
The harness then sends SIGKILL once through the approved owned-process control.

The later manifest must name that observation's finite poll count and deadline.
It must also bind the actual collector identity and signal route.
Failure to observe the prefix leaves the case unavailable.
The harness must not guess when 1024 bytes reached storage.

An observed prefix can be complete for the emitter's known accepted bytes.
It still supplies no collector EOF, successful collector exit or terminal publication.
The control does not deliberately create lost bytes or prove that every process-loss tail is recoverable.
No replacement collector or second raw writer is permitted.

### R5: fail the collector's real write

The approved collector copy targets the first stdout storage write with data.
The test emitter supplies 2048 bytes and empty stderr.
The copied call site may limit that write to the declared prefix.
All bytes come from the real collector buffer and reach the real assigned object.
If the first data write contains fewer than 1024 bytes, the intended prefix case is unavailable.

For R5-before-write, the site performs no write and returns the declared failure.
For R5-prefix-write, it performs actual writes totalling exactly 1024 bytes, then returns failure.
A short or failed underlying prefix write makes the intended control unavailable.
It must never fabricate 1024 persisted bytes.

Neither control retries the failed storage operation.
Accepted but unpersisted bytes remain distinct from retained bytes.
If later storage is unavailable, the case reports unavailable retention.
Failure-handling success does not claim preservation on failed storage.

Only these R3/R5 sites may differ in the collector copy.
The audit binds the production source, copied source and declared substitutions.
An unrelated edit, missing site, duplicate site or unused site fails the test.
Owner/backend/caller copies retain their separately approved sites and audits.

## Process and descriptor accounting

Count live processes, not role names or successful exits.
The later plan must identify where the finite caller and test supervisor share a process.
It cannot assume that a shell, test runner or helper disappeared during a blocked command.

| Role | Possible overlap in the declared topology | Writer descriptor |
|---|---|---|
| Test supervisor | One. It performs external assertions and retains control evidence. | No |
| Finite caller | One, unless implemented inside the supervisor itself. | Only during a permitted final or recovery handoff |
| Command owner | One during the operation. | Original descriptor |
| Keepalive worker | One during the operation. | No |
| Sleep child | One while that worker sleeps. | No |
| Backend | One active operation child. | Inherited original descriptor |
| Collector | One active collector child. | Inherited original descriptor |
| Intermediary / emitter | One process incarnation across exec, not two simultaneous processes. | Inherited original descriptor |
| R4 inherited helper | One only in R4-inherited-holder. | Inherited original descriptor |

The general separated topology can contain nine simultaneous processes.
Combining supervisor and caller lowers that count to eight.
Neither arrangement fits the six-process mechanism-study ceiling.

The raw cases can hold the worker in its approved controlled sleep.
No tick is then due during their finite emission.
That control changes test timing only and claims no production cadence or liveness.
The worker still exists, and an external sleep control still counts as a child.

The design does not require an additional scenario process.
The test harness submits through the real finite caller interface.
If the implementation requires a scenario helper, its process and resources must be added before execution.
Any separately executed validator or inspector also counts while alive.
Sequential replacement can reduce a peak only after actual exit and descriptor closure.

Every extra inherited member must appear in the finite manifest.
No process-name scan, stale PID, lock replacement or guessed group authorises containment.
A child exit and release of every inherited writer are separate observations.

## Retention and remaining execution inputs

The qualification proposal retains a 256 KiB extent ceiling per raw object.
There are two measured raw originals per base case.
Thus their retained extent envelope alone is `17 * 2 * 256 KiB = 8.5 MiB`.
Setup operations need additional raw originals.
This is not the complete study's storage allowance.

The existing charging rule remains `Lout + Lerr + 1 + Q` per operation,
plus separately counted setup records and metadata.
For these limits, its logical contribution is `8193 + Q` bytes.
The aggregate stream limit never reduces that precharge.
Each per-object assignment and the aggregate must fit before a row runs.

Q includes both pipes and their direct-transfer or temporary buffering paths.
A collector's two 4096-byte buffers and at most 16 KiB control storage are separate.
Thread stacks, runtime, allocator metadata, bootstrap and native contributions remain separately bounded.
No value for Q follows from this design.

Controlled requested emissions total 67,586 bytes across the matrix.
That sum excludes uncontrolled setup/loader diagnostics and all control channels.
It is a fixture inventory check, not a resource guarantee or retained-byte prediction.
Each syscall may accept less, and process loss may prevent complete retention.

The complete later manifest must add:

- Exact implemented subjects, copied sources, fixtures, builds, loaded images and environments.
- Per-case operation family, original deadline, supervision, poll bounds and containment schedule.
- Every emitter/control-channel object, accepted-byte observation and final caller record.
- Record slots, attachments, mandatory publication carriers and failed-carrier fallbacks.
- Raw buffer/pipe bounds, both per-object extents and aggregate backing with metadata.
- Process overlap, thread stacks, descriptor inheritance and exact teardown.
- All setup, audits, copies, byte inventories and retained partials.

Unknown values keep the affected execution unavailable.
The complete profile must derive its own numerical useful workload.
Neither 8.5 MiB nor these small emitters can become a production allowance.
A control's result cannot precede the real coordinator implementation.

## Decisive mutants and limits

| Defect | Discriminating case or invariant |
|---|---|
| Treat an exact limit as excess | R1-out-at, R1-err-at and R2-sum-at require EOF-sensitive success. |
| Accept first excess or check only individual streams | R1-above cases and R2-sum-above must close eligibility. |
| Let producer exit zero clear raw failure | R1-above, R2-sum-above and R3 retain raw failure through owner disposition. |
| Wait for blocked writers before releasing the collector | R3's release rule and unchanged deadline detect the deadlock. |
| Drain continuously after first excess | R3 requires containment before the one finite remainder drain. |
| Treat parent exit as EOF or lock release | R4-inherited-holder keeps actual inherited descriptors open. |
| Accept a persisted prefix without collector completion | R4-collector-loss refuses clean acceptance. |
| Invent or overwrite a partial prefix | R5 compares actual original-object bytes and identities. |
| Accept an unrelated collector-copy edit | The independent correspondence audit rejects the copy before execution. |
| Dispatch after raw failure or refund its charge | Every failed row checks one refused sentinel and the retained original charge. |

These controls do not discharge all resource mutants.
Admission, capacity rechecks, cancellation, fences and final-publication failures remain
with the expanded S controls and existing owner controls.
Both held-pointer cases still prohibit release or corrective input.
The raw fixtures create no real held pointer.

Private roots and exact originals remain mandatory.
Snapshot-tree, empty-AXValue, OCR-substring and held-frame limitations remain unchanged.
No raw control establishes native focus, VNC idle safety or acceptance.
The existing input order, sleep20, polls, historical failures and closed slots remain binding.

## Evidence and handoff

The current backend still opens raw stdout/stderr files directly before its subprocess call.
Its capture inspection follows producer completion.
This source observation establishes the migration boundary, not a raw collector implementation.

Tier 2 graph discovery located `run_locked` in `scripts/vm-guest-exec.py`.
Its exact snippet supplies the observation above.
The trace contains unrelated name matches, which supply no evidence.
Coverage generation `2026-10-31T15:12:43Z` reports matching metadata and no recorded gap for that file.
Coverage remains best-effort.

The [design-check receipt](ordering-keepalive-raw-controls/verification.json)
records document, arithmetic and browser checks.
The documentation task reports the two existing missing k23 archive targets.
These checks establish no coordinator or native result.

A read of [TestAnyware issue 13](https://github.com/Linkuistics/TestAnyware/issues/13)
on 2026-11-01 found OPEN status and no comments.
No dependency response or mechanism result was available through that issue.
This design makes no claim about unpublished external work.

K122 supplies this scoped control design.
K123 expands S2–S6 and retained lifecycle boundaries.
K124 derives complete workload, records and carrier costs.
K125 specifies missing native and dependency evidence scopes.
K126 retains every unresolved complete-profile criterion and whole-design reconciliation.

Independent scoped review and every earned integration precede consumption.
Whole-design review follows only the complete artifact.
Planning and implementation remain separate future work.
No ancestor closes from this slice.

