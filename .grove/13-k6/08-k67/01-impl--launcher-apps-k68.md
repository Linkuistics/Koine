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
