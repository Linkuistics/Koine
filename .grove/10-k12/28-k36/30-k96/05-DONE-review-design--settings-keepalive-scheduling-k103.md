# settings-keepalive-scheduling-k103

**Reviews:** settings-keepalive-scheduling-k101


## Goal
Independently challenge the scheduling slice against the accepted ownership,
failure, timing and lifecycle contract before resource design consumes it.



## Context
Read the producer commit and current docs/specs/settings-keepalive-owner.md,
especially Scheduling and deadline profile. Read KEEPALIVE-SCHEDULING.md,
KEEPALIVE-DESIGN.md and KEEPALIVE-LIFECYCLE-REVIEW.md under
docs/verification/settings-activation, plus the complete k98/k96 charters.
K101 leaves resource enforcement and whole-design reconciliation to k102.
The reviewed lifecycle was not an implemented or numerically qualified owner.

## Done when
- Inspect the current design and producer diff independently. Challenge the
  receive-order fairness argument, one-outstanding cardinality, admission origins,
  phase arithmetic, queue/control precedence and both overlap directions.
- Challenge continuous-clock identity, delayed observation, process creation,
  caller supervision, normal stop/drain and failure containment. No timer may
  establish exit, released ownership, native liveness or successful late evidence.
- Check the result/publication joins and exact status preservation against k97/k100.
  Check failure before/after commitment and both held-pointer signal cases.
- Assess the illustrative usefulness claim without treating it as complete workload
  qualification. Enforceable resources, reservations, total-run capacity and finite
  collection remain k102 duties. Identify contradictions across current documents.
- Evaluate whether the specified controls can falsify the claimed guarantees at
  the stated seams. Copied-module internal barriers remain proposed pending agreement.
- Record supported findings with consequence and smallest useful correction.
  Cut integration only when earned, before the live resource-design sibling k102.
  Supply no fixes, runtime acceptance or whole-design approval in this review.

## Notes
Inspection only. No VM, candidate, freeze, cap expansion, native experiment,
production changes or ancestor closure. Keep all availability/privacy/history
limits and the original k89/k81/k76/k67/k62/k57/k54 obligations.
The producer had no inherited GROVE_PROVIDER_EVIDENCE. No Creator is inferred.

## Decisions (running log)

- 2026-10-30: Adopt the mandated review leaf in the clean jj workspace at
  e9045bf9. The working copy equals that commit for every reviewed path. Read
  the k101 commit and its whole diff. Read the current spec, the scheduling
  evidence, the design record and the lifecycle review record. Read the
  product-spec hold, the protocol rows on polls and restart, both unchanged
  views and the new view. Read the k97, k99, k100, k101 and k102 bodies. Read
  the root brief, the k53 to k98 briefs and the glossary. Scan the k12 to k36
  briefs for scheduling terms. Read the capture loop, the Allow helper, the
  backend, the legacy loop and the capture controls directly.
- 2026-10-30: Run no test, build, lint, format, VM or coordinator command on the
  artifact. Run only the prose checker on this file. Use no graph tool. Compare
  the clock claims with Apple's mach_continuous_time page and the macOS
  clock_gettime manual page. Compare them with the Python time documentation.
  Read the tagged CLI's vm command source for the start wait. Every conclusion
  below rests on those reads.
- 2026-10-30: This file already passes the prose checker, so no conversion
  commit precedes this edit. No in-session reviewer runs. This leaf is the
  adversarial read.
- 2026-10-30: The slice holds on receive order, one outstanding operation per
  producer, the clock choice and control precedence. It also holds on both
  overlap directions, drain, containment and both held-pointer cases. Three
  material gaps remain inside this slice. They are the admission margin
  arithmetic, the observer of the backend-internal phases and the caller's rule
  for a live unresponsive owner. Five narrower findings follow.
