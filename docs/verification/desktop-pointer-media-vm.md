# Pointer and media: VM verification

This record is the V seam of pointer and media, which Koine 0.6.0 ships with
desktop release 1.0.2. One run of one task checks the happy path on the signed
`Koine.app` in a clean TestAnyware macOS VM. A real player, Music, plays local
tracks, and a real TextEdit document stays in front. The contract is "Pointer
and media" in [the desktop contract](../specs/machine.md).

**The tracks are silent.** Tart sends the sound of a guest to the speakers of
the host. So the run makes three silent tracks of five minutes each on the
host, and only the guest plays them. Five minutes is long enough that no track
ends by itself during a case.

## Procedure

```sh
task app                            # build and sign .build/app/Koine.app
task app:vm-verify-pointer-media    # scripts/vm-verify-pointer-media.sh
```

The run creates two grants in the Settings window. The reading grant holds
`koine:manage` and `desktop:read`. The controlling grant holds `desktop:control`
alone. The guest client `scripts/vm-verify-pointer-media-client.py` sends each
operation with the text of
[the example operations](../design/desktop-pointer-media-operations.graphql),
unchanged.

**Koine never witnesses its own answers.** Two independent witnesses read the
system after each action:

- `Fixtures/WindowIdentityProbe` is test material that is signed and never
  shipped. `pointer` reads the position of the pointer and the buttons that
  are held. `focused` reads the front app. `events <seconds>` listens at the
  session event tap and changes nothing. It records every mouse-moved, key and
  system-defined event that passes, with the location of a move, and the
  subtype and `data1` of a media key.
- `scripts/vm-verify-pointer-media-music.applescript` asks Music for its player
  state, its track and its position through Apple events. It reads the output
  volume and the mute through Standard Additions, which ask no app.

The witness of Music needs Automation consent, so macOS asks once whether
`testanyware-agent` may control Music. The run clicks "Allow", as a user does.
That consent belongs to the agent that runs the witness, not to Koine.

Each nudge and each key runs inside a window of five seconds of the event
witness. The guest helper repeats a command that the agent reports as timed
out. A second key would change the state under test, so each post takes a guard
directory, and a repeat posts nothing.

| Step | Action | Expected result |
|---|---|---|
| Disclosures, new grant | Read the served disclosures. Read the create-grant view. | The view presents the served text for `desktop:read` and `desktop:control`. The texts state the pointer position, the nudge and the keys that reach the Now Playing app. They also state the change of volume and mute, and that play/pause can open Music. |
| Disclosures, request | A client enrols for `desktop:read` and `desktop:control`. | The request view presents both served texts. The approved grant holds both capabilities. |
| Disclosures, grant list | Read the rows of the three grants. | Each row presents the served text of each desktop capability that it holds. |
| Consent | Give Accessibility consent in System Settings. | Koine is in the Accessibility list. |
| Pointer position | Move the pointer to two places. Read the position each time. | Koine's position is within one point of the witness's position. |
| Nudge | Type into a TextEdit document, so that TextEdit hides the pointer. Nudge the pointer. | The receipt is `NUDGED`. The witness sees exactly two mouse-moved events: one point to the right of the start, and then at the start. The pointer is back at the start with no button held. No key event passes. |
| Music | Open Music. Choose "Start Listening" in its welcome window and "Not Now" in its sheet about notifications. Allow the witness. Play the playlist of three tracks. Open TextEdit in front. | Music plays the first track in the background, and TextEdit is the front app. No permission dialog is on screen. |
| Play/pause | Post `PLAY_PAUSE` twice. | Music pauses, and then it plays again. |
| Next | Post `NEXT`. | Music plays the second track. |
| Previous | Post `PREVIOUS` after 5 seconds of a track. If Music restarts the track, set the position to 0 and post `PREVIOUS` again in the same guest command. | Music restarts the current track or plays the previous one. At the end, it plays the first track. |
| Volume and mute | Set the output volume to 50, unmuted. Post `VOLUME_UP`, `VOLUME_DOWN`, `MUTE` and `MUTE`. | The volume rises, then returns to 50. The output is muted, then unmuted. |
| Each key | Read the event witness and the front app. | The receipt names the key. The witness sees exactly one system-defined event of subtype 8 down and one up, with the key number of the contract. No key event passes. TextEdit stays in front. |
| No dialog | Read the screen after the keys. | No permission dialog is on screen. |
| Restart | Quit Koine and open it again. | The grants are unchanged, and each row still presents its served disclosures. |

The window layout precedent stands in for an upgrade: a restart rebuilds the
grant list from the stored grants, and presenting a grant changes none.

## Evidence

The accepted run took place on 2026-11-27 in a clone of macOS 27.2.1 (26B131),
arm64, at 1920 by 1080 points on one display. The bundle carried the signature
of `Developer ID Application: Antony Blakey (TA43A4RUP3)`, with CDHash
`f6d7af6583805298c359d6b0bfe159bad3c371a8`. Its desktop provider is release
1.0.2.

