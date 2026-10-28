# Trace-disabled native activation context

Declared before the first guest on 2026-10-28. This is a new causal instrument
qualification sample, separate from the closed diagnostic, order and native
samples. None of those samples may be extended or replaced.

Use the unchanged signed native candidate copied separately to
`.build/settings-activation/context/Koine.app`, with complete relative file/link
inventory equality to native-bundle.txt. Keep its actual NSApp.activate path and
window-before-activation order. Source and all consumed inputs are frozen before
guest 01. This is signed, unnotarized current source, not a released bundle.

Run at most three fresh clones, context 01, 02 and 03, from
`testanyware-golden-macos-27` at 1920×1080. Each runs the existing native focused
prefix, with first launch, settled TextEdit, initial Settings selection and
reopens 1–3; it ends at its first assertion failure, failed native-start transport
or interruption. Stop the sample early only if positive evidence discriminates
a failed actual-path request/disposition or its responsible activation context.
Every started guest consumes its slot. No replacement, repeated scenario,
cap expansion or repeated user action after a failed assertion. Preserve every
unsuccessful outcome. Safe-read retries inherited from the original scenario
remain unchanged; raw new trace-disabled and logger-start/stop execs never retry.

The only changed instruments are the application trace preference and the
native predicate. Set KOINE_SETTINGS_TRACE=0 and require a single clean guest
observation that the trace preference is absent and no trace file exists before
first launch and after the scenario. The opt-in recorder then installs no
notification observers and makes no synchronous JSON writes. Retain the raw
transport; a missing-value error must explicitly say the preference does not
exist. An enabled preference, existing trace file, unexpected error, missing
marker or unsuccessful transport fails qualification.

The new predicate keeps every Koine record and selects activation/front/focus/
resume/yield/token/menu messages from the original native process set. The
[exact predicate](context-predicate.txt) is uploaded before logger launch. The
[offline qualification](context-qualify-filter.sh) derives its ASCII needles
from that file, applies them to both retained wide streams, and checks all full
native-path reference records survive. This qualifies those known positive
records only. The offline ASCII matcher is not a proof of Unicode equivalence
to NSPredicate or a complete refusal monitor. The live logger's stderr/exit and
actual positive records qualify its use in the guest. Retain the full reduced
stream, not only the reading extracts.

Disabling synchronous application tracing removes the callback and call-interval
records for these guests. Preserve the historical diagnostic-02 callback/
failed-activation classification; do not claim a new failed callback from an
absent trace. Correlate native records by timestamp, PID, connection and menu
context, supported by the original input log and independent window observations.
No transaction ID or complete log coverage is assumed. Absence of a log is not
absence of a request; -50 token results and inactive-window warnings occur in
successful reference selections and cannot alone establish refusal or cause.
A successful alternative API cannot qualify the actual path.

The reduced sidecar still adds CPU/disk/logging load. The two instrument changes
are combined; neither a pure timing effect nor timing neutrality is established.
A recorded failure establishes symptom preservation for this configuration. If
all guests pass, report that bound without selecting a repair, inferring
external ownership or extending it to seek a failure.

Freeze before the first guest: this protocol, scripts, actual source/manifests,
Taskfile, signing inputs, observer binary, offline reference/filter inputs,
application bundle and complete inventories, plus golden config/disk/NVRAM.
Audit the same subjects after every attempt and after the sample. Preserve every
raw transport, failure screenshot and native/window observation before any
intervention; record every later phase as NOT RUN. Stop and inventory every clone.
No code or consumed input may change during the sample.

These focused guests provide no resize, scrolling, shortcuts, requests/consent,
silent launch, running-app reopen, login restart or application Quit acceptance.
No ordinary-operation repair acceptance is implied by trace-disabled exploration.
If a responsible application condition is identified, demonstrate a focused
failing product seam where feasible, implement the justified repair, and declare
a separate finite complete fresh-guest acceptance through app:vm-verify-menu-bar
with diagnostics disabled before its first guest. Otherwise preserve the precise
remaining question in a successor. No release, notarization or upstream report.