- 2026-10-30: P2-1, P2-2 and P2-3 need resolution before k102 consumes the
  profile. Insert the integration before k102, the first later sibling with
  live work. The cut is settings-keepalive-scheduling-k104 at position 03. K102
  moves to 04 with no content change. Its body carries this review's handle,
  not the findings. No Creator line applies, because this leaf finishes no
  producer. Retire this leaf only. K98 and k96 keep live work.

## Findings

Severity: P1 means the design would lead k102 or downstream work to violate an
inherited contract. P2 means a material omission or inconsistency inside this
slice that k102 must not consume as settled. P3 means a narrower precision, seam
or legibility defect. No finding below is a k102 resource or workload
obligation. Each one concerns the scheduling slice itself.

Line numbers refer to commit e9045bf9, which the working copy equals. "The
spec" is docs/specs/settings-keepalive-owner.md. "The evidence" is
docs/verification/settings-activation/KEEPALIVE-SCHEDULING.md. "The design" is
docs/verification/settings-activation/KEEPALIVE-DESIGN.md. "The protocol" is
docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md.

<!-- tc: depart synonym-rotation because vm-verify-lib.sh is a file name -->
"The README" is docs/design/architecture/settings-activation/README.md. "The
backend" is scripts/vm-guest-exec.py. "The legacy library" is
scripts/vm-verify-lib.sh. "Bats" is Tests/scripts/vm-capture-evidence.bats.

### P2-1. The admission margin is zero, not two seconds

The spec gives a request two seconds to reach the owner and two further seconds
for the owner to publish admission (spec :540-545). Selection and commitment
take two more seconds (spec :550-551). The spec then states that transfer,
admission and selection add at most six seconds to the longest holder. That
gives a 148-second path and two seconds of margin (spec :556-560, evidence
:90-93).

That path counts the tick's own three steps. It does not count the holder's
steps. The owner only needs to receive the holder before it receives the tick
(spec :523-528). A tick with origin O can arrive at O plus two. A scenario
request can arrive just before it.

The owner publishes that request's admission within two seconds. It commits the
request within two further seconds. Received, admitted and committed are
separate serial events (spec :150-159, :323). The holder can therefore commit
at O plus six and release at O plus 148. The tick's commitment then lands at O
plus 150. An observation at its deadline is expired (spec :576), so the margin
at the worst case is zero.

Consequence: the fairness argument's number is wrong at the exact boundary.
That boundary is what the control "Maximum valid holder, then another request"
must exercise (evidence :119). A control built from 148 cannot reach the real
worst case.

State the holder's post-origin receipt, admission and commitment in the path.
Then either raise the admission budget by the two-second holder-receipt window,
or state that an idle owner shares one two-second window for admission and
commitment. Recompute the path either way. Record the chosen arithmetic in the
verification receipt.

### P2-2. The backend-internal phases have no named observer, clock or channel

The spec makes the owner's processing time the authority. An observation
processed at or after its deadline is expired, and an earlier sender timestamp
cannot rescue it (spec :575-577). The phase table gives the CLI phase its family
allowance and validation ten seconds (spec :606-611). The CLI allowance starts
when child creation is observed (spec :586).

Those two phases run inside the backend child. The retained backend runs the
CLI with a blocking call and writes `cli.exit` with no time. It then runs the
response and image checks and only then emits a payload (backend :331-359). It
sends no intermediate frame. Under the owner, the first owner observation after backend
creation is that emission, up to 42 seconds after a 30-second CLI.

Read literally, the owner processes the CLI-exit observation after the CLI
deadline, and every clean capture expires. Read the other way, the child's own
stamps bound those phases. The child stamps with `monotonic_ns`, which the spec
forbids as a comparison source (spec :571-572, backend :282, :383). The spec
also says "child creation" where the row names backend or CLI creation (spec
:586, :608). The backend creates the CLI, so the owner cannot observe CLI
creation at all.

Consequence: the CLI and validation ceilings cannot be enforced as written. The
control row "Every message, admission, phase and whole deadline" (evidence
:117) has no defined observer for those rows.

