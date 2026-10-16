# Koine.should-be-a-persistent-menubar-item — brief

## Goal

Koine becomes a menu bar application, "just like Modaliser" (the human's
words): no Dock icon, one persistent menu bar item that always leads back to a
resizable settings window and says when something waits on the user. It ships
to users as Koine 0.3.0 through the Homebrew cask. The behaviour below was
settled with the human in `plan-k1`; it is this grove's design, and no spec or
ADR restates it.

## Done when

- **Agent application.** Koine runs with the `accessory` activation policy for
  its whole run: no Dock icon, no Cmd-Tab entry, no visible menu bar, even
  while the settings window is open. One menu bar item exists from launch to
  Quit.
- **The menu.** First, status lines, each present only while its condition
  holds: "Review 1 Grant Request…" / "Review N Grant Requests…" while client
  grant requests are pending, and "Accessibility Not Granted…" while Koine
  lacks Accessibility consent. Choosing one opens the settings window at that
  section. Then Settings… (⌘,), then Quit Koine (⌘Q).
- **The icon.** The SF Symbol `character.bubble` as a template image, carrying
  a small dot while any status line is present. Its accessibility label states
  the same thing ("Koine", or e.g. "Koine, 1 grant request waiting"), so
  VoiceOver and the VM checks read the mark rather than its pixels.
- **The settings window** (titled "Koine Settings") opens and comes to the
  front from Settings… or a status line however many times it has been closed.
  It is resizable: its content scrolls when small, a minimum size keeps every
  control usable, and today's size stays the default. Its shortcuts keep
  working with no visible menu bar: ⌘C/⌘V/⌘X/⌘A in its fields, ⌘W, ⌘Q.
- **Launch.** At any launch, by login item or by hand, the window opens only
  while setup needs the user: Accessibility not granted, or login launch not
  enabled. Otherwise Koine starts silently in the menu bar. Opening Koine again
  while it runs (Finder, Spotlight, `open`) shows the window. A client's grant
  request never brings the window forward by itself, because anonymous
  enrollment is open to every local process.
- **Quit Koine** from the menu stops the server exactly as Quit does today:
  descriptor withdrawn, instance lock released.
- Both agreed test seams (Pointers) pass, and every existing VM check works
  with the new launch and quit behaviour.
- README, client guide and glossary describe the menu bar application in
  current-state terms. The term is **settings window**.
- Koine 0.3.0 is released: notarized, release checks passed on the notarized
  build, tagged, GitHub release published, cask bumped, Homebrew check passed.

## Decomposition

1. `menu-bar-item`: the whole user-visible change on the development-signed
   bundle, proven by the package seam and a new VM check. It goes first
   because everything else depends on it.
2. `vm-checks-for-menu-bar-app`: the shared VM helpers and the existing checks
   adapted to the new launch and quit behaviour; the base check and the release
   acceptance checks pass. Needs 1.
3. `release-0-3-0`: version, notarization, release checks on the notarized
   build, then publishing, with the human confirming each outward-facing step.
   Needs 1 and 2.

## Pointers

- Glossary: **Settings window**, **Machine server**, **Grant**, **Client**
  (`CONTEXT.md`).
- README "Resident application" is the section this work rewrites. The spec's
  "Application composition and availability" (`docs/specs/machine.md`) still
  binds: one resident per-user process, a UI that closes without stopping the
  listener, explicit Quit, login launch through `SMAppService.mainApp`. It says
  nothing about the Dock, and no ADR governs the application's shape.
- Reference implementations: ModalAnyware's `AppShell` (`accessory` policy set
  before `run()`; a fixed status item; a menu rendered from a GUI-free state
  value of disabled text lines, separators and actions) and Modaliser
  (`LSUIElement`; a status item from a template image; a warning item at the
  top of its menu).
- **Test seams, agreed with the human:**
  1. *Package seam.* A GUI-free menu and launch model in a Foundation-only
     target (`KoineManagementClient` is the existing one, package-tested
     against an embedded server). Input: the status the console already serves
     (pending requests; the Accessibility permission from the host's
     `OSPermissionSource`, faked in tests) plus the login-launch state the
     application supplies. Output: the status lines with wording and counts,
     the attention mark, the accessibility label, and whether the window opens
     at launch. The application target only renders it.
  2. *VM seam.* TestAnyware on the signed, later notarized, bundle. A new menu
     bar check covers: no Dock icon; the item present at launch and after
     login launch; the window at first launch and not once setup is complete;
     close then reopen from Settings…; resize; a client request shows the mark
     and a "Review 1 Grant Request…" line that opens the Requests section;
     Accessibility missing shows its line; the window's shortcuts; Quit from
     the menu withdraws the descriptor. The existing checks keep working
     through the shared helpers.

## Notes

- **GUI work runs only in TestAnyware VMs**, never on the host: launching
  Koine.app, driving its UI, taking focus, the clipboard. Builds, `swift test`
  and codesign on the host are fine. A leaf that says "demonstrate" means "in a
  VM".
- **Docs state the current shape only**: no "previously a Dock application", no
  plans. The README's present "regular Dock application, not an accessory"
  paragraph is replaced, not annotated.
- The launch rule deliberately avoids telling a login launch from a launch by
  hand, which `SMAppService` items do not reliably report. It uses state Koine
  already reads: `AXIsProcessTrusted` and `SMAppService.mainApp.status`, where
  `requiresApproval` counts as not enabled.
- Shortcuts without a visible menu bar: an `accessory` application keeps the
  main menu it sets for key equivalents, which is believed but not yet
  observed for Koine. The VM check establishes it; if it fails, the window
  supplies the shortcuts itself.
- The window re-reads status every 2 s only while its view lives. The dot needs
  a status follow of its own that runs while the window is closed: one
  in-process console operation, cheap at the same cadence.
- Koine has no application icon (the bundle names none). This work does not
  need one.
- ModalAnyware's README ("Open Koine's window, find the ModalAnyware request
  under Requests") stays accurate and is outside this grove.
