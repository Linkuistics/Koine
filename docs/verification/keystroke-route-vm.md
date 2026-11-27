# Route A for app input: VM probe

This record answers the questions that the design of app input needs before
Koine 0.7.0. Route A sends a chord into the target's own event stream with
`CGEventPostToPid`. Do the configured apps act on such a chord? Does the chord
skip the system shortcuts and the keyboard taps of other processes? Does the
call need posting access? And how can Koine read the Space shortcuts and count
the Spaces?

**Route A works for the five apps in the VM.** Safari, Finder, Zed, Zotero and
Obsidian each acted on one chord from Antony's Modaliser configuration while
the app was in front. A Control-2 sent by route A switched no Space, and a
keyboard tap at the session level did not see a route A chord. The same chord
at the HID event tap switched the Space, and the tap saw it.

**Route A needs posting access.** Without it, a route A post delivered
nothing, and macOS showed a consent dialog that named the posting app. So
Koine checks its consent and its posting access before it sends, as it does
for the media keys.

**No public interface counts Spaces.** The private SkyLight call
`SLSCopyManagedDisplaySpaces` gives the live count and the current Space. The
preferences domain `com.apple.spaces` gives the count through a public call,
but its format is not documented, and its current Space lags.

## Procedure

```sh
task fixture:keystroke-route-vm   # scripts/vm-check-keystroke-route.sh
```

The task starts a clone of the prepared launcher image
(`task launchers:prepare`). That image holds Zed, Zotero and Obsidian past
their first runs. The task installs no Koine, and it sends no chord on the host.

Three test tools, which Koine never ships, do the work:

- `Fixtures/KeystrokeProbe` builds each chord as Modaliser's
  `KeystrokeEmitter.swift` builds it. It sends the modifier key-down events,
  the key down and up, and then the modifier key-up events in reverse order.
  It posts each event with `CGEventPostToPid` to a named process, or at the
  HID event tap. Only the post differs. Each event carries a tag in its source
  user data. The probe also reads the shortcut settings and counts the Spaces.
- `Fixtures/KeyWitness` is an app with one window. It records each key event
  that reaches it, with the sending process and the tag. It shares no code
  with the probe.
- `Fixtures/WindowIdentityProbe` names the front app, lists the windows of an
  app and the windows on screen, and listens at the session event tap.

The TestAnyware agent starts the probe, and the probe inherits the agent's
Accessibility consent and posting access. To post without them, the probe
also ships as two app bundles. `open` starts each bundle as its own process,
with no consent of its own. The two bundles differ only in their identifiers,
so macOS meets each one apart.

The guest helper repeats a command that the agent reports as timed out. So
each post takes a guard directory, and a repeat posts nothing. Each effect is
read by a witness, and never from the probe.

1. **Spaces.** The run reads the start state. Then it clicks the add button
   of the Spaces bar in Mission Control, as a user does. SkyLight must then
   report two desktops, with Desktop 1 current.
2. **Absent shortcut.** The probe posts Control-2 at the HID event tap. The
   key witness is in front, and the guest has no Desktop 2 entry.
3. **Shortcuts on.** The run writes the "Switch to Desktop 1" and "Switch to
   Desktop 2" entries as Control and the digit. It applies them with
   `activateSettings -u`.
4. **Control-2 by route A.** The probe sends Control-2 to the key witness with
   `CGEventPostToPid`. The Space must not change, and the key witness must
   receive the whole chord.
5. **Control-2 at the HID event tap.** The Space must change to Desktop 2,
   and the key witness window must leave the on-screen window list. Control-1
   then returns to Desktop 1.
6. **Session tap.** A listen-only tap at the session level runs for 25
   seconds. Route A sends Control-Shift-K to the key witness, and then the HID
   event tap gets Control-Shift-J. The tap must see J and must not see K.
7. **Shortcut off.** The run turns off "Switch to Desktop 2", and the probe
   posts Control-2 at the HID event tap.
8. **Missing Space.** The run turns on "Switch to Desktop 3" with two Spaces,
   and the probe posts Control-3 at the HID event tap.
9. **Apps.** The run brings each app to the front and reads its witness.
   Route A sends one chord to the front app's process. Then the run reads the
   witness again.
10. **Background target.** With the key witness in front, route A sends
    Command-N to Finder. The run records what Finder does, and asserts
    nothing.
11. **No access.** With the key witness in front, the first bundle sends
    Control-Shift-L by route A. The run reads the witness and looks for a
    consent dialog. Then the second bundle posts Control-Shift-H at the HID
    event tap, and the run does the same. A last control proves that the key
    witness still receives a chord from the agent-started probe.

| App | Chord from the configuration | Witness |
| --- | --- | --- |
| Finder | New Window, Command-N | Accessibility: the count of Finder's standard windows |
| Safari | New Tab, Command-T | Accessibility: the tab elements of Safari's tab bar |
| Zed | Command Palette, Command-Shift-P | OCR: the palette's "Execute a command" text |
| Zotero | Advanced Search, Command-Shift-F | OCR: the "Advanced Search" pane |
| Obsidian | New Note, Command-N | The files of the vault |

