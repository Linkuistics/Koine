# walk-linear-cost

## Goal

`LocationWalk.resolve` costs time linear in the path's length, so a very long
caller path cannot hold the provider's queue before the hand-off limit refuses it.

## Context

- Found by the fresh-context read of `open-path-locations-k175`; the walk is
  `reveal-locations-k174`'s. `Providers/WorkspaceProvider/Logic/LocationWalk.swift`
  consumes `pending` with `removeFirst()` per component and rebuilds the remainder with
  `Array(pending.dropFirst(...))`, and skips `.` and leading slashes the same way, so
  each step copies what is left.
- A request body may be up to 1 MiB (`Sources/KoineCore/RequestPolicy.swift`), so a
  path such as `/` followed by 500,000 `./` is quadratic: about 5e11 byte moves, then a
  `failed` for being over the limit. The spec requires an absent long path to be
  `PATH_NOT_FOUND`, so the limit cannot come first; the walk itself has to be cheap.

## Done when

- The walk advances an index through `pending` rather than shifting or copying it, with
  every observable (spellings, expansion remainders, cycle state, errors) unchanged:
  `LocationWalkTests`, `RevealLocationTests`, `OpenLocationTests` and
  `WorkspaceLongLocationTests` stay green and `task check:location-walk-mutations` still
  sees every mutation.
- A test shows the cost is linear: a path of about 1 MiB made of `./` or `/` components
  resolves in a bound that quadratic cost cannot meet, through the shipped walk.

## Decisions (running log)

- Keep the pending byte array and advance a cursor; expose the remainder as a slice
  and materialize it only for a link expansion's recorded spelling. Reset the cursor
  after expansion. Link expansion is bounded at 32, so its remainder processing does
  not change the linear bound. Keep all resolution and error rules unchanged.
- Exercise roughly 1 MiB dot and slash paths on the real filesystem, with timing
  around resolution only, and through the independently built signed provider.
  Use 1,000,000 bytes so the GraphQL envelope remains below the 1 MiB request limit.
- The graph CLI refused startup because an unverified generation is active; use
  targeted reads of the walk, its tests, build tasks and mutation script instead.
- The original walk fails the two-second shared-source bound at 7.88–8.08 seconds.
  After correcting the test's slash escaping, the signed provider also fails:
  dot paths and a missing slash path reach the five-second execution deadline
  instead of resolving. Apple documents `withoutEscapingSlashes` since macOS
  10.15, below this project's macOS 26 floor; cite it at the test encoding call.
- `rest` becomes an `ArraySlice`; update only the slash-cycle mutation's replacement
  to materialize that slice, preserving the mutation's original broken behavior.
- Use executable disproof rather than an in-session reviewer: the old walk fails
  the new real-filesystem timing tests, and the existing mutation suite tests
  changed spellings, cycles, permissions, budgets and consumer decisions directly.
  An additional read of this bounded cursor refactor would duplicate that evidence.

## Validation

- `task check:location-walk`: all 69 tests in `LocationWalkTests`,
  `RevealLocationTests`, `OpenLocationTests` and `WorkspaceLongLocationTests` pass.
  The new direct test's two roughly 1 MiB cases finish together in 0.274 seconds;
  the original resolutions each took 7.88–8.08 seconds. All four signed-provider
  cases meet the two-second request bound and return the expected hand-off
  refusal or `PATH_NOT_FOUND`, with no action submitted.
- All 246 unmutated tests across the mutation instrument's twelve suites pass,
  including application, discovery and receipt consumers. The independently
  built signed provider and receipt probe use the changed shipped source.
- `task check:location-walk-mutations`: all 57 mutations are detected. The final
  JSON was checked against the script's mutation identities and assigned suites
  item by item, with every assigned suite red; no mutation failed to apply or build.
- `ruff check --select E,F,I --line-length 100 scripts/check-location-walk-mutations.py`
  passes. The mutation's only change is the slice-to-array conversion required
  to retain its original intentionally broken cycle state.
- SHA-256 comparisons confirm unchanged repository source inputs and targeted
  manifests, Taskfile, workspace Logic/Sources, walk/planner/application/receipt
  tests, filesystem fixture support and mutation script across verification.
  Build outputs and intentionally mutated copies live under ignored `.build/`;
  Grove notes and VCS metadata are outside the mutation instrument's input tree.
- Resolution semantics and the descriptor-relative ADR are unchanged. The parent
  `long-locations-k172` remains open for `selection-vm-workspace-repin-k185`.
