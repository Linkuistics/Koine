# Settings command ownership and worker lifecycle

## Design boundary

The proposed owner lets the Settings scenario and its required keepalive
captures share one command stream. This document specifies ownership and
cooperative stop under the [agreed
scope](../verification/settings-activation/KEEPALIVE-DESIGN.md#required-scope-decision).
It combines a **reviewed lifecycle slice** with a proposed
[scheduling profile](#scheduling-and-deadline-profile). The scheduling proposal
awaits independent review. The [remaining profile](#remaining-profile) must supply
enforceable resources and whole-design reconciliation before whole-design review,
planning or implementation. Adoption and every runtime slot stay held.

The [review integration](../verification/settings-activation/KEEPALIVE-LIFECYCLE-REVIEW.md)
records the source basis, dispositions and remaining test-seam choice.

A planned stop is a lifecycle event. It can cancel a tick before dispatch
commitment. It cannot turn a failed sleep or capture into success. A capture
already committed to dispatch must finish its original validation and
publication, or remain failed or unavailable. Every earlier failure continues to
prevent acceptance.

The [lifecycle
view](../design/architecture/settings-activation/keepalive-lifecycle.mmd) shows
this distinction. The [ownership
view](../design/architecture/settings-activation/keepalive-owner.mmd) shows who
may dispatch and write. These are editable explanatory diagrams, not
model-checking evidence.

## Ownership and interface

The finite caller starts one **command owner** for one run identity, exact VM
identity and private evidence root. The owner also supervises its keepalive
worker. It retains the root's opened directory identity and existing writer-lock
identity. Aliases, a replaced directory, a mismatched subject or an already
owned root refuse initialisation. An initialised root is not permission to
bypass the owner. One run has one owner generation, never a replacement owner
that resumes scenario input after loss.

The owner alone admits commands, assigns attempt ordinals and authorises backend
execution. It writes the lifecycle events and the final operation disposition.
The backend writes command, raw-output, validation and result receipts under that
authority and the inherited lock. It can also set the existing sticky latch.
The worker requests ticks but neither runs the CLI nor writes evidence.

Scenario eligibility requires both the owner's open state and an absent backend
latch. A failed child, missing receipt or unfinished prior attempt also prevents
dispatch. The owner reads these facts at every commitment boundary, including
after a child that otherwise returned clean. Neither writer can reopen eligibility.

Scenario helpers submit operations to the owner and synchronously receive their result.
Collection uses that same owner, root, lock and ordinal sequence after scenario
eligibility closes. No second evidence writer, unlocked success path or
alternate root is introduced.

| Interface operation | Contract |
|---|---|
| Start | Pin run/VM/root, the reviewed profile identity and actual process ownership. Establish exclusive writer ownership and worker readiness before scenario admission. Missing profile, failed readiness or duplicate owner refuses startup. |
| Submit scenario operation | Supply the bound client identity, unique submission ID, caller sequence, operation name, class, transport, exact arguments and required predicate/confirmation. At most one outstanding submission per scenario. Helpers cannot pipeline inputs. |
| Submit due tick | Supply worker generation, tick sequence and completed sleep identity. At most one outstanding tick. The owner constructs the existing checked capture. The worker cannot choose an evidence exemption or arbitrary CLI arguments. |
| Report local failure | Submit the exact poll/state/sleep/signal status and phase. The owner closes eligibility and retains the original status. A failed reporting channel is itself unavailable. This control is not queued behind command admission. |
| Finish scenario | Supply the declared end marker, final scenario submission/result identity and scenario outcome. Only normal completion with no outstanding scenario submission can request normal stop. Failure, interruption and premature completion request failure containment instead. |
| Collect / contain | Only after ticks are suppressed and the active holder is settled, admit the existing read-only evidence and exact-clone containment set. Each command has its own receipt and may fail independently. |

There are at most two outstanding operations: one scenario submission and one tick.
At most one is active. The other can be pending. When neither is active, both
can be pending. Submissions are immutable values.

The owner hides queue, lock and process mechanics. A duplicate, unknown sender, sequence gap,
excess submission or broken result channel closes eligibility. It is not retried
or silently deduplicated into success. One idempotent internal notification that
an already recorded stop is pending is not a second stop request or external
command.

The worker is a direct, joinable child, never disowned. Its identity consists of
the run and owner generations, a fresh worker token, the directly created child
and its recorded process incarnation. Retained private control channels bind
messages to that child. A PID supplied later by a file is insufficient authority
to signal, accept a stop acknowledgement or claim exit. The finite caller
likewise owns the command-owner child until reap.

The finite caller creates one private scenario channel and registers its client
token and process incarnation during owner startup. Helpers use that channel
through the caller. They cannot create another authorised sender by copying an ID.
Each frame binds the role, run, owner generation, token and sequence to its
retained channel. The worker channel has a separate role and token.

The caller remains in its original process group. The owner starts a separate
session, outside the caller's foreground group. Its worker and each active
backend have separate owned process groups within that session. The backend's
CLI and validators inherit the backend group. Only recorded members qualify for
group containment. Unknown descendants retain the unresolved-containment outcome.

Before readiness, the owner records the worker's creation and sends that identity
to the caller. Each backend creation likewise receives a distinct observation.
These records support identification after owner loss. They do not let the caller
reap a grandchild or turn a bare PID into termination authority.

Neither worker nor scenario client inherits the writer descriptor. Only the
active command/validator processes that must preserve the current lock on owner
loss inherit it.

This is a cooperating-harness contract. It is not confinement against malicious
same-user processes or a guarantee that the external CLI cannot create an
unknown descendant. An unknown holder or descendant makes containment
unresolved.

## Dispatch and publication boundary

The owner processes control events and state transitions serially, while it
observes the active child without blocking receipt of stop/failure events. An
operation owns the dispatch domain through CLI completion, full response and
artifact qualification, required output delivery and terminal publication. An
available writer during a preliminary check grants no future permission.
Potentially blocking CLI and validation work runs in owned children. It cannot
block the owner's control loop.

The adapter uses the owner's already-held writer descriptor through a private
entry point. Calling the current public lock-taking adapter beneath a
lifetime-held lock would contend with the owner itself and is not this design.
Child lock inheritance and actual closure remain required.

The owner exclusively reserves the next attempt directory and publishes its
commitment before creating the backend child. The private entry point receives
the held directory and lock, assigned ordinal, submission ID and commitment ID.
It also receives the stop ID observed at commitment, or null. A later stop is a
separate event referencing the commitment, never a rewritten argument.

The child checks those bindings and uses that exact directory. It neither
scans for a new ordinal nor creates another attempt. The prior-attempt scan
excludes only this correctly bound commitment and still rejects unfinished
predecessors. A reservation or publication failure closes eligibility and retains
the partial directory. No ordinal is reused, including after owner loss.

Owner events and child receipts occupy distinct immutable records under the same
writer authority. Only the owner assigns event sequence numbers. No concurrent
appenders share an event file, and no child independently authorises another
operation. The current public backend remains unchanged until implementation.

At actual dispatch the owner rechecks root/VM/generation identity, eligibility,
pending failure and stop events, and worker health. It also rechecks the
required profile, reserved capacity and the absence of an unfinished prior
attempt. Admission acknowledgement is never dispatch authority. Required capture
validation and terminal publication must be complete before any later scenario
command can cross this boundary.

There are three distinct records of progress:

1. **Submission:** accepted into bounded pending work, with no attempt ordinal.
<!-- tc: depart synonym-rotation because launch is an event and started is a required state identifier -->
2. **Dispatch commitment:** the owner assigns the next ordinal and records an
   intent to execute once. This is the serialised ordering point against stop.
   It creates an owned attempt, not proof that the external CLI ran or delivered
   input. The observed launch state is `not-started`, `started` or `unknown`. A crash between intent and launch cannot prove no dispatch.
3. **Terminal result:** the original command, validation, delivery and publication
   outcomes are known and retained. Only their complete clean conjunction is a
   clean attempt. A result file alone proves neither successful client receipt
   nor process exit.

The commitment transition drains already observable failure/stop controls and
checks eligibility immediately before initiating the operation. It must not
yield to another admission decision between that check and launch. An
asynchronous signal or remote failure can race this local transition. Record the
observed ordering and uncertain delivery, never claim an atomic observation of
the outside world.

A failure known before commitment prevents it. A failure learned afterward
closes all later scenario dispatch even if this committed operation finishes
clean. If launch is suppressed after commitment, retain the ordinal and its real
cause. The attempt remains unstarted or uncertain. Do not pretend it was a
successful capture.

Pending cancellation has a submission/lifecycle record and **no attempt
ordinal**. Committed work is never returned to pending, renumbered, resubmitted
or replaced. 

The owner preserves the backend's raw CLI, local evaluator and
signal statuses separately from its admission/result status. Unavailable owner
transport returns 125. Clean local negative state and exhausted state remain
distinguishable under the existing helper contracts. Signals retain their actual
number and observed wait representation, including shell statuses 129/130/143
for HUP/INT/TERM where that shell supplies them. No numeric status alone
establishes clean evidence.

An output delivery failure after successful capture is unavailable. The owner
must record it before opening dispatch again. Missing acknowledgement closes
eligibility. A terminal publication failure also closes eligibility even if
successful payload bytes have reached the scenario. The scenario cannot use
those bytes to bypass the next owner gate.

The first failure observed by the owner is immutable. A backend latch can precede
that observation and remains binding independently. Later events preserve their
own times and causes without claiming a global signal-delivery order.

### Output receipt and operation completion

Backend emission and submitter receipt are different events. The backend flushes
its payload to the owner and publishes its existing result receipt. The owner
requires complete streams, that receipt, validation evidence and observed backend
exit before offering a result to the submitter. Flush success alone proves no
submitter receipt.

The owner sends one result offer containing the submission, ordinal, payload
identity and backend-result reference. The submitter acknowledges the exact offer
and records its receipt time in that message. The owner retains the original
acknowledgement and its own receive time. A missing, mismatched or failed
acknowledgement closes eligibility. Failure results remain failures even when
their delivery succeeds.

The acknowledgement reports byte receipt, not permission to continue. The submitter
waits while the owner publishes the terminal operation disposition. The owner
then sends a completion frame naming that immutable terminal record. Only receipt
of that frame completes the synchronous helper operation. No further acknowledgement
of the frame is required, so publication does not depend on its own later receipt.

The next submission or finish message echoes the preceding terminal identity and
completion-frame receipt time. The worker's next phase report does the same.
Missing or conflicting echoes close eligibility. A broken channel or failed
completion send also closes eligibility. A recipient that lacks the completion
frame reports unavailable and cannot continue from the offered payload.

The owner's event records retain every available send, acknowledgement and echo
observation. A missing final echo remains unknown, never inferred from a terminal
file. The caller's final observation boundary below governs that unavailable tail.

## Cooperative normal stop

The worker follows this sequence: complete one sleep of twenty seconds, submit
one tick, then await that submission's disposition. It starts no new sleep while
admission, capture, validation, acknowledgement or terminal completion is outstanding.
After a clean completion frame, it starts the next sleep only if no stop or
failure is pending. Cancellation or failure ends the loop instead.

The worker's control channel remains observable while it waits for a result.
That wait prohibits another tick. It does not prohibit receiving stop or failure
controls. The worker acknowledges a result offer before waiting for completion,
so the result protocol contains no circular wait.

The worker supervises its sleep child and observes the parent channel while that
child sleeps. The sleep child inherits the worker group and no writer descriptor.
A normal stop waits for that same sleep to return. Parent loss follows failure
containment instead and never supplies normal-stop evidence.

| Worker phase | Meaning |
|---|---|
| Starting | The child exists but readiness is incomplete. |
| Sleeping | The current sleep of twenty seconds has not returned. |
| Submitting | Sleep completed and one tick message awaits its admission disposition. |
| Awaiting result | One admitted tick awaits cancellation or the complete result protocol. |
| Stopping | The worker resolves its current sleep or tick under the received stop ID. No new sleep or tick starts. |
| Exiting | The worker sent its final acknowledgement or failure and is closing its channel. This phase does not establish exit. |

The owner records each received phase report with its worker sequence and sleep
or tick identity. A stop record names the last observed phase and report ID.
That phase can lag the worker. The owner's pending and committed records decide
cancellation versus drain. Reaped is an owner observation, not a worker phase.

Normal completion closes scenario admission and suppresses future ticks in one
owner transition **before** acknowledging the finish request. It assigns one
stop ID and records the caller's declared normal end, the observed worker phase,
any pending submission and any committed attempt. The owner then sends that
exact stop ID to its owned worker. If durable intent cannot be written,
normal-stop success is impossible. Suppression still occurs and failure
containment starts.

The worker retains the existing sleep-20-then-one-capture schedule. A normal
stop does not signal or shorten an active sleep. The worker finishes that sleep,
sees the stop control and exits cooperatively without submitting another tick.
The owner independently suppresses a due submission that races this
notification. There is no successful-sleep capture receipt, extra capture, new
sleep or repeated input.

The remaining natural sleep can delay reap by almost twenty seconds. The finite
profile must accommodate it without claiming that a scheduler or an
uninterruptible sleep has a guaranteed return time.

For a pending tick the owner records `cancelled-unstarted` against its
submission ID and stop ID, without an ordinal. For a committed capture, normal
stop drains that attempt through the same CLI, full validation, output and
terminal record. The worker acknowledges stop only after it receives that
attempt's actual result or learns that completion is unavailable. A stop does
not extend the operation's existing deadline. Failure or expiry switches to
failure containment. It cannot be classified as a clean planned cancellation.

| Phase when finish/stop is processed | Required action and outcome |
|---|---|
| Before worker readiness | Startup unavailable. No normal completion or scenario dispatch. Retain and reap any created child. |
| Sleeping | Suppress ticks, retain stop intent, let this sleep finish and require matched acknowledgement and clean exit. Unexpected sleep failure remains a failure. |
| Sleep returned. Tick message not admitted | Suppress the message, retain its cancellation identity, and send the existing stop disposition. No ordinal or capture. |
| Tick pending behind OCR, exec, transfer or another operation | Cancel the pending tick as unstarted. Stop closes future admission. The holder retains its actual outcome. No special VNC or UI exception. |
| Stop and tick both ready before commitment | The stop/failure control is processed first. Cancel the tick. Control precedence is independent of screen state or command success. |
| Capture committed or running | Retain the attempt and drain normally within its unchanged deadline. No next tick. Any interruption, failed transport or unknown completion prevents acceptance. |
| CLI exited. Capture still validating | Keep ownership. Finish the required PNG qualification. Corruption or resource failure cannot become normal shutdown. |
| Artifact qualified. Terminal publication or delivery outstanding | Keep ownership until both are established. A missing/failed result or delivery prevents acceptance. |
| Terminal published. Completion frame outstanding | Deliver the completion frame and stop disposition. A broken channel is unavailable, not an assumed receipt. |
| Worker acknowledged. Has not exited | Wait for this exact child. Acknowledgement alone is not exit. Unexpected signal/nonzero exit remains failed. |
| Worker exited. Owner has not published reap | Require observed child wait status plus complete lifecycle publication. Exit zero alone is insufficient. |
| Prior failure at any phase | Preserve it. A matched cooperative exit may still be recorded, but the run stays ineligible. |

No scenario call may remain queued at normal finish: the synchronous interface
requires its result before the declared end. A concurrent scenario submission
therefore makes the finish protocol invalid and closes eligibility. During an
abnormal stop, pending scenario work is cancelled without dispatch and reported
as unavailable with its causal failure, never as clean skipped work.

## Lifecycle evidence and final observation

Lifecycle records use a separate event sequence under the **same owner and
lock**. They do not consume command ordinals. Their type cannot be confused with
a clean capture or a local failed-sleep poll record. Each event is immutable. It
names the run, exact VM/root identity, owner/worker generations, monotonic
observation time, wall time for presentation, event ID and its causal
predecessor.

Numeric times from different processes are comparable only under the declared
common clock. The owner's event sequence decides ordering.

| Record | Required fields in addition to common identity |
|---|---|
| Worker ready | Created-child identity/incarnation, process group, channel role/token, initial tick sequence and readiness observation. Reference the prior creation record and caller notification. |
| Worker phase | Original phase report, worker sequence, sleep/tick identity, sender time and owner receive time. Include the preceding completion identity and receipt time where applicable. |
| Submission event | Client or worker identity, submission ID, producer sequence, operation/tick ID and event kind: received, admitted or cancelled-unstarted. Each kind has its own immutable event and time. Cancellation includes its cause and stop ID. The ordinal is always null. |
| Dispatch commitment | Owner-written event linking submission and assigned ordinal to the reserved directory and exact command, arguments, predicate and transport. Include class, profile/deadlines/capacity identity, eligibility observations, commitment time and stop ID or null. |
| Launch observation | Owner-written event referencing commitment, backend child token/incarnation/group, observed creation time and launch state. Backend observations separately name the CLI and validator children, times and actual wait results. Missing creation evidence remains unknown. |
| Backend result | Child-written command result, raw stream references, validation/artifact references, raw statuses, emission status and terminal publication time. It names the assigned ordinal and commitment. It proves neither submitter receipt nor clean owner disposition. |
| Result acknowledgement | Owner-retained original acknowledgement naming the result offer, submission, ordinal, payload identity and backend-result reference. Include submitter receipt time, owner receive time and any exact channel failure. |
| Terminal operation disposition | Owner-written record joining commitment, launch observations, backend result, child reap and result acknowledgement. Include exact outcomes/statuses, first-failure reference, missing facts, publication identity and time. Clean requires the complete clean join. |
| Completion observation | Owner-written completion-send observation or later submitter echo, each with its own event and time. Name the terminal record. A missing echo stays unknown. |
| Stop intent | Stop ID, reason (`normal-end`, failure or signal), declared scenario-end/result identity and first-failure reference or null. Worker phase, pending IDs, current attempt ordinal or null and frozen deadline/profile identity. |
| Worker acknowledgement | Exact stop ID/token, last submitted tick and its disposition, any active attempt result reference, final worker phase. The owner retains the received message before interpreting it. |
| Worker reap | Exact child match, observed raw wait status, exit code or signal, acknowledgement reference, pending/active resolution, missing-record list and independent lifecycle classification. |
| Owner handoff | Closed eligibility, first failure, all attempt/lifecycle references, holder status, possible held input, required untouched collection order and containment outcome. |

Submission events never gain an ordinal later. The commitment provides the
immutable link to an attempt. Launch observations distinguish backend creation
from external CLI execution. A recorded creation alone proves neither CLI launch
nor input delivery. Each publisher preserves partial files and missing facts
without overwriting an earlier event.

The record's complete publication establishes that record's existence. It cannot
establish its publisher's later return or exit. Child terminal facts belong to
the owner's observations, and owner terminal facts belong to the caller below.

A **normal worker stop** requires the declared scenario end and a clean prior
history. It also requires complete resolution of committed required work, the
exact intent/acknowledgement join, observed exit zero and a published matched
reap. All are required. A cooperative exit after failure is recorded as such
alongside the original failure. It supplies no normal-run acceptance.

Missing fields, duplicate/conflicting events, a truncated record, EOF before
acknowledgement or an unmatched child make the lifecycle unavailable. No later
reconstruction replaces a missing event.

The owner remains alive for collection after worker reap and retains the writer
through its final handoff. The finite caller observes the owner's final
response, channel completion and actual child wait status, then records them in
the caller's outcome. Owner death after its final file but before established
delivery/exit is not accepted from that file alone.

The caller's final return is the explicit source/OS trust boundary: there is no
infinite chain of writers recording their own later exits. Caller death or
storage loss can leave this final tail unknown. Complete-looking files do not
establish acceptance. No recovery continues the scenario or starts another slot
from such a tail.

## Failure and containment

INT, TERM and HUP close scenario eligibility and suppress future ticks. Keep the
original signal separate from transport failures and later cleanup statuses.
Normal stop sends no signal. A signal used after timeout is a containment
action, never its successful acknowledgement. Unexpected worker exit, broken
parent channel or owner death likewise ends eligibility, including an exit with
status zero that has no matching planned-stop evidence.

The caller forwards an observed INT, TERM or HUP once to its owned owner through
the control channel. Channel failure itself ends eligibility. The owner first
closes admission and records the signal, then applies the declared containment
policy to owned groups. It never forwards a signal as a normal-stop request.
Independent or simultaneous signals retain each process's actual observed status.

On parent-channel EOF or loss, the worker suppresses ticks immediately when it
observes the loss. It reports failure if a channel remains and exits after
settling its owned sleep child. Normal-stop protection against shortening sleep
does not classify parent loss as normal. Uninterruptible sleep, unknown descendants
or unavailable terminal observation can leave containment unresolved.

The owner likewise treats caller-channel loss as failure. An orphaned worker
cannot keep submitting ticks to a replacement owner. The caller cannot claim a
worker reap after owner death unless its own actual child relationship permits
that observation. Otherwise the missing terminal fact remains explicit.

The active command and validator remain owned until actual terminal observation
and reap. Recorded direct-child ownership and retained identity, not a bare PID
or name search, authorise termination. A process group is usable only while its
membership/ownership remains established. If descendants, inherited descriptors
or an uninterruptible holder cannot be resolved within the selected containment
policy, report unknown ownership/containment and block later slots. Do not
delete or replace the writer file, clear the latch or reopen another lock
domain. Do not assume that killing the parent released inherited ownership.

If the owner dies, the finite caller stops the scenario and resolves only
children it can positively identify. It may acquire the original writer lock for
a collection-only recovery after all known holders are settled and exclusive
ownership is actually obtained. It records the failed owner generation and the
new collection-only generation. It never resumes scenario admission or
overwrites partial receipts. Inability to establish ownership leaves collection
and exact clone containment unresolved. This is a serialised handoff in the
original domain, not permission for a concurrent second writer or an out-of-band
VM command.

After holder resolution, perform the protocol's untouched failure observer,
agent-window list and screenshot in that order when applicable. Perform each
once, before other collection. A failed observation remains failed. Attempt the
next required context item only while ownership and collection capacity permit.
No focus, keyboard, corrective pointer input or bare release is introduced.

Waiting for a holder can delay these observations or make them unavailable.
Later context never replaces the original assertion.

Retain endpoint/environment/original audits, the exact requested clone's stop
response, and independent inventory separately. Failure of any collection item
cannot invalidate an already qualified recurrence or restore acceptance. Missing
containment prevents every later slot.

Both held-pointer cases remain: a signal during a held-point attempt, and a
signal during settling sleep after a clean down receipt. A clean down without a
later clean release means possible held input even with no latch. Failed or
partial down/release receipts preserve delivery uncertainty. Neither worker stop
nor owner recovery sends a release. Contain the exact clone under the same
domain.

All original images, raw output, intent/terminal records and partials remain
unique and private. At a resource limit, stop acceptance and later scenario
dispatch without truncating, deleting, overwriting, downsampling or omitting a
required image to keep running. Storage failure can prevent even failure and
reap records. Preserve what exists and report what cannot be established. This
design does not guarantee preservation or available cleanup on failed storage.

## Test seams and discriminating controls

Use the agreed existing helper/adapter seam with controlled CLI and sleep
behaviour. Exercise the real owner, lock, validator and receipt code once
implemented. Phase barriers are test controls, not production UI waits. Tests
must observe actual CLI invocation count and arguments, event/ordinal
relationships, raw statuses, retained bytes and later-dispatch refusal. Proposed
controls are not claimed as executed tests of this unimplemented design.

CLI controls reach an active command and its return. A controlled sleep executable
in the worker's test environment reaches sleeping and sleep-return schedules.
The parent's shell-function override does not reach a separately executed worker.
A copied validator wrapper reaches the interval after CLI exit and before PNG
qualification completes. These controls retain real receipts and locking.

CLI and sleep controls cannot reach every transition inside the owner. The
proposed additional enabling points are test-only barriers in a copied owner
module. They precede the final control drain and eligibility check, follow durable
commitment before child creation, and bracket acknowledgement and terminal publication.
They must preserve the real transition code and introduce no production switch
or UI-dependent delay. A barrier before commitment resumes through the actual
eligibility check.

Whole-design agreement must settle the seam decision before these internal
barriers become agreed. The recommendation uses barriers in copied modules, matching the existing
validator control. Their cost is test-copy correspondence auditing. An injected
production callback adds a maintained interface and requires separate approval.
External controls alone leave the internal race rows unqualified. None of those
alternatives is approved here by implication.

| Controlled schedule or defect | Required discrimination |
|---|---|
| OCR/exec/transfer holds ownership when a tick becomes due | Tick is pending, not dispatched/refused as a competing writer. A failure before its actual commitment cancels it with no ordinal. Numerical admission expiry is tested under the later profile. |
| Capture holds ownership when scenario input arrives, including after CLI exit | Input cannot dispatch until image validation, delivery and terminal publication finish. Invalid image prevents it entirely. |
| Failure after admission, immediately before commitment, and immediately after commitment | Only the last schedule may have committed work. No later success restores eligibility. Launch uncertainty remains explicit. |
| Normal end during each row of the stop race table | Required cancellation/drain and exact intent/acknowledgement/reap match. No fake attempt or extra tick. |
| Clean sleep versus sleep failure/signal concurrent with normal stop | Natural sleep completion can stop normally. Actual failed/interrupted sleep cannot be relabelled. |
| Prior latch followed by otherwise matched stop. Exit zero without stop | Both remain ineligible. |
| Wrong token, stale/reused PID, duplicate finish, pending scenario input at finish | No normal-stop success, no mistaken signal target and no later input. |
| Missing intent, acknowledgement, result, output acknowledgement or reap publication | Complete-looking remaining files cannot establish acceptance. Include final-record capacity exhaustion separately from command failure. |
| INT/TERM/HUP and abrupt owner death at CLI, validator and publication barriers | Exact signal/partial evidence survives where available. No concurrent collection or recovery of scenario authority. |
| Parent dies while child retains writer. Unknown or uninterruptible holder | Collection stays refused until established ownership and actual lock acquisition. Unresolved containment blocks later slots. |
| Both held-pointer cases | No resize-release or other corrective input. Ordered receipts and held-input uncertainty reach exact-clone containment. |
| Collection failure and exact-clone stop/inventory disagreement | Separate statuses, unchanged recurrence, no acceptance and no later slot. |
| Tick remains pending longer than twenty seconds | No second sleep or tick occurs before the first tick's complete disposition. A premature-sleep mutant fails. |
| Owner dies after commitment and before backend creation | The reserved ordinal and intent remain. No second allocator, replacement attempt or claim of external delivery appears. |
| Backend latches but returns otherwise clean | The owner's next commitment still refuses. Child result and owner eligibility remain separate facts. |
| Backend emission succeeds but submitter acknowledgement fails | No clean terminal disposition or later dispatch follows. Payload bytes alone grant no authority. |
| Terminal publication or completion frame is missing | The submitter cannot continue. The retained payload acknowledgement does not certify final completion. |
| Terminal-group signal, direct child signal and parent-channel loss | The chosen process topology and actual statuses remain visible. No orphan tick, false reap or normal-stop classification follows. |

Exercise mutants that treat cancellation as a clean capture or accept exit zero
without the stop join. Also exercise mutants that clear a prior latch, release
ownership before validation or start collection while a child retains it. Each
must fail its corresponding control. Resource boundary and usefulness controls
belong to the complete profile. Local controls establish neither VNC liveness
nor repaired native focus. Native behaviour stays at the existing TestAnyware
workflow after all prerequisites.

## Decisions and excluded alternatives

The owner centralises scheduling, failure and receipt knowledge that otherwise
spreads across the scenario and background worker. A separate lifecycle writer
would require another publication and failure-ordering protocol. It is not
selected. Signalling a sleeping worker is simpler but conflicts with the
retained failed-sleep meaning. Letting its one existing sleep finish costs
shutdown latency and preserves that distinction. Revisit this choice only
through an explicit change to the agreed sleep/stop contract, with corresponding
interruption controls.

This design introduces control channels, child supervision and acknowledgement
state. It does not claim fewer failure cases or simpler implementation merely
because callers have one entry point.

## Scheduling and deadline profile

This is the proposed `settings-owner-scheduling/1` policy. It is a reviewable
timing contract, not an executable default or a qualified native profile.
The [scheduling evidence](../verification/settings-activation/KEEPALIVE-SCHEDULING.md)
explains its source basis, alternatives and required controls.

### Arbitration and admission

The owner orders complete valid submissions by its receive-event sequence.
It serves the oldest pending submission without preemption. A stable scan order
reads the scenario channel before the worker channel when both become readable
in one control-loop iteration. This only breaks a simultaneous arrival tie.
Already received work always precedes newly received work.

Failure controls, expired deadlines and stop controls precede command selection.
The owner drains these controls again immediately before commitment. An expired
deadline takes precedence over a success observation processed at that boundary.
No result, input class, VNC activity or observed UI state changes priority.

Each producer has one outstanding operation, including pending, committed and
awaiting-completion states. Thus there are at most two outstanding operations
across scenario and worker. There can be one active and one pending operation,
or two pending operations while the owner is idle. Neither producer may pipeline
another operation behind its active one.

The submitter starts its admission clock before sending its immutable request.
For a tick, this origin is the worker's observation of successful sleep completion.
The complete request must reach the owner within two seconds. The owner must
publish admission or refusal within two further seconds. An admitted request
must reach commitment within 150 seconds of its original admission-clock origin.
These message and admission deadlines do not reset while the holder progresses.

Every other control or result frame also has a two-second send-to-receive limit.
An incomplete frame is not receipt. Existing whole-phase deadlines still apply.

Selection starts immediately when ownership becomes available. The owner has
two seconds to finish selection, reserve the ordinal and publish commitment.
This interval remains inside the 150-second admission deadline. No deliberate
delay consumes otherwise available time. Expiry closes eligibility and cancels
unstarted work without ordinals. A failed or expired request is never resubmitted.

One holder can delay the other producer. It cannot be replaced by an endless
sequence of younger requests. With the operation bounds below, the longest
clean holder occupies at most 142 seconds. Request transfer, admission recording
and selection add at most six seconds. The 150-second admission budget covers
that 148-second conservative path with two seconds of scheduling margin.

If the host cannot meet those bounds, the outcome is unavailable. Starvation
cannot be labelled success, even when process termination remains unresolved.

### Clock and operation deadlines

All proposed deadlines use one host continuous clock in integer nanoseconds.
On macOS, use `clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)` or its exact binding.
This clock includes host sleep. Record the host boot identity and clock API.

Do not compare these times with guest clocks or the existing backend's
`monotonic_ns` durations. The owner event sequence remains the ordering authority.
Wall times are presentation only. Missing clock identity refuses startup.

The owner checks deadlines on every control transition and before commitment.
An observation processed at or after its deadline is expired. An earlier sender
timestamp cannot rescue a late owner observation.

The owner's timed event wait has a maximum of 100 milliseconds. After delayed scheduling
or host resume, it checks expiry before accepting a result or dispatching work.
The finite caller independently watches the advertised absolute deadlines.
It receives each deadline/state transition through the existing private channel
within two seconds. Lost progress or an unresponsive owner closes caller eligibility.
No timer guarantees that the host can run a signal handler at its deadline.

The CLI allowance starts when child creation is observed. The whole-operation
allowance starts at dispatch commitment, before child creation.

| Operation family | CLI allowance | Whole-operation allowance |
|---|---:|---:|
| Checked capture, physical input, ordinary agent/screen read | 30 seconds | 52 seconds |
| Existing Allow OCR with its unchanged timeout of 30 seconds | 45 seconds | 67 seconds |
| Guest exec, including its existing guest timeout | 45 seconds | 67 seconds |
| File upload/download and VM lifecycle commands | 120 seconds | 142 seconds |
| Local poll/failure record with no CLI | 0 seconds | 22 seconds |

An exact operation mapping belongs to the frozen profile. Unknown operations
refuse admission. Evidence-class operations use the same family limits.
A helper with several commands retains separate submissions and existing waits.
Its queue time never shortens a sleep, increases a poll count or grants another attempt.

Every operation also has these phase ceilings. A phase starts at the end of
its predecessor, without an unbudgeted gap. Every ceiling is clipped by the
unchanged whole-operation deadline. Unused time cannot extend a later phase.

| Phase | Maximum elapsed time | Required completion |
|---|---:|---|
| Commitment to observed backend/CLI creation | 2 seconds | Bound child identity and launch observation |
| CLI | Family allowance above | Actual exit and retained complete raw streams |
| Response, predicate and artifact validation | 10 seconds | Complete required checks, including every PNG check |
| Backend receipt and payload emission | 2 seconds | Complete backend result and emission observations |
| Backend exit/reap | 2 seconds | Actual terminal child observation |
| Result offer and submitter acknowledgement | 2 seconds | Exact payload acknowledgement retained by owner |
| Owner terminal publication | 2 seconds | Complete immutable operation disposition |
| Completion frame delivery | 2 seconds | Sender observation and submitter receipt before its next action |

The phases outside the CLI total 22 seconds. CLI exit does not release ownership.
An active validator, unpublished result or unfinished delivery prevents later
dispatch. The final echo still follows the lifecycle contract. A late echo
cannot rescue an earlier delivery timeout or prove an unobserved receipt.

The 45-second allowance leaves 15 seconds around the existing 30-second inner
OCR/exec budget. The 120-second family accommodates slower finite transfers and
lifecycle work without assigning them native liveness credit. The other phases
reserve explicit time for validation and durable protocol work. These are
selected service targets, not measured performance distributions. Resource design
must demonstrate a useful workload within them or revise the whole profile before review.

### Sleep, stop and containment deadlines

Startup has five seconds from the caller's owner-creation request to published
worker readiness and caller receipt. Missing readiness ends startup eligibility.
It does not prove that no process was created.

The worker starts its next sleep within two seconds of complete tick disposition.
The sleep remains one invocation of `sleep 20`. From the worker's sleep-launch
intent, allow 24 seconds for creation, natural sleep completion and its phase report.
This includes two seconds each for launch and observation around the unchanged
twenty-second sleep. A late, failed or interrupted sleep closes eligibility.

Normal stop never signals or shortens this sleep. A due tick uses the original
150-second admission budget, without catch-up ticks or another sleep while pending.

Normal stop has 150 seconds from receipt of the valid finish request to published
worker reap. Stop intent must publish within two seconds. A committed operation
keeps its original deadline, leaving at most 142 seconds from finish receipt.
An existing sleep keeps its original 24-second deadline. After that work resolves,
allow two seconds each for stop acknowledgement, actual exit and reap publication.
The conservative 142 + 2 + 2 + 2 path fits within 150 seconds.

Intent publication
occurs during that drain, not before starting a new drain clock.
Pending cancellation must publish within two seconds of stop intent.
Failure at any phase invokes failure containment. A matched stop never clears it.

Failure containment uses one twenty-second observation window from the first
failure requiring termination. Admission closes immediately. Send TERM only to
established owned targets by second 2. Observe them until second 7. If still
owned and live, send KILL once by second 9. Observe exit/reap until second 14.

Allow two seconds each for holder bookkeeping, actual original-lock acquisition
and containment-disposition publication. Missing facts at second 20 remain unresolved.
Already exited targets receive no signal. Unknown identities receive no signal.
Repeated failures cannot restart this window. A normal-stop deadline that fails
starts this failure window once, without reclassifying the stop as normal.

The caller applies this policy to its actual owned children after owner loss.
It cannot infer a grandchild reap or authority over an unknown descendant.
No unconditional blocking wait follows timeout. Uninterruptible holders may outlive
the observation window and prevent collection indefinitely. The outcome remains
unresolved containment, with every later slot blocked. No lock deletion or new
writer domain substitutes for actual ownership.

After established holder resolution, the collection-only path retains the same
operation deadlines and writer domain. It performs the untouched observer,
window list and screenshot in their required order, then the remaining audits.
Exact-clone stop uses the lifecycle family. Independent inventory is a separate
read, with its own result. Their failures remain separate. The complete workload
must supply the total collection budget and protected capacity before startup.

After collection ends, owner handoff, caller receipt, owner reap and caller outcome
publication each have two seconds, for eight seconds total. A missing final fact
remains unavailable under the existing caller-return trust boundary.

### Timing evidence and offline controls

Extend the existing record fields with profile identity, clock/boot identity,
phase origin and absolute deadline, observed finish, and deadline-check time.
Admission records retain the producer origin, owner receive sequence, current
holder identity, queue entry, selection and commitment. Delay attribution names
ownership, transfer or local protocol work. It never names a UI predicate as a
scheduling reason. Record late observations even after eligibility closes.

Retain sleep launch/return/report, due time, CLI creation/exit, validation end,
publication, acknowledgement and completion receipt separately. Record the
deadline that failed and the first-failure link. Preserve raw statuses alongside
owner status 125. Do not invent an exit code for a process whose exit is unknown.

The [boundary-control matrix](../verification/settings-activation/KEEPALIVE-SCHEDULING.md#required-offline-controls)
specifies both overlap directions, expiry boundaries, stop races and containment.
Those are obligations for the real coordinator with controlled CLI and sleep.
No coordinator test, native liveness result or focus repair is claimed here.

## Remaining profile

Scheduling is proposed above. Enforceable resources and complete workload accounting
remain mandatory unresolved inputs. There is no executable combined profile.
Absence prevents startup. Resource design must reconcile the timing targets with
actual useful capture, transfer, validation, retention and collection work.

That design must bound the actual external CLI/encoder before
allocations/writes. It must also bound encoded bytes, dimensions/decoded bytes,
owned validator buffers and elapsed work. Aggregate captures/raw output/partials
and separately protected terminal/cleanup capacity also require bounds.
Post-capture checks and free-space snapshots are not reservations. A streaming
validator alone does not bound its producer.

Required offline controls and a useful declared workload must justify the
numbers. This slice supplies neither an arbitrary cap nor an availability
promise.

<!-- tc: depart synonym-rotation because fixed describes policy and repaired describes native focus -->
The complete design must preserve successful scenario input order, explicit
sleeps, poll counts, one-attempt transports and the same E/A prefix. Only fixed,
logged UI-independent ownership delays are admitted. Record submission, due,
admission, commitment, CLI exit, validation, publication and result-receipt times
so elapsed changes remain visible. Those delays can change the intermittent
symptom. All-green results still leave symptom preservation unknown.

## Original duties and review handoff

The [complete original-duty
comparison](../verification/settings-activation/KEEPALIVE-DESIGN.md#original-duties-and-handoff)
and [ordering
protocol](../verification/settings-activation/ORDERING-EVALUATION-PLAN.md)
remain binding. Lifecycle design does not discharge numerical profile, helper
implementation, caller adoption, signals, finite collection, prefix or readiness
duties.

Missing snapshot trees, omitted versus empty AXValue, OCR substring early stop
and held-frame capture fallback remain availability limits. Private roots, all
historical failures/partials/NOT RUN phases, closed caps and held causal slots
are unchanged. No VM, candidate, freeze, acceptance, release or ancestor closure
follows. Lifecycle review corrections are integrated. Scheduling review and every
earned integration precede the resource design. The complete owner receives
whole-design review and every earned integration before planning and implementation.
