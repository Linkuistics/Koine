# Desktop 1.0.2: binary compatibility

This record is the N seam of pointer and media. Koine 0.6.0 bundles desktop
release 1.0.2, which serves the pointer position, the nudge and the media keys.
The bundle requires the host feature `desktop-disclosures-v2`. This tree's host
advertises that feature. The released Koine 0.4.1 and 0.5.0 hosts do not. The
record shows these results:

- This tree's host loads this tree's desktop 1.0.2 bundle and serves its
  profile.
- Each released host refuses the same bundle before it loads, when the bundle
  is bundled in place of the host's own desktop.
- Each released host also refuses an approved per-user desktop 1.0.2 before it
  loads. The released 0.5.0 host keeps its bundled desktop 1.0.1 selected, and
  the released 0.4.1 host keeps its bundled desktop 1.0.0 selected.

The contract is "Versions and host feature" under "Pointer and media" in
[the desktop contract](../specs/machine.md). The window layout record of
desktop 1.0.1 is
[desktop-window-layout-compatibility.md](desktop-window-layout-compatibility.md).

## Procedure

```sh
task compat                         # compat:build, compat:verify, then compat:workspace-subjects, in debug
task compat:released-0.5.0          # only the released Koine 0.5.0 tree
```

`task compat:released-0.5.0` builds the released Koine 0.5.0 from tag `v0.5.0`.
The pin `scripts/released-0.5.0.json` names the commit. The build extracts that
revision into a tree of its own under `.build/compat/<configuration>/released-0.5.0`.
That revision's own scripts build it. The tree holds the 0.5.0 headless host,
its framework, and its sealed desktop 1.0.1 and workspace 1.0.2 bundles.
`task compat:released-0.4.1` builds the released 0.4.1 tree in the same way.

`scripts/build-compat-pairs.sh` builds this tree in a copy of its own. It also
builds a per-user variant of this tree's desktop 1.0.2. The variant changes one
descriptor line and one manifest entry: both state `first-party-selection-v1`,
which an earlier host requires of a per-user update. Both released hosts get
the same variant.

`scripts/verify-compat-pairs.py` puts the pairs together at run time. Each case
starts one headless host over a temporary data directory. The case drives the
host over loopback HTTP with a grant. The script digests every host, framework
and provider binary before and after the run, and it fails when one changed.

## The cases

| Case | Host | Bundles | Expected result |
|---|---|---|---|
| The new bundle in the new host | This tree's host | This tree's desktop 1.0.2, bundled | `ACTIVE`. The served schema, digest and candidate row hold `core-desktop-pointer-media-extension-host`. |
| Bundled in the released 0.5.0 host | Released 0.5.0 host | This tree's desktop 1.0.2 and the 0.5.0 workspace 1.0.2, bundled | Desktop 1.0.2 `INCOMPATIBLE`, `feature-unavailable`. The desktop slot is unavailable. No desktop image is mapped. Workspace 1.0.2 is `REJECTED`, `missing-capability-owner`. |
| Per-user in the released 0.5.0 host | Released 0.5.0 host | The 0.5.0 desktop 1.0.1 and workspace 1.0.2, bundled. The desktop 1.0.2 variant, approved per user | Desktop 1.0.2 `INCOMPATIBLE`, `feature-unavailable`. Desktop 1.0.1 stays `SELECTED`, and only its image is mapped. |
| Bundled in the released 0.4.1 host | Released 0.4.1 host | This tree's desktop 1.0.2 and the 0.4.1 workspace 1.0.2, bundled | The same result as the bundled 0.5.0 case. |
| Per-user in the released 0.4.1 host | Released 0.4.1 host | The 0.4.1 desktop 1.0.0 and workspace 1.0.2, bundled. The desktop 1.0.2 variant, approved per user | Desktop 1.0.2 `INCOMPATIBLE`, `feature-unavailable`. Desktop 1.0.0 stays `SELECTED`, and only its image is mapped. |

