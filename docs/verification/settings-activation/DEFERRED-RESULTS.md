# Deferred archive acquired; actual Koine path unqualified

The sole [declared deferred guest](DEFERRED-PLAN.md) stopped before Koine launched.
A clean preflight response ends with its completion marker, but TestAnyware removes
the trailing newline required by the new check. This is an instrument failure,
not a Settings activation failure. **Every application assertion is NOT RUN.**
The one-guest cap is closed; no corrected guest, replacement or replay occurred.

Post-observation public `log collect` nevertheless acquired and rendered a native
archive without a live reader. It retains recent loginwindow Info client calls,
not Koine's actual path. That establishes a working archive transport and generic
Info retention in this guest. It does not qualify actual-path retention, failed-
activation discrimination, symptom preservation or a product repair. K25 owns
those duties and separately declared complete ordinary-operation acceptance.

## Subject, protocol and every outcome

The unchanged signed candidate is `.build/settings-activation/events/Koine.app`.
Its [full inventory](deferred-bundle.txt) equals the earlier events candidate's;
[signature checks](deferred-signature.txt) pass. It is an unnotarized current-source
candidate labelled 0.4.0, not the released bundle. Guest strict/deep checks pass;
Gatekeeper reports Unnotarized Developer ID. Installation sets no quarantine
attribute and supplies no first-launch Gatekeeper acceptance.

Clone `koine-k12-deferred-01` used macOS 27.0.1/26A434/arm64, TestAnyware 2.7.0 and
1920×1080. Host UTC on 2026-10-28: completed freeze 05:28:09, wrapper start
05:28:15, scenario end 05:29:11, collection end 05:30:57. There was no restart.
The prefix preserves the original NSApp/window order and existing input/focus
checks. It starts no native log reader or logging-configuration mutation.

| Outcome | Status |
|---|---|
| Scenario / inner Task | 1 / 201 |
| Wrapper / outer launcher Task | 201 / 201 |
| Combined native collection / collection / audit | 1 / 1 / 1 |
| Raw archive acquisition / packaging | 0 / 0; clean exec envelope |
| Clone stop | 0; expected ID, ok/stopped true |

[Task log](deferred-01/task.log), [launcher](deferred-launcher-task.log),
[original statuses](deferred-01/) and [stop envelope](deferred-01/stop.json) retain
these separate outcomes. The archive transport's success does not change the
failed qualification or combined collection statuses.

Installation, initial normalized installed inventory, trace-disabled precondition,
buffer enable and System Events setup complete. The [preflight](deferred-01/deferred-preflight.json)
returns ok=true, exit=0, timed_out=false and the completion marker without a final
newline. The old literal `endswith("...\n")` rejects it before first launch.
Help usage exits 64 are explicitly retained; they are not this failure. The
read-only root logging status uses the documented disposable admin/admin account.

**NOT RUN:** first-launch title/frame/agent/Dock/menu assertions, TextEdit-front
precondition, initial Settings selection, reopens 1–3, resize/minimum-size/content
height/scrolling, shortcuts, client requests/denials, Accessibility consent, silent
launch, running-app reopen, login restart and Quit. Clone stop is cleanup.
The [native snapshot](deferred-01/failure-native.json), [windows](deferred-01/failure-windows.json)
and [screenshot](deferred-01/failure-observed.png) capture the prelaunch state;
they are not observations of a failed activation. No user action was repeated.

## Public acquisition and its limits

