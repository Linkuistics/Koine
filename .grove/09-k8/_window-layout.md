# window-layout-k8 — brief

## Goal

A client can:

- list windows across running applications, with the geometry and
  stacking/visibility state needed to place labels over them;
- place a window in thirds, half-thirds, two-thirds, halves or quarters, or
  maximise or centre it, and restore its prior geometry;
- list displays, move a window to another display while preserving its
  position and size as fractions of the visible areas, and focus a display.

## Done when

- The Desktop windows row, except Space switching, and the Displays row are
  demonstrated through public operations. Space switching belongs to
  `app-input`.
- Window label state is public:
  - screen geometry tied to each window reference;
  - the stacking and visibility information needed to account for occlusion;
  - a location that is unavailable, as for minimised or other-Space windows,
    distinguishable from a known one, with no fabricated coordinates.
  Label assignment, placement and drawing are recorded as client
  responsibilities. Any display geometry left for the client to read is
  identified explicitly.
- Restore's ownership is decided and recorded: Koine or the client remembers
  the prior geometry. Windows that refuse a geometry, such as fixed-size or
  full-screen windows, are reported rather than silently ignored.
- Geometry and display focus carry the allocated authority. A read-only or
  focus-only grant cannot deliver input or invoke menus.
- VM acceptance covers occlusion and stacking, visible and unavailable
  targets, restore and display transfer, with trace rows added.

## Decomposition

1. `design` evidence: global stacking and visibility through public API.
2. `design`: the API.
3. `planning`: cut implementation leaves.

## Notes

This increment extends the existing desktop provider unless
`provider-architecture` places it elsewhere. The held-element window identity
stands. Any association used for stacking is presentation state and is never
used for targeting.
