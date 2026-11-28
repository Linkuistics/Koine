# app-input-acceptance-k6

## Goal

Accept app input on the signed bundle with the N check, one happy-path VM run
and the scheduled check on Antony's Mac.

## Context

- The precedent is the acceptance of pointer and media:
  `docs/verification/desktop-pointer-media-compatibility.md`,
  `docs/verification/desktop-pointer-media-vm.md` and
  `task app:vm-verify-pointer-media`.
- `task compat:released-0.5.0` shows how the pairs build a released host from
  its tag.
- The root brief holds the agreed V cases and the host check under its test
  seams.

## Done when

- The compatibility pairs pass. The new host loads the signed input bundle,
  and the released 0.6.0 host refuses it before load.
- A new Taskfile task runs the V cases with independent witnesses, and one
  run passes.
- Antony approved the procedure and the chords of the host check, and he set
  its time. The check ran at that time, and it passed.
- A verification record holds the procedure, the evidence and what the runs
  do not claim.
- The trace rows link the evidence.

## Notes

- The host check sends one harmless chord each to Dia and Telegram. Propose a
  chord per app whose effect a witness can read, and a way to undo the effect.
- The host check leaves Antony's installed Koine, its grants and his apps as
  it found them. State how in the proposal.
- Until Antony sets the time, the leaf stays live. Ask him, and finish the
  turn while you wait.
- One V case sends a chord to Safari in the background. The probe sent a
  chord to Finder in the background only. If Safari ignores the chord, stop
  and ask Antony, because route A has no fallback.

## Decisions (running log)

**Two released hosts for the N check.** The released 0.6.0 headless host
builds its catalogue from the approval records beside its sealed root. So it
has no reserved-only input entry, and it would load a per-user input bundle as
an ordinary provider. The bundled case runs there with no input record, which
matches the catalogue of the 0.6.0 application. The per-user case runs in the
0.6.0 selection host, which the released tree's own scripts build and sign as
its "production" host. That host carries the sealed 0.6.0 catalogue verbatim.

**The compatibility run passed.** `task compat` ran 45 cases on 2026-11-28, in
debug, with no failed check, and no subject binary changed. The 0.6.0 headless
host refused input 1.0.0 as `unexpected-bundled-candidate`, and the 0.6.0
selection host refused it as `reserved-only`. The record is
`docs/verification/app-input-compatibility.md`.

**One operation for every row.** The example operations name fixed chords
only. The V run sends 24 rows, so `docs/design/input-operations.graphql` gains
`SendChord`, with the key and the modifiers as variables. The guest client
sends that text unchanged. `task design:app-input-check` still passes.

**The witnesses of the rows.** An exploration clone of the launcher image
settled one witness for each row before the run was written:

- Finder views and Go destinations: AppleScript to Finder, which reads the
  current view and the name of the front window. Gallery reads as `flow view`.
- New Window: the count of Finder windows. Get Info and Connect to Server: the
  window titles that the window witness lists.
- New Folder: the files of the scratch folder. Toggle Hidden and Go to Folder:
  OCR of the hidden file's name and of the panel's placeholder.
- Safari: AppleScript for the tabs, and the TestAnyware agent's accessibility
  snapshot for the find banner and the focus of the address field. The find
  row goes before the address row, because a click on the page does not take
  the focus from the address field.
- Zed, Zotero and Obsidian: the probe's witnesses.

The AppleScript witnesses run in the agent's process, so macOS asks once
whether the agent may control Finder and Safari. The run answers as a user
would. Koine is not involved.

**The host check, as proposed to Antony (awaiting his approval and time).**
`task app:host-check-app-input -- <phase>` runs `scripts/host-check-app-input.sh`,
one phase per call. Each phase refuses unless `KOINE_HOST_CHECK=approved`.

- **Subject.** The signed 0.7.0 candidate from `.build/app/Koine.app`, never
  installed into `/Applications`. It has the identifier and Team ID of the
  installed Koine, so the Accessibility consent of the installed Koine covers
  it. Nothing asks for a permission.
- **Chords.** Dia gets New Tab, Command-T, from Antony's Dia screen. Telegram
  gets Search in Chat, Command-F, from his Telegram screen. Each app comes to
  the front first, as each app did in the VM. Neither chord types text or
  sends a message.
- **Witness.** Antony reads each effect on his screen. This session's process
  holds no Accessibility and no screen capture access, so no tool here can
  read Dia or Telegram without a new permission. Koine's receipt says only
  that Koine sent the chord.
- **Undo.** Antony closes the new Dia tab with Command-W, and he presses
  Escape in Telegram. A chord from Koine does not undo, because Command-W
  closes his own tab if the new tab did not open.
- **As found.** Koine keeps no keychain item. Its data directory holds
  `grants.sqlite`, the lock, the endpoint and provider staging. The check
  copies that directory after Antony quits his Koine. Afterwards it restores
  the copy exactly, and a manifest of SHA-256 digests proves the result. So
  the temporary grant goes. The check unregisters the candidate from Launch
  Services, and it opens his Koine again if his Koine was running before. It
  brings his front app back to the front.

**The first VM run stopped at the witness setup.** In
`app-input-20261128T163932.log`, every disclosure step passed. Then the run
found no Automation prompt for Finder. AppleScript answers the name of an
application itself, so `get name` sends no Apple event, and macOS asks
nothing.

In the kept VM, `get count of Finder windows` raised the prompt after
a few seconds. In the same VM, Koine captured Finder and sent Command-2, and
Finder changed from icon view to list view. The run now asks for the count of
windows. The second run is a fresh clone.

