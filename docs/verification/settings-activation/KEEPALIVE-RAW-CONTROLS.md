# Keepalive raw-output control design

## Scope and entry

This design expands the qualification proposal's R1–R5 rows into 17 named cases.
It defines inputs, control sites, required evidence and failure oracles.
Actual loader-output capture remains an additional open R obligation outside that list.
R3 also needs qualified observations of blocking and accepted bytes before its complete retention claim is available.
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
For pipe-capture cases, the real backend binds pipes, collector, writer inheritance and operation records.
R4-exec-missing instead refuses setup before creating those pipe processes.
The external CLI seam selects a finite test emitter.
The emitter contacts no VM, native OCR engine or application.

Worker sleep requires the real readiness and clean-start transitions.
The external CLI seam supplies a synthetic start result without creating a VM.
Any setup operations have separate commitments, charges, raw objects and records.
They are outside the measured emission table and its two-object extent arithmetic.
The later manifest must count them before execution.
It cannot place the worker directly into sleep by bypassing startup.

Each stream uses a deterministic position-dependent byte pattern.
Block `i` is SHA-256 of `ASCII(case-id) || 0x00 || ASCII(stream) || 0x00 || uint64le(i)`.
Here `stream` is `stdout` or `stderr`, and block indices start at zero.
Concatenate the 32-byte blocks and take the requested prefix.
Retain the expected byte arrays and their digests in the fixture inventory before execution.
Charge their construction, storage and comparison separately from raw capture.

Each row gives requested lengths, not assumed successful write counts.
No emitter retries an interrupted or short write to obtain the intended length.
Unexpected short writes make the intended boundary unavailable.

The emitter records each syscall's entry and return through a separately bounded test-control channel.
Each returned result includes the actual accepted count or error.
That channel is not stdout or stderr and cannot replenish their allowances.
Its original messages, handles and memory belong in the later fixture inventory.
Missing return telemetry leaves that syscall's accepted-byte total unknown.
Entry alone supplies no count, including when containment kills a writer during its write.

A raw-clean result requires both streams' EOF, exact retained bytes and a clean collector outcome.
It does not establish a valid producer response, capture artifact or owner completion.
Successful owner-path fixtures also need valid assigned results and any required artifact.
Their actual encodings and sizes depend on the implemented protocol.

An expected raw failure must reach the real backend and owner.
The owner preserves its first failure, original charge and attempt.
The harness then submits one sentinel scenario request through the existing caller interface.
The seam records each invocation's operation class, submission identity and assigned ordinal.
It must receive zero scenario-class invocations attributable to that sentinel's submission.
The refusal has terminal-record cost but no operation ordinal or charge.

That sentinel is a test observation, not a retry of the failed operation.
The sentinel never submits corrective input or repeats the failed operation.
It requests normal finish only for otherwise complete clean paths.
Failed cases follow the real failure-containment and final-outcome path.

Applicable collection items use the same CLI seam with separately identified synthetic fixtures.
They retain the owner contract's observer, window-list and screenshot order, followed by its audits, containment and inventory duties.
Each attempted collection item has its own identity, expected invocation count, charge, raw objects and result.
Missing fixtures or unavailable ownership leave the relevant item unavailable.
No fixture contacts a VM, and no collection success clears the measured failure.
The later manifest enumerates these items and costs separately from the measured ordinary operation and the refused sentinel.

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

Each clean row requires a zero-length read on both streams as its actual EOF observations.
For fixed-length excess rows, complete accepted-count telemetry must establish the requested boundary.
A short or unobserved write makes that boundary unavailable, never a passing retention control.

