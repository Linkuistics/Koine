# discovery-acceptance-k4

## Goal

Establish the cut at the N and V seams on the development-signed bundle. The new
workspace bundle loads in the new host, and the released 0.3.0 host refuses it.
One happy-path TestAnyware VM run passes.

## Context

- The image: `task launchers:prepare` makes `koine-launchers-prepared`, with
  Gatekeeper enforcing and the twelve launchers installed
  (`docs/verification/launcher-apps-vm.md`). Its inventory names each
  launcher's bundle identifier and path
  (`docs/verification/launcher-apps/inventory.json`).
- The contract-only client (`clients/contract-only`) makes every VM request. It
  is generated again from the served schema
  (`docs/verification/launch-contract.md`).
- The shared VM helpers are in `scripts/vm-verify-lib.sh`, which 0.3.0 adapted
  to the menu bar application. The launch witness is `Fixtures/LaunchWitness`
  (`docs/verification/launch-vm.md`).
- The compatibility tasks are the `compat:*` and `selection:*` tasks in the
  Taskfile. `docs/verification/workspace-compatibility.md` records the retained
  pairs.
- The review leaf that `application-catalogue-k3` cut runs before this leaf.
  Read its findings and their outcome first.

## Done when

- N: the new workspace bundle loads in the new host. The released 0.3.0 host
  refuses it before it loads, and the refusal names the missing feature. The
  retained 1.0.0 and 1.0.1 profiles still pass.
- V: a new VM check, run by a new Taskfile task, passes on the launchers image.
  It covers the four points of the V seam in the root brief.
- The check records the index state before it reads the catalogue. It tells an
  index that is still building apart from a missing application.
- If the run shows the index without Safari or Finder, the lookup in the root
  brief exists, with L tests, and a second run passes.
- The evidence is in a record under `docs/verification/`. The trace rows link to
  it.

## Notes

- **A permission dialog naming Koine during a read stops this leaf.** Record
  what the dialog said and which read raised it, and then ask the human. Do not
  dismiss it as a pass, and do not change the read to avoid it without the
  human's decision.
- A VM run takes long. Make each change first, then run once, and compare the
  per-item record rather than the totals.
- The release checks on the notarised build are the release leaf's work, not
  this one's.
- **What `special-locations-k2` left for the N seam.** The workspace provider
  is now release 1.0.2, schema 1.0.2, and it requires
  `additional-capabilities-v1` and `workspace-native-disclosures-v1`. Several
  scripts still treat this tree's workspace as release 1.0.1:
  `scripts/verify-compat-pairs.py` (`REPAIR_PROFILE`, `W101`),
  `scripts/verify-selection-updates.py`, `scripts/build-selection-real.sh`,
  `scripts/verify-repair-subjects.sh` and `scripts/selection_harness.py`. Re-pin
  them to the new profile
  `docs/design/profiles/core-desktop-workspace-special-locations-extension-host.json`.
  Keep the 1.0.1 repair profile for the retained 1.0.1 pair. `task
  conformance:headless` and `scripts/vm-verify-conformance.sh` already use the
  new profile. The per-user variant that `scripts/first-party-update-lib.sh`
  builds now adds `first-party-selection-v1` to the two features above.
- `swift test` has one failure that does not come from this grove:
  `aBundleWithinTheLimitWhoseInfoPlistIsTooLongForThePlatformIsFailedNamingTheCause`
  at length 1023. On macOS 27 the platform words that refusal differently
  ("the file name … is invalid") from the macOS 26.5 text that the test expects.