**The second VM run stopped at the same step, for another reason.** In
`app-input-20261128T164806.log`, the prompt for Finder was on the screen, but
OCR found no "Allow". With the prompt on screen, Vision read three garbled
words from the whole screen, on the host as well as through TestAnyware. The
same Vision read every capture without the prompt in full. The agent lists the
prompt as a window of UserNotificationCenter titled "alert", and its snapshot
gives the Allow button. So the run now waits for that button, clicks it, and
takes the app's own answer as the proof of consent.

**The headless conformance and selection runs passed.** Two earlier leaves
left these runs to this leaf. `task conformance:headless` passed both headless
profiles. `task selection:decisions` ran 134 host runs, `selection:failures`
119 and `selection:updates` 153, each with no failure. The pending rows that
need a second Developer ID team stay pending, as before. `task conformance:vm`
holds the signed application to the input profile, and it runs after the
accepted V run.

**The third VM run sent every chord, and three witnesses misread.** In
`app-input-20261128T170102.log`, 21 rows passed, and so did the background
case, the Control-2 case and both Space switch cases. Three OCR witnesses read
"0 to 0": Toggle Hidden, Go to Folder and Zed's palette. The Zed capture shows
the palette open. Host Vision read that whole capture as if it were upside
down, but it read the same capture in full without the left 320 pixels. Those
pixels hold Koine's Settings window, with its dense small text.

In the kept VM, with that window closed, OCR read the screen. The run's own
Toggle Hidden chord showed the hidden files, and a second chord hid them. Go to
Folder opened its panel. Finder filled the panel with the last path of the
consent step, so the placeholder was absent. Then the run did not quit Koine, because Command-Q did
not reach Koine's window behind the test apps.

So the run now closes the Settings window before the rows, and it reads the Go
to Folder panel as the sheet `GoToWindow` in the snapshot. It closes the test
apps before the restart. Each dialog check first requires OCR to find "Help"
in the menu bar. Host OCR of the third run's Zed capture finds no "Help", so
this control fails on a misread screen.

**The fourth VM run is accepted.** `app-input-20261128T175602.log` passed every
step on the bundle with CDHash `3f720b4d332631adfbdd5f0f27f6ecacff09dd16`. All
24 rows passed, and each app acted on each chord. Safari opened a tab in the
background while TextEdit kept its text and stayed in front. Control-2 left
Desktop 1 current, and the Space switch reached Desktop 2, returned, and
refused with the shortcut off. No dialog appeared, and the restart kept the
grants.

The subjects had the same digests before and after. The record is
`docs/verification/app-input-vm.md`, and the trace rows link it and the
compatibility record. Dia and Telegram stay pending until the host check.

**The VM conformance check found a control with nothing to move.** The first
`task conformance:vm` read the signed application's candidates as the 0.7.0
profile pins them. Then the control "the workspace launch field moved before
desktop's" changed nothing in the 0.7.0 design. That control expects desktop's
last mutation field directly before workspace's launch field, and input's
fields now sit between them. The control now lets input's fields stay between,
and it swaps the same two fields as before in every older profile.

The profile includes input, but `scripts/conformance-lib.sh` held no input
coordinate on its own. So it gains five controls under the input profile: the
three roots, one keystroke outcome and one Space switch outcome. A local
stand-in showed that every control changes its design text, under the 0.7.0
and 0.6.0 profiles.

**The VM conformance check passed.** One more control was stale: "a required
provider that is not served" added an input row, which 0.7.0 serves. It now
adds `menus`, which every host keeps reserved-only. Then `task conformance:vm`
passed in `conformance-20261128T190548.log`. The signed application served the
0.7.0 design exactly, its three candidates matched the pin, and every control,
the five input controls among them, turned red. `task conformance:headless`
passed again with the changed library.

**Antony approved the host check and set its time.** Asked to approve the
procedure and the two chords, and to set a time, with the recommendation to
approve them as written, Antony answered: "now". So the check runs at once,
with New Tab to Dia and Search in Chat to Telegram.

**Dia acted on the chord.** At 19:11:21 the candidate captured Dia, pid 14271,
and reported `SENT` for Command-T. Dia stayed the front app. Antony's
observation: "yes, it brought up a new tab".

**Telegram acted on the chord.** At 19:12:01 the candidate captured Telegram,
pid 94193, and reported `SENT` for Command-F. Telegram stayed the front app.
Antony's observation: "yes, it opened the search. I closed the search and the
new dia tab".

**The restore needed a second step.** At 19:13:09 the restore phase put the
data directory back, and its manifest matched the record. Then `rm -rf` of the
copy failed, because Koine makes its provider staging read-only, and the
script stopped before Launch Services. The failed `rm -rf` had already deleted
`grants.sqlite` from the copy, so a rerun of the phase refused.

The data directory was already exact. So the rest ran by hand at 19:13:40.
The manifest again matched, and `chmod -R u+w` and `rm -rf` deleted the copy.
The candidate left Launch Services, and `/Applications/Koine.app` was
registered again. The installed Koine was not running before the check, and it
stays closed. The script now makes the copy writable before `rm -rf`.

**The host check passed, and no review leaf follows.** The record is
`docs/verification/app-input-host.md`, and the Dia and Telegram trace rows
link it. This leaf is acceptance evidence, and its records state what the runs
do not claim. The adversarial read of the design is `app-input-k8`. So this
leaf cuts no `review-impl` step.
