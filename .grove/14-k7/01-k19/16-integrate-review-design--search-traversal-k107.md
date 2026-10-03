# search-traversal-k107

**Integrates:** search-traversal-k106

## Goal

Triage the findings of `search-traversal-k106` against the traversal and
process-descriptor design from `search-traversal-k105`, and apply the real
ones. Implementation planning should then start from a traversal, revalidation,
descriptor-admission and serviceability-evidence contract that it can build and
accept without rediscovering these defects in the adapter.

## Context

- Read the findings in the review's own leaf and commit. This charter does not
  restate them. They are anchored to producer commit `6814ec741fa4`, with
  coordinates equal to that commit's. Some evidence is read-only inspection of
  this Mac and of the checked-out swift-nio and SDK headers. It informs the
  design; it is not native acceptance.
- Artifact: `docs/specs/workspace-search.md`, the search SDL and examples, both
  discovery ADRs, the search terms in `CONTEXT.md`, the client guide's search
  section, the workflow trace rows, the traversal/coverage/handoff views with
  their exports, captions, manifest and README, the brief chain, and the live
  `protected-home-search-k93` context.
- Keep k103's typed BLOCKED, outcome, lifecycle, transport and compatibility
  meanings. Keep k104's worker-only ownership, canonical-parent policy checks,
  unified path spelling and witness accounting, except where a finding shows
  that one of them does not hold under FIFO.
- Approval is unchanged. No new consent, entitlement, usage key, setup,
  descriptor-limit change, smaller search domain or incompatible version is
  approved. Reduced coverage remains `protected-home-search-k93`'s decision
  with Antony.

## Done when

- Every finding of `search-traversal-k106` is applied, accepted as a stated
  limit or trade-off, or rejected with its reason in this leaf's running log.
- Applied changes leave every affected durable contract and summary layer
  consistent, with ADRs reworked in place.
- Every changed rule has constructible subjects at the three agreed seams, and
  native acceptance stays pending. A serviceability or revalidation subject
  names the instrument that would observe its outcome.
- `task design:search-render`, `task design:search-check` and `task check:docs`
  pass on frozen subjects.
- A substantive redesign is externalized as a new producer with its own
  load-bearing review beside this leaf, not absorbed here.

## Notes

This leaf integrates a design review. It does not implement the adapter or
start a native evidence chain. It may spend one narrow in-session reviewer, as
`integrate-review-*` kinds do. Planning (`app-and-file-search-k30`) cannot cut
implementation until this leaf, and anything it externalizes, retires.
