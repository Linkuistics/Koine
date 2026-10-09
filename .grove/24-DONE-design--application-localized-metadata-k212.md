# application-localized-metadata-k212


## Goal

Repair the application catalogue's admitted localized-name reader construction,
deriving every pathname boundary it actually addresses before app-and-file-search
implements it. Preserve useful localized names and the agreed native category.



## Context

- Review native-discovery-k210 at `bad36298`, finding R2, against complete
  producer native-discovery-k205 (`165b6a430dfe`). Integration native-discovery-k211
  classifies the issue as valid and externalizes this redesign. Read its committed
  triage and current artifacts, including the repairs to diagnostics and Settings.
- docs/specs/workspace-search.md, docs/verification/native-discovery-sources.md
  and native-discovery-acceptance.md, docs/design/long-application-metadata.json
  and application-population.json, Taskfile design checks, SDL/composed SDL,
  architecture native-long-applications view and downstream k7/k191/k127/k123/k30.
- The 20-byte `/Contents/Info.plist` suffix forces indexing at a 1,004-byte
  bundle, but does not authorize a localized dictionary read below it.
  `/Contents/Resources/en.lproj/InfoPlist.strings` adds 46 bytes; Base/English and
  other localization names differ. L1500's 1,003-byte copy cannot be credited as
  an ordinary localized-reader control. The certificate explicitly marks the
  complete ordinary boundary unresolved.
- No new reader/helper/access/consent/signing posture, unlocalized substitute or
  useful-category loss is authorized. A choice requiring one needs Antony's
  concrete recommendation/evidence decision before being adopted.

## Done when

- Select a constructible admitted type/identifier/localized-name/flag episode
  with explicit provenance and enumerate every whole pathname addressed, its
  actual length limit and safe admission rule. No arbitrary universal locale
  length, hidden enumeration/fallback or Info.plist-only proof. If this cannot
  be settled inside the existing boundary, surface that concrete choice to Antony.
- Re-derive attempt/gross-copy/wire implications and reconcile spec, source,
  certificates/checks, SDL/examples/composition/profiles, acceptance, guide,
  glossary, requirements, Machine/trace, ADRs/views and affected live charters.
  Keep the unchanged 1,024-byte action handoff and independent old action evidence.
- L1500 has a safe actual localized ordinary-reader control below the derived
  boundary and a copy inside the formerly missed longer-resource band, plus
  actual indexed tuples/current-identity and same-ID competitor controls.
  State exact source/reader routing and useful known-name expectations; native
  G11/N8/V13 verdicts remain pending. Frozen design checks need broken controls.
- Cut a mandatory review-design of this producer with the bare stem
  application-localized-metadata before k7; its Reviews names this handle and
  finishing this producer writes its own actual Creator. The review must assess
  the complete reconciled contract, including compatibility with k211's repairs.
  Any earned integration also precedes k7. Never let k7 consume the unresolved
  boundary or an unreviewed redesigned reader.

## Notes

Design only: no implementation, native probe, launch, consent request, signing
change or VM experiment. Existing graph CLI was unavailable to k211 because an
incompatible generation was active; do not infer graph coverage from that attempt.
Recheck graph availability for any new source discovery and fall back explicitly.

## Decisions (running log)

- The jj working copy starts empty on k211's committed integration. The graph
  CLI again refuses startup because a pre-coordination/unverified generation is
  active. Use bounded source/SDK/document fallback; no graph generation or
  coverage is established. Taskfile.yml is the deterministic design entry point.
- Exact suffix arithmetic exposes distinct safe example endpoints: en.lproj's
  InfoPlist.strings fits at 977 bundle bytes and fails at 978; Base fits at 975,
  English at 972. A 1,003-byte bundle's en resource is 1,049 bytes excluding NUL.
  These are counterexamples to the old guard, not complete Bundle admission.
- SDK 27 NSBundle.h documents selection using user preferences and available
  localizations, without an exhaustive pathname manifest or a caller-controlled
  lookup plan. Apple's published historical CF sources additionally show
  resource-directory enumeration, Base/development fallback and platform-specific
  Info-macos.plist lookup. They are counterexamples to the assumed recipe,
  not a source map of the shipped macOS 26+ implementation. Neither asking Bundle
  for localizations nor assuming a fixed locale suffix repairs admission before
  those discovery calls themselves have been qualified.