The script, the client, the Music witness, the probe source and the
operations file had the same SHA-256 before and after the run. The bundle had
the same CDHash after the run. Every step passed. The transcript is
[pointer-media-20261127T152848.log](desktop-pointer-media/pointer-media-20261127T152848.log).

| Step | Observed |
|---|---|
| Disclosures | The create-grant view, the request view and the rows of the three grants presented the served texts of `desktop:read` and `desktop:control`, word for word. |
| Pointer position | At x 699.988, y 419.996 and at x 1309.977, y 776.988, Koine and the witness read the same values. |
| Nudge | The receipt was `NUDGED`. The witness saw a move to x 1310.977, y 776.988 and a move back to x 1309.977, y 776.988, and no other event. The pointer was back at its start with no button held. |
| Music | Music played "Koine Silence 1" in the background, and TextEdit was the front app. No permission dialog was on screen. |
| Play/pause | Music paused at second 10 and played again. The witness saw `data1` 1051136 and 1051392, which are key 16 down and up. |
| Next | Music played "Koine Silence 2". `rcd` sent `NextTrack`. The witness saw key 19 down and up. |
| Previous | At second 13 of "Koine Silence 2", the first `PREVIOUS` restarted the track. The second, at second 0, made Music play "Koine Silence 1". `rcd` sent `PreviousTrack`. The witness saw key 20 down and up each time. |
| Volume and mute | The volume went from 50 to 56 and back to 50. The output was muted and then unmuted. The witness saw keys 0, 1, 7 and 7, each down and up. |
| Each key | Each receipt named its key. No key event passed during any key, and TextEdit stayed in front after each key. |
| No dialog | No dialog text was on screen after the keys. |
| Restart | The grants were the same before and after, and every row presented its served disclosures again. |

[media-keys.png](desktop-pointer-media/pointer-media-20261127T152848-media-keys.png)
records the screen after the keys. TextEdit's document is in front with its
text unchanged, and Music plays "Koine Silence 1" behind it.
[music-notifications-sheet.png](desktop-pointer-media/pointer-media-20261127T152848-music-notifications-sheet.png)
records the sheet "Hear About New Music First", which Music presents after its
welcome window.

### The codes for next and previous

Modaliser posts key 19, `NX_KEYTYPE_FAST`, for next and key 20,
`NX_KEYTYPE_REWIND`, for previous. Nobody had checked these numbers against a
player. In this run, `rcd` turned them into `NextTrack` and `PreviousTrack`, and
Music honoured both. So Koine keeps Modaliser's numbers, and the contract states
the result.

### The posting access of the signed Koine

The nudge and the keys post only when `AXIsProcessTrusted` and
`CGPreflightPostEventAccess` are both true. The nudge reported `NUDGED`, and
each key returned its receipt. So the signed Koine had posting access under the
consent that `grant_accessibility` gives in System Settings. No new permission
dialog appeared.

### Earlier runs

Two earlier runs used the same bundle. The first stopped at a check that was
too strict. The second passed with a check that was too weak. The repository
keeps both transcripts.

- [pointer-media-20261127T151731.log](desktop-pointer-media/pointer-media-20261127T151731.log)
  stopped at previous. Key 20 at second 12 restarted the track, and the
  witness read second 6 afterwards. The check took a restart to mean a position
  below 3 seconds, but the press and the reads take about 6 seconds. The check
  now compares the position with its value before the key.
- [pointer-media-20261127T152308.log](desktop-pointer-media/pointer-media-20261127T152308.log)
  passed every step. Its search for a notification prompt looked for the word
  "Notifications" and found nothing. Music's sheet stayed open behind TextEdit,
  and Music played through it. The run now chooses "Not Now" in that sheet and
  checks that the sheet is gone.

## What this does not claim

- **That a hidden pointer becomes visible again.** No witness in the VM can see
  it. `CGCursorIsVisible`, which the SDK marks as no longer supported, read true
  before the run typed into TextEdit and false after. It read false after the
  nudge too. In a kept VM, real moves of one point and of several hundred
  points through VNC also left it false. So the call cannot tell a reveal from
  no reveal. A screen capture of the guest holds no pointer, because the
  framebuffer does not draw it. The run proves the two mouse-moved events and
  the pointer at its start, which is the mechanism of Modaliser.
- **The refusal while a pointer button is held.** The L tests cover it. The run
  holds no button.
- **Another player.** The run uses Music alone. Another player decides for
  itself what previous does and whether it honours keys 19 and 20.
- **A second display.** The VM has one display. Issue #23 holds the checks on a
  second display.
- **An upgrade from an installed 0.5.0.** A restart stands in for it, as in the
  window layout precedent.
- **A Mac whose policy denies event posting.** The run has posting access. A
  managed Mac can allow Accessibility and deny `PostEvent`, and then Koine
  reports `os-permission`. The run does not check that case.
- **The notarised bundle.** The release leaf repeats the run on the notarised
  bundle.
