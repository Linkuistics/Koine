# Platform acceptance on the release artifact

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, and its
closing instruction to *"verify the signed release build's entitlement and
permission behavior rather than extrapolating from an unsigned development
run"*. Every case here also passes on a **development-signed** bundle, in a clean
VM of its own. This run shows that they hold on the **notarized, stapled,
quarantined** artifact, in **one** session, composed rather than
sliced — so the failure it exists to catch is *the release path changed
something*: a different quarantine state, a stapled ticket, a provider loaded
from a quarantined bundle, a permission attributed to a different identity.

It is not a second copy of the six runs it composes. Where a case is unchanged
and already established, the table below cites the document that establishes it
and says whether this run **supersedes** it on the release build or merely
**repeats** it there.

## Procedure

```sh
task app                     # build and sign .build/app/Koine.app on the host
task app:notarize            # submit, wait, staple, and zip the release artifact
task app:verify              # signature, version, staple, and Gatekeeper's verdict
task app:vm-verify-release   # scripts/vm-verify-release.sh
```

The clean clone, the transcript (`.build/vm-verify/release-<timestamp>.log`),
`KOINE_VM_KEEP=1` and the TestAnyware workarounds are those of
[resident-app-vm.md](resident-app-vm.md). Nothing runs the application on the
host. The Gatekeeper-enforcing clone, the explicit quarantine attribute and the
first-run dialog are [notarized-release-vm.md](notarized-release-vm.md)'s
procedure, in `scripts/vm-verify-gatekeeper-lib.sh`, which the two routes share; the guest is started at `1920x2160` for the same reason.

**The order of this run is forced, and that is why it is one script.** Consent
absent must be read before consent is given. The second request *in a later run
of Koine* needs consent absent again, so it follows revocation and a restart of
Koine. And the VM restart that proves login launch destroys the desktop state
every other case needs, so it is last.

| Step | How | Expectation checked | Other document |
|---|---|---|---|
| Entitlements and hardened runtime | `codesign -d --entitlements - --xml` and `codesign -dvv`, **in the guest, on the installed copy** | the entitlement dictionary is empty, and the flags word is exactly `flags=0x10000(runtime)` — for the application *and* every provider in its `Contents/PlugIns`, of which there must be at least the bundled desktop and workspace | only here: no other run reads these from a release build |
| First launch | plain `open` of the quarantined copy, and the dialog's **Open** | a first-run dialog appeared and is not a refusal; the attribute survives the launch | **repeats** [notarized-release-vm.md](notarized-release-vm.md), which owns the discrimination between the notarized dialog and the two refusals |
| Consent absent | `desktopApplication` with `desktop:read`; the same with a grant that has only `desktop:control`; `koineManagement.osPermissions` | an `os-permission` error at `["desktopApplication","windows"]`, the application's consent-free fields still resolving, a **capability** refusal naming `desktop:read` for the other grant, `granted: false`, and no dialog on screen | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) and [accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md) on the release build |
| Prompt attribution | the window's Request Accessibility Access, read from the screen | macOS's dialog names **Koine** | **repeats** [notarized-release-vm.md](notarized-release-vm.md) |
| A **second** request, same run of Koine | the same control again | whatever macOS does is **recorded**, not asserted | **closes** the item [accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md) does not show |
| Settings attribution | the dialog's route to System Settings; the entry read; consent then given by the list's **Add** control | Koine is listed, switched **off**, and consent is given there with no restart of Koine | **supersedes** [accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md) on the release build |
| Duplicate titles | two Finder windows, listed twice | same title, distinct references, and the second listing returns the same references | **supersedes** [desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md) on the release build |
| PID reuse, as far as it is observable | the live PID at another `startedAt`; an absent PID; a malformed instant | ordinary `null` with **no error** for the first two, an input error for the third | **supersedes** [desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md) |
| Window closure | ⌘W, with `WindowIdentityProbe` reading the system **before** Koine is asked | the system has one window fewer, exactly one reference is `unavailable`, its same-titled siblings still resolve, and Koine's listing loses exactly one row | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) |
| Settings window closed | `agent window-close`, then a window opened with no settings window | the listener answers `200`, the system's count returns to the baseline, and Koine serves the new window under a reference it had not issued before | **supersedes** [resident-app-vm.md](resident-app-vm.md) and the observation half of [desktop-remembered-windows-vm.md](desktop-remembered-windows-vm.md) |
| Koine restart | quit and relaunch | the **application** reference resolves to the same application, field for field; the **window** reference is `unavailable`; the open windows are listed under the new run's own references | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) |
| Consent revoked | Koine's switch in System Settings, while Koine runs — driven until the switch itself reports the change | an `os-permission` error at `["desktopApplication","windows"]` and at `["desktopWindow"]`; the consent-free fields still resolving; a missing capability still reported as the capability class; no dialog | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) |
| A request in a **later** run of Koine | quit, relaunch, request again | recorded, not asserted | **closes** the second half of the same item |
| Login launch | the window's toggle, Koine **quit**, then a VM restart | Koine is running after login with nothing having launched it and no client installed; the stapled ticket and the quarantine attribute survive; the grant made before the restart is still reported; an unauthenticated request is `401` | **supersedes** [resident-app-vm.md](resident-app-vm.md) on the release build |

