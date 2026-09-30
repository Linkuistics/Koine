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
diagnostic completeness. Ordinary duplicates, the capability-owner cascade and a
start failure are `duplicates-cascade`'s; the digest and restart rows are
`digest-restart`'s. Each adds its own section here.

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
G**, except that the diagnostics' agreement with the capability-owner cascade is
`duplicates-cascade`'s, which is where a fixture first names another provider as an
additional-capability owner.

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

## Controls

Every install that wrote nothing, or did not reach every phase, needs a run that shows
its compiled binary (or its twin) writing them. Six control scenarios supply them:
the baseline, a healthy update, a healthy update with a loadable private dependency,
two baselines, a second slot's update, and two ordinary providers. `failures.json`
lists which run supplied each in `controls`.

## Instruments seen red

`task selection:mutation` breaks one decision at a time in a copy of the tree (as
[selection-decisions.md](selection-decisions.md#instruments-seen-red) describes) and
runs the named scenarios of this driver. Each of the five below was seen red in every
host run of each scenario named:

| Broken decision | Scenario | Red runs |
|---|---|---|
| Two shipped selections not both refused on a principal conflict | `a shipped update and another shipped identity's bundle…`, `two shipped updates are equal slot owners…` | 3 of 3, 3 of 3 |
| An ordinary claimant of a principal not refused | `an ordinary claimant of a shipped principal is refused alone, the bundled owner running`, `ordinary claimants of one principal…` | 3 of 3, 3 of 3 |
| A principal class of the host's own not counted as a conflict | `its principal class is one the host's own image registered`, `…a system class`, `an ordinary claimant of a host class…` | 2 of 2 each |
| The descriptor's features not compared with the manifest's | `its descriptor disagrees with its manifest` | 2 of 2 |
| Every eligible candidate loaded, after a frozen update fails | `dlopen refuses its private dependency`, `…the host's own image registered` | 2 of 2 each |

## Run record

2026-10-01, macOS 26.6.2 (25G83), arm64, debug build, Developer ID signed (hardened
runtime, not notarized). `task selection:failures`: **22 scenarios, 49 host runs**,
**0 failed, 0 without a control, 0 owned reasons unseen**, on a tree in which
`task selection:decisions` still gives **134 host runs, 0 failed, 0 without a
control** after its driver was moved onto the shared library (its per-run checks,
markers and never-ran assertions match the run before the move). `task
selection:mutation`: the five mutations above seen. `task check:docs` passes.

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

## Not established here

- Ordinary duplicates, the cascade, a start failure: `duplicates-cascade`.
- The digest and restart rows: `digest-restart`.
- Notarized hosts, quarantined downloads and every V row: `selection-vm`.
- No claim that the loader is a sandbox. The absence of a marker is the observation.
