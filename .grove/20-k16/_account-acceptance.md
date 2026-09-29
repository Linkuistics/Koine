# account-acceptance-k16 — brief

## Goal

Verify the account-dependent intended outcomes for Signal, Slack, Telegram,
Messages and Mail in isolated VMs, using dedicated test accounts and data.
Check the annotated Signal and Messages chords against their intended results.

## Done when

- The accounts, and the conversations and messages the actions need, exist
  only inside isolated VMs, never on Antony's live desktop. Provisioning is
  repeatable through the Taskfile where the services allow it.
- Each account-dependent shortcut's actual outcome is recorded with the
  application versions.
- A shortcut found to produce the wrong result is corrected through new work,
  not frozen into the contract.
- An account or data set that is unavailable leaves its cases pending, each
  recorded with the account or data it needs. A documented untested limitation
  does not pass them. This node may close with cases pending.
  `baseline-acceptance` keeps them as live work, and none counts as passed.

## Decomposition

1. `impl` (HITL): provision the test accounts and data with Antony.
2. `impl`: run and record the acceptance.

## Notes

This increment sits late so that waiting on human-supplied accounts does not
stall the AFK increments before it. `app-input` implements these shortcuts and
records their account-dependent acceptance as pending until this node runs.
