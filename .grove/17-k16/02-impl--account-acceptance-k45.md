# account-acceptance-k45

## Goal

Run the account-dependent acceptance for Signal, Slack, Telegram, Messages and
Mail through the public operations, and record the actual outcomes.

## Context

- `test-accounts-k28`'s provisioned accounts, or its record that an account is
  unavailable.
- `app-input-k34`'s intended-result table, and `menu-bar`'s design where a row
  uses menu invocation.

## Done when

- Each configured shortcut's actual outcome is recorded with application
  versions, including the annotated Signal and Messages chords.
- Cases without an account stay pending.
- A wrong shortcut gets a leaf to correct it rather than a documented
  limitation.
- The trace rows show the result.
