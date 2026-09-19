# client-enrollment-k33 — brief

## Goal

The fifth working Koine: a client generates its own bearer secret, requests
capabilities, and is approved or denied by the user in Koine's native UI or by
a `koine:manage` client over GraphQL. This completes the second of the two
agreed grant workflows, and is how the first management client is
bootstrapped without any credential being typed or pasted. Planned by
`grant-enrollment-k10`.

## Done when

- **Enrollment protocol** (public GraphQL seam): anonymous `koineRequestGrant`
  admitted only as the single root action of its operation; known, immutable
  requested capabilities; request ID and comparison code; idempotent retry for
  an identical digest/label/capability set, conflict otherwise; digest
  uniqueness across requests, active grants and revoked tombstones.
  `koineGrantRequest` is authorized by proof of the submitted secret and, after
  approval, by the resulting grant; a status-only credential confers nothing
  else. `koineApproveGrantRequest` approves a subset atomically into at most one
  grant; `koineDenyGrantRequest`; missing, already-decided and invalid-subset
  outcomes are explicit. Decisions persist across restart; pending requests
  expire after 24 hours; terminal status is retained seven days then
  `unavailable`; tombstones remain. A pending-request cap and an enrollment rate
  limit independent of authenticated execution. A requester cannot approve
  itself, list others or use provider operations. `koineManagement.requests`
  lists requests for managers. A store or commit failure never reports a
  successful approval.
- **Native review UI** (TestAnyware seam): pending requests with label,
  comparison code and exact capability set; approve a subset or deny; a
  prominent warning when `koine:manage` is requested; the first
  management-client bootstrap performed this way in a VM.

## Decomposition

Four impl leaves, in dependency order. The protocol comes first because it is a
working increment without the UI: after the first leaf, a client holding a
manually created `koine:manage` grant can enrol other clients over GraphQL.

1. `request-approve-and-poll-k34` — the walking skeleton through every new
   part: anonymous admission, the durable request record, the status-only
   principal, approval into a grant, the manager's listing. It carries the
   security boundary of the two new admission cases, which is the stage's main
   risk, so nothing is deferred from that boundary.
2. `deny-retry-and-decision-outcomes-k35` — constrains what the first leaf
   opened: denial, the explicit decision outcomes, idempotent retry and
   conflict, digest uniqueness across all three populations, failure honesty.
3. `request-expiry-retention-and-limits-k36` — everything that needs a clock
   or a counter: the injectable time source, expiry, retention, the pending cap
   and the enrollment rate limit.
4. `request-review-ui-and-vm-bootstrap-k37` — the review UI and its VM
   verification in one leaf, as `desktop-provider-k27` did: a UI cannot be
   launched on the host, so a UI leaf without its VM run could not be seen
   working. It is last because a manager over GraphQL already decides requests;
   it depends on k34 and k35 (approve and deny) but not on k36.

## Pointers

- Spec: `docs/specs/machine.md`, "Client-requested grant", "Management
  authority and surface" (its table and closing paragraph), the anonymous
  enrollment admission case in "Mutation preflight and revocation", and the
  management and VM rows of "Test seams and acceptance".
- ADR: `docs/adr/bearer-grants-and-live-revocation.md`.
- Design SDL for the target shapes: `docs/design/desktop-schema.graphql`
  (`KoineRequestGrantInput`, `KoineGrantRequestReceipt`, `KoineGrantRequest`,
  `KoineGrantRequestState`). The client's view: `RequestDesktopGrant` and
  `PollOwnGrantRequest` in `docs/design/desktop-operations.graphql`; they must
  validate and run unchanged.
- Seams: public GraphQL (over HTTP where admission is the subject) for all
  protocol behaviour; a TestAnyware VM only for the real UI workflow.

## Notes

**What this stage builds on.** `Principal` already has an `anonymous` case that
admits nothing, and the HTTP front answers 401 to a request with no bearer
before the engine sees it. `Authority` is the one serialized boundary;
`authenticate(bearer:)` resolves a digest to an active grant and nothing else.
`GrantStore` and its SQLite implementation hold grants only, with a unique
digest column and a migrator. `KoineManagement`'s served field list is pinned
by `GrantManagementTests`, and introspection must stay inside `RequestPolicy`
as schema is added. `ManagementClient.status()` is the one operation the window
polls. `RevocationOrderingTests`' scripted `GrantStore` and the engine's
`OrderingHook` are the means of forcing a store failure or an order at the
public boundary.

**Two new admission cases, both explicit.** No bearer at all is anonymous
enrollment and admits exactly one thing: an operation whose only selected root
action is `koineRequestGrant`. Anything else without a bearer stays HTTP 401,
which existing VM scripts rely on. A bearer whose digest names a request that
is pending, denied or expired is a status-only principal: it may select
`koineGrantRequest` and nothing else, and mixing it with any other field gains
nothing. After approval the same bearer authenticates as the resulting grant;
after that grant is revoked it is 401. Neither case is a fallback reached by
failing another.

**Approval is an authority change.** It creates a grant, so it goes through
`Authority`, not straight to the store, and "at most one grant" is a property
of one durable commit that moves the request to `APPROVED` and inserts the
grant together.

**Serve only what is implemented** continues to bind: each leaf serves the
fields it makes real. The design SDL is the target, not something to stub.

**The human's host rule binds** (`resident-app-skeleton-k13`): launching
Koine, driving its UI or touching the clipboard happens in a TestAnyware VM,
never on the host.

**What `request-approve-and-poll-k34` left.** The admission cases are
`FieldAuthority.anonymousEnrollment` and `.requestStatus`; `Principal.requester`
is admitted only while its request is `PENDING`, so k35 widens
`Authority.admits` and `authenticate` for denied requests. Every refusal k35
makes precise is `failed` today (a missing request ID is `unavailable`), and a
duplicate request digest is a bare `failed`. The served
`KoineGrantRequestState` is `PENDING APPROVED` only. For k36: anonymous
requests are unbounded, and `Authority.authenticate` reads every request row on
every authenticated call, so the cap bounds that scan too. `GrantEnrollmentTests`
has the helpers, and reads the design operations from the file unchanged.

**What `deny-retry-and-decision-outcomes-k35` left.** Already-decided is
`state != .pending` and status-only is `GrantRequestState.isStatusOnly`
(`!= .approved`), so k36 adds `EXPIRED` as a case and both rules take it in.
Request outcomes that share `failed` carry `extensions.reason` (the table in the
spec's "Management authority and surface"); k36's cap and rate limit need their
own reasons there, and k37's UI reads `already-decided` with
`extensions.requestState` when two managers decide at once. The store owns digest
uniqueness across both tables, so tombstones k36 keeps must stay rows those
checks see. An identical retry answers from the stored request in every state,
which k36's retention has to decide about once the row is gone.
`GrantDecisionTests` holds the decision cases; `ScriptedStore` fails `approve`
and `deny` on demand.

**What `request-expiry-retention-and-limits-k36` left.** `EXPIRED` is served
and is never stored: every request that is served or decided on passes through
`Authority.standing`, so k37's UI sees it in `requests` like any state, and a
request past retention simply is not listed. Enrollment goes through
`Authority.enrol`. The UI's polling is the console's and spends none of the
enrollment budget; a VM script that enrols more than 10 times in a minute meets
HTTP 429, and one that leaves 16 requests pending meets `pending-request-limit`.
`Harness(clock:)` with `TestClock` moves the server's time.

No research, prototype or review leaf is added, and no question for the human
arose: the protocol is fully specified by the approved design. Notarization,
Gatekeeper and the supported matrix stay with `release-acceptance-handoff-k11`.
