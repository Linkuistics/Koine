# window-geometry-k3

## Goal

Serve the window list with frames, the display list, frame setting and the
disclosure, as the design of `window-layout-k2` defines them.

## Context

- Modaliser's `WindowEnumerator.swift` lists windows across applications.
  Its `WindowManipulator.swift` sets frames, lists displays and converts
  visible frames into window coordinates.
- The desktop provider lists one application's windows today, through its
  window table of held elements.

## Done when

- The window list, the display list and frame setting are served with their
  designed authority, with L and G tests.
- Frame setting disables the Electron accessibility mode during the write.
  It repeats the write after a move to a larger display until the size
  matches, as Modaliser does.
- The Settings window and the GraphQL descriptions carry the disclosure.
- The desktop contract and the trace rows describe what this leaf serves.

## Notes

- Order and visibility belong to `window-stacking-k4`, not to this leaf.