## How a green run is kept from being empty

Four things in this run exist only because a passing run without them would
prove nothing.

- **The witness reads the system before the action, never only after.** A step
  that reads a state only after acting cannot fail; a minimised step can pass
  without the window ever being minimised
  ([desktop-focus-vm.md](desktop-focus-vm.md)). Here `WindowIdentityProbe` —
  not Koine — establishes that Finder has two same-titled windows **before**
  Koine is asked anything, so the OS-permission refusal that follows is a
  refusal about windows that demonstrably exist, and it establishes the window
  is gone before anything is concluded from Koine reporting it `unavailable`.
- **Two enumerations that need not agree are compared by their change.** Koine's
  window list and the probe's need not match row for row, so nothing here equates
  them. Each side's **baseline** is recorded and every later claim is a change
  against it: one window closes, and each side loses exactly one.
- **The repeat consent request is recorded, not asserted.** The question is
  *whether macOS shows the dialog again*. An assertion either way
  would assert the question. What **is** asserted for every request is that Koine
  offers the control and that any dialog that appears names Koine.
- **A switch is driven until the switch says it moved.** The shared library types
  the administrator password a fixed two seconds after clicking Koine's switch
  and reads nothing back, so a revocation can silently not happen, and the run
  then fails downstream with *"windows were still listed 60s after consent was
  revoked"* — a sentence that reads like a finding against Koine and is not one.
  This run tries each way of pressing the control, prints which one worked,
  answers whatever macOS puts in front of the change, and asserts the control's
  own value afterwards.

### The switch's direction depends on how consent was given

With consent given **by the switch** in the Accessibility pane, the same switch could
not afterwards be turned **off**: at identical coordinates on the identical
36×16 `AXCheckBox`, neither `testanyware agent press` (HTTP 400, as it answers
for every SwiftUI control here) nor a VNC click at its centre moved it, and
nothing appeared on screen — where the *on* direction had raised the "Modify
Settings" sheet from the same click. With consent given **by the list's Add
control**, which is how [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md)
and [desktop-focus-vm.md](desktop-focus-vm.md) give it, the click on the switch
raised that sheet and the switch went off. So the two routes into the entry are
not interchangeable, and a run that revokes should grant by Add.

## What this does not show

- **It is one OS build on one architecture.** macOS 26.5 on arm64, which is the
  supported matrix; latency is measured in [latency-and-support-matrix.md](latency-and-support-matrix.md), not here.
- **PID reuse cannot be forced.** What is observable is the other half of the
  identity — a live PID claimed at a start instant that is not its own — and that
  is what is checked. A genuinely reused PID was not produced, here or anywhere
  else in this repository.
- **Focus is not exercised.** `desktopFocusWindow` is
  [desktop-focus-vm.md](desktop-focus-vm.md)'s, and the controlling grant made
  here exists to be the grant **without** `desktop:read`, not to focus anything.
- **Spaces and `REMEMBERED` rows are not exercised.**
  [desktop-remembered-windows-vm.md](desktop-remembered-windows-vm.md) owns them;
  what this run takes from that document is the settings window closed with the
  provider still serving.
- **The grant workflows are not exercised here.** Grants are made in the window
  because the desktop cases need credentials; both workflows end to end on the
  release build are [grant-workflow-acceptance-vm.md](grant-workflow-acceptance-vm.md)'s.
