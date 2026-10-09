# native-discovery-k211

**Integrates:** native-discovery-k210

## Goal

Triage the findings of `native-discovery-k210` against the complete native
discovery producer `native-discovery-k205` (closed by `native-discovery-k209`),
and apply the real ones, so that app-and-file-search-k7 and its reconciled
downstream chain consume a coherent, reviewed contract.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `165b6a430dfe`, whose coordinates
  equal the review's tree.
- The artifact: `docs/specs/workspace-search.md`,
  `docs/verification/native-discovery-sources.md` and
  `native-discovery-acceptance.md`, the three design certificates under
  `docs/design/` (`application-population.json`, `settings-readiness.json`,
  `long-application-metadata.json`), the native SDL/examples, composed SDL and
  four native profiles, the client guide, CONTEXT, requirements, Machine,
  workflow trace, launch-and-open's long handoff rows, the ADR set and the
  native architecture views, together with the Taskfile design checks that pin
  the certificates.
- Downstream charters that may need adjusting: root brief, k7, k191, k127,
  k123, k30, k93 and baseline k17.
- Approval is unchanged. Integrating a finding does not authorize a new reader,
  helper, consent/access/signing posture, smaller useful category or accepted
  workflow loss. Anything that would need one goes to Antony with a
  recommendation and the evidence, never silently into the contract.

## Done when

- Every finding is classified (a contract stated unclearly, valid and
  actionable, a visible accepted trade-off, or noise), with the reason recorded
  in this leaf's running log, and each actionable one is applied where it lives.
- Any certificate, envelope or G/N/V subject a fix changes is re-derived and
  kept consistent across spec, source report, acceptance, certificates, SDL and
  examples, guide, glossary, trace, views and the affected charters. No native
  verdict is credited and no live leaf is pruned.
- Frozen checks appropriate to the changed inputs pass with deliberately failing
  controls, and claim no native pass. Substantive redesign beyond what this
  integration can verify becomes a new producer review chain before k7, not an
  in-session rewrite.

## Notes

No implementation, native probe, launch, consent request, signing change or VM
experiment. One narrow in-session reviewer is allowed by the integration
allowance. Triage and reconciliation must finish before app-and-file-search-k7.
