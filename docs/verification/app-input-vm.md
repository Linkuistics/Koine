# App input: VM acceptance

This record is the V seam of app input. Koine 0.7.0 bundles input release
1.0.0. A client with `input:control` sends one chord to an app, in front or in
the background. A client that also holds `desktop:control` switches to a
Mission Control desktop with Control and a digit. The run accepts the happy
path of both on the signed bundle, in one clean VM.

**The accepted run passed every step.** In one clean clone of the launcher
image, Koine sent all 21 rows of Finder and Safari. It also sent one row each
of Zed, Zotero and Obsidian. Each app acted on each chord, as its own witness
read it.

With TextEdit in front, Safari opened a tab in the background, and TextEdit
kept its text and stayed in front. A Control-2 through the keystroke operation
left Desktop 1 current. The Space switch reached Desktop 2 and returned, and it
refused with the shortcut off. No permission dialog appeared.

**The disclosures hold.** The create-grant view, the request view and the
grant list showed the served `input:read` and `input:control` texts. After a
restart, the grants were unchanged, and the grant list showed the same texts.

The transcript is
[app-input-20261128T175602.log](app-input-vm/app-input-20261128T175602.log).
The compatibility record is [app-input-compatibility.md](app-input-compatibility.md).

## Procedure

```sh
task app:vm-verify-app-input        # scripts/vm-verify-app-input.sh
```

The task starts a clone of the prepared launcher image
(`task launchers:prepare`). That image holds Zed, Zotero and Obsidian past
their first runs. The task installs the signed `Koine.app` in the clone. It
sends no chord on the host, and it never starts the application there.

Koine never witnesses its own sends. Each effect is read by a tool that shares
no code with Koine:

- `Fixtures/WindowIdentityProbe` names the front app and lists the windows of
  an app.
- AppleScript to Finder reads the view and the name of the front window, and
  the count of Finder windows. AppleScript to Safari reads its tabs.
- The TestAnyware agent's accessibility snapshot reads Safari's find banner,
  the focus of Safari's address field and the text of TextEdit.
- OCR of the guest screen reads text that no other witness reaches.
- `Fixtures/KeystrokeProbe` reads the Space shortcuts and counts the Spaces.
  It posts nothing in this run.

The AppleScript witnesses run in the agent's process. So macOS asks once
whether the agent may control Finder and Safari, and the run answers as a user
would. Koine is not involved in that prompt.

The guest client `scripts/vm-verify-app-input-client.py` knows only the
endpoint descriptor, a protected credential file and
`docs/design/input-operations.graphql`. It sends each operation with the text
of that file, unchanged. Every row uses `SendChord`. The guest helper repeats a
command that the agent reports as timed out. So each chord takes a guard
directory, and a repeat sends nothing.

1. **Spaces.** The run clicks the add button of the Spaces bar in Mission
   Control. SkyLight must then report two desktops, with Desktop 1 current.
   The run turns on "Switch to Desktop 1" and "Switch to Desktop 2" as Control
   and the digit.
2. **Disclosures.** A reading grant holds `koine:manage` and `input:read`. The
   served disclosures must be the two desktop, two input and two workspace
   texts. The create-grant view, the request view and the grant list must show
   the served input texts. Each text must state the reach that the contract
   requires. A controlling grant holds `input:control` and
   `desktop:control`.
3. **Consent.** The run gives Koine its Accessibility consent in System
   Settings, as a user does. No permission dialog may show before the chords.
4. **Rows.** For each app, the run brings the app to the front, and the window
   witness names it. Target capture under the reading grant must name the
   same app, with its pid in the reference. Then the controlling grant sends
   each row's chord, and Koine must report `SENT`. The witness reads before and
   after each chord.
5. **Background target.** With TextEdit in front, Koine sends New Tab to the
   Safari target that the run captured earlier. Safari must open a tab, and
   TextEdit must keep its text.
6. **Control-2 by the keystroke operation.** With TextEdit in front, Koine
   sends Control-2 to TextEdit. Desktop 1 must stay current.
7. **Space switch.** With TextEdit in front, the switch to Desktop 2 must
   report `POSTED`, and SkyLight must report Desktop 2. The switch to Desktop 1
   must then return. With "Switch to Desktop 2" turned off, the switch must
   report `SHORTCUT_OFF`, and Desktop 1 must stay current. No permission
   dialog may show.
