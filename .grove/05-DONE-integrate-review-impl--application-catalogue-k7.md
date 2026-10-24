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

## Decisions (running log)

- **Source read.** Findings come from the committed `application-catalogue-k6` review. Both were checked against the source at `@-` and against the macOS SDK header `NSMetadata.h`.
- **R1 accepted as a real issue, filed, not fixed.** The timeout branch of `IndexedApplicationQuery.run(wait:)` queues its outcome on the serial queue that already runs `gathered()`, then calls `waitUntilAllOperationsAreFinished()` without a bound. A slow or stalled gathering therefore overruns the deadline, and a late `.gathered` can read as complete. No evidence shows the ordinary happy path meets that state, so issue 10 sends it to an issue: https://github.com/Linkuistics/Koine/issues/12. If the V run in `discovery-acceptance-k4` cannot obtain the application list because of it, the finding becomes a blocker.
- **R2 accepted as a real issue, filed, not fixed.** `NSMetadataQueryIndexedLocalComputerScope` includes the home directory "even if remote" (`NSMetadata.h:191`). `CapabilityDisclosures.workspaceRead` says local disks only. The same wording sits in `GrantManagementTests`, the search spec, the feature ADR, the client guide and the README. The defect does not stop the read-and-launch path: https://github.com/Linkuistics/Koine/issues/13. A fix before 0.4.0 changes one text in five places and one test. A fix after 0.4.0 needs a new host feature version. The release leaf shows the human the final text and can raise this.
- **No code, test or doc change.** Neither finding is a happy-path blocker, so this leaf runs no test, build, lint or format command. `discovery-acceptance-k4` keeps its own N and V obligations and its human stop rule for a permission dialog that names Koine.
- **Review conclusions 1, 3, 4 and 6 stand as reported.** The review found no defect in them and asked for no action. Check 6 stays open until V.
