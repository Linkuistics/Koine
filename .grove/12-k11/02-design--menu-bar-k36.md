# menu-bar-k36

## Goal

Design menu-bar discovery and validated invocation.

## Context

- `menu-evidence-k23`'s findings.
- `provider-architecture-k5`'s authority and classification decisions.
- The requirements' "Application-menu requirements", including the accepted
  conservative-invalidation trade-off.

## Done when

The spec, and an ADR where a decision clears the bar, state:

- how a menu and an item are referenced, and how long a reference lives;
- how an item is revalidated. It is never matched by title, ordinal or menu
  path.
- the listing shape and metadata, with unknown distinct from false;
- the needs-opening and unsupported reports;
- the read-purity rule for passive inspection;
- the invocation result and errors;
- authority;
- the VM acceptance cases for each configured application's menu kind.

## Notes

Leave explicit opening to `context-menus`, but name the references so opened
submenus and context menus can share them.
