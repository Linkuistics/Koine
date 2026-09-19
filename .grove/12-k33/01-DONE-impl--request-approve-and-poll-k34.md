# request-approve-and-poll-k34

## Goal

A client with no credential enrols itself and a manager approves it, end to
end over the public GraphQL API: the client submits the digest of a secret it
generated, polls its own request with that secret, a `koine:manage` principal
lists and approves it, and the same secret then works as an ordinary grant.

## Context

`Principal`, `Authority.authenticate(bearer:)` and `Authority.check` in
`KoineCore`; the bearer handling in `KoineServer.respond(to:engine:)`, which
today answers 401 before the engine runs; mutation preflight in `Engine`;
`GrantStore` and `SQLiteGrantStore` (add a migration, do not rewrite the first
one); `Credential` for digest canonicality and constant-time comparison;
`GrantManagementTests` for the test style and the pinned `KoineManagement`
field list.

## Done when

Shown by tests at the public GraphQL seam, over HTTP wherever admission is the
subject:

- `koineRequestGrant` is served with `KoineRequestGrantInput` and
  `KoineGrantRequestReceipt` as in the design SDL. With no `Authorization`
  header it is admitted only when it is the single selected root action of the
  operation: a second root action, an alias repeating it, or a query alongside
  it in the selected operation is refused before anything is stored. Skipped
  fields and unselected operations in the document do not count, as for
  preflight. Any other operation without a bearer is still HTTP 401.
- The digest must be canonical (64 lower-case hex); every requested capability
  must be one `availableCapabilities` lists; the label and the set are stored
  as submitted and never change. The receipt carries a request ID and a short,
  non-secret comparison code. A pending request confers no authority.
- `koineGrantRequest` is served. A bearer whose digest names a pending request
  is a status-only principal: it reads its own request (ID, label, code,
  requested capabilities, state, null `grant`) and nothing else. Under it,
  `koine`, `koineManagement`, every provider field and every mutation are
  refused with the agreed permission shape, alone or mixed into the same
  operation as `koineGrantRequest`; it cannot approve itself or see another
  request. Under an ordinary grant that did not come from a request,
  `koineGrantRequest` is null.
- `koineManagement.requests` lists requests for `koine:manage` and the local
  console, with the agreed permission error otherwise; the pinned field list
  test is updated to include it.
- `koineApproveGrantRequest(requestId:capabilities:)` requires `koine:manage`,
  goes through `Authority`, and in one durable commit marks the request
  `APPROVED` and inserts one active grant bound to the submitted digest with
  the approved subset. Afterwards the requester's unchanged secret
  authenticates as that grant: `koineGrantRequest` shows `APPROVED` with the
  grant's metadata, `koine.ownGrant` matches, and the approved capabilities
  work. No secret appears in any response.
- The request, its approval and the resulting grant survive a server restart
  on the same data directory.
- `RequestDesktopGrant` and `PollOwnGrantRequest` from
  `docs/design/desktop-operations.graphql` validate and run unchanged.
- Introspection stays inside `RequestPolicy`; `task test` passes; the README's
  management section describes the workflow as served.

## Notes

Left to later leaves, so do not build them here: deny, retry/conflict and the
full uniqueness rules (`deny-retry-and-decision-outcomes-k35`); expiry,
retention, the cap and the rate limit
(`request-expiry-retention-and-limits-k36`). What this leaf must not do is
leave them unsafe in the meantime: approving a request whose digest already
belongs to a grant must fail rather than create a second identity, which the
grants table's unique digest already guarantees if approval is one commit.
Approving with a capability outside the requested set, or a request that is
not pending, must at least refuse; k35 makes those outcomes precise.

The comparison code's alphabet and length are yours to choose: short enough to
compare by eye, not derived from the digest in a way that discloses it. Record
the choice in the spec's "Client-requested grant" if it becomes contract.

The status-only principal is a new `Principal` case, not a grant with an empty
capability set: `FieldAuthority.admitted` must not admit it, or every
`admitted` field silently opens to unapproved clients.

## Decisions (running log)

- The two admission cases are two `FieldAuthority` cases, `.anonymousEnrollment`
  and `.requestStatus`, checked where every other field is. `Principal.requester`
  and `.anonymous` have no capability set at all (`nil`, not empty), so
  `.admitted` and every `.capability` refuse them by construction.
- The anonymous shape rule lives in `Engine.execute`, on the same
  `rootMutationActions` preflight uses, before validation. Under no bearer,
  anything that is not that shape is 401, a syntax error or an undecodable body
  included. A well-shaped enrollment that fails validation is 401 too: the
  validator's messages suggest real type and field names.
- `koineRequestGrant` is anonymous only: with any live bearer it is refused in
  preflight (403, `permission`), since the design SDL says "Anonymous enrollment
  only".
- Authentication lets a grant with the presented digest decide alone, whatever
  its state; a request is consulted only when no grant has the digest. A revoked
  grant's secret therefore never falls back to a requester.
- Status-only admission is for a `PENDING` request only. An operation in flight
  when approval commits is refused at its next check; the next request
  authenticates as the grant.
- Served `KoineGrantRequestState` is `PENDING APPROVED`; `DENIED` and `EXPIRED`
  join with k35 and k36 (serve only what is implemented).
- Comparison code: eight random characters of `ABCDEFGHJKMNPQRSTVWXYZ23456789`
  shown as `XXXX-XXXX`. The spec now says it is random and opaque; the alphabet
  and length are not contract.
- Refusals k35 will make precise are all `failed` (or `unavailable` for a
  missing request ID) with a null result. A duplicate request digest is
  `failed` for now; k35 owns retry and conflict.
- `GrantStore` grew four methods rather than a second store protocol: approval
  has to be one commit over both tables.
- The leaf's one in-session reviewer was spent on the two admission cases. Valid
  and fixed, each with a test seen failing first: a skip condition that is not a
  JSON boolean is now undecided, so included (the library coerces numbers, and
  `{"s": 0}` hid a second action from the shape rule and from preflight, a flaw
  preflight already had); a status-only principal is refused root meta-fields
  (403, `permission`), because the library resolves `__schema` and `__type`
  outside every field check; several operations with none named select nothing.
  Visible trade-offs, left: approving an empty subset yields a grant with no
  capabilities, as `koineCreateGrant` allows; a requester whose approval commits
  between authentication and admission gets one 401 and succeeds on retry.
  Left to k36, which owns them: unbounded anonymous storage and the per-request
  scan of every request row in `authenticate`.
