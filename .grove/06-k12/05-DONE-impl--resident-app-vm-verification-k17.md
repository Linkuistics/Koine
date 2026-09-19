# resident-app-vm-verification-k17

## Goal

Prove the real workflow through the TestAnyware seam: the signed Koine
application installed in an isolated macOS VM, launched at login with no client
present, and the manual grant workflow and revocation driven through its real
UI.

## Context

- Load the `testanyware:using-testanyware` skill before anything else.
- The "Isolated TestAnyware macOS VMs" row of the spec's "Test seams and
  acceptance", limited to what this stage built. Accessibility attribution,
  the request/approval workflow and desktop behaviour belong to later stages.
- The earlier leaves' commits for the bundle and verification commands and the
  login-item behaviour recorded by
  `grant-management-ui-and-login-launch-k16`.
- Login-item behaviour observed by `grant-management-ui-and-login-launch-k16`
  in a TestAnyware clone of `testanyware-golden-macos-tahoe`, macOS 26.5
  (25F71), arm64, bundle installed by `ditto -c -k --keepParent` on the host,
  `testanyware file upload`, `ditto -x -k` into `/Applications`:
  - The upload route sets no quarantine attribute. `codesign --verify --strict`
    passes; `spctl -a -vv` says `accepted`, `source=Unnotarized Developer ID`,
    but also `override=security disabled` — the golden has Gatekeeper
    assessments disabled (`spctl --status`), so that acceptance is not evidence
    of what a stock machine does. State this in the procedure.
  - Status before any registration: `notFound` (not `notRegistered`). After
    clicking the toggle: `enabled` immediately, no approval step, with a system
    "Login Item Added" notification; `sudo sfltool dumpbtm` lists
    `2.dev.antony.Koine`, type app, team TA43A4RUP3, disposition `[enabled,
    allowed, notified]`. After unticking: `notRegistered`, disposition
    `[disabled, allowed, notified]`. The text shown matched the status read
    back each time. `requiresApproval` was not seen.
  - Tooling: `testanyware agent press` on the SwiftUI checkboxes answers HTTP
    400; a VNC `input click` on the checkbox works. The status text is a static
    text, absent from `agent snapshot --mode interact`; read it from a
    screenshot or a fuller snapshot mode. `sfltool dumpbtm` needs `sudo`
    (password `admin`) or it hangs. Log out and back in was not done.

## Done when

A repeatable, written procedure (script where the tooling allows, with its
Taskfile command and README entry) that in a clean VM:

- installs the Developer-ID-signed bundle and shows the VM accepts its
  signature; how the bundle reaches the VM, and any Gatekeeper or quarantine
  consequence of that route, is stated rather than worked around — never strip
  quarantine or disable code-signing checks to make it pass;
- starts Koine, enables login launch in the UI, logs out and in (or restarts),
  and finds the endpoint descriptor and an answering listener with no client
  having launched anything;
- creates a grant through the real UI, delivers the credential to a script in
  the VM, and that script reads the descriptor and gets `Query.koine`;
- closes the management window and shows the same script still answered;
- revokes the grant through the real UI and shows the script now gets 401;
- quits Koine and shows the descriptor gone and the endpoint unavailable.

The evidence (what ran, VM OS version and architecture, what was observed) is
recorded where the release stage can find it. Anything the VM shows that the
signed build cannot do as the spec says is reported to the human as a finding
with a recommendation, not patched around.

## Notes

This verifies an un-notarized Developer ID build; notarization and the
supported OS/CPU matrix are `release-acceptance-handoff-k11`'s. If the run
exposes a defect an earlier leaf of this stage owns, cut a new leaf for the fix
under this node instead of absorbing it here.
