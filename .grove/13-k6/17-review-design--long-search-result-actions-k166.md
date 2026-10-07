# long-search-result-actions-k166

**Reviews:** long-search-result-actions-k128
**Creator:** run 85cbf064-9cb4-4de9-abca-3dd1d46003a4

## Goal

Mandatory load-bearing adversarial read of the long-search-result-actions
design as it stands after k165: the v1 long-location action contract, the new
descriptor-relative access decision and everything reconciled with them.
Findings only; no fixes.

## Context

- Producer node long-search-result-actions-k128; its final design session is
  long-action-route-k165 (read that leaf's running log and its commit diff).
- Antony's 2026-10-07 reaction in local-url-naming-k164 and GitHub issue
  Linkuistics/Koine#1: surface the failure, defer long-path application support
  past v1, Koine's own filesystem code descriptor-relative. Treat that trade-off
  as settled; review the design that implements it, not the decision itself.
- `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`,
  `docs/adr/filesystem-access-is-descriptor-relative.md`,
  `docs/specs/workspace-search.md#long-location-action-dependency`,
  `docs/design/workspace-action-repair-schema.graphql`, the client guide,
  workflow trace, glossary, research bridge and the architecture viewer's
  current discussion. `docs/verification/long-action-route-prototype.md` holds
  the k134 measurements the limit and the prompt obligation rest on.

## Done when

- Every finding names the artifact, the defect and its consequence. In
  particular, attack these doubts the producer could not settle alone:
  - Does resolution really mirror the kernel: cycle detection by a repeated
    link plus remaining path, physical `..`, trailing-slash demands, following
    the final link for reveal, and `fpathconf` name limits for non-ASCII names?
  - Is "literal, every expanded remainder and resolved spelling under
    `PATH_MAX`" the right refusal predicate — could it refuse a location the
    platform would accept, or admit one it rejects, given firmlinks and the
    cryptex-volume links seen for Safari in k134?
  - Does moving copy identity from resource identifiers to the walk's device
    and inode keep every accepted multiple-copies outcome (other spellings
    match, another volume does not, Trash copy eligible)?
  - Is the search-only-handle prompt obligation, with escalation to Antony,
    an honest bound, or does the design depend on an unmeasured property in a
    way that should block planning?
  - Is `failed` with guidance, rather than a new dependency reason, sound for
    1.0.1 compatibility and for clients?
  - Do any current-state artifacts still claim an unresolved route, or did the
    rewrite drop an obligation the earlier briefs carried (short regressions,
    controls, acknowledgment, receipts, separate subjects and profiles)?
- If findings warrant action, cut the integration where `pick` reaches it next
  (before long-location-actions-k167). Otherwise retire with none.

## Notes

Earned review and any integration precede planning (long-location-actions-k167)
and every search consumer (k123/k120/k30). Native, binary, public and signed-VM
acceptance are planning's, not this review's.
