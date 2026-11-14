# settings-keepalive-coordination-k94

**Reviews:** settings-keepalive-coordination-k92

## Goal
Independently inspect the producer's design against its original charter and
inherited contracts. Produce findings, not fixes or implementation.

## Context
Find the producer commit by its stable handle. Read its diff against current
source, docs/verification/settings-activation/KEEPALIVE-DESIGN.md, the current
capture/shared/physical/click reports, ORDERING-EVALUATION-PLAN.md, the spec and
editable settings-activation views. Read k92's original Done when, k85/k80/k75/
k71/k66 charters and the retained source/control receipts. No native guest,
candidate, freeze or acceptance occurred in this producer.

## Done when
- Challenge how the design treats the original obligations. Decide whether the
  design missed a compliant coordination route. Decide whether escalation to
  the proposed scope decision is justified. Re-derive the overlap cases from
  current source and controls. Distinguish a possible schedule, native command
  behaviour, a measured collision rate and any claimed impossibility.
- Inspect ownership, admission, first-failure ordering and planned cancellation
  versus failed required work. Inspect partial and local-signal records,
  orphan-held locks, untouched collection and exact VM containment. Include
  both held-pointer cases, no later input or release, and unavailable recording
  or cleanup outcomes.
- Inspect the unbounded PNG and retention accounting and the proposed resource
  decision. Cover producer versus validator limits, partial preservation,
  privacy, meaningful boundary controls and the absence of a serviceability
  guarantee. No arbitrary cap or deletion may be smuggled into implementation
  authority.
- Check every proposed amendment against the accepted input, wait, poll and
  transport contract. Check it against all remaining k89/k81/k76/k67/k62/k57/k54
  duties. Check that prose, diagrams and tree sequencing agree. Review approval
  must not become human scope approval, runtime authorisation or ancestor
  closure.
- Report actionable findings with precise source and contract evidence and
  limits. If the findings earn integration, insert it immediately before the
  first later live sibling, settings-keepalive-scope-k93. It then precedes that
  decision and k89/k81/k76 consumption. Create no integration if none is earned.

## Notes
Settings-keepalive-scope-k93 is a requirements discussion, not an approved
scheduler. Any resulting design, planning, implementation and earned review must
precede downstream consumption. All runtime stays held. Historical results,
closed caps, six causal slots and private secret-bearing roots are unchanged.

## Decisions (running log)

- 2026-10-29: Adopt the mandated review leaf in the clean jj workspace. Read
  the k92 commit 5ce8a16e and its whole diff. The working tree equals that
  commit for every reviewed path. Read the design, the spec, the protocol, the
  capture, shared, physical and click reports, and the views. Read the k85,
  k80, k75, k71 and k66 charters. Run no test, build, lint, format or VM
  command. This review used no graph tool. Every conclusion below rests on
  direct source reads.
- 2026-10-29: Re-derive both overlap directions from the backend, the library
  and the capture controls. Both refuse, latch and stop, as the design states.
  Read the TestAnyware v2.7.0 tag at commit 65bc05c9 for transport facts.
  Every screen and input command holds one RFB connection for its whole run.
  A tick refused during the locked Allow read therefore loses no VNC liveness.
- 2026-10-29: Convert the inherited charter text of this file to controlled
  English as its own change first. Its meaning is unchanged.
- 2026-10-29: The escalation is justified. Every inspected route that removes
  the conflict amends an inherited rule. The design states this by one example.
  The findings name what the scope menu and the ownership contract still omit.
- 2026-10-29: P2-1 to P2-3 need resolution before settings-keepalive-scope-k93
  runs. Insert the integration immediately before k93, the first later live
  sibling. Spend no in-session reviewer. This leaf is the adversarial read.
- 2026-10-29: The cut is settings-keepalive-coordination-k95 at position 06.
  K93 moved to 07 and k89 to 08 with no content change. Its body carries the
  review handle, not the findings. No Creator line applies: this leaf finishes
  no producer. Retire this leaf only. The parent k85 keeps live work.

## Findings

