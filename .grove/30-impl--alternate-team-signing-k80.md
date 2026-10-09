# alternate-team-signing-k80

## Goal

Close the selection and trust acceptance cases that need code signed by a
second real Developer ID team:

- a differently team-signed host derives its own team;
- a per-user bundle signed by another team is refused before load, recording
  what the kernel does behind Koine's check.

## Context

- `docs/specs/machine.md`, "Selection acceptance": the trust-refusal row and the
  alternate-team host row. Also the "Mismatched signing identities" open item in
  "Acceptance status".
- The cases `selection-acceptance` recorded as pending.

## Done when

- With Antony, a second team's signing identity is made available for use in
  isolated VMs only, never on the live desktop. If Antony decides against that,
  record the decision.
- If available: the pending N, G and V cases run, and Machine's table and
  acceptance status link the evidence.
- If not: the cases stay pending as live work. `baseline-acceptance` does not
  close around them.

## Notes

HITL. This sits late so that waiting on a human-held certificate does not stall
the AFK increments. If `selection-acceptance` already closed these cases because
a certificate was available then, confirm that and retire.
