# media-keys-k4

## Goal

Serve the six media keys in the desktop provider, with L and G tests.

## Context

- The design leaf `pointer-media-k2` fixes the operation shape and the
  receipts: `desktopPostMediaKey(key:)` with the enum `DesktopMediaKey`, in
  `docs/design/desktop-pointer-media-schema.graphql`. The "Media keys"
  subsection of `docs/specs/machine.md` holds the key numbers. The leaf
  `pointer-k3` already serves the disclosure, release 1.0.2 and the host
  feature.
- Modaliser's `MediaKeyEmitter.swift` is the mechanism to port. It posts a
  system-defined event of subtype 8, down then up, at the HID event tap. Its
  pure `data1(button:state:)` function is the test seam.

## Done when

- Desktop control operations post play/pause, next, previous, volume up,
  volume down and mute as the design states.
- A receipt says that Koine posted the key, and nothing about the player.
- L tests cover the event contents of each key: the key number and the down
  and up states.
- G tests cover the authority and the descriptions. No G test posts a key.
- The served SDL is the whole design, word for word. The composed design files
  and profiles of `pointer-k3` gain the media key root and its types.
- Without Accessibility consent or posting access, the operation reports
  `os-permission` and posts nothing. It makes the two consent checks of the
  nudge in `pointer-k3`.
- `swift test` passes. The "Pointer and media" section of the desktop contract,
  the trace row "Media", the README and the client guide describe the served
  state.

## Notes

- A key posted on the host would change the music or the volume of the
  developer. So only the VM run posts a key.
- The codes for next and previous stay as the design states until the VM run
  settles them. In the Music check, `rcd` turned 19 into `NextTrack` and 20
  into `PreviousTrack` (`docs/verification/media-key-music-launch.md`).
- The provider creates both events before it posts either.

## Decisions (running log)

**The pure module.** `Logic/MediaKeys.swift` holds the key numbers, the
`data1` packing, the order of the two states and the order of the steps.
`MediaKeyPress.perform` takes the two consent checks, the creation and the post
as closures, as `PointerNudge.perform` does. It reuses `PostingConsent` from
`Logic/Pointer.swift`, so the nudge and the keys give the same message for a
missing access.

**The enum argument.** `key` is the first enum argument in Koine. The GraphQL
library builds each SDL enum value as `.string(name)` (`ExtendSchema.swift`,
`buildEnumValueMap`), so the provider receives the name as a string. A core
test with a stub provider holds that, so no test posts a key to find it out.

**The native post.** The provider creates both events with
`NSEvent.otherEvent(with: .systemDefined, ...)` and takes their `cgEvent`, as
Modaliser does. It runs the whole press on the main actor, because `NSEvent`
belongs to the main actor. It posts at the HID event tap. An argument that
names no media key reports `failed` and posts nothing. GraphQL validation
refuses such a value first, so that branch is a guard only.

**The served SDL.** The served file is now the whole design without its
comment header. `desktopCoordinatesNotYetImplemented` is empty, and the two
composed files hold the media key root and its two types word for word. The
schema tests name the added set `pointerMediaCoordinates`.

**The conformance controls.** `scripts/conformance-lib.sh` gains four controls
for desktop schema 1.0.2: the media key root removed, a key removed, the
receipt key made nullable and the root description changed.

**No key with a control grant.** The G tests ask for each key only with a
read-only grant and with a grant without capabilities. Both are refused before
the provider is asked.

**No review leaf.** The leaf ports Modaliser's mechanism into a shape that the
design fixed, and `pointer-media-k7` reviewed that design adversarially. The
open risk is whether a player honours the posted keys, and only the VM run of
`pointer-media-acceptance-k5` can show that. So this leaf cuts no
`review-impl` step.
