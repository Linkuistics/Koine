# Persisted Debug reproduces the failure; clock and disposition remain open

The sole [persisted guest](PERSISTED-PLAN.md) passes initial Settings and fails
Settings reopen 1. Its memory recorder and a clean independent native snapshot
show a delivered callback followed by inactive Koine with its visible Settings
window behind active TextEdit. This reproduces the symptom under the changed
instrument. It does not establish timing neutrality or a product repair.

Deferred acquisition retains native Debug, including the successful selection's
front-change result and resume. Near the failed selection it retains an actual
Koine client call and native token processing. **No explicit failed activation
result or responsible cause is established.** The -50 token result and token
fields occur in success too. Remote-menu teardown follows the client call in
both outcomes. Those observations do not discriminate refusal or justify a
menu-close deferral repair.

The strict wall-clock interval reader matches neither selection. This is a new
qualification limit, not evidence of missing requests. Raw native ticks and
buffered uptime suggest a clock-domain route, but its conversion and boot/sleep
semantics have not been qualified. The original empty joins remain unchanged.
The exact-join criterion is unmet, so the capability protocol has not qualified
in full despite useful Debug acquisition and symptom preservation.
The sample is closed; do not replay an endpoint, action, acquisition or guest.

## Subject and all outcomes

The subject is the unchanged signed `.build/settings-activation/events/Koine.app`.
Its [full inventory](persisted-bundle.txt) equals retention's inventory; strict/deep
host and guest signature checks pass. It is the unnotarized current-source
candidate labelled 0.4.0, not the released bundle. The guest's Gatekeeper rejection
is recorded; installation adds no quarantine attribute or first-launch acceptance.
No application source, window order or activation API changes.

Guest `koine-k12-persisted-01` uses macOS 27.0.1/26A434/arm64,
TestAnyware 2.7.0 and 1920×1080. It does not restart. On 2026-10-28 UTC,
[golden hashing completes](persisted-golden-before-completed.txt) at 06:02:25,
[input freezing completes](persisted-freeze-completed.txt) at 06:02:50 and the
wrapper starts at 06:02:57. All three precede cloning/application observation.

| Outcome | Status |
|---|---|
| Scenario / inner Task | 1 / 201 |
| Native collection / collection / audit | 1 / 1 / 1 |
| Outer launcher Task | 201 |
| Native acquisition / packaging | 0 / 0; clean raw envelope |
| Logging enable / later status | Clean single raw envelopes |
| Buffer dump / independent failure snapshot | Clean single raw envelopes |
| Initial independent / final installed inventory | Clean, both match frozen subject |
| Final environment / display | Clean, still 1920×1080 |
| Post-trace-disabled observation | Timeout / exit -1 despite returned marker |
| Clone stop / interruption | 0 / 0; correct ID and stopped true |

The [scenario log](persisted-01/task.log), [launcher log](persisted-launcher-task.log),
[launcher status](persisted-launcher-task.exit), independent [raw records](persisted-01/)
and [stop response](persisted-01/stop.json) retain these distinctions. The
[post-trace timeout](persisted-01/trace-disabled-after.json) keeps native collection
and audit failed; matching text is not promoted to a successful read. The
[clean native snapshot](persisted-01/failure-native.json),
[agent windows](persisted-01/failure-windows.json) and
[screenshot](persisted-01/failure-observed.png) precede diagnostic collection
and any further input. No collection retry or packaging recovery was needed.

First-launch title/default frame, agent policy, absent Dock icon, one menu item,
expected menu/label and settled TextEdit-front precondition PASS. Initial Settings
PASS. Reopen 1 FAIL: TextEdit is first/focused and Koine Settings is second/unfocused.
Reopens 2 and 3 are NOT RUN. Every subsequent complete-scenario phase is NOT RUN:
resize/minimum-size/content-height/scrolling, shortcuts, client requests/denials,
Accessibility consent, silent launch, running-app reopen, login restart and Quit.
Clone stop is cleanup. This diagnostic prefix is not ordinary repair acceptance.

## Positive native observations and failed correlation criterion

The clean [dump](persisted-01/events-dump.json) and downloaded
[buffer](persisted-01/settings-events.json) agree. The [JSONL copy](persisted-01/events.jsonl)
has 49 contiguous records and zero drops. Both callbacks run in default run-loop
mode after menu.didClose. Selection 1 has active/key notifications. Selection 2
records show/activation entry and return, then no active/key transition through
its dump about 13.2 seconds later. Its last row still has Settings visible,
active false and keyWindow -1. This preserves diagnostic-02's classification;
notification absence is observational, not an atomic WindowServer history.

[Native extracts](persisted-01/native-path-records.jsonl),
[full local contexts](persisted-01/selection-context.jsonl) and the
[summary](persisted-native-summary.json) retain the successful and failed-adjacent
records. Both client rows name Koine PID 814, the unchanged image UUID and the
same SLSSetFrontProcessWithInfo call/options. Successful processing uses native
activity 88373, failed-adjacent processing 89551. These fields and proximity are
correlation evidence, not a verified transaction contract.

