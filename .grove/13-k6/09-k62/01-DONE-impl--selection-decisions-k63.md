# selection-decisions-k63

## Goal

Accept the selection decision table at N and G, and build the signed-host
harness the rest of this node reuses.

## Context

- `docs/specs/machine.md`, "Selection acceptance": the rows this node's brief
  assigns here.
- The private candidate-substitution seam from `provider-selection-k57`.

## Done when

- A reusable harness exists. It runs a fresh signed headless host subprocess
  per scenario and order, with a fresh marker log. Purpose-built signed test
  hosts are built with test catalogues before signing, including later enabled
  identities so identifier order can be told apart from catalogue order. Fixture
  providers carry distinct fixture signing identifiers. Each piece is a Taskfile
  recipe.
- N and G evidence covers the version rows:
  - 1.9.0 against 1.10.0;
  - a malformed triple;
  - equal and older copies;
  - schema-major mismatch and schema regression;
  - visible fallback when a higher release is ineligible;
  - the same outcome with discovery order reversed and verdicts fixed.
- It covers the tie rows: a tied greatest group, successive tied groups, lower
  duplicates and canonical-directory aliases. Tied candidates never load, and
  renaming paths does not change an outcome.
- It covers reserved identity, prefix and SDL claimants, before load and after.
  The owner may be absent, rejected or reserved-only. A claimant is refused
  alone, never evicting the owner or enabling a reserved-only slot.
- Purpose-built signed hosts cover the designated-bundle rows: a missing,
  refused or mismatched bundle; a valid newer update; and an unexpected in-app
  claimant. The catalogue floor and reservations hold. The missing-bundle
  synthetic row persists while an update is active.
- It covers the catalogue rows: a malformed or conflicting catalogue runs no
  provider and reports `catalogue-invalid`. An unsigned or ad-hoc host reports
  `host-team-unavailable`. The alternate-team host's N and G parts pass only if
  a real second team is available; otherwise they stay pending for
  `alternate-team-signing`.
- Diagnostic completeness is asserted: every candidate and synthetic row, enum,
  selection pointer and stable reason. A real provider named `unknown` stays
  distinct from `(unknown)`.
- Machine's table links the evidence for these rows.

## Decisions (running log)

**The host is a real application bundle, not the compatibility host with a seam.** `Fixtures/SelectionHost` (`KoineSelectionHost`) reads `Contents/Resources/ProviderCatalogue.json` and `Contents/PlugIns` as `AppDelegate` does, and its Team ID is its own verified signature. `scripts/build-selection-hosts.py` puts each host's catalogue and bundles in *before* signing (`Fixtures/SelectionHost/hosts.json` is the declaration), so a defective catalogue is content that was wrong when the seal was made. The one private seam left is the discovery order. `KoineCompatibilityHost` stays as it is: it stands in for a team and a catalogue, which is what this leaf must not do.

**Real loads need their own bundle family (`Sh`, `Sk`, `Od`, `Unknown`).** `build-selection.sh`'s `Sl` bundles are one binary with edited manifests and are never loaded, so an update's manifest declares a feature its descriptor does not, and a real load would end as `descriptor-mismatch`. `build-decisions.sh` compiles a baseline and an update per shipped slot (the update with `FIXTURE_SELECTION`) so any release can really load. `build.sh` gained `FIXTURE_STEM` (a provider truly named `unknown`) and `FIXTURE_EXTRA_SDL` (a descriptor claiming names the manifest does not); `FixtureProvider.swift` gained `FIXTURE_DESCRIBES_SLOT`.

**Markers come from the images, keyed by staged directory.** `initializer.c` writes `<phase>\t<image path>` to `KOINE_FIXTURE_MARKER_LOG` at the initializer, and the factory and `start()` call the same hidden function. The symbol is `koine_image_marker`: the build tags every `fixture` occurrence, and the first name, `koine_fixture_marker`, was renamed to an undefined symbol. The staged copy's directory name (`<install name>-<digest>`) attributes a line to an install.

**A refused-marker assertion is paired with a control by compiled binary.** For each install that wrote nothing, the run fails unless the same compiled binary wrote all three markers in another scenario of the same run. A subset run (`--only`) therefore cannot close it.

**Same-identifier refused copies make the healthy choice `selected-with-refusals`.** My first expectations for the claimants that use the slot's identifier (another prefix) and for the unexpected in-application bundle had a plain healthy row; the spec's "any same-identity refused candidate" is what the loader does, so the expectation was wrong, not the loader.

**Instruments seen red in a copy of the tree, never the working tree.** `task selection:mutation` breaks seven decisions one at a time in `.build/selection-mutations/tree` (the framework stager prunes that directory as it prunes `.build/compat`). Every named scenario went red in every run.

**Not closed here.** The alternate-team host: this keychain has one Developer ID team, the one that signs every fixture. Recorded pending in the driver's output, `docs/verification/selection-decisions.md` and Machine's table, for `alternate-team-signing`. A truly unsigned arm64 executable does not run, so "unsigned or ad-hoc" is the one ad-hoc host.
