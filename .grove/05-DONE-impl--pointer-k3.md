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
- The consent step is two checks: `AXIsProcessTrusted` and
  `CGPreflightPostEventAccess`. When either is false, the nudge reports
  `os-permission` with `accessibility`, and its message names the missing
  access. No operation calls `CGRequestPostEventAccess`. The integration
  `pointer-media-k8` added the second check.
- `task design:pointer-media-check` must still pass after any change to the
  design files.

## Decisions (running log)

**The pure module.** `Logic/Pointer.swift` holds the conversion, the nudge
path, the two consent checks and the order of the nudge steps.
`PointerNudge.perform` takes each native fact as a closure, as
`DisplayFocus.perform` does. It creates both events into a list before the
first post, so a failure leaves no half nudge. The message of the consent
failure is in the pure module too, so an L test holds that it names the
missing access.

**The position read.** The provider reads `NSEvent.mouseLocation` and
`NSScreen.screens` in one turn on the main actor, because `NSScreen` belongs to
the main actor. The read needs no consent check.

**The feature constant.** The provider keeps the Swift name
`desktopDisclosuresFeature` with the value `desktop-disclosures-v2`. The
selection fixtures and the compatibility build substitute the text of the
descriptor's feature list by that name. The core names the new feature
`desktopDisclosuresV2Feature` and keeps `desktopDisclosuresFeature` for v1.

**The served SDL.** The served file is the design without its comment header,
without `desktopPostMediaKey`, and without `DesktopMediaKey` and
`DesktopMediaKeyReceipt`. A G test holds the composed file to the design with
exactly those three coordinates missing. `media-keys-k4` empties that set.

**The window layout profiles.** The two window layout composed files and
profiles stay unchanged in content. The contract now names them as the record
of desktop 1.0.1, which Koine 0.5.0 released. `task conformance` and the VM
conformance script hold the new pointer and media profiles.

**The compatibility pairs.** The desktop pairs now put this tree's desktop
1.0.2 under this tree's host and under the released 0.4.1 host, which refuses
it by `desktop-disclosures-v2`. The pairs with the released 0.5.0 host belong to
`pointer-media-acceptance-k5`, as the root brief gives the N check to it.

**The window layout G tests.** The host feature test and the refusal test move
from `DesktopWindowLayoutTests` to `DesktopPointerTests`, at v2. The refusal
test uses a host that advertises `desktop-disclosures-v1` and lacks v2, as the
released 0.5.0 host does.

**No nudge with a control grant.** The G tests ask the nudge only with a
read-only grant and with a grant without capabilities. Both are refused before
the provider is asked, and the tests check that the pointer did not move.
