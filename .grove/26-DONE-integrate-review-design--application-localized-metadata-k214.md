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

## Decisions (running log)

- Bootstrap adopts the mandated live leaf in the stated jj workspace. The empty
  working copy is on review commit c1a0c6e5; its findings were read with jj file
  show from that commit against producer 8117c5dc7614. The graph CLI refuses
  startup because a pre-coordination/unverified generation is active. Use exact
  document/source fallback; no graph generation or coverage is established.
  Taskfile.yml remains the deterministic verification entry point.
- R1/R2/R3 are valid and actionable design defects, rather than accepted native
  uncertainty: conflicting oversized-file outcomes, a finite certificate whose
  required baseline refutes its dimensions, and an omitted shipped name-file
  format. Re-measure their fixed-file/inventory evidence read-only. Their coupled
  sizing/accounting/file-format repair is substantial redesign, so externalize a
  new design producer with mandatory whole-producer review/earned integration
  before k7. Adopt no new size, format, host gate, accounting refund or useful
  category exclusion in this integration. Mark the current certificate and file
  closure as refuted for consumption, preserving their arithmetic as a checked
  counterexample rather than a useful-population qualification.
- R4 is a contract stated unclearly with a valid wrong-language consequence.
  The selector's unmatched-preference backstop is positional. Put an exactly
  observed development region first in its possible-localization array, then
  byte-sort the remaining inventory. This retains actual matching preferences
  while making the positional backstop deliberate; with no observed development
  region the deterministic byte-first backstop is explicit. No extra selector,
  file, directory walk or locale subset is introduced.
- R5 is a contract stated unclearly. Specify information bases alongside the
  four resource bases, and first usable candidate precedence across bases: within
  one dictionary display name precedes bundle name; a later base's display name
  cannot override an earlier base's usable bundle name. Construct information
  candidates as well as name candidates in the design check.
- R6 is valid and actionable. Rework the existing host-disclosure ADR in place
  and pin the fixed-file/direct-localization read reach in G9/V10 and a deliberate
  clause-removal design control. Prior-host refusal/action-only fallback stays
  independent. Native G/N/V remains pending; no in-session reviewer is spent.
- R1/R2/R3 remeasurement on macOS 26.6.2 (25G83) confirms the actionable
  consequences with narrower exact evidence. The fixed query's checked /System
  .app-directory subject is 290, not the review's 325 (35 other indexed paths
  are outside it, explicitly recorded). It has 934,207 information bytes,
  10,794 locale records, 14,721 raw entries and 247 loctable bundles; maximum
  loctable 103,197 bytes, ten over 65,536. The indexed Unarchiver plist is
  83,346 bytes; system information plus that useful witness is 1,017,553 bytes.
  Substituting system-only L/input into the old full-envelope construction gives
  a certificate subtotal 9,131,967 at the old fixed 128-byte locale reservation,
  above 8 MiB before fixture/name/repeated inputs. This is not measured allocation,
  a lower bound on actual component-copy bytes, or a complete P1024 manifest. Per-item
  identities, byte/hash records and inventory digests match before/after;
  instrument hash a4bcfecfc214a1ca4d4e54cfa4d2f7acefc3703593a703026949df3755698028
  also matches. The first attempted measurement rejected a non-directory query
  item rather than reporting a false bundle count; only the corrected frozen
  directory measurement is credited.
- Pure CF literal-array measurements reproduce R4: byte-first ar wins unmatched
  en-AU/en, observed development-first it then wins, and actual de preferences
  still select de. No Bundle/target/path/launch/consent call. Record those finite
  controls alongside the file manifest; no native reader/language support pass.
- Cut application-localized-metadata-k215 before the k7 sibling. It owns the
  coupled format/sizing/accounting decision, complete measured finite manifest,
  whole-artifact reconciliation and mandatory review/earned integration. Current
  manifest closure/useful-subject certificate become false with explicit k215
  consumption holds. R1–R3 remain real redesign work in that producer, not
  accepted loss, noise or deferred native uncertainty for k93. The recommendation
  and unapproved alternatives are recorded there; this integration selects none.
- Reconcile the holds/repairs across spec, source and G/N/V contract,
  localized/population/long certificates, SDL/composed SDL/four profiles,
  guide/CONTEXT/requirements/Machine/workflow trace, facts/disclosure ADRs,
  architecture source/exports/rollups and live k7/k19/k191/k127/k123/k30/k93.
  Rework ADRs in place; the image-authority decision stays unchanged. Preserve
  independently retained action-only evidence and all k211 Settings/diagnostic
  behavior. The old arithmetic is an explicitly conditional certificate subtotal
  at its fixed reservations, never a lower bound on actual component-copy bytes.
- Final verification after all artifact edits: design:search-compose and
  design:native-discovery-render generated the composed SDL and exports;
  design:search-check, design:localized-boundary-check,
  design:long-applications-check, design:settings-check and check:docs all exit 0.
  The new controls reproduce oversized information/loctable files, old aggregate
  input and L/copy assumptions, missing shipped loctable names, falsely credited
  closure, wrong selector ordering, undefined information bases, cross-base name
  priority and removed disclosure reach. Original schema/authority/profile/action,
  diagnostic-saturation and Settings controls still reject their broken subjects.
  Freeze/hash 1,718 subjects across docs/, CONTEXT, Taskfile, the link checker,
  client package/lock and installed graphql source; before/after comparison is
  item-for-item unchanged (records in .build/application-localized-baseline).
  An earlier misspelled Settings task name ran no checks and is not credited;
  the actual design:settings-check was run successfully in the final frozen run.
  No Koine build/probe/launch/VM/consent/signing change or native verdict is credited.
- Retirement closes only this root leaf; k215 and downstream work remain live,
  so no parent-chain close/promotion or Creator rewrite is due. Seal the focused
  jj change after the DONE rename, including the inserted producer and renumbers,
  then send harness-dispatch exit as the session's last action.
