# Application metadata grouped storage

The [joint population evidence boundary](application-population-metadata-shape.md)
preserves all saved per-copy associations but finds the corpus insufficient for
an exact useful metadata shape: payloads/formats and complete typed candidates
are absent. No distribution/qualification recipe is selected; private eligibility
remains false and all native/advertisement/consumption holds remain. Whole review
and a bounded human evidence decision precede further subject design.


[Grouped ownership → Preserve literal keys through slab growth](../design/architecture/index.html#diagram-native-metadata-grouped-storage)
is the current bounded refinement. Graphs enter at the dark **Start here** node;
numbered edges show work order. The [selected accounting decision](../adr/application-metadata-accounting-covers-explicit-work.md)
and [reader semantics](application-metadata-reader-plan.md) remain binding.
This is a pure design instrument over the frozen historical subject, not a reader
implementation, actual native tape, supported-VM qualification or macOS 27 census.

## Candidate and alternative

The candidate uses one owner per direct inventory and one independent owner per
loctable inventory. Literal bytes occupy append-only linked slabs. Five-word
records identify a byte range, exact selector length, classification and original
ordinal. Direct `.lproj` selector keys borrow the suffix-free range of their raw
entry; they do not allocate two additional terminated key copies. Each table
retains its own literal keys, including LocProvenance and unselected keys. Raw
selector returns remain separate native observations, before exact mapping and
ordered deduplication. No direct/table inventory is substituted for another.

The alternative, movable geometrically growing byte and record buffers, makes
lookup simpler but requests larger replacements and recopies populated prefixes.
Linked slabs avoid that relocation and keep earlier spans stable. They introduce
more descriptors, unused slab tails and explicit traversal/comparison work. A
sound full fit with those costs would reverse the failed result; an uncharged
lookup, shared ownership across independent tables or a locale subset would not.
No ABI extension or new source interface is needed by this representation.

## Owners, fields and requests

All widths below are proposed controlled raw requests, not Swift memory layout.
All blocks have a 64-byte header: eight UInt64 cells for next link, parent owner,
capacity, used extent, token, disposer, dependency and retired state. Padding is
uninitialized; any actual zeroing is additional charged work. Headers initialize
64 bytes, retirement writes eight bytes, and free is an explicit operation.

An inventory's 128-byte descriptor has sixteen cells: state, borrower count,
byte head/tail/slab count, record head/tail/slab count, cursor, raw count, accepted
direct count, native-owner dependency, pending backing, selector phase, refusal
reason and reserved cell. It requests 192 bytes, initializes its header and
payload, and writes the supervisor's pending-owner cell before initialization
and clears it after acquisition. Final raw-count, freeze and closing-cursor clear each write eight bytes. Final retirement/free are independent. Its complete ordinary local
cost is 432 gross bytes and ten operations, even for an empty inventory.
The existing once-per-job supervisor admits one pending acquisition at a time;
its fixed allocation remains in the shared 616-byte augmentation.

Byte slab payload is max(256, next literal UTF-8 length + NUL); record slab
payload is 640 bytes, sixteen 40-byte records. A key never crosses a byte slab.
Requests round 64 + payload up to sixteen-byte alignment. Each acquired slab
writes a pending-backing pointer, initializes its header, writes head/tail/count
cells (including writing the retained head value on later growth), clears the
pending pointer, and eventually writes retired state and frees. Later slabs also
write the previous next link. No prior payload is recopied, adopted or refunded.
A new slab and all prior slabs overlap until final retirement; allocation failure
retains the old chain. Failed initialization/linking retains its pending owner
for cleanup. There is no directory re-enumeration or count-first second scan.

The record's first word packs UInt32 slab ordinal and UInt32 byte offset; the
remaining words hold raw byte length, selector byte length, classification and
original ordinal. The report expands the locator into two columns for inspection.
The selected gross gate itself bounds these local slab/offset values below 2^32;
checked arithmetic rejects overflow before an allocation. A record is initialized
once, then classification is written separately. A valid direct entry writes its
exact suffix-free selector length and increments accepted-direct count. Byte-used,
record-used and cursor each have an eight-byte write per raw slot. A performed
conversion prefix, raw bytes plus NUL and 40-byte span initialization are separate
charges. Rejected/non-locale entries still have their literal bytes and records;
unknown native type results do not become accepted languages. Known size/key
failures retain the selected individual affected-fact refusal semantics.

Each loctable uses one separately headed 16*n-byte pointer extraction block,
with independent n-pointer key and value ranges. It requests, initializes,
populates both ranges, retires and frees; the native extraction invocation is
already counted once by the reader API ledger. Dictionary ownership outlives
these borrowed native pointers and every conversion. Inventory raw bytes are
independent copies. The parser/input can retire after its last borrower, even
when the retained raw inventory remains live. Two immutable file inputs, EOF and
conversion scratch remain allocated once per job under the existing recipe.

## Borrowers and every exit

Only frozen inventories permit selectors or converters to borrow spans. Each
explicit borrower-count update and call/retain/release is charged in the reader
owner/return tape. Borrowed ranges use checked length APIs, never a falsely
terminated suffix view. Native CFString/array construction and real ProviderValue
publication remain provider-owned; their explicit invocations/cleanup count,
while runtime/compiler internals remain excluded and disclosed, not measured zero.
Slab lookup, loop/access, byte comparisons and parser/getter/dependency updates
remain in that tape with their actual operands. The model's Python containers are instrument implementation, not proposed
uncharged production ownership. Isolated owner/slot controls model one fixture;
production groups share the job ledger/slot and disposal of one group never ends
a still-live job. Offline summed conservative enclosures can exceed admission;
actual work would stop at the guard rather than perform the entire enclosure.

Every acquisition reserves requests, all known writes, explicit attempts and
existing/new cleanup before invocation. Equality admits; a byte or attempt short
refuses. A pending native call also reserves borrower release and cancellation
state. Failure before allocation keeps the prior owner. Failure after allocation,
header, link, cursor or partial population keeps each performed prefix and every
acquired backing. Unwind frees pending backings and linked slabs before the group
owner, after all borrowers return; a partly initialized span is never selectable.
Cancellation/deadline freezes optional work, retains native dependencies and the
shared slot until true return, then spends reserved cleanup. Disposal refunds
neither bytes nor attempts. Oversized files refuse affected facts and stop name
fallback; shared population/count/call/copy/deadline exhaustion is FAILED/null.
Diagnostic saturation retains choices and fixed summaries.

## Receipt replacement and complete composition

The [per-item packet](../design/application-metadata-grouped-storage.json) stores
all inherited composition/storage/local/wire cells alongside every new row, in both original
2,043-row orders. Each row names its original spelling and target, all five
replaced receipt categories and the old scoped owner-block correction. Input
writes and EOF charges remain. The new recipe replaces complete old key/input
partitions rather than subtracting 72 bytes while keeping incompatible owners.
The five replaced categories are raw-entry projections, direct inventory
projections, direct selector-key projections, table-key projections and the two
separate table extraction vectors. Column names are stored once; equal inventory report shapes are interned
without sharing production owners or reducing repeated episode charges. Every
ordinal associates with the complete global spelling list. All 78,983 old blocks
remain inspectable as
comparison; the candidate has independent inventory owners and linked backings.

Let K_i and C_i be the new grouped key gross/operations, I_i the retained selected
input/EOF writes, and A_i the inherited reader API upper (including reads).
Known local gross is 270,368 + 616 + sum(I_i + K_i); known attempts are
8 + 9 + sum(A_i + C_i). Reader input/EOF attempts are not counted twice.
All additional contributions still use the five episode tapes and four job tapes
from [complete composition](application-metadata-composition.md#complete-expressions).
The packet retains their names, recipes, native inputs and old cells without
changing their scope. Exact expressions are:

- G_job = knownLocalGross + sum_i G(first walk, resource/indexed branch, reader
  extras, second walk, identity/final publication)_i + G(four job tapes).
- A_job = knownLocalAttempts + sum_i A(the same episode tapes)_i + A(four job tapes).

Grouped byte/span population belongs only in K_i/C_i. Additional borrower,
selector-return, owner, loop/access, getter, sort-index and native record work
belongs in reader extras; it cannot repeat replaced raw inventories or disappear.
Path projections belong to snapshots/registration; the two independent walk
literal/state blocks belong to their respective walk tapes. Actual tuples,
expanded visits, preference arrays, regional/duplicate returns, native failure
prefixes, final scalars/domains/errors and full publication remain conditional.
No absent observation is an empty tape or a product quota. Both system seed groups,
all 149 outside records, aliases, 129-byte labels, long roots through 1,500 and
all four layout/base/file families remain. Rejected keys and LocProvenance remain
literal inventory observations with independent selector semantics.

The full selected wire is unchanged and independently hashed. All roots, nested
aliases, response-key merging, fields, escapes, diagnostics, permissions and errors
remain; actual response bytes are null, not the conservative upper. Its retained
conditional bounds are 40,141,782 single-root and 147,120,535 full-example bytes.
The separate 8,388,608 sent-body gate supplies no allocation or useful-fit proof.
Application attempts 4,194,304, deadlines three/five seconds and four true-return
slots are unchanged, as are Settings/location gates, action pathname/authority,
source AND image/four-action guards, read disclosures/old-host refusal and retained
action-only evidence. Native G1–G11/N1–N8/V1–V13 all remain pending.

## Failed controlled enclosure

A declared controlled counterpart retains all 7,862 saved repeated source paths
under the existing projection recipe (3,633,104 gross). For each saved successful
directory episode, each independent walk additionally constructs its own literal
block from that episode spelling and a 96-byte state block under the retained raw
recipe. These two disjoint subterms total 2,793,804 gross across 2,043 episodes.
No component/link/stack/owner/native suffix, system return or final publication is
included in that number. It is a conservative design enclosure for those declared
successful operands, not an observed native trace or universal runtime lower bound.
Long/refused ordinary-reader suffixes remain conservative comparison work and
never permission to run ordinary metadata at long roots.

| Saved run | Grouped local gross | Local + controlled source paths | Plus two-walk literal/state subterms | Excess over 20,971,520 |
| --- | ---: | ---: | ---: | ---: |
| en-AU,en | 16,811,702 | 20,444,806 | 23,238,610 | 2,267,090 |
| de | 16,985,809 | 20,618,913 | 23,412,717 | 2,441,197 |

Known local attempt uppers are 914,288/947,419. The controlled path recipe adds
47,172 local attempts; the displayed walk blocks add 40,860 operations. Additional
explicit comparisons, calls, retains/releases and cleanup remain conditional;
no full attempt or deadline claim follows these partial counts.

Grouping improves the original local terms by 3,057,614 gross in each run, but
this recipe still supplies no sound complete useful finite certificate under the
selected gate. This is a failed candidate, not proof of inevitable native overflow
or impossibility of a different construction. Even below-gate partial sums would
not supply missing native operands or certify the independent selected response.
Useful finite fit remains unestablished. K235's selected ordering below amends
the private design close condition; advertisement/consumption remain held.

## Selected acceptance ordering

K235 records Antony's explicit "you choose" delegation and selects the
[guarded private qualification order](../adr/application-metadata-qualification-precedes-analytic-fit.md).
All amounts, accounting scope, useful breadth, ABI/posture and independent gates
remain. A private guarded implementation may exercise the already chartered
N5/N8/V11/V13 qualification before a complete analytic useful-fit certificate
exists only under the complete [durable eligibility conjunction](../specs/application-metadata-private-qualification.md#eligibility-and-existing-qualification-sequence).
The independent metadata-shape subject is still incomplete; cardinality-only
P1024 fixtures cannot qualify it. The application protocol includes terminal guard
credit and cleanup-failure publication; shared image/ownership design adopts it.
Advertisement/downstream consumption stay held until full declared native operands,
actual complete selected responses, required useful witnesses and independent
serviceability qualify. Refused/unknown required useful metadata, exhaustion,
response/deadline failure or unavailable subjects cannot pass or reduce scope.

This amends the analytic-fit prerequisite and blanket implementation hold solely
for the reviewed private qualification route. Grouping saves known work but the
retained conservative composition fails; actual native work/final wire cannot be
inferred from disk dimensions. The analytic-first ordering was not selected.
Larger numbers alone cannot settle unknown explicit work or the independent
response. The complete private qualification contract now supplies the exact guard,
eligibility and existing sequence. The ordering choice alone supplied none of
these; implementation and every native verdict still await the required reviews. The packet's unchanged `changesAdopted` fields describe the
k233 candidate alone; current ordering is owned by the selected current contract.

## Original close checks and verification

K215's independent frozen subject and k217/k231 answers remain intact; historical
macOS 26.6.2 data establish no macOS 27/support-floor qualification. Fixed formats,
131,072-byte regular files, exact selector/backstop/absence/healthy-empty/refused
branches and individual versus population outcomes are retained. Complete family
and live consumers cite this failed grouped refinement and the unchanged hold.
The sound useful finite certificate remains missing. The amended k215 private
design boundary is complete; private eligibility still awaits whole review and
applicable downstream prerequisite reviews/placement. Existing root
whole-producer review/earned integration precede private implementation and k7;
advertisement/consumption require actual full useful qualification. No duplicate
fragment review or Creator attribution follows this requirements interview.

After edits settle, use task design:application-metadata-reconciliation-regenerate
then task design:application-metadata-reconciliation-check. The grouped check
reproduces every input hash, inventory and ordered receipt association; validates
exact admission, growth stability, every append failure prefix, frozen/pending
borrowers and true return; and rejects disposable omissions of header/pending/
link/classification/retirement charges or rows/receipts/unknown/wire/outside/hold.
The whole suite freezes every documentation/script/config/source/dependency/tool
subject before/after and compares each hash. These checks establish a reproducible
failed design result, never native qualification. No target reads/probes, launches,
registration, signing, consent or VM experiment run.
