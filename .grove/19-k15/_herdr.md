# herdr-k15 — brief

## Goal

A client identifies the focused iTerm session and its nested herdr context well
enough to address the intended running instance. It lists and acts on herdr's
panes, tabs, Spaces, worktrees and agents, places jump labels over herdr
targets, and tells detaching the client from stopping the server. Navigation
into and out of the chain stays with the client.

## Done when

- These rows are demonstrated through public operations, with multiple and
  nested instances and equal display labels: Terminal context, herdr panes,
  herdr tabs and Spaces, herdr worktrees, and herdr agents and lifetime.
  Specifically:
  - Copy mode within the live pane is distinct from scrollback opened in an
    editor, and both are distinct from iTerm's own copy mode.
  - Worktree removal is non-forcing, and the client keeps confirmation.
  - Detaching the client leaves the server and panes running; stopping the
    server is a separate operation.
  - The next blocked agent is reachable.
- The list state covers:
  - row titles and details;
  - focused or current state;
  - agent status sufficient for status-priority ordering;
  - worktree current and switchable state.
  Unknown is distinct from false.
- Jump-target geometry for panes, tabs, Spaces and agents combines herdr's
  layout with host geometry, and an unavailable location is distinguishable.
  The observed label misplacement when other host splits coexist is
  investigated as evidence. Reproducing it is not acceptance.
- herdr that is absent, not running, or unreachable for a session is an absent
  dependency, never an empty list.
- The cross-provider identity question is decided under
  `provider-architecture`'s constraint. Allocated authority, trace rows,
  recorded herdr version, and VM acceptance.

## Decomposition

1. `design` evidence: herdr's interface, instance discovery and geometry.
2. `design`: the API and provider boundary.
3. `planning`: cut implementation leaves. Read state and labels may land before
   actions.

## Notes

Modaliser talks to herdr over newline-delimited JSON-RPC on herdr's Unix
socket, one request per connection. Its CLI wraps the same socket. Zellij and
Neovim were removed from scope and are not part of the chain.
