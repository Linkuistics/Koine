# search-path-resolution-k125

**Integrates:** search-path-resolution-k124

## Goal

Triage the findings of `search-path-resolution-k124` against the resolution,
pre-open policy, spelling and file-name design from
`search-path-resolution-k122`, then apply the real ones. Classification
`search-path-classification-k123` must consume a path contract that it can
build on without rediscovering these defects.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `7ec0af50ea38`, whose coordinates
  equal the review's tree.
- The artifact:
  - `docs/specs/workspace-search.md`, including k119's in-process phase table and
    the selection handoff;
  - `docs/verification/search-canonical-paths.md`;
  - the search ADRs and the traversal ADR;
  - CONTEXT, the SDL and examples, the client guide and the workflow trace;
  - the six search views with their exports, captions, manifest and README;
  - the brief chain.
- One finding touches the separate launch-and-open contract,
  `docs/specs/workspace-launch-and-open.md`. Route any change there through its
  own increment, or escalate it, rather than editing it in place.
- Approval is unchanged. None of the following is authorized:
  - a new consent, entitlement, usage key, setup or private long-path policy;
  - a raised limit or account;
  - a shorter public ceiling or a smaller domain;
  - an incompatible version;
  - a changed k119 call set.
- Lost workflow coverage goes to `protected-home-search-k93` before it becomes a
  dependency.

## Done when

- Classify every finding as one of:
  - a contract stated unclearly;
  - valid and actionable;
  - a visible trade-off;
  - noise.

  Record the verdict and its reason in the running log, and apply the actionable
  repairs in place across every affected durable artifact and summary.
- Escalate before relying on a change that alters workflow coverage, approval
  posture, k119's call set or another increment's contract.
- Regenerate the changed views, and run `task design:search-render`,
  `task design:search-check` and `task check:docs` on frozen inputs.
- A repair may amount to substantive redesign. If so, externalize it as a design
  producer with its own load-bearing review, placed ahead of k123.
- k123 then consumes the reconciled path artifact. k120 and planning k30 still
  wait on k123's chain.

## Notes

Design triage only: no implementation and no native evidence chain. All native,
binary, prompt and useful-coverage acceptance remains pending.
