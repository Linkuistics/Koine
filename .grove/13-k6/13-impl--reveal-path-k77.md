# reveal-path-k77

## Goal

Serve `workspaceRevealPath` complete to its design and accept it at L, G, N and
V. Because this lands the last workspace root, the conformance profile then
requires the complete design SDL.

## Context

- `docs/specs/workspace-launch-and-open.md`: the reveal paragraphs, the failure
  table, and the Finder reveal and Input boundary rows.
- The path inspection from `open-path-k75`, and the prepared VM.

## Done when

- A literal absolute path is inspected as for opening. A missing path is
  `PATH_NOT_FOUND`, and missing Finder is `APPLICATION_NOT_INSTALLED`.
- Finder's native selection is requested with its boolean acknowledgment, inside
  the same one-shot three-second bound. A false result is `failed`. There is no
  AX, keystroke or menu check.
- The receipt echoes the submitted path.
- L: with the adapter substituted, cover missing Finder, false acknowledgment,
  late acknowledgment and cancellation.
- G: composition tests cover authority, branches and multi-action behavior.
- N: the real bundle serves the widened contribution.
- V: reveal a file, a folder, an application bundle, an alias and the filesystem
  root. Observe the actual selection or root view, and record that the receipt
  alone is not selection. Accessibility is absent throughout.
- `task conformance` now requires the complete workspace design SDL. The
  contract-only client reveals a path.
- The spec rows link the evidence. So do the trace rows that reuse reveal:
  Application search and File search.