State which process observes each phase boundary, in which clock, and through
which frame or file. If the child stamps them, require the declared continuous
clock in the private backend. Then say that the owner's processing rule applies
only to frames the owner receives. If the owner observes them, add the frame or
file the child must publish at each boundary. Give that frame its own
two-second limit. Say which creation starts the CLI allowance.

### P2-3. The caller has no rule for a live owner that misses a deadline

The caller independently watches advertised absolute deadlines. It receives each
transition within two seconds. Lost progress or an unresponsive owner closes
caller eligibility (spec :581-584). Containment then names only owner loss. The
caller applies the policy to its owned children after owner loss (spec
:667-668). It resolves children it can positively identify when the owner dies
(spec :402-411).

An owner that is alive, holds the writer and misses a deadline is neither dead
nor progressing. The spec does not say that a missed advertised deadline is
owner loss. It does not say that the caller then applies the twenty-second
policy to the owner process, its direct child. Nor does it say so for the
children the owner reported (spec :95-98). It does not bound the caller's wait. The sentence
"No unconditional blocking wait follows timeout" sits inside the owner's
containment paragraph (spec :669).

Consequence: the final trust boundary depends on the caller, and the caller can
wait without bound on a hung owner. The control "Owner loss while its child
retains writer" (evidence :123) covers death only. State that a missed
advertised deadline plus the two-second report limit is owner failure for the
caller. State that the caller then contains the owner and its reported children
under the same twenty-second policy, once. Bound the caller's wait, or hand that
bound to k102 as an explicit input.

### P3-1. The normal-stop derivation cites a holder that cannot exist at finish

The spec allows a committed operation at finish up to 142 seconds, then adds
three two-second steps to reach 148 (spec :644-649). The verification receipt
records that number. Only normal completion with no outstanding scenario
submission can request normal stop (spec :63, :301-305). The only possible
holder at finish is a tick capture of at most 52 seconds (spec :61, :591). A
worker in its sleep adds at most 24 seconds (spec :636-639). The reachable
drain is 58 seconds from a capture, or 30 seconds from a sleep.

Consequence: the 150-second bound is safe but loosely justified, and the
receipt records an unreachable path. State the reachable bound, or state that
150 is a shared outer bound chosen for symmetry with admission.

### P3-2. The deadline controls need a clock enabling point that no seam names

The control matrix requires equality and just-after observations to fail. It
also requires a host clock that jumps forward across a deadline while wall time
moves backward (evidence :117-118). The agreed seam controls the CLI through
PATH and sleep through a shell function (Bats :34-39, :103-106). The proposed
internal barriers are test-only barriers in a copied owner module (spec
:455-468). None of these reaches the owner's clock read.

A real continuous clock cannot be made to jump in a test. A slow CLI cannot hit
equality in integer nanoseconds. A 142-second holder control runs for minutes in
real time.

Consequence: two matrix rows are unqualifiable at the stated seams, and the
others are slow. Name a clock enabling point. The cheapest form is a
substitutable clock reader in the same copied owner module the barriers use,
which adds no seam count. State which rows it serves. Because it departs from
the agreed CLI and sleep controls, carry it to the same human seam decision that
k100 handed to k98.

### P3-3. The local failure record is both an operation and a control

The family table lists a local poll or failure record with no CLI and a
22-second whole-operation allowance that starts at commitment (spec :586-587,
:595). The interface says a local failure report is a control that is not queued
behind command admission (spec :62). Failure controls precede selection, and a
failure known before commitment prevents it (spec :529-530, :168). The retained
backend records a failed sleep as an evidence-class attempt with an ordinal
(backend :561-570, :246-247).

Consequence: the record's budget origin contradicts the control's precedence
unless the record is an evidence-class operation that the owner itself commits
after closing eligibility. State who submits that record and that it is
evidence class. State that its 22 seconds start at the failure observation.

### P3-4. The family bounds are not inventoried against the existing waits and the known workload

