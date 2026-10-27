# Menu bar application: VM verification

What the signed `Koine.app` does as a menu bar application, on the real bundle in
a clean TestAnyware macOS VM: no Dock icon and one menu bar item from launch to
Quit; its menu, status lines, mark and accessibility label as Accessibility consent
and client grant requests come and go; the settings window at first launch and not
once setup is complete, reopened from the menu over another application's window
however often it was closed, resizable, with its shortcuts working and no visible
menu bar; a client's request never opening it; reopening the running application
showing it; login launch across a VM restart; and Quit from the menu. The model
that decides all of it (`MenuBarModel`) is tested without a GUI by
`MenuBarModelTests` under `swift test`; this run shows the application renders it.
The shape being checked is in README "Resident application".

## Procedure

```sh
task app                    # build and sign .build/app/Koine.app on the host
task app:vm-verify-menu-bar # scripts/vm-verify-menu-bar.sh: everything below, in a fresh VM
```

It needs `testanyware` with a macOS golden image, and `jq`. Nothing runs the
application on the host. Each run clones the golden, stops the clone when it ends
(`KOINE_VM_KEEP=1` keeps it), exits non-zero at the first expectation that fails
with a screenshot beside the transcript, and writes the transcript to
`.build/vm-verify/menu-bar-<timestamp>.log`.

| Step | How | Expectation checked |
|---|---|---|
| First launch | `open` the bundle on a clone where Accessibility is not granted and login launch is not enabled | one window titled "Koine Settings", 480 wide and 680 plus the title bar high; System Events reports the process `background only`; the Dock holds no Koine; exactly one menu bar item, labelled "Koine, Accessibility not granted"; its menu is "Accessibility Not Granted…", a separator, "Settings…", "Quit Koine" |
| No visible menu bar | TextEdit opened over Koine's window | TextEdit is in front and the menu bar is its, though Koine's window is on screen |
| Reopen from the menu | close the window; choose "Settings…" with the pointer; close and choose it three more times | the window is back each time, first in the front-to-back list and the key window, over TextEdit's; the item is there throughout |
| Resize | drag the window's corner (not `agent window-resize`, which is not held to the least size) out, then in past the least size | larger as dragged; no smaller than 440 wide and 320 plus the title bar high; at that size every control is still reached by scrolling |
| Shortcuts | in the Client label field: type, ⌘A ⌘C ⌘X, ⌘V; then ⌘W | the field empties on cut and returns on paste; ⌘W closes the window and the item stays |
| A client's request | a guest client enrols with `scripts/vm-verify-enrollment-client.py`, with no credential and no consent from the user; a second | within a poll the label reads "Koine, 1 grant request waiting, Accessibility not granted" and then "…2 grant requests waiting…"; the menu leads with "Review 1 Grant Request…" and then "Review 2 Grant Requests…"; no window opened by itself |
| A status line | from the least size, choose "Review 2 Grant Requests…"; deny both | the window opens at Requests: a request row lies wholly on screen; the label and menu drop the requests |
| The Accessibility line | scroll the window to its end, close it, choose "Accessibility Not Granted…" | the window opens with the Accessibility text on screen |
| Consent | give Accessibility in System Settings (the same steps `scripts/vm-verify-desktop-lib.sh` uses) | with no restart the label reads "Koine" and the menu is "Settings…", "Quit Koine" only |
| Silent launch | enable "Start Koine at login" in the window; Quit Koine from the menu; `open` the bundle once | no process, no `endpoint.json` after Quit; after the launch the descriptor and the item are there, the label is "Koine" and no window opens |
| Reopen the running application | `open` the bundle again | the window opens and is the key window |
| Login launch | ⌘Q from the window, then `shutdown -r now`; the golden logs in automatically | the process, the descriptor and the item exist after login with nothing having launched Koine; the label is "Koine", no window, still an agent application |
| Quit from the menu | choose "Quit Koine" | no process, no `endpoint.json`, connection refused on the old port |

## What this route does and does not show

