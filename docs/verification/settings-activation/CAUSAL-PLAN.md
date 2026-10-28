# Matched Settings selection modality

This protocol selects a controllable activation condition before new runtime
work: select the same highlighted Settings menu row with a mouse click or Return.
It is a causal probe of the selection path. It does not change the activation
API, window order, foreground application or product behavior to obtain a pass.
The compiled native-interval recorder is ready for runtime qualification; this
document alone does not establish its availability or symptom preservation.
The revised causal interpretation must receive its scheduled fresh review before
VM execution. Review findings may require revision before this set is frozen;
they cannot silently change a set after it starts.

## Evidence and competing predictions

The [retained native input analysis](CAUSAL-RESULTS.md) reads the full saved
persisted archive, including messages omitted by the older text predicate.
WindowServer positively records beginDeferredActivation for mouse selection of
the menu row in both the successful and failed-adjacent native sequences. It
records an active TextEdit key-appearance request in the latter. This supports
testing a mouse-selection interaction with foreground focus, not declaring that
deferred activation or a TextEdit marker causes failure. The [independent marker
counterexamples](FOCUS-RESULTS.md) still apply.

The necessary-row-click hypothesis predicts that an unsuccessful activation
requires clicking the Settings row. A positively qualified Return selection
with a failed activation would refute the necessity of that row click. It would
not refute a mouse-origin native context: both arms still mouse-open and hover
the menu, and Return may inherit that context. The competing hypothesis is a
modality-independent activation-context problem: matched foreground/window
context can produce the same positive native
disposition after either input. Different positive native processing/disposition
under otherwise matched context would contradict that strict independence claim.
Neither hypothesis predicts a failure rate. An all-green finite sample, or a
mouse failure and keyboard success without a positive discriminator, settles
neither. No absence of a native message establishes absence of processing.