The evidence cites the Allow OCR timeout of 30 and the guest exec timeout of 30
(evidence :27-28, design :80). The lifecycle family also covers `vm start`,
which the backend admits (backend :174-175, :204-206). The scenario starts it
with `--wait` and no stated bound (legacy library :318). The tagged CLI passes
`--wait` through as a duration and states no maximum. The transfer family
covers the bundle upload, whose size the evidence does not name (legacy library
:337-341). The evidence does not say whether `vm start` runs under the owner or
before it.

The legacy library also records the fact the usefulness section needs. The
keepalive starts before those uploads (legacy library :327-331). The VZ
assertion follows about 60 seconds without a VNC client (legacy library
:321-326). Transfers use the agent connection, not VNC (design :81). A deferred
tick behind a 142-second transfer therefore reproduces the condition the
keepalive exists to prevent. The evidence states the general caution (evidence
:97-102) but not this concrete case.

Consequence: k102 inherits the family numbers without the list of waits they
must cover, and without the first workload case that already exceeds the
observation. Add a table of each admitted command, its CLI-internal wait where
known, its family and the source line. Mark `vm start --wait` and the upload as
unbounded in the cited source. State whether the owner runs `vm start`. Name the
upload-during-keepalive schedule as the first case k102 must reconcile.

### P3-5. Rationale, vocabulary and two captions lag the profile

The rejected arbitration alternatives, scenario priority and tick priority,
appear only in the evidence (evidence :68-72). The spec's own "Decisions and
excluded alternatives" section does not mention them (spec :500-512). K99's
P3-4 made the same point for the lifecycle slice, and k100 graded it real. The
profile coins admission clock, operation family, phase ceiling and containment
window. The glossary holds k100's lifecycle terms and none of these.

The README says ownership continues through validation and publication (README
:5-6). The spec continues it through completion-frame delivery (spec :617-619).
The lifecycle view's note on the drained capture still says the
numerical profile remains design work. Its caption now says the scheduling
proposal supplies the deadlines.

Consequence: a reader of the spec alone cannot see why receive order was
chosen, and the terms drift. Add the two rejected policies to the spec's
decisions section with their reason. Add the four terms to the glossary. Align
the README sentence and the lifecycle note with the profile.

### Supported items

These claims hold against the source, the agreed scope and the k97 and k100
contract. They need no correction.

- Receive order with one outstanding operation per producer bounds any wait to
  one holder, and the tie-break is deterministic (spec :523-538).
- Controls precede selection, and the owner drains them again before
  commitment. An expired deadline beats a late success (spec :529-532).
- The spec and the matrix cover both overlap directions (spec :472-473,
  evidence :114-115).
- The continuous clock choice holds. Apple documents mach_continuous_time
  as incrementing during system sleep and names
  clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW) as its equivalent. Python documents
  monotonic on macOS as mach_absolute_time (evidence :38-47). A host sleep during
  the worker's sleep therefore ends the run. That is a visible choice, consistent
  with the clock-jump control.
- The phase arithmetic holds: 22 seconds outside the CLI and whole bounds of
  52, 67 and 142. The sleep, containment and final-handoff bounds of 24, 20 and
  8 seconds also add up.
- The result protocol order matches k100. Streams, receipt, validation and
  backend exit precede the offer. Acknowledgement, terminal publication and the
  completion frame follow (spec :198-216, :611-615).
- Raw statuses survive beside owner status 125 (spec :695-697).
- No timer establishes exit, released ownership, native liveness or successful
  late evidence (spec :576, :619-620, :662-672).
- Both held-pointer cases and the no-release rule remain (spec :426-431,
  evidence :125).
- No wall-clock bounded loop appears in the menu-bar scenario or its shared
  library. Ownership delays therefore change elapsed time without reducing poll
  counts (protocol :234, :253).
- The three illustrative schedules are arithmetically consistent. The
  usefulness claim is narrow and honest about the sixty-second observation.
- The new scheduling view corresponds to the profile, and the owner view's new
  cardinality matches the spec.
- No decision earns an ADR yet. The choices remain reversible before
  implementation, as k97 and k100 concluded.
