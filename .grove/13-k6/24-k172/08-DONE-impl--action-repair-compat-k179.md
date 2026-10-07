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

## Decisions (running log)

- **Not decomposed.** The leaf fitted one session at the seam it names (pairs, then matrix): the pairs and the
  retained subjects are `scripts/verify-compat-pairs.py` and `scripts/verify-repair-subjects.sh`, the matrix is the
  re-pinned selection fixtures; `task compat` and the three selection drivers all pass in one run
  (`docs/verification/workspace-compatibility.md`, `docs/verification/selection-updates.md`).
- **The 1.0.1 per-user variant is the shipped source plus `first-party-selection-v1`, on a copy.** An earlier host
  (and the retained one, which is this tree's host as of the pin) refuses a per-user update that does not state the
  feature, so the plain 1.0.1 bundle cannot be the "approved per-user variant"; the refusal is itself a pair. The
  substitution is the one `scripts/build-selection-real.sh` already made for the real updates, moved to
  `scripts/first-party-update-lib.sh` and sourced by both, so one definition builds both.
- **The retained side is never rebuilt by the pairs**: `compat:build` runs `compat:workspace-baseline` (which reuses
  the extraction of the pinned revision), and `build-compat-pairs.sh` refuses to run without `retained.json`.
- **A host's retained or new side is told apart by what the process mapped, not by the schema.** `lsof -p` names the
  staged `libWorkspaceProvider.dylib`, whose SHA-256 must be the expected bundle's, and the superseded candidate is
  never mapped. The first version looked in the staging directory for a nested bundle and read nothing; it was changed
  to read the mapped image.
- **The probes can reach no application.** Every probe location is absent or an extant over-limit directory, so
  neither release can submit a request, and any `AVAILABLE` fails the case. A present short path would act, and its
  effects are `target-locations-vm`'s. The one difference between the releases is the one Antony accepted
  (`DEPENDENCY_UNAVAILABLE`/`PATH_NOT_FOUND` becomes `failed` for an extant directory of 1,024 bytes or more); nothing
  else differs, so nothing went to him.
- **The retained suites are run unedited against 1.0.1, with the catalogue entry of the copy as the only input moved.**
  One assertion (the loaded rows say 1.0.0) fails by design and the script names it and its line; the test beside it that
  compares the SDL reads the copy's source and passes, so it is not claimed. The instrument is first seen red against a
  1.0.1 provider with `ENOENT` read as a failure.
- **Four update profiles edited in place, not copied.** They are the current selection profiles, not retained ones
  (the retained `core-desktop-workspace-extension-host` is untouched and still held byte-for-byte); the generation
  before any update uses the repair profile k178 made. New: `core-desktop-workspace-repair-per-user-extension-host`.
- **`selection_harness.check_conformance` gained the controls "each workspace row pinned at the retained 1.0.0" and
  "every other composed design"**, so a profile left at 1.0.0 cannot pass. The unchanged driver was seen red against
  1.0.1 first (16 of 153 host runs).
- **The `impostor-host`'s designated workspace moved to 1.0.1/1.0.1** so the control mirrors the catalogue's designation.
- **The V seam of the selection acceptance is not re-run**: it notarizes. Cut as `selection-vm-workspace-repin-k185`
  with the question to Antony about spending notary submissions; the Machine spec says "not re-run for 1.0.1".
- **No in-session reviewer spent.** The claims are held by executable checks seen red (the 9.9.9, crossed-profile and
  crossed-design controls in every pair, the 16 red host runs, the red retained-suite control, 36 seen mutations).
