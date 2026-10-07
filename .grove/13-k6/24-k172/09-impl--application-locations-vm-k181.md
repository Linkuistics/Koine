# application-locations-vm-k181

## Goal

Accept the application stages at V: an over-limit application path is refused
before any delivery, and short launch, named open and reveal keep working beside
a long copy of the same application on disk.

## Context

- `docs/specs/workspace-launch-and-open.md#subjects-and-versions` (V) and
  `docs/verification/application-installations-vm.md`.
- `scripts/vm-installation-fixtures.sh`, `scripts/vm-installation-request.py`,
  `scripts/vm-registration-lookup.swift`; the prepared launcher VM
  (`docs/verification/launcher-apps-vm.md`).
- `docs/verification/long-action-native-boundary.md` (short workflows with long
  registered copies; long constrained installation).
- `target-locations-vm-k180` for the observers.

## Done when

- An over-limit constrained `applicationPath` is `failed` with guidance and no
  application is launched or opened.
- With a long copy of the same application on disk and registered, in either
  enumeration order and as the preferred copy where the guest admits it, short
  constrained launch, named open and unconstrained launch still work, and reveal
  still finds Finder. An unconstructible registration leaves that subject pending
  and L does not pass it.
- Evidence is a verification document linked from the spec's rows; the
  long-location acceptance entries of the spec carry their final status.

## Notes

- A systematic length-caused `process: null` would be a defect, not an accepted loss.