Severity: P1 means the design would lead the scope decision or downstream work
to violate an inherited contract. P2 means a material omission or inconsistency
that k93 must have resolved before it decides. P3 means a narrower precision or
completeness defect.

Line numbers refer to commit 5ce8a16e. "The design" is
`docs/verification/settings-activation/KEEPALIVE-DESIGN.md`. "The spec" is
`docs/specs/settings-activation-discrimination.md`. "The plan" is
`docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`.

"The backend" is `scripts/vm-guest-exec.py`. "The library" is
`scripts/vm-capture-evidence-lib.sh`. "Bats" is
`Tests/scripts/vm-capture-evidence.bats`. TestAnyware paths are under
`cli-rs/crates/` at tag v2.7.0, commit 65bc05c9.

### P2-1. Planned keepalive cancellation cannot be recorded without latching the root

The design requires planned worker cancellation to be a recorded lifecycle
result, never a clean tick (design :144-150). It forbids clearing a latch
(design :132-133). The loop has two exits only: a failed sleep that it records,
or a failed capture (library :29-42). A supervisor must therefore signal the
loop at every normal scenario end, as the legacy cleanup does
(`scripts/vm-verify-lib.sh:101-102`).

Each recordable exit latches. A signal during the sleep records `poll-step`
phase `sleep` with the signal status. The backend sets a reason for every sleep
record, and a reason latches at once (backend :313-323, :367-368). Every later
dispatch re-latches that interrupted receipt (backend :236-245).

Bats test 18 shows the interrupted receipt (Bats :377-391). Tests 2 and 19 show the latch
(Bats :74-116, :393-404). A signal during a capture leaves an unfinished
attempt, which the next gate latches (design :160). Only an unrecorded kill
during the sleep leaves the root clean, and it leaves no record.

Failure scenario: a scenario passes every assertion. The supervisor cancels the
worker during its sleep and records intent. The root is now `unavailable`, with
reason `window poll sleep exit 143`. The finite caller must either report the
run unavailable or accept a latched root. The second is a new exception to the
sticky-latch rule, and the design does not state it.

The design defers the record schema (design :166-169). It should name the required amendment: a
cooperative stop, or a lifecycle receipt kind that does not latch, each with
controls. Without that, k93 may believe the current receipt and latch semantics
can host the cancellation contract.

### P2-2. The timing amendment is not reconciled with the spec's excluded driver-wait class

The design recommends admission delays before owned submissions, including
scenario input (design :63, :86-91). It names the added delay as an amendment
with possible effects on the symptom. The spec excludes "driver waits, retries
or repeated input" as a class (spec :301-304). Reconsidering an excluded class
requires a separate explicit scope proposal (spec :305).

The plan adds no focus wait or input retry (plan :94). It preserves fixed waits and adds no wait or
success retry (plan :148-149). The spec says the protocol never changes an
input or wait to obtain success (spec :176).

An admission delay immediately before a Settings menu click is a driver-inserted
wait in effect. Its purpose is coordination, not focus. The design does not
name the excluded class. The spec's new hold section does not connect the
proposal to it (spec :129-146).

Failure scenario: k93 approves serialisation as a cadence matter, and nobody records the separate explicit scope proposal the
spec requires. The E-set symptom-preservation reasoning (plan :291-297) then
rests on an unrecorded amendment. Scope item 1 should name the class and state
that approval is that proposal. It should give the distinguishing criterion: a
delay independent of observed UI state, against a wait conditioned on focus or
outcome.

### P2-3. The scope menu omits the one option that changes no scenario timing

The alternatives table has five rows (design :60-66). Its third row joins two
different arrangements: a second evidence writer for keepalive receipts, and a
liveness ping that is not evidence. The ping would run the same `screen capture`
outside the evidence root, hold or discard its image privately, and ignore its
own failure. It would amend the inherited rule that every capture, including
the keepalive, is checked evidence (k85 brief, Done when, and physical report
:147). That is a scope amendment, so it belongs on k93's menu rather than in
the compliant set. It is the only option that leaves scenario timing unchanged.

The design should state its costs, which are real. A failed ping would be
ignored, which k88 and k90 rejected. Its images carry secret screen content.

