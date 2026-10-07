# long-search-result-actions-k170

**Integrates:** long-search-result-actions-k169

## Goal

Triage k169's finding and reconcile the exact public open-path description with
the reviewed target/discovery/selected-application stages before planning k167.

## Context

- Review `long-search-result-actions-k169`, anchored to k168's design commit
  `6647c3a6` (`zlnnvywv`). Read its R1 and checked/accepted conclusions; the
  finding is the review's deliverable, not this charter's summary.
- `docs/design/workspace-action-repair-schema.graphql:83` and
  `docs/specs/workspace-launch-and-open.md#order-of-target-and-application-stages`:
  target refusal precedes handler discovery, but an over-limit discovered
  application can only be refused after its location is discovered.
- Search 1.1.0 incorporates the repaired action descriptions. The standalone
  `workspace-search-schema.graphql` is a separate extension; `Taskfile.yml`'s
  `design:search-check` shows the repaired-action composition.
- Planning `long-location-actions-k167` consumes the reconciled design next.
  Native/public/binary/signed-VM acceptance remains that planning chain's work.

## Done when

- Classify R1 against its exact evidence. Apply the actionable correction or
  record a supported dismissal in the running log.
- Make refusal guarantees stage-specific without changing shapes, enums,
  error kinds, capabilities, the settled hand-off bound or independent
  1.0.0 / action-repair 1.0.1 / search 1.1.0 profiles. An over-limit target gets
  no discovery read; a refused discovered application may have the discovery
  read required to learn its location and gets no subsequent pathname metadata
  or domain request. Preserve the no-domain-request guidance.
- Reconcile any affected current-state explanations/composed contract and
  planning's existing L subjects, distinguishing necessary discovery from
  forbidden subsequent calls. Preserve the review's supported short-path,
  candidate, cycle, name-limit, permission, reveal-root and nil semantics.
- Verify the correction through applicable deterministic Taskfile design checks;
  record the results without promoting them to runtime acceptance.

## Notes

This is design integration only. Antony's v1 refusal and descriptor-relative
access decision are settled. No new hand-off workaround, long-path application
support, shorter search ceiling, consent, entitlement or signing change is
authorized. First-use search-only prompt behavior remains pending with the
existing requirement to return to Antony if it prompts.