- **The status item is read through System Events.** TestAnyware's agent lists
  windows, not status items, so the item's accessibility description (the label),
  position and menu items are read with `osascript` in the guest and the item and
  its menu are chosen with the pointer over VNC. System Events asks, once per
  clone, whether the agent may control it; the script answers that prompt by
  clicking Allow (`grant_system_events_automation` in `scripts/vm-verify-lib.sh`).
  That consent lives in the clone and is not Koine's.
- **A menu chooses nothing for a click with no pointer movement before it**, so
  `click_at` moves the pointer onto the target first. An item chosen through System
  Events' own `click` does not make the application active; only the pointer does,
  which is how a user chooses.
- **A drag resizes, an accessibility resize does not obey the least size.**
  `agent window-resize` set the window to 200 by 200. A drag of the corner stops at
  440 wide and 320 high in content (a 440 by 352 frame).
- **The mark is read as the label.** The dot is also seen in
  `…-mark.png`, but the check asserts the accessibility label, which the item
  states in words.
- **A launch that must stay silent cannot be retried.** `open` of a running Koine
  is a reopen and shows the window, and `guest()` repeats an exec the agent
  falsely reports as timed out, so the silent launch is `guest_once`, followed by
  a wait for the descriptor.
- **Notification banners are windows.** A "Login Item Added" banner is a window of
  Notification Center, in front of everything while it shows, so the front-to-back
  list is read without Notification Center's windows (`front_windows`).
- **TextEdit's first launch.** Choosing "Settings…" within seconds of TextEdit's
  first launch on a clean clone left Koine's window behind TextEdit's in three runs
  of five, and never in some twenty-five choices made once TextEdit had been up for a
  while, with Koine freshly launched or not. The cause is not established, so the
  script waits for TextEdit to settle before it asks.
- **No quarantine and Gatekeeper is off in the golden**, as in
  [resident-app-vm.md](resident-app-vm.md). Nothing here is evidence of what
  Gatekeeper does on a stock machine; the notarized build is shown in
  [notarized-release-vm.md](notarized-release-vm.md).
- **Restart, not log out.** Login launch is exercised by a restart and the golden's
  automatic login, with Koine quit first so that macOS's reopening of running
  applications cannot be what starts it.

## Evidence

Run of 2026-10-17 against the **notarized, stapled 0.3.0** bundle (tag `v0.3.0`,
submission `a216930f-6424-4106-a4fb-31659ba17d9c`), signed `Developer ID
Application: Antony Blakey (TA43A4RUP3)`. VM: clone of
`testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64, 1920×1080, on an
Apple-silicon host. Installed by `ditto`, so it carries no quarantine attribute
and the golden's Gatekeeper assessments are off (`override=security disabled`);
the quarantined, enforcing case is
[notarized-release-vm.md](notarized-release-vm.md)'s. Result: **passed**, every
expectation above.

```
== Start a clean VM (koine-verify-19511)
Gatekeeper: assessments disabled

== Install the signed bundle (ditto zip, testanyware file upload, ditto -x)
Quarantine attribute: xattr: /Applications/Koine.app: No such xattr: com.apple.quarantine
/Applications/Koine.app: valid on disk
/Applications/Koine.app: satisfies its Designated Requirement
Identifier=dev.antony.Koine
CodeDirectory v=20500 size=37148 flags=0x10000(runtime) hashes=1150+7 location=embedded
Authority=Developer ID Application: Antony Blakey (TA43A4RUP3)
Authority=Developer ID Certification Authority
TeamIdentifier=TA43A4RUP3
/Applications/Koine.app: accepted
source=Notarized Developer ID
override=security disabled
origin=Developer ID Application: Antony Blakey (TA43A4RUP3)

== First launch: no Dock icon, one menu bar item, and the settings window because setup needs the user
Windows: ["Koine Settings"]
Default frame: 720 95 480 712
Background only (an agent application): true
Dock: Finder, Apps, Safari, Messages, Mail, Maps, Photos, FaceTime, Phone, Calendar, Contacts, Reminders, Notes, TV, Music, Games, App Store …
Item: Koine, Accessibility not granted
Menu: Accessibility Not Granted…, , Settings…, Quit Koine

