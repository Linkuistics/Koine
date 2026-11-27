# pointer-k3

## Goal

Serve the pointer position read and the nudge in the desktop provider, with L
and G tests. Serve the new disclosure text for the whole grove too.

## Context

- The design leaf `pointer-media-k2` fixes the schema, the descriptions, the
  version numbers and the disclosure text. The design is
  `docs/design/desktop-pointer-media-schema.graphql`, and the contract is the
  "Pointer and media" section of `docs/specs/machine.md`. The review leaf
  `pointer-media-k7` and any integration of it come first.
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
- Desktop release 1.0.2 with schema 1.0.2 serves `desktopPointer` and
  `desktopNudgePointer`. The served SDL is the design restricted to the served
  roots and the types that they reach, word for word.
- The core adds the host feature `desktop-disclosures-v2`. It advertises the
  feature together with `desktop-disclosures-v1`, and it serves the 0.6.0 text
  of "Capability disclosures". The desktop manifest and descriptor require
  `desktop-disclosures-v2` alone.
- Two new composed design files and two new profiles hold the headless host and
  the signed application: `core-desktop-pointer-media-extension-host` and
  `core-desktop-pointer-media-workspace-extension-host`. The window layout
  files and profiles stay. The update profiles pin desktop schema 1.0.2.
- A G test proves that a host without `desktop-disclosures-v2` refuses the
  bundle before load.
- `swift test` passes. The "Pointer and media" section of the desktop contract,
  the trace rows "Pointer" and "Grant disclosure", the README and the client
  guide describe the served state.

## Notes

- The nudge never clicks, and it synthesises no pointer button.
- The position read follows Modaliser: `NSEvent.mouseLocation`, flipped against
  the height of the first screen in the same `NSScreen.screens` reading. With no
  screen, the read is null and the nudge reports `failed`.
- The nudge checks consent first, then the held buttons. It creates both
  mouse-moved events before it posts either.
- `task design:pointer-media-check` must still pass after any change to the
  design files.
