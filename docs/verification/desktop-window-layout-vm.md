# Window layout: VM verification

This record is the V seam of window layout, the first cut that Koine 0.5.0
ships with desktop release 1.0.1. One run of one task checks the happy path on
the signed `Koine.app` in a clean TestAnyware macOS VM. The run uses real
TextEdit and Finder windows, with no application mocks. The contract is
"Window layout" in [the desktop contract](../specs/machine.md).

**The VM has one display.** TestAnyware 3.0.0 starts a macOS VM with one
display. So this run cannot check a move to another display, the repeated
resize across displays, or display focus on a display with no window. Those
cases wait for a two-display check.

## Procedure

```sh
task app                          # build and sign .build/app/Koine.app
task app:vm-verify-window-layout  # scripts/vm-verify-window-layout.sh
```

The run creates two grants in the Settings window. The reading grant holds
`koine:manage` and `desktop:read`. The controlling grant holds `desktop:control`
alone. The guest client `scripts/vm-verify-window-layout-client.py` sends each
operation with the text of
[the example operations](../design/desktop-window-layout-operations.graphql),
unchanged. Window focus uses `FocusDesktopWindow` from the released operations.

**Koine never witnesses its own answers.** `Fixtures/WindowIdentityProbe` is test
material that is signed and never shipped. It reads these facts from the system
after each action:

- `windows <pid>` and `stack <pid>...` give the Accessibility frame of each
  window of an application. `stack` also gives the window server's on-screen
  list, front to back, and the window number of each Accessibility window. So
  the probe puts the windows of TextEdit and Finder in the window server's
  order.
- `displays` gives the bounds of each display from Core Graphics, and the
  visible frame of the AppKit screen with the same number.
- `focused` gives the frontmost application and its focused window.
- `pointer` gives the position of the pointer and the buttons that are held.

The probe converts the visible frame with the formula of the contract. So the
display check proves that Koine reads the same facts, not that the formula is
right. The formula is visible in the result: the visible frame leaves out the
menu bar strip at the top of the display.

| Step | Action | Expected result |
|---|---|---|
| Disclosures, new grant | Read the served disclosures. Read the create-grant view. | The view presents the served text for `desktop:read` and `desktop:control`. Each text states the reach of window layout. |
| Disclosures, request | A client enrols for `desktop:read` and `desktop:control`. | The request view presents both served texts. The approved grant holds both capabilities. |
| Disclosures, grant list | Read the rows of the three grants. | Each row presents the served text of each desktop capability that it holds. |
| Window list | Open two TextEdit documents and one Finder window. Give Accessibility consent. List the windows. | One row for each window, with a window reference, a title, the application and a frame. Each frame is within 2 points of the witness's frame. |
| Display list | List the displays. | One primary display. Its frame and visible frame are within 2 points of the witness's values. The visible frame leaves out the menu bar. |
| Frame setting | Read the frame of one document. Set the left half of the visible frame. Set the earlier frame again. | Each receipt names the reference. Koine and the witness read each new frame within 2 points. |
| Order, two applications | Overlap the document and the Finder window. Focus the document, then the Finder window. | Both rows are `ON_SCREEN` with an order. Koine's order of the two equals the witness's order, with the focused window in front. |
| Point query | Ask at a point inside both windows. | The front window is `ON_TOP`, and the back window is `NOT_ON_TOP`. |
| Order, equal bounds | Give both documents one frame. Focus A, then B, then A. | Koine's order of the two equals the witness's order each time. |
| Minimised window | Minimise one document. | The witness sees it minimised. Its row is `OFF_SCREEN` with no order. |
| Display focus | Focus the Finder window and close every Finder window. Move the pointer away from the centre. Focus the display. | The receipt is `WINDOW_FOCUSED` with `pointerMoved` true. The witness reads the front listed window as focused, and the pointer at the centre of the display with no button held. No permission dialog appears. |
| Restart | Quit Koine and open it again. | The grants are unchanged, and each row still presents its served disclosures. |

The workspace precedent stands in for an upgrade: a restart rebuilds the grant
list from the stored grants, and presenting a grant changes none.

## Evidence

The accepted run took place on 2026-11-26 in a clone of macOS 27.2.1 (26B131),
arm64, at 1920 by 1080 points on one display. The bundle carried the signature
of `Developer ID Application: Antony Blakey (TA43A4RUP3)`, with CDHash
`18f4a4f767860dd9f70c2d6608de9d29663d608e`. Its desktop provider is release
1.0.1. The script had the same SHA-256 before and after the run. Every step
passed. The transcript is
[window-layout-20261126T231906.log](desktop-window-layout/window-layout-20261126T231906.log).

