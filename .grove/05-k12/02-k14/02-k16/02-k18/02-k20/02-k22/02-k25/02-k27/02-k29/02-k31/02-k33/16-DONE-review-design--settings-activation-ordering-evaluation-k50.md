# settings-activation-ordering-evaluation-k50

**Reviews:** settings-activation-ordering-evaluation-k49

<!-- tc: off because the Goal, Context, Done when and Notes are the producer-authored charter, kept verbatim as the task contract -->

## Goal

Independently challenge the concrete single-request ordering design and its
finite empirical acceptance rules before any implementation or runtime.



## Context

Read the producer's committed artifact by its stable handle, k46's explicit
"approve" and the current docs/specs/settings-activation-discrimination.md.
The concrete protocol and bounded source/API evidence are
docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md and
ORDERING-DESIGN-EVIDENCE.md. The presentation is under
docs/design/architecture/settings-activation. The verification receipt retains
two existing archived-context link failures owned by k23; they are not new design
findings. The producer used bounded exact source reads because graph startup
refused before project/generation discovery. It supplies no graph coverage.

K46 permits the named empirical hypothesis without a documented API-use
violation. It does not establish comparative improvement, native mechanism,
ownership or general reliability. The reviewed old no-candidate assessment and
closed traced ABBA sample remain unchanged. Both orders succeeded with tracing;
the reversal also moved synchronous writes. There is no instrument-free
comparison. The six causal slots remain held and unstarted.

The proposal reverses calls inside the existing shared show owner after readiness,
window preparation and navigation. It specifies one new ordinary signed subject,
two focused fresh guests and then three separate complete ordinary guests using
the identical candidate with diagnostics disabled throughout. No source change,
build, candidate or guest ran in the producer. K36 remains live and held after
this review and every earned integration.

## Done when

- Derive the design's requirements from the actual k42/k46 amendments and original
  duties. Check the entire design, current handoffs and presentation for weaker
  obligations, accidental runtime authority or a claim beyond the agreed sample.
- Verify API applicability and the local reversal's effects on launch, reopen,
  both menu callers, retained window identity, readiness and already-active
  behavior. Check that returning from activate is not treated as completed
  activation and no second request, deferral, yielding or driver workaround enters.
- Challenge the single-arm two-focused/three-ordinary convention, exact subject
  and matched setup, slot consumption, admission, first-failure stops and
  outcome precedence. A qualified recurrence must reject reversal; missing
  required evidence or another ordinary failure must prevent acceptance. No
  replacement, cap expansion or hidden baseline is available.
- Examine route-qualified behavioral recurrence versus actual callback/native
  provenance. Could the chosen raw window results, menu closure and screenshots
  falsely accept or reject? Inspect how failed transport hidden by guest_once/
  guest_text remains unavailable, including setup and restart, without turning
  clean negative polls into product failure or allowing a later read to erase a
  failure. The intended correction is evidence handling, not a focus repair.
- Check the explicit seam choice and its limits: historical real product failures
  instead of an invented deterministic OS fake, useful helper controls, actual
  complete ordinary assertions, diagnostics disabled and no native logging probe.
  Pay particular attention to availability qualification, new capture workload,
  unknown symptom preservation on green, and whether the design relies only on
  the finite standard Antony accepted without waiving an original evidence duty.
- Check actual signed/all-input/completed-golden freeze, original/endpoint/golden
  audits, failed/partial/NOT RUN retention, exact stop and unchanged historical
  caps/causal protocol. Record findings with concrete consequences and smallest
  useful corrections; no source repair or guest belongs to this review.
- If actionable findings earn an integration, insert it where it runs next,
  before settings-modality-disposition-repair-k36. Every earned integration must
  finish before implementation/runtime. Do not materialize an in-session reviewer
  or cut speculative implementation work. A clean review does not itself create
  a runtime result or close a product/causal ancestor.

## Notes

No current provider-evidence receipt was present in the finishing producer's
environment, so no Creator line is supplied. Do not infer a provider or import
legacy evidence. Owner policy may require an explicit declaration independently
of this artifact's inspection.

<!-- tc: on -->

## Decisions (running log)

- 2026-10-29: Adopt the mandated review-design leaf on empty jj change
  vyxoxrzv, parent e3194ff8, the k49 producer commit. Read the brief chain,
  the glossary and the k42, k45, k46, k47, k48 and k49 task files. Read the
  contract, the protocol, the design evidence and the presentation. Read the
  historical order, correction and causal records. The graph server failed to
  connect in this session. Read the application source, scenario and helper
  scripts directly. Claim no graph coverage. Run no test, build, lint, guest,
  product change or in-session reviewer.
- 2026-10-29: Re-read the six cited Apple pages over HTTPS and digest the
  installed SDK activation header. Every digest matches the producer's receipt.
  The header states that the app need not be active after the call returns
  and may not be activated at all. The disabled trace, interval wrapper and
  menu probe create no observer, timer, output or tick read. The nine
  preserved historical inputs and the causal protocol suffix match the parent.
