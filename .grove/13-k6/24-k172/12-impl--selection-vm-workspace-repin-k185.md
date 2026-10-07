# selection-vm-workspace-repin-k185

## Goal

Re-run the selection acceptance's V seam against workspace 1.0.1, so that the
record `docs/verification/selection-vm.md` says what the signed, notarized hosts did
with the repaired workspace as the real baseline and as the designated bundle, and not
only with 1.0.0.

## Context

- Found by `action-repair-compat-k179`. That leaf re-pinned every N and G selection
  fixture to 1.0.1 (`task selection:updates`, `selection:decisions` and
  `selection:failures` pass, and `selection:mutation` sees every mutation) but did not
  run `task selection:vm`: it needs `task selection:vm-hosts`, which signs, **submits to
  Apple's notary service** and staples each host and update, and a Gatekeeper-enforcing
  TestAnyware VM. `selection-vm.md`, and the "V established" statements in
  `docs/specs/machine.md#selection-acceptance`, are for the 1.0.0 workspace.
- `scripts/verify-selection-vm.py` takes its scenarios from the table of
  `scripts/verify-selection-updates.py`, so the real-provider rows already expect
  workspace 1.0.1 and its profiles `core-desktop-workspace-*-extension-host`; the V
  fixtures (`.build/selection-vm`) are built from the same sources, so they need
  rebuilding.
- `docs/verification/workspace-compatibility.md` ("What this does not claim").

## Done when

- `task selection:vm-hosts` and `task selection:vm` pass with workspace 1.0.1 as the
  bundled baseline and the 1.1.0 update of it, on notarized hosts, and
  `selection-vm.md` and the V statements of the affected rows of the Machine spec say so.

## Notes

- **Ask Antony before notarizing.** The notary submissions are outward-facing and the
  stored credential is his; confirm that spending them on this is wanted, or that the
  V seam for the first-party workspace is to be left at 1.0.0 with the compatibility
  pairs standing in for it.
