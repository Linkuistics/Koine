# menu-evidence-k23

## Goal

Establish, from the signed hardened Koine in isolated VMs, how application
menus can be discovered, validated, opened, invoked and cleaned up through the
public Accessibility boundary. The evidence serves `menu-bar`,
`held-interactions` and `context-menus`.

## Context

- The requirements' application-menu and interaction sections, and the
  review's design question on passive population and read purity.
- ADR `desktop-automation-uses-public-accessibility` and the spec's accepted
  limits.
- Apple's menu-update contract and show-menu action are cited in the
  requirements' evidence section.

## Done when

A `docs/verification/` document answers these questions with a per-application
table. It covers AppKit, Catalyst and Electron/Chromium applications from the
configured set: Safari, Finder, Mail, Zed, Obsidian, Slack and Dia.

- How is the menu bar exposed? Which submenus populate only when opened? Does
  a passive Accessibility read trigger application menu-update code or visibly
  change anything?
- Which required metadata is available: shortcut characters and modifiers,
  checked marks, enabled state and separators? What does an unavailable value
  look like?
- Can a listed item be revalidated as the same item after the menu refreshes
  or reopens? How does a replaced Open Recent entry, or a duplicate title,
  show?
- What do pressing an item, showing a context menu at a screen point or on the
  keyboard-focused element, and cancelling or dismissing an opened menu do?
  What is observable when the target loses foreground while a menu is open?
- Separate native menu actions from pointer-button or Escape fallbacks: those
  require input authority at admission and cannot replace menu-only paths.
  Identify a native menu cleanup route for those paths. Apply the shared
  selected-effect rule to activation using call-path inspection and native
  outcomes; app reactions alone do not prove a hidden activation call.
- Demonstrate direct refusal of Koine's UI and recognized consent/security
  targets before capture and effects, and document recognition limits.

It ends with recommendations for `menu-bar-k36`, and inputs for
`interaction-lifecycle-k38` and `context-menus-k25`.

## Notes

This question is bounded. An application or menu that public Accessibility
cannot expose becomes an explicit report and a stated limit, not permission to
drop required working menu access from acceptance, and not a private-API
detour.