Zed exposes only its menu bar to Accessibility, so OCR reads its palette.
Zotero 10 opens Advanced Search as a pane in its main window, not as a new
window. Obsidian stops at its vault chooser until it has a vault, so the run
writes one vault with one note into Obsidian's settings first.

## Run of 28 November 2026

The run used macOS 27.0.1 (26A434) in the guest, on a clone of the image
`koine-launchers-prepared`. The apps were Safari 27.0.1, Finder 27.0, Zed
1.25.3, Zotero 10.0.6 and Obsidian 1.14.5. Zed offered to restart into a
downloaded update, so the run used the installed version. The transcript is
[keystroke-route-20261128T020941.log](keystroke-route-vm/keystroke-route-20261128T020941.log).
The run captured the screen after each app's chord and at each consent check.

| Step | Observation |
| --- | --- |
| Spaces | SkyLight and the preferences reported one desktop at the start. After the click, both reported two desktops, with Desktop 1 current. |
| Absent shortcut | The guest had no entries 118 to 126. Control-2 at the HID event tap left Desktop 1 current. The key witness received Control down, key 19 down and up, and Control up. |
| Shortcuts on | Entries 118 and 119 read as enabled, with the parameters `65535, 18, 262144` and `65535, 19, 262144`. |
| Control-2 by route A | Desktop 1 stayed current. The key witness received the whole chord in Modaliser's order, with the probe's tag on each event. |
| Control-2 at the HID event tap | Desktop 2 became current. The key witness window left the on-screen list, and Finder became the front app. The key witness received only Control down and up. Control-1 then returned to Desktop 1. |
| Session tap | The tap began 2.2 seconds before the route A post and 3.3 seconds before the HID post, and it listened for 25 seconds. It saw Control-Shift-J, key 38. It saw no event of Control-Shift-K, key 40. The key witness received both chords. |
| Shortcut off | Entry 119 read as disabled. Control-2 at the HID event tap left Desktop 1 current, and the key witness received the whole chord. |
| Missing Space | Entry 120 read as enabled with two desktops. Control-3 at the HID event tap changed nothing, and the key witness received the whole chord. |
| Finder | The standard windows went from 1 to 2. |
| Safari | The tab elements went from 0 to 2. With one tab, Safari shows no tab bar. |
| Zed | "Execute a command" went from 0 to 1 on the screen. |
| Zotero | "Advanced Search" went from 0 to 1 on the screen. |
| Obsidian | The vault went from one note to two, and the new note is `Untitled.md`. |
| Background target | Finder's standard windows went from 2 to 3, and Finder became the front app. |
| No access, route A | The bundle reported no consent and no posting access. The key witness received nothing. The consent dialog named "KeystrokeProbe". |
| No access, HID | The bundle reported the same. The key witness received nothing. The consent dialog named "KeystrokeProbeControl". |
| Witness control | The key witness received Control-Shift-L from the agent-started probe. |

In each app step, the window witness named the app in front before the post.
The probe sent the chord to that app's process.

## How Koine can read the shortcut for Control and a digit

The "Switch to Desktop N" shortcuts of Mission Control are the entries 118 to
126 of `AppleSymbolicHotKeys` in the preferences domain
`com.apple.symbolichotkeys`. Entry 118 is Desktop 1, and entry 126 is
Desktop 9. The probe reads them with `CFPreferencesAppSynchronize` and
`CFPreferencesCopyAppValue`.

- **The call is public. The domain and its format are not documented.**
  Apple documents CFPreferences, but not this domain or its entries.
- **An entry holds `enabled` and three parameters.** The parameters are the
  character (65535 for none), the key code and the modifier mask. Control
  alone is 262144. So Control-2 is the parameters `65535, 19, 262144`.
- **An absent entry acts as a disabled one.** The guest had no entries at the
  start. A Control-2 at the HID event tap then switched no Space, and the
  front app received the whole chord.
- **A remapped shortcut has another key code or mask.** The run did not
  remap a shortcut. It shows only the form that the probe compares.
- **The probe compares what the preferences hold.** The run applied each
  write with `activateSettings -u`, and the HID post then checked the
  setting. The run did not test a write that macOS has not applied.

## How Koine can count Spaces

The probe reads two sources. No public interface counts Spaces.
`CGWindowListCopyWindowInfo` is public, but it shows only which windows are on
screen.

| Source | Public | What the run found |
| --- | --- | --- |
| `SLSCopyManagedDisplaySpaces` in SkyLight, with `SLSGetActiveSpace` | No, private | The desktops of each display, their identifiers and the current Space, at once after each change <!-- tc: depart synonym-rotation because "display" here names a monitor, a noun, and not the action "show" --> |
| `SpacesDisplayConfiguration` in `com.apple.spaces`, through CFPreferences | The call is public. The domain and its format are not documented | The right count after the run added a Space. The preferences name the main display `Main`, not by its identifier |

