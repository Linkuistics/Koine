# Deferred capture retains Koine's actual calls; repair unresolved

The one [declared retention guest](RETENTION-PLAN.md) passes all four Settings
checks. Post-observation acquisition, with no live native log reader, retains one
actual Koine client call inside each buffered activation interval. WindowServer
front-change/foreground records and active/key notifications agree with successful
focus. This establishes a useful finite acquisition capability on this guest.
**No failed native disposition, responsible cause or application repair follows.**

The sample is closed. It is not extended or pooled with earlier samples.
Collection/audit remain failed because the final environment and installed-bundle
reads time out, despite agreeing returned text. The initial raw endpoint,
preflight, acquisition, dump and trace postcondition are clean. These distinctions
prevent the positive native reference from becoming an all-clean charter,
symptom-preservation qualification or ordinary-operation acceptance.

## Subject and every outcome

The candidate remains `.build/settings-activation/events/Koine.app`, unchanged
from the events experiment. Its [complete inventory](retention-bundle.txt)
equals the earlier events inventory, and [strict/deep signature checks](retention-signature.txt)
pass. It is an unnotarized current-source candidate labelled 0.4.0, not the
released bundle. Guest signature checks pass; Gatekeeper reports Unnotarized
Developer ID. Installation supplies no quarantine-based first-launch acceptance.
No application source, native activation API or window/activation order changes.

Clone `koine-k12-retention-01` uses macOS 27.0.1/26A434/arm64,
TestAnyware 2.7.0 and 1920×1080. There is no restart. Host UTC on 2026-10-28:
completed golden freeze 05:42:13; completed input freeze and wrapper start
05:44:51; scenario end/collection start 05:48:26; collection end 05:49:40.
Sequential host commands complete the input freeze before starting the wrapper,
although their retained timestamps have the same one-second precision.

| Outcome | Status |
|---|---|
| Scenario / inner Task | 0 / 0 |
| Native collection | 0 |
| Collection / audit | 1 / 1 |
| Outer launcher Task | 201 |
| Archive acquisition / packaging | 0 / 0; clean raw exec envelope |
| Clone stop / interruption | 0 / 0; expected ID, ok/stopped true |

[Task log](retention-01/task.log), [launcher log](retention-launcher-task.log),
[launcher status](retention-launcher-task.exit), individual [status files](retention-01/)
and [validated stop](retention-01/stop.json) retain separate outcomes.
`wrapper.exit` is the inner Task's status before EXIT collection; the outer Task
preserves the later collection failure. No action, acquisition or guest was
replayed; packaging recovery was unnecessary.

First-launch title/default frame, agent status, absent Dock icon, one menu-bar
item, menu/label and settled TextEdit-front precondition PASS. Initial Settings
and reopens 1–3 PASS the existing independent front/focus check. The inherited
safe-read retries remain, including approximately a minute between selections
2 and 3. Their delays are part of this actual retention subject.

**NOT RUN:** user-input resize/minimum-size/content height/scrolling,
shortcuts, client requests/denials, Accessibility consent, silent launch,
running-application reopen, login restart and application Quit. Clone stop is
cleanup. This focused diagnostic prefix is not the required complete ordinary
acceptance with diagnostics disabled.

## Per-selection actual-path retention

The clean [dump](retention-01/events-dump.json) and independent
[snapshot download](retention-01/settings-events.json) agree; the completion
marker is exact. The buffer has 101 contiguous records and zero drops.
[JSONL reading copy](retention-01/events.jsonl), [interval joins](retention-01/interval-joins.json),
[native extracts](retention-01/native-path-records.jsonl) and
[summary](retention-native-summary.json) preserve all four selections.

All calls are from Koine PID 723. Each `SLSSetFrontProcessWithInfo` timestamp
falls inside its corresponding `application.activate.before`/`after` interval.
Collection starts at 05:48:26 and finishes at 05:48:29 UTC.

| Selection | Client call UTC | Lag to collection start | Lag to collection end |
|---|---|---|---|
| Initial | 05:47:06.511227 | 79.489 s | 82.489 s |
| Reopen 1 | 05:47:12.257961 | 73.742 s | 76.742 s |
| Reopen 2 | 05:48:17.984822 | 8.015 s | 11.015 s |
| Reopen 3 | 05:48:23.706022 | 2.294 s | 5.294 s |

