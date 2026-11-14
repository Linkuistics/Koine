# settings-keepalive-lifecycle-k99

**Reviews:** settings-keepalive-lifecycle-k97

## Goal
Inspect the proposed owner and worker lifecycle independently against the agreed
keepalive scope and the full k96 contract. Report material findings without fixes.

## Context
Read the producer's committed diff and docs/specs/settings-keepalive-owner.md.
Read KEEPALIVE-DESIGN.md and ORDERING-EVALUATION-PLAN.md under
docs/verification/settings-activation. Read the binding product-spec hold and the
editable owner and lifecycle views.

K97 is the first design slice of k96. K98 owns
numerical scheduling and deadline policy and enforceable resource completion. No
coordinator is implemented, resource-qualified or adopted. The producer's coverage
and link receipts are evidence with stated limits, not concurrency proofs.

## Done when
- Read the artifact independently against the actual k93 scope and the original
  duties. Challenge whether one owner can process failure or stop while children
  hold the dispatch domain. Challenge whether the owner checks eligibility at
  actual dispatch.
- Inspect the distinction between submission, commitment and actual launch.
  Inspect the stop races before and after each boundary. Inspect the validation,
  delivery and publication order. Decide whether cancellation or a later clean
  result can conceal a required failure.
- Challenge exact worker and owner identity and the acknowledgement, exit and reap
  joins. Challenge the final publication and receiver limits, prior latches and
  signals. Challenge inherited or orphan holders, collection-only takeover and
  both held-pointer cases. Find assumptions that allow false normal completion,
  later input or unproved containment.
- Check that the agreed sleep20 semantics, the untouched collection order, the
  originals, the private roots and every downstream duty survive. Review the
  test-seam and control discrimination. Review the correspondence of the diagrams
  to the spec.
- Distinguish an explicit k98 numerical or resource obligation from an
  inconsistency that already breaks this lifecycle slice. Do not accept the
  complete coordinator or select limits merely because its abstract profile
  inputs are mandatory.
- Report findings with source locations and consequences, or state that none is
  supported. If findings warrant integration, cut it before k98 with this review's
  handle. Do not transcribe the findings as its charter. Spend no competing
  in-session reviewer.

## Notes
Inspection only. Whole-design review still follows the completed profile, before
planning, implementation and earned review and integration. K89, k81 and k76
consumption, readiness, freeze, runtime and every E/A slot remain held. All
ancestors stay open.

## Decisions (running log)

- 2026-10-30: Adopt the mandated review leaf in the clean jj workspace at
  aa600318. Read the k97 commit and its whole diff. The working tree equals that
  commit for every reviewed path. Read the spec, the design record, the protocol
  and the product-spec hold. Read both new views, the k93, k94, k95, k96 and k98
  bodies, the brief chain and the glossary. Read the backend, the capture library, the
  legacy loop and the capture controls directly.
- 2026-10-30: Run no test, build, lint, format or VM command on the artifact.
  Use no graph tool. Every conclusion below rests on direct reads.
- 2026-10-30: Convert the inherited charter text of this file to controlled
  English as its own change first. Its meaning is unchanged.
- 2026-10-30: The slice holds against the agreed scope on ownership, first
  failure, cancellation without ordinals, the stop join, signals, holders and
  both held-pointer cases. Two material gaps remain inside this slice, not in
  k98: the worker's blocking contract and the commitment record. Four narrower
  findings follow.
- 2026-10-30: P2-1 and P2-2 need resolution before k98 consumes the contract.
  Insert the integration before k98, the first later sibling with live work.
  Spend no in-session reviewer. This leaf is the adversarial read.
- 2026-10-30: The cut is settings-keepalive-lifecycle-k100 at position 03. K98
  moves to 04 with no content change. Its body carries the review handle, not
  the findings. No Creator line applies, because this leaf finishes no producer.
  Retire this leaf only. The parent k96 keeps live work.

## Findings

Severity: P1 means the design would lead k98 or downstream work to violate an
inherited contract. P2 means a material omission or inconsistency inside this
slice that k98 must not consume as settled. P3 means a narrower precision, seam
or legibility defect. No finding below is a k98 numerical or resource
obligation. Each one concerns the lifecycle slice itself.

Line numbers refer to commit aa600318. "The spec" is
docs/specs/settings-keepalive-owner.md. "The design" is
docs/verification/settings-activation/KEEPALIVE-DESIGN.md. "The backend" is
scripts/vm-guest-exec.py. "The library" is scripts/vm-capture-evidence-lib.sh.
"Bats" is Tests/scripts/vm-capture-evidence.bats.

