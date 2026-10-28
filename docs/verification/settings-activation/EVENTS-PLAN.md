# Buffered callback/event qualification: one fresh guest

Declared on 2026-10-28 before any event-instrument guest. All diagnostic, order,
native and reduced-context samples are closed. This experiment is separately
named `events`, candidate `.build/settings-activation/events/Koine.app`, clone
`koine-k12-events-01`. Run 01 exactly once through `task app:vm-settings-events
CLI_ARGS=01`. Its existing output directory refuses reuse. Every started guest
consumes the sole slot, including preflight/transport failure or interruption.
No replacement, cap extension or repeated user action after failure is permitted.

The candidate preserves window-before-activation order and `NSApp.activate()`.
Only diagnostic observation changes: `KoineSettingsActivationTrace` remains
absent and `KoineSettingsEventBuffer` points to `/Users/admin/settings-events.json`.
The application reserves 4096 records only when that mode is enabled. It retains
the first records and explicitly counts subsequent drops. Append captures scalar
application/window state, last-event context, clocks and notification subject PID.
There is no record-time JSON encoding, file output or frontmost-application lookup
in this mode. The legacy synchronous mode remains available but simultaneous
modes are refused. No diagnostic preference is enabled in ordinary operation.

Current-event type, timestamp, modifiers and nonperiodic window number are
observations of the last retrieved event. They do not establish input provenance,
an activation token, user intent or causation. Periodic window-number access is
undefined and is omitted. State and clocks are sampled sequentially, not atomically.
No keystrokes or event text are captured. Apple sources are cited at these calls.

Use the same macOS 27 golden clone, 1920×1080, settled TextEdit precondition,
initial Settings action and reopens 1–3, stopping at the first assertion failure.
Keep the input/focus assertions and inherited safe-read retries unchanged. Enable
the qualified reduced native sidecar with its unchanged predicate. Preserve every
raw new preflight, enable, dump, native start/stop and endpoint transport without
replay. An unsuccessful envelope stays unsuccessful even if returned text agrees.

On scenario failure, collect native/window/screenshot state before the dump. The
headless Foundation requester then posts one distributed notification and waits
at most five seconds for the completion marker. This wait occurs after focus
assertions; it never retries activation/input or repairs scenario acceptance.
Distributed delivery may be delayed or dropped. A missing dump is a failed
instrument outcome. The receiver ignores notification payloads and uses only the
locally configured path. It freezes once, writes without overwriting, then writes
a completion marker only after the snapshot write returns. The helper rejects
output/marker already present before its request. Retain separate raw file
downloads even if that request's transport fails.

Qualification requires clean enable and dump envelopes, zero dropped records,
contiguous sequences, start/dump sentinels, complete ordered callback/show/window/
activation boundaries for each observed selection and current-event/native records
that can actually be correlated. Preserve partial or rejected output as evidence,
never treat it as a successful instrument. The no-VM tests cover retention,
overflow, explicit/non-destructive dump and write refusal, plus raw transport,
marker and boundary rejection. They cannot establish native delivery or focus.

Before launch, freeze the completed signed candidate and full file/link inventory,
actual source/manifests/lockfiles, Taskfile, all consumed scripts, dump helper source
and binary, signing inputs, failure observer, predicate and this protocol. Finish
the golden config/disk/NVRAM digest before starting the clone. Audit the same
subjects after collection and after the sample. No consumed input changes during
the experiment. Preserve original failed controls and every raw unsuccessful
transport/attempt/NOT RUN phase; stop and inventory the clone on every outcome.

Buffer snapshots, memory allocation, local state reads and notification observers
still add work. The native sidecar adds logging/CPU/disk load. This reduces a known
source of synchronous I/O; it establishes no timing neutrality. A reproduced
failure qualifies symptom preservation only for this configuration. Green actions
alone establish neither cause, repair nor external ownership. Missing native logs
are not absent requests; -50 token results and inactive-window warnings also occur
in success. Correlation by clocks/PID/connection is not a verified transaction join.

This focused guest has no resize, scrolling, shortcuts, requests/consent, silent
launch, running-app reopen, login restart or Quit acceptance. All are NOT RUN.
Clone stop is cleanup. Any justified product repair still needs its own useful
failing seam where feasible and a separately predeclared frozen complete fresh-
guest set through `app:vm-verify-menu-bar`, diagnostics disabled. If this instrument
slice cannot discriminate cause within its bound, preserve the exact remaining
question and decompose, retaining every original k18/k16/k14/k12 obligation.
No release, notarization or upstream report.
