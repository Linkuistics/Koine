# menu-focus-evidence-k7

## Goal

Qualify independent focus observations around a single Settings action, preserve
all exploratory failures, and make the existing scenario check every intended
reopen from one action. Leave the unexplained historical failure to k8.

## Done when

- Retain menu-open/dismissed screenshots, pointer delivery, native activation
  and window ordering before keyboard input, and an actual keyboard recipient.
- Distinguish unreliable System Events readings, the polling monitor's
  potentially cached activation field, failed AX reads and driver timeouts.
- Check each Settings iteration, request review, Accessibility, explicit reopen
  and pre-Command-Q opening independently; send initial launch and explicit
  reopen once. No new polling or guessed activation delay.
- Execute one full Taskfile attempt with complete per-file hashes of the actual
  extracted bundle, all sourced scripts, Taskfile and both client fixtures before
  and after it. Retain failures and NOT RUN outcomes and update the existing doc.

## Execution plan

1. Preserve the exploratory source, logs and bounded observations. Use the
   fresh native observer and keyboard receipt to qualify the focus observation.
2. In scripts/vm-verify-menu-bar.sh, move the loop's focus assertion into each
   iteration, add the missing Accessibility and pre-Command-Q assertions, and
   use guest_once for initial launch and explicit reopening. Update the Taskfile
   description. Keep the existing count observation and timing untouched.
3. Run Bash syntax, ShellCheck and the existing pointer checks. Freeze all
   inputs, run app:vm-verify-menu-bar once, then verify the inventory item by item.
4. Reconcile docs/verification/menu-bar-vm.md, keep menu-activation-k8 precise,
   retire this child and commit with the parent still live.

## Decisions (running log)

- These are assertion-placement and one-action plumbing changes at the agreed
  real-VM seam. The complete scenario verifies them; no source-text test will
  mirror the placement of assertions. No application code or focus wait changes
  are justified by this evidence.
- The single fresh-context reviewer found a low-severity provenance gap: the
  first keyboard probe happened outside the retained script, and its delayed
  after-action screenshot already contains the probe text. Valid and actionable:
  qualify those artifacts as incomplete action provenance; base the keyboard
  claim on the separately traced controlled-TextEdit sequence. This is a prose
  correction, not a new behavioral change or a second-review need. No other
  findings were reported.
- Read the macOS 27 SDK's NSRunningApplication.h: time-varying properties persist
  until a main-run-loop turn in a common mode. This confirms the reason to
  exclude the polling monitor's activation field. The retained one-shot native
  source now carries that source citation; the annotation changes no probe logic.
- `task check:vm-menu-pointer` passed all eight controls plus its syntax,
  ShellCheck and formatting steps. Separate scenario syntax/ShellCheck passed.
  Start exactly one complete scenario with scripts and all regular files of
  the actual extracted KOINE_APP_BUNDLE inventoried; record symlinks separately.
  The input inventory also includes Taskfile, both uploaded clients and release
  zip. Guest koine-menu-k7-scenario uses the same macOS 27 golden.
- The complete Taskfile attempt exited zero. Every intended reopen assertion,
  silent launch, explicit reopen, pre-Command-Q focus, login launch and final
  shutdown ran. Resize remains NOT RUN; scroll reachability used default size.
- Recomputed every inventoried file and re-enumerated the extracted host input
  app tree: all paths/hashes and symlink mappings matched. Post-run deep strict
  signature verification passed. The guest copy itself was signature-checked,
  not independently per-file hashed before/after. Repository App/Info.plist was
  checked separately against the initial clean immutable parent a764302d; future
  runs should include that read explicitly in the pre-run SHA inventory.
- Two extra observation-only calls during a position-read delay are retained
  and explicitly not treated as atomic action-boundary evidence. No extra input
  or focus intervention was supplied during the scenario. Both guests stopped.
- K7's evidence and assertion-coverage increment is complete. K8 remains live:
  the historical screenshot-confirmed failure has no established cause, so k6
  and k2 cannot close. No application repair or new activation bound is claimed.
