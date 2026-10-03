# app-and-file-search-k30

## Goal

Cut `app-and-file-search`'s implementation from its settled design into
vertical `impl` leaves that each stay verifiable through the three seams.

## Context

- `app-and-file-search-k19`'s design and evidence.
- `app-and-file-search-k95`'s triage and the subsequent producer/review repairs.
  Do not cut implementation from the withdrawn minor-2 nil-consent proposal or
  the unresolved default-discovery/coverage budget. Consume the settled
  diagnostic ADR and mechanism contract after their reviews.
- The node brief's `Done when`.
- k124/k125 route witness repairs through search-preopen-witnesses-k126 and
  replay/size phases through search-path-observation-phases-k127. Their producer
  reviews/integrations precede classification k123's chain, then resource k120.
  Consume long-search-result-actions-k128's launch/open design/review chain too;
  no copy-only or PATH_MAX-limited baseline, changed call set, larger account or
  workflow loss is approved by this integration.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

Application search and file search are independently useful. Split them if
the design gives them separate mechanisms.
Keep the workspace 1.0.0 action-only profile against its separate compatibility
host, and add an exact search-required profile for the search-serving release.
