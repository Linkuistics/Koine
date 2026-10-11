# herdr-k44

## Goal

Cut `herdr`'s implementation from its settled design into vertical `impl`
leaves that each stay verifiable through the three seams.

## Context

- `herdr-k43`'s design and `herdr-evidence-k27`'s evidence.
- The node brief's `Done when`.

## Done when

The node holds ordered `impl` leaves covering the brief's `Done when`, each a
working, testable slice, and any review judgment is recorded.

## Notes

Terminal context with read state and labels is independently useful before the
actions. Worktree, agent and lifetime actions can then follow as separate
slices.