These lags use one-second collection timestamps and fractional client timestamps;
they describe observed retention, not guaranteed durations. There are no unmatched
Settings intervals in this sample. The application-start activation before any
Settings callback is outside this four-selection claim.

For each selection, WindowServer records making PSN 0x0-0x2b02b the front process,
a policy naming Koine/PID 723 and a new foreground connection 2d783 for
`dev.antony.koine`. The buffer records active/main/key transitions afterward.
Correlation uses clocks, PID, connection and ordered observations, not a verified
transaction identifier or independently captured stack. The richer Debug
err/noErr/resume chain from the earlier live stream is not claimed here.

Every callback uses default run-loop mode. Last-event snapshots have type 1,
window 0 and modifiers 0; callback age is approximately 0.344–0.347 seconds.
This is a successful-context reference, not proof of activation authority,
input provenance or a cause of the historical failure. The ordinary NSApp call
is unchanged, and no alternate activation API is tested as a substitute.

## Native acquisition and its limits

The [preflight](retention-01/deferred-preflight.json) is clean and its normalized
completion marker has no trailing newline. Public help usage exits 64 are
explicitly allowed. The read-only root logging status reports **System mode =
INFO** in this golden image. No logging configuration is changed by this run.
The process inventory is retained; no live native formatting/output reader is
started before or during the scenario. Root reads use the disposable admin/admin
account, not the host's configuration.

The single [acquisition](retention-01/deferred-collect.json) is clean, as are
rendering and packaging. The full raw archive remains locally at
`.build/settings-activation/retention/01/deferred-native.tgz` (about 65 MiB).
Its [digest](retention-archive.sha256), [verification](retention-archive-check.txt)
and [extracted file inventory](retention-archive-files.sha256) are retained.
The full archive is not committed; reproducing a full-archive query needs that
local artifact. The [filtered rendering](retention-01/deferred-native/native.jsonl.gz)
is committed and restores losslessly to 9,402,920 bytes.

The rendering has 6,861 JSON rows and no non-JSON lines: 6,479 log events,
271 activity-create events, 110 state events and one metadata row. Its log
levels include 1,803 Info, 4,624 Default, 26 Error, 12 Fault and 14 Debug rows.
The Debug rows concern Koine's AppleEvents connection; their presence does not
establish retained activation Debug detail. Collection stderr is empty here;
the older deferred archive's missing-uuid warning remains its own limitation.
No filtered loss event is observed. Neither a clean archive nor this filtered
count proves complete system delivery, buffer flushing or platform health.

Apple's [persistence explanation](https://developer.apple.com/videos/play/wwdc2020/10168/)
distinguishes recent Info retention from ordinarily discarded Debug messages.
The actual golden configuration and returned rows govern this finite result.
`--last 10m` requests a range without ensuring completeness; `--debug` displays
retained data rather than recreating discarded data. Missing records cannot prove
absent requests, refusal or external ownership. The unchanged filter is already
qualified against known successful live references, not every possible failure.

Removing the live reader still leaves buffer allocation, observers, state reads,
ordinary system logging and existing driver work. The new independent initial
inventory also delays launch. This is no randomized or controlled load comparison
with prior guests. No failure under this configuration means no demonstrated
symptom preservation or timing neutrality.

## Failed transports, controls and integrity

[Initial independent raw endpoint](retention-01/installed-before-raw.json),
[its check](retention-01/installed-before-check.exit),
[pre-trace check](retention-01/trace-disabled-before.json),
[enable](retention-01/events-enable.json), preflight, acquisition, dump and
[post-trace check](retention-01/trace-disabled-after.json) are clean.
Both legacy-trace checks confirm it is disabled. The initial raw inventory matches
the frozen candidate, separately from the inherited normalized safe-read inventory.

[Final environment](retention-01/guest-final.json) and
[final installed endpoint](retention-01/installed-after.json) each report timeout
and exit -1 despite CLI exit 0. Environment text agrees on OS/architecture and
Gatekeeper status; [returned installed text](retention-installed-timeout-text.txt)
[equals the frozen inventory](retention-installed-timeout-text-diff.txt).
Both remain unsuccessful transports. The new wrapper correctly fails audit for
the environment envelope as well as the installed endpoint. The display read is
clean and remains 1920×1080. No continuous runtime immutability is inferred.

