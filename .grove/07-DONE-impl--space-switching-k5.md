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

## Decisions (running log)

**Plain property-list values.** The logic module parses both native replies
from a plain `PropertyValue`. The provider converts the CFPreferences value
and the SkyLight reply into it. So the L tests hold each form of a reply,
and each form that fails, with no native read.

**A strict entry form.** `enabled` must be a property-list boolean, and the
three parameters must be integers. Any other form is `failed`. The route
probe wrote this form, and a read-only export on Antony's Mac gave the
same form for the entries 118 to 120. Entry 126 was absent there.

**A disabled entry is off.** A disabled entry gives `SHORTCUT_OFF` before
Koine reads its parameters. macOS does not act on a disabled shortcut, and
both outcomes post nothing.

**The count.** An empty SkyLight reply counts no desktops, so every number
gives `NO_SUCH_DESKTOP`. A display entry without a list of Spaces, or a
Space without an integer type, is another form, and it is `failed`.

**One main-thread turn.** The steps after the number check run in one
`MainActor.run`. AppKit updates the front app only between turns of the main
thread. So the front app that the check reads is the front app at the posts.
The spec states this after the steps of "Switching".

**The native reads.** `MissionControl.swift` holds the shortcut read and the
SkyLight read, as `WindowServer.swift` holds the window-server reads of the
desktop provider. The SkyLight functions are a lazy global, so a missing
symbol fails the switch alone. The reply follows the Copy rule, so Koine
releases it.

**Rows in pending tables.** The authority row "Control-digit Space
switching" and the trace row "Desktop windows" sit in pending tables. As
`input-keystrokes-k4` did, this leaf edits only its own cells and writes them
by the rules. The other touched passages were already in converted regions.

**The VM conformance run waits.** `task conformance` checks the input profile
only through the signed application in a VM. `app-input-acceptance-k6` owns
that run. The `swift test` conformance test holds the composition and its
digest to the design file.

**Failures that predate this leaf.** `task test` fails only in the workspace
test `aBundleWithinTheLimitWhoseInfoPlistIsTooLong...`, and `task check:docs`
fails only on the evidence link to a removed task file. The log of
`input-keystrokes-k4` records both at its parent revision.

**No review chain.** This leaf implements a design that `app-input-k8`
reviewed and `app-input-k9` integrated. The private SkyLight call is Antony's
decision, and that review read it. Nothing here is hard to reverse. The L
tests hold every check, and `app-input-acceptance-k6` checks the switch and
its refusals in a VM. The root brief plans no review for this leaf.
