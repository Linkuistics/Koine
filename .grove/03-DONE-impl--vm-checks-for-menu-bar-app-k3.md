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

## Decisions (running log)

- **The window is asked for, never waited for.** `show_window` (`scripts/vm-verify-lib.sh`)
  returns once a Koine window exists and otherwise `open`s the running bundle (a
  reopen, which shows it) and looks again, up to a minute. `place_window` calls it,
  `launch` is now start, await the descriptor, then `place_window`, and
  `quit_koine` calls it before ⌘Q. `open` rather than the menu's Settings…, so that
  the 27 scripts do not each need System Events' per-clone Automation consent;
  `vm-verify-menu-bar.sh` is what drives the menu.
- **The window is found by `WINDOW_TITLE` ("Koine Settings")**, defined once in the
  library; `read_frame` matches it exactly and window-move and window-close take it.
  `snapshot` and `window-focus` still name the application. Focusing by the full
  title was tried and failed `vm-verify-contract-client.sh` twice in three runs: the
  Approve click did not reach Koine's window (macOS answered it as a click on the
  wallpaper, "Click Wallpaper to Show Desktop Items", and hid every window), and
  Finder was still the active application with Koine's window inactive. Focusing by
  application name, as before, passes. Cause not established beyond that: `--window`
  with a title raises the window through Accessibility, and the application name
  evidently also activates the application.
- **Six scripts had their own "Quit Koine" loop** (⌘Q three times, then `pkill`):
  open-url, open-path, installations, reveal-path, network, target-locations. They
  focused the window by name, and with no window that sends ⌘Q to whichever
  application is in front. The loop is now `quit_koine_or_terminate` in the library.
- **Other bypasses fixed:** `vm-verify.sh` (exact title "Koine", raw ⌘Q),
  `vm-verify-release.sh` (exact title), `vm-verify-desktop-remembered.sh` (close by
  name), `approve_in_window` and `vm-verify-accessibility.sh` (focus without
  showing), `vm-verify-grant-workflows.sh` (its own `read_frame`), and the two
  bespoke waits for a window at launch in `vm-verify-gatekeeper-lib.sh` and
  `vm-verify-notarized.sh`, which `place_window` now covers with a 90 s wait for
  the window's controls.
- **`task app:vm-verify` passed** on the rebuilt development-signed bundle, in a
  clean clone. The clone has no Accessibility, so the launch rule opens the window,
  as `vm-verify-menu-bar.sh` shows for the same clone state.
- **Green on the final code, in clean clones of the development-signed bundle:**
  `app:vm-verify`, `app:vm-verify-providers`, `app:vm-verify-desktop` and
  `app:vm-verify-contract-client`. The release acceptance checks
  (`app:vm-verify-release`, `app:vm-verify-grant-workflows`,
  `app:vm-verify-notarized`) are adapted through the same helpers and the same
  title fixes, and are run on the notarized artifact in `release-0-3-0-k4`.
- **Not this leaf's, left alone:** `app:vm-verify-contract-client` has no `client`
  dependency, so it fails with "koine-client.mjs does not exist" until `task client`
  has run (`app:vm-verify-launch-contract-client` does declare it). The checks that
  were not run here — homebrew, saved-state, and the rest that reach the helpers
  through `launch` and `quit_koine` — got the helper change and nothing else of
  their own, except the six scripts' Quit loops above.
- **A kept VM does not survive idle:** a clone left running with
  `KOINE_VM_KEEP=1` died within minutes of the last call to it (the host's VNC
  hazard `start_vm` describes), so inspecting a failure needs a run that keeps
  talking to it.
