# menu-bar-item-k2

## Goal

Deliver the menu bar application the root brief's "Done when" describes —
agent application, the menu, the icon, the settings window, the launch rule,
Quit — on the development-signed bundle: the package seam's model with its
tests, the application rendering it, current-state docs, and a new VM check
that proves it on the real app.

## Context

- Lifecycle: `Sources/KoineApp/AppDelegate.swift` shows the window right after
  the server starts (the launch rule replaces that), keeps
  `applicationShouldHandleReopen` (keep it), and owns the Quit path through
  `applicationShouldTerminate` (Quit Koine reuses it). It builds the fixed
  `NSWindow` (title, style mask). `main.swift` and `MainMenu.swift` hold the
  programmatic main menu, which stays for its key equivalents. Its "Hide Koine"
  item has no meaning without a Dock icon.
- `App/Info.plist`: `LSUIElement`, or the policy set in code before `run()` as
  ModalAnyware does. Choose one and give the reason in the README.
- `Sources/KoineApp/ManagementView.swift` fixes the frame at 480×680 and orders
  the sections (Accessibility first, Requests second). `StatusView.swift`'s
  `StatusModel` follows `ManagementClient.status()` every 2 s while the view
  lives. `LoginLaunchView.swift`'s `LoginLaunchModel` reads
  `SMAppService.mainApp.status`. `AccessibilityPermission.swift` holds the
  host's permission source.
- Package seam: `Sources/KoineManagementClient/` (Foundation only) and
  `Tests/KoineManagementClientTests/`, which test against an embedded server
  with a supplied `OSPermissionSource`.
