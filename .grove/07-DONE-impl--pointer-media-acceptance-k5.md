# pointer-media-acceptance-k5

## Goal

Accept pointer and media on the signed bundle with the N check and one
happy-path VM run.

## Context

- The precedent is the acceptance of window layout:
  `docs/verification/desktop-window-layout-compatibility.md`,
  `docs/verification/desktop-window-layout-vm.md` and
  `task app:vm-verify-window-layout`.
- The root brief holds the agreed V cases under its test seams.

## Done when

- The compatibility pairs pass. The new host loads the signed bundle. The
  released 0.5.0 host refuses desktop 1.0.2 before load, because it lacks
  `desktop-disclosures-v2`, and its bundled desktop 1.0.1 stays selected.
- A new Taskfile task runs the V cases with an independent witness, and one
  run passes.
- The run settles which codes for next and previous a player honours. If
  Modaliser's codes fail, this leaf changes them, and the passing run uses the
  settled codes.
- A verification record holds the procedure, the evidence and what the run
  does not claim.
- The trace rows link the evidence.

## Notes

- The tracks are silent, because the sound of the guest reaches the speakers
  of the host.
- If the VM cannot keep a player playing, or no witness can see a hidden
  pointer appear again, follow the notes of the root brief.
- Start Music with its playlist before any key is posted. With no Now Playing
  app, play/pause makes macOS open Music and bring it to the front, in front of
  TextEdit (`docs/verification/media-key-music-launch.md`).
- In a fresh guest, Music opens with its "Welcome to Apple Music" window, and
  macOS asks about its notifications. The run deals with both before the media
  cases.
- A witness that asks Music for its state through Apple events needs Automation
  consent, and macOS shows a dialog for it. The library helper
  `grant_system_events_automation` is the precedent.
- The player decides whether previous goes to the previous track or to the
  start of the current one.
- The nudge and the keys post only when `CGPreflightPostEventAccess` is true
  as well as `AXIsProcessTrusted`. So a passing run establishes that the signed
  Koine has posting access under the consent that `grant_accessibility` gives.
  The Music probe does not establish it.
- If the nudge or a key reports `os-permission` while Koine's Accessibility
  switch is on, stop and ask the human. Posting would then need a new consent
  posture (root brief).

## Decisions (running log)

**The compatibility pairs.** The pin `scripts/released-0.5.0.json` names tag
`v0.5.0`, and `task compat:released-0.5.0` builds that revision as
`compat:released-0.4.1` does. The verifier adds two cases with the released
0.5.0 host: this tree's desktop 1.0.2 bundled, and the per-user variant over
the bundled desktop 1.0.1. Each refusal must name `desktop-disclosures-v2` and
not v1. The schema probe of every refusal is now `desktopPointer`, because the
kept desktop 1.0.1 of 0.5.0 serves `desktopWindows`. The new-host case serves
`desktopPointer`, so it is the control of that probe.

**The compatibility run passed.** `task compat` ran 42 cases on 2026-11-27,
in debug, with no failed check, and no subject binary changed. The two 0.5.0
refusals named `desktop-disclosures-v2` alone. In the per-user case, desktop
1.0.1 stayed selected and still answered a read.

**The trace table stays pending.** The rows "Media", "Pointer" and "Grant
disclosure" are in the `pending` region of `docs/specs/workflow-providers.md`.
The three rows have no hard finding of the checker. The other rows of the
table have 59, mostly semicolons.

A marker line inside a Markdown table ends
the table, so a conversion region cannot hold three rows alone. So this leaf
edits the three rows in place and keeps them clean, as `pointer-k3` and
`media-keys-k4` did. It does not convert the rest of the table.

**No witness sees a hidden pointer appear again.** The first VM run
(`pointer-media-20261127T151731.log`) passed the position read and the nudge.
The witness saw the two mouse-moved events, one point right and back, and the
pointer at its start with no button held. `CGCursorIsVisible` read true before
the run typed into TextEdit and false after it. After the nudge it still read
false.

In the kept VM, a real VNC move of one point and of several hundred
points also left it false. So that call falls when TextEdit hides the pointer,
and nothing makes it true again. It cannot tell a reveal from no reveal. A
screen capture of the guest shows no pointer at all, because the framebuffer
does not draw it. The root brief sends this harness limit to Antony.

**Previous restarts the track first.** In the same run, key 20 on track 2 at
second 12 made Music restart track 2. Next, key 19, went to track 2. The check
of a restart was too tight, because the witness window and the reads take
about 6 seconds. The run now counts a restart when the position falls below
its value before the key. It then sets the position to 0 and posts previous
in the same guest command, so that Music goes to the previous track.

**The second run passed, and the codes stand.** In
`pointer-media-20261127T152308.log`, `rcd` sent `NextTrack` for key 19 and
`PreviousTrack` for key 20. Music went to the next track, restarted the
current track at second 13, and went to the previous track near the start of
a track. So Modaliser's codes stay.

Music's own sheet "Hear About New Music
First" stayed open behind TextEdit during that run. Music played through it,
but the leaf asks the run to answer it first. So the run now chooses "Not Now"
right after the welcome window and checks that the sheet is gone. The third
run is the accepted run.

**The third run is accepted.** `pointer-media-20261127T152848.log` passed
every step on the bundle with CDHash `f6d7af6583805298c359d6b0bfe159bad3c371a8`.
The subjects and the bundle had the same digests before and after. The run
answered Music's sheet with "Not Now", and no permission dialog appeared before or
after the keys.

The records are `docs/verification/desktop-pointer-media-vm.md`
and `docs/verification/desktop-pointer-media-compatibility.md`. The contract
now states the settled codes and the posting posture. The trace rows link both
records.

**Open: the hidden pointer.** Per the root brief, the limit goes to Antony.
The recommendation is to release with the limit stated in the VM record and
file an issue for a witness of the reveal.

**Antony's decision on the hidden pointer.** Asked how the release treats the
limit, Antony chose: "Release, file an issue (Recommended)". So 0.6.0 releases
with the limit stated under "What this does not claim" in the VM record, and an
issue asks for a witness of the reveal. The release leaf files it, because each
issue is a public step that Antony approves there. Its notes now list the cases
that this acceptance defers.

**No review leaf.** The run is acceptance evidence, and the records state what
it does not claim. The adversarial read of the design is `pointer-media-k7`.
So this leaf cuts no `review-impl` step.
