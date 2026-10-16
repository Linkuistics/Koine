# plan-k1

## Goal

Establish, in the human's own words, what "Koine should be a persistent menu bar
item" means, settle the open behaviour questions, agree the test seams, and cut
the work.

## Context

- The human's words: the workspace name ("should be a persistent menubar item"),
  then "Just like modaliser. 1. The settings currently can't be re-opened once
  the window is closed 2. The settings window should be resizable."
- Reference implementations, read for this leaf: Modaliser
  (`~/Development/Modaliser`: `Info.plist` sets `LSUIElement`; `root.scm` sets
  the `accessory` activation policy and builds one status item from the app
  icon as an 18 pt template image, with a menu of commands ending in "Quit
  Modaliser"; its permission onboarding switches to `regular` while its window
  is up and back to `accessory` after) and ModalAnyware
  (`~/Development/ModalAnyware`, `AppShell`: `accessory` policy, a fixed status
  item with an SF Symbol, a menu rendered from shell state mixing disabled
  status lines with actions).
- Koine today: a regular Dock application (README "Resident application"); the
  window is a fixed 480×680 `.titled/.closable/.miniaturizable` `NSWindow`;
  reopening relies only on `applicationShouldHandleReopen` (Dock click, Finder
  or `open` of the running app); the main menu has no item that shows the
  window; the window is shown at every launch, login launch included. That
  Dock-app shape was an `impl` leaf's choice (resident-app-skeleton-k13), not a
  decision the human made.
- Koine has no application icon (no `CFBundleIconFile`; nothing in the bundle
  build), so Modaliser's app-icon-as-status-image needs a glyph.
- The spec ("Application composition and availability") requires a resident
  process whose UI closes without stopping the listener, explicit Quit, and
  `SMAppService.mainApp` login launch. It says nothing about the Dock, so a
  menu bar item is inside the contract.
- Every VM check script (27 use the shared helpers in `scripts/vm-verify-lib.sh`)
  assumes the window appears at launch (`place_window`) and quits with ⌘Q from
  the focused window (`quit_koine`); `vm-verify.sh` also expects the window
  after login launch and reopens it with `open` of the bundle.

## Done when

- The behaviour of the menu bar item, the window and launch is settled and
  recorded below, in the human's terms.
- The test seams are agreed with the human.
- The work is cut into leaves (or a `planning` leaf added, if it proves larger).

## Notes

## Decisions (running log)

- **Koine is a menu bar application, like Modaliser.** No Dock icon and no
  Cmd-Tab entry in its steady state: an agent application with one status item
  present for as long as Koine runs, whose menu carries Koine's commands,
  including Quit. (Human: the workspace name, and "Just like modaliser.")
- **The window can always be reopened.** Closing the window must never leave
  Koine unreachable; the menu bar item reopens it. (Human: "The settings
  currently can't be re-opened once the window is closed.")
- **The window is resizable.** (Human: "The settings window should be
  resizable.")
- **The menu shows what is waiting on the user, and the icon says so too.**
  Below the status lines come Settings… (⌘,) and Quit Koine (⌘Q). A status line
  appears only while its condition holds: a pending client grant request
  ("Review 1 Grant Request…", counted) and missing Accessibility consent
  ("Accessibility Not Granted…"); choosing one opens the window at that
  section. While either holds, the menu bar icon carries an attention mark (a
  dot); otherwise it is the plain icon. This needs a status check that runs
  while the window is closed. Chosen over status lines with an unchanging icon
  (what Modaliser and ModalAnyware do) and over a plain Settings…/Quit
  launcher. (Human, choosing among the three.)
- **A client's request never brings the window forward by itself.** The dot
  and the status line announce it. Anonymous enrollment is open to every local
  process, so a window that popped up per request would hand any of them a way
  to pull Koine in front of the user. (Consequence of the decision above;
  raised with the human in the final confirmation.)
- **The window opens by itself at launch only while setup needs the user.**
  At any launch, by login item or by hand, Koine shows the window only while
  Accessibility is not granted or login launch is not enabled (the state
  `AXIsProcessTrusted` and `SMAppService.mainApp.status` already report);
  otherwise it starts silently in the menu bar. Opening Koine again while it
  runs (Finder, Spotlight, `open`) still shows the window, as today. Like
  Modaliser's permission gate. Chosen over "whenever launched by hand, never
  at login" (which depends on telling a login launch apart, unreliable for
  `SMAppService` items) and over "never at launch". (Human.)
- **Never in the Dock or Cmd-Tab, even with the window open.** One activation
  policy, `accessory`, for the whole run, as ModalAnyware does; no switching to
  `regular` while the window is up (Modaliser's onboarding pattern, rejected:
  an icon that comes and goes, and policy-switch edge cases). The window's
  keyboard shortcuts — ⌘C/⌘V/⌘X/⌘A in its fields, ⌘W, ⌘Q — must keep working
  with no visible menu bar, which the VM check establishes. (Human.)
- **Done is a shipped release, not main.** The work ships as the next Koine
  release through the existing route — notarize, the release VM checks, tag,
  GitHub release, cask bump in homebrew-taps — proposed as 0.3.0 (a visible
  change of the application's shape; the `koine-desktop/1` contract is
  unchanged). Each outward-facing publishing step is confirmed with the human
  when it is reached. Main carries only five doc and VM-check commits since
  v0.2.0 and no other workstream is in flight. (Human.)
- **Two test seams, both existing.** (1) Package tests on the host: the menu
  bar's behaviour is a GUI-free model — which status lines appear, their
  wording and counts, whether the icon carries the attention mark, and whether
  the window opens at launch — derived from the status Koine already serves
  (pending requests, the Accessibility permission) plus the login-launch state
  the application supplies, tested with `swift test` against an embedded
  server and the existing fake permission source; the app target only renders
  it, as ModalAnyware's shell renders its state. (2) TestAnyware VM checks on
  the real signed and then notarized bundle: a new menu bar check (no Dock
  icon; the item present at launch and after login launch; the window at first
  launch and not once setup is complete; close then reopen from Settings…;
  resize; a client request shows the mark and a "Review 1 Grant Request…" line
  that opens the Requests section; Accessibility missing shows its line;
  ⌘C/⌘V/⌘W/⌘Q in the window; Quit from the menu withdraws the descriptor),
  and the shared VM helpers adapted so every existing check — the two release
  acceptance checks included — still passes. The status item's accessibility
  label carries its state, so the VM reads the mark through Accessibility
  rather than pixels. Chosen over VM-only evidence. (Human.)
- **It is the settings window.** The human's word. The menu item reads
  "Settings…", the window is titled "Koine Settings", and the docs and the
  glossary use "settings window" where they said "management window" or
  "Koine's window". (Proposed, confirmed by the human in the final summary.)
- **The icon is the SF Symbol `character.bubble`.** Koine has no application
  icon to reuse as Modaliser does; a letter in a speech bubble stands for the
  common language. A template image, so it follows light and dark menu bars,
  with a small dot as the attention mark. (Proposed, confirmed.)
- **Requests never pop the window, and the login-launch toggle stays in the
  window only.** (Proposed, confirmed.)
- **Shared understanding confirmed; three `impl` leaves, in order:** the menu
  bar item with its package tests, docs and new VM check; the existing VM
  checks adapted to the new launch and quit behaviour; the 0.3.0 release.
  No spec and no ADR: nobody else has to agree to anything before the work is
  cut, and no decision here is hard to reverse, so the design lives in the root
  brief. No review chain: a small UI change, not a load-bearing artifact.
  (Human confirmed the summary; the cut is this leaf's.)
