# Resident application: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, limited to
signed installation, login launch with no client, the manual grant workflow and
revocation through the real UI, the settings window closed with the service
still answering, and Quit. Accessibility attribution
([accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md)),
the request/approval workflow
([grant-workflow-acceptance-vm.md](grant-workflow-acceptance-vm.md)), desktop
behaviour, notarization ([notarized-release-vm.md](notarized-release-vm.md)) and
the supported OS/CPU matrix
([latency-and-support-matrix.md](latency-and-support-matrix.md)) are outside
this run.

## Procedure

```sh
task app            # build and sign .build/app/Koine.app on the host
task app:vm-verify  # scripts/vm-verify.sh: everything below, in a fresh VM
```

It needs `testanyware` with a macOS golden image (`testanyware vm list`) and
`jq`. Nothing runs the application on the host. Each run clones the golden,
stops the clone when it ends (`KOINE_VM_KEEP=1` keeps it), exits non-zero at the
first expectation that fails with a screenshot beside the transcript, and writes
the transcript to `.build/vm-verify/<timestamp>.log`.

| Step | How | Expectation checked |
|---|---|---|
| Install | `ditto -c -k --keepParent` on the host, `testanyware file upload`, `ditto -x -k` into `/Applications` | `codesign --verify --strict --deep` passes in the VM; identifier, team and hardened runtime are printed; `spctl -a -vv` and the quarantine attribute are recorded |
| Enable login launch | `open` the bundle, on a clone where Accessibility is not granted, so the launch rule opens the settings window; click "Start Koine at login" | the status text reads "Koine will start when you log in." |
| Login with no client | ⌘Q from the window first, so nothing but the login item can bring Koine back (no process, no descriptor); then `shutdown -r now`; the golden logs in automatically | after the restart a Koine process, `endpoint.json`, and HTTP 401 to an unauthenticated request — a listener answers |
| Manual grant | type a label, "Create Grant", the sheet's "Copy" button, `pbpaste` into a mode-600 file in the VM | `scripts/vm-verify-client.sh`, which knows only the descriptor and that file, gets HTTP 200 and `ownGrant.clientLabel` as typed; "Done" removes the credential from the UI |
| Window closed | close the settings window ("Koine Settings") | no Koine window; the same script still gets 200 |
| Revoke | `open` the bundle again (the reopen path, which shows the window), "Revoke", confirm | the row reads "Revoked"; the same script gets 401 |
| Quit | ⌘Q from the window | no process, no `endpoint.json`, connection refused on the old port |

The credential never leaves the VM and is never printed: it travels from the
sheet's Copy button through the VM's clipboard to the protected file.

## What this route does and does not show

- **No quarantine, and Gatekeeper is off in the golden.** `testanyware file
  upload` sets no `com.apple.quarantine` attribute, and the golden image reports
  `spctl --status` as `assessments disabled`, so `spctl -a` answers `accepted`
  with `override=security disabled`. What the VM does show is that the
  Developer ID signature verifies strictly there with no certificate installed
  and that the bundle satisfies its designated requirement. It is **not**
  evidence of what Gatekeeper does on a stock machine with a downloaded,
  un-notarized bundle; nothing was stripped or disabled to get here. A
  quarantined first launch of the notarized build on a clone whose
  assessments are enabled is shown in
  [notarized-release-vm.md](notarized-release-vm.md).
- **Restart, not log out.** The login item is exercised by a restart and the
  golden's automatic login. Koine is quit before the restart so that macOS's
  reopening of applications that were running cannot be what starts it.
- **Login-item approval.** Registration went straight to `enabled` with no
  approval step; `requiresApproval` is not observed in this or any other run.

## Tooling notes (TestAnyware 2.1.0)

- `agent press` answers HTTP 400 for every control tried in this window
  (checkbox, button, menu item). The script finds elements in `agent snapshot
  --mode full --depth 12 --json` by accessibility identifier, role and label,
  and clicks their centre over VNC, re-reading positions each time. The default
  snapshot depth stops above a grant row's children.
