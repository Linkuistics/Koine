# vm-checks-for-menu-bar-app-k3

## Goal

Make every existing VM check work against the menu bar application. The shared
helpers must cope with a settings window that no longer opens at launch once
setup is complete, with its "Koine Settings" title, with reopening through the
menu bar item, and with Quit through the menu bar item or ⌘Q from the window.
The checks whose shared libraries changed must run green.

## Context

- Shared helpers in `scripts/vm-verify-lib.sh`: `launch` (opens the bundle,
  then waits for the window), `place_window` (waits for the window, moves it
  to 40,40, focuses it), `quit_koine` (focuses the window, then ⌘Q),
  `calibrate_window_scroll` and `reveal` (measure scrolling on the window's
  frame). Other libraries that assume the window: `vm-verify-desktop-lib.sh`,
  `vm-verify-contract-client-lib.sh` (`approve_in_window` focuses the window
  by application name), `vm-verify-gatekeeper-lib.sh`, `vm-launchers-lib.sh`.
- About 27 scripts reach these helpers. Find them by what they call, not from
  a list. Some match the window by `.title == "${APP_NAME}"` (for example
  `vm-verify.sh`'s "window closed" step), and that title is now
  "Koine Settings".
- `vm-verify.sh` expects the window after a login launch. In its VM
  Accessibility is not granted, so the setup rule still opens it; confirm this
  rather than assume it.
- Whatever `menu-bar-item-k2` added to the shared library for opening the menu
  bar item's menu.

## Done when

- The shared helpers open the settings window when it isn't showing (through
  Settings… in the menu bar item's menu, or `open` of the running bundle),
  find it by its new title, and quit through Quit Koine or ⌘Q, whichever each
  check needs. No script waits for a window at launch that the launch rule no
  longer opens.
- In a clean VM on the development-signed bundle: `task app:vm-verify` passes,
  and so does one check from each other shared library —
  `app:vm-verify-desktop` and `app:vm-verify-contract-client` at least — plus
  `app:vm-verify-providers`.
- The release acceptance checks (`app:vm-verify-release`,
  `app:vm-verify-grant-workflows`, `app:vm-verify-notarized`) are adapted here.
  They run on the notarized artifact in `release-0-3-0-k4`, which needs them
  anyway, so they aren't run twice.
- Procedure docs under `docs/verification/` whose steps changed (reopening,
  quitting, the window's title) describe the procedure as it now is.

## Notes

- This is migration through the shared helpers, not a rewrite: change each
  helper once, and touch an individual script only where it bypasses them.
- If a check fails for a reason unrelated to the menu bar change, record it in
  this leaf and leave it; don't widen the leaf to fix it.