| Step | Observed |
|---|---|
| Disclosures | The create-grant view, the request view and the rows of the three grants presented the served texts of `desktop:read` and `desktop:control`, word for word. |
| Window list | `layout-a.txt` was at x 213, y 77, 673 by 439. `layout-b.txt` was at x 242, y 106, 673 by 439. The Finder window `Recents` was at x 500, y 161, 920 by 436. The witness read the same frames. |
| Display list | The frame is x 0, y 0, 1920 by 1080. The visible frame is x 0, y 30, 1920 by 960. It leaves out the 30-point menu bar and the Dock. The witness read the same values. |
| Frame setting | The left half was requested as x 0, y 30, 960 by 960. Koine and the witness both read 960 by 959, within the tolerance. The restore of x 213, y 77, 673 by 439 read back exactly. |
| Order, two applications | With the document focused, Koine and the witness both put `layout-a.txt` before `Recents`. With the Finder window focused, both put `Recents` first. |
| Point query | At x 960, y 340, the front window was `ON_TOP` and the back window was `NOT_ON_TOP`, in both orders. |
| Order, equal bounds | Both documents at x 660, y 140, 500 by 350. Focus A, B and A gave the orders A–B, B–A and A–B in Koine and in the witness. |
| Minimised window | The witness read `layout-b.txt` as minimised. Its row was `OFF_SCREEN` with no order. |
| Display focus | The receipt was `WINDOW_FOCUSED` with `pointerMoved` true. Focus moved from Finder, with no focused window, to window 55 of TextEdit, the front listed window. The pointer moved to x 960, y 540, the centre, with no button held. No dialog text was on screen. |
| Restart | The grants were the same before and after, and every row presented its served disclosures again. |

[order-textedit-front.png](desktop-window-layout/window-layout-20261126T231906-order-textedit-front.png)
records the overlap with the document in front.
[display-focus.png](desktop-window-layout/window-layout-20261126T231906-display-focus.png)
records the screen after display focus.

### The Dock and the point query

The first run, on an earlier build, stopped at the point query
([window-layout-20261126T224100.log](desktop-window-layout/window-layout-20261126T224100.log)).
The front window was `NOT_ON_TOP` at a point inside it. In the witness's list,
an entry at layer 20 with alpha 1 and the bounds of the whole display was in
front of every window. A diagnostic session in a clean clone named its owner,
`/System/Library/CoreServices/Dock.app/Contents/MacOS/Dock`, with default Dock
settings
([diagnose-layers-20261126T224445.log](desktop-window-layout/diagnose-layers-20261126T224445.log)).
The contract then counted every opaque entry in front as a cover. So every
window was `NOT_ON_TOP` at every point while the Dock was visible.

Antony chose the Dock bar rule. An entry of the Dock covers a point only outside
the visible frame of the display. The contract section "Visibility at a point"
states the rule and its limit. A magnified Dock or a Dock folder stack can hide a
window that reads `ON_TOP`. The accepted run above is on the build with the rule.
The first run also serves as the control of the point query check, because the
check failed there.

### Other checks on the same bundle

`task conformance:vm` passed on the accepted bundle: the signed application
serves `core-desktop-window-layout-workspace-extension-host`, and both positive
controls failed as they must (`conformance-20261126T232304.log`).
`task app:vm-verify-disclosure` passed on the earlier build
(`disclosure-20261126T224905.log`). That build differs only in the point query,
and the disclosures of the accepted run match it.

## Release checks on the notarised bundle

Koine 0.5.0 shipped as the notarised bundle with CDHash
`13b4f8eba7d169b5fcfc446051f1d28ca20a76bf`. Apple accepted submission
`fce5556e-0bfa-4d2a-a997-46709761e93f`, and the ticket is stapled. The zip of the
GitHub release has the SHA-256
`6db4d9f57b1bae5330749331f902127fb464284fb508239ab77388a02059366c`. The six
release checks ran on that bundle on 2026-11-26 and 2026-11-27, in clones of
macOS 27.2.1 (26B131).

| Check | Result |
|---|---|
| `task app:vm-verify-window-layout` | Every step above passed again ([window-layout-20261126T233721.log](desktop-window-layout/window-layout-20261126T233721.log)). Display focus moved the pointer to x 960, y 540. |
| `task app:vm-verify-release` | Passed (`release-20261126T233722.log`). |
| `task app:vm-verify-grant-workflows` | Passed (`grant-workflows-20261126T234051.log`). |
| `task app:vm-verify-notarized` | Passed (`notarized-20261126T234322.log`). The bundled desktop provider 1.0.1 was `ACTIVE` under quarantine. |
| `task app:vm-verify-disclosure` | Passed (`disclosure-20261126T234550.log`). |
| `task app:vm-verify-menu-bar` | The second attempt passed (`menu-bar-20261126T235519.log`). The first attempt passed every Koine step. It then stopped at the guest restart, because the guest took longer than the harness waits (#17). |

After each run, the bundle had the same CDHash. The transcripts other than the
window layout transcript stay in `.build/vm-verify` on the host that ran them.

## What this does not claim

- **A second display.** The VM has one display. So the run does not check a move
  to another display, the repeated resize across displays, or display focus on a
  display with no window. Issue #23 holds that check.
- **A Dock that draws inside the visible frame.** The run does not magnify the
  Dock or open a Dock folder stack. Issue #26 holds that case.
- **An upgrade from an installed 0.4.1.** A restart stands in for it, as in the
  workspace precedent.
