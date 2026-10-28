# Activation before window ordering: inconclusive comparison

The [declared four-guest comparison](ORDER-PLAN.md) completed its cap. The
original order failed on the first Settings action in 01 and passed all four
actions in 04. Activation-before-window ordering passed all four actions in
02 and 03. This does **not** establish the cause of the unsuccessful activation
or qualify reversal as a repair. No ordinary-operation repair acceptance ran.
The experimental source change was restored after the final measurement audit;
the separately signed B bundle and its source remain available for investigation.

The hypothesis remains unresolved, rather than disproved. Both orders can
produce active, key windows. A small set of successful B outcomes cannot show
that reversing the calls prevents an intermittent failure. Moving the trace
boundaries with their calls also moves synchronous diagnostic writes relative
to the requests; there is no instrument-free comparison here. No reliability
rate, release regression or external ownership follows.

## Subjects and every attempt

A is a copy of the unchanged signed diagnostic bundle. Its
[complete inventory comparison](order-a-original-diff.txt) with that original
is empty. B differs in application source only by moving activate and its two trace
boundaries before makeKeyAndOrderFront and its boundaries. The
[saved B source](order-source/Sources/KoineApp/AppDelegate.swift),
[build](order-build.txt), [signature](order-b-signature.txt),
[A inventory](order-a-bundle.txt), [B inventory](order-b-bundle.txt) and
[input freeze](order-frozen-at.txt) identify both subjects. B was built from
baseline f20f76c7 plus this saved application change. B is a signed,
unnotarized current-source candidate labelled 0.4.0, not the released bundle.
The local bundles are `.build/settings-activation/order-a/Koine.app` and
`.build/settings-activation/order-b/Koine.app`.

Each fresh clone used testanyware-golden-macos-27, macOS 27.0.1/26A434/arm64,
TestAnyware 2.7.0 and 1920×1080. The focused driver equals the existing menu
scenario through the initial Settings action and its three reopens, with only
the repository-root cd adjusted. There is no new input, focus action, wait or
retry. Each attempt stops at its first failure. Times below are host UTC.

| Attempt / clone suffix | Start → scenario end | Scenario / Task | Collection / audit / stop | Outcome |
|---|---|---|---|---|
| [A01](order-a-01/task.log), `order-a-01` | 03:33:31 → 03:43:29 | 1 / 201 | 0 / 0 / 0 | Initial Settings action failed; reopens 1–3 NOT RUN |
| [B02](order-b-02/task.log), `order-b-02` | 03:44:56 → 03:49:01 | 0 / 0 | 0 / 0 / 0 | All four Settings actions passed |
| [B03](order-b-03/task.log), `order-b-03` | 03:49:40 → 03:54:45 | 0 / 0 | 1 / 1 / 0 | All four actions passed; final installed-inventory transport failed |
| [A04](order-a-04/task.log), `order-a-04` | 03:55:36 → 03:58:41 | 0 / 0 | 0 / 0 / 0 | All four Settings actions passed |

Full clone names prepend `koine-k12-`. Collection ended at 03:44:29, 03:49:02,
03:55:16 and 03:59:12 respectively. No started attempt was interrupted,
replaced or extended. First-launch assertions and the TextEdit-front precondition
passed in each guest. Resize, minimum-size scrolling, shortcuts, client requests,
consent, silent launch, login restart and final Quit are **NOT RUN in all four**:
the prefix intentionally ends before them. Cleanup stopping a clone is no Quit
acceptance. These are not complete menu scenarios.

## Native observations and limitations

A01's [25-row trace](order-a-01/trace.jsonl), PID 852, records selection 1
entering the callback at 1793159006.3037071. Window-show returns at
1793159006.309242 with Settings visible, the app inactive and no key window.
Activation returns at 1793159006.3114018 with the same state. No later row
records activation or a key window. Menu closure precedes the callback, whose
mode remains kCFRunLoopDefaultMode.

