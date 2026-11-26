# display-focus-k5

## Goal

Serve display focus as the design of `window-layout-k2` defines it.

## Context

- Modaliser's `focusDisplay`, in `WindowManipulator.swift`, raises the front
  window on a display, activates its application and moves the pointer. On a
  display with no window, it also clicks. Koine never clicks.

## Done when

- On a display with a window, display focus raises the front window there,
  chosen by the order from `window-stacking-k4`. It activates that window's
  application and moves the pointer to the display's centre.
- On a display with no window, it moves the pointer to the centre and
  reports that no window took focus.
- It never clicks, under any grant.
- L and G tests cover both cases and the authority.

## Notes

- The click for clients that also hold input control is an issue for the
  app input item. The release leaf files it.
