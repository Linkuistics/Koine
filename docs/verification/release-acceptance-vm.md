# Platform acceptance on the release artifact

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, and its
closing instruction to *"verify the signed release build's entitlement and
permission behavior rather than extrapolating from an unsigned development
run"*. Every case here has passed before, on a **development-signed** bundle, in
a clean VM of its own. What this run adds is that they hold on the **notarized,
stapled, quarantined** artifact, in **one** session, composed rather than
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
procedure, now in `scripts/vm-verify-gatekeeper-lib.sh` so that the two routes
share one copy of it; the guest is started at `1920x2160` for the same reason.

**The order of this run is forced, and that is why it is one script.** Consent
absent must be read before consent is given. The second request *in a later run
of Koine* needs consent absent again, so it follows revocation and a restart of
Koine. And the VM restart that proves login launch destroys the desktop state
every other case needs, so it is last.

| Step | How | Expectation checked | Earlier document |
|---|---|---|---|
| Entitlements and hardened runtime | `codesign -d --entitlements - --xml` and `codesign -dvv`, **in the guest, on the installed copy** | the entitlement dictionary is empty, and the flags word is exactly `flags=0x10000(runtime)` — for the application *and* its bundled provider | new: no earlier run read these from a release build |
| First launch | plain `open` of the quarantined copy, and the dialog's **Open** | a first-run dialog appeared and is not a refusal; the attribute survives the launch | **repeats** [notarized-release-vm.md](notarized-release-vm.md), which owns the discrimination between the notarized dialog and the two refusals |
| Consent absent | `desktopApplication` with `desktop:read`; the same with a grant that has only `desktop:control`; `koineManagement.osPermissions` | an `os-permission` error at `["desktopApplication","windows"]`, the application's consent-free fields still resolving, a **capability** refusal naming `desktop:read` for the other grant, `granted: false`, and no dialog on screen | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) and [accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md) on the release build |
| Prompt attribution | the window's Request Accessibility Access, read from the screen | macOS's dialog names **Koine** | **repeats** [notarized-release-vm.md](notarized-release-vm.md) |
| A **second** request, same run of Koine | the same control again | whatever macOS does is **recorded**, not asserted | **closes** the item [accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md) left open |
| Settings attribution | the dialog's route to System Settings; the entry read; consent then given by the list's **Add** control | Koine is listed, switched **off**, and consent is given there with no restart of Koine | **supersedes** [accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md) on the release build |
| Duplicate titles | two Finder windows, listed twice | same title, distinct references, and the second listing returns the same references | **supersedes** [desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md) on the release build |
| PID reuse, as far as it is observable | the live PID at another `startedAt`; an absent PID; a malformed instant | ordinary `null` with **no error** for the first two, an input error for the third | **supersedes** [desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md) |
| Window closure | ⌘W, with `WindowIdentityProbe` reading the system **before** Koine is asked | the system has one window fewer, exactly one reference is `unavailable`, its same-titled siblings still resolve, and Koine's listing loses exactly one row | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) |
| Management window closed | `agent window-close`, then a window opened with no management window | the listener answers `200`, the system's count returns to the baseline, and Koine serves the new window under a reference it had not issued before | **supersedes** [resident-app-vm.md](resident-app-vm.md) and the observation half of [desktop-remembered-windows-vm.md](desktop-remembered-windows-vm.md) |
| Koine restart | quit and relaunch | the **application** reference resolves to the same application, field for field; the **window** reference is `unavailable`; the open windows are listed under the new run's own references | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) |
| Consent revoked | Koine's switch in System Settings, while Koine runs — driven until the switch itself reports the change | an `os-permission` error at `["desktopApplication","windows"]` and at `["desktopWindow"]`; the consent-free fields still resolving; a missing capability still reported as the capability class; no dialog | **supersedes** [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md) |
| A request in a **later** run of Koine | quit, relaunch, request again | recorded, not asserted | **closes** the second half of the same open item |
| Login launch | the window's toggle, Koine **quit**, then a VM restart | Koine is running after login with nothing having launched it and no client installed; the stapled ticket and the quarantine attribute survive; the grant made before the restart is still reported; an unauthenticated request is `401` | **supersedes** [resident-app-vm.md](resident-app-vm.md) on the release build |

## How a green run is kept from being empty

Three things in this run exist only because a passing run without them would
have proved nothing, and each was learned from a run that did exactly that.

