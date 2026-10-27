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
mise exec -- task check:vm-window-resize
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
  The resize phase explicitly focuses the window and checks its front/focused
  state before the helper prepares a point three pixels inside the bottom-right
  corner, then sends one `input drag --steps 100` with held-button movement.
  It tests growth directly before shrinking. The title-bar movement probe used
  by earlier macOS 27 attempts could skip a working corner route; it is removed.
  Both dimension assertions must run before the minimum-size screenshot and
  scrolling checks. A failed action or assertion stops the scenario and gives
  no resize acceptance. The screenshot filename records the observed dimensions.
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

**The resize by a drag was not run in these attempts.** In this guest (macOS 27.0.1, testanyware
2.7.0), the attempted title-bar and corner routes had no effect at the tested
positions. A drag of a scroll thumb worked. The released 0.3.0 bundle failed the
same way, so the guest or the input tool is the cause.

At that point the script tried a title-bar drag first. If the window did not
move, it printed `NOT RUN` for resize and still ran a screenshot and scrolling
at the observed size. The later [corner-route investigation](#user-input-corner-route--2026-10-28)
finds a working corner path in this environment and removes that proxy gate.

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

## Historical activation route and installed-bundle inventories — 2026-10-28

The historical activation failure remains **unexplained and unresolved**. A
single-action recreation succeeded with qualified native observations, but it
cannot explain the earlier screenshot-confirmed failure. No application repair
or new focus polling bound was selected. The scenario now inventories the
installed guest bundle as well as the separately recorded host input.

### Single-action recreation

Guest `koine-menu-k8-diagnosis` used the same released 0.4.0 input, macOS 27.0.1
(26A434), TestAnyware 2.7.0 and 1920×1080 display. The
[tool and bundle record](menu-bar-activation/host-tools.txt) identifies the
subject. The [setup](menu-bar-activation/setup.sh) and its
[transcript](menu-bar-activation/setup.log) installed and verified the signed
bundle, answered Automation consent, launched Koine once, then launched TextEdit
once and used the inherited ten-second settling delay.

The [first diagnostic wrapper](menu-bar-activation/diagnose-upload-permission.sh)
closed Koine once and [failed before any Settings action](menu-bar-activation/diagnose.log):
upload had not preserved the native observer's executable permission. After one
`chmod +x` in the guest, the [corrected wrapper](menu-bar-activation/diagnose.sh)
started from the already-closed window. It neither repeated close nor explicitly
focused TextEdit. The [intervention record](menu-bar-activation/diagnostic-notes.txt)
preserves that correction and the extra read-only window observation.

The [corrected transcript](menu-bar-activation/diagnose-2.log) records one Settings
click, using the unchanged k7 [fresh-process native observer](menu-bar-focus/activation-snapshot.m).
Both native execs returned exit code zero without a timeout.

| Observation | Before Settings | After Settings, before any keyboard input |
| --- | --- | --- |
| Native activation | TextEdit active; Koine inactive | Koine active; TextEdit inactive |
| CoreGraphics normal-window order | TextEdit; no Koine window | Koine, then TextEdit |
| Agent windows | TextEdit first and focused | Koine first and focused; TextEdit unfocused |
| Visible state | Koine absent; its menu then open | Menu dismissed; Koine above TextEdit |

The [before native result](menu-bar-activation/historical-before-native.json),
[after native result](menu-bar-activation/historical-after-before-keyboard-native.json),
[before windows](menu-bar-activation/historical-before-windows.json) and
[after windows](menu-bar-activation/historical-after-before-keyboard-windows.json)
retain the raw readings. The [before image](menu-bar-activation/historical-before.png),
[open menu](menu-bar-activation/historical-open-menu.png) and
[after image](menu-bar-activation/historical-after-before-keyboard.png) corroborate
the visible transition. No keyboard intervention followed this action. The
status-item frame was `1660, 3, 36, 24`, and Settings was `1656, 71, 242, 24`;
the helper retained the same approach and destination coordinates as k5.

These are sequential observations, not an atomic snapshot or an event trace.
They establish that this action succeeded from a natively TextEdit-active
baseline. They do not reproduce or diagnose the historical failure. In
particular, this pass does not relabel the failure as an observer error or as
an external limitation. The [guest stop result](menu-bar-activation/diagnostic-stop.json)
records cleanup. This exploratory attempt had no complete per-file freeze.

The macOS floor remains 26 in `Package.swift`; the SDK and guest were 27.
Apple's [activation contract](https://developer.apple.com/documentation/appkit/nsapplication/activate())
and [cooperative activation guide](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation)
permit a denied activation request. That contract alone does not identify why
the earlier Settings action failed. No API change follows from it.

### Reusable installed-subject check

`task app:vm-verify-menu-bar` now records every regular file's SHA-256 and each
symlink's associated path and target in `/Applications/Koine.app` after
installation, before first launch, and after final Quit. Each read requires a
completion marker after successful enumeration and hashing. The scenario
compares the manifests before printing PASSED. An early scenario failure does
not imply that its after inventory ran. These endpoint inventories detect
changed, added or removed files and changed symlink targets at the endpoints;
they do not prove an immutable runtime or detect a transient edit restored
before the final read. Attributes and empty directories are outside this check.

The [focused checks](menu-bar-activation/checks-final.txt) passed Bash syntax,
ShellCheck, the existing pointer formatter check and eight pointer controls.
The [bounded review record](menu-bar-activation/inventory-review.txt) found no
actionable defect in inventory collection or comparison. Neither check
establishes native activation reliability.

### Remaining activation work

The existing `menu-bar-samples-k4` task now carries the precise follow-up:
prepare observation-only failure collection before freezing its declared finite
sample. At the first reproduced failure, capture fresh native activation,
CoreGraphics ordering, agent windows and the screenshot/menu state before
keyboard input, a window-focus action, or another menu action. Keep the guest
long enough to collect that evidence and then stop it. Use the qualified
fresh-process observer with executable permission; exclude the known System
Events focus disagreement and the old cached polling trace. Do not enlarge the
sample cap to chase a failure. If the observations still cannot classify the
failure, retain it and name the missing observation. All-green samples leave
the historical defect unresolved; they do not establish an external limitation
or justify an activation workaround.

### Complete scenario with both host and installed-subject inventories

Exactly one complete attempt ran after the scripts and inputs were settled:

```sh
KOINE_APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app" \
KOINE_VM_BASE=testanyware-golden-macos-27 \
KOINE_VM_ID=koine-menu-k8-scenario \
mise exec -- task app:vm-verify-menu-bar
```

It exited **0**. The [complete transcript](menu-bar-activation/scenario.log)
reaches PASSED after the first Settings reopen and each of its three further
iterations, request review, Accessibility reopening, the single explicit app
reopen and the Settings opening before Command-Q. It also completes the
shortcut checks, setup-complete silent launch, silent login launch across a
reboot and final Quit. The old port refused the final connection with curl exit
7. No scenario assertion failed or was skipped after a failure. No extra guest
input or observation was supplied outside the fixed scenario during this run.
The inherited TextEdit setup, settling delays and window-count observation
remain; this is no matched reliability comparison with earlier attempts.

**Resize was NOT RUN.** The title-bar drag left the window at `(40,40)`, so the
corner-resize assertions were not attempted. Scroll reachability ran at the
default size. This adds no minimum-size acceptance to the older 0.3.0 evidence.
The guest ran macOS 27.0.1 (26A434), arm64, with Gatekeeper enabled. Its installed
bundle had no quarantine attribute and passed strict deep signature verification
and the notarised Developer ID assessment. The display changed from 1920×1080
to 1024×768 after reboot; the final pointer coordinates used that new size.

The [inventory builder used for this attempt](menu-bar-activation/host-inventory.sh)
recorded every regular file of the actual extracted host bundle, the release
zip, Taskfile, `App/Info.plist`, all sourced scripts and both client fixtures.
The [before inventory](menu-bar-activation/scenario-subjects.sha256),
[after re-enumeration](menu-bar-activation/scenario-subjects-after.sha256),
[item-by-item verification](menu-bar-activation/scenario-subject-check.txt) and
[empty manifest diff](menu-bar-activation/scenario-inventory-diff.txt) agree.
Re-enumeration also detects additions or removals. The host bundle's
[before symlinks](menu-bar-activation/scenario-links-before.txt) and
[after symlinks](menu-bar-activation/scenario-links-after.txt)
[match](menu-bar-activation/scenario-links-diff.txt); its
[post-run signature verification](menu-bar-activation/signature-after.txt) passed.

The installed guest's own
[before manifest](menu-bar-activation/menu-bar-20261028T093123-installed-before.txt)
and [after manifest](menu-bar-activation/menu-bar-20261028T093123-installed-after.txt)
[match](menu-bar-activation/installed-inventory-diff.txt). Its before manifest
also [matches the extracted host bundle](menu-bar-activation/host-installed-before-diff.txt),
using the retained [relative-path host manifest](menu-bar-activation/host-bundle-relative.txt).
These are complete regular-file and symlink endpoint inventories of the actual
installed subject, with the runtime and metadata limits stated above. The
[post-run VM inventory](menu-bar-activation/vms-after.json) confirms that neither
of this investigation's guests remained running.

The screenshots retain [first launch](menu-bar-activation/menu-bar-20261028T093123-first-launch.png),
[Settings above TextEdit](menu-bar-activation/menu-bar-20261028T093123-over-textedit.png),
[the default size after resize NOT RUN](menu-bar-activation/menu-bar-20261028T093123-least-size.png),
[the request mark](menu-bar-activation/menu-bar-20261028T093123-mark.png),
[request review](menu-bar-activation/menu-bar-20261028T093123-requests.png) and
[silent login launch](menu-bar-activation/menu-bar-20261028T093123-after-login.png).
This is one passing attempt under its recorded conditions. It establishes no
activation repair or reliability rate. Issue 14's historical activation outcome
remains unresolved, with the precise follow-up stated above.

## User-input corner route — 2026-10-28

**Resize acceptance remains unestablished in macOS 27.0.1/TestAnyware 2.7.0.**
Corner input produced positive exploratory effects, but both fresh-guest
candidates failed to grow the window. Minimum-size acceptance continues to rest
on the older macOS 26/Koine 0.3.0 run. The title-bar probe could skip a usable
exploratory corner route, and
the former corner helper sent only mouse-down at the corner and mouse-up at
the destination. The replacement establishes a focused window, prepares the pointer three pixels inside
the corner and sends a combined `input drag --steps 100`, which includes
movement with the button held. The application and its size contract are
unchanged.

The [exploratory sequence and raw observations](window-resize/README.md)
retain the unsuccessful routes as well as the successful ones. In one
disposable 1920×1080 guest, the inherited title-bar probe left Koine and an
independent TextEdit window unmoved. A combined corner route nevertheless
grew both. At Koine's valid grown corner, the separate down/up sequence left
its 703×903 frame unchanged; preparation and a combined drag from that same
point then produced a 440×352 frame. The repaired helper itself repeated the
703×903 growth and 440×352 minimum and grew TextEdit from 751×701 to 853×823.
These are sequential exploratory observations without a complete subject
freeze. They identify the working recipe, not the necessity of each parameter
or a general cause for the unsuccessful title drags.

The [official TestAnyware v2.7.0 implementation](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-rfb/src/input.rs#L171-L194)
confirms the held-button interpolation semantics, and the helper cites it
beside the call. The ordinary separate `move` sends no held button; it cannot
substitute for that interpolation. [TestAnyware issue 12](https://github.com/Linkuistics/TestAnyware/issues/12)
is a closed input-reset fault repaired in 2.7.0. This investigation establishes
no new upstream defect, so no report was sent. It also establishes no product
activation repair or reliability rate.

The helper now lives in source-only `scripts/vm-window-resize-lib.sh`, still
loaded through the shared VM library. `task check:vm-window-resize` checks the
selected window's corner request and propagates failed pointer preparation or
drag transport instead of hiding it behind a later sleep. The
[four regression controls](window-resize/checks-red.txt) failed against the
former implementation and [passed after repair](window-resize/checks-green.txt),
with syntax, ShellCheck and formatting checks. The
[eight pointer controls](window-resize/pointer-checks.txt) also passed.
The [one bounded fresh-context review](window-resize/review.txt) found no
actionable issue. These checks supplement the native scenario.

The scenario now tests corner growth directly, with the original minimum-width,
minimum-height and scroll-reachability assertions. Failed input or a failed
dimension check stops execution and establishes no resize acceptance. The
minimum-size screenshot includes its observed dimensions in its filename.
Earlier resize NOT RUN attempts remain NOT RUN; their default-size scrolling
and screenshots do not gain minimum-size credit from this repair.

### Complete-scenario failure retained

Exactly one complete attempt ran with the first candidate script and the
unchanged notarised 0.4.0 input:

```sh
KOINE_APP_BUNDLE="$PWD/.build/menu-interaction/Koine.app" \
KOINE_VM_BASE=testanyware-golden-macos-27 \
KOINE_VM_ID=koine-resize-k3-scenario KOINE_VM_KEEP=1 \
mise exec -- task app:vm-verify-menu-bar
```

The [complete log](window-resize/scenario.log) stopped at Settings reopen 3:
TextEdit was first/focused and Koine was behind it. The scenario exited 1;
Task returned 201, retained in [the wrapper result](window-resize/scenario.exit).
First launch, the first Settings reopen and loop iterations 1 and 2 passed.
**Resize and all later assertions were NOT RUN**: minimum-size scrolling,
shortcuts, requests, consent, setup-complete silent launch, explicit app reopen,
Command-Q, login restart and final Quit have no result from this attempt.

Before any keyboard or focus intervention, observation-only collection retained
[a screenshot](window-resize/scenario-activation-failure.png),
[agent windows](window-resize/scenario-failure-windows.json) and
[fresh native activation/CoreGraphics ordering](window-resize/scenario-failure-native.json).
They agree: TextEdit active and in front, Koine inactive and behind it, menu
dismissed. The native observer returned zero without a timeout. Its
[binary](window-resize/failure-observer-binary) and
[digest](window-resize/failure-observer.sha256) identify the reused k7 observer;
the [source and qualification](menu-bar-vm.md#which-observations-can-support-a-conclusion)
remain applicable. These are sequential post-failure observations, with no
native pre-action observation. They reproduce and corroborate the activation
failure but do not explain it or select an application repair. No full-scenario
retry was made to obtain a pass. K4 retains the causal investigation and a
complete run of the resulting resize route.

The [host inventory builder](window-resize/host-inventory.sh),
[before hashes](window-resize/scenario-subjects.sha256),
[after re-enumeration](window-resize/scenario-subjects-after.sha256),
[item checks](window-resize/scenario-subject-check.txt),
[empty manifest diff](window-resize/scenario-inventory-diff.txt) and
[symlink comparison](window-resize/scenario-links-diff.txt) agree. Subjects are
every regular file in the extracted app, its release zip, Taskfile,
`App/Info.plist`, all sourced helpers and both uploaded client fixtures.
The [archived initial scenario](window-resize/initial-source/vm-verify-menu-bar.sh)
and [initial helper](window-resize/initial-source/vm-window-resize-lib.sh) match
their measured hashes, preserving the source before the later focus-setup edit.

The normal after-Quit inventory was not reached. An explicit
[post-failure guest read](window-resize/scenario-installed-after-failure.json)
returned complete output ending in the required marker, despite the driver's
false 30-second timeout. No action was retried. Its
[parsed manifest](window-resize/scenario-installed-after-failure.txt)
[matches](window-resize/scenario-installed-failure-diff.txt) the
[installed before manifest](window-resize/menu-bar-20261028T100532-installed-before.txt).
These are endpoint regular-file/symlink checks, with no claim about transient
runtime changes, attributes or empty directories. The
[stop result](window-resize/scenario-stop.json) records cleanup.

### Focused qualification and its failed first candidate

One separate clean-guest attempt of the exact resize/scroll segment used the
[first focused wrapper](window-resize/resize-only.sh). Its
[log](window-resize/focused.log) and [exit 1](window-resize/focused.exit) retain
another failure: the three-pixel drag left the fresh 480×712 window unchanged.
The dimension assertion correctly failed, and minimum-size scrolling was NOT RUN.
Its [before](window-resize/focused-subjects.sha256) and
[after](window-resize/focused-subjects-after.sha256) subject inventories,
[item checks](window-resize/focused-subject-check.txt),
[manifest diff](window-resize/focused-inventory-diff.txt) and
[symlink diff](window-resize/focused-links-diff.txt) agree. This failed candidate
is retained separately from the later revised recipe.

In follow-up exploration, both eight-pixel and three-pixel inset paths worked
after explicit window focus. An AX resize prepared the default frame for one
comparison only; no acceptance rests on that assignment. The
[geometry setup log](window-resize/exploratory/geometry-setup.log) and
[three-pixel before](window-resize/exploratory/geometry-compare-three-before.json)/
[after](window-resize/exploratory/geometry-compare-three-after.json) observations
retain this distinction. Earlier exploratory input sent before setup completed
is unqualified; it is retained in the evidence directory rather than treated
as a geometry result. The trials establish neither the necessity of an inset
nor the cause of the failed first focused attempt.

The revised resize phase explicitly focuses the window and checks its
front/focused state before dragging. This is a setup precondition for the size
exercise, after the unchanged menu-reopen assertions. It does not intervene in
or pass a failed menu activation. The revised recipe requires fresh native
qualification rather than pooling the earlier exploratory successes.

That one [revised focused attempt](window-resize/revised.log) also
[exited 1](window-resize/revised.exit): the explicitly focused 480×712 window
did not grow. Minimum-size scrolling was NOT RUN. Its
[before](window-resize/revised-subjects.sha256) and
[after](window-resize/revised-subjects-after.sha256) inventories,
[item checks](window-resize/revised-subject-check.txt),
[manifest diff](window-resize/revised-inventory-diff.txt) and
[symlink diff](window-resize/revised-links-diff.txt) agree. No result from either
focused candidate is a minimum-size pass. The
[final VM inventory](window-resize/vms-after.json) contains no running clone.

Both focused failures stopped before their installed-after reads, so they have
no installed-guest endpoint comparison. Their retained failure screenshots show
the default [first-candidate 480×712 frame](window-resize/menu-bar-20261028T100921-failure.png)
and [revised-candidate 480×712 frame](window-resize/menu-bar-20261028T101315-failure.png).
The [revised scenario source](window-resize/revised-source/vm-verify-menu-bar.sh)
and [revised helper bytes](window-resize/revised-source/vm-window-resize-lib.sh)
match the measured hashes in the [source recovery comparison](window-resize/revised-source-recovery.txt).
Only the helper's later explanatory comment changed. Its measured bytes were
recovered by restoring that comment and checking the pre-recorded SHA-256;
no runtime behavior changed after the revised failed attempt.

This investigation is therefore split at the input-delivery boundary.
The retained candidate fails an unperformed native exercise instead of allowing
the title-bar proxy to print a passing scenario with resize skipped. Further
work must isolate held-button delivery/timing in the fresh guest, with a matched
ordinary-window control, before selecting another route or blaming an upstream
component. The current CLI has interpolation steps but no exposed duration;
its source sends those steps without a per-step delay. That is an untested
diagnostic lead, not a measured cause. A native route must still grow the real
window, attempt shrinking below its limit and establish scrolling at the
observed minimum, or leave the result explicitly unresolved with a minimal
reproducer. The historical activation failure and the complete scenario remain
separate live work. No release, product fix, new upstream report or reliability
rate follows from this session.
