# settings-activation-native-path-k16


## Goal

Find the application/native condition that prevents the delivered Settings
activation request from producing an active, key window, then repair it where
this repository owns the cause and qualify ordinary operation.

## Context

Read the parent k14 brief and docs/verification/settings-activation/ORDER-RESULTS.md,
alongside the original README and diagnostic-02 trace. K15 completed its fixed
four-guest focused comparison: A01 original order failed at initial Settings;
B02/B03 reversed order and A04 original order passed all four actions. Both
orders can succeed. This does not establish reversal as a cause or sufficient
repair. Synchronous trace writes move with the experimental call blocks, so
the diagnostic timing limitation remains. Ordinary AppDelegate is restored
byte-for-byte. No product repair or complete ordinary-operation acceptance ran.

The present observation boundary shows a normal return from void NSApp.activate
and subsequent native notifications, not whether AppKit submitted a request or
the native activation system accepted/declined it. That missing distinction,
or an observed user-event/activation-context condition that discriminates it,
is the precise next causal question. Qualify what a native log or other public
instrument actually reports before relying on it; a plausible missing log is
not proof of no request. Do not assume that a request from a different API has
the same native path as the existing NSApp call.

K15's A01 native failure snapshot reports timeout/-1 despite agreeing text;
A01/A04 final environment reads also time out. B03's final installed-inventory
read times out despite matching returned text, retaining collection/audit 1/1.
Every available clean installed endpoint matches; host input/inventory and
golden config/disk/NVRAM audits pass; every guest stops. Raw outcomes remain in
the evidence directories. No timeout becomes a successful native read.

The original diagnostic sample stops at 02; do not run diagnostic 03. The ABBA
comparison stops at four; do not reset or extend it. A new hypothesis needs a
new bounded protocol, candidate identity and frozen actual inputs before its
first guest. Existing bundles remain locally under .build/settings-activation;
do not overwrite the diagnostic or order-a/order-b subjects. Saved overlays and
inventories, not archived bundles, are the durable evidence.

## Done when

- Discriminate the responsible activation path or condition with qualified
  causal evidence. Use official AppKit sources for version-dependent decisions;
  cite non-obvious calls at their decision sites. Neither a menu-tracking
  callback nor a menu-close deferral repair follows from existing traces.
- Preserve each original failure/classification. Any further instrument must
  state its timing effects and be qualified in a predeclared bounded matched
  experiment. Retain every started attempt, unsuccessful outcome and NOT RUN.
- If the cause is here, repair application behavior. A driver wait/retry or a
  repeated activation/input action is no demonstrated repair. Use a focused
  failing seam where feasible before changing the product. One Settings
  selection must return its one window in front and focused.
- Declare a separate finite complete-scenario acceptance set before its first
  fresh guest through task app:vm-verify-menu-bar. Freeze the final ordinary
  subject and all consumed inputs; validate with diagnostics disabled, preserve
  every outcome and address the timing limitation explicitly. The existing
  run.sh exports KOINE_SETTINGS_TRACE=1 for every stage, including repair, so it
  must not silently serve as instrument-free ordinary-operation acceptance.
- If the cause is external, preserve the reproducer and evidence and leave the
  repair outcome explicitly unresolved. No external attribution from absence
  of notifications or successful alternative calls alone; no upstream report
  without Antony's approval.
- Reconcile every original k14/k12 criterion, verification documents and root
  handoff before closing those nodes. No release or notarization required.

## Notes

Graph startup at k15 again refused before establishing a project/generation.
Bounded direct source reads covered AppDelegate, MenuBarController,
SettingsActivationTrace and the existing scenario/helpers/capture wrapper.
Try the graph normally; do not stop other sessions to acquire it. The new
check:vm-settings-order Task passes script syntax/lint and the five existing
capture controls; eight pointer and nine resize controls also pass. Those are
helper checks, not evidence that a native activation repair exists.
