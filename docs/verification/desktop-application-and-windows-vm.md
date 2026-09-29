# Desktop application and windows: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
resolving an application and listing its windows, on the
Developer ID signed `Koine.app` with real applications and no application mock.
Which native mechanism identifies a window, and the evidence for it, is
[desktop-window-identity.md](desktop-window-identity.md); this run verifies what
ships.

## Procedure

```sh
task app                    # build and sign .build/app/Koine.app, desktop provider included
task app:vm-verify-desktop  # scripts/vm-verify-desktop.sh
```

Requirements, the clean clone, the transcript
(`.build/vm-verify/desktop-<timestamp>.log`), `KOINE_VM_KEEP=1` and the
TestAnyware workarounds are those of [resident-app-vm.md](resident-app-vm.md);
the scripts share `scripts/vm-verify-lib.sh`. Nothing runs the application on
the host.

The client is `scripts/vm-verify-desktop-client.py`, run in the guest. It knows
the endpoint descriptor, a credential file and an application's name. It captures
the process identity as any client must, the PID and the kernel's start instant
from `proc_pidinfo(PROC_PIDTBSDINFO)` in canonical form, and posts one query with
the identity as a variable.

| Step | How | Expectation checked |
|---|---|---|
| Bundle | `find`, `codesign --verify --strict` and `-dvv` on `Contents/PlugIns/Desktop.koineprovider`, in the VM | recorded: the bundle's content, a valid signature by `TA43A4RUP3` with the hardened runtime |
| Grants | two grants created in Koine's window: `koine:manage` + `desktop:read`, and `desktop:control` alone; each credential by Copy and `pbpaste` | both credential files exist |
| Provider status | `{ koineManagement { providers { … } } koine { availableCapabilities } }` | `desktop` is `ACTIVE`; `desktop:read` and `desktop:control` are available |
| Real windows | `open -a Finder`, ⌘N twice | — |
| Before consent | the query for Finder | recorded, and an error is required: `permission` / `os-permission` naming `accessibility`, at the path `desktopApplication.windows`. `windows` is non-null, so the error discards the enclosing application and `desktopApplication` is null. Its classification is asserted in [desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md). |
| Consent | see below | Koine is in System Settings' Accessibility list |
| Resolve and list | the query for Finder, with its true `pid` and `startedAt` | no errors; name `Finder`, bundle identifier `com.apple.finder`, an application reference; at least two windows, every one titled, all with one title, all references distinct window references, all `CURRENT`. Finder's desktop, which is in its window list, has no row. |
| Stable references | the same query again | the same set of window references |
| Mismatched `startedAt` | the true instant plus one microsecond | `desktopApplication` is null, no errors |
| Absent process | PID 1000000 | null, no errors |
| Malformed `startedAt` | the true instant in whole seconds | null, one error with a path and no `extensions.kind` |
| Missing `desktop:read` | the true identity with the `desktop:control` grant | `permission`, `capability`, `requiredCapability` `desktop:read` |

## Accessibility consent in a VM

The desktop VM runs give consent by this route; the request Koine's own window
makes is verified in
[accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md).
Consent is System Settings' to record, and the script
gives it as a user does (`grant_accessibility` in `scripts/vm-verify-desktop.sh`):

1. `open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"`
   opens the pane directly.
2. Koine's reads never request consent. Once a read has asked `AXIsProcessTrusted`,
   macOS lists Koine in the pane, switched off, without showing any dialog;
   before that it is not listed. **Add** serves both cases: the button is found
   in the accessibility tree (role `button`, label `Add`), waited for while the
   pane loads, and clicked over VNC.
3. macOS asks for the account's password to modify Privacy & Security. The
   golden image's account is `admin` / `admin`; `KOINE_VM_PASSWORD` overrides it.
4. In the file chooser, ⌘⇧G, the installed path `/Applications/Koine.app`, Return
   twice. Koine appears in the list, enabled.

Consent takes effect in the running Koine at once: the next query lists windows
with no restart. It is keyed to the designated requirement, which is the same for
every Koine build, so it survives reinstalling a rebuilt bundle in one VM; a
clean clone starts without it.

