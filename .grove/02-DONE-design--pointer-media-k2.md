# pointer-media-k2

## Goal

Design the pointer and media surface of desktop for Koine 0.6.0. It covers
the pointer position read, the nudge and the six media keys. Write the design
into the durable documents that the root brief's "Docs" item names.

## Context

- The design leaf of the window layout grove is the precedent. Its schema is
  `docs/design/desktop-window-layout-schema.graphql`, and its example
  operations are `docs/design/desktop-window-layout-operations.graphql`.
  `task design:window-layout-check` checks them.
- `Providers/DesktopProvider/schema.graphql` is the served schema of desktop
  1.0.1. Its display focus receipt already reports `pointerMoved` and the
  `POINTER_BUTTON_HELD` outcome.
- `Sources/KoineCore/CapabilityDisclosures.swift` holds the served desktop
  disclosure texts. Desktop 1.0.1 requires the host feature
  `desktop-disclosures-v1`.
- Modaliser's `MediaKeyEmitter.swift` documents each key number, its source
  header and the packing of `data1`.

## Done when

- A design schema and its example operations cover the pointer position, the
  nudge and the six keys. A Taskfile task checks them.
- Each operation states its authority, its receipt and its failures. The
  refusal while a button is held is an outcome of the nudge, not an error. A
  media key receipt says only that Koine posted the key.
- `docs/specs/machine.md` states the new surface in the desktop contract.
- The "Media" row of `docs/requirements/modaliser-workflows.md` names the six
  keys. In `docs/specs/workflow-providers.md`, the authority row and the
  "Media", "Pointer" and "Grant disclosure" trace rows match the design.
- The disclosure text for desktop read and desktop control is final. A VM
  check establishes whether macOS starts Music when no app holds Now Playing,
  and the text states the result.
- The glossary names the new concepts, such as the Now Playing app, the media
  key and the nudge.
- This task file records the new version numbers, and whether desktop needs a
  new disclosure feature of the host.
- The leaf decides whether `desktop-automation-uses-public-accessibility`
  needs a change about the posted events, and makes the change if so.
- The leaf decides whether its design needs an adversarial review, and it
  cuts the review leaf if so.

## Notes

- The design chooses the operation shapes. For example, the nudge receipt can
  carry the pointer position, or a client can read the position first. One
  media key operation can take the key as an argument, or each key can have an
  operation of its own.
- The position read can also name the display under the pointer, or leave
  that to the client. A client can derive it from the display frames.
- The Music check needs a signed instrument that posts the play/pause key in a
  VM with no player running. Use the cheapest one, and record what macOS did.

## Decisions (running log)

**Design files.** The design goes into two new files:
`docs/design/desktop-pointer-media-schema.graphql` and
`docs/design/desktop-pointer-media-operations.graphql`. The schema file is the
whole desktop 1.0.2 contribution. It keeps every desktop 1.0.1 definition word
for word, and no released type gains a field. The window layout design files
stay unchanged, because they record desktop 1.0.1. A new task,
`task design:pointer-media-check`, checks the new files.

**Position read.** `Query.desktopPointer` returns a `DesktopPointer` with one
field, `location: DesktopPoint!`. The root is null when Koine cannot establish
the position. The wrapper type lets a later release add a field without a
breaking change. The read does not name the display under the pointer. A
client finds that display from the frames of `desktopDisplays`, so a second
answer for the same fact is not needed.

The provider reads the position as Modaliser does: `NSEvent.mouseLocation`,
flipped against the height of the first screen in the same
`NSScreen.screens` reading. With no screen, the position is null. On the host,
a read-only check found the flipped value equal to the location of a
null-source `CGEvent`. The VM witness reads that `CGEvent` location, so the
acceptance compares two independent readings. The read needs no Accessibility
consent.

**Nudge.** `Mutation.desktopNudgePointer` returns a receipt with an outcome,
`NUDGED` or `POINTER_BUTTON_HELD`. The receipt carries no position. A control
receipt carries no read data in this contract, and a position in it would let
a control-only grant read the pointer. A client reads the position under
`desktop:read`.

