# Settings command ownership and worker lifecycle

## Design boundary

The proposed owner lets the Settings scenario and its required keepalive
captures share one command stream. This document specifies ownership and
cooperative stop under the [agreed
scope](../verification/settings-activation/KEEPALIVE-DESIGN.md#required-scope-decision).
It is a **design slice awaiting independent review**, not an implemented or
complete coordinator. The [remaining profile](#remaining-profile) must supply
numerical deadlines, arbitration and enforceable resources before whole-design
review, planning or implementation. Adoption and every runtime slot stay held.

A planned stop is a lifecycle event. It can cancel a tick that has not entered
dispatch. It cannot turn a failed sleep or capture into success. A capture
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

The owner is the only process that accepts commands, changes scenario
eligibility, assigns attempt ordinals or publishes normal receipts. The worker
requests ticks. It neither runs the CLI nor writes evidence. Scenario helpers
submit operations to the owner and synchronously receive their result.
Collection uses that same owner, root, lock and ordinal sequence after scenario
eligibility closes. No second evidence writer, unlocked success path or
alternate root is introduced.

| Interface operation | Contract |
|---|---|
| Start | Pin run/VM/root, the reviewed profile identity and actual process ownership. Establish exclusive writer ownership and worker readiness before scenario admission. Missing profile, failed readiness or duplicate owner refuses startup. |
| Submit scenario operation | Supply unique submission ID, caller sequence, operation name, class, transport, exact arguments and required predicate/confirmation. At most one outstanding submission per scenario. Helpers cannot pipeline inputs. |
| Submit due tick | Supply worker generation, tick sequence and completed sleep identity. At most one outstanding tick. The owner constructs the existing checked capture. The worker cannot choose an evidence exemption or arbitrary CLI arguments. |
| Report local failure | Submit the exact poll/state/sleep/signal status and phase. The owner closes eligibility and retains the original status. A failed reporting channel is itself unavailable. This control is not queued behind command admission. |
| Finish scenario | Supply the declared end marker, final scenario submission/result identity and scenario outcome. Only normal completion with no outstanding scenario submission can request normal stop. Failure, interruption and premature completion request failure containment instead. |
| Collect / contain | Only after ticks are suppressed and the active holder is settled, admit the existing read-only evidence and exact-clone containment set. Each command has its own receipt and may fail independently. |

There is one active operation and at most two pending operations: one scenario
submission and one tick. Submissions are immutable values. The owner hides
queue, lock and process mechanics. A duplicate, unknown sender, sequence gap,
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

The first failure is immutable. Later events add evidence rather than replace
its cause or restore eligibility.

## Cooperative normal stop

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
| Clean attempt published. Worker has not received it | Deliver the original result and stop disposition. A broken channel is unavailable, not an assumed receipt. |
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
| Worker ready | Created-child identity/incarnation and channel token, initial tick sequence, readiness observation. |
| Submission disposition | Submission ID and producer sequence, operation or tick ID, received/admitted/cancelled times, cancellation cause and stop ID when applicable. Attempt ordinal null until commitment. |
| Stop intent | Stop ID, reason (`normal-end`, failure or signal), declared scenario-end/result identity and first-failure reference or null. Worker phase, pending IDs, current attempt ordinal or null and frozen deadline/profile identity. |
| Worker acknowledgement | Exact stop ID/token, last submitted tick and its disposition, any active attempt result reference, final worker phase. The owner retains the received message before interpreting it. |
| Worker reap | Exact child match, observed raw wait status, exit code or signal, acknowledgement reference, pending/active resolution, missing-record list and independent lifecycle classification. |
| Owner handoff | Closed eligibility, first failure, all attempt/lifecycle references, holder status, possible held input, required untouched collection order and containment outcome. |

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

Exercise mutants that treat cancellation as a clean capture or accept exit zero
without the stop join. Also exercise mutants that clear a prior latch, release
ownership before validation or start collection while a child retains it. Each
must fail its corresponding control. Resource boundary and usefulness controls
belong to the complete profile. Local controls establish neither VNC liveness
nor repaired native focus. Native behaviour stays at the existing TestAnyware
workflow after all prerequisites.

## Remaining profile

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

The protocol deliberately has no executable defaults for admission, operation,
validation, publication, normal-stop drain, acknowledgement, reap or containment
deadlines. These are mandatory, finite profile inputs. Absence prevents startup.
The next design must derive and choose them together with tick arbitration,
maximum tick delay, a finite run workload and enforced resource capacities.

Normal stop consumes the remaining active-operation deadline. It cannot reset
it. It must also account for the remainder of sleep20 and final
publication/reap. Expiry closes acceptance and later dispatch, with no retry or
successful cleanup reclassification. No deadline establishes a safe native idle
interval.

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
follows. The lifecycle slice receives independent review before the remaining
design consumes it. The complete owner receives whole-design review and every
earned integration before planning and implementation.
