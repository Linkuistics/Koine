# Client-requested grants and request review: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
`request-review-ui-and-vm-bootstrap-k37`: the second agreed grant workflow
through Koine's real window, performed as the bootstrap of the first management
client. It runs on the Developer ID signed `Koine.app`; there are no application
mocks, and the client is a script that knows only the endpoint descriptor. The
protocol itself is covered at the public GraphQL seam (`GrantEnrollmentTests`,
`GrantDecisionTests`, `GrantRequestLifetimeTests`) and the window's operations
in `KoineManagementClientTests`; this run is where they are seen working
together in the installed application. The tooling workarounds are in
[resident-app-vm.md](resident-app-vm.md).

## Procedure

```sh
task app                        # build and sign .build/app/Koine.app
task app:vm-verify-enrollment   # scripts/vm-verify-enrollment.sh
```

No grant is created in the window and no credential exists when the run starts.
The guest client, `scripts/vm-verify-enrollment-client.py`, makes its own
32-byte secret into a `0600` file, sends Koine only the secret's SHA-256 digest,
and later presents the unchanged secret as its bearer. It never prints the
secret or the digest, and nothing brings either to the host. The script then
checks, in order:

1. A fresh Koine shows "No requests are waiting."
2. The first client requests `koine:manage`, `desktop:read` and
   `desktop:control`. Its poll says `PENDING`, and its secret is refused
   `koineManagement` with the ordinary `permission` error.
3. With nothing clicked or focused, the window comes to show the request: the
   client's label, the comparison code the client's receipt carries, a tick for
   exactly the three requested capabilities, each set, and the warning that
   `koine:manage` permits issuing and revoking other grants.
4. The window's whole accessibility tree is uploaded to the guest and searched
   there for the secret and its digest: neither occurs. The same search is first
   seen to find the secret in the secret's own file, so a clean result is not a
   search that cannot find anything.
5. `desktop:control` is unticked. Approve, with `koine:manage` still ticked,
   raises a confirmation and decides nothing: the poll still says `PENDING`.
   Return decides nothing either, because the dialog has no default button;
   Escape cancels it, and the poll still says `PENDING`.
6. Approve again and "Approve with koine:manage". The request leaves the list,
   the client's poll says `APPROVED` with an `ACTIVE` grant holding exactly
   `koine:manage` and `desktop:read`, and the grant's row appears in the window.
7. The client, its secret unchanged, is that grant (`ownGrant`) and reads
   `koineManagement`, where its own request is `APPROVED`. This is the first
   management client, and no credential was typed, pasted or shown to make it.
8. A second client requests `desktop:read`. The window shows it; the first
   manager approves it over GraphQL; its poll says `APPROVED`; the window drops
   it on its own; and its grant, without `koine:manage`, is refused
   `koineManagement`.
9. A third client requests `koine:manage`; its row carries the warning; Deny in
   the window; its poll says `DENIED` with no grant, and its secret is refused
   `koineManagement`.
10. Koine is quit and started again. The first manager still manages; `requests`
    reports the three decisions and `grants` the two active grants with their
    capability sets; the second client's secret still works; the third still
    polls `DENIED`; the window shows no request waiting and the first grant's
    row; and the window's tree still holds no secret or digest.

Guest commands are repeated by the agent's false "timed out" reports
([resident-app-vm.md](resident-app-vm.md)), so every client case is safe to run
again: enrollment reuses the secret file, which the protocol answers with the
original receipt, and the client keeps its first `approve` answer and prints
that again. A run is about eight minutes.

## What this does not show

- **A refusal shown in the window.** Two managers deciding the same request at
  once, or a request expiring between the poll and the click, reaches the window
  as `already-decided` with the request's state. Forcing that order through a
  real UI is a race the script does not run. `KoineManagementClientTests` shows
  the client surfacing `already-decided` with `DENIED` and with `EXPIRED`,
  `invalid-subset` and an unknown request; the sentence the window composes from
  them, and its re-read of the lists afterwards, were not seen in a VM.
