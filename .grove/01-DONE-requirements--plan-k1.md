# plan-k1

## Goal

Agree with Antony which item of the roadmap in GitHub issue 11 this grove
delivers. Then agree the happy-path scope of that item and its test seams.

## Context

- The roadmap is GitHub issue 11. Its first two items shipped: app and file
  search in Koine 0.4.0, and window layout in Koine 0.5.0. The next open
  checkbox is "Pointer and media: pointer location, reveal nudge, system
  play/pause".
- The requirements are the "Media" and "Pointer" rows of
  `docs/requirements/modaliser-workflows.md`. Koine supplies the pointer
  access, and the client draws the ring.
- "Authority allocation" in `docs/specs/workflow-providers.md` allocates the
  authority. The pointer location needs desktop read. The nudge needs desktop
  control, and Koine refuses it while a pointer button is held. System
  play/pause needs desktop control and goes through the system media route.
- `docs/adr/provider-authority-follows-effects.md` keeps pointer movement
  without held buttons and system media events as desktop effects. Grant
  descriptions must disclose the expanded desktop reach before the additions
  ship.
- Modaliser is at `~/Development/KeyboardDrivenUI/Modaliser`. Its
  `CursorLibrary.swift` reads the pointer position. It nudges the pointer one
  point and back with two mouse-moved events. Its `MediaKeyEmitter.swift`
  posts the play/pause media key as a system-defined event, down then up.
  Antony's configuration binds both in `~/.config/modaliser/config.scm`.
- Koine's desktop provider already checks the held pointer buttons and moves
  the pointer for display focus. In a VM, the witness
  `Fixtures/WindowIdentityProbe` reads the pointer position and the held
  buttons.

## Done when

- Antony agreed to the roadmap item, its happy-path scope and its test seams.
- The running log below records each decision that settled.
- The root brief holds the settled scope, and the leaves after this one exist.

## Notes

## Decisions (running log)

**Roadmap item and scope.** This grove delivers pointer and media, the next
open checkbox of the roadmap in issue 11, as Koine 0.6.0. Koine ports
Modaliser's mechanisms.

A desktop read returns the pointer position in screen coordinates, and the
client draws the ring. A desktop control operation nudges
the pointer one point to the right and back. Koine refuses the nudge while a
pointer button is held. The Settings window and the GraphQL descriptions
disclose the wider desktop reach before the release.

A media key receipt can say only that Koine posted the key. macOS gives no
public way to ask which app holds Now Playing. When no app holds Now Playing,
macOS may start Music. The design leaf checks that in a VM, and the disclosure
states it if it happens. Antony agreed on 2026-11-27: "I think we should
deliver the whole media keys family, rest I agree with".

**Media keys.** The grove delivers the whole family that Modaliser's library
posts: play/pause, next, previous, volume up, volume down and mute. Antony
decided this on 2026-11-27, against the recommendation of play/pause alone, in
the words above. Each key is a system-defined event, down then up, as in
Modaliser's `MediaKeyEmitter.swift`.

The decision has these consequences:

- The "Media" row of the requirements names play/pause alone. The design leaf
  widens it to the six keys, with the authority row and the trace row.
- Play/pause, next and previous go to the Now Playing app. Volume up, volume
  down and mute change the system output.
- All six keys stay desktop effects under desktop control.
  `provider-authority-follows-effects` already counts system media events as
  desktop effects. The disclosure states that desktop control can change the
  volume and mute the output.
- Modaliser's codes for next and previous (`NX_KEYTYPE_FAST` and
  `NX_KEYTYPE_REWIND`) are a judgement call that nobody verified. The VM run
  establishes which codes a player honours.

**Test seams and plan.** The work reuses four existing seams and adds none.
Antony agreed on 2026-11-27 with "yes".

The logic tests feed plain values to the pure desktop logic, and nothing posts
an event. They cover the nudge path, the refusal while a button is held, the
coordinate conversion and the event contents of each key. The public GraphQL
tests load the real desktop bundle over loopback. They cover the authority,
the descriptions and the served disclosure, and they never call the nudge or a
key with a control grant. The native compatibility check runs the signed
bundle against the new host and the released 0.5.0 host.

One TestAnyware run accepts the happy path with an independent witness. It
checks the disclosure for a new grant request and for an existing grant after
a restart. It checks the pointer position against the witness, and the pointer
back at its start after a nudge. A real player, Music by default, plays three
short silent tracks in the background while TextEdit stays in front. Each of
the six keys changes the state that the witness reads. TextEdit receives no
keystroke, and no permission dialog appears.

The run carries three risks. The guest may have no audio device. A witness may
not see a hidden pointer appear again, and then the run states that limit and
an issue holds the check. If the VM cannot keep a player playing, the session
asks Antony. It recommends the close with the limit stated and an issue.

The plan cuts five flat leaves after this one: design, pointer, media keys,
acceptance and release 0.6.0.
