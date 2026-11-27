# pointer-k3

## Goal

Serve the pointer position read and the nudge in the desktop provider, with L
and G tests. Serve the new disclosure text for the whole grove too.

## Context

- The design leaf `pointer-media-k2` fixes the schema, the descriptions, the
  version numbers and the disclosure text.
- `Providers/DesktopProvider/Sources/DesktopProvider.swift` already has the
  held-button check and the pointer move of display focus.
  `Providers/DesktopProvider/Logic/DisplayFocus.swift` is the pattern: the
  pure module takes the native facts as plain values.
- The precedent for this leaf is the commit of `window-geometry-k3`. It served
  the window list and frame setting behind the desktop disclosures.

## Done when

- A desktop read returns the pointer position in screen coordinates.
- The nudge moves the pointer one point to the right and back with two
  mouse-moved events, and the pointer ends where it started. While a pointer
  button is held, the nudge refuses and moves nothing.
- The core serves the new disclosure text, which covers the media keys too.
  The descriptions state the new reach.
- L tests cover the nudge path, the refusal and the coordinate conversion.
- G tests cover the authority, the descriptions and the served disclosure. No
  G test calls the nudge with a control grant.
- `swift test` passes, and the documents that the design leaf named describe
  the served state.

## Notes

- The nudge never clicks, and it synthesises no pointer button.
