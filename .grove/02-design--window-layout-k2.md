# window-layout-k2

## Goal

Design the public surface of the window layout first cut, so that the
implementation leaves serve one agreed contract.

## Context

- The root brief's "Done when" lists every surface and behaviour. The
  running log of `plan-k1` holds the human's decisions and their reasons.
- No design schema covers window geometry yet. The desktop design schema is
  `docs/design/desktop-schema.graphql`, with operations in
  `docs/design/desktop-operations.graphql`. The served schema is
  `Providers/DesktopProvider/schema.graphql`.
- Modaliser's window layer (root brief, Pointers) holds the native mechanics.
  Its window rows carry a window number, an owner and bounds. It decides
  visibility from the window server's list.

## Done when

- The design schema and operations define every read and operation in the
  root brief's "Done when". Each value that Koine may not establish has an
  explicit unknown form.
- The design fixes one coordinate space for window frames, display frames
  and screen points, and the contract states it.
- The desktop contract in `docs/specs/machine.md` describes order,
  visibility, display identity, frame setting and display focus, with their
  failure results.
- The trace rows "Desktop windows", "Displays", "List and label state" and
  "Grant disclosure" in `docs/specs/workflow-providers.md` name the planned
  coordinates and capabilities.
- The two decision records named in the root brief's Pointers change in
  place, and every citation of them is reconciled.
- The glossary states each term that the design resolves. Its entry
  **Public Accessibility boundary** admits the private lookup for ordering.
- The disclosure has a first draft for the Settings window and the GraphQL
  descriptions.
- The session decided whether the design needs an adversarial review. If it
  does, the session inserts a `review-design` leaf before
  `window-geometry-k3`.

## Notes

- Choose how a client asks about visibility at a point. Modaliser's
  `window-visible-at?` takes a window and a point and answers yes or no.
- Choose how a display is identified. Modaliser uses its `CGDirectDisplayID`.
- Choose whether frame setting takes absolute points or fractions of a
  display. The client computes every layout in either form.
- Choose what display focus does when the front window's order is unknown.
  It must not guess.
- If the design finds a slice of the decomposition wrong, reshape the later
  leaves before retiring.
