# Desktop focus: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
focus: `desktopFocusWindow` focuses exactly the window a
reference names, or reports why it did not and moves nothing. It runs on the
Developer ID signed `Koine.app` with Finder, TextEdit and Stickies; there are no
application mocks. The identity mechanism it rests on is in
[desktop-window-identity.md](desktop-window-identity.md), and the consent route in
[desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md).

## Procedure

```sh
task app                          # build and sign .build/app/Koine.app
task app:vm-verify-desktop-focus  # scripts/vm-verify-desktop-focus.sh
```

Two grants are created in Koine's window: a reader (`koine:manage`,
`desktop:read`) that lists, and a controller with `desktop:control` **alone** that
focuses. The guest client sends `DesktopChoices` and `FocusDesktopWindow` with the
text `docs/design/desktop-operations.graphql` has for them, unchanged, each sent
alone.

**Which window has focus is never asked of Koine.** `Fixtures/WindowIdentityProbe`
(test material, signed, never shipped) reads it from the system after every
action: `focused` reports the front application as `NSWorkspace` gives it to a
fresh process, that application's own `AXFocusedWindow` with its window-server id
(the private `_AXUIElementGetWindow`, in the probe alone, as in the identity
evidence), and the owner of the window server's front ordinary window as a second
witness of the application. `windows <pid>` reports what a background application
lists now. Two same-titled windows need no map from a reference to an id: focusing
A, B, A must read X, Y, X with X ≠ Y.

| Step | How | Expectation checked |
|---|---|---|
| Receipt shape | `__type(name: "DesktopFocusReceipt")` | its fields are exactly `ref` |
| Same title, from the background | TextEdit in front; focus A, B, A | each answer is `{ref}` equal to the submitted reference, no errors; the witness reads Finder with ids X, Y, X, X ≠ Y, one title |
| The other order | TextEdit in front again; focus B, A, B | Y, X, Y |
| Background application | Finder in front; focus TextEdit's document | TextEdit, the document's id |
| Minimised | ⌘M, Finder in front; the probe sees the document `minimized: true`; focus it | TextEdit, the same id, `minimized: false` |
| Another Space | ⌃⌘F (full screen, a Space of its own), ⌃← to the desktop Space; the probe sees focus elsewhere and TextEdit listing no such window here; focus it | either the receipt and the witness on that window, or one `failed` error; which one is printed |
| Closed | focus A, ⌘W, TextEdit in front; focus A; then focus B | `unavailable`; the witness reads the same application and window before and after; B still focuses as Y |
| Quit | Stickies' note focused once, `killall Stickies`, TextEdit in front; focus the note | `unavailable`, focus unmoved |
| Restarted | Stickies opened again (it restores a look-alike note), TextEdit in front; focus the old reference | `unavailable`, focus unmoved: the observable PID-reuse case |
| Cannot be re-established | a token this run never issued; an application reference; after Koine is quit and opened again, a window reference from before | each `unavailable`, focus unmoved; the new run lists the window under another reference, and that one focuses |
| Revoked consent | Koine's switch in System Settings and the password; focus until one reports it (60 s bound) | `permission` / `os-permission`, `accessibility`, `koine`, at `["desktopFocusWindow"]`, no receipt; focus unmoved across that call; the dialog's text is nowhere on screen |

Ambiguity, by the identity evidence, is an element that is not provably its own
window: such an element is never listed, so it has no reference to submit, and
every use of a held element repeats that check before acting. The cases a client
can present are the ones above, and the host suite holds those that need no
window (`DesktopProviderTests`, "Focus"): another provider's reference, another
run's session, the other resource kind, a malformed remainder, and a grant
without `desktop:control`, which is refused before the provider is asked.

## What the action does, and why

Re-resolve, check consent, confirm the held element is still its own window, and
act, in one turn on the provider's queue. The steps: restore if minimised, make
the window main, raise it, bring its application to the front, then wait, off the
queue and for at most three seconds, until the application reports itself
frontmost with that element as its focused window. Only then is the receipt
returned; any step's failure is `failed` and names the step.

**AppKit activation is closed to a background service.** A build that asked
`NSRunningApplication.activate(options: [])` got `false` for Finder in the VM; Koine reported `failed`, "The window was raised, but its application
refused the request to activate.", and the witness still read TextEdit's document
([desktop-focus/appkit-activation-refused.json](desktop-focus/appkit-activation-refused.json)):
the failure path of the contract, observed. `NSRunningApplication.h` deprecates
`activateIgnoringOtherApps` as having no effect from macOS 14, and
`activate(from:options:)` needs the active application to yield, which a resident
service never is. The provider sets the application element's `AXFrontmost`
instead, under the Accessibility consent the action already needs. The header
lists that attribute and does not say it can be set; the wait above is what makes
the receipt true regardless.

