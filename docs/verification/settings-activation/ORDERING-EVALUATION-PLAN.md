# Empirical Settings ordering evaluation

## Decision and execution boundary

This is the concrete design under the [accepted empirical scope](../../specs/settings-activation-discrimination.md#scope-after-no-candidate).
It selects one candidate: prepare the retained Settings window and requested
section, request self activation once, then request key/front window ordering
in the same main-actor invocation. The [behavior contract](../../specs/settings-activation-discrimination.md#single-request-ordering-design)
owns caller effects and API limits; the [design evidence](ORDERING-DESIGN-EVIDENCE.md)
identifies the inspected implementation and contracts.

The [k50 review and k51 integration](ORDERING-REVIEW.md) settle the design's
evidence and setup rules. K36 owns implementation of the application change,
the changed scenario/helpers and the finite caller, with verification before
freeze. The [application implementation](ORDERING-APPLICATION-RESULTS.md)
compiles and passes existing headless controls. Shared harness repairs and the
finite caller remain live. No signed bundle or runtime result is supplied here.

The question is whether that candidate meets the agreed behavior over the fixed
sets below. It is not a comparison of failure rates or an attempt to identify
native cause. There is one arm, no original-order baseline, no ABBA repetition,
no preliminary guest and no adaptive sample. Historical [ORDER-RESULTS](ORDER-RESULTS.md)
remain inconclusive, symmetric, file-traced evidence. The [six causal slots](CAUSAL-PLAN.md)
remain held with unchanged criteria, subjects and caps.

## Fixed sets and subject

The [keepalive coordination hold](../../specs/settings-activation-discrimination.md#keepalive-coordination-hold)
binds helper consumption and all readiness, freeze and runtime work.
The [accepted scope](KEEPALIVE-DESIGN.md#required-scope-decision) permits design
of one serialized owner, logged UI-independent ownership delays and deferred
keepalive ticks, an enforceable finite resource profile, and a separately
recorded cooperative normal stop. Required capture qualification before later
scenario dispatch, first-failure eligibility and private original retention
remain binding. This is design authority only: concrete design, independent
review/every integration, planning, implementation and earned review/integration
still precede consumption. The proposed [owner and lifecycle contract](../../specs/settings-keepalive-owner.md)
defines reviewed ownership, stop races and record fields. Its
[scheduling proposal](../../specs/settings-keepalive-owner.md#scheduling-and-deadline-profile)
now fixes receive-order service and exact deadlines, pending independent review.
Enforceable resources and whole-design reconciliation remain outstanding. No slot is admitted.

Declare both sets and their exact slot identities before the first clone request.
Reserve the distinct namespace `ordering-evaluation` for the focused set and
`ordering-ordinary` for complete acceptance. Run serially, with one writer.

| Set | Fixed slots, in order | Required work per fresh guest | Admission to next slot or set |
|---|---|---|---|
| Focused evaluation | E01, E02; at most two started guests | Existing first-launch and TextEdit preparation, initial Settings selection and reopens 1–3; stop before resize | Every required assertion, observation, transport, audit and exact stop in the preceding slot passes |
| Separate ordinary acceptance | A01, A02, A03; at most three started guests | One complete existing `app:vm-verify-menu-bar` scenario, including its later phases and restart | Both E slots qualify before A01; each preceding A slot must qualify before the next |

Two focused guests provide a bounded early behavioral check; three complete
guests exercise the full caller/lifecycle scenario in separate fresh clones.
These numbers are selected conventions under Antony's agreement. They do not
come from a failure-rate estimate, independence assumption, confidence target or
prediction that five successes exclude intermittent failure. A single passing
slot is insufficient; even all five support only their own sample.

Use one newly built, Developer-ID-signed, unnotarized current-source candidate
labelled 0.4.0, with the sole Settings behavior change above. Freeze it at
`.build/settings-activation/ordering-evaluation/Koine.app`; use those exact
bundle bytes for all E and A slots. Do not rebuild, re-sign, recopy from a mutable
build output, alter preferences to enable diagnostics, or change helpers between
sets. The path is a proposed destination, not an existing qualified subject.
Preserve all historical bundles, especially `events/Koine.app`.

Record the actual source commit, full source/build-input inventory, signing
identity/Team ID, designated requirement, bundle and executable UUIDs, complete
file hashes and symlink targets, and signature verification results before any
launch. A version label or source diff alone cannot identify the subject.
The ordinary set has its own declaration and readiness receipt before A01,
revalidating the same candidate and all inputs; focused results cannot fill it.
Any subject or protocol change after E01 starts ends this evaluation unresolved
unless a qualified recurrence has already rejected it. It earns no replacement
evaluation or ordinary set. Return the gap for a new explicit scope decision.

## Matched observable setup

All slots use fresh clones of the same stopped
`testanyware-golden-macos-27` image: macOS 27.0.1 build 26A434, arm64,
TestAnyware 2.7.0, initial display 1920×1080, disposable admin account, one active
Space, no restored application/session state, no pre-existing Koine data or
diagnostic preferences. Verify the actual image and tool versions before clone
creation and the actual guest environment after boot. A mismatch holds the
sequence; silently substituting a newer environment is not this design.
The ordinary scenario's existing restart may reset display to 1024×768;
record the actual result and continue only under its existing geometry checks.
Do not force a display change after restart to obtain a pass.

Use the existing no-quarantine installation route and automation setup. It does
not exercise Gatekeeper's quarantined first launch or establish release fitness.
The application starts with Accessibility not granted and login launch disabled.
First launch must show exactly one titled Settings window at the existing
default size, with one menu item and no Dock icon. Retain all existing assertions.

K36 must change the current scenario and its helpers to implement the transport,
positive setup, title-audit and liveness rules below. These are required evidence
repairs, not existing helper behavior. Retain every existing ordinary assertion,
input action, fixed settling wait and state-poll bound. Replace hidden transport
retries and ignored failures as specified below; add no focus wait or input retry.
Freeze this changed complete scenario and extract its prefix for E from those
same bytes. Both sets use identical helpers and predicates through the four
Settings actions **and the existing TextEdit quit**, ending E immediately before
the resize step. Verify that exact prefix correspondence before freeze. Do not
copy a historical prefix or add the repairs only to E.

For each of those four selections, close Settings once and establish zero visible
Koine windows. TextEdit must be the front application, with its same idle untitled
document and no dialog, sheet or menu. Use the existing first TextEdit launch,
window move and fixed settling steps; subsequent close/reopen cycles retain
that document and position. Record the positive precondition before opening
Koine's menu. An unexpected front app, panel or document is failed setup; do not
repair it with focus input, a wait extension or a repeated selection. The initial
selection has no earlier successful menu selection; reopen 1 follows one, and so
on. This preserves the observed histories without calling them causal controls.

Use these fixed precondition oracles immediately before each of the four menu
openings, after the existing close/count check and without an added settling wait:

| Required fact | Retained observation and decision |
|---|---|
| No visible Koine window | A clean full agent window list contains zero entries for Koine. Retain the list used by the existing zero-count check. |
| TextEdit is frontmost | A clean System Events read names TextEdit as the frontmost process, with its PID equal to the TextEdit PID captured after initial preparation. A merely non-Koine front app is insufficient. |
| The same idle untitled document | The full agent list has exactly one TextEdit window, of type `standard`, titled `Untitled`, with the same position and size recorded after the initial move/settle. The scenario has made no document or typing action since preparation. This observable tuple and unchanged TextEdit PID are the continuity criterion; the agent list has no stable window identifier and proves no hidden document identity. |
| No dialog or sheet | One clean System Events read of TextEdit's windows supplies their subroles and sheet counts. Require one `AXStandardWindow`, no extra window and zero attached sheets. An `AXDialog`, `AXSystemDialog`, extra panel/window or sheet is failed setup. Missing attributes or incomplete enumeration are unavailable. |
| No open menu | A clean System Events enumeration of the menus exposed under the TextEdit and Koine menu-bar items reports zero open menus. Retain each item's count and completion of the enumeration. Missing or inaccessible menu data is unavailable, not zero. This is the same read-only menu boundary used for selection and closure; it sends no Escape or other input. |

Retain a precondition screenshot with these observations. The structured checks
must pass before opening the menu; the screenshot is supplemental visible
context, audited after the slot and before admitting the next. An observed
conflict invalidates setup. Add no human-response pause, focus action or settling
delay. A clean mismatch is failed setup; missing, conflicting or unreadable
required evidence is unavailable setup. Neither permits re-preparation or a
replacement capture to obtain a pass. These are observable setup criteria, not
proof of absent hidden state. Qualify their availability in E01 as specified below.

Fresh clones and matching observable setup do not match hidden native state or
make selections independent. The complete scenario deliberately changes setup
later to exercise requests, consent and login; those transitions are its tests,
not mismatched replacements for the focused setup.

## Input and observation qualification

Use the existing physical-pointer route for each Settings or status-line menu
selection: one menu opening, the current item's geometry, the existing approach
and centre moves, and one click. Record the requested item identity, its current
enabled state and frame, derived coordinates, display bounds and each raw input
result. Retain a screenshot of the open menu before the row click and the menu
closed/window outcome afterward. This adds observation at the agreed UI seam,
not a new in-app monitor. No Return route, AXPress, direct callback, activation
command, focus operation or replacement input is permitted for these selections.

Record the raw window list used by each existing count/front/focus assertion,
not a later recreation. Preserve the scenario's bounded observation polls and
fixed waits, including its post-click delay; add no UI-conditioned wait or
success retry. The sole new admission-delay scope is command ownership under
the fixed policy described in [Diagnostics and timing](#diagnostics-and-timing). A
successful observation that the expected window is not yet visible may continue
within the existing count-poll bound. Failed transport is different and stops
the slot. The existing front/focus predicate runs once at its existing point:
the first window outside Notification Center belongs to Koine and has
`focused:true`. The existing count predicate separately counts all Koine windows,
without checking their title. Retention alone strengthens neither predicate.
Add a title/identity audit of that same full front/focus list: it must contain
exactly one Koine window, titled `Koine Settings`, and that entry must be the
front/focused entry. This audit is required for acceptance of each return,
including later ordinary returns. A wrong title is a separate window-identity
assertion failure; missing fields are unavailable evidence. Do not re-read to
replace a failed list. Preserve both old predicate results and the new audit.

Retain an outcome screenshot before any subsequent close, focus, keyboard action
or launch. Screenshot collection must not replace the assertion's earlier raw
window result with a later favorable state. After a failed assertion, make one
fresh read with the existing independent failure observer, one agent-window read
and one screenshot before other collection. Preserve original and subsequent
observations with their order, time, PID and raw status. No corrective input or
second assertion follows. If the observer is unavailable, retain that failure;
never use its text from timeout/nonzero transport as a successful read.

An outcome screenshot is retained evidence, not an automatic acceptance
assertion. Acceptance requires the clean window predicates and title audit plus
a readable retained screenshot; it does not infer focus from pixels. A visible
conflict discovered in the screenshot makes the outcome unresolved. Rejection
additionally requires the explicit visual corroboration below.

**A qualified behavioral recurrence** needs the frozen subject/setup, current
enabled target and valid geometry, one clean issued row click, a closed menu,
and clean original window/count/focus evidence plus a corroborating outcome
screenshot that show the required return failed. Zero windows after the existing
bound with the same Koine process still alive, multiple Settings windows, or a
sole Settings window behind/unfocused each fails the behavior. For the zero-window
branch only, make one clean process read during untouched failure capture and
compare the Koine PID and process start identity recorded before the click. Use
the existing guest process-inspection seam and retain the exact executable path,
PID and start identity in both reads. A missing process or changed identity is
`process lost during selection`, a separate assertion failure that prevents
acceptance but does not qualify a Settings recurrence. An unavailable identity
or failed liveness read leaves the result unresolved. A stale endpoint file is
not liveness. Do not relaunch or repeat the selection. This does not distinguish
a crash from a Quit misclick, and makes no claim of callback delivery.
This qualifies the UI result of the requested selection; it does
not prove callback dispatch identity, the count of native requests, native refusal
or an activation subsequently lost. Missing route evidence, an open menu, invalid
geometry, conflicting observations or failed essential observation transport makes
the result unresolved. Do not turn it into a native classification.

Any qualified Settings recurrence anywhere in either set rejects reversal,
including an ordinary Settings selection outside the focused prefix. A clean
failure of another required assertion prevents acceptance but is recorded under
that assertion, without inventing a Settings recurrence. A qualified recurrence
is not erased by a later failed native capture, archive, audit or cleanup; record
both. Evidence sufficient for rejection need not be sufficient for acceptance.

## Required transport and evidence handling

K36 must replace the scenario's uses of `guest`, `guest_text`, `guest_once` and
bare discarded exec results with raw single-attempt adapters at the existing
helper boundary. This includes setup, installation, defaults, System Events,
launch, restart and final collection. The legacy twelve-attempt `guest` path is
not admitted to either set. Idempotence alone does not authorize repeating failed
evidence acquisition. No text stripping, `|| true` or later successful read may
clear a failed required transport.

For every attempt retain the command, exact VM identity, operation/class, ordinal,
start/end times, stdout, stderr, CLI exit and complete raw response. Guest exec
uses its JSON response: clean means CLI zero, `ok:true`, `timed_out:false`,
`exit_code:0` and complete command-specific payload. Reject absent/malformed
fields; preserve the whole original, not only decoded text. Agent/input/capture/VM
commands likewise need successful completion and their full expected payload
or output artifact. Do not infer success from exit zero alone.

| Transport class | Bound and meaning |
|---|---|
| Read-only state poll | Keep only the existing scenario/helper poll count and delay. Every poll is one clean read. A complete negative state may advance to the next existing poll; a transport failure immediately latches unavailable. No nested twelve-try transport loop. `await_windows`, endpoint/boot polling and `koine_in_front` must keep read failure distinct from false state. |
| One-shot command | Submit exactly once. Require clean completion and the command-specific downstream confirmation below. A downstream success cannot rehabilitate failed submission. Never repeat launch, defaults writes, menu input or restart. |
| Required evidence acquisition | Window lists (including poll inputs), screenshots, setup/route records, inventories, environment/default reads, failure observer, process identity and stop evidence each require a clean single attempt. Failure latches unavailable; subsequent collection preserves context only. A window list used as a poll must meet this class on every poll. |

Negative domain facts travel in a complete successful payload: absent diagnostic
key or endpoint, absent process, count zero, unchanged boot identity and the
expected curl connection-refused code 7 are data. They are not permission to
accept CLI 7, guest errors, timeout or partial text. Ordinary state polls may
continue on the clean negatives their existing predicates admit. An exhausted
clean poll bound is the named state failure; an errored poll is unavailable.

| One-shot operation | Required confirmation after clean submission |
|---|---|
| First Koine launch | Endpoint descriptor/process identity and the existing one titled window, size, menu and Dock assertions. |
| Silent launch after setup | Endpoint/process identity, existing settling wait, zero-window and menu assertions. |
| Open of running Koine | Same process remains, one titled front/focused window. No second `open`. |
| TextEdit launch/quit and other setup actions | Existing window/state consequences, plus the positive precondition above. The prefix includes the one quit; require its clean completion and one clean process-absence observation. |
| Menu open and row click | Each input's clean raw completion, the current enabled item/frame/coordinates, open-menu screenshot, subsequent closed menu and original window outcome. Delivery is not callback proof. |
| Defaults write or other configuration mutation | Clean write plus one clean read of the exact expected key/value or absence. The diagnostic keys remain absent; no enabling write is permitted. |
| Restart | The existing `shutdown -r now` is submitted once. Require clean submission, then changed boot identity within the existing 30-second wait and 60-by-5-second poll bound, followed by the existing login assertions. A disconnect, timeout, CLI 7/255, missing envelope or guest nonzero is unavailable, even if reboot later occurs. No delayed shutdown, detached launcher or substitute reboot route is selected. |

An unlisted required operation uses the strict one-attempt rule and its existing
assertion. K36 enumerates the exact call sites and payload schemas before freeze;
it cannot add tolerated error classes. In particular, the agent's known false
timeouts can end a slot early, and restart may never supply clean submission.
That availability cost is accepted visibly under the existing evidence rule;
no passing evaluation is promised. If implementation evidence establishes that
a required command cannot supply the declared clean result, hold before E01 and
return that precise gap for a new decision. Do not consume guests to qualify a
different transport or silently relax this standard.

On any latched failure stop scenario input, retain untouched failure evidence,
audit and stop the exact clone. Collection continues only to preserve evidence
and contain the clone. Keep scenario, inner/outer Task, collection, endpoint,
environment, audit and stop results separate. A scenario zero cannot override
an evidence failure; cleanup success cannot requalify a failed trial.

The approved worker-stop design may distinguish a cooperative stop between
captures after declared normal scenario completion. It requires a separate
lifecycle record matched to the owned worker and confirmed exit, never a clean
tick or retrospective reclassification. Earlier failures, unexpected exits,
interrupted required captures and missing lifecycle records still prevent
acceptance. Preserve exact signal/status and any in-flight attempt or partial.
The proposed lifecycle slice and its remaining numerical/resource profile must
receive whole-design review before use; current sleep-interruption receipts still
latch. Suppress future ticks before
collection and resolve owned holders through the same domain. A stuck or unknown
holder leaves containment unresolved and all later slots NOT RUN.

The finite resource profile must enforce its stated producer, validator and
aggregate limits with separate final-record/cleanup capacity. Reaching a limit
stops acceptance and later scenario dispatch. Retain all produced originals and
partials; do not truncate, overwrite, delete, downsample or omit required images.
Post-capture size checks and streaming validation alone do not bound prior
external-producer work. Record any preservation or collection that storage or
process failure makes unavailable. No numerical limit is selected here.

At the existing focused-helper seam, use actual retained failed envelopes and
controlled transport responses to check partial JSON, timeout with matching text,
nonzero status, missing completion marker, unexpected extra/missing inventory
entries, interruption and exact clone cleanup. Check all three transport classes,
each one-shot confirmation, a clean negative state poll that continues, and a
failed poll that stops without another scenario command. Check restart disconnect
followed by a changed boot remains unavailable, hidden helper retry is rejected,
and both E/A use the same setup/title/liveness rules. A passing envelope cannot
hide an earlier failed one; a failed scenario cannot skip collection/stop. These
are meaningful evidence-handling checks, not a simulated native product repair.
No new public product interface or OS-response fake is selected.

## Diagnostics and timing

Both sets run ordinary application behavior: `KOINE_SETTINGS_TRACE` unset;
`KoineSettingsActivationTrace` and `KoineSettingsEventBuffer` absent from the
effective defaults; `KoineSettingsMenuProbe` absent/false. Reject conflicting
global/managed defaults or injected arguments/environment. Verify the launch
inputs and guest defaults before first launch and their retained values after
the slot; include restart persistence in each A slot. Absence must be a clean
observation, not a failed defaults command interpreted as absent.

No native Debug configuration, live logging/formatting sidecar, buffer dump,
tracking timer or diagnostic file is enabled. The existing disabled trace calls
and one-call activation wrapper remain in the signed product. Source inspection
must confirm the disabled branches create no observer/timer/output or tick
measurement. Do not call this an instrument-free application or neutral timing.

The host transcript, precondition/menu screenshots, ordinary polling, VNC
keepalive and post-assertion captures still add work and delays. The accepted
coordination scope additionally permits logged waits determined by command
ownership and fixed policy, independent of observed UI state, focus or outcome.
A Settings click may wait behind a capture and its full qualification. The
existing sleep-20 schedule may defer its due capture until ownership is available;
actual tick cadence changes. Keep input order, explicit sleeps, poll counts and
one-attempt transports unchanged. There is no UI-conditioned wait, focus/success
retry, tick omission to avoid contention or repeated input.

The concrete design must define and report the admission/dispatch timing,
deadlines, pending-work bound, tick policy and normal-stop outcomes. An expired
deadline stops acceptance and further dispatch; it cannot retry or resubmit work,
silently drop a tick or relabel an interrupted required capture as cleanup.
Neither serialized dispatch nor a chosen deadline establishes a safe native
idle interval. Command connection activity, post-CLI validation and total lock
duration remain distinct. These delays can affect the intermittent symptom.

The same reviewed observation and scheduling policy applies in E and A and is
frozen before E01. Historical
ordinary-route failures establish that the broad end-to-end seam has exposed
the symptom; the new candidate/capture combination has no preservation proof
before it runs. A qualified recurrence demonstrates preservation for that
combination and simultaneously rejects the repair. If every slot passes,
preservation remains unknown; report bounded observed behavior only, never
elimination or comparative improvement. This does not waive qualification of a
new diagnostic instrument: none is admitted here. A need for one holds runtime
for a separately reviewed proposal; these slots cannot be spent qualifying it.

In E01, qualify availability in the existing successful first-launch/closed-window
states: complete raw window lists, correct titled window and zero-window counts,
readable screenshots, and positive TextEdit-front precondition. Source/fixture
checks precede this guest. A failed availability control consumes E01 and stops
both sets, without replacement. Success qualifies only those observations;
no synthetic failure or native completeness follows. The existing independent
native observer remains supplemental failure capture, not the success predicate.

## Freeze, audit and exact cleanup

Before any clone request, finish all edits and enumerate every consumed input:
candidate/source/package locks/build scripts and configuration, Taskfile,
scenario/extracted prefix/helpers/tests, this protocol, finite wrapper and evidence
classifier, signing/installation settings, observer source/binary, CLI and decoder
versions, launch defaults/environment and the stopped golden config/disk/NVRAM.
Keep complete relative-path file/link inventories, hashes and the actual golden
digests with a completion time strictly before the first clone request. No
background freeze that overlaps launch, mutable input, second writer or reused
output directory. An omitted required input prevents admission, not a later
opportunity to reconstruct its old bytes.

Include the completed, independently reviewed coordinator and resource design,
its implementation and controls, fixed scheduling/deadline/tick policy,
producer/validation/retention limits, capacity reservations and worker-stop
schema in that freeze. The agreed scope supplies none of those qualified inputs.
If a necessary native capability experiment emerges, it needs separate explicit
reviewed scope; neither E nor A is a budget for discovering replacement limits.

The declaration maps E01/E02/A01/A02/A03 to exact clone IDs
`koine-k49-ordering-e01`, `koine-k49-ordering-e02`,
`koine-k49-ordinary-a01`, `koine-k49-ordinary-a02`,
`koine-k49-ordinary-a03`, and unique output directories under the corresponding
namespace. A slot is consumed immediately before invoking its clone-start command,
even if startup/setup fails. Record every requested clone and any actual returned
identity; do not start another clone to replace one with uncertain creation.

Audit host inputs/bundle before and after every slot, and installed regular-file
hashes/symlink targets independently at both endpoints. Attempt final inventory
on early failure after untouched outcome capture. Retain raw originals, partials
and any available archive, with a manifest comparing each saved artifact to its
original; do not fabricate a native archive when logging was not requested.
Recheck the completed stopped golden inventory before A01 and after the sequence,
comparing each item, not merely totals. A mismatch prevents acceptance.

An exit/signal handler collects available evidence and stops only the exact clone
this slot requested. Retain stop response, CLI status and an independent VM
inventory showing that identity stopped. A failed stop leaves cleanup unresolved
and blocks further slots; use only exact-identity containment, recording any
additional cleanup action separately, never as a successful trial retry. Do not
stop an unrelated guest or delete evidence. Stopping the clone is not the product's
Quit assertion. Every unused action, phase and later slot is explicitly NOT RUN.

## Stop rules and outcome consequences

Evaluate outcomes in this precedence order; retain all lower-level failures too.

| Observation | Consequence |
|---|---|
| Qualified Settings recurrence in any started slot | Reject reversal as the repair. Stop further scenario input and all later slots; capture/audit/stop the current clone. Cause and ownership remain unresolved. |
| No qualified recurrence, but any failed ordinary assertion or required setup/control | No acceptance. Record the exact failure and later NOT RUN phases; stop the entire sequence. Do not infer that reversal caused a different failure. |
| Missing, invalid, conflicting or failed required evidence/transport/audit/stop, including interruption | No acceptance; unresolved, not automatically a product failure. Preserve partials and stop further slots. |
| E01 and E02 both pass all required work | Focused sample passes; declare/revalidate ordinary readiness and proceed to A01 only. No repair acceptance yet. |
| All E and A slots pass every required assertion and evidence duty | Accept the candidate only under the agreed finite behavioral convention. Report each slot and assertion; no elimination, rate, mechanism, API violation, ownership or general reliability claim. |

No early success closure, replacement, cap expansion, failure-chasing baseline,
input retry or successive workaround follows any row. A rejected or unavailable
evaluation leaves the repair obligation live for an explicit next decision.

## Complete ordinary acceptance and preserved duties

Each A slot runs the complete current `app:vm-verify-menu-bar` entry point. It
must include first launch/menu/Dock behavior, all four TextEdit selections,
actual corner growth and minimum size/content height/scroll reachability,
shortcuts and close, client requests without unsolicited window opening,
request/Accessibility status-line navigation, denials and consent, silent launch
after setup, running-app reopen, Command-Q, login restart, silent login, final
menu Quit and refusal on the old server port. Required screenshots, raw outcomes,
before/after inventories and cleanup all count. No focused prefix, diagnostic
wrapper, or prior passing phase substitutes for any A-slot assertion.

The [complete original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
is binding. Native condition/intervention/disposition and clock claims remain
unmet; k42 amended their role as repair prerequisites, not their evidence.
K46 additionally amended only the API-use-mismatch prerequisite for this named
ordering hypothesis. K93 permits the narrow ownership-based admission-delay and
normal-stop design, requires a finite resource profile, and preserves the
required-capture barrier and every original helper/adoption/containment duty.
Historical bytes, classifications, strict false joins,
failed transports, NOT RUN phases and every closed cap are unchanged. A design
or passing instrument control closes no product or causal ancestor. No release,
notarization or upstream report is included.