== No visible menu bar, even with the window open: the menu bar stays the previous application's
Front application: TextEdit

== Close the window; Settings… brings it back over TextEdit's, to the front

== The window resizes: larger, then no smaller than its least size, where its content scrolls
Larger: 40 40 701 901
Smaller: 40 40 440 352
grant-label at y=437.0 moved to y=337.0 under --dy -10; towards the end is --dy -10

== Shortcuts, with no visible menu bar: ⌘A, ⌘C, ⌘X, ⌘V in a field, ⌘W

== A client's request shows the mark and a line within a poll, and never opens the window
Menu: Review 1 Grant Request…, Accessibility Not Granted…, , Settings…, Quit Koine
Menu: Review 2 Grant Requests…, Accessibility Not Granted…, , Settings…, Quit Koine

== The line opens the window at Requests, scrolled there from the least size
Requests on screen: ["request-label-567fcc05-a8a2-455d-a69f-6118204c6577","vm-editor"]
Menu: Accessibility Not Granted…, , Settings…, Quit Koine

== The Accessibility line opens the window at Accessibility, scrolled there from below

== Consent given in System Settings: the mark and the line go within a poll
Menu: Settings…, Quit Koine

== Setup complete: enable login launch, Quit from the menu, and a launch by hand starts silently
Item: Koine; windows: 0

== Opening Koine again while it runs shows the window

== Quit with ⌘Q from the window, then restart the VM: only the login item can start Koine

== After login, with nothing having launched Koine: the item, and no window
489 /Applications/Koine.app/Contents/MacOS/Koine
Item after login launch: Koine; windows: 0

== Quit Koine from the menu: the server stops as it always has
curl to the old port 49152: exit 7

== PASSED — transcript in .build/vm-verify/menu-bar-20261017T122935.log
```

Earlier runs failed on the matters noted above (a retried `open`
reopening the window; a Notification Center banner counted as the front window;
TextEdit's first launch), and on the resize being tried with an accessibility
resize that the window does not hold to its least size. None of them was Koine
behaving other than as specified.

## Koine 0.4.0

The check ran on the **notarised, stapled 0.4.0** bundle. The bundle is tag `v0.4.0`, submission `3a73ea8c-e99d-4d98-a943-5b4c1a0e9f26`, CDHash `160b0f0b39a0541f99b8d656a5c87dc3bad9ef5c` and zip SHA-256 `e1cd1481195e41a042a49cc2131d35fb12e34c0655c3e78375a965f7438af4e8`.
It passed on 5 of 9 runs, and the last 5 runs all passed. The released 0.3.0
bundle passed 3 of 3 runs with the same script. The runs were on 2026-10-27 and
2026-10-28 on macOS 27.0.1.

The failures included "the window did not come to the front" (twice, at
different steps) and `testanyware input move` rejecting an argument of `-1`
(twice). The code difference between `v0.3.0` and the 0.4.0 commit touches no
window or activation code. The sample is too small to show a difference between
the two bundles. Issue 14 tracks it.

**The resize by a drag was not run.** In this guest (macOS 27.0.1, testanyware
2.7.0), a drag of the title bar or of a window corner has no effect at any
position. A drag of a scroll thumb works. The released 0.3.0 bundle fails the
same way, so the guest or the input tool is the cause.

The script now tries a title-bar drag first. If the window does not move, the script prints `NOT RUN`
for the resize assertions and does not count them as a pass. It still runs the
least-size screenshot and the scroll-reachability steps.

The claim that the window resizes and keeps its content reachable rests on the
0.3.0 run above. Transcripts of passing 0.4.0 runs: `menu-bar-20261027T222535.log`,
`menu-bar-20261027T232206.log`, `menu-bar-20261027T233659.log`,
`menu-bar-20261027T235535.log` and `menu-bar-20261028T001643.log`.