An exploration in another clone of the same image showed a limit of the
preferences. After a switch to Desktop 2, SkyLight reported Desktop 2 at
once, and the preferences still reported Desktop 1. A read of the same domain
on Antony's Mac listed 19 display entries, and SkyLight reported one display
there. So the preferences counted the desktops of the main display in this run,
but they do not give the current Space.

Each source reports a type for each Space. Type 0 is a desktop, and type 4 is
a full-screen Space. The probe numbers the desktops of a display in order and
skips the other types. The run had one display and no full-screen Space, so it
does not show how macOS numbers desktops across displays.

## What reaches the front app

| Case | What reached the key witness in front | Space |
| --- | --- | --- |
| Shortcut on, Space exists, HID post | Control down and up only. macOS took the digit | Switched to Desktop 2, which held no window. Finder became the front app |
| Shortcut absent, HID post | The whole chord | No change |
| Shortcut off, HID post | The whole chord | No change |
| Shortcut on, no such Space, HID post | The whole chord | No change |
| Shortcut on, route A post to the key witness | The whole chord | No change |

So when Koine posts Control and a digit, the front app receives that chord in
three cases. They are an absent entry, a disabled entry and a missing Space.
The root brief has Koine refuse each of them before it posts.

## Posting access

The two bundles reported no Accessibility consent, no posting access and no
listening access. Each call returned without an error.

- **A route A post without access delivered nothing.** The key witness
  received no key. macOS showed the dialog "Device Control and Data Access
  (Events)": "“KeystrokeProbe” would like to control this Mac and access your
  data."
- **A HID post without access delivered nothing either.** macOS showed the
  same dialog for "KeystrokeProbeControl".
- **The key witness still received a chord afterwards** from the
  agent-started probe, so it was live throughout.

So `CGEventPostToPid` needs posting access, as the post at the HID event tap
does. macOS drops the events without an error. It also asks the user for
consent, which would be a new permission dialog for Koine. A check of
`AXIsProcessTrusted` and `CGPreflightPostEventAccess` before the post avoids
both.

## A target in the background

With the key witness in front, route A sent Command-N to Finder. Finder opened
a window, as it does in front, and it came to the front. So a target that
loses the front in the instant before it reads a chord can still act on that
chord. Its action can bring it to the front. This step did not read what the
key witness received.

## What the run establishes

- Safari, Finder, Zed, Zotero and Obsidian act on a chord sent by route A
  while they are in front. These apps use AppKit, Zed's own toolkit, the
  engine of Firefox and Electron.
- A route A chord skips the system shortcut for Control and a digit, and a
  session-level keyboard tap does not see it. This supports two consequences
  in the plan. The keystroke operation needs no list of refused chords, and
  Koine marks no event for client taps.
- Route A needs the same consent check as the post at the HID event tap.
- With the shortcut on and the Space present, macOS takes Control and the
  digit and switches the Space. Otherwise the front app receives the chord.
- Koine can read the shortcut through a public call on an undocumented domain.
  Only a private call counts Spaces and names the current Space live.

## What the run does not establish

- **Another macOS release.** The launcher image runs macOS 27.0.1. A later
  release needs a new run of this task.
- **Chromium and Qt.** Dia and Telegram need accounts that the VM does not
  have. The scheduled check on Antony's Mac covers them.
- **The other configured rows.** The run sends one chord for each app.
- **How Koine behaves.** The probe sends as Koine will send, but it is not
  Koine.
- **A remapped shortcut, a setting that macOS has not applied, several
  displays and full-screen Spaces.** The run tested none of them.
- **Keyboard layouts.** Modaliser's key table holds the key codes of the US
  ANSI layout. The guest used the US layout.
- **The race with a Space switch.** The run did not change a setting or a
  Space in the instant between the check and the post.

## Earlier runs

The repository keeps the transcripts of three earlier runs of this task.

- [keystroke-route-20261128T010928.log](keystroke-route-vm/keystroke-route-20261128T010928.log)
  stopped at the tap check, but the tap saw key 38. The check used `jq`'s
  `index` with an array argument. That form looks for consecutive elements,
  not for one pair. The check now compares each event with the pair.
- [keystroke-route-20261128T011901.log](keystroke-route-vm/keystroke-route-20261128T011901.log)
  stopped at the tap check, and the tap recorded no events. Its log did not
  show when the tap began. The step now waits until the tap process runs
  before it posts. The tap listens for 25 seconds, and the log prints when it
  began.
- [keystroke-route-20261128T013149.log](keystroke-route-vm/keystroke-route-20261128T013149.log)
  passed every check. But it reported no dialog after the HID post without
  access. Its own capture,
  [keystroke-route-20261128T013149-noaccess-hid.png](keystroke-route-vm/keystroke-route-20261128T013149-noaccess-hid.png),
  shows the dialog for "KeystrokeProbeControl". With that name, "this Mac"
  wraps to the next line, and OCR missed the whole phrase. The detector now
  looks for "would like to control" only.
