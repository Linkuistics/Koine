# revocation-ordering-and-store-failure-k15

## Goal

Harden the revocation path `grant-listing-and-revocation-k14` opened: prove the
serialized authority boundary under controlled ordering, and make every store
failure fail closed without ever reporting success.

## Context

- Spec: "Mutation preflight and revocation" (the revocation/dispatch race and
  the read re-check before publication), "Grants and management" (store
  durability), and the "Public GraphQL authorization" and "Public GraphQL
  management" rows of "Test seams and acceptance".
- Read k14's commit for the authority boundary it built.

## Done when

- Revocation between preflight and dispatch prevents that dispatch; when
  dispatch wins, the admitted action finishes. Both orders are forced
  deterministically in tests, not sampled by racing threads. The ordering
  control is internal (an injected store or an internal hook reached with
  `@testable`); no fourth public testing interface appears.
- A protected read whose grant is revoked before its result is admitted for
  publication does not publish that result.
- A store that fails the revoke commit makes `koineRevokeGrant` fail with
  `failed`; the grant is still active afterwards and admission is unchanged.
  The same for `koineCreateGrant`: no credential is returned for a grant that
  was not committed.
- A store read failure during authentication or an authority check refuses the
  request; it never admits.
- A corrupt or unreadable `grants.sqlite` makes `KoineServer.init` throw. The
  file is left in place, no replacement store is created, and no listener or
  descriptor appears. The resident application surfaces that failure to the
  user instead of starting empty; if `resident-app-skeleton-k13` did not
  already, add it here.

## Notes

This is the `transport-policy-k6` pattern: constrain a path that already exists.
If k14 already covers a case above through the public seam, cite its test and
move on; do not duplicate it.

## Decisions (running log)

**The ordering control is an internal engine hook, not a store.** Every store
call the authority makes is inside its lock, so a scripted store cannot run a
revocation between two checks without deadlocking or bypassing the boundary. The
gap between checks is the engine's, so `Engine` takes an internal
`reached: OrderingHook`; the public initializer passes a no-op. Tests run the
real `koineRevokeGrant` as the console inside the hook.

**The publication re-check applies to reads only.** The spec's re-check is
stated for reads, an admitted action "may finish", and k14 settled that a
self-revoking action is reported. Fields of the `Mutation` type are not checked
again; their output fields are reads and are. Accepted cost: two store reads per
read field.

**Already covered by k14, not duplicated.** Revocation between actions
(`noLaterActionStartsUnderARevokedGrant`), 401 on a keep-alive connection and
after restart, idempotence. The resident application's store-failure alert is
k13's `AppDelegate.fail`.

**Tests are at the `Engine` seam, not HTTP.** `KoineServer` takes no store, and
giving it one would be a public testing interface. HTTP adds only the outcome to
status mapping, which `TransportPolicyTests` and k14 cover.
