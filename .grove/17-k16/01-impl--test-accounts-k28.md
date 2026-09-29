# test-accounts-k28

## Goal

Provision dedicated test accounts and data for Signal, Slack, Telegram,
Messages and Mail inside isolated TestAnyware macOS VMs. Each application must
have the conversations and messages its configured actions act on.

## Context

- The requirements' test-accounts paragraph, and `app-input-k34`'s table of
  account-dependent shortcuts.
- Use the `testanyware:using-testanyware` skill for VM work.

## Done when

For each application, one of two things holds:

- A provisioned account and data set is usable in a VM, with repeatable
  preparation captured as a Taskfile task where the service allows it.
- The account is recorded as unavailable, and the affected cases stay pending.

No credential or personal data lands in the repository.

## Notes

This is HITL. Signal and Telegram need a phone number, Messages needs an
Apple Account, and Slack needs a workspace. Ask Antony what he can supply, with
a recommendation for each service. Never use his live desktop or accounts.