The provider checks consent first, then the held buttons, then reads the
start. It creates both mouse-moved events before it posts either, so
a failure leaves no half nudge.

**Media keys.** One operation, `Mutation.desktopPostMediaKey(key:)`, takes a
`DesktopMediaKey` with six values. One operation has one authority, one
receipt and one description. The enum description states what each key does.
The receipt echoes the key and says nothing about the player.

The key numbers are Modaliser's: 16, 19, 20, 0, 1 and 7. In the VM, `rcd` turned 19 into
`NextTrack` and 20 into `PreviousTrack`. The acceptance run still settles
whether a player honours them.

**Music check.** `task fixture:media-key-music-vm` posts keys with a signed
probe in a clean VM with no player running. On macOS 27.2.1, play/pause made
`mediaremoted` open Music within one second. Music then took the front from
TextEdit. Next and previous did nothing, because `mediaremoted` dropped them
without an option to open an app.

Volume down and up changed the output volume, which proves that the posts took
effect. The record is
`docs/verification/media-key-music-launch.md`. The disclosure states that
play/pause can make macOS open Music and bring it to the front.

**Consent.** The nudge and the media keys check `AXIsProcessTrusted` before
they post, as every other desktop action checks it. Without consent they report
`os-permission` and post nothing. macOS can drop a posted event from a process
without consent and report no error, so the check makes that case visible. In
the VM, the probe had Accessibility consent and event posting access together.

**Version numbers and host feature.** The application becomes 0.6.0. The
desktop provider becomes release 1.0.2 with schema 1.0.2. The selection
fixtures stamp desktop updates as 1.1.0, so the gap stays as for 1.0.1.

Desktop 1.0.2 requires a new host feature, `desktop-disclosures-v2`. The
Koine 0.6.0 host advertises it together with `desktop-disclosures-v1`, because
its text still states the window layout reach. The released 0.5.0 host lacks
the new feature, so it refuses desktop 1.0.2 before load and keeps its bundled
desktop 1.0.1. The core comment on `workspaceNativeDisclosuresFeature` states
the rule: a feature widens only with a new version.

**Disclosure text.** The final text for `desktop:read` and `desktop:control` is
in "Capability disclosures" of `docs/specs/machine.md`. The read text adds the
pointer position. The control text adds the nudge and the three keys that
reach the Now Playing app. It also adds the change of volume and mute, and the
opening of Music.
It now says "It never clicks, and it never types into an app", because a media
key is a key but types nothing.

**Decision record.** `desktop-automation-uses-public-accessibility` gains three
paragraphs. Display focus already posted an event, and the record did not say
so.

The paragraphs state that a posted event names no element or process. So a
receipt cannot tell who received the event. The media key layout is a
convention, not a documented contract. The paragraphs also record the rejected
MediaRemote route.

The record keeps its title and slug, so no citation changes.
`provider-authority-follows-effects` needs no change, because it already counts
these effects as desktop effects.

**Document placement.** The requirements document was large and had no
markers. Its "Workflow inventory" section converted first, as its own change,
and the other sections went into pending regions. In
`docs/specs/workflow-providers.md`, the touched rows are inside pending tables.
A marker inside a table would break the table, so the rows themselves follow
the rules, as the window layout leaves did.

**Adversarial review.** The design needs one. It fixes a public contract that
clients will code against. It also sets an authority boundary for a pointer
move, and the window layout review found a defect of that kind. The session
inserts `pointer-media-k7`, a `review-design` leaf, before `pointer-k3`.

**Later leaves.** `pointer-k3` serves release 1.0.2, the host feature, the
0.6.0 disclosure and the new profiles. `media-keys-k4` adds the key root to
the composed files. `pointer-media-acceptance-k5` expects the 0.5.0 host to
refuse desktop 1.0.2. It also gets the Music findings that the VM run needs.
