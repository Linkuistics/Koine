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
