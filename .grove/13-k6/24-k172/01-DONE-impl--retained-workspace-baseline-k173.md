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

## Decisions (running log)

- **Pinned revision is jj commit `f24d6290e1f90e5967f88192e3bfa4e4a197e1f7`**, tag
  `workspace-1.0.0-baseline` (the parent of this leaf's work). Checked: no change to
  `Providers/`, `Sources/`, `Tools/`, `Fixtures/`, `Package.swift`, `App/` or `Tests/`
  since `c465b191be` (the last provider commit); the only difference in the retained
  SDL file `docs/design/workspace-schema.graphql` since then is four header-comment
  lines added by long-location planning (the SDL itself is byte-identical).
- **No colocated git repo is needed**: the jj store is git-backed
  (`jj git root` → `/Users/antony/Development/Koine/.git`), so the revision is
  extracted with `git archive` against that store, which keeps symlinks
  (`Providers/WorkspaceProvider/Logic/ProcessStart.swift` and `ProcessIdentity.swift`
  are links) that `jj file show`, as `build-baseline-host.sh` uses it, would flatten.
  The pin names the commit id, and the tag must agree with it.
- **Verification runs the retained tree's own suites against the artifact**, not a
  rebuild: the retained `BundledProviders` root is filled from the kept-apart sealed
  bundles, so the N suite sees those exact bytes.
- **Tasks**: `task compat:workspace-baseline` (builds, `scripts/build-retained-workspace.sh`) and
  `task compat:workspace-baseline-verify` (`scripts/verify-retained-workspace.sh`); the pin is
  `scripts/retained-workspace-1.0.0.json`; evidence and the path layout are in
  `docs/verification/retained-workspace-baseline.md`. Later leaves cite those. The artifacts to pair are
  `.build/compat/<configuration>/workspace-1.0.0/bundled/` (sealed, approved Desktop and Workspace) and
  `.../products/KoineCompatibilityHost` (that revision's host). Not added to `compat:build`: it adds a
  full second tree to every pair build, and `action-repair-compat-k179` decides whether the pairs take it.
- **First mutation control did nothing, and was replaced.** Making `isMissing` return false left all 22
  short-path N subjects green because a missing path is classified by `stat` and `unavailable(errno)`,
  never by `isMissing`; the control that stands removes `ENOENT` from `unavailable`'s absent cases and fails
  exactly `aMissingPathADanglingLink…ArePathNotFound…` and `…AreNotFoundForReveal…`. A first grep for the
  1.0.1 control also matched a file path rather than the row; it now names the pin problem verbatim.
- **Observed**: build from nothing 52 s, verification 34 s warm (the revision's tests build once). Conformant
  against `core-desktop-workspace-extension-host.json` (10 mutated contracts and 5 mutated pins red first; a
  resealed 1.0.1 copy red); 14 suites pass with the artifact as the bundled root (143 + 148 tests); the
  unsealed provider build is byte-identical across two builds. No provider behaviour changed and no
  acceptance row of the spec was changed by this leaf.
