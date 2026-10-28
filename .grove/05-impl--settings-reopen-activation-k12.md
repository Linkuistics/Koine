# settings-reopen-activation-k12


## Goal

<!-- tc: depart synonym-rotation because "fix" is the human's quoted words -->

Find why the Settings window sometimes reopens behind TextEdit after a menu-bar
selection. Repair it where the cause is in this repository. Antony asked
for this on 2026-10-28, at the finish proposal: "I want you to fix the
settings-reopening failure".

## Context

- The bounded comparison in k4 reproduced the symptom with both released
  bundles. Attempts 01 and 03 failed at Settings reopen 1, and attempt 04
  failed at reopen 3. K3 also reproduced reopen 3 behind TextEdit. No rate or
  regression is established.
- `docs/verification/menu-bar-samples/README.md` and
  `docs/verification/menu-bar-vm.md` name the missing observation. It is a
  time-correlated record across one Settings selection: callback entry,
  window-show and activation calls, and native active and key-window changes.
  The post-failure captures cannot distinguish a missing callback, a failed
  activation and an activation that is lost later.
- `task app:vm-verify-menu-bar` is the end-to-end seam, with focused no-VM
  controls at the helper boundary. These checks are agreed in the root brief.
- K8 found no activation change, focus polling bound or external cause.

## Done when

- Add the missing time-correlated instrument before any repair. It must record
  one Settings selection without keyboard, focus or repeated-action
  intervention. Show that it does not hide the symptom, for example by a
  reproduced failure while it records.
- Classify at least one reproduced failure as a missing callback, a failed
  activation or a lost activation, from the recorded order of events.
- If the cause is in this repository, repair the application, not the test
  driver. A test-only wait or retry does not count as the repair. Add a focused
  check at the existing seam where one can show the repaired logic.
- Check the repair over a bounded set of fresh-guest complete scenarios. Declare
  the set before the first run, record every attempt, and make no claim beyond
  that sample.
- If the cause is outside this repository, retain the reproducer and the
  classification. Leave the outcome explicitly unresolved, and do not report it
  upstream without the human's approval.
- Update the verification documents and the root brief handoff. No release is
  produced.

## Notes

The instrument can change the timing. If the symptom then does not appear in a
declared bound, record that result as a finding. Do not expand the bound to
chase a failure. Decompose instead.
