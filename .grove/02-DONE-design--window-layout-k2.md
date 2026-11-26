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

## Decisions (running log)

**Design files.** The design goes into two new files:
`docs/design/desktop-window-layout-schema.graphql` and
`docs/design/desktop-window-layout-operations.graphql`. The files that the
Context names stay unchanged. The `core-desktop-old-host` profile holds
`desktop-schema.graphql` to the released 0.1.0 host. The contract-only client
checks `desktop-operations.graphql` against a captured released schema.
The new schema file is the whole desktop contribution, as the workspace
design files are.

**Coordinate space.** Every frame and point uses one space, screen
coordinates. Its unit is the point, and its origin is the top-left corner of
the primary display. The x axis grows to the right, and the y axis grows
downward. Accessibility window frames, the window server's bounds,
`CGDisplayBounds` and the pointer use this space already. A visible frame
comes from `NSScreen.visibleFrame`, flipped against the full height of the
primary display, as Modaliser flips it.

**Display identity.** A display is a resource reference,
`koine://desktop/display/<CGDirectDisplayID>`. A reference to a display that
is no longer online is `unavailable`. The design rejects a bare number field,
because a client must not construct a reference. It rejects the display UUID
for this cut, because no operation needs more than the online check.

**Frame setting.** Frame setting takes absolute screen coordinates, the same
form that the reads return. A restore writes back a frame that the client
read. Fractions of a display would add a second form and a display argument,
and the client computes layouts in either form.

**Visibility at a point.** A root query takes a window reference and a screen
point. It answers `ON_TOP`, `NOT_ON_TOP` or `UNKNOWN`. This keeps the shape of
Modaliser's `window-visible-at?` and adds the unknown answer. A hit test that
names the top window was rejected. It would have to name entries that are no
listed window, such as the Dock.

**Unknown forms.** A frame or an order that Koine cannot establish is null.
Each list row's visibility is `ON_SCREEN`, `OFF_SCREEN` or `UNKNOWN`. The
point query answers `UNKNOWN`. An enumeration carries the yes, no and unknown
facts, so that a client meets the unknown case in its own switch. A number or
a rectangle has no value that can mean unknown, so it is null.

**The window-server link.** Koine links a held element to a window server
entry in two steps. First, the private lookup gives a window number. The link
holds when the on-screen list has that number under the same process, with
bounds within 2 points of a known frame. Second, a unique layer-0 entry of
the same process with bounds within 2 points of the frame links it.

No other window of that process may have a frame that matches the same
bounds. Otherwise order and visibility are unknown. A minimised window, or a
window of a hidden application, is `OFF_SCREEN` from public facts alone.

**Cover at a point.** Every opaque window server entry in front of the window
covers it where its bounds contain the point. An entry with an alpha below 1
does not cover, as in Modaliser. Koine's own windows cover too, unlike
Modaliser's chips.

Koine draws no labels, and its Settings window really covers what is behind
it. A client asks before it draws its own labels. This changes the
visibility rule in `window-stacking-k4`.

**Display focus without a known front window.** A window belongs to a display
when the centre of its frame is in the display's frame, as in Modaliser.
Display focus raises nothing when a candidate window on that display has an
unknown frame, visibility or order. It still moves the pointer, and its
receipt says `FRONT_WINDOW_UNKNOWN`. While a pointer button is held, display
focus acts on nothing and says `POINTER_BUTTON_HELD`. The authority table
forbids pointer movement that turns into a drag.

**Version numbers and host feature.** The application becomes 0.5.0. The
desktop provider becomes release 1.0.1 with schema 1.0.1. The selection
fixtures stamp desktop updates as 1.1.0, so 1.1.0 would collide with them.
The workspace releases 1.0.1 and 1.0.2 keep the same gap.

The provider requires a new host feature, `desktop-disclosures-v1`. So the
released 0.4.1 host refuses it before load, because that host cannot
disclose the wider reach. This applies the reasoning of
`native-workspace-requires-disclosure-capable-host` to desktop.

**Adversarial review.** The design needs one. It fixes a public contract that
clients will code against, and a change after the release costs a contract
change. It also widens an identity decision record with private API. The
session inserts a `review-design` leaf before `window-geometry-k3`.

**Later leaves.** The session reshaped four leaves to match the design.
`window-geometry-k3` serves release 1.0.1, the host feature and a new
composed profile. Until `window-stacking-k4`, its list has no known order.
`window-stacking-k4` takes the cover rule above and updates three texts that
say "public macOS Accessibility".

`display-focus-k5` gains the two extra outcomes. `window-layout-acceptance-k6` expects the 0.4.1 host to refuse the
new provider before load.
