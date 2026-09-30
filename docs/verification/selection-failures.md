# First-party selection: the failure boundary after choices freeze

The failure rows of "Selection acceptance" in
[the Machine spec](../specs/machine.md#selection-acceptance) that concern a
selection that has already frozen, at the two seams that node assigns them: **N**,
the native loader with real independently built binaries in a fresh signed host
process, and **G**, public GraphQL management over loopback HTTP. The harness is the
one [selection-decisions.md](selection-decisions.md) describes, now a library
(`scripts/selection_harness.py`) that both drivers import.

This record covers `freeze-failures`: a frozen update failing after its choice, the
principal conflicts among frozen selections, and the later-failure half of
diagnostic completeness; and `duplicates-cascade`: ordinary duplicates, the
capability-owner cascade and a start failure. The digest and restart rows are
`digest-restart`'s, which adds its own section here.

## Procedure

```sh
task selection:failures     # fixtures, hosts, then every scenario; .build/selection-acceptance/failures.json
task selection:mutation     # each instrument seen RED against a loader with one decision broken
```

`task selection:failures -- --only <text>` runs the scenarios whose name contains
the text; a subset run cannot close the control pairing.

## What is new in the harness

- **Phases.** A scenario may go on: an action on the stopped host's data directory
  (`remove`, `replace`, `install`), then a **restart**, which is a new host process
  over the same data directory with a **new marker log**. Every phase is asserted
  as a scenario is (rows, invariants, markers, service). Recovery is repair or
  removal and then a restart, and nothing else.
- **Controls for a partly-run image.** A frozen selection that fails after it
  loaded ran its initializer, and perhaps its factory, and never started. The
  phases it did not reach are controlled by the same compiled binary writing every
  marker elsewhere in the run, or by a declared twin built from the same source
  without the defect (`TWINS`): the two whose SDL the core refuses are twinned with
  the healthy update, and every other failing update here is the healthy update's
  binary with an edited manifest.
- **What the whole host serves.** A phase can also assert the capabilities
  `koine.availableCapabilities` lists (and does not), the Mutation fields published,
  a Query field that is published and fails as `unavailable`, and a **conformance
  profile**: the harness captures the introspection, the provider rows and the digest
  a client reads, and holds them to `docs/design/profiles/<profile>.json` with the
  same `KoineConformance` tool `task conformance` uses, then shows that check red
  against a wrong design and four mutated pins before the clean verdict counts.
- **Host class.** `KoineSelectionHost` registers `KoineSelectionHostClass` in its
  own image, so a manifest can name a class the host already has. `NSObject` is the
  system's.

## What a fixture is

Every failing update is release 2.0.0 of `fixturesh`, so it outranks a healthy lower
update (1.5.0) and the bundled baseline; both alternatives are installed with it.

| Case | What is wrong | Where it is caught |
|---|---|---|
| `f-principal-host-class` | its manifest names `KoineSelectionHostClass`, registered by the host's own image | the loader's batch principal check, before any `dlopen` |
| `f-principal-system-class` | its manifest names `NSObject` | the same |
| `f-dlopen-unloadable` | its main image links a private dependency (in the bundle, validated, signed) whose own dependency is a system-path library that does not exist | `dlopen`: the dynamic loader refuses, no initializer runs |
| `f-principal-missing` | its image loads and registers no class of the manifest's principal name | after `dlopen`, before the factory |
| `f-principal-not-factory` | the name is a class of its image that is no `ProviderFactory` | the same |
| `f-descriptor-mismatch` | its manifest requires `additional-capabilities-v1` and its descriptor does not declare it | after the factory constructs: descriptor agreement |
| `f-schema-invalid-sdl` | its SDL does not parse | the core, before publication |
| `f-schema-outside-prefix` | its SDL defines `OtherThing`, outside `FixtureSh` | the core, before publication |
| `f-dlopen-good` | the same binary and bundle as `f-dlopen-unloadable` with a private dependency that loads | (the control for it) |
| `f-repaired` | a good 2.0.0 | (the repair every recovery installs) |

Principal-conflict fixtures: `f-principal-sk` (a `fixturesh` 2.0.0 whose manifest
names `fixturesk`'s principal class), and ordinary providers `ordinary-principal-sh`,
`ordinary-principal-host-class` and `unknown-principal-od` that name a shipped
provider's, the host's, and another ordinary provider's principal class.

### What a dependant is

The cascade needs a provider that names *another* provider as an additional-capability
owner (the existing `FIXTURE_ADDITIONAL` names only itself). `FIXTURE_NEEDS_SH` and
`FIXTURE_NEEDS_SK` name `fixturesh` or `fixturesk`, so that a real independently built
binary requires `fixturesh:read` or `fixturesk:read` for its `…RenameItemChecked` action
(framework minor 1, `additional-capabilities-v1`, declared by manifest and descriptor):

| Case | What it is | Stands for |
|---|---|---|
| `dep-sk-needs-sh` | a `fixturesk` 1.1.0 update that requires `fixturesh`'s read capability | workspace |
| `dep-od-needs-sk` | an ordinary `fixtureod` that requires `fixturesk`'s | the third provider |
| `dep-sh-needs-sk` | a `fixturesh` 2.0.0 update that requires `fixturesk`'s | the other half of a cycle |
| `sf-start-fails` | a `fixturesh` 2.0.0 update whose `start()` throws after its marker | desktop that fails to start |
| `ordinary-same-prefix`, `ordinary-same-identifier` | `fixtureod` with another identifier, or another prefix | half an identity |
| `ordinary-framework-future`, `ordinary-adhoc`, `ordinary-tampered` | `fixtureod` whose framework minor the host lacks, signed ad hoc, or altered after sealing | rivals a pre-load check refuses |

The chain is `fixturesh` ← `fixturesk` ← `fixtureod`; `dep-sh-needs-sk` with
`dep-sk-needs-sh` is the cycle.

## Evidence by row

### Frozen update fails later

Row: *Frozen update fails principal check, dlopen, descriptor or schema with healthy
alternatives*. **Established at N and G.**

For each of the eight failing updates above, in a `slot` host with the lower update
and the bundled baseline installed:

- The failing update is `REJECTED` / `SELECTED`, with the stable reason of its
  failure (`principal-collision`, `load-failed`, `principal-class-missing`,
  `principal-class-invalid`, `descriptor-mismatch`, `invalid-sdl`, `missing-prefix`)
  and a diagnostic that says what failed. Its row names itself and the lower update
  and the baseline point at it: the choice stays identifiable.
- Both alternatives are `superseded-candidate` and **wrote no marker**: nothing was
  loaded, started or retried in their place. Neither the update's own fields nor
  the slot's are in the served schema.
- Markers follow the phase that failed: none before `dlopen` (principal collision,
  `load-failed`), `initializer` alone for the two principal-class failures,
  `initializer` and `factory` for the descriptor and the core's schema refusals, and
  never `start`. A refused image can be mapped; none of it contributed.
- **Recovery, in the same data directory.** The failing copy is repaired in place
  (`f-repaired` under the same name): the next process runs it as an `ACTIVE`
  `2.0.0`, with the lower update and the baseline still `superseded-candidate`. The
  repaired copy is then removed: the lower update is `ACTIVE`, and the baseline is
  superseded. Each phase has its own marker log.

### Principal conflicts

Row: *Shipped update principal conflicts with another shipped bundle; ordinary
candidate conflicts with shipped selection or host class*. **Established at N and
G**, and the diagnostics' agreement with the capability-owner cascade is
[the cascade's](#desktop-rejected-before-publication): a shipped selection refused for
a principal conflict is refused before publication, and strands whatever requires its
capabilities (`a refused desktop strands…: its principal class is one the host's own
image registered`, and the other loader refusals).

- `a shipped update and another shipped identity's bundle are refused symmetrically`
  (`two-slots` host): a `fixturesh` 2.0.0 update that names `fixturesk`'s principal
  class and `fixturesk`'s own bundled baseline are both `REJECTED` / `SELECTED` /
  `principal-collision`, whatever their physical origin. No image of either, or of
  the bundled `fixturesh`, ran: nothing is retried. Neither provider's field is served.
- `two shipped updates are equal slot owners, and both are refused`: the same when
  both are per-user updates.
- `an ordinary claimant of a shipped principal is refused alone`, with the bundled
  owner running and with a shipped update running: only the ordinary provider is
  `principal-collision`; the owner keeps its row and its service.
- `ordinary claimants of one principal are both refused`, the shipped owner running.
- `an ordinary claimant of a host class is refused`, the shipped owner running.
- Every scenario above except the host-class one also runs with every per-user
  path renamed, so that path order cannot be what decides the outcome.

### Diagnostic completeness: the later-failure half

Row: *Diagnostic completeness, … Later failure retains frozen identity and competing
refusal details*. **Established.** With a failing frozen update, a lower update, an
impostor (`signing-identifier-mismatch`, claims 9.0.0) and a malformed release
(`invalid-version`) installed, the failed row keeps `SELECTED`, names itself, carries
its own failure as its reason, and its diagnostic holds both the failure and the two
competing refusals with their reasons and the releases they claim. The competing
copies keep their own rows and reasons. Run for a failure the core makes
(`invalid-sdl`) and one the loader makes (`principal-collision`).

### Ordinary duplicates

Row: *Ordinary duplicate identities/prefixes, with unapproved/incompatible rivals*.
**Established at N and G.** Discovery forward and reversed, and every per-user path
renamed, give the same rows.

- **Eligible duplicates are all refused.** Two copies of `fixtureod` (same identifier and
  prefix), three copies, two that share only a prefix (`fixtureod` and `fixtureother`),
  and two that share only an identifier: every one is `REJECTED` / `NOT_SELECTED` /
  `manifest-collision`, its diagnostic names the other and says both are refused, and
  **no image of any of them ran** (no marker). The bundled baseline beside them runs.
  A third, unrelated provider (`unknown`) still runs: the collision does not spread.
- **A refused rival never evicts a valid provider.** Beside a valid `fixtureod`, a rival
  that claims its whole identity but is incompatible (a framework minor this host lacks:
  `INCOMPATIBLE` / `framework-incompatible`), signed ad hoc (`signature-refused`) or
  altered after it was sealed (`signature-refused`), and one that claims only its prefix and
  is unapproved (`not-approved`), is `NOT_SELECTED` for its own reason and never contests:
  the valid provider stays `ACTIVE` / `SELECTED`, runs all three markers and answers. The
  rival wrote no marker.
- **Refusal beside collision.** Two eligible duplicates and an incompatible rival: the
  duplicates are `manifest-collision` and the rival keeps `framework-incompatible`.

An approval is by provider identifier and Team ID (`<provider>.approval.json`), so a
copy that shares a valid provider's identifier is approved exactly as it is: an
*unapproved* rival is necessarily another identifier, which is why the unapproved case
claims only the prefix. Quarantine refusal needs a quarantined download and is V's.

### Desktop rejected before publication

Row: *Desktop rejected before publication; workspace depends on desktop; third provider
on workspace*. **Established at N and G.** `fixturesh` stands for desktop, a `fixturesk`
update for workspace and `fixtureod` for the third.

- **The fixed point.** The refused desktop is an update whose refusal is made by the
  loader before `dlopen` (a principal class the host has: `principal-collision`), after
  `dlopen` (`load-failed`, `principal-class-missing`, `principal-class-invalid`,
  `descriptor-mismatch`) or by the core before publication (`invalid-sdl`,
  `missing-prefix`): eight scenarios, each in both discovery orders. In each, the
  workspace stand-in is `REJECTED` / `SELECTED` / `missing-capability-owner` with a
  diagnostic naming `fixturesh` as "not an admitted provider", and then, in the second
  round, the third is the same naming `fixturesk`. Each selected row names itself; the
  desktop's and workspace's bundled baselines are `superseded-candidate` and **never
  ran**, which is also the answer to "no retry". The removed providers' images ran their
  initializer and factory (the loader admitted them) and never started.
- **Exact absent/rejected profile.** For the core-refused case,
  [`selection-cascade-extension-host.json`](../design/profiles/selection-cascade-extension-host.json)
  pins the five rows exactly (releases, schemas, `REJECTED`, origin, selection, reason), over
  the design SDL [`core-schema-extension-host.graphql`](../design/core-schema-extension-host.graphql): the
  served schema, its digest and the candidate rows, read as a client reads them, are
  `CONFORMANT`. A design control (another host's design, with a provider in it; this
  design with a nullability marker removed) and four pin controls (a reason that is not
  served, a selection that is not served, a row left out, a provider that is not served)
  were each seen red, each naming its cause, in every run. Swift tests hold the design file to
  `desktop-schema-extension-host.graphql` less exactly the desktop coordinates, the served
  core alone to the design file, and the profile to its rows.
- **Capabilities and management.** No capability of `fixturesh`, `fixturesk` or `fixtureod`
  is in `availableCapabilities` (the same six names are all listed in the healthy
  control), none of the three providers' Query fields or the dependants' actions is
  published, and `koine` and `koineManagement` are served and answer: management is usable.
- **A valid cycle survives.** `fixturesh` and `fixturesk` updates that each require the
  other's capability, and the third on the cycle, are all `ACTIVE`, ran every marker and
  publish their fields and their `…RenameItemChecked` actions: a name is not a call. A
  chain with its owner present (`fixturesh` bundled) loads the same way.

### Desktop published but start fails

Row: *Desktop published but start fails*. **Established at N and G.** A `fixturesh` 2.0.0
update, a lower update (1.5.0) and the bundled baseline, with the workspace stand-in and
the third installed:

- The update is `FAILED` / `SELECTED` / `start-failed` ("The provider failed to start:
  built to fail its start"); it ran all three markers, the last immediately before it threw.
- **Schema retained.** `fixtureShInfo` is still a published Query field; resolving it
  returns the execution error `The fixturesh provider is not running.` with
  `extensions.kind = unavailable` and null data: its fields are unavailable.
- **Authority retained.** `fixturesh:read` and `fixturesh:control` are still available.
- **Nothing is removed for it.** The workspace stand-in and the third are `ACTIVE`, ran, and
  publish their fields and actions; the workspace's Query field answers.
- **No retry.** The lower update and the bundled baseline are `superseded-candidate` and
  wrote no marker. Without dependants the result is the same: the bundled baseline is
  not started in its place.

## Controls

Every install that wrote nothing, or did not reach every phase, needs a run that shows
its compiled binary (or its twin) writing them. Eight control scenarios supply them:
the baseline, a healthy update, a healthy update with a loadable private dependency,
two baselines, a second slot's update, two ordinary providers, a dependant and its
dependant whose owners are present, and the valid cycle. The start-failing update is its
own control: it wrote every marker. `failures.json` lists which run supplied each in
`controls`; eleven compiled binaries are controlled.

## Instruments seen red

`task selection:mutation` breaks one decision at a time in a copy of the tree (as
[selection-decisions.md](selection-decisions.md#instruments-seen-red) describes) and
runs the named scenarios of this driver. Each of the twelve below was seen red in every
host run of each scenario named:

| Broken decision | Scenario | Red runs |
|---|---|---|
| Two shipped selections not both refused on a principal conflict | `a shipped update and another shipped identity's bundle…`, `two shipped updates are equal slot owners…` | 3 of 3, 3 of 3 |
| An ordinary claimant of a principal not refused | `an ordinary claimant of a shipped principal is refused alone, the bundled owner running`, `ordinary claimants of one principal…` | 3 of 3, 3 of 3 |
| A principal class of the host's own not counted as a conflict | `its principal class is one the host's own image registered`, `…a system class`, `an ordinary claimant of a host class…` | 2 of 2 each |
| The descriptor's features not compared with the manifest's | `its descriptor disagrees with its manifest` | 2 of 2 |
| Every eligible candidate loaded, after a frozen update fails | `dlopen refuses its private dependency`, `…the host's own image registered` | 2 of 2 each |
| A rival that a pre-load check refused contesting an ordinary identity | `a refused rival never evicts…` (incompatible, ad hoc, unapproved prefix) | 3 of 3 each |
| Eligible ordinary duplicates not refused | `two eligible copies…`, `two eligible providers that share only a prefix…` | 3 of 3 each |
| The capability-owner removal never run | `the third on that: its SDL does not parse`, `…the host's own image registered` | 2 of 2 each |
| The removal run for one round only | the same two | 2 of 2 each |
| A cycle given no owner (a dependant counted as an owner only when it has none) | `control: a valid dependency cycle…`, `control: a dependant whose capability owner is present…` | 2 of 2 each |
| A provider that failed its start still answering | both start-failure scenarios | 2 of 2 each |
| Every eligible candidate loaded, after a shipped provider fails its start | both start-failure scenarios | 2 of 2 each |

## Run record

2026-10-01, macOS 26.6.2 (25G83), arm64, debug build, Developer ID signed (hardened
runtime, not notarized). `task selection:failures`: **44 scenarios, 100 host runs**,
**0 failed, 0 without a control, 0 owned reasons unseen** (sixteen stable reasons observed,
including `manifest-collision`, `missing-capability-owner`, `start-failed`,
`not-approved`, `framework-incompatible` and `signature-refused`). `task
selection:mutation`: the twelve mutations above seen. `swift test` over the conformance
suites: 26 tests pass, including the new design and profile tests. `task check:docs` passes.

## Observations

- A path under `/usr/lib` is a *system path* to the loader's own dependency check,
  which does not look for the file. So a private dependency that links a missing
  `/usr/lib/…` library is not refused before load: it is `dlopen`'s refusal
  (`load-failed`, dyld's "Library not loaded" in the diagnostic), and none of the
  bundle's initializers ran. That is what makes it a `dlopen` failure that the
  same binary, with a loadable dependency, can be shown to survive.
- `objc_lookUpClass` finds a class the host's executable declares with `@objc(name)`
  as well as a system class, so the loader's "free in the host as it already is"
  holds for both.
- A principal class that is missing or is no factory is not a pre-load refusal: the
  image loads (its initializer writes its marker) and the loader then refuses it.
  Only a collision is known before `dlopen`.
- A failed frozen selection is `REJECTED` and keeps `selection` `SELECTED` whether the
  loader (`principal-collision`, `load-failed`, `principal-class-*`,
  `descriptor-mismatch`) or the core (`invalid-sdl`, `missing-prefix`) refused it, and
  its diagnostic carries both its own failure and the competing refusals.

- **An ordinary provider beside a refused rival shows no trace of it.** The valid
  `fixtureod` row is `ACTIVE` / `SELECTED` with a null reason and diagnostic; the
  rival's own row carries its reason and points at the valid copy as its
  `selectedCandidateId`. The spec's "healthy choice with any same-identity refused
  candidate uses `selected-with-refusals`" is written for release selection, where the
  calculation does set it; the ordinary path (`ProviderSelection.plan`) does not. The
  Machine row asks only that the rival cannot evict, so this is recorded, not asserted.
- The removal for a missing capability owner admits the provider's image first, so a
  provider that is later removed has run its initializer and factory. It never starts.
- `FIXTURE_ADDITIONAL` fixtures need framework minor 1 (`additional-capabilities-v1`) in
  both manifest and descriptor, or the loader refuses the disagreement before the core
  ever sees the requirement.

## Not established here

- The digest and restart rows: `digest-restart`.
- Notarized hosts, quarantined downloads and every V row: `selection-vm`.
- No claim that the loader is a sandbox. The absence of a marker is the observation.
