# Application metadata runtime admission

## Problem and current outcome

The selected application population contract needs a numeric upper **before**
every owned acquisition, initialization, copy, field update and possible cleanup.
The public provider interface returns Swift String, Array and Dictionary values.
Their public value layout and minimum element capacity do not establish all
backing requests, intermediate copies or compiler-generated ownership operations.
The [composition report](../verification/application-metadata-composition.md)
therefore remains a failed construction under the selected accounting.

[Runtime admission → Separate explicit storage from the public value boundary](../design/architecture/index.html#diagram-native-metadata-runtime-admission)
shows the concrete choice. Graphs enter at the dark **Start here** node; numbered
edges give the reading order. The strict contract below remains binding. The
accounting alternative is a proposal awaiting Antony's selection.

This is a failure of a portable certificate from the available public interface,
not a claim that actual metadata necessarily exceeds 20 MiB, that every Swift
allocation is unknowable, or that a certificate for a particular compiled image
could never be built. Increasing the budget alone supplies no missing upper.

## Strict admission contract

An explicit raw allocation is admitted from its requested aligned byte size,
including its declared header. Each actual initialization, read, copy, NUL and
field/owner write is admitted separately. Requested capacity is distinct from
allocator metadata and usable-size excess, which the existing construction
already excludes from its peak claim. Disposal and reuse refund nothing.

A runtime constructor needs more evidence: maximum requested backing sizes,
maximum intermediate writes, all possible owners and cleanup, and a bound on
the performed local/ownership operations for the actual compiler and runtime
paths it calls. Payload length, minimumCapacity, a value-witness stride and a
capacity observed after allocation each prove a different fact. None alone is
this certificate. Unknown or unsupported evidence refuses before the constructor.
This refusal is a failed job, with no convenient alternate label or sample prefix.

A complete runtime-specific certificate would identify the provider and framework
images, compilation options and emitted ownership paths, system Swift/Objective-C
runtime and Foundation/AppKit implementations, relevant allocator request paths,
and their correspondence to the source used for the upper. Both inlined client
code and dynamically called implementations matter. A compiler version or an OS
version string alone does not identify that combination. An empirical peak or
the size of an already-created object cannot fund the earlier invocation.

The installed development compiler is Apple Swift 6.4 targeting macOS 27. The
saved subject was observed on macOS 26.6.2. Neither establishes this certificate
for supported signed macOS VMs. Source review here performs no native experiment.

## Representation comparison

| Path | Capacity and ownership control | Remaining mandatory boundary | Cost |
| --- | --- | --- | --- |
| Retain runtime collections | Preserve existing walker and convenient Swift overlays; bind each actual constructor/growth/COW/bridge using a runtime-specific certificate | Swift source projections, String/Array/Dictionary publication and compiler/runtime ownership paths | Requires evidence for the exact deployed combinations; an unqualified combination must refuse |
| Explicit staging plus real publication adapter | Own raw blocks, typed records, buffers, vectors, lookup structures and dependencies; avoid implicit Swift overlays while staging | Conversion of staged facts into the existing ProviderValue tree still constructs Swift values | Concentrates requested-capacity policy, but adds a discovery-only adapter and does not remove public runtime work |
| Explicit staging with a scoped accounting contract, proposed | Same raw receipts; separately identify public runtime and platform internals as excluded from the numeric gate | Existing ProviderValue publication remains real provider-owned work with an unbounded implementation footprint | Preserves the public API and support direction, but weakens the selected all-owned certificate and needs a human decision |

Explicit staging is the recommended internal representation if the third choice
is selected. It gives one owner to capacity/growth/lifetime policy. Callers supply
source observations and receive one frozen value tree; they do not reconstruct
arena or bridge protocols. Retaining collections is the smallest migration but
does not solve the strict admission requirement. Replacing ProviderValue with a
raw-tree ABI could expose controlled storage to the host, but would require a
separate framework/host compatibility design and still would not control all
system/compiler internals. No such ABI change is proposed for adoption here.

## Explicit staging candidate

This describes executable source-level operations, not a certificate for their
compiled implementation. It preserves the source and reader semantics in the
[source/root contract](application-metadata-source-root.md) and the selected
[owned-storage representation](../verification/application-metadata-owned-storage.md).

### Raw records and capacities

Use contiguous explicitly allocated bytes, with fixed unsigned 64-bit fields
and owner-relative spans. Alignment is 16; a headed block with payload P requests
`16 * ceil((32 + P) / 16)` bytes. Its four header fields occupy 32 bytes.
Header population costs 32 further written bytes. Raw scratch requests
`16 * ceil(P / 16)`; its separate owner record remains charged.

Use the existing 24-byte span, 32-byte owner, 64-byte source slot, 112-byte copy,
40-byte locale/plan, 48-byte seed, 40-byte ordered-domain, 96-byte walker,
64-byte cycle/diagnostic/summary records. These are byte-format declarations;
they do not stand for Swift struct or enum stride. Additional state or output
fields require their own declared cells and writes. Verify actual offsets,
alignment and bounds at the raw adapter's enabling point before using a format.

Each primitive has explicit operations: allocate requested bytes; populate a
listed range; copy a specified initialized range; update named 8-byte cells;
compare specified byte ranges; move a disposal credit; retire in dependency
order. Reserve every operation and possible disposer before starting. A nil
allocation writes no payload and retains the old owner; a failed later operation
keeps every performed prefix charge and cleans up all already-acquired owners.
Do not infer that failure returned nil before doing work inside a runtime call.

### Sources, reader and walker

Keep native results in their actual opaque owners; access borrowed children by
the native fixed getters while those owners live. A Swift array overlay is not
an opaque native result. Replacing it requires a real native-object access
adapter, preserving the same frozen source snapshot, errors and call ordering.
If that access cannot be obtained without the overlay, it remains a runtime
boundary, rather than being relabelled or counted as a packed pointer vector.

Convert checked native strings losslessly into the existing bounded raw scratch,
then into retained span blocks. Charge both writes, every rejected conversion
prefix, owner population and explicit native retain/release/pool operations.
Keep every raw slot, type-tree member, preference, regional/duplicate selector
return and LocProvenance inspection before deduplication. Direct and table
inventories retain their separate native owners and selection plans.

Known-count pointer vectors request headed 8N payload bytes and populate 8N
bytes. Growing record vectors use capacities 1, 2, 4, ...; admit the new block,
32-byte header, used-prefix copy and pointer/capacity/length owner updates before
growth. Old and new allocations overlap until copying and owner transfer end;
failed growth retains the original. Lookup structures need explicit bucket,
key-span, probe/comparison, insertion and rehash operations. Their full job costs
depend on the actual dimensions; a nominal map entry is not their cost. The
current independent-key construction is retained rather than assuming cheaper
arena packing or sorted insertion. No fit is claimed for these replacements.

The discovery walker operates on byte spans and explicitly allocated component,
C-name, link input/text, suffix, pending, stack, expansion, cycle and resolved
buffers. It preserves the original 32-link/cycle/dot/error semantics and the two
independent identity observations. Write a component plus NUL directly into its
admitted C buffer; a raw view does not manufacture the current map-and-concatenate
Swift arrays. Zeroing a readlink input and copying its returned prefix are two
charged writes. Collapse slashes, join paths and retain expansions with exact
prefix writes and span/owner updates. A disposal-credit transfer writes state
without duplicating or refunding the close. No action walker is changed here.

Two immutable 128 KiB inputs, EOF storage and conversion scratch retain the
270,368-byte raw partition once per serial job. Their owner records, listing,
parser/selector borrowers, retained staging and walker/output allocations are
additional overlapping owners. Retire name borrowers/parser/data before reuse;
retire metadata and the first held root before the second walk. Cancellation,
deadline and lifecycle loss freeze optional work but hold inputs, possible
outputs, disposal credits and the shared slot until actual return.

### Real ProviderValue adapter

For each successful checked copy, materialize each selected staged path/name/
identifier as a Swift String, construct its nullable scalar/enum/bool fields,
populate its object Dictionary, append the object to the list Array, then
construct the complete catalogue object including summaries, diagnostics and
permission data. Final refused facts retain their selected null/unknown behavior.
Failure output and error construction have the same runtime requirement.

Freeze the completed tree before returning success. Raw storage stays alive
through the last conversion borrower; it can retire after the public tree owns
all values. The raw spans cannot be passed as String/Array/Dictionary values.
Sharing a Swift value may avoid a payload copy but still requires ownership and
value writes; it is not raw-buffer adoption. The strict contract refuses this
adapter unless all these constructors and failed prefixes have valid pre-call
runtime uppers. Publishing nothing on refusal is the only currently established
strict outcome; it does not meet useful-population acceptance.

Host conversion remains separate actual work: the host retains object values,
builds another list array, and traverses object values for depth validation.
GraphQL completion materializes selected aliases and errors, then encodes a
complete body before applying the independent 8 MiB guard. The provider does not
pay host work by moving its own adapter there. The response guard establishes
sent-body size and pays no earlier allocation; complete selections remain intact.

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

## Concrete decision awaiting Antony

Recommended alternative: explicitly scope the existing 20,971,520 cumulative
gross gate to **application-controlled raw requested allocations and every
performed source-level raw initialization/input/copy/field/owner write**. Preserve
the no-refund rule. Keep the 4,194,304 attempt gate for explicit adapter/local/
native invocations and their explicit cleanup/retains/releases/comparisons.
Compiler-generated ownership traffic and internal platform/Swift constructor,
bridge/COW, metadata and allocator work are outside those numeric guarantees.
ProviderValue publication stays provider-owned; its runtime backing is explicitly
excluded from the gate, not reclassified as host work or certified by wire size.

This is a materially weaker accounting guarantee and is **not selected**. It
keeps the binary/public interface, existing file/source/category/locale policy,
three/five-second deadlines, four true-return slots, independent response cap,
authority, disclosure and action compatibility. It does not promise total
provider memory, cumulative hidden copies, runtime attempts, RSS or native peaks.
Useful fit of the explicit work must still be derived from all saved rows and
conditional native inputs; 20 MiB is not declared sufficient by this proposal.

Alternative: retain the complete strict guarantee and require implementation-
specific source/image/toolchain correspondence and full pre-call uppers before
admitting each runtime combination. Unqualified combinations refuse useful
discovery. That adds an explicit qualification/support condition; current evidence
does not supply a viable certificate. If Antony chooses it, the next design must
establish a concrete attainable correspondence before adding more sizing leaves.
Changing framework representation would be another explicit human choice, not
an implicit consequence of selecting strict accounting.

The requirements decision must select or reject this precise boundary, including
its ownership/attempt exclusions, rather than re-ask the agreed file cap, formats,
locale breadth, oversize outcomes or seams. No larger budget, new quota, helper,
posture change or useful-category loss is adopted here. After a selection, one
design continuation reconciles the selected boundary and performs the unchanged
whole-parent close checks; it must not commission another identical gap model.

## Test seams and retained obligations

The existing public GraphQL, actual provider/host binary and isolated signed
supported macOS VM seams remain the human-confirmed seams. Pure controls reject
using numeric ABI layout, minimum capacity or post-call capacity as pre-call
allocation evidence; preserve initialization/owner/growth/partial-failure and
cleanup credits; and retain inherited call/branch/unknown/alias/escaping plus
original oversize/baseline/omitted-table controls. Frozen composition reproduces
every ordered row in both 2,043-episode runs, all 149 outside records and the two
system seed groups. Actual native dimensions, final values and errors stay
conditional; independent wire selection is unchanged. All G/N/V remain pending.

The family consumption hold remains. No complete job sum or useful fit is earned;
the next live work is the concrete human accounting decision, followed by its
selected design and eventual whole-family reconciliation and mandatory review.
