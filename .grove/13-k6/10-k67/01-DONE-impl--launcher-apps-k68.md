# launcher-apps-k68

## Goal

Turn installing and onboarding the required applications into a reusable
Taskfile recipe. It produces an isolated macOS VM state in which each launcher
is installed and has completed its first run and Gatekeeper approval, with a
recorded inventory.

## Context

- The workspace spec's Twelve launchers row, and the node brief's note that
  later increments repeat this preparation.
- The existing TestAnyware recipes and their golden-image conventions.

## Done when

- One recipe prepares a reusable VM state or clone with all twelve launchers
  installed from their normal distribution. Each has launched once past
  Gatekeeper and first-run UI, without signing in to any account.
- Safari remains available as the default browser, and Dia can be made the
  alternate default.
- The inventory records each application's actual bundle identifier, version,
  installed path, and any onboarding that needed GUI action.
- An application that cannot be obtained without an account or purchase is
  recorded as live preparation work, with the reason.
- The recipe is verified by a run whose inventory matches the resulting VM.

## Notes

Nothing is installed or launched on the host. Keep the separately quarantined
copy the Gatekeeper-pending case needs out of the approved state.

## Decisions (running log)

- The prepared state is a tart image (`koine-launchers-prepared`) made by
  `tart clone` of a stopped, cleanly shut-down clone, started later with
  `testanyware vm start --base`. The golden image is never changed. The recipe is
  `task launchers:prepare` / `launchers:verify` / `launchers:inventory`, and
  `docs/verification/launcher-apps-vm.md` is the evidence.
- Jump Desktop comes from the vendor's own download, not its Homebrew cask: the cask
  pins 9.1.9, which aborts at launch on macOS 26.5. The inventory records whatever
  version the vendor link serves that day.
- First runs are driven by narrow, logged rules keyed on dialog owner and button label.
  Nothing signs in, types an email address or starts a purchase; an account gate is
  where first run stops. Mail's Add Account sheet and Dia's email gate are resting
  states, not steps (Mail's Cancel quits Mail).
- Kimi's Accessibility request returns after every Deny, so it is answered once and
  its return is recorded as recurring, not waited out.
- Install, then **restart the guest**, then first-run: the boot that ran Zed's cask
  postflight opened Zed with no dialog and left it unapproved, and a fresh clone
  raised the dialog.
- The Gatekeeper-pending copy is Obsidian, archived with `tar` before any first run
  (`ditto` zips drop the quarantine attribute on extraction, with or without `--qtn`),
  kept in the guest account's `~/gatekeeper-pending/`.
- Dia is made the alternate default browser by `NSWorkspace.setDefaultApplication` for
  `http` and the system's "Use / Keep" confirmation, and Safari restored the same way.
- Shared VM helpers moved into `scripts/vm-verify-lib.sh` (`guest_long`, `guest_text`)
  and the library gained `KOINE_VM_NO_APP`, `KOINE_VM_ID` and `KOINE_VM_BASE`.
