# Keepalive coordination and the agreed design scope

## Decision and status

**Design is authorised. Adoption remains held.** Antony approved design of
**one serialised command owner**, logged ownership-based admission delays and
deferred keepalive ticks. Required capture qualification must still finish
before any subsequent scenario dispatch. The accepted scope also requires an
enforceable finite resource profile with lossless retention, and permits design
of a separately recorded normal worker stop. The [actual answers and precise
boundaries](#required-scope-decision) resolve k92's scope questions.

**This design is history.** On 2026-11-21, Antony approved the removal of the
keepalive captures. The ADR
[settings harness takes no keepalive captures](../../adr/settings-harness-takes-no-keepalive-captures.md)
records the decision. No consumer waits for the owner design below.

Earlier that day, Antony revised the finite-resource requirement. The
[finite-resource revision](#finite-resource-revision) limits the guarantee to
the resources that the owner controls.

This changes the permitted design, not the current implementation. The existing
keepalive still collides with the scenario's evidence writer. No scheduling
policy, numerical limit or lifecycle schema has been implemented or qualified.
Concrete design, independent review and every earned integration, planning,
implementation and earned review/integration precede adoption. No guest, signed
candidate, freeze or safe native idle interval follows from the agreement.

The [evaluation protocol](ORDERING-EVALUATION-PLAN.md),
[capture contract and integration](ORDERING-CAPTURE-RESULTS.md),
[shared writer](ORDERING-NONEXEC-RESULTS.md) and
[accepted product scope](../../specs/settings-activation-discrimination.md)
remain binding with the narrow amendments recorded here. The [k94 review
dispositions](#review-integration) remain historical review evidence.
Antony's subsequent answers supply the scope agreement. Settings-keepalive-owner-k96 owns
the concrete design before k89/k81/k76 consumption. This document supplies no
native acceptance or ancestor closure.

The [resource-admission slice](KEEPALIVE-RESOURCES.md) now identifies the
pre-producer enforcement and protected-capacity obligations. Candidate OS
mechanisms still need external evidence and the complete useful numerical profile.
The existing lifecycle and scheduling contracts supply no resource qualification.

The editable [visual discussion](../../design/architecture/settings-activation/README.md)
shows the collision and the agreed design scope. Sequence views start at their
first message. Graph views start at the dark **Start here** node. Neither is a
model-checking result.

<!-- tc: pending because the conversion has not reached this part of the document -->

## Why the present rules conflict

The loop sleeps 20 seconds **after the preceding capture completes**, then
attempts one capture. It is not a wall-clock periodic timer. The shared
nonblocking lock covers dispatch, response validation, complete PNG inspection
and terminal publication. The existing Allow OCR invocation can occupy this
domain through its 30-second OCR polling interval; its substring matcher can
also finish early. This is not a bound on the whole command or lock hold.
There is no measured distribution or guaranteed early finish.

A permitted schedule suffices: the preceding capture finishes at time 0; the
loop sleeps; the scenario enters a long Allow read just afterward; at time 20
the tick finds the writer occupied. The tick refuses without dispatch, latches
unavailable and exits. A clean eventual OCR result cannot restore eligibility.
Conversely, a capture that starts first can refuse the next scenario command,
including while the CLI has finished and PNG inspection still owns the lock.
This is a schedule counterexample, not a measured 30-second native OCR run or
a collision-frequency estimate.

A blocking acquire for the keepalive alone, as suggested in k90, removes only
the first direction. Once that capture starts, the scenario can still collide.
Its lock covers RFB connection setup, frame acquisition, encoding, response
checks, PNG inspection and publication. RFB is the protocol used by the VNC
connection. The tagged frame reader has a five-second wait for each message's
first byte; message completion and repeated messages are not bounded by that
timer. Five seconds is not a whole-capture deadline.

Under the present shared writer and independent loop, eliminating both
contention refusals requires preventing capture ownership at every scenario
dispatch. The scenario must either wait for ownership or declare an exclusive
capture window that it cannot overrun. The latter also changes tick admission
and needs a defined completion rule. Keepalive-only waiting and a check that the
writer is free do not establish this invariant. This argument concerns the
present capture design, not every possible liveness transport.

### Lock duration and connection activity

The tagged source distinguishes command execution from validation after it.
The writer covers both. A live VNC connection during one part of a hold does
not prove activity throughout the hold or establish a safe idle interval.

| Operation class | Lock hold and VNC consequence |
|---|---|
| Screen capture, size and Allow OCR | The command opens a VNC connection; OCR reuses it across polls. While that connection remains live, a deferred tick creates no additional connection-free interval. PNG inspection and terminal publication after CLI exit still own the lock without that connection. |
| Physical input | The command opens a VNC connection through input and confirmation. The tagged confirmation limit is ten seconds; it is not a whole-command bound or proof of delivery. |
| Guest exec | The writer waits for the CLI and response checks. The legacy source and retained transport fixture identify a 30-second guest timeout; that does not bound host transport or total lock duration. The file-exec handler uses the agent connection, not VNC. |
| Upload/download and plain agent reads | The writer spans the transfer or read and its validation. These handlers use the agent connection; they do not maintain VNC activity. Transfer length has no established bound here. `agent snapshot --open-menu` is a distinct path that sends VNC input; the collection adapter excludes it. |
| VM lifecycle and local validation/publication | The writer spans the admitted lifecycle command or local work. Neither supplies a general VNC liveness guarantee. The adapter forbids `vm start --viewer`. |

Exec, transfer and validation intervals therefore matter to any deferred-tick
decision even when the OCR interval already has a live connection. Source
classification supplies no collision rate or measured native availability.

The legacy source documents an observed VZ assertion after roughly 60 seconds
without a VNC client. That observation motivates activity; it does not establish
a safe interval, that every other command refreshes VNC activity, or that a
readable capture proves new pixels. The tagged pipeline may return its held
framebuffer. Adding 20 and 30 and comparing the sum to 60 proves no safety margin:
command duration, validation, scheduling and connection activity remain distinct.

## Alternatives and explicit amendments

| Arrangement | What it preserves | Cost or rule it would change | Disposition |
|---|---|---|---|
| Current independent loop and global nonblocking writer | Immediate refusal, one ordinal domain, whole-capture qualification, unchanged sleeps | Collision stops both eligibility and keepalive; no useful complete-run availability is established | Retain source for evidence; do not adopt as the resolved design |
| One serialized owner of scenario and keepalive commands | One dispatch at a time; complete capture validation before later dispatch; first failure can cancel unstarted work | Admission waits replace immediate contention refusal for owned submissions; ticks can be late and scenario actions can wait behind a capture | **Accepted scope for further design**; concrete policy and implementation remain outstanding |
| Separate keepalive writer plus shared failure admission gate | Scenario need not wait for PNG validation; capture could have its own unique receipts | Relaxes the global writer/ordinal domain and the barrier against input during unqualified capture; a later capture failure can follow newly admitted scenario input | Not selected; the approved scope preserves the stronger ordering guarantee |
| Liveness-only capture outside the evidence root | Keeps the existing scenario command schedule without adding coordinator waits; the worker can retain its sleep-20 loop | Removes keepalive captures from required checked evidence and ignores their failures for scenario eligibility. Private images need an explicit retention/disposal decision. Concurrent VNC clients and host work can still affect input and elapsed timing | Not selected; no exemption from tick qualification, failure eligibility or original retention is authorized |
| Skip busy ticks or capture only at scenario checkpoints | Can avoid some collisions without a queue | Omits or defers required captures, changes cadence; checking free then dispatching still races; it does not solve a scenario arriving during a capture | Not selected; neither an idle guarantee nor preservation of all current obligations |
| Persistent VNC connection or another keepalive transport | Might remove periodic screenshot work | The tagged viewer forwards host input and reconnects; the recorder encodes video for at most 300 seconds. Both add lifecycle and resource duties and can coexist with other VNC clients | Neither is a passive liveness interface. A separately scoped capability/design question remains; neither is selected |

One coordinator earns its place by owning the shared ordering invariant. Callers
would submit one operation and receive one terminal result, rather than manage
lock timing, cross-process latches and background cleanup themselves. It also
introduces pending-work and cancellation state. Merely wrapping each caller in
a blocking lock distributes that protocol and leaves cancellation and evidence
ownership implicit. A priority queue cannot preempt a capture already validating.
Scenario priority can starve ticks; keepalive priority can delay input. Those
trade-offs cannot be hidden behind the word serialization.

One owner also serializes the scenario's VNC clients as a side effect. The
tagged CLI documents a routed connection reset on client departure that can
overtake input at tart's VNC server. It does not establish whether separate
concurrent clients interfere. A separate writer, liveness-only worker or
persistent connection gives up this serialization benefit. This is an
unresolved delivery risk, not evidence that concurrent clients do interfere.

The liveness-only alternative separates activity from evidence. Its capture
would run outside the required writer, with a private image destination and
failures that do not latch scenario eligibility. This explicitly reopens k85's
rule that every capture, including keepalive, is checked and retained evidence.
It cannot silently inherit permission to discard images or ignore failure from
the legacy loop. A retained image can contain credentials or consent content;
discarding it also changes the original-retention duty. Its lack of a new
scenario wait is not a promise of unchanged native timing or useful liveness.

The tagged viewer creates a host GUI, forwards input and reconnects. The
recorder is noninteractive, but samples and encodes frames until its duration
ends, capped at 300 seconds. Repeated recording, continuous connection ownership
and resource handling would need a new design. Neither is admitted by the
current adapter as a liveness replacement.

Evidence that would reverse the recommendation is a qualified existing transport
that maintains the needed connection without capture competition, or an accepted
requirement that permits input while another required observation is unqualified.
Neither has been established. No claim rules out every possible design.

## Required scope decision

**Resolved in k93.** Antony accepted the choices below individually, then
confirmed the complete scope and test seams. The answers authorize further
design only; review, silence and elapsed time supplied no agreement.

| Choice | Actual answer and accepted boundary |
|---|---|
| Timing and liveness | On 2026-10-29, "approved" to one serialized owner with logged ownership-based driver waits and deferred ticks. This is the separate explicit scope amendment to the excluded driver-wait class. Admission depends only on command ownership and fixed policy, never observed UI state, focus or success. |
| Required-capture failure ordering | The same approved proposal expressly preserves complete required-capture validation before later scenario input. The existing stronger barrier before any subsequent scenario dispatch remains binding; no second writer or liveness-only exemption was selected. |
| Finite resources | On 2026-10-29, "approved" to design and offline qualification of enforceable finite limits with separate capacity for final records and cleanup. Account for the external capture producer as well as validation and retention. Unbounded host exposure was not selected. |
| Normal worker stop | On 2026-10-30, "yes" to a cooperative stop with its own lifecycle record, matched to the owned worker and confirmed exit. A stop between captures after normal scenario completion may finish without making the run unavailable. This is a nonfailure lifecycle result, never a clean tick or an excuse for a prior failure, interrupted required capture or missing stop record. |
| Test seams and complete understanding | On 2026-10-30, "yes" to the existing helper/adapter controls and existing TestAnyware VM workflow, with the full scope above. Numerical policies and schemas remain design work; no new native experiment is authorized. |

Existing input order, explicit sleeps, poll counts and one-attempt transports
stay fixed. In particular, the existing sleep-20 schedule may produce a due tick
that waits for command ownership; actual tick cadence and scenario elapsed timing
change. A Settings click may wait behind capture qualification, which can affect
the intermittent symptom. No UI-conditioned delay, focus wait, success retry,
repeated input, tick omission to avoid contention, or latch reset is admitted.
The same reviewed policy must apply to the focused prefix and complete scenario.
An all-green sample still leaves symptom preservation unknown.

At a resource limit, stop acceptance and later scenario dispatch, preserve all
bytes already produced and classify incomplete work honestly. No truncation,
deletion, overwrite, downsampling or skipped required image is authorized.
Post-capture checks and streaming validation alone cannot bound earlier producer
allocation or writes. Storage failure may itself prevent preservation or cleanup;
report that boundary rather than promising available collection.

The accepted normal-stop result requires an explicit planned-stop/owned-worker
match and confirmed exit. Earlier failures remain binding. Unexpected exits,
interrupted required captures and missing lifecycle evidence still prevent
acceptance. Pending work and a tick racing stop need concrete dispatch-boundary
rules; no undispatched cancellation can pretend to be a completed capture.

The ensuing design must fix maximum pending work, admission/operation deadlines,
tick delay and stop policy, resource units and limits, and the evidence by which
those choices are useful. A deadline that expires must stop acceptance and later
dispatch; it cannot silently retry, drop a tick, cancel then resubmit, or turn
an interrupted required capture into planned cleanup. The design must account
for an uninterruptible/unknown holder and honest unresolved containment.

No E/A slot is a budget for testing a replacement transport or discovering these
limits. A newly required native capability experiment needs its own explicitly
reviewed scope; it is not added by this document or by agreement to design.

<!-- tc: on -->

## Finite-resource revision

**Antony approved this revision on 2026-11-21.** He chose option B. He gave
this reason: "I don't want us to require that of TestAnyware when our only
interest is in using it for testing." It revises the finite-resource row of the
[required scope decision](#required-scope-decision). The other rows stay unchanged.

The owner enforces finite limits on the resources that it controls:

- Pending work, admission and operation deadlines.
- The count of commands and child processes that it starts.
- The bytes that it reads from each command and writes as evidence.
- Its own validation buffers and local work.
- Separate protected capacity for final records and cleanup.

Koine uses TestAnyware unchanged. Koine requires no bounded-producer schema,
guard, build or evidence from TestAnyware. These costs are outside the guarantee:

- TestAnyware memory, storage and child work.
- Vision and other native service work.
- Kernel pipe buffers and exec memory floors.
- Loader diagnostics and crash-reporting work.
- Filesystem metadata and copy-on-write costs.

Operation deadlines and containment bound these costs in time only. Their
actual size is a named limitation, not a guarantee. A limit breach, an expired
deadline or an exhausted resource stops later dispatch. The run is then
unavailable. It never becomes a pass.

The revision keeps the protected reserve, first failure and capture validation
before later input. It also keeps the cooperative stop, privacy and lossless
retention of the bytes that a command produces. Missing or partial evidence
keeps its existing classification. Guest status meanings are not resource
bounds, so their qualification stays with k81.

The revision withdraws the external returns that the
[evidence scope](KEEPALIVE-EVIDENCE-SCOPE.md) requested for these limits.
K126 reconciles each dependent duty and control with this revision. Each
withdrawn duty names this revision as its reason. No duty disappears silently.
Any message on TestAnyware issue 13 still needs explicit authority from Antony.

<!-- tc: pending because the conversion has not reached this part of the document -->

## Ownership, failure and collection contract

These obligations apply to any replacement and remain outstanding adoption work.
They describe semantics; the current source-only library does not implement a
complete supervisor.

| Owner | Responsibility and boundary |
|---|---|
| Scenario supervisor | Own exact VM/root and the keepalive child from creation to reap; never disown it. Stop scenario eligibility on any required failure, unexpected worker exit or INT/TERM/HUP. Retain scenario, worker, signal and cleanup outcomes independently. |
| Command/evidence owner | Recheck eligibility at actual dispatch; a prior clean check grants no future permission. Preserve one attempt, actual argv/predicate/raw streams and unique ordinal/artifact. Hold the domain through validation and publication. A later clean result cannot clear a prior latch. |
| Keepalive worker | Execute the declared schedule once per tick; retain every produced complete or partial artifact. Report exact local/transport status. No replacement capture, successful-sleep receipt pretending to be a capture, or evidence-class tick after failure to keep the scenario alive. |
| Collection/containment supervisor | Stop new work, settle or terminate only recorded owned processes, reap them, preserve all partials, then use the same domain for untouched observations and exact-clone stop. Preserve stop and independent inventory separately. Unresolved ownership or cleanup blocks all later slots. |

At a stop, suppress future ticks before collection. Preserve any already
dispatched attempt and its terminal result or partial state; do not pretend the
failure retroactively prevented that dispatch. Resolve the owned holder before
another collection command can use the writer. Waiting here is containment
after scenario eligibility has ended, not a new wait intended to make the
scenario pass. A failed exact-stop or recording attempt remains a refusal;
never unlock by deleting the lock file or clear a latch.

After holder resolution, retain the protocol's untouched failure observer,
agent-window list and screenshot in that order before other collection when
applicable. No corrective input, focus change or release is introduced.
Cancellation/holder settlement can delay these observations or make them
unavailable. Record that limitation; later context cannot replace the original
assertion. Finish endpoint/environment/original audits and exact VM containment
with separate statuses. A failure in collection cannot erase an already
qualified recurrence, and collection success cannot restore acceptance.

Planned worker cancellation begins only after the supervisor has closed
scenario eligibility or reached its declared normal end. Record intent before
signalling when possible, the exact owned target, phase, signal, wait result and
any outstanding ordinal. Match that intent to the observed termination.
It is a lifecycle result, never a clean tick. If a required capture was in
flight, its interrupted or missing completion still prevents acceptance.
An unmatched exit/signal remains unexpected; do not relabel it after the fact.

The current loop cannot express this normal-stop distinction. A recorded failed
sleep uses `poll-step`/`sleep`; the backend sets a reason, latches immediately,
and re-latches its interrupted result on later dispatch. Signalling during a
capture can leave a failed or unfinished required attempt. Killing a sleeping
worker without such a record supplies no lifecycle evidence. Recording intent
elsewhere does not make any of these paths a clean stop.

The accepted normal-stop scope still requires a reviewed replacement. Its
cooperative exit and separate lifecycle receipt must
distinguish an undispatched tick from required work already dispatched, record
the matched stop and reap, and preserve all earlier failures. It cannot turn a
`poll-step` interruption into clean evidence, ignore a sticky latch, or relabel a
missing capture as cleanup. Failure to record or establish the stop is unavailable.

## Exact interruption and partial records

| Event | Required interpretation and retained evidence |
|---|---|
| Failed sleep, writer free | Existing `poll-step` request retains phase `sleep`, exact local status and predicate. Signal statuses 129–192 retain `interrupted`; ordinary sleep failure returns unavailable. |
| Failed sleep, writer occupied | One record attempt refuses. `refusals.jsonl` retains attempted phase/status with no ordinal; an already observed signal status returns unchanged. Ordinary failed sleep returns 125. No second recording attempt to manufacture a clean ordinal. |
| Contended capture or scenario call | Refusal, sticky latch, no dispatch and no attempt ordinal for the contender. Preserve the current owner's eventual result separately. |
| Caught backend SIGINT | Interrupted result where publication succeeds, partial streams and actual process status; the CLI/validator may still hold the inherited lock. |
| TERM/HUP/KILL or allocation/storage failure before terminal publication | Preserve request/raw/image/validator/facade/refusal files that exist and the caller's observed status. Missing result/artifact is unfinished, never clean. No promise that an uncatchable signal or failed storage can produce a final record. |
| Clean pointer down, then interrupted settling sleep | Held input remains possible even without a failed down receipt or latch. No later resize-release is issued. |
| Failed/partial held-point or release | Delivery is uncertain; a failed release proves no release. Retain the ordered receipts and contain the exact clone. Both held-pointer cases remain k76 controls. |

Current paths use shared ordinal request/result files, `artifact.json`,
`refusals.jsonl` and `facade-refusals.log`; structured operation/phase/status
fields govern interpretation, not the historical reason text `window poll`.
A future coordinator must distinguish queued-but-never-dispatched work from
attempts, and may not allocate fake dispatched-attempt ordinals for cancellation.
The exact lifecycle record schema is a subsequent reviewed design obligation
under the accepted normal-stop scope. Current signal and latch behavior remains
unchanged.

## Resource contract and limits

Current inspection reads the whole compressed file, copies IDAT data, creates
chunk slices and expands a pixel buffer using header-derived dimensions. For
RGBA8, expected decoded bytes are `(4 × width + 1) × height`; this is a length
check, not a practical allocation bound. The file, accumulated compressed data
and expanded buffer can coexist. Interpreter, allocator and zlib overhead add
further memory. The format's dimension limit and the six-digit ordinal ceiling
do not establish useful per-file, memory, elapsed-time or aggregate-storage bounds.

Retaining every tick grows storage with run duration. A fixed number of guests
does not bound a guest's wall time, image bytes, raw output or partials.
`MemoryError`, a killed process or full storage can prevent final receipts,
latching and collection. Rejecting subsequent input where the process and
storage remain usable is failure containment, not guaranteed serviceability.

No implemented cap changes here. The approved finite profile must specify and
control: maximum encoded file bytes, dimensions and decoded bytes; peak owned
validation buffers and elapsed work; total capture count/bytes; other raw output
and partials; and separate capacity for terminal evidence and cleanup. It must
state which limits include the external CLI and native encoder. A host
post-capture size check cannot bound storage or allocation already consumed by
that producer. A streaming validator alone cannot bound its producer either.
Reservations or isolation must be real enforcement at the responsible owner,
not a free-space snapshot treated as a guarantee against concurrent consumers.

At a limit, retain every byte already produced and its unavailable/partial
classification; prevent further scenario dispatch. Do not convert a refused
capture to a passing observation or delete older images to make room. Where
storage itself has failed, report which preservation/cleanup claims are unknown.
Numerical limits require a declared workload, reasoned accounting and boundary
controls before implementation/adoption; none is inferred from one small PNG.
All secret-bearing roots stay private, including screenshots, argv, credentials,
raw responses and refusal logs. Publish only safe synthetic controls and metadata.

## Verification seams and review questions

The bounded source path is
[keepalive facade](../../../scripts/vm-capture-evidence-lib.sh) →
[backend dispatch and writer](../../../scripts/vm-guest-exec.py) →
[PNG inspector](../../../scripts/vm_capture_artifact.py).
The [ordinary common library](../../../scripts/vm-verify-lib.sh) retains the
legacy idle-assertion explanation and disowned loop;
[Allow helper](../../../scripts/vm-click-evidence-lib.sh) supplies the timeout.
The [capture controls](../../../Tests/scripts/vm-capture-evidence.bats) exercise
the current overlap and partial-record cases. These are current direct source
reads, not claims about an installed native tool's behavior.

The original k92 evidence used Tier 2 graph generation `2026-10-29T09:52:58Z`,
which located the relevant symbols and
the backend/inspector call. The bidirectional backend trace also had unrelated
Swift/trace edges, which are not credited. The
[coverage receipt](ordering-keepalive-design-evidence/coverage.json) reports changed
metadata for the capture facade/backend/reports, partial shell ranges and
untracked Bats metadata. Direct reads covered the relied-on source and flagged
lines, including the actual current backend rather than trusting stale offsets.
The earlier `scripts/.*` graph filter returned zero; no absence claim uses it.
This is task-bounded verification, not an exhaustive graph audit.

K92's [verification receipt](ordering-keepalive-design-evidence/verification.json)
and [capture output](ordering-keepalive-design-evidence/capture-check.txt) identify
the fresh helper check and unchanged measured inputs. The
[documentation output](ordering-keepalive-design-evidence/docs-check.txt) is the
actual repository-wide link result, including any pre-existing failures.
K92's browser inspection checked the two new rendered views after correcting a sequence
label's semicolon parse error. No native guest or new implementation is tested.

Use the existing helper/adapter seam with controlled CLI and sleep behavior.
Keep real locking, qualification and receipt logic. This does not fake native
focus or establish VNC liveness. The existing overlap, post-CLI validation
barrier, signal/refusal and synthetic allocation-failure controls are relevant
evidence; their exact source and limitations are in the capture report.

Antony confirmed these seams on 2026-10-30. Replacement controls exercise the
real coordination logic at this same boundary. Native behavior stays at the
existing TestAnyware VM workflow only after design, review, implementation and
readiness. These local checks establish neither useful native liveness nor
repaired focus; a new native capability experiment needs its own reviewed scope.

Before a replacement is consumed, its controls must discriminate both overlap
directions; tick due during 30-second OCR; failure before and after admission;
capture failure before later input; no dispatch for cancelled pending work;
unexpected worker death; planned cancellation during sleep versus in-flight
capture; matched normal stop after an otherwise passing run; a prior latch that
normal stop cannot erase; a tick racing stop before versus after dispatch;
missing lifecycle publication; INT/TERM/HUP and inherited orphan lock; both held-pointer paths;
original/partial retention; exact VM stop plus inventory; every resource-limit
boundary and failure to write terminal evidence. Preserve all successful
scenario actions, explicit waits, poll bounds and E/A prefix correspondence.
Any newly permitted scheduling latency needs separate assertions and reporting.
It must be independent of observed focus/outcome. Any liveness-only or persistent
connection alternative needs separate qualification of concurrent-client effects,
failure policy, private artifact handling and lifecycle before consumption.

## Review integration

K95 grades k94's findings from commit `79b6b340` against the reviewed artifact
`5ce8a16e`, the current contracts and TestAnyware v2.7.0 at `65bc05c9`.

| Finding | Classification and disposition |
|---|---|
| P2-1: planned cancellation latches | Real issue. The normal-stop choice and ownership contract now name the missing nonfailure exit/receipt semantics. Current `poll-step` still latches; intent alone supplies no exception. |
| P2-2: excluded driver-wait class | Unclear contract. Timing item 1 now explicitly reopens that class for an ownership-based delay, distinguishes UI-conditioned waiting, and requires the actual agreement in the spec/protocol before use. No approval is inferred. |
| P2-3: missing liveness-only choice | Real issue. Separate it from a second evidence writer. State lost required evidence, ignored failure, private retention/disposal and concurrent-client risks. Accept the absence of an intentional scheduling wait as an option's property, not the review's stronger unchanged-timing implication. |
| P3-1: long holds and liveness | Real issue. Add the operation-class table and separate live VNC time from the whole lock hold. Qualify the review's agent generalization: open-menu snapshots also use VNC. No command duration becomes a native safe interval. |
| P3-2: persistent consumers | Real issue. Name the tagged viewer's input/reconnect behavior and the recorder's 300-second cap and encoding work. These are available consumers, not a qualified passive replacement. |
| P3-3: keepalive-only waiting | Real issue. State both directions and dispose of the half-measure explicitly. Correct the suggested five-second capture bound: it is only message readiness, not the whole operation. |
| P3-4: repeated proposal/work orders | Real issue. The spec and protocol retain binding holds and pointers. The capture summary, view index and live brief/task handoffs refer to this decision surface. Historical findings and logs remain unchanged. |

The supported held-pointer, orphan-lock, untouched-collection, exact-containment,
resource and privacy obligations remain below and above. No redesign is
implemented. K93's later [scope agreement](#required-scope-decision) supplies the
human decision; the k94/k95 dispositions record the preceding review.

The tagged command evidence is [VNC connection and input confirmation](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/mod.rs),
[screen](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/screen.rs),
[input](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/input.rs),
[file](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/file.rs),
[agent](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/agent.rs),
[viewer](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/viewer.rs),
[recorder](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/record.rs)
and [frame acquisition](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-vm/src/capture.rs).
These are direct reads of that commit, not a native experiment or a claim about
an installed binary. Current backend and Bats source establish the latch path;
no production test is rerun for this documentation-only repair. A single narrow
adversarial reader found no issue in the scope, normal-stop, first-failure and
hold contract. This is one aimed review, not native qualification or human approval.
The [k95 verification receipt](ordering-keepalive-integration-evidence/verification.json)
retains source coverage, document checks and rendered-view observations. The
[documentation output](ordering-keepalive-integration-evidence/docs-check.txt)
records the actual link-check outcome, including existing failures.

The preceding independent review challenged the overlap argument and routes
under the unchanged contract before the scope decision. The concrete replacement
still needs its own inspection-only review: challenge failure ordering, any
deadline mistaken for native liveness, and preservation/containment claims when
storage or a holder is unavailable. That review and every earned integration
must precede implementation and consumption.

## Original duties and handoff

| Duty | Disposition |
|---|---|
| Single writer, nonblocking refusal, sleep-20 loop, under-lock unique complete captures, sticky first failure | Current source unchanged. Design may replace immediate contention refusal for owned submissions with fixed, logged ownership-based admission; due ticks may be deferred. One writer/ordinal domain, complete validation before subsequent dispatch and first-failure eligibility remain. No native liveness or collision-free implementation is established. |
| Original scenario input, explicit sleeps, poll bounds and strict one-attempt transports | Preserved. Only UI-independent command-ownership admission delays are admitted for design. No UI-conditioned wait, retry, repeated input, tick omission to avoid contention, bypass or latch reset is authorized. |
| Required capture qualification and original retention | Every required capture, including keepalive, remains checked evidence. Separate writers and liveness-only exemptions were not selected. Unique private complete images and every produced partial remain retained. |
| Host resource exposure | Design and offline qualification of an enforceable finite profile are approved; unbounded exposure was not selected. Actual numerical limits, external-producer enforcement, reservations and useful boundary controls remain outstanding. A limit stops acceptance; no deletion, overwrite, truncation or downsampling. |
| Normal worker stop | A cooperative stop with a separate matched lifecycle record and confirmed exit may end normally between captures after scenario completion. Prior failure, unexpected exit, interrupted required capture or missing stop evidence still prevents acceptance. Current receipt semantics stay unchanged until implementation. |
| K89 file/upload/install/environment/lifecycle/collection helpers | Remain live after k96's concrete design, independent review/every integration, planning, implementation and earned review/integration. No speculative implementation leaf is created by k93. |
| K81 every exec and one-shot consequence | Still required: installed identity, exact defaults/absence, launch/endpoint identity, quit/absence, restart clean submission plus changed boot. |
| K76 complete adoption, all callers/root, window blocks and signals | Still required, including worker supervision, status propagation and both held-pointer cases. No ordinary caller changes here. |
| K67 / k62 | Positive setup/title/liveness and later returns; exact shared focused prefix through TextEdit quit before resize and complete original-duty reconciliation remain. |
| K57 / k54 | Finite caller, private retention, collection/orphan ownership/exact containment; whole-harness review, readiness, actual signed/all-input/completed-golden freeze and runtime remain held. |
| Existing availability limits | Missing snapshot trees and omitted/empty AXValue distinction, OCR substring early stop and held-frame capture fallback remain. No new negative inference or retry. |
| Agreed test seams | Existing helper/adapter controls with controlled CLI/sleep and real coordination/lock/validation/records; existing native TestAnyware workflow after all prerequisites. Both overlap directions, failure/stop races, resource/partial/publication limits, signals and both held-pointer cases remain required. No local test proves native liveness or focus. |
| Product/causal and historical obligations | One selection/one front-focused window and all complete ordinary assertions remain. Native cause, ownership and repair acceptance unresolved; all historical bytes, false joins, failed transports, NOT RUN phases, closed caps and six held causal slots unchanged. |

The requirements are agreed; the complete replacement design remains outstanding.
All ancestors remain open; no release, notarization, upstream report or runtime
result follows.

## Lifecycle design slice

K96 decomposes at an independently reviewable lifecycle boundary. K97 proposes
the [command-owner and cooperative-stop contract](../../specs/settings-keepalive-owner.md):
one owner, one active operation, at most one pending scenario submission and one
pending tick; dispatch commitment distinct from confirmed external launch;
unstarted cancellation without attempt ordinals; and a separate stop-intent,
worker-acknowledgement and observed-reap join. Normal stop does not signal sleep20
or erase prior failure. Committed captures retain full validation, delivery and
publication. Unknown inherited holders block collection and later slots.

K98 now separates the [scheduling proposal](../../specs/settings-keepalive-owner.md#scheduling-and-deadline-profile)
from enforceable resource design. K101 proposes receive-order service, exact
deadlines and bounded containment observation. Its independent review and every
integration precede k102. K102 retains external producer limits, the complete
useful workload, raw/partial retention, protected final-record/cleanup capacity
and whole-design reconciliation. Missing combined profile inputs prohibit startup.
The [scheduling evidence](KEEPALIVE-SCHEDULING.md) establishes no native liveness
or available containment. Current source behaviour remains unchanged.

Independent lifecycle review and every integration precede k98 consumption.
The complete design then receives whole-design review/every integration before
planning, implementation and earned review/integration. All precede k89/k81/k76
consumption and readiness/freeze/runtime. No speculative implementation leaf is
created. The original-duty table above remains binding in full: k89 all remaining
file/environment/lifecycle/collection helpers; k81 every exec/one-shot consequence;
k76 full adoption/status/signals and both held-pointer cases; k67 setup/title/
liveness; k62 exact focused prefix; k57 finite caller/private retention/containment;
k54 signed/all-input/completed-golden freeze and runtime. No ancestor closes.

### Source basis and verification limits

Tier 2 coverage generation `2026-10-30T09:51:57Z` locates the capture loop,
backend dispatcher and PNG inspector. The keepalive trace identifies its capture,
root, poll and failure helpers; absent caller edges are not proof of no callers.
Exact backend snippets establish the whole-operation nonblocking lock, inherited
descriptor, unfinished-attempt scan, under-lock PNG inspection and terminal
publication. Direct reads cover current capture/cleanup, failed-sleep behavior,
Allow's timeout argument and the fixture seam. Reported partial shell lines 175
in the common library, 82 in the click library and 169 in the scenario were read
directly. Bats metadata was untracked by the index; relied-on fixture/setup/lock
controls were read directly. Changed document metadata was resolved with current
file reads. This is bounded source evidence, not an exhaustive graph audit.

The new control matrix describes later implementation tests, not passing tests
of an existing coordinator. Existing controls establish neither this lifecycle,
resource bounds, VNC liveness nor native focus. Editable views show
[ownership](../../design/architecture/settings-activation/keepalive-owner.mmd)
and [lifecycle](../../design/architecture/settings-activation/keepalive-lifecycle.mmd).

The [coverage receipt](ordering-keepalive-lifecycle-evidence/coverage.json) retains
those exact checks. The [documentation check](ordering-keepalive-lifecycle-evidence/docs-check.txt)
and [verification receipt](ordering-keepalive-lifecycle-evidence/verification.json)
record the final link result and source stability. Browser inspection found and
corrected semicolon-created stray state nodes, then checked both rendered views
and the lifecycle's failure/containment tail. This verifies the document delivery,
not the proposed concurrency protocol. The documentation check still reports the
two missing archived context targets assigned to k23; no runtime or new production
control was run for this documentation-only slice.
