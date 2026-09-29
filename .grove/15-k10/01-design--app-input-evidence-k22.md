# app-input-evidence-k22

## Goal

Establish, from the signed hardened Koine in an isolated VM, how synthesized
keyboard input reaches a specific captured application. Establish what can be
observed when the target is not foreground or changes during delivery.

## Context

- The spec's process-capture rules and accepted public Accessibility limits.
- Modaliser's input library and app trees show how the configured shortcuts
  are sent today. They are evidence of intended results, not of correctness.

## Done when

A `docs/verification/` document answers:

- Is event delivery addressed to a process reliable for the configured
  applications' shortcuts? Compare it with posting to the session after
  checking the target is foreground. Say which shortcuts need the target
  foreground and key-focused.
- What happens when the foreground changes between the check and delivery?
  What part of that race is an accepted limit, stated as the existing
  Accessibility limits are?
- Do bounded Control-digit events switch Spaces, and what shows the switch
  happened? How is a disabled/remapped binding refused without changing settings,
  and what can fall through to the foreground app during a race? This is a
  system-directed operation with input plus desktop authority, not delivery to
  the captured application.
  Check that an input-only delivery path cannot dispatch the same system
  shortcut as an alternate route; refuse it if the mechanism cannot separate it.
- Can the mechanism enforce refusal of Koine's own UI at capture and delivery,
  including session-directed paths? How are consent/security targets recognized,
  and what is refused when safe delivery cannot be established? Exercise the
  actual management UI in the isolated VM; do not assert a general OS sandbox.
- How are shortcuts represented so that keyboard layout does not change their
  meaning?

It ends with a recommendation for `app-input-k34`.

## Notes

This question is bounded. Do not chase a guarantee public API cannot give;
record it as a limit.
