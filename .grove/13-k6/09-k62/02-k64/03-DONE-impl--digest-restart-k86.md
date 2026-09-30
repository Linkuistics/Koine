# digest-restart-k86

## Goal

Accept the schema-digest rows and the restart rows of the failure boundary at N
and G.

## Context

- The node brief `selection-failures-k64`: its "Digest" and "Restart"
  conditions, and Machine's rows "Same SDL across roots, changed SDL in newer
  copy, extra ordinary provider" and "Restart after update removal or changed
  baseline; changed assessment verdict; unreadable root".
- The harness library and restart machinery `freeze-failures-k84` leaves in
  `scripts/`, and `docs/verification/selection-failures.md`.
- The private `ProviderLoader.Seam.assessment` seam, for the injected verdict.

## Done when

The node brief's "Digest" and "Restart" conditions hold, Machine's two rows link
the evidence, and the node's "Machine's table links the evidence" condition is
met for every row this node owns.

## Decisions (running log)

**The digest is held to an absolute reference, not only to itself.** Equal digests across roots prove a replacement preserves the digest, but a composition wrongly ordered the same way everywhere would agree with itself. So a phase that tags a digest and asserts the start order (which is the composition order) also has the harness write out the design SDL of that order (`core-schema-extension-host.graphql` plus each bundle's `schema.graphql` in order) and hold the served introspection and digest to it with `KoineConformance --design --served-digest`, then shows the reverse order `NOT CONFORMANT`. The reference is written from an asserted order, not from the digest. `two-slots` lists `fixturesk` first, so `two-slots-sorted` (identifier order) is the control that catalogue order decides nothing.

**Tags, not constants.** A phase tags its digest; one tag is one value wherever it recurs, in a scenario and across its forward, reversed and renamed runs (`check_digests_across_runs`), and a scenario names pairs that must differ (`differs`). No digest is written into the driver, which would break whenever a fixture's SDL changed.

**Authority is read from the grants, not assumed.** Grants are durable, so an earlier phase's credential still works after a restart. Every later phase re-reads each earlier credential's `ownGrant.capabilities` and requires what it held; `clients=` names a field an earlier credential is `served`, `denied` or `unpublished` at. That is "recompute without granting authority": a provider that returns is not added to a grant that predates it.

**The verdict is injected at `ProviderLoader.Seam.assessment`, and the copy is quarantined user-approved.** `KoineSelectionHost` reads `KOINE_FIXTURE_ASSESSMENT` (`accept`/`refuse`). The first `accept` attempt quarantined with `0083;…`; the host hung in `dlopen` of a Developer ID, non-notarized image (the dialog the assessment exists to forestall) and had to be killed. `0x40` (user-approved) in the flags makes the OS ask nothing while the loader still sees the attribute, so the injected verdict is the only verdict. A phase that quarantines says so (`quarantine=`), and the old "nothing is quarantined" check holds otherwise.

**An unreadable root needed no loader change.** `contentsOfDirectory` throws on an unreadable existing root, which stops `KoineServer`; the host printed a crash, so `KoineSelectionHost` now prints `{"error": …}` and exits 1 as it does for a server that fails to start. A phase expects it with `start_fails=`, asserts no marker at all (the bundled baseline included), and gives the root back in the next phase. The baseline must be able to run in the scenario (no update installed) or the "nothing ran" claim has no control.

**Changed baseline is another signed host over the same data directory.** `slot-baseline-1.7.0` (catalogue release 1.7.0, bundle `baseline-r1.7.0`); the 1.5.0 update is then `older-than-bundled` and the baseline `selected-with-refusals`, which is the spec's rule for a refused same-identity candidate, not `superseded-candidate` as I first wrote. A phase's `host=` switches host.

**Extra SDL is an enum.** A type with a field needs a resolver (`missing-resolver`); an enum needs none. `sdl-changed` adds an enum, `sdl-changed-description` describes it otherwise.

**Instruments.** Seven mutations added to `scripts/check-selection-mutations.py`: composition without the shipped group first; composition in reverse identifier order; a digest over type names alone; every grant holding `koine:manage`; the verdict never asked; a refusal remembered across restarts (a marker beside the staged copy); an unreadable root read as empty. Each seen red for the right reason in every host run of each named scenario. The script now passes the unmutated tree's `KoineConformance` to the failures driver, so the expected digest's printer is never the subject of a mutation.

**Nothing larger surfaced, so nothing was cut.** `task selection:failures` gives 52 scenarios, 119 host runs, 0 failed; `task selection:decisions` still gives 134, 0 failed.
