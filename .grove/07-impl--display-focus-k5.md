# display-focus-k5

## Goal

Serve display focus as the design of `window-layout-k2` defines it.

## Context

- The contract is "Display focus" in `docs/specs/machine.md`, under "Window
  layout".
- Modaliser's `focusDisplay`, in `WindowManipulator.swift`, raises the front
  window on a display, activates its application and moves the pointer. On a
  display with no window, it also clicks. Koine never clicks.

## Done when

- On a display with a window, display focus raises the front window there,
  chosen by the order from `window-stacking-k4`. It activates that window's
  application and moves the pointer to the display's centre.
- On a display with no window, it moves the pointer to the centre and
  reports that no window took focus.
- When Koine cannot establish the front window on the display, it raises
  nothing, moves the pointer and reports `FRONT_WINDOW_UNKNOWN`.
- While a pointer button is held at the start, it does nothing and reports
  `POINTER_BUTTON_HELD`.
- Immediately before the pointer move, it checks the buttons again. When a
  button is held then, it leaves the pointer where it is. The receipt field
  `pointerMoved` says whether the pointer moved (`window-layout-k9`).
- It never clicks, under any grant.
- L and G tests cover both cases, both button checks and the authority.
- Display focus moves from the design into the served SDL and both composed
  files, word for word. Its coordinates leave
  `desktopCoordinatesNotYetImplemented`, and `scripts/conformance-lib.sh`
  gains a control for its root (`window-geometry-k3`).

## Notes

- The click for clients that also hold input control is an issue for the
  app input item. The release leaf files it.
- Modaliser posts a mouse-moved event after it warps the pointer. If macOS
  asks for a consent other than Accessibility for that event, stop and ask the
  human (root brief, Notes).
