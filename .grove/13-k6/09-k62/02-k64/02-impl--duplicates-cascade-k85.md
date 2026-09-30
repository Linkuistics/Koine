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
