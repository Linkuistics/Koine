# Retained AX objects and process incarnation

A macOS 26.5 (25F71) TestAnyware experiment found that a held Accessibility
window can address a different OS process after actual PID recycling. Retaining
the AX object is therefore not, by itself, a process-incarnation guarantee.
The task-name right and the AX object have different lifetime behavior.

This is a diagnostic experiment, not a run of Koine or evidence that a normal
Koine operation has already mistargeted a window. It tests the platform premise
needed to close the interval between an identity check and a native effect.
The [capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md)
requires the effect to stay with the captured process, including when it ends
after the last check.

## Observed PID reuse and effect

In disposable clone `koine-k54-binding`, the holder started a diagnostic Cocoa
child, obtained its task-name right, and retained its AX application, window
and the window's AX parent. It killed and reaped only that child. It then
created and reaped one child at a time until the original PID was allocated
again; that child executed the same app with a different window title.
Separate observer processes inspected the replacement before and after the
holder sent a minimize request through its **old** window object.
The experiment ran on 2026-09-21; the diagnostic was compiled using Xcode 27.0
(27A266a), macOS SDK 27.0, with a macOS 26.0 deployment target.

The decisive, narrower run recycled PID **781** after **99,413** child
allocations. After the original died, the holder **never created another AX
application or enumerated replacement windows**. All fresh acquisitions happened
in separate observer processes. The result was the same:

| Observation | Retained window / task | Independent view of replacement |
|---|---|---|
| Original process alive, PID 781 | Window title `ORIGINAL PROCESS`; task-name acquisition succeeds | Original window exists |
| Original killed and reaped | Held AX reads return `-25204` (`cannotComplete`) | Original process has ended |
| New process at PID 781 | Old window title is now `REPLACEMENT PROCESS`; old task right is a dead name | Replacement exists and is not minimized |
| Minimize through the old window | `AXUIElementSetAttributeValue` returns success | Replacement is minimized |

The [full held-only result](retained-ax-binding/held-only.json) contains the
native records, empty stderr, diagnostic exit code **0**, and final guest
hashes. The original task's numeric name remained held throughout; the new
task-name acquisition returned a different name. The AX parent returned by the
original window was also retained and answered again after recycling.

The [before](retained-ax-binding/before.sha256) and
[after](retained-ax-binding/after.sha256) digests match for the final probe
source, plist and compiled binary. The [guest-before record](retained-ax-binding/guest-before.json)
and final guest hashes match that same binary and plist. No measured input was
edited during this run. The [launch record](retained-ax-binding/launch.json)
is preserved separately and is not the evidence of completion.

The first completed experiment recycled PID **760** after 99,415 child
allocations. The old window changed from `ORIGINAL PROCESS` to
`REPLACEMENT PROCESS`. The held task right had become a dead name
(`MACH_PORT_TYPE_DEAD_NAME`, 1048576); acquiring the replacement's task-name
right returned a different name. The old AX application and AX parent answered
again, and `CFEqual` equated the held window with a newly enumerated replacement
window. The minimize request through the held window returned success.
The independent observer saw the replacement change from unminimized to
minimized.

This run also created a fresh AX application and enumerated windows in the
holder after replacement. Its complete
[source](retained-ax-binding/probe-with-reacquisition.m),
[captured output](retained-ax-binding/with-reacquisition.json) and
[input digests](retained-ax-binding/with-reacquisition-before.sha256)
preserve that scope. The immediate read within the holder still reported
`minimized: false`; the subsequent independent observer reported `true`.
The effect is witnessed by that later observation, not by assuming an
asynchronous native action became visible immediately.
The earlier digest names `probe.m`, its name at that run; the preserved
`probe-with-reacquisition.m` copy has those same bytes. The final held-only run
is the one with both host and guest before/after hashes.

An earlier exploratory attempt ended with exit 7 because the holder could not
enumerate a replacement window. It had no independent observer and was
inconclusive. It is not counted as evidence that references fail closed.

## What this changes

The vulnerable interval is: capture/validate process A → A ends → B receives
A's PID → an AX operation through an old element reaches B. Actual PID reuse
was observed here; it was not simulated by changing a timestamp input.
The diagnostic intentionally continues to use the AX object after task death
to examine that endpoint's behavior. A provider should refuse a task already
known dead. That refusal does not close the interval when death occurs after
its last check and before the effect.

The currently implemented provider's native effect surface is:

| Native step | Target currently supplied | Obligation for a replacement design |
|---|---|---|
| Restore from Dock | Held window, `AXMinimized = false` | Effect must stay with the captured process and window |
| Choose main window | Held window, `AXMain = true` | Same binding |
| Raise | Held window, `AXRaise` | Same binding |
| Bring application forward | Fresh `AXUIElementCreateApplication(pid)`, `AXFrontmost = true` | Acquiring by the old PID after death may select its successor |
| Confirm frontmost and focused window | Another fresh AX application; compare window with `CFEqual` | Report only the captured target; an after-check cannot undo a wrong effect |

