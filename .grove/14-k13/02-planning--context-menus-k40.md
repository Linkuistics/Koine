# context-menus-k40

## Goal

Cut `context-menus`' implementation from its settled design into vertical
`impl` leaves that each stay verifiable through the three seams.

## Context

- `context-menus-k25`'s design.
- The node brief's `Done when`.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

An explicitly opened menu must land with its cleanup. Opening without cleanup
is not an acceptable intermediate.
