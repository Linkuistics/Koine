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

The pointer-helper checks run without a bundle or VM:

```sh
mise exec -- task check:vm-menu-pointer
```

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

## Coordinate repair and focus diagnosis, 2026-10-28

The coordinate helper is repaired; **the intermittent focus problem remains
open**. These are different outcomes. The menu-interaction Grove leaf was
decomposed after a real focus failure reproduced, so its remaining focus work
and complete scenario acceptance stay live. This investigation establishes no
failure rate and changes no Koine application code.

The subject was the released, notarised and stapled **0.4.0** zip downloaded
with `gh release download v0.4.0 --repo Linkuistics/Koine --pattern
Koine-0.4.0-aarch64-apple-darwin.zip --dir .build/menu-interaction`. Its SHA-256
was `e1cd1481195e41a042a49cc2131d35fb12e34c0655c3e78375a965f7438af4e8`;
the extracted bundle passed `codesign --verify --strict --deep` and had CDHash
`160b0f0b39a0541f99b8d656a5c87dc3bad9ef5c`. The older bundle in the other
workspace was 0.2.0 and was not used. CLI and running TestAnyware app were both
2.7.0. The guest base was `testanyware-golden-macos-27`, at 1920×1080.
The host's transcript filenames use local time; the guest clock is a separate
observation and is not used to compare event latency.

### Deterministic coordinate reproducer

With the old helper, `click_centre '100, 0, 22, 15'` computes the valid target
`(111, 7)`, then calls `testanyware input move 99 -1` before moving onto that
target. TestAnyware 2.7.0 rejects that first command with exit 2:
[CLI reproduction](menu-bar-interaction/negative-coordinate.txt). This is a
deterministic reproduction of the helper path, **not a recovered historical
source frame**: the two original failures did not retain that frame.

The repair preserves the centre of every accepted frame. It reads the actual
framebuffer dimensions, rejects invalid or off-display destinations, and bounds
only the synthetic approach point. At the top-left corner it uses a distinct
on-display approach pixel. Invalid frame input is refused before any pointer
event; fields are validated separately, including positive width and height.
The source-only `vm-menu-pointer-lib.sh` can be checked without initialising the
VM helper's bundle checks, transcript or cleanup trap.

The Bats controls first failed for the y=7 approach, corner geometry, malformed
frames and ignored transport failure. `task check:vm-menu-pointer` then passed
eight controls, including missing/malformed display dimensions and rejected
off-display destinations. These checks verify arithmetic, validation and CLI
arguments. They do not establish native focus behaviour. The
[check output](menu-bar-interaction/helper-checks.txt),
[source inventory](menu-bar-interaction/helper-subjects.sha256) and
[post-check verification](menu-bar-interaction/helper-subject-check.txt) preserve
the checked subjects. The existing installation and latency recipes now include
the extracted helper in their own digest lists; both changed recipes also passed
Bash syntax and ShellCheck.

### Real menu action: delivered, window opened, focus stayed with TextEdit

In guest `koine-menu-k2-diagnosis`, the first Automation setup attempt failed
while the prompt was still present. The prompt was answered manually through
TestAnyware input, and the diagnostic sequence was restarted after that consent.
This intervention makes the sequence exploratory, not an untouched acceptance
run. Its [failed Automation attempt](menu-bar-interaction/automation-attempt.log)
and [diagnostic transcript](menu-bar-interaction/diagnosis.log) are retained.
`testanyware doctor --json` reported the app reachable, matching CLI/app versions
and permitted local networking; its only failing check was the host app's login
item registration. No host setting was changed.

The diagnostic launched TextEdit once, waited ten seconds, closed Koine's
window once, observed zero Koine windows, then chose Settings once through
`choose_menu_item`. It did not repeat the action or explicitly focus a window.
The pointer transport calls returned success:

| Source | Frame | Approach | Destination and click |
|---|---|---|---|
| Koine status item | `1660, 3, 36, 24` | `(1666, 7)` | `(1678, 15)` |
| Settings… | `1656, 71, 242, 24` | `(1765, 75)` | `(1777, 83)` |

The [before-action window observation](menu-bar-interaction/before-action-windows.json)
contains TextEdit and no Koine window. The
[after-action observation](menu-bar-interaction/after-action-windows.json)
contains Koine Settings, behind TextEdit, with `focused: false`; TextEdit is
first and has `focused: true`. `koine_in_front` returned false. System Events
reported Koine's window `AXMain=true`, `AXFocused=false`, and the
[screenshot](menu-bar-interaction/after-action.png) shows TextEdit covering it.
A separate follow-up command returned `TextEdit`:

```sh
testanyware file exec 'osascript -e '\''tell application "System Events" to get name of first process whose frontmost is true'\''' --vm koine-menu-k2-diagnosis --json
```

