# Retained AX objects and process incarnation

A macOS 26.5 (25F71) TestAnyware experiment found that a held Accessibility
window can address a different OS process after actual PID recycling. Retaining
the AX object is therefore not, by itself, a process-incarnation guarantee.
The task-name right and the AX object have different lifetime behavior.

A subsequent [signed/hardened private-API experiment](#private-token-and-data-reconstruction-also-cross-incarnations)
also found successor effects through token-created and data-plus-PID-created
AX objects. A subsequent [direct-port experiment](direct-ax-endpoint.md) supplies
bounded positive evidence for port lifetime and live-responder matching; its
complete native effect transport remains unestablished.

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
Those leads motivated the private reconstruction experiment below. WebKit's
cooperating-process transfer does not itself establish endpoint lifetime or
arbitrary-target capture; the observed native result is what rejects the tested
reconstruction route.

The investigation must also account for signed/hardened availability and every
native effect, including application activation and focus confirmation. The
choice authorizes investigating a private server mechanism; it approves neither
a specific dependency nor an altered reference/restart contract.

## Private token and data reconstruction also cross incarnations

The server-private reconstruction candidates are now **disproved on macOS 26.5
(25F71)**. In clone `koine-k56-binding`, a Developer ID-signed diagnostic with
hardened runtime obtained the original window through ordinary Accessibility,
then created two private equivalents while that process was alive:

- `_AXUIElementRemoteTokenCreate` followed by
  `_AXUIElementCreateWithRemoteToken`;
- `_AXUIElementGetData` followed by `_AXUIElementCreateWithDataAndPid`.

Both compared equal to the original and read its original title. After killing
and reaping the original, the diagnostic retained those objects, their original
inputs and the original task-name right. It created no new AX objects after
death; fresh acquisitions occurred only in separate witnesses. Neither target
incarnation supplied tokens or changed its Accessibility implementation for the
test: both ran the same ordinary Cocoa-window fixture.

| Observation | Private token object | Private data-plus-PID object |
|---|---|---|
| Original PID **787** alive | Reads `ORIGINAL PROCESS`; equal to original window | Same |
| Original killed and reaped | Reads fail with `cannotComplete` | Same |
| PID 787 recycled after **99,412** child allocations | Reads `REPLACEMENT PROCESS` | Same |
| Original task right | Dead name (`1048576`) | Same held task |
| Old object used for effect | Minimize returns success; witness sees `true` | Restore returns success; witness sees `false` |

The witness initially saw the replacement unminimized. Thus the second effect
is the exact **restore-from-Dock attribute operation** used by the provider,
against the successor rather than the captured process. The token object's
`_AXUIElementGetActualPid` still returned 787 with success. It reports a PID,
not an incarnation discriminator. This test deliberately operates after death
to expose what can happen if death falls after a provider's last check.

The [complete result](retained-ax-binding/private-result.json) records all native
phases, empty diagnostic stderr, `probe_exit=0` and final guest hashes. The
[before](retained-ax-binding/private-before.sha256) and
[after](retained-ax-binding/private-after.sha256) hashes match for the baseline
probe, private wrapper, source plist, Taskfile, generated plist and signed
binary. The [guest-before record](retained-ax-binding/private-guest-before.json)
and final guest hashes match the same generated plist and binary. The
[launch record](retained-ax-binding/private-launch.json) is separate from the
completion evidence. The measured files were unchanged throughout this run.

### What the token contains in this run

The token was 20 bytes: `13030000 00000000 6f636f63 2a00000000000000`.
The observed fields are PID 787, zero, kind `0x636f636f`, and element data 42.
The data getter returned kind `0x636f636f` and the final eight bytes. This is
an observation about this Cocoa element and OS build, not a portable encoding
contract or a claim about all token variants.

Before assigning diagnostic signatures, a small
[inspection program](retained-ax-binding/inspect-private.m) read code from its
**own loaded HIServices image in the VM**. Its
[raw instructions and branch symbols](retained-ax-binding/private-symbols.json),
decoded with Capstone 5.0.7 in the [disassembly](retained-ax-binding/private-disassembly.txt),
show the token creator copying three four-byte fields and element data. The
token decoder passes its decoded fields to `_AXUIElementCreateInternal`;
the data-plus-PID entry point branches to that same constructor.
`_AXUIElementGetActualPid` branches to a PID getter. These observations guided
the diagnostic's inferred signatures; the decisive lifetime evidence is the
native effect, not a claim that disassembly proves every closed implementation
path. The inspection did not attach to, inject into or modify a target process.

### Availability, refusal and remaining limits

`task fixture:private-ax` builds and signs the
[private probe](retained-ax-binding/private-probe.m), reusing the public fixture.
It never launches an app. The
[signature record](retained-ax-binding/private-signing.txt) shows Team ID
`TA43A4RUP3`, Developer ID signing and the runtime flag. Compilation used Xcode
27.0 / macOS SDK 27.0 with deployment target 26.0. All five private symbols
resolved in the guest, Accessibility trust was available, and live acquisition
and both effects succeeded. This establishes diagnostic availability under those
conditions only. The diagnostic was not notarized or quarantine-launched, and
inherited usable Accessibility access when launched by the VM agent; it does
not establish Koine's separate consent attribution or all policy configurations.

The diagnostic refuses missing symbols, missing trust and unsuccessful initial
construction; those refusal branches were not separately exercised. No viable
product mechanism is being recommended, so this is not a signed-product policy
acceptance claim. Native main-window selection, raise and application activation
were not individually retested: the observed wrong restore already violates the
required all-effects guarantee. Neither exec replacement nor automatic
restoration was exercised in this private run. The separate serial experiment
still establishes why restored logical-app identity cannot substitute for strict
process lifetime. No wrappers tested here should be adopted on the assumption
that another pre-check repairs their endpoint lifetime.

For reproduction, upload `.build/private-ax.zip` to a disposable clone, unpack
under `/tmp`, and execute
`/tmp/K56PrivateBinding.app/Contents/MacOS/K56PrivateBinding --run-private`.
Capture stdout, stderr and the exit code independently of a detached launcher.
The bound is 300,000 child allocations, one child at a time; reaching it or
failing a witness is inconclusive. Only the fixture's own children are killed.
The target behavior is inherited from the public probe; the wrapper selects
the private investigation only for `--run-private`.

### Recommendation and the remaining endpoint question

Reject **AX reconstruction as the process binding**. It keeps a shallow
interface but hides the same reusable PID/element addressing. Private dependency
maintenance cost buys no required lifetime guarantee in the tested paths.
Reconsider only with a distinct native binding mechanism and evidence that its
effects cannot reach a successor; a different opaque encoding is insufficient.

A concrete alternate acquisition lead remains:
[`bootstrap_look_up2`](https://github.com/apple-oss-distributions/launchd/blob/d448a1c8f70a61202f8705f94337f686b87c30c4/liblaunch/libbootstrap.c#L188-L234)
can request a target PID's `com.apple.axserver` send right using
[`BOOTSTRAP_PER_PID_SERVICE`](https://github.com/apple-oss-distributions/launchd/blob/d448a1c8f70a61202f8705f94337f686b87c30c4/liblaunch/bootstrap_priv.h).
WebKit's [sandbox registration](https://github.com/WebKit/WebKit/blob/38cc1fbc76b839ab6cb0d3d58f1ffa3d1de1e3bf/Source/WebKit/WebProcess/com.apple.WebProcess.sb.in)
names that service as per-PID. The launchd implementation is historical primary
source; the [direct experiment](direct-ax-endpoint.md) now establishes lookup
availability on its guest build, but not a complete effect protocol.
This lead keeps public client capture and private code inside
Koine, but replaces AX wrapper convenience with a private transport whose
ownership, lifetime and version maintenance must be understood.

The next feasibility decision must establish three connected properties:

1. **Acquisition and attribution:** the endpoint actually belongs to the
   captured task. A PID lookup may race with replacement. A harmless request
   with a kernel audit trailer is a possible matching instrument, not a settled
   identity scheme. The bootstrap reply's audit token authenticates launchd,
   not the target; indefinitely cached pidversion equality remains insufficient.
   The ordered live-task comparison in the direct experiment is a different
   candidate, with bounded native evidence.
2. **Lifetime:** this particular receive right ends with the captured task
   and cannot be transferred or recovered for a successor. A retained send
   right identifies a port object, not necessarily one receiver incarnation.
   XNU [port destruction](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_port.c#L1116-L1126)
   allows a backup receiver. The AX service's actual registration and teardown
   need evidence under death, exec and automatic restoration.
3. **Complete effects:** every read, restore, main-window selection, raise,
   activation and focus confirmation consumes that endpoint continuously,
   without reconstructing a PID-addressed AX object. Death after admission
   or between native steps must fail closed; an after-check cannot undo effects.

The direct experiment advances acquisition and ordinary death behavior without
establishing all three properties. Until those hold there is
**no feasible complete binding established**, but
also no evidence for universal private-API impossibility. The public schema,
client consent and strict lifetime contract remain unchanged by this result.

### Bounded review reconciliation

One fresh-context reviewer inspected alternate primary-source routes while the
native test ran. Its findings were checked against their actual scope:

- **Remote wrappers lack a documented guarantee:** actionable when received;
  the completed native experiment supplies the stronger counterexample above.
- **Per-PID AX service lookup lacks captured-task attribution:** actionable
  design gap, preserved as the next endpoint question. The reviewer's proposed
  audit-trailer matching is a lead; it does not overcome finite pidversion or
  establish receiver ownership by itself.
- **Send rights can outlive a receiver:** actionable limitation on the generic
  lifetime claim, supported by the XNU source above and launchd's distinction
  between registered sends and recoverable receives in
  [service creation](https://github.com/apple-oss-distributions/launchd/blob/d448a1c8f70a61202f8705f94337f686b87c30c4/src/core.c#L6316-L6352)
  and [notifications](https://github.com/apple-oss-distributions/launchd/blob/d448a1c8f70a61202f8705f94337f686b87c30c4/src/core.c#L7296-L7309).
- **SkyLight connection evidence reaches WindowServer:** actionable correction
  to treating it as a target AX endpoint. Yabai's
  [concrete use](https://github.com/asmvik/yabai/blob/dd845723416f5fe92af49fad5ebab00369e07edd/src/window.c#L930-L960)
  uses its own connection and a window number. That does not reject all
  SkyLight mechanisms; it rejects the offered evidence for this binding.
- **AppleEvent addressing lacks an all-effects arbitrary-target path:** an
  already recorded limitation, not a new impossibility result. Port addressing
  alone supplies neither AX handlers nor equivalent consent behavior.
- **Modern exec creates a replacement task:** relevant evidence against
  rejecting the raw-port candidate on an assumption that every port survives
  exec. [XNU exec](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exec.c)
  supports task replacement; AX endpoint teardown remains unproved.

No second reviewer was used. The unresolved direct transport is separate design
work, not a patched wrapper requiring another review. Code verification used
Tier 2 graph generation `2026-09-21T11:51:36Z` and exact provider effect snippets;
the private diagnostic was also read directly because its index coverage
reported a parse gap across lines 1–108. These are bounded source findings.

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
