# app-input-k34

## Goal

Design input delivery and Space switching, and the intended result of every
configured app-shortcut row.

## Context

- `app-input-evidence-k22`'s findings.
- `provider-architecture-k5`'s authority allocation and cross-provider
  reference decision.
- Requirement rows Safari, Dia's ordinary operations, Finder, Mail, Slack,
  Zed, Signal, Messages, Telegram, Obsidian and Zotero, plus Space switching.
- The configured app trees give the bindings and their labels. The executable
  bindings govern where comments are stale.

## Done when

The spec, and an ADR where a decision clears the bar, state:

- the operations: semantic per-app or generic chord delivery;
- the key representation;
- how the target is named and preserved;
- any foreground precondition;
- results, including the unknown-outcome rule;
- errors and authority.

A table records each configured shortcut's intended result and the mechanism
that achieves it, keystroke or menu invocation. Rows that are unverified or
account-dependent are marked for `account-acceptance`. The VM acceptance cases
are listed.

## Notes

Do not freeze a known shortcut bug into the contract. Where the intended result
is ambiguous and the configuration cannot settle it, ask Antony with a
recommendation.
