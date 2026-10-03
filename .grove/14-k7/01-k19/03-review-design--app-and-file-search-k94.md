# app-and-file-search-k94

**Reviews:** app-and-file-search-k92

## Goal

Read the committed search design adversarially before implementation planning.
Challenge whether the public API, coverage, authority, scoped failure mapping
and native ownership contract can be implemented without contradicting the
accepted workflows, platform evidence or existing action/provider contracts.

## Context

- Producer commit named `app-and-file-search-k92`; inspect its complete diff.
- `docs/specs/workspace-search.md`, additive SDL and example operations in
  `docs/design/workspace-search-{schema,operations}.graphql`.
- Architecture viewer: current discussion, search coverage and search handoff
  sources/exports; the discovery and metadata views are evidence context.
- `docs/verification/search-discovery.md` and
  `docs/verification/protected-path-metadata.md`: bounded signed-host results,
  not acceptance of the new descriptor-relative adapter or arbitrary traversal.
- Workflow trace, Machine error/ABI contract, launch/open spec and unchanged
  action SDL; authority and first-party selection ADRs.
- `protected-home-search-k93`, `protected-default-open-k89` and
  `reveal-app-bundle-notice-k90` retain their distinct pending human decisions.

## Done when

The inspection-only findings identify concrete contradictions or missing
obligations with exact artifact/source coordinates and their consequences.
Try counterexamples involving complete versus partial empty results; mixed and
all-blocked roots; scope/value exhaustion; cancellation, blocked workers and
late completion; protected aliases, mount changes and unrepresentable names;
application identity/unknown metadata; and selection followed by replacement.
Assess the feature-gated minor-2 nil-consent mapping against current framework
constructors, publication errors and old-host refusal. Check every nested
read field, both-control action handoffs, unchanged action-only profiles,
independent composition and the three existing acceptance seams. Judge whether
the current spec/ADR set carries the durable decisions coherently. Record no
runtime/native guarantee on the strength of SDL or presentation checks.

## Notes

No in-session reviewer ran in the producer. `task design:search-check` and
`task design:workspace-check` passed their positive and negative schema controls;
they do not establish runtime branch invariants. Safari presentation checks
cover readable deep links, starts/branches and narrow discussion reflow.
Parent Tier-2 graph coverage used generation 2026-09-29T10:36:20Z; docs are
excluded, workspace-provider paths were untracked, and core files had changed
metadata/Engine's line-295 parse gap. The producer read current source directly
for those paths/ranges. Confirm current project/generation and coverage rather
than treating that earlier graph as fresh native/framework evidence.
Do not fix artifacts in this review. If actionable findings earn integration,
cut the next `integrate-review-design` at the review's sequencing boundary.
