# Persisted Debug: one native-disposition capability guest

Declared on 2026-10-28 before any persisted guest. Exactly one fresh clone,
`koine-k12-persisted-01`, runs `task app:vm-settings-persisted CLI_ARGS=01`.
A started clone consumes the slot on every outcome. No replacement, acquisition
retry, repeated failed action or cap extension. Every earlier sample stays closed.

## Hypothesis and alternatives

The working hypothesis is that cooperative activation rejects a delivered NSApp
request under the current native context. The alternative is suppression before
native submission. Diagnostic-02 establishes callback delivery and failed activation,
not either cause. Its failed activation call takes about 0.614 ms; its successful
selections take about 3.120/1.483/1.717 ms. Call duration alone cannot classify
submission or refusal. Default deferred Info acquisition now retains actual client
calls, but not the detailed Debug result/resume reference seen in NATIVE-RESULTS.md.

Apple's [cooperative activation contract](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation)
describes a context-dependent request, with no promise that it succeeds. A missing
log, missing notification, last-event age or -50 token row cannot distinguish these
alternatives. Native positive failure/result evidence must precede a causal claim.

This guest first tests whether narrowly persisted Debug retains the necessary
actual-path request/result observations after focus checks. It is a capability
experiment, not a matched causal intervention or ordinary repair acceptance.
If a failure occurs, preserve it untouched and classify only positive native
records. If every action passes, do not treat that as a cause or repair. The next
causal comparison needs its own hypothesis, matched conditions and finite charter;
it cannot simply repeat these four actions to seek a failure.

## Controlled subject and capture

Use the unchanged signed `.build/settings-activation/events/Koine.app` and dump
binary. Preserve its complete inventory. No application source, call order,
window behaviour or activation API changes. The inherited retention prefix and
wrapper are copied into separately named persisted files. Their only operational
additions are the guest logging configuration before Koine launch and a later
status read after focus/failure observations. All original input and focus checks,
memory recorder, independent initial endpoint, raw transports and cleanup remain.

After the original read-only deferred preflight, upload and execute
persisted-guest-config.sh enable in the disposable guest. Save installed public
`log help config` (allow documented usage exit 64), each subsystem's initial status,
configuration result and final status in one raw envelope. Set `level:debug` and
`persist:debug` only for `com.apple.SkyLight`, `com.apple.SkyLight.processes` and
`com.apple.launchservices`. The earlier native reference's resume uses SkyLight;
its explicit LS/CAS err=0/noErr result uses Launch Services. Do not change
system-wide mode, enable a live native reader, configure the host/golden, enable
private data or substitute a different activation call. Root commands use the
disposable golden's documented admin/admin test account. The clone is stopped;
no configuration is promoted to the golden.

The native [logging guidance](https://developer.apple.com/videos/play/wwdc2020/10168/)
and installed help distinguish enabling from persistence. Post-scenario --debug
cannot restore events discarded before configuration. Capture is qualified only
by actual retained Debug records, not by successful configuration commands alone.
Preserve the initial/post-configuration status and a separate post-observation
status response. No post-read replay converts a failed transport into success.

Reuse RETENTION-PLAN.md and DEFERRED-PLAN.md for inherited mechanics: macOS 27
golden, 1920×1080, settled TextEdit, four Settings actions, original show/activate
order, first-failure stop, untouched failure capture before diagnostic collection,
one `log collect --last 10m`, filtered rendering, partial-archive EXIT packaging,
one packaging-only recovery if needed, then buffer dump and validated clone stop.
All raw envelopes/statuses are independent. Matching text from timeout/-1 remains
failed. Inherited safe-read retries and their delays remain part of the subject.

## Freeze and positive qualification

Before launch, finish golden config/disk/NVRAM hashes. Freeze the candidate's
complete regular-file/link inventory, dump binary, every source/manifest/build
input, Taskfile, consumed wrapper/prefix/helper/observer/filter/reader/test,
protocols and retained qualification fixtures. Record completed freeze timestamps.
No consumed input changes during measurement. Audit original inputs, endpoint
inventories and golden afterward. Retain every started attempt, failed transport,
partial archive and NOT RUN phase, including configuration failures before launch.

Join each Settings interval to actual Koine PID client calls. For each selection,
retain all available native records and report call-to-collection lag. Positive
capability requires Debug records associated with the actual Koine request path
and at least one result or resume record, with successful controls agreeing with
buffered transitions and independent focus. Distinguish the client-call interval
from later asynchronous server processing. State correlation fields and ambiguities;
no verified transaction identity or log completeness is assumed. Save a lossless
filtered rendering plus full raw-archive inventory/digest; preserve the local raw
archive. A generic Debug row or another application's resume does not qualify it.

A failed selection with a positive native request and explicit failed native
result would support a refused-request classification; a successful native result
followed by observed focus loss would instead support lost activation. Absent
client/server rows cannot prove suppression. Successful controls alone leave
failed disposition and responsible context unestablished. Symptom preservation
under persisted Debug requires an observed failure; no failure leaves it unknown.
The new configuration adds formatting/persistence workload even without a reader.
No timing neutrality, external ownership or reliability rate follows.

## Original obligations retained

All later complete-scenario phases are NOT RUN: user-input resize/minimum size,
content-height/scrolling, shortcuts, client requests/consent, silent launch,
running-app reopen, login restart and Quit. Clone stop is cleanup. No final repair
subject is selected. The diagnostic run.sh repair stage is not ordinary acceptance.
Before final repair acceptance, separately declare a finite complete fresh-guest
set through task app:vm-verify-menu-bar, freeze the ordinary final subject and all
inputs, disable diagnostics and retain every outcome while addressing timing.

Diagnostic-02's delivered-callback/failed-activation classification remains met.
Every k27/k25/k22/k20/k18/k16/k14/k12 positive failed-path/responsible-context,
justified product repair/useful failing seam and separate ordinary-acceptance
criterion stays live. Reconcile each criterion and the root/verification handoff
before closing ancestors. No driver wait/retry is a repair, no upstream report
without Antony's approval, and no release or notarization. If only richer-capture
capability is obtained, decompose at that verified boundary without closing the
causal parent or extending any sample.
