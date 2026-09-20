# Desktop remembered windows: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
`remembered-windows-across-spaces-k31`: windows Koine has seen that an
application no longer enumerates are listed as `REMEMBERED`, are dropped when
their end is observed, and are revalidated on every selection. It runs on the
Developer ID signed `Koine.app` with TextEdit and Finder; there are no application
mocks. The identity mechanism it rests on is in
[desktop-window-identity.md](desktop-window-identity.md), focus in
[desktop-focus-vm.md](desktop-focus-vm.md), and the consent route in
[desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md).

## What the platform offers

- **An application enumerates the current Space alone.** `AXWindows` omits a
  window on another Space; nothing public enumerates it. The element held for it
  still answers from there. So remembering is the only source of such a row, and
  what `REMEMBERED` adds is the enumeration, not the display data: the row's title
  is read from the element as it is listed, and the stored title stands only when
  the application does not answer.
- **Destruction** is `kAXUIElementDestroyedNotification`, registered per element
  on an `AXObserver` per application, delivered through a run loop source
  (`AXUIElement.h`, `AXNotificationConstants.h`: the callback's element is the
  destroyed one, invalid for further calls and still comparable with `CFEqual`).
  Registration is an Accessibility call and needs consent; the provider registers
  only for windows it has listed, which already needed it.
- **Termination** is `NSWorkspace.didTerminateApplicationNotification`, which
  needs no consent. Independently of it, every use compares the process
  incarnation against the kernel first, so nothing of an ended incarnation is
  served even if the notification never arrives.
- **A second Space in a VM** is a full-screen window's own: ⌃⌘F, then ⌃← back to
  the desktop Space. TestAnyware drives both as key presses; Mission Control is
  not needed.

Both notifications only ever remove. Whether Koine itself received one is not
visible through GraphQL: the row would go at the next listing anyway, because the
element is asked again. What the notification adds is that the token is retired at
once, which narrows the identity assumption in
[desktop-window-identity.md](desktop-window-identity.md). The native evidence that
it arrives is the probe's.

## Procedure

```sh
task app                               # build and sign .build/app/Koine.app
task app:vm-verify-desktop-remembered  # scripts/vm-verify-desktop-remembered.sh
```

Two grants are created in Koine's window: a reader (`koine:manage`,
`desktop:read`) and a controller with `desktop:control` alone. Listings are
`DesktopChoices` and focuses `FocusDesktopWindow`, as
`docs/design/desktop-operations.graphql` has them. `Fixtures/WindowIdentityProbe`
is the native witness: `focused` and `windows <pid>` as before, and
`observe <pid> <seconds>`, which registers for the destruction of every window the
application lists, waits until it is told of one or the seconds pass, and prints
what it was told, with its times.

| Step | How | Expectation checked |
|---|---|---|
| Seen | TextEdit opens `remembered-a.txt` and `remembered-b.txt`; list | two rows, both `CURRENT`; references A and B |
| Left on another Space | focus A, ⌃⌘F, ⌃←; the probe sees focus elsewhere and TextEdit enumerating no window with A's id; list; `desktopWindow` for each | two rows: A once, `REMEMBERED`, under reference A; B `CURRENT`; `desktopWindow` agrees for both |
| Selected | focus A | the receipt; the probe reads A's id focused; listed from there, A is `CURRENT` and B `REMEMBERED` |
| Returned | ⌃⌘F leaves full screen; list | both `CURRENT`, same references |
| Closed while observable | the probe observes TextEdit; focus A, ⌘W; list; `desktopWindow` and focus A | the probe was told of the destruction of A's id alone; one row, B; A is `unavailable` by both routes and focus does not move |
| Terminated | B left on another Space and listed `REMEMBERED`; `killall TextEdit`; `desktopWindow` B, the application's reference; TextEdit opened again; list | both `unavailable`; the successor has another reference and lists nothing `REMEMBERED` and neither A nor B |
| Management window closed | Koine's window closed; *then* `remembered-d.txt` opened, listed, focused, ⌃⌘F, ⌃←; the probe sees it not enumerated; list; focus it | `CURRENT`, then `REMEMBERED` under the same reference; the receipt, and the probe reads its id focused |
| Quit | Koine's window shown again, ⌘Q | no Koine process three seconds later, with observers registered |

The host suite holds what needs no window: `HeldWindowsTests` for the
bookkeeping (each window once and under its token, titles refreshed, the four
answers of an omitted element, tokens never issued again, nothing under a
successor), and `DesktopProviderTests` for the references no run can resolve.

## Evidence

