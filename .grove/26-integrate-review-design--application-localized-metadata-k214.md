# application-localized-metadata-k214

**Integrates:** application-localized-metadata-k213

## Goal

Triage the findings of `application-localized-metadata-k213` against producer
`application-localized-metadata-k212` and apply the real ones, so that
app-and-file-search-k7 consumes a reviewed explicit application metadata reader
whose bounds and file set fit the shipped platform.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `8117c5dc7614`, whose coordinates
  equal the review's tree. Three are high and rest on measurements of shipped
  macOS 26.6.2 described in the review's running log; re-measure rather than
  trust them where a fix depends on the exact values.
- The artifact: docs/specs/workspace-search.md, native-discovery-sources.md and
  native-discovery-acceptance.md, application-localized-admission.json,
  application-population.json and long-application-metadata.json, the Taskfile
  design checks, SDL/composed SDL/profiles, client guide, CONTEXT, requirements,
  Machine/workflow trace, facts/image/host-disclosure ADRs, native architecture
  views and the live k7/k191/k127/k123/k30/k93 charters.
- Approval is unchanged: Antony authorized design of target-local fixed metadata
  reads and direct localization listing only. Integrating a finding authorizes no
  helper, new consent/entitlement/signing posture, host policy increase, locale
  subset, baseline/helper filtering or useful-category loss. A fix that needs a
  sizing, file-format or posture choice beyond that approval goes to Antony with
  the trade-off, a recommendation and its evidence before it is adopted.

## Done when

- Every finding is classified (a contract stated unclearly, valid and actionable,
  a visible accepted trade-off, or noise), with its reason in this leaf's running
  log, and each actionable one is applied where it lives.
- Any certificate, gate, file set or G/N/V subject a fix changes is re-derived
  from measured shipped-baseline dimensions rather than assumed ones, and kept
  consistent across spec, sources, acceptance, certificates/manifest, SDL and
  examples, guide, glossary, requirements, trace, ADRs, views and the affected
  live charters. No native verdict is credited and no live leaf is pruned.
- Frozen design checks for the changed inputs pass with deliberately failing
  controls, including controls that would have caught the reviewed defects, and
  claim no native pass. Substantive redesign beyond what this integration can
  verify becomes a new producer review chain before k7, not an in-session rewrite.

## Notes

No implementation, Koine native probe, launch, consent request, signing change or
VM experiment. One narrow in-session reviewer is allowed by the integration
allowance. Triage and reconciliation must finish before app-and-file-search-k7.