The tagged CLI documents one route where a client's departure resets the guest
connection and tart's VNC server drops input the reset overtakes
(`testanyware-cli/src/commands/mod.rs:120-126`). Whether two concurrent RFB
clients interact at tart's server is not established either way. The current
lock serialises RFB clients as a side effect, and the design never names that
as a benefit of one owner (design :68-75). Failure scenario: k93 chooses
between serialisation and unavailability without seeing the zero-timing option
or the VNC-level reason to reject it.

### P3-1. The conflict section names one long lock hold and treats every hold alike for liveness

The design names only the 30-second Allow read as a long hold (design :35-40).
Other classes hold the lock too. Every guest exec holds it until the guest
process ends or the agent's timeout fires. The legacy comment and the retained
fixture put that timeout at 30 seconds (`scripts/vm-verify-lib.sh:43-48`,
transport report :157-163). A bundle upload holds it for the whole transfer.
Lifecycle commands hold it through the adapter (backend :204-211).

The liveness consequence differs by class. Screen and input commands each hold
one RFB connection for their whole duration, and `find-text` polls on the same
connection (`testanyware-cli/src/commands/screen.rs:1-6`, `input.rs:1-6`,
`mod.rs:79-83`). A tick refused or deferred during such a hold loses no VNC
liveness. Agent and file commands open no RFB connection, so they are the
exposure. The next design's deadlines and k93's deferred-tick trade-off need
this class list and these bounds. No collision rate follows from it.

### P3-2. The persistent-connection alternative is dismissed without the tagged CLI's facts

The design says the current source establishes no suitable interface (design
:66). The tagged CLI has two long-lived RFB consumers. The viewer is a host GUI
window that forwards host input and reconnects
(`testanyware-cli/src/commands/viewer.rs:1-10`). The recorder keeps one
connection for at most 300 seconds and encodes video
(`testanyware-cli/src/commands/record.rs:1-14`, `:29-31`).

The adapter forbids `--viewer` because it blocks (backend :174-175). Neither is a liveness ping,
and each adds resource and lifecycle duties. The design should name them so
k93 rejects the alternative on facts.

### P3-3. The two-sided argument is made by example, and the k90 half-measure is not disposed of by name

The design proves collision by one permitted schedule (design :42-49). It
mentions the reverse direction in two table cells (design :63, :65). K90
suggested a serialised wait for the keepalive alone (k90 task file :111-113). A
keepalive-only blocking acquire removes the first direction and leaves the
second.

Its window is the capture's whole lock hold: RFB connect, up to five
seconds waiting for a frame (`testanyware-vm/src/capture.rs:22-33`), encode,
payload check and PNG inspection. The design should state the structural claim
once. Where the scenario never waits, no capture may be in flight at any
scenario dispatch, and only the scenario can guarantee that. Scenario-side
waiting, or scenario-declared windows, is therefore forced. That statement
supports the escalation and closes the half-measure.

### P3-4. The proposal is restated in many places, and the spec carries work-order text

The recommendation and hold appear in the design, the spec (spec :129-146), the
plan (plan :28-35), the capture report (:20-27) and the views README. They also
appear in the k85 brief, the root brief and the k89 and k93 bodies. SPEC-FORMAT
keeps a spec to the current agreed design and says to cite rather than restate.
The spec section says "proposed, not approved" and "pending independent design
review", which is brief language. Failure scenario: k93 records the decision in
one place, and the other copies keep saying "proposed". The spec and plan should
carry only the binding hold and a pointer to the design.

### Supported items

These claims hold against the source and need no correction. Both overlap
directions match the backend and the controls. The interruption table rows
match the backend's poll-step, SIGINT and unfinished-attempt paths. The
resource accounting matches the validator (`scripts/vm_capture_artifact.py:37`,
`:88-99`).

The held-pointer, orphan-lock, untouched-collection and
exact-containment duties are present. The diagrams agree with the prose, and
the tree order k94, k93, k89 agrees with the design. No ADR is earned: no
decision exists yet, so the three-part test fails.
