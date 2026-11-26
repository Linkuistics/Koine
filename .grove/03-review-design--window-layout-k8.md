# window-layout-k8

**Reviews:** window-layout-k2

## Goal

Try to break the window layout design before three implementation leaves
build on it.

## Context

- The artifact is the design that `window-layout-k2` committed:
  - `docs/design/desktop-window-layout-schema.graphql` and
    `docs/design/desktop-window-layout-operations.graphql`.
  - The "Window layout" subsection and the desktop disclosure draft in
    `docs/specs/machine.md`.
  - The trace rows "Desktop windows", "Displays", "List and label state" and
    "Grant disclosure" in `docs/specs/workflow-providers.md`.
  - The two changed decision records,
    `desktop-window-identity-is-a-held-element` and
    `desktop-automation-uses-public-accessibility`.
  - The new glossary terms and the amended **Public Accessibility boundary**
    in `CONTEXT.md`.
  - `task design:window-layout-check` in `Taskfile.yml`.
- The contract that the design must meet is the root brief's "Done when". The
  running log of `plan-k1` holds the human's decisions and their reasons.
- Modaliser is the reference implementation (root brief, Pointers).

## Done when

- Each finding names its location in the artifact, a concrete failure
  scenario, and the requirement or rule that it breaks.
- If a finding is worth acting on, the session cuts an
  `integrate-review-design` leaf as its last act. With no such finding, it
  cuts nothing.

## Notes

These are questions to test, not conclusions:

- Can a client get a known value that is false: an order, a visibility or an
  on-top answer? Examine the two link steps, the 2-point tolerance and windows
  with equal bounds.
- `docs/verification/desktop-window-identity.md` found layer-0 entries in the
  window server's list that are no windows. Can such an entry cover a window
  at a point, or block display focus?
- Does every value that Koine may not establish have an unknown form? Include
  a frame of a window on another Space and the display list.
- Does display focus guess in any case? Consider a window across two displays
  and a full-screen window. Also consider an unknown frame on another display
  and the Settings window of Koine.
- Is every value in the one coordinate space? Include `NSScreen.visibleFrame`
  on a display above the primary display.
- Does any effect lack its capability in the trace? Include the toggle of
  `AXEnhancedUserInterface`, the pointer move and its mouse-moved event. Could
  the event post ask for a new consent?
- Do release 1.0.1 and the host feature `desktop-disclosures-v1` hold against
  the selection fixtures, the conformance profiles and the released 0.4.1
  host?
- Are the two decision records a minimum coherent set, with every citation
  reconciled?
- Does the disclosure draft state the reach for a new grant request and for an
  existing grant after the upgrade?
