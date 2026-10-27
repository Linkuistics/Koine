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