- **Expiry, retention, the pending cap and the enrollment rate limit** are not
  exercised here; they need a clock or a volume the VM run does not have, and
  are covered by `GrantRequestLifetimeTests`. The run makes three enrollments
  and leaves at most one pending, well inside both limits.
- **That the user compares the code.** The run shows the window's code equals
  the client's receipt. A client that displays it, and a person who looks, are
  outside it.
- **Several requests pending together.** At most one was pending at a time, so
  the window's layout with many, and scrolling to reach one, were not driven.
- **Revocation of an enrolled grant** through the window, and the secret's 401
  after it, are `GrantEnrollmentTests`' and were not repeated here.
- **The clipboard** is never touched by this workflow, so nothing about it is
  shown; the search in step 4 covers what the window exposes to accessibility,
  not pixels.
- Gatekeeper assessments are disabled in the golden image and the route sets no
  quarantine attribute, as in every run here. **Closed** for the build itself by
  [notarized-release-vm.md](notarized-release-vm.md), which runs the notarized,
  quarantined bundle on a Gatekeeper-enforcing clone; the enrollment cases
  themselves are `grant-workflow-acceptance-k43`'s.

## Evidence

Run of 2026-09-20, transcript `enrollment-20260920T085102.log`, against the
bundle built from the working copy on `90faa04` that this leaf commits, signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`, un-notarized. The
executable and the six scripts the run reads were digested before and after and
did not change. VM: clone of `testanyware-golden-macos-tahoe`, macOS 26.5
(25F71), arm64. Result: **passed**, every expectation above.

Two runs before it stopped on the script's expectations, not on Koine. The first
expected Return to cancel the confirmation; the dialog has no default button, so
Return does nothing, which is the stricter behaviour and what step 5 now checks.
The second compared the grant's capabilities in the order they were ticked;
Koine stores a grant's capabilities as a sorted set, and the grant was the
approved subset. In both, Koine's answers in the transcript were correct.

Lines over 300 characters are cut at `[…]`.

```
== Start Koine: no grant exists and no request is waiting

== A client makes its own secret and asks for koine:manage and the desktop capabilities
{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "comparisonCode": "6DXY-VS8Q"}}}}
-rw-------  1 admin  staff  43 Sep 19 22:51 /Users/admin/koine-secret-first
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "clientLabel": "first-manager", "comparisonCode": "6DXY-VS8Q", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "PENDING", "grant"[…]
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": null}, "errors": [{"message": "This operation requires the koine:manage capability.", "locations": [{"line": 1, "column": 3}], "path": ["koineManagement"], "extensions": {"phase": "execution", "permissionClass": "capabilit[…]
{"case": "shown-in", "secret": true, "digest": false, "bytes": 43}

== The window shows the request, with no user action: label, code, exact capability set, warning
Label: first-manager  Code: 6DXY-VS8Q  Client's code: 6DXY-VS8Q
Capabilities offered: ["desktop:control","desktop:read","koine:manage"]
Warning: text request-manage-warning-c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a AXStaticText text This client asks for koine:manage, which permits issuing and revoking other grants, including more koine:manage grants.
{"case": "shown-in", "secret": false, "digest": false, "bytes": 99326}

== Untick desktop:control; Approve alone decides nothing while koine:manage is ticked
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "clientLabel": "first-manager", "comparisonCode": "6DXY-VS8Q", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "PENDING", "grant"[…]
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "clientLabel": "first-manager", "comparisonCode": "6DXY-VS8Q", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "PENDING", "grant"[…]
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "clientLabel": "first-manager", "comparisonCode": "6DXY-VS8Q", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "PENDING", "grant"[…]

== Approve the subset, confirming koine:manage
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "clientLabel": "first-manager", "comparisonCode": "6DXY-VS8Q", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APPROVED", "grant[…]
Grant row: ["first-manager","desktop:read, koine:manage","Active","Revoke"]

