# iterm-evidence-k26

## Goal

Establish which iTerm integration mechanism the signed Koine can use, and what
each yields. Today Koine runs under the hardened runtime with an empty
entitlements file.

## Context

- The spec's "Native extensions" loading and trust sections, and ADR
  `open-source-release-and-distribution`: notarized, hardened and no
  entitlements.
- Modaliser's iTerm host library and pane/tab blocks, which use AppleScript,
  Accessibility frames and key bindings.

## Done when

A `docs/verification/` document compares, from the signed Koine in an isolated
VM, these candidates:

- AppleScript or Apple Events, which need the apple-events entitlement, a usage
  description and per-application Automation consent;
- iTerm's Python API, with its enablement and authentication;
- synthesized key bindings through `app-input`;
- Accessibility.

For each it reports:

- stable session and tab identity;
- titles, the current tab, and process and working directory;
- pane frames associated with a session without walk-order guessing;
- split, move, zoom, copy mode and tab operations;
- the prerequisites, and how setup can be made explicit and discoverable.

It ends with a recommendation for `iterm-k41`.

## Notes

A recommendation that adds an entitlement or a new consent changes the
release's signing posture. Record it as a decision and raise it with Antony
before `iterm-k41` builds on it. This question is bounded; unavailable
identity becomes a stated limit.
