# grant-enrollment-k10

## Goal

Plan the fifth working increment: the client-requested grant workflow. A client
generates its own secret, requests capabilities, and the user approves or
denies in Koine's native UI — or a `koine:manage` client does so over GraphQL —
completing the second of the two agreed grant workflows.

## Context

Spec sections: "Client-requested grant", "Management authority and surface",
the anonymous-enrollment admission case in "Mutation preflight and revocation",
and the management row of "Test seams and acceptance". The operations
`RequestDesktopGrant` and `PollOwnGrantRequest` in
`docs/design/desktop-operations.graphql` are the client's view.

## Done when

The tree holds narrow impl leaves delivering:

- **Enrollment protocol** (public GraphQL seam): anonymous `koineRequestGrant`
  admitted only as the single root action of its operation; known, immutable
  requested capabilities; request ID and comparison code; idempotent retry for
  an identical digest/label/capability set, conflict otherwise; digest
  uniqueness across requests, active grants and revoked tombstones;
  `koineGrantRequest` authorized by proof of the submitted secret and, after
  approval, by the resulting grant; status-only credentials confer nothing
  else. `koineApproveGrantRequest` approves a subset atomically into at most
  one grant; `koineDenyGrantRequest`; missing, already-decided and
  invalid-subset outcomes are explicit. Decisions persist across restart;
  pending requests expire after 24 hours; terminal status is retained seven
  days then `unavailable`; tombstones remain. Pending-request cap and an
  enrollment rate limit independent of authenticated execution. A requester
  cannot approve itself, list others or use provider operations.
  `koineManagement.requests` lists requests for managers.
- **Native review UI** (TestAnyware seam): pending requests with label,
  comparison code and exact capability set; approve a subset or deny; a
  prominent warning when `koine:manage` is requested; the first
  management-client bootstrap performed this way in a VM.

## Notes

Follow `desktop-delivery-k3`'s cutting shape (see `resident-app-manual-grants-k7`).

This stage depends only on `resident-management-k12` (the stage `resident-app-manual-grants-k7` planned). It is ordered
after the desktop path because the manual workflow already lets ModalAnyware
proceed and the desktop path carries more unproven risk. If the human would
rather ModalAnyware exercise enrollment earlier, reordering this stage ahead
of `native-provider-contribution-k8` is safe and costs nothing.

The 24-hour and seven-day clocks need an injectable time source to be testable
at the public seam without waiting; that is a construction parameter of the
embedded server, not a public API.

## Decisions (running log)

**One stage, not several.** The protocol without the UI is already useful (a
manually granted manager enrols others), but the root decomposition fixed this
as one increment; that split is the stage's leaf order instead. Reordering
ahead of the provider stages is moot: they are complete.

**Cut as stage `client-enrollment-k33`, four impl leaves.** Request, approve
and poll as the walking skeleton carrying both new admission cases; then deny,
retry and the explicit decision outcomes; then everything that needs a clock
or a counter; then the review UI. The stage slug differs from this leaf's so a
bare slug still resolves.

**The UI leaf carries its own VM verification**, following
`desktop-provider-k27` rather than `resident-management-k12`'s closing VM
leaf: a UI cannot be launched on the host, so a UI-only leaf could not be seen
working. It names the seam to decompose at if it proves too big.

**The status-only principal is a new admission case in the first leaf**, not
deferred: it is the stage's main security risk, and `FieldAuthority.admitted`
would otherwise open to unapproved clients.

**No question for the human arose.** The approved design specifies the
protocol; what it leaves open (comparison-code form, the cap and rate values,
the representation of decision outcomes, 429 versus a GraphQL error) are
implementation choices each leaf is told to settle and record in the spec. No
research, prototype or review leaf is added.
