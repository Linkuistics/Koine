# context-menus-k25

## Goal

Design context-menu target selection, explicit opening of context menus and
menu-bar submenus, and the opened-menu interaction.

## Context

- `menu-evidence-k23`, `menu-bar-k36` and `interaction-lifecycle-k38`.
- The requirements' context-target, explicit-opening and target-loses-foreground
  scenarios, and the review's question about screen points that hit another
  application or a client overlay.

## Done when

The spec, and an ADR where a decision clears the bar, state:

- how a target is selected by point or by focused element, referenced and kept;
- what happens when a point lands on another application or on a client
  overlay, and how that relates to declared client presentation;
- the explicit opening operation and its authority;
- the opened menu as an instance of the interaction lifecycle, covering finish,
  cancel and every cleanup trigger;
- results, errors and the VM acceptance cases, including the app-shortcut rows
  `menu-bar-k36` named for explicit opening.
