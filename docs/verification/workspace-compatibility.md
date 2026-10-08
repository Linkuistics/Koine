# Workspace 1.0.1 against the retained 1.0.0: compatibility pairs

The long-location repair ships as workspace release/schema **1.0.1** under `koine-desktop/1`
([spec](../specs/workspace-launch-and-open.md#subjects-and-versions)). Its promise is that the
1.0.0 bundle stays independent of it and that nothing already accepted about selection, updates
and the short workflows changed meaning. This record is what shows it, on binaries built apart:

- the **old side** is the retained 1.0.0 bundle and its own host
  ([retained-workspace-baseline.md](retained-workspace-baseline.md)), built from a pinned
  revision before any source changed, and never rebuilt for this check;
- the **new side** is this tree's workspace 1.0.1, sealed and approved as the application seals
  it, and this tree's host, built by `scripts/build-compat-pairs.sh` in a tree of its own;
- the **per-user variant** is the same 1.0.1 source with `first-party-selection-v1` stated in its
  manifest and descriptor, which an earlier host requires of a per-user update, approved per user
  (`newer/workspace-per-user`). It is built by the substitution
  `scripts/first-party-update-lib.sh` also gives the selection acceptance's real updates, on a
  copy, with the product source untouched.

Nothing on the old side is relabelled and nothing on either side is rebuilt from changed source.

```
task compat:build            # the retained bundle, the released baseline, this tree's host and workspace, the variant
task compat:verify           # scripts/verify-compat-pairs.py: the fixture pairs and the workspace pairs below
task compat:workspace-subjects   # scripts/verify-repair-subjects.sh: the retained suites against 1.0.1
```

## The pairs

Each is one headless host over a bundled root (standing in for `Contents/PlugIns`) and a per-user
root, driven as a client drives Koine: loopback HTTP with a grant. Every case holds, in the same
run:

- **the candidate rows exactly**: provider, release, schema, state, origin, selection and reason;
- **the conformance profile the pair pins** (`KoineConformance --profile`): the served schema is
  that profile's composed design, its digest is that text's, the rows are its pins;
- **three controls on that check, seen red in the same run**: a profile pinning workspace 9.9.9,
  the *other* release's profile (the retained one against a 1.0.1 host and the repair's against
  a 1.0.0 host), and the other release's composed design (which differs from the repair's in three
  descriptions alone);
- **the binary that ran**: the process maps exactly one workspace image, from the host's own
  staging, and its SHA-256 is that of the expected bundle's, never the superseded candidate's
  (an identical schema and digest cannot say which binary ran);
- **one framework image**, the host's own;
- an application that is not installed answers `DEPENDENCY_UNAVAILABLE` /
  `APPLICATION_NOT_INSTALLED`, and the probes below;
- the host stops cleanly, and no subject binary moved during the run.

| Pair | Host | Bundled | Per user | Profile held |
|---|---|---|---|---|
| the retained 1.0.0 in its own host (the old pair) | retained | desktop 1.0.0, workspace 1.0.0 | none | `core-desktop-workspace-extension-host` |
| **old provider, newer host** | this tree's | desktop 1.0.0, workspace 1.0.0 (retained) | none | the same |
| **new provider, old host** | retained | desktop 1.0.0, workspace 1.0.1 | none | `core-desktop-workspace-repair-extension-host` |
| control: the new provider in its own host | this tree's | desktop 1.0.0, workspace 1.0.1 | none | the same |
| **the approved per-user 1.0.1 variant, retained host** | retained | workspace 1.0.0 | workspace 1.0.1 | `core-desktop-workspace-repair-per-user-extension-host` |
| the same, this tree's host | this tree's | workspace 1.0.0 | workspace 1.0.1 | the same |
| the shipped 1.0.1 installed per user without the feature | retained | workspace 1.0.0 | workspace 1.0.1 | rows only |

