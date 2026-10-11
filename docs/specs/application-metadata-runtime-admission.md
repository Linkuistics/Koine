# Application metadata runtime admission

<a id="concrete-decision-awaiting-antony"></a>

## Selected boundary

Application metadata uses the [explicit-work accounting decision](../adr/application-metadata-accounting-covers-explicit-work.md).
Antony selected this boundary in k231. The 20,971,520-byte cumulative gross
counter covers controlled raw requested allocations and performed raw
initialization, input, copy, field and owner writes. The 4,194,304-attempt
counter covers every explicit adapter/local/native operation, comparison,
retain, release and cleanup. Disposal, sharing, reuse and cancellation refund
nothing. Both counters reserve charged work and retained/possible cleanup
before the next optional invocation.

Compiler-generated ownership traffic and internal platform/Swift constructor,
bridge/COW, metadata and allocator work are outside these numeric guards.
They are excluded costs, not measured zeros. Issuing a constructor, getter,
bridge, comparison, retain or release still charges its explicit attempt.
ProviderValue publication remains provider-owned; only its runtime backing
is excluded. There is no total provider heap, hidden-copy gross, runtime-attempt,
RSS or peak guarantee. The independent 8 MiB sent-body cap supplies none.

[Runtime admission → Account explicit work through real publication](../design/architecture/index.html#diagram-native-metadata-runtime-admission)
shows the selected boundary. Graphs enter at the dark **Start here** node;
numbered edges give reading order. The old strict failure remains comparative
evidence in [Evidence and incompatibility](#evidence-and-incompatibility).
It is no longer a pending human choice or an admission requirement for excluded
internals. Native dimensions/final values/errors remain conditional. Selection
alone does not establish useful fit or lift the family consumption hold.

## Representation and ownership

The discovery adapter owns raw staging, capacity/growth decisions, explicit
operation accounting and a real public-value adapter. A caller requests one
catalogue and receives one frozen ProviderValue tree; it need not assemble
arena, native-owner or publication protocols. Raw observations retain source
order; grouping uses separate indices. Actual Foundation/Swift APIs supply their
real values and accessors. An array returned through a Swift interface is still
a Swift array, with excluded internal backing, rather than a fictitious borrowed
CF array. Native CF children use type/count/value getters while their actual
owner lives. Explicit array access, getter, bridge and cleanup invocations are
charged even when their internal representation is excluded.

| Alternative | Caller obligations | Internal ownership and cost | Selection |
| --- | --- | --- | --- |
| Retain runtime collections throughout | Existing API remains convenient | Explicit invocations can be counted, but controlled raw capacity/write policy is dispersed among stages | Rejected as the staging design; real source access remains where the API requires it |
| Controlled raw staging and real ProviderValue adapter | One request and frozen value result | One owner of requested capacities, field writes and lifetime; mandatory Swift publication remains real work with excluded internals | Selected under the scoped ADR |
| Strict runtime-specific certification | Public API can remain intact | Needs image/toolchain/source correspondence and full constructor/ownership uppers; unqualified combinations refuse useful output | Comparative alternative; reconsider only with an attainable certificate |

No raw-tree framework extension is selected. A changed ABI, budget, posture,
source/locale/category loss or new product quota requires its own decision.

## Controlled raw recipes

Let align16(x) round up to a multiple of 16. Each headed block now requests
align16(64+p): 32 bytes of capacity/used/token/flags and 32 bytes of
owner/disposer/dependency/state. These are explicit eight-byte cells, not Swift
value-witness strides. Initializing the header writes 64 bytes; actual payload
population writes p bytes. Retiring the block writes its eight-byte state and
frees it. A fully populated block therefore costs align16(64+p)+64+p+8 gross
and five explicit operations. Empty payloads still have their header/owner and
cleanup. Failure charges only performed requests/writes and retains any acquired
owner; it never credits an unperformed full population as actual work.

The embedded owner record avoids a recursively allocated owner-of-owner table.
A raw supervisor frame carries fixed state plus four scratch owner records;
native-owner descriptors are separate declared 32-byte payload blocks. Each
native retain/release/pool operation and each subsequent descriptor update is
additional work. The disposer tag determines the actual native/descriptor-free
sequence, all reserved first. Native descriptors and controlled buffers remain
live while any getter/parser/converter borrows them.

The retained record payload widths remain span 24, owner 32, source slot 64,
copy 112, locale/plan 40, seed 48, ordered domain 40, walker 96, cycle 64,
diagnostic 64 and source summary 64 bytes. Raw capacity, header initialization,
payload initialization and each later eight-byte field update are separate
receipts. No uninitialized padding is treated as a useful field. If zeroed,
its actual writes are additional charges.

A scalar conversion writes its actual successful or failed prefix into the
admitted shared conversion scratch. A complete retained scalar separately
allocates, initializes and writes its bytes plus one NUL. This is a real copy,
not Swift String adoption. Source scalar scratch uses the shared buffer only
within its existing bound; it is not reallocated on each getter. The explicit
bound/access/conversion operations remain charged. Unknown lengths are explicit
operands and cannot be excluded or set to zero.

Known-count pointer/record vectors use the declared stride times count.
Growing vectors use capacities 1,2,4,..., with a new headed request, header
initialization, used-prefix copy, pointer/capacity/length updates, old retired
state/free and actual new-cell population. Old/new owners overlap through copy
and transfer. Failed allocation retains the old vector; failed later population
retains all performed prefixes and disposes every acquired block. Reserve the
whole transition and its cleanup before starting it.

Grouping sorts a separate raw index vector using heapsort and byte-exact span
comparisons. With h=ceil(log2(max(1,n))), conservative bounds are n(h+1) swaps
and 2n(h+1) comparisons. Each swap performs three eight-byte writes. Loop/index
accesses and changed fields are separately counted; these bounds do not erase
them. Frozen identifiers are found by binary search with at most
ceil(log2(n+1)) comparisons per lookup. Original raw ordinals and domain ranks
retain first-observation ordering. This avoids an unspecified runtime hash-table
backing or uncounted rehash while charging all actual duplicate comparisons.

## Source, reader and independent walks

Every source/root receipt has a disposition and parameterized recipe in the
[decision packet](../design/application-metadata-runtime-admission.json).
The complete receipt inventory and both saved ordered runs are in the
[composition report](../verification/application-metadata-composition.md).
All previously unbound labels are either controlled raw operations with explicit
capacities/writes or real runtime operations with excluded internals and charged
callers. Known source writes and opaque acquisitions are classified too; toy
branch frequency never supplies actual native event counts.

Observe preferences, indexed gathering and running applications once per job.
Keep every raw slot/type-tree member/preference, and expand each coherent ID once,
including both system seed groups. Registration reserves both array and error
cleanup; returned registration values create no recursive seeds. Preserve all
source/layout/locale breadth. Source order and raw duplicate observations survive
classification and grouping.

The first walker operates on literal/component/C-name/link/suffix/expansion,
stack/cycle/map/resolved raw blocks and explicit descriptors. Its receipt tape
includes every dot, parent, link/cycle/32nd/33rd-link and failure branch, status
comparison, actual prefix, state update and cleanup. The 1,025-byte readlink
buffer zeroing and returned prefix are separate writes. Named calls retain their
explicit C-name construction rather than pretending a raw span is a Swift array.
The terminal directory is checked and transfers one close credit; transfer
changes raw state and does not duplicate the close. Actions keep their existing
walker and authority.

Only a checked ordinary root at <=1,023 bytes performs the root-resource
observation and fixed reader. Longer roots require actual indexed tuples. The
reader preserves complete independent direct/table inventories, LocProvenance
inspection and all regional/duplicate selector returns before exact mapping and
deduplication. Its native type/getter/selector/file/parser API upper is counted
once; extra raw owner records, conversion prefixes, field updates, comparisons
and cleanup writes are additional. Existing unselected keys and repeated input
writes stay charged. Individual oversize/refused name files retain the copy and
unknown affected facts without a convenient fallback; shared exhaustion fails
publication as FAILED/null.

Two immutable 128 KiB inputs, EOF storage and conversion scratch retain the
270,368-byte requested raw partition once per serial job. The supervisor/owner
frame and its raw cleanup add 616 gross bytes and nine attempts. Input data,
parser/listing/selector borrowers, native-owner descriptors, staging and walker
allocations overlap explicitly. Retire name borrowers before reusing input;
retire metadata and the first root before the independent second walk. The second
walk checks directory/device/inode and keeps the first finalized spelling.
There is no third walk or per-copy registration re-walk.

## Real ProviderValue publication

For each admitted copy, materialize each checked staged path/name/identifier as
an actual Swift String. Construct nullable scalar/enum/bool values, initialize
its Dictionary, insert each complete field and append its ProviderValue object
to the Array. Construct the whole catalogue including coverage, summaries,
diagnostics, permissions and failure/error data. Count every explicit constructor,
access, insertion, append, freeze and failed-prefix destroy/release. Under the
ADR, their internal String/Array/Dictionary allocation, value writes and
compiler-generated ownership are excluded. Controlled conversion scratch and
raw owner/field/state writes remain charged. An excluded backing is never an
unknown explicit write.

The application choice has seven scalar fields and two list fields. With p
running-policy elements, s source elements and S explicitly issued String
constructors (including whichever key/enum strings are actually constructed),
a fresh choice uses S+(7+p+s) scalar/enum wrappers, one object Dictionary
initialization, nine insertions, two list initializations, two list wrappers,
one object wrapper and p+s+1 appends, including append to the outer items list:
S+23+2p+2s explicit operations before raw accesses, field writes and cleanup.
Absent optional scalars still construct null. Reused static key/enum strings
have their actual enabling construction/retention counted at their owning job,
rather than charging each occurrence as a newly allocated raw string. Result,
coverage, diagnostic, permission and failure objects use the same rule: actual
String constructors + scalar wrappers + object/list initializations/wrappers +
one insertion per field + one append per element + freeze/cleanup. Empty and
failed envelopes retain their actual fields. The complete wire selection does
not multiply provider construction for nested aliases; independent roots do.

Freeze the tree before returning success. Raw storage remains live through the
last conversion borrower and retires only after the public tree owns its values.
A raw span never masquerades as a public String/Array/Dictionary. Nil or thrown
runtime construction can have internal work, which is excluded; the explicit
invocation, actual controlled prefix, acquired owners and cleanup are accounted.
No useful prefix publishes after shared refusal/cancellation/deadline/lifecycle
loss. Possible output cleanup and the shared slot remain held until true return.

Host conversion retains real object values, builds its own converted list,
validates depth and completes the full selected fields/aliases/errors before
encoding. These are separate host operations, not a way to move provider
publication out of its counter. The sent-body guard follows full encoding;
it bounds neither earlier controlled work nor excluded runtime backing/peak.

## Admission, failure and conditional fit

For a transition, sum all controlled requested capacities and performed-write
uppers, plus retained and possible cleanup writes. Sum every explicit operation
and cleanup attempt. Compare both sums with the remaining counters before
starting optional work. Keep cleanup credits across native waits. On actual
return charge performed prefixes/requests/events only; unspent reservation can
end, spent charges cannot fall. Nil allocation retains the old owner and charges
its explicit invocation. Cleanup after freeze spends its prior reservation,
including raw state writes, and true return follows all borrowers and owners.

The full expressions cover every saved row in both 2,043-row runs, all 149
outside records and both system seed groups. Native tuples/type trees/events,
preferences, expanded visits, regional getter/selector returns, final values and
emitted errors are conditional inputs. No finite assumption becomes a product
quota. A numeric upper is usable only for its declared complete finite input
and explicit event sequences. Fit requires the full explicit gross <=20,971,520,
attempts <=4,194,304 and independently completed selected wire <=8,388,608.
Neither partial sums nor broad wire uppers establish useful fit or inevitable
overflow. The precise remaining closure is these native operands/final values,
not another strict-versus-scoped design or a portable runtime certificate.

Three/five-second deadlines, four slots retained until true return, all source/
layout/locale/useful witnesses, authority/action/Settings/disclosure and retained
action-only compatibility remain. Four application jobs can consume four scoped
cumulative counters; this gives no process memory or peak bound.

## Evidence and incompatibility

Swift ABI stability preserves external interoperability while allowing changes
inside implementations. OSes supply the system runtime independently of the
provider's compiler. The certificate cannot follow from ABI compatibility alone.
This is an inference from the [Swift ABI manifesto](https://github.com/swiftlang/swift/blob/1ff1cc1170617ab23ab74aa8b741c8daca1903f6/docs/ABIStabilityManifesto.md)
and [Swift's description of the system runtime](https://www.swift.org/blog/abi-stability-and-more/).

The pinned Swift 6.2 source illustrates the distinction. Array construction asks
for a minimum, initializes storage, and can derive usable capacity after allocation;
COW depends on ownership state. That is neither a pre-call usable-size observation
nor a complete bound for every emitted allocation/copy/retain path.
[Array](https://github.com/swiftlang/swift/blob/1ff1cc1170617ab23ab74aa8b741c8daca1903f6/stdlib/public/core/Array.swift),
[array storage](https://github.com/swiftlang/swift/blob/1ff1cc1170617ab23ab74aa8b741c8daca1903f6/stdlib/public/core/ContiguousArrayBuffer.swift)
and [ManagedBuffer](https://github.com/swiftlang/swift/blob/1ff1cc1170617ab23ab74aa8b741c8daca1903f6/stdlib/public/core/ManagedBuffer.swift)
provide source evidence; allocator excess alone is not the obstruction because
the existing raw contract already excludes that excess.

String's implementation includes its storage header, terminator, conditional
breadcrumb state and allocation rounding. Dictionary construction has native
storage, growth and optional bridging paths. The small public value is not that
backing, and the source snapshot is not identity evidence for an Apple system
image. [String storage](https://github.com/swiftlang/swift/blob/1ff1cc1170617ab23ab74aa8b741c8daca1903f6/stdlib/public/core/StringStorage.swift),
[Dictionary](https://github.com/swiftlang/swift/blob/1ff1cc1170617ab23ab74aa8b741c8daca1903f6/stdlib/public/core/Dictionary.swift)
and [native dictionary](https://github.com/swiftlang/swift/blob/1ff1cc1170617ab23ab74aa8b741c8daca1903f6/stdlib/public/core/NativeDictionary.swift)
are comparative evidence only. The [decision packet](../design/application-metadata-runtime-admission.json)
records immutable revision, full source hashes and every inherited receipt label.

A counterexample explains the incompatible inference: an implementation can add
a private temporary allocation and retire it before returning the same public
value, without changing the external ABI or result. For any purported small
upper derived solely from the public payload/layout, that temporary can exceed
the upper. This is a logical witness, not a claim that Apple's runtime makes
such an allocation. A bound on requested bytes from a **particular** verified
implementation would exclude that witness; the current public contract does not.

Thus strict all-owned pre-call accounting, useful output through the current
Swift value interface, and acceptance based solely on portable public ABI/source
contracts cannot all be established together. The available evidence identifies
no supported implementation-specific certificate. Repeating a census or changing
the name of an unknown operand cannot settle that conflict.

## Test seams and delivery

The agreed public GraphQL, actual provider/host binary and isolated signed
supported macOS VM seams remain. Pure saved-input controls reject unknown-to-zero,
dropped calls/raw writes/cleanup credits, provider-to-host publication moves and
wire-as-memory inference. They preserve inherited charge/call/branch/alias/
escaping/error and original oversize/baseline/omitted-table controls. Every subject
is hashed before/after and every ordered cell compared, not merely totals.
The strict comparison still rejects ABI layout/minimum/post-call observations
as complete strict runtime certificates; those observations are no longer required
for costs explicitly excluded by the selected ADR. Every G/N/V verdict stays
pending. The family hold remains; whole-family reconciliation and mandatory
whole-producer review still precede downstream consumption.

## Grouped refinement and retained hold

The [grouped inventory/key refinement](../verification/application-metadata-grouped-storage.md) replaces complete retained key
partitions with independent linked-slab owners, while preserving the selected
reader semantics, scoped gates, every saved association and the full wire. Its
controlled local/source/two-walk enclosure still exceeds 20 MiB before other
terms; it establishes no useful fit or native pass. Earlier independent-block
numbers remain reproducible comparison. K215 and its consumption hold remain
live. The [selected qualification order](../adr/application-metadata-qualification-precedes-analytic-fit.md)
permits a private guarded implementation for existing N5/N8/V11/V13 qualification
before analytic fit, after complete design, whole-producer review and earned
integration. Advertisement/downstream consumption remain held until full useful
native operands, actual complete selected responses, required witnesses and
independent serviceability qualify. Failed/refused/unknown required useful cases
and unavailable subjects keep those holds and affected acceptance work live.
Existing whole-producer review, all native G/N/V, actual full operands/response,
useful breadth and independent authority/action/Settings/disclosure/compatibility
duties remain. No repeated strict/scoped selection or new capture leaf follows.
