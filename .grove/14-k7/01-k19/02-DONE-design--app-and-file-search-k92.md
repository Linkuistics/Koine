# app-and-file-search-k92


## Goal
Consume `docs/verification/search-discovery.md` and the protected-path metadata
report, then settle application/file search's public API, coverage and action
handoff. The signed-host evidence recommends bounded filename enumeration;
Spotlight scoped to Desktop prompted, and disabled indexing did not reliably
make queries fail. Do not build on an index-health inference or protected
traversal consent that the experiment does not establish.

## Context

- Parent `app-and-file-search-k19` and increment `app-and-file-search-k7`.
- `search-discovery-evidence-k91`, its report and exact retained records.
- The launch/open spec and SDL; workflow provider authority/error contracts.

## Done when

The durable spec and concrete SDL fix query semantics, root defaults and
limits, per-root complete/partial/unknown coverage, searched/skipped scopes and
reasons, result metadata with unknown values, ordering and bounds. They fix how
each selection becomes a constrained launch, path-open or reveal input and
retain client clipboard/MRU ownership. Public errors and aggregate all-blocked
outcomes remain distinguishable from healthy empty results. Consent diagnostics
are extension-only, without changing desktop fields or inventing an approved
consent. Raise any necessary new entitlement/consent/setup contract with Antony
before relying on it. The three existing seams and cumulative trace are updated;
implementation/acceptance remain planning's work.

## Notes

Compare bounded directory enumeration against an index-based interface with
honest unknown coverage. Evidence establishes neither exhaustive application
inventory nor arbitrary prompt-free filesystem traversal. Directory-list
materialization, cancellation, symlink/classification races, protected root
aliases, mount/cloud scopes and missing metadata must be owned by the design.
Do not treat the sample probe's 3,000-path scheduling threshold as a hard
result or memory bound; a single directory listing can exceed it.
Retain k73's unknown/blocked document-handler policy and the already live
protected-default-opening and app-reveal-notice decisions.

## Decisions (running log)

- Use bounded streaming filename enumeration, with declared application roots
  and client-supplied file roots. Reject an index-backed first implementation:
  k91 could not distinguish an unavailable index from ordinary results, and
  protected Spotlight queries prompted. No index health diagnostic is inferred.
- Search supplies location values and, where known, registered application
  identifier/path selectors. It issues no resource reference and owns no chooser,
  MRU, pasteboard write or implicit action. Launch/open/reveal revalidate their
  existing inputs; the two pending action decisions remain live.
- Keep protected traversal blocked before access, regardless of assumed prior
  consent. Coverage distinguishes a known prompt-risk policy from observed
  denial and unknown failure; diagnostics do not declare a consent absent or
  add a consent identifier, entitlement or setup route.
- Publish bounded per-root coverage beside nullable matches. An all-blocked
  outcome withholds matches and raises an OS-permission error at that field,
  retaining every root's diagnostic. A compatible, feature-gated framework
  extension carries prompt-risk scope without fabricating an `osPermission`
  identifier; old provider/desktop behavior is unchanged.
- Prefer descriptor-relative `fdopendir`/`readdir` over the probe's Foundation
  array listing. Refuse union and unsupported volumes, bound Koine's retained
  records and work, and explicitly retain native allocation and blocking-call
  limits. The new adapter and no-prompt paths require signed-VM acceptance.
- Public shapes are the standalone additive workspace search SDL and examples,
  backed by `docs/specs/workspace-search.md`. Defaults, literal Unicode filename
  matching, bounded rank order and per-root scopes are explicit. Separate read
  output types leave the existing action-only SDL and conformance profiles intact.
- The accepted domain cannot be expanded around protected home traversal by
  inference. Externalized Antony's partial-home versus explicit-setup decision
  as `protected-home-search-k93` before baseline acceptance, coordinating any
  chosen setup with the already live default-opening decision.
- No new ADR is earned: provider/effect boundaries remain those of the current
  ADR set, and the replaceable search algorithm and additive diagnostic contract
  are fully specified in the area spec. The load-bearing API/coverage/framework
  semantics earn a scheduled `review-design` before implementation planning;
  no in-session reviewer duplicates that read.

## Verification

- `task design:search-check`: independent and composed SDL/examples validate;
  existing action examples still validate. Removed search root, incorrect input,
  unknown output and foreign provider type controls fail as intended. Nullable
  matches preserve coverage at the schema boundary; runtime branch invariants
  remain pending.
- `task design:workspace-check`: existing independent/composed action SDL and
  five operations validate, with its negative controls still rejected.
- `task design:search-render`: generated the coverage and handoff SVGs with
  D2 0.9.0/Dagre/light 0/dark 200; the existing discovery export is unchanged.
- Safari in disposable macOS 26.5 clone `koine-k92-design`: byte-identical
  manifest/exports, current-discussion and deep-link delivery, both starts and
  branch layouts at wide size in light/dark appearance, and 800-pixel discussion
  reflow. This is presentation verification, not search runtime acceptance.
- Current native/framework source was read directly where graph coverage was
  excluded, untracked, stale or partial; the graph generation was 2026-09-29.
  No native adapter implementation or new consent was delivered by this leaf.
