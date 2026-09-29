# herdr-evidence-k27

## Goal

Establish how Koine can reach herdr and address the right instance from an
iTerm session. Establish what herdr supplies for the required state, actions
and label geometry.

## Context

- `iterm-k41`'s session identity.
- Modaliser's herdr socket, mux and list/jump-legend libraries, as evidence of
  the protocol and of the label pipeline, including the observed misplacement.
- The installed herdr and its documentation or source, for the protocol and
  version.

## Done when

A `docs/verification/` document answers:

- What protocol and version does herdr expose? Which methods supply panes,
  tabs, Spaces, worktrees, agents and status, and the required actions?
- How does an iTerm session map to its herdr instance and socket, including
  nested and multiple instances? The candidates are environment, tty and
  process tree.
- Can the signed hardened Koine reach that socket, and with which
  prerequisites?
- Where does target geometry come from? Why does the inherited probe misplace
  labels when other host splits coexist?

It ends with a recommendation for `herdr-k43`.

## Notes

This question is bounded. Record unresolvable instance ambiguity or geometry as
a stated limit, and report the affected targets as unavailable locations.
