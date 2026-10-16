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