| Selection | Buffered activate before–after, UTC | Native client UTC | Native wall time after buffered after | Lag to native collection start/end |
|---|---|---|---|---|
| Initial, PASS | 06:05:59.902792–.904170 | 06:05:59.904569 | 0.399 ms | 8.095 / 11.095 s |
| Reopen 1, FAIL | 06:06:05.663813–.665042 | 06:06:05.665596 | 0.554 ms | 2.334 / 5.334 s |

These lag values use one-second collection timestamps, not guaranteed retention.
The [unchanged strict reader result](persisted-01/strict-interval-joins.json) is
qualified false with no joined selections. No tolerance, clock shift or interval
widening was applied. Do not report either row as wall-clock-enclosed.

For success, WindowServer names Koine PSN 0x0-0x2e02e/connection 403fb as front,
Launch Services logs err=0/noErr and SkyLight posts a PID 814 resume, followed by
buffered active/key transitions and the passing focus check. For the failed-adjacent
request, native token processing explicitly targets PID 814, but the retained
selected records supply no explicit failed activation return/disposition. The
isActivationTokenActive result=-50 and token fields occur in both selections.
Missing front/resume rows cannot substitute for a refusal result. The independent
failure snapshot confirms the observed unsuccessful outcome, not its cause.

Last-event ages are approximately 0.346 and 0.361 seconds. Neither is activation
authority or verified input provenance. The remote-menu end-tracking messages
follow the client call in both outcomes, so their presence/order alone does not
explain failure. There is no established external owner or selected product fix.

## Changed logging and clock limits

The [enable response](persisted-01/persisted-enable.json) includes installed public
log config help and before/after status for com.apple.SkyLight,
com.apple.SkyLight.processes and com.apple.launchservices. Each changes from
INFO/PERSIST_DEFAULT to DEBUG/PERSIST_DEBUG; the clean
[post-observation status](persisted-01/persisted-status.json) retains that mode.
There is no system-wide mutation, live native formatting/output reader or host/
golden logging change. Root commands use only the disposable admin/admin account.
Buffering, observers, existing safe-read retries and new persistence still change
workload. The reproduced failure qualifies symptom preservation in this guest,
not neutral timing or equivalent failure frequency.

