# pointer-and-media-k9 — brief

## Goal

A client can locate the pointer and reveal it, including the configured nudge
that shows a cursor an application left idle-hidden, so the client can draw its
highlight. It can also send system play/pause through the system media route
rather than to the foreground application.

## Done when

- The pointer location is readable in the coordinate space the window and
  display geometry use.
- A reveal-nudge operation exists and returns the pointer to where it was, if
  the design requires that.
- Drawing the highlight ring is recorded as a client responsibility.
- Play/pause reaches the system's current media target, whichever application
  is foreground, and the operation says what it can and cannot confirm.
- Allocated authority, trace rows, and VM acceptance with a real media player
  and an application that hides the idle cursor.

## Decomposition

1. `design`: the mechanism, with a bounded evidence check, and the API.
2. `planning`: cut implementation leaves.