The image's TCC database is not used. It is readable in the clone, but editing it
bypasses the consent the OS records; nothing here depends on it.

The identity probe needed no consent of its own: a command-line tool started by
`testanyware file exec` is Accessibility-trusted through its responsible
process, `testanyware-agent`, which holds the consent in the golden image. That
is true of test tools only, never of Koine, which is launched by `open`.

## What this does and does not show

It shows the bundled provider loading under the hardened runtime by the one
loader and its built-in approval, the process identity compared in both halves
against a real application, the input error, the capability refusal, and
distinct, stable references for same-titled real windows, all through loopback
GraphQL with manually created grants.

This run does not force PID reuse;
[retained-ax-binding.md](retained-ax-binding.md) does. What is observed here is a
live PID claimed
at another start instant, here, and a relaunched application with another
`startedAt`, in the identity evidence. Untitled windows, closure, restart and
Spaces are exercised natively in the identity evidence, not through GraphQL:
looking a window reference up again is verified in
[desktop-references-and-permission-vm.md](desktop-references-and-permission-vm.md),
and focusing in [desktop-focus-vm.md](desktop-focus-vm.md).

## Evidence

Run of 2026-09-19, macOS 26.5 (25F71) arm64 clone, Gatekeeper assessments
disabled in the golden image, bundle signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`; transcript
`.build/vm-verify/desktop-20260919T232356.log`. **PASSED.**

- Bundle: `Desktop.koineprovider` holds `libDesktopProvider.dylib`,
  `manifest.json`, `schema.graphql`, `Info.plist` and `_CodeSignature`;
  `valid on disk`, identifier `dev.antony.Koine.provider.desktop`,
  `flags=0x10000(runtime)`, team `TA43A4RUP3`.
- Status: `{"provider":"desktop","version":"1.0.0","state":"ACTIVE","diagnostic":null}`,
  `availableCapabilities` `["koine:manage","desktop:read","desktop:control"]`.
- Before consent, for Finder (`pid` 362, `startedAt` `2026-09-19T13:24:04.635833Z`):
  `"data":{"desktopApplication":null}` with one error, path
  `["desktopApplication","windows"]`, `kind` `permission`, `permissionClass`
  `os-permission`, `osPermission` `accessibility`, `permissionOwner` `koine`. No
  dialog appeared.
- After consent, with no restart of Koine: `ref`
  `koine://desktop/application/362/1789824244635833`, `name` `Finder`,
  `bundleIdentifier` `com.apple.finder`, and three windows, all titled `Recents`,
  all `CURRENT`, with references `…/4495ab5376ecc2c4/1`, `/2` and `/3`. (`open -a
  Finder` opens a window of its own besides the two ⌘N.) The second listing
  returned the same three references.
- `startedAt` `…04.635834Z`, one microsecond later: `{"data":{"desktopApplication":null}}`.
  PID 1000000: the same.
- `startedAt` `2026-09-19T13:24:04Z`: null, with one error at `["desktopApplication"]`
  carrying no `extensions`, "process.startedAt must be the process start instant
  as UTC with six fractional second digits, such as 2026-09-19T01:02:03.000456Z."
- The `desktop:control` grant: `kind` `permission`, `permissionClass`
  `capability`, `requiredCapability` `desktop:read`.

The same day, on the same build: `task app:vm-verify` PASSED
(`.build/vm-verify/20260919T232144.log`), `task app:vm-verify-providers` PASSED
(`.build/vm-verify/providers-20260919T230439.log`), and `task compat` passed its
19 cases.

Two other runs of this task ended on the TestAnyware guest-exec fault that
[resident-app-vm.md](resident-app-vm.md) describes, not on Koine: a snapshot taken
while the Accessibility pane was still loading had no **Add** button, and
`open -a Finder` was reported timed out six times running. The script waits
for the button and does not end on a setup command that the following assertions
verify anyway. `scripts/vm-verify.sh` likewise repeats its last port check when
the guest returns nothing.
