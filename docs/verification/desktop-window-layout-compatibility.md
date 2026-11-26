# Desktop 1.0.1: binary compatibility

This record is the N seam of window layout. Koine 0.5.0 bundles desktop release
1.0.1, which serves window layout. The bundle requires the host feature
`desktop-disclosures-v1`. This tree's host advertises that feature, and the
released Koine 0.4.1 host does not. The record shows three results:

- This tree's host loads this tree's desktop 1.0.1 bundle and serves its
  profile.
- The released 0.4.1 host refuses the same bundle before it loads, when the
  bundle is bundled in place of desktop 1.0.0.
- The released 0.4.1 host also refuses an approved per-user desktop 1.0.1
  before it loads. Its bundled desktop 1.0.0 stays selected.

The contract is "Compatibility and delivery" under "Window layout" in
[the desktop contract](../specs/machine.md). The other pairs of the same run are
in [binary-compatibility.md](binary-compatibility.md) and
[workspace-compatibility.md](workspace-compatibility.md).

## Procedure

```sh
task compat                         # compat:build, compat:verify, then compat:workspace-subjects, in debug
task compat:released-0.4.1          # only the released Koine 0.4.1 tree
```

`task compat:released-0.4.1` builds the released Koine 0.4.1 from tag `v0.4.1`.
The pin `scripts/released-0.4.1.json` names the commit. The build extracts that
revision into a tree of its own under `.build/compat/<configuration>/released-0.4.1`,
and that revision's own scripts build it. The tree holds the 0.4.1 headless host,
its framework, and its sealed Desktop 1.0.0 and Workspace 1.0.2 bundles.

`scripts/build-compat-pairs.sh` builds this tree in a copy of its own. It also
builds a per-user variant of this tree's desktop 1.0.1. The variant changes one
descriptor line and one manifest entry: both state `first-party-selection-v1`,
which a host that predates selection requires of a per-user update.

`scripts/verify-compat-pairs.py` puts the pairs together at run time. Each case
starts one headless host over a temporary data directory, and it drives the
host over loopback HTTP with a grant. It digests every host, framework and
provider binary before and after the run, and it fails when one changed.

## The cases

| Case | Host | Bundles | Expected result |
|---|---|---|---|
| The new bundle in the new host | This tree's host | This tree's desktop 1.0.1, bundled | `ACTIVE`. The served schema, digest and candidate row hold `core-desktop-window-layout-extension-host`. |
| Bundled in the released host | Released 0.4.1 host | This tree's desktop 1.0.1 and the 0.4.1 workspace 1.0.2, bundled | Desktop 1.0.1 `INCOMPATIBLE`, `feature-unavailable`. The desktop slot is unavailable. No desktop image is mapped. Workspace 1.0.2 is `REJECTED`, `missing-capability-owner`, because no selected provider owns `desktop:control`. |
| Per-user in the released host | Released 0.4.1 host | The 0.4.1 desktop 1.0.0 and workspace 1.0.2, bundled. The desktop 1.0.1 variant, approved per user | Desktop 1.0.1 `INCOMPATIBLE`, `feature-unavailable`. Desktop 1.0.0 stays `SELECTED`, and only its image is mapped. |

Each refusal must name `desktop-disclosures-v1` as a host feature that the host
lacks. In each refusal, the schema must reject a query of `desktopWindows`. In the per-user case,
desktop 1.0.0 must still answer a read.

The new-host case reuses the check of the released desktop provider. That check
runs `KoineConformance --profile` and has two controls. The same check must fail
against a design text with one description changed. It must also fail against
a profile that pins another release.

## Run record

The run took place on 2026-11-26, in debug, on macOS 27.2.1 (26B131), arm64. The
tools were Apple Swift 6.4.2, Xcode 27.2 (27B52) and Task 3.54.0. The bundles
carry the signature of Developer ID Application, Team ID TA43A4RUP3. The
released tree came from tag `v0.4.1`, commit `1088ce07e477`.

`task compat` ran 40 cases with no failed check, and no subject binary changed
during the run. `compat:workspace-subjects` also passed. The three desktop
1.0.1 cases gave these results:

| Case | Observed |
|---|---|
| The new bundle in the new host | Desktop 1.0.1 `ACTIVE`, `BUNDLED`, `SELECTED`, with no reason. `KoineConformance` reported `CONFORMANT` against `desktop-window-layout-schema-extension-host.graphql` and the profile. Both controls failed as the check requires. |
| Bundled in the released host | "The provider requires host features this Koine lacks: desktop-disclosures-v1." The rows were exactly the three rows of the table above. The host mapped no desktop image. A query of `desktopWindows` got HTTP 400: "Cannot query field "desktopWindows" on type "Query"." |
| Per-user in the released host | The same diagnostic. Desktop 1.0.0 stayed `ACTIVE`, `SELECTED`, with the reason `selected-with-refusals`, and workspace 1.0.2 stayed `ACTIVE`. The only desktop image that the host mapped was the 0.4.1 desktop 1.0.0, from the host's own staging. Desktop 1.0.0 answered a read. |

The first run of the same day failed one check, and the instrument caused it.
The pin of the bundled case expected workspace 1.0.2 to be `ACTIVE`. The host
served it as `REJECTED`, `missing-capability-owner`. That is the designed
cascade when no desktop provider is selected, so the pin now states it. The
failure also shows that the row check can fail.

The new-host case is the control of the two refusals. The same bundle is
`ACTIVE` in a host that has `desktop-disclosures-v1`, so the refusals come from
the host feature and not from the bundle.

`.build/compat/debug/results.json` holds every observation of the run. The
SHA-256 prefixes of the desktop subjects are below.

| Subject | SHA-256 prefix |
|---|---|
| This tree's desktop 1.0.1 image | `da7eea4c8e25` |
| The per-user variant image | `dab67c3ed8e6` |
| The released 0.4.1 host | `172d34e6799b` |
| The released 0.4.1 framework | `321493d4ace4` |
| The released 0.4.1 desktop 1.0.0 image | `b8bcab673bb7` |
| The released 0.4.1 workspace 1.0.2 image | `2c5fefdf1bd2` |
