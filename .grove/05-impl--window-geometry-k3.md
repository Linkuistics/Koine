# window-geometry-k3

## Goal

Serve the window list with frames, the display list, frame setting and the
disclosure, as the design of `window-layout-k2` defines them.

## Context

- The design is `docs/design/desktop-window-layout-schema.graphql`, with
  operations in `docs/design/desktop-window-layout-operations.graphql`. The
  contract is "Window layout" and "Capability disclosures" in
  `docs/specs/machine.md`. `task design:window-layout-check` holds the design.
- Modaliser's `WindowCache.swift` lists windows across applications. Its
  `WindowManipulator.swift` sets frames, lists displays and converts visible
  frames into screen coordinates.
- The desktop provider lists one application's windows today, through its
  window table of held elements.

## Done when

- The window list, the display list and frame setting are served with their
  designed authority, with L and G tests.
- Frame setting disables `AXEnhancedUserInterface` during the writes. It
  repeats the write until the size matches, as the contract states.
- The display list follows the display table in the contract. It leaves out
  a display with empty bounds. A visible frame is null when no AppKit screen
  matches, or when the converted frame is outside the display's frame. A
  failed `CGGetActiveDisplayList` reports `failed`. L tests cover both null
  cases (`window-layout-k9`).
- The core advertises `desktop-disclosures-v1`, and the desktop provider
  requires it. The Settings window, the management catalogue and the GraphQL
  descriptions carry the disclosure.
- The desktop provider is release 1.0.1 with schema 1.0.1, in its manifest and
  in `App/ProviderCatalogue.json`.
- The served SDL has a new composed design file and a profile beside the
  earlier ones. The earlier profiles still pass.
- The desktop contract, the trace rows, the README and the client guide
  describe what this leaf serves.

## Notes

- Order and visibility belong to `window-stacking-k4`. Until that leaf, the
  window list serves every order as null and every visibility as `UNKNOWN`,
  or `OFF_SCREEN` from public facts.
- `desktop-schema.graphql` and `desktop-operations.graphql` stay unchanged.
  The old-host profile and the contract-only client depend on them.
- `scripts/build-selection-real.sh` builds the desktop update from this tree
  as release 1.1.0. That update now serves the new schema. So the update
  profiles that state "an update adds no schema" need a decision here.