| Case | Requested stdout / stderr bytes | Controlled schedule | Required raw outcome |
|---|---:|---|---|
| R1-empty | 0 / 0 | Close both streams without writes. | Require raw-clean completion after both EOF observations. Retain two known empty originals. |
| R1-out-below | 4095 / 0 | One stdout write, then close. | Require raw-clean completion, exactly 4095 retained stdout bytes and empty stderr. |
| R1-out-at | 4096 / 0 | One stdout write, then close. | Require raw-clean completion, exactly 4096 retained stdout bytes and empty stderr, after both EOF observations. |
| R1-out-above | 4097 / 0 | One stdout write, then close. | Retain all 4097 accepted stdout bytes and empty stderr. First excess closes eligibility despite producer exit zero. |
| R1-err-below | 0 / 4095 | One stderr write, then close. | Require raw-clean completion, exactly 4095 retained stderr bytes and empty stdout. |
| R1-err-at | 0 / 4096 | One stderr write, then close. | Require raw-clean completion, exactly 4096 retained stderr bytes and empty stdout, after both EOF observations. |
| R1-err-above | 0 / 4097 | One stderr write, then close. | Retain all 4097 accepted stderr bytes and empty stdout. First excess closes eligibility despite producer exit zero. |
| R1-both-one | 1 / 1 | One write per stream, then close. | Require raw-clean completion and one byte in each original. No cross-stream ordering claim follows. |
| R2-sum-at | 4096 / 4096 | One write per stream. `Lsum=8192`. | Require raw-clean completion and exactly 4096 retained bytes per stream after both EOF observations. |
| R2-sum-above | 4096 / 4096 | One write per stream. `Lsum=8191`. | Retain all 4096 accepted bytes per stream. Aggregate excess fails although both individual limits fit. |
| R3-queued | 8192 / 8192 | Two emitter threads issue one write each during the approved pre-read hold. | Require excess and stopped ordinary draining. Per stream, retain the ordinary read prefix plus the independently established remainder after writer resolution. Unknown counts leave retention coverage unavailable. |
| R4-exec-missing | No emitter invocation | Backend setup detects the absent assigned executable before creating any intermediary, emitter or collector. | Require setup refusal, zero external invocations and two known empty raw originals. Keep commitment, charge and actual backend outcome. No producer exit or pipe EOF exists. |
| R4-direct-abnormal | 2048 / 1024 | Direct descriptor writes, then exit 7 without a complete operation observation. | Retain actual bytes and exit 7. Raw EOF cannot make the operation clean. |
| R4-inherited-holder | 4096 / 0 total | Parent writes 2048 bytes. Its one declared child writes the next 2048 and retains both writer descriptors. | Require no completion at equality while the child lives. On expiry, contain the child and independently observe its exit, descriptor closure and EOF. Retain all 4096 bytes and sticky failure. |
| R4-collector-loss | 1024 / 0 | Emitter pauses after its write. Observe the retained 1024-byte original, then send SIGKILL once to the established collector. | Retain that original and collector death. Missing EOF/result facts prevent clean completion. |
| R5-before-write | 2048 / 0 | Fail the first nonempty stdout storage write before any byte is written. | Retained stdout length is zero. Report accepted but unpersisted bytes separately. |
| R5-prefix-write | 2048 / 0 | The approved first stdout write stores exactly 1024 actual bytes, then reports failure. | Preserve the exact 1024-byte prefix. No invented successful second half or clean disposition follows. |

The matrix expands `8 + 2 + 1 + 4 + 2 = 17` base cases.
This list does not close every R obligation.
It excludes actual loader-output capture and cannot claim blocked-writer coverage from an unblocked R3 schedule.
It does not enumerate S controls or producer-unit controls.

R4-exec-missing fixes the detection point at the backend's executable-binding check after raw-object creation.
The fixture's bounded setup record identifies the absent path through its private binding and records the actual refusal.
Retain owner, worker and backend incarnations and the absence of any intermediary, collector or emitter incarnation.
Both raw objects remain empty by identity and byte inspection, not by an invented pipe EOF.
This exercises setup refusal only.

Actual loader-output capture remains required outside the 17-case inventory.
K125 must identify a present executable whose loader fails after descriptor binding, with exact loaded-image and environment evidence.
A missing declared linked image is a candidate, not an adopted subject or execution authority.
The separate proposal must name invocation counts, process outcomes, actual stream lengths and the observation route under qualified Q.
K124 and k126 must add its costs and reconcile that open R obligation before claiming complete coverage.

No original obligation is waived. An infeasible route requires an explicit human choice with costs.

For excess rows, compare every retained byte with its expected stream offset, including the first excess byte and the tail.
Only bytes inside all applicable eligibility limits can contribute to eligible output.
The first excess byte and all later bytes remain retained failure evidence, never eligible output.
For aggregate excess, record the collector's actual read accounting without inventing a total native order between streams.

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

Record each return's ordering against barrier release in the bounded control evidence.
Use a common qualified clock or an established event order, retaining ambiguous races as unknown.
Classify the schedule as `returned-before-release`, `blocked-at-release` or `unresolved`.
The blocked classification needs independent evidence that at least one write actually blocked, not merely a missing return notification.
Only `blocked-at-release` can discriminate waiting for blocked writers before release.

An unblocked schedule can test excess handling but leaves that release-order obligation open.
Keep the fixed 8192-byte bursts. Do not enlarge them or add a case without a separately reviewed proposal.

A blocked writer must not prevent barrier release.
The first excess starts the existing containment window immediately.
The collector stops ordinary draining of both pipes.
Only after all pipe writers become unable to write can the collector drain the finite remainder once.
Collector or storage loss can leave that drain unavailable.

For each stream, let `P` be all bytes read before the remainder drain, including the excess read.
Let `N` be an independently observed outstanding accepted-byte count after writer resolution and before that drain.
The retention oracle requires exactly `P + N` original bytes and a remainder drain of exactly `N` bytes.
The prefix comparison covers all `P` bytes, including any read buffer awaiting persistence when eligibility closed.
Complete return telemetry may establish `N` by subtracting `P` from known accepted bytes.

A killed write with no returned count needs a separately qualified observation of all outstanding accepted bytes.
Retained length or the drain's own byte count cannot supply that independent observation.

K125 owns the missing observation design within its existing queue and native-evidence scope.
It must establish a read-only observation route covering queued, direct-transfer and temporary-buffer bytes, with a finite cost and safe timing.
No kernel API, extra collector site or capture mechanism is selected here.
If the route needs a new seam or mechanism, it requires its own producer review chain and any required authority.

