# Keepalive coordination and the scope decision

## Decision and status

**Adoption remains held.** The existing keepalive cannot promise continued
operation when it competes with the scenario's evidence writer. This design
takes k92's explicit unresolved-scope branch: it specifies the conflict, the
failure and containment contract that must survive, and the decision needed
before designing a replacement. It does not authorize a scheduler, new lock,
resource cap, guest, signed candidate or freeze.

The recommendation is to permit design of **one serialized command owner**,
accepting explicitly recorded scheduling delays and deferred keepalive ticks.
This preserves complete capture qualification before another command can start.
It changes timing, so it needs a scope decision; it is not an implementation
instruction. Pair that decision with a finite resource-profile design that
preserves all produced originals. No numerical limits have been selected.

The [evaluation protocol](ORDERING-EVALUATION-PLAN.md),
[capture contract and integration](ORDERING-CAPTURE-RESULTS.md),
[shared writer](ORDERING-NONEXEC-RESULTS.md) and
[accepted product scope](../../specs/settings-activation-discrimination.md)
remain binding. Independent design review and every earned integration precede
the scope decision. Any approved replacement then needs concrete design, review,
planning, implementation and earned review/integration before k89/k81/k76
consumption. This document supplies no native acceptance or ancestor closure.

The editable [visual discussion](../../design/architecture/settings-activation/README.md)
shows the collision and the proposed decision. Sequence views start at their
first message; graph views start at the dark **Start here** node. Neither is a
model-checking result.

## Why the present rules conflict

The loop sleeps 20 seconds **after the preceding capture completes**, then
attempts one capture. It is not a wall-clock periodic timer. The shared
nonblocking lock covers dispatch, response validation, complete PNG inspection
and terminal publication. The existing Allow OCR invocation can occupy this
domain for its 30-second timeout; its substring matcher can also finish early.
There is no measured distribution or guaranteed early finish.

A permitted schedule suffices: the preceding capture finishes at time 0; the
loop sleeps; the scenario enters a long Allow read just afterward; at time 20
the tick finds the writer occupied. The tick refuses without dispatch, latches
unavailable and exits. A clean eventual OCR result cannot restore eligibility.
Conversely, a capture that starts first can refuse the next scenario command,
including while the CLI has finished and PNG inspection still owns the lock.
This is a schedule counterexample, not a measured 30-second native OCR run or
a collision-frequency estimate.

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
| One serialized owner of scenario and keepalive commands | One dispatch at a time; complete capture validation before later dispatch; first failure can cancel unstarted work | Admission waits replace immediate contention refusal for owned submissions; ticks can be late and scenario actions can wait behind a capture | Recommended **scope for further design**, not selected implementation |
| Separate keepalive writer plus shared failure admission gate | Scenario need not wait for PNG validation; capture could have its own unique receipts | Relaxes the global writer/ordinal domain and the barrier against input during unqualified capture; a later capture failure can follow newly admitted scenario input | Not recommended under the present evidence contract; a shared latch alone cannot restore the lost ordering guarantee |
| Skip busy ticks or capture only at scenario checkpoints | Can avoid some collisions without a queue | Omits or defers required captures, changes cadence; checking free then dispatching still races; it does not solve a scenario arriving during a capture | Not selected; neither an idle guarantee nor preservation of all current obligations |
| Persistent VNC connection or another keepalive transport | Might remove periodic screenshot work | New connection/lifecycle semantics and qualification duties; the current source does not establish a suitable supported interface or its effects | Separate capability/design question if serialization is rejected; no new transport selected |

One coordinator earns its place by owning the shared ordering invariant. Callers
would submit one operation and receive one terminal result, rather than manage
lock timing, cross-process latches and background cleanup themselves. It also
introduces pending-work and cancellation state. Merely wrapping each caller in
a blocking lock distributes that protocol and leaves cancellation and evidence
ownership implicit. A priority queue cannot preempt a capture already validating.
Scenario priority can starve ticks; keepalive priority can delay input. Those
trade-offs cannot be hidden behind the word serialization.

Evidence that would reverse the recommendation is a qualified existing transport
that maintains the needed connection without capture competition, or an accepted
requirement that permits input while another required observation is unqualified.
Neither has been established. No claim rules out every possible design.

## Required scope decision

The next requirements discussion must resolve these concrete choices together:

1. **Timing:** permit design of a serialized owner with logged admission delays
   and deferred ticks, or retain the current no-scheduling-wait rule and leave
   adoption unavailable. The recommendation is permission to design serialization.
   Existing explicit scenario sleeps, input sequence and poll counts would stay;
   added elapsed delay would be a named amendment, with possible effects on the
   intermittent symptom. No claim of unchanged timing would remain.
2. **Failure eligibility:** preserve the strong rule that required capture
   qualification finishes before any subsequent scenario dispatch. The
   recommendation retains it. A second writer requires a separate explicit
   relaxation of this rule, not just agreement to use two lock files.