The transcript's attempted combined `{name, frontmost}` process query is
malformed AppleScript and returned `-1728`; it is **not focus evidence**. The
individual query above and the window AX attributes are retained as raw
readings. The [later observer qualification](#which-observations-can-support-a-conclusion)
shows why they cannot serve as an independent focus oracle here. The agent's
window order and screenshot preserve the observed failure. Reading menu titles
after the action still returned titles; that read does not prove whether the
menu was visibly dismissed.

This establishes a delivered menu action with a window effect and a real
front/focus failure. It does not yet identify whether the menu-input route or
Koine's activation sequence caused the failure. A longer count wait or a repeated
action would not explain it. The next focus investigation must capture menu
dismissal and activation evidence, check every intended reopen independently,
preserve silent-launch versus reopen semantics, and complete the scenario.
The diagnostic guest was stopped after evidence capture.

### Additional whole-scenario attempt

Exactly one additional, unassisted Taskfile attempt ran with the repaired
pointer helper:

```sh
KOINE_APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app" \
KOINE_VM_BASE=testanyware-golden-macos-27 \
KOINE_VM_ID=koine-menu-k2-scenario \
mise exec -- task app:vm-verify-menu-bar
```

It exited **0**, with the existing checks printing PASSED and resize explicitly
**NOT RUN**. The [complete transcript](menu-bar-interaction/scenario.log)
records macOS 27.0.1 (26A434), arm64. Gatekeeper was enabled and accepted the
notarised bundle; this installation had no quarantine attribute. The initial
display was 1920×1080; after restart it was 1024×768. The helper read the new
dimensions and clicked the relocated status item and Quit successfully. Login
launch was silent and the final connection to the old port was refused. The
scenario's cleanup stopped its guest.

The [host/tool versions](menu-bar-interaction/host-tools.txt) and
[bundle identity](menu-bar-interaction/bundle-identity.txt) identify the subject.
Every entry in the [script and release-zip inventory](menu-bar-interaction/scenario-subjects.sha256)
was [verified unchanged after the run](menu-bar-interaction/scenario-subject-check.txt).
The extracted bundle passed strict deep signature verification before and after
the run. **Its complete file tree was not hashed before the run.** The original
zip checksum and signature checks are a weaker inventory than a full per-file
bundle freeze; the next acceptance run must include that actual input tree.

The script still checks focus after the first Settings reopen and after the
three-iteration loop, rather than after each intermediate reopen. Its explicit
application reopen still uses the retrying `guest()` wrapper. Consequently this
run does not establish the parent's stricter every-reopen/one-action criteria,
nor does it explain the failed diagnostic action. Request review, Accessibility,
silent launch, explicit reopen, login launch and final Quit all ran; no later
scenario assertion was skipped. Resize was the separate NOT RUN outcome, and
scroll reachability was exercised at the default size. Resize acceptance still
rests on the older 0.3.0 run, not this attempt. This is one successful attempt of
the existing script, with these stated limits, not a reliability estimate.

## Focus observation qualification — 2026-10-28

The k7 investigation used the same released 0.4.0 bundle and macOS 27.0.1
(26A434) golden, with TestAnyware 2.7.0. It made **no application change and
established no cause for the earlier screenshot-confirmed failure**. The
[environment record](menu-bar-focus/host-tools.txt) identifies the tools.

### Exploratory attempts and controls

All actions below used guest `koine-menu-k6-diagnosis`. Setup installed and
verified the released bundle, answered the System Events Automation prompt,
and launched Koine once. The [setup wrapper](menu-bar-focus/setup.sh) then
[failed](menu-bar-focus/setup.log) because `await_koine` is defined by the full
scenario, not its shared libraries. The next wrapper repeated that helper-scope
mistake and [failed before any menu action](menu-bar-focus/diagnose.log).
The retained `diagnose.sh` is the subsequently corrected wrapper; the failed
version's bytes were not retained. These are exploratory driver failures.

The corrected [first sequence](menu-bar-focus/diagnose.sh) and its
[transcript](menu-bar-focus/diagnose-2.log) closed Koine's window, chose Settings
once, and observed Koine first and focused in the agent. The
[open menu](menu-bar-focus/open-menu.png) is retained. The
[after-action image](menu-bar-focus/after-action.png) was captured later, after
blocking System Events reads and an intervening keyboard probe. That probe was
issued outside the scripted transcript. The image and
[Koine snapshot](menu-bar-focus/keyboard-koine.json) contain its witness text,
but the retained sequence does not establish how focus was obtained or a
pre-keyboard screenshot. The [TextEdit snapshot](menu-bar-focus/keyboard-textedit.json)
is also retained. Use the separately traced controlled sequence below for
the keyboard-delivery conclusion.

A [second sequence](menu-bar-focus/controlled.sh), with its
[transcript](menu-bar-focus/controlled.log), added a fresh native observer.
Its before-action native snapshot still named Koine active after the window
closed; closing a window had not established a TextEdit-active baseline. This
sequence therefore does not establish an activation transition from TextEdit.

The [controlled sequence](menu-bar-focus/controlled-textedit.sh) explicitly
focused TextEdit **before** opening the menu. Its
[transcript](menu-bar-focus/controlled-textedit.log) records one Settings action
and no window-focus intervention after that action:

| Observation | Before the action | After the action, before keyboard input |
|---|---|---|
| Agent windows | TextEdit focused; no Koine window | Koine first and focused; TextEdit unfocused |
| Fresh native activation | TextEdit active; Koine inactive | Koine active; TextEdit inactive |
| Native normal-window order | TextEdit only | Koine, TextEdit |
| System Events front process | TextEdit | TextEdit |
| System Events Koine window AXFocused | No window | false |

The raw [before native envelope](menu-bar-focus/controlled-before-native.json)
and [after native envelope](menu-bar-focus/controlled-after-before-keyboard-native.json)
retain transport status and complete JSON output. The before read reported a
timeout with a complete answer; the after read exited zero. This
exploratory collection accepted complete parseable observation output even
when the driver reported a timeout; it did not resend an action.

The pointer source frames were `1660, 3, 36, 24` for the status item and
`1656, 71, 242, 24` for Settings. The approach/target pairs were
`(1666,7)→(1678,15)` and `(1765,75)→(1777,83)`. The
[before image](menu-bar-focus/controlled-before.png),
[open menu](menu-bar-focus/controlled-open-menu.png), and
[after image before keyboard input](menu-bar-focus/controlled-after-before-keyboard.png)
agree with the native ordering. The menu visibly dismissed and the window
appeared above TextEdit. Only after those observations did keyboard input append
`k6-controlled-witness` to the client label. The
[Koine keyboard snapshot](menu-bar-focus/controlled-keyboard-koine.json) records
the exact value and the focused text field; the
[TextEdit snapshot](menu-bar-focus/controlled-keyboard-textedit.json) and
[after-keyboard image](menu-bar-focus/controlled-after-keyboard.png) retain the
other observations. This establishes keyboard delivery for this action.

### Which observations can support a conclusion

The [native snapshot source](menu-bar-focus/activation-snapshot.m) reads
`NSRunningApplication.active`, `NSWorkspace.frontmostApplication` and
CoreGraphics normal-window ordering in a **fresh process per observation**.
It was compiled on the host, then executed only inside the guest:

```sh
xcrun clang -fobjc-arc -mmacosx-version-min=26.0 activation-snapshot.m \
  -framework AppKit -framework ApplicationServices -o activation-snapshot
```

System Events continued to report TextEdit frontmost and Koine's window
AXFocused false even while native activation, visible ordering and actual
keyboard receipt agreed on Koine. These System Events queries are an
**not a qualified focus oracle in this guest**, including when the AppleScript
syntax is correct. This does not invalidate the predecessor's screenshot and
agent-order evidence of a real failure; it limits the additional System Events
corroboration claimed there.

Two other diagnostic instruments are explicitly excluded as activation/focus
proof. The [polling monitor](menu-bar-focus/front-monitor.m) did not service
AppKit's event loop. The macOS 27 SDK's `NSRunningApplication.h` documents that
time-varying application properties persist until a main-run-loop turn in a
common mode. Thus its [trace](menu-bar-focus/front-monitor.jsonl) may retain
cached activation state; its activation field is excluded rather
than treated as a measured transition. The
[system-wide AX probe](menu-bar-focus/focus-witness.m) reported trusted but
returned `-25204` for both focused application and focused element, as retained
in its [result](menu-bar-focus/native-focus.json). Those reads established no
keyboard recipient. An additional JXA experiment using `ObjC.deepUnwrap` on the
running-application array failed with a TypeError before producing a snapshot;
its [transcribed result](menu-bar-focus/jxa-attempt.txt) supplies no focus evidence.

Apple's [activate documentation](https://developer.apple.com/documentation/appkit/nsapplication/activate())
(available since macOS 14) and
[cooperative activation guide](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation)
state that activation is a request that can be denied. The manifest's macOS
floor is 26; this run used 27.0.1. That API contract is a diagnostic lead,
**not an established explanation** of the historical failure. No focus polling
bound, activation workaround or application repair was selected.

The exploratory guest was stopped after collection. Its bundle and scripts did
not have a complete before/after per-file freeze; this is observer qualification
and reproduction evidence, not a frozen acceptance sample.

### Every intended reopen now has its own assertion

The scenario now checks the first Settings reopen, **each** of its three further
Settings iterations, request review, the Accessibility line, explicit application
reopen and the Settings opening immediately before Command-Q. Each assertion
checks agent window order and its focused flag after the window-count observation.
A count alone does not pass it. The initial launch and explicit reopen now use
`guest_once`; the setup-complete silent launch remains its own separate,
unrepeated operation. No action retry or additional focus poll was introduced.
The Taskfile description names this coverage and the explicit resize NOT RUN
outcome. The [host checks](menu-bar-focus/checks.txt) record syntax, ShellCheck
and the eight existing pointer controls.

This plumbing does not repair application activation. The scenario still uses
its inherited TextEdit settle delay and window-count polling; a successful run
under those conditions cannot explain the historical failure. The residual
activation investigation must qualify its timing and focus instruments before
selecting a repair or a new polling policy.

### Complete scenario attempt with the stricter assertions

Exactly one full attempt used the changed scenario:

```sh
KOINE_APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app" \
KOINE_VM_BASE=testanyware-golden-macos-27 \
KOINE_VM_ID=koine-menu-k7-scenario \
mise exec -- task app:vm-verify-menu-bar
```

It exited **0**. The [complete transcript](menu-bar-focus/scenario.log) reaches
PASSED after every intended reopen assertion, setup-complete silent launch,
explicit reopening, Command-Q, silent login launch after reboot, and final Quit.
The final request to the old port returned curl exit 7. No scenario assertion
failed or was skipped after a failure. **Resize was NOT RUN** because the
window's title-bar drag left it at `(40,40)`, so no corner drag was attempted.
Scroll reachability ran at the default size. Minimum-size resize acceptance
continues to rest on the older 0.3.0 evidence; this attempt adds none.

The guest ran macOS 27.0.1 (26A434), arm64, with Gatekeeper enabled. Installation
had no quarantine attribute and accepted the notarised Developer ID bundle.
The display changed from 1920×1080 to 1024×768 after reboot; the pointer helper
used the new dimensions for final Quit. Its cleanup stopped the guest; a final
VM inventory showed no running clone.

The [before inventory](menu-bar-focus/scenario-subjects.sha256) hashes every
regular file of the actual extracted input app at
`.build/menu-interaction/Koine.app`, the original release zip, Taskfile, each
sourced script and both uploaded client fixtures. The
[after inventory](menu-bar-focus/scenario-subjects-after.sha256),
[item-by-item verification](menu-bar-focus/scenario-subject-check.txt) and
[empty inventory diff](menu-bar-focus/scenario-inventory-diff.txt) agree.
Re-enumeration also checked for added or removed files rather than checking only
the old paths. The app's [before symlink inventory](menu-bar-focus/scenario-links-before.txt)
and [after inventory](menu-bar-focus/scenario-links-after.txt) also
[match](menu-bar-focus/scenario-links-diff.txt), and its
[post-run signature verification](menu-bar-focus/signature-after.txt) passed.
This is a per-file freeze of the extracted **host input bundle** supplied to the
installer. The installed guest copy passed strict deep signature verification;
its own tree was not independently hashed before and after execution.

`signing-env.sh` also reads the repository's `App/Info.plist`. Its
[supplemental identity](menu-bar-focus/source-config-identity.txt) matches the
session's initial clean, immutable parent `a764302d`. This comparison is recorded
separately from the pre-run SHA inventory, which did not include that source
configuration path. A future inventory should include it explicitly.

The run's screenshots retain [first launch](menu-bar-focus/menu-bar-20261028T091002-first-launch.png),
[Settings above TextEdit](menu-bar-focus/menu-bar-20261028T091002-over-textedit.png),
[the default-sized window after the resize NOT RUN](menu-bar-focus/menu-bar-20261028T091002-least-size.png),
[request mark](menu-bar-focus/menu-bar-20261028T091002-mark.png),
[request review](menu-bar-focus/menu-bar-20261028T091002-requests.png) and
[silent login launch](menu-bar-focus/menu-bar-20261028T091002-after-login.png).
During an extended position-read delay, two additional observation-only calls
collected a [screenshot](menu-bar-focus/scenario-midrun.png) and
[window read](menu-bar-focus/scenario-midrun-windows.json); their
[collection note](menu-bar-focus/scenario-midrun.txt) explains the race with the
script. No additional input or focus action was supplied. Those observations
do not establish an atomic action boundary.

This is one successful attempt of the stricter script, under its stated timing
and observation conditions. It is neither a reliability estimate nor a repair
of the unexplained historical focus failure. The remaining investigation must
explain that failure using qualified observations before selecting a product
change or activation-wait policy.
