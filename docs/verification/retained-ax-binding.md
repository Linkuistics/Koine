# Retained AX objects and process incarnation

**A held Accessibility element can address a different OS process after actual
PID reuse.** Retaining the AX object is therefore not a process-incarnation
guarantee: the task-name right and the AX object have different lifetimes. This
is why the [public Accessibility decision](../adr/desktop-automation-uses-public-accessibility.md)
accepts wrong-target data and effects during reuse, and why the
[capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md)
does not treat a held element as proof of an unchanged destination.

These are diagnostic experiments on macOS 26.5 (25F71) in disposable TestAnyware
clones, not runs of Koine. They deliberately use an AX object after its process
died, to show what happens when death falls after a provider's last check.

## Observed PID reuse and effect

The holder started a diagnostic Cocoa child, obtained its task-name right, and
retained its AX application, window and the window's AX parent. It killed and
reaped only that child, then created and reaped one child at a time until the
original PID was allocated again; that child executed the same app with a
different window title. Separate observer processes inspected the replacement
before and after the holder sent a minimize request through its **old** window
object. The diagnostic was compiled with Xcode 27.0 (27A266a), macOS SDK 27.0 and
a macOS 26.0 deployment target.

PID **781** was recycled after **99,413** child allocations. After the original
died, the holder **never created another AX application or enumerated
replacement windows**; all fresh acquisitions happened in separate observers.

| Observation | Retained window / task | Independent view of replacement |
|---|---|---|
| Original process alive, PID 781 | Window title `ORIGINAL PROCESS`; task-name acquisition succeeds | Original window exists |
| Original killed and reaped | Held AX reads return `-25204` (`cannotComplete`) | Original process has ended |
| New process at PID 781 | Old window title is now `REPLACEMENT PROCESS`; old task right is a dead name | Replacement exists and is not minimized |
| Minimize through the old window | `AXUIElementSetAttributeValue` returns success | Replacement is minimized |

The [full held-only result](retained-ax-binding/held-only.json) contains the
native records, empty stderr, diagnostic exit code **0**, and final guest
hashes. The retained AX parent also answered again after recycling. The
[before](retained-ax-binding/before.sha256) and
[after](retained-ax-binding/after.sha256) digests match for the probe source,
plist and compiled binary, and the [guest-before record](retained-ax-binding/guest-before.json)
matches the same binary and plist. The [launch record](retained-ax-binding/launch.json)
is separate from the completion evidence.

A second run that also re-enumerated windows in the holder recycled PID **760**
with the same outcome, and `CFEqual` equated the held window with a newly
enumerated replacement window. Its [source](retained-ax-binding/probe-with-reacquisition.m),
[captured output](retained-ax-binding/with-reacquisition.json) and
[input digests](retained-ax-binding/with-reacquisition-before.sha256) preserve
that scope; the digest names the file `probe.m`, whose bytes the preserved copy
matches.

The desktop provider's restore (`AXMinimized = false`), main-window selection
(`AXMain`) and raise (`AXRaise`) all act through a held window, so each shares
this premise. Application activation acquires a fresh AX application by PID,
which after death may select the successor. The experiment exercises minimizing,
not every AX action or every application.

## Public substitutes do not bind a process

- A task-name right is a retained kernel identity, not an AX messaging endpoint
  or a reservation of the PID.
- An [AX application](https://developer.apple.com/documentation/applicationservices/1459374-axuielementcreateapplication)
  is acquired by PID, and the public [AX reference surface](https://developer.apple.com/documentation/applicationservices/axuielement_h)
  takes no task-name argument in the element operations inspected.
- [NSRunningApplication](https://developer.apple.com/documentation/appkit/nsrunningapplication)
  represents application continuity; its `processIdentifier` may change after
  automatic termination, and its activation methods take no task identity.
- Apple Events have a port-addressed surface
  ([`typeMachPort`](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleEvents/appendix2_aepg/appendix2_aepg.html)),
  but [`AEGetRegisteredMachPort`](https://developer.apple.com/documentation/coreservices/1449736-aegetregisteredmachport)
  returns the caller's own endpoint, and no path from a captured task-name right
  to an arbitrary application's endpoint with equivalent focus behavior exists.

These are findings about the inspected interfaces, not proof that no public
mechanism could bind a process.

## Private AX reconstruction does not bind a process either

Koine does not rebuild AX objects from private tokens, because they cross
incarnations exactly as retained public objects do. A Developer ID-signed,
hardened diagnostic obtained the original window through ordinary Accessibility,
then created two private equivalents while that process was alive:

- `_AXUIElementRemoteTokenCreate` followed by `_AXUIElementCreateWithRemoteToken`;
- `_AXUIElementGetData` followed by `_AXUIElementCreateWithDataAndPid`.

Both compared equal to the original and read its title. After the original was
killed and reaped, the diagnostic created no new AX objects; fresh acquisitions
occurred only in separate witnesses. Both targets ran the same ordinary Cocoa
fixture.

| Observation | Private token object | Private data-plus-PID object |
|---|---|---|
| Original PID **787** alive | Reads `ORIGINAL PROCESS`; equal to original window | Same |
| Original killed and reaped | Reads fail with `cannotComplete` | Same |
| PID 787 recycled after **99,412** child allocations | Reads `REPLACEMENT PROCESS` | Same |
| Original task right | Dead name (`1048576`) | Same held task |
| Old object used for effect | Minimize returns success; witness sees `true` | Restore returns success; witness sees `false` |

The second effect is the provider's exact restore-from-Dock attribute operation,
landing on the successor. `_AXUIElementGetActualPid` still returned 787: it
reports a PID, not an incarnation. The 20-byte token observed was
`13030000 00000000 6f636f63 2a00000000000000` (PID 787, zero, kind `0x636f636f`,
element data 42); that is this element on this build, not an encoding contract.

An [inspection program](retained-ax-binding/inspect-private.m) read the guest's
own loaded HIServices image. Its [raw instructions and branch symbols](retained-ax-binding/private-symbols.json),
decoded with Capstone 5.0.7 in the [disassembly](retained-ax-binding/private-disassembly.txt),
show the token decoder and the data-plus-PID entry point both reaching
`_AXUIElementCreateInternal`. The decisive evidence is the native effect, not
the disassembly.

The [complete result](retained-ax-binding/private-result.json) records all
native phases, empty stderr, `probe_exit=0` and final guest hashes. The
[before](retained-ax-binding/private-before.sha256) and
[after](retained-ax-binding/private-after.sha256) hashes match for the probe,
private wrapper, plists, Taskfile and signed binary, and the
[guest-before record](retained-ax-binding/private-guest-before.json) matches the
same binary. The [launch record](retained-ax-binding/private-launch.json) is
separate from the completion evidence. The
[signature record](retained-ax-binding/private-signing.txt) shows Developer ID
signing with the hardened runtime; the diagnostic was not notarized.

## Reproduction

`task fixture:retained-ax` builds the public diagnostic
([probe.m](retained-ax-binding/probe.m) with [Info.plist](retained-ax-binding/Info.plist));
`task fixture:private-ax` builds and signs the [private probe](retained-ax-binding/private-probe.m)
on top of it. Neither task launches anything. Run them only in a disposable
TestAnyware macOS clone: upload the zip from `.build/`, unpack it under `/tmp`
with `ditto -x -k`, and run `K54Binding --run` or `K56PrivateBinding --run-private`
from the app bundle. Capture stdout, stderr and the exit code directly; a
detached launcher returning success is not completion. The probes bound
themselves at 300,000 child allocations and kill only their own children; a cap,
a missing window or an observer failure is inconclusive.