== The client, its secret unchanged, manages Koine over HTTP
{"case": "own", "status": 200, "response": {"data": {"koine": {"ownGrant": {"grantId": "c95ac9e9-065b-4dbd-ab6f-ace84e735d3e", "clientLabel": "first-manager", "capabilities": ["desktop:read", "koine:manage"], "state": "ACTIVE"}}}}}
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": {"requests": [{"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "clientLabel": "first-manager", "comparisonCode": "6DXY-VS8Q", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APP[…]

== A second client asks; the window shows it; the first manager approves it over GraphQL
{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "c09821b5-a11c-42c9-b7a7-614c6b0f1ca9", "comparisonCode": "RNHR-9EKZ"}}}}
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": null}, "errors": [{"message": "This operation requires the koine:manage capability.", "locations": [{"line": 1, "column": 3}], "path": ["koineManagement"], "extensions": {"phase": "execution", "permissionClass": "capabilit[…]
{"case": "approve", "status": 200, "response": {"data": {"koineApproveGrantRequest": {"grantId": "78005a55-e4ad-4400-aecd-bc619479a60d", "clientLabel": "second-client", "capabilities": ["desktop:read"], "state": "ACTIVE"}}}}
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c09821b5-a11c-42c9-b7a7-614c6b0f1ca9", "clientLabel": "second-client", "comparisonCode": "RNHR-9EKZ", "requestedCapabilities": ["desktop:read"], "state": "APPROVED", "grant": {"grantId": "78005a55-e4ad-4400-[…]
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": null}, "errors": [{"message": "This operation requires the koine:manage capability.", "locations": [{"line": 1, "column": 3}], "path": ["koineManagement"], "extensions": {"permissionClass": "capability", "requiredCapabilit[…]

== A third client asks for koine:manage and is denied in the window
{"case": "enrol", "status": 200, "response": {"data": {"koineRequestGrant": {"requestId": "c84b661d-b077-4bca-a43b-4520584e87aa", "comparisonCode": "W627-PF34"}}}}
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c84b661d-b077-4bca-a43b-4520584e87aa", "clientLabel": "third-client", "comparisonCode": "W627-PF34", "requestedCapabilities": ["koine:manage"], "state": "DENIED", "grant": null}}}}
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": null}, "errors": [{"message": "This operation requires the koine:manage capability.", "locations": [{"line": 1, "column": 3}], "path": ["koineManagement"], "extensions": {"phase": "execution", "permissionClass": "capabilit[…]

== Quit and restart Koine: the grants and the decisions are still there
{"case": "manage", "status": 200, "response": {"data": {"koineManagement": {"requests": [{"requestId": "c11d9af3-0b3b-4bcb-8a6b-ddf73f3fa28a", "clientLabel": "first-manager", "comparisonCode": "6DXY-VS8Q", "requestedCapabilities": ["koine:manage", "desktop:read", "desktop:control"], "state": "APP[…]
{"case": "own", "status": 200, "response": {"data": {"koine": {"ownGrant": {"grantId": "78005a55-e4ad-4400-aecd-bc619479a60d", "clientLabel": "second-client", "capabilities": ["desktop:read"], "state": "ACTIVE"}}}}}
{"case": "poll", "status": 200, "response": {"data": {"koineGrantRequest": {"requestId": "c84b661d-b077-4bca-a43b-4520584e87aa", "clientLabel": "third-client", "comparisonCode": "W627-PF34", "requestedCapabilities": ["koine:manage"], "state": "DENIED", "grant": null}}}}
{"case": "shown-in", "secret": false, "digest": false, "bytes": 98258}

== PASSED — transcript in .build/vm-verify/enrollment-20260920T085102.log
```

The request and the confirmation as the screen showed them, and the window after
the restart:
[request.png](grant-enrollment/request.png),
[manage-confirmation.png](grant-enrollment/manage-confirmation.png),
[after-restart.png](grant-enrollment/after-restart.png).

No behaviour of the signed build differed from the spec in this run.
