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
- The point query moves from the design into the served SDL and both
  composed files, word for word. Its coordinates leave
  `desktopCoordinatesNotYetImplemented` in `SchemaConformanceTests`, and
  `scripts/conformance-lib.sh` gains a control for its root
  (`window-geometry-k3`).
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

## Decisions (running log)

**The private lookup binds at run time.** Koine calls the same private
`_AXUIElementGetWindow` as Modaliser. It finds the function with `dlsym` when
it first needs it, instead of the `@_silgen_name` declaration of Modaliser. A
strong reference would stop the whole desktop provider from loading if a macOS
release removed the symbol. Without the function, the link uses owner and
bounds alone.

The call also uses the C calling convention that the function
has. A host check resolved the symbol, and a made-up name stayed unresolved.

**Two windows never share one entry.** The contract left this case open. When
two windows give one window number, neither has a link. A link by bounds to an
entry that another window holds by number is no link. Both rules report
unknown where a link could be wrong. The contract now states them.

**Both reads link with the same candidates.** The window list links the
current windows of each application. The point query uses the current windows
of the application that owns its window. It adds that window when the
application does not enumerate it now. So the two reads link a window in the same way.

**Missing bounds make the point answer unknown.** The linked entry with no
bounds gives `UNKNOWN`. An opaque entry in front with no bounds gives `UNKNOWN`
too, unless another entry covers the window. Modaliser skips such an entry and
assumes visible. The contract now states the rule.

**The window-server list is read after the Accessibility reads.** The window
list reads every frame and window number first, and then it reads the list
once. The point query does the same for its application. When the listing of
that application fails, the point query reports `failed`, as the window list
does.

**The trace rows change in place.** The two rows sit inside a pending region
of a Markdown table. A marker line inside the table would break it. So the
changed rows use controlled English, as `window-geometry-k3` did, and the
region marker stays.

**A workspace test fails on this host for an unrelated reason.**
`aBundleWithinTheLimitWhoseInfoPlistIsTooLongForThePlatformIsFailedNamingTheCause`
fails for 1023 bytes, because the message does not contain "File name too
long". Its own comment records the observation on macOS 26.5, and this host
runs macOS 27.2.1. This leaf changes no workspace file, and the failure repeats
alone. No GitHub issue tracks it yet. A public issue is the decision of the
human, so the release leaf or the human files it.

**No adversarial review before acceptance.** The design passed its adversarial
review in `window-layout-k8` and `window-layout-k9`. This leaf follows that
contract, and its L tests went red under four mutations of the rules.

The VM
acceptance in `window-layout-acceptance-k6` compares order and visibility with
an independent witness. It covers overlapping windows of two applications and
two TextEdit windows with equal bounds. That witness is the independent
challenge of the load-bearing behaviour. A change of the private binding is a
later provider release, so the decision is not hard to reverse.

**Verification.** The L suite passed 46 tests, and four mutations of the rules
each turned it red. The G and conformance suites passed 54 tests. A mutation of
the point query authority turned the authority test red. `task conformance`
held both headless profiles, and the two new controls went red.

The VM profile
needs the signed application in a TestAnyware VM, which belongs to
`window-layout-acceptance-k6`. `task design:window-layout-check` passed. The
full `task test` passed, except the unrelated workspace test above.

No GUI
step ran on the host, and the test process had no Accessibility consent. So
the G test of the point answer for a live window returned early, and the VM
run holds that path.