Each refusal must name `desktop-disclosures-v2` as a host feature that the host
lacks. The refusal must not name `desktop-disclosures-v1`, because the 0.5.0
host has it. In each refusal, the schema must reject a query of
`desktopPointer`, the read that desktop 1.0.2 adds. In each per-user case, the
kept desktop must still answer a read.

The schema probe of the refusals is `desktopPointer`, not `desktopWindows`. The
kept desktop 1.0.1 of the 0.5.0 host serves `desktopWindows`. So a probe of
`desktopWindows` cannot tell desktop 1.0.1 from desktop 1.0.2.

The new-host case reuses the check of the released desktop provider. That check
runs `KoineConformance --profile` and has two controls. The same check must fail
against a design text with one description changed. It must also fail against
a profile that pins another release.

## Run record

The run took place on 2026-11-27, in debug, on macOS 27.2.1 (26B131), arm64. The
tools were Apple Swift 6.4.2, Xcode 27.2 (27B52) and Task 3.54.0. The bundles
carry the signature of Developer ID Application, Team ID TA43A4RUP3. The
released trees came from tag `v0.5.0`, commit `8cb2d75eb0dd`, and tag `v0.4.1`,
commit `1088ce07e477`.

`task compat` ran 42 cases with no failed check, and no subject binary changed
during the run. `compat:workspace-subjects` also passed. The five desktop 1.0.2
cases gave these results:

| Case | Observed |
|---|---|
| The new bundle in the new host | Desktop 1.0.2 `ACTIVE`, `BUNDLED`, `SELECTED`, with no reason. `KoineConformance` reported `CONFORMANT` against `desktop-pointer-media-schema-extension-host.graphql` and the profile. Both controls failed as the check requires. |
| Bundled in the released 0.5.0 host | "The provider requires host features this Koine lacks: desktop-disclosures-v2." The rows were exactly the three rows that the table states. The host mapped no desktop image. A query of `desktopPointer` got HTTP 400: "Cannot query field "desktopPointer" on type "Query"." |
| Per-user in the released 0.5.0 host | The same diagnostic. Desktop 1.0.1 stayed `ACTIVE`, `SELECTED`, with the reason `selected-with-refusals`, and workspace 1.0.2 stayed `ACTIVE`. The only desktop image that the host mapped was the 0.5.0 desktop 1.0.1, from the host's own staging. Desktop 1.0.1 answered a read. |
| Bundled in the released 0.4.1 host | The same diagnostic and the same three rows. The host mapped no desktop image, and the schema rejected `desktopPointer`. |
| Per-user in the released 0.4.1 host | The same diagnostic. Desktop 1.0.0 stayed `ACTIVE`, `SELECTED`, with the reason `selected-with-refusals`. Its image was the only desktop image that the host mapped, and it answered a read. |

In the per-user 0.5.0 case, the HTTP 400 answer suggested `desktopWindows` and
`desktopWindowOnTop` in place of `desktopPointer`. So the schema of that host
held the window layout of desktop 1.0.1 and not the pointer read of 1.0.2.

The new-host case is the control of the refusals. The same bundle is `ACTIVE`
in a host that has `desktop-disclosures-v2`, and that host serves
`desktopPointer`. So the refusals come from the host feature and not from the
bundle, and the schema probe can pass.

`.build/compat/debug/results.json` holds every observation of the run. The
SHA-256 prefixes of the desktop subjects are below.

| Subject | SHA-256 prefix |
|---|---|
| This tree's desktop 1.0.2 image | `e7fd40760a2d` |
| The per-user variant image | `5b305195786e` |
| The released 0.5.0 host | `d508a8665f49` |
| The released 0.5.0 framework | `c06bd7b0622d` |
| The released 0.5.0 desktop 1.0.1 image | `954821ea9765` |
| The released 0.5.0 workspace 1.0.2 image | `2f7784285915` |
