# search-defaults-k104

**Integrates:** search-defaults-k102

## Goal

Triage the findings of `search-defaults-k102` against the default-discovery
design from `search-defaults-k101` and apply the real ones. Implementation
planning should then start from an admission, traversal-order, descriptor,
cancellation, canonical-path and accounting contract that it can build and
accept without rediscovering these defects in the adapter.

## Context

- The findings are in the review's own leaf and commit. They are anchored to
  producer commit `44233e3defc0`, with coordinates in the working copy after
  `search-permission-transport-k103`. Read them there; this charter does not
  restate them. Their host evidence is read-only inspection of this Mac. Some of
  it rests on Antony's actual home tree and on Modaliser's file indexer. It
  informs the design; it is not acceptance.
- Artifact: `docs/specs/workspace-search.md` (admission, traversal and
  scheduling, resource accounting, native ownership, identity, capacity
  examples and acceptance), `docs/design/workspace-search-{schema,operations}.graphql`,
  `docs/adr/search-coverage-describes-observations.md`,
  `docs/adr/application-search-uses-bundle-identity.md`, the client guide's
  search section, the search terms in `CONTEXT.md`, the workflow trace rows,
  the coverage/handoff views with their exports/captions/README, and the live
  `protected-home-search-k93` context.
- Keep k103's transport, compatibility and failure-class meanings. Reconcile
  any shared admission wording with them rather than reopening them.
- Approval is unchanged. No new consent, entitlement, usage key, setup,
  descriptor-limit change or incompatible version is approved. No reduced
  search domain is approved either: that stays `protected-home-search-k93`'s
  decision with Antony. A traversal-order or descriptor-account change is design
  work. A smaller domain is not.

## Done when

- Every finding of `search-defaults-k102` is applied, accepted as a stated limit
  or trade-off, or rejected with its reason in this leaf's running log.
- Applied changes leave the spec, SDL, examples, both discovery ADRs (reworked
  in place where their decisions change), glossary, client guide, workflow trace
  and views consistent, including their summary layers.
- Capacity examples and acceptance rows give constructible subjects for every
  changed rule, across the three seams, with native acceptance still pending.
- The design checks and rendering tasks pass on frozen subjects.
- A substantive redesign is externalized as a new producer with its own
  load-bearing review beside this leaf, rather than absorbed here. A changed
  traversal order is one example.

## Notes

Use the existing `task design:search-check`, `task design:search-render` and
`task check:docs`. This leaf integrates a design review. It does not implement
the adapter or start a new native evidence chain. This leaf may spend one
narrow in-session reviewer, as `integrate-review-*` kinds do. Planning
(`app-and-file-search-k30`) cannot cut implementation until this leaf, and any
producer and review it externalizes, retire.
