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
