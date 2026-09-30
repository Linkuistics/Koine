# First-party selection: independent updates across binary generations

The update rows of "Selection acceptance" in
[the Machine spec](../specs/machine.md#selection-acceptance), at the two seams that node assigns
them: **N**, the native loader with real independently built binaries in a fresh signed host
process, and **G**, public GraphQL management over loopback HTTP. The harness is the one
[selection-decisions.md](selection-decisions.md) describes and
[selection-failures.md](selection-failures.md) extends (`scripts/selection_harness.py`); this record
covers what `selection-updates` adds to it, and the rows it closes.

What is new is the subject. The binaries are independently built **generations**, not edited copies
of one:

- the **released** revision's headless host (v0.1.0) and its desktop provider, compiled from that
  release's own source by `scripts/build-baseline-host.sh`, beside this tree's host and providers;
- the **real** first-party providers as well as fixtures: this tree's desktop and workspace
  (release 1.0.0), and **newer releases of the same sources** (1.1.0) that state
  `first-party-selection-v1` in their manifest *and* their descriptor, as every newly published
  first-party update must;
- fixtures where a defect must be made on purpose, as before, standing in for desktop
  (`fixturesh`) and workspace (`fixturesk`).

A real provider writes no marker. It is seen loaded by its **image being mapped** into the host
process (the host now reports every image that is not the system's, with the runtime classes it
defines), and served by its row being `ACTIVE`; a refusal is paired with a control of the same
compiled binary, exactly as a marker refusal is.

## Procedure

```sh
task selection:updates      # fixtures, hosts, then every scenario; .build/selection-acceptance/updates.json
task selection:mutation     # each instrument seen RED against a loader with one decision broken
task selection:fixtures     # the provider bundles: fixtures, and the real providers and their updates
task selection:hosts        # the signed hosts
```

It needs the signing identity of `scripts/signing-env.sh`, `rsync`, `python3`, and the released
host (`task compat:baseline`, which the fixtures recipe depends on). Nothing launches `Koine.app` or
touches `~/Library/Application Support/Koine`: each run is a headless host over a temporary data
directory. It is a debug build, signed with the Developer ID identity and the hardened runtime,
**not notarized**; the V seam and its notarized hosts are `selection-vm`'s.

`task selection:updates -- --only <text>` runs the scenarios whose name contains the text; a subset
run cannot close the control pairing.

## What is new in the harness

| Piece | Where |
|---|---|
| **Real first-party bundles.** `current-desktop` and `current-workspace` (this tree's), `released-desktop` (the released revision's own bundle, its seal untouched), and `desktop-update`, `workspace-update` (1.1.0, the feature stated in manifest and descriptor), each also under another principal class (`…-renamed`) and with a manifest that does not state the feature (`…-no-feature`). An update is compiled from a **copy** of `Providers/` with two checked source substitutions and the release edited in the manifest (1.1.0); the product source is never edited and no build flag exists in it. The workspace update reuses the desktop provider's kernel start-instant helper as source, as the workspace provider always does | `scripts/build-selection-real.sh` |
| **Hosts around real bundles.** `production`: the shipped catalogue whole, around this tree's two providers. `desktop-old`: the shipped catalogue (workspace reserved-only) around the released desktop provider as the designated baseline. `impostor-host`: the shipped provider identifiers and prefixes, admitting fixture signing identifiers that are not the production ones. `slot-caught-up`, `slot-impostor-admitted` | `Fixtures/SelectionHost/hosts.json`, `scripts/build-selection-hosts.py` |
| **What the process mapped.** The host's ready line lists every non-system image with the Objective-C classes it defines (`objc_copyClassNamesForImage`); the released host's driver does the same | `Fixtures/SelectionHost/main.swift`, `scripts/compat-released-host-main.swift` |
| **Staging names, predicted.** The loader names a staged copy from its origin, canonical location and content. The harness forms that name (`staged_name`) and so tells two bundles of one name in two roots apart (`FixtureSh@bundled`, `FixtureSh@user`), tells a legacy entry from a current one, and reads which staged copies carry the quarantine attribute | `scripts/selection_harness.py` |
| **The released host as a subject.** `ReleasedHost`: the v0.1.0 driver over a fresh data directory, a bundled root that stands in for `Contents/PlugIns` with the approval record the released application gives its own, and a per-user root | `scripts/selection_harness.py` |
| **Desktop operations, as a client sends them.** An application running here, the same PID claimed a microsecond later, an absent process, a malformed identity, a stale reference read and acted on, and the same under a read-only grant and a control-only one; each answer normalised so that two hosts can be compared | `harness.desktop_operations` |
| **Actions on a stopped host's data.** Install under a given approval (none, or another Team ID), place a bundle outside the root behind a link, replace a release without touching its approval, clear a quarantine attribute, delete a staged copy, damage one, make the staging directory unwritable, plant an entry of the earlier staging scheme | `HostRun.apply` |

**Private seam.** The one substitution is still the discovery order within a root, reversed for the
alternative run, and the assessment verdict on a quarantined image, as in the failure boundary. The
verifier, staging, approval check and loader are the shipped ones.

**A harness defect found and fixed.** `HostRun.stop` removed its temporary directory with
`ignore_errors`, and a staged copy is read-only: every run left its data directory behind.
`/var/folders/…/T` held 1 688 `koine-selection-*` and 979 `koine-compat-*` directories from earlier
leaves (1.6 GB); the directories are made writable first, and the stale ones were removed.

## Evidence by row

A scenario name is a substring of the name in `scenarios()`; each runs forward and reversed.

### Old host and new host over an old baseline

Row: *Old host + old desktop; new host + independently compiled old designated baseline*.
**Established at N and G; V pending in `selection-vm`.**

- `old host: the released host and its desktop provider`: the released host, running the released
  desktop provider as its bundled provider, `ACTIVE`; its desktop operations answer as the contract
  says (below); the **old-host** profile `core-desktop-old-host` holds, with the check's own controls
  seen red.
- `a selection-aware host over an independently compiled old designated baseline`: the signed host
  `desktop-old`, whose catalogue entry for `desktop` is the shipped catalogue's own, byte for byte, and
  whose designated bundle is the **released** desktop provider. `desktop 1.0.0` `BUNDLED` `SELECTED`
  `ACTIVE`, no reason. The bundle's signing identifier (read from its signature), release and schema are
  the entry's, it declares no feature and needs framework minor 0 (no new factory witness), and the
  **extension-host** profile `core-desktop-extension-host` holds.
- `old host and new host: existing desktop operations preserved`: the same eleven steps sent to both
  hosts give the same status, data and errors, with their kinds, messages and paths. The steps (eleven, and two more when Finder is running, which the run requires so that the positive path is
  exercised; Finder's window list, which changes from one moment to the next, is not compared) hold the
  contract on each host: an absent process, and the same PID claimed a microsecond later, are ordinary
  nulls; a malformed instant is refused naming its form; a stale window reference is `unavailable` whether
  read or acted on; a read-only grant reads and is refused the action naming `desktop:control`; a
  control-only grant is refused the read naming `desktop:read` and reaches the action, where the stale
  reference is what fails; a running application (Finder) is served by name and bundle identifier.

### Compatible newer updates

Row: *Selection-aware host + compatible newer desktop/workspace update*. **Established at N and G; V
pending in `selection-vm`.**

- `a separately approved newer desktop update…`: four phases over one data directory under **one
  signed host**. Baseline only; then a 1.5.0 update with its approval record, which is
  `{providerId, teamIdentifier}` naming the host's own Team ID and nothing else; then a 1.6.0 release
  **replacing the bundle with different bytes under the same approval record** (the record is byte for
  byte the file it was), which is selected; then the update removed. In each phase exactly the selected
  image's initializer, factory and start markers are written and the unselected bundle wrote none; the
  mapped images are that one; the selected binary answers with its own greeting and its operations work
  (items, unavailable outcomes as their kinds, a control action seen read back, a read-only grant refused
  the action naming the capability); the host application is digested before and after, every file, and
  its seal verifies throughout: it was never rebuilt. Koine wrote no approval.
- `a compatible newer workspace update beside the desktop baseline`, and `both shipped slots updated
  independently`: one image per slot, the baselines' markers absent, identifier order.
- `a desktop update under another principal class…`, `a workspace update under another principal
  class…`: the renamed-principal variant is selected like any other on a selection-aware host.
- The same with the **real** providers (`a newer desktop release over the released baseline, without
  rebuilding the host`, and the mixed releases below): the released 1.0.0 is superseded, the 1.1.0 update
  is `ACTIVE` and the only desktop image mapped, under the selected-update profiles
  (below).

### A host that predates the feature

Row: *Pre-extension host + newly published desktop/workspace update, both normal and renamed
principal*. **Established at N and G; V pending in `selection-vm`.**

- `old host: a newly published desktop update, the principal class kept` and `…renamed`: the released
  host (v0.1.0), with the released desktop provider bundled, is given the **real** 1.1.0 desktop update
  per user, with its approval. The update is `INCOMPATIBLE` ("requires host features this Koine lacks:
  first-party-selection-v1") and its image is never mapped; the bundled desktop stays `ACTIVE` and
  its operations answer as above. The **old-host** refused-update profile `core-desktop-old-host-update-refused`
  holds for the first.
- `old host: a newly published workspace update, …kept` and `…renamed`: the same for the workspace
  stand-in, a fixture built to need no framework minor, so that the feature is the **only** thing the
  host lacks: `INCOMPATIBLE` for that reason, no initializer, factory or start marker, while the
  bundled baseline beside it ran all three.
- Each update binary is shown loading where the feature is supplied (the control pairing).
- On the extension host, `a desktop update that does not state first-party-selection-v1…` and its
  workspace, renamed-principal and **real** counterparts: a per-user update whose manifest lacks the
  feature is `INCOMPATIBLE` / `selection-feature-required` before it loads, and the bundled baseline
  keeps the slot with `selected-with-refusals` naming the refused release. The profile
  `core-desktop-workspace-update-refused-extension-host` pins this.

### Trust refusals

Row: *Missing approval, wrong Team ID, unsigned/ad-hoc/tampered seal, escaping location, incompatible
framework/feature/OS/architecture, failed quarantine assessment*. **Established at N and G except a bundle
signed by a second team, pending in `alternate-team-signing`; V pending in `selection-vm`.**

Each case runs for the desktop stand-in and the workspace stand-in. A refused release (2.0.0) is
installed beside a healthy lower update and then alone. Each refusal writes **no marker**, the lower
update (or the bundle) is selected with `selected-with-refusals`, and the selected row's diagnostic names
the release it passed over as a claim. The refused row's own diagnostic:

| Case | State / reason | The diagnostic names |
|---|---|---|
| no approval record | `REJECTED` `not-approved` | "is not approved" |
| a record naming another Team ID | `REJECTED` `approval-team-mismatch` | the Team ID |
| an unsigned bundle | `REJECTED` `signature-refused` | "it is not signed." |
| an ad-hoc signed bundle | `REJECTED` `signature-refused` | "ad-hoc signed, not by the approved identity" |
| a seal altered after it was made | `REJECTED` `signature-refused` | "a sealed resource is missing or invalid" |
| a location that resolves outside the root | `REJECTED` `location-outside-root` | "resolves outside its provider root" (refused before it is staged or read, so it is an `(unknown)` row) |
| an incompatible framework | `INCOMPATIBLE` `framework-incompatible` | "requires provider framework 1.99 or later; this Koine supplies 1.1" |
| a feature this host lacks | `INCOMPATIBLE` `feature-unavailable` | "time-travel" |
| a newer operating system | `INCOMPATIBLE` `os-incompatible` | "requires macOS 99.0" |
| another architecture | `INCOMPATIBLE` `architecture-incompatible` | "built for x86_64; this Koine runs as arm64" |
| a failed quarantine assessment | `REJECTED` `quarantine-refused` | the staged copy, and the command that clears it |

An approval record is one file **per provider**, not per bundle: what refuses one per-user copy refuses
every one, so a missing or foreign record cannot leave a healthy lower update to fall back to. Those two
cases are run as that (`…refuses every per-user copy of the provider; the bundle keeps the slot`), which
is the observation, rather than as a fall-back to a lower update that cannot exist.

**Stage and quarantine recovery** are run as the diagnostics say to:

- `a quarantine refusal is recovered as its diagnostic says`: refused under a verdict that refuses;
  clearing the attribute on the **installed** bundle alone changes nothing (the content-named staged copy
  is reused and keeps it); deleting the staged copy as well, and restarting, stages a fresh copy that
  carries no attribute, is not assessed, and loads. The staged copies are checked to be exactly the
  candidates' own, and which carry the attribute.
- `a staging directory that cannot be written…`: every candidate, the designated bundle included, is
  `staging-failed`, nothing runs, and the slot is an explicit `no-eligible-candidate`; restoring the
  directory and restarting recovers the update.
- `a staged copy damaged after it was made…`: the copy's signature is verified on every start, so the
  damaged copy is `signature-refused` and the bundle keeps the slot; deleting it and restarting recovers.

**Pending: a bundle signed by a second team.** The wrong-Team-ID refusal here is an approval record that
names another team, which is the loader's own check. A bundle *signed* by a second real Developer ID team,
and the alternate-team host, need that team's certificate, which this keychain does not hold
(`security find-identity` lists one Developer ID identity); no mock closes it. Owned by
`alternate-team-signing`, at N and G as at V.

### A fixture under another signing identifier

Row: *Approved same-team fixture claiming a reserved pair/high release under a different signing
identifier*. **Established at N and G; V pending in `selection-vm`.**

- `an approved same-team provider claiming the reserved pairs…`: on the host `production` (the shipped
  catalogue, whole, around the real desktop and workspace), providers named `desktop` / `Desktop` and
  `workspace` / `Workspace` at release 9.0.0, approved for the host's own team and signed under
  `dev.antony.Koine.provider.desktop.impostor` and `…workspace.impostor`, are `REJECTED` /
  `signing-identifier-mismatch` before load, naming the identifier they carry; the real 1.0.0 providers
  stay selected (`selected-with-refusals`, "claims release 9.0.0") and serve their operations; no
  fixture marker was written.
- `the same compiled binaries load as the designated baselines of a test catalogue that admits their
  identifiers`: the control. The host `impostor-host` gives fixtures the shipped identifiers and prefixes
  under signing identifiers that are not production ones, and the same compiled binaries write all three
  markers there. The generator refuses a test catalogue that names a production signing identifier.
- `a test catalogue admits its own distinct fixture identifier, and refuses the one it does not name`:
  with the catalogue naming `…fixturesh.impostor`, a 9.0.0 update signed under it is selected, and a
  1.5.0 update signed under the identifier the other catalogues name is `signing-identifier-mismatch`.
- A correctly identified compatible release needs no new hash approval: see the 1.6.0 phase above, where
  the approval record is unchanged byte for byte.

### Equal bytes in both roots

Row: *Equal bytes and basename in both roots; quarantined per-user copy; legacy shared staging entry*.
**Established at N and G; V pending in `selection-vm`.**

The host `slot-caught-up` designates as its baseline the very directory `r1.5.0`, which an earlier host
installed per user: equal bytes, equal bundle name, one copy in each root.

- `equal bytes in both roots, the per-user copy staged first…`: the host with the quarantined per-user
  copy, then **the host that catches up**. The bundled copy is staged beside the per-user one under its
  own name and runs; only the per-user copy carries the quarantine attribute; under a verdict that
  refuses, the per-user copy is `quarantine-refused` and the bundled copy, which no verdict is asked of,
  is selected. Restarted under a verdict that accepts, the same per-user copy is assessed **again** and is
  now `equal-to-bundled`: the assessment is made of the copy that loads on every start.
- `equal bytes in both roots, the bundled copy staged first…`: the other order. The bundled copy is staged
  and runs first; the per-user copy arrives quarantined and is **assessed, not skipped** by reuse of the
  bundled copy's clean staging: `quarantine-refused`, not `equal-to-bundled`, until the verdict accepts it.
- `a legacy shared staging entry is never reused for an update`: an entry of the earlier, content-only
  scheme (`<bundle name>-<content digest>`) is planted holding the **baseline's** bytes under the name the
  update's bytes would have had. The update is staged under its own candidate-specific name and its
  greeting is the update's; the planted entry is untouched, byte for byte, and no image was mapped from it.
- `a quarantined legacy entry is never inherited by the bundled copy of equal bytes`: the same for a
  quarantined entry of the bundled bytes: the bundled image is mapped from its own name, and the planted
  entry is never mapped.

### Mixed releases

Row: *Mixed desktop/workspace releases and reused helper source*. **Established at N and G; V pending in
`selection-vm`.**

On the host `production`, with the **real** providers:

| Scenario | Desktop | Workspace | Profile pinned |
|---|---|---|---|
| the generation before any update | 1.0.0 bundled | 1.0.0 bundled | `core-desktop-workspace-extension-host` |
| `a mixed release: a newer desktop beside the workspace baseline` | 1.1.0 per user | 1.0.0 bundled | `core-desktop-workspace-desktop-update-extension-host` |
| `a mixed release: a newer workspace beside the desktop baseline` | 1.0.0 bundled | 1.1.0 per user | `core-desktop-workspace-workspace-update-extension-host` |
| `both real providers updated independently` | 1.1.0 per user | 1.1.0 per user | `core-desktop-workspace-update-extension-host` |
| `both real updates under another principal class…` | 1.1.0, renamed | 1.1.0, renamed | the same |

In each, the mapped provider images are exactly the selected ones, and a native inventory of the process
holds:

- the Swift modules each image **defines types in** (the nominal type and protocol descriptors, which an
  optimised build keeps though it hides the rest) are `DesktopProvider` and `WorkspaceProvider` and no
  others, disjoint from each other and from the twenty-one the host image defines, and the framework's;
- the Objective-C runtime classes each image defines are disjoint from each other and from the host's
  166, and no class name is defined by two images of the process;
- the framework is mapped once, the host's own, and no provider defines its module;
- the **helper source is reused**: `ProcessStart` is a nominal type in both images, each under its own
  module (`DesktopProvider.ProcessStart`, `WorkspaceProvider.ProcessStart`), so the two do not collide
  though neither is a shared module;
- **each executes its own implementation**: the desktop provider answers a desktop operation, the
  workspace provider answers a workspace action for an application that is not installed with
  `DEPENDENCY_UNAVAILABLE` / `APPLICATION_NOT_INSTALLED`, and the row for each names the release that ran.

The same inventory is taken of the fixture mixes (`fixturesh` and `fixturesk` share one source file
compiled under two module names), where the answers are two greetings, one per provider.

This is a native observation of what was mapped. It does not claim the loader is a sandbox: native code a
selected provider loads remains trusted.

### Conformance profiles

Six profiles are added beside the existing ones (Machine, "Conformance profiles"), each served by a signed
headless host and held with `KoineConformance --profile`: the design SDL is the unchanged contract (an
update adds no schema), and the pins are what tell the binaries apart.

| Profile | Served by | Pins |
|---|---|---|
| `core-desktop-update-extension-host` | `desktop-old` + the desktop update | desktop 1.1.0 `PER_USER` selected; the released 1.0.0 `superseded-candidate` |
| `core-desktop-workspace-desktop-update-extension-host` | `production` + the desktop update | the mixed release |
| `core-desktop-workspace-workspace-update-extension-host` | `production` + the workspace update | the other mixed release |
| `core-desktop-workspace-update-extension-host` | `production` + both | both updated (also with the renamed principal) |
| `core-desktop-workspace-update-refused-extension-host` | `production` + both updates without the feature | each `INCOMPATIBLE` / `selection-feature-required`; each baseline `selected-with-refusals` |
| `core-desktop-old-host-update-refused` | the released host + a newly published desktop update | desktop 1.0.0 `ACTIVE`; 1.1.0 `INCOMPATIBLE` (management `baseline`) |

Each check is preceded by its controls in the same run: the design half red against another design and
against this design with a nullability marker removed, the pin half red against a wrong reason, a wrong
selection, a row left out and a provider that is not served. The two existing profiles
(`core-desktop-old-host`, `core-desktop-extension-host`) and `core-desktop-workspace-extension-host` are
held by this driver against the signed hosts too.

## Instruments seen red

`task selection:mutation` breaks one decision at a time in a copy of the tree
(`.build/selection-mutations`; the working tree is never edited), assembles the purpose-built hosts around
that copy's headless host and runs the named scenarios. Each of the ten below was seen red in every host
run of each scenario named:

| Broken decision | Scenario | Red runs |
|---|---|---|
| An approval record's Team ID not compared with the host's | `an approval naming another Team ID refuses every per-user copy` | 4 of 4 |
| No approval record required (the host's team assumed) | `missing approval refuses every per-user copy` | 4 of 4 |
|  | `an approval naming another Team ID refuses every per-user copy` | 4 of 4 |
| Code signatures not verified | `an unsigned bundle is refused before load` | 8 of 8 |
|  | `an ad-hoc signed bundle is refused before load` | 8 of 8 |
|  | `a seal altered after it was made is refused before load` | 8 of 8 |
|  | `a staged copy damaged after it was made` | 2 of 2 |
| A location that resolves outside the root accepted | `whose location resolves outside the root` | 8 of 8 |
| The per-user quarantine assessment skipped | `a failed quarantine assessment is refused before load` | 8 of 8 |
|  | `a quarantine refusal is recovered` | 2 of 2 |
| Staged names from content alone (the earlier scheme), shared across origins | `equal bytes in both roots, the per-user copy staged first` | 2 of 2 |
|  | `equal bytes in both roots, the bundled copy staged first` | 2 of 2 |
|  | `a legacy shared staging entry` | 2 of 2 |
|  | `a quarantined legacy entry` | 2 of 2 |
| The selection feature not required of a per-user update | `update that does not state first-party-selection-v1 is refused before it loads` | 8 of 8 |
|  | `real updates that do not state the feature are refused` | 2 of 2 |
| The signing identifier not compared with the catalogue's | `claiming the reserved pairs at a high release` | 2 of 2 |
|  | `admits its own distinct fixture identifier` | 2 of 2 |
| Framework, feature, OS and architecture compatibility not checked | `an incompatible framework is refused before load` | 8 of 8 |
|  | `a feature this host lacks is refused before load` | 8 of 8 |
|  | `a newer operating system is refused before load` | 8 of 8 |
|  | `another architecture is refused before load` | 8 of 8 |
| Every eligible candidate loaded | `a mixed release: a newer desktop beside the workspace baseline` | 2 of 2 |
|  | `a compatible newer workspace update beside the desktop baseline` | 2 of 2 |
|  | `both real providers updated independently` | 2 of 2 |

The instruments that are not a host run are seen red against a subject that is wrong, in the driver's own
`instruments` record: the content digest moves with a byte and with the executable bit; a staged name
differs by origin and by location; the earlier scheme's name is not the current one; the inventory goes red
for two images that define one module, one class, a class or module the host defines, the framework's
module, a framework mapped twice, and helper source that is not compiled into two providers; the desktop
expectations go red for an absent process that is not null, a stale reference that is not `unavailable`, a
read-only grant that names the wrong capability and a control-only grant that is let read; and the
differential between two hosts is red for one step answered differently and empty for identical answers.

## Run record

2026-10-01, macOS 26.6.2 (25G83), arm64, debug build, Developer ID signed (hardened runtime, not notarized).
`task selection:updates`: **80 records (the scenarios, the old/new differential and the driver's instruments), 153 host runs, 2 373 checks, 0 failed,
0 without a control, 0 owned reasons unseen**, twice in a row; the released host (v0.1.0, built from its own source) ran
five of them. `task selection:mutation`: all ten update mutations seen, every named scenario red in every host run.
`task selection:decisions` (134 runs) and `task selection:failures` (119 runs) still pass with the harness as changed, and
`task conformance` (headless profiles) passes. `task test` passes but for one test that is not this leaf's and
does not always fail: `WorkspaceCompositionTests.denialInsideADependencyWithholdsItsNonNullFieldAndSoTheDependency`
(a revocation race) failed in two full runs and passed in three and alone, and the parent revision fails
`ProviderLoaderTests.aQuarantinedUnnotarizedProviderIsRefusedBeforeLoading` (it asks Gatekeeper online) in its
own runs; no file under `Sources/`, `Tests/` or `Providers/` changed here.

An adversarial read by a fresh context (the leaf's one in-session reviewer) found no outright bug and eleven hollow
or unbacked points, of which these were repaired: the start order of both shipped slots is now asserted; the control
accounting credits `FixtureSh@user` and `FixtureSh@bundled` to their own binaries; the pin controls of a
baseline-management profile mutate a field the row has; the architecture a manifest claims is the one this Mac
is not; the differential no longer compares a volatile window list and fails if a side is missing; the running
application the positive path needs is required; the escape scenarios assert that nothing was staged; the
approval record is compared by inode and time as well as bytes; the inventory asserts it inspected something; and
a released-host run credits a control only when its own checks held. Accepted and documented: the real updates
cannot be told from their baselines by behaviour, and the `…-no-feature` real bundles keep the production signing
identifier (Observations).

## Observations

- An approval record is per provider, not per bundle, so the trust refusals that concern it refuse every
  per-user copy of the provider at once. A lower update is only a fall-back for a defect in one bundle.
- A per-user copy equal to the bundled one is still staged and, if it is quarantined, **assessed** before it is
  judged `equal-to-bundled`: with a verdict that refuses it the row is `quarantine-refused`, not
  `equal-to-bundled`. The reason changes with the verdict across restarts, which is the spec's "no cross-restart
  verdict guarantee".
- A staging directory that cannot be written refuses the designated bundle as well: staging is attempted
  before an existing copy is looked for, so nothing runs and the slot reports `no-eligible-candidate`. The
  recovery is the directory's, then a restart.
- The real desktop and workspace providers load in a headless signed host around the shipped catalogue with
  no application shell, and serve their operations there; the real desktop answers a running application's
  identity without Accessibility consent.
- A released host reports a refused update as one more row of the provider with the same identifier, the
  original management schema unchanged, and the original core + desktop contract still exactly what it serves.
- A bundle whose location resolves outside the root is refused before it is staged, so nothing of it is
  read, and its row is an `(unknown)` one rather than the provider's.

- The real updates are the baselines' source with a newer release and the feature stated, so the loader and the
  rows tell an update from its baseline (release, origin, staged image) but its behaviour cannot. That is the
  point of the compatibility promise, and the reason the mixed-release claim rests on the image inventory and the
  rows, not on a behavioural difference.
- The `…-no-feature` real bundles are the genuine release artifacts with a manifest that omits the feature, so
  they keep the production signing identifier: the refusal under test is the missing feature, which the loader
  checks before the signing identifier. The negative fixtures for the signing identifier itself are never signed
  under a production one (`…impostor`).
- The approval-record bytes, inode and modification time are compared across the replacement of a bundle; the
  host application is compared file for file. Both are single-phase, and so only recorded, in the scenarios that
  install an update once.

## Not established here

- A bundle signed by a second real Developer ID team, and the alternate-team host (above):
  `alternate-team-signing`.
- Notarized hosts, genuinely quarantined downloads and every V row: `selection-vm`.
- No claim that the loader is a sandbox. A refused image's absence from the marker log and the mapped image
  list is the observation; native code the loader loaded stays trusted.
