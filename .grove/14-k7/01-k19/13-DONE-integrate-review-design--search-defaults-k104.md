# search-defaults-k104

**Integrates:** search-defaults-k102

## Goal

Triage the findings of `search-defaults-k102` against the default-discovery
design from `search-defaults-k101` and apply the real ones. Implementation
planning should then start from an admission, traversal-order, descriptor,
cancellation, canonical-path and accounting contract that it can build and
accept without rediscovering these defects in the adapter.

## Context

- The findings are in the review's own leaf and commit. They are anchored to
  producer commit `44233e3defc0`, with coordinates in the working copy after
  `search-permission-transport-k103`. Read them there; this charter does not
  restate them. Their host evidence is read-only inspection of this Mac. Some of
  it rests on Antony's actual home tree and on Modaliser's file indexer. It
  informs the design; it is not acceptance.
- Artifact: `docs/specs/workspace-search.md` (admission, traversal and
  scheduling, resource accounting, native ownership, identity, capacity
  examples and acceptance), `docs/design/workspace-search-{schema,operations}.graphql`,
  `docs/adr/search-coverage-describes-observations.md`,
  `docs/adr/application-search-uses-bundle-identity.md`, the client guide's
  search section, the search terms in `CONTEXT.md`, the workflow trace rows,
  the coverage/handoff views with their exports/captions/README, and the live
  `protected-home-search-k93` context.
- Keep k103's transport, compatibility and failure-class meanings. Reconcile
  any shared admission wording with them rather than reopening them.
- Approval is unchanged. No new consent, entitlement, usage key, setup,
  descriptor-limit change or incompatible version is approved. No reduced
  search domain is approved either: that stays `protected-home-search-k93`'s
  decision with Antony. A traversal-order or descriptor-account change is design
  work. A smaller domain is not.

## Done when

- Every finding of `search-defaults-k102` is applied, accepted as a stated limit
  or trade-off, or rejected with its reason in this leaf's running log.
- Applied changes leave the spec, SDL, examples, both discovery ADRs (reworked
  in place where their decisions change), glossary, client guide, workflow trace
  and views consistent, including their summary layers.
- Capacity examples and acceptance rows give constructible subjects for every
  changed rule, across the three seams, with native acceptance still pending.
- The design checks and rendering tasks pass on frozen subjects.
- A substantive redesign is externalized as a new producer with its own
  load-bearing review beside this leaf, rather than absorbed here. A changed
  traversal order is one example.

## Notes

Use the existing `task design:search-check`, `task design:search-render` and
`task check:docs`. This leaf integrates a design review. It does not implement
the adapter or start a new native evidence chain. This leaf may spend one
narrow in-session reviewer, as `integrate-review-*` kinds do. Planning
(`app-and-file-search-k30`) cannot cut implementation until this leaf, and any
producer and review it externalizes, retire.

## Decisions (running log)

- Bootstrap adopted integrate-review-design/search-defaults-k104 on an empty jj
  change. Findings were read from review commit `fc360b7c`, against producer
  `44233e3defc0` and the current artifacts after k103. Tier 2 graph generation
  `2026-09-29T10:36:20Z` excludes docs/scripts and reports changed glossary and
  Taskfile metadata; the relied-on contracts were read directly. No graph
  completeness or new native acceptance is claimed.
- D1 and D2 are real issues, externalized together to a new traversal producer
  with a mandatory load-bearing review before planning. Sixteen deep roots can
  demand 512 streams from one process table, so root-local EMFILE handling cannot
  protect other jobs/listener/store/actions. DFS spends the entry allowance
  inside an early branch before examining shallow siblings. The review's host
  observations inform the design, not acceptance. The producer must weigh
  shallow-first alternatives and choose a process-wide search descriptor account
  below the effective soft limit, with non-search reserve and no limit change.
  This session marks the existing traversal proposal unready rather than
  absorbing that redesign or approving a smaller domain.