8. **Restart.** After Koine quits and starts again, the grants must be
   unchanged. The grant list must show the input texts again.

The rows are Antony's Modaliser screens: every row of Finder and Safari, and
one row each of Zed, Zotero and Obsidian.

| App | Row | Chord | Witness |
| --- | --- | --- | --- |
| Finder | View: List, Column, Gallery, Icon | Command-2, 3, 4, 1 | AppleScript: the current view of the front window. Gallery reads as `flow view` |
| Finder | Toggle Hidden | Command-Shift-Period | OCR: the name of a hidden file in the window |
| Finder | New Folder | Command-Shift-N | The files of the scratch folder |
| Finder | Get Info | Command-I | The window witness: a window whose title ends in "Info" |
| Finder | Go to Folder | Command-Shift-G | OCR: the placeholder "Go to Folder" of the panel |
| Finder | Connect to Server | Command-K | The window witness: the "Connect to Server" window |
| Finder | Go: Home, Applications, Desktop, Downloads, Recents, Computer | Command-Shift-H, A, D, Command-Option-L, Command-Shift-F, C | AppleScript: the name of the front window |
| Finder | New Window | Command-N | AppleScript: the count of Finder windows |
| Safari | Find on Page | Command-F | Snapshot: the find banner |
| Safari | Focus Address Bar | Command-L | Snapshot: the focus of the address field |
| Safari | New Tab, Close Tab, Reopen Closed Tab | Command-T, Command-W, Command-Shift-T | AppleScript: the count of tabs |
| Zed | Command Palette | Command-Shift-P | OCR: "Execute a command" |
| Zotero | Advanced Search | Command-Shift-F | OCR: "Advanced Search" |
| Obsidian | New Note | Command-N | The files of the vault |

Between some rows, the run restores the window as a user would, with the
keyboard of the VNC session. It ends the name of the new folder with Return.
It closes the Info window and the "Connect to Server" window with Command-W,
and the "Go to Folder" panel with Escape. Each of these is harness work, not a
chord from Koine, and the run checks that each window is gone.

The Safari find row goes before the address row. A click on the page does not
take the focus from the address field, but the find banner does.

## Run of 28 November 2026

The run used macOS 27.0.1 (26A434) in the guest, on a clone of the image
`koine-launchers-prepared`. That is the image of the route probe, and
[keystroke-route-vm.md](keystroke-route-vm.md) names its app versions. The host
ran macOS 27.2.1 (26B131). The bundle carried CDHash
`3f720b4d332631adfbdd5f0f27f6ecacff09dd16`, with the signature of Developer ID
Application, Team ID TA43A4RUP3. The bundle, the script, the guest client and
the operations file had the same SHA-256 digests before and after the run.

| Step | Observation |
| --- | --- |
| Spaces | SkyLight reported two desktops, with Desktop 1 current. Entries 118 and 119 read as enabled Control-digit shortcuts. |
| Disclosures | The served disclosures were the two desktop, two input and two workspace texts. Each of the three views showed the served input texts, and each text stated the required reach. |
| Consent | Koine was in the Accessibility list. No consent dialog showed before the chords. |
| Finder views | The current view went from icon to list, column, `flow view` and icon again, one row at a time. |
| Finder Toggle Hidden | The name of the hidden file went from 0 to 1 on the screen. |
| Finder New Folder | `untitled folder` went from 0 to 1 in the scratch folder. |
| Finder Get Info | The windows whose title ends in "Info" went from 0 to 1. |
| Finder Go to Folder | The sheet `GoToWindow` went from 0 to 1. |
| Finder Connect to Server | The "Connect to Server" windows went from 0 to 1. |
| Finder Go destinations | The front window went from KoineFinder to admin, Applications, Desktop, Downloads, Recents and "Admin’s Virtual Machine", one row at a time. |
| Finder New Window | The Finder windows went from 1 to 2. |
| Safari Find on Page | The find banners went from 0 to 1. |
| Safari Focus Address Bar | The focus of the address field went from false to true. |
| Safari tabs | New Tab took the tabs from 1 to 2, Close Tab from 2 to 1, and Reopen Closed Tab from 1 to 2. |
| Zed | "Execute a command" went from 0 to 1 on the screen. |
| Zotero | "Advanced Search" went from 0 to 1 on the screen. |
| Obsidian | The vault went from one note to two, and the new note is `Untitled.md`. |
| Background target | Safari's tabs went from 2 to 3. TextEdit's text stayed "TextEdit stays unchanged", and TextEdit stayed the front app. |
| Control-2 by the keystroke operation | Koine reported `SENT`, and Desktop 1 stayed current. |
| Space switch on | The switch to Desktop 2 reported `POSTED`, and SkyLight reported Desktop 2, with Finder in front. The switch to Desktop 1 reported `POSTED`, and Desktop 1 returned, with TextEdit in front. |
| Space switch off | With entry 119 turned off, the switch to Desktop 2 reported `SHORTCUT_OFF`, and Desktop 1 stayed current. |
| Dialogs | OCR found "Help" in the menu bar, and no consent dialog showed after the chords and the switches. |
| Restart | The grants were unchanged, and the grant list showed the input texts again. |