3. **Resources:** permit design and offline qualification of a declared finite
   profile with lossless retention and explicit unavailable outcomes at its
   limits, or explicitly accept unbounded host resource exposure. The
   recommendation is the finite profile. It is not permission to truncate,
   overwrite, delete, downsample or omit a required image.

Approval of this direction would not choose numerical bounds or admit runtime.
The ensuing design must fix maximum pending work, admission/operation deadlines,
tick delay and stop policy, resource units and limits, and the evidence by which
those choices are useful. A deadline that expires must stop acceptance and later
dispatch; it cannot silently retry, drop a tick, cancel then resubmit, or turn
an interrupted required capture into planned cleanup. The design must account
for an uninterruptible/unknown holder and honest unresolved containment.

No E/A slot is a budget for testing a replacement transport or discovering these
limits. A newly required native capability experiment needs its own explicitly
reviewed scope; it is not added by this document or by agreement to design.

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
The exact lifecycle record schema is a subsequent reviewed design obligation.

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

No cap changes here. Any proposed finite profile must explicitly specify and
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

Tier 2 graph generation `2026-10-29T09:52:58Z` located the relevant symbols and
the backend/inspector call. The bidirectional backend trace also had unrelated
Swift/trace edges, which are not credited. The
[coverage receipt](ordering-keepalive-design-evidence/coverage.json) reports changed
metadata for the capture facade/backend/reports, partial shell ranges and
untracked Bats metadata. Direct reads covered the relied-on source and flagged
lines, including the actual current backend rather than trusting stale offsets.
The earlier `scripts/.*` graph filter returned zero; no absence claim uses it.
This is task-bounded verification, not an exhaustive graph audit.

The [verification receipt](ordering-keepalive-design-evidence/verification.json)
and [capture output](ordering-keepalive-design-evidence/capture-check.txt) identify
the fresh helper check and unchanged measured inputs. The
[documentation output](ordering-keepalive-design-evidence/docs-check.txt) is the
actual repository-wide link result, including any pre-existing failures.
Browser inspection checks the two new rendered views after correcting a sequence
label's semicolon parse error. No native guest or new implementation is tested.

Use the existing helper/adapter seam with controlled CLI and sleep behavior.
Keep real locking, qualification and receipt logic. This does not fake native
focus or establish VNC liveness. The existing overlap, post-CLI validation
barrier, signal/refusal and synthetic allocation-failure controls are relevant
evidence; their exact source and limitations are in the capture report.

Before a replacement is consumed, its controls must discriminate both overlap
directions; tick due during 30-second OCR; failure before and after admission;
capture failure before later input; no dispatch for cancelled pending work;
unexpected worker death; planned cancellation during sleep versus in-flight
capture; INT/TERM/HUP and inherited orphan lock; both held-pointer paths;
original/partial retention; exact VM stop plus inventory; every resource-limit
boundary and failure to write terminal evidence. Preserve all successful
scenario actions, explicit waits, poll bounds and E/A prefix correspondence.
Any newly permitted scheduling latency needs separate assertions and reporting.

Independent review should try to defeat the overlap argument and find a route
that satisfies the unchanged contract. It should also challenge whether the
recommended scope weakens failure ordering, mistakes a deadline for native
liveness, or promises preservation/containment when storage or a holder is
unavailable. Review is inspection-only and precedes scope/implementation work.

## Original duties and handoff

| Duty | Disposition |
|---|---|
| Single writer, nonblocking refusal, sleep-20 loop, under-lock unique complete captures, sticky first failure | Current source unchanged; no collision-free availability claimed. Proposed timing amendment requires an explicit scope decision. |
| Original scenario input, explicit sleeps, poll bounds and strict one-attempt transports | Preserved. No scheduling wait, retry, tick omission, bypass or latch reset authorized. |
| K89 file/upload/install/environment/lifecycle/collection helpers | Remain live after review, scope resolution and any resulting design/planning/implementation/review. |
| K81 every exec and one-shot consequence | Still required: installed identity, exact defaults/absence, launch/endpoint identity, quit/absence, restart clean submission plus changed boot. |
| K76 complete adoption, all callers/root, window blocks and signals | Still required, including worker supervision, status propagation and both held-pointer cases. No ordinary caller changes here. |
| K67 / k62 | Positive setup/title/liveness and later returns; exact shared focused prefix through TextEdit quit before resize and complete original-duty reconciliation remain. |
| K57 / k54 | Finite caller, private retention, collection/orphan ownership/exact containment; whole-harness review, readiness, actual signed/all-input/completed-golden freeze and runtime remain held. |
| Existing availability limits | Missing snapshot trees and omitted/empty AXValue distinction, OCR substring early stop and held-frame capture fallback remain. No new negative inference or retry. |
| Product/causal and historical obligations | One selection/one front-focused window and all complete ordinary assertions remain. Native cause, ownership and repair acceptance unresolved; all historical bytes, false joins, failed transports, NOT RUN phases, closed caps and six held causal slots unchanged. |

This completes the design's decision-needed boundary only. All ancestors remain
open; no release, notarization, upstream report or runtime result follows.
