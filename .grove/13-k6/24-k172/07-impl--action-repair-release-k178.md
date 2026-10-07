# action-repair-release-k178

## Goal

Ship the behaviour as workspace release/schema **1.0.1** under `koine-desktop/1`:
the repair SDL's three appended descriptions, an unchanged action shape, error
kinds and enums, a catalogue and conformance profile that say so, and a served
schema digest that differs from 1.0.0 on the same host and printer.

## Context

- `docs/design/workspace-action-repair-schema.graphql` and
  `task design:action-repair-check`.
- `docs/specs/workspace-launch-and-open.md#subjects-and-versions` (the 1.0.1
  paragraph) and `#packaging-and-compatibility`.
- `Providers/WorkspaceProvider/manifest.json`, `schema.graphql`, `App/ProviderCatalogue.json`,
  `scripts/check-provider-catalogue.py`, `docs/design/profiles/`,
  `scripts/conformance.sh`, `clients/contract-only`.
- The three stage leaves, which make those descriptions true, and
  `retained-workspace-baseline-k173`, which keeps 1.0.0.

## Done when

- The served schema is the repair SDL's verbatim, with the 1.0.1 manifest and
  schema versions and the catalogue entry sealed with the actual signed packaged
  outputs' values (the signing identifier read from the bundle, as
  `task check:provider-catalogue` does).
- A new bundled profile (workspace 1.0.1/schema 1.0.1, desktop 1.0.0, full
  candidate rows) is held to what the signed host serves, by type, field,
  argument, nullability, default, deprecation and description, with its digest
  against the digest served. Candidate versions are pinned separately from
  canonical SDL and digest equality, and the check is seen red against mutated
  copies. The retained 1.0.0 profile and SDL are untouched and still pass against
  the retained bundle.
- The contract-only client is regenerated from the served schema and its coverage,
  and the findings record are reconciled with this contract; its documented-contract
  check (`task client`, `task conformance`) passes.
- `docs/specs/workspace-launch-and-open.md` and the workflow trace say what is
  now served.

## Notes

- A numeric served digest cannot be written before the actual composition exists;
  take it from the served schema and compare, never from a hand edit.
