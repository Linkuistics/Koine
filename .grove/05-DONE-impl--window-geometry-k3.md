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

## Decisions (running log)

**The served SDL is the design, restricted.** The desktop 1.0.1 schema serves
the design verbatim without the point query and display focus. Those two root
fields and the types that only they reach (`DesktopPointInput`,
`DesktopOnTop`, `DesktopDisplayFocusReceipt` and
`DesktopDisplayFocusOutcome`) arrive with `window-stacking-k4` and
`display-focus-k5`. The release numbers stay 1.0.1 until the release, because
no build ships before 0.5.0. This follows the workspace precedent, where a
profile held the design restricted to the implemented roots.

**Frame setting is one turn on the provider queue.** Identity, the toggle of
`AXEnhancedUserInterface`, the writes and the repeat run in one turn. So
nothing comes between the identity check and the writes, and the setting is
always turned on again. The cost is that other desktop calls wait up to about
350 ms behind a repeat. A failure to turn the setting on again reports
`failed`, because the operation then left a side effect.

**One application that does not answer fails the window list.** The list
reports `failed` with the name of that application. A list without its windows
would claim a false complete list. Partial results for an unresponsive
application are hardening, so they become a GitHub issue rather than work here.

**Disclosures state the whole 0.5.0 reach now.** The two desktop entries use
the contract's first draft as it stands. They name order, visibility and
display focus, although later leaves serve those. No build ships between this
leaf and the release, and the feature `desktop-disclosures-v1` must not widen
afterwards.

**Two composed files and two profiles.** The headless host of this tree serves
core and desktop 1.0.1, and the signed application adds workspace 1.0.2. So
each gets a composed design file and a profile:
`core-desktop-window-layout-extension-host` for `task conformance`, and
`core-desktop-window-layout-workspace-extension-host` for the VM conformance
check. A test holds each composed file to the design, less the coordinates not
served yet. The desktop 1.0.0 files and profiles stay, because the released
desktop provider still serves them.

**The update profiles follow the tree.** The selection checks build the desktop
update 1.1.0 from this tree, so it serves schema 1.0.1. The update profiles now
pin schema 1.0.1 for it and use the window layout compositions. The bundled
desktop in the production host is 1.0.1. The released host now refuses the
desktop update for two missing features, and the loader names both.

**The workspace compatibility pairs compose the released desktop.** Every
workspace profile pins desktop 1.0.0, and those pairs test workspace. So they
now compose the desktop provider of the released revision instead of the
desktop of this tree. Without this change, every workspace pair would fail on
the desktop half alone.

**The VM disclosure script expects the desktop disclosures.** The window now
presents the served desktop text where `scripts/vm-verify-disclosure.sh` asserted
none. Nobody has run the changed script yet. Its first run belongs to
`window-layout-acceptance-k6`.

**The released-baseline host states the released release.** The `desktop-old`
selection host is the shipped catalogue around the released desktop 1.0.0.
The shipped catalogue now names 1.0.1, so that host rejected the released
bundle as `catalogue-bundle-mismatch`. Its definition now states release and
schema 1.0.0 for desktop (`releasedBaselines` in
`Fixtures/SelectionHost/hosts.json`), as the catalogue that shipped that
bundle did. The catalogue match check holds the entry to that override.
