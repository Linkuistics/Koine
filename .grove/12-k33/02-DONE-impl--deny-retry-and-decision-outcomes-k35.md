# deny-retry-and-decision-outcomes-k35

## Goal

Constrain what `request-approve-and-poll-k34` opened: a manager can deny, every
decision outcome is explicit, a client whose response was lost can retry
without splitting its identity, and a credential digest names at most one thing
for ever.

## Context

What k34 built (its commit names the handle): the request record and its
migration, the status-only principal, approval through `Authority`. The
scripted `GrantStore` in `RevocationOrderingTests` is the precedent for a store
that fails on demand.

## Done when

Shown by tests at the public GraphQL seam:

- `koineDenyGrantRequest(requestId:)` is served, requires `koine:manage`,
  commits durably and returns the request as `DENIED`. The requester's poll
  then shows `DENIED`, explicitly, with a null `grant`; the denial survives a
  restart.
- Decision outcomes are explicit and distinguishable by a client: a request ID
  that names nothing; a request already approved, denied or expired; a subset
  containing a capability that was not requested. None of them changes state,
  and approval never resurrects a denied or expired request or one whose grant
  was revoked. Use the existing error vocabulary (`unavailable` for the missing
  ID, as `koineRevokeGrant` does); where the vocabulary cannot tell two
  outcomes apart, settle the representation, record it in the spec's
  "Management authority and surface", and keep it additive to the design SDL.
  Decide and record whether an empty approved subset is invalid.
- Retrying `koineRequestGrant` with the same digest, label and capability set
  returns the original request ID and code, while pending and also after
  approval, and creates nothing. The same digest with a different label or set
  is a conflict and changes nothing. Capability-set comparison ignores order
  and duplicates.
- A digest belonging to an active grant, a revoked grant, or a denied request
  cannot start a new request: the client needs a fresh secret. Manual
  `koineCreateGrant` retries a random collision against requests as well as
  grants before committing.
- After the approved grant is revoked, the requester's secret gets HTTP 401 for
  everything, including `koineGrantRequest`, on an existing keep-alive
  connection and after restart.
- A store or commit failure during approval or denial reports a `failed` error
  and no success; afterwards the request is still pending and no grant exists.
- The acceptance case from the spec's management row, as one test: a pending
  requester cannot approve itself, enumerate others, or use provider
  operations.
- `task test` passes; the README reflects deny and the retry rule.

## Notes

Revocation between preflight and the dispatch of an approve or deny action is
already covered by the engine's admission recheck; add an ordering test only if
approval introduced a new path around it.

Expired requests appear in these rules but expiry itself arrives in
`request-expiry-retention-and-limits-k36`; write the already-decided handling
so `EXPIRED` is one more terminal state, not a special case.

## Decisions (running log)

- Outcomes that share `failed` are told apart by an additive `extensions.reason`
  (`already-decided` with `extensions.requestState`, `invalid-subset`,
  `enrollment-conflict`, `credential-in-use`); a missing ID stays `unavailable`.
  Extensions are outside the SDL, so the design schema is untouched. Recorded in
  the spec's "Management authority and surface".
- An empty approved subset is valid, matching `koineCreateGrant` with an empty
  set; denial is the refusal. Recorded in the same place.
- An identical retry returns the original receipt in every request state,
  denied included: it starts nothing, and the poll shows `DENIED`. A changed
  retry is a conflict in every state.
- Digest uniqueness across requests and grants is the store's, checked inside
  the inserting transaction; approval alone binds a request's own digest. So
  `koineCreateGrant`'s existing collision retry covers requests with no change
  to it.
- Already-decided is `state != pending`, and status-only is `state != approved`,
  so `EXPIRED` joins as one more case of each with no new branch.
- No new ordering test: approve and deny take the same `Authority` boundary and
  the same engine recheck as revocation; no path goes around it.
- The leaf's one reviewer found no authority or uniqueness defect. Applied: the
  spec no longer claims a retry learns no more than a poll (it is answered on
  digest, label and set, and the receipt is not secret); `credential-in-use` on
  approval is in the spec table; a SQLite rollback test, denied-bearer
  confinement and the revoked retry state were added. Accepted trade-offs:
  `isStatusOnly` admits by exclusion so `EXPIRED` needs no branch; the
  store-returned-false branches and concurrent decisions sit behind the
  `Authority` lock and have no test of their own.