- VM: `scripts/vm-verify-lib.sh` (shared helpers), `scripts/vm-verify.sh` (the
  base check, the model for a new one), `docs/verification/resident-app-vm.md`
  (how a check's procedure and evidence are recorded); `Taskfile.yml` gains
  `app:vm-verify-menu-bar`.
- Docs: README "Resident application" (and its "management window" wording
  elsewhere), `docs/client-guide.md` ("Koine's window"), and any other doc
  using the old names for the window.
- References: ModalAnyware `Sources/AppShell/AppShell.swift` and
  `ShellState.swift` (state rendered to a menu); Modaliser
  `Sources/Modaliser/LifecycleLibrary.swift` (status item from a template
  image).

## Done when

- `swift test` passes, including new tests of the menu and launch model at
  the package seam: no pending request and consent granted gives no status
  line, no mark and the label "Koine"; one pending request and two give the
  singular and plural lines and the mark; missing consent gives its line and
  the mark; both together; the launch rule across consent granted or not and
  every `SMAppService.Status` (`requiresApproval`, `notRegistered` and
  `notFound` all count as not enabled).
- `task app` builds the signed bundle, and the application renders that model.
  The menu bar item is `character.bubble` as a template image, with the dot,
  its accessibility label and the menu as specified. Settings… and each status
  line open the window, bring it to the front and scroll it to the right
  section. The window is resizable with a minimum size, the activation policy
  is `accessory` throughout, and the launch rule and reopen work as specified.
  Quit Koine goes through the existing terminate path.
- `task app:vm-verify-menu-bar` passes in a clean TestAnyware VM on the signed
  bundle and covers every item in the brief's VM seam, including the window
  coming to the front over another application's window when opened from the
  menu. Its procedure and evidence are recorded under `docs/verification/` in
  current-state terms.
- README, client guide and every other doc that named the window use
  **settings window** and describe the menu bar application as it is. No doc
  says 0.3.0 is released; that is `release-0-3-0-k4`.

## Notes

- Existing VM checks will break where they wait for a window at launch, match
  the window by the title "Koine", or quit with ⌘Q from a window. Adapting
  them is `vm-checks-for-menu-bar-app-k3`, so do not chase them all here. Add
  any helper the new check needs, such as opening the menu bar item's menu or
  choosing an item, to the shared library in a form k3 can reuse.
- Coming to the front from the menu: an `accessory` application activates
  itself (`NSApp.activate()`, cooperative activation on macOS 14+) and orders
  the window front. Establish that in the VM; don't assume it.
- If the main menu's key equivalents turn out not to reach the window without
  a visible menu bar, the window supplies ⌘C/⌘V/⌘X/⌘A, ⌘W and ⌘Q itself. The
  requirement is the shortcuts, not the mechanism.

## Decisions (running log)

- **Agent application by `LSUIElement`, not by `setActivationPolicy` in code.**
  The plist key is in force before any of Koine's code runs, so no launch can
  show a Dock icon. The README ("Resident application") gives the reason with
  Apple's page for the key. Observed in a VM: `background only` true for the
  process, no Dock entry, and the menu bar stays the previous application's
  while the settings window is key.
- **The seam model is `MenuBarModel`**, with `LoginLaunchState` (a Foundation-only
  stand-in for `SMAppService.Status`, mapped in `LoginLaunchState+Service.swift`)
  and `SettingsSection`. `ManagementStatus` and `ManagedOSPermission` gained
  public initializers so the model is testable without a server; one test also
  runs it against an embedded server. A status that could not be read, or that
  does not report Accessibility, claims nothing (no line, and no forced window).
- **The item cannot be dragged off the menu bar** (`behavior = []`): it is the
  only way back to the window. Its icon is `character.bubble` with a dot knocked
  out of the bubble by a ring, as a template image; the label is the model's.
- **Window sizing.** The hosting controller takes the least size from the view's
  `.frame(minWidth:minHeight:)` (440×320 content); the first size is set
  explicitly (480×680) because the controller would otherwise open at the least.
  `contentMinSize` set in code was not honoured under the hosting controller (a
  drag took the window to 101×201), which is why the view carries the minimum.
  The accessibility resize (`agent window-resize`) is not held to the least size,
  a drag is; the VM check resizes by dragging the corner (`drag_window_corner`).
- **The main menu stays, without "Hide Koine"**, for its key equivalents. Observed
  in a VM on the signed bundle: ⌘A ⌘C ⌘X ⌘V in a field, ⌘W and ⌘Q all work with
  no visible menu bar, so the window supplies none itself.
- **Coming to the front** is `NSApp.activate()` plus `makeKeyAndOrderFront`;
  observed in a VM to bring the window over TextEdit's from the menu item chosen
  with the pointer. An item chosen through System Events' `click` did not activate
  the application, so the check chooses by the pointer, as a user does.
- **The VM check reads the item through System Events** (TestAnyware's agent lists
  no status items): `description` of the item is the label, `title of every menu
  item` the menu. System Events asks once per clone for Automation consent for
  `testanyware-agent`; the check answers it by clicking Allow
  (`grant_system_events_automation`). A menu chooses nothing for a click with no
  pointer movement before it, so `click_at` moves first.
- **Docs.** README, client guide, glossary, the machine spec's two row titles, the
  architecture diagram and the verification procedure documents say **settings
  window**. Verification prose that called the window fixed now says it opens at
  480×680. The old checks' scripts and their step titles are `k3`'s.
- **For `k3`, what the shared library gained** (`scripts/vm-verify-lib.sh`, last
  section): `grant_system_events_automation`, `sysevents`, `menu_item_label`,
  `open_menu`, `choose_menu_item`, `read_menu`, `click_at`, `koine_windows`,
  `await_windows`, `front_windows`, `koine_in_front`, `drag_window_corner` and
  `guest_once`. The old checks still find the window by the title "Koine" as a
  substring, but `vm-verify.sh` and `vm-verify-release.sh` compare it to the exact
  title "Koine" and will need "Koine Settings"; a launch that must stay silent
  must use `guest_once`, since a retried `open` is a reopen.
- **`task test` has one failure that is not this leaf's**: `WorkspaceApplicationLocationTests`
  expects "File name too long" for a 1023-byte Info.plist path and does not get it
  on this host (macOS 27). The same test fails the same way on a `git archive` of
  `HEAD` built and run alone in the scratchpad, as does
  `ProviderLoaderTests.aQuarantinedUnnotarizedProviderIsRefusedBeforeLoading`
  failed in that one run and passed in this tree's. Everything else passes, including the new package-seam tests.
