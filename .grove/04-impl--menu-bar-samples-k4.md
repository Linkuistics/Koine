# menu-bar-samples-k4

## Goal

Measure the menu-bar scenario after the pointer repair and stronger reopen
assertions over a declared, bounded comparison and
leave an accurate verification record for issue 14, including every failure and
any assertion that did not run.

## Context

- `docs/verification/menu-bar-vm.md` and the preceding menu-interaction-k2 and
  window-resize-k3 artifacts.
- `Taskfile.yml`, `app:vm-verify-menu-bar`, and the scenario's sourced helpers.
- Issue 14's historical 0.4.0 5/9 and 0.3.0 3/3 results are small historical
  samples, not proof of a release regression.

## Done when

- Before sampling, record the exact bundle subjects, script/input identities,
  guest image, OS/build, TestAnyware version, display configuration, run order,
  attempt cap and stopping rule. Use matched fresh-guest conditions for the
  released 0.3.0 and 0.4.0 bundles where available. If an application repair was
  necessary, identify its candidate bundle separately rather than calling it
  the released 0.4.0 image. No new release is required to collect these samples.
- Declare a finite diagnostic sample, not a statistical reliability promise.
  End at the cap or a finding that requires a new repair. Never rerun until only
  green outcomes remain, or pool results across a mid-run script/bundle edit.
- Record each started attempt, exit outcome, completed assertions, NOT RUN
  assertions and interruption. Keep per-attempt logs/screenshots and one writer
  per result. Hash the actual subjects before and after the measurement.
- Preserve complete scenario coverage, including first launch, repeated menu
  reopening, requests, consent, shortcuts, silent launch, login restart and Quit.
  Resize success is credited only when that assertion actually ran.
- Update the existing verification record and any directly affected public
  claims. Explain what the finite sample establishes and what remains unknown.
  Make any residual failure actionable without declaring it repaired or silently
  closing an unresolved issue.

## Notes

K8 recreated one historical-route Settings action successfully from a natively
TextEdit-active baseline. It did not establish a historical activation cause or
justify a product repair or new focus polling bound. Keep that issue outcome
unresolved even if all declared samples pass. Its native before/after results,
visible menu dismissal and exploratory permission correction are retained in
docs/verification/menu-bar-activation and described in menu-bar-vm.md.

The precise remaining activation task belongs to this already-chartered finite
sample: at the first reproduced front-window failure, retain a fresh-process
native activation read, independent CoreGraphics window order, agent windows
and the screenshot/menu state before keyboard, window-focus or repeated menu
input. Prepare that collection before freezing the sample (for example, retain
the guest until observation-only failure collection, then stop it explicitly).
Use the qualified menu-bar-focus/activation-snapshot.m; upload needs an explicit
executable permission. Do not use System Events focus as an independent oracle
or the old non-run-loop polling monitor as an activation trace. If the failure
still cannot be classified, retain the failed evidence and name the exact
missing observation rather than selecting a workaround. Do not expand the cap
to chase a failure. A successfully collected action is no historical repair.

The scenario now records the installed guest bundle's regular-file hashes and
associated symlink paths/targets before launch and after final Quit. Preserve
those alongside each host per-file inventory, which must include App/Info.plist,
all sourced helpers and both client fixtures. These are endpoint comparisons,
not proof of an immutable runtime. An early failure may lack the after read.

The preceding leaves must leave their scripts settled before this measurement.
If this sample reveals a new cause, retain its failed evidence and cut the
specific repair before a fresh measurement. An outcome requiring a future
release remains explicit; it does not authorize releasing one here.

K3's sole full-scenario attempt reproduced the activation failure at Settings
reopen 3 before resize, in `koine-resize-k3-scenario`. Its post-failure native
read, agent ordering and screenshot agree TextEdit is active/in front and Koine
inactive behind it. These observations were collected before keyboard or focus
intervention; no complete native pre-action observation was taken. Read
`docs/verification/window-resize/scenario-failure-native.json`,
`scenario-failure-windows.json`, `scenario-activation-failure.png` and
`scenario.log`. The fresh observer had explicit executable permission and
returned exit zero with no timeout. This establishes a reproduced failure with
corroboration, but no causal explanation or product repair. Retain it in the
historical outcome regardless of k4's sample results.

K3 replaces the title-bar proxy gate and down/up corner sequence with prepared
held-button interpolation, retaining all size/content assertions. Include
`scripts/vm-window-resize-lib.sh` in host subject inventories. A full-scenario
pass with this route remains a separate obligation from a focused resize pass;
an earlier activation failure leaves resize and all following assertions NOT RUN.

Both k3 unpaced focused fresh-guest candidates failed growth, including the
version with explicit focus setup. K10 subsequently settled the route and
qualified it, as recorded below; retain those failed candidates in the history.


K10 qualified the paced helper on the unchanged signed 0.4.0 bundle. Its final
focused attempt and sole final complete scenario both grew to 703×903 and stopped
at 440×352 with actual AXScrollArea content height 320, then reached the existing
required controls by scrolling. The complete scenario exited 0 with every
intended assertion run. This is one complete positive, not a reliability rate
or historical activation repair. Read docs/verification/resize-delivery/README.md
and scenario.log; preserve k3's earlier native activation failure and all its
unrun assertions independently.

Use the settled paced held-button helper and corrected frame/content guards.
The request/error/guard seam has nine resize controls plus the eight existing
pointer controls. The comparison isolates recipe sensitivity, not a pure timing
cause: per-command connections, sleeps and point count changed together. No
upstream defect or application repair was established. The final complete guest
started at 1920×1080 and reverted to 1024×768 after restart; record and match
that actual display sequence in the bounded sample. The final host/installed
endpoint inventories agree, and every k10 guest is stopped.
