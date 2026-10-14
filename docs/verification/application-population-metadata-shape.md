# Application population metadata shape

This is the canonical selected reference/evidence requirement and exact amendment comparison.
Saved census facts below retain their original reference and claim limits. Changing design,
construction, qualification and delivery outcomes are kept in the separate
[unconsumed report](application-reference-input-partition.md#current-construction-and-evidence-report).

## What the saved corpus establishes

The historical macOS 26.6.2 (25G83) census contains 640 directory spellings:
290 under /System and 350 installed non-system spellings. The latter include
nested helpers and installation copies; location alone does not classify a
useful GUI app or an independent application identity. The saved census is neither
an exhaustive host population nor the actual supported VM baseline.
The [selected requirements](#selected-reference-and-evidence-requirements) name the
current macOS 27 installation as the template reference for the 1,010 generated
useful apps. Historical host templates, current-host templates, supported-VM
templates and a justified finite envelope answer different questions. Recovering
historical bytes alone would neither establish the selected current reference nor
establish representativeness. The saved audit's null selection fields describe its
historical projection boundary; they do not override the subsequent human choices.

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

## Evidence alternatives and historical recovery limits

Antony selected a new current-installation reference and one bounded packaging
pass under the [requirements below](#selected-reference-and-evidence-requirements).
The historical census remains a concrete available comparison corpus. Its System
and non-System payload gaps have distinct recovery candidates, but those historical
cohorts no longer supply the selected template bytes. Their recovery is not needed
or authorized by the current-reference choice. The actual supported-VM baseline
remains additive, distinct from both historical and current-host templates.

| Cohort | Missing evidence | Candidate recovery source and verification limit |
| --- | --- | --- |
| Historical System | 538 payloads/formats, all 247 complete loctables, full candidates and ambiguous flags | An existing archive or matching 25G83 system image is a candidate. The common saved file timestamp supports inspecting that candidate, but does not prove image availability or identical bytes. Every relative file/copy must match its saved SHA-256 before credited recovery. No historical image acquisition is authorized or required for the selected current reference. |
| Historical non-System | 1,508 payloads/formats, complete per-locale/information candidates and ambiguous flags | Existing archives or exact vendor/version artifacts are candidates, including nested helpers/copies. Matching app names or a newer vendor version is insufficient; each saved file digest and copy association must match. Availability remains unverified. |
| Selected current host, macOS 27.0.1 (26A434) | Complete current copy/file inventory, payloads/formats, typed candidates and independent classification | One bounded reference-packaging pass is authorized below and remains unexecuted. It produces new per-file/copy evidence, not equality with the historical capture. The actual supported VM still supplies its own full baseline and qualification. |

Reading repository packets is not acquisition. A bounded check of 27 existing
workspace zip/tar archives found one historical payload equality candidate:
Koine's 904-byte Contents/Info.plist, SHA-256
431300765533dd93c89b85d479c3127d92cfd9a8468048b7cf84cd3e2dde7157,
associated in the saved census with ordinal 76, /Applications/Koine.app. This is
no verified source-copy association or complete cohort replay. The check covered
docs and .build, excluding generated subject, mutation, compatibility and
node_modules trees; external backups, installed apps and OS images were not read.
Census, audit, Python executable and the listed archives had equal before/after
digests. The observation claims nothing about archives outside that bounded set.
No target payload or VM capture has been obtained in this requirements session;
sw_vers alone pins the current OS label/build. A build label, timestamp or archive
hash alone supplies no complete replay or independent useful classification.
The existing N5/N8/V11/V13 programme still owns actual supported-VM qualification.

| Approach | Formats/candidates and joint facts | Useful classification | Multiplicity/assignment and justification gap |
| --- | --- | --- | --- |
| Recover needed cohort bytes with per-file digest/copy verification | Restores actual formats, typed candidates, flags and joint tails for recovered files | Still requires a separately named independent classification source | At most 640 historical tuples cannot supply 1,010 distinct useful apps without a declared rewrite/assignment. Recovery alone selects no reference or rule. Preferred where needed matching bytes are available; availability is unknown. |
| Package the selected current installation completely | Supplies new original bytes, formats, typed candidates, flags and per-copy joint facts if the authorized pass succeeds; no historical digest equality is implied | Apple/vendor documentation and Antony-confirmed app purposes, frozen in an independent per-copy role manifest | Selected route. Whole-template repetition is declared below; exact assignment, resulting rewrites and useful shape remain to be designed and reviewed. Permission alone supplies none of those artifacts. |
| Repeat/resample projected rows | Retains only the saved projection; cannot restore unsaved facts | Same independent classification obligation; reader flags/location are partial inputs | Repetition is shared with other routes, not this route's unique defect. Unstated facts and independently sampled marginals fail the current contract. |
| Declare a per-copy joint envelope preserving every saved dimension | Declares only unsaved format/value/flag/candidate choices, with each original association retained | Same independent classification obligation | Requires an explicit 1,010-app assignment and proof that declared choices are a suitable finite envelope. No argument currently shows domination of opaque native parse cost or usefulness across those choices. A synthetic pass qualifies only that declared shape. |
| Declare a global maximum-size/keys/languages envelope | Artificial correlated stress, with no established per-copy association mapping | Same independent classification obligation | Per-file caps do not bound the correlated job. Maxima alone cannot establish the useful finite subject or replace the joint evidence. |

The requirements below select the current-reference route, classification source
and assignment policy. They establish no complete package, per-copy role
classification, assignment or qualification recipe. No probability, confidence,
representativeness or universal 1,024-app-machine claim follows. A subsequent
design must freeze the explicit finite joint shape and reproduction mapping;
missing evidence cannot become a language subset, smaller population, helper
deletion, weaker gate or new amount/posture. The failure here remains a known
subject-design gap, not actual native gross/attempt exhaustion. Valid exhaustion
later goes once to the existing human coverage decision; it is not a route around
this missing prerequisite.

## Selected reference and evidence requirements

The finite stress reference is the current installation, macOS 27.0.1 (26A434),
with both System and installed non-System template cohorts. Its purpose is to
exercise that installation's actual joint metadata shapes in a declared finite
constructed workload. It is neither a statistical population model nor the
supported VM's baseline. The historical 25G83 packets remain frozen comparison
evidence; their identities, file digests, 640-copy associations and 2,043 combined
episodes are not rewritten or relabelled as current evidence. Selecting this
reference changes no product support floor or acceptance gate.

### One bounded reference-packaging pass

The [evidence contract](application-reference-evidence.md#one-pass-acquisition-and-closure)
and [complete record model](application-reference-evidence.md#evidence-records-and-association-keys)
make this permission reproducible. Its [pure control matrix](application-reference-evidence.md#independent-controls-required-before-target-acquisition)
must be built and observed before the authorized target query/contents pass. No contract
check consumes permission or establishes a package.

Antony authorized one byte-complete pass for the subsequent complete subject-design
producer. Verify the exact installed build before using the authorization. The
reference source is the fixed indexed application-bundle path query
`kMDItemContentTypeTree == 'com.apple.application-bundle'`; retain its complete raw
returned slots and explicit out-of-scope/refused observations. Contents are limited
to checked .app directories under /System, /Applications and /Library whose
resolved roots remain within those same locations. Retain root spellings,
identities and alias/copy associations separately. These are evidence-instrument
permissions, not a change to Koine's production source or reader policy.
The [authority and protected-contact choices](#authority-and-admission-choices)
additionally bind this pass; prefix membership alone does not authorize contents.

For the fixed Contents, Support Files, Resources and flat layouts, retain the
layout observations and the complete selected information/resource bases. Package
Info-macos.plist and Info.plist, and InfoPlist-macos.strings, InfoPlist.strings,
InfoPlist-macos.loctable and InfoPlist.loctable globally and in every direct locale
directory. Preserve original bytes and serialization, exact per-file digests,
complete typed contents and present/absent/empty/non-string/malformed distinctions,
both name candidates and rejected values, all raw direct entries/component bytes,
all table keys/dictionaries/types/LocProvenance and joint tail associations.
Unparsed/refused values retain their original evidence and explicit limits;
inventing a typed tree is not recovery. No language subset is selected.

Freeze the exact current inventory, source/build, instrument/tool inputs and
per-file/copy associations before and after the pass. Record output payload and
manifest digests and exact replay/association limits. Missing, refused, changed or
unavailable copies/files remain explicit; a failed or incomplete pass is no
complete package and permits no silent repeat. Stop at that boundary rather than
substituting newer bytes, a historical row or a padded projection. No installed
payload is packaged in this requirements session. No executable acquisition,
arbitrary recursive contents, OS-image download, app launch, registration/index
modification, new consent/signing/helper posture or native/VM acceptance capture
is authorized by this packaging choice. The legacy lossy capture/fixture task
cannot stand in for byte-complete packaging or overwrite the historical packets.

### Authority and admission choices

Antony delegated reference-evidence-authority-k270's choices with "you decide".
The following conservative selections use that delegation within the existing unused
one-pass permission. They are the selected requirements, not an initialized authority,
passing qualification or permission for another pass.

**One-time authority and lifecycle.** Select one explicit initialization of
`koine.reference-evidence.macos-27.0.1-26A434.1` at
`/Users/antony/Library/Application Support/KoineReferenceEvidence/permissions/koine.reference-evidence.macos-27.0.1-26A434.1`.
This is the independent evidence tool's namespace, outside Koine product, checkout and
export lifecycles. A separately owned, reviewed and qualified provisioning operation
must bind the actual UID and held subject/ancestor identities and independently validate
the resulting receipt. This interview creates none of them. Packaging never initializes
authority from its absence. After the explicit initialization, absent, moved, replaced,
unreadable or uncertain authority refuses without scan/reset/recreation. Authority must
be consumed before target contact; ordinary attempt/export deletion or movement, cleanup
and lock release never replenish it. Recovery or a further attempt requires new explicit
human authority. Accept cooperative local enforcement: deliberate whole-authority forgery
or undetectable rollback by the user/admin is outside its protection. No secure monotonic
or cross-machine store is selected.

**Independent approval and corrections.** Antony retains authority over scope, privilege
and new attempts. Within these requirements, the existing independent whole-design
review and earned integration are delegated approval of concrete admission-anchor
revisions. Separately owned qualified provisioning and independent validation must bind
the actual accepted required inventory, expected profile, all canonical/ADR/contract
normative extracts, concordance and verifier/launcher identities to an approval record
outside regenerated proofs and the restorable checkout. The producer cannot approve its
own weakened required set or substituted verifier. Corrections require independent
review/integration and affected requalification before contact, with an exact live owner;
they cannot refund or reinitialize consumed authority. Broader scope, new privilege or a
new attempt still needs an explicit human decision. The replacement design owns the
concrete independently anchored approval mechanism; a review sentence or regenerated
matching hashes alone cannot satisfy admission.

**Human-owned acceptance and foreground lifetime.** Antony selected the explicit
human-owned ceremony. He makes the independent trust decisions over the ready exact
reviewed/final payloads, original review findings and dispositions, and original
verification results, accepting or refusing each before its first consumer. Compatible
acceptance, audit and release responsibilities may share his ownership and be batched
when their required inputs already exist. This relaxes the earlier mutually separate
owner proposal for those compatible human responsibilities; producer/repairer exclusions,
independently authored original controls and required inspection-only review/earned
integration remain. The qualification runner and acquisition child do not acquire the
independent trust role. Retain a distinct instrument original-obligation closing owner
and step after final affected qualification, independent acceptance and audit. Earlier
acceptance still occurs after its actual inputs exist and before their first consumer; this is no blanket
approval of future objects.

At the one acquisition boundary Antony explicitly starts the retained supervisor and
its appointed acquisition child together in one foreground invocation and retains that
invocation through true terminal return. The supervisor and child coexist there; no
supervisor lifetime across sequential Grove sessions is selected. Starting an image,
possessing a receipt/proof/eligible-release record or naming a task cannot supply that
human appointment. The complete reviewed design must state the exact compatibility and
exclusion relation, the bounded sequential acceptance/close/release schedule, and the
fresh invocation/channel binding. Cooperative same-UID enforcement and its tamper limit
remain selected. This requirements decision appoints no process, initializes no authority,
qualifies no instrument and spends no pass.

**Reviewed computation and five checkpoints.** Antony selected "Use the smaller
reviewed workflow (Recommended)" in k313; k314 applies that received answer. A separately
authored and reviewed comparison/display tool computes exact byte/member equality,
the complete required-result audit and the eligible basis. It retains original results
and gives a bounded readable summary with explicit refusal reasons. Antony makes the
semantic accept/refuse judgment and explicitly confirms the displayed short manifest
binding. That confirmation names the exact ready objects checked by the tool; the short
binding does not replace full-byte/member comparison or authorize future objects.

Before first use, the replacement design must specify the tool's independent bootstrap
trust, including a short inspectable entry. The candidate cannot certify itself or its
own comparison/control acceptance. Every human ceremony runs in Antony's own terminal
outside agent harnesses; agents never drive it through a pty. This is a cooperative
workflow rule. Inherited fd/foreground-group facts do not authenticate a human origin.

The clean path has these five baseline human checkpoints:

| Checkpoint | Required ready input and human act |
| --- | --- |
| Bootstrap/artifact acceptance | Accept the independently established bootstrap trust and actual reviewed/final artifacts and original findings/dispositions before their first consumer. |
| Qualified receipt acceptance | Accept the original qualified provisioning and separate actual receipt-validation results and their exact ready receipt binding. |
| Final original Q results/audit | Accept the final affected qualification originals and complete required-result audit after those results exist. |
| Eligible basis after distinct instrument close | Accept the eligible basis only after final qualification/acceptance/audit and the distinct instrument original-obligation closing owner and step. |
| Acquisition-boundary exact-entry acceptance/fresh appointment | Accept the exact fresh invocation entries and explicitly appoint/start the coexisting foreground supervisor/checker/acquirer at k245's boundary, through true return. |

K315 must fit the clean first-consumer dependencies into these five checkpoints by
batching compatible ready objects and must give each checkpoint a named human step,
including k245's currently AFK acquisition boundary. Earlier required acceptance remains
after its inputs exist and before its own first consumer. Repeat only the affected
correction suffix. If an exact original duty cannot fit, identify that conflict and
the bounded trade-off; do not silently add ceremonies, approve future records or claim
a realizable five-step path. Producer/repairer/runner/acquirer exclusions, independently
authored originals and the distinct closing owner/step remain binding.

**Documentary proportionality.** Replace k291 F6's per-fragment enumeration with a
reviewed complete list of historical/reporting exceptions and an explicit enduring-rule
default for everything else. Each exception identifies its whole object or exact section
in original context, its historical/reporting meaning and any original R retained duty.
Retain those enduring duties in the consumed rule set; neither an exception nor the
default can hide a superseded command or make a defective proposal accepted input.

Move changing observations out of normative S/C into the separate unconsumed report.
An unconsumed reporting edit alone requires no regeneration of the whole-source
composite or individual-fragment apparatus. Preserve complete actual consumed-byte
binding, original-source/basis/actual-read membership, phase/absence duties and original
R retained obligations. Whole companions/tables/bases and actual task/runtime/charter
reads remain bound to their complete bytes. A reporting label cannot exempt an object
actually consumed; actual consumed changes still disarm and require affected
requalification. Missing required originals retain null actual identities and exact work
before their consumers. K315 must deliver and earn whole review of the complete repaired
representation; this amendment supplies no replacement inventory, qualified tool or
accepted current input.

**Independent build, process-image and terminal correspondence.** Permit the following
bounded read-only arrangement for independently authored and accepted correspondence
evidence. Antony manually opens the local OS About display and records its product/build
values, host, session, time and his own observation. Compare those originals with the
already permitted fresh `kern.osproductversion`/`kern.osversion` buffers and qualified
SDK/API/compatibility configuration. This is an explicit exception for that human UI
observation to the evidence permission's no-launch rule. It admits no scripted UI,
`sw_vers`, plist, subprocess or alternative-sysctl fallback, app inventory, network or
installation operation.

A separately authored unprivileged observer may inspect only the finite same-UID
commissioned foreground supervisor/checker and declared retained Task/interpreter/
verifier/CLI/control peers: `proc_pidinfo(PROC_PIDTBSDINFO)`, `proc_pidpath`, read-only
`csops` `CS_OPS_STATUS`/`CS_OPS_CDHASH`/`CS_OPS_PIDOFFSET`, and
`proc_pidinfo(PROC_PIDREGIONPATHINFO)` at each explicitly declared image address.
Preserve original returned bytes, lengths, results and errors, actual process incarnation,
SDK/API/image/configuration and independently calculated retained Mach-O slice/signature/
UUID and held backing comparisons. The already selected fixed `/usr/bin/mdfind` source
child may receive the same bounded metadata observations only within A after consumption;
this permission adds no source invocation or pre-intent sample. Missing required source-child
correspondence prevents complete A evidence rather than requiring earlier target success.
Retained-source artifact/argv/input checks remain P prerequisites.
Reported executable/backing paths grant no additional lookup or contents access; comparisons
use the separately approved retained runtime/tool object plan and held identities. This
metadata permission adds no executable-content acquisition from application targets.

For only the direct ceremony's already inherited operator fd and foreground group,
`fstat`, `isatty`, `tcgetpgrp` and `getpgrp` may obtain terminal identity/type/group
facts alongside original process/session/channel provenance. No tty scan, extra tty open,
injection, saved/automated answer or hostile-user authentication claim is admitted.
The peer route grants no unrelated PID/daemon/application-target observation, all-system
process/mapping inventory, task-memory bytes, debugger/root/helper/signing/SIP/entitlement
change or fallback privilege. It changes no target root, cohort, layout, file, protected
lookup, prohibited effect, consumption rule or attempt count.

Shared OS mechanisms, cooperative same-UID enforcement, exec/PID/address/replacement
races and short/error/refused observations limit the evidence. A code-directory hash is
not a whole-file digest or every library identity; region/backing metadata is not immutable
memory. Availability or sufficient signatures/cache/backing metadata is not promised.
Independently qualify each named route and original expectation before Q06–Q08 credit
and fresh P01–P03 use; unknown, stale, mismatched or unavailable required facts still block
their stage. No required fact becomes an accepted contact unknown. This authority clause
supplies no observation, commissioning, provisioning, instrument close or eligible release.
Existing controlled-input/offline/admission/retained-task-domain/unprivileged-scratch and
GraphQL/binary/supported-VM seams, R7–R10 and every product/private/native duty remain.

**Persistence assumption.** Accept the bounded assumption that the reviewed local
filesystem/device honors the selected full-synchronization and namespace-ordering
operations once all required acknowledgements succeed. Apple's archived
[fsync manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fsync.2.html)
describes the OS-crash/power-loss gap of fsync alone; its
[fcntl manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fcntl.2.html)
describes the F_FULLFSYNC device-cache flush request and hardware limits. These sources
name the basis for this assumption, not current APFS directory/namespace crash evidence.
K273 must name and justify every actual file/namespace operation, filesystem assumption
and required acknowledgement before construction. Unsupported or unknown required
semantics and failed acknowledgements keep admission unavailable. Scratch controls cover
observable acknowledgements, ordering and process-death retention only. Accept unobserved
storage/hardware failure as an explicit limit; no unconditional at-most-one-across-power-
loss guarantee, secure store or native/VM crash experiment is selected.

**Observer privilege and bounded contact evidence.** Retain unprivileged pure qualification
at the user's UID. No root/sudo collector is authorized and no privileged supplier is
appointed. Antony accepted k281's stated bounded contact limit: independently authored
byte/value/association expectations, source review, exact retained task/parser/domain
controls, actual unprivileged scratch-adapter tests and any actually available bounded
observations qualify only their named claims. Each claim must identify its evidence,
operation/object scope and missing coverage. Missing current-service, proxy, initial-right
and mapping correspondence remains explicitly unknown, not clean or inapplicable. These
checks supply no complete C1–C8 observation/prevention or full no-contact certificate.

Accept the residual risk that native/framework/startup code, inherited capabilities or
detached proxies could accidentally inspect forbidden resources without detection.
Accepting that risk grants no permission for forbidden contact. Complete independent
contact coverage is no longer a blanket prerequisite for instrument closure or target
admission; all other required controls, actual identities and authority checks remain
binding. K282 must define and reconcile the exact bounded claims and admission blockers,
with mandatory whole-design review and earned integration before k269 constructs or
qualifies them. Failed required controls and known instrument defects cannot become
accepted unknowns. No test may select LIVE or use the target pass as calibration. A stronger
arrangement needs its concrete separate human decision; this choice grants no unspecified
administrator, SIP, helper, entitlement, signing, consent or VM change.

**Protected lookup, contents and intermediate contact.** Antony accepted k281's closed
pre-lookup rule. Check raw component bytes before any lookup; admit only exact paths or
component classes in an independently reviewed allowlist fixed before the pass. The
three literal and walk-resolved target prefixes remain necessary, including during link
expansion, subject only to the checked root-ancestor step below; prefix membership alone
grants no lookup or contents authority. Unlisted
paths and known or unsettled consent risk refuse as unavailable before lookup/open,
not merely before listing or contents handles. No prompt is answered to complete evidence.
No blanket Data-volume exclusion is selected.

| Target spelling or operation | Selected pre-lookup expectation |
| --- | --- |
| Ordinary application candidates under /System, /Applications or /Library | May pass only with their own independently reviewed exact path/component-class entries and all held-root/layout checks; a whole-prefix wildcard is insufficient |
| /System/Volumes/Data/Applications or /System/Volumes/Data/Library candidates, directly or through an observed link | May pass with their own reviewed entries; preserve both spellings and checked identity, with no sealed-volume or hidden-ancestry claim |
| /private or /Users target paths | Refuse target scope before lookup; preserve the raw rejected slot |
| /System/Volumes/Data/private or any /System/Volumes/Data/Users home | Syntax can pass /System, but refuse risk before lookup, directly or through observed link expansion |
| Desktop, Documents, Downloads, Containers, Group Containers, Mail, Messages or Mobile Documents target components | Refuse before lookup, through every direct or observed-link spelling; a component renamed or redirected invisibly is not proved absent by this rule |
| Relative or absolute link expansion outside the three prefixes and back inside | Preserve observed link text and physical component order; refuse before the first outside lookup/open except for the narrow checked Safari root step below, without lexical simplification that erases the step |
| Common ancestors used to enter an admitted target prefix | Only independently reviewed held search-only ancestor/operation entries may be used; no listing or arbitrary sibling access |
| Fixed authority namespace and separately reviewed fresh export ancestry | Distinct exact ancestor/operation entries are required; no target access follows, no authority-path substitution is allowed, and protected/unsettled ancestry refuses before lookup |
| Unlisted path/class, unresolved risk or unknown expansion | Refuse as unavailable before the corresponding lookup/open; retain raw occurrences and precise unperformed work |

An observed link may be read at its already admitted parent under the exact reviewed
operation entry; classify its expansion before taking the next component operation.
The authority/export ancestor exception does not admit application evidence in a user
home. Root/common-ancestor operations retain the ADR's held search-only semantics.
K282 must enumerate the exact admitted classes and common-ancestor operations, their
independently authored expectations and refusal points before construction; neither
this rule nor a synthetic positive supplies current installed-path qualification.

**Narrow Safari root step.** Antony answered "Allow the narrow shortcut step
(Recommended)" in k318; k319 applies that received answer. This is the sole exception
to continuous prefix membership during link expansion, only at the Safari app-position
link entry `/Applications/Safari.app` and cryptex-component link entry
`/System/Cryptexes/App`. At either position, a separately reviewed search-only physical
`..` operation may reach the root only when its held result is identity-equal to the
already held A1 root. The next component operation must immediately enter an independently
reviewed admitted-prefix production. No listing, browsing, arbitrary sibling access or
other outside component is admitted. A wrong held-root identity, wrong link position,
non-immediate re-entry or other outside step refuses before the next lookup/open.
All protected, unlisted and known/unsettled-risk refusals remain binding.

The separate historical syntax bases are k94's macOS 26.6.2 app-position link text
`../System/Cryptexes/App/System/Applications/Safari.app` and k110's same-build-family
cryptex-component link text `../../System/Volumes/Preboot/Cryptexes/App`. Preserve their
physical component order: lexical cancellation or the final spelling supplies neither
permission nor physical identity. These records establish no current 26A434 link text,
presence, identity, topology or consent fact. No arbitrary ancestor-link exception follows.
K320 must reconcile the separate link/A1 entries and independently authored positive and
refusal specimens with the full companions/views, then earn mandatory whole review and
every integration before k269. This requirements answer qualifies no instrument, appoints
no process, initializes no authority and authorizes no additional pass. Every other
earlier selected clause, original Goal/Done when duty, k246/k247 obligation, useful breadth
and product/private/native hold remains; k245 retains exactly one authorized pass under
its existing admission and consumption requirements.

A lexical predicate cannot prove hidden physical ancestry or current TCC behavior.
Hidden redirects, opaque mounted-root contact, unobserved replacement and proxy effects
retain the accepted bounded-contact risk; no physical-ancestry or prompt-free certificate
follows. The macOS 26.5 search-only measurement is no macOS 27.0.1 certificate. No installed,
protected or topology probe is authorized by this interview. These clauses amend the
evidence permission, not the production filesystem ADR.

**Disposition of refused required evidence.** Antony accepted a truthful failed/incomplete
package and subject-design boundary when this rule refuses a required copy. Preserve each
raw slot and exact missing bytes/associations, and carry that boundary through k245/k246/
k247 and mandatory whole review. It cannot count as a complete finite subject, accepted
useful-category loss or private eligibility; required unavailable copies remain explicit
missing evidence. Do not omit them, repeat the pass or trim breadth to manufacture success.
A later need to change scope returns as one concrete human decision before its consumer,
rather than another identical unavailable survey. No complete subject is promised by
choosing the rule.

**Agreed seams.** Antony accepted controlled source/filesystem/byte-decoder inputs,
independent offline/admission verification, exact retained task/parser/domain controls
and actual unprivileged scratch adapters under the bounded contact-evidence rule above.
Independently authored expectations and any actually available bounded observations must
support each named claim; none supplies complete contact observation/containment. Existing
public GraphQL, actual provider/host binary and isolated signed supported-VM product seams
remain. No installed-target positive, authority provisioning, collector probe or native
capture occurs in this requirements leaf. Both product holds,
private ineligibility and every native PENDING outcome remain.

### Independent classification and whole-template assignment

Freeze a separate per-copy role manifest based on named Apple/vendor documentation
and Antony-confirmed knowledge of application purpose, associated with the exact
copy/version. Confirmed GUI copies supply useful templates; documented helpers
supply helper templates. Uncertain copies retain declared stress roles and cannot
count as confirmed useful apps. The reader's flags, paths and outputs are not the
independent classification source. No universal user-facing-app predicate follows.
The resulting signed GUI test apps still need independent useful type/identity/
metadata and behavior witnesses through the existing acceptance seams.

Use deterministic whole-template repetition: first cover required joint shapes,
tails and branches within each role, then balance repetition to exactly 1,010
distinct useful test apps and 256 helpers. The design must freeze its exact
per-copy ordering, coverage and multiplicity, preserving every source association
and explaining any shape it cannot include. It must not silently omit a copy,
helper, branch, table, unselected key/language or tail to fit. An unresolved
coverage/capacity conflict is a precise subject-design gap, not permission to
trim the reference or count uncertain copies as useful.

Every generated copy needs a distinct identity and a complete source-to-generated
identifier/executable/signing rewrite manifest. Independently recalculate resulting
byte sizes, formats, typed candidates/flags/branches, locale components and digests;
an edited copy inherits neither its source digest nor its source identity. All 128
aliases have explicit target and joint recipe associations. Retain all fourteen
configured/system witnesses and the full actual supported-VM baseline and
registration pressure in the same native workload. Balanced repetition creates a
declared finite construction, not 1,010 independent real-app measurements. No
independent marginal sampling, means-only model or thin cardinality padding is
selected. Exact recipes and useful fit remain unestablished.

### Test seams and required handoff

Pure reference/recipe checks must compare independently frozen source evidence
with generated copies and distinguish permitted rewrites from joint-shape loss.
Observe controls fail for omitted tables/languages/keys/LocProvenance, unapproved
type/serialization changes, clipped or reassigned tails, lost copy/file/alias
associations and thin same-cardinality replacements. A declared permitted rewrite
must pass when its resulting dimensions and branches satisfy the contract; a
whole-row hash comparator is insufficient. Check complete inputs before/after
every measurement. These are construction/evidence controls, not a fourth public
product interface and not native usefulness evidence.

Actual qualification retains the agreed public GraphQL, actual provider/host
binary and isolated signed supported-macOS VM seams. Reuse existing N5/N8/V11/V13
and their independent source, listener, grant-store, action, dialog and hydration
obligations after the complete canonical prerequisite chain. This requirements
handoff creates no duplicate native capture or implementation programme.

On success, unavailable evidence or a failed packaging/design boundary, the next
work remains a complete independent subject-design producer with mandatory whole
producer review and every earned integration before private construction and
app-and-file-search. Its artifact must reconcile the current contract, acceptance,
source/subject/family, eligibility, consumer charters and editable/rendered views.
Permission, an archive hash, cardinality, a policy or a projection cannot satisfy
the missing finite-subject predicate. Private eligibility remains false, both
advertisement and ordinary-consumption holds remain, and all native G/N/V verdicts
stay PENDING. All file/count/quota/scoped gross/attempt/wire/deadline/true-return,
Settings/location/core/action/authority/disclosure/source-and-image/compatibility
obligations remain selected. Actual valid useful exhaustion goes once to the
existing bounded coverage decision; a known design defect is repaired/reviewed
first. No amount, accounting, ABI, posture or useful-category change follows.

## Reference-evidence decision comparison and reporting

The selected clauses above and exact comparison below record only the actual k270/k281/
k290/k295/k314/k319 amendments. Changing design/construction/qualification/pass observations
live in the [unconsumed report](application-reference-input-partition.md#current-construction-and-evidence-report).
The k314 before state is 47875236: its two selected clauses were inserted before Independent
build, process-image and terminal correspondence; all earlier selected clause bytes were
retained. The practical design changes no selected clause, permission or accepted limit.
The k319 before state is k318's retirement commit cafb8e88: only the protected
prefix-continuity sentence and out-and-back table expectation are amended, and the
**Narrow Safari root step** clause is added. All other earlier selected clause bytes
are retained. K320 owns the complete design reconciliation under that actual answer.

### Status outside the measured permission

The exact relocated status sentences and all changing outcomes are
[reported separately](application-reference-input-partition.md#current-construction-and-evidence-report).
Old fragment/composite identities remain historical defective review subjects; they are
never replacement proof. The selected Documentary proportionality clause owns that change.

### Line-by-line original-obligation comparison

| Original clause or condition | Selected disposition |
| --- | --- |
| Observer privilege: "A realizable independent full contact observer/containment boundary remains required" and "Until it is independently qualified, admission remains unavailable" | Replaced by **Observer privilege and bounded contact evidence**: qualify only named evidenced claims, report current-service/proxy/initial-right/mapping coverage unknown, accept the stated accidental-contact risk, and retain all other controls and authority checks. No blanket full-coverage gate for k244 closure/k245 admission remains. |
| Agreed seams: "actual unprivileged scratch adapters with independently qualified complete contact observation/containment" | Replaced by the accepted controlled-input, independent offline/admission, exact task/parser/domain and actual scratch-adapter seams under the bounded contact rule. Any bounded observation supports only its named scope. |
| Protected clause: known/unsettled consent risk refuses "before contents handles/listing" | Strengthened to refusal **before lookup/open**. Independently reviewed exact path/component-class entries fixed before the pass are required in addition to the three literal/walk-resolved prefixes. |
| Protected clause: held search-only common ancestors may enter a permitted prefix; out-and-back expansion refuses before outside lookup/open | Retained except for the explicitly compared **Narrow Safari root step** below, restricted to reviewed ancestor/operation entries. Relative/absolute expansions and physical `..` cannot erase an outside step. Exact authority/export ancestry has separate entries and grants no target access. |
| K281 selected prefix sentence at cafb8e88: "three literal and walk-resolved prefixes remain necessary, including during link expansion, but prefix membership alone grants no lookup or contents authority"; selected out-and-back expectation: "Preserve observed link text and physical component order; refuse before the first outside lookup/open, without lexical simplification that erases the step"; k314 reserves any Safari outside-prefix exception for a separately specified need and human decision | K318's actual "Allow the narrow shortcut step (Recommended)" answer, applied by k319, amends only continuous prefix membership at `/Applications/Safari.app`'s app-position and `/System/Cryptexes/App`'s cryptex-component link entries. A reviewed search-only physical `..` must yield a held identity equal to the already held A1 root, immediately followed by an admitted-prefix production. No listing/browsing, sibling or other outside component; all other protected/unlisted/risk refusals and kernel order remain. The new prefix sentence retains target-prefix necessity subject only to that checked root step; the out-and-back expectation names only this exception, and the added selected clause supplies its exact conditions and separate historical syntax bases. No lexical cancellation, current native identity or general ancestor permission follows. K320 owns full grammar/A1/specimen/companion/view reconciliation and mandatory whole review/every integration before k269; no instrument, appointment, authority or additional pass is supplied. |
| Protected clause: no blanket Data-volume exclusion | Retained. Data/Applications and Data/Library candidates can pass only with their own reviewed entries. Data/private, Data/Users and the named protected/unsettled components refuse before lookup through direct/observed-link spellings. |
| Protected clause: hidden redirects/mounted-root/proxy effects retain a "full independent qualification obligation" | The universal coverage prerequisite is replaced by the accepted bounded-contact risk. Observable identities, link text, replacement/refusal controls and precise limits remain required; no hidden-ancestry or current prompt-free claim follows. |
| Required unavailable copies remain live missing evidence, never accepted useful loss | Retained with Antony's explicit disposition: carry a truthful failed/incomplete package and subject-design boundary through k245/k246/k247 and whole review. No copy omission, repeat, useful-category reduction, complete finite-subject credit or private eligibility follows. A later scope change needs a concrete decision. |
| Canonical control status: "Those controls are currently specified, not executed." | Moved verbatim to the reporting subsection above. The prerequisite to build and observe controls before the target pass remains in the selected section. |
| Canonical pass status: "The single pass is unused; both product holds," followed by "private ineligibility and every native PENDING outcome remain." | Antony approved moving only the pass observation to the separate unconsumed report as "The single pass is unused." The retained first line is "Both product holds," and the second line is byte-identical. The one-attempt permission/consumption rules, both holds and every private/native qualification duty remain binding. |
| K270 independent approval: whole-design review/earned integration selects concrete admission-anchor revisions; the producer cannot approve its own weakened required set or substituted verifier | Retained. Antony supplies the selected independent own trust/acceptance act over actual ready reviewed/final payloads, original findings/dispositions and verification results before their first consumer. Inspection-only review and earned integration remain prerequisites, not operator appointment or approval of future objects. |
| K282 mutually separate acceptance, audit and release ownership | Amended only for compatible independent human responsibilities: these may share Antony's ownership and be batched when their required inputs already exist. Producer/repairer exclusions, independently authored original controls, phase ordering and distinct instrument close remain; the repaired design must enumerate exact compatibility/exclusions rather than cut one session per role. |
| K282 independent release supervisor still live at k245 and separate acceptance-side commissioning supervisor | Replaced by the selected human-owned foreground lifetime: Antony explicitly performs the required trust acts and starts the retained supervisor plus appointed acquisition child together at the acquisition boundary through true return. No cross-session supervisor, task/image/receipt/proof-driven appointment or automated independent operator is selected. |
| K282 independent judgment, qualification-runner/acquirer separation, original-result acceptance before consumption, and distinct k244 original-obligation close | Retained. The human owns trust judgments; the qualification runner and acquisition child cannot appoint or approve themselves. Required earlier acceptance precedes its own first consumer. Instrument closure retains its distinct owner and step after final affected qualification/acceptance/audit; this requirements answer spends no pass and approves no future payload. |
| K290 decision 1: "Antony accepts the ready reviewed/final payloads and original results on the required independent judgment"; k312 R2 identifies undefined mechanical full-byte comparison, required-result audit and eligible-basis computation | Independent semantic judgment is retained. The separately authored/reviewed tool performs exact byte/member equality, the complete audit and basis computation with original results and readable refusal reasons. Antony accepts/refuses its bounded summary and explicitly confirms the short manifest binding in his own terminal outside agent harnesses. Independent bootstrap trust with a short inspectable entry precedes first use; candidate self-certification and an agent-driven pty ceremony are excluded. Terminal metadata is not human authentication. |
| Canonical Human-owned acceptance: "accepting or refusing each before its first consumer" and "be batched when their required inputs already exist" | Retained under five baseline checkpoints: bootstrap/artifacts; qualified receipt; final original Q results/audit; eligible basis after distinct close; acquisition-boundary exact entries/fresh appointment. K315 must place every clean first-consumer dependency and name each human step, including k245, by compatible ready-object batching. Corrections repeat only the affected suffix. An exact original-duty conflict requires its bounded trade-off, never a silently added ceremony or approval of future records. |
| K291 F6: "enumerate every individual enduring/historical/changing statement and subordinate clause across all selected extracts, whole companions/tables/bases and actual task/runtime reads" | Replaced by the reviewed complete historical/reporting exception list with exact whole-object/section context and an explicit enduring-rule default. This is the selected amendment to exhaustive individual-fragment classification, not a claim that old generic E labels discriminate or that the defective k291 representation is accepted. Original R retained duties remain in the consumed rule set. |
| K291 F6: "Refresh the complete TSV/report and bind exact byte ranges/digests; record H statements individually"; canonical reporting: "all affected current members/associations are reconstructed against the preserved extracts and historical originals" after a reporting edit | Replaced only for unconsumed reporting changes: move changing observations out of normative S/C; do not regenerate the per-fragment apparatus or whole-source composite solely for that report edit. The complete reviewed exception/default representation replaces those mechanics. Actual consumed sources/whole objects still bind complete current bytes and members, and their changes disarm and require affected requalification. Historical original identities remain historical. |
| K291 F6 and k282 R6: whole consumed-byte equality, independent original-source/basis/actual-read membership, phase/absence duties and original R retained obligations | Retained in full. No exception slices a whole companion/table/basis or actual task/runtime/charter read, no reporting label waives a consumed object, and no reference row/hash supplies missing original possession. Required missing originals/identities remain null with exact work before their consumers. Only the compared fragment classification and reporting-driven reconstruction mechanics change. |
| Evidence permission's no-launch rule and no independent installed-build display route | Amended only for Antony's manual local OS About product/build observation with original host/session/time provenance. Compare with the two already permitted fresh sysctl buffers and qualified configuration; scripted UI, sw_vers, plist, subprocess/alternative-sysctl fallback and every other launch/inventory/network/installation effect remain excluded. This changes observation authority, not the expected 27.0.1/26A434 bytes or actual current-build evidence. |
| Permitted O05–O07 mechanics lack an independently observed executing-peer/image route | Add only the separately authored unprivileged finite same-UID commissioned supervisor/checker and declared retained Task/interpreter/verifier/CLI/control metadata operations named in the selected clause. Retain original results/errors/lengths and independently checked incarnation/slice/signature/UUID/held-backing associations; no unrelated PID/daemon/target, all-system inventory, task-memory bytes or new privilege/posture. Spawn, child/loader self-report and pre-exec hashes remain insufficient by themselves. |
| O15's fixed source artifact/argv checks precede intent; actual spawned-source facts first occur in A | Retained. Approve the same bounded metadata route for the already selected fixed mdfind child only after consumption inside A. It adds no spawn, earlier source sample, LIVE calibration, extra attempt or success prerequisite. Missing required A image/source facts prevent complete evidence; source P checks remain. |
| Foreground appointment policy does not establish original terminal provenance | Add only fstat/isatty/tcgetpgrp/getpgrp for the ceremony's already inherited operator fd/foreground group with original process/session/channel records. No tty scan/open/injection, automated/saved answer or hostile-user authentication claim. K290/K292's actual human appointment, compatibility/exclusions, inherited-channel and true-return duties remain. |
| Q06–Q08/P01–P03 known native/build/image/terminal expectations, identities and required controls; R7–R10 and bounded-contact limits | Retained in full. New authority supplies no actual observation or qualification; missing/refused/stale required facts still block, and required A failures retain incomplete evidence. Shared-OS/cooperative/race/signature/cache/backing limitations grant no contact permission or waiver. Existing Q/P/A and E/M/U definitions, protected lookup, exact A3/disarm rules and agreed seams remain. |
| K244 Done when 1: lossless fixed-query framing/terminal failure, component scope/held roots, closed layouts/files/direct locales, immutable bytes and complete associations | Retained in full. The additional pre-lookup allowlist/refusals apply; contact evidence has the accepted bounded scope. |
| K244 Done when 2: complete typed decoder route, pinned identities, XML/binary/OpenStep/unsupported/malformed/type/serialization/duplicate limits and original six-basename evidence | Retained in full. No value/type/image proof is supplied by this decision. |
| K244 Done when 3: independently authored pure byte/type/inventory/association expectations, fault seams, applicable intended negatives/positives, helper/alias/race/scope/error/freeze/interruption/no retry, and k246 generated controls | Retained. Only the blanket independent complete-contact/no-contact sufficiency claim is amended: actual scratch/task/domain tests and available observations qualify named claims, with accepted missing coverage stated unknown. Failed required controls and known defects still block. Every input/tool freeze and k246 duty remains. |
| K244 Done when 4: verified reusable pure/packaging recipes, exact build/fixed scope/fresh output, interrupted evidence and no target acquisition during qualification | Retained in full. Tests cannot obtain LIVE authority; the one pass cannot calibrate wiring or native calls. |
| K244 Done when 5: exact schema/version, reproducible actual proofs and editable/rendered views, distinct verified instrument versus payload/role/subject/native claims, unused pass for k245 | Retained with bounded contact claims explicitly labelled. No requirements/design closure substitutes for actual qualification or stable proof. |
| K242 Done when 1: verify the byte-complete instrument before the single exact-build/cohort/layout/file pass; preserve complete raw/typed/LocProvenance/tail/digest/copy/version/alias evidence and explicit failures/limits | Retained in full under the amended contact/lookup requirements. A refused required copy has the explicit incomplete disposition above; no complete package is invented. |
| K242 Done when 2: independent exact-copy Apple/vendor/human role manifest; uncertain copies are stress inputs, not confirmed useful apps | Retained in full. No classification predicate or copy purpose is selected by this interview. |
| K242 Done when 3: whole-template coverage/balanced repetition for 1,010 useful apps, fourteen witnesses, 256 helpers, 128 aliases and additive full actual VM baseline/registration pressure; exact rewrites and independently recalculated facts | Retained in full. No amount, shape, useful breadth, rewrite or baseline substitution follows. |
| K242 Done when 4: independent thin/omission/type/serialization/tail/association negatives and permitted-rewrite positive, including helpers/aliases and complete freezes | Retained in full; these generated controls remain k246's separate obligation. |
| K242 Done when 5: whole family/spec/acceptance/eligibility/charter/view reconciliation, all nine tapes/real publication and resource/authority/action/compatibility duties | Retained in full. The accepted contact risk changes no product/native qualification gate. |
| K242 closing condition: complete coherent subject-design boundary and mandatory whole-producer review/integration before private construction/k7, including exact unavailable/failed work | Retained in full. An incomplete package permits only the truthful failed/unavailable design handoff, never finite-subject credit or closure of missing native obligations. |
| K244/admission C1–C8/U1–U6 blanket prerequisites: complete current universe, mechanism, initial capabilities and proxy/map coverage before any adapter/entry/read credit, node close or k245 admission | Superseded only as universal no-contact prerequisites. Preserve the documentary inventory and each missing class as an explicit limit; k282 must map the accepted bounded claims, their actual required proofs and exact remaining blockers throughout the contract/companions/profile/controls/views. Unrelated UID/build/receipt/image/entry/decoder/freeze/refusal proofs cannot be waived as unknown. |
| Exact target permission, one attempt, authority lifecycle/independent approval, no new consent/privilege/posture, useful breadth, product holds/private ineligibility and native pending obligations | Retained under only the explicitly compared amendments. K314 changes acceptance computation/checkpoints and documentary mechanics, without adding target or observation authority. K319 changes only the two checked search-only Safari root transitions above. Neither this answer nor future scratch controls initialize live authority, select LIVE, authorize an application-target/protected/topology probe beyond the selected evidence scope, consume another pass or qualify a product/native outcome. Reported peer paths add no target lookup/contents or executable acquisition. |

The original k244/k242 Done when texts remain as the historical obligation inventory;
the explicitly identified k281 contact/pre-lookup, k290 operator/owner/status, k295
bounded correspondence-authority, k314 acceptance/documentary and k319 narrow root-step
amendments above control
their interpretation. K314 changes k291 F6's per-fragment enumeration and reporting-driven
composite reconstruction only as compared; every other original obligation remains.
K320 owns the complete contract/companion/operation-map/representation reconciliation,
and its mandatory whole review/every earned integration must precede k269 consumption.

## Required reproduction contract after the decision

Use the selected [complete evidence contract](application-reference-evidence.md), its
[historical/reporting exceptions and E default](application-reference-evidence.md#historical-and-reporting-exceptions),
both whole-byte companions and all five whole tables. Complete actual consumed-byte,
original/basis/read/phase/absence and original R retained duties remain. Actual acquired
objects need their complete members; missing originals keep null actual identities.
The [practical report](application-reference-input-partition.md#practical-original-obligation-comparison)
locates the whole original-obligation comparison and exact missing work before consumers.

## Reproducible boundary checks

The saved projection audit is checked by `task design:application-population-metadata-shape-check`.
Its scope is packet integrity and the enumerated projection losses: row/association edits
must fail, including a permitted identifier rewrite that the later generated-subject shape
contract might accept. These checks cannot recover missing original bytes or typed trees,
qualify a current reference population, or replace k246's independent rewrite-aware useful/
helper/alias discriminator. The detailed [saved check report](application-reference-input-partition.md#reproducible-boundary-checks)
records its historical controls and evidence limits; old fragment/composite regeneration
instructions there are not a current handoff. The Taskfile recipe remains current.

Document/link/render checks validate only the saved design. Exact replacement documentary
identity and historical-parent/Safari comparisons are reported with their bounded scope
[separately](application-reference-input-partition.md#practical-documentary-verification).
No check supplies authority, instrument/control qualification, current target bytes or
private/product/native eligibility. Actual consumed changes still disarm/requalify.
