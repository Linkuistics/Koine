# iterm-k42

## Goal

Cut `iterm`'s implementation from its settled design into vertical `impl`
leaves that each stay verifiable through the three seams.

## Context

- `iterm-k41`'s design and `iterm-evidence-k26`'s evidence.
- The node brief's `Done when`.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

Read state with geometry, and prerequisite discovery, can land before actions.
Setup must land with discovery, so a missing prerequisite is never silent.
