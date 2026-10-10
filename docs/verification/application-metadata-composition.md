# Application metadata owned composition

[Owned composition → Require runtime bounds before acquisition](../design/architecture/index.html#diagram-native-metadata-composition)
shows the admission question. Graphs enter at the dark **Start here** node;
numbered edges give accounting order. The [source/root contract](../specs/application-metadata-source-root.md),
[owned-storage subcertificate](application-metadata-owned-storage.md) and
[complete selected-wire contract](application-metadata-wire.md) supply the inputs.

**The full construction fails to establish admission.** This is a reproducible
failed construction, not proof that useful metadata cannot fit the selected gates.
The proposed packed records do not bind the current Swift collections or the
public provider value conversion. Unknown owned capacities prevent numeric
pre-call admission even when a known subtotal is below the application gate.
Required native inputs remain conditional and all G/N/V verdicts remain pending.

## Compose disjoint contributions

For saved episode i, let A_i be its explicit reader API upper, L_i its local
attempt upper, F_i its selected regular-file count, and G_i its local gross
subterms. Both ledgers count the payload and EOF read attempts, including empty
files. The disjoint known attempt term is `A_i + L_i - 2F_i`. Every repeated read
still contributes its input bytes to G_i; removing the duplicate attempt term
removes no performed write or gross charge. The inputs must agree on selected
payload bytes and exact ordered spellings before composition.

The allocation-only shared scratch contributes 270,368 gross bytes and eight
local allocation/free attempts once per serial job. It is already included in
the saved local aggregate; do not add it again. Exact EOF is a zero-byte write
but remains an attempt; the saved extra-EOF charge is a conservative refusal
branch upper. The conservative reader suffix remains a comparison superset for
long/refused episodes, never permission to run ordinary metadata above 1,023.

| Saved run | Disjoint known attempt upper | Known gross subterms |
| --- | ---: | ---: |
| en-AU,en | 871,255 | 14,181,924 |
| de | 904,386 | 14,356,031 |

These are partial terms, neither complete job uppers nor runtime lower bounds.
The [complete row report](../design/application-metadata-composition.json) retains
all 2,043 associations in each run and every one of the 149 outside records.
It preserves the controlled raw-source dimensions and two system seed reserves;
the latter carry no invented returned tuples. Raw/regional/duplicate locale
returns, LocProvenance, aliases, the 129-byte name and L1500 dimensions remain
in the hashed input ledgers. No raw slot, name or outside outcome becomes a
product exclusion through this composition.

Full episode attempts/gross additionally require the first expanded walk and
transfer, ordinary-resource or indexed projection, reader owners/records/raw
selector returns, independent second walk, identity merge and final publication.
Full job terms additionally require preferences and all source snapshots/type
trees/raw slots, once-per-ID registration including both system seeds, seed/domain
maps and comparisons, outside outcomes, diagnostics, coverage, permissions and
errors. Any unknown summand keeps the whole total null. Counting a nominal record
once cannot pay for repeated field writes, growth or value copies.

## Runtime binding obligations

For each actual transition, bind requested capacity C, every initialized or copied
byte upper W, optional operation attempts A, possible output owners and their
disposal credits **before** invoking it. Admission needs remaining gross >= C+W
and remaining attempts sufficient for A plus all retained and possible disposals.
Record actual performed capacity/write prefixes on return; unspent reservation
may end, but spent gross never falls on reuse, sharing, disposal or cancellation.
Each allocate, field write, retain, release, compare, growth-copy and free has its
own receipt unless a declared bulk operation really performs them together.

The pure `begin_owned` control represents one declared acquisition transition;
it does not infer the runtime's operations. It rejects an unknown C before any
invocation. It exercises equality, overflow, nil-output/prefix writes, cancellation
and previously reserved cleanup. The existing ledger keeps inputs/outputs and
the slot until true return; a bound refusal cannot trigger a convenient fallback.

| Transition | Required capacity/write/operation binding | Lifetime and failure |
| --- | --- | --- |
| Raw input/conversion blocks | Existing exact aligned raw capacities; every read, conversion prefix and explicit terminator; owner-record population and updates separately | Two immutable inputs overlap with their CFData/dictionaries; no overwrite before borrowers and parser owners retire |
| Fixed typed records | Existing proposed 64-bit field widths, aligned block header, initialized fields and each later changed field; actual runtime representation still must be selected | A span retains its owner; descriptor transfer moves one disposal credit and separately writes state |
| Native source/preference/URL overlays | Actual getter result ownership, overlay/bridge backing capacity, pointer/record population, each retain/autorelease/release and pool drain | Snapshot only once; raw slots before dedup; native object footprint stays opaque, but an owned overlay cannot disappear into that category |
| Dynamic vectors/arenas/maps/plans | New backing capacity/header, initialized new cells, used-prefix or insertion-shift bytes, owner/pointer/capacity updates and comparisons | Old/new blocks overlap through copy; nil growth retains old owner; every raw key and selector return remains charged |
| Walker bytes/state/cycle/maps/errors | Literal/component/C-name buffers; zeroed readlink input plus actual returned prefix; text/suffix/expansion/stack/cycle records; final join and error transcode | All expanded visits, dot/link/33rd-link and error branches; independently retire first metadata/root before second walk |
| Final application scalars | Each checked path/name/identifier, typed nullable flags/provenance/state/policy/source; String construction capacity, transcode prefix and owner updates | Ordinary refusal withholds affected facts; indexed facts do not invent current flags; no copy is credited as adoption without an actual ownership move |
| ProviderValue publication | ProviderValue element stride, Array/Dictionary backing headers/capacity/growth, String keys/values, populated enum payloads and field updates; ARC/COW/share/destroy operations | A frozen snapshot owns its returned tree; nested aliases borrow that snapshot while separate roots own separate jobs |
| Host conversion/completion/encoding | Native list conversion, retained ProviderObject values, completed Map arrays/dictionaries/errors, encoder scratch/final Data/growth/copies/retirement | Host receipts remain separate; finished-body bytes do not establish requested capacity, pre-encoding overlap or application admission |

Known packed widths are proposals for explicitly allocated storage, not
`MemoryLayout<ProviderValue>`, Swift Array capacity, Dictionary bucket count or
String backing allocation. A new count/locale/field quota, a fixed fee or a
post-call capacity observation does not supply the required pre-call bound.
The report enumerates **every** unresolved non-opaque receipt in every saved
source/root branch, with repeated fixture associations; it does not sweep a
hand-written list of labels or substitute fixture frequency for actual visits.

## Concrete failed construction

Exact [walker source](../../Providers/WorkspaceProvider/Logic/LocationWalk.swift)
constructs components, maps CChars then concatenates NUL for each named call,
zero-initializes the link buffer, copies its returned prefix, inserts into Set
and Dictionary, appends expansions and constructs a final joined spelling.
The source/root grammar names those operations, but supplies no numeric owned
capacities for their Swift backing storage or additional COW/ARC operations.
The raw packed block formula cannot be substituted while claiming this code path.

Exact [ProviderValue source](../../ProviderAPI/Sources/KoineProviderAPI/Resolution.swift)
requires public String, Array and Dictionary values. Exact
[provider conversion source](../../Sources/KoineCore/ProviderContribution.swift)
wraps object values in ProviderObject; list conversion appends converted elements
to another Swift array. It does not encode a raw arena directly. A valid bounded
UTF-8 span therefore does not by itself pay for publishing its String, value tree,
host list or resulting completed output. Sharing may avoid a payload copy but
needs an explicit enabling operation, owners and reference/field writes; assigning
zero to all such terms would be a different, unselected accounting rule.

For example, a declared transition with 64 capacity bytes and at most 16 initialized
bytes needs an 80-byte pre-call reservation. A 79-byte remainder refuses before
invocation; an unknown capacity refuses even with a 100-byte remainder. This
counterexample does not claim an actual Swift allocation is 64 bytes. It proves
that a known payload and a post-encoding cap cannot admit an unspecified runtime
allocation. The same missing contract affects source overlays and walker state,
not only the last response buffer. No native observation is needed to identify it.

Graph Tier 2 generation 2026-09-29T10:36:20Z is stale for Engine and
ProviderContribution; graph snippets were unsuitable for current source evidence.
Exact reads include Engine's missed line 295. LocationWalk is untracked in that
generation; docs/scripts are excluded. The derivation hashes the exact relied-on
sources instead. This establishes no negative or exhaustive graph claim.

## Final values and the independent wire gate

The full finite k228 selections remain intact. Actual ordinary/indexed final
paths/names/identifiers, source summaries, declared domains, permission targets
and emitted error messages/extensions/locations/paths remain unknown. No saved
literal spelling is silently used as a final resolved path, and saved English/
German file names establish no missing regional or long indexed native value.
Domain/permission widths in the completion example remain explicit assumptions,
not new product quotas. Actual selected sizes and actual complete response stay null.

Conditional successful-data uppers of 40,141,782 bytes for one complete root and
147,120,535 for two roots/four items aliases are above the unchanged 8,388,608 cap.
They establish neither useful fit nor inevitable overflow. Selecting fewer fields
or dropping choices is not this design's remedy. Distinct roots have independent
application-job budgets; nested aliases multiply host completion/encoding work,
not source observations. The example imposes no public root/alias restriction.

[Engine](../../Sources/KoineCore/Engine.swift) materializes and encodes the full
result before the body-size check. Above cap it replaces data with null and a
failed error (174 bytes in the read default shape). This protects the sent body;
it pays no earlier application allocation or host encoder capacity and supplies
no peak certificate. Application and host totals are separate accounting owners;
neither host conversion nor encoding is declared free or charged to a newly
invented application policy. Their unresolved terms are reported explicitly.

## Alternatives and completion criterion

Keeping the current collections requires a supported conditional capacity and
operation contract for their exact construction paths, including failed prefixes.
An explicitly allocated raw representation can hide capacity/growth policy inside
the discovery adapter and make its receipt seam deep, but must account the real
source overlays and final public value boundary. It adds migration work and cannot
silently change the provider ABI or action walker. Moving a stage to “opaque,”
using logical payload charges, increasing gates or excluding useful categories
would change the selected accounting/behavior and is not adopted.

The concrete remaining design question is: **which representation and publication
path supplies numeric pre-call owned capacity/copy/operation bounds while producing
the existing ProviderValue contract?** An answer must bind the enumerated source/
root/local/publication receipts, every field and owner update, all growth/ARC/COW
paths, overlap and prefix cleanup. A compiler-dependent conditional contract must
state its exact source/toolchain/ABI assumptions and refusal behavior; it cannot
be an empirical peak measurement or the same null operands with new names.
Already pending native tuples/preferences/expanded visits/regional values stay
separate conditional inputs, never another native-capture design increment.

Completion requires full per-episode/job expressions and independently supplied
final values/errors through the complete selections. A conditional useful fit is
earned only when those bounds and finite input assumptions fit. Otherwise keep
the family consumption hold and state the precise failed construction. The selected
20,971,520 gross/4,194,304 attempts, independent 8 MiB wire, three/five-second
deadlines, four true-return slots, source/category/layout/locale policy and all
authority/action/disclosure/Settings/compatibility contracts remain binding.

## Reproduction

Run `task design:application-metadata-composition`, then
`task design:application-metadata-composition-check` after edits settle. The
instrument freezes all declared ledgers, selected document, exact sources,
models/tests/mutation tools, this contract, diagram/manifest and Taskfile before
reading and compares hashes after derivation. It compares complete per-item cells
and ordered associations, not just aggregate totals. Its exit 0 means the declared
failed construction reproduced, never that useful metadata fits or native passed.

Disposable mutants remove shared-read subtraction, drop input gross/aliases/outside
records, erase an unknown operand or omit initialization from pre-call admission;
each must fail a behavioral assertion. Inherited source/root/storage/wire controls
retain call/branch/cleanup, alias/escaping/error and original oversize/baseline/
omitted-loctable controls. Pure passing checks do not remove the consumption hold
or complete the mandatory whole-producer review. No target/source/CF/reader/launch/
VM/signing/consent experiment or native implementation runs here.
