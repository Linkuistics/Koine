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