Apple's [cooperative activation guidance](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation)
supports context-dependent requests. Its [current status-item guidance](https://developer.apple.com/videos/play/wwdc2026/289/)
supports keyboard interaction and distinguishes a system-managed menu from custom
expanded UI. In particular, the [expanded-interface delegate contract](https://developer.apple.com/documentation/appkit/nsstatusitem/expandedinterfacedelegate)
says menu-backed items do not receive those callbacks. Adding a custom delegate,
forcing session cancellation or an extra activation is not this intervention.
Menu keyboard delivery must be positively qualified in the actual guest.

## Finite set and matched state

The separately named set is **modality-01 through modality-04**, in fixed
mouse / Return / Return / mouse order. Use fresh clones named
`koine-k12-modality-01` through `koine-k12-modality-04`. Each started clone consumes
its slot, including preflight/transport failures and interrupted runs. At most
one Settings selection is made in each clone. Never replace a slot, add a fifth,
repeat a failed selection or extend a previous sample. No clone has started.
The executing successor must implement and check this route, freeze its actual
inputs, and record readiness before starting the first slot.

Use the same newly built/signed candidate for all four slots, in a new
`.build/settings-activation/modality/Koine.app` directory. Keep every historical
candidate, especially `.build/settings-activation/events/Koine.app`, intact.
This candidate preserves makeKeyAndOrderFront then NSApp.activate, with opt-in
memory diagnostics and direct native call brackets. No tracing file, live
native reader, changed activation policy, yield, alternate API, added activation,
async deferral or activation retry is allowed. The historical persisted Debug
configuration/acquisition can be reused under the new names; retain configuration
and actual-path records, not just successful config commands.

All slots use the same macOS 27 golden/build/architecture, TestAnyware version,
1920×1080 display, installation route, preferences, first-launch setup and idle
TextEdit document as the persisted reference. Retain environment/version and
signature observations. Use the existing first-launch/default-frame/title,
agent-policy/no-Dock/one-item checks and settled TextEdit setup. Close Settings
once. Independently verify no Settings window and TextEdit frontmost with its
same document window before opening the menu. Do not create a document panel,
activate another app, or repair an unmatched foreground state after selection.

Open the status menu using the settled pointer route in every slot. Move the
pointer to the same Settings row using the same approach and target coordinates,
without selecting it. Use the same read-only menu observation in both arms to
verify its identity and highlighted state; if highlighting cannot be observed,
record the failed precondition and stop that slot. Freeze the exact input API,
coordinates, pointer-motion and observation commands before launch.

- Mouse arm: one click on the highlighted Settings row.
- Return arm: one Return key press while that same row is highlighted. Do not
  use Command-comma, AXPress, arrow-key exploration, callback invocation or a
  launch command as a substitute. Verify the actual Settings callback and
  keyboard invocation context afterward. Unavailable delivery is a failed
  instrument precondition, not an application activation failure.

Both arms then perform the same existing one-window/front/focus observations
and untouched failure capture, with the same bounds and no new wait/retry.
Retain pointer transport, invocation type, event context and native input path.
Return changes event kind and inherent delivery timing together. This experiment
does not isolate a pure timing effect. Extra preselection observation and the
new recorder affect timing equally by design, without proving timing neutrality.

## Native relation and positive qualification

In memory mode, SettingsActivationTrace caches kern.bootsessionuuid and
mach_timebase_info from the observed process. Its application.activate.interval
record contains decimal-string beforeTicks and afterTicks sampled with
mach_continuous_time immediately around exactly one NSApp.activate call. The
wrapper constructs its interval record after the call and reads metadata only
at initialization. Existing observers can still record synchronously if AppKit
posts notifications during activation; this work is inside the measured call,
not excluded from the interval. No promise of deferred notification delivery,
capture-free execution or timing neutrality is made. Ordinary and
legacy-file modes take no new samples. Metadata failure remains an explicit
nativeClockError; it does not prevent or retry activation.

Before using a runtime interval, independently match the guest kernel boot UUID
and scale with the saved archive bootUUID and Apple's timesync decoder. Require
one process/image identity, zero dropped buffer rows, complete contiguous
sequences, exactly one interval for that selection and ordered tick endpoints.
Require the actual Koine client record to lie inside the exact closed interval
in the same continuous clock. Reject missing/ambiguous candidates, reversed
samples, wrong identity/scale and malformed metadata. No tick/uptime equality,
wall-clock fit, tolerance, interval widening or host-clock substitution is allowed.
An interval is an enclosing correlation bound, not a verified native transaction
identifier. Keep asynchronous server processing distinct from the client call.

Retain full raw archives and a broad native rendering with input/session/window
context; the old message predicate omits useful endUserInteraction/order records.
Use positive successful request/front-change/result/resume controls where they
occur, buffered active/key transitions and independent native/agent/screenshot
observations. Compare complete native context around every actual interval,
including foreground identity, focus chain and TextEdit key-return requests.
Qualify keyboard delivery, instrument availability, recorded failure preservation
and timing separately. If no failure occurs, preservation is unknown.

Native cause/disposition remains open unless positive evidence connects an
unsuccessful actual request to its disposition and responsible condition. Green
counts, a valid clock join, missing rows, -50/shared token fields, the terminal
marker or an effective alternative input alone cannot establish it. A qualified
Return failure can refute the necessity of clicking the row, while leaving
shared mouse-open context unresolved. Require positive keyboard invocation
evidence as well as clean input transport; a stale currentEvent alone cannot
qualify delivery. Other
outcomes may remain inconclusive; preserve them at the cap and state the precise
remaining question, without promising this monitor can observe every refusal.

## Freeze, cleanup and original duties

Before the first slot, complete golden config/disk/NVRAM digests and freeze the
actual signed candidate's full regular-file/link inventory, dump tool, complete
build/source/manifests, Taskfile, protocol and every consumed input/helper/test,
observer, logging configuration/filter/decoder and comparison reader. Complete
all edits before hashing. No measurement overlaps an edit or another writer.
Preserve timestamps and pre/post digests. Audit every original, both installed
endpoints where available, and golden afterward. Stop every clone and validate
its exact identity/stopped result even after interruption. Retain every raw
transport, timeout, nonzero exit, partial archive and failed audit separately.
Matching returned text from failed transport remains failed.

This focused set ends after the sole selection/observation. Reopens 1–3 and all
later complete-scenario phases are NOT RUN here: resize/minimum-size/content-height/
scrolling, shortcuts, requests/denials, Accessibility consent, silent launch,
running-app reopen, login restart and Quit. Clone stop is cleanup. All prior
historical caps and failure classifications remain unchanged.

Any justified product repair still needs a useful failing seam where feasible
and one selection returning one front/focused Settings window. Driver waits,
retries and repeated input are not repairs. Separately declare finite fresh-guest
complete ordinary acceptance through app:vm-verify-menu-bar only after selecting
the final repair subject. Freeze it and all inputs, disable diagnostics, retain
all outcomes and address timing. This probe supplies no ordinary acceptance.
If an external cause is established, preserve positive evidence/reproducer and
leave the repair unresolved. No upstream report without Antony's approval;
no release/notarization. Every original duty in FOCUS-RESULTS.md remains live.
