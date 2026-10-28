# Settings row-selection protocol

## Execution boundary

This is k38's implemented replacement for the unstarted k34 proposal, repaired
by [k41's integration](CAUSAL-PROTOCOL-REVIEW.md). The
[complete prior proposal](CAUSAL-PLAN-K34.md) is retained unchanged.
**No guest has run. No runtime freeze or launch is authorized by this artifact.**
The producer's tree review and every earned integration precede k36. A separate
causal-design leaf must resolve the precise competing-prediction gap below before
*any* route-qualification or causal guest. The implementation makes a narrow
question testable; it does not claim to satisfy k33's original causal duty.

Explicit changes to the unstarted proposal: add one prior successful mouse
Settings-selection/close control; replace the one-selection limit with exactly
one setup selection and one measured reopen, plus unavoidable first-launch
activation; add two separately capped route-qualification slots; implement the
highlight and direct-delivery criteria; state provisional/deferred native-control
policy. The four unstarted modality positions retain mouse/Return/Return/mouse
order. None of the historical closed caps is reopened, replaced or enlarged.

## What the evidence permits

[CAUSAL-RESULTS.md](CAUSAL-RESULTS.md#independent-saved-input-context) retains the
positive paired native contrast. Successful-adjacent native context has TextEdit
inactive-key appearance, Koine active-key appearance and conditional ordering
op 1 relative 0. Failed-adjacent context has TextEdit active-key appearance and
Koine conditional ordering op -1 relative 32. Both contain deferred mouse
activation. These private op values have no established semantic contract; they
are observations, not refusals. Failure to identify a counterpart proves no
absent event. Keep the complete native timeline and the
[paired rows](causal-review-evidence/paired-native.json), including processing
after activation return. The older marker counterexamples remain valid.

Persisted reopen 1 followed a successful initial menu selection and close.
Match that history once in both arms. First-launch activation is a different
control and cannot replace the prior menu selection. ORDER A01 also failed
initially, so prior history is not a demonstrated necessary cause. A failed
setup ends the slot; it does not justify repeating setup until green.

## Competing predictions and the remaining question

| Claim | Positive prediction | Finite falsifier and limit |
|---|---|---|
| Hclick: clicking the Settings row is necessary for the observed failure | Every qualified failed measured reopen has a row click | A qualified Return-origin callback, exact enclosed actual client call, and independently observed inactive/behind/no-key failure after matched successful setup refute necessity. A missing log or stale currentEvent does not. |
| Hshared: shared mouse-open/native context can permit failure regardless of row-selection modality | A qualified failure may occur in either arm | This possibility has **no finite falsifier in the supported four-slot comparison**. Green counts, source-label changes, mouse failure/Return success and different private op fields do not refute it. It is not a valid competing experimental prediction under k33. |

These are not a completed two-sided experiment. No evidence supports replacing
Hshared with a deterministic claim that the two arms must produce identical
outcomes or private-field sequences. Nor does Hclick establish why any request
failed. The narrow probe can refute necessity only. Mouse failure/Return success,
all-green, all failures, unmatched controls and unavailable route/clock outcomes
remain inconclusive for native responsibility and repair.

The externalized design question is: **Which independently supported,
controllable foreground/window/native interaction can be matched and intervened
on, with positive observations and a finite falsifier for each competing causal
prediction, rather than merely testing row-click necessity?** It must account for
the paired appearance/ordering context without undocumented semantics and decide
whether the narrow slots below earn runtime at all. It may specify a different
finite set before launch, with an explicit comparison of changes; it cannot
quietly spend these slots or a qualification guest to look for a hypothesis.
If the evidence cannot answer it, escalate the scope decision to Antony rather
than declaring this one-sided probe a cause or cutting endless richer monitors.
No guest starts while that question remains unresolved.

## Implemented observation and input route

`SettingsMenuProbe` runs only when memory diagnostics are configured, file tracing
is absent, and `KoineSettingsMenuProbe` is true. Before launch create the fixed
empty guest directory `/Users/admin/settings-menu-probe`; set the memory path
and opt-in boolean. No host GUI is involved. The probe reads no arbitrary path
or command from a request. One UUID identifies one immutable response, with a
16-request lifetime budget. A timer polls at 0.1 seconds in AppKit's event-tracking
run-loop mode, at most 80 polls per menu opening. It reads only the fixed request
file and `NSMenu.highlightedItem`, writes one response without overwriting, then
stops. Closing the menu stops the timer and local monitor. Unsupported delivery,
I/O or expiry yields no qualified receipt, never a fallback input.

The getter reports the actual highlighted item. Its identity must be the enabled
Settings item whose action is `chooseSettings`. This avoids assigning menu
highlight semantics to an AXSelected/checkmark property. See Apple's
[highlight contract](https://developer.apple.com/documentation/appkit/nsmenu/highlighteditem)
and [tracking mode](https://developer.apple.com/documentation/foundation/runloop/mode/eventtracking).
Raw primary API JSON and the
[API receipt](protocol-evidence/API-SOURCES.md) are retained. This path adds
preselection timer/file/monitor work; it proves no timing neutrality.

Use `causal-protocol.py select` only after the reviewed caller's readiness checks
and after opening the status menu once with the settled `open_menu` route.
The implemented command fixes the remaining sequence:

1. Read geometry once, retaining the complete raw exec envelope. The exact JXA
   command is `FRAME_COMMAND` in the source: System Events → Koine → menuBars[1]
   → menuBarItems[0] → menus[0] → menuItems.byName("Settings…") → position/size.
   No setter, AXPress or foreground operation occurs. Validate four integers,
   positive size and containment in the frozen 1920×1080 display. Record the
   frame and integer centre. The same coordinate derivation applies in both arms;
   concrete coordinates are observed facts, never adjusted after an outcome.
2. Move once to centre minus (12,8), bounded at zero; wait 0.3 s. Move once to
   centre; wait 0.3 s. No click yet. Preserve both JSON responses, host stderr
   and CLI exits. CLI zero plus `ok:true` is required; the installed input schema
   is a stub, so this is transport evidence only.
3. Write one freshly allocated UUID to the fixed request file with the source's
   literal `printf` command. Validate its raw guest/CLI statuses and exact UUID
   acknowledgement. Wait 1 s; read the UUID-named response once with `cat`.
   No polling/retry or second nonce. Require a fresh matching UUID, expected PID,
   positive menu session, exact decimal native sample tick and true actual
   Settings highlight. Any failure ends the slot before selection.
4. Mouse: one `testanyware input click X Y --json --vm ID`. Return: one
   `testanyware input key Return --json --vm ID`, with no modifiers. No further
   move, arrow navigation, shortcut, AXPress, callback invocation, activate,
   launch command or repeated input. Every command includes the exact guest ID.
   Each raw command/stdout/stderr/exit is retained in a newly created route
   directory; a host timeout retains partial output and is not retried.

Example *after all review/design/readiness/freeze prerequisites*, not a launch
instruction for this producer:

```sh
python3 docs/verification/settings-activation/causal-protocol.py select Return \
  --nonce "$nonce" --pid "$koine_pid" --vm "$actual_clone_id" --output "$slot/route"
```

Exit zero from `select` means transport completion only; its JSON deliberately
keeps `qualified:false`. Observe the outcome and preserve failure captures before
any dump, archive acquisition or intervention. The same existing bounded
one-window/front/focus checks run once in each arm; do not add a focus wait,
retry or repair to obtain success.

## Positive delivery criteria

The expected nonce is allocated by the enclosing route and supplied explicitly
as `--nonce` to either offline reader. A highlight file never authenticates its
own request UUID. Both readers require a complete zero-drop event buffer, one
Settings callback for the selection, a highlight receipt matching the expected
nonce and callback PID, and direct inputs in that menu session before callback.

**route-readiness-01 (mouse)** requires `mouse_invocation` / the `mouse` CLI:
exactly one monitored leftMouseDown (1), then one leftMouseUp (2), both after
the served nonce, in the receipt's session and with Settings highlighted. Both
must have no modifiers/repeat/key code, the callback PID/nonce, and consecutive
positive input serials within the probe budget. No extra direct input is allowed.
The callback must carry the same last-input record as the up event except for
`sameEvent`. Callback `currentEvent` identity is deliberately not a mouse gate:
the saved mouse getter can still name the earlier down event. This qualifies
positive mouse-pair-to-callback **correlation**, not object-identity dispatch
provenance or a native transaction. Missing down/up/monitor coverage ends the
slot; do not substitute clean click transport. The local monitor may not expose
both events in real menu tracking; this remains an explicit route risk.

```sh
python3 docs/verification/settings-activation/causal-protocol.py mouse events.json \
  --highlight route/highlight.json --selection 2 --nonce "$nonce"
```

**route-readiness-02 (Return)** requires `return_invocation` / the `return` CLI
under the stricter criterion below. Both readers also apply to their respective
measured modality selections; neither reader is a focus-outcome test.

## Positive Return invocation

The local monitor observes its actual NSEvent argument and returns that identical
event unchanged. It records input only after serving the nonce, with that nonce,
menu session, input serial, event type, key code, modifiers, repeat bit and actual
highlight. Apple documents
[pre-dispatch monitoring](https://developer.apple.com/documentation/appkit/nsevent/addlocalmonitorforevents(matching:handler:));
its coverage of these menu-tracking events is **not yet qualified**.

`return_invocation` requires exactly one direct input before the sole
`callback.settings` for the measured selection: keyDown (10), Return (36),
no device-independent modifiers, no repeat, same menu session and nonce, and
Settings highlighted at that direct event. The callback must carry the same
record and an object-identity match between the monitored NSEvent and
`NSApp.currentEvent`. A fresh direct monitor event plus this match is the criterion;
`currentEvent` alone, matching timestamps, clean VNC input or a different input
label cannot qualify delivery. Duplicate, intervening, stale, missing, wrong-key,
wrong-session or unhighlighted evidence is unavailable. Preserve it without
substituting another route. No text characters are recorded.

```sh
python3 docs/verification/settings-activation/causal-protocol.py return events.json \
  --highlight route/highlight.json --selection 2 --nonce "$nonce"
```

This criterion intentionally can fail on a platform where the system menu does
not expose the direct event through this monitor. That is a finite route failure,
not permission to weaken the criterion after observing it.

Before deciding to spend readiness-02, weigh the retained observation in
[EVENTS-RESULTS.md](EVENTS-RESULTS.md): successful mouse callbacks ran in default
mode after menu close with `currentEvent` still leftMouseDown, about 0.35 s old,
rather than the ending up event. This does not predict what Return exposes.
It does positively show that callback context need not be the final input.
There is no supported guarantee of Return object identity. Keep this criterion
unchanged, retain unavailable evidence, and let k39 decide whether the finite
route risk is worth runtime. No route guest may discover a causal hypothesis.

## Separate route qualification and finite setup

Subject to the execution boundary, declare exactly **route-readiness-01** (mouse)
and **route-readiness-02** (Return), fresh clones
`koine-k12-route-readiness-01/02`. Every started clone consumes its slot, including
preflight failure or interruption. Both slots must complete readiness, all controls,
exact joins and the named `mouse_invocation` (01) / `return_invocation` (02) evidence before any modality slot. Stop the
whole qualification at the first unavailable/invalid/failed control; leave any
unstarted slot NOT RUN. No replacement, corrected rerun, third slot or transfer
of unused qualification slots to the modality set. Failure requires a new reviewed
instrument/protocol decision, not additional input. These guests qualify the route
and acquisition only, never cause, repair or ordinary operation.

The still-unstarted **modality-01…04**, if earned by the causal-design decision,
use fresh `koine-k12-modality-01…04` clones and mouse/Return/Return/mouse order.
The maximum is four started clones, including all failures. Each has the same one
setup selection and one measured reopen. At a qualification/precondition defect,
stop the whole set and retain the remaining slots NOT RUN. A qualified measured
product failure is a result: retain it and continue only the remaining fixed
slots, never repeat input in that guest. At the cap preserve inconclusive outcomes.
There is no fifth slot, replacement or extension of a historical set.

Both sets use one newly built/signed candidate in
`.build/settings-activation/modality/Koine.app`, preserving every historical
candidate, especially events/Koine.app. Keep the original window-then-activation
order, activation API/policy and ordinary product behavior. No alternate API,
yield, async deferral or repeated activation is selected. Match macOS 27/build/
architecture, TestAnyware, 1920×1080, preferences, installation and persisted
Debug configuration (both SkyLight subsystems plus launchservices), with no live
native output reader. Archive before/after subsystem status; command success alone
is no retained-path qualification. Readiness includes a running unambiguous PID,
valid signature/image identity, one status item/no Dock, exact display, usable
observer/dump binaries, memory-only diagnostics and empty output directories.

The fixed progression in each guest is:

- First launch once. Retain the initial window/title/default-frame and independent
  native active/key/front success observations. If they fail or their transport
  fails, stop the slot before any menu selection. First-launch activation is
  selection 0 and must later have its ordinal wrapped-call candidate enclosed.
  A separate earlier launch-prefix row is required and retained as described below;
  it is not selection 0's candidate and is never called enclosed by that bracket.
- Use the settled TextEdit idle-document setup from persisted-01, including its
  fixed settling/move steps. Close Settings once, verify zero Settings windows,
  TextEdit frontmost with the same idle document and no panel. Do not repair an
  unmatched state. Open and observe the menu with the implemented route. Make
  exactly one mouse Settings selection (setup selection 1). It must yield one
  front/focused Settings window with successful independent transports. Failure
  ends the slot; keep it as a failed setup control, never a measured reopen.
- Close Settings once. Verify the same zero-window/TextEdit-front/document state.
  Open/hover/observe by the same route. Make measured selection 2 in the assigned
  arm. Capture the independent outcome without intervention. Stop focused work.
- Acquire the full native archive/rendering once, dump once after observations,
  and evaluate native joins for selections 0,1,2. No extra action follows a known
  failed gate. Native qualification is deferred: later setup/measured actions
  taken after successful window controls are explicitly **provisional** until
  both earlier native controls are ENCLOSED. If either fails, credit neither
  matched state nor the measured causal result, even if all windows looked right.

This deferred policy avoids pretending the irreversible final dump supplies an
online native gate. It deliberately allows only the two predeclared provisional
menu inputs after successful window controls, never another input after a native
gate is known to fail. `control_policy` and the `control` CLI implement this
progression. At `launch`, `--focus-success` means only first-launch independent
window/front/key checks and transports succeeded; at `setup`, it means only the
setup-selection checks and transports succeeded, after a successful launch-stage
decision. The caller retains both decisions. Native joins may be PENDING for
these two provisional stages, but any known bad join stops immediately.

At `final`, supply **no focus flag**: the reader rejects any supplied focus input.
The caller must already have both recorded successful window-control decisions;
pass `--launch-join ENCLOSED --setup-join ENCLOSED` only for their actual final
joins. `CLASSIFY_MEASURED` permits interpretation of a measured success **or
failure**, subject to measured delivery/join qualification. It certifies control
availability only, not measured success. For example:

```sh
python3 docs/verification/settings-activation/causal-protocol.py control final \
  --launch-join ENCLOSED --setup-join ENCLOSED
```

A first-launch successful window without a contained actual client
record fails availability for the entire slot; collect, audit and stop, with no
replacement. Setup failure never becomes repeated-input failure hunting.

## Recorder scope and exact native containment

Keep the tested activate-only bracket. `mach_continuous_time` samples enclose
exactly one NSApp.activate call. Cached observed-process boot UUID and scale must
be valid. Existing observers can run synchronously inside the call and their work
is inside its interval; no timing-neutral, capture-free or asynchronous-delivery
claim follows. The new menu probe adds workload before selection and direct-input
recording. Unsampled show/menu/notification rows have **no qualified native-time
relation**. The narrow necessity inference needs callback/delivery and independent
post-outcome observations, not their exact native ordering. A future inference
that needs wider bounds must implement/test/review those samples first.

Keep the broad full native rendering, with terminal completion/count, for the
entire process lifetime. `read_native` rejects partial/malformed rendering. Retain
all actual-image SLSSetFrontProcessWithInfo candidates, including outside ticks;
never search only inside desired endpoints. The frozen whole-process shape is
**one launch-prefix candidate plus one candidate per wrapped activation interval**.
This is an empirical accounting rule, not a claim about the prefix's source or
SkyLight semantics. The retained persisted-01 extract has rows at lines 9, 20,
37 and 49 for three application calls. Events-01 and native-01 also have one
extra launch-time row. See the retained-row control and evidence limits in
[the integration](CAUSAL-PROTOCOL-REVIEW.md#launch-prefix-accounting).

`containment` first validates every interval's process/clock metadata, unique
selection and strict nonoverlapping native-tick order. It validates identities
and integer ticks for **all** client candidates and requires exactly N+1 rows
for N intervals. Fewer is MISSING; more is AMBIGUOUS, even if a desired subset
would enclose. Sort the entire candidate list by native tick; duplicate ticks
are AMBIGUOUS. Candidate 0 is retained as `launchPrefixTick` and must strictly
precede the first bracket's before tick, otherwise AMBIGUOUS. Candidates 1…N
map in order to intervals 0…N-1. Report the full `candidateTicks`, prefix tick,
selected tick and any exact outside distance. Do not discard a second early row
or search for a closer replacement. Check **every** interval before crediting
the slot; another interval's failure cannot be hidden by selecting a success.

This strict shape can reject a future legitimate different launch sequence.
That is a retained availability failure requiring a new reviewed decision, not
permission to remove rows after observation. Matching counts, ordinal placement
and exact enclosure remain correlation, not a verified transaction ID or proof
of native disposition. The prefix is not itself an activation success control.

Independently retain clean single-attempt guest sysctl boot UUID reads before
launch and after collection; raw archive Info.plist boot and Apple
`log raw-dump -t` timesync boot/timebase; observed-process metadata; and signed
candidate/installed executing-image UUID and PID evidence. Normalize those exact
independently validated values to identity.json fields `guestBootBefore`,
`guestBootAfter`, `archiveBoot`, `timesyncBoot`, `numerator`, `denominator`, `pid`,
`imageUUID`. The parser checks agreement, not provenance: the executing wrapper
must validate and retain each raw transport and decoder outcome before writing
that normalization. An invented/missing/failed source cannot qualify it. K37's
host UUID receipt is not target-guest qualification. Capture `log raw-dump -t`
from the extracted guest archive, never the host database or a fitted scale.

| Exact result | Required disposition |
|---|---|
| ENCLOSED | One ordinal wrapped-call candidate in the exact closed interval, validated launch prefix and matching identities/scales; enclosing correlation only |
| OUTSIDE | Retain sole candidate and exact tick distance; stop qualification, never widen or infer refusal/suppression |
| MISSING | Retain missing candidate; unqualified, never absent-request proof |
| AMBIGUOUS | Retain all candidates; unqualified, no preferred candidate |
| INVALID | Metadata error/mismatch, reversed bounds, wrong PID/image, float ticks, dropped/incomplete buffer; stop interpretation |

There is no contract that SkyLight emits its client row synchronously inside
activate. Outside outcomes are expected possibilities, not instrument successes.
No uptime equality, wall-clock fit, tolerance, widening or host substitution is
permitted. After the native-control gates pass, an ENCLOSED measured failed
activation is still no native refusal: positive disposition/responsible-context
evidence remains required under k33. No richer monitor promises every refusal.

## Freeze, outcomes, timing and every original duty

K36 must implement the enclosing finite caller before a runtime freeze. This
producer supplies checked route/readers, not a launch/scenario/audit wrapper.
After all review/integration/design obligations, freeze the actual signed subject
with full regular-file/link inventory; the complete build/source/manifests,
Taskfile, this protocol, route/readers/tests, dump/native observer binaries,
logging/subsystem configuration, decoder and every consumed input. Complete all
edits, actual input freeze and golden config/disk/NVRAM hashes before *any* clone.
Digest these subjects before and after; no overlapping edit or second writer.
Audit both installed endpoints where available, original archives/candidates and
golden. Stop each exact clone, validating its identity and stopped result on
success, failure and interruption. Never erase or retry a failed endpoint.

Retain every scenario, inner/outer Task, native acquisition/render/package,
collection/audit, environment, dump, endpoint and stop status separately. Keep
all raw CLI/envelope/timeouts/-1/partials and NOT RUN phases. Matching stdout from
failed transport stays failed. Later focused actions are NOT RUN after early
stop; ordinary resize/minimum-size/content-height/scrolling, shortcuts,
requests/denials, consent, silent launch, running-app reopen, login restart and
Quit are NOT RUN in this protocol. Clone stop is cleanup.

A recorded measured failure qualifies symptom preservation only for that actual
changed instrument and route, not timing neutrality or a reliability rate. No
failure means preservation unknown. New polling/file/monitor and synchronous
observer work and input timing stay explicit. Qualification guests do not
conclude cause, justified product repair/useful failing seam or ordinary acceptance.
The complete original-duty table in [CAUSAL-RESULTS.md](CAUSAL-RESULTS.md#every-original-duty)
and the FOCUS/CLOCK/PERSISTED comparisons remains authoritative. Preserve
historical diagnostic-02 classification, persisted symptom preservation, old
strict false/empty joins and every historical cap, failure and NOT RUN.

One Settings selection must ultimately return one front/focused window. No
driver waits/retries/repeated input counts as repair. Any justified application
repair needs its useful failing seam where feasible and a **separate** finite
complete ordinary-acceptance set through app:vm-verify-menu-bar, actual final
signed subject/all-input/completed-golden freeze, diagnostics disabled, retained
outcomes and explicit timing limits. No repair subject is selected here. If
external, keep positive evidence/reproducer and repair unresolved; no upstream
report without Antony's approval. No release/notarization or causal ancestor
closure follows from this producer or the narrow probe.