- No complete admitted episode has been established. Present the concrete
  recommendation in workspace-search's Localized reader decision: authorize
  design of an explicit bounded per-application metadata reader and direct
  localization-directory discovery, preserving useful-name/flag obligations.
  This is a new target-local contents/listing exception, not authorization
  already implied by lookup-only resolution. Indexed-only metadata is the
  alternative, with its non-indexed support gap explicit. Requested Antony's
  decision; no choice is adopted without the answer. No new reader is built.
  This leaf stays live until the selection, complete reconciliation, derived
  L1500 control and mandatory review charter have been delivered.
- Added exact example-path certificate and design:localized-boundary-check.
  Its broken controls reject an Info.plist-only complete-reader claim, invented
  ordinary control, incorrect suffix, NUL off-by-one, character-count-for-UTF-8,
  historical-source-as-current-platform and falsely fitting 1,003-byte control.
  These establish counterexamples, never a complete ordinary reader or native pass.
- Final frozen run of design:localized-boundary-check, design:search-check,
  design:settings-check, design:long-applications-check and check:docs passed.
  All 16,709 input paths/hashes matched individually before/after, with a
  changed-item digest control rejected: all repository Markdown outside build/
  .grove/VCS output, design artifacts, contract-client package/lockfile and
  installed modules, Taskfile, documentation checker, Node/task/Python executables
  and digest instrument. No writer changed those subjects during this run.
  Application certificate remains 989,240 attempts / 6,816,128 gross bytes /
  7,929,856 wire bytes; Settings remains 514 events / 90,304 attempts /
  6,094,976 gross bytes. None is a certificate for the unadopted reader.
- Regenerated the native presentation through its existing Taskfile task and
  inspected the new SVG at a fresh deep-linked Chrome page on loopback port 8924.
  The diagram, caption, current-discussion panel and changed marker identify
  the scope as proposed, with the complete-reader gap and both alternatives
  visible. Existing action/Settings/population views remain unchanged context.
  No production code, native probe, target launch, consent/signing or VM work
  occurred. Awaiting the explicit scope answer; no retirement, Creator naming
  or completion exit signal is appropriate while this producer remains live.
- Antony answered yes to the concrete target-local metadata-reader proposal.
  Authorize design of fixed bundle-file reads and direct localization-directory
  listing for one observed installation; no helper, new OS consent, entitlement,
  signing change or useful-category reduction is authorized. Continue this same
  producer to a complete reviewed handoff rather than re-requesting approval.
- Select resource type at the resolved bundle root, followed by descriptor-relative
  fixed-file metadata. Never initialize a foreign Bundle or invoke its resource/
  localization discovery. Only the root resource-type call uses a whole target
  pathname: admit at <=1,023 UTF-8 bytes; at >=1,024 preselect the actual indexed
  tuple route with UNKNOWN/null flags. Metadata descendants use literal components
  from held directories, so their total spelled length does not reintroduce a
  whole-path limit. This extends the ordinary reader through the previously missed
  978…1,003 en-resource band while leaving all action handoff/Bundle evidence
  independent. BUNDLE_RESOURCE denotes this explicit resource-type/fixed-file
  episode; no new public enum or framework ABI is needed.

- Closed the ordinary caller-visible file/call manifest: four fixed layouts,
  platform/plain information and name pairs, one direct resource inventory and
  explicit-preference CF selector plus global/Base/observed-development fallback.
  Metadata descendants use held-directory nofollow components with actual parent
  NAME_MAX (excluding NUL); links/special/dataless/refused/malformed candidates
  cannot trigger a convenient fallback. The root property call and native parser
  internals remain opaque and require real N8 qualification.
- Retain selected information and current name-file inputs in two fixed 64 KiB
  buffers within existing scratch, with borrowed native dictionaries and final-
  only scalar copying. No deep copy, candidate-name recopy or separately copied
  development-region is admitted. Parsed native peak remains unbounded by the
  owned certificate. L1500 uses seven boundary copies (977/978/1003/1004/1023/
  1024/1500) and two short same-ID competitors, actual indexed tuples and distinct
  localized/plain names. Ordinary 1004…1023 state remains UNKNOWN under unchanged
  action Info.plist support; indexed roots remain UNKNOWN/null flags.
