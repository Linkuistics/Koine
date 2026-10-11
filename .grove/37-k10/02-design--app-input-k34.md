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
- any foreground precondition, and the race left between checking the target
  and native delivery, as a stated limit;
- results, including the unknown-outcome rule;
- errors and authority.

A table records each configured shortcut's intended result and the mechanism
that achieves it, keystroke or menu invocation. Menu-invocation rows are marked
for `menu-bar`. Account-dependent rows, including the annotated Signal and
Messages chords, are marked for `account-acceptance`. Every other row is
accepted in VMs by this increment or, for menu invocation, by `menu-bar`. The
VM acceptance cases are listed.

## Notes

Do not freeze a known shortcut bug into the contract. Where the intended result
is ambiguous and the configuration cannot settle it, ask Antony with a
recommendation.
