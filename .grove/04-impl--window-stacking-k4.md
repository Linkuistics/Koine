# window-stacking-k4

## Goal

Serve each window's front-to-back order and visibility with Modaliser's
mechanism, as the design of `window-layout-k2` defines them.

## Context

- Modaliser orders windows in `WindowEnumerator.swift`. It decides
  visibility in `WindowLibrary.swift`, in `windowVisibleAtFunction` and the
  label-placement walk.
- Modaliser declares the private `_AXUIElementGetWindow` lookup with
  `@_silgen_name`.

## Done when

- Order and visibility come from the private window-number lookup first.
  Where the lookup disagrees with the window server's list, they come from
  owner and bounds. Otherwise they are unknown.
- Visibility skips translucent overlays and Koine's own windows, as
  Modaliser does. It reports unknown where Modaliser assumes visible.
- L tests feed plain values through the three ordering steps and the
  visibility rules. G tests cover authority and unknown values.
- The session decided whether an adversarial review is necessary before
  acceptance. If it is, the session inserts a `review-impl` leaf before
  `window-layout-acceptance-k6`.

## Notes

- The lookup orders windows and never identifies them. Every action still
  goes to the held element.
