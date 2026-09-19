# request-expiry-retention-and-limits-k36

## Goal

Bound enrollment in time and volume: pending requests expire, terminal status
is forgotten after its retention while its digest is not, and anonymous
enrollment cannot fill the store or crowd out authenticated clients.

## Context

What k34 and k35 built. `RequestPolicy` in `KoineCore` holds every
request/response limit as a value, and `KoineServer(dataDirectory:policy:)` is
the embedding constructor; `TransportPolicyTests` is the precedent for testing
limits at the public seam.

## Done when

Shown by tests at the public GraphQL seam, with time moved by an injected
source and no real waiting:

- The embedded server takes a time source as a construction parameter,
  defaulting to the wall clock. It is not a GraphQL field, an HTTP header or an
  environment variable, and the application does not set it. Durations that
  must survive a restart are stored as wall-clock instants.
- A request still pending 24 hours after submission is `EXPIRED`: the
  requester's poll says so, `koineManagement.requests` says so, and approving
  or denying it gives the already-decided outcome. Expiry holds across a
  restart that spans the deadline. An approved grant never expires, however old
  its request.
- Seven days after a request became terminal (approved, denied or expired),
  lookup of that request returns `unavailable` to a status-only requester and
  it leaves `requests`. For an approved request whose grant is still active,
  decide from the spec whether `koineGrantRequest` under the grant is
  `unavailable` or null after retention, and record it; the grant itself is
  unaffected.
- Digest tombstones outlive retention: after a denied or expired request's
  status is gone, its digest still cannot start a new request or become a
  manual grant.
- Unapproved requests are capped. At the cap a new `koineRequestGrant` is
  refused with a distinguishable outcome and stores nothing; an idempotent
  retry of an existing pending request still succeeds; expiry or a decision
  frees a slot.
- Enrollment is rate-limited on its own budget: exhausting it refuses further
  anonymous `koineRequestGrant` calls (decide between HTTP 429 and a GraphQL
  error, and record it in the spec) while a client with an active grant, a
  status-only poll and the local console are unaffected at the same moment.
  The limit follows the injected time source.
- The cap, the rate and the two durations are named values beside the other
  limits in `RequestPolicy`, stated in the spec or README with their defaults.
- `task test` passes.

## Notes

The spec fixes 24 hours and seven days; it does not fix the cap or the rate.
Choose defaults proportionate to a single-user loopback service where a
legitimate client enrols once, and say why in the README. Every local process
shares the loopback address, so the rate limit is global, not per peer.

Whether expiry is applied lazily at read time or by a sweep is an
implementation choice; the observable rule is that no read or decision ever
treats an over-age pending request as pending. Deleting retained status must
not delete the tombstone.

## Decisions (running log)

- **Expiry is computed, never written.** `EXPIRED` is a stored `PENDING` row
  whose `submitted_at` plus the lifetime has passed
  (`GrantRequestRecord.standing`). No sweep exists, so there is no moment a
  sweep has not reached; a restart across the deadline needs nothing.
  `Authority` applies it before every decision; the store stays clock-free and
  takes the decision instant as an argument.
- **Retention deletes nothing.** Past retention the row stops being served and
  stays as the tombstone, so the store's digest-uniqueness checks needed no
  change and the secret still authenticates as status-only, which is what lets
  its poll be `unavailable` rather than 401. Trade-off accepted: label, code and
  capability names stay in the user-only store file. A purge to a separate
  tombstone table would have to keep the request ID and digest anyway.
- **Approved request past retention, under its active grant: `unavailable`,
  not null.** The spec's lookup rule makes no exception for the grant, and null
  already means "no request produced this grant". Recorded in the spec.
- **Retry once the status is gone: `credential-in-use`.** There is no receipt
  left to repeat and the digest is still taken; the spec's table row is widened.
- **Cap is a GraphQL error, rate limit is HTTP 429.** The cap depends on store
  state and is an outcome of the action (`failed`, `pending-request-limit`),
  counted and inserted inside `Authority`'s boundary. The rate limit is decided
  after the anonymous shape check and before validation, so no action began and
  there is no action path; 429 carries `Retry-After`. Requests without a
  credential that are not enrollment never spend it and stay 401, which the VM
  scripts rely on. Refused attempts spend nothing.
- **Defaults: 16 pending; 10 enrollments per 60 s, global, in memory.**
  Reasoning in the README. `RequestPolicy.version` stays 1: nothing is released,
  and the values join `version1` rather than making a second policy.
- **Pre-existing rows** (development stores only) count their lifetime and
  retention from the migration.
- No in-session reviewer was spent: each claim is held by a test at the public
  seam, and a mutation that disables expiry failed exactly the expiry tests.