The original failure screenshot, [subsequent screenshot](order-a-01/failure-observed.png)
and [agent windows](order-a-01/failure-windows.json) agree that TextEdit remains
in front of inactive Settings. Capture preceded any keyboard, focus, repeated
selection or launch intervention. The [native snapshot](order-a-01/failure-native.json)
returns agreeing text but reports timeout and exit -1. It is a failed exec,
not a qualified native read. A01's final environment exec also times out.

B02, B03 and A04 each retain a 100-row trace with active and key-window
transitions for all four selections. Per-attempt trace-integrity files record
contiguous per-process sequence numbers. B02 selection 1, for example, returns
from activation while still inactive and becomes active/key on subsequent
notification rows. A04 shows that the original order can also succeed. The
traces record delivered notifications, not an atomic WindowServer history, and
have no periodic heartbeat after their last row.

Apple's [activate contract](https://developer.apple.com/documentation/appkit/nsapplication/activate())
permits the system to decline activation. Its
[cooperative activation guidance](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation)
explains that user intent and system context determine the result; the
[WWDC23 explanation](https://developer.apple.com/videos/play/wwdc2023/10054/)
says the former ignoringOtherApps option is ignored. The installed macOS SDK's
NSRunningApplication.h also says activate(from:options:) expects a prior yield
from the other app. None supplies a supported force-activation repair here.
The sources checked do not prescribe an activation/window ordering that would
explain this recorded refusal.

The missing observation is below the present trace boundary: whether AppKit
submits the activation request to the native focus service, and whether that
service declines it under an observed activation context. Neither the normal
return from a void activate call nor a missing notification distinguishes those
possibilities. A follow-up must qualify a native request/disposition observation
or a discriminating native-path experiment, without silently adding an activation
retry. It owns any eventual repair and ordinary-operation complete acceptance.

## Integrity and checks

Both [A](order-a-final-check.txt) and [B](order-b-final-check.txt) final subject
checks passed before restoring source. Every attempt's pre/post host checksum
and complete file/link inventories match. Every initial installed inventory
matches its frozen arm. Final installed reads are clean and match for A01,
B02 and A04. B03's [final read](order-b-03/installed-after.json) times out with
exit -1; its [returned text comparison](order-b-03/timedout-inventory-text-diff.txt)
matches, but this does not make the failed transport successful. A04's final
environment exec also times out. Raw outcomes remain in each directory.

The [golden before](order-golden-before.sha256) and
[after](order-golden-after.sha256) hashes and their comparison retain the
config/disk/NVRAM check; the [comparison](order-golden-diff.txt) is empty.
[Archive checks](order-artifact-checks.txt) compare every original collection
file to its saved copy and each initial installed inventory to its frozen arm.
Explicit stop results, [VM inventory](order-vms-after.json)
and [Tart states](order-tart-after.txt) retain cleanup. Endpoint inventories
establish no continuous runtime immutability.

The [single pre-guest reviewer](order-review.txt) found no actionable defect;
it explicitly retained the native-transport and inference limits. The existing
five capture, eight pointer and nine resize controls pass in
[the focused check log](order-controls.txt). Those controls qualify helper logic,
not native activation. The experiment's wrapper preserves that existing capture
logic; its new stage names and focused Task are retained alongside the source.

The final no-VM [checks](order-final-controls.txt) validate the retained scripts
and unchanged capture/pointer/resize helpers. The current Taskfile adds this
check entry after measurement; the [saved Taskfile](order-source/Taskfile.yml)
is the one the four guests consumed. Restoring AppDelegate after final audits
intentionally changes its current hash; it is byte-identical to the original
diagnostic source, while the saved B source retains the measured intervention.

This finite comparison is discharged. Do not reset it or add an attempt to
obtain a preferred outcome. The original diagnostic sample also remains stopped
at 02. Settings activation is unresolved; no product repair, ordinary-operation
acceptance, release, notarization or upstream report was made.
