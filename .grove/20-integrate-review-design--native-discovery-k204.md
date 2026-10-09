# native-discovery-k204

**Integrates:** native-discovery-k203

## Goal

Triage the findings of `native-discovery-k203` against the native discovery
design that `native-discovery-k199` returned (closed by `native-discovery-k202`),
and apply the real ones. app-and-file-search-k7 and its reconciled chain should
consume a coherent contract; any posture question the findings raise should be
put to Antony with a recommendation.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `913613ae98c1`, whose coordinates
  equal the review's tree.
- The artifact: `docs/specs/workspace-search.md`,
  `docs/verification/native-discovery-sources.md` and
  `native-discovery-acceptance.md`, the native SDL/examples
  (`docs/design/workspace-search-{schema,operations}.graphql`, the composed
  `desktop-workspace-native-schema-extension-host.graphql`) and native profiles,
  `docs/specs/machine.md` (consent ownership, capability disclosures, native
  profiles), the workflow trace's authority/disclosure rows,
  `docs/client-guide.md`, `docs/specs/workspace-launch-and-open.md`'s native
  handoff rows, CONTEXT, the ADR set (especially
  `settings-discovery-uses-app-supplied-objects` and
  `provider-authority-follows-effects`), the native architecture views, and
  `Sources/KoineCore/CapabilityDisclosures.swift` as the shipped disclosure text.
- Downstream consumers whose charters may need adjusting: root brief, k7, k19,
  k126/k191/k193, k127, k123, k120, k30, k93 and baseline k17.
- Approval is unchanged. Integrating a finding does not authorize a new consent
  route, entitlement, usage key, host feature, signing change, helper, smaller
  useful category or accepted workflow loss. Those go to Antony with a
  recommendation and the evidence, never silently into the contract.

## Done when

- Every finding is classified — a contract stated unclearly, valid and
  actionable, a visible accepted trade-off, or noise — with the reason recorded
  in this leaf's running log. Each actionable one is applied where it lives.
- Any finding that turns on a human posture decision (who may trigger Koine's
  OS consent, whether prior hosts may serve the native surface under their
  shipped disclosure) is put to Antony as a named trade-off with a recommended
  answer, and his answer is recorded before the contract builds on it.
- Durable artifacts stay mutually consistent after the changes: spec, SDL,
  examples, composed SDL, profiles, acceptance, trace, Machine, guide, glossary,
  ADR set and views. Mixed downstream charters receive any duties the changes
  create, and no ambiguous leaf is pruned or credited native-passed.
- Frozen checks appropriate to the changed inputs pass with deliberately failing
  controls (SDL/examples/profiles, links, renders), and they claim no native
  pass. Substantive redesign beyond what this integration can verify becomes a new
  producer review chain beside this leaf, not an in-session rewrite.

## Notes

No implementation, native probe, backend, consent request, signing change or VM
experiment. One narrow in-session reviewer is allowed by the integration
allowance; do not substitute it for a needed producer review chain. Native G/N/V
verdicts remain pending throughout.
