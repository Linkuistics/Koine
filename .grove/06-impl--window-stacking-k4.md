# window-stacking-k4

## Goal

Serve each window's front-to-back order and visibility with Modaliser's
mechanism, as the design of `window-layout-k2` defines them.

## Context

- The contract is "The window-server link" and "Visibility at a point" in
  `docs/specs/machine.md`, under "Window layout".
- Modaliser orders windows in `WindowEnumerator.swift`. It decides
  visibility in `WindowLibrary.swift`, in `windowVisibleAtFunction` and the
  label-placement walk.
- Modaliser declares the private `_AXUIElementGetWindow` lookup with
  `@_silgen_name`.

## Done when

- Order and visibility come from the private window-number lookup first.
  Where the lookup disagrees with the window server's list, they come from
  owner and bounds. Otherwise they are unknown.
- An entry with an alpha below 1 does not cover a window, as in Modaliser.
  Unlike Modaliser, Koine's own windows cover, because Koine draws no labels.
  Koine reports unknown where Modaliser assumes visible.
- The point answer tests the bounds of the linked entry, not the window
  frame. The 2-point tolerance decides only whether the link holds
  (`window-layout-k9`).
- L tests feed plain values through the three ordering steps and the
  visibility rules. G tests cover authority and unknown values.
- The session decided whether an adversarial review is necessary before
  acceptance. If it is, the session inserts a `review-impl` leaf before
  `window-layout-acceptance-k6`.

## Notes

- The lookup orders windows and never identifies them. Every action still
  goes to the held element.
- This leaf brings the first private API into the shipped product. Three
  texts say "public macOS Accessibility" today, so they change with it: the
  README, the client guide and "Public GraphQL contract" in
  `docs/specs/machine.md`.
