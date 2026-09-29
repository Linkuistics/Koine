# menu-bar-k11 — brief

## Goal

A client inspects the selected application's menu bar. It sees nested
submenus in order, with labels, separators, enabled and checked state, keyboard
shortcuts, and whether a submenu still needs opening. It can invoke a currently
valid item under menu-invocation authority. A stale selection is rejected and
never substituted.

## Done when

- The requirement's hierarchy-and-state scenario is demonstrated in VMs across
  the kinds of menu the configured applications present:
  - Unavailable metadata is distinguished from actual state and not
    fabricated.
  - Disabled items are inspectable but cannot be invoked as enabled.
  - Icons are not required.
- A submenu whose contents are not yet available is reported as needing
  opening, not as an empty completed list. An inaccessible or unsupported menu
  is reported as such.
- Passive inspection does not open menus or change the desktop. The
  read-purity question is decided and recorded: whether passive population
  counts as changing the desktop.
- Validation passes the acceptance cases:
  - A replaced Open Recent entry is rejected.
  - After an unrelated sibling change, the validated original item is invoked
    or the selection is reported unavailable. A replacement is never invoked.
  - Duplicate titles are not identity.
  - Disabled or removed items are refused.
  - Consent and authority losses keep their permission classifications.
- Each app-shortcut row that `app-input` assigned to menu invocation reaches
  its intended outcome in VMs through validated invocation. A row whose item
  needs explicit opening passes to `context-menus`. An account-dependent row's
  outcome is recorded as pending for `account-acceptance`.
- Menu-invocation authority can be granted without input, and read-only,
  focus-only, denied and revoked grants cannot invoke. The unknown-outcome and
  no-replay rules hold. Trace rows are added.

## Decomposition

1. `design` evidence: native menu exposure, covering context menus and opening
   too, so `held-interactions` and `context-menus` build on one evidence base.
2. `design`: menu references, listing and invocation.
3. `planning`: cut implementation leaves.

## Notes

Explicit opening, context menus and cleanup of opened menus belong to
`context-menus`, which reuses `held-interactions`' lifecycle. Status-item and
Dock menus are deferred and receive no design or acceptance here. Apple's
menu-update contract lets contents change when a menu opens. Its show-menu
action is an explicit contextual-menu effect. Neither shows that every
application exposes every menu through one mechanism.