Until then, unknown `N` makes complete retention coverage unavailable even if the owner correctly reports failure.
K126 must reconcile this obligation explicitly. Unknowns cannot pass the truncation mutant.

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

The parent completes its write before creating the child, so their stdout prefixes cannot reverse.
The child remains alive after both writes return and the original contains exactly 4096 stdout bytes and empty stderr.
The child writes offsets 2048 through 4095 of the same stdout fixture as the parent.
The harness checks that equality and parent exit produce neither EOF nor a clean completion while the child retains the descriptors.

The owner observes its original deadline with the approved clock seam and opens the real containment path.
That path signals the recorded child. The child exits.
The backend can reap its own emitter child, not that emitter's helper after the emitter exits.
The helper's exit needs separate qualified, incarnation-bound evidence. EOF and descriptor closure do not establish that exit or a reap.

The later manifest must bind that existing supervision observation route, its finite costs and its actual wait relationships.
If the route is unavailable, resolved containment remains unavailable. No adopting process or new collector site is implied.
Record helper reap as unavailable unless an actual reaper supplies the fact through a qualified route.
The collector then performs the one permitted remainder drain and observes both EOF results.

Require unchanged 4096-byte stdout, empty stderr, original-lock release only after every holder resolves, and a refused sentinel.
Teardown cannot turn deadline expiry into clean completion.
This row exercises resolved containment after an inherited hold, not permanently unresolved ownership.
Unknown membership or missing exit/holder evidence makes this expected path unavailable and blocks later slots.
The owner's separate unresolved-holder controls remain required in the expanded S design.

R4-collector-loss requires no additional copied collector barrier.
The controlled emitter writes only 1024 stdout bytes, then waits without further writes.
A bounded external observation checks the real raw object's identity, size and exact bytes.
The harness then sends SIGKILL once through the approved owned-process control.

The later manifest must name that observation's finite poll count and deadline.
It must also bind the actual collector identity and signal route.
Failure to observe the prefix leaves the case unavailable.
The harness must not guess when 1024 bytes reached storage.

The production collector must persist each completed nonempty read before its next raw read.
It must not wait for a full buffer or EOF before attempting that persistence.
R4 observes the object after those real writes, without a new collector barrier.
Its paused emitter prevents additional bytes while the supervisor checks the prefix.

An observed prefix can be complete for the emitter's known accepted bytes.
It still supplies no collector EOF, successful collector exit or terminal publication.
The control does not deliberately create lost bytes or prove that every process-loss tail is recoverable.
No replacement collector or second raw writer is permitted.

### R5: fail the collector's real write

The approved collector copy targets the first stdout storage write with data.
That write persists the first completed nonempty stdout read under the same production rule as R4.
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

Controlled requested emissions total 69,634 bytes across the matrix.
That sum excludes uncontrolled setup/loader diagnostics and all control channels.
It is a fixture inventory check, not a resource guarantee or retained-byte prediction.
Each syscall may accept less, and process loss may prevent complete retention.

The complete later manifest must add:

- Exact implemented subjects, copied sources, fixtures, builds, loaded images and environments.
- Per-case operation family, original deadline, supervision, poll bounds and containment schedule.
- Every emitter/control-channel object, accepted-byte observation and final caller record.
- R3 return/release ordering and an independent accepted-byte oracle, including killed-write coverage.
- The additional loader-output obligation, its subject, costs and separately reviewed execution scope.
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
| Treat equality without EOF as completion | R4-inherited-holder retains exactly 4096 bytes while its child holds both write descriptors. Completion must remain pending. |
| Accept first excess or check only individual streams | R1-above cases and R2-sum-above must close eligibility. |
| Discard the first excess byte or truncate the tail | R1-above and R2-sum-above require their full accepted lengths. R3 requires the independent `P + N` comparison. Unknown counts supply no passing result. |
| Let producer exit zero clear raw failure | R1-above, R2-sum-above and R3 retain raw failure through owner disposition. |
| Wait for blocked writers before releasing the collector | Only R3's independently established blocked schedule tests this defect. An unblocked or unresolved schedule leaves the obligation open. |
| Drain continuously after first excess | R3 requires containment before the one finite remainder drain. |
| Treat parent exit as EOF or lock release | R4-inherited-holder keeps actual inherited descriptors open. |
| Accept a persisted prefix without collector completion | R4-collector-loss refuses clean acceptance. |
| Invent or overwrite a partial prefix | R5 compares actual original-object bytes and identities. |
| Accept an unrelated collector-copy edit | The independent correspondence audit rejects the copy before execution. |
| Dispatch after raw failure or refund its charge | Every failed row checks zero scenario invocations for the sentinel's identity and the retained original charge. Collection has separate identities and counts. |

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

The [original design-check receipt](ordering-keepalive-raw-controls/verification.json)
records k122's document, arithmetic and browser checks before review integration.
Its 67,586-byte fixture total is historical. The revised holder adds 2048 requested bytes.
The [integration checks](ordering-keepalive-raw-controls/integration-verification.json)
record the revised document, arithmetic and browser checks.
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

