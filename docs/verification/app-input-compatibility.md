# Input 1.0.0: binary compatibility

This record is the N seam of app input. Koine 0.7.0 bundles input release
1.0.0, its first input provider. The released Koine 0.6.0 seals a catalogue
that keeps the input slot reserved-only, so it cannot load an input bundle from
either root. The record shows these results:

- This tree's host loads this tree's input 1.0.0 bundle beside desktop 1.0.2
  and workspace 1.0.2, and it serves the Koine 0.7.0 profile.
- The released 0.6.0 headless host refuses the same bundle before load when
  the bundle is in its sealed root.
- The released 0.6.0 signed selection host refuses an approved per-user input
  bundle before load. That host carries the sealed catalogue of the 0.6.0
  application.

In each refusal, the released host keeps its bundled desktop 1.0.2 and
workspace 1.0.2 selected, and it offers no input capability.

The contract is "Reserved identities" in [the machine contract](../specs/machine.md).
A reserved-only catalogue entry cannot load from either root. The record of
desktop 1.0.2 is
[desktop-pointer-media-compatibility.md](desktop-pointer-media-compatibility.md).

## Procedure

```sh
task compat                         # compat:build, compat:verify, then compat:workspace-subjects, in debug
task compat:released-0.6.0          # only the released Koine 0.6.0 tree
```

`task compat:released-0.6.0` builds the released Koine 0.6.0 from tag `v0.6.0`.
The pin `scripts/released-0.6.0.json` names the commit. The build extracts that
revision into a tree of its own under `.build/compat/<configuration>/released-0.6.0`.
That revision's own scripts build it. The tree holds the 0.6.0 headless host,
its framework, and its sealed desktop 1.0.2 and workspace 1.0.2 bundles.

`scripts/build-compat-pairs.sh` builds this tree in a copy of its own. It seals
and approves this tree's input 1.0.0 as the application seals it. It also runs
two scripts of the released 0.6.0 tree in that tree, unedited. The first builds
the 0.6.0 selection host, and the second assembles and signs it as the
"production" host of the 0.6.0 selection acceptance. That host carries the
0.6.0 file `App/ProviderCatalogue.json` verbatim, around the 0.6.0 desktop and
workspace bundles. It is the headless form of the signed 0.6.0 application.

`scripts/verify-compat-pairs.py` puts the pairs together at run time. Each case
starts one host over a temporary data directory. The case drives the host over
loopback HTTP with a grant. The script digests every host, framework, catalogue
and provider binary before and after the run, and it fails when one changed.

## Why two released hosts

The released 0.6.0 headless host builds its catalogue from the approval
records beside its sealed root. The sealed root holds the 0.6.0 desktop and
workspace bundles with their records, as the 0.6.0 application designates
them. The case puts the input bundle beside them with no record. So that
catalogue designates desktop and workspace alone, as the catalogue of the 0.6.0
application does.

That host has no reserved-only input entry, so it cannot hold the per-user
case. It would treat a per-user input bundle as an ordinary provider. The
signed selection host reads the sealed 0.6.0 catalogue with its reserved-only
input entry, as the 0.6.0 application reads it. So the per-user case runs
there.

## The cases

| Case | Host | Bundles | Expected result |
|---|---|---|---|
| The new bundle in the new host | This tree's host | This tree's desktop 1.0.2, input 1.0.0 and workspace 1.0.2, bundled | The three providers are `ACTIVE`, `BUNDLED` and `SELECTED`. The served schema, digest and candidate rows hold `core-desktop-input-workspace-extension-host`. The host maps the input image from its staging. |
| In the sealed root of the released 0.6.0 | Released 0.6.0 headless host | The 0.6.0 desktop 1.0.2 and workspace 1.0.2 with their records. This tree's input 1.0.0, with no record | Input 1.0.0 `REJECTED`, `unexpected-bundled-candidate`. The host maps no input image. |
| Per-user in the released 0.6.0 | Released 0.6.0 signed selection host | Its own sealed catalogue, desktop 1.0.2 and workspace 1.0.2. This tree's input 1.0.0, approved per user | Input 1.0.0 `REJECTED`, `reserved-only`. The host maps no input image. |