### P2-1. The worker's blocking contract and phase set are implied, never stated

The spec bounds pending work to one scenario submission and one tick (spec :44,
:49). An excess submission closes eligibility (spec :51-52). The worker keeps
the existing sleep-20-then-one-capture schedule (spec :136). The owner delivers
each tick's result to the worker (spec :148-149, :163, :189). No sentence says
that the worker waits for that result before its next sleep.

The current loop blocks: `sleep 20`, then one capture that returns after
publication (library :29-42). The design states that the 20-second sleep runs after
the preceding capture completes (design :37-38). Under the owner, a tick can wait
behind a 30-second OCR hold (spec :273). If the worker sleeps again after
submitting, its second tick becomes due while the first is still pending. The
owner then closes eligibility for an excess submission. An ordinary admitted
delay would fail the run.

<!-- tc: depart semicolon because the semicolon is inside a quoted table-row label -->
The spec names a "worker phase" in three records (spec :131, :188, :189) and
never enumerates the phases. The stop table separates "Sleeping" from "Sleep
returned; tick message not admitted" and from "Tick pending" (spec :156-158).
Those rows only make sense if the worker is not sleeping while a tick is pending.

Consequence: the pending bound, the retained sleep-20 meaning and the stop table
all depend on an unstated rule. State that the worker submits one tick and waits
for its terminal result or its cancellation disposition. State that the next
sleep follows only then. Enumerate the worker phases that the records name.
This is a lifecycle rule, not a k98 number.

### P2-2. The commitment record has no fields and no writer, and ordinal assignment conflicts with the retained backend

The spec makes dispatch commitment the serialised ordering point against stop.
The owner assigns the ordinal and records an intent to execute once (spec
:91-95). The owner is the only process that assigns attempt ordinals or
publishes normal receipts (spec :33-34). The lifecycle record table has no row
for commitment or for the terminal result (spec :184-191). The submission
disposition carries an attempt ordinal that is null until commitment (spec :187),
yet every event is immutable (spec :179). Either the disposition changes in
place, or a second record links submission to ordinal, and the spec specifies
neither.

The retained backend allocates the ordinal itself by scanning the root (backend
:233-235, :260). It writes request.json after it creates the attempt directory
(backend :263-306). The spec keeps that backend as the owned child through a
private entry point for the already-held lock (spec :77-78). Tests exercise the
real receipt code once implemented (spec :265). Nothing says that the private
entry point accepts a pre-assigned ordinal, or that the owner writes a durable
commitment record before the child process exists. With two allocators, a crash between
the owner's decision and the child's scan leaves two next ordinals.

Several required facts have no named record. One is the launch state
`not-started`, `started` or `unknown` (spec :94). Another is the child identity
that the caller needs to identify a holder after owner death (spec :229-230).
A third is the result-receipt time (spec :326-328). Output delivery acknowledgement closes
eligibility when missing (spec :120-122) and has no record or operation either.
"Delivery" names two hops: the backend's stdout emission to its parent (backend
:351-359) and the owner's result to the submitter.

Consequence: the ordering point that the stop table rests on cannot be recorded
as specified, and k98 would inherit an unresolved writer and schema. Specify the
fields and the writer of the commitment and terminal records. Decide whether the
private entry point takes the ordinal, the submission ID and the stop ID as
arguments. Name the acknowledgement that delivery requires and where it lives.

### P3-1. Eligibility and receipts have two writers in the retained source

The spec says the owner alone changes eligibility and publishes normal receipts
(spec :33-34). The backend writes the `unavailable` latch on refusal and on a
prior non-clean or unfinished attempt (backend :66-71, :243, :245). It also
writes it on a failed confirmation and on any reason (backend :325, :368). It
writes result.json itself (backend :369-385). After a latch, evidence-class commands still dispatch (backend
:246-247).

Under one active operation this is safe. The child's latch is complete before
the owner's next commitment check. But the sentence is false for the retained
backend. The owner's eligibility check must read the latch file or the child's
exit before each commitment. The spec should say that the owner's closed state
and the child-written latch together form eligibility. It should say that the
owner authorises while the child writes under the owner's lock.

### P3-2. Process topology and client identity are unspecified

