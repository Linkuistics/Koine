# transport-policy-k6

## Goal

Make the loopback endpoint obey the whole version-1 transport contract: HTTP
request rules, status mapping, parsing/execution limits and the descriptor
lifecycle. After this leaf a website cannot drive the endpoint, oversized or
abusive requests never reach execution, and two Koine instances cannot both
publish a descriptor.

## Context

Builds on `first-authenticated-query-k5`. The authoritative text is the spec's
"Local transport and discovery"; every rule there that k5 deferred lands here.

## Done when

Verified over real loopback HTTP against the embedded server:

- Only `POST /graphql` with `Content-Type: application/json` is accepted;
  `Accept: application/graphql-response+json` is supported. GET, batching and
  other methods/media types are transport errors. Responses carry
  `Cache-Control: no-store`. No cookies, query-string credentials, redirects or
  CORS headers exist.
- Any request with an `Origin` header, including `Origin: null`, is rejected.
  `Host` must equal the literal bound loopback address and port.
- GraphQL syntax, validation and variable-coercion failures return HTTP 400
  with `errors` and no `data`. Executed operations return HTTP 200 whatever
  their execution errors. The 401 and 403 cases from k5 still hold, and
  authentication is evaluated per request, never per connection.
- Limits reject before any resolver runs: 1 MiB body, depth 16, 1,000 expanded
  field selections (fragments expanded with cycle detection before counting),
  10 root mutation actions. Response materialization is capped at 8 MiB and
  execution at 5 seconds. Introspection of the served schema fits within them.
- A process lock prevents a second instance from publishing; shutdown removes
  only the instance's own descriptor; a descriptor left by a dead instance is
  replaced, not trusted.
- The limits are named, versioned policy values in one place, not scattered
  literals.

## Notes

The 5-second bound cannot interrupt arbitrary native code and proves nothing
about an action that already began; implement it as cooperative cancellation
plus a response deadline, and say so in the code's contract. Provider-facing
consequences (bounded OS calls) belong to `native-provider-contribution-k8`.

The 10-action and selection limits need at least one mutation and nested
selections to test; use the core fields that exist. Do not add fixture schema
to the served product for the sake of a test.

## Decisions (running log)

- **Limits live in `RequestPolicy` (KoineCore), injected through
  `KoineServer(dataDirectory:policy:)`.** Injection is what lets the 8 MiB cap and
  the 5 s deadline be tested over HTTP with no fixture schema: a small cap against
  introspection, a zero deadline against `Query.koine`.
- **A pre-parse bracket-nesting bound (64) was added to the policy and the spec.**
  GraphQLSwift 4.2.0's parser is recursive with no bound (read in
  `Language/Parser.swift`); with the guard removed, 100,000 nested `{` killed the
  test process with signal 10. The same 64 bounds fragment/inline-fragment chains,
  which bounds the limit walker's and the library validator's recursion.
- **Limits run after parse and before validation and preflight**, so an over-limit
  mutation from an unauthorized caller is 400, not 403. Fragments are measured
  once and reused per spread, so exponential expansion costs linear time; counts
  saturate. `@skip`/`@include` are ignored: over-deny only.
- **Coercion/operation-selection 400s are classified structurally.** The
  library's `execute` returns those failures as an ordinary result
  (`Execution/Execute.swift`), and its coercion functions are internal. A
  per-request `ExecutionScope` records whether any resolver began; no data and no
  resolver begun is a request error.
- **`data: null`, not an absent `data`, for an executed operation whose error
  reached the root.** The library omits the key; the spec says null.
- **Deadline: an unstructured race, not a task group**, because a group waits for
  a child that ignores cancellation. On expiry the caller is answered, the task
  cancelled, and the host resolver wrapper admits no further resolver. Timeout and
  over-cap responses are 200, `data: null`, `kind: failed`. The cap applies to the
  finished body, since the library materializes whole.
- **Transport statuses, which the spec left open:** Origin 403, Host 421, other
  target 404, method 405, media type 415, body 413; checked in that order before
  the credential. Now in the spec. `Cache-Control: no-store` is set by the
  listener so its own 413 carries it too.
- **Instance lock: BSD `flock` on `instance.lock`, taken in `init` before the
  store opens, released by `stop()`.** `flock` belongs to the open file
  description, so two servers in one process exclude each other as two processes
  do; `fcntl` locks would not, and drop when any descriptor closes. Under the
  lock any existing descriptor is stale by construction and is deleted unread.
  A `KoineServer` object is one run: `start()` twice, or after `stop()`, throws.
- **Tests write raw HTTP over a POSIX socket** (URLSession rewrites Host and
  framing), on dispatch threads: blocking the cooperative pool starved the
  in-process server and produced false 5 s timeouts.
- **Not done:** `KoineCore` on Linux is still unverified; a failed descriptor
  publish in `start()` leaves the listener bound (inherited from k5, harmless
  while the caller treats a throwing `start()` as fatal).
