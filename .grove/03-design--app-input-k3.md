# app-input-k3

## Goal

Design the input provider for Koine 0.7.0 from the evidence of
`keystroke-route-k2`. It covers target capture, the keystroke operation and
Space switching. Write the design into the durable documents that the root
brief's "Docs" item names.

## Context

- The design leaf of the pointer and media grove is the precedent. Its schema
  is `docs/design/desktop-pointer-media-schema.graphql`, and its example
  operations are `docs/design/desktop-pointer-media-operations.graphql`.
  `task design:pointer-media-check` checks them.
- The verification record of `keystroke-route-k2` holds the probe's evidence.
  It says how Koine reads the shortcut settings and counts Spaces.
- `Providers/DesktopProvider/schema.graphql` shows the process identity
  `{ pid, startedAt }` and the receipt of `desktopPostMediaKey`.
- `Sources/KoineCore/CapabilityDisclosures.swift` holds the served disclosure
  texts. `Sources/KoineCore/Composition.swift` names the features of the host,
  such as `desktop-disclosures-v2`.
- The workflow providers spec gives Space switching an additional capability
  requirement for desktop control. The framework feature
  `additional-capabilities-v1` supports it.

## Done when

- A design schema and its example operations cover target capture, the
  keystroke operation and Space switching. A Taskfile task checks them.
- Each operation states its authority, its receipt and its failures. A target
  that is not the front app is a refusal that sends nothing.
- The design names the refusals for a stale target, a protected target, an
  unknown key, a disabled or remapped shortcut and a missing Space.
- The design states how Koine decides that the target is the front app. It
  also lists the consent and security dialogs that Koine recognises.
- The input contract states the new surface. The leaf chooses whether that
  contract is a section of `docs/specs/machine.md` or a spec of its own.
- In `docs/specs/workflow-providers.md`, the authority rows and the trace rows
  "Desktop windows", Safari to Zotero and "Grant disclosure" match the design.
- The leaf checks the requirements rows "Desktop windows" and Safari to Zotero
  against the design, and it changes any row that disagrees.
- The disclosure text for input read and input control is final. It says that
  a chord sent to a terminal can type and run commands.
- The descriptions state the two limits of the root brief.
- The glossary names the new concepts, such as the chord, the front app, the
  protected target and the Space switch.
- `desktop-automation-uses-public-accessibility` accepts per-process posting.
  It also accepts how Koine reads the shortcut settings and counts Spaces.
- This task file records the new version numbers, and whether input needs a
  disclosure feature of the host.
- The leaf names the documents that each implementation leaf brings to the
  served state, the README and the client guide among them.
- The leaf decides whether its design needs an adversarial review, and it
  cuts the review leaf if so.

## Notes

- If the count of Spaces needs a private call, ask Antony before the design
  adopts it. His ruling on private calls covers Modaliser's mechanisms, and
  Modaliser counts no Spaces.
- The design chooses the operation shapes. For example, the keystroke
  operation can take a key and a set of modifiers, or a chord string such as
  "cmd+shift+t".
- Target capture can read the front app, as Modaliser reads it to choose a
  screen. A client then sends chords to that captured target.
- A refusal after the first event can leave a modifier key down in the
  target. State whether any refusal can occur after the first event.
