# keystroke-route-k2

## Goal

Prove route A in a TestAnyware VM before any design or implementation. Route
A sends a chord into the target's own event stream with `CGEventPostToPid`.
Also settle how Koine reads the shortcut settings and counts Spaces.

## Context

- The running log of `plan-k1` records route A and the reasons for it. The
  macOS SDK header `CGEvent.h` documents `CGEventPostToPid`.
- The precedent for a signed probe is the Music check of the pointer and media
  grove. It is `Fixtures/MediaKeyProbe`, `scripts/vm-check-media-key-music.sh`,
  `task fixture:media-key-music-vm` and
  `docs/verification/media-key-music-launch.md`.
- Modaliser's `KeystrokeEmitter.swift` holds the key table and the chord
  order. The probe builds each chord the same way, and only the post differs.
- `scripts/launcher-apps.json` records how the VM tooling installs Zed, Zotero
  and Obsidian from their casks. Obsidian stops at its vault chooser until it
  has a vault.
- The "Switch to Desktop N" shortcuts of Mission Control catch Control and a
  digit. Their settings are in the preferences domain
  `com.apple.symbolichotkeys`. No public interface counts Spaces.
- The section "The posting access of the signed Koine" of
  `docs/verification/desktop-pointer-media-vm.md` shows the consent checks
  before a post at the HID event tap.

## Done when

- A small signed instrument sends one chord with `CGEventPostToPid` to a named
  process. A new Taskfile task runs it in a clean VM, and never on the host.
- A verification record holds the procedure, the evidence and what the probe
  does not claim.
- Safari, Finder, Zed, Zotero and Obsidian each act on one chord from Antony's
  configuration while the app is in front. An independent witness sees each
  effect.
- A Control-2 sent with `CGEventPostToPid` switches no Space. The same chord
  at the HID event tap switches to Space 2, so the shortcut and the Space are
  live.
- A keyboard tap at the session level does not see a chord sent with
  `CGEventPostToPid`. The same tap sees the chord at the HID event tap.
- The record states whether `CGEventPostToPid` needs the posting access check,
  as the post at the HID event tap needs it.
- The record states how Koine reads the shortcut for Control and each digit,
  and how it counts Spaces. For each source, it states whether the call is
  public.
- The record states what reaches the front app when the shortcut is disabled,
  and when the Space does not exist.

## Notes

- If an app does not act on a chord in its own event stream, stop and ask
  Antony. Do not post app chords at the HID event tap instead.
- If only a private call counts Spaces, record the evidence. The design leaf
  asks Antony before it adopts that call.
- Choose chords whose effect a witness can read through Accessibility, such as
  a new window or a focused field.
- The VM needs two Spaces and an enabled shortcut for Desktop 2. Record how
  the run creates them.
- If the VM cannot switch Spaces at all, record a harness limit and ask
  Antony.

## Decisions (running log)

**Image and witnesses.** The run uses a clone of the prepared launcher image,
because that image already holds Zed, Zotero and Obsidian past their first
runs. The image runs macOS 27.0.1, and the record states that version.

**App witnesses.** Each app has its own witness. Accessibility reads the
windows of Finder and the tabs of Safari. Zed exposes only its menu bar to Accessibility, so OCR reads its command
palette. Zotero 10 opens Advanced Search as a pane in its main window, so OCR
reads that pane too. Obsidian gets a seeded vault, and a new file in the vault
is the witness of its new note.

**Instruments.** `Fixtures/KeystrokeProbe` sends each chord, and
`Fixtures/KeyWitness` records each key that reaches the front app with its
sender. The tap check reuses `WindowIdentityProbe events`, which the pointer
and media grove proved at the session tap. To post without consent, the probe
also ships as two app bundles that `open` starts as their own responsible
processes. Their identifiers differ, so the route A post and the HID control
each meet macOS alone.

**Space setup.** The run adds the second Space with the add button of
Mission Control, as a user does, and checks the count afterwards. It writes
the "Switch to Desktop N" entries with `defaults` as typed property-list values,
and it applies them with `activateSettings -u`. A Control-2 at the HID event
tap then proves that the shortcut and the Space are live.

**Exploration findings that the run asserts.** In the exploration clone,
all five apps acted on their route A chord while in front. A Control-2 by
route A switched no Space, and a session tap missed the route A chord. An
absent Desktop 2 entry acted as a disabled one. A post without access
delivered nothing by either route and raised the "would like to control this
Mac" dialog. The scripted run separates the two routes for that dialog.

**Tap step after two failed runs.** The first scripted run stopped at the tap
check, but the tap recorded key 38. The check used `jq`'s `index` with an
array argument, which looks for consecutive elements and not for one pair.

The second run used a corrected check, and its tap recorded no events. Its
log did not show whether the tap ran while the probe posted. So the step
now waits until the tap process runs before it posts, and the tap listens for
25 seconds. The log prints when the tap began beside the time of each post.

**Dialog detector after the third run.** The third run passed every check,
but it reported no dialog after the HID post without access. Its own screen
capture shows the dialog for "KeystrokeProbeControl". With that longer name,
"this Mac" wraps to the next line, and OCR missed the whole phrase. The
detector now looks for "would like to control", as the desktop library does.
A fourth run produces the recorded evidence with the committed script.

**Record.** `docs/verification/keystroke-route-vm.md` holds the procedure,
the evidence and the limits. It recommends nothing that is Antony's decision.
The design leaf asks him before it adopts the private SkyLight count.

**Comments after the fourth run.** After the fourth run, only comments changed
in the script and the fixtures, to meet the writing rules. The jj snapshot
from 02:51 matches the digests that the fourth run read. A diff of that
snapshot with the committed files shows no change outside comment lines.
