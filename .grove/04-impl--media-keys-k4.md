# media-keys-k4

## Goal

Serve the six media keys in the desktop provider, with L and G tests.

## Context

- The design leaf `pointer-media-k2` fixes the operation shape and the
  receipts. The leaf `pointer-k3` already serves the disclosure.
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
- `swift test` passes, and the documents describe the served state.

## Notes

- A key posted on the host would change the music or the volume of the
  developer. So only the VM run posts a key.
- The codes for next and previous stay as the design states until the VM run
  settles them.
