# search-coverage-k100

**Integrates:** search-coverage-k98

## Goal

Triage the findings of `search-coverage-k98` against the discovery, coverage
and resource design from `search-coverage-k96`. Apply the real ones to the
design artifacts so implementation planning starts from a settled discovery
and coverage contract.

## Context

- The findings are in the review's own leaf and commit, anchored to producer
  commit `7653465b1173`; coordinates are the working copy after
  `search-permission-transport-k97`. Read them there. This charter deliberately
  does not restate them.
- The artifact: `docs/specs/workspace-search.md`,
  `docs/design/workspace-search-{schema,operations}.graphql`,
  `docs/adr/search-coverage-describes-observations.md`, the search entries in
  `CONTEXT.md`, the search rows of `docs/specs/workflow-providers.md`,
  `docs/client-guide.md`'s search section, and the coverage/handoff views with
  their README captions, plus the `task design:search-check` controls.
- Evidence the review cites: `docs/verification/search-discovery.md`,
  `docs/verification/protected-path-metadata.md` and its recorded environment,
  and the Safari paths in the launcher and open-URL verification records.
- `search-permission-transport-k97` owns BLOCKED transport, and its review
  (`search-permission-transport-k99`) runs after this leaf over the same files.
  Keep its sections intact unless a finding requires a change, and record any
  such change so k99 can reconcile it.
- `protected-home-search-k93` holds Antony's protected-home and bound-driven
  omissions decision. Any reduction of the agreed application/home coverage
  goes through that decision, not inference here. Default opening and app-reveal
  notice keep their own decisions.

## Done when

Every finding of `search-coverage-k98` is accepted and applied, accepted as a
stated limit or pending obligation, or rejected with its reason in this leaf's
running log. Applied changes leave the spec, SDL, examples, ADR, glossary,
shared contracts, views and design checks mutually consistent and current-state.
A changed traversal, admission or deduplication decision that earns a record
reworks the ADR set in place. No new consent, entitlement, usage key, setup or
incompatible contract version is introduced. A substantive redesign that
needs its own adversarial read is externalised as a producer/review chain
beside this leaf rather than settled here.

## Notes

The review only inspected. Its host counts, mount flags and scratch filename
probe are inspection evidence for design bounds, not acceptance. Re-run
`task design:search-check`, `task design:search-render` and `task check:docs`
after changing the SDL, examples, views or links.

## Decisions (running log)
