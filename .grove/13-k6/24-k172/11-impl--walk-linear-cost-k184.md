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