This matrix was checked against `resolveAndAct`, `act`, `hasFocus`, `held` and
`window` in the provider source. The experiment exercises minimizing, not every
row individually. It disproves the shared premise that retaining an arbitrary
actionable AX window is sufficient; it does not claim every AX action or app
will exhibit the same result.

Code discovery used the project's Tier 2 graph and exact source snippets, with
coverage reporting matching metadata and no recorded gaps for the provider
files. Coverage is a best-effort signal. The local SDK declarations were read
directly; they were not inferred from graph results or function names alone.

## Public API assessment

The installed Xcode 27.0 (27A266a), macOS SDK 27.0 declarations and Apple's
documentation distinguish three different objects:

- A task-name right is a retained kernel identity. It is not an AX messaging
  endpoint or a reservation of the PID. The prior pinned XNU review is recorded
  in the capture design's brief; native transfer must transfer an actual right,
  not its numeric name.
- An [AX application](https://developer.apple.com/documentation/applicationservices/1459374-axuielementcreateapplication)
  is acquired by PID. The public [AX reference surface](https://developer.apple.com/documentation/applicationservices/axuielement_h)
  supports retention and comparison but supplies no task-name argument to the
  element operations inspected here. The native result above settles a failure
  that the documentation alone left unproved.
- An [NSRunningApplication](https://developer.apple.com/documentation/appkit/nsrunningapplication)
  represents application continuity. Its `processIdentifier` header explicitly
  permits PID changes after automatic termination. Its activation methods do not
  accept a retained task identity, so substituting it does not establish strict
  process lifetime.

Apple Events do have a public port-addressed effect surface:
[`typeMachPort`](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleEvents/appendix2_aepg/appendix2_aepg.html).
However, [`AEGetRegisteredMachPort`](https://developer.apple.com/documentation/coreservices/1449736-aegetregisteredmachport)
returns the calling process's endpoint. No complete acquisition path from the
captured task-name right to an arbitrary unmodified application's endpoint was
established, nor equivalent window-focus behavior and consent ownership.
[`kAEDontReconnect`](https://developer.apple.com/documentation/coreservices/aesendmode)
is deprecated and unsupported on macOS. This alternative cannot currently be
presented as the solution.

These are bounded findings about the inspected interfaces and tested candidate,
not proof that every public macOS mechanism is incapable of satisfying the
contract. No private endpoint-binding solution has been established either.

## Authorized private-API investigation

The human chose to investigate private APIs **inside Koine**, retaining public
client APIs and strict process lifetime. The SDK's HIServices export list has
`_AXUIElementCreateWithRemoteToken`, `_AXUIElementRemoteTokenCreate`,
`_AXUIElementCreateWithDataAndPid`, and `_AXUIElementGetActualPid`.
[WebKit's private accessibility declarations](https://raw.githubusercontent.com/WebKit/WebKit/main/Source/WebCore/PAL/pal/spi/cocoa/NSAccessibilitySPI.h)
include `NSAccessibilityRemoteUIElement` with token construction and
initialization; [its WebPage implementation](https://raw.githubusercontent.com/WebKit/WebKit/main/Source/WebKit/WebProcess/WebPage/mac/WebPageMac.mm)
transfers tokens produced for local UI elements between cooperating processes.
Those are concrete leads, not lifetime guarantees or an acquisition path for
arbitrary unmodified applications. A token may simply serialize the same unsafe
identity. Investigate its representation, endpoint ownership, process matching,
death and exec behavior before proposing it as the binding.

The investigation must also account for signed/hardened availability and every
native effect, including application activation and focus confirmation. The
choice authorizes investigating a private server mechanism; it approves neither
a specific dependency nor an altered reference/restart contract.

## Reproduction and measurement boundary

`task fixture:retained-ax` compiles and packages the diagnostic; it never
launches it. Execute it only in a disposable TestAnyware macOS clone. The final
probe is [probe.m](retained-ax-binding/probe.m), packaged with
[Info.plist](retained-ax-binding/Info.plist). Its `--trust` mode reports consent
without starting a target. In this clone, an agent-launched diagnostic inherited
usable Accessibility access. That is a test setup fact; it does not propose
moving product consent from Koine to its clients.

Upload `.build/retained-ax.zip` to `/tmp`, unpack it there with `ditto -x -k`,
then run `/tmp/K54Binding.app/Contents/MacOS/K54Binding --run`. Redirect output
and errors to files and capture the process exit code. A detached launcher
returning success is not completion. The probe bounds itself at 300,000 child
allocations; a cap, a missing original/replacement window, or observer failure
is inconclusive. It kills only the child it created and waits for it; the guest
is stopped after collecting results.

The diagnostic uses public APIs, is neither Developer ID-signed nor notarized,
and runs a controlled Cocoa app. It does not establish Mach-right transfer under
the signed product's policy, event-handler attribution, exec semantics, all
applications' behavior, automatic restoration, restart reference policy, or a
replacement protocol. The separate
[serial lifetime experiment](process-serial-lifetime.md) covers automatic
restoration. A formal model that assumes AX endpoints expire with processes
would be modelling the false premise exposed here.
