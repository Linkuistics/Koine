# Empirical Settings ordering evaluation

## Decision and execution boundary

This is the concrete design under the [accepted empirical scope](../../specs/settings-activation-discrimination.md#scope-after-no-candidate).
It selects one candidate: prepare the retained Settings window and requested
section, request self activation once, then request key/front window ordering
in the same main-actor invocation. The [behavior contract](../../specs/settings-activation-discrimination.md#single-request-ordering-design)
owns caller effects and API limits; the [design evidence](ORDERING-DESIGN-EVIDENCE.md)
identifies the inspected implementation and contracts.

**Design only; independent review and every earned integration precede product
implementation or runtime.** The implementation owner must produce and verify
the finite caller and its evidence handling before freezing a subject. This
document does not identify a built bundle or authorize a launch now.

The question is whether that candidate meets the agreed behavior over the fixed
sets below. It is not a comparison of failure rates or an attempt to identify
native cause. There is one arm, no original-order baseline, no ABBA repetition,
no preliminary guest and no adaptive sample. Historical [ORDER-RESULTS](ORDER-RESULTS.md)
remain inconclusive, symmetric, file-traced evidence. The [six causal slots](CAUSAL-PLAN.md)
remain held with unchanged criteria, subjects and caps.

## Fixed sets and subject

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

The focused set is the current complete scenario's prefix through its four
Settings actions, not the historical frozen order-prefix file. Its build must
verify that the extracted prefix has the same commands, waits and predicates as
the frozen complete scenario, apart from evidence retention and its deliberate
termination before resize. Do not copy a stale historical prefix into a new run.

For each of those four selections, close Settings once and establish zero visible
Koine windows. TextEdit must be the front application, with its same idle untitled
document and no dialog, sheet or menu. Use the existing first TextEdit launch,
window move and fixed settling steps; subsequent close/reopen cycles retain
that document and position. Record the positive precondition before opening
Koine's menu. An unexpected front app, panel or document is failed setup; do not
repair it with focus input, a wait extension or a repeated selection. The initial
selection has no earlier successful menu selection; reopen 1 follows one, and so
on. This preserves the observed histories without calling them causal controls.

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
fixed waits, including its post-click delay; add no wait or success retry. A
successful observation that the expected window is not yet visible may continue
within the existing count-poll bound. Failed transport is different and stops
the slot. The front/focus predicate runs once at its existing point: the first
non-Notification-Center window must be the sole visible Koine Settings window
and have `focused:true`. Retain the full unfiltered list and the exact predicate
result, so an unrelated Koine window cannot satisfy it.

Retain an outcome screenshot before any subsequent close, focus, keyboard action
or launch. Screenshot collection must not replace the assertion's earlier raw
window result with a later favorable state. After a failed assertion, make one
fresh read with the existing independent failure observer, one agent-window read
and one screenshot before other collection. Preserve original and subsequent
observations with their order, time, PID and raw status. No corrective input or
second assertion follows. If the observer is unavailable, retain that failure;
never use its text from timeout/nonzero transport as a successful read.

**A qualified behavioral recurrence** needs the frozen subject/setup, current
enabled target and valid geometry, one clean issued row click, a closed menu,
and clean original window/count/focus evidence plus a corroborating outcome
screenshot that show the required return failed. Zero windows after the existing
bound, multiple Settings windows, or a sole window behind/unfocused each fails
the behavior. This qualifies the UI result of the requested selection; it does
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

The existing helpers are the test boundary, not already a complete acceptance
instrument. `guest_once` can discard a failed launch result; `guest_text` can
strip a timeout and parse its text. Before runtime, the finite caller must retain
the actual command, exact VM identity, stdout, stderr, CLI exit and any raw JSON
envelope for every attempt, including those currently hidden by these helpers.
Required failed/timeout/incomplete transport must latch an unavailable outcome
and stop the scenario before a retry. A later success or matching returned text
cannot clear that result. Keep the existing bounded polls on clean observations;
do not confuse a clean negative state predicate with failed transport.

Declare operation-specific expected outcomes before freeze. Examples include
absence of a diagnostic key and the scenario's expected connection-refused result
after Quit. Encode a clean negative observation in a successful envelope rather
than accepting arbitrary nonzero transport. The existing one-shot restart still
executes once; an unconfirmed transport remains unavailable even if a later boot
appears. No runtime exception may be invented for a troublesome command.
Keep scenario, inner/outer Task, collection, endpoint, environment, audit and
stop results separate. A scenario exit of zero cannot override an evidence failure.

At the existing focused-helper seam, use actual retained failed envelopes and
controlled transport responses to check partial JSON, timeout with matching text,
nonzero status, missing completion marker, unexpected extra/missing inventory
entries, interruption and exact clone cleanup. Also check that a clean negative
state poll can continue and a failed transport cannot. A passing envelope cannot
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
keepalive and post-assertion captures still add work and delays. The same
observation policy applies in E and A; it is frozen before E01. Historical
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
ordering hypothesis. Historical bytes, classifications, strict false joins,
failed transports, NOT RUN phases and every closed cap are unchanged. A design
or passing instrument control closes no product or causal ancestor. No release,
notarization or upstream report is included.
