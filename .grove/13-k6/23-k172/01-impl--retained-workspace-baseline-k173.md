# retained-workspace-baseline-k173

## Goal

Keep workspace release/schema 1.0.0, as it stands before any long-location change,
as an independently built binary that later leaves pair with 1.0.1. It runs first
because nothing afterwards can honestly recover it: the spec rules out rebuilding
the baseline from changed source and relabelling a historical update.

## Context

- `docs/verification/long-action-native-boundary.md#compatibility-and-implementation-obligations`
  (retain the 1.0.0 bundle, SDL and profile; pair independent old and new
  providers and compatible hosts).
- `docs/specs/workspace-launch-and-open.md#subjects-and-versions` (the 1.0.0,
  1.0.1 and search 1.1.0 subjects).
- `Taskfile.yml` `compat:baseline`, `compat:build`, `compat:verify` and
  `selection:fixtures`, and `scripts/build-baseline-host.sh`,
  `scripts/build-compat-pairs.sh`, `scripts/build-selection-real.sh`. The released
  baseline there is revision `v0.1.0`, which has no workspace provider, so the
  existing mechanism cannot retain this one as it stands. `current-workspace` in
  the selection fixtures is built from this tree and would become 1.0.1.
- The retained 1.0.0 profiles under `docs/design/profiles/` and
  `docs/design/workspace-schema.graphql`, which stay unchanged.

## Done when

- A named revision of this tree, recorded in the repository (the jj commit that
  holds the provider with no long-location change), builds the workspace
  provider as the retained 1.0.0 bundle. A reusable `Taskfile.yml` task builds it
  from that revision in a tree of its own and keeps it apart, as `compat:baseline`
  does for the released desktop. Its manifest says 1.0.0/1.0.0 and, once sealed,
  its signing identifier is `dev.antony.Koine.provider.workspace`.
- Run against a host, the retained bundle serves exactly the retained 1.0.0 SDL
  and passes the existing 1.0.0 conformance profile and the existing workspace
  composition and short-path subjects it shipped with. The check is first seen to
  fail against a mutated copy.
- The task and the recorded revision are what later leaves cite. Nothing about
  the retained bundle depends on the working tree's provider source, which later
  leaves change.
- Nothing in the provider's behaviour changes.

## Notes

- Do not build the retained bundle from the working tree's current source and
  describe it as 1.0.0 after the repair has started. If the revision cannot be
  reproduced without a colocated git repository, say so and decide how to pin it;
  a binary kept as an artifact is acceptable if its build revision and digest are
  recorded and the task verifies them.
