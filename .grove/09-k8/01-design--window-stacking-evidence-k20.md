# window-stacking-evidence-k20

## Goal

Establish, in an isolated VM under the signed Koine, what public API can
report about the order and visibility of windows across applications. That
state must be associated with the desktop provider's held Accessibility window
elements. Establish too whether display transfer can be accepted in a VM at
all.

## Context

- ADR `desktop-window-identity-is-a-held-element`. It rejects the private window
  number and window-list bounds as identity, and records that window-list names
  need Screen Recording consent.
- ADR `desktop-automation-uses-public-accessibility` and the spec's accepted
  limits.
- Modaliser's window-list block places labels by walking stacking order and
  subtracting occluding windows. That is the observed need, not a mechanism to
  copy.

## Done when

A `docs/verification/` document answers the following, each with the observed
failure cases:

- Can public API give front-to-back order and on-screen visibility across
  applications without Screen Recording or private API? Candidates include
  window-list order with owner and bounds, per-application Accessibility order,
  and activation history.
- Can that order be associated with held window elements unambiguously? Report
  where it cannot: equal frames, minimised windows, other Spaces, full-screen,
  off-screen, and sheets or panels.
- Can a TestAnyware macOS VM present more than one display? If not, what does
  acceptance of display transfer and display focus require?

It ends with a recommendation for `window-layout-k31`: which stacking and
visibility values are knowable, and where the state must be reported unknown.

## Notes

This question is bounded. Where public API cannot establish an association,
the answer is that the state is reported unknown and the limit is stated. It is
not a deeper evidence chain; if the guarantee is not there, stop there.
