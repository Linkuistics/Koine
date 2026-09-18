# resident-app-skeleton-k13

## Goal

The walking skeleton of the resident application: a signed `Koine.app`, built
by script from the Swift package, that embeds the Koine server and lets a person
create a grant in its window and hand the credential to a script. It makes the
UI-framework, bundle-layout and signing choices the rest of the stage builds on.

## Context

- The stage brief's notes hold the human's two decisions (Developer ID signing,
  scripted bundle) and what k4 left to build on.
- `../Modaliser/scripts/build-app.sh` is the local precedent for a scripted
  bundle; read it for shape, not to copy its ad-hoc fallback.
- Spec: "Application composition and availability", "User-created grant",
  "Management authority and surface".

## Done when

- `Package.swift` has an executable target for the application. Platform
  frameworks stay out of `KoineCore`.
- A Taskfile command assembles `Koine.app` (Info.plist with a stable bundle
  identifier, entitlements file, hardened runtime) and signs it with the
  Developer ID identity, overridable by an environment variable. A missing
  identity fails with an actionable message; there is no silent ad-hoc
  fallback. A second command verifies the result (`codesign --verify --strict`
  and the designated requirement). Both are in the README.
- Launching the bundle starts the embedded `KoineServer` over
  `KoineServer.userDataDirectory` and publishes the descriptor. A second launch
  meets `alreadyRunning` and tells the user, rather than starting a second
  listener.
- Closing the management window leaves the listener answering. Explicit Quit
  calls `stop()`: the listener is gone and the descriptor removed. Reopening
  the application (Dock, Finder) shows the window again.
- The window creates a grant: a label, a capability set chosen from
  `Query.koine.availableCapabilities` as served, and the credential shown once
  with a copy affordance. The UI executes `koineCreateGrant` through
  `KoineServer.console`; it never touches the store or engine directly, and
  nothing retains the credential after the sheet is dismissed.
- Demonstrated end to end on this machine: create a grant in the UI, then a
  plain HTTP client reads the descriptor and gets `Query.koine` with that
  credential; close the window and repeat the query; Quit and see the
  descriptor gone. Record the commands used.
- The logic between UI and console (building the operation, decoding the
  result, surfacing GraphQL errors) is covered by package tests against an
  embedded server. No UI-automation test is required here; the VM leaf owns the
  real workflow.

## Notes

The UI-framework choice (SwiftUI, AppKit or a mix) is this leaf's, within the
macOS 13 floor; verify lifecycle behaviour — keeping the process alive with no
windows, a regular Dock application versus an accessory — against Apple's
documentation rather than memory, and record the choice in the README. Do not
build list, revoke or login launch here: those are
`grant-management-ui-and-login-launch-k16`. Do not request Accessibility; that
belongs to `desktop-path-k9`.

## Decisions (running log)

- **UI framework: AppKit lifecycle, SwiftUI content.** `NSApplicationDelegate`
  plus one retained `NSWindow` hosting SwiftUI; regular Dock app. Verified
  against Apple's documentation (JSON backing of the three pages cited in the
  README and at the decision sites in `AppDelegate.swift`). SwiftUI `App` scenes
  were rejected: no dependable single-window re-show on macOS 13.
- **Two targets.** `KoineManagementClient` (Foundation only; the UI↔console
  logic, package-tested against an embedded server) and the `KoineApp`
  executable (the only importer of AppKit/SwiftUI). The bundle executable is
  named `Koine`.
- **Bundle identifier `dev.antony.Koine`**, following `dev.antony.Modaliser`.
  Stated once in `scripts/signing-env.sh`; the build fails if `App/Info.plist`
  disagrees.
- **Entitlements file is empty**: hardened runtime with no exceptions, not
  sandboxed. No `--timestamp` flag is passed; secure timestamps are a
  notarization (k11) concern.
- **Quit** uses `.terminateLater` and replies after `await server.stop()`.
- **Any GraphQL error fails a UI operation** (`ManagementError.rejected` with
  messages and the first `extensions.kind`); the UI has no use for partial data.
- **The human directed, mid-session, that anything interfering with use of the
  host runs in TestAnyware instead.** The end-to-end demonstration below had
  already been run on the host by then; later leaves (k16, k17) must use a VM.

## End-to-end demonstration (2026-09-19, host, signed bundle)

`task app && task app:verify`, then `open .build/app/Koine.app`. The UI was
driven with `osascript` through System Events (set the label field's value,
click the capability checkbox, click Create Grant, Copy, Done). Observed:

- Descriptor published 0600 in `~/Library/Application Support/Koine` with the
  app's pid; the sheet showed the credential once.
- `curl` as in the README with that credential: 200, `ownGrant.clientLabel`
  `demo-script`, `capabilities ["koine:manage"]`, `ACTIVE`.
- Window closed (System Events window count 0): the same `curl` still 200.
- Direct second exec of `Contents/MacOS/Koine`: alert "Koine is already
  running."; after OK it exited; the descriptor still named the first pid.
- `open` on the running app: window count back to 1.
- `osascript -e 'tell application "Koine" to quit'`: process gone,
  `endpoint.json` removed, `curl` exit 7 (connection refused).
- `KOINE_SIGNING_IDENTITY="Nobody (XXXXXXXXXX)" task app` fails before building
  with the actionable message.

Afterwards the data directory, which this session had created and which held
only the demo grant, was removed, and the clipboard cleared.
