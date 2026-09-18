# grant-listing-and-revocation-k14

## Goal

Grant management over the public GraphQL seam: a `koine:manage` grant lists
grants and revokes one, and revocation is live and durable.

## Context

- Target shapes: `KoineManagement`, `koineRevokeGrant` and `KoineGrant` in
  `docs/design/desktop-schema.graphql`. Serve `KoineManagement.grants` only;
  its other fields arrive with later stages.
- Spec: "Grants and management", "Management authority and surface",
  "Errors and partial data", "Mutation preflight and revocation".
- k4's tests (`Tests/KoineServerTests`) show the seam's conventions: a real
  listener over loopback HTTP, the console principal only for bootstrap.

## Done when

All verified over real loopback HTTP, with the console used only to mint the
first `koine:manage` grant:

- `Query.koineManagement { grants }` returns every grant, active and revoked,
  with no secret or digest. Without `koine:manage` the caller gets the agreed
  permission error with its response path and `requiredCapability`, and
  `koineManagement` is null while sibling fields such as `koine` still resolve.
- `koineCreateGrant` works for an HTTP caller holding `koine:manage`, and is
  denied with the permission shape for one that does not.
- `koineRevokeGrant` requires `koine:manage`, commits durably before it reports
  success, and is idempotent: revoking a revoked grant succeeds with the same
  result. The outcome for an unknown grant ID follows the design SDL and spec;
  if they leave it open, settle it, record it in the spec, and test it.
- `GrantStore` gains the revoke write; `SQLiteGrantStore` implements it as an
  atomic durable commit. Revocation state survives a server restart over the
  same data directory.
- A revoked credential gets 401 on the next request of an existing keep-alive
  connection, and 401 after restart. A grant may revoke itself; its following
  request is 401.
- A mutation selecting `koineRevokeGrant` on the caller's own grant followed by
  another management action runs the first and refuses the second: no later
  action starts under a revoked grant, and the earlier one is not undone.
- Introspection of the grown schema stays inside `RequestPolicy`; the schema
  digest changes and the README's served-schema description is current.

## Notes

Revocation and dispatch admission must go through one serialized authority
boundary (`Authority` is the single place authority is read today). Build that
boundary here; `revocation-ordering-and-store-failure-k15` proves it under
controlled ordering and adds the failure cases, so leave it a seam a test can
order, without adding a public testing interface.
