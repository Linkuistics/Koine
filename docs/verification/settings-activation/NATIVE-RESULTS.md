# Native activation records: successful controls, cause unresolved

Both guests in the [declared two-guest qualification](NATIVE-PLAN.md) passed
their initial Settings selection and three reopens. The logs correlate Koine's
actual activation call with a WindowServer front-process change and application
resume, followed by active/key notifications. They supply successful controls
for the native path. **No failed activation occurred in this sample**, so it
does not discriminate why the original requests failed or establish a repair.

The sample has reached its cap. Do not add or replace an attempt. The original
diagnostic and four-guest ordering samples also remain closed. Their failures
and classifications remain unchanged. No product change, ordinary-operation
repair acceptance, release, notarization or upstream report occurred.

## Subject and instrument

The [bundle inventory](native-bundle.txt) is identical to the signed diagnostic
candidate's inventory; the [comparison](native-original-diff.txt) is empty.
The separately named local bundle is `.build/settings-activation/native/Koine.app`.
Its source is the [unchanged diagnostic overlay](diagnostic-source/), retained
in the parent source state at 5840b5bb. This is a signed, unnotarized
current-source candidate labelled 0.4.0, not a released bundle. Strict/deep
signature checks passed in each guest; Gatekeeper reported Unnotarized Developer
ID. Installation set no quarantine attribute and supplies no first-launch
Gatekeeper acceptance.

The [prefix](native-prefix.sh) equals the ordering experiment's existing
prefix apart from the native-log setup inserted before first launch. Input,
focus assertions and their waits are unchanged. The original window-show then
NSApp.activate order and synchronous application trace remain enabled.

The [guest sidecar](native-guest-log.sh) runs the public `log stream` command
at debug level, filtering the named application/native service processes. It
invokes no activation or focus operation. The [single startup exec](native-start.sh)
preserves its raw transport and requires a clean readiness result. Collection
uses [a stop helper](native-guest-stop.sh) that rejects prior completion or a
missing process, records intentional termination and waits for the logger's
recorded exit. Both loggers ended with signal status 143 following that request.
Raw startup and stop execs are successful, without timeout, in both guests.

The sidecar produced about 166 MB and 284 MB of uncompressed output. That CPU,
disk and logging load, together with synchronous application tracing, can alter
timing. With no failure under this instrument, preservation of the symptom is
unestablished. No timing neutrality or equivalence to ordinary operation follows.

## Every started attempt

Both clones used testanyware-golden-macos-27, macOS 27.0.1/26A434/arm64,
TestAnyware 2.7.0 and 1920×1080. No restart occurred. Times are host UTC.

| Attempt / clone | Start → scenario end → collection end | Scenario / Task | Native collection / collection / audit / stop | Outcome |
|---|---|---|---|---|
| [01](native-01/task.log), koine-k12-native-01 | 04:15:12 → 04:17:19 → 04:17:21 | 0 / 0 | 0 / 0 / 0 / 0 | All four Settings actions passed |
| [02](native-02/task.log), koine-k12-native-02 | 04:17:27 → 04:24:32 → 04:24:35 | 0 / 0 | 0 / 0 / 0 / 0 | All four Settings actions passed |

First-launch frame/title, agent status, absent Dock icon, one menu item,
accessibility label/menu and the TextEdit-front precondition passed in each
guest. The Settings initial selection and reopens 1–3 each passed their
independent focus assertion. Neither attempt was interrupted, replaced or
replayed. The scenario's existing safe-read retries remain unchanged.

**NOT RUN in both guests:** user-input resizing, minimum-size/content-height
acceptance, minimum-size scrolling, text shortcuts, client requests and denials,
Accessibility consent, silent launch, running-application reopen, login restart,
and application Quit. This prefix ends before those assertions. Clone stop is
cleanup, with no Quit acceptance. No complete ordinary-operation acceptance ran.

## What the native records establish

The [01 trace](native-01/trace.jsonl) is PID 717; [02](native-02/trace.jsonl)
is PID 885. Each records selections 1–4 and active/key notifications for every
selection, with contiguous per-process sequence numbers. The
[01 native extracts](native-01/native-path-records.jsonl) and
[02 extracts](native-02/native-path-records.jsonl) preserve full selected records,
including process/image identity, timestamp, level, subsystem and message.

For each selection, a client `SLSSetFrontProcessWithInfo` log occurs inside the
trace's NSApp.activate before/after interval. WindowServer then reports a front
application change to Koine's process serial number with err=0/noErr and posts
kCGSEventResume to the corresponding Koine PID. The application subsequently
records active/key state. These are observations of the existing NSApp path;
no alternative activation API was substituted.

Correlation uses timestamps and process/connection identity. No independently
verified transaction-ID join links the application trace to the native service.

The table gives the client call, WindowServer's front change and application's
did-become-active timestamp. Times are UTC on 2026-10-28; native logs store the
same instants with a -0700 offset on the preceding local date.

