# window-layout-k31

## Goal

Design the window and display state and operations for `window-layout`:
cross-application window listing with geometry and stacking/visibility,
geometry changes, restore, displays, move-to-display and display focus.

## Context

- `window-stacking-evidence-k20`'s findings and recommendation.
- `provider-architecture-k5`'s allocation.
- The current desktop contract: process capture, held-element window
  references and remembered windows.
- Requirement rows Desktop windows and Displays. Also "State for configured
  lists and on-screen labels".

## Done when

The spec, and an ADR where a decision clears the bar, state:

- how a client lists windows across running applications. This includes
  whether Koine enumerates running applications, within the process-capture
  rules.
- the geometry fields, their coordinate space, and their unknown or
  unavailable values;
- the stacking and visibility state;
- whether placement is expressed as a target frame computed by the client, or
  as named layouts;
- restore ownership;
- what "focus a display" does natively;
- the move-to-display computation's owner;
- errors for windows that refuse geometry;
- authority, and the VM acceptance cases.

## Notes

Keep the held-element identity; do not introduce title or bounds matching for
targeting.