- **The witness reads the system before the action, never only after.** A step
  that reads a state only after acting cannot fail; an earlier run passed a
  minimised step without ever seeing the window minimised
  ([desktop-focus-vm.md](desktop-focus-vm.md)). Here `WindowIdentityProbe` —
  not Koine — establishes that Finder has two same-titled windows **before**
  Koine is asked anything, so the OS-permission refusal that follows is a
  refusal about windows that demonstrably exist, and it establishes the window
  is gone before anything is concluded from Koine reporting it `unavailable`.
- **Two enumerations that need not agree are compared by their change.** Koine's
  window list and the probe's need not match row for row, so nothing here equates
  them. Each side's **baseline** is recorded and every later claim is a change
  against it: one window closes, and each side loses exactly one.
- **The repeat consent request is recorded, not asserted.** The open item is
  *"whether macOS shows the dialog again is unverified"*. An assertion either way
  would assert the question. What **is** asserted for every request is that Koine
  offers the control and that any dialog that appears names Koine.
- **A switch is driven until the switch says it moved.** The shared library types
  the administrator password a fixed two seconds after clicking Koine's switch
  and reads nothing back. Three runs of this script died downstream of a
  revocation that never happened, reporting *"windows were still listed 60s after
  consent was revoked"* — a sentence that reads like a finding against Koine and
  was not one. This run tries each way of pressing the control, prints which one
  worked, answers whatever macOS put in front of the change, and asserts the
  control's own value afterwards.

### The switch's direction depends on how consent was given

Worth carrying to the leaves that follow, because it cost three runs. With
consent given **by the switch** in the Accessibility pane, the same switch could
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

- **It is one OS build on one architecture.** macOS 26.5 on arm64; the supported
  matrix is `support-matrix-and-latency-k44`'s, and no latency is measured here.
- **PID reuse cannot be forced.** What is observable is the other half of the
  identity — a live PID claimed at a start instant that is not its own — and that
  is what is checked. A genuinely reused PID was not produced, here or anywhere
  else in this repository.
- **Focus is not exercised.** `desktopFocusWindow` is
  [desktop-focus-vm.md](desktop-focus-vm.md)'s, and the controlling grant made
  here exists to be the grant **without** `desktop:read`, not to focus anything.
- **Spaces and `REMEMBERED` rows are not exercised.**
  [desktop-remembered-windows-vm.md](desktop-remembered-windows-vm.md) owns them;
  what this run takes from that document is the management window closed with the
  provider still serving.
- **The grant workflows are not exercised here.** Grants are made in the window
  because the desktop cases need credentials; both workflows end to end on the
  release build are `grant-workflow-acceptance-k43`'s.
- **No per-user provider is installed.** The quarantined-plugin rule is
  [notarized-release-vm.md](notarized-release-vm.md)'s and
  `provider-quarantine-rule-k47`'s; this run loads only the provider sealed in
  the bundle, which the application's own ticket covers.
- **Login-item approval was not observed**, as in
  [resident-app-vm.md](resident-app-vm.md): registration goes straight to
  `enabled`, and `requiresApproval` has still not been seen.

## Evidence

Run of 2026-09-21, transcript `release-20260921T002221.log`, against the
**notarized, stapled 0.1.0** bundle built from the working copy at `85d5fd6`,
signed `Developer ID Application: Antony Blakey (TA43A4RUP3)`. The nine files
the run reads — the script, the three libraries it sources, the two guest
clients, the probe's source, the published operations and Koine's own executable
— were digested before and after and did not change. VM: clone of
`testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64, guest display
1920×2160. Result: **passed**, every expectation in the table above.

```
== Put the clone into a Gatekeeper-enforcing state
Before: assessments disabled;
After:  assessments enabled;developer id disabled;
The clone is App Store-only; setting the default posture in System Settings.
After System Settings: assessments enabled;developer id enabled;

== The release artifact's hardened runtime and empty entitlements, read from the installed copy in the guest
Entitlements: {}
/Applications/Koine.app: flags=0x10000(runtime)
/Applications/Koine.app/Contents/PlugIns/Desktop.koineprovider: flags=0x10000(runtime)

== First launch of the quarantined copy: plain open, no right-click-Open
  "Koine" is an app downloaded from the Internet. Are you sure you want to open it?
  Safari downloaded this file today at 2:24 PM. Apple checked it for malicious software and none was detected.

== Nothing was stripped: the attribute is still on the launched bundle
Quarantine before launch: 0181;6aafec86;Safari;36D4BB18-5070-4180-8137-BF391557770C
Quarantine after launch:  01c1;6aafec86;Safari;36D4BB18-5070-4180-8137-BF391557770C

== Real windows: two Finder windows with the same title, seen natively before Koine is asked anything
The system says Finder has 3 windows, all titled "Recents".

