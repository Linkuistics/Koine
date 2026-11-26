# display-focus-k5

## Goal

Serve display focus as the design of `window-layout-k2` defines it.

## Context

- The contract is "Display focus" in `docs/specs/machine.md`, under "Window
  layout".
- Modaliser's `focusDisplay`, in `WindowManipulator.swift`, raises the front
  window on a display, activates its application and moves the pointer. On a
  display with no window, it also clicks. Koine never clicks.

## Done when

- On a display with a window, display focus raises the front window there,
  chosen by the order from `window-stacking-k4`. It activates that window's
  application and moves the pointer to the display's centre.
- On a display with no window, it moves the pointer to the centre and
  reports that no window took focus.
- When Koine cannot establish the front window on the display, it raises
  nothing, moves the pointer and reports `FRONT_WINDOW_UNKNOWN`.
- While a pointer button is held at the start, it does nothing and reports
  `POINTER_BUTTON_HELD`.
- Immediately before the pointer move, it checks the buttons again. When a
  button is held then, it leaves the pointer where it is. The receipt field
  `pointerMoved` says whether the pointer moved (`window-layout-k9`).
- It never clicks, under any grant.
- L and G tests cover both cases, both button checks and the authority.
- Display focus moves from the design into the served SDL and both composed
  files, word for word. Its coordinates leave
  `desktopCoordinatesNotYetImplemented`, and `scripts/conformance-lib.sh`
  gains a control for its root (`window-geometry-k3`).

## Notes

- The click for clients that also hold input control is an issue for the
  app input item. The release leaf files it.
- Modaliser posts a mouse-moved event after it warps the pointer. If macOS
  asks for a consent other than Accessibility for that event, stop and ask the
  human (root brief, Notes).

## Decisions (running log)

**The reference resolves before the first button check.** The contract lists
the button check as the first act, but it did not place the reference. A
reference that names no active display raises `unavailable`, and the provider
reads nothing else, not even the buttons. Resolution reads no window state and
has no effect, so it comes before the acts. The provider keeps the display frame
from that read, and the pointer moves to its centre. The contract now states
this order.

**A failed window list read ends display focus.** The contract named two
`FRONT_WINDOW_UNKNOWN` cases and did not say what a failed read does. Display
focus now reports the error of `desktopWindows`, and it raises nothing and moves
nothing. That error is `os-permission` without consent, and `failed` when an
application does not answer. `FRONT_WINDOW_UNKNOWN` would move the pointer after
a read that established nothing. The contract now states the rule.

**Focus goes through the reference of the front row.** Display focus calls the
same focus path as `desktopFocusWindow`, with the reference of the row that it
chose. So it resolves that row's held element again, checks its identity, acts
and waits up to 3 seconds. A consent failure of that step stays `os-permission`.
Every other failure becomes `failed`, because the client passed a display
reference. An `unavailable` for a window that closed would read as a stale
display.

<!-- tc: depart spelling because the paragraph quotes Apple's documentation word for word -->
**The button check reads `NSEvent.pressedMouseButtons`.** One read covers every
button. Apple documents it as "the state of devices combined with synthesized
events at the moment". The pointer move is Modaliser's `warpMouse`:
`CGWarpMouseCursorPosition`, and then one mouse-moved event posted at the HID
tap. The code cites both Apple pages. A warp error, or no mouse-moved event,
gives `failed`.

**No adversarial review before acceptance.** Display focus follows the contract
that `window-layout-k8` and `window-layout-k9` reviewed. Its L tests went red
under seven mutations of the rules. The VM acceptance in
`window-layout-acceptance-k6` raises the front window and moves the pointer
under an independent witness. A change is a later provider release, so the
decision is not hard to reverse.

**Verification.** The L suite passed 60 tests. Seven mutations each turned it
red. They removed each button check, the unknown visibility rule and the unknown
frame rule. They also reversed the order, ignored a focus failure and moved the
edge of a display.

The G and conformance suites passed 25 tests. Four G mutations each turned a test red: the authority,
an inactive display, the consent error and the served description. The
authority mutation crashed the test process, which also counts as red.

The full
`task test` run held the earlier suites. Two failures are not from this leaf.
The first is the macOS 27 wording failure that `window-stacking-k4` records. The
second is `anEarlierCoreDeadlineAnswersTheWholeRequestAndNoLaterRevealBegins`.
Its grant setup hit the short core deadline of the test during the parallel
run, and it passed five times out of five alone.

`task design:window-layout-check` passed with 5 roots.
`task conformance:headless` passed, and its two new display focus controls went
red. The test process had no Accessibility consent, so no G test moved the
pointer of the host. A mutation proved that the consent test ran its body. The
VM run holds the live path.
