# long-action-native-boundary-k132

**Integrates:** long-action-native-boundary-k131

## Goal

Triage the findings of `long-action-native-boundary-k131` against the native
boundary, proposed failure repair and independent subjects from
`long-action-native-boundary-k129`, then apply the real ones.
`long-action-route-k130` must start from a boundary and error contract it can
build on, without rediscovering these defects.

## Context

- Read the findings in the review's own leaf and commit. This charter does not
  restate them. They are anchored to producer `d57d2bae7837`, whose coordinates
  equal the review's tree.
- The artifact:
  - `docs/verification/long-action-native-boundary.md` and its declaration
    probe;
  - `docs/specs/workspace-launch-and-open.md`: the long-location boundary, the
    outcome table and the acceptance rows;
  - the search handoff in `docs/specs/workspace-search.md`;
  - the client guide, the workflow trace, `CONTEXT.md`, the workspace SDL and
    examples, and the architecture viewer;
  - `Taskfile.yml`.
- Code and tests to read, and not to change in this design integration:
  - `Providers/WorkspaceProvider` (native adapter, selection, open, reveal,
    observation);
  - `Tests/KoineServerTests/WorkspaceProviderTests.swift`;
  - the contract-only client adapter.
- Parent `long-search-result-actions-k128` keeps its whole original mandate and
  approval posture.

## Done when

- Each finding is classified as one of:
  - a contract stated unclearly;
  - a real issue, fixed in the design artifacts;
  - a visible accepted trade-off;
  - noise.

  Each classification is recorded in this leaf's running log.
- Every reconciliation a real finding needs lands in this commit: the spec, the
  verification, the guide, the trace, the glossary, the SDL comments and the
  viewer. Changes to code, tests or the contract client are left for planning
  as stated obligations. They are not edited here.
- A decision that belongs to Antony is escalated as a concrete trade-off with a
  recommendation. It is never settled silently. Such decisions include:
  - an incompatible meaning under the unchanged 1.0.0 version;
  - accepting a registered long copy that breaks short launches;
  - a systematic null receipt process for long applications.
- A finding that needs the route rethought rather than repaired becomes a new
  producer review chain. It is not done here, and this leaf completes no route.
- Existing Taskfile checks run on changed artifacts. No native action subject
  runs. `long-action-route-k130` and the search consumers stay after this leaf.

## Notes

No shorter search ceiling, copy-only or disabled baseline, new consent, setup or
entitlement, private policy or accepted workflow loss is approved by this
integration.
