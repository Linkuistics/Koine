# action-repair-compat-k179

## Goal

Prove the 1.0.1 workspace is independent of the retained 1.0.0 one and that
nothing already accepted about selection, updates and old hosts changed meaning:
independently built old and new providers on compatible hosts, the retained-host
per-user 1.0.1 variant, and every selection fixture re-pinned to the new release.

## Context

- `docs/verification/long-action-native-boundary.md#compatibility-and-implementation-obligations`
  (the retained-host approved per-user 1.0.1 variant with SELECTED/PER_USER and
  NOT_SELECTED/BUNDLED 1.0.0 pins, paired independent providers and hosts).
- `docs/specs/machine.md#first-party-provider-selection` and `#selection-acceptance`.
- `scripts/build-selection-real.sh` (`current-workspace`, `workspace-update`,
  `-renamed`, `-no-feature`), `scripts/build-compat-pairs.sh`,
  `scripts/verify-compat-pairs.py`, `Taskfile.yml` `selection:*` and `compat:*`.
- `retained-workspace-baseline-k173` and `action-repair-release-k178`.

## Done when

- Old (1.0.0, retained) and new (1.0.1) providers are each paired with compatible
  hosts and checked over loopback, with full exact candidate pins: the 1.0.1
  per-user variant approved on the retained host is SELECTED/PER_USER with the
  bundled 1.0.0 pin NOT_SELECTED/BUNDLED, and neither side is rebuilt from
  changed source or relabelled.
- The whole selection acceptance matrix still passes with the new release as the
  current workspace and a newer update, as it did for 1.0.0: nothing in the
  fixtures or `check-selection-mutations.py` still assumes 1.0.0 as the current
  value, and each is seen red against a mutated pin.
- The cycle, component and established-nil subjects and every short workflow are
  repeated against 1.0.1, and no incompatible meaning or short-workflow loss
  appears. If one does, it goes to Antony before adoption.

## Notes

- This leaf touches many pins at once. If it proves bigger than a session,
  decompose at the seam between the compat pairs and the selection matrix.
