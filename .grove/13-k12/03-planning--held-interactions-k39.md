# held-interactions-k39

## Goal

Cut `held-interactions`' implementation from its settled design into vertical
`impl` leaves that each stay verifiable through the three seams.

## Context

- `interaction-lifecycle-k38`'s design and `held-input-evidence-k24`'s evidence.
- The node brief's `Done when`.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

An interaction without its revocation, inactivity and shutdown cleanup is not
a safe working increment. Land the lifecycle with its first consumer rather
than as a dead layer.
