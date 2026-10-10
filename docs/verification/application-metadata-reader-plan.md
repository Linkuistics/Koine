# Application metadata reader construction

[Reader → Select independent inventories and stop refused fallback](../design/architecture/index.html#diagram-native-metadata-reader-plan)
shows this semantic construction. Graphs start at the dark **Start here** node;
numbered edges show work order. The plan consumes Antony's recorded
[format, gross budget and refusal selections](application-metadata-subject.md#human-selection-and-final-design-handoff).
It is a pure-observation design, with an executable policy model; it performs no
native discovery, file parsing, selector call, launch or consent operation.

**Construction boundary.** The file/layout, inventory, precedence and refusal
semantics below are selected. The complete owned-storage, gross, call and wire
certificate is still work under application-metadata-certificate-k220; whole-family
reconciliation is application-metadata-reconciliation-k221. The proposal's
numerical totals remain estimates. The existing k215 consumption hold and its
mandatory whole-producer review before k7 remain binding. Every native
G1–G11/N1–N8/V1–V13 verdict stays **pending**. This document does not lift the
hold or replace the old certificate with a claimed fit.
The [operation ledger](application-metadata-operation-ledger.md) now defines the
concrete branch/ownership protocol; applying it to every saved episode and the
source/storage/wire envelope remains k220's following design child's work.

## Root and layout admission

Retain the ordinary root admission in the [native contract](../specs/workspace-search.md#localized-reader-decision):
checked directory identity and positive native root application type; only that
root receives a whole target pathname, through 1,023 UTF-8 bytes. Larger roots
use actual indexed tuples and INDEXED_ITEM, with UNKNOWN installation state and
null flags. No metadata descendant uses a whole path, foreign Bundle or recursive
resource scan. Action pathname limits and image/authority boundaries are independent.

Resolve the first root once and hold its directory descriptor. Probe only the
following literal layouts, in this order. Flat root is the already checked root,
not another pathname resolution.

| First present checked layout | Information base | Resource base |
| --- | --- | --- |
| Contents | Contents | Contents/Resources |
| Support Files | Support Files | Support Files/Resources |
| Resources | Resources | Resources |
| Flat | Root | Root |

Only checked ENOENT absence permits the next layout. A wrong type, link,
permission error, dataless observation, unsupported check or changed identity
refuses the layout-dependent metadata. A present layout does not fall through
because its information or resources are missing. Information and resource bases
are independently checked below that layout; resource-base absence permits a
healthy empty resource plan and information-name fallback. Resource-base refusal
leaves the name unknown while healthy information identifier/flags can survive.
No alternative layout supplies convenient replacement facts.

Every submitted variable component is literal, lossless UTF-8, slash/NUL-free,
neither dot nor dot-dot, and within the held parent's actual positive
fpathconf(_PC_NAME_MAX). The terminator is separately reserved; NAME_MAX excludes
it. Fixed components also undergo this parent check. Indeterminate/refused limits
withhold affected metadata. Locale keys have the existing 1…1,024-byte lossless
key bound; a direct key must additionally fit its complete `.lproj` component.
The root's length is no bound on a reconstructed descendant: none is submitted.

## Fixed files and exact priority

Information probes are **Info-macos.plist, then Info.plist**, in the selected
information base. Only checked file absence advances. The first present healthy
dictionary is authoritative, including an empty dictionary or missing fact keys.
It cannot borrow missing values from plain information. An individually refused
information file affects identifier, declarations, development region and its
plain-name fallback; independent healthy name resources can still yield a name.

Name search is **base-first**. Visit the global resource base, then the direct
directory plan below. At each base visit these families in order:

1. InfoPlist-macos.strings
2. InfoPlist.strings
3. InfoPlist-macos.loctable
4. InfoPlist.loctable

Each loctable performs its own key selection at that exact position. A usable
global table therefore precedes a later directory's strings. Family-first across
all bases was rejected because it changes the existing first-usable-base policy.
This is an explicit target-local contract; it claims no private Bundle equivalence.
A required native useful witness can refute it and stays unmet until repaired.

Within an ordinary name dictionary or selected table-language dictionary,
CFBundleDisplayName precedes CFBundleName. Missing keys or a healthy empty string
allow the next name key; if both are absent/empty, advance to the next dictionary,
family or base. The first usable name wins. A later display name cannot override
an earlier usable bundle name. Any present wrong-type, invalid-UTF-8/NUL or
over-bound name key refuses the affected name; it cannot be bypassed through the
other key or a later candidate. Only after every preceding candidate is checked
absent or healthy without a name may the information dictionary supply display/name.
Information refusal also refuses that final fallback. Never use a filename,
another copy, running label or unlocalized information to conceal a preceding
name-resource refusal.

## Independent localization inventories

Snapshot explicit Locale.preferredLanguages once per job. Validate each raw
preference as a lossless nonempty, NUL-free string within the existing 1,024-byte
key bound, charging every raw slot/copy to the shared job ledger. An empty but
healthy preference array is explicit; never pass null preferences or consult a
main/foreign Bundle. The old 32-record/4,096-payload preference dimensions are
finite certificate assumptions, not new production language quotas.

Enumerate one selected resource directory's direct raw slots, including duplicate,
nonlocalization and rejected entries. Non-`.lproj` entries are not opened. For a
literal `.lproj` name, validate the component and check/open/recheck its directory
without following links. Preserve the suffix-stripped key and exact component.
A refused or vanished candidate makes that direct inventory incomplete and the
name unknown; it is not a healthy absent language. Duplicate exact keys or an
ambiguous returned mapping refuse the inventory. Do not normalize punctuation,
case, Unicode, region or language spelling, and do not use optional
CFBundleLocalizations as the inventory. No en/de/English-only product subset exists.

A loctable is a separately parsed bounded top-level dictionary. Count every raw
top-level key, including **LocProvenance**, against its 4,096-key object bound and
charge every inspected key/type/record. LocProvenance is reserved metadata, never
a language: observe its type, and when it is a dictionary check its direct count
against 4,096, but do not enumerate or recurse through its metadata contents.
Every other key must be an exact bounded string; every value must be a dictionary
with at most 4,096 keys, including unselected language dictionaries. Unsupported
top-level key/value shape or per-dictionary overflow refuses that table and the
name. No key is silently dropped to make a table look healthy. Table keys are CF
values, never filesystem components; they are never submitted as paths. Each
table owns its literal non-reserved inventory. A direct inventory cannot be
borrowed for a table, nor one table's inventory for another.

For **each** actual direct/table inventory independently:

1. Place the healthy information development region first only if it exactly
   names an observed key. Byte-sort the remaining literal keys. There is no
   directory/native enumeration-order winner.
2. If nonempty, call pure CFBundleCopyLocalizationsForPreferences with that exact
   possible array and the explicit job preferences. Empty inventory skips the
   selector and has an empty returned array.
3. Inspect/count every returned slot before projection. Require exact string
   membership in the supplied inventory; reject foreign or ambiguous keys without
   normalization. Retain every distinct returned key in returned order, rather
   than assuming one result. Charge duplicate slots before deduplication.
   A nil, wrong-type or unavailable selector result is refusal, not a healthy
   empty array and not permission for unlocalized fallback.
4. Append exactly observed Base, then exactly observed development region,
   deduplicating literal keys already planned. A development region absent from
   that particular inventory supplies no backstop there.

The selector's no-match positional behavior is deliberate: observed development
first, otherwise byte-first. Actual preference matches precede it. A directory
plan maps exact keys to the observed `.lproj` components; a table plan maps exact
keys to that table's borrowed dictionaries. Healthy empty dictionaries can
advance within either plan; refused selected dictionaries cannot.

The saved English FindMy selection returns **en_AU, en_GB, en**; its direct plan
also includes observed Base, while its table has no invented Base. The model
checks every saved English/German plan for all **2,043 episodes**, including each
alias's repeated episode. These are historical macOS 26.6.2 selector observations,
not current-macOS matching qualification or a restriction on user preferences.

## Input, facts and failure publication

Each selected fixed file must be an independently checked regular nonlink file,
not known dataless, of **0…131,072 declared bytes**. Reserve the input/read charge
before reading; zero declared bytes still need a healthy parse and will ordinarily
be malformed. Perform one exact-size pread and one EOF-byte pread, with no retry.
Short/extra input or changed size/time/name-to-inode checks refuses that file;
never parse a successful prefix. Parse immutable XML/binary/OpenStep property-list
bytes using CFPropertyListCreateWithData via no-copy CFData and a charged buffer.
Require a bounded dictionary before getters. No alternate parser or Bundle fallback.

Information supplies only identifier, display/name, development region, LSUIElement
and LSBackgroundOnly. Name resources supply only display/name. Missing identifier
stays null; malformed identifier withholds that fact with diagnostics. Identifier
is 1…512 lossless UTF-8 bytes, final label 1…1,024; a **129-byte** label is valid,
never narrowed to the old finite 128-byte reserve. Exact typed optional flags
stay null when absent/invalid, never false. An invalid development region is
withheld and supplies no positional/backstop authority. Other individually healthy
facts survive; no cross-copy/index-to-current-plist upgrade follows.

| Outcome | Affected metadata | Publication |
| --- | --- | --- |
| Checked absence / healthy no-name dictionary | Continue only by the explicit rules above | Admitted choice retained |
| Oversized information file | ID, flags, development and plain-name fallback unknown; independent localized name may survive | Choice/identity/location/diagnostic retained |
| Oversized or otherwise refused preceding name file | Name unknown; stop all later name fallback | Other healthy facts and choice retained |
| Per-object malformed/input/key/type refusal | Withhold affected facts; no rescue that bypasses refusal | Choice retained when root admission still holds |
| Shared source/plan/count, call, cumulative gross or deadline exhaustion | Invalidate complete application population | FAILED with null items, no prefix |
| Diagnostic detail saturation alone | Continue facts/choices with fixed source summaries | DIAGNOSTIC_LIMIT guidance; not result truncation |

The selected application gross gate is **20,971,520 cumulative bytes**, counting
every performed read/copy and no reuse refund; attempts remain **4,194,304**.
Shared metadata-plan slots include raw directory/preference/selector/table-key
inspection and rejected/duplicate slots. Before every actual work/projection the
owner checks shared count/call/copy/deadline admission. Per-object 4,096-key
overflow is distinct from shared count exhaustion. Complete definitions and all
performed terms must be derived in k220; neither this model nor the earlier
40/32C/8E/48F estimates is that certificate.

The core response cap remains 8 MiB, read/core deadlines three/five seconds, and
four shared slots persist until true return. Four application jobs can admit
80 MiB cumulative gross, with no process RSS/parser/native peak guarantee.
Settings/locations keep their gates. A legal null does not waive a known required
useful name, flag, source or identity: that acceptance case still fails.

## Lifetime and every exit

Before acquisition, reserve its cleanup attempts and owned charges. An exhausted
cleanup reservation refuses acquisition and invokes shared failure. Do not issue
new optional work after failure/deadline/lifecycle loss. Cleanup acts only on
already acquired resources, with capacity held until each native call actually
returns; caller cancellation cannot transfer/free an in-use buffer or descriptor.

| Acquisition / stage | Lifetime and exit obligation |
| --- | --- |
| First root resolution | Hold root fd through the metadata episode; release on every actual-return exit. Root absence/replacement refuses choice. |
| Layout/resource/locale descent | Each open is nofollow and held-fstat checked. Close acquired temporary/intermediate fds on absence, refusal and success; no alternate descent after refusal. |
| Resource listing | Retain resource fd for component reads. dup a separate listing fd before fdopendir; success transfers that fd to DIR/closedir, failure leaves it caller-owned/close. Enumerate at most once. EOF is checked; enumeration refusal freezes name. |
| File fd | Pre/post held and named checks bracket two reads. Close acquired fd on oversize, malformed/changed/input refusal and success. Absence acquires no file fd. |
| Information buffer/CFData/dictionary | Hold healthy selected information input while its borrowed values are used. Dispose dictionary, then CFData, then release/reuse backing buffer; refusal disposes any acquired partial result in that same dependency order. |
| Current name buffer/CFData/dictionary | At most one beside information. Table keys/values and name candidates are borrowed until plan/name extraction finishes; release selector/vector/plan references, dictionary and CFData before buffer reuse. Never overlap the next name input with it. |
| Selector input/result and inventory plans | Inputs use checked literal values and explicit preferences. Inspect complete returned result under gates; release acquired native result/input/vector objects on every mapped/foreign/overflow exit. Empty inventory acquires no selector result. |
| Final scalar transcodes | Copy only retained final identifier/name into result storage. Count actual copied bytes and all representations; partial transcode failure disposes partial owned storage and withholds affected output, or fails whole job if shared gross/call exhausted. |
| Episode completion | Retire names/information/plans/descriptors, close first root, then second fresh root resolution under the existing two-walk allowance. Require equal before/after device/inode; mismatch refuses choice. Close that second walk on every exit. No third walk or query-long pin. |
| Shared failure / lifecycle freeze | Publish no arbitrary prefix; discard staged values and retire all actual acquisitions on true return. Do not release the shared slot on caller timeout. |

This is the normative cleanup protocol, not a measured disposal count. k220 must
enumerate concrete reserve slots, buffer/vector representations, CF error-object
ownership, dup/fdopendir failure, scalar failure and every native boundary. Opaque
parser/selector/root-resource acquisitions and undetected races remain N5/N8 and
serviceability obligations. No finite design check proves prompt safety or native peak.

## Reproduction and acceptance boundary

The source/export is served at the stable architecture-viewer URL. This session's
browser inventory is empty, so local SVG rasterization establishes readable
diagram delivery only. Browser deep-link, mobile and dark-appearance verification
remain explicit reconciliation work; HTTP success supplies no such check.

Run `task design:application-metadata-reader-plan-check` for the pure policy model,
controlled counterexamples and every saved selector mapping. It reads only checked
repository inputs. Tests hash their census/proposal/model/test inputs before and
after; the final session check freezes the full declared design-input set around
Taskfile execution. Fixtures independently catch layout fallback after denial,
cross-base/family reordering, malformed display rescue, omitted tables, conflated
inventories, normalized/foreign/regional returns, individual oversize poisoning,
the 129-byte name, unselected invalid table values and shared failure confusion.
Original finite-dimension controls remain in
`design:application-metadata-subject-check` and `design:localized-boundary-check`;
those latter checks deliberately retain the refuted old certificate as a counterexample.

Public GraphQL, actual provider/host binaries and isolated signed supported macOS
VMs remain the agreed seams. Their future cases include each family/layout,
information/resource absence and denial, selectors/backstops, healthy empty and
malformed candidates, independent table inventories, LocProvenance, aliases,
129-byte output, individual oversize versus shared overflow, English Find My/Voice
Memos and German loctable names. Long actual-source/action boundaries, independent
four-action image guards, grant/revocation/disclosure/old-host refusal, native
baseline and dialog/hydration/listener/store/action serviceability controls remain
independent. The 149 other recorded query paths are no product exclusion. No
current installed target, reader/Koine probe, VM, source query, signing, consent or
macOS 27 qualification is exercised by this model.
