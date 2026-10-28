# Koine menu-bar VM reliability — brief

## Goal

Resolve the menu-bar verification problems recorded in
[Koine issue 14](https://github.com/Linkuistics/Koine/issues/14): intermittent
front-window assertions, rejected negative pointer coordinates, and the missing
window-drag resize exercise in the macOS 27 guest. Preserve the distinction
between a Koine failure, a test-driver failure and an assertion that did not run.

## Done when

- The intermittent failure paths have evidence-based diagnoses and verified
  repairs where the cause is within this repository. Any remaining external
  limitation has a concrete reproducer and an explicit unresolved outcome.
- Resize evidence exercises the user's minimum-size behaviour through a working
  input route. If that route remains unavailable, resize stays NOT RUN and the
  evidence continues to name the older run on which the claim rests.
- A bounded set of complete VM runs records each attempt, bundle and environment,
  including failures and assertions not run. Comparisons use matched conditions
  and make no reliability claim beyond their sample.
- The reusable Taskfile entry and verification document describe the resulting
  procedure and its limits. No release is produced as part of this workstream.

## Decomposition

Requirements were established in plan-k1. Three implementation work items
follow: menu-interaction-k2 diagnoses and repairs menu input/focus checks;
window-resize-k3 restores or isolates resize input; menu-bar-samples-k4 measures
the resulting scenario over a declared finite sample. Each owns its evidence
and any local repair. If investigation makes a leaf too large, that leaf
decomposes with the new evidence rather than guessing later work now.

## Test seams — agreed with Antony

Keep `task app:vm-verify-menu-bar` as the end-to-end seam: a real signed bundle,
real menu input, independent window observations and screenshots in a disposable
TestAnyware guest. Preserve the minimum-size assertion's user-input semantics;
an Accessibility frame assignment alone does not prove the constraint.

Use focused non-GUI checks for any repaired script logic at its existing helper
boundary, such as pointer coordinates or observation classification. Such checks
supplement the VM exercise; they cannot establish native window behaviour.

Antony agreed on 2026-10-28: "Yes, use that test scope." The proposed scope kept
the real menu-bar workflow in disposable TestAnyware VMs, focused script checks,
and resize explicitly unresolved until actual user-input resizing works. A
documented external limitation can conclude this workstream's resize investigation;
it cannot count as resize acceptance or close that unresolved issue outcome.

## Pointers

- [Issue 14](https://github.com/Linkuistics/Koine/issues/14), read on 2026-10-28.
- `docs/verification/menu-bar-vm.md`: established 0.3.0 evidence and the 0.4.0
  attempts, failures and resize limitation.
- `README.md`, Resident application: the behaviour being verified.
- `Taskfile.yml`, `app:vm-verify-menu-bar`.
- `scripts/vm-verify-menu-bar.sh` and `scripts/vm-verify-lib.sh`: the scenario,
  menu-pointer helpers, front-window observation and corner-drag route.

## Notes

Issue 14 explicitly says these findings do not block 0.4.0 under the roadmap's
happy-path release rule. It records 5/9 passes for the unchanged notarised 0.4.0
bundle and 3/3 for 0.3.0; this does not establish a regression. The old counts
also omit a successful resize exercise on macOS 27.0.1/TestAnyware 2.7.0.

The graph CLI could not establish a project or generation during plan-k1:
`CBM CLI could not start because a pre-coordination or unverified CBM generation
is active; close all CBM sessions and commands, then retry`. Source observations
in this brief use bounded direct reads, not graph completeness claims. Do not
stop other sessions merely to obtain graph access.

## Menu-interaction handoff

K5 repairs the demonstrated coordinate defect while preserving the valid target;
its historical failing source frame was not recovered. K7 qualifies the focus
instruments and asserts every intended reopen from one Koine action. K8 adds a
successful historical-route recreation and one full passing scenario with
matched host-input and installed-guest regular-file/symlink endpoint inventories,
including App/Info.plist in the original host inventory.

Menu-interaction-k2 and menu-focus-k6 close under their explicit allowance for an
unexplained historical symptom with a precise remaining task. **The historical
activation failure is still unresolved.** No application activation change,
new focus polling bound, reliability rate or external cause is established. The
original criteria are checked in both node briefs. K4 already owns the finite
sample and now carries precise native/window/visible failure capture before
keyboard, focus or repeated action intervention; an all-green sample does not
close that historical issue outcome. Do not expand its cap to chase a failure.

K8's resize remained NOT RUN, with scroll reachability at the default size.
K3 still owns the missing user-input resize exercise; no new minimum-size
acceptance follows from the passing menu scenario. The detailed evidence and
endpoint-inventory limitations are in docs/verification/menu-bar-vm.md.

## Resize investigation handoff

Window-resize-k3 decomposed after exploratory corner successes failed fresh
qualification twice. Resize-input-evidence-k9 delivers the request/error seam,
both failed candidates and the native observations; resize-input-delivery-k10
continued the precise input-delivery/timing investigation. At that handoff there
was no new minimum-size or minimum-size scrolling acceptance on macOS 27; k10
subsequently qualified the paced route below. The prior macOS 26/0.3.0 evidence
remains the historical acceptance for that older release.

The one complete k3 attempt also reproduced Settings reopen 3 behind TextEdit;
fresh native activation, CoreGraphics order, agent windows and the screenshot
agree before any keyboard/focus intervention. This supplies new corroboration
but no activation cause. K4 owns that causal question and the full-scenario
sample after the resize subtree settles. All k3 guests were stopped. See
docs/verification/menu-bar-vm.md, User-input corner route, and the raw
docs/verification/window-resize evidence. No release or upstream report was made.


## Qualified resize handoff

K10 closes window-resize-k3 with a useful user-input route on the unchanged
signed 0.4.0 bundle in macOS 27.0.1/TestAnyware 2.7.0. Matched initial-frame
controls showed unpaced 100-step corner input failing fresh Koine at both tested
insets while growing TextEdit. Separate paced held-button requests grew both.
The helper keeps the three-pixel inset, waits after its initial down and ten
held points, attempts release on transport failure and never retries the input.
Pacing, point count and connection lifecycle changed together; no pure timing
cause or external defect ownership is established.

The final frozen focused run and the sole final complete scenario both grew to
703×903 and stopped at 440×352 with 320 measured content pixels; scrolling reached
the existing required controls. The complete scenario exited 0 with all intended
assertions run, including login restart and Quit. Installed and host endpoint
inventories match; all investigation guests stopped. The display began at
1920×1080 and reset to 1024×768 after restart. Nine resize controls and the eight
pointer controls pass; the scenario also now rejects failed frame reads and
checks actual content height rather than inferring it from outer frame height.

K4 can use the settled script. It still owns its declared finite sample and the
historical activation cause; a positive k10 run closes neither. Retain k3's
failed complete attempt and its unrun assertions, both failed unpaced focused
candidates, and the older macOS 26/0.3.0 evidence. The current native evidence is
in docs/verification/resize-delivery and the Paced fresh-window route section of
menu-bar-vm.md. No release, application repair or upstream report was made.

## Bounded comparison handoff

K4 reached its declared four-attempt cap with the unchanged released bundles,
settled scenario/helpers and matched fresh macOS 27.0.1/26A434 guests. The order
was 0.3.0, 0.4.0, 0.4.0, 0.3.0. Attempt 02 completed every assertion, including
703×903 growth, a 440×352 minimum frame with 320 measured content pixels,
minimum-size scrolling, requests/consent, shortcuts, silent launch, login restart
and final Quit. It began at 1920×1080 and reset to 1024×768 after restart.

Attempts 01/03 failed at Settings reopen 1; attempt 04 failed at reopen 3.
Both releases therefore reproduced the activation symptom. Resize and every
later phase are NOT RUN in those attempts. There was no interruption, replacement
or full-scenario retry. Every subject audit passes; all available installed
inventories match their frozen host release inputs, with both endpoints available
only for the complete pass. Every guest stopped. No measured input changed.
Final golden config/disk/NVRAM hashes also match their pre-sample values.

The first two failure captures have clean fresh native activation/CoreGraphics
reads, agreeing agent windows and original/subsequent screenshots before any
key/focus/repeated-action intervention. The final failed attempt's observer emits
agreeing complete JSON but reports timeout and exit -1, as does its final
environment read. These transport failures are explicit, not successful native
reads or new scenario failures. The original scenario exits remain 1/0/1/1,
separate from Task's 201/0/201/201.

The causal question remains open under k4's explicit instruction to retain an
unclassified failure and name the missing observation. That observation is a
time-correlated record across one Settings selection: callback entry,
window-show/activation calls and native active/key-window transitions. The
post-failure captures cannot distinguish missing callback delivery, failed
activation and activation subsequently lost. No workaround or product repair is
selected. This work does not close issue 14's activation outcome, claim a rate or
regression, or pool these attempts with k3/k10/historical evidence.

The durable report and full assertion/NOT RUN table are in
docs/verification/menu-bar-samples/README.md and the main menu-bar verification
document. The Taskfile exposes the one-attempt wrapper and six focused no-VM
controls, alongside the existing eight pointer and nine resize controls. One
pre-freeze reviewer found two instrument gaps; mutation controls demonstrate the
fixes. No release or upstream report was made. The finite measurement charter
has been discharged without representing the unresolved issue as repaired.

## Settings activation observation handoff

Antony requested repair of Settings reopening at the finish proposal. K12
decomposed into observation/evidence k13 and the remaining causal repair work.
K13 adds opt-in callback/show/activation and native active/key-window observation
without changing the application's call order or adding an input/focus retry.
Its declared diagnostic sample stops at the first classified failure within a
three-guest cap: 01 completes every scenario assertion; 02 reproduces Settings
reopen 3 behind TextEdit. Attempt 03 must not start under this charter.

In 02, Settings callback selection 4 reaches show and activation, with the window
visible but the app inactive and no key window. No subsequent become-active/key
notification is recorded. Prior selections in the same process record both.
This classifies failed activation in the observed interval, rather than missing
callback or an observed activation then lost. The callback runs in default
run-loop mode after menu.didClose; menu-tracking deferral is no demonstrated
repair. The recorded failure shows observation can preserve the symptom, without
proving timing neutrality. Application/platform cause and product repair remain
open under k12. No external ownership, rate or regression is established.

Scenario/Task exits are 0/0 and 1/201. 01's final inventory exec and 02's native
failure observer return complete agreeing text but report timeout/-1; neither
is a successful native read. 02's screenshot and agent windows independently
agree with the inactive-behind-TextEdit state before intervention. Its resize
and every later assertion are NOT RUN. Host full bundle inventories and hashes
match; 02's installed endpoint read is clean. Both guests stopped. Five focused
capture controls, eight pointer controls and nine resize controls pass. The
signed diagnostic candidate is not the released bundle and is unnotarized.
The durable record and raw traces are in docs/verification/settings-activation.
No release or upstream report was made. The successor owns a causal repair and
its own bounded fresh-guest complete-scenario acceptance; k12 stays open.

## Activation ordering comparison handoff

K14 decomposes after k15's declared four-guest focused comparison. The original
call order fails once at initial Settings and passes once; activation before
window ordering passes both attempts. Both orders therefore produce active/key
windows in this sample, but there is no established cause or qualified repair.
The experimental ordinary-source change is restored after final audits. K14's
successor owns the native request/disposition boundary and eventual application
repair with complete ordinary-operation acceptance. Neither completed sample
may be extended to seek a preferred outcome.

All host subject/inventory and golden config/disk/NVRAM checks match; every clone
stops. One passing B scenario's final installed read times out with matching
returned text, leaving collection/audit 1/1. The failed A native snapshot and
two final environment reads also time out. These are retained failed transports,
not successful native reads. The focused prefix supplies no resize, scrolling,
shortcuts, consent, client-request, restart or Quit acceptance. Full outcomes and
the precise missing native observation are in
docs/verification/settings-activation/ORDER-RESULTS.md. K12 remains open; no
release, notarization or upstream report was made.

## Native activation-path qualification handoff

K17 completes a new two-guest native-log qualification on the unchanged signed
diagnostic candidate. Both guests pass all four Settings actions. The actual
NSApp interval correlates to a native client call, WindowServer front change
and resume, followed by active/key notifications. This is a successful reference
for the missing native observation, with no failed disposition or cause. The
wide debug stream adds substantial load and leaves synchronous trace timing in
place; preservation of the symptom under that instrument is unestablished.

All recorded scenario, native capture, endpoint, host/golden audit and clone-stop
outcomes pass. Resize and all later full-scenario phases are NOT RUN in these
focused guests. All original failures and incomplete assertions remain. K16
decomposes to completed native evidence k17 and remaining activation-context
repair k18. Every original k12/k14/k16 causal repair and ordinary-operation
acceptance obligation remains live; no completed sample may be extended. The
durable report is docs/verification/settings-activation/NATIVE-RESULTS.md. No
product change, ordinary acceptance, release, notarization or upstream report.

## Reduced activation-context handoff

K19 completes the reduced-filter/context evidence slice of decomposed k18.
Offline filtering retains every known native reference row; a front-term mutant
fails. The overall three-guest budget contains two preflight parser failures
before Koine launch and one focused guest passing four Settings assertions.
The first golden digest completes four seconds after the first clone launch;
initial charters end for instrument defects, with separately frozen corrections
and no guest replacement/cap expansion. All limits remain in CONTEXT-RESULTS.md.

The actual application's reduced native stream shows successful client/front
changes/resumes only. Its prelaunch trace check/logger start are clean; post-trace,
logger-stop, final environment and installed transports time out. Matching text
is retained as failed transport. Host/archived overlay and final golden audits
match; every clone stops. Resize and every later complete-scenario phase are
NOT RUN. No failure under the reduced instrument means no symptom-preservation
qualification, cause, external owner, product repair or ordinary acceptance.

K20 owns the missing callback/call and user-event-context join without synchronous
trace-file writes, positive failed actual-path discrimination, and every original
k18/k16/k14/k12 repair and separately declared complete ordinary acceptance duty.
Those nodes remain open. Diagnostic-02's delivered-callback/failed-activation
classification and all older failures remain unchanged. Every completed sample
stays closed; no release/notarization/upstream report.