The spec names direct children, tokens and recorded incarnations (spec :56-63).
It names process groups only for termination (spec :222-223). It does not say
whether the owner, worker, backend and CLI share the caller's foreground process
group. A terminal INT, TERM or HUP then reaches all of them at once.

The `sleep` returns 129, 130 or 143. The backend records `interrupted` and re-raises SIGINT
(backend :348-350, :388-390). The CLI dies, and the owner receives the same
signal.

The first-failure cause (spec :124-125) and each child's wait status depend on
which event arrives first. Bats sends SIGINT to the whole group (Bats :344).
The worker's behaviour on parent loss is also unstated. A worker in `sleep`
after owner death holds no writer (spec :61-62). It is an unowned grandchild
that the caller cannot reap. The spec should say that it exits on a broken
parent channel.

Scenario submissions carry a submission ID and a caller sequence (spec :43) but
no sender credential. An unknown sender closes eligibility (spec :51). The
worker has a token (spec :57). Define the scenario client's identity, or limit
the unknown-sender rule to the worker channel.

### P3-3. The control matrix needs enabling points that the agreed seam text does not name

K93 agreed the existing helper/adapter seam, with controlled CLI and sleep
behaviour (design :329-339). Bats controls the CLI through PATH (Bats :30-39)
and sleep through a shell function in the test process (Bats :103, :379, :396,
:424). It also patches a test-only barrier into a copied validator module (Bats
:272-283).

The spec says that phase barriers are test controls (spec :266). It requires
controls immediately before and immediately after commitment (spec :275) and
mutants that yield between the eligibility check and launch (spec :101-103,
:286-289). A CLI or sleep control cannot produce an event inside the owner's
control loop. A shell-function sleep override does not reach a worker that the
owner runs as a separate process. The copied-module patch is a third control
that the project already uses, and the spec does not name it.

State which stop-table rows the CLI and sleep controls reach, and which rows
need an owner-internal enabling point. Name that point. If it departs from the
k93 seam agreement, it is a human check, not an implementation detail.

### P3-4. Rationale sits under the wrong heading, and the new vocabulary is unrecorded

The section "Remaining profile" opens with the owner's justification, the
rejected separate lifecycle writer and the rejected signal-the-sleeper choice
(spec :295-304). SPEC-FORMAT places settled calls under Decisions and rejected
alternatives under Out of scope. A reader who asks why normal stop does not
signal the worker will not look under "Remaining profile".

The spec coins command owner, keepalive worker, tick, dispatch commitment,
lifecycle record, stop ID and collection-only generation. CONTEXT.md has none of
them. CONTEXT-FORMAT records a term when it is resolved, not at the end. The
spec's own usage wavers. It says "entered dispatch" (spec :13-14) against
"commitment" everywhere else, and "delivery" for two hops (P2-2). Add the terms,
or state in the glossary that they await the whole design.

### Supported items

These claims hold against the source and the agreed scope and need no
correction. The slice preserves one writer and ordinal domain, complete capture
qualification before later dispatch and first-failure eligibility (spec :36-38,
:85-86, :124-125). Cancellation of unstarted work allocates no ordinal (spec
:111, :145). Committed work drains through its original deadline and is never
relabelled (spec :146-151). The stop join requires intent, acknowledgement,
observed exit and published reap, and exit zero alone proves nothing (spec
:193-199). Normal stop sends no signal and does not shorten sleep 20 (spec
:136-139, :215).

Signals keep their numbers, and 129, 130 and 143 are HUP, INT and TERM (spec
:116-118). Inherited descriptors and unknown holders block collection and later
slots (spec :220-227, :234-235). Collection-only takeover never resumes scenario
input (spec :229-236). Evidence-class collection after a latch matches the
backend (backend :246-247). The untouched observer, window list and screenshot
order matches the design (spec :238-240, design :210-212). Both held-pointer
cases and the no-release rule are present (spec :249-253).

Unavailable transport status 125 matches the backend's general unavailable
status (backend :23). The two views correspond to the spec. The lifecycle view's
"Cancel unstarted tick" state also covers a worker that was only sleeping, where
no submission exists to cancel. That is a loose label, not a contradiction. The
owner view merges normal end and signal into one stop node, while the lifecycle
view separates Closed from Failed.

No ADR is earned yet. The choices are not hard to reverse before implementation,
and the whole-design review is the right time to retest them. The product-spec
hold and the protocol carry pointers, not restatements. The spec is not in
controlled English: 49 lines carry semicolons. The integration must convert it
as a preparatory commit before it edits the spec.
