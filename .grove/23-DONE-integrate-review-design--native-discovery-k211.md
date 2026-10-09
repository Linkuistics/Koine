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

## Decisions (running log)

- Read k210's findings from review commit `bad36298`, against producer
  `165b6a430dfe`. The stated jj workspace starts clean. Codebase-memory CLI
  list_projects cannot start because a pre-coordination/unverified generation
  is active; use direct document/source fallback, with no graph or coverage claim.
  Taskfile.yml owns the existing deterministic design checks.
- R1 is valid and actionable: per-item uncertainty can exceed 63 detail records
  within both population envelopes. Keep the 64-record storage bound and final
  DIAGNOSTIC_LIMIT record, but continue discovery after detail saturation.
  Derive status/source precedence from fixed per-source reason bits, independently
  of stored details. Saturation marks an omission of guidance, with no item loss,
  native-order survivor selection or resultsTruncated claim. Record/byte/call
  population gates still fail closed. Use existing fixed-record reserves for
  reason bits; arithmetic is unchanged and N5 must account actual storage.
- R2 is valid but requires a new design producer: the 20-byte known-plist suffix
  says nothing about the longer and variable localization resource pathname.
  For example `/Contents/Resources/en.lproj/InfoPlist.strings` is 46 bytes;
  a 1,003-byte bundle is not a proved ordinary localized-reader control.
  Choosing an admitted localized-name route and deriving every addressed path
  is more than repairing a threshold. Externalize that repair with mandatory
  review/earned integration before k7; mark the existing certificate's localized
  resource boundary unresolved. No new reader, unlocalized substitute, arbitrary
  locale-length bound, useful-choice loss or native acceptance is selected here.
- R3 is valid and actionable: lazy no-such-object does not establish absence in
  either read or reveal. A failed exact reveal pre-check remains failed with
  uncertainty guidance and no reveal/activation; it cannot become
  SELECTION_UNAVAILABLE under this runtime source. Keep positive re-resolution
  before either effect. Add a separate fresh unvisited incarnation revealing
  a pane/anchor recorded in an earlier incarnation; inability to deliver the
  required ordinary destination remains unmet useful acceptance for k93.
- R4 is a contract stated unclearly, with an actionable inconsistency: a
  confirmation deadline need not erase a complete first map. Preserve its
  uncontradicted positive entries as PARTIAL/TIME_LIMIT with UNKNOWN readiness;
  an incomplete first sweep still fails on deadline, and count/call/copy overflow
  still invalidates the population. Accepted second-sweep contradictions withhold
  affected first-map entries; target/lifecycle loss cannot be rescued. Freeze
  ownership/publication normally and retain the slot until native true return.
- Re-derivation makes the R1 summary charge explicit rather than hiding it in a
  record allowance: four fixed 32-byte source summaries add 128 gross bytes.
  Application gross copies become 6,816,128; wire stays 7,929,856. Settings
  diagnostics reserve 64×2,048 gross record/payload bytes (the prior 65,536
  covered guidance alone); with the summary its gross certificate is 6,094,976.
  Attempts remain 989,240/90,304 under 1,048,576/131,072; all copy gates stay
  8 MiB. New design assertions were run against the old certificate and rejected
  the missing independent diagnostic policy before the certificate was edited.
- Spend the one narrow doubt reviewer on diagnostic-summary/confirmation-checkpoint
  constructibility and precedence, with document-only evidence and no parent
  conclusions. Its sole finding is valid/actionable: internal reason masks alone
  can leave clients unable to see a failure after detail saturation. Project all
  observed source/reason tokens canonically in the reserved record's guidance;
  derive the closed-enum three-source worst case under 1,024 bytes and reject an
  undersized encoding control. Existing diagnostic gross storage covers it;
  actual N5 must count transient replacement copies. No new public field or
  native call is selected. This executable encoding seam covers the repair;
  spend no second reviewer. K212's later review owns the new reader redesign.
- Insert application-localized-metadata-k212 before app-and-file-search-k7.
  Its producer must cut its mandatory whole-contract review before k7 and name
  its own Creator; any earned integration also precedes k7. Root retirement of
  k211 closes no ancestor node and must not name another producer's run.
- The canonical three-source summary re-derives to 843 bytes, below 1,024.
  Render once at freeze from fixed masks and reusable scratch, avoiding repeated
  gross copies inside one diagnostic allowance; late replies cannot alter it.
  Certificates and failing controls pin that construction. The review's sole
  finding is repaired through this executable encoding/budget seam; its limits
  remain document-only, with no graph, implementation or native evidence.
- Reconciled the current spec/source/acceptance, certificates, SDL/composed SDL,
  guide/glossary/requirements, Machine/trace, affected ADRs, architecture captions
  and live k7/k191/k127/k123/k30/k93/k17 charters. Existing profiles continue to
  point at the recomposed complete SDL and retain action-only fallbacks. Native
  source/binary/usefulness verdicts all stay pending. V12 adds one separate
  unvisited-incarnation pane/anchor selection per profile after its three cold/warm
  comparisons; no observer or earlier pane-only reveal may warm that target.
- Fresh `task --silent design:search-check design:settings-check
  design:long-applications-check` passed, including deliberate declaration,
  accounting, visibility/encoding, authority and profile mutations. Application
  outputs: 989,240 attempts, 6,816,128 gross bytes, 7,929,856 wire bytes; Settings:
  514 events, 90,304 attempts, 6,094,976 gross bytes. The localized resource boundary
  is explicitly unresolved and the false ordinary-control declaration is rejected.
  SHA-256 manifests compared every one of 16,563 input paths before/after: Taskfile,
  all docs/design artifacts (certificates, SDL, examples, profiles and views),
  contract-client package/lockfile and complete local node_modules, Node executable
  and digest instrument. Every path/hash matched; a deliberately changed-item
  digest control failed. No writer edited those subjects during the checks.
- `task --silent design:native-discovery-render` regenerated the eight native
  views successfully before the frozen checks. Only the four changed diagrams
  differ. These are deterministic design checks/rendering, no native G/N/V pass;
  no implementation, probe, consent, signing, launch or VM experiment occurred.
