# first-authenticated-query-k5

## Goal

Build the walking skeleton of the Koine server: an embeddable Swift server that
binds loopback, publishes its endpoint descriptor, authenticates a bearer
credential against a durable grant store and answers `Query.koine` and full
introspection. The first grant comes from the in-process console principal.

## Context

There is no code, package or build tooling yet; this leaf creates them.
Read the spec's "Local transport and discovery", the opening of "Public GraphQL
contract", and "Grants and management" through "Management authority and
surface". The `Koine*` types in `docs/design/desktop-schema.graphql` are the
target shapes.

This leaf makes three library choices: a GraphQL execution engine, an HTTP
server and a durable store. Verify each against its primary source (current
repository/documentation, supported Swift and platform versions, maintenance
state), not from memory. Constraints on the choice:

- The Machine core must build without macOS-only frameworks; keep the listener
  and store behind narrow interfaces if the chosen implementation is
  platform-bound.
- The engine must support full standard introspection, custom scalars,
  programmatic schema construction (providers will later contribute SDL and
  resolvers at startup), and host-controlled field execution so authorization
  can run before a resolver. GraphQL-library types stay private to the engine.
- The store must give atomic, durable commits and fail closed.

## Done when

- A Swift package builds and tests from documented commands.
- The embeddable server binds only IPv4 `127.0.0.1` on an OS-assigned port and,
  once ready, atomically publishes the version-1 descriptor
  (`descriptorVersion`, `instanceId`, `pid`, `port`, `path` = `/graphql`,
  `contractVersion` = `koine-desktop/1`, no credential) in a 0700 directory
  with 0600 file mode. The descriptor location is injectable so tests never
  touch the user's real Application Support directory.
- The in-process console principal executes `koineCreateGrant` through the same
  GraphQL execution, authorization and store path as HTTP. There is no token,
  header, URL or public resolver that can create that principal.
- `koineCreateGrant` returns the one-time credential: 32 random bytes,
  unpadded base64url. Only the lower-case hex SHA-256 digest of the decoded
  bytes is stored, with grant identity, label, capabilities and state.
  Noncanonical or wrongly sized credentials are rejected; digest comparison is
  constant time.
- Over HTTP, `POST /graphql` with a valid bearer returns `Query.koine`:
  `contractVersion`, `instanceId`, `schemaDigest`, `ownGrant`,
  `availableCapabilities`. Missing, malformed or unknown credentials get HTTP
  401 before execution. An HTTP caller without `koine:manage` calling
  `koineCreateGrant` is refused with HTTP 403, `extensions.kind: permission`,
  `permissionClass: capability`, `phase: authorization`, and no `data`; a
  grant holding `koine:manage` succeeds.
- Any active grant, including one with no capabilities, receives full standard
  introspection of the served schema, including descriptions.
- Grants survive a server restart against the same store.
- `schemaDigest` has a documented canonical definition, added to
  `docs/specs/machine.md` (the spec names the field but not its computation).
- Tests exercise all of the above over real loopback HTTP; only the first grant
  uses the console principal.

## Notes

Serve only `Query.koine`, `Mutation.koineCreateGrant` and the types they reach.
Revocation, `koineManagement`, enrollment and provider fields belong to later
stages; do not stub them into the schema.

Model the principal as three explicit admission cases from the start — active
grant, local console, anonymous — even though anonymous admits nothing yet.
The spec forbids treating console authority as an HTTP fallback.

Defer to `transport-policy-k6`: Origin/Host validation, media-type and method
rules, syntax/validation status mapping, request/response limits, the
single-instance lock and descriptor removal. Do not defer loopback-only binding
or descriptor file modes.

If this proves larger than one session, the natural seam is the durable store
and credential handling; decompose rather than run long.

## Decisions (running log)

- **GraphQL engine: GraphQLSwift/GraphQL 4.2.0.** Verified at the tag: MIT,
  released 2026-07-08, macOS 10.15+, Swift 5.8+/6 mode, public `parse`,
  `validate`, `execute`, `buildSchema`, `printType`; `GraphQLField.resolve` is
  settable, which is how the host wraps every field with authorization.
- **HTTP: swift-nio 2.103 directly**, not Hummingbird 2.26 (macOS 11+, fine, but
  a large dependency set for one POST route whose rules `transport-policy-k6`
  must control exactly). `withThrowingDiscardingTaskGroup` needs macOS 14, so
  connections run as unstructured tasks under the macOS 13 floor.
- **Store: GRDB 7.11.1 over SQLite**, `synchronous = FULL` plus `fullfsync = ON`
  (SQLite documents that macOS needs the latter for durable commits), `STRICT`
  table, unique digest. Behind `GrantStore` in its own target.
- **swift-crypto 5.0** for SHA-256; it sets the package's tools version to 6.2.
- **The library's `locatedError` returns a thrown `GraphQLError` unchanged**, so
  the engine builds every resolver error itself with `info.path` and the
  contract's extensions. Non-domain errors become `failed` with a fixed message.
- **Preflight collects root mutation fields itself** (fragments with cycle
  guard, `@skip`/`@include`), because the library's `collectFields` and
  variable coercion are internal. A condition it cannot decide counts as
  included: it can only over-deny, and execution then rejects the bad variable
  before any action.
- **Authentication scans every stored digest in constant time** rather than an
  indexed lookup, so the comparison is constant-time in the literal sense the
  spec asks for. Grants are few and human-approved.
- **`extensions.requiredCapability`** names the capability on a capability
  error; added to the spec, which required it be identified but named no key.
- **`schemaDigest`** is defined order-independently (definitions sorted by
  name); spec section "Schema digest".
- **Unknown capability names in `koineCreateGrant` are a `failed` execution
  error.** The spec's vocabulary has no input-rejection kind beyond GraphQL
  coercion; a later management stage may want to name one.
- **Beyond this leaf's list, cheaply included:** 400 for syntax/validation,
  404/405 for other paths/methods, a 1 MiB body cap, `Cache-Control: no-store`.
  `transport-policy-k6` still owns their exact rules and tests.
- **Not done here:** the Linux build of `KoineCore` is unverified. The workflow
  tool question was put to the human, who chose **"Add Taskfile.yml now"**;
  the root `Taskfile.yml` (`task`, `task build`, `task test`) is added here and
  the two briefs that carried the open question now record the answer.
