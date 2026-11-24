<!-- tc: pending because this large document retains its existing conversion boundary -->

# Settings activation: repair and evidence contract

## Current decision

<!-- tc: on -->

On 2026-10-29, Antony approved the recommended empirical design and the finite
acceptance convention, with the answer "approve." The decision permits the design
of one activation-before-window-ordering evaluation. It does not require a
documented API-use violation. This is a named exception to the
[earlier API-use correction test](#scope-decision-for-antony). It is not
permission for an unrestricted search for workarounds.

One activation request and the repetition, retry, deferral and speculative-yield
exclusions remain. The ADR [settings harness takes no keepalive captures](../adr/settings-harness-takes-no-keepalive-captures.md)
withdraws the [keepalive coordination hold](#keepalive-coordination-hold) and its
command-ownership admission scope. Thus driver waits are excluded in full again.
The harness relies on the pinned host macOS and Tart versions instead of keepalive
captures. The [accepted convention](#scope-after-no-candidate) rejects the repair
on a qualified recurrence, prevents acceptance without required evidence and
requires every ordinary assertion to pass. A passing finite bound supports only that sample.

The [correction assessment](#correction-assessment) still finds no qualifying
API-use correction in the inspected path. That bounded finding survives
[review and integration](../verification/settings-activation/CORRECTION-REVIEW.md).
Those reports keep the proposal in its form before this approval. The empirical
hypothesis now has a [concrete design](#single-request-ordering-design). Prepare
the same retained window, request activation once, and then request key and
front ordering.

The [distinct protocol](../verification/settings-activation/ORDERING-EVALUATION-PLAN.md)
sets two focused guests and a separate set of three complete ordinary guests.
One unchanged signed candidate serves both sets, with diagnostics disabled. These
numbers are conventions, not statistical bounds. On 2026-11-24, k54 froze one
signed subject and ran E01. E01 stopped before the first selection, because one
required setup read was unavailable. The evaluation ended with no acceptance, as
the [qualification results](../verification/settings-activation/ORDERING-QUALIFICATION-RESULTS.md) record.

The [independent review and integration](../verification/settings-activation/ORDERING-REVIEW.md)
are complete. The [application implementation](../verification/settings-activation/ORDERING-APPLICATION-RESULTS.md)
supplies the reviewed call order. It passes compilation and the existing headless
controls. K36 delivered the repairs of the shared scenario, its helpers and the
finite caller before the runtime freeze. Repair acceptance stays unresolved.

On 2026-11-24, after the E01 stop, Antony closed the repair as unresolved.
[Issue #15](https://github.com/Linkuistics/Koine/issues/15) brings the evaluation
back. A new run there needs a new scope decision, a new declared sequence, a new
freeze and new slot identities.

Antony left the call order to the decision task. That task chose the order that
0.4.0 shipped, because the candidate has no acceptance.
`settings-released-call-order-k184` returns the code to that order. Issue #15
can apply the candidate again with its evaluation. The dormant diagnostics stay
in the product.

The shared scenario keeps the strict positive setup. Thus the release menu-bar
check runs the front-process read that stopped E01 before each of its four
Settings selections. A release run can stop at that read until issue #15 changes
it. Such a stop is unavailable evidence, not a Koine failure.

<!-- tc: pending because the conversion has not reached this part of the document -->

This amends a prerequisite; it does not satisfy it. Native cause and ownership
remain unresolved. The retained evidence still does **not** support the finite,
two-sided causal experiment previously required before repair evaluation. The
implemented mouse/Return probe earns **no runtime**, including its two
route-qualification guests. All six slots remain unstarted. A different question
needs its own separately justified protocol and bound.

The accepted scope permits design only. A concrete candidate needs independent
review before implementation or runtime evaluation, followed by separate complete
ordinary-operation acceptance with diagnostics disabled. One Settings selection
must still return one front/focused Settings window. No API violation, product
repair, native mechanism or external owner is established.

The [visual discussion](../design/architecture/settings-activation/README.md)
shows the proposed call order, bounded evaluation and outcome rules alongside
the unresolved causal question.
Graph views begin at the dark **Start here** node; arrows in the evidence view
describe reasoning, not measured event order or a proven causal graph.

## Single-request ordering design

The application delegate continues to own Settings readiness, the retained
window and navigation. On the main actor, each admitted show invocation first
requires the existing server and port, creates/configures the window only if
needed, and applies any requested section. It then makes exactly one existing
self-activation request, followed immediately in application control flow by
the existing key/front window request. There is no suspension, run-loop dispatch,
menu-close gate, activation-status polling or conditional second request between
them. Existing trace boundaries move with their corresponding calls; they remain
disabled in this evaluation.

This is application call order, not a promise that macOS completes activation
before window ordering. The system may decide later or decline. The window call
still runs after the activation call returns, even if the application is inactive;
an inactive result cannot select a retry. One valid user selection must
return the one front/focused Settings window under the empirical acceptance
standard. A refusal is a possible failed product outcome, not a branch the
application hides with another API.

| Caller or state | Preserved behavior and effect of reversal |
|---|---|
| First launch while setup needs the user | The same launch decision invokes the shared show operation after server/port readiness. The window is fully constructed before activation; no additional launch or request is added. |
| Launch after setup, including login | The existing launch policy does not call show. Reversal must not introduce activation or an unsolicited window into that path. |
| Finder/open of the running application | The existing reopen handler calls the same operation and returns false. If readiness is incomplete it retains the current no-op behavior; no queued retry is introduced. |
| Settings menu selection | One callback invokes show once. One activation request and one key/front request apply to the retained window. |
| Status-line selection | The same operation first selects the requested section, then uses the same order. The caller need not learn or choose an activation policy. |
| Window closed or already visible | Keep the single window identity, non-release-on-close lifetime, size, ordinary level and move-to-active-Space behavior. Closing orders it out; reopening does not replace it. A visible window is reused. |
| Already-active application | Retain the existing unconditional single request. Apple's contract says it cancels any pending outgoing activation yield; this design adds no yield and does not claim none could exist externally. |

The separate fatal-alert activation/termination path is outside this method and
unchanged. Main-actor serialization prevents concurrent application mutations;
native notifications may still arrive while a framework call executes. The
proposal adds no state, cache, completion callback or reentrancy mechanism.

### Public API preconditions and limits

The declared deployment floor is macOS 26; self activation is available from
macOS 14. The current agent/accessory policy permits programmatic activation.
The application owns an ordinary titled window, which is key eligible under the
documented style rule. The real application run loop and main-actor owner remain
in place. A ready server/port and constructed window precede both requests.
These facts establish API applicability, not success.

Apple recommends the existing self-activation API for this receiver and makes
activation discretionary. The installed SDK additionally warns that a return
does not establish immediate activation. The window request addresses key/front
ordering within its level; moving to the active Space specifies destination when
active, not activation authority. No checked contract requires this relative
order. The [primary contracts and source evidence](../verification/settings-activation/ORDERING-DESIGN-EVIDENCE.md#primary-contracts)
support those limits. No cooperating TextEdit yield is assumed or requested.

### Alternatives, ownership and reversal condition

| Design | Benefit | Cost and disposition |
|---|---|---|
| Reverse inside the existing show operation — selected and implemented | One owner keeps window lifetime, navigation and the two requests together; callers retain the same interface. Small, reversible application change. | Affects launch/reopen/status-line callers as well as Settings. Requires complete ordinary acceptance; no contract guarantees improvement. |
| Reverse only in the menu caller or add a caller-selectable order | Could limit the changed path to menu actions. | Splits activation knowledge across callers or adds an unsupported mode. Divergent launch/reopen behavior and a wider test surface earn no benefit for the accepted single-window contract. Not selected. |
| Keep current order | No behavioral migration. | Preserves the established unresolved failure. Remains the baseline if the empirical candidate is rejected, not a successful repair. |

No general activation adapter, fake OS response, new public seam or additional
monitor is earned. A fake that rejects the old order and accepts the new would
encode the hypothesis as its own oracle. The actual native response is the
external dependency; the agreed complete VM seam observes the relevant behavior.
The existing historical end-to-end failures are useful failing product evidence.
The intermittent response offers no established deterministic local RED test;
do not manufacture one or run a baseline until failure. Source inspection can
check one request and retained identity, but cannot demonstrate repaired focus.
Focused helper tests instead exercise real transport/classification defects at
their existing substitution boundary.

A qualified recurrence in either declared set rejects reversal as the repair.
Missing required evidence or another ordinary failure prevents acceptance and
keeps the outcome unresolved. Neither permits another candidate or larger sample
without a new explicit decision. A future API-use mismatch could justify a
different design under the existing default test; this exception does not.

## Finite evaluation and ordinary acceptance

<!-- tc: on -->

The [evaluation protocol](../verification/settings-activation/ORDERING-EVALUATION-PLAN.md)
owns the exact subjects, five slots, setup, observation qualification, freeze,
stop rules and outcome precedence. Two fresh focused guests each run the current
prefix of first launch and four selections. The separately declared three-guest
complete ordinary set runs only if both qualify.

One new signed candidate is frozen before the first guest. It remains
byte-identical across both sets. Ordinary readiness is separately revalidated.
There is no baseline arm or qualification-only guest. All implementation and
review finish before freezing.

The freeze also pins the host, as the
[keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md)
decides. The host must run macOS 27.2.1 (26B131) with Tart 2.42.0. A mismatch holds
before the first slot for a new decision. The harness does not rely on the
TestAnyware VNC keeper. A Tart crash during a slot is a test-driver failure. It
stops every later slot, permits no retry and is never a Koine failure or a pass.

<!-- tc: pending because the conversion has not reached this part of the document -->

Both sets use the same changed scenario and helpers. The focused prefix includes
the existing TextEdit quit and ends before resize. Positive setup observations
must establish TextEdit in front with the same observable idle document and no
dialog, sheet or menu before each of its four selections. Missing observations
are unavailable setup, not permission to continue or refocus.

The existing front predicate checks Koine and focused on the first window outside
Notification Center; a separate count counts all Koine windows. The protocol
adds a required title/identity audit on the original front/focus list. Outcome
screenshots are retained context, not automatic acceptance assertions. A
zero-window recurrence additionally requires clean same-process liveness;
process loss is a separate assertion failure and unavailable liveness is
unresolved. Neither supplies a native classification.

Both sets disable application diagnostics and the native logging experiment.
The existing UI seam retains real input, window/front/focus observations and
screenshots. Raw failed transport cannot be stripped or repaired by later output.
The protocol stops all later slots on the first required failure or unavailable
result, retains every partial and NOT RUN phase, audits inputs/endpoints/golden,
and verifies exact clone cleanup. It never changes an input or wait to obtain
success. Only clean negative state reads continue within existing poll bounds.
The protocol fixes state-poll, one-shot-command and required-evidence classes;
hidden transport retries and ignored failures must be removed from both sets.
Launch/configuration/restart need clean submission and their declared downstream
confirmation. A restart disconnect remains unavailable despite a later boot.
This availability cost may prevent acceptance; it is no authority to relax the
rule, add a delay or replace a guest. If a required clean completion is
demonstrably unavailable, hold before the first slot for a new decision.

Removing diagnostics changes workload; it proves no timing neutrality. The new
capture policy also adds observation work. A qualified recurrence demonstrates
symptom preservation for that combination and rejects the candidate. An all-green
sample leaves preservation unknown and supports only the explicitly accepted
finite behavioral convention. No native mechanism, comparative risk reduction,
API violation or general reliability claim follows.

<!-- tc: on -->

### Keepalive coordination hold

The [keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md)
withdraws this hold. The harness takes no keepalive captures and has no serialised
command owner. Thus the owner design, its ownership delays, the finite resource
profile and the cooperative worker stop are withdrawn too. Helper adoption,
readiness, freeze and runtime no longer wait for that design. Their other
prerequisites remain. The driver-wait exclusion in the
[scope decision](#scope-decision-for-antony) applies in full again.

These capture duties stay binding:

- The single writer and ordinal domain
- Complete required-capture qualification before any later scenario dispatch
- First-failure eligibility
- Unique private originals and partials.

<!-- tc: depart synonym-rotation because fixed means set in advance, not repaired -->
No second evidence writer, UI-conditioned delay, input retry or latch reset is
admitted. An interrupted required capture still prevents acceptance. The fixed E
and A sets, outcome rules, exact VM identity, private roots and all other evidence
and containment duties remain. The
[design record](../verification/settings-activation/KEEPALIVE-DESIGN.md) and the
[owner contract](settings-keepalive-owner.md) stay as history.

<!-- tc: pending because the conversion has not reached this part of the document -->

## Evidence and the missing control

The [paired native observations](../verification/settings-activation/CAUSAL-RESULTS.md#independent-saved-input-context)
contain a real contrast. Success-adjacent native records show a successful front
change, TextEdit inactive-key appearance, Koine active-key appearance and Koine
conditional ordering with op 1 relative 0. Failure-adjacent records positively
show TextEdit requesting active-key appearance and Koine conditional ordering
with op -1 relative 32. Both sequences contain deferred mouse activation.

The appearance/ordering records follow their respective native client records
in native tick order. This does not put the old application show, menu or
notification records on that clock. Private op values have no established
refusal semantics; missing counterparts establish no absent event. The
[saved failure](../verification/settings-activation/persisted-01/failure-native.json)
and independent visible/window observations supply the failed outcome.

Two causal directions remain compatible with this contrast: a competing native
interaction could affect activation, or an unsuccessful activation could leave
TextEdit's appearance and Koine's relative ordering as observed. The full
[native-row comparison](../verification/settings-activation/DISCRIMINATION-REVIEW.md#native-row-comparison)
adds details that matter to that distinction:

- After the failure-adjacent token checks, TextEdit requests active-key appearance
  for window 32 and asks window 38 to resign main appearance. Connection 2d503
  earlier set window 38 active main and later sets it inactive main; its owner
  is not identified here. In success, Koine also requests main-appearance
  resignation for another window. Resignation alone is not a failure marker.
- Success records setting Koine frontmost and posting its resume after the token
  checks. No matching rows are identified between the failure-adjacent client
  call and conditional ordering. TextEdit's request is interleaved with that
  native processing; it is not evidence of an action taken only after a recorded
  failed result. A missing counterpart still proves no absent event.
- Koine's remote-menu tracking-end update follows its client call in both
  outcomes, at about 19 ms and 4 ms respectively. Both menu interactions also
  end with the same immediate end-user-interaction form. Neither shared event
  identifies the responsible condition.

These observations leave both causal directions open. They do not identify a
supported setter for the relevant interaction, a qualified observation of its
absence, or a matched intervention that separates the directions. They supply
context for candidate hypotheses, not a completed causal experiment.

The [earlier marker comparison](../verification/settings-activation/FOCUS-RESULTS.md#native-sequence-evidence)
also has positive successful counterexamples. These refute marker presence as
a sufficient condition for failure, but do not refute its necessity. The table
below evaluates that separate claim. Different recording loads prevent those
runs from establishing a replacement matched cause.

## Candidate interventions and falsifiers

| Candidate | Independent support and controllability | Prediction, possible falsifier and remaining gap |
|---|---|---|
| Change the final Settings-row input from mouse to Return | Mouse deferred-activation context is positively recorded in both outcomes. The route can request a different final input after identical mouse-open/hover preparation; actual direct delivery is still unqualified. | If row clicking is necessary for failure, a positively qualified failed Return reopen refutes necessity. The shared-context rival permits either outcome and has no finite falsifier here. Mouse failure/Return success, all-green and all-failed results do not distinguish the pair. |
| Change TextEdit's apparent key state or foreground application | TextEdit's active-key/main-resignation requests occur after the failure-adjacent token checks. Koine makes analogous resignation requests in success. No supported setter isolates the relevant competing interaction. | The necessity hypothesis predicts that failure requires TextEdit's key reclaim; one qualified failure with reclaim independently excluded would refute it. Missing log rows cannot establish that exclusion. The rival permits failure without reclaim and has no finite falsifier here. Closing/replacing TextEdit or forcing focus also changes the foreground/window setup and other interactions, so it is not the required matched intervention. |
| Remove TextEdit's viewbridge marker before selection | The saved rendering contains its deferring rules after a ViewBridge termination message and before the failed selection; it also contains rules after success. Earlier native runs place the marker before successful activations. No supported independent setter/remover in the same setup is established. | If the marked condition is necessary, a qualified failure with that condition independently absent would refute necessity. Success with the marker refutes sufficiency only. Missing logs cannot qualify absence, and changing the app/window/service setup changes other conditions. The marker-independent rival still permits either outcome and has no finite falsifier here. |
| Remove the earlier successful Settings selection | The persisted failure follows one successful menu selection and close; the ordering study also contains an initial-selection failure. | A universal prior-selection necessity claim is already contradicted. Repeating that comparison would not isolate the failed request's responsible context. Matching one prior selection is a control, not an intervention on a proven cause. |
| Reverse the application's show/activate order | The completed ordering comparison contains success in both orders and a failure in the original order; the experimental source was restored. | Its finite results do not establish reversal as a cause or sufficient repair. Repeating it or enlarging its cap supplies no newly supported deterministic or probabilistic prediction. |

There is no evidence-backed lower bound on failure probability, independent-trial
model or deterministic identical-outcome rule for the shared-context explanation.
Four outcomes cannot manufacture one. A richer recorder could improve correlation
while leaving this identifiability problem intact; it is not the missing
intervention and earns no additional producer or guest under this decision.

More generally, an unrestricted claim that failure *can* occur with or without a
condition permits every finite sequence of successes and failures. To obtain a
logical finite falsifier, independent evidence must support a narrower prediction
that rules out some observable outcome under a controllable intervention. An
evidence-backed failure-rate bound and trial model could instead support a
predeclared statistical rejection rule; that is not logical disproof and would
need explicit agreement as the causal standard. Neither basis is established
here. The intermittent symptom alone supplies neither one, and there is no
promise that a targeted investigation can obtain them.

### Matched setup retained for the narrow question

The [current protocol](../verification/settings-activation/CAUSAL-PLAN.md)
already specifies one successful first launch, one successful mouse menu selection
and close, then one measured reopen. Before both menu selections, Settings has
zero visible windows and TextEdit is frontmost with the same idle document and
no panel. The same candidate, preferences, display, native logging configuration,
mouse-open/hover and positive highlighted Settings row are required. Only the
final row input changes in the four fixed mouse/Return/Return/mouse positions.

This matches the declared observable setup, not all hidden native state. Input
kind and its inherent timing change together. A failed setup is a retained
control failure with no repeated input or replacement slot. Even perfectly
matched successful setup cannot give the broad rival its missing finite falsifier.

## Scope decision for Antony

**Accepted on 2026-10-28: permit a separate behavioral-repair design while leaving
native cause unresolved.** The user-facing failure is established, and the present
probe cannot distinguish the competing causes. Retaining native causal proof
as a prerequisite could block repair indefinitely. Antony accepted this
recommendation; ending the repair investigation was not selected.

This original API-use test remains the default for other candidates. The later
[accepted empirical scope](#scope-after-no-candidate) removes its documented-
violation prerequisite for activation-before-window ordering only.

A candidate justified by public API contracts and the observed product behavior
may now be designed without first establishing a positive native refusal,
responsible context or two-sided native causal discrimination. Those facts stay
unresolved and remain necessary for any corresponding causal or ownership claim.

<!-- tc: on -->

The accepted boundary admits a **single-request application correction**. A
different public activation API is eligible for design only if its preconditions
can be established and it passes the justification test below. These classes
remain excluded under this amendment:

- Application-side repeated activation
- Driver waits, retries or repeated input
- Menu-close or later-run-loop deferral
- Yield-based activation used as a speculative timing workaround.

Reconsidering an excluded class requires a separate explicit scope proposal.
The [keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md)
withdraws the later [keepalive scope agreement](#keepalive-coordination-hold),
which was that proposal for command-ownership admission delays. Thus every
excluded class applies in full. The unchanged experiment subject still excludes
every alternative API, yield, async deferral and repeated activation, irrespective
of candidate-design scope.

<!-- tc: pending because the conversion has not reached this part of the document -->

Outside that named exception, the justification test requires a concrete mismatch
or omitted step in Koine's current window/activation use, supported by applicable
public API requirements and source or retained evidence. A design must show how its single-request
correction addresses that mismatch, establish its preconditions, and state the
remaining discretionary OS behavior. It must identify a useful failing product
seam where feasible and a separate finite ordinary-acceptance plan. API
availability alone is insufficient. Apple's
[activation contract](https://developer.apple.com/documentation/appkit/nsapplication/activate())
allows the system to decline activation; the
[checked ordering evidence](../verification/settings-activation/ORDER-RESULTS.md)
supplies no prescribed call sequence that explains or avoids the failure.
No candidate met that test in the inspected path, and the original agreement
promised none.

This is an explicit amendment to those prerequisites, not a finding that they
have been met. A follow-on design must identify one concrete candidate, explain
its justification under the applicable scope and its limits, define a useful
failing product seam where feasible, and receive review before any runtime work.
A green count or successful alternative API alone does not establish an API-use
correction. The no-candidate assessment led to the explicit empirical exception
below, not permission to try a sequence of workarounds.

| Choice | Decision and effect | Cost and limit |
|---|---|---|
| Behavioral-repair design — accepted | Amend only the requirement that native causal discrimination/disposition precede repair evaluation. Admit design of a single-request correction under the justification test above; preserve the named repetition, deferral and speculative-yield exclusions. Keep native cause and ownership unresolved. | A documented correction might improve behavior without explaining the native mechanism. No such candidate is established. Review and separate bounded evaluation remain required; this agreement selects no candidate or guest. |
| Retain the causal prerequisite — not selected | A future causal experiment still needs independent evidence for a controllable intervention and predictions that each rule out a finite observable outcome. | The unrestricted intermittent rival cannot be falsified by any finite sample. A supported deterministic restriction is missing; a supported rate/trial model would offer only statistical rejection and require explicit agreement to that standard. Neither may become available. More monitoring or another all-green set does not supply them. |
| End the investigation unresolved — not selected | The repair request remains active. The reproducer and findings remain evidence of an unresolved failure. | No repair obligation is abandoned or marked satisfied by the scope agreement. |

The existing six-slot probe remains held. Its unused slots provide no runtime
budget for the accepted design question. The named exception below changes the
justification standard only; it supplies no repair result or sequence of
speculative workarounds.

## Correction assessment

The [source and public-contract assessment](../verification/settings-activation/CORRECTION-ASSESSMENT.md)
finds no evidenced API-use mistake or omitted step that justifies a correction
in the inspected Settings path. The application retains a titled window, requests
key/front status and makes one self-activation request. Accessory application
policy permits activation. Apple recommends the self-activation API already in
use and leaves the outcome discretionary. A different activation API supplies no
missing guarantee; cooperative activation lacks an established prior yield from
the active app. Unconditional window ordering alone would not supply focus.
The existing move-to-active-Space setting governs an activated window's
destination; it supplies no activation guarantee or evidenced correction for
the observed failure.

<!-- tc: on -->

Reversing the window and activation calls remains an empirical hypothesis. The
checked contracts do not prescribe that ordering, and the closed comparison
does not establish a repair. Repetition, driver waits, retries, repeated input,
deferral and speculative yielding remain excluded. The
[keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md)
withdraws the later keepalive agreement and its ownership-based driver-wait design.

That assessment selected no candidate, new product seam, runtime subject or
acceptance sample. The later empirical design above changes the permitted
justification, not this finding. This is a bounded finding that survives review.
It is not proof that every possible correction is absent or that the operating
system owns the failure.

<!-- tc: pending because the conversion has not reached this part of the document -->

### Scope after no candidate

**Accepted on 2026-10-29, answering "approve":** permit design of one empirical
activation-before-window-ordering evaluation without requiring a documented
API-use violation. Antony approved the recommended design scope and finite
acceptance convention after the reviewed no-candidate finding. This changes only
the candidate-justification standard for that named hypothesis. One activation
request, one front/focused window, the other excluded classes, independent design
review, evidence integrity and separate complete ordinary acceptance remain
required. It does not establish that the earlier API-use test was satisfied.

The reason for recommending this option is its small single-request behavioral
change.
Historical feasibility is instrumented and symmetric: reversed B02/B03 and
original A04 succeeded with synchronous file tracing, and reversing the calls
also moved the trace writes. The [closed comparison](../verification/settings-activation/ORDER-RESULTS.md)
contains no instrument-free comparison and does not establish lower failure
risk from reversal. Feasibility does not predict that the intermittent failure disappears.

The finite acceptance standard is an explicitly agreed convention, not a
rejection rule derived from a supported failure-rate bound or trial model;
neither is available. The accepted rule rejects reversal as the repair if one
qualified Settings selection in its declared evaluation or separate ordinary
acceptance fails to return one front/focused window. Failed transport or missing
required observations prevent acceptance and leave the result unresolved; they
are not automatically product failures. Every other required ordinary assertion
must also pass. Completing the fixed bound with all required evidence and
assertions passing supports only success for that declared sample, not
elimination of intermittent failure, a mechanism or general reliability.

The concrete design must fix numerical bounds, qualification criteria and stop/
failure/unavailable-evidence rules before runtime, and receive independent review
with every earned integration completed before implementation or execution.
The old ABBA cap stays closed. The scope answer itself fixed no numerical cap,
final subject or guest. The concrete design above now fixes two focused and three
ordinary slots; its independent review and integration are now complete.
Implementation verification and actual readiness still precede runtime.
No signed subject or runtime result exists for that design.

| Choice after the reviewed assessment | Effect and cost |
|---|---|
| Permit the named empirical design — accepted | Allows design of activation-before-window ordering under the changed justification standard, preserving one request and all other exclusions. Its historical feasibility is instrumented and shared by the original order. A finite acceptance bound is an agreed convention: a qualified recurrence rejects the repair, unavailable required evidence prevents acceptance, and all required ordinary assertions must pass. A passing sample proves no API violation, mechanism, ownership or general reliability. No implementation or runtime follows from the scope answer alone. |
| Retain the API-use test without an exception — not selected | Would keep repair held until new evidence supplied a qualifying mismatch and correction. Further unchanged sampling or richer monitoring would not fill that gap. The test still applies to other candidates. |
| End the investigation unresolved — not selected | Repair remains live. The observed failure and reproducer remain; no repair work is abandoned or marked satisfied. |

The answer is Antony's explicit approval, not an inference from review or elapsed
time. Native cause and ownership remain unresolved. The six held causal slots
remain unchanged and unstarted; unused positions provide no evaluation budget.
No historical result or strict false join changes, and no causal or product
ancestor closes from agreement alone.

## Protocol change comparison and qualification boundaries

| Surface | Before this design | Current disposition |
|---|---|---|
| Two route slots and four modality slots | Unstarted, conditional on a supported causal design | Still unstarted; no runtime earned because that condition is unmet |
| Slots, setup, order, caps, route and recorder | Current reviewed causal protocol | Unchanged. The separate empirical protocol above does not replace or consume these slots |
| Highlight and delivery | Actual highlight, expected route nonce; positive mouse pair/callback correlation; strict Return event identity | Unchanged, including Return's possible unavailability despite delivered input |
| Native containment and controls | One explicit launch prefix plus all ordinal candidates; exact ENCLOSED/OUTSIDE/MISSING/AMBIGUOUS/INVALID classes; successful window controls and deferred native gates; final takes no measured focus input | Unchanged; no desired-bracket filtering or weakened control |
| Headless versus guest evidence | Reader/request/transport checks and compilation; actual AppKit dispatch, timing and changed-instrument availability unqualified | Unchanged; this design runs no guest or product check |
| Identity and clock | Raw guest/archive/timesync/image provenance required; parser agreement alone insufficient | Unchanged; no host substitution, historical clock upgrade, synchronous-emission guarantee, fit, tolerance or widened bounds |

The activate-only bracket gives no common native clock to unsampled show/menu/
notification rows. Synchronous observers can run inside the call, and probe
timer/file/monitor work precedes selection. A future qualified failure could
establish symptom preservation only for that instrument; no timing neutrality
or reliability rate follows. Even exact enclosure is correlation, not a native
transaction identity or refusal.

## Duties under the accepted scope

### Ownership and existing test seams

The codebase-design distinction between an observation seam and a behavior seam
matters here. The menu observer records highlight and input; the offline readers
classify supplied evidence; the application owns showing its window and making
one activation request. The operating system's response remains external state.
Changing an offline fixture cannot reproduce or control that native response.

| Boundary | What its check can establish | What remains outside it |
|---|---|---|
| Menu probe and route | Request bounds, transport retention and positive delivery criteria | Actual AppKit tracking/dispatch coverage and native activation authority |
| Interval and evidence readers | Exact supplied identities/ticks, candidate accounting and control policy | Raw provenance, complete native decision coverage, cause and ownership |
| Product behavior | One real selection must return one front/focused window; historical VM failures demonstrate this seam | No deterministic failing headless native substitute is evidenced; source-order assertions cannot prove repair |
| Existing complete VM scenario | The agreed ordinary user behavior across the declared finite sample | Mechanistic explanation and reliability beyond that sample |

Keep these owners separate. A repair design must earn a product seam for its
concrete behavior; adding more observer APIs or injecting invented OS outcomes
would not resolve the missing causal control. No new seam or interface is added
by this agreement. Antony agreed to the complete VM seam and focused helper
checks on 2026-10-28 and retained that scope when accepting this amendment.
The complete scenario exercises a real signed application, real menu input,
independent window observations and screenshots in a disposable guest. A useful
focused failing product check, where feasible, supplements that native evidence.

<!-- tc: on -->

On 2026-10-30, Antony agreed to the keepalive replacement's tests at these
existing boundaries. The
[keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md)
withdraws the keepalive-only tests. They cover real coordination, both overlap
directions, races between a normal stop and dispatch, unexpected worker exits and
resource limits. Control the CLI and sleep behaviour while the remaining tests
exercise real locks, capture validation and records. Cover these cases:

- Failure ordering
- Retention of originals and partials
- Signal handling
- Both held-pointer cases.

Retain the existing TestAnyware VM workflow for native behaviour after all
prerequisites. These local controls cannot establish VNC liveness or repaired
focus. A new native capability experiment needs its own explicitly reviewed scope.

### Original-duty comparison

The original criteria remain binding, except for the native-causal prerequisites
and the named candidate-justification exception below. The
[keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md)
withdraws the narrow keepalive amendments, and the rows below name each withdrawn
duty. The [keepalive duty comparison](../verification/settings-activation/KEEPALIVE-DESIGN.md#original-duties-and-handoff)
stays as history. It maps each keepalive duty to its origin.
The full earlier comparisons remain historical evidence:
[causal](../verification/settings-activation/CAUSAL-RESULTS.md#every-original-duty),
[protocol](../verification/settings-activation/CAUSAL-PROTOCOL-RESULTS.md#integrity-and-original-duties),
[focus](../verification/settings-activation/FOCUS-RESULTS.md#every-original-duty),
[clock](../verification/settings-activation/CLOCK-RESULTS.md#original-duties-and-remaining-work)
and [persisted](../verification/settings-activation/PERSISTED-RESULTS.md#every-original-duty-and-remaining-work).

| Duty | Disposition under the accepted scope |
|---|---|
| Historical callback/failed-activation classification and persisted symptom preservation | Preserved. No historical byte or classification changes. |
| Supported condition, matched intervention and two finite falsifiers | Unmet. Its role as a prerequisite to the permitted behavioural-repair design and evaluation is amended. It is still required for the corresponding causal claim. The narrow probe does not satisfy it. |
| Positive failed actual request/native disposition/responsible context | Unresolved. Its role as a prerequisite to the permitted behavioural-repair design and evaluation is amended, and it is not marked satisfied. Native cause and ownership remain unresolved. |
| Qualified acquisition/configuration/lag and changed-instrument availability/symptom/timing | Historical capabilities and limits are preserved. There is no new runtime qualification. |
| Actual signed subject/all consumed inputs/completed golden freeze | Met for the closed k54 sequence. On 2026-11-24, k54 froze one signed subject, all consumed inputs and the completed golden image. It also pinned the host macOS version and build and the Tart version. Any future run needs its own freeze, after review, integration and implementation. The [qualification results](../verification/settings-activation/ORDERING-QUALIFICATION-RESULTS.md) hold the identities. |
| Failed transport, partial archive, every started attempt and NOT RUN retention <!-- tc: depart synonym-rotation because a started attempt is a protocol state, while launch names an application launch --> | Preserved separately from scenario results. Text from a timeout or a nonzero status remains failed. |
| Original/endpoint/golden audits and exact clone stop | E01 passed its original, endpoint and input audits and its exact clone stop. The closing golden audit passed. Future runs keep the duty. Historical duties and results are unchanged. |
| Justified application repair and useful failing product seam | Repair unmet. The concrete design reverses the two calls locally under the named exception. Historical real VM failures are useful product evidence. No deterministic local native RED seam is established. Recorder and reader controls and an order-encoding fake prove no repair. Other candidates retain the API-use test. The [keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md) withdraws the separate command-ownership delay. Repetition, driver waits, retries, repeated input, deferral and speculative yield remain excluded. |
| Keepalive/scenario admission and timing | Withdrawn by the [keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md). The harness has no serialised owner, ownership delay or deferred tick. Input order, explicit sleeps, poll counts and one-attempt transports remain unchanged. |
| Required captures, failure ordering and retention | Preserved: one writer and ordinal domain, full required-capture validation before subsequent scenario dispatch, sticky first failure, unique private originals and all produced partials. There is no second writer or liveness-only exemption. |
| Finite host resource profile | Withdrawn by the [keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md). The harness needs no resource profile, limit or capacity reservation. |
| Planned keepalive shutdown | Withdrawn by the [keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md). The harness has no keepalive worker, so it needs no cooperative stop or worker supervision. Earlier failure or an interrupted required capture still prevents acceptance. |
| Helper, adoption, caller and qualification work | Every remaining duty survives. The surviving duties cover each file, environment, lifecycle and collection helper, and each exec and one-shot confirmation. They cover complete scenario adoption, signals and both held-pointer cases, and the positive setup, title and liveness check. They also cover the exact focused prefix, the finite caller and containment, and readiness, freeze and runtime. The [keepalive removal ADR](../adr/settings-harness-takes-no-keepalive-captures.md) withdraws the owner design chain of design, review and planning. Implementation and each earned review and integration still precede consumption. |
| One selection, one front/focused Settings window | The required behaviour and one activation request are unchanged. |
| Separate finite complete ordinary acceptance | Unmet. It is fixed at three full fresh-guest scenarios after two qualifying focused slots. The same signed subject applies throughout, with diagnostics disabled. Separate declaration and readiness, the all-input and completed-golden freeze and every evidence duty remain. A qualified recurrence rejects reversal. Missing or failed required evidence, or another required failure, stops all later slots without acceptance. A complete pass supports only that finite sample. In k54, E01 stopped with unavailable evidence, so A01, A02 and A03 did not run. |
| External evidence/reproducer/approval | No external owner is established. Attribution requires positive evidence and a reproducer. If the owner is external, the repair stays unresolved. There is no upstream report without Antony's approval. |
| Closed historical caps and unrun ordinary phases | All closed caps stay closed. Persisted reopens 2 and 3 stay NOT RUN. So do resize, minimum size, content height and scrolling, shortcuts, requests and denials, and consent. Silent launch, running-app reopen, login restart and Quit also stay NOT RUN. |
| Repair acceptance/release | The scope agreement supplies no repair or ordinary-acceptance result. The k54 evaluation ended with no acceptance. Antony closed the repair as unresolved, and issue #15 owns the next evaluation. There is no release or notarisation. |

Persisted scenario/inner Task 1/201, native/collection/audit 1/1/1, outer Task 201
and post-trace timeout/-1 remain failed outcomes. Original strict false/empty
clock joins remain unchanged. Every future evaluation still requires complete
readiness, freeze, audit and cleanup coverage and the product and ordinary duties
above. Independent review of a concrete justified design precedes implementation
or guests. Agreement and document review supply no causal, product or
ordinary-acceptance result.
