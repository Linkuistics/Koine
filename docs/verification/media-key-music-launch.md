# Media keys with no Now Playing app: VM check

This record answers one question for the design of pointer and media, which
Koine 0.6.0 ships with desktop release 1.0.2. Koine will post media keys as
Modaliser posts them. What does macOS do with such a key when no app holds Now
Playing? The answer decides a sentence of the `desktop:control` disclosure in
[the desktop contract](../specs/machine.md#capability-disclosures).

**macOS opens Music for play/pause.** In a clean VM with no player running,
play/pause made macOS open Music within one second, and Music took the front
from TextEdit. Next and previous did nothing. A volume key changed the output
volume.

## Procedure

```sh
task fixture:media-key-music-vm   # scripts/vm-check-media-key-music.sh
```

The task starts a clean TestAnyware macOS VM and installs no Koine. Koine does
not serve the media keys yet. So `Fixtures/MediaKeyProbe`, a signed test tool
that is never shipped, posts each key.

The probe uses Modaliser's mechanism. It
posts a system-defined event of subtype 8, down and then up, at the HID event
tap, with Modaliser's key numbers and `data1` layout. It prints whether it had
Accessibility consent and event posting access, because macOS can drop a post
without them. The TestAnyware agent starts the probe, and the probe had both.

The run posts each key once. The guest helper repeats a command that the agent
reports as timed out, so each post takes a guard directory, and a repeat posts
nothing. The run reads every fact from the system, not from the probe:

1. **Start state.** No Music, TV, Podcasts or QuickTime Player process runs. The
   guest has one output device, the Apple Virtual Sound Device.
2. **Control.** It posts volume down and reads the output volume with
   `osascript`. Then it posts volume up and reads the volume again. This proves
   that a posted key takes effect in the guest.
3. **Front app.** It opens a TextEdit document. `Fixtures/WindowIdentityProbe
   focused` must name TextEdit as the front app.
4. **Next and previous.** It posts next, waits 8 seconds, and checks that Music
   does not run and that TextEdit is still in front. Then it does the same for
   previous. After each key, it prints what `rcd` and `mediaremoted` logged.
5. **Play/pause.** It posts play/pause and checks once a second, for 10 seconds,
   whether Music runs. Three seconds later it reads the front app, captures the
   screen and prints the log of the two daemons.

## Run of 27 November 2026

The run used macOS 27.2.1 (26B131) in the guest, on the golden image
`testanyware-golden-macos-27`. Its transcript is
[media-key-music-20261127T135233.log](media-key-music-launch/media-key-music-20261127T135233.log).
The screen after play/pause is
[media-key-music-20261127T135233-play-pause.png](media-key-music-launch/media-key-music-20261127T135233-play-pause.png).

| Step | Observation |
| --- | --- |
| Control | Volume down took the output volume from 100 to 94. Volume up took it back to 100. |
| Front app | TextEdit. |
| Next, key 19 | `rcd` sent `NextTrack` through MediaRemote. `mediaremoted` found no Now Playing client, and the command had no option to open an app, so it dropped the command. Music did not open, and TextEdit stayed in front. |
| Previous, key 20 | `rcd` sent `PreviousTrack`, and `mediaremoted` dropped it in the same way. Music did not open, and TextEdit stayed in front. |
| Play/pause, key 16 | `rcd` sent `TogglePlayPause`. `mediaremoted` logged that its destination, `com.apple.Music`, was not available, and that the command asked to open the app. It queued the command and opened Music. Music ran within 1 second, and 3 seconds later it was the front app. The screen shows the "Welcome to Apple Music" window in front of TextEdit. |

An earlier exploration in another clean VM gave the same results by hand. Its
log showed that `mediaremoted` opened Music in the same way.

## What the run establishes

- With no Now Playing app, play/pause makes macOS open Music and bring it to
  the front. Music is the default destination of `mediaremoted`, and the
  command asks to open the app. So the disclosure states that play/pause can make
  macOS open Music and bring it to the front.
- With no Now Playing app, next and previous do nothing.
- `rcd` turns Modaliser's key 19 into `NextTrack` and key 20 into
  `PreviousTrack`. This supports Modaliser's choice of `NX_KEYTYPE_FAST` and
  `NX_KEYTYPE_REWIND` over `NX_KEYTYPE_NEXT` and `NX_KEYTYPE_PREVIOUS`.
- A probe that the TestAnyware agent starts has Accessibility consent and
  event posting access, so a key that it posts takes effect.

## What the run does not establish

- Whether a player honours next and previous. No player ran. The acceptance
  run of pointer and media plays a playlist in Music and settles that.
- Whether Music plays after it opens. The library of the guest is
  empty, and Music showed its first-run welcome window. With a library, the
  queued command can make Music play.
- Whether another macOS release behaves in the same way. The disclosure says
  "can", and a later release needs a new run of this task.
- How Koine itself behaves. The probe posts as Koine will post, but the probe
  is not Koine. The acceptance run of pointer and media checks Koine.
- Whether the keys reach the front app. MediaRemote and the log say where the
  commands went. The run reads no events in TextEdit.
