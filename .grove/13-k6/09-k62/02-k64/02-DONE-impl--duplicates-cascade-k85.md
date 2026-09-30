# duplicates-cascade-k85

## Goal

Accept ordinary-duplicate refusal, the missing-capability-owner cascade and a
desktop start failure at N and G.

## Context

- The node brief `selection-failures-k64`: its "Ordinary duplicates", "Cascade"
  and "Start failure" conditions, and Machine's rows "Ordinary duplicate
  identities…", "Desktop rejected before publication…" and "Desktop published
  but start fails".
- The harness library and restart machinery `freeze-failures-k84` leaves in
  `scripts/`, and its evidence file `docs/verification/selection-failures.md`.
- `Sources/KoineCore/Composition.swift`: the fixed point that removes a
  contribution whose additional-capability owner is not admitted.

## Done when

The node brief's "Ordinary duplicates", "Cascade" and "Start failure" conditions
hold, and Machine's three rows link the evidence. Conformance gains the exact
absent/rejected profile the cascade is held to.

## Notes

`freeze-failures-k84` proved the principal conflicts but left one clause for this
leaf: "the diagnostics agree with the capability-owner cascade". A shipped
selection refused for a principal conflict, before publication, strands whatever
requires its capabilities; once a fixture can name another provider as an
additional-capability owner, assert that dependant is removed with
`missing-capability-owner`. Machine's principal-conflict row says so in its Evidence.

Fixture providers need a way to name another provider as an additional-capability
owner (the existing `FIXTURE_ADDITIONAL` names only itself).

## Decisions (running log)

**A dependant is a build flag, not a new fixture provider.** `FIXTURE_NEEDS_SH` / `FIXTURE_NEEDS_SK` (with `FIXTURE_ADDITIONAL`) make the existing `…RenameItemChecked` action require another provider's read capability; `build-decisions.sh` builds `sh-update-needs-sk`, `sk-update-needs-sh` and `od-needs-sk`, giving the chain sh ← sk ← od and the cycle sh ↔ sk. Manifest and descriptor both declare `additional-capabilities-v1` and framework minor 1, or the loader refuses the disagreement before the core sees the requirement.

**The cascade runs once per way the desktop stand-in can be refused.** Eight scenarios reuse `FAILURES` (loader before `dlopen`, after `dlopen`, core before publication), because the fixed point must not care which phase refused its owner. Only the core-refused one (`invalid-sdl`) is held to the conformance profile, since a profile pins one exact row set.

**The absent/rejected profile names the fixtures and lives in `docs/design/profiles/`, checked by `task selection:failures`, not `task conformance`.** It is a failure profile: the production catalogue has no provider to refuse. Its design is a new `core-schema-extension-host.graphql`, the desktop extension-host design less exactly the desktop coordinates, held to that by a Swift test and to the served core alone by another. The harness runs the real `KoineConformance` tool and sees four pin controls and two design controls red before crediting the clean verdict.

**An unapproved rival cannot share the valid provider's identifier.** Approval is `<providerId>.approval.json` (identifier + Team ID), so a same-identifier copy is approved as its sibling is. My first expectation (an unapproved same-identifier rival) was wrong, not the loader; the unapproved case claims only the prefix, and the same-identifier rivals are incompatible, ad hoc or tampered.

**Start failure is asserted by what the row, the field and the capability list say.** `fixtureShInfo` stays published and resolves to `unavailable` ("The fixturesh provider is not running."), `fixturesh:*` stay available, dependants are `ACTIVE`, and the lower update and bundled baseline wrote no marker.

**Left alone, recorded, and raised for the human:** an ordinary provider beside a refused same-identity rival shows `reason: null` and no diagnostic (`ProviderSelection.plan` sets `selected-with-refusals` only for slots). Machine's "healthy choice with any same-identity refused candidate" could be read to cover it. The row this leaf closes asks only that the rival not evict, so nothing asserts the gap; it is in the evidence file's Observations.

**Instruments.** Seven mutations added to `scripts/check-selection-mutations.py` (a refused rival contesting; eligible duplicates not refused; the cascade never run, run one round, given no cycle; a failed start still answering; alternatives loaded after a failed start), each seen red for the right reason in every host run of each scenario named.

**Nothing larger surfaced, so nothing was cut.** The decisions driver still gives 134 host runs, 0 failed, after the harness gained its new phase assertions.
