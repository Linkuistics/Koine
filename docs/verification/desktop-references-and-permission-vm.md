# Desktop references and Accessibility permission: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
`reference-lookups-and-accessibility-permission-k29`: the two by-reference
lookups, what makes a reference `unavailable`, and what a read does when Koine
lacks Accessibility consent. It is the second half of one scripted run, on the
Developer ID signed `Koine.app` with real applications; the first half, the
procedure's requirements and the consent route are in
[desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md).

## Procedure

```sh
task app                    # build and sign .build/app/Koine.app
task app:vm-verify-desktop  # scripts/vm-verify-desktop.sh
```

The guest client, `scripts/vm-verify-desktop-client.py`, passes a reference it was
given back unchanged (`--ref application|application-plain|window <reference>`);
`plain` selects the application fields without `windows`.

| Step | How | Expectation checked |
|---|---|---|
| Before consent: windows | Finder by identity, with `windows` | `desktopApplication` null; one error at `["desktopApplication","windows"]`: `permission`, `os-permission`, `osPermission` `accessibility`, `permissionOwner` `koine` |
| Before consent: fields that need none | Finder by identity, then by its reference, without `windows` | both resolve, no errors; by reference with `windows` is the same OS-permission error at `["desktopApplicationByReference","windows"]` |
| Before consent: capability | the same query with the `desktop:control` grant | `permission`, `capability`, `desktop:read`: the two classes in one run, with consent absent |
| No dialog | the screen is read (OCR) for the dialog's text, "would like to control", after those reads; a screenshot is kept | the text is nowhere on screen |
| Agreement | after consent: Finder by identity, by reference, and each window through `desktopWindow` | the application objects are equal, `windows` included; each `desktopWindow` equals its row |
| Wrong kind, malformed | a window reference to the application lookup and the reverse; an application reference with `/` appended; a window reference without its token; a token never issued | each one error, `unavailable`, at the field, data null |
| Closed window | `open -a Finder`, ⌘W, then every earlier window reference | exactly one is `unavailable`; the same-titled others resolve as themselves |
| Ended process | Stickies listed, then `killall Stickies` | its application reference and its window reference are `unavailable` |
| Koine restart | Quit, `open` again, the same grants | Finder's application reference resolves to the equal object; a window reference from before is `unavailable`; the new listing names no old reference |
| Revoked while running | Koine's switch in System Settings' Accessibility pane, the account password, then reads until one reports it (60 s bound) | the delay is printed; the listing and `desktopWindow` are the OS-permission error at their own paths; the application by reference still resolves; no dialog text on screen; screenshot |
| Control | Koine quit; `Fixtures/ConsentPromptControl`, which asks with the prompt option, opened with `open` | the same screen read finds the dialog's text; screenshot |

A reference naming another registered provider is not in this run, because the
signed bundle ships one provider: `DesktopProviderTests` loads the fixture
provider beside the desktop one and checks that `koine://fixture/item/1` reaches
both lookups and is `unavailable`. The same suite holds every case that needs no
window on the host.

### Revoking consent in a VM

As a user does (`revoke_accessibility` in `scripts/vm-verify-desktop.sh`): the
pane of the consent route, Koine's switch (`Koine_Toggle` in the accessibility
tree), and the account password macOS then asks for. The switch reads off as soon
as it is clicked, before that sheet is answered, so its value proves nothing. By
hand, with the sheet left unanswered, Koine listed windows for four more minutes;
once the password was entered its next read, 4 s later, was the OS-permission
error. The run therefore takes Koine's reads as the proof of revocation and
prints how long the first one took.

**macOS reports a revocation made this way to the running Koine promptly**:
`AXIsProcessTrusted` answers false on the next read, with no restart.

**`tccutil reset Accessibility dev.antony.Koine` does not.** An earlier run of
this script revoked that way. The command reported `Successfully reset
Accessibility approval status for dev.antony.Koine`, and for the 60 s the run
allowed, every read by the running Koine still listed Finder's windows
(`.build/vm-verify/desktop-20260920T000543.log`). That is recorded as found, not
worked around: the reset is not the route a user takes, and what it does to a
process already trusted is macOS's to define. What it means for Koine is only
that consent a running Koine holds ends when macOS says so, which the provider
asks on every read.

### The dialog detector and its control

The dialog is looked for as a user would see it: `testanyware screen find-text`
reads the screen for "would like to control", the sentence the dialog carries. A
detector that has never fired proves nothing, so the run ends by opening
`Fixtures/ConsentPromptControl`, a signed application that makes the one call
Koine never makes, `AXIsProcessTrustedWithOptions` with
`kAXTrustedCheckOptionPrompt`. The same screen read then finds the text and the
screenshot shows the dialog. A command-line tool would not do: started by
`testanyware file exec` it is trusted through the agent and is never asked.

