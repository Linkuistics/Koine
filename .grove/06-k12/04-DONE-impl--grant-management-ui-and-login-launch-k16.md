# grant-management-ui-and-login-launch-k16

## Goal

Complete the manual grant workflow in the native UI — list and revoke — and let
the user enable login launch during setup.

## Context

- Read `resident-app-skeleton-k13`'s commit for the UI framework, the
  console-operation layer and the bundle script; read
  `grant-listing-and-revocation-k14`'s for the operations this UI calls.
- Spec: "Application composition and availability" (login launch),
  "User-created grant", "Management authority and surface".
- Apple's `SMAppService.mainApp` documentation, linked from the spec. Verify
  its registration, status and user-approval behaviour there, not from memory.

## Done when

- The management window lists grants (label, capabilities, state) from
  `koineManagement.grants` through the console principal, and refreshes after
  create and revoke.
- The user revokes a grant from the list, with a confirmation that names it.
  The UI calls `koineRevokeGrant`; a failure is shown, never swallowed.
  Granting `koine:manage` in the create flow is shown prominently, because it
  permits issuing and revoking other grants.
- No affordance re-reads a credential. Where a user would look for one, the UI
  says that lost delivery is handled by revoking and creating again.
- A setup affordance enables and disables login launch through
  `SMAppService.mainApp`, reflects the service's actual status (including
  "requires approval in System Settings") and never claims an enabled state it
  has not read back.
- The list/revoke logic between UI and console is covered by package tests
  against an embedded server. Login-item registration is exercised with the
  signed bundle in a TestAnyware VM, not on the host (the human's direction in
  `resident-app-skeleton-k13`; see the stage brief), and the observed behaviour
  is recorded for the VM leaf.

## Notes

Keep the UI a thin client. Service status and OS-permission guidance are named
by the spec as UI affordances but belong to later stages; add only a plain
"listening on loopback / stopped" indication if it costs nothing.

## Decisions (running log)

- `SMAppService` behaviour verified against Apple's documentation (URLs cited in
  `LoginLaunchView.swift` and the README): `register()` affects subsequent
  logins and throws when unapproved; `unregister()` leaves the running app;
  `requiresApproval` also follows withdrawn consent. The model therefore holds
  only the last `status` read, re-read after every call and on activation.
- One management window: grant list, create flow, setup, a one-line loopback
  status. The list refreshes after create/revoke and on activation, because a
  `koine:manage` client can change grants over HTTP.
- VM exercise blocked, not done: in this session non-Apple binaries
  (`testanyware`, `python3`) get "No route to host" to the tart subnet
  192.168.64.0/24 while `curl` connects and the agent answers healthy — macOS
  Local Network privacy is the likely cause. The human reports iTerm holds that
  permission, but this session's ancestry is `claude → grove → zsh →
  /opt/homebrew/bin/herdr → launchd`, never iTerm; with the VM up the route is
  `bridge100`, and `python3` still gets errno 65 with the command sandbox off.
  `responsibility_get_pid_responsible_for_pid` reports the herdr server (pid
  1572, up since boot) as its own responsible process, so iTerm's grant does
  not reach this session, and a bundle-less binary cannot be added to the Local
  Network list. The VM and agent are healthy (`curl` reaches them); nothing in
  the VM needs changing. No denial was found in the unified log. Not
  worked around (no driving the agent through `curl`); `tart exec` has no guest
  agent in the golden. VNC over 127.0.0.1 works but cannot install the bundle.
- Correction: the human reproduced the failure from a bare iTerm tab, so the
  herdr attribution above is not the cause; the problem is host-wide. Measured
  with a VM up: Apple-signed `/usr/bin/curl`, `/usr/bin/nc`, `/usr/bin/python3`
  and `ping` reach the guest; Homebrew `python3`, Homebrew `curl` and
  `testanyware` get errno 65 to the guest only — the same Homebrew python
  reaches the LAN gateway, the host's own bridge address and VNC on 127.0.0.1.
  No system extension, VPN service or application firewall is active, and the
  unified log shows no denial. Cause unconfirmed.
- Settled with the human: the block is host-wide macOS Local Network privacy
  state, not herdr, TestAnyware, tart or the VM. From this session and from a
  plain iTerm tab (iTerm's Local Network switch on, toggled off and on), Homebrew
  `python3` and `testanyware` get errno 65 to the guest and to ordinary LAN
  hosts that Apple's `nc`/`curl` reach; only the router answers. The policy
  store (`/Library/Preferences/com.apple.networkextension.plist`) decodes
  cleanly. Separately: macOS runs at most two macOS guests, and `vm start`
  leaves the clone running when it only warns about agent health, so leaked
  clones make every later `vm start` fail with "did not become reachable" —
  check `tart list` for running clones first.
- After the host reboot the VM agent was reachable from this session; the
  Local Network block above no longer reproduces. Login-item registration was
  exercised in a TestAnyware macOS 26.5 (25F71, arm64) clone and the
  observations recorded in `resident-app-vm-verification-k17`'s Context.
- `notFound` is what a never-registered signed bundle reads, and `register()`
  succeeds from it, so its wording changed from an orange "run Koine from its
  signed bundle" warning to a neutral "not registered"; only
  `requiresApproval` is orange. The reworded text was built and verified on the
  host but not re-observed in a VM (the clone's record already existed); k17's
  clean VM shows it on first launch.
