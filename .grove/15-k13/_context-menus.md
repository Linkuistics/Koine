# context-menus-k13 — brief

## Goal

A client selects a context-menu target, by a specified screen point or by the
keyboard-focused UI element, and explicitly opens that context menu. It can
also explicitly open a menu-bar submenu when discovery needs it. It inspects
and invokes as in `menu-bar`, then finishes or cancels. Koine cleans up opened
menus through `held-interactions`' lifecycle.

## Done when

- Both target modes work, and discovery and selection stay associated with the
  chosen target. A later pointer move or foreground change does not retarget.
- A point that lands on another application's element or on a client overlay
  is handled as designed.
- Passive inspection stays distinct from explicit opening. Lazy submenus
  become inspectable after opening, and browsing can finish or cancel.
- Cleanup of opened context menus and menu-bar submenus passes the acceptance
  cases in VMs:
  - foreground loss, including activation changes the user did not cause and
    declared client presentation;
  - grant revocation;
  - inactivity expiry;
  - orderly shutdown;
  - abrupt termination with its documented recovery.
- Each app-shortcut row that `menu-bar` passed here reaches its intended
  outcome in VMs through explicit opening and validated invocation. An
  account-dependent row's outcome is recorded as pending for
  `account-acceptance`.
- Opening carries documented authority. Trace rows are added.

## Decomposition

1. `design`: target selection, explicit opening and the opened-menu
   interaction.
2. `planning`: cut implementation leaves.

## Notes

`menu-evidence-k23` should already answer the native questions. If a gap
remains, the design session cuts one bounded evidence leaf ahead of itself
rather than absorbing it.
