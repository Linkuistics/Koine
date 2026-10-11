# Application population metadata shape

[Preserve joint facts before choosing a population](../design/architecture/index.html#diagram-native-population-metadata-shape)
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
No reference population has been selected for the 1,010 generated useful apps.
Historical host templates, current-host templates, supported-VM templates and a
justified finite envelope answer different questions; recovering historical bytes
alone cannot select among them or establish representativeness.

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

The file families are disjoint: System has 289 regular information files and 249
global name files, including all 247 loctables and two other name files, with no
per-locale strings. Non-System has 348 information files and 1,160 per-locale
strings, with no global name file or loctable. The source information projection
records at least one true agent/background flag for 179 copies (134 System,
45 non-System), and 13 spellings are nested under another app (five System,
eight non-System). These are partial, reader-derived classification inputs.
They establish no independent useful cohort and justify no choice suppression.

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

The audit enumerates every actual file-row field before classifying it against
reader facts; an unclassified field refuses the audit rather than disappearing
from a hand-written list. The packet's `fileProjectionInventory` and each cohort's
inventory carry per-field occurrence counts and limitations:

| Projected fields | Retained fact | Lost reader fact |
| --- | --- | --- |
| relative, role, state | File/copy association, family and filesystem category | Payload and serialization |
| bytes, sha256, identity | Length, supplied-byte equality token and captured stamps | Bytes, format, current occupant or reconstructable contents |
| parsed, dictionaryKeys | Top-level parse category and count | Serialization, all member keys/types/values |
| localeKeys, otherKeys, localeDictionaryKeys | Raw dictionary/non-dictionary key categories and per-dictionary counts | Exact non-dictionary types/values and all dictionary members |
| names, maximumNameBytes | Chosen en/de strings and chosen-name maximum | Other-language and rejected candidates; maximum's language/key/value association |
| name | One selected non-table name | Individual display/bundle candidates and absent/empty/non-string/rejected branches |
| identifier, identifierNativeType | String/null and Python projected type | Original non-string contents and absent-versus-null key distinction |
| developmentRegion, developmentRegionNativeType | String/null and Python projected type | Complete original non-string value and absent-key distinction |
| flags | Boolean/null for each flag | Null conflates absent and malformed/non-Boolean values |

For regular information files that last loss affects 474 LSUIElement observations
(170 System/304 non-System) and 614 LSBackgroundOnly observations (272/342).
Their original missing-versus-malformed branch and typed values remain unknown.
No null becomes a false flag or a usefulness classification. Original payloads
or an explicitly justified declaration must resolve every required reader branch.

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

**Recommend retaining all holds and deciding the finite reference and its purpose
before authorizing cohort-specific recovery or a justified envelope.** K240 asks
which real population the generated apps should reflect, why, and which historical
cohorts would feed their templates. The actual supported-VM baseline is additive
in every case; historical System templates are needed only if the selected mapping
uses them. The historical census is a concrete available comparison corpus, not
an already selected useful-app reference. A current-host or VM reference would
need its own bounded evidence authorization; no such evidence is acquired here.

| Cohort | Missing evidence | Candidate recovery source and verification limit |
| --- | --- | --- |
| Historical System | 538 payloads/formats, all 247 complete loctables, full candidates and ambiguous flags | An existing archive or matching 25G83 system image is a candidate. The common saved file timestamp supports inspecting that candidate, but does not prove image availability or identical bytes. Every relative file/copy must match its saved SHA-256 before credited recovery. Obtaining image bytes is acquisition requiring K240's decision. |
| Historical non-System | 1,508 payloads/formats, complete per-locale/information candidates and ambiguous flags | Existing archives or exact vendor/version artifacts are candidates, including nested helpers/copies. Matching app names or a newer vendor version is insufficient; each saved file digest and copy association must match. Availability remains unverified. |
| Selected current-host/VM reference, if chosen | Complete evidence for that specific inventory and its classification | This is new reference evidence, not recovery of the historical capture; source/build/scope and authorization must be explicit. The VM's actual baseline cannot be replaced with historical rows. |

Reading repository packets is not acquisition. No OS image, installed application
or VM is read here. A build label, timestamp or archive hash alone supplies no
complete per-copy replay or independent useful classification. This session
authorizes neither bounded packaging nor a change to the evidence requirement.
The existing N5/N8/V11/V13 programme still owns actual supported-VM qualification.

| Approach | Formats/candidates and joint facts | Useful classification | Multiplicity/assignment and justification gap |
| --- | --- | --- | --- |
| Recover needed cohort bytes with per-file digest/copy verification | Restores actual formats, typed candidates, flags and joint tails for recovered files | Still requires a separately named independent classification source | At most 640 historical tuples cannot supply 1,010 distinct useful apps without a declared rewrite/assignment. Recovery alone selects no reference or rule. Preferred where needed matching bytes are available; availability is unknown. |
| Repeat/resample projected rows | Retains only the saved projection; cannot restore unsaved facts | Same independent classification obligation; reader flags/location are partial inputs | Repetition is shared with other routes, not this route's unique defect. Unstated facts and independently sampled marginals fail the current contract. |
| Declare a per-copy joint envelope preserving every saved dimension | Declares only unsaved format/value/flag/candidate choices, with each original association retained | Same independent classification obligation | Requires an explicit 1,010-app assignment and proof that declared choices are a suitable finite envelope. No argument currently shows domination of opaque native parse cost or usefulness across those choices. A synthetic pass qualifies only that declared shape. |
| Declare a global maximum-size/keys/languages envelope | Artificial correlated stress, with no established per-copy association mapping | Same independent classification obligation | Per-file caps do not bound the correlated job. Maxima alone cannot establish the useful finite subject or replace the joint evidence. |

No route, reference, classification source or assignment is selected. No probability, confidence,
representativeness or universal 1,024-app-machine claim follows these observations.
A subsequent design must state an explicit finite joint shape and reproduction
mapping; missing evidence cannot become a language subset, smaller population,
helper deletion, weaker gate or new amount/posture. The failure here is a known
subject-design gap, not actual native gross/attempt exhaustion. Valid exhaustion
later goes once to the existing human coverage decision; it is not a route around
this missing prerequisite.

## Required reproduction contract after the decision

A qualifying design must freeze the complete source evidence, independently
name its reference population and reason, classify its useful cohort from a named
independent source, and select whole per-copy tuples with an explicit
multiplicity/assignment rule for 1,010 distinct useful test apps. Keep the fourteen
configured/system witnesses, 256 helpers, 128 aliases and **all actual VM baseline
and registration pressure** in that same workload. Identifiers/executable/signing
rewrites need explicit manifests and independently checked resulting byte sizes,
formats, typed candidates, locale components and selected/refused branch effects.
They cannot silently preserve a source digest or source identity after editing it.
Replication and rewriting create a declared finite constructed subject, not
1,010 independently measured applications. If a measured distribution informs
the assignment, state its actual scope and justify the resulting finite shape
or envelope without inferring population-wide representativeness.
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

These are **packet-integrity checks**: any row edit fails, including a declared
identifier rewrite, even if that rewrite would preserve the later shape contract.
The complete subject's rewrite-aware discrimination controls remain **unbuilt**
and cannot be satisfied by these hashes. Supplied-fact controls demonstrate that
the loss inventory counts illustrated payload/format/typed facts as present and
rejects an unclassified field. Their annotations select no recovery schema and
verify neither supplied bytes nor completeness of a typed tree.

These controls verify preservation of the **available projection**. They do not
validate the missing file bytes/typed strings, qualify a distribution or establish
native usefulness. The manifest explicitly records no selected distribution,
no qualification recipe and no qualification scope. Hash every input packet,
evidence instrument, audit/test source, Taskfile and Python executable before and
after; check mode also freezes the saved output. The whole reconciliation suite
freezes the full family and tools separately. A changed input invalidates a run.
