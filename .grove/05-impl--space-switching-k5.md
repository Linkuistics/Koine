# space-switching-k5

## Goal

Serve Space switching in the input provider, with its checks, and with L and
G tests.

## Context

- The design leaf `app-input-k3` fixes the operation, its refusals and its
  descriptions.
- The verification record of `keystroke-route-k2` says how Koine reads the
  shortcut settings and counts Spaces. It also says what a fall-through does.
- `input-keystrokes-k4` serves the bundle that this leaf extends.

## Done when

- Under input control and desktop control, Space switching posts Control and
  a digit from 1 to 9 at the HID event tap.
- Before it posts, it reads the shortcut settings and the count of Spaces, and
  it changes neither. It refuses when the shortcut is disabled or remapped, or
  when the Space does not exist.
- It refuses while Koine or a recognised consent or security dialog is in
  front.
- L tests cover the checks from plain shortcut settings and a Space count.
- G tests cover the authority. Input control alone cannot switch a Space, and
  desktop control alone cannot switch one either. No G test switches a Space.
- `swift test` passes, and the documents that the design leaf named describe
  the served state.

## Notes

- Space switching never uses `CGEventPostToPid`, because macOS must catch its
  chord at the session level.
