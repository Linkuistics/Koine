# application-locations-vm-k181

## Goal

Accept the application stages at V: an over-limit application path is refused
before any delivery, short launch, named open and reveal keep working beside a
long copy of the same application on disk, and a long copy that is the
identifier's preferred one is refused, never replaced by another.

## Context

- `docs/specs/workspace-launch-and-open.md#subjects-and-versions` (V) and
  `docs/verification/application-installations-vm.md`.
- `scripts/vm-installation-fixtures.sh`, `scripts/vm-installation-request.py`,
  `scripts/vm-registration-lookup.swift`; the prepared launcher VM
  (`docs/verification/launcher-apps-vm.md`).
- `docs/verification/long-action-native-boundary.md` (the v1 reading of its subject
  table: short workflows with long registered copies; long constrained
  installation).
- `target-locations-vm-k180` for the observers.

## Done when

- An over-limit constrained `applicationPath` is `failed` with guidance and no
  application is launched or opened.
- **Selected copy short, long copy beside it.** With a long copy of the same
  application on disk and registered, in either enumeration order, short
  constrained launch and named open (selecting the short copy by `applicationPath`)
  work; unconstrained launch and named open work where the guest makes the short
  copy the identifier's preferred one; reveal still finds Finder. An
  unconstructible registration leaves that subject pending and L does not pass it.
- **Preferred copy long.** Where the guest admits the long copy as the
  identifier's preferred one, an unconstrained launch and named open are `failed`
  with the guidance of the limit, name the long spelling and its byte count, and
  launch and open nothing, even with a short copy of the same application
  running. No other copy is substituted. If the guest will not make the long copy
  preferred, that subject stays pending and the selected-short cases do not pass
  it.
- Receipts for the short workflows above carry a non-null process where the
  accepted short workflows do, observed through the kernel's identity for the
  returned process, so `receipt-executable-identity-k183` is seen to hold at V.
- Evidence is a verification document linked from the spec's rows; the
  long-location acceptance entries of the spec carry their final status.

## Notes

- A systematic length-caused `process: null` would be a defect, not an accepted loss.
- The preferred-long refusal is the v1 contract, not a regression: the 1.0.0 success
  for it that the native boundary record once asked for is superseded by the v1
  decision (Linkuistics/Koine#1).