Run of 2026-09-20, macOS 26.5 (25F71) arm64 clone, bundle signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`; transcript
`.build/vm-verify/desktop-remembered-20260920T054307.log`, with the screenshot
`…-a-remembered.png` beside it. **PASSED**, exit 0, with no guest exec exhausted.
The provider's sources, its sealed dylib and the application's executable, the
script and its libraries, the guest clients, the probe's source and the design
operations had the same SHA-256 digests after the run as before it. The probe's
binary is built and signed by the run itself. Window numbers are the probe's;
references are written `<token>` within session `51f495eb080e8bcc`.

- Seen: TextEdit (pid 767) listed `remembered-b.txt` (1) and `remembered-a.txt`
  (2), both `CURRENT`.
- Left on another Space: A focused (window 59) and made full screen; back on the
  desktop Space the probe read B (58) focused and TextEdit enumerating 58 alone.
  Koine listed 1 `CURRENT` and then 2 `REMEMBERED`, two rows; `desktopWindow`
  answered `REMEMBERED` for 2 and `CURRENT` for 1, with the same titles.
- Selected: focusing 2 returned its receipt and the probe read 59 focused; macOS
  had switched to its Space. Listed from there: 2 `CURRENT`, 1 `REMEMBERED`.
- Returned: after leaving full screen, 2 and 1 both `CURRENT`.
- Closed while observable: the probe registered for 59 and 58 (both
  `kAXErrorSuccess`) at 19:47:16Z; ⌘W at 19:47:50Z; the probe then saw TextEdit
  enumerate 58 alone, and had been told of the destruction of 59, and of nothing
  else, in that same second. Koine listed one row, 1 `CURRENT`. Reference 2:
  `unavailable`, "The window is no longer open.", by `desktopWindow` and by
  focus, with Finder 115 focused before and after.
- The management window was closed here; nothing after this had one.
- Terminated: B focused, made full screen and left; listed as the one row, 1
  `REMEMBERED`. After `killall TextEdit`: reference 1 `unavailable`, "The window
  is no longer open."; the application's reference `unavailable`, "The
  application is no longer running." TextEdit opened again (pid 976, `open -F`):
  another application reference, one row, `remembered-c.txt` (3) `CURRENT`,
  nothing of pid 767.
- Opened and moved afterwards: `remembered-d.txt` listed as 4 `CURRENT` beside 3;
  focused (143), made full screen and left; the probe saw TextEdit enumerate 140
  alone; Koine listed 3 `CURRENT` and 4 `REMEMBERED`; focusing 4 returned its
  receipt and the probe read 143 focused.
- Quit: Koine's window shown again, ⌘Q, and no Koine process three seconds later.

Four earlier runs are not the evidence. The first ran a build in which `stop()`
forgot nothing (found by reading, below) and ended at the closure step, where the
probe reported no destruction: the exec that started the probe in the background
had waited for it, so the window closed after the probe's time was up. The probe
now ends at the first destruction it is told of and stamps its times, and the
script sees it running, and the window natively gone, before concluding anything.
The second and fourth ended in the script's scenario, not in Koine: a killed
TextEdit restores its windows, full screen included, so the rest of the run
happened inside that Space (`open -F` opens it fresh). The third ended on
TestAnyware's false timeout at a `lookup` whose answer was complete; `lookup` now
uses `guest_json`. Every step those runs reached read as it does above.

`WindowObservation` was put to one adversarial read in a fresh context, given the
sources and their contract. Found and fixed before the run above: forgetting was
written as `observation?.forget(table.forget(…))`, and an optional chain on no
observation skips its argument, so `stop()` and a provider without observation
forgot nothing; a termination notice delivered late could forget a successor that
had reused the PID, so the kernel is asked first; an observation released without
`stop()` left its sources in the run loop; and an ended incarnation met only by
reference was never forgotten. Stated, not fixed: where no main run loop runs, a
retired watch is never released. That is a host without Accessibility consent,
where none is ever made.

The two earlier desktop verifications were run again afterwards, on the same
signed build, because this leaf moved the choosing, focusing and witness helpers
into `scripts/vm-verify-desktop-lib.sh` and changed `lookup`:
`task app:vm-verify-desktop-focus`, transcript
`.build/vm-verify/desktop-focus-20260920T060056.log`, and
`task app:vm-verify-desktop`, transcript
`.build/vm-verify/desktop-20260920T063428.log`. Both **PASSED**, exit 0, with no
guest exec exhausted and the scripts, guest client and provider dylib unchanged
across them. `task compat` was not run: `KoineProviderAPI` is untouched.

## What is incomplete, and stays so

- **A Space no listing was ever made from.** Koine holds only what a client's
  listing has seen. It does not watch applications no client has asked about, so
  a window that was never enumerated while a client listed its application is
  unknown until it is. Run four showed it: a document opened inside a full-screen
  Space was not in the listing made from the desktop Space.
- **A disappearance that is not observable.** A remembered window whose
  application does not answer stays listed with the title last read, until the
  element answers that it is gone, the destruction notice arrives or the process
  ends. Not reproduced here: TextEdit always answered.
- **Whether Koine's own observer fired** is not visible from outside; the probe's
  is the evidence that the platform delivers it, and re-asking makes it
  unnecessary for correctness.
- This run is macOS 26.5 on arm64 alone, which is the supported matrix:
  [latency-and-support-matrix.md](latency-and-support-matrix.md).

## Tooling notes for the leaves that follow

- A guest exec that starts a background job waits for it unless the job is fully
  detached: `nohup … </dev/null >file 2>&1 &`.
- ⌃⌘F toggles: inside a full-screen Space it leaves full screen. Know which Space
  the run is on before pressing it; `open -F` keeps a relaunched application from
  restoring one.
- `testanyware agent window-close --window Koine` answers HTTP 400 when Koine's
  window is on another Space than the current one.