The lossless filtered rendering has 6,048 JSON rows, including 192 Debug rows.
The selected successful actual-path result/resume records are positive evidence
that this configuration retains useful Debug. No filtered loss event is observed;
this is not complete system delivery or a complete refusal monitor. The
[collection stderr](persisted-01/deferred-native/collect.stderr) reports missing
UUID text at /private/var/db/uuidtext/29/8F0E6EF41333469DEC5CB5BC4AFAD8.
The clean transport does not remove that warning or establish which other
messages could not be rendered. Public
[logging guidance](https://developer.apple.com/videos/play/wwdc2020/10168/)
and installed help distinguish persistence from later display. No retrospective
Debug recovery is claimed for any earlier default archive.

The raw client tick values are 4338579225 and 4476843871. Under a **provisional**
24 MHz conversion, they would fall inside the recorded uptime intervals. That
conversion is not qualified by numerical fit. The archived
[Info.plist](persisted-01/archive-clock/Info.plist) and
[raw timesync bytes](persisted-01/archive-clock/0000000000000002.timesync) are
retained for boot-specific clock investigation; no undocumented parser or host
clock assumption is used to upgrade these joins. On this host's installed log,
--mach-continuous-time changes the [default rendering](persisted-native-continuous-default.txt)
to the same ticks; [NDJSON](persisted-native-continuous.jsonl) and
[compact](persisted-native-continuous.txt) still show wall-clock strings.
These are offline renderings of the saved archive, not new guest observations.

The next task must qualify the clock relationship from retained original inputs
and applicable primary documentation before relying on precise joins. Missing or
unqualified timebase/sleep facts stay unknown. This can begin offline without a
new guest. Even a corrected clock join would establish correlation, not an
explicit refusal or responsible cause.

## Integrity and controls

All 316 [frozen inputs](persisted-subjects.sha256) match the
[final check](persisted-final-subject-check.txt). The measured scripts, Taskfile,
protocol and tests remain unchanged after freeze. Both installed endpoints and
full host bundle inventory match; [before](persisted-golden-before.sha256)/
[after](persisted-golden-after.sha256) golden config/disk/NVRAM hashes
[match](persisted-golden-check.txt). The [VM inventory](persisted-vms-after.json)
and [Tart inventory](persisted-tart-after.txt) retain cleanup. No continuous
runtime immutability follows from endpoint inventories.

The full raw archive remains locally at
.build/settings-activation/persisted/01/deferred-native.tgz, about 65 MiB.
Its [digest](persisted-archive.sha256), [verification](persisted-archive-check.txt)
and [file inventory](persisted-archive-files.sha256) preserve its identity.
Re-querying the full archive requires that local artifact. The committed
[filtered gzip](persisted-01/deferred-native/native.jsonl.gz) restores losslessly;
[artifact checks](persisted-artifact-checks.txt) compare retained originals,
archive scalar copies and clock-file copies. Acquisition/packaging status and
completion written after tar returns remain separately downloaded evidence.

The [sole review](persisted-review.txt) found a direct-scenario route that could
start an undeclared default clone. A fake-VM control failed before the early
identity/output guard and passes afterward. No real guest started in that control.
[Pre-freeze checks](persisted-checks.txt) pass four persisted controls and all
inherited retention/deferred/event/context/native/capture controls plus syntax/
lint. The new transport tests reject timeout, wrong phase, false-ok and nonzero
CLI/guest outcomes without replay. These controls repair instruments only.
The repository documentation check still retains the two known archived-context
missing links owned by k23; no historical measured bytes are changed here.

## Every original duty and remaining work

References below name the corresponding criterion in each node's original
Done when section; later handoffs do not replace those criteria.

| Original duty | Owning original criteria | Outcome / remaining duty |
|---|---|---|
| Record and classify the historical failure | k12 observation and classification; k14 preserve original; k16 preserve history | Met historically by diagnostic-02; unchanged. This guest independently records delivered callback/failed activation with clean native snapshot |
| Supported hypothesis and discriminating finite protocol | k27 hypothesis; k25 positive discrimination; k22/k20/k18/k16 native context; k14 native path | Cooperative rejection versus pre-submission suppression stated, but this capability guest does not discriminate them. Exact clock joins fail; explicit failed disposition/responsible context remain open |
| Qualify new observation and timing effects | k12 preserve symptom; k14 instrument; k16 matched instrument; k18 observation; k20 new instrument; k22 deferred capture; k25 actual-path/load; k27 richer availability | Persisted useful Debug and a real failure observed. Configuration and extra reads add load. Strict clock join and complete causal monitor unqualified; no timing neutrality |
| Separate bound, actual freeze and completed golden before launch | k27 freeze; k25 corrected capability; k22 new protocol; k20 finite protocol; k18 qualification; k16 new experiment; k14 acceptance/observation | Sole new slot retained with 316 inputs and completed prelaunch hashes. All prior caps stay closed; no unchanged failure chase |
| Default-retention/alternative acquisition boundary and lag | k25 actual calls and default fallback; k22 deferred availability; k20 buffered context; k18 reduced observation | Earlier default actual-path capability preserved. New explicit persistence retains useful Debug; per-selection lags recorded. Empty wall-clock joins remain failed, not silently repaired |
| Retain every failure/transport/partial archive/NOT RUN, audit and stop | k27 freeze/audit; k25 preserve outcomes; k22 new bound; k20 new bound; k18 observation; k16 preserve history; k14 preserve evidence | Scenario failure, post-trace timeout, strict join failure and unrun phases retained. Frozen inputs/endpoints/golden match; correct clone stopped |
| Positive failed native request/disposition/responsible-context evidence | k27 discrimination; k25 failed-path; k22 failed-path; k20 positive discriminator; k18 positive discriminator; k16 activation path; k14 native path | Nearby actual client/token records and failed app state retained. Precise join and explicit failed return/context remain unqualified; -50/shared token fields/age/teardown are not discriminators |
| Justified application repair and useful failing product seam | k27 repair; k25 repair; k22 repair; k20 repair; k18 repair; k16 repair; k14 repair; k12 repair | No product repair selected. Capture guards are not product repair. Demonstrate a useful failing product seam where feasible once a justified repair exists |
| One selection, one front/focused Settings window | k27/k25/k22/k20/k18/k16/k14 repair criteria; k12 behavior | Initial action passes and reopen 1 fails; intermittent product outcome remains unresolved. No driver wait/retry/repeated-input repair |
| Separate finite complete ordinary acceptance with frozen final subject | k27/k25/k22/k20/k18/k16/k14 acceptance criteria; k12 bounded complete acceptance | NOT RUN. No final repair subject selected. Must use app:vm-verify-menu-bar, diagnostics disabled, all consumed inputs frozen, all outcomes retained and timing addressed; diagnostic repair wrapper is not sufficient |
| External cause/reproducer and approval | k27/k25/k22/k20/k18/k16/k14 external criteria; k12 external outcome | No external ownership established. Keep repair unresolved if external; no upstream report without Antony's approval |
| Verification/root reconciliation and release constraints | k27/k25/k22/k20/k18/k16/k14 reconciliation criteria; k12 documents | Updated with retained failure and precise next question. No causal ancestor closes; no release/notarization or upstream report |

K27 decomposes into persisted evidence k28 and native clock/disposition work k29.
K29 first qualifies the existing cross-clock join offline, without widening the
failed reader result or rerunning this guest. It then carries every positive
failed-disposition/responsible-context, justified product repair/failing seam and
separately declared frozen complete ordinary-acceptance duty above. A further
causal experiment needs a new finite matched hypothesis/protocol; clock correction
or more green actions cannot close those duties. K27/k25/k22/k20/k18/k16/k14/k12
remain open. This failure-bearing acquisition result does not close issue 14.
