# platform-acceptance-k42

## Goal

Run the platform half of release acceptance against the **notarized** build in
one composed VM session: entitlements and Accessibility attribution, login
launch with no client installed, absent and revoked OS consent, and the desktop
behaviours that are properties of a real machine — window closure, duplicate
titles, PID reuse and restart.

## Context

- The spec's "Test seams and acceptance", the Isolated TestAnyware macOS VMs
  row, and its closing paragraph: "Verify the signed release build's entitlement
  and permission behavior rather than extrapolating from an unsigned development
  run."
- Earlier stages verified each of these on the **development-signed** bundle, in
  separate runs, each with its own evidence document:
  `resident-app-vm.md` (installation, login launch, window closed with the
  service still answering), `accessibility-status-and-consent-vm.md`,
  `desktop-application-and-windows-vm.md` (duplicate titles, the identity
  comparison), `desktop-references-and-permission-vm.md` (stale, wrong-kind and
  malformed references, absent and revoked consent), `desktop-focus-vm.md` and
  `desktop-remembered-windows-vm.md`.
- What this leaf owns is what none of them could show: that the same behaviour
  holds **on the release artifact**, composed rather than sliced.
- Existing routes to reuse: `task app:vm-verify`, `app:vm-verify-desktop`,
  `-desktop-focus`, `-desktop-remembered`, `-accessibility`, and the shared
  `scripts/vm-verify-lib.sh` / `vm-verify-desktop-lib.sh`.

## Done when

- **One acceptance route** — `task app:vm-verify-release` — runs the composed
  platform cases against the notarized, stapled, quarantined bundle on a
  Gatekeeper-enforcing clone, in a single VM session rather than a clean VM per
  case.
- Covered, each asserted and not merely performed:
  - the hardened runtime with the empty entitlements file, and the Accessibility
    prompt and System Settings entry attributed to **Koine**;
  - login launch through `SMAppService.mainApp` across a restart with **no
    client installed**, Koine quit first so macOS's reopening cannot be what
    starts it (`resident-app-vm.md`'s method);
  - the management window closed with the listener and provider observation
    still running;
  - consent **absent** and consent **revoked**, each an OS-permission error at
    the original response path, distinguishable from a missing capability, with
    no dialog raised by a read;
  - window **closure**, **duplicate titles** under distinct stable references,
    **PID reuse** as far as it can be observed (a live PID claimed at another
    start instant), and **restart** behaviour for each kind of reference.
- **A second Accessibility consent request** is attempted — in the same run and
  in a later one — closing the item
  `accessibility-status-and-consent-vm.md` explicitly left open ("Whether macOS
  shows the dialog again is unverified").
- `docs/verification/release-acceptance-vm.md` records it, with its own "what
  this does not show", and says for each item which earlier document it
  supersedes on the release build and which it merely repeats.

## Notes

**Composed, not re-sliced.** Every case here has passed before on a development
build. The leaf's worth is in running them against the release artifact in one
session, so the failure mode it exists to catch is *notarization or the release
path changed something* — a different quarantine state, a stapled ticket, a
provider loaded from a quarantined bundle. Where a case is genuinely unchanged
and already covered, say so and cite the document rather than padding the run.

**Do not let a green run be the only evidence.** Two hazards the earlier VM
documents recorded, both of which produced a passing run that proved nothing:
a step that reads a state only *after* acting cannot fail (`desktop-focus-vm.md`
— an earlier run passed a minimised step without ever seeing the window
minimised), and TestAnyware's false "Process timed out after 30s" comes in
bursts, so `launch` must not end a run on the status of its `open`. Assert the
precondition before acting, every time.

**A failure here is a finding against the stage that owns the slice**, not this
leaf's to absorb — add a repair leaf. That is most likely for anything that
changes under a quarantined, stapled bundle.

**The identity guarantee is not established by inspection.** The spec is
explicit that the native identity guarantee must be proven by these seams and
"neither is established by diagrams or the current source inspection". Assert
against an independent native witness where one is available, as the earlier
desktop runs did, rather than against Koine's own answer.

## Decisions (running log)

- **The Gatekeeper machinery is extracted, not copied.** `vm-verify-notarized.sh`
  owns four hard-won pieces this run needs verbatim — `enforce_gatekeeper` /
  `enable_developer_id` (the second switch no `spctl` spelling reaches on macOS
  26.5), `install_app_quarantined` (attribute asserted *before* anything
  launches), the first-run dialog read as accessibility text rather than OCR, and
  `await_service` (the refused-plugin dialog that blocks startup). Copying them
  would give two divergent copies of a procedure that cost several runs to
  establish. They move to `scripts/vm-verify-gatekeeper-lib.sh`, sourced by both,
  and the notarized run keeps its own discriminating assertions on the dialog
  text the shared helper leaves in `DIALOG_TREE`.
- **One VM session, and its order is forced.** Consent-absent cases must precede
  the grant; the second consent request in "a later run" of Koine needs consent
  absent again, so it follows revocation and a Koine restart; the VM restart that
  proves login launch destroys the desktop state every other case needs, so it is
  last. That ordering is the reason this is one script rather than six.
- **The probe's window list includes Finder's desktop, and the baseline had to
  exclude it.** The first run died on `[.windows[].title] | unique | length == 1`
  because `WindowIdentityProbe` returns Finder's desktop — an `AXScrollArea` with
  a null title and no window-server id — alongside the three real windows. The
  fact is already in `desktop-application-and-windows-vm.md` ("Finder's desktop
  is an element of its window list and no window"); the run now counts `AXWindow`
  rows. The jq condition was checked green against the exact payload that failed
  and red against a mutation, so the filter is evidence rather than a guess.
- **Koine's window count is never equated with the probe's.** The two
  enumerations need not agree row for row, so each side's count is a baseline and
  every later claim is a change against it: one window closes, each side loses
  exactly one. Coupling them would have made the run depend on an incidental fact
  about how both walk the accessibility tree.
- **Revocation is driven until the switch reports it, and consent is granted by
  Add.** Three runs failed downstream with "windows were still listed 60s after
  consent was revoked" — which reads as a finding against Koine and is not one:
  the shared library types the administrator password two seconds after clicking
  the switch and reads nothing back. With consent granted **by the switch**, that
  switch could not afterwards be turned off by any route: `agent press` answers
  HTTP 400 and a VNC click at the identical coordinates that had turned it *on*
  produced nothing at all. With consent granted by the list's **Add** control —
  the route `desktop-references-and-permission-vm.md` and `desktop-focus-vm.md`
  use — the same click raised the "Modify Settings" sheet and the switch went
  off. The run now grants by Add, tries each press route in turn, and asserts the
  control's own value; which route worked is printed into the transcript.
- **Three helpers stay local to `vm-verify-release.sh` rather than going into the
  shared libraries** — the retry-tolerant `ask`, the switch-driving helpers and
  the `AXWindow` filter. Each would be an improvement to `vm-verify-desktop-lib.sh`,
  but four routes that currently pass use that file and this leaf cannot re-run
  them; changing shared behaviour on the strength of one run is the wider blast
  radius, not the safer one.
- **Passed on the notarized 0.1.0 bundle**, transcript
  `release-20260921T002221.log`, with the nine files the run reads digested
  before and after and unchanged. The open item
  `accessibility-status-and-consent-vm.md` left — whether macOS shows the consent
  dialog again — is closed there and marked closed in that document: it does, on
  all three requests.
