# Buffered event intervals retained; Settings repair unresolved

The single [declared guest](EVENTS-PLAN.md) passed its four Settings actions.
Its explicit post-scenario dump retains 101 ordered records with zero drops,
including callback, window/activation boundaries, last-event context and active/
key transitions. Each actual native client call falls within its corresponding
activation interval. Native front-change/resume records and independent focus
assertions agree with success. **No failed disposition or responsible condition
was observed. No application repair or complete ordinary acceptance occurred.**

The bound is closed. The guest is not replaced or extended. Collection fails:
the legacy-trace postcondition rejects a new missing-key diagnostic, and final
environment/installed transports time out. These remain failed outcomes despite
the useful buffered/native observations. This is neither a fully successful
qualification charter nor symptom-preservation or timing-neutrality evidence.

## Instrument and actual subject

The separately signed candidate is `.build/settings-activation/events/Koine.app`,
built from parent e3000cec plus this task's source. [Build](events-build.txt),
[signature](events-signature.txt), [full inventory](events-bundle.txt) and
[freeze](events-subjects.sha256) identify it. It is an unnotarized current-source
candidate labelled 0.4.0, not the released bundle. The guest's strict/deep checks
pass; Gatekeeper reports Unnotarized Developer ID. There is no quarantine-based
first-launch acceptance.

`AppDelegate` and `MenuBarController` are unchanged. The existing window-before-
`NSApp.activate()` sequence stays intact. The [recorder](../../../Sources/KoineApp/SettingsActivationTrace.swift)
adds a separate `KoineSettingsEventBuffer` preference. The ordinary application
enables neither mode; simultaneous memory/file preferences are refused. The
Foundation-only store reserves 4096 records only when enabled, retains the first
records and counts drops. Appends capture local scalar state and clocks, without
JSON encoding, file output or frontmost-application lookup in that branch.
Observers, allocation and state reads still add work.

The [requester](../../../Tools/SettingsEventDump/main.swift) posts one distributed
notification after scenario observations. Its receiver ignores notification
payloads, freezes once, writes without overwriting and creates a completion marker
after the snapshot write returns. The requester refuses pre-existing output and
waits at most five seconds for completion. Delivery can be delayed/dropped; no
delivery or output is manufactured by a retry. Buffer/dump and legacy file modes
are distinct. No activation, input, window-order or focus operation is added.

