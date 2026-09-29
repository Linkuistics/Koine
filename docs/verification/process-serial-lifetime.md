# Process serial numbers can outlive a kernel process

A macOS 26.5 (25F71), Apple Silicon TestAnyware VM demonstrated that a public
Process Manager serial number (PSN), even paired with the platform boot identity,
can name successive OS processes for one automatically terminated application.
That pair cannot implement Koine's strict process-incarnation contract.

The test ran on 2026-09-21 in a disposable TestAnyware clone. Koine was not
launched. The diagnostic app used public APIs and was compiled with the host
Xcode SDK, without Developer ID signing or notarization. This is a native API
counterexample, not product acceptance evidence.

## Observation

The app declares `NSSupportsAutomaticTermination` and
`NSSupportsSuddenTermination`. It logs its own `GetCurrentProcess` result and
boot identity, opens a window, then closes the window and hides after twenty
seconds. The delay makes observation convenient; it contributes no identity.
Apple's `talagent -memory_pressure` command was also invoked. The app may become
automatically terminable before that command; this experiment does not attribute
the exact termination instant to simulated memory pressure.

Boot identity throughout: `25214686-C4E0-4D45-BDF4-2D0B08EF8DB9`.

| Observation | PSN | PID reported by `GetProcessPID` | Native process evidence |
|---|---|---:|---|
| App running | `000000000003f03f` | 893 | `ps` sees the app; task-name and audit-token calls succeed; pidversion 2360 |
| App automatically terminated | `000000000003f03f` | 893 | `ps` finds no process (status 1); task-name acquisition fails with 5 |
| App restored using `open` | `000000000003f03f` | 910 | New app logs the same PSN; task-name and audit-token calls succeed; pidversion 2398; old PID remains absent |

Both forward and reverse PSN/PID lookups returned success in all three rows,
including the row with no live process. The platform's
[lifecycle log](process-serial-lifetime/lifecycle.json) identifies TAL termination
and later restoration. A separate exploratory run observed the same pattern
with PID 848 → 863 and PSN `0000000000039039`; the table is a repeat using
frozen inputs and captured output.

The app reads `kIOPMBootSessionUUIDKey` through public
`IORegistryEntryFromPath(kIOMainPortDefault,
"IOPower:/IOPowerConnection/IOPMrootDomain")` and
`IORegistryEntryCreateCFProperty`. The lookup tool's
`sysctlbyname("kern.bootsessionuuid")` returned the same value. The IOKit SDK
header describes the property's scope as one boot, unchanged by sleep or
hibernation; a boot scope does not distinguish these two processes.

## Sources and captured output

- [AutoTerm.m](process-serial-lifetime/AutoTerm.m) and
  [Info.plist](process-serial-lifetime/Info.plist): complete diagnostic app.
- [lookup.c](process-serial-lifetime/lookup.c): public PSN lookup plus task-name
  and audit-token diagnostics. `samePort` is only a numeric comparison: **ignore
  it when either acquisition failed**, as both output variables remain null.
  These diagnostics do not establish native action safety.
- [first-launch.json](process-serial-lifetime/first-launch.json): OS version and
  guest binary/plist hashes. Its immediate foreground lookup still saw Finder;
  it is not the target-app sample.
- [live.json](process-serial-lifetime/live.json),
  [terminated.json](process-serial-lifetime/terminated.json), and
  [restored.json](process-serial-lifetime/restored.json): the table's three
  observations, including exact commands and exit/timeout fields.
- [before.sha256](process-serial-lifetime/before.sha256) and
  [after.sha256](process-serial-lifetime/after.sha256): matching source, plist and
  host binary digests before and after the repeat. Guest hashes in the launch
  and restoration records match those binaries and plist.

The repeat's captured commands all completed without timeout. During exploratory
setup, guest commands that launched a GUI app with inherited output handles
sometimes timed out while the app had launched successfully. The repeat redirects
both app streams and the launcher streams; an `ok` envelope alone is never treated
as a successful guest exit. No measured input changed during the repeat.

## Reproducing the experiment

`task fixture:process-serial` builds the two probes and packages
`.build/process-serial.zip`; it never runs the app. Start a disposable macOS
TestAnyware clone, upload the zip to `/tmp`, and unpack it with
`ditto -x -k /tmp/process-serial.zip /tmp`. Run the following **inside that VM**,
through `testanyware file exec --vm <clone> --json`:

```sh
open -a /tmp/K51AutoTerm.app --stdout /tmp/probe.stdout --stderr /tmp/probe.log </dev/null >/tmp/open.stdout 2>/tmp/open.stderr
```

Read `/tmp/probe.log` after the app finishes launching and before its window
closes; query the recorded serial with
`/tmp/koine-k51-psn-probe psn <16-hex-PSN>`. After it closes/hides, invoke
`/System/Library/CoreServices/talagent -memory_pressure`; observe both `ps` and
the same serial lookup. Reopen the app with the same redirected launch command,
using a new log filename, and query the **old** serial again. Capture the native
lifecycle log with `talagent -log`. Record hashes before/after, examine guest
exit codes and timeout flags, and stop the clone afterwards. The exact commands
and results of this run are linked above. Automatic termination timing is owned
by macOS; a process that remains alive is an inconclusive run, not a pass.

## Interpretation and limits

Apple's [app lifecycle documentation](https://developer.apple.com/library/archive/documentation/General/Conceptual/MOSXAppProgrammingGuide/CoreAppDesign/CoreAppDesign.html)
describes automatic termination as removing an app's underlying process while
preserving the user's application continuity. The installed
`NSRunningApplication` header likewise warns that a PID can change under
automatic termination. This experiment establishes that public PSN lookup can
also preserve that application identity across different kernel processes.

An ordinary quit/relaunch test is insufficient: in an exploratory TextEdit probe
the old PSN returned `procNotFound` and relaunch assigned a new serial, but
automatic termination takes a different path. Adding a live-process check
would detect the middle row only; a delayed request after restoration would
still find a live process under the original PSN and boot identity.

This does not establish PSN reuse by an unrelated application, whole-boot
uniqueness, counter wrap, logout behavior, actual PID recycling, exec semantics,
or Accessibility endpoint binding. It does not test the final client event
capture path or retained-right transfer. None of those claims is needed for
the counterexample: one PSN/boot pair demonstrably names two OS processes.
