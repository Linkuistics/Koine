# Settings activation: repair and evidence contract

## Current decision

Antony accepted the recommended behavioral-repair design scope on 2026-10-28,
answering "I agree." A separately justified correction using one activation
request may be designed without first proving the native cause. The
[accepted boundary](#scope-decision-for-antony) requires a concrete, evidenced
mistake or omission in the application's API use and preserves the excluded
repair classes. No candidate has yet passed that test.

This amends a prerequisite; it does not satisfy it. Native cause and ownership
remain unresolved. The retained evidence still does **not** support the finite,
two-sided causal experiment previously required before repair evaluation. The
implemented mouse/Return probe earns **no runtime**, including its two
route-qualification guests. All six slots remain unstarted. A different question
needs its own separately justified protocol and bound.

The accepted scope permits design only. A concrete candidate needs independent
review before implementation or runtime evaluation, followed by separate complete
ordinary-operation acceptance. One Settings selection must still return one
front/focused Settings window. No product repair or external owner is established.

The [visual discussion](../design/architecture/settings-activation/README.md)
shows why the current observation and intervention do not meet the requirement.
Graph views begin at the dark **Start here** node; arrows in the evidence view
describe reasoning, not measured event order or a proven causal graph.

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

**Accepted: permit a separate behavioral-repair design while leaving native
cause unresolved.** The user-facing failure is established, and the present
probe cannot distinguish the competing causes. Retaining native causal proof
as a prerequisite could block repair indefinitely. Antony accepted this
recommendation; ending the repair investigation was not selected.

A candidate justified by public API contracts and the observed product behavior
may now be designed without first establishing a positive native refusal,
responsible context or two-sided native causal discrimination. Those facts stay
unresolved and remain necessary for any corresponding causal or ownership claim.

The accepted boundary admits a **single-request application correction**. A
different public activation API is eligible for design only if its preconditions
can be established and it passes the justification test below. The following
classes remain excluded under this amendment: application-side repeated
activation; driver waits, retries or repeated input; menu-close or later-run-loop
deferral; and yield-based activation used as a speculative timing workaround.
Reconsidering an excluded class requires a separate explicit scope proposal.
The unchanged experiment subject still excludes every alternative API, yield,
async deferral and repeated activation, irrespective of candidate-design scope.

The justification test requires a concrete mismatch or omitted step in Koine's
current window/activation use, supported by applicable public API requirements
and source or retained evidence. A design must show how its single-request
correction addresses that mismatch, establish its preconditions, and state the
remaining discretionary OS behavior. It must identify a useful failing product
seam where feasible and a separate finite ordinary-acceptance plan. API
availability alone is insufficient. Apple's
[activation contract](https://developer.apple.com/documentation/appkit/nsapplication/activate())
allows the system to decline activation; the
[checked ordering evidence](../verification/settings-activation/ORDER-RESULTS.md)
supplies no prescribed call sequence that explains or avoids the failure.
No candidate has been justified here, and the agreement promises none.

This is an explicit amendment to those prerequisites, not a finding that they
have been met. No candidate is selected by this document. A follow-on design
must identify one concrete candidate, explain its justification and limits,
define a useful failing product seam where feasible, and receive review before
any runtime work. A green count or successful alternative API alone remains
insufficient justification. If no such candidate can be justified, return the
unresolved decision rather than trying a sequence of workarounds.

| Choice | Decision and effect | Cost and limit |
|---|---|---|
| Behavioral-repair design — accepted | Amend only the requirement that native causal discrimination/disposition precede repair evaluation. Admit design of a single-request correction under the justification test above; preserve the named repetition, deferral and speculative-yield exclusions. Keep native cause and ownership unresolved. | A documented correction might improve behavior without explaining the native mechanism. No such candidate is established. Review and separate bounded evaluation remain required; this agreement selects no candidate or guest. |
| Retain the causal prerequisite — not selected | A future causal experiment still needs independent evidence for a controllable intervention and predictions that each rule out a finite observable outcome. | The unrestricted intermittent rival cannot be falsified by any finite sample. A supported deterministic restriction is missing; a supported rate/trial model would offer only statistical rejection and require explicit agreement to that standard. Neither may become available. More monitoring or another all-green set does not supply them. |
| End the investigation unresolved — not selected | The repair request remains active. The reproducer and findings remain evidence of an unresolved failure. | No repair obligation is abandoned or marked satisfied by the scope agreement. |

The existing six-slot probe remains held. Its unused slots provide no runtime
budget for the accepted design question. If no candidate meets the justification
test, the outcome remains unresolved; the agreement permits no sequence of
speculative workarounds.

## Protocol change comparison and qualification boundaries

| Surface | Before this design | Current disposition |
|---|---|---|
| Two route slots and four modality slots | Unstarted, conditional on a supported causal design | Still unstarted; no runtime earned because that condition is unmet |
| Slots, setup, order, caps, route and recorder | Current reviewed protocol | Unchanged; no replacement runtime protocol is published |
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
| Product behavior | One real selection must return one front/focused window | No useful failing headless product seam has yet been identified for a repair |
| Existing complete VM scenario | The agreed ordinary user behavior across the declared finite sample | Mechanistic explanation and reliability beyond that sample |

Keep these owners separate. A repair design must earn a product seam for its
concrete behavior; adding more observer APIs or injecting invented OS outcomes
would not resolve the missing causal control. No new seam or interface is added
by this agreement. Antony agreed to the complete VM seam and focused helper
checks on 2026-10-28 and retained that scope when accepting this amendment.
The complete scenario exercises a real signed application, real menu input,
independent window observations and screenshots in a disposable guest. A useful
focused failing product check, where feasible, supplements that native evidence.

### Original-duty comparison

The original criteria remain binding except for the two prerequisites explicitly
amended below. The full earlier comparisons remain historical evidence:
[causal](../verification/settings-activation/CAUSAL-RESULTS.md#every-original-duty),
[protocol](../verification/settings-activation/CAUSAL-PROTOCOL-RESULTS.md#integrity-and-original-duties),
[focus](../verification/settings-activation/FOCUS-RESULTS.md#every-original-duty),
[clock](../verification/settings-activation/CLOCK-RESULTS.md#original-duties-and-remaining-work)
and [persisted](../verification/settings-activation/PERSISTED-RESULTS.md#every-original-duty-and-remaining-work).

| Duty | Disposition under the accepted scope |
|---|---|
| Historical callback/failed-activation classification and persisted symptom preservation | Preserved; no historical byte or classification changes |
| Supported condition, matched intervention and two finite falsifiers | Unmet. Amended as a prerequisite to the permitted behavioral-repair design/evaluation; still required for the corresponding causal claim. The narrow probe does not satisfy it |
| Positive failed actual request/native disposition/responsible context | Unresolved. Amended as a prerequisite to the permitted behavioral-repair design/evaluation, not marked satisfied. Native cause and ownership remain unresolved |
| Qualified acquisition/configuration/lag and changed-instrument availability/symptom/timing | Historical capabilities and limits preserved; no new runtime qualification |
| Actual signed subject/all consumed inputs/completed golden freeze | Still required before any future launch, after all design/review/integration work; no final subject selected here |
| Failed transport, partial archive, every started attempt and NOT RUN retention | Preserved separately from scenario results; timeout/nonzero text remains failed |
| Original/endpoint/golden audits and exact clone stop | Required for future runs; historical duties and results unchanged; no clone in this design |
| Justified application repair and useful failing product seam | Unmet; recorder/reader controls are not a failing product seam. The accepted candidate boundary preserves application repetition, driver waits/retries/repeated input, deferral and speculative-yield exclusions; alternative APIs require the stated justification test |
| One selection, one front/focused Settings window | Required behavior unchanged |
| Separate finite complete ordinary acceptance | Still required through app:vm-verify-menu-bar, final ordinary signed subject/all-input/completed-golden freeze, diagnostics disabled, every outcome retained and timing addressed |
| External evidence/reproducer/approval | No external owner established; positive evidence/reproducer required for attribution, repair unresolved if external; no upstream report without Antony's approval |
| Closed historical caps and unrun ordinary phases | All closed caps stay closed. Persisted reopens 2/3, resize/minimum-size/content-height/scrolling, shortcuts, requests/denials, consent, silent launch, running-app reopen, login restart and Quit stay NOT RUN |
| Repair acceptance/release | Scope agreement supplies no repair or ordinary-acceptance result; no release or notarization |

Persisted scenario/inner Task 1/201, native/collection/audit 1/1/1, outer Task 201
and post-trace timeout/-1 remain failed outcomes. Original strict false/empty
clock joins remain unchanged. Every future evaluation still requires complete
readiness, freeze, audit and cleanup coverage and the product/ordinary duties
above. Independent review of a concrete justified design precedes implementation
or guests. Agreement and document review supply no causal, product or
ordinary-acceptance result.
