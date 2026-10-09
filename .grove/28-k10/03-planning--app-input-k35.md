# app-input-k35

## Goal

Cut `app-input`'s implementation from its settled design into vertical `impl`
leaves that each stay verifiable through the three seams.

## Context

- `app-input-k34`'s design and `app-input-evidence-k22`'s evidence.
- The node brief's `Done when`.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

The first slice should prove the separate input grant end to end on one
application before widening to every row.
