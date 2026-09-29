# app-and-file-search-k30

## Goal

Cut `app-and-file-search`'s implementation from its settled design into
vertical `impl` leaves that each stay verifiable through the three seams.

## Context

- `app-and-file-search-k19`'s design and evidence.
- The node brief's `Done when`.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

Application search and file search are independently useful. Split them if
the design gives them separate mechanisms.