In each app step, target capture named the app that the window witness named,
with the same pid in the reference. Koine reported `SENT` for every chord.

The run captured the screen after the views and after each app. The captures
are in [app-input-vm](app-input-vm/).

## Conformance of the signed application

`task conformance:vm` holds the same signed bundle to the profile
`core-desktop-input-workspace-extension-host`, in a clean VM of its own. Its
run on 28 November 2026 passed, in
[conformance-20261128T190548.log](app-input-vm/conformance-20261128T190548.log).
The bundle served the design `desktop-input-workspace-schema-extension-host.graphql`
exactly, with digest `322ed31a6cd8`. Its three candidates matched the pin.

Every control turned red. Five controls hold input on its own: each of its
three roots removed, one keystroke outcome removed and one Space switch outcome
removed. The run before it, in the same session, found two stale controls,
because both assumed that no host serves input. The library now swaps the
same two fields as before with input's fields between them. It also names
`menus` as the provider that no host serves.

## Earlier runs

The repository keeps the transcripts of three earlier runs of this task. None
of them showed an app that ignored a chord.

- [app-input-20261128T163932.log](app-input-vm/app-input-20261128T163932.log)
  stopped before the rows. The disclosure steps passed. The run asked
  AppleScript for the name of Finder, which AppleScript answers without an
  Apple event, so macOS asked nothing. The run now asks for the count of
  windows.
- [app-input-20261128T164806.log](app-input-vm/app-input-20261128T164806.log)
  stopped at the same step. The Automation prompt was on the screen, but OCR
  found no "Allow". The run now finds the button in the prompt's
  accessibility snapshot, and the app's answer proves the consent.
- [app-input-20261128T170102.log](app-input-vm/app-input-20261128T170102.log)
  sent every chord. 21 rows passed, and so did the background, Control-2 and
  Space switch steps. Three OCR witnesses read 0 before and after: Toggle
  Hidden, Go to Folder and Zed. Its
  [Zed capture](app-input-vm/app-input-20261128T170102-Zed.png) shows the
  palette open. Then the run did not quit Koine, because Command-Q did not
  reach Koine's window behind the test apps.

Host Vision read the Zed capture of the third run as if it were upside down.
Without the left 320 pixels, which hold Koine's Settings window and its dense
small text, it read the same capture in full. So the run now closes that
window before the rows. Finder filled the Go to Folder panel with the last
path of the consent step, so its placeholder was absent. The run now reads the
panel as a sheet in the snapshot. The run also closes the test apps before the
restart.

Each dialog check now first requires OCR to find "Help" in the menu bar. Host
OCR of the third run's Zed capture finds no "Help". So that control fails on a
misread screen, and a clean dialog check cannot come from a broken
instrument.

## What this does not claim

- **Dia and Telegram.** The VM cannot run them past their accounts. The
  scheduled check on Antony's Mac covers route A for Chromium and Qt.
- **The other configured rows.** Zed, Zotero and Obsidian sent one row each.
  An issue holds their other rows.
- **A row's full effect.** Each witness reads one sign of the row, such as a
  window title or a tab count. It does not read every effect of the menu item.
- **Another macOS release or keyboard layout.** The guest ran macOS 27.0.1
  with the US layout. Modaliser's key table holds the key codes of the US
  ANSI layout.
- **More than one monitor, full-screen Spaces, a remapped shortcut, or a
  setting that macOS has not applied.** The run tested none of them.
- **The race with a Space switch.** The run did not change a setting or a
  Space in the instant between the check and the post.
- **The notarised bundle.** The run used the signed bundle that `task app`
  builds. The release checks of 0.7.0 run on the notarised build.
