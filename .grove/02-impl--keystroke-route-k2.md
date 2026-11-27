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