- D3 is a real issue, repaired by worker-only stream ownership and cleanup.
  Cancellation freezes publication and schedules no new I/O; it cannot close
  the worker's frames from another thread. Frames, descriptors and job capacity
  stay charged until the blocked call returns and the worker unwinds once.
- D4 is a real issue, repaired by a pre-open held-parent location/identity/policy
  check, refusing observed movement before child open. The residual check-to-open
  race remains explicit and unaccepted as a no-prompt guarantee. A moved-ancestor
  signed-host subject must inspect the actual location call and any dialog;
  inability to establish prompt-free location inspection requires redesign.
- D5 is an unclearly stated contract: unknown Preboot identity/classification
  uses INSPECTION_FAILED, while positively unsupported classification keeps
  UNSUPPORTED_VOLUME. This aligns the bullet with k103 without changing admission.
- D6 is an unclearly stated contract, repaired by one filesystem-reported
  directory-path operation for admitted anchors, roots, frames and bundles, and
  canonical-parent paths for file entries. Preliminary resolution is not the
  public canonical path; protected/cloud synthetic targets use canonical-home
  components without opening excluded directories. Native firmlink, case and
  Unicode witnesses remain mandatory. File symlink names remain locations.
- D7 is a real issue, repaired by explicitly charging region/mount, protected
  and cloud witnesses, including every retained path occurrence and temporary
  witness. The account is enlarged and its maximum shape enumerated; pre-turn
  account failure is job-wide INSPECTION_FAILED with no progress, not an
  unidentified affected root. No policy witness may be silently dropped.
- D8 is an unclearly stated contract: repair the reviewed-transport summary,
  include entry-budget/early-branch omissions, replace queue residue with held
  work, and count each depth-32 anchor itself even when empty. These are summary
  and vocabulary corrections, with group/outcome meanings preserved.
- The externalized producer is search-traversal-k105. Its charter requires
  the final order/account, reconciled capacity/acceptance subjects and a lazy
  load-bearing review before planning; the parent chain remains live. The
  doubt-driven-development skill's in-session reviewer is declined because
  that mandatory future read is already chartered to contest the integrated
  ownership/canonical-path/witness rules with the replacement traversal. A fresh
  read here cannot establish native prompt behavior; maximum-shape arithmetic
  is checked executably. No in-session reviewer or new native chain was spawned.
- Verification: task design:search-render passed with 511 tracked non-Grove
  input subjects unchanged per file before/after (only its three SVG outputs
  excluded). After rendering/static inspection and the README update,
  task design:search-check and task check:docs passed with all 514 tracked
  non-Grove subjects unchanged per file and the same inventory. This includes
  root glossary/configuration/manifests, every tracked doc/spec/ADR/design/evidence
  file and export, scripts/fixtures/source/client files. SDL independent/composed
  examples and existing action examples passed; removed-root, wrong-input,
  unknown-output, foreign-type and nullable-matches controls were exercised.
- Maximum-shape calculation is 274 KiB in the 320 KiB witness account; the
  historical 128 KiB account rejects that shape. Proposed per-job retained charge
  is 13.4453125 MiB, four jobs 53.78125 MiB, plus 0.5 MiB scratch = 54.28125 MiB.
  k103 publication, extension-permission and compatibility sections are byte-for-
  byte unchanged from parent commit fc360b7c. No arithmetic/check establishes
  runtime, binary, native prompt-free or useful-coverage acceptance.
- Coverage/handoff exports were inspected as librsvg rasters at 1200/900 pixels:
  labelled starts, witness-account refusal, traversal-replacement labels, anchor
  counts, outcome branches and action handoff are readable without clipping.
  No new Safari, dark-mode or narrow-window claim is made.
- The leaf's integration obligations are settled. D3/D4/D7 are bounded artifact
  repairs; D5/D6/D8 clarify contracts; D1/D2 remain substantive redesign in k105,
  with its mandatory future review and any earned integration before planning.
  That live child keeps app-and-file-search-k19 open, so no parent-chain node
  closes in this session. Protected-home-search-k93 and all native acceptance
  remain live; no changed domain, posture, setup or version was approved.