- 2026-10-29: One P1 finding and one P2 finding bear on whether k36 can
  implement the evidence rules as the plan states them. Three P3 findings
  concern clarity, classification and the glossary. They earn an integration.
  Insert one integrate-review-design leaf before
  settings-modality-disposition-repair-k36, the first live sibling after this
  review. This session finishes no producer and has no provider evidence, so
  it writes no Creator line.

## Findings

Severity: P1 means k36 would have to choose an evidence rule that the accepted
convention reserves to the reviewed design. It also covers a design that cannot
run as written. P2 means a defect or ambiguity that integration must settle
before k36 implements. P3 means a clarity, completeness or retention gap.

Line numbers refer to commit e3194ff8. "The plan" is
`docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`. "The
contract" is `docs/specs/settings-activation-discrimination.md`. "The scenario"
is `scripts/vm-verify-menu-bar.sh`. "The helpers" is `scripts/vm-verify-lib.sh`.

### P1-1. The transport rule collides with the helper every guest command runs on

The plan requires the finite caller to retain every attempt's raw envelope,
including those the helpers hide (plan:151-154). It then requires required
failed, timeout or incomplete transport to latch an unavailable outcome and
stop the scenario before a retry (plan:155-156). It also requires the
extracted prefix to keep the frozen scenario's commands, waits and predicates
(plan:81-82). Each A slot must run the complete existing entry point
(plan:269).

Every guest command in the scenario runs through `guest` (helpers:49-68). That
helper retries up to twelve times when the agent reports a false timeout with
status 255, and sleeps and retries on status 7. Its own comment records that
about half of all execs complete and are then reported as timed out
(helpers:43-48). The endpoint wait, every System Events read, the menu open,
the item click and the installed inventory all go through it. The design
evidence names this path and states that it cannot establish clean evidence.
The plan does not state what replaces it.

Three one-shot commands have no declared transport class. First launch and
silent launch use `guest_once` (scenario:87, 248, 256). Its envelope is
discarded, and a false timeout can follow a launch that happened. The restart
runs the shutdown command through a bare exec and discards the result
(scenario:268-277). The plan states that an unconfirmed restart transport
stays unavailable even if a later boot appears (plan:163-164). The guest goes
down during that exec, so a clean envelope may never exist.

`await_windows` (helpers:422-430) treats an empty answer from a failed agent
call as a wrong count and keeps polling. At its bound it fails as a state
failure. The plan forbids that confusion (plan:157-159) without stating that
the helper changes.

Consequence: read literally, the stop-before-retry rule ends almost every slot
at its first false timeout, so no slot can pass. Read loosely, the existing
retry stands everywhere and the rule binds nothing. Under either reading k36
chooses the evidence standard at implementation time, which the plan forbids
as a runtime exception (plan:165). Every A slot can also end as unresolved at
its restart.

Smallest correction: declare three transport classes in the plan before
freeze. For idempotent reads and state polls, the existing retry stands with
its existing bound. The caller retains every try's raw envelope and the try
count. For one-shot commands, declare the expected envelope classes per
command. Those commands are launch, silent launch, menu click, defaults write
and restart. Name each command's downstream positive confirmation: endpoint
descriptor, window count or boot-time change.

For required evidence transports (window lists, screenshots,
inventories, failure observer, environment reads, stop), the first failed,
timeout or incomplete envelope latches unavailable with no retry. State that
`await_windows` and `koine_in_front` must separate a failed read from a
negative count. State that the extracted prefix and the complete scenario
carry the same changed helpers.

### P2-1. The positive TextEdit precondition is a predicate the frozen scenario does not have

Before each of the four selections, the plan requires zero Koine windows. It
requires TextEdit in front with its same idle untitled document and no dialog,
sheet or menu. It requires that positive precondition to be recorded, and it calls an
unexpected state failed setup (plan:86-91).

Before the first selection the scenario checks only that Koine is not in front
and echoes the front process name (scenario:126-127). The reopen loop closes
the window, awaits zero windows, chooses the item and awaits one window
(scenario:137-143). It has no positive TextEdit-front check, no document
check and no dialog check.

The plan requires the prefix to keep the frozen scenario's predicates, apart
from evidence retention and its termination (plan:81-83). It requires the A
slots to run the complete existing scenario (plan:269). Retaining all existing assertions (plan:77) permits additions, but
the plan never states that the scenario script changes. It names no oracle for
the idle document or for the absence of a dialog, sheet or menu. The prefix
ends before resize (plan:83), and the scenario quits TextEdit between the
reopen loop and resize (scenario:144). The plan does not state whether the
prefix includes that quit.

Consequence: if k36 adds the check to the prefix only, E and A differ in
predicates. A mismatched setup is then failed setup in E and a measured
selection in A. If k36 adds it to the scenario, the frozen complete scenario
is a changed script, and the plan should state so. If k36 records the state
without asserting it, failed setup has no effect. Each choice moves a
TextEdit-front mismatch to a different outcome row.

Smallest correction: state that the precondition record and the raw window
retention are changes to the scenario script and helpers. State that they
apply identically to the extracted prefix and the complete scenario, and that
the changed script is the frozen one.