- Derived fixed40 +16U+5R+12D+32C+8E+48F+2C(6V+4), F<=4C+2L. E includes all raw
  directory/preferences/selector values. Finite E=65,536/L=4,096/F=16,384/V=32
  gives 2,345,024 attempts under 4,194,304. Former records/scratch plus 1,000,000
  aggregate gross input bytes and 4,096×(64+2×32) localization storage give
  8,340,416 gross bytes under unchanged 8 MiB; wire 7,929,856/core 8 MiB unchanged.
  L/input/component maxima are finite qualification dimensions, not production
  locale quotas; actual baseline must fit and useful failure reaches k93 once.
- Reconciled spec, source report, two certificates/new manifest, meaningful Taskfile
  controls, SDL/examples/composition, acceptance, guide/glossary/requirements,
  Machine/workflow trace, current ADRs, views and live k7/k191/k127/k123/k30/k93
  charters. Native releases/profiles/ABI pins and old action evidence remain
  independent; no implementation or native/VM/launch/signing/consent work occurred.

- The localization-copy term counts every retained inventory name, including
  unselected locales; selected file probes are only a subset. E also includes
  every preference/selector slot. Finite preference scratch is <=32 records and
  4,096 payload bytes within the existing scratch allowance; native acquisition
  and parser objects remain disclosed opaque allocations. No omitted inventory
  copies or universal locale/prefs quota is credited.

- Fresh final frozen run after the approved construction: task
  design:localized-boundary-check design:search-check design:settings-check
  design:long-applications-check check:docs exited zero. The preliminary run
  caught an application-only replacement accidentally inserted into the Settings
  check; systematic root-cause inspection restored that check before this run.
  The application certificate is 2,345,024/8,340,416/7,929,856; Settings remains
  514 events/90,304 attempts/6,094,976 bytes and saturation guidance max 843 bytes.
  All broken manifest/arithmetic/provenance/budget/authority/profile controls
  rejected. Every one of 16,709 subject paths/hashes matched before/after, with
  a changed-item digest control rejected: repository Markdown excluding .grove/
  VCS/build outputs, all design files, contract-client package/lockfile/modules,
  Taskfile, documentation checker, Node/task/Python executables and the digest
  instrument. No writer changed those frozen subjects during measurement.
- Regenerated SDL/changed SVGs before freezing, inspected reader, long-routing,
  population and composition views in Chrome and the reader at a 390×844 viewport
  (fit view is an overview; native-size/full-SVG controls provide detail). Restored
  default viewport. A fresh reader deep link loaded all 34 SVG assets with no
  failed image, matching approved status, topic outline, captions and actual
  changed markers. Dark emulation is not exposed by this browser surface. Retain
  the reader tab at http://127.0.0.1:8924/#diagram-native-localized-decision.
- Rechecking graph project/generation still fails at CBM startup with the same
  unverified/pre-coordination-generation refusal. No graph/coverage claim or
  CBM repair follows. Bounded SDK/config/document evidence remains the provenance.
- Done-when audit: explicit caller-visible pathname/file/localization construction,
  revised certificates and frozen broken controls, reconciled consumers/views/
  live charters and L1500 ordinary/band/indexed witnesses are delivered as design.
  All native G/N/V remain pending; action evidence, ABI/releases/profile pins and
  k211 repairs remain independent. Cut the mandatory complete-contract review
  before k7 as the final work step, then retire/name Creator/seal this root leaf;
  the root retains live work so there is no parent-chain close.

- Cut application-localized-metadata-k213 as mandatory review-design immediately
  before k7, with Reviews naming k212 and Creator taken from this finishing
  session's own HARNESS_DISPATCH_RUN_ID. Its charter challenges the complete
  reconciled contract, all caller-visible admission/localization/cost/ownership
  doubts, finite native-pending witnesses, image/authority/profile boundaries and
  compatibility with k211; any earned integration must also precede k7.