Apple documents [currentEvent](https://developer.apple.com/documentation/appkit/nsapplication/currentevent)
as the last retrieved event. Its [timestamp](https://developer.apple.com/documentation/appkit/nsevent/timestamp)
uses seconds since startup. The recorder excludes the documented undefined
[periodic-event window number](https://developer.apple.com/documentation/appkit/nsevent/windownumber).
These fields establish no input provenance, activation authority or cause. State
and clocks are sampled sequentially. No keystrokes/event text are captured.
[Distributed notification delivery](https://developer.apple.com/documentation/foundation/distributednotificationcenter)
is not a guaranteed observation channel. Source citations remain beside the calls.

## Every attempt and assertion

Events 01 used clone `koine-k12-events-01`, golden macOS 27.0.1/26A434/arm64,
TestAnyware 2.7.0 and 1920×1080. It did not restart. Host UTC: start 05:07:42,
scenario end 05:09:28, collection end 05:10:30 on 2026-10-28.

| Outcome | Status |
|---|---|
| Scenario / inner Task | 0 / 0 |
| Native collection / collection / audit | 1 / 1 / 1 |
| Outer launcher Task | 201 |
| Clone stop CLI and validated envelope | 0; expected ID, ok/stopped true |

[Raw task log](events-01/task.log), [launcher](events-launcher-task.log) and the
individual status files retain these separate outcomes. No guest or user action
was replayed. Existing safe-read retries remain, including a delay before the
last selection; new raw enable/dump/native transports are single attempts.

First-launch title/default frame, agent status, absent Dock icon, one item,
menu/label and settled TextEdit-front precondition PASS. Initial Settings and
reopens 1–3 PASS the existing independent front/focus check.

**NOT RUN:** user-input resize/minimum-size/content-height and scrolling,
shortcuts, client requests/denials, Accessibility consent, silent launch,
running-application reopen, login restart and application Quit. Clone stop is
cleanup, not Quit acceptance. This is the focused prefix, not the separately
required complete ordinary-operation acceptance.

## Actual-path/event join

[Raw snapshot](events-01/settings-events.json), [JSONL reading copy](events-01/events.jsonl),
[interval joins](events-01/interval-joins.json) and [native extracts](events-01/native-path-records.jsonl)
retain the observations. All rows name Koine PID 747; sequences are contiguous.
Each selection has the required ordered callback/show/window/activation boundaries,
then active/key notifications. Dump is last, after focus observations. The separate
download equals the clean dump transport's returned snapshot; its completion
marker has the exact required contents.

| Selection | Callback UTC | Native client call UTC | Did-become-active UTC |
|---|---|---|---|
| Initial | 05:08:37.905774 | 05:08:37.907916 | 05:08:37.939654 |
| Reopen 1 | 05:08:43.704414 | 05:08:43.705724 | 05:08:43.715880 |
| Reopen 2 | 05:08:49.528410 | 05:08:49.530840 | 05:08:49.546925 |
| Reopen 3 | 05:09:25.482287 | 05:09:25.483282 | 05:09:25.495410 |

Each client `SLSSetFrontProcessWithInfo` row is enclosed by the corresponding
buffered activation interval. WindowServer follows with front changes to
0x0-0x36036, err=0/noErr, resumes to PID 747 and foreground connection 42003.
The native timestamps preserve the preceding local date with -0700 offset.
Correlation uses clocks/PID/connection and ordered observations, not a verified
transaction ID or independently captured call stack.

All callbacks run in default mode. Last-event snapshots have type 1
(`leftMouseDown`), window 0 and modifiers 0, aged about 0.346–0.353 seconds at
callback sampling. The same event persists across the associated call boundaries.
This is a successful context reference only: it is no proof that this event
authorized activation, was stale, or explains a historical failure. Token -50
and inactive-window warnings again occur with success. Missing native messages
still cannot prove an absent request.

The [native stream](events-01/native-log/stream.jsonl.gz) restores losslessly to
14,917,542 bytes. [Integrity](events-01/native-log/integrity.json) records one
non-JSON predicate header, 12,263 log events and 229 activity-create events.
The native logger intentionally terminates with 143. Clean stop and parsing do
not certify complete delivery/flushing. The reduced live sidecar still adds
formatting, CPU/disk and native logging load. This sample has no reproduced
Settings failure, so symptom preservation remains unqualified.

## Failed checks, repairs and integrity

[Enable](events-01/events-enable.json), initial [trace-disabled](events-01/trace-disabled-before.json),
[native start](events-01/native-start.json), [dump](events-01/events-dump.json)
and [native stop](events-01/native-stop.json) are clean.

The [post-trace transport](events-01/trace-disabled-after.json) is clean as a
transport but its guest check exits 1: `Error: Could not find key
'KoineSettingsActivationTrace' in domain 'dev.antony.Koine'.` The new memory
preference has created the domain; the inherited parser recognizes missing-domain
and older missing-key forms but rejects this one. Preserve the failed check.
It does not establish that legacy tracing was enabled, nor does its text make
the check successful. The [measured helper/tests](events-measured-inputs/) are
archived unchanged. After sample/frozen audits, the [actual fixture fails](events-missing-key-red.txt)
before a literal-only parser correction. Seven context controls subsequently
pass. No corrected guest ran and no past status is changed.

[Final environment](events-01/guest-final.json) and
[installed read](events-01/installed-after.json) time out/exit -1. Returned
[installed text](events-01/timedout-installed-text.txt) equals the frozen inventory;
the transport remains failed and audit remains 1. The initial installed inventory
is clean and matches. No continuous runtime immutability follows.

All 340 [frozen inputs match before repair](events-final-subject-check.txt).
The [overlay check](events-measured-overlay-check.txt) reconciles the two deliberately
changed helper/test files to their exact measured copies and every unchanged file.
[Artifact checks](events-artifact-checks.txt) compare every collected original to
its saved copy, restoring native gzip. Completed golden [before](events-golden-before.sha256)
and [after](events-golden-after.sha256) config/disk/NVRAM hashes match; before
finished before clone launch. [VM](events-vms-after.json)/[Tart](events-tart-after.txt)
inventories and the validated [stop](events-01/stop.json) retain cleanup. The host
[doctor](events-doctor.json) retains its existing disabled start-at-login setting;
no machine setting changed.

Three [memory-store tests](events-buffer-controls.txt) pass after the retained
[empty-store failures](events-buffer-red.txt). Eleven event controls, six original
context controls, six native, five capture, eight pointer and nine resize controls
pass [before freeze](events-controls.txt). [Review findings](events-review.txt)
have [failing seams](events-review-red.txt) before fixes for suppressed chmod and
unvalidated stop results. [Final controls](events-final-controls.txt) also cover
the corrected seven-case context suite. The single reviewer allowance is spent;
later mechanical parser repair has its executable seam, with no second reviewer.
Initial no-VM development invocations exposed a missing `try`, missing framework
staging and a shell quoting/lint error; these were corrected before credited
checks. Their full terminal output was not all archived. No guest was consumed
by those development errors. Helper checks prove neither native reliability nor
a product repair.

The repository [documentation check](events-doc-links.txt) reports two missing
relative targets from the archived `context-initial-inputs/CONTEXT-PLAN.md`.
Parent e3000cec has the same charter bytes and [no adjacent targets](events-parent-archive-files.txt).
K23 separately owns restoring those links without changing measured historical
bytes. The new report links produce no additional diagnostic in that check;
the whole documentation check remains failed, not credited as passing.

## Every original obligation and handoff

| Original criterion | Result / remaining duty |
|---|---|
| K12: record and classify a real Settings failure | Met historically by diagnostic-02; delivered callback/failed activation classification unchanged |
| K20: callback/call/event join without synchronous trace writes | Positive successful reference now retained; full charter has failed postcondition/final transports |
| K18/K16/K14/K12: responsible actual-path/context discriminator | UNRESOLVED; no failed disposition/causal condition under this instrument |
| New bounded protocol, frozen actual inputs, all outcomes/cleanup | One declared guest retained, cap closed; parser failure and timeouts explicit; frozen and golden audits match, clone stopped |
| Preserve historical failures and instrumentation limits | Unchanged diagnostic/order/native/context samples remain closed; no absence or success becomes cause |
| Application repair and useful focused failing product seam | NOT DONE; capture/store/parser checks are instrument repairs only |
| One Settings selection returns its one front/focused window | Four passing observations here; historical failures remain unresolved |
| Separate declared frozen complete ordinary-operation acceptance | NOT RUN; no final repair subject selected; diagnostics-disabled complete scenario still required |
| External ownership / reproducer / upstream approval | No external ownership established; no upstream report |
| Verification/root reconciliation, no release | Updated; k20/k18/k16/k14/k12 remain open; no release/notarization |

K21 completes the buffered-instrument evidence slice of decomposed k20. K22 owns
the next precise instrumentation question: can post-scenario native acquisition
retain the actual-path records without a concurrent live formatting/output
sidecar? Qualify that capability before relying on it, without assuming debug
messages persist or treating missing records as absent requests. The current
buffer supplies callback/event intervals but the live sidecar's timing effect
and failed-path symptom preservation remain unestablished. Do not merely extend
this guest or replace failed endpoints. K22 also carries every original positive
causal discrimination, justified repair and complete ordinary-acceptance duty.