- **No per-user provider is installed.** The quarantined-plugin rule is the spec's
  ([loading and trust](../specs/machine.md#loading-and-trust)), verified in
  [notarized-release-vm.md](notarized-release-vm.md) and
  [provider-quarantine-precheck-vm.md](provider-quarantine-precheck-vm.md); this run loads only the providers sealed in
  the bundle, which the application's own ticket covers.
- **Login-item approval is not observed**, as in
  [resident-app-vm.md](resident-app-vm.md): registration goes straight to
  `enabled`, and `requiresApproval` has not been seen in any run.

## Evidence

Run of 2026-10-17, transcript `release-20261017T130017.log`, against the
**notarized, stapled 0.3.0** bundle (tag `v0.3.0`), signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)` and notarized as
submission `a216930f-6424-4106-a4fb-31659ba17d9c`. Host: Mac16,5 on macOS 27.0.1
(26A434), testanyware 2.1.0, tart 2.40.1. VM: clone of
`testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64, guest display
1920×2160. Result: **passed**, every expectation in the table above. Koine is a
menu bar application in this run, so the settings window is the one the launch
rule opens while Accessibility is not granted, and the run drives every request
through it.

```
== Start a clean VM (koine-verify-54110)
Setting guest display resolution to 1920x2160 px...
  set-display-mode: switched main display to 1920x2160 pt @ 1x (1920x2160 px, modeID 11)
ProductName:		macOS
ProductVersion:		26.5
BuildVersion:		25F71
arm64
Gatekeeper: assessments disabled

== Put the clone into a Gatekeeper-enforcing state
Before: assessments disabled;
After:  assessments enabled;developer id disabled;
The clone is App Store-only; setting the default posture in System Settings.
  attempt 1: the menu did not open in front; retrying
After System Settings: assessments enabled;developer id enabled;

== Install the notarized bundle and quarantine it, as a download arrives
Quarantine on the bundle: 0181;6ad2d6e6;Safari;4102550B-9524-4E56-A755-9F03D10B53EF
Quarantined files inside it: 37
Processing: /Applications/Koine.app
The validate action worked!

== The release artifact's hardened runtime and empty entitlements, read from the installed copy in the guest
Entitlements: {}
/Applications/Koine.app: flags=0x10000(runtime)
/Applications/Koine.app/Contents/PlugIns/Desktop.koineprovider: flags=0x10000(runtime)
/Applications/Koine.app/Contents/PlugIns/Workspace.koineprovider: flags=0x10000(runtime)

== First launch of the quarantined copy: plain open, no right-click-Open
  “Koine” is an app downloaded from the Internet. Are you sure you want to open it?
  Safari downloaded this file today at 2:01 AM. Apple checked it for malicious software and none was detected.
  Photos will appear here when they are finished processing
  Sydney
  Chance of light rain in the next hour
  Now
  60m
Koine pid: 931

== Nothing was stripped: the attribute is still on the launched bundle
Quarantine before launch: 0181;6ad2d6e6;Safari;4102550B-9524-4E56-A755-9F03D10B53EF
Quarantine after launch:  01c1;6ad2d6e6;Safari;4102550B-9524-4E56-A755-9F03D10B53EF
Koine pid: 931

== Two grants in the window: one that reads the desktop, one that does not
grant-label at y=411.0 moved to y=311.0 under --dy -10; towards the end is --dy -10
-rw-------  1 admin  staff  43 Oct 17 02:11 /Users/admin/koine-credential
-rw-------  1 admin  staff  43 Oct 17 02:13 /Users/admin/koine-credential-controller

== Real windows: two Finder windows with the same title, seen natively before Koine is asked anything
{"pid":388,"trusted":true,"windows":[{"axError":0,"axIdentifier":"FinderWindow","isItsOwnWindow":true,"minimized":false,"privateError":0,"privateWindo …
The system says Finder has 3 windows, all titled "Recents".

== Consent absent: windows are an os-permission error at the original path, and nothing prompts
osPermissions: [{"permission":"accessibility","owner":"koine","granted":false}]
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": null}, "errors": [{"message": "K …
no consent dialog on screen (after a windows read without consent); universalAccessAuthWarn: running

== Consent absent: the application fields that need none still resolve
{"case": "plain", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": {"ref": "koine://desktop/applica …

== Consent absent: a grant without desktop:read gets the capability class, not the OS one
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": null}, "errors": [{"message": "T …
no consent dialog on screen (after every read without consent); universalAccessAuthWarn: running

== The window's request: macOS shows its dialog, naming Koine
["\"Koine\" would like to control this computer using"]
Observation: the request (the first request of this run of Koine) showed macOS's consent dialog, naming Koine.
Shown by: 944 universalAccess

== A SECOND request in the same run of Koine: whatever macOS does is recorded
["\"Koine\" would like to control this computer using"]
Observation: the request (a second request in the same run of Koine) showed macOS's consent dialog, naming Koine.

== System Settings lists Koine, switched off; consent is then given there
Koine's switch element: {"actions":["AXPress","AXPress","AXShowMenu"],"childCount":0,"children":[],"description":"switch","enabled":true,"focused":fal …
Observation: osPermissions reported granted: true within 60s.

== Same-titled windows under distinct references, stable across two listings
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": {"ref": "koine://desktop/applica …
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": {"ref": "koine://desktop/applica …
Koine lists 3 windows where the system says 3.

== PID reuse as far as it can be observed: the same live PID at another start instant is another process
{"case": "later", "pid": 388, "startedAt": "2026-10-17T02:00:28.461317Z", "response": {"data": {"desktopApplication": null}}}
{"case": "absent", "pid": 1000000, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": null}}}
{"case": "malformed", "pid": 388, "startedAt": "2026-10-17T02:00:28Z", "response": {"data": {"desktopApplication": null}, "errors": [{"message": "proc …

== A closed window is unavailable; the same-titled windows beside it still resolve
{"case": "window", "ref": "koine://desktop/window/388/1792202428461316/b687a3294babc2ca/1", "response": {"data": {"desktopWindow": {"ref": "koine://de …
{"pid":388,"trusted":true,"windows":[{"axError":0,"axIdentifier":"FinderWindow","isItsOwnWindow":true,"minimized":false,"privateError":0,"privateWindo …
{"case": "window", "ref": "koine://desktop/window/388/1792202428461316/b687a3294babc2ca/1", "response": {"data": {"desktopWindow": null}, "errors": [{ …
{"case": "window", "ref": "koine://desktop/window/388/1792202428461316/b687a3294babc2ca/2", "response": {"data": {"desktopWindow": {"ref": "koine://de …
{"case": "window", "ref": "koine://desktop/window/388/1792202428461316/b687a3294babc2ca/3", "response": {"data": {"desktopWindow": {"ref": "koine://de …
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": {"ref": "koine://desktop/applica …

== The settings window closed: the listener answers and the desktop provider still serves
{"data":{"koine":{"contractVersion":"koine-desktop\/1","ownGrant":{"clientLabel":"vm-release-reader","capabilities":["desktop:read","koine:manage"],"state":"ACTIVE"}}}}
HTTP 200
{"pid":388,"trusted":true,"windows":[{"axError":0,"axIdentifier":"FinderWindow","isItsOwnWindow":true,"minimized":false,"privateError":0,"privateWindo …
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": {"ref": "koine://desktop/applica …

== Across a Koine restart: an application reference resolves again, a window reference does not
{"case": "application-plain", "ref": "koine://desktop/application/388/1792202428461316", "response": {"data": {"desktopApplicationByReference": {"ref" …
{"case": "application-plain", "ref": "koine://desktop/application/388/1792202428461316", "response": {"data": {"desktopApplicationByReference": {"ref" …
{"case": "window", "ref": "koine://desktop/window/388/1792202428461316/b687a3294babc2ca/4", "response": {"data": {"desktopWindow": null}, "errors": [{ …
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": {"ref": "koine://desktop/applica …

== Consent revoked while Koine runs: an os-permission error at the original path, and nothing prompts
No matching processes belonging to you were found
Koine's switch element: {"actions":["AXPress","AXPress","AXShowMenu"],"childCount":0,"children":[],"description":"switch","enabled":true,"focused":fal …
Route: agent press on the switch
  error: HTTP 400 Bad Request: 
    → run `testanyware llm-instructions` for the full usage guide
Buttons on screen after turning Koine's Accessibility switch off (press): ["Search","Add","Remove","Back","Revoke","Revoke","Create Grant","back","for …
Nothing stood in front of the change.
Route: VNC click at the switch's centre
Buttons on screen after turning Koine's Accessibility switch off (click): ["Search","Add","Remove","Back","Modify Settings","Cancel","Revoke","Revoke" …
An administrator authentication sheet is up; answering it.
Observation: the switch moved to 0 by click.
Observation: consent was revoked by Koine's switch in the Accessibility pane.
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": null}, "errors": [{"message": "K …
Observation: the first read to report revoked consent completed 30s after the password was entered.
{"case": "window", "ref": "koine://desktop/window/388/1792202428461316/eba3eb62a77c8517/1", "response": {"data": {"desktopWindow": null}, "errors": [{ …
{"case": "application-plain", "ref": "koine://desktop/application/388/1792202428461316", "response": {"data": {"desktopApplicationByReference": {"ref" …
{"case": "exact", "pid": 388, "startedAt": "2026-10-17T02:00:28.461316Z", "response": {"data": {"desktopApplication": null}, "errors": [{"message": "T …
no consent dialog on screen (after reads with consent revoked); universalAccessAuthWarn: running
Observation: osPermissions reported granted: false within 0s.

== A request in a LATER run of Koine: whatever macOS does is recorded
["\"Koine\" would like to control this computer using"]
Observation: the request (the first request of a later run of Koine, after consent was given and removed) showed macOS's consent dialog, naming Koine.
Observation, the open question closed: with Koine already listed in System Settings, a repeat request showed a dialog: yes in the same run of Koine, yes in a later one.

== Login launch: enable it in the window, quit Koine, and restart the VM with no client installed
Before: Koine is not registered to start at login. Clients find the service unavailable until you open Koine.

== After login, with nothing having launched Koine and no client installed
503 /Applications/Koine.app/Contents/MacOS/Koine
{"contractVersion":"koine-desktop\/1","descriptorVersion":1,"instanceId":"8c04975f-e94c-4f5b-9653-ba2d308bc018","path":"\/graphql","pid":503,"port":49152}
Processing: /Applications/Koine.app
The validate action worked!
Quarantine after the restart: 01c1;6ad2d6e6;Safari;4102550B-9524-4E56-A755-9F03D10B53EF
{"data":{"koine":{"contractVersion":"koine-desktop\/1","ownGrant":{"clientLabel":"vm-release-reader","capabilities":["desktop:read","koine:manage"],"state":"ACTIVE"}}}}
HTTP 200
Listener without a credential: HTTP 401

== Quit Koine

== PASSED — transcript in .build/vm-verify/release-20261017T130017.log
```

**macOS shows its consent dialog again.** It showed it, naming Koine, on all
three requests: the first of a run, a second in the same run of Koine, and the
first of a later run made after consent had been given and taken away.
`accessibility-status-and-consent-vm.md` does not show that; it is verified here,
on the release build.

**References, before and after the Koine restart.** The application reference
`koine://desktop/application/388/1792202428461316` resolved to the same
application, field for field, in both runs of Koine. Its windows were listed
under `…/b687a3294babc2ca/{1,2,3}` in the first run and `…/eba3eb62a77c8517/{1,…}`
in the second, and a window reference from the first was `unavailable` in the
second. The application reference is the process; the window reference is the
run's.

**"Within 0s" is not latency.** It means the first read after the action
already reported the change. In this run `osPermissions` reported the revocation
in 0s, while the first windows read to report it completed 30s after the
password was entered; the transcript does not separate Koine's answer time from
the TestAnyware agent's, and a read through the agent can take far longer than
Koine does: a guest exec that runs to completion and is then reported as
"Process timed out after 30s" costs a real thirty seconds. The check allows 60s.
Latency is measured with an instrument built for it, in
[latency-and-support-matrix.md](latency-and-support-matrix.md).

**Every bundled provider is hardened.** The step reads every provider in the
installed bundle's `Contents/PlugIns`, not the desktop provider alone, and this
run passed it:

```
Entitlements: {}
/Applications/Koine.app: flags=0x10000(runtime)
/Applications/Koine.app/Contents/PlugIns/Desktop.koineprovider: flags=0x10000(runtime)
/Applications/Koine.app/Contents/PlugIns/Workspace.koineprovider: flags=0x10000(runtime)
```

**The consent dialog is awaited, not read once.** macOS draws its dialog some
seconds after the request, so the check reads the screen until the dialog shows
or about eighteen seconds pass. A single read three seconds after the click once
reported "no dialog" while the capture taken immediately afterwards showed it.

No behaviour of the release build differed from the spec in this run.

## Tooling note

The Gatekeeper-enforcing clone, the explicit quarantine attribute, the first-run
dialog read as accessibility text and the wait that dismisses a provider refusal
live in `scripts/vm-verify-gatekeeper-lib.sh`, which the two release-artifact
routes, `scripts/vm-verify-notarized.sh` and `scripts/vm-verify-release.sh`,
share. `scripts/vm-verify-release.sh` keeps three things of its own rather than
in the shared libraries, which four other routes use: a retry-tolerant `ask`,
the switch-driving helpers described above, and the `AXWindow` filter that keeps
Finder's desktop out of the probe's window count.