## Evidence

Run of 2026-09-20, macOS 26.5 (25F71) arm64 clone, bundle signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`; transcript
`.build/vm-verify/desktop-focus-20260920T031134.log`, with the screenshots
`…-other-space.png` and `…-after-revocation.png` beside it. **PASSED**, exit 0,
with no guest exec exhausted. The provider's sources and its sealed dylib, the
three scripts, the guest client, the probe's source and the design operations had
the same SHA-256 digests after the run as before it. Twenty focus requests, all
under the controller grant; every reading below is the probe's.

- `DesktopFocusReceipt` has the one field `ref`.
- Finder listed three windows, all `Recents`, under distinct references. From
  TextEdit in front (window 61, `focus-target.txt`): A → Finder 55, B → Finder 54,
  A → 55. Again from TextEdit: B → 54, A → 55, B → 54. Every answer was
  `{"desktopFocusWindow": {"ref": <the submitted reference>}}` with no errors.
- From Finder in front, TextEdit's document: TextEdit 61.
- Minimised: with Finder 54 in front the probe listed TextEdit's one window, 61,
  `minimized: true`; after the focus, TextEdit 61, `minimized: false`.
- Another Space: on the desktop Space, Finder 54 in front and TextEdit listing
  **no** windows; the focus returned its receipt, and the probe read TextEdit 61
  focused. macOS switched to the window's Space. The window server's front window
  there was 98, TextEdit's, not 61.
- Closed: A focused (55), ⌘W, TextEdit 61 in front. Focus A: `unavailable`, "The
  window is no longer open."; TextEdit 61 before and after. B then focused as 54.
- Stickies (pid 1176) note focused once (131). After `killall Stickies`, and
  again after Stickies was opened anew, the old reference: `unavailable`, "The
  window is no longer open."; TextEdit 61 before and after, both times.
- Token `999999`: `unavailable`, "The window is no longer open." Finder's
  application reference: `unavailable`, "The reference does not name a desktop
  window." After Koine was quit and opened again, B's reference from the earlier
  run (session `97250eb136005a8e`): `unavailable`; Koine's own window (154) in
  front before and after. The new run listed the windows under session
  `995b82e475a2dcee`, and its first reference focused Finder 54.
- Revoked: the first focus after the password was entered was already the error:
  `permission`, `os-permission`, `accessibility`, `koine` at
  `["desktopFocusWindow"]`, data null; System Settings 168 in front before and
  after; no dialog text on screen, `universalAccessAuthWarn` not running.

Another run on the same provider binary passed every step as well and is not
the evidence: its minimised step never saw the window minimised, so it could not
have failed. The two runs' readings otherwise agree step for step, with that
VM's own window numbers.

The desktop verification, which shares `scripts/vm-verify-desktop-lib.sh` with
this one and whose read path goes through the same re-resolution focus uses, was
run on the same build: `task app:vm-verify-desktop`,
transcript `.build/vm-verify/desktop-20260920T042411.log`, **PASSED**, exit 0, its
script, libraries, guest client and the provider's dylib unchanged across the run.

## Tooling notes

- The probe's first witness asked the system-wide element for
  `AXFocusedApplication`. From a command-line tool in this VM it answers
  `kAXErrorCannotComplete` (-25204) with an application plainly in front; the
  probe records that answer and does not use it.
- `open -a Finder` on a Finder with no window opens one, so two ⌘N give three
  same-titled windows. The script takes the first two.
- The window server's front ordinary window has the focused window's number on
  the desktop Space, and another (a full-screen backing window) on a full-screen
  Space. It is asserted by owning application, never by number.
- TestAnyware's false "Process timed out after 30s" comes in bursts: once, twelve
  tries running, on a focus whose output held Koine's receipt. `guest_json`
  (`scripts/vm-verify-desktop-lib.sh`) accepts a complete one-line JSON answer
  whatever status the agent reports; a truncated one does not parse and fails.
- `launch` (`scripts/vm-verify-lib.sh`) does not end the run on the status of
  its `open`: a burst can exhaust it at a relaunch with no assertion failed. The
  window and the endpoint descriptor it then waits for are the proof.
- A step that reads a state only *after* acting cannot fail. One run passed
  the minimised step without ever seeing the window minimised; the probe's
  `windows <pid>` exists so that the state is seen before the focus.

## What this does not show

`REMEMBERED` rows and selecting one are in
[desktop-remembered-windows-vm.md](desktop-remembered-windows-vm.md): here the
other-Space window was listed while it was on the current Space and focused by
that reference. The latency of a focus, and the supported matrix, are in
[latency-and-support-matrix.md](latency-and-support-matrix.md); this run is macOS 26.5 on arm64 alone.