All 302 [frozen files](retention-subjects.sha256) match in the
[final subject check](retention-final-subject-check.txt); the full host bundle
inventory also matches. The measured wrapper/prefix/helpers/Taskfile remain
unchanged after freeze, so no measured-source overlay is needed.
[Artifact checks](retention-artifact-checks.txt) compare original collection files
with retained copies and restore gzip. [Archive scalar checks](retention-archive-scalar-check.txt)
compare independent downloads to packaged files; packaging status/completion are
written after tar returns and retained independently.
Completed golden [before](retention-golden-before.sha256)/[after](retention-golden-after.sha256)
hashes and their [comparison](retention-golden-check.txt) retain config/disk/NVRAM
integrity. [VM](retention-vms-after.json)/[Tart](retention-tart-after.txt) inventories
and the validated stop retain cleanup. The host [doctor](retention-doctor.json)
keeps its existing disabled start-at-login finding; no machine setting changes.

The sole [review](retention-review.txt) identifies cleanup on TERM, suppressed
initial raw transport status and uncredited final environment/display failures.
[Failing wrapper fixtures](retention-review-red.txt) precede their fixes;
[passing wrapper checks](retention-review-green.txt) and the
[initial endpoint failing fixture](retention-endpoint-red.txt) retain the seams.
The [final pre-freeze Task check](retention-final-controls.txt) passes six retention,
eleven deferred, eleven event, seven context, six native and five capture controls,
plus syntax/lint. The normalized retained response and timeout/wrong-marker/
nonzero-guest/nonzero-CLI/false-ok cases are covered. No second reviewer is used.
Helper controls establish no native reliability or product repair.

The repository [documentation check](retention-doc-links.txt) still reports the
same two missing relative targets in the archived initial context charter.
K23 owns that separate byte-preserving archive packaging repair. This failed
repository check remains explicit alongside the passing capture controls.

## Original obligations and remaining work

| Original criterion | Result / remaining duty |
|---|---|
| K12 record/classify a real failure | Historically met by diagnostic-02; delivered callback/failed activation classification unchanged |
| K25 normalized preflight and raw completion qualification | Exact normalized success and unsuccessful-envelope controls pass before this guest; actual preflight is clean |
| K25/K22 actual-path capture without live output sidecar | Positive per-selection PID/interval joins and collection lags retained for all four selections |
| Bounded matched protocol, actual frozen inputs, every outcome/cleanup | One new declared guest; all slots consumed, no replacement/extension; failed final transports explicit, clone stopped, input/golden audits retained |
| K20 callback/call/event join without synchronous trace writes | Successful buffered reference retained; 101 ordered zero-drop records |
| K25/K22/K20/K18/K16/K14/K12 positive failed-path/disposition/context discriminator | UNRESOLVED; every observed Settings activation succeeds |
| Preserve historical evidence and qualify instrument timing/symptom preservation | Earlier samples unchanged/closed; reduced-load symptom preservation remains unestablished |
| Application repair and useful failing product seam | NOT DONE; capture/parser/audit controls repair instruments only |
| One Settings selection returns its one front/focused window | Four passing observations here; historical intermittent failure unresolved |
| Separate frozen complete ordinary-operation repair acceptance | NOT RUN; no final repair subject selected; diagnostics-disabled complete scenario still required |
| External cause/reproducer/upstream approval | No external ownership established; no upstream report |
| Verification/root reconciliation; no release | Updated; causal/repair ancestors remain open; no release/notarization |

The verified boundary is actual-path acquisition capability, not causal closure.
K25 decomposes into retained evidence k26 and remaining activation disposition
work k27. K27 must state a causal hypothesis and a separately bounded protocol
that can discriminate it using this positive reference, rather than repeat the
unchanged four-action instrument to chase failure. If richer native records are
needed, qualify their precise acquisition and timing effects first. It carries
every original justified product repair/useful failing seam and separately
predeclared frozen complete ordinary-acceptance duty. No ancestor closes here.
