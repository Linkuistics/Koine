# space-switching-k5

## Goal

Serve Space switching in the input provider, with its checks, and with L and
G tests.

## Context

- The design leaf `app-input-k3` fixes the operation, its refusals and its
  descriptions. The section "Space switching" of `docs/specs/app-input.md`
  states the checks and their order.
- Antony chose the private SkyLight call `SLSCopyManagedDisplaySpaces` for
  the count, and a count across all displays. The `KeystrokeProbe` fixture
  calls it with `dlopen` and `dlsym`. The private window lookup in
  `Providers/DesktopProvider/Sources/WindowServer.swift` explains why Koine
  avoids a strong link.
- The verification record of `keystroke-route-k2` says how Koine reads the
  shortcut settings and counts Spaces. It also says what a fall-through does.
- `input-keystrokes-k4` serves the bundle that this leaf extends.

## Done when

- Under input control and desktop control, Space switching posts Control and
  a digit from 1 to 9 at the HID event tap.
- Before it posts, it reads the shortcut settings and the count of Spaces, and
  it changes neither. It refuses when the shortcut is disabled or remapped, or
  when the Space does not exist.
- It refuses while Koine is in front.
- Koine counts the Spaces of type 0 on every display, in the order of the
  SkyLight reply. When a SkyLight symbol is missing, or the reply has another
  form, the switch reports `failed` and posts nothing. The chords still load
  and work.
- L tests cover the checks from plain shortcut settings and plain lists of
  Spaces with their types, for one display and for two.
- The shortcut mask must equal 262144, which is Control and no other bit, as
  `app-input-k9` decided. An L test gives `SHORTCUT_REMAPPED` for a mask with
  the Fn bit.
- G tests cover the authority. Input control alone cannot switch a Space, and
  desktop control alone cannot switch one either. No G test switches a Space.
- `swift test` passes, and the documents that the design leaf named describe
  the served state.

## Notes

- Space switching never uses `CGEventPostToPid`, because macOS must catch its
  chord at the session level.