Apple's [logging guidance](https://developer.apple.com/documentation/os/generating-log-messages-from-your-code)
explains memory/disk levels, and its [WWDC20 persistence explanation](https://developer.apple.com/videos/play/wwdc2020/10168/)
says collection can retain recent Info while unconfigured Debug is discarded.
`--last 10m` requests a time range, not completeness. `--debug` displays retained
Debug records; it cannot recreate disabled records. The installed guest's public
help and configuration/process observation are in the preflight envelope. The
[host help](deferred-host-log-help.txt) also retains usage statuses.

The one [acquisition envelope](deferred-01/deferred-collect.json) is clean. Native
collection starts at 05:29:12, finishes at 05:29:14 and renders by 05:29:16, after
the failed preflight and untouched state capture. No packaging recovery is used.
The full raw archive remains locally at
`.build/settings-activation/deferred/01/deferred-native.tgz` (about 59 MiB), with
its [digest](deferred-archive.sha256) and [extracted file hashes](deferred-archive-files.sha256)
retained here. The full system archive is not committed; reproducing the full
archive reading requires that local artifact. The [lossless filtered rendering](deferred-01/deferred-native/native.jsonl.gz)
and all scalar/raw transport evidence are committed.

The [native summary](deferred-native-summary.json) records 2,934 JSON rows:
743 Info, 2,031 Default, 25 Error and 135 other/metadata rows. There are no Koine
process rows. Two loginwindow Info `SLSSetFrontProcessWithInfo` records are dated
05:28:23.306934 and 05:28:24.124502 UTC, about 48–49 seconds before collection.
These are positive generic native records, not Koine's NSApp call or evidence of
its submission/disposition. No buffered Settings interval exists to join. The
reader's historical positive controls remain offline controls only.

The [collection stderr](deferred-01/deferred-native/collect.stderr) reports missing
uuid text. The rendering contains no Debug messages. Neither the archive nor its
filtered reading proves completeness or a guaranteed retention duration. A lack
of matching records cannot prove an absent request or native refusal; filtered
loss-row counts also cannot certify lossless system delivery. Removing the live
reader leaves buffering/observers and ordinary native logging work, and this
prelaunch failure supplies no symptom-preservation or timing-neutrality evidence.

## Failed endpoints, parser correction and integrity

The [dump](deferred-01/events-dump.json) is a clean transport with guest exit 1:
there is no receiver/output because Koine never launched. Both independent buffer
file downloads fail. The [post-trace](deferred-01/trace-disabled-after.json),
[environment](deferred-01/guest-final.json) and [installed endpoint](deferred-01/installed-after.json)
report timeout/exit -1. The trace marker and [matching inventory text](deferred-installed-timeout-text.txt)
remain failed transports. Combined native collection/collection/audit stay 1/1/1.
Initial normalized installed inventory matches the subject using the inherited
read helper; no separate clean raw envelope is asserted for that helper.

All 290 [frozen subjects](deferred-subjects.sha256) match in the
[final pre-correction audit](deferred-final-subject-check.txt). Only afterward,
retain the exact [measured prefix/tests](deferred-measured-inputs/), extract the
preflight boundary and run the actual normalized response as a fixture. It
[fails before correction](deferred-preflight-red.txt). The correction accepts the
last complete marker line with or without a trailing newline, while refusing
wrong markers and timeouts. Ten new controls and inherited event/context/native/
capture suites [pass afterward](deferred-final-controls.txt). No corrected guest
runs and no previous outcome changes.

The [overlay check](deferred-measured-overlay-check.txt) reconciles every original
frozen input to unchanged current bytes or its exact two-file measured overlay.
The new host preflight helper is a post-measurement extraction/correction.
[Artifact checks](deferred-artifact-checks.txt) compare every original collected
file to its saved copy, restoring gzip; [archive scalar checks](deferred-archive-scalar-check.txt)
compare independently downloaded files with their packaged counterparts. Archive
[digest verification](deferred-archive-check.txt) passes. Completed golden
[before](deferred-golden-before.sha256)/[after](deferred-golden-after.sha256)
config/disk/NVRAM hashes [match](deferred-golden-check.txt); the initial digest
finished before clone start. [VM](deferred-vms-after.json)/[Tart](deferred-tart-after.txt)
inventories and the validated stop retain cleanup. The host [doctor](deferred-doctor.json)
retains its existing disabled start-at-login finding; no machine setting changed.

The sole [review](deferred-review.txt) found raw-archive loss on early acquisition/
rendering failure. [Failing fixtures](deferred-package-red.txt) precede EXIT
packaging with separate statuses and bounded packaging-only recovery. Original
[transport](deferred-controls-red.txt) and [reader](deferred-join-red.txt) failures
precede their implementations; eight [pre-freeze controls](deferred-controls.txt)
pass. Initial development also exposed shellcheck redirect/trap diagnostics and a
host zsh read-only-variable error; they were corrected before freeze and consumed
no guest. The final newline defect is retained separately above. No second review
was run; the parser correction has its exact executable failing seam.

The [documentation check](deferred-doc-links.txt) remains failed for the two
pre-existing missing relative targets in the archived initial context charter.
K23 already owns their byte-preserving packaging repair. This report introduces
no additional link diagnostic; the whole check is not credited as passing.

## Every original duty and handoff

| Original criterion | Result / remaining duty |
|---|---|
| K12 actual failure recorded/classified | Historically met by diagnostic-02; delivered callback/failed activation remains unchanged |
| K22 post-scenario public native acquisition | Clean archive/generic Info transport; actual Koine path unqualified because first launch never ran |
| New bounded frozen protocol, all outcomes and cleanup | Sole declared attempt retained and closed; parser failure/timeouts explicit, original frozen/overlay/golden audits match, clone stopped |
| K20 successful buffered callback/call/event join | Earlier events reference unchanged; no buffer or actual-path observation in this attempt |
| K22/K20/K18/K16/K14/K12 positive causal discriminator | UNRESOLVED; no failed actual-path request/disposition/responsible context observed |
| Preserve failures and qualify instrument timing/symptom preservation | Historical samples unchanged and closed; deferred sample supplies no actual-app qualification |
| Product repair and useful focused failing product seam | NOT DONE; parser/package controls repair only instruments |
| One Settings selection returns its one front/focused window | NOT RUN here; historical failures unresolved |
| Separate frozen complete ordinary-operation acceptance | NOT RUN; no final repair subject selected; diagnostics-disabled complete scenario still required |
| External ownership and reproducer/upstream approval | No external ownership established; no upstream report |
| Verification/root reconciliation, no release | Updated; k22/k20/k18/k16/k14/k12 remain open; no release/notarization |

K24 retains this completed evidence slice of decomposed k22. K25 owns positive
actual-Koine-path qualification under a separately named finite protocol with the
corrected preflight, every causal repair duty and separate ordinary acceptance.
No existing bound is extended, no failed endpoint is replaced and no generic
native call is substituted for the application's actual path. The Settings
repair remains unresolved.
