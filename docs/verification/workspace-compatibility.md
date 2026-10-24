# Workspace 1.0.1 against the retained 1.0.0: compatibility pairs

The long-location repair ships as workspace release and schema **1.0.1** under `koine-desktop/1`
([spec](../specs/workspace-launch-and-open.md#subjects-and-versions)).
The repair makes one promise. The 1.0.0 bundle stays independent of it. Nothing already accepted about selection, updates and the short workflows changed meaning.
This record shows the promise on binaries that were built apart.

- The **old side** is the retained 1.0.0 bundle and its own host ([retained-workspace-baseline.md](retained-workspace-baseline.md)).
  The build used a pinned revision from before any source changed. Nothing rebuilds it for this check.
- The **new side** is this tree's workspace 1.0.1 and this tree's host.
  The application seals and approves the bundle. `scripts/build-compat-pairs.sh` builds both in a tree of their own.
- The **per-user variant** is the same 1.0.1 source with `first-party-selection-v1` in its manifest and descriptor.
  An earlier host requires that feature of a per-user update. The variant is approved per user (`newer/workspace-per-user`).
  It comes from the substitution that `scripts/first-party-update-lib.sh` also gives the real updates of the selection acceptance.
  The substitution works on a copy and leaves the product source untouched.

Nothing on the old side is relabelled. Nothing on either side is rebuilt from changed source.

```
task compat:build            # the retained bundle, the released baseline, this tree's host and workspace, the variant
task compat:verify           # scripts/verify-compat-pairs.py: the fixture pairs and the workspace pairs below
task compat:workspace-subjects   # scripts/verify-repair-subjects.sh: the retained suites against 1.0.1
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

| Pair | Host | Bundled | Per user | Profile held |
|---|---|---|---|---|
| the retained 1.0.0 in its own host (the old pair) | retained | desktop 1.0.0, workspace 1.0.0 | none | `core-desktop-workspace-extension-host` |
| **old provider, newer host** | this tree's | desktop 1.0.0, workspace 1.0.0 (retained) | none | the same |
| **new provider, old host** | retained | desktop 1.0.0, workspace 1.0.1 | none | `core-desktop-workspace-repair-extension-host` |
| control: the new provider in its own host | this tree's | desktop 1.0.0, workspace 1.0.1 | none | the same |
| **the approved per-user 1.0.1 variant, retained host** | retained | workspace 1.0.0 | workspace 1.0.1 | `core-desktop-workspace-repair-per-user-extension-host` |
| the same, this tree's host | this tree's | workspace 1.0.0 | workspace 1.0.1 | the same |
| the shipped 1.0.1 installed per user without the feature | retained | workspace 1.0.0 | workspace 1.0.1 | rows only |

The per-user profile pins what the retained host reports for the variant.
Workspace 1.0.1 with schema 1.0.1 is `ACTIVE`, `PER_USER` and `SELECTED`.
The bundled workspace 1.0.0 is `REJECTED`, `BUNDLED` and `NOT_SELECTED`, with the reason `superseded-candidate`.
Desktop 1.0.0 is untouched.

The last pair is the reason for the variant. The plain 1.0.1 bundle, installed per user, is refused before it loads.
Its state is `INCOMPATIBLE` with the reason `selection-feature-required`.
The bundled 1.0.0 keeps the slot with the reason `selected-with-refusals`.
So a retained host would not load the update as published.

## The same locations through every pair

The probes use eight locations. Each one goes through `workspaceOpenPath` and through `workspaceRevealPath`.
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

| | 1.0.0 (retained), in three pairs | 1.0.1, in four pairs |
|---|---|---|
| the seven short or impossible locations, open and reveal | `DEPENDENCY_UNAVAILABLE` and `PATH_NOT_FOUND` | the same, identically |
| the extant directory of 1,024 bytes or more | `DEPENDENCY_UNAVAILABLE` and `PATH_NOT_FOUND`, the defect: `ENAMETOOLONG` read as absence | an error of kind `failed`, no dependency reason |

Three cases keep their outcome. They are the cycle, the impossible component and plain absence.
Only the location that the repair names changes. It changes from the same enum and kinds to a kind that the contract already had.
Antony accepted that correction ([obligations](long-action-native-boundary.md#compatibility-and-implementation-obligations)).
No incompatible meaning appears, and nothing needed his decision before adoption.

All pairs that serve one release agree with each other. The last case of the run compares the two releases.

## The retained revision's own subjects, against 1.0.1

`scripts/verify-repair-subjects.sh` runs the suites of the retained revision, **unedited**.
The script diffs their `Tests/` against the retained tree's.
The suites run in a copy of the retained tree, which is built on its own.
The suites are:

- `WorkspaceProviderTests`. These are the short-path subjects over the signed bundle.
  They cover a missing path, a dangling link, a loop and a trailing slash.
  They also cover an absent application, a wrong application, every refusal, and every control and read capability.
- `WorkspaceCompositionTests`.
- `WorkspaceInstallationsCompositionTests`.

The in-application root holds the retained desktop and this tree's workspace 1.0.1.
The root holds the sealed and approved bundle. The copy's catalogue entry for workspace moves to 1.0.1 and 1.0.1, as the repair's own entry does.
The suites hold the bundle to the catalogue.

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

## What this does not claim

- It does not close any long-location row. Those rows belong to the stage leaves (L, G and N) and to `target-locations-vm` and `application-locations-vm` (V).
- The probes reach no application. So they show the outcomes of the walk through two independently built hosts, not an effect.
  Only `target-locations-vm` shows a present outcome that needs an effect.
- This compatibility run did not repeat the V seam of the selection acceptance.
  The [2026-10-08 selection VM run](selection-vm.md#workspace-101-rerun) establishes it on notarised hosts.
  That run has workspace 1.0.1 as the bundled baseline and workspace 1.1.0 with schema 1.0.1 as its update.
  The 1.0.1 per-user compatibility variant on the retained host above remains N and G evidence.