In each refusal, these checks also hold:

- The candidate rows are exactly the three rows of the table.
- The input row carries a diagnostic.
- The host offers no input capability.
- The schema rejects a query of `inputTarget`, the read that input 1.0.0 adds.
- The bundled desktop 1.0.2 still answers a read.

The new-host case has two controls of its conformance check. The same check
must fail against a design text with one input description changed. It must
also fail against a profile that pins another input release.

The new-host case is also the control of the image check. The same function
that lists the mapped input images must find one image in the new host. So an
empty list in a refusal comes from the refusal and not from a broken
instrument.

## Run record

The run took place on 2026-11-28, in debug, on macOS 27.2.1 (26B131), arm64.
The tools were Apple Swift 6.4.2, Xcode 27.2 (27B52) and Task 3.54.0. The
bundles and the selection host carry the signature of Developer ID Application,
Team ID TA43A4RUP3. The released tree came from tag `v0.6.0`, commit
`e937db518e5e`.

`task compat` ran 45 cases with no failed check, and no subject binary changed
during the run. `compat:workspace-subjects` also passed. The sealed catalogue
inside the selection host was identical to `App/ProviderCatalogue.json` at
`v0.6.0`. The three input cases gave these results:

| Case | Observed |
|---|---|
| The new bundle in the new host | Desktop 1.0.2, input 1.0.0 and workspace 1.0.2 were `ACTIVE`, `BUNDLED`, `SELECTED`, with no reason. The host offered `input:read` and `input:control`. An absent process gave a null `inputTarget` with no error. The host mapped one input image, from its staging, with the bytes of the sealed bundle. `KoineConformance` reported `CONFORMANT` against `desktop-input-workspace-schema-extension-host.graphql` and the profile. Both controls failed as the check requires. |
| In the sealed root of the released 0.6.0 | "Input.koineprovider is not a bundle this Koine's catalogue designates. The application's sealed root holds the designated bundles only, and an unexpected one never replaces a designated bundle." The host mapped no input image, and it offered no input capability. A query of `inputTarget` got HTTP 400: "Cannot query field "inputTarget" on type "Query"." Desktop 1.0.2 answered a read. |
| Per-user in the released 0.6.0 | "input is reserved for a provider Koine has not shipped yet; it cannot load from either root." The host mapped no input image, and it offered no input capability. The schema rejected `inputTarget` in the same words. Desktop 1.0.2 answered a read. |

The new-host case is the control of the refusals. The same bundle is `ACTIVE`
in a host whose catalogue enables input. So the refusals come from the 0.6.0
catalogue and not from the bundle.

`.build/compat/debug/results.json` holds every observation of the run. The
SHA-256 prefixes of the input subjects are below.

| Subject | SHA-256 prefix |
|---|---|
| This tree's input 1.0.0 image | `4e700ef8e25f` |
| This tree's input 1.0.0 manifest | `4bb1fd49e0f8` |
| The released 0.6.0 headless host | `5e4bdf88bf64` |
| The released 0.6.0 framework | `b340792f6fd4` |
| The released 0.6.0 selection host | `f8c2f23f0ef7` |
| The sealed 0.6.0 catalogue | `09250ea9bec3` |
| The released 0.6.0 desktop 1.0.2 image | `122789941ea1` |
| The released 0.6.0 workspace 1.0.2 image | `edb471753fb7` |

## What this does not claim

- **The notarised application.** The hosts here are headless. The selection
  host carries the sealed catalogue and signature of the 0.6.0 application,
  but it is not the notarised 0.6.0 download. The release checks of 0.7.0 run
  on the notarised build.
- **A release configuration.** The run used debug builds.
- **Hosts before 0.6.0.** Every earlier release also keeps input reserved-only.
  The run tested the released 0.6.0 alone, because that is the release a user
  updates from.
