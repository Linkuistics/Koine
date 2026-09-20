# Accessibility status and consent: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
`accessibility-status-and-consent-ui-k32`: Koine's own window explains and
requests Accessibility consent and shows provider and service status, and
`koineManagement.osPermissions` reports the same facts. It runs on the Developer
ID signed `Koine.app` with Finder; there are no application mocks. This is where
the spec's claim that the prompt is attributed to the signed, packaged
application is checked for the development-signed build;
`release-acceptance-handoff-k11` repeats it on the release build. The consent
route the earlier leaves used is in
[desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md),
and revocation in
[desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md).

## What the platform offers

- **Reading and asking are different calls.** `AXIsProcessTrusted` takes no
  options. `AXIsProcessTrustedWithOptions` with `kAXTrustedCheckOptionPrompt` is
  documented in `AXUIElement.h` as "indicating whether the user will be informed
  if the current process is untrusted", and "prompting occurs asynchronously and
  does not affect the return value". Koine's server and provider make only the
  first; the window's request control makes the second.
- **The trust read is live.** The same running process read `false`, then `true`
  after its switch was turned on, then `false` after it was turned off. No
  restart is needed, so the window says so rather than asking for one.
- **Nothing announces a change**, so the window re-reads its status every two
  seconds.
- **The pane's URL**,
  `x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`,
  has no official source. It opened the Accessibility pane on macOS 26.5 from
  Koine's button; check it on a new macOS release.

## Procedure

```sh
task app                           # build and sign .build/app/Koine.app
task app:vm-verify-accessibility   # scripts/vm-verify-accessibility.sh
```

Two grants are created in Koine's window: a manager (`koine:manage`,
`desktop:read`) and a stranger with `desktop:read` alone. The script then checks,
in order:

1. The window's service line names the port the endpoint descriptor names, and
   its provider row shows the state `koineManagement.providers` reports.
2. With consent absent: the window's guidance names Koine; `osPermissions` is
   exactly `accessibility`, `koine`, `granted: false`; and no consent dialog is
   on screen after those reads and the window's own polling.
3. The stranger's `osPermissions` read is a `permission` / `capability` error
   requiring `koine:manage`, with `koineManagement` null.
4. "Request Accessibility Access…" makes macOS show its dialog, whose text, read
   from the screen, names Koine.
5. The dialog's own "Open System Settings" leads to the Accessibility pane,
   which lists Koine, switched off.
6. Koine's switch is turned on and the password given. Without a restart (the
   PID is compared) `osPermissions` reports `granted: true`, the window says
   Koine has access and withdraws its request controls, and a desktop read lists
   Finder's windows.
7. Consent is removed by the same switch. Without a restart both follow, and the
   desktop read is an `os-permission` error naming `accessibility` and `koine`.
8. "Open Accessibility Settings…" opens the pane, where Koine is still listed.

The script replaces the library's `ask` for itself alone: the agent's false
"timed out" reports (see [resident-app-vm.md](resident-app-vm.md)) once outlasted
every retry on a query Koine had answered with HTTP 200, so a complete JSON body
followed by its status line is accepted whatever the agent reports. A run is
about seven minutes.

## What this does not show

- **The Settings entry is not evidence that the request made it.** macOS lists an
  application there, switched off, once it has merely asked whether it is trusted
  ([desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md)),
  and the window's polling has done that before the request. The entry shows the
  identity macOS attributes Koine's process to; the dialog is what shows the
  request.
- **A second request** in the same or a later run of Koine was not made. Whether
  macOS shows the dialog again is unverified; "Open Accessibility Settings…" is
  the route that does not depend on it.
- "Within 0s" below means the first `osPermissions` read after System Settings
  was quit already reported the change; that read comes several seconds after the
  password. It is not a latency measurement.
- Gatekeeper assessments are disabled in the golden image and the route sets no
  quarantine attribute, as in every run here. **Closed**:
  [notarized-release-vm.md](notarized-release-vm.md) shows this dialog naming
  Koine on the notarized build, on a Gatekeeper-enforcing clone with the bundle
  quarantined.

## Evidence

Run of 2026-09-20, transcript `accessibility-20260920T074804.log`, against the
bundle built from the working copy on `2f14936` that this leaf commits, signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`, un-notarized. The
executable and the three scripts the run reads were digested before and after
and did not change. VM: clone of `testanyware-golden-macos-tahoe`, macOS 26.5
(25F71), arm64. Result: **passed**, every expectation above. The run before it,
from the same sources but for one source comment, also passed; the one before
that stopped at step 1 on the tooling matter described above, with Koine's
correct answer in its transcript.

```
== The window shows the service where the descriptor says it is, and the desktop provider's state
Descriptor port 49152; window: Serving koine-desktop/1 at http://127.0.0.1:49152/graphql. Closing this window leaves it running.
{"data":{"koineManagement":{"providers":[{"provider":"desktop","version":"1.0.0","state":"ACTIVE","diagnostic":null}]}}}
Provider row: ["desktop 1.0.0, Active"]

== Consent absent: the window gives guidance naming Koine, osPermissions reports granted: false, and nothing prompts
Window: Koine does not have Accessibility access, so clients cannot list or focus windows. Koine is the application that needs it, not its clients: switch Koine on in System Settings, under Privacy & Security, Accessibility. No restart is needed.
{"data":{"koineManagement":{"osPermissions":[{"permission":"accessibility","owner":"koine","granted":false}]}}}
no consent dialog on screen (after osPermissions reads and the window's own polling without consent); universalAccessAuthWarn: running

== A grant without koine:manage cannot read osPermissions
{"data":{"koineManagement":null},"errors":[{"message":"This operation requires the koine:manage capability.","locations":[{"line":1,"column":3}],"path":["koineManagement"],"extensions":{"requiredCapability":"koine:manage","permissionClass":"capability","phase":"execution","kind":"permission"}}]}

== The window's request: macOS shows its consent dialog, naming Koine
[{"confidence":1.0,"height":17.0000000000001,"text":"\"Koine\" would like to control this computer using","width":318.13952636718756,"x":831.6279072582668,"y":279.0000004056765}]

== Consent given by Koine's switch; with no restart the window and osPermissions agree, and a desktop read succeeds
Observation: osPermissions reported granted: true within 0s, Koine pid 608.
{"data":{"koineManagement":{"osPermissions":[{"permission":"accessibility","owner":"koine","granted":true}]}}}
Window: Koine has Accessibility access. Clients read and focus windows through it.

== Consent removed in System Settings: the window and osPermissions follow, and a desktop read is an os-permission error
Observation: osPermissions reported granted: false within 0s, Koine pid 608.
{"data":{"koineManagement":{"osPermissions":[{"permission":"accessibility","owner":"koine","granted":false}]}}}
Window: Koine does not have Accessibility access, so clients cannot list or focus windows. […]
```

Koine was pid 608 at launch and at both observations. The dialog and the
Settings entry as the screen showed them:
[consent-dialog.png](accessibility-status-and-consent/consent-dialog.png),
[settings-entry.png](accessibility-status-and-consent/settings-entry.png).

No behaviour of the signed build differed from the spec in this run.
