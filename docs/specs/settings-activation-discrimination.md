# Settings activation: experiment limit and scope decision

## Current decision

The retained evidence does **not** support the finite, two-sided causal
experiment required by the current charter. The implemented mouse/Return probe
earns **no runtime**, including its two route-qualification guests. All six
slots remain unstarted. This is a decision about the evidence available for this
design, not a claim that no future causal experiment is possible.

The open decision for Antony is whether native causal discrimination must remain
a prerequisite to evaluating a product repair. The recommendation below is a
**proposal**, not an accepted change to that requirement. No product repair or
external owner has been established. One Settings selection must still return
one front/focused Settings window.

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
TextEdit's appearance and Koine's relative ordering as observed. The retained
evidence does not identify an independently settable pre-activation variable
that separates those directions. These are possible explanations of the
observations, not newly validated experimental hypotheses.

The [earlier marker comparison](../verification/settings-activation/FOCUS-RESULTS.md#native-sequence-evidence)
also has positive successful counterexamples. The TextEdit viewbridge marker
alone cannot be the failure discriminator. Different recording loads prevent
those runs from establishing a replacement matched cause.

## Candidate interventions and falsifiers

| Candidate | Independent support and controllability | Prediction, possible falsifier and remaining gap |
|---|---|---|
| Change the final Settings-row input from mouse to Return | Mouse deferred-activation context is positively recorded in both outcomes. The route can request a different final input after identical mouse-open/hover preparation; actual direct delivery is still unqualified. | If row clicking is necessary for failure, a positively qualified failed Return reopen refutes necessity. The shared-context rival permits either outcome and has no finite falsifier here. Mouse failure/Return success, all-green and all-failed results do not distinguish the pair. |
| Change TextEdit's apparent key state or foreground application | The paired appearance records are positive, but a setter for the relevant native interaction and its causal direction are not established by these records. | Closing/replacing TextEdit or forcing focus changes the foreground/window setup and potentially many interactions. Neither a positive causal prediction nor a finite counterprediction follows from the observed op values. It is not an admissible matched replacement. |
| Remove the earlier successful Settings selection | The persisted failure follows one successful menu selection and close; the ordering study also contains an initial-selection failure. | A universal prior-selection necessity claim is already contradicted. Repeating that comparison would not isolate the failed request's responsible context. Matching one prior selection is a control, not an intervention on a proven cause. |
| Reverse the application's show/activate order | The completed ordering comparison contains success in both orders and a failure in the original order; the experimental source was restored. | Its finite results do not establish reversal as a cause or sufficient repair. Repeating it or enlarging its cap supplies no newly supported deterministic or probabilistic prediction. |

There is no evidence-backed lower bound on failure probability, independent-trial
model or deterministic identical-outcome rule for the shared-context explanation.
Four outcomes cannot manufacture one. A richer recorder could improve correlation
while leaving this identifiability problem intact; it is not the missing
intervention and earns no additional producer or guest under this decision.

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

**Recommended: authorize a separate behavioral-repair design while leaving native
cause unresolved.** The user-facing failure is established, and further spending
on the present probe cannot satisfy the current causal prerequisite. This option
would permit a candidate justified by public API contracts and the observed
product behavior to be evaluated without first establishing a positive native
refusal/responsible context or two-sided native causal discrimination.

This is an explicit amendment to those prerequisites, not a finding that they
have been met. No candidate is selected by this document. A follow-on design
must identify one concrete candidate, explain its justification and limits,
define a useful failing product seam where feasible, and receive review before
any runtime work. A green count or successful alternative API alone remains
insufficient justification. If no such candidate can be justified, return the
unresolved decision rather than trying a sequence of workarounds.

| Choice | What accepting it means | Cost and limit |
|---|---|---|
| Behavioral-repair design — recommended | Amend only the requirement that native causal discrimination/disposition precede repair evaluation. Keep native cause and ownership explicitly unresolved. Design a justified candidate and its separate bounded evaluation before implementation or guests. | May deliver useful behavior without explaining the native mechanism. It promises neither a candidate nor success and does not establish external ownership. |
| Retain the current causal requirement | Keep all guests held. Revisit only with independent evidence that identifies a controllable condition and finite falsifiers for both predictions. A separately authorized, targeted primary-source investigation could seek that evidence. | No supported runtime experiment or immediate repair route is currently available. More monitoring alone does not change this. |
| End this investigation unresolved | Preserve the reproducer and findings, explicitly accept that Settings repair remains unresolved, and separately decide the fate of the live repair work. | Does not fix the behavior or meet the original repair criterion. Requires Antony's explicit decision; no leaf is abandoned here. |

No answer, review approval, or passage of time counts as accepting the recommended
scope amendment. Under every choice, the existing six-slot probe remains held;
authorizing behavioral design does not authorize this probe or any new guest.

## Protocol change comparison and qualification boundaries

| Surface | Before this design | Current disposition |
|---|---|---|
| Two route slots and four modality slots | Unstarted, conditional on a supported causal design | Still unstarted; no runtime earned because that condition is unmet |
| Slots, setup, order, caps, route and recorder | K41-integrated protocol | Unchanged; no replacement runtime protocol is published |
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

## Duties preserved through the scope decision

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
by this design. The root's agreed complete VM seam remains the acceptance surface.

### Original-duty comparison

The original criteria and full comparisons remain authoritative:
[causal](../verification/settings-activation/CAUSAL-RESULTS.md#every-original-duty),
[protocol](../verification/settings-activation/CAUSAL-PROTOCOL-RESULTS.md#integrity-and-original-duties),
[focus](../verification/settings-activation/FOCUS-RESULTS.md#every-original-duty),
[clock](../verification/settings-activation/CLOCK-RESULTS.md#original-duties-and-remaining-work)
and [persisted](../verification/settings-activation/PERSISTED-RESULTS.md#every-original-duty-and-remaining-work).

| Duty | Disposition at this design boundary |
|---|---|
| Historical callback/failed-activation classification and persisted symptom preservation | Preserved; no historical byte or classification changes |
| Supported condition, matched intervention and two finite falsifiers | Not established; escalated explicitly, not discharged by the narrow probe |
| Positive failed actual request/native disposition/responsible context | Still required under the current charter; unresolved. Only Antony may approve the proposed prerequisite amendment |
| Qualified acquisition/configuration/lag and changed-instrument availability/symptom/timing | Historical capabilities and limits preserved; no new runtime qualification |
| Actual signed subject/all consumed inputs/completed golden freeze | Still required before any future launch, after all design/review/integration work; no final subject selected here |
| Failed transport, partial archive, every started attempt and NOT RUN retention | Preserved separately from scenario results; timeout/nonzero text remains failed |
| Original/endpoint/golden audits and exact clone stop | Required for future runs; historical duties and results unchanged; no clone in this design |
| Justified application repair and useful failing product seam | Unmet; recorder/reader controls are not a failing product seam; no driver waits/retries/repeated-input repair |
| One selection, one front/focused Settings window | Required behavior unchanged |
| Separate finite complete ordinary acceptance | Still required through app:vm-verify-menu-bar, final ordinary signed subject/all-input/completed-golden freeze, diagnostics disabled, every outcome retained and timing addressed |
| External evidence/reproducer/approval | No external owner established; positive evidence/reproducer required for attribution, repair unresolved if external; no upstream report without Antony's approval |
| Closed historical caps and unrun ordinary phases | All closed caps stay closed. Persisted reopens 2/3, resize/minimum-size/content-height/scrolling, shortcuts, requests/denials, consent, silent launch, running-app reopen, login restart and Quit stay NOT RUN |
| Ancestor closure/release | No causal ancestor closes from this design; no release or notarization |

Persisted scenario/inner Task 1/201, native/collection/audit 1/1/1, outer Task 201
and post-trace timeout/-1 remain failed outcomes. Original strict false/empty
clock joins remain unchanged. The existing runtime owner retains the enclosing
readiness/freeze/audit/cleanup wrapper and every unresolved product/ordinary duty.

## Review and resumption

This design requires independent tree review and every earned integration before
the runtime owner may proceed, including before route qualification. Review must
challenge the no-experiment conclusion against the paired positive evidence and
check that the proposed scope amendment is neither silently accepted nor an
unjustified workaround. No in-session reviewer runs beside that review.

The scope decision must be recorded explicitly. An accepted amendment requires
a coherent replacement design, exact comparison against the original duties and
its own earned review before any guest. Retaining the original requirement keeps
the present hold until new independent evidence supports it. The design and its
review cannot themselves close the causal repair ancestors.

## Verification record

The [verification receipt](../verification/settings-activation/discrimination-evidence/verification.json)
records the documentation check and per-input digest comparison. Its
[raw output](../verification/settings-activation/discrimination-evidence/doc-links.txt)
retains all reported failures. The browser presentation was inspected in Chrome
at the current-discussion view and both rendered diagrams, including a fresh
direct link to the scope view. This is document/presentation verification only;
no AppKit, guest, activation, timing or product-repair acceptance is claimed.
