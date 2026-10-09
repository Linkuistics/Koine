# menu-bar-k37

## Goal

Cut `menu-bar`'s implementation from its settled design into vertical `impl`
leaves that each stay verifiable through the three seams.

## Context

- `menu-bar-k36`'s design and `menu-evidence-k23`'s evidence.
- The node brief's `Done when`.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

Discovery alone is useful before invocation. Invocation must land with its
validation, since unvalidated invocation is not an acceptable intermediate.
