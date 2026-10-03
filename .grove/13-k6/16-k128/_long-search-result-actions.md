# long-search-result-actions-k128 — brief


## Goal

Reconcile the existing launch/open/reveal metadata and error contract with
locations returned by application/file search through 8,192 bytes. Own the
cross-increment action defect in search-path-resolution-k124 P4; search's value
ceiling must not become a promise of actions that report extant paths missing.



## Context

- Review `c0ece7a8`, producer `7ec0af50ea38`, integration
  search-path-resolution-k125. Consume current search path dependencies, not
  presumed completion of the still-live witness/replay/classification designs.
- `docs/specs/workspace-launch-and-open.md`, protected-path metadata evidence,
  action SDL/examples, current action verification and workflow trace.
- `docs/specs/workspace-search.md#selection-and-action-handoff` and
  `docs/verification/search-canonical-paths.md`: returned values versus action
  inputs, long native subjects and exact installation selection.
- Existing action inspection uses realpath/stat and selected resource values;
  PATH_MAX is 1,024. The overlength-not-found classification does not establish
  absence of a component-created long path. Search includes long files/folders,
  packages and app paths; copy remains client-owned.

## Done when

- Establish the supported action route and truthful failure/input meaning for
  returned long locations, including a roughly 1,500-byte ordinary file and
  constrained application. Separate source length, expanded/canonical length,
  classification and actual submission limits; neither raw byte length nor an
  injected native success proves actionability.
- Preserve selected installation constraints, both controls, cancellation,
  acknowledgments, native payload refusals, handler decisions and no prompt read.
  Never omit applicationPath, shorten/rewrite a location or retry another copy.
- Source/SDK analysis must support a proposed change. Escalate before adopting
  new consent/setup/entitlement/private policy, incompatible contract change or
  accepted workflow loss. Do not select a shorter search ceiling or accept a
  copy-only baseline as a repair. k93 owns measured workflow omissions.
- State controlled action adapter, independent provider/public GraphQL, binary
  compatibility and signed-VM subjects that take an actual long search result
  into default/Zed open, reveal and constrained app launch. Existing short-path
  action acceptance stays bounded to its subjects; long outcomes remain pending.
- Reconcile the action contract and its owned artifacts, search handoff, SDL
  descriptions/examples, client guide, workflow trace, glossary and viewer.
  Deterministic checks use the existing Taskfile; native execution is planning's
  work. No search implementation belongs in this producer.
- Cut a mandatory load-bearing `review-design` of this producer before retiring;
  it and any earned integration must be reached before search consumers. The
  root and search briefs require this action chain before k123/k120/k30 consume
  a completed handoff. Route implementation/acceptance through this increment.

## Notes

This leaf reopens only the long-result action seam, not prior accepted launch
workflows or the separate protected-default-open/app-reveal human decisions.

## Decomposition

`long-action-native-boundary-k129` establishes the source/SDK limits, truthful
failure correction and independent subjects without inventing a complete route.
Its load-bearing review and any integration precede `long-action-route-k130`,
which completes the supported metadata/classification/selection/submission
design and remaining artifact reconciliation. The final producer must cut this
node's mandatory review before closure. The entire chain stays in launch-and-open
and is reached before the later search node, including k123/k120/k30. The original
Done when above remains binding; retiring the first child closes none of it.
No implementation leaves are cut here; planning owns native execution after
the reviewed supported route. If the route needs an unapproved posture or workflow
trade-off, escalate a concrete decision rather than repeating evidence indefinitely.