Name the oracle for each precondition fact. The agent window list can supply TextEdit's window and title. System
Events can supply the frontmost process. State what counts as a dialog. State
whether the prefix ends before or after the TextEdit quit.

### P3-1. The plan describes the existing front predicate as stronger than it is

The plan states that the first window outside `Notification Center` must be
the sole visible Koine Settings window with focused true (plan:116-118). It
adds that retaining the list stops an unrelated Koine window from satisfying
the predicate (plan:118-119). `koine_in_front` (helpers:439-441) checks only
that the first window outside `Notification Center` belongs to Koine and has
focused true. Sole-ness
comes from `await_windows 1`, which counts Koine windows of any title. No
title check runs at a reopen.

The plan requires a corroborating screenshot for
rejection (plan:130-134). Acceptance rests on the agent list alone. The
caller retains the screenshot and checks nothing in it.

Consequence: a reader believes a title check exists, and an implementer who
trusts the plan adds none. A pass means the agent list predicate passed and
the caller retained a screenshot.

Smallest correction: describe the existing predicate exactly. State whether
the retained unfiltered list is audited for the Settings title after the slot.
State that the outcome screenshot is retained evidence, not an acceptance
assertion.

### P3-2. A zero-window result does not separate a lost process from a failed reopen

The plan counts zero windows after the existing bound as a qualified
recurrence when the click was clean and the menu closed (plan:130-134). Quit
Koine is the item directly below Settings. A click from a stale frame reaches
it, closes the menu and leaves zero windows. A crash on reopen leaves the same
state. The route evidence the plan names cannot separate these from a window
that never appeared.

The plan records a failure of another required assertion
under that assertion, not as a Settings recurrence (plan:142-144). It names
no assertion for a lost process.

Consequence: a driver misclick or a crash rejects reversal as the repair.

Smallest correction: for the zero-window branch, require one process liveness
read in the post-failure capture, through the existing process or endpoint
check. Classify a dead process under its own assertion.

### P3-3. The design's load-bearing terms are not in the glossary

The plan defines "qualified recurrence" (plan:130-139), "focused evaluation"
and "ordinary acceptance" (plan:32-33). The contract, the briefs, the k36 leaf
and the presentation use all three. `CONTEXT.md` has no entry for any of them.

Consequence: k36, its review and its integration each re-derive the terms
from the plan. The distinction between a qualified recurrence and another
failed assertion is the one the outcome table rests on.

Smallest correction: add three glossary entries of one or two sentences each,
pointing to the plan for the full criteria.

### Checked without a finding

- The reversal's effect on each caller matches the source. Launch after
  readiness, Finder reopen and both menu actions reach the one show method.
  The readiness guard returns before either request. Window identity,
  lifetime, size, level and move-to-active-Space behaviour are unchanged. The
  fatal-alert activation is a separate terminating path (AppDelegate.swift:52-58,
  89-92, 110-137, 139-148 and MenuBarController.swift:74-82).
- The contract does not treat the activate return as completion. It adds no
  second request, deferral, yield, isActive condition or driver workaround
  (contract:49-65). The already-active row matches the SDK declaration and the
  live page.
- The six Apple pages fetched today return the receipt's digests, and the
  installed header digest matches. API applicability holds at the declared
  deployment floor.
- Diagnostics disabled: with both defaults absent, the trace initialiser
  returns before it installs observers, and `record` returns without reading
  windows. The interval wrapper runs the operation once with no tick reads.
  The probe creates no timer or monitor. The product keeps those branches, as the plan
  states.
- The convention is single-arm. There is no baseline, no ABBA repeat and no
  qualification-only guest. Slot consumption precedes the clone request. Admission
  to E02 and to A01 requires the preceding slot's audit and exact stop. The
  outcome table gives rejection precedence over a later evidence failure and
  keeps unavailable distinct from product failure. No row permits replacement,
  expansion or retry.
- No new seam or fake is earned, for the reason the contract gives: a fake
  would be the hypothesis's own oracle. The show method has no enabling point.
  Historical VM failures remain the failing product evidence. Helper checks
  exercise transport and classification only.
- Freeze, audits and exact stop: all consumed inputs and golden digests
  complete before the first clone request. A separate ordinary readiness
  receipt precedes A01. The caller audits both installed endpoints, and the
  handler stops only the exact clone.
- The nine preserved historical inputs and the causal protocol from its
  implemented section onward match the parent. The producer's changed-file
  list holds only task, documentation, presentation and verification files.
  The six causal slots stay held.
- The summary layers agree with the plan and claim nothing beyond the declared
  sample. Those layers are the root brief, the k33 brief, the k36 leaf, the
  verification README, `menu-bar-vm.md` and the presentation.
<!-- tc: depart synonym-rotation because "Start here" is the presentation's node label -->
- Each graph has one dark Start here node, and the sequence's note states that
  a return does not establish active state.
- No ADR is due. The ordering choice is reversible, and no ADR is cited or
  changed.
- K49 wrote no Creator line, and this leaf carries none.
