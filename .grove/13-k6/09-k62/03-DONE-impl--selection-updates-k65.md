# selection-updates-k65

## Goal

Accept independent updates across binary generations at N and G: real,
independently built old and new hosts and providers, the trust refusals that
fall back visibly, candidate-specific staging, and mixed releases.

## Context

- `docs/specs/machine.md`: the rows this node's brief assigns here.
- The reusable pre-extension host build from `additional-capabilities-k56`.

## Done when

- Old host with old desktop, and new host with an independently compiled old
  designated baseline: existing desktop operations, errors and grants work, and
  both core + desktop profiles pass.
- A selection-aware host with a separately approved newer desktop update, and
  one with a newer workspace update: exactly one image, factory and start marker
  per slot. The unselected bundle never loads. Management names the update, and
  real operations work without rebuilding the host.
- A pre-extension host is given newly published updates with normal and with
  renamed principals. It refuses `first-party-selection-v1` as `INCOMPATIBLE`
  before load, with no update marker, and bundled desktop stays usable. The
  extension host refuses a per-user update lacking the feature as
  `selection-feature-required`.
- Each trust refusal has no initializer marker and falls back to a visibly
  diagnosed lower or bundled selection:
  - missing approval or wrong Team ID;
  - unsigned, ad-hoc or tampered seal;
  - escaping location;
  - incompatible framework, feature, OS or architecture;
  - failed quarantine assessment.
  Stage and quarantine recovery is exercised. Real second-team signing passes
  only if a second team's certificate is available; otherwise its N and G parts
  stay pending for `alternate-team-signing`.
- An approved same-team fixture claims a reserved pair and a high release under
  a fixture signing identifier. The production catalogue refuses it as
  `signing-identifier-mismatch`, and the valid release stays selected. A test
  catalogue admits it. A correctly identified compatible release needs no new
  hash approval.
- Equal bytes and basenames in both roots stay candidate-specific when staged in
  both orders, including across restarts after the host catches up to an update.
  Bundled loading never inherits per-user quarantine. A legacy shared staging
  entry is never reused.
- Mixed desktop and workspace releases built from reused helper source have a
  disjoint private-image module and runtime-class inventory across identities
  and the host, except the single host framework. Each executes its own expected
  implementation.
- Conformance adds the selected-update profiles.
- Machine's table links the N and G evidence for these rows.

## Decisions (running log)

**The subject is generations, real where the claim is about a real binary.** The old side is the released revision's own host and desktop provider (`task compat:baseline`, unchanged), the new side this tree's; updates of the *real* desktop and workspace are compiled from a **copy** of `Providers/` with two checked substitutions (the descriptor's `requiredFeatures`, and for the renamed variant the `@objc` principal name), so no product source changed and no build flag was added to it (`scripts/build-selection-real.sh`). Fixtures stay where a defect has to be made on purpose (the trust refusals, the impostors), standing in for desktop (`fixturesh`) and workspace (`fixturesk`) as in `selection-decisions`.

**A real provider writes no marker, so it is seen by its image being mapped.** Both headless hosts now report every non-system image with the runtime classes it defines; a real install is loaded if its staged image is mapped and its row is `ACTIVE`, and a refusal of it is paired with a control of the same compiled binary exactly as a marker refusal is. A phase that states `images=` asserts the mapped set; one that does not asserts nothing of a real install's.

**Three hosts carry real bundles; the generator's guard is relaxed only as far as it has to be.** `production` (the shipped catalogue whole, around this tree's providers), `desktop-old` (the shipped catalogue with workspace reserved-only, around the released desktop as the designated baseline), and `impostor-host` (the shipped identifiers and prefixes under fixture signing identifiers). `production` hosts may hold only `current-*` / `released-*` bundles; `productionNames` hosts may use the shipped names but never a production *signing* identifier. The negative impostor and the positive control are the same compiled binary (`desktop-impostor`), which is what makes the refusal a finding.

**An approval record is per provider, so "missing approval" and "wrong Team ID" have no lower-update fall-back.** My first expectation had one; the run showed the lower update's record approving the bad bundle (missing case) or refusing both (wrong-Team case). Those two cases are run as "refuses every per-user copy of the provider; the bundle keeps the slot", which is the observation. A *signed* second team stays pending.

**Staged names are predicted, not guessed.** `staged_name` reproduces `ProviderStaging` (origin, canonical location, content digest), validated by the markers of every scenario that depends on it; two bundles of one name in both roots are labelled `@bundled` / `@user`. A per-user copy of the bundled bytes is staged and assessed *before* it is judged equal, so its row is `quarantine-refused` under a refusing verdict and `equal-to-bundled` only under an accepting one; the test asserts both, across a restart, in both staging orders.

**The legacy scheme is tested by planting its entries.** An entry of the content-only scheme is planted holding the *baseline's* bytes under the name the update's bytes would have had, and another holding quarantined bytes of the bundled copy; the loader must stage candidate-specific copies, leave the planted entry untouched and map nothing from it.

**The module inventory counts what an image defines, not what it mentions.** `nm -U` on an optimised image lists thunks for Foundation types, so modules are read from nominal type and protocol descriptors (`…Mn`, `…Mp`), which an optimised build keeps; the result is exactly `DesktopProvider` / `WorkspaceProvider` against the host's twenty-one. `ProcessStart` (the reused helper) is a nominal type in both images under each one's own module.

**Six profiles are added, each held with its controls.** Four selected-update profiles (desktop only over the released baseline; the two mixed releases; both updated), one explicit rejected profile (updates lacking the feature), and one for the released host refusing a newly published update (`management: baseline`). The controls' "wrong design" is chosen to differ from the profile's own (the desktop-only profile would otherwise be held red against itself).

**A harness defect, found by looking at the temp directory:** `HostRun.stop` could not remove a run's directory, because staged copies are read-only. 1 688 + 979 directories (1.6 GB) had accumulated; the stale ones were removed and the directories are made writable first. `task selection:hosts`'s script also ignores a driver's `--only` now, since `task` hands CLI_ARGS to every recipe in a run.

**Instruments seen red.** Ten loader mutations (`task selection:mutation`, each in a copy of the tree) and the driver's own `instruments` record (digest, staged name, inventory, desktop expectations, differential) each go red against a subject known to be wrong.

**Not closed here.** A bundle *signed* by a second real Developer ID team, and the alternate-team host: this keychain has one Developer ID team. Recorded pending in the driver's output, `docs/verification/selection-updates.md` and Machine's table, for `alternate-team-signing`. V: `selection-vm`.

**One in-session reviewer spent** (fresh context, read-only, adversarial): no outright bug; eleven hollow or unbacked points, of which start order, collision-label controls, baseline pin controls, the differential, the Finder requirement, the escape staging assertion, approval inode/time, an inventory non-empty guard, architecture portability and control crediting were repaired; accepted as stated in the evidence document: real updates differ from baselines by release and image, not behaviour; `…-no-feature` real bundles keep the production identifier because the feature is checked first.
