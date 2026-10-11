# Application population metadata shape

[Subject evidence → Preserve joint facts before choosing a population](../design/architecture/index.html#diagram-native-population-metadata-shape)
shows the current boundary. Graphs enter at the dark Start here node; numbered
edges express dependency order. This is the permitted **corpus-insufficiency
boundary**, not a selected P1024 distribution or a useful qualification pass.
The [per-copy audit](../design/application-population-metadata-shape.json) preserves
all saved associations without inventing missing data. Private eligibility remains
false under the [canonical predicate](../specs/application-metadata-private-qualification.md#eligibility-and-existing-qualification-sequence).

## What the saved corpus establishes

The historical macOS 26.6.2 (25G83) census contains 640 directory spellings:
290 under /System and 350 installed non-system spellings. The latter include
nested helpers and installation copies; location alone does not classify a
useful GUI app or an independent application identity. The saved census is neither
an exhaustive host population nor the actual supported VM baseline.

Every audit row pins a baseline ordinal, spelling, canonical digest of the entire
saved row, associated grouped episode ordinal and inventory-profile reference.
The two input packet digests bind their complete original rows, receipt arrays
and all 2,043 combined episode associations. Consumers follow the reference into
the frozen packets, rather than independently sampling sizes, locales or keys.
No file/hash/name association, rejected entry, unselected key, LocProvenance
record, long-root row, source repeat or outside observation is deleted.

| Saved cohort | Spellings | Information bytes | All fixed-file bytes | Direct locale records | Raw direct entries | Loctables |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| System | 290 | 934,207 | 3,594,216 | 10,794 | 14,721 | 247 |
| Installed non-system, including helpers/copies | 350 | 1,404,355 | 3,296,899 | 2,878 | 13,773 | 0 |

These summaries describe that exact joint evidence, not marginal sampling inputs.
637 saved copies use Contents and three use flat layout; Support Files and
Resources occur only in controlled branch fixtures. The real tail includes the
83,346-byte information file, 103,197-byte loctable and 129-byte localized name.
The [original subject](application-metadata-subject.md#dimensions-and-accounting-comparison)
retains those witnesses and all direct component bytes. Both selector runs and
[grouped receipts](application-metadata-grouped-storage.md#receipt-replacement-and-complete-composition)
remain comparison evidence with conditional native operands and wire.

## Exact information loss

The versioned census stores 2,046 regular fixed-file observations with sizes,
SHA-256 and identity stamps, but does not store their bytes or encoding/format
tags. A digest verifies supplied bytes; it cannot reconstruct them. The evidence
instrument's measure_file function passes bytes through plistlib or plutil and
retains a projection of the result. A parsed DICTIONARY tag does not distinguish
binary/XML/OpenStep strings, encoding, serialized order or layout of that payload.

For its 247 loctables the projection retains dictionary-valued raw keys, other
raw keys, per-dictionary key counts, en/de chosen names and a maximum chosen-name
length. Thus it preserves useful key/type-category facts, including whether an
observed LocProvenance value is dictionary-valued. It omits complete member
keys/types/values, LocProvenance contents, all other languages' strings and their
individual display-name/bundle-name/rejected candidates. The single maximum
loses which language and key supplied the tail. Non-table files similarly keep
one chosen name; absent, empty, non-string and rejected display/bundle candidates
cannot be recovered from that result. Grouped literal-key/slab receipts and
two finite selector plans cannot restore these losses.

For example, FindMy's table retains 42 raw dictionary keys, including
LocProvenance, 28 entries for each language dictionary, English Find My,
German Wo ist? and maximum chosen-name length 33. It does not retain the exact
33-byte value or its language/key association, rejected alternatives, or the
other dictionary contents. Repeating that row, independently assigning a
33-byte string, or padding generated XML to its 95,891-byte size would fabricate
precisely the associations this subject must qualify.

## Recommendation and alternatives

**Recommend retaining all holds and obtaining one bounded human decision about
recovering the missing evidence before selecting the distribution.** First assess
whether a byte-complete, digest-matching archive of the credited capture can be
supplied. If none exists, the human must explicitly authorize bounded evidence
packaging or change the design-evidence requirement. This session performs neither
fresh target inspection nor a VM run and authorizes no new capture programme.
The existing N5/N8/V11/V13 programme still owns actual supported-VM qualification.

| Approach | What it supplies | Why it cannot presently establish the requested shape |
| --- | --- | --- |
| Recover byte-complete evidence matching each saved file digest, with independently verified useful-copy classification | Actual formats, complete typed candidates and joint tails; retains the historical source limit | The named saved packets do not contain it. Availability and permission to acquire missing evidence need the bounded decision. This is the recommended route. |
| Resample or repeat the 350 installed non-system projections to fill 1,010 app identities | A concrete projected dimension distribution | Helpers/copies are not a measured useful-app cohort; every repeated projection still lacks formats and full candidate associations. It fails the specified evidence contract. |
| Construct a synthetic maximum-size/keys/languages envelope | Declared artificial stress | The joint branch/string/format facts and language/component extent lack a measured justification. Per-file caps do not bound the entire correlated population. A failing or passing artificial case cannot silently replace the requested useful shape. |

No one of the last two approaches is selected. No probability, confidence,
representativeness or universal 1,024-app-machine claim follows these observations.
A subsequent design must state an explicit finite joint shape and reproduction
mapping; missing evidence cannot become a language subset, smaller population,
helper deletion, weaker gate or new amount/posture. The failure here is a known
subject-design gap, not actual native gross/attempt exhaustion. Valid exhaustion
later goes once to the existing human coverage decision; it is not a route around
this missing prerequisite.

## Required reproduction contract after the decision

A qualifying design must freeze the complete source evidence, independently
classify its useful cohort, and select whole per-copy tuples with an explicit
multiplicity/assignment rule for 1,010 distinct useful test apps. Keep the fourteen
configured/system witnesses, 256 helpers, 128 aliases and **all actual VM baseline
and registration pressure** in that same workload. Identifiers/executable/signing
rewrites need explicit manifests and independently checked resulting byte sizes,
formats, typed candidates, locale components and selected/refused branch effects.
They cannot silently preserve a source digest or source identity after editing it.
Every helper/alias also needs its exact joint recipe/target association; the old
thin helpers are not exempt from shape design.

The mapping must retain each information/name-file family, layout, format,
raw direct component, table key/dictionary/type/LocProvenance fact, selected and
rejected string, and all tail associations. Independent original evidence must
check generated per-copy artifacts, not merely totals produced by the generator.
A recipe covering only en/de fails full key/value preservation. The actual
supported VM baseline is additive, never replaced by these historical 640 rows.
Fit under every selected count, scoped gross/attempt, deadline/slot and full-wire
gate remains an actual acceptance obligation; baseline that does not fit stays
live rather than being removed. No recipe or distribution is frozen here.

A future pass qualifies only the explicitly selected joint finite shape plus
that run's actual full baseline, source batches, preferences, image/profile and
supported OS. It does not establish an arbitrary population of the same size,
all-disk completeness, total heap/RSS/peak, opaque-native health or another OS.
All independent location/Settings/core/action/authority/disclosure/source-and-image/
compatibility duties stay live. Real publication and all nine tapes remain required.

## Reproducible boundary checks

Run task design:application-population-metadata-shape to write the saved projection
audit; it reads only named repository inputs and constructs no app. Run task
design:application-population-metadata-shape-check to compare it and observe every
broken control before crediting the clean comparison. The controls replace all
metadata with thin fixtures while retaining cardinality, clip real size tails,
remove a loctable, drop an unselected raw key or LocProvenance, and swap file sets
between copies while leaving global marginals unchanged. Each must fail exact
independent saved-row comparison; reorder alone must pass. False qualification,
private eligibility, native pass and removed-hold claims also fail.

These controls verify preservation of the **available projection**. They do not
validate the missing file bytes/typed strings, qualify a distribution or establish
native usefulness. The manifest explicitly records no selected distribution,
no qualification recipe and no qualification scope. Hash every input packet,
evidence instrument, audit/test source, Taskfile and Python executable before and
after; check mode also freezes the saved output. The whole reconciliation suite
freezes the full family and tools separately. A changed input invalidates a run.
