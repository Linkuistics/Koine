# application-catalogue-k7

**Integrates:** application-catalogue-k6

## Goal

Triage the findings of `application-catalogue-k6` under issue 10's delivery
rule. Read that review's committed findings and evidence. Record a reasoned
disposition for each, and apply only the work that the accepted disposition
requires.

## Context

- The review covers both discovery queries from `special-locations-k2` and
  `application-catalogue-k3`.
- The root brief owns the happy-path release rule and the limits on native
  reads. `discovery-acceptance-k4` owns the pending signed N and VM V work.
- This leaf precedes acceptance so the review's source coordinates remain
  current when it is triaged.

## Done when

- Every finding has a disposition supported by its contract and source.
- Accepted findings that do not break the happy path have GitHub issues, as
  issue 10 requires. Record their links without expanding this release's scope.
- Any accepted happy-path blocker is corrected and appropriately verified.
- Required checks for any changes are recorded accurately, and the acceptance
  leaf retains its independent N/V obligations and human stop rule.

## Notes

Load the integration skill for this leaf's kind. It owns fixes and post-fix
verification; the preceding review ran no test, build, lint, format command or
native discovery read.