**The process that shows the dialog is not a detector.** The dialog belongs to
`universalAccessAuthWarn`, and this script first looked for that process. Its
first two runs failed there: after Koine's plain `AXIsProcessTrusted()` came back
false the process was running, with nothing on screen (the failure screenshots,
and an accessibility snapshot of the kept VM, show no dialog). In a clone where
nothing had asked about trust it was not running. So it started here for an
untrusted application that asked without the prompt option, and showed nothing;
presumably it is what lists Koine, switched off, in the Accessibility pane, which
is inferred, not observed. With the control it also runs, which is why the control alone
did not expose the mistake: it was the reading of Koine that was dirty. Each
no-dialog check now records whether the process runs, and asserts nothing of it.

## What this does and does not show

It shows, through loopback GraphQL on the signed build, that every route to an
application or a window reports the same references and fields; that no stale,
wrong-kind or malformed reference is null without an error or resolves a
substitute, same-titled windows included; what a Koine restart does to each kind
of reference; and that absent and revoked consent are OS-permission errors at
the original path, distinguishable from a missing capability, with no dialog.

It does not show PID reuse, which cannot be forced (a live PID at another start
instant stands for it, in `DesktopProviderTests`), nor an ambiguous native
identity, which no real application could be made to produce on demand: the
own-window check that decides it is exercised on every lookup, and its evidence
is [desktop-window-identity.md](desktop-window-identity.md). Focusing is
`focus-exact-window`'s.

## Evidence

Run of 2026-09-20, macOS 26.5 (25F71) arm64 clone, bundle signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`; transcript
`.build/vm-verify/desktop-20260920T011741.log`, with the screenshots
`…-before-consent.png`, `…-after-revocation.png` and `…-control-dialog.png`
beside it. **PASSED.** The scripts, the guest client, the control's source and the
provider's dylib had the same SHA-1 digests after the run as before it.

- Before consent, Finder (`pid` 357, `startedAt` `2026-09-19T15:17:49.783937Z`):
  `"desktopApplication": null`, one error at `["desktopApplication","windows"]`
  with `kind` `permission`, `permissionClass` `os-permission`, `osPermission`
  `accessibility`, `permissionOwner` `koine`. Without `windows`, by identity and
  by `koine://desktop/application/357/1789831069783937`: `Finder`,
  `com.apple.finder`, no errors. By reference with `windows`: the same error at
  `["desktopApplicationByReference","windows"]`. The `desktop:control` grant:
  `permission`, `capability`, `requiredCapability` `desktop:read`, at
  `["desktopApplication"]`. No dialog text on screen after either;
  `universalAccessAuthWarn` was running both times.
- Agreement: the application by reference equalled the application by identity,
  three `Recents` windows included, and `desktopWindow` for
  `…/a772cb02b2c84818/1`, `/2` and `/3` equalled its row each time.
- A window reference given to the application lookup, and `…/1789831069783937/`:
  `unavailable`, "The reference does not name a desktop application." The
  application reference given to `desktopWindow`, and a window reference without
  its token: `unavailable`, "The reference does not name a desktop window." Token
  `999999`: `unavailable`, "The window is no longer open." Each with data null
  and one error at the field.
- After ⌘W in Finder: `…/1` `unavailable`; `…/2` and `…/3`, both still titled
  `Recents`, resolved as themselves.
- Stickies listed two windows; after `killall Stickies` its application
  reference was `unavailable`, "The application is no longer running.", and its
  window reference `unavailable`.
- After Quit and relaunch of Koine: Finder's application reference resolved to the
  equal object; `…/a772cb02b2c84818/2` was `unavailable`; the new listing named
  the same two windows `…/b033a7e70e25009b/1` and `/2`.
- Revocation by the switch and password: the **first** read afterwards was already
  the OS-permission error, at `["desktopApplication","windows"]`. The transcript's
  "completed 61s after the password was entered" is that one read's guest exec,
  which the TestAnyware agent twice reported as timed out after 30 s before
  answering; by hand the same read took 4 s. `desktopWindow` for a live window:
  the same error at `["desktopWindow"]`. The application by reference: resolved.
  No dialog text on screen.
- Control: the screen read found `"ConsentPromptControl" would like to control
  this` at confidence 1.0.

`task test` passed beforehand with this leaf's provider: 107 tests in the server
suites, among them the eleven `unavailable` cases that need no window and the
reference naming another provider.

Eight earlier runs of this task did not pass, and none of them on Koine's
behaviour. Two were the process detector above. One was a function this leaf's
own edit had deleted from the script. One revoked with `tccutil`, above. Four
ended on TestAnyware transients: a guest exec reported timed out six times
running (twice), and `CONNECTION_TIMEOUT`, exit 7, from a key press and from a
guest exec. `guest` in `scripts/vm-verify-lib.sh` now tries twelve times and also
retries exit 7, since every command it is given is safe to repeat; a key press is
not, and is not retried.

With this leaf's changes in place, the shared helper included: `task
app:vm-verify` PASSED (`.build/vm-verify/20260920T013307.log`) and `task
app:vm-verify-providers` PASSED (`.build/vm-verify/providers-20260920T013517.log`).
`task compat` was not run again: nothing in the package's `Sources/` changed, the provider
contract included.