| Guest / selection | Client native call | WindowServer front change | Application active |
|---|---|---|---|
| 01 / 1 | 04:16:28.996162 | 04:16:28.997771 | 04:16:29.027470 |
| 01 / 2 | 04:17:04.893941 | 04:17:04.895487 | 04:17:04.902925 |
| 01 / 3 | 04:17:10.688868 | 04:17:10.695688 | 04:17:10.703568 |
| 01 / 4 | 04:17:16.526848 | 04:17:16.534054 | 04:17:16.542042 |
| 02 / 1 | 04:23:41.956924 | 04:23:41.958237 | 04:23:42.069620 |
| 02 / 2 | 04:24:17.880131 | 04:24:17.881486 | 04:24:17.889603 |
| 02 / 3 | 04:24:23.778933 | 04:24:23.781678 | 04:24:23.792226 |
| 02 / 4 | 04:24:29.752128 | 04:24:29.753480 | 04:24:29.767197 |

In 01 selection 4, WindowServer's `isActivationTokenActive` reports result=-50
immediately before its successful front-process change. That value alone is
therefore not a failed-activation classifier. The AppKit warning about ordering
a window from an inactive application also appears in this successful selection;
it does not establish the intermittent failure's cause or qualify reordering as
a repair. No interpretation of undocumented token fields as a refusal contract
is supported by this experiment.

Apple documents [activation as a request](https://developer.apple.com/documentation/appkit/nsapplication/activate())
and describes the system's [context-dependent decision](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation).
The log messages expose implementation observations, without an Apple guarantee
that every request or refusal emits a particular message. A missing record
cannot establish that AppKit suppressed a request. These successful controls
qualify a positive observation route, not a complete request/disposition monitor
or the explanation of any historical failure.

## Integrity and limits

The [freeze](native-frozen-at.txt), [input hashes](native-subjects.sha256),
per-attempt host checks and [final check](native-final-subject-check.txt) retain
the unchanged actual source, manifests, scripts, Taskfile, observer and bundle.
Both complete host inventories and both installed before/after inventories
match the frozen bundle. All recorded startup/stop and independent final
installed/environment exec envelopes complete cleanly. The scenario's inherited
safe-read retry helper is unchanged; this experiment adds raw transport records
for native-log startup and stop. Endpoint matches provide no continuous runtime
immutability.

The [before](native-golden-before.sha256) and
[after](native-golden-after.sha256) golden config/disk/NVRAM hashes are retained
with their [comparison](native-golden-diff.txt). Explicit stop results and the
[VM](native-vms-after.json)/[Tart](native-tart-after.txt) inventories retain cleanup.
[Doctor](native-doctor.json) reports the existing host application's disabled
start-at-login setting; the GUI service is running and this prefix does not
exercise host login. No machine setting changed.

Raw native streams are retained losslessly as
[01 gzip](native-01/native-log/stream.jsonl.gz) and
[02 gzip](native-02/native-log/stream.jsonl.gz). Each stream's raw and restored
SHA-256 digests match. The integrity records report one non-JSON filter header
per stream; remaining lines parse as logEvent or activityCreateEvent records.
Neither parsing nor endpoint liveness certifies complete delivery,
buffer flushing on termination or coverage outside the selected processes.

The native-path extracts select messages by these expressions from each raw
JSON line: `SLSSetFrontProcessWithInfo`, `SetFrontProcessInternal`,
`LS/CAS: Changed front application`,
`SetFrontProcessWithInfo.*(frontmostProcess|front process|foreground connection)`,
`isActivationTokenActive`, and `ordered front from a non-active`.
They are reading aids; the full stream remains the evidence for other messages.

The [sole pre-guest review](native-review.txt) found two capture gaps. Six
focused startup/stop controls pass after repair; an
[always-successful stop mutant](native-stop-mutation.txt) fails the stop controls.
The existing five capture, eight pointer and nine resize controls also pass in
[the focused checks](native-controls.txt). These checks qualify helper logic.
The [final no-VM checks](native-final-controls.txt) pass after strengthening the
stop test to observe child readiness and require completion before test cleanup.
That test-only change follows measurement; the frozen runtime scripts, Taskfile,
source and bundle are unchanged. The stop mutant still fails all three controls.
`task check:vm-settings-native` and `task app:vm-settings-native CLI_ARGS=01`
retain the reusable route; completed attempt directories refuse overwrite.

## Remaining work and original repair obligations

The missing observation is now a failed activation on the actual NSApp path
with native records that positively discriminate request submission, native
disposition or a responsible activation context. The successful request/front
change/resume sequence supplies a reference for that observation. The large
debug stream and synchronous trace leave a concrete instrumentation limitation.
A successor can qualify a reduced native focus filter against these saved raw
streams and test the original application with synchronous tracing disabled,
under its own new bounded protocol. It must preserve unsuccessful outcomes and
must not extend this sample. Missing logs and green counts still establish no
cause or external ownership.

K12's recorded callback/failed-activation classification remains satisfied by
diagnostic 02. K14/k16's responsible condition remains unresolved. There is no
application repair, focused failing product seam or final ordinary candidate.
The required separate finite complete fresh-guest acceptance with diagnostics
disabled has not run. All original repair/acceptance obligations stay live in
the successor, with no close of k16, k14 or k12 from this qualification result.

The subsequent [reduced-context evidence](CONTEXT-RESULTS.md) qualifies retention
of this sample's known positive records offline. Its overall three-guest budget
contains two preflight failures and one actual application guest; that guest
passes four Settings actions with trace disabled at launch. Postcondition and
other final transports fail. It supplies no failed disposition, causal repair
or ordinary complete acceptance, and does not extend this native sample.
