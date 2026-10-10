# Application metadata owned-storage subcertificate

[Owned storage → Separate capacity, writes and overlap](../design/architecture/index.html#diagram-native-metadata-owned-storage)
shows this independently checkable design slice. Graphs enter at their dark
**Start here** node; numbered edges give accounting order. The source/root
[receipt grammar](application-metadata-source-root-certificate.md) and reader
[operation ledger](application-metadata-operation-ledger.md) remain its contracts.

**Whole-job construction remains unestablished.** This supplies an explicit local
storage representation and known saved input/key/vector subterms, not a completed
source/root/bridge/publication/wire composition. Packed buffer sizes are proposed
requested capacities, not Swift Array/String/Dictionary layouts or native peaks.
Every original gate, the k215 family hold and pending native G/N/V bind. K225/k220
remain open; k227 owns full composition and their complete close checks.

## Capacity and event contract

The owned storage module hides capacity, lifetime and growth decisions behind
allocate, write, grow, project and retire operations. Its enabling point is the
existing cleanup-first ledger; pure traces substitute explicit native observations.
An allocation event charges its requested bytes once, including header and padding.
Every actual initialization, native input/prefix write, memcpy, field update and
NUL write charges its bytes separately. No capacity reservation also constitutes
a performed write. Free, reuse, cancellation and ownership transfer refund no
performed bytes or attempts. An unspent upper reservation may end on actual return.

For a raw owned block with P payload bytes, its requested capacity is
`16 * ceil((32 + P) / 16)`. The 32-byte header has four 64-bit fields: capacity,
used length, owner token and flags. It is initialized once, costing 32 further
gross bytes and one local event. Header updates are further writes. No blanket
zero initialization of the payload is required or charged; if performed, it is
an additional receipt. Allocation/free each consumes one attempt, and each
explicit population/copy/write event consumes one conservative local attempt.
Allocator-internal metadata, size-class excess and opaque acquisitions remain
distinct peak uncertainties; this is a requested-capacity construction only.

Raw immutable input and conversion buffers have no embedded header; their owners
must occupy separately accounted owner records in the full composition. Requested
raw capacity is `16 * ceil(P / 16)`. Record and vector backing use the block header.
All packed field widths are eight bytes; flags/enums/nullable values use explicit
64-bit discriminants, not inferred Swift padding. Byte spans use owner-relative
offsets, never pointers escaping an owner's lifetime.

| Record | Fields, in stored order | Payload bytes |
| --- | --- | ---: |
| Scalar span | owner, offset, byte length | 24 |
| Owner | token, disposer tag, dependency token, state | 32 |
| Source slot | source, ordinal, path span (3), identifier span (3) | 64 |
| Copy | identity device/inode, path span (3), identifier span (3), name span (3), metadata provenance, installation/flag bits, policy/source bitsets | 112 |
| Locale/plan | key span (3), native owner/index, classification/order | 40 |
| Seed | identifier span (3), first slot, domain offset/count | 48 |
| Ordered domain | path span (3), ordinal, resolution index | 40 |
| Walker | current/terminal descriptors, literal/pending/stack/expansion/cycle/link-map owners, pending index, phase, status identity (2) | 96 |
| Cycle | directory identity (2), text span (3), collapsed-suffix span (3) | 64 |
| Diagnostic | source/reason, subject span (3), guidance span (3), flags | 64 |
| Source summary | source, availability, observation/category completeness, examined, reason bits, diagnostic count, saturation | 64 |

Payload widths are design declarations. Every population initializes each listed
field; mutations update only their actual field widths. Populating a vector in
one bulk event costs its entire written payload; populating per field costs the
same bytes and each performed field event. The full attempt derivation must name
which path it uses. A schema whose final fields require extra spans/discriminants
must revise its width and receipts; packed records cannot hide that work.

## Vectors, arenas, maps and ownership

Known-count pointer vectors allocate exactly `capacity(8 * N)` and populate 8N
bytes. Table extraction has two such vectors per actual table; they remain live
with its parser until all key/value borrowers and selectors retire. Plans retain
their literal keys and native owner association. They never borrow a different
table's inventory or omit LocProvenance inspection. A plan's reference vector
and every raw regional/duplicate return require separate population receipts.

Unknown-count vectors start empty and use capacities 1, 2, 4, ... at append
boundaries, subject to existing shared count/gross admission. On growth, admit
the new allocation/header, copy exactly used records, update the owner's pointer/
capacity fields, then free the old block. Both capacities overlap until the copy
returns. The pure growth test accounts allocation/header/payload copying and
overlap; owner-field updates are named separate composition receipts, not a claim
that the test includes the caller's state. Nil allocation keeps the old owner.
Cancellation never frees either buffer while an outstanding copy/native call uses it.

An arena can group existing scalar/record payloads only with explicit page
receipts: 4,096 payload bytes plus the aligned header per page, each next-page
link update and each suballocation write. Unused page capacity still costs gross.
Free pages after their last borrower; retained output pages last through final
conversion. The current subcertificate deliberately uses independent exact-size
key blocks, so it credits no arena packing or COW sharing. A packed arena is an
alternative construction for the composition child, not a silently smaller sum.

Maps/sets may use sorted reference vectors with exact literal-byte comparisons
and explicit insertion shifts and owner writes. Binary search comparisons require
bounded local events under the full attempt contract; copying/shifting a suffix
charges every byte on every insertion. Hash tables instead need bucket capacity,
load/growth/rehash/probe and per-field receipts. Neither has an unspecified "map"
fee or a free Swift Dictionary bridge. Native array/property overlay capacities,
ARC retain/release and Swift COW copies remain explicit unbound terms. This design
does not certify that replacing their labels with packed sizes makes them occur.

## Immutable inputs and overlap

The serial job allocates two 131,072-byte raw immutable input buffers once: one
for retained information and one for the current name file. Two separate EOF
byte slots use one raw two-byte block, aligned to 16. One reusable 8,193-byte
conversion block aligns to 8,208. Their known requested capacity is **270,368**.
No initialized payload is assumed, so this is also their allocation-only gross.
Their four allocations and four eventual frees cost eight local attempts.
The full composition adds owner records and their writes, not a second scratch
allocation or a blanket former 1 MiB reservation.

Each attempted payload and EOF read remains a separate receipt on every file.
Successful exact EOF writes zero bytes; extra EOF writes one and refuses. The
saved envelope charges one possible extra byte per present selected file as a
conservative branch upper; it does not assert that healthy files wrote EOF bytes.
Short reads and partial conversion charge the actual prefix. Zero-length files
still attempt payload and EOF calls. Individual oversize performs no input read.

CFDataCreateWithBytesNoCopy has a null allocator for the backing bytes; it owns no
second input payload. Its opaque data owner depends on that buffer. The parsed
dictionary and its borrowed values keep data/buffer dependencies until retirement.
Information and one name dictionary may overlap. Before reading another name
file, retire its borrowers/selectors, dictionary and CFData, in that order.
No overwrite of either immutable buffer is admitted while a dependent parser is
live. Parser result/error objects, possible nil/error/both returns and exact API
calls continue to use the operation ledger; the storage test's parser token is
an abstract dependency, not a replacement parser call count or native footprint.

The maximum simultaneous owned set also includes current first-root/walker
state, listing/descent owners, table key/value vectors, possible/preference/result
vectors, scalar blocks and retained staging. The second walk begins only after
metadata owners and the first root retire. Known scratch is one partition of this
overlap, never the whole live set. A pending call retains inputs and all possible
cleanup; the slot is returned only after true return and complete retirement.

## Scalar conversion and final values

The existing path/key/name/identifier UTF-8 limits remain 8,192/1,024/1,024/512.
For an actual checked CF string, observe type, UTF-16 length and encoding upper,
then invoke bounded lossless CFStringGetBytes with buffer length at most its
field's existing UTF-8 limit. Require all input characters converted, no NUL and
the existing field rules. A larger encoding maximum does not require allocating
it: an accepted bounded value fits the chosen output buffer; incomplete conversion
refuses. Every actual prefix is charged, including refusal prefixes. A terminator
is a separately charged write only when performed. Regional/duplicate selector
returns and unselected direct/table keys get their actual observations before
mapping/dedup. Rejected inventory entries do not get invented scalar contents.

The explicit local key construction writes B bytes into reusable conversion
scratch, allocates `capacity(B+1)`, initializes its 32-byte header and copies B+1
retained bytes including NUL: `B + capacity(B+1) + 32 + B+1` gross, five events
including eventual free. Actual CF calls are separate upstream receipts. Final
identifier/name/path spans can retain existing blocks only by moving ownership
without another byte copy; caller/owner field updates still cost their writes.
String creation, UTF-8 repair of error components, native/Swift bridging, result
vectors/dictionaries and host serialization are additional performed operations.
No such conversion is credited as zero by this subcertificate. A 129-byte label
is admitted; bounds and en/de maxima supply no missing regional value observation.

## Saved episode derivation and limits

The instrument independently joins every saved literal episode/alias to its
observed target, files and each run's selected bases. For each of 2,043 rows in
both saved runs it derives selected payload input plus extra EOF upper, complete
raw direct-entry projections, retained .lproj components and separately projected
suffix-stripped selector keys, complete table key projections including LocProvenance,
and both raw key/value extraction vectors. Shared scratch is added once per job.
The long-root disk-reader suffix remains a comparison superset; it authorizes no
ordinary-reader call beyond 1,023 bytes. Rejected entries stay per-copy metadata
refusal; their saved literal names are preserved, while unknown type outcomes
and unperformed suffixes are disclosed.
All 149 outside query paths retain their exact saved records; they are no source
or category exclusion. No new native observation or supported-VM qualification occurs.

The [per-item JSON](../design/application-metadata-owned-storage.json) labels these
figures known local subterms. Named columns are stored once per common/run table;
every cell is preserved, and each complete row remains associated with its literal
spelling at the same index in episodeSpellings. That complete ordered sequence is
validated before omitting its duplicate per-table spelling cells. Checks reject
inconsistent columns and compare full tables item by item.
They omit record/owner population, native listing
buffer acquisition, selector/return scalar values, source/preferences/type trees, expanded
walks/maps/owner updates/errors, final Swift/host conversion and response encoding.
Their sums are neither a lower bound on every runtime branch nor a whole-job
upper: saved conservative reader suffixes coexist with omitted unknown terms.
Whole episode/job gross, attempts, final scalars and response stay null. Input
read attempts overlap the reader API manifest and cannot be added to it twice.
No local fit compares these subterms alone with the whole-job gates.

| Saved run | Known local gross subterms | Known local attempt subterms |
| --- | ---: | ---: |
| en-AU,en | 14,181,924 | 401,979 |
| de | 14,356,031 | 404,815 |

These deliberately conservative independent-key blocks preserve every actual
raw-entry/key projection in the proposed local contract. Keeping native borrowers
would reduce owned copies but couple parser lifetimes to later staging; an arena
could reduce headers but adds page capacity, links and ownership transitions.
The explicit-block construction is the inspectable comparison, not an assumption
that a future Swift adapter achieves these figures. Reconsider packing only after
the composition exposes a material fit shortfall and derives every replacement
receipt under the unchanged gross rule. Neither an accepted construction nor a
larger gate follows a locally smaller number.

## Reproduction and remaining design work

Run `task design:application-metadata-owned-storage-check` after edits settle.
The command compares complete rows, freezes every declared subject before/after,
checks capacity/header/repeated input/EOF/partial conversion/growth overlap and
cleanup prefixes, and rejects isolated charge/growth/refund/alias/outside/unknown
mutations in disposable copies. Existing source/root, reader, episode and original
oversize/baseline/omitted-table controls remain required. Pure passing controls
prove this local contract's reproduction, no native or useful whole-job verdict.

The composition child must instantiate record fields/owners/arena or exact-block
choice, actual Swift bridge/COW obligations and conversion boundaries; bind each
source/root/reader receipt including walker allocations, suffix/expanded copies,
seed/domains/errors and scalar returns; then compose final scalars and a complete
finite selected GraphQL response with roots/aliases/fragments, keys/punctuation,
escaping, coverage/diagnostic saturation/null/error paths and body-guard failure.
Already pending native tuples/preferences/expanded visits and regional scalar
observations remain separately conditional inputs, never zero. Keep the 20 MiB/
4,194,304 gates, independent 8 MiB response and three/five-second/four-true-return
contracts. K227 performs full k225/k220 closure checks; k221 owns reconciliation
and mandatory whole-k215 review. No new implementation or fragment review is cut.
