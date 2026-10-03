# search-traversal-k105

## Goal

Replace the reopened depth-first traversal/process-descriptor proposal with
one buildable design that preserves useful shallow application/home discovery
under unchanged bounds and keeps unrelated Koine work serviceable. This is the
substantial redesign externalized by search-defaults-k104, not adapter code.

## Context

- Read search-defaults-k102's D1/D2 from review commit `fc360b7c`, and k104's
  committed triage/repairs. Read-only host counts/order/limits inform this design,
  not native acceptance: Development has over 400,000 entries, an early branch
  over 200,000; DFS loses later depth-1 home names at the 100,000-entry budget.
  A proposed job can hold 512 streams against a shared process table whose
  normal-launch limit may be far smaller; EMFILE is not root-local.
- Artifact: docs/specs/workspace-search.md, search SDL/examples, both discovery
  ADRs, glossary, guide, workflow trace, coverage/handoff sources, manifest,
  exports/captions/README, brief chain and protected-home-search-k93 context.
- Preserve k103's typed BLOCKED/outcome/failure/compatibility meanings and k104's
  worker-only ownership, pre-open canonical-parent checks, unified path spelling,
  fifteen-witness accounting and job-wide pre-turn refusal. Native prompt/race
  limits and all runtime acceptance remain pending.
- Tier 2 project Users-antony-Development-Koine.add-plugins-for-modaliser-requirements,
  generation 2026-09-29T10:36:20Z; docs/scripts are excluded, glossary/Taskfile
  metadata changed. Parent read contracts directly and made no code call-chain
  claim. Confirm generation/coverage and read current excluded artifacts.

## Done when

- Weigh shallow-first traversal against DFS on the measured-scale early-branch
  shape. Include breadth-first work with a bounded queue and one reserved root
  FRONTIER_LIMIT group, and iterative deepening over held streams. Choose an
  exact order property and constructible expected shallow/deep/later-root names;
  account for repeated work, pending paths, streams, scratch, groups and freeze.
  A directory/file shallow-name witness is not acceptance of all descendants.
- Define a Koine-owned process-wide search descriptor account shared by aliases,
  jobs and provider instances. Read the effective soft limit without raising it;
  choose the non-search reserve, charges before opens, atomic acquisition,
  per-job/root allocation, refusal/release semantics and blocked-worker ownership.
  Cover temporary component/canonical/bundle descriptors too. State serviceability
  limits honestly rather than inferring them from a static search-only cap.
- Reconcile every affected durable contract and summary, reworking ADRs in place.
  Supply new maximum shapes and capacity examples; groups count observed anchors,
  not unseen descendants, and overflow never silently drops policy or work.
- Construct three-seam subjects for a responsive 400,000-entry tree with a
  200,000-entry early branch and later depth-1 witnesses, 5,000-wide roots,
  depth-bound anchors, 16 roots, long/invalid paths, deadlines, changed parents,
  cancellation/freeze and descriptor refusal. Normally launched signed-host
  saturation must keep independent listener requests, grant-store operations
  and authorized actions serviceable with effective limit/reserve/charges recorded.
  Real Safari/Finder/home/canonical-path/no-dialog acceptance remains pending.
- Run task design:search-render, task design:search-check and task check:docs
  on frozen subjects. Cut a load-bearing review-design leaf for this producer as
  the last work act, with **Reviews:** search-traversal-k105 and its specific
  residual doubts; do not clear planning merely because static checks pass.

## Notes

Planning app-and-file-search-k30 waits for this producer, its mandatory review
and any integration the review earns. Review chains are lazy: this producer
cuts its review after the artifact exists. No native evidence chain, adapter
implementation, smaller search domain, new consent/entitlement/usage key/setup,
descriptor-limit change or incompatible version is authorized. Reduced coverage
remains Antony's protected-home-search-k93 decision after actual measurements.
