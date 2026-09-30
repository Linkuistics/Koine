# First-party selection: the pre-load decision rows

The decision rows of "Selection acceptance" in
[the Machine spec](../specs/machine.md#selection-acceptance), at the two seams that
node assigns them: **N**, the native loader with real independently built binaries in
a fresh signed host process, and **G**, public GraphQL management over loopback
HTTP. It also builds the signed-host harness the other selection-acceptance leaves
(`selection-failures`, `selection-updates`, `selection-vm`) reuse.

The in-process suite `ProviderSelectionTests` holds these decisions while the
loader is written. It cannot show what a fresh process shows: that an image the
loader refused never ran, or that the reported rows are what a client reads.

## Procedure

```sh
task selection:decisions    # fixtures, hosts, then every scenario; .build/selection-acceptance/decisions.json
task selection:mutation     # each instrument seen RED against a loader with one decision broken
task selection:fixtures     # only the provider bundles
task selection:hosts        # only the signed hosts (name some after `--` to build just those)
```

It needs the signing identity of `scripts/signing-env.sh`, `rsync` and `python3`.
Nothing launches `Koine.app` or touches `~/Library/Application Support/Koine`: each
run is a headless host over a temporary data directory. It is a debug build,
signed with the Developer ID identity and the hardened runtime, and **not
notarized**; the V seam and its notarized hosts are `selection-vm`'s.

## The harness

| Piece | Where | Task |
|---|---|---|
| Provider bundles: an old designated baseline and an independently compiled update per shipped slot, ordinary providers, claimants, a provider whose identifier really is `unknown`; every one sealed under its own signing identifier, none approved | `Fixtures/FixtureProvider/build-decisions.sh` | `selection:fixtures` |
| Markers: each image appends `initializer`, `factory` and `start` with its own path to `KOINE_FIXTURE_MARKER_LOG`, from its own code | `Fixtures/FixtureProvider/initializer.c`, `FixtureProvider.swift` | (built with the bundles) |
| The host: a real application bundle in everything selection reads. Catalogue from `Contents/Resources`, in-application root `Contents/PlugIns`, approval Team ID from its own verified signature; it reads no environment itself (the images it loads read the marker log's path) | `Fixtures/SelectionHost/main.swift` (`KoineSelectionHost`) | (`swift build`) |
| Purpose-built signed hosts: each names its catalogue and bundles in `Fixtures/SelectionHost/hosts.json`, which are put in **before** the framework and the application are signed. No seal is altered afterwards and no notarized application is touched | `scripts/build-selection-hosts.py` | `selection:hosts` |
| The driver: a fresh host process, data directory, per-user root and marker log for every scenario and for each alternative order within it | `scripts/verify-selection-decisions.py` | `selection:decisions` |
| The mutation check | `scripts/check-selection-mutations.py` | `selection:mutation` |

The hosts, as `hosts.json` states them: `slot` (one enabled slot and a
reserved-only identity), `two-slots` (`fixturesk` listed before `fixturesh`, so
identifier order and catalogue order differ, plus the reserved-only one), the
missing, mismatched, wrongly signed, ad-hoc-signed and framework-incompatible
designated bundle, an unexpected in-application bundle, four defective
catalogues, and an ad-hoc-signed host. Fixture signing identifiers
(`dev.antony.Koine.provider.fixturesh`, `…fixturesk`) differ from every production
one; `build-selection-hosts.py` stops if a test catalogue names a production
identifier, prefix or signing identifier, and only those catalogues admit the
fixtures. Every host is a Developer ID signature except `adhoc-host`, signed ad
hoc: an unsigned arm64 executable does not run, so "unsigned or ad-hoc" is one
case.

**Private seam.** The one substitution is the discovery order within a root,
reversed for the alternative run. The verifier, staging, approval check and
loader are the shipped ones. The assessment verdict is fixed by construction:
nothing installed is quarantined, and every run checks the data directory for a
`com.apple.quarantine` attribute.

## What a scenario asserts

Each host run reads `koineManagement.providers` with the host's own grant and
checks:

1. **Rows.** The multiset of `(provider, version, origin, state, selection,
   reason)` equals the rows the spec requires, with named substrings of the
   diagnostic where the spec requires the refused version or cause to be visible.
2. **Report invariants**, whatever the scenario: rows sort by provider, origin and
   candidate identifier with synthetic rows last for their provider; candidate
   identifiers are unique; a synthetic row has no candidate identifier or origin
   and is `UNAVAILABLE`; at most one row per provider is `SELECTED`, it names
   itself, and every row of the provider points to it (or to nothing); only a
   `SELECTED` row is `ACTIVE`.
3. **Markers.** Exactly the installs a scenario names reached the phases it names,
   and every other image wrote nothing. The staged copy's directory names the
   install, so a marker is attributed without trusting the image.
4. **Service.** Where a scenario names a served field, the selected binary
   answers it, and its greeting says which release ran. Where a scenario says no
   provider is published, introspection does not list the field.
5. **Team.** A Developer ID host reports a verified Team ID, the ad-hoc host none.
6. The host stops cleanly when standard input ends.

**Controls.** A refused-marker assertion is paired with a control: for every
install that wrote nothing, the run fails unless the same compiled binary
wrote all three markers in another scenario of the same run. The control is the
binary, not the bundle: the compiled dylib is the same across a bundle's manifest
edits and re-signing. The runs that supplied them are in `decisions.json` under
`controls`. Every stable reason the leaf owns must also appear in some run.

**Order.** Every scenario runs twice, discovery forward and reversed. The
scenarios that contest a tie run a third time with every per-user path renamed so
their sort order flips.

## Evidence by row

Machine's table links each row here. A scenario name is a substring of the name
in `scenarios()`; each runs at least twice (forward and reversed).

### Version rows

Row: *Releases 1.9.0 and 1.10.0; malformed triple; equal/older baseline;
schema-major mismatch/regression*. **Established at N and G.**

- `1.10.0 exceeds 1.9.0 numerically, not as text`: the numeric winner, both
  others `superseded-candidate`, and only the winner's markers.
- `a malformed triple…`, `a leading zero…`: `REJECTED` / `invalid-version`; the
  bundle stays selected and is `selected-with-refusals`.
- `equal and older copies never override the bundle`: `equal-to-bundled`,
  `older-than-bundled`.
- `a schema major the slot cannot take…`, `a schema regression within the major…`:
  `INCOMPATIBLE` / `schema-incompatible`.
- `a higher release that is ineligible falls back visibly…` (to the next release,
  and to the bundle): `framework-incompatible`, `selection-feature-required`,
  `signing-identifier-mismatch` on the refused copies, and the selected row's
  diagnostic names the refused release it passed over.
- The discovery-reversed run of every one of these gives the same rows and markers.

### Tie rows

Row: *Greatest tie, successive tied groups, lower duplicates, canonical-directory
alias*. **Established at N and G.**

- `a tied greatest group…`, `a tie falls back to the verified bundle`,
  `successive tied groups…` (with and without a unique release left), `a tie with no
  lower update and no bundle…` (a `missing-bundled` synthetic row and nothing runs):
  every tied copy is `ambiguous-update` and wrote no marker; the choice is the
  unique lower update or the bundle.
- `lower duplicates do not contest a unique higher winner`.
- `a canonical-directory alias is one candidate, not a tie` (one row for the
  alias's target), and `distinct canonical directories of equal bytes are a tie`.
- Renamed-path runs and reversed-discovery runs give the same outcomes.

### Reserved claimants

Row: *Reserved identity/prefix/SDL claimant; owner absent/rejected or
reserved-only*. **Established at N and G.**

- Before load: four claimants (another prefix under the slot's identifier, another
  identifier under its prefix, an overlapping identifier and prefix, a shorter
  prefix), each with the owner present, absent (`slot-no-bundle`) and rejected
  (`slot-bundle-other-identifier`): `reserved-identity`, alone, no marker, the
  owner's row unchanged and never evicted.
- The exact pair of a reserved-only identity is `reserved-only`, and an
  overlapping claim on it is `reserved-identity`; neither enables the slot or
  loads, whatever else is missing.
- After load: an ordinary provider whose SDL claims a shipped slot's names or a
  reserved-only identity's, and one whose runtime descriptor names the slot's
  identity under another manifest. Each runs its initializer and factory (the
  loader has to load the image to learn this), never starts, and is refused alone
  as `reserved-identity` or `descriptor-mismatch`, with the owner present, absent
  or rejected.

### Designated bundle

Row: *Missing/refused/mismatched designated bundle, valid newer update,
unexpected in-app claimant*. **Established at N and G.**

- Missing, release-mismatched (`catalogue-bundle-mismatch`), signed under another
  identifier (`signing-identifier-mismatch`), signed ad hoc (`signature-refused`)
  and framework-incompatible (`INCOMPATIBLE`) designated bundles, each in a host
  sealed that way. A refused bundle leaves a `no-eligible-candidate` synthetic
  row; a missing one leaves `missing-bundled`.
- A valid newer update fills the slot in each of those five hosts. The missing
  bundle's synthetic row persists while the update is `ACTIVE`, and its selection
  pointer names the update.
- Equal and older copies fill neither a missing nor a refused bundle.
- An unexpected in-application bundle claiming the reserved pair at release 9.0.0
  and an unexpected ordinary provider are `unexpected-bundled-candidate`, never
  substituted, never loaded, and do not stop a valid update filling the slot.
- The catalogue's floor and reservations hold in each host: the claimant scenarios
  above run against the missing and refused hosts too.

### Catalogue and host team

Row: *Malformed/conflicting sealed catalogue; unsigned/ad-hoc host;
differently team-signed host*. **Established at N and G, except the
alternate-team host, pending.**

- Four defective catalogues (an unknown key, two entries overlapping, a partial
  baseline, a truncated file): one synthetic `(unknown)` row, `catalogue-invalid`,
  `REJECTED` / `UNAVAILABLE`; no fixture ran, neither the bundled baseline nor an
  installed update nor an ordinary provider, and their fields are not in the
  served schema. Core management still answered.
- The ad-hoc host reports no verified Team ID; the baseline and the update are
  `host-team-unavailable`, the slot has a `no-eligible-candidate` row, and an
  ordinary provider still loads.
- `identifier order, not catalogue order…`: with `fixturesk` listed first,
  `fixturesh` loads and starts first.
- **Pending: the alternate-team host.** A differently team-signed host derives its
  own Team ID; that needs a second real Developer ID team's certificate. Only one
  is in this keychain, the team that signs every fixture, and no mock closes it.
  Owned by `alternate-team-signing`, which confirms it if the certificate exists
  when it runs.

### Diagnostic completeness

Row: *Diagnostic completeness, including a real provider named `unknown` and an
unidentified bundle*. **Established for the decision rows;** the later-failure
half (a frozen choice retaining its identity and competing refusals after a
failure) is `selection-failures`'.

- `the report is complete…`: thirteen rows from one installation, one for each
  candidate and no synthetic row for a slot that has a choice, with every enum and
  every selection pointer.
- `a real provider named unknown is distinct…`: a real `unknown` is `ACTIVE`
  beside the unidentified bundle's `(unknown)` / `manifest-invalid`.
- Every owned stable reason is produced by some run: `ambiguous-update`,
  `catalogue-bundle-mismatch`, `catalogue-invalid`, `descriptor-mismatch`,
  `equal-to-bundled`, `framework-incompatible`, `host-team-unavailable`,
  `invalid-version`, `manifest-invalid`, `missing-bundled`, `no-eligible-candidate`,
  `older-than-bundled`, `reserved-identity`, `reserved-only`,
  `schema-incompatible`, `selected-with-refusals`, `selection-feature-required`,
  `signature-refused`, `signing-identifier-mismatch`, `superseded-candidate`,
  `unexpected-bundled-candidate`.

## Instruments seen red

`task selection:mutation` breaks one decision at a time in a copy of the tree
(`.build/selection-mutations`, its own build directory; the working tree is never
edited), assembles the purpose-built hosts around that copy's headless host and
runs the named scenarios. Each of the seven below was seen red in every host run of
each scenario named:

| Broken decision | Scenario | Red runs |
|---|---|---|
| Version compared as text | `1.10.0 exceeds 1.9.0…` | 2 of 2 |
| A tie broken by the first copy | `a tied greatest group…` | 3 of 3 |
| The signing-identifier check removed | `…falls back visibly to the bundle` | 2 of 2 |
| Reserved-name claims not refused | `claims-overlapping-prefix: … owner present` | 2 of 2 |
| An equal release takes over | `equal and older copies never override the bundle` | 2 of 2 |
| Every eligible candidate loaded | `a tie falls back…`, `1.10.0 exceeds 1.9.0…` | 3 of 3, 2 of 2 |
| A host with no Team ID given one | `an ad-hoc host admits no shipped candidate…` | 2 of 2 |

The marker check is seen red where the tie-breaking mutation runs the first copy
instead of the lower update (the log names `first`, the scenario names `lower`), and
where the load mutation makes the bundle and the tied copies collide so that the
bundle wrote nothing.

## Run record

2026-10-01, macOS 26.6.2 (25G83), arm64, debug build, Developer ID signed
(hardened runtime, not notarized). `task selection:decisions`: **64 scenarios, 134
host runs** (64 forward, 64 reversed, 6 renamed), **0 failed, 0 without a control,
0 owned reasons unseen**. `task selection:mutation`: every mutation seen. `task
test` still passes (285 tests in the server suite among the others).

## Observations

- The loader has to load an image to learn that a descriptor claims names the
  manifest does not, so a post-load claimant's initializer and factory markers are
  written before the core refuses it, and no start marker follows. That is the
  spec's "a selected image can run initializers before descriptor/schema refusal",
  observed rather than assumed.
- A refused copy that claims the slot's own identifier (another prefix under
  `fixturesh`, an unexpected bundle claiming the reserved pair) makes the healthy
  choice `selected-with-refusals`; a claimant under another identifier does not.
  The spec's wording is "any same-identity refused candidate"; the scenarios hold
  that reading.
- An in-application bundle signed ad hoc inside a Developer ID application is
  refused as `signature-refused`, not as an approval or identifier mismatch.
- The staged copy's directory name carries the install's name and a digest, which
  is how a marker is attributed to an install. The driver reads only the name, so
  two bundles of one name in different roots are not told apart by it; no decision
  row installs two, and a leaf that does (equal bytes and basename in both roots)
  has to attribute by the digest.

## Not established here

- The alternate-team host (above).
- Notarized hosts and quarantined downloads, and every V row: `selection-vm`.
- Update-side trust refusals, staging, mixed releases, and a frozen choice failing
  later: `selection-updates`, `selection-failures`.
- No claim that the loader is a sandbox. A refused image's absence from the marker
  log is the observation; native code the loader loaded stays trusted.