- The settings window is not open at every launch: the launch rule opens it only
  while Accessibility is not granted or login launch is not enabled. A check that
  needs the window asks for it (`show_window` in `scripts/vm-verify-lib.sh`), and
  `open` of the running bundle is what shows it, which is also how a user gets it
  back from Finder or Spotlight. `launch` shows and places it, `place_window` does
  the same, and `quit_koine` shows it before ⌘Q. Quit from the menu bar item's menu
  needs System Events, which [menu-bar-vm.md](menu-bar-vm.md) sets up and covers.
  The base run's clone has no Accessibility, so its launches open the window
  by rule.
- `agent window-focus --window Koine` (the application's name) is what makes the
  settings window the one a click reaches. Naming the window by its full title,
  "Koine Settings", raised it but left Finder the active application, and a click
  on a button in it then went to the wallpaper and hid every window. Window moves
  and closes take the title.
- A notification banner ("Login Item Added") covers the top-right of the screen
  and swallows clicks — one opened System Settings. The script keeps the window
  at the top-left.
- The display is 1024×768 after the restart; nothing depends on it.
- `file exec` intermittently (about half of calls in a long-lived clone, `true`
  included) runs the command and then reports `Process timed out after 30s`,
  status 255. The script retries exactly that answer; every guest command but
  the restart is safe to repeat, and the restart is not retried.
- The guest's `/tmp` is emptied by the restart; the client script lives in the
  home directory.

## Evidence

Run of 2026-10-16 against the bundle built from `ce42c55` plus the shared-helper
migration to the menu bar application, signed `Developer ID Application: Antony
Blakey (TA43A4RUP3)`, un-notarized. VM: clone of `testanyware-golden-macos-tahoe`,
macOS 26.5 (25F71), arm64, on an Apple-silicon host. Result: **passed**, every
expectation above. Accessibility is not granted in the clone, so both launches that
needed the window (the first, and the one after the restart) found it opened by the
launch rule, and the reopen step brought it back with `open` of the running bundle.

```
== Install the signed bundle (ditto zip, testanyware file upload, ditto -x)
Quarantine attribute: xattr: /Applications/Koine.app: No such xattr: com.apple.quarantine
/Applications/Koine.app: valid on disk
/Applications/Koine.app: satisfies its Designated Requirement
Identifier=dev.antony.Koine
CodeDirectory v=20500 size=37148 flags=0x10000(runtime) hashes=1150+7 location=embedded
Authority=Developer ID Application: Antony Blakey (TA43A4RUP3)
TeamIdentifier=TA43A4RUP3
/Applications/Koine.app: accepted
source=Unnotarized Developer ID
override=security disabled

== Start Koine and enable login launch in the UI
Before: Koine is not registered to start at login. Clients find the service unavailable until you open Koine.
After:  Koine will start when you log in.

== After login, with nothing having launched Koine
473 /Applications/Koine.app/Contents/MacOS/Koine
{"contractVersion":"koine-desktop\/1","descriptorVersion":1,"instanceId":"848911d3-…","path":"\/graphql","pid":473,"port":49152}
Listener without a credential: HTTP 401

== Create a grant through the UI and deliver its credential to a script
-rw-------  1 admin  staff  43 Oct 16 08:58 /Users/admin/koine-credential
{"data":{"koine":{"contractVersion":"koine-desktop\/1","ownGrant":{"clientLabel":"vm-script","capabilities":[],"state":"ACTIVE"}}}}
HTTP 200

== Close the settings window; the service still answers
HTTP 200

== Reopen the window (opening the running application shows it) and revoke the grant through the UI
Grant row: ["vm-script","No capabilities","Revoked","Revoke"]
HTTP 401

== Quit Koine
grants.sqlite
instance.lock
no descriptor
curl to the old port 49152: exit 7
```