The per-user profile pins what the retained host reports for the variant: workspace 1.0.1 /
schema 1.0.1 `ACTIVE`, `PER_USER`, `SELECTED`, the bundled workspace 1.0.0 `REJECTED`,
`BUNDLED`, `NOT_SELECTED` with `superseded-candidate`, and desktop 1.0.0 untouched. The last pair is the
reason the variant exists: the plain 1.0.1 bundle installed per user is refused before it loads,
`INCOMPATIBLE` / `selection-feature-required`, and the bundled 1.0.0 keeps the slot with
`selected-with-refusals`, so a retained host given the update as published would not load it.

## The same locations through every pair

Eight locations, each through `workspaceOpenPath` and `workspaceRevealPath`, built component by
component (no whole-path `mkdir` or `open` of the long one): a missing path, a dangling link, a
two-link cycle, a missing parent, a file used as a directory, a component of 256 bytes, a missing
short path under an extant directory, and an **extant directory whose spelling is more than 1,100 bytes**.
Every outcome is an absence or a refusal, so no probe can reach an application: none launches,
opens or reveals anything, and a probe that came back `AVAILABLE` fails its case.

| | 1.0.0 (retained), in three pairs | 1.0.1, in four pairs |
|---|---|---|
| the seven short or impossible locations, open and reveal | `DEPENDENCY_UNAVAILABLE` / `PATH_NOT_FOUND` | the same, identically |
| the extant directory of 1,024 bytes or more | `DEPENDENCY_UNAVAILABLE` / `PATH_NOT_FOUND`, the defect: `ENAMETOOLONG` read as absence | an error of kind `failed`, no dependency reason |

The three cases the walk replaced (the cycle, the impossible component and plain absence) keep their
outcome; the one location that changes is the one the repair names, from the same enum and kinds
to a kind the contract already had. That is the correction Antony accepted
([obligations](long-action-native-boundary.md#compatibility-and-implementation-obligations)): no
incompatible meaning appears, and nothing needed his decision before adoption. All pairs that serve one release agree with each other, and
the two releases are compared by the last case of the run.

## The retained revision's own subjects, against 1.0.1

`scripts/verify-repair-subjects.sh` runs the retained revision's suites, **unedited** (the script
diffs their `Tests/` against the retained tree's), in a copy of the retained tree built on its own:
`WorkspaceProviderTests` (the short-path subjects over the signed bundle: a missing path, a dangling
link, a loop, a trailing slash, an application that is absent or the wrong one, every refusal, every
control and read capability), `WorkspaceCompositionTests` and
`WorkspaceInstallationsCompositionTests`. The in-application root holds the retained desktop and this
tree's workspace 1.0.1; the copy's catalogue entry for workspace is moved to 1.0.1/1.0.1, as the
repair's own is (the suites hold the bundle to the catalogue).

**103 tests in 3 suites ran, and one assertion failed**: the retained
`theSignedBundleLoadsBesideDesktopFromTheInApplicationRoot` expecting release and schema `"1.0.0"` of
every shipped row (`WorkspaceProviderTests.swift:65`), which is the release the repair changes by
design. No short-workflow subject was lost. (The test beside it that compares the served SDL to the
1.0.0 design file reads the copy's own provider source, not the bundle, so it says nothing of 1.0.1
and passes; what the bundle serves is held to the repair's design by the pairs above.)

The instrument was first seen red: a 1.0.1 provider built from a copy with a missing component read
as a failure rather than absence (`LocationWalk.swift`'s `ENOENT` case) fails the same suite, 5
issues in 22 tests, naming the missing-path subjects. The script fails if that run passes, if any
other test fails, or if the one that fails does so on any other line.

## Run record

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

## What this does not claim

- It does not close any long-location row: those are the stage leaves' (L, G and N) and
  `target-locations-vm`'s and `application-locations-vm`'s (V).
- The probes reach no application, so they show the walk's outcomes through two independently built
  hosts, not an effect. A present outcome that only an effect shows is `target-locations-vm`'s.
- This compatibility run did not repeat the selection acceptance's V seam. The subsequent
  [2026-10-08 selection VM run](selection-vm.md#workspace-101-rerun) establishes it on notarized hosts
  with workspace 1.0.1 as the bundled baseline and workspace 1.1.0/schema 1.0.1 as its update.
  The retained-host 1.0.1 per-user compatibility variant above remains N/G evidence.
