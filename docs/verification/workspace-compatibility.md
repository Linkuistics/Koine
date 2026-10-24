# Workspace 1.0.0, 1.0.1 and 1.0.2: compatibility pairs

Three workspace releases ship under `koine-desktop/1` ([spec](../specs/workspace-launch-and-open.md#subjects-and-versions)).

- Release **1.0.0** is the retained original.
- Release **1.0.1** is the long-location repair. It shipped with Koine 0.3.0.
- Release **1.0.2** is the first cut of native discovery. It adds `Query.workspaceSpecialLocations` and `Query.workspaceApplications`.
  It is the workspace of Koine 0.4.0.

Each release makes a promise about the one before it.
The 1.0.1 repair promises that the 1.0.0 bundle stays independent of it.
Nothing already accepted about selection, updates and the short workflows changed meaning.

The 1.0.2 release promises two things.
The new bundle loads in the new host. The released Koine 0.3.0 host refuses it before it loads and names the feature it lacks.
This record shows both promises on binaries that were built apart.

- The **retained 1.0.0 side** is the retained bundle and its own host ([retained-workspace-baseline.md](retained-workspace-baseline.md)).
  The build used a pinned revision from before any source changed. Nothing rebuilds it for this check.
- The **released 0.3.0 side** is the tag `v0.3.0`. It gives the released host, its framework, its desktop provider and its workspace 1.0.1.
  `scripts/retained-workspace-1.0.1.json` pins the revision. `scripts/build-retained-workspace.sh` builds it in a tree of its own.
  The 1.0.1 pairs use the released bundle, not this tree's source. This tree's workspace is now 1.0.2.
- The **new side** is this tree's workspace 1.0.2 and this tree's host.
  The application seals and approves the bundle. `scripts/build-compat-pairs.sh` builds both in a tree of their own.
- The **per-user variants** are the same source with `first-party-selection-v1` in the manifest and descriptor.
  An earlier host requires that feature of a per-user update. Each variant is approved per user.
  The 1.0.1 variant comes from the released tree's own source. The 1.0.2 variant comes from this tree's source.
  Both come from the substitution that `scripts/first-party-update-lib.sh` also gives the real updates of the selection acceptance.
  The substitution works on a copy and leaves the product source untouched.

Nothing on an old side is relabelled. Nothing on any side is rebuilt from changed source.

```
task compat:build            # the retained bundle, the released 0.3.0, the baseline, this tree's host and workspace, the variants
task compat:verify           # scripts/verify-compat-pairs.py: the fixture pairs and the workspace pairs below
task compat:workspace-subjects   # scripts/verify-repair-subjects.sh: the retained suites against the released 1.0.1
```

## The pairs

Each pair is one headless host over a bundled root and a per-user root.
The bundled root stands in for `Contents/PlugIns`. A client drives each host over loopback HTTP with a grant.
Every case holds all of these in the same run:

- **The candidate rows, exactly.** The rows give provider, release, schema, state, origin, selection and reason.
- **The conformance profile that the pair pins** (`KoineConformance --profile`).
  The served schema is that profile's composed design. Its digest is that text's digest. The rows are its pins.
- **Three controls on that check, each seen red in the same run.**
  The first control is a profile that pins workspace 9.9.9.
  The second control is the profile of the other release. The retained profile runs against a 1.0.1 host. The repair's profile runs against a 1.0.0 host.
  The third control is the composed design of the other release. It differs from the repair's design in three descriptions alone.
- **The binary that ran.** The process maps exactly one workspace image, from the host's own staging.
  Its SHA-256 is that of the expected bundle, never that of the superseded candidate.
  An identical schema and digest cannot say which binary ran.
- **One framework image**, the host's own.
- An application that is not installed answers `DEPENDENCY_UNAVAILABLE` and `APPLICATION_NOT_INSTALLED`. The probes below also run.
- The host stops cleanly. No subject binary moved during the run.

The retained host is the host of the 1.0.0 revision. The released host is the host of Koine 0.3.0.
The newer host is this tree's host.

| Pair | Host | Bundled | Per user | Profile held |
|---|---|---|---|---|
| the retained 1.0.0 in its own host (the old pair) | retained | desktop 1.0.0, workspace 1.0.0 | none | `core-desktop-workspace-extension-host` |
| **old provider, newer host** | newer | desktop 1.0.0, workspace 1.0.0 (retained) | none | the same |
| the released 1.0.1 in its own host (the 1.0.1 pair) | released | desktop 1.0.0, workspace 1.0.1 | none | `core-desktop-workspace-repair-extension-host` |
| the released 1.0.1, retained host | retained | desktop 1.0.0, workspace 1.0.1 | none | the same |
| the released 1.0.1, newer host | newer | desktop 1.0.0, workspace 1.0.1 | none | the same |
| the approved per-user 1.0.1 variant, retained host | retained | workspace 1.0.0 | workspace 1.0.1 | `core-desktop-workspace-repair-per-user-extension-host` |
| the same, newer host | newer | workspace 1.0.0 | workspace 1.0.1 | the same |
| the shipped 1.0.1 installed per user without the feature | retained | workspace 1.0.0 | workspace 1.0.1 | rows only |
| **the new bundle loads in the new host** | newer | desktop 1.0.0, workspace 1.0.2 | none | `core-desktop-workspace-discovery-extension-host` |
| the approved per-user 1.0.2 variant, newer host | newer | workspace 1.0.0 | workspace 1.0.2 | `core-desktop-workspace-discovery-per-user-extension-host` |
| **the released 0.3.0 host refuses 1.0.2** | released | desktop 1.0.0, workspace 1.0.2 | none | rows only |
| the retained 1.0.0 host refuses 1.0.2 | retained | desktop 1.0.0, workspace 1.0.2 | none | rows only |

The 1.0.1 per-user profile pins what the retained host reports for the variant.
Workspace 1.0.1 with schema 1.0.1 is `ACTIVE`, `PER_USER` and `SELECTED`.
The bundled workspace 1.0.0 is `REJECTED`, `BUNDLED` and `NOT_SELECTED`, with the reason `superseded-candidate`.
Desktop 1.0.0 is untouched.

The last pair is the reason for the variant. The plain 1.0.1 bundle, installed per user, is refused before it loads.
Its state is `INCOMPATIBLE` with the reason `selection-feature-required`.
The bundled 1.0.0 keeps the slot with the reason `selected-with-refusals`.
So a retained host would not load the update as published.

## The 1.0.2 bundle in the old hosts

Release 1.0.2 requires two host features: `additional-capabilities-v1` and `workspace-native-disclosures-v1`.
The second feature carries the `workspace:read` disclosure. Only this tree's host advertises it.

The released Koine 0.3.0 host advertises `additional-capabilities-v1` and `first-party-selection-v1`.
The retained 1.0.0 host advertises less. Each host therefore refuses the 1.0.2 bundle at its loader, before it prepares any image.
Each case in this section holds these results:

- The workspace row is `INCOMPATIBLE`, `BUNDLED` and `NOT_SELECTED`, with the reason `feature-unavailable`.
- The diagnostic of that row reads: "The provider requires host features this Koine lacks: workspace-native-disclosures-v1."
  So the refusal names the missing feature.
- A second workspace row says that the slot is unavailable. Its reason is `no-eligible-candidate`, and the slot stays reserved.
- The host maps no workspace image. The check reads the process with `lsof`.
  The loading pairs use the same check and find exactly one image, so the instrument can see an image when one loads.
- The desktop row stays `ACTIVE`. The host stops cleanly.

The new host loads the same bundle. The pair "the new bundle loads in the new host" holds all the checks of the section above.
It holds the discovery profile, its three red controls, the expected binary and the probes.

## The same locations through every pair

The probes use eight locations. Only the pairs that load a release probe it. Each one goes through `workspaceOpenPath` and through `workspaceRevealPath`.
The probes build each location component by component. No probe calls `mkdir` or `open` on the long path as a whole.
The eight locations are:

- a missing path
- a dangling link
- a two-link cycle
- a missing parent
- a file used as a directory
- a component of 256 bytes
- a missing short path under an extant directory
- an **extant directory whose spelling is more than 1,100 bytes**

Every outcome is an absence or a refusal. So no probe can reach an application.
None launches, opens or reveals anything. A probe that came back `AVAILABLE` fails its case.

| | 1.0.0 (retained), in two pairs | 1.0.1 (released), in six pairs |
|---|---|---|
| the seven short or impossible locations, open and reveal | `DEPENDENCY_UNAVAILABLE` and `PATH_NOT_FOUND` | the same, identically |
| the extant directory of 1,024 bytes or more | `DEPENDENCY_UNAVAILABLE` and `PATH_NOT_FOUND`, the defect: `ENAMETOOLONG` read as absence | an error of kind `failed`, no dependency reason |

Three cases keep their outcome. They are the cycle, the impossible component and plain absence.
Only the location that the repair names changes. It changes from the same enum and kinds to a kind that the contract already had.
Antony accepted that correction ([obligations](long-action-native-boundary.md#compatibility-and-implementation-obligations)).
No incompatible meaning appears, and nothing needed his decision before adoption.

All pairs that serve one release agree with each other. The last case of the run compares the three releases.
Release 1.0.2 adds reads and no action. So its two pairs must give each location the outcome that 1.0.1 gives.

## The retained revision's own subjects, against the released 1.0.1

`scripts/verify-repair-subjects.sh` runs the suites of the retained revision, **unedited**.
The script diffs their `Tests/` against the retained tree's.
The suites run in a copy of the retained tree, which is built on its own.
The suites are:

- `WorkspaceProviderTests`. These are the short-path subjects over the signed bundle.
  They cover a missing path, a dangling link, a loop and a trailing slash.
  They also cover an absent application, a wrong application, every refusal, and every control and read capability.
- `WorkspaceCompositionTests`.
- `WorkspaceInstallationsCompositionTests`.

The in-application root holds the retained desktop and the released Koine 0.3.0's workspace 1.0.1.
The root holds the sealed and approved bundle. The copy's catalogue entry for workspace moves to 1.0.1 and 1.0.1, as the repair's own entry does.
The suites hold the bundle to the catalogue.

This tree's workspace 1.0.2 cannot be the subject. The retained revision builds a host that refuses 1.0.2 by design.
This tree's own suites hold the 1.0.2 workflows. The pairs above hold what the 1.0.2 bundle serves.

**103 tests in 3 suites ran, and one assertion failed.**
The failing assertion is the retained test `theSignedBundleLoadsBesideDesktopFromTheInApplicationRoot`.
It expects release and schema `"1.0.0"` for every shipped row (`WorkspaceProviderTests.swift:65`).
The repair changes that release by design. No short-workflow subject was lost.

The test beside it compares the served SDL to the 1.0.0 design file.
That test reads the copy's own provider source, not the bundle. So it says nothing about 1.0.1, and it passes.
The pairs above hold what the bundle serves to the repair's design.

The instrument was first seen red. A 1.0.1 provider with a missing component reads that component as a failure, not as absence (`LocationWalk.swift`, the `ENOENT` case).
That provider fails the same suite with 5 issues in 22 tests. The failures name the missing-path subjects.
The script fails in three cases:

- the red run passes
- any other test fails
- the one failing test fails on any other line

## Run record

<!-- tc: off because this is the dated record of a past run, kept as history -->

2026-10-07, debug, macOS 26.6.2 (25G83), arm64, bundles signed by Developer ID Application, Team ID
TA43A4RUP3, from the retained revision `f24d6290e1f9` (tag `workspace-1.0.0-baseline`):

- `task compat:verify`: **32 cases, 0 failed checks, no binary changed during the run** (the 24 fixture cases of
  [binary-compatibility.md](binary-compatibility.md), the seven workspace pairs above, and the comparison of the two
  releases);
- `task compat:workspace-subjects`: the control red (22 tests, 5 issues), then **103 tests in 3 suites with the one
  expected assertion failing**;
- `task compat:workspace-baseline-verify` still passes with the retained bundle as built by the same run (143 and
  148 tests); the retained profile, SDL and composed design are byte-identical to the pinned revision's;
- `task selection:updates` 153 host runs, `selection:decisions` 134, `selection:failures` 119, all with 0 failed;
  `selection:mutation` sees every mutation
  ([re-pinned](selection-updates.md#re-pinned-to-workspace-101)); `task test` passes (426 and 236 tests, among others).

The first run of the pairs found no defect in the provider; the check that the host staged the expected binary
read an empty staging directory because the staged copy is the bundle's contents in a directory named for it, not
a nested `Workspace.koineprovider`, and was changed to read what the process mapped (`lsof`), which names the
file. The first run of the retained subjects pinned two expected failures, and found one: the second named test reads the
copy's own source rather than the bundle, and so passes; the expectation was corrected to the one that
does fail, rather than loosened.

<!-- tc: on -->

### Run of workspace 1.0.2

2026-10-27, debug, macOS 27.0.1, arm64. The bundles are signed by Developer ID Application, Team ID TA43A4RUP3. The retained bundle comes from the revision `f24d6290e1f9` (tag `workspace-1.0.0-baseline`). The released 1.0.1 bundle comes from the tag `v0.3.0` (commit `efcc06023dd2`).

- `task compat:verify`: **37 cases, 0 failed checks, and no binary changed during the run.** The cases are the 24 fixture cases of [binary-compatibility.md](binary-compatibility.md), the twelve workspace pairs above and the comparison of the three releases.
- The new 1.0.2 bundle loads in the new host. The released 0.3.0 host and the retained 1.0.0 host each refuse it before they load it. Each refusal names `workspace-native-disclosures-v1`, and neither process maps a workspace image.
- The retained 1.0.0, the released 1.0.1 and the 1.0.2 profiles pass, with their per-user variants. Each red control turned red in the same run. The probes of the three releases give the same outcomes, so 1.0.2 equals 1.0.1 on the long locations.
- `task compat:workspace-subjects`: the control was red, then **103 tests in 3 suites passed, except the one expected assertion.** The subject is the released 1.0.1 bundle.
- `task selection:updates` ran 153 host runs, `selection:decisions` 134 and `selection:failures` 119. None failed, and none lacked a control. `selection:mutation` saw every mutation. See [the re-pin to 1.0.2](selection-updates.md#re-pinned-to-workspace-102).
- `swift test` fails one test, `aBundleWithinTheLimitWhoseInfoPlistIsTooLongForThePlatformIsFailedNamingTheCause`. On macOS 27 the platform words that refusal in a different way from macOS 26.5. This failure is older than this leaf.

The first run of the pairs guessed two refusal facts wrongly. The refused bundle has the reason `feature-unavailable`, and a second placeholder row has the reason `no-eligible-candidate`. The pins now hold both rows.

The checks ran again after the search scope of the index query changed. That change reworded a schema description of the workspace provider, so the schema digest changed too. The results above are from the second run.


## What this does not claim

- It does not close any long-location row. Those rows belong to the stage leaves (L, G and N) and to `target-locations-vm` and `application-locations-vm` (V).
- The probes reach no application. So they show the outcomes of the walk through two independently built hosts, not an effect.
  Only `target-locations-vm` shows a present outcome that needs an effect.
- This compatibility run did not repeat the V seam of the selection acceptance.
  The [2026-10-08 selection VM run](selection-vm.md#workspace-101-rerun) establishes it on notarised hosts.
  That run has workspace 1.0.1 as the bundled baseline and workspace 1.1.0 with schema 1.0.1 as its update.
  The 1.0.1 per-user compatibility variant on the retained host above remains N and G evidence.
