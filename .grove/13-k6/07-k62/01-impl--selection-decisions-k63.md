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
