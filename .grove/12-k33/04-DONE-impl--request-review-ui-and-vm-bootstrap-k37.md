# request-review-ui-and-vm-bootstrap-k37

## Goal

The user reviews enrollment requests in Koine's window: sees who is asking and
for exactly what, approves a subset or denies, and is warned prominently when
`koine:manage` is asked for. Verified in a VM by bootstrapping the first
management client this way, with no credential ever typed, pasted or shown.

## Context

What the three protocol leaves built. `KoineManagementClient` (Foundation-only;
`ManagementClient.status()` is the one operation the window polls) and its
tests; `ManagementView`, `GrantListView`, `CreateGrantView` and `StatusView` in
`KoineApp`. For the VM run: `scripts/vm-verify-lib.sh` (`start_vm`,
`install_app`, `place_window`, `click`, `value_of`, `guest`),
`scripts/vm-verify.sh` as the manual-workflow precedent, `guest_json` and the
`ask` pattern in `scripts/vm-verify-accessibility.sh` for guest reads that
survive the agent's false timeouts, and `docs/verification/resident-app-vm.md`
for the tooling workarounds and the evidence-document shape.

## Done when

- `ManagementClient` gains the request listing, approve and deny, through the
  console's GraphQL path like everything else it does, with
  `KoineManagementClientTests` covering them and their error outcomes. Pending
  requests arrive with the polled status, so a request appears in an open
  window without user action.
- The window lists pending requests, each with its client label, comparison
  code and exact requested capability set. The user can untick capabilities
  and approve the remaining subset, or deny. When `koine:manage` is among the
  requested capabilities the request carries a prominent warning that it
  permits issuing and revoking other grants, and approving it with that
  capability still ticked is a deliberate act, not the default button's. An
  outcome the server refuses (already decided, expired) is shown and the list
  refreshes. Controls carry accessibility identifiers, as the existing views'
  do, so the VM script can drive them.
- `task app:vm-verify-enrollment` runs a scripted TestAnyware VM verification
  on the signed build, in which a guest script client generates a secret,
  calls `koineRequestGrant` for `koine:manage` plus a provider capability, and
  polls; the script checks that the window shows the same label, code and
  capability set and the warning; approves a subset in the UI; and the client,
  with its unchanged secret, then manages Koine over HTTP. That first manager
  then approves a second client's request over GraphQL, a third request is
  denied in the UI and its poll says `DENIED`, and the approved grants and the
  decisions survive quitting and restarting Koine.
- `docs/verification/grant-enrollment-vm.md` records the procedure, the
  evidence and a "does not show" section for
  `release-acceptance-handoff-k11`. The README's management section covers
  request review.
- `task test` and `task app:verify` pass.

## Notes

Nothing here launches Koine, drives its UI or touches the clipboard on the
host; that is the human's rule from `resident-app-skeleton-k13`.

Keep the view a thin client: what may be approved, and every refusal, is the
server's. The capability ticks start from the request's own set, never from
`availableCapabilities`.

If the UI and the VM run together prove more than one session, decompose at
that seam: the UI with its `ManagementClient` tests first, the VM verification
second.

## Decisions (running log)

- **Requests ride the one polled operation.** `ManagementClient.status()` gained
  `requests`, every served state; the view filters to `PENDING`. No second poll
  loop, and `StatusModel`'s equal-value suppression keeps the window from
  redrawing between changes.
- **`ManagementError.rejected` gained `reason` and `requestState`, defaulted.**
  Additive like the server's extensions, so existing call sites construct it
  unchanged; only a positional pattern match needed its arity widened.
- **Ticks are stored as the unticked set per request.** What is ticked is then
  derived from the request's own `requestedCapabilities`, so nothing outside
  that set can be offered or sent, by construction.
- **The warning shows whenever `koine:manage` was requested**, ticked or not:
  it describes what the client asked for. The deliberate act is a confirmation
  dialog whose approving button has the destructive role. Seen in the VM: macOS
  then gives the dialog no default button at all, so Return neither approves nor
  dismisses; Escape cancels. The script's first expectation (Return cancels) was
  wrong and was corrected to what the platform does.
- **No Approve button is a default button**, with or without `koine:manage`:
  there may be several requests, and none is "the" default.
- **The Requests section is second in the window**, above Grants: the VM script
  clicks at on-screen centres, and a pending decision is the user's to act on.
- **A guest mutation must survive the agent's repeated execs.** Enrollment is
  idempotent in the protocol once the secret file is reused; the guest client
  keeps its first `approve` answer beside the secret and replays it.
- **Secrecy is checked in the guest.** The window's accessibility tree is
  uploaded and searched there for the secret and its digest, with the search
  first seen to find the secret in the secret's own file.
