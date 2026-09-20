# Resident application: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, limited to
what `resident-management-k12` built: signed installation, login launch with no
client, the manual grant workflow and revocation through the real UI, the
management window closed with the service still answering, and Quit.
Accessibility attribution, the request/approval workflow, desktop behaviour,
notarization and the supported OS/CPU matrix belong to later stages.

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
| Enable login launch | `open` the bundle; click "Start Koine at login" | the status text reads "Koine will start when you log in." |
| Login with no client | ⌘Q first, so nothing but the login item can bring Koine back (no process, no descriptor); then `shutdown -r now`; the golden logs in automatically | after the restart a Koine process, `endpoint.json`, and HTTP 401 to an unauthenticated request — a listener answers |
| Manual grant | type a label, "Create Grant", the sheet's "Copy" button, `pbpaste` into a mode-600 file in the VM | `scripts/vm-verify-client.sh`, which knows only the descriptor and that file, gets HTTP 200 and `ownGrant.clientLabel` as typed; "Done" removes the credential from the UI |
| Window closed | close the management window | no Koine window; the same script still gets 200 |
| Revoke | `open` the bundle again (the reopen path), "Revoke", confirm | the row reads "Revoked"; the same script gets 401 |
| Quit | ⌘Q | no process, no `endpoint.json`, connection refused on the old port |

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
  un-notarized bundle; nothing was stripped or disabled to get here.
  **Closed**: a quarantined first launch of the notarized build on a clone whose
  assessments are enabled is shown in
  [notarized-release-vm.md](notarized-release-vm.md).
- **Restart, not log out.** The login item is exercised by a restart and the
  golden's automatic login. Koine is quit before the restart so that macOS's
  reopening of applications that were running cannot be what starts it.
- **Login-item approval.** Registration went straight to `enabled` with no
  approval step, as `grant-management-ui-and-login-launch-k16` also saw;
  `requiresApproval` has not been observed.

## Tooling notes (TestAnyware 2.1.0)

- `agent press` answers HTTP 400 for every control tried in this window
  (checkbox, button, menu item). The script finds elements in `agent snapshot
  --mode full --depth 12 --json` by accessibility identifier, role and label,
  and clicks their centre over VNC, re-reading positions each time. The default
  snapshot depth stops above a grant row's children.
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

Run of 2026-09-19 against the bundle built from `9991ac9` plus this
procedure, signed `Developer ID Application: Antony Blakey (TA43A4RUP3)`,
un-notarized. VM: clone of `testanyware-golden-macos-tahoe`, macOS 26.5
(25F71), arm64, on an Apple-silicon host. Result: **passed**, every expectation
above, about two minutes. One earlier complete run the same day also passed;
the failures before them were the tooling matters noted above, not Koine.

```
== Install the signed bundle (ditto zip, testanyware file upload, ditto -x)
Quarantine attribute: xattr: /Applications/Koine.app: No such xattr: com.apple.quarantine
/Applications/Koine.app: valid on disk
/Applications/Koine.app: satisfies its Designated Requirement
Identifier=dev.antony.Koine
CodeDirectory v=20500 size=33884 flags=0x10000(runtime) hashes=1048+7 location=embedded
Authority=Developer ID Application: Antony Blakey (TA43A4RUP3)
TeamIdentifier=TA43A4RUP3
/Applications/Koine.app: accepted
source=Unnotarized Developer ID
override=security disabled

== Start Koine and enable login launch in the UI
Before: Koine is not registered to start at login. Clients find the service unavailable until you open Koine.
After:  Koine will start when you log in.

== After login, with nothing having launched Koine
417 /Applications/Koine.app/Contents/MacOS/Koine
{"contractVersion":"koine-desktop\/1","descriptorVersion":1,"instanceId":"d65f16ec-…","path":"\/graphql","pid":417,"port":49152}
Listener without a credential: HTTP 401

== Create a grant through the UI and deliver its credential to a script
-rw-------  1 admin  staff  43 Sep 19 08:23 /Users/admin/koine-credential
{"data":{"koine":{"contractVersion":"koine-desktop\/1","ownGrant":{"clientLabel":"vm-script","capabilities":[],"state":"ACTIVE"}}}}
HTTP 200

== Close the management window; the service still answers
HTTP 200

== Reopen the window and revoke the grant through the UI
Grant row: ["vm-script","No capabilities","Revoked","Revoke"]
HTTP 401

== Quit Koine
grants.sqlite
instance.lock
no descriptor
curl to the old port 49152: exit 7
```

No behaviour of the signed build differed from the spec in this run.