== Consent absent: windows are an os-permission error at the original path, and nothing prompts
osPermissions: [{"permission":"accessibility","owner":"koine","granted":false}]
"path": ["desktopApplication", "windows"], "extensions": {"kind": "permission", "permissionClass": "os-permission", …}
no consent dialog on screen (after a windows read without consent); universalAccessAuthWarn: running

== Consent absent: a grant without desktop:read gets the capability class, not the OS one
"This operation requires the desktop:read capability." … "permissionClass": "capability"

== The window's request: macOS shows its dialog, naming Koine
Observation: the request (the first request of this run of Koine) showed macOS's consent dialog, naming Koine.
== A SECOND request in the same run of Koine: whatever macOS does is recorded
Observation: the request (a second request in the same run of Koine) showed macOS's consent dialog, naming Koine.

== Same-titled windows under distinct references, stable across two listings
Koine lists 3 windows where the system says 3.

== PID reuse as far as it can be observed: the same live PID at another start instant is another process
{"case": "later",     "pid": 362, "startedAt": "…397177Z", "response": {"data": {"desktopApplication": null}}}
{"case": "absent",    "pid": 1000000,                       "response": {"data": {"desktopApplication": null}}}
{"case": "malformed", "pid": 362, "startedAt": "2026-09-20T14:22:32Z" -> "process.startedAt must be the process start instant as UTC with six fractional second digits…"

== A closed window is unavailable; the same-titled windows beside it still resolve
…/69a6aea17a79266a/1 -> "The window is no longer open." (kind: unavailable);  /2 and /3 still resolve

== Consent revoked while Koine runs: an os-permission error at the original path, and nothing prompts
Route: agent press on the switch   ->  error: HTTP 400 Bad Request
Route: VNC click at the switch's centre  ->  ["…","Modify Settings","Cancel",…]
Observation: the switch moved to 0 by click.
Observation: the first read to report revoked consent completed 0s after the password was entered.

== A request in a LATER run of Koine: whatever macOS does is recorded
Observation: the request (the first request of a later run of Koine, after consent was given and removed) showed macOS's consent dialog, naming Koine.

== After login, with nothing having launched Koine and no client installed
473 /Applications/Koine.app/Contents/MacOS/Koine
{"contractVersion":"koine-desktop/1","descriptorVersion":1,"instanceId":"46590697-…","path":"/graphql","pid":473,"port":49152}
Processing: /Applications/Koine.app
The validate action worked!
Quarantine after the restart: 01c1;6aafec86;Safari;36D4BB18-5070-4180-8137-BF391557770C
{"data":{"koine":{…,"ownGrant":{"clientLabel":"vm-release-reader","capabilities":["desktop:read","koine:manage"],"state":"ACTIVE"}}}}
HTTP 200
Listener without a credential: HTTP 401
```

**The open item is closed, and the answer is yes.** macOS showed its consent
dialog, naming Koine, on all three requests: the first of a run, a second in the
same run of Koine, and the first of a later run made after consent had been given
and taken away. `accessibility-status-and-consent-vm.md` recorded that as
unverified; it is verified here, on the release build.

**References, before and after the Koine restart.** The application reference
`koine://desktop/application/362/1789914152397176` resolved to the same
application, field for field, in both runs of Koine. Its windows were listed
under `…/69a6aea17a79266a/{1,2,3}` in the first run and `…/d4be979346154e2b/{1,…}`
in the second, and a window reference from the first was `unavailable` in the
second. The application reference is the process; the window reference is the
run's.

**Two numbers in the transcript are not latency.** *"Within 0s"* means the first
read after the action already reported the change. The 93 s that `osPermissions`
took to report `granted: false` is elapsed time through the TestAnyware agent's
retries — a guest exec that runs to completion and is then reported as
"Process timed out after 30s" costs a real thirty seconds, and the same
revocation was visible to a desktop read at 0 s. Latency is
`support-matrix-and-latency-k44`'s and is measured with an instrument built for it.

No behaviour of the release build differed from the spec in this run.

## Tooling note

The Gatekeeper-enforcing clone, the explicit quarantine attribute, the first-run
dialog read as accessibility text and the wait that dismisses a provider refusal
now live in `scripts/vm-verify-gatekeeper-lib.sh`, extracted unchanged from
`scripts/vm-verify-notarized.sh` so the two release-artifact routes share one
copy. `scripts/vm-verify-release.sh` keeps three things of its own rather than
pushing them into the shared libraries, so that the four passing routes that use
those libraries are not changed by this leaf: a retry-tolerant `ask`, the
switch-driving helpers described above, and the `AXWindow` filter that keeps
Finder's desktop out of the probe's window count.
