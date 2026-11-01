# Settings owner records and collection recovery

## Contract and scope

This is the proposed `settings-owner-records/1` format for the [Settings command
owner](settings-keepalive-owner.md). It supplies the bounded records and
recovery rules required by that design. The owner contract remains authoritative
for scheduling, eligibility, process ownership and collection order. The
[producer contract](settings-capture-resource-contract.md) owns dependency units
and approved test substitutions. Neither a parseable record nor this proposal
establishes an implemented or qualified mechanism.

The design uses immutable records in a predeclared terminal pool. Each writer
has a disjoint range of slots. A successor abandons the preceding writer's
remaining range, even when a slot appears empty. Separately, an allocation fence
bounds the command ordinals that writer can consume. A collection successor
burns uncertain ordinals and never resumes the scenario.

The [storage
view](../design/architecture/settings-activation/keepalive-storage.mmd) and
[record view](../design/architecture/settings-activation/keepalive-records.mmd)
show those two sequences. Graphs start at the dark **Start here** node. They are
explanations, not proofs of storage behaviour or model-checking results.

All quantities below are format sizes or symbolic workload parameters. They are
not selected useful resource limits. The qualification proposal's eight-ordinal
fence and 4096-byte record remain study choices. The full profile, mechanism
evidence and independent whole-design review remain prerequisites to adoption.
No native experiment or dependency implementation is authorised here.

## Encoding and identity

All integer encodings are unsigned, big-endian and checked before addition,
multiplication, offset calculation or conversion. Signed values use a signed
64-bit two's-complement payload only where explicitly specified. No length is an
allocation instruction until it is checked against both the remaining frame and
the immutable profile. A zero bound means zero permitted units, never infinity.

The wire/storage version is major 1, minor 0. Reject any other version, unknown
kind or unknown code. Reject nonzero reserved bits, excess fields, repeated
fields, wrong field order, wrong lengths or trailing bytes within a frame. There
is no optional field omission. Schema changes, including a code or unit-set
change, need a new version and an exact profile binding. Do not guess
compatibility.

| Atom | Bytes | Encoding and meaning |
|---|---:|---|
| `I` | 16 | Opaque nonzero 128-bit identity. Chosen once at creation, checked for collision within the run. It is not a PID, path or authorisation capability. |
| `K` | 24 | Tagged identity: state byte, seven zero bytes, then `I` bytes. Known is nonzero. Missing retains the expected identity. Unknown/inapplicable payload is zero. Uses the four `Q` states. |
| `U` | 8 | Required finite count, index, ordinal or length. Zero is a real value. Ordinals and slot indices start at 1. |
| `C` | 4 | Two unsigned 16-bit words: namespace and value. Each field has a closed enum, as specified below or in its pinned profile registry. |
| `Q` | 16 | State byte, seven zero bytes, then unsigned value. States 0 known, 1 missing, 2 unknown, 3 inapplicable. Non-known payload is zero. Signed status quantities use the same layout with signed payload. |
| `T` | 32 | `Q` nanoseconds followed by `I` clock identity. Continuous times use the pinned host boot/API identity. Presentation wall time uses its separately declared clock identity and signed value. Non-known times retain the relevant clock ID. |
| `H` | 32 | SHA-256 digest bytes. A digest field is required and known. Use a tagged reference when the digest is unavailable. No textual hex in the frame. |
| `R` | 72 | State byte. Storage-class byte. Expected-kind unsigned 16-bit word. Four zero bytes. Object `I`. Index `U`. Length `U`. Digest `H`. States are the same four as `Q`. For known references all fields are checked. Non-known references have zero length/digest. A missing reference retains its expected object/index/type. Unknown or inapplicable uses zero object/index. |
| `V(X,n)` | `4 + n * size(X)` | Unsigned 32-bit count followed by exactly that many fixed-size entries. Count is at most the field's profile maximum `n`. No nested unbounded vector. |

Known zero differs from missing, unknown and inapplicable. Missing means that a
required named observation or object was not published. Unknown means that its
identity or fact cannot be established. Inapplicable means that the protocol
does not require it on this branch.

Known empty bytes have length zero and the digest of empty bytes. A missing
record never becomes a known empty record. A whole frame that is absent or torn
is not a frame with unknown fields.

All original commands, argv bytes, predicates, environment values, channel
frames, paths, VM selectors and raw text live in bounded private objects.
Records contain references, not excerpts. Object names are derived from opaque
identities, not their secret contents. Public diagnostics contain only
kind/reason codes and opaque IDs.

No private-root path or environment dump. References and pool inventories are
themselves private. A digest is an integrity check, not authentication,
confidentiality or evidence of execution.

For private byte objects the format is exact length plus exact original bytes,
without normalisation, trimming or truncation. A vector of original argv or
environment entries uses a 32-bit entry count, then a 64-bit byte length and the
original bytes for each entry. Environment entries separately encode name and
value, or an explicit absence code. The profile bounds count, each length and
aggregate bytes before receipt.

An oversized or malformed producer message closes that channel and eligibility.
Retain all bytes already accepted within its charged receive buffer, including a
partial frame, and mark the unread tail unknown. Do not drain an unbounded
remainder or claim to have retained bytes that never entered the owner. The
profile must cover normal valid messages in full.

An object reference resolves only within the root's immutable object map. The
map defines class, owning attempt or setup role, permitted maximum length and
derived location. A reference to a terminal record includes its global slot
index. An ordinary/collection object uses its object index.

The reader checks root, type, exact identity, actual length and digest before
treating the join as known. Expected-kind values 65534 and 65535 identify a
retained raw prefix and native raw object respectively. They never satisfy a
complete-record join. This permits a checksum of real partial bytes without
inventing a valid record.

There is no fallback pathname search. Forward references are permitted only as
missing expectations in a declaration. A known evidence reference must name
already completed bytes. A later record can report newly observed evidence but
cannot supply a missing earlier publication.

### Reference types and profile identity

The expected-kind word has disjoint domains. `K1` through `K29` below mean
record kinds 1 through 29, encoded as those integers. `O1` through `O12` mean
wrapped object types 1 through 12, encoded as `256 + object-type`. `PFX` means
65534, a retained raw prefix.

`RAW` means 65535, a native raw object. Reject every other expected-kind value.
Storage class and expected kind are separate checks. Backend kinds 14 and 15 use
their assigned ordinary or collection object index, rather than a terminal slot.

Each reference stores one exact expected kind. A union below permits only its
named members, never a wildcard. The immutable role definition selects the
member for each branch before receipt. The reader checks that branch, the
target's wrapper or record kind, and the reference's exact kind.

Missing references keep that expected kind. Unknown and inapplicable references
still use the field's declared kind or branch member. Their zero object/index
payload does not authorise a different type.

`Evidence` below is the closed union of `K1`–`K29`, `O1`–`O12`, `PFX` and `RAW`.
Only generic observation fields use this union. Their role or target identity
determines one exact member before checking bytes. A prefix never satisfies a
complete-record join. A failed publication can instead carry a missing reference
to the expected complete kind. The available prefix has its own `PFX` reference
in the failure or extent observation.

| Frame or bundle field | Permitted expected kind |
|---|---|
| Common `previous`, `causal` | Terminal `K1`–`K29`, excluding backend `K14` and `K15`. Backend `previous` permits `K14` or `K15`, and backend `causal` is `K9`. |
| `P.creation-evidence` | `O1`, the exact original creation observation. |
| `B.evidence` | `Evidence`, fixed by the unit, phase and enforcement evidence role. |
| `E.retained-content` | The mapped object's exact complete kind, or `PFX` for its real retained prefix. |
| `J.evidence` | The exact kind required by `J.required-kind` in its pinned registry. |
| `F.target` | The schedule's exact target kind, or `PFX` for a partial target. A missing target retains its complete expected kind. |

The following table covers every direct catalogue `R` field and `V(R,...)`
element. Bundle references retain the rules above wherever a bundle occurs.

| Record kind | Reference field to expected kind |
|---|---|
| 1 | `private-VM-binding`: `O1`. `original-lock-binding`: `O3`. `backing-map`: `O6`. `profile`, `pool-layout`: `O4`. `caller-binding`: `O1`. `clock-registry`: `O5`. |
| 2 | `original-profile`: `O1`. `registry-bindings`: `O5`. |
| 3 | `physical-layout`: `O6`. `bootstrap-manifest`: `O4`. |
| 4 | Only bundle references. |
| 5 | Owner `predecessor-handoff`: final setup `K4`. Collection `predecessor-handoff` and `recovery`: `K25`. Owner `recovery`: inapplicable `K25`. |
| 6 | `prior-fence`: `K6`. `backing-map`: `O6`. Its `F.target` follows the publication-carrier schedule. |
| 7 | `fence`: `K6`. `exact-request`, `cost-profile`: `O1`. Its `F.target`: `K6`. |
| 8 | `original-frame`, `operation-definition`, `cost-profile`: `O1`. `holder`: `K11`. `stop`: `K21`. |
| 9 | `assignment`: `K7`. `directory-observation`: `O3`. `exact-request`, `predicate`, `transport`: `O1`. `eligibility`: admitted `K8` or failure `K10`. `stop`: `K21`. Its `F.target`: `K7`. |
| 10 | `original-frame`: `O1` or `PFX`. `failed-subject`: `Evidence`. `prior-backend-latch`: `O1`. |
| 11 | `commitment`: `K9`. `channel-binding`: `O3`. `descriptor-inventory`: `O6`. |
| 12 | `original-frame`: `O1`. `creation`: `K11`. `preceding-completion`: send subtype `K19`. |
| 13 | `commitment`: `K9`. `original-frame`, `selector-comparison`: `O1`. `environment`: `O2`. `descriptor-inventory`: `O6`. |
| 14 | `commitment`: `K9`. `dependency-request`, `predicate`: `O1`. `exact-argv`, `environment`: `O2`. |
| 15 | `request`: `K14`. `producer-observation`, `validation`: `O1`. `stdout`, `stderr`: `RAW`. `payload`: `O1` or `RAW`, fixed by the output role. |
| 16 | `backend-result`: result subtype `K15`. `payload`: the exact kind and identity from that result. |
| 17 | `original-ack`: `O1`. `payload`: the exact kind and identity from its offer. `backend-result`: result subtype `K15`. |
| 18 | `commitment`: `K9`. `launch`, `backend-reap`: `K11`. `backend-result`: result subtype `K15`. `acknowledgement`: `K17`. `first-failure`: `K10`. |
| 19 | `terminal`: `K18`. `original-frame`: `O1`. |
| 20 | `first-failure`: `K10`. Its `F.target` follows the publication-carrier schedule. |
| 21 | `scenario-end`: `O1`. `final-scenario-result`: `K18`. `first-failure`: `K10`. `worker-phase`: `K12`. `pending`: `K8`. |
| 22 | `original-ack`: `O1`. `last-tick`: `K8`. `disposition`: `K18` for an assigned tick or cancelled-unstarted `K8`. |
| 23 | `acknowledgement`: `K22`. `tick-resolution`: `K18` or cancelled-unstarted `K8`, matching the stop acknowledgement. |
| 24 | `first-failure`: `K10`. `ownership`: `O7`. |
| 25 | `original-lock-observation`, `backing-check`: `O7` attachments, as specified under transfer order. `last-fence`: `K6`. `known-assignments`: `K7`. `first-failure`: `K10`. |
| 26 | `first-failure`: `K10`. `final-worker`: `K23`. `final-attempt`, `exact-stop`, `independent-inventory`: `K18`. `event-range-summary`, `holder-summary`, `collection-results`: `O7`. `required-collection-order`: `O9`. |
| 27 | `handoff`: `K26`. `original-response`: `O1`. |
| 28 | `owner-exit`: `K27`. `recovery`: `K25`. `first-failure`: `K10`. `collection-results`: `O7`. `exact-stop`, `independent-inventory`: `K18`. |
| 29 | `failed-slot`: `PFX`, or a missing reference to its intended terminal record kind. `first-failure`: `K10`. |

| Object type | Reference field to expected kind |
|---|---|
| 1, 2 | No references. |
| 3 | `original-path`, `opened-identity-evidence`: `O1`. |
| 4 | `profile-fragments`: `O1`. `registries`, `clocks`: `O5`. `backings`, `lock`: `O3`. `collection-plan`: `O9`. `object-layout`: `O6`. `tail-tables`: `O8`. |
| 5 | `definitions`: `O1`. |
| 6 | `descriptor-bindings`: `O10`. Object extents follow the `E` rule. |
| 7 | Join entries follow the `J` rule. |
| 8 | `states`: `O11`. |
| 9 | `items`: `O12`. |
| 10 | `object`: `O3`, binding the exact opened object behind that descriptor. |
| 11 | Resource cells follow the `B` rule. |
| 12 | `operation-definition`, `exact-target`, `cost-profile`: `O1`. `prerequisites`: `O7`, declaring required joins rather than future successes. |

The pool's `physical-layout` is a type-6 object dedicated to terminal slots. Its
ordered extent vector has one entry per slot, in ascending global slot order.
Vector position is the slot index. Type 4's disjoint ranges determine each
slot's lane and permitted parity.

Descriptor bindings retain each slot's opened identity through object types 10 and 3. The separate type-6 `object-layout` covers bootstrap objects, attachments and
descriptor bindings. Both layouts have finite profile bounds. Future content
references remain missing or inapplicable, without future digests.

The frozen profile digest is SHA-256 over the complete canonical type-4
bootstrap/profile object bytes. The preimage includes its 16-byte prefix,
eight-byte payload length, complete payload and final 32-byte object digest. It
contains no path spelling, textual digest or record frame. Root `profile` and
`pool-layout`, and pool `bootstrap-manifest`, all identify that same object and
complete-byte digest.

Type-4 fragment references name original type-1 content objects. They never name
kind-2 frames. Every common frame binds this digest, including kind 2. Prepared
layouts cannot contain known references to any frame carrying this digest, or to
their own enclosing manifest.

These exclusions preserve the existing acyclic bootstrap rule.

### Common frame

Every record has **384 bytes of framing** plus its kind's payload:

| Ordered field | Bytes |
|---|---:|
| ASCII magic `KORREC01`. Major. Minor. Kind. Flags (each of the last four is 16-bit, flags zero) | 16 |
| Root, generation, writer and pool IDs (`4I`) | 64 |
| Physical slot/object index and event sequence (`2U`) | 16 |
| Frozen profile digest (`H`) | 32 |
| Previous complete record and causal record (`2R`) | 144 |
| Writer observation and presentation wall time (`2T`) | 64 |
| Payload length (`U`) | 8 |
| Frame digest (`H`) | 32 |
| Payload, then ASCII end marker `KOREND01` | payload + 8 |

The digest covers the complete header, payload and end marker, with its own
32-byte field zeroed. Padding outside the declared frame is not record content.
The frame is accepted only after exact length, marker, checksum, field and
reference checks. Bytes after the frame through the end of its fixed slot must
still be zero.

Extra nonzero content is invalid, not a second record. Neither a checksum nor a
successful read proves a successful prior flush. A record cannot attest to its
own later flush, return or exit. The next dependent record retains that
publication observation.

Final publication uses the existing caller-return trust boundary, without
another recursive logger.

Terminal event sequence equals global terminal slot index. Gaps are allowed and
retained as gaps. It is not a count of successful publications. `previous` names
the preceding complete terminal event known to that writer, while `causal` names
the event that caused this one.

A failure can therefore follow a damaged slot while its predecessor still points
to the preceding complete event. Missing joins prevent acceptance even if this
shorter chain passes its checks. At lane transfer, the first event references
the prior lane's last checked event. The transfer-order rules locate the range
disposition without a forward or self-reference. Backend frames use an
operation-local monotonically increasing sequence and exact commitment
reference.

They do not allocate terminal event numbers or command ordinals.

For clean acceptance, consecutive records in one lane must use the first
permitted slot after their predecessor. Only the next kind's required parity
skip is allowed. Larger unexplained gaps are unavailable. A declared
irreversible lane closure can leave an unused suffix.

Its handoff/range summary records that suffix. A shorter checksum chain alone
cannot hide a consumed non-fence slot. Recovery range burning never establishes
clean acceptance.

### Fixed bundles and registries

These bundles make the catalogue below a complete size calculation. Fields are
ordered as listed. A bundle cannot contain an arbitrary dictionary.

| Bundle | Size | Ordered fields |
|---|---:|---|
| `P`, process observation | 232 | Token `I` and parent token `K`. Role and observed relationship `2C`. PID, parent PID, process group and session `4Q`. Boot `I`. Incarnation/start observation `T`. Creation evidence `R`. |
| `S`, status | 64 | Status domain `C`. Raw wait representation, exit code and signal `3Q`. Outcome `C`. Source event/object index `U`. A raw wait value is signed. Exit/signal cannot both be known for the same terminal observation. |
| `D`, deadline | 104 | Phase and observer `2C`. Origin, absolute deadline and observed check `3T`. |
| `B`, resource cell | 168 | Unit, phase, enforcer and check outcome `4C`. Declared limit, requested quantity, observed quantity, irrevocable charge and remaining capacity `5Q`. Evidence `R`. |
| `E`, object extent | 184 | Object, backing and directory `3I`. Role and class `2C`. Maximum bytes `U`. Observed length, allocated bytes and metadata contribution `3Q`. Exact retained content/prefix `R`. |
| `J`, missing or required join | 80 | Required kind and reason `2C`. Evidence or expected evidence `R`. |
| `A`, slot range | 24 | First, count and maximum frame bytes `3U`. |
| `F`, publication observation | 176 | Target `R`. Requested-write, write-result, requested-flush, flush-result, namespace-result and visibility-result `6C`. Requested bytes and observed written bytes `2Q`. Observation time `T`. Raw I/O status `Q`. |

Core code namespaces are closed. They have these values:

- Storage class: terminal, ordinary, collection
- Outcome: clean, state-failed, unavailable, interrupted, cancelled-unstarted,
  refused, not-started, started, unknown
- Fact/check: not-requested, success, failure, unknown, inapplicable
- Relationship: direct-child, reported-owned, unestablished
- Role: caller, owner, worker, sleep, backend, intermediary,
  producer, collector, validator, helper
- Input state: clear, possibly-held, unknown
- Recovery mode: normal-handoff, failed-owner, refusal
- Reason: protocol, identity, capacity, deadline, I/O, process, channel,
  validation, signal, normal-end, predecessor, frontier, missing-evidence.

Each list assigns consecutive values starting at 1 in its listed order.
Namespaces are assigned in that same order starting at 1. Unknown is a fact, not
a wildcard code. No arbitrary error text goes in `C`.

Field-local subtypes use namespace `100 + kind`, with listed values numbered
from 1. Kind 5's mode is owner or collection-only. Kind 12's phase uses the
worker-phase table. Kind 26's eligibility uses its listed three values. Registry
namespaces start at 1000 in the order named below. Status-domain codes are
shell, POSIX-wait, local-evaluator, dependency, channel and I/O, in namespace 9.

Operation, phase, unit, transport, predicate, environment and object-role codes
are indexes into finite registries frozen in the profile. Each registry row has
its numeric ID, semantic version, exact private definition reference and maximum
representation. The profile records the exact registry length and digest. No
runtime registration is allowed.

The producer's unit schema is independently versioned and pinned. This format
cannot invent its still-missing definitions. Status domains declare how to
interpret the raw signed value, including shell, POSIX wait, local evaluator and
dependency status. A shell 130 and signal 2 remain separate reported facts.

Field-specific enum restrictions are part of each row's semantics. Inapplicable
does not excuse a required fact.

## Record catalogue

Kind numbers are the first column. Each payload is the listed concatenation.
Maximum encoded size is **384 plus the sum of its listed field sizes**,
including every four-byte vector count. All vector maxima are finite profile
inputs below.

This formula applies to failed rows too. Partial writes consume the whole
assigned slot/allowance, never merely the visible prefix. `R` names an original
object or record. It does not duplicate that payload.

### Setup, allocation and submissions

| Kind | Payload in encoding order | Meaning and maximum multiplicity |
|---|---|---|
| 1 Root declaration | `I run, I exact-VM, R private-VM-binding, R original-lock-binding, R backing-map, R profile, R pool-layout, R caller-binding, R clock-registry` | One caller setup record. Private bindings retain actual opened filesystem identity and exact VM identity. Tokens alone are insufficient. |
| 2 Profile fragment | `U part, U parts, R original-profile, V(B,u) units, V(R,r) registry-bindings` | `p` parts, predeclared. Their ordered digest/length list is bound by the root. Includes workload, count/size/metadata and enforcement evidence, not only limit numbers. |
| 3 Pool declaration | `I pool, U slot-size, U slots, V(A,5) lanes, R physical-layout, R bootstrap-manifest` | One. Layout defines bootstrap, owner-history, owner-tail, successor and caller-final ranges in that order. |
| 4 Setup publication | `V(F,z) publications, V(E,o) setup-objects, V(J,j) missing` | Bounded setup batches `b`. Establishes observed preparation, not guaranteed future I/O. |
| 5 Generation open | `C mode, P writer, R predecessor-handoff, R recovery, V(A,2) assigned-ranges, V(J,j) missing` | Once for the owner. At most once for the collection successor. Neither ordinary admission nor generation reuse follows from parsing it. |
| 6 Allocation fence | `R prior-fence, U lower, U upper, I generation, R backing-map, C class, Q collection-item, Q retired-unused-lower, F prior-publication` | `f` ordinary fences and at most `f_c` collection fences. Each inclusive finite range is contiguous with its established predecessor frontier. A collection fence binds exactly one plan item and one ordinal. |
| 7 Assignment/storage binding | `I submission, U ordinal, R fence, C class, I backing, I directory, I operation-token, R exact-request, R cost-profile, V(B,u) charge, F fence-publication` | Once per assigned attempt, even if later publication fails. The in-memory assignment/charge precedes this write. |
| 8 Submission observation | `C received-admitted-refused-cancelled, I sender, I submission, U producer-sequence, R original-frame, R operation-definition, R cost-profile, R holder, R stop, T producer-origin, T receive, D admission, V(B,u) check, V(J,j) missing` | At most four rows per bounded submission `n`. Received then admitted or refused, and at most one unstarted cancellation. All are ordinal-free. The subtype is a field-local closed enum in listed order. |
| 9 Dispatch commitment | `I submission, U ordinal, R assignment, R directory-observation, R exact-request, R predicate, R transport, R eligibility, R stop, V(D,d) deadlines, V(B,u) charge, F binding-publication` | At most one per assignment `a`. The charge is the same immutable charge, not another debit. Installed-limit observations are inapplicable here. |
| 10 First failure/control | `C reason, C phase, I sender, R original-frame, R failed-subject, R prior-backend-latch, S status, D deadline, C input-state, V(J,j) missing` | At most `q` rows, including the first failure and all later distinct controls. First-failure identity never changes. Repeated identical observations update no file and emit no new event. |

Root/profile/layout use a bootstrap manifest prepared before owner creation. The
caller retains the original lock while recording the observed owner creation in
a setup attachment. The created owner waits for this startup handoff without
writing. Only after complete bootstrap and exclusive transfer of the original
writer domain can it publish generation opening/readiness.

Parent loss during this handoff is failed startup, never authority to restore or
reopen bootstrap. Its canonical content contains root/pool IDs, fixed slot
ranges, profile fragment content hashes and object layout. To avoid a digest
cycle, it excludes digests of frames that reference this manifest. Fragment
frames reference that content digest.

Root and pool records reference already prepared content objects. Profile
fragment references in the manifest name content objects, never the frames that
wrap them. Prepared object layouts contain missing/inapplicable content
references for future bytes, not future digests or self-references. These setup
objects, their complete bytes, prefixes and metadata are charged to terminal
setup capacity.

Incomplete bootstrap prohibits owner readiness and any attempt allocation. It is
retained, never reinitialised in place.

### Referenced private objects

The following object shapes close the indirection in the catalogue. Each object
has a 16-byte prefix, an eight-byte payload length, its payload and a 32-byte
digest over prefix/length/payload. The total is **56 bytes plus payload**. The
prefix contains eight-byte ASCII magic `KOROBJ01`, 16-bit major and minor,
16-bit object type and 16 zero bits. Original raw byte streams and images are
exceptions: preserve their native bytes exactly and retain length/digest in the
referencing observation. A partial object is a real retained prefix, never a
valid wrapper claiming a complete original.

| Object type | Ordered payload and maximum size method |
|---|---|
| 1 Exact bytes | `U length` and at most `x` original bytes. Total at most `64+x`. Used for commands, paths, VM selector, predicates, original channel frames and diagnostic originals. Length and `x` are byte counts, not characters. |
| 2 Argument/environment vector | 32-bit entry count, followed by at most `x_count` length-prefixed original entries as defined below. Count/absence/name/value headers plus the profile's aggregate `x_bytes` are all charged. No recursive values or conversion to normalised text. |
| 3 Filesystem/lock binding | `I logical, C role, Q device, Q inode, Q incarnation, I volume, I mount, R original-path, R opened-identity-evidence, S observation`. Logical identity is not authority without matching opened evidence. Platform-specific original evidence is a bounded type-1 object. |
| 4 Bootstrap/profile layout | `I root, I pool, I run, U slot-size, V(A,5) lanes, V(R,r) profile-fragments, V(R,r) registries, V(R,3) backings, R lock, R clocks, R collection-plan, R object-layout, V(Q,m) parameters, V(R,r) tail-tables`. Parameter order is frozen as below. Variable lists have finite bootstrap maxima supplied before parsing. |
| 5 Registry | `C registry, U version, V(R,r) definitions`. Each definition is a type-1 exact byte object with a declared bounded versioned grammar supplied by that owning contract. No runtime extension or dependency-unit inference. |
| 6 Object/descriptor layout | `U count, V(E,o) objects, V(R,r) descriptor-bindings`. Each descriptor binding is a fixed tuple `I process-token, C role, Q descriptor-number, C access-mode, R object, C inheritance, C closure-phase`. Access is read/write/read-write and inheritance is keep/close. |
| 7 Required/observed join summary | `V(J,j) joins`. Used for holder, event-range, collection and missing-evidence summaries. A missing summarised object remains missing. The summary confers no success. |
| 8 Tail-state table | `U states, V(R,r) states`. Each state is a fixed tuple of profile state `C`, allowed transition `C`, predecessor state `C`, `V(B,u)` maximum next cost and `V(B,u)` remaining-tail cost. Counts cover the full finite state expansion. |
| 9 Ordered collection plan | `U count, V(R,r) items`. Each item is `U index, R operation-definition, R exact-target, R cost-profile, C applicability, V(R,r) prerequisites`. Applicability codes are always, failure-only, held-input, or declared-protocol-condition. The last references its exact predicate through operation-definition. |

Fixed tuple objects referenced by types 6, 8 and 9 use the same wrapper with
object types 10, 11 and 12 respectively. Type-10 access and inheritance use
namespaces 210 and 211. Type-12 applicability uses namespace 212, with values in
listed order. Profile state/transition/closure-phase meanings are pinned
registry definitions.

Redundant count fields must equal the vector count. A type-2 entry contains a
`C` argv/environment-present/environment-absent discriminator, then
length-prefixed bytes (one argv value. Name and value for present environment.
Name only for absent environment).

Its namespace is 202, values in listed order. No NUL terminators or character
normalisation are added.

The parameter vector in type 4 has this fixed order:

- `n,a,w,h,q,g,p,b,f,f_c,v,t`
- `u,r,z,o,j,d,m`
- Fence width, slot size and total slots
- Maximum object bytes and maximum original-frame bytes
- Maximum argv/environment entries and aggregate bytes
- Maximum receive/parser/scan live bytes
- Maximum depth and component bytes.

All are known finite `Q` values at startup. Missing/unknown is a refused
profile. Each distinct field may have a smaller bound through its registry
definition, never a larger implicit one. Type 4's `m` must accommodate this
fixed vector.

Large manifests use predeclared fragments with numbered parts, total parts and
exact reference lists. All fragment/object counts, bytes and metadata are
charged. Neither fragmentation nor references permit an unbounded chain or
cycle.

Terminal original-frame and summary objects are preassigned by `(pool, slot,
object-role, element-index)`. Their exact IDs, sizes and opened identities are
in the immutable object layout. Reserve their slots before writing their bytes.
Write each object once before its referring event.

<!-- tc: depart synonym-rotation because launch names process execution while start also names range and time origins -->
A crash burns
these attachments with their parent slot even if the event remains empty. Backend objects are assigned by `(operation-token, object-role, element-index)`
under the exact directory binding. The frozen role schema determines those
identities before launch. Both maps have finite checked domains and reject any
ID collision before writes.

No dynamic map entry or recursive binding record is needed.
Received/admitted/refused submission originals belong to terminal attachments,
because no attempt yet exists. Later records reference them without copying. A
digest of an unavailable original is never invented.

### Processes, results and delivery

<!-- tc: depart synonym-rotation because launch names process execution while start also names range and time origins -->
| Kind | Payload in encoding order | Meaning and maximum multiplicity |
|---|---|---|
| 11 Process/holder observation | `P process, R commitment, R channel-binding, R descriptor-inventory, C creation-exit-holder, S status, T sender, T receive, V(J,j) missing` | Bound `h` includes each created child, inherited descriptor owner, exit and holder-resolution observation. Subtype is a field-local enum in listed order. A reported grandchild exit is not caller reap. |
| 12 Worker readiness/phase | `I worker, U sequence, C phase, K sleep-or-tick, Q tick-sequence, Q sleep-sequence, R original-frame, R creation, R preceding-completion, T sender, T receive, T completion-receipt, S sleep-status, D deadline` | Bound `w` covers readiness and every permitted phase transition, including stop races. Phase uses the owner spec's seven phases in table order. No periodic heartbeat rows. |
| 13 Backend/launcher/collector progress | `U ordinal, R commitment, P reporter, R original-frame, C phase, T sender, T receive, D current, D next, S status, R environment, R selector-comparison, R descriptor-inventory, V(B,u) resources, V(E,o) extents, V(J,j) missing` | Bound `g` per attempt covers setup, raw binding, limit calls/readbacks, producer/collector/validator phases and failures. Actual creator and external execution are separate events. |
| 14 Backend request | `U ordinal, I operation-token, R commitment, R dependency-request, R exact-argv, R environment, R predicate, V(E,o) outputs, V(D,d) deadlines` | One child-owned frame per attempt in its assigned class. Contains no invented setup result. |
| 15 Backend validation/result | `U ordinal, R request, R producer-observation, R stdout, R stderr, R payload, R validation, S transport, S evaluator, S emission, V(E,o) extents, V(J,j) missing` | At most two frames per attempt: validation then result, distinguished by the validation/result field-local subtype prepended as `C`. An incomplete producer observation remains missing. |
| 16 Result offer | `I offer, I submission, U ordinal, R backend-result, R payload, D delivery, S send` | At most one per completed backend attempt. Records actual offer/send state. |
| 17 Payload acknowledgement | `I offer, I submission, U ordinal, R original-ack, R payload, R backend-result, T receipt, T owner-receive, S channel` | At most one per offer. Retains the exact ack before interpreting its match. |
| 18 Terminal disposition | `U ordinal, R commitment, R launch, R backend-result, R backend-reap, R acknowledgement, R first-failure, C outcome, V(S,4) statuses, V(B,u) settlement, V(E,o) extents, V(J,j) missing` | At most one per assigned attempt. A failed attempt can have missing commitment/backend. Settlement never refunds. |
| 19 Completion observation | `C send-echo, I submission, U ordinal, R terminal, R original-frame, T sender, T receipt, T owner-receive, D deadline, S channel` | At most two per terminal disposition. Subtype is a field-local enum in listed order. The send and later echo stay distinct. |
| 20 Publication observation | `F publication, R first-failure` | Bound `v`, derived from the publication-carrier schedule below. Mandatory clean-path observations and failed-path fallbacks both count. No observation of this observation is required. |

For kind 15 the prepended subtype makes the size unambiguously `384 + 4 + 8 +
6*72 + 3*64 + (4 + 184o) + (4 + 80j)`. Status, raw streams and producer
observation remain separate. Artifact and raw bytes are objects, not additional
free records. A private command/result JSON needed by an existing consumer is
another declared object in the attempt's charge. This schema does not make that
compatibility copy free.

### Stop, recovery and the caller

| Kind | Payload in encoding order | Meaning and maximum multiplicity |
|---|---|---|
| 21 Stop intent | `I stop, C reason, R scenario-end, R final-scenario-result, R first-failure, R worker-phase, V(R,2) pending, Q active-ordinal, D deadline, C input-state` | One owner stop intent. A later failure references it without issuing another normal stop or resetting its deadline. |
| 22 Worker stop acknowledgement | `I stop, I worker, R original-ack, R last-tick, R disposition, C phase, T sender, T receive, S status` | At most one matched ack. One malformed/duplicate channel event instead closes eligibility and consumes control capacity. |
| 23 Worker reap | `K stop, P worker, R acknowledgement, R tick-resolution, S wait, C lifecycle-outcome, V(J,j) missing` | At most one direct-child reap record. Unavailable is retained if observation is absent. |
| 24 Containment action/result | `R first-failure, P target, C action, T origin, T observation, D unchanged-window, S result, R ownership, C input-state, V(J,j) missing` | Bounded by `t` actual targets and their fixed TERM/KILL/observation protocol. Action enum: term, kill, wait, lock-acquire, disposition. Unknown targets receive no signal. |
| 25 Recovery/range disposition | `I failed-generation, I successor-generation, C mode, R original-lock-observation, R backing-check, R last-fence, Q safe-upper, V(A,2) burned-slot-ranges, Q burn-lower, Q burn-upper, V(R,r) known-assignments, V(J,j) uncertain, R first-failure, C input-state` | At most one caller range disposition, in the successor lane for failed recovery or the final lane for normal handoff. Ordinal burning is not a capture charge. Refusal is permitted only if the original terminal identity/lock and a valid unused successor lane are established. Otherwise no new record is possible. |
| 26 Owner handoff | `R first-failure, R final-worker, R final-attempt, R event-range-summary, R holder-summary, R required-collection-order, R collection-results, R exact-stop, R independent-inventory, C eligibility, C input-state, V(J,j) missing` | At most one. Eligibility enum: closed-clean-history, closed-failed, unknown. None permits another scenario command. Summaries are bounded objects, not substituted evidence. |
| 27 Caller owner-exit | `P owner, R handoff, R original-response, S response, S channel, S wait, T receipt, T wait-observation, V(J,j) missing` | At most one after the caller establishes exclusive original-lock ownership. Caller retains observations in its charged memory until then. |
| 28 Caller final outcome | `R owner-exit, R recovery, R first-failure, R collection-results, R exact-stop, R independent-inventory, C outcome, C input-state, V(J,j) missing` | One attempted final write. Caller return/exit after publication is explicitly unrecorded. |
| 29 Bounded write-failure summary | `R failed-slot, F write-observation, R first-failure, V(J,j) missing` | At most one per active writer role: bootstrap, owner, successor, caller-final. Its own failure causes no further log write. Existing bytes and unavailable tail are the outcome. |

Closed channel records retain the original failed or partial message in a
charged private object. Unknown senders cannot create unbounded refusal rows:
the first protocol violation closes that channel, then at most one closure
observation is retained. Signals are bounded per owned process by the fixed
containment policy. Later duplicate notifications do not cause new records.
Unknown descendants are one unresolved set, not an unbounded discovered-PID log
or signal target list.

## One-use pool and bounded costs

The pool contains precreated fixed-size terminal slot objects, their preassigned
attachments, immutable bootstrap objects and the original lock. Its private
layout maps each slot index to one opened object identity, maximum size and
permitted writer lane. Precreation, extent allocation and namespace metadata are
qualification obligations. A zero-filled slot is unused capacity, never a
record.

The implementation may not replace, truncate, rename over, clone or grow a slot.
It writes only the selected frame prefix into that slot once, with positional
writes bounded by its fixed size. A short write or error ends this attempted
publication. It is not continued or retried as a second frame.

The five ordered ranges are:

1. **Bootstrap**, caller preparation and owner-creation observation, before owner writing.
2. **Owner history**, ordinary clean event history before stop or first failure.
3. **Owner tail**, reserved failure, stop, complete original-owner collection,
   containment and handoff evidence, whether stop is normal or abnormal.
4. **Collection successor**, the original finite caller after failed owner
   resolution, with its own history and protected final portion.
5. **Caller final**, owner-exit and final outcome after either path.

Each slot belongs to one range forever. Within a range, its writer consumes
indexes strictly in order in memory. Each range starts at an odd index and has
an even length. Odd slots permit only allocation fences (kind 6).

Even slots permit every other allowed terminal kind. Bootstrap and final lanes
cannot publish fences. Select the next slot of the required kind, burning any
skipped slot. This makes a damaged non-fence slot distinguishable from a damaged
fence without trusting the damaged frame's header.

Mark the chosen index consumed **before any write call**. The first byte need
not reach disk for that slot to be consumed. Moving from history to tail
irreversibly closes history. A successful publication never releases a slot.

A write failure consumes its full slot and closes scenario eligibility. Any
later failure-handling record gets another allowed slot.

The slot's immutable layout entry is its assignment. There is no new assignment
record for each record write, and no allocation log that needs its own
allocator. Kind, generation, writer and slot in the attempted frame must match
that entry. The layout binds permitted roles.

Generation-open binds the actual owner token before its other writes. Bootstrap
preparation is never resumed after preparer loss. The original caller retains
its own role/token until its return. Another process cannot impersonate it by
reading the layout.

On a normal handoff the caller burns all unused owner and successor slots before
using its final lane. On failed owner handoff it burns **both complete owner
ranges**, retaining their existing bytes. This is a range disposition, not a
physical overwrite. It enters the successor lane at its predetermined first
index.

A caller already partway through that lane never restarts it. Caller death or
collection-successor loss ends recoverable work for this run. There is at most
one collection successor and no successor to the final caller. This follows the
finite caller trust boundary, and prevents endless recovery generations.

### Encoded and physical accounting

The [combined workload derivation](../verification/settings-activation/KEEPALIVE-ACCOUNTING.md)
applies this catalogue to start, scenario, ticks, collection and both caller paths.
It derives standalone carrier counts, lane costs and the coupled preparation/layout constraints.
It establishes `m >= 29` from the fixed parameter list, without selecting useful capacities.
Its scoped review precedes consumption. Exact manifests and qualified physical costs remain prerequisites.

Let `n` bound all valid received submissions, including due ticks and
collection. Let `a` bound all assigned attempts. Let `w` bound worker reports.
Let `h` bound process/holder observations.

Let `q` bound the first failure and all later distinct priority controls. Let
`g` bound progress events per attempt. Let `p,b,f,f_c,v,t` have the catalogue
meanings. All are finite whole-workload inputs, including failure branches.

Counts do not come from the number of successful captures. Distinguish `a` from
complete commitments.

For each kind `k`, let `L_k` be its catalogue maximum. For example:

- Kind 6: `384 + 72 + 8 + 8 + 16 + 72 + 4 + 2*16 + 176 = 772` bytes.
- Kind 7: `384 + 16 + 8 + 72 + 4 + 3*16 + 2*72 + (4+168u) + 176 = 856 + 168u` bytes.
- Kind 8: `384 + 4 + 2*16 + 8 + 5*72 + 2*32 + 104 + (4+168u) + (4+80j) = 964 + 168u + 80j` bytes.
- Kind 28: `384 + 6*72 + 2*4 + (4+80j) = 828 + 80j` bytes.

`S = max(L_k)` over permitted terminal kinds is the minimum logical slot size.
Rounding/allocation granularity can make the physical size larger. Backend kinds
14/15 use their attempt's separately bounded record objects. Select no numerical
`S` until all vector maxima are supplied. In particular 4096 is not a default.

A conservative catalogue count vector for kinds 1 through 29 is
`[1,p,1,b,2,f+f_c,a,4n,a,q,h,w,a*g,a,2a,a,a,a,2a,v,1,1,1,5t+3,1,1,1,1,4]`. Kinds
14/15 are charged to attempts, not the terminal pool. `t` counts distinct
target/window pairs across the owner and caller windows. The extra three kind-24
rows cover lock/disposition observations.

If the final implementation needs more observations or compatible objects,
expand the declared vector before startup. Do not silently exceed it.
Lane-specific path maxima must still place these rows in their actual
normal/failure/recovery paths and include all attachment bytes.

For each reachable complete path, count every attempted terminal publication by
kind, including the write that fails, kind 20 observations, setup and kind 29.
Reserve `N_lane >= 2 * max_path(sum attempted rows in that lane)` slots for each
lane, with an even length. This pays for at most one skipped parity slot per
attempted row, including fences and the final unused parity slot. Slots use the
same maximum size even though their permitted kinds differ.

For each slot `i`, let `A_i` count every attachment in its immutable layout. Let
`B_i` sum their maximum encoded byte lengths, including wrappers and prefixes.
These sums cover all preassigned roles and element indices for that slot. They
are not counts of attachments in a successful row or path. A parity-skipped,
failed or uncertain slot consumes its complete attachment set. No later slot can
reuse those objects or their capacity.

Let `B_boot` and `O_boot` be the bootstrap objects' maximum logical bytes and
object count. Each object appears once, either in bootstrap or in one slot's
attachment set. The lock and directory objects have separate physical charges
below. Define total terminal logical data bytes as:

`T_data = S * sum(N_lane) + sum_over_all_slots(B_i) + B_boot`.

The terminal data-object count is `sum(N_lane) + sum_over_all_slots(A_i) +
O_boot`. The sums include every reserved slot, including slots that no path
writes. Path enumeration determines lane lengths and which attachment roles each
slot must support. It cannot replace per-slot reservation with a per-row
attachment total.

Each object has one creation attempt and a fixed maximum. A failed prefix keeps
that full charge. An unreceived frame has no invented bytes.

For terminal physical capacity, add the lock, directory tree, metadata and
backing costs to data extents. Let `E_round` bound allocation-rounding slack
above `T_data` across every data object. Write the required capacity as:

`T_phys = T_data + E_round + M_lock + M_dirs + sum M_objects + M_updates +
M_backing`.

No `M` is assumed zero. APFS/image/host allocation and copy-on-write costs need
qualified upper bounds. Missing bounds keep startup unavailable. No checksum or
row-count calculation supplies them. Partial bootstrap has its own bounded
preparation allocation and no resize/retry under this run identity.

Ordinary and collection charges separately include each attempted directory and
request/validation/result object. They also include that attempt's original
control objects, artifacts, raw streams, retained prefixes and simultaneous
temporary objects. Terminal payload references do not move these bytes to
terminal storage. Collection directories are charged only to collection storage.
Terminal assignment and commitment rows are charged only to terminal storage.
Accounting cells repeat the same charge ID/reference for explanation and never
debit it a second time.

### Preserve the remaining tail

Before each transition, compute its worst permitted new record/object
contribution and the maximum remaining failure/stop/recovery/caller contribution
for every successor state. This is a finite path calculation over the declared
workload and protocol, not a runtime free-space estimate. The immutable profile
contains the state-to-tail table and its derivation. Reject overflow or an
unexpanded branch before startup.

Require `available >= transition cost + remaining tail` independently for slots,
logical bytes, objects and qualified metadata in each applicable class. The
successor and caller-final lanes are never available to the original owner.
Collection-only transitions preserve the successor's final portion and all
caller-final capacity. Refusal and unstarted cancellation have their own
terminal cost even when no operation is charged. The refusal's cost is reserved
before admission can be attempted. Failure of that write is still unavailable.

The tail check is an in-memory capacity decision against the immutable profile.
Kind 7 reserves no contiguous terminal range for an attempt. Its lifecycle rows
can interleave with other rows under the same sequential slot rule. Transition
cost includes the chosen slot and every parity-skipped slot, with all their
attachments. The profile must bound slots, attachment bytes, objects and
metadata for each remaining lane separately.

One bounded kind-29 failure summary per failing writer path is the last optional
write about logging itself. Its failure emits no recursive summary. The writer
then attempts only already reserved, independently necessary stop/containment/
handoff records whose facts it can actually establish, each once. A terminal
capacity failure cannot spend collection bytes or reassign an old slot. Physical
I/O failure can defeat all remaining writes despite reservation. Close
eligibility in memory and channels, preserve prefixes, and leave unavailable
observations.

## Ordered writes and recovery

### Original owner operation

The following steps are serialised under the original writer lock. They do not
form a cross-volume transaction.

<!-- tc: depart synonym-rotation because launch names process execution while start also names range and time origins -->
1. Check root, original lock object, backing identities, complete bootstrap and
   owner generation. Acquire actual exclusive ownership. Publish the generation opening and its kind 20 before readiness.
2. Before consuming an ordinal, select a fresh slot, write a fence, and observe
   its required write/flush/visibility results. Fence width `W` is a positive
   profile parameter derived from the workload. Only one fence may be open.
   Its inclusive range starts at the previous valid upper frontier plus one.
   Do not consume its members after failed or unknown publication.
   Ordinary fences use width `W`. Collection fences use one ordinal and bind
   one immutable collection-plan item. Thus a failed owner cannot obscure which
   collection item may already have run.
3. Drain failure/stop controls. Recheck eligibility, deadlines, identities and
   resource/tail capacity. Assign the next ordinal, directory and operation token,
   and debit the full operation contribution in memory. This is irreversible.
   Publish kind 7 before creating any attempt directory. An error retains the
   charge/ordinal. A crash may leave their individual facts unknown.
4. Create the exact assigned directory once in ordinary or collection backing.
   Retain its identity and creation result in the commitment's referenced bounded
   observation object. Existing or mismatched objects are failure, never adoption.
   Publish kind 9 and its mandatory kind 20 before child creation.
   Failure at any point prevents launch and all later scenario work.
5. The backend receives this assigned directory/ordinal and inherited lock. It
   cannot scan roots, allocate an ordinal or launch from a binding alone. Observe
   actual setup, process, collector, validation, result and reap facts separately.
6. Complete the offer/acknowledgement/terminal/send/echo protocol and original
   deadlines. Failed publication after payload receipt still blocks later input.
   A new ordinary fence is permitted only after the current one is exhausted and
   every assigned predecessor is settled. On irrevocable scenario closure, the
   first collection fence can instead retire the unused ordinary suffix. Its
   `retired-unused-lower` names that suffix, ending at the prior fence's upper
   bound. No charge is created for that suffix. Later collection fences name
   the next unattempted applicable plan item. No normal owner restart exists.

### Publication carriers

The live writer observes each required write, flush and visibility result before
the dependent effect. The following schedule defines where that observation must
be retained. A known `F.target` names the exact complete target record or
object. Failure uses its retained prefix or a missing expectation, without
inventing a completed target.

| Target publication | Dependent effect | Required carrier |
|---|---|---|
| Prepared bootstrap objects, kinds 1, 2 and 3, and any preceding kind 4 batch | Complete setup | Kind 4's `publications` vector covers every required preparation result. |
| Final kind 4 setup batch | Transfer writer ownership to the created owner | One mandatory kind 20 before transfer. |
| Kind 5 generation opening | Owner readiness, or successor command work | One mandatory kind 20 before readiness or any successor fence. |
| Kind 6 fence | Assignment within its range | Kind 7's `fence-publication`, retained with each assignment. |
| Kind 7 binding | Create its exact attempt directory | Kind 9's `binding-publication`. The live writer observes success before directory creation. |
| Kind 9 commitment | Create the backend child | One mandatory kind 20 before child creation. |
| Kind 18 terminal disposition | Send completion to the submitter | One mandatory kind 20 before completion send. |
| Kind 21 stop intent | Send its stop ID to the worker | One mandatory kind 20 before stop delivery. Failure still suppresses future ticks and starts failure containment. |
| Kind 23 worker reap | Claim published matched reap in handoff | One mandatory kind 20 before kind 26. |
| Kind 25 in failed-owner mode | Publish the successor's kind 5 opening | One mandatory kind 20 between kind 25 and kind 5. |
| Kind 25 in normal-handoff mode | Continue caller-final evidence | One mandatory kind 20 before kind 27. |
| Kind 26 owner handoff | Send the handoff response and relinquish writer ownership | One mandatory kind 20 in the owner tail before response or transfer. |
| Kind 27 owner-exit | Publish the caller's final outcome | One mandatory kind 20 before kind 28. |
| Kind 28 final outcome | Caller return | The existing caller-return trust boundary observes publication. No additional record is required. |

A mandatory kind 20 is attempted once after its target's publication attempt, if
the live writer can still write. It records actual success, failure or unknown
results. Failed or unknown target publication forbids the dependent effect. A
failed mandatory kind 20 also forbids that effect and closes eligibility. Its
own failure invokes only the existing bounded failure-summary rule. There is no
kind 20 about another kind 20 or kind 29.

If kind 7 or kind 9 cannot retain its predecessor observation, attempt one
fallback kind 20 for that predecessor. Count the failed carrier and the fallback
separately. A fallback never restores the failed carrier or permits dependent
work. If the writer dies first, retain the missing observation as unknown.

Recovery cannot invent the lost result. Kind 4 batches already carry preparation
failures. Their own failed publication uses the same final-batch kind 20 rule.

For kind 6, `prior-publication.target` is kind 5 on the first fence in each
generation. On every later fence in that generation, it is the exact
`prior-fence` kind 6 record. The field repeats the live writer's retained
observation of that target. It does not observe the new fence's own publication.
A successor's first fence therefore refers to its own opening, even when
`prior-fence` names an older generation's fence.

For each reachable path, count every attempted mandatory and fallback kind 20 in
its actual lane. Set `v` to at least the maximum of that count across all
complete paths, including publication failures. Thus `v` is derived from this
schedule, not an independent allowance selected by k119. Kinds 4, 7 and 9 pay
for their embedded carriers in their catalogue sizes. The count vector, lane
parity costs and remaining-tail calculation include every standalone carrier and
its attachments.

A record cannot predeclare its own successful flush. Recovery treats an
unrecorded flush result as unknown. Readability on the still-mounted system
supplies only a later visibility fact.

### Collection-only entry

The original finite caller stops scenario activity on owner failure. It resolves
actual owned holders under the one existing containment window. PID text, a zero
exit from an unrelated process, missing files or a newly created lock do not
establish ownership. It must actually acquire the **same original lock object**
after positively settling known holders.

Unknown descendants or inherited holders keep containment unresolved even if a
lock API reports acquisition. No caller evidence writes occur concurrently with
the owner/backend. If it cannot acquire that lock, its final persistent tail can
remain unavailable.

Under that lock the caller checks the complete immutable root/profile/pool and
physical object identities, and reads the bounded full predecessor ranges. It
does not stop scanning at the first empty slot. The declared upper bound makes
this scan finite. Check every nonempty frame and its allowed lane, identity,
predecessors and references. Retain all invalid bytes and missing joins.

The complete bootstrap supplies the genesis frontier zero. Before any fence,
recovery can therefore start at ordinal 1. The first fence has an inapplicable
prior-fence reference and references its generation-opening publication. A
structurally complete, properly linked fence whose own flush outcome was not
retained can supply a conservative upper frontier to burn. It cannot establish a
successful prior publication or any clean attempt.

The caller can recover only if it can establish a unique valid ordinal frontier.
Every attempted fence must be either complete and checked or demonstrably absent
without a dependent assignment. Any nonempty torn/invalid fence, conflicting
fence range, broken fence predecessor, foreign generation or indistinguishable
damaged slot that might be a fence prevents allocation. An all-zero slot alone
does not prove no write. The qualification assumption below must establish that
successfully published dependent records cannot vanish during this process-loss
model. If that assumption is unavailable, recovery is unavailable.

Burn every unused or uncertain member of the last valid fence. The new ordinal
starts strictly after its upper bound. Also retain all known earlier assignments
and charges. A missing kind-7 write may hide whether charging occurred.

Record that subset as unknown and conservatively keep the prior ordinary
allowance unavailable. Do not synthesise a per-operation charge, refund,
replacement ordinal or proof of execution. Recovery has its own separately
prebudgeted collection path. It can proceed despite an unfinished failed
ordinary attempt only after holder resolution, with that attempt and its
uncertainty retained.

Burn the failed writer's slot ranges, write kind 25 in the predetermined
successor lane. Then write its kind 20, kind 5 in collection-only mode and that
opening's kind 20. If any entry write fails, do not allocate a new fence or
dispatch collection. No second entry attempt is allowed. The original caller
owns the successor role.

It creates no replacement scenario owner or worker. Its fresh generation token
is never reused. It uses a new fence beyond the established frontier, the same
global ordinal sequence and the exact collection-backed directories. Each
collection item has a disjoint prebudgeted contribution and one immutable plan
index.

A valid predecessor collection fence makes its named item possibly attempted
even when binding is missing. Withhold that item's allowance as uncertain,
without inventing a known charge, and never reissue it. Retain any known result.
Only an applicable suffix proved never fenced can dispatch.

A torn collection fence prevents proving that frontier and refuses further
collection. No second full collection set is created by recovery. Preserve
unavailable earlier items and the untouched observer/window/screenshot order and
exact-clone stop plus independent inventory. Neither held-pointer case permits
release input.

At final transfer, burn unused successor slots and use the caller-final range
under the same lock. The caller records owner response/channel/wait observations
and one final outcome. If it dies or the final write fails, the unknown tail is
terminal. Existing files cannot establish its later return or acceptance.

### Transfer order and joins

The caller retains containment and original-lock observations in bounded charged
memory while the old writer can still hold the lock. After exclusive
original-lock acquisition, it writes their attachments in its first assigned
caller slot. No caller publication occurs concurrently with an owner or backend
writer. Kind 25's `original-lock-observation` and `backing-check` name type-7
attachment summaries.

Those summaries reference completed type-3 opened-identity bindings and type-1
original observations, including every required holder disposition. They cannot
reference later kind 11 or kind 24 rows as already known evidence. All
attachment objects belong to kind 25's selected slot and consume its
reservation.

Failed-owner entry uses this successor-lane order:

1. Write kind 25 after retaining its lock, holder, backing and frontier evidence.
2. Write the mandatory kind 20 for kind 25.
3. Write kind 5 in collection-only mode, with both `predecessor-handoff` and `recovery` naming that kind 25.
4. Write the mandatory kind 20 for kind 5.
5. Write any delayed kind 24 or kind 11 observations from the earlier containment window.
6. Permit the first successor fence only after all required entry evidence is complete.

Every row uses the next even slot, until a fence selects its next odd slot. The
first kind 25's `previous` names the prior lane's last checked complete record.
Its `causal` names the known first-failure record, or retains a missing/unknown
failure join. Kind 5's `previous` names the intervening kind 20, and its
`causal` names kind 25.

Each later row's `previous` names the immediately preceding complete row. An intervening kind 20 names its complete target as `causal`.
For an incomplete target, it uses a missing expectation of that target's record kind. Delayed observations use kind 25
as their recovery cause. They retain their original observation times.

Recovery never rewrites them as observations made after entry.

Normal handoff burns the unused owner and entire successor ranges. Its kind 25
is the first caller-final record, in `normal-handoff` mode. It names kind 26 as
`causal` and the owner's handoff-publication kind 20 as `previous`. No successor
kind 5 or collection fence follows this normal transfer. The caller writes kind
25's mandatory kind 20, then kind 27, its mandatory kind 20, and kind 28.

After failed recovery collection, the caller burns the successor suffix before
entering caller-final. Kind 27 is then the first final-lane row. Its `previous`
names the last complete successor row and its `causal` names kind 25. The
caller's own uninterrupted cursor establishes its successor-range burn. No
second kind 25 is written. Both paths end with the same kind 27, kind 20, kind
28 sequence where facts and writable capacity permit it.

### Ambiguity table

<!-- tc: depart synonym-rotation because launch names process execution while start also names range and time origins -->
| Observed condition | Required disposition |
|---|---|
| Empty slot before the first write, or death between in-memory slot consumption and first byte | Preserve it and burn the failed lane. Never infer that it is reusable. No fabricated event is added. |
| Short/torn frame or checksum/length failure | Retain the full real slot and prefix. Mark the event unavailable. If it could hide a fence or destroys the unique frontier, refuse new ordinals. |
| Complete duplicate record, repeated submission, reused slot or conflicting binding | Protocol failure. No idempotent success. Conflicting allocation evidence refuses recovery. Copying a valid frame into another slot fails identity checks. |
| Stale generation, root/pool mismatch or replaced backing/lock | Refuse recovery and later slots. Do not unlink, remount into another identity or create another writer domain. |
| Complete fence. Death before or during assignment/binding | Burn the fence remainder. Preserve known charges and mark hidden assignment/charge facts unknown. No launch from the fence. |
| Complete binding. Empty or partial directory | Retain assignment/charge and exact backing. Never recreate the directory under the old ordinal. No child launch. |
| Directory exists. Commitment absent or torn | Retain directory and charge. Live failure before launch knows not-started. Post-death launch can remain unknown unless actual evidence establishes it. |
| Commitment complete. Backend creation/launch evidence absent | Intent only. Do not infer no execution or resend. Resolve holders before collection. |
| Handoff present. Owner wait or final caller write absent | No final acceptance. Preserve actual available response and wait observations separately. |
| Last fence upper frontier or required layout identity unavailable | No new ordinal, collection command or exact-clone command through another domain. Retain unresolved containment and block every later slot. |

## Assumptions and guarantees

The protocol guarantees one-use allocation **conditional on** a cooperating
implementation and the following still-unestablished mechanism prerequisites.
Failure of a prerequisite is an unavailable profile or recovery, not permission
to weaken its guarantee.

<!-- tc: depart synonym-rotation because launch names process execution while start also names range and time origins -->
| Prerequisite | What must be established. What is not inferred |
|---|---|
| Original lock and identity | Actual exclusivity across intended inherited holders, descriptor lifetime and reliable opened-object identity. Merely retaining its pathname is insufficient. |
| Bounded original pool | Fixed object identities/sizes, no replacement or unintended resize, complete bounded scan and protection of remaining class capacity/metadata. Precreation alone proves none of these. |
| Process-loss visibility | On the supported still-mounted healthy system, a completed required publication and dependent ordering remain visible after process loss. A partial write cannot silently become a different valid record. Establish the actual write, flush, read and identity behaviour used. |
| Ordering and flush | The selected calls and observed outcomes precede dependent directory/launch work. No atomic multi-record, cross-volume or rename transaction is assumed. Failed/unknown flush prevents dependent work. |
| Damage detection | SHA-256/length/identity checks detect accidental mismatches within the declared fault model. This is not protection against a malicious same-user writer or proof of non-collision. |
| Bounded parser and channel retention | Declared frame/object/count/peak-memory limits apply before allocation, including incomplete reads, digests and recovery scans. No unbounded JSON/parser expansion behind a length check. |
| Private backing and metadata | The three backing identities, host/image allocations, directory/object/update costs and protected ordinary/collection/terminal separation have qualified bounds. Shared-device loss can make all classes unavailable. |

Power failure, device loss, remount recovery, hostile mutation and filesystem
rollback are outside this process-loss claim. They can make the upper frontier
unavailable. A passing S1/S3 fixture does not extend the claim to them. No
storage call, checksum, extent reservation or finite process-loss test proves
universal durability or available cleanup.

The one-use lanes avoid an atomic persistent slot counter, at the cost of unused
retained capacity and no second recovery generation. A mutable high-water file
would be smaller but needs an atomic update/recovery proof not supplied here. A
separate allocation log would recreate the same allocation problem. Scanning
ordinary and collection roots would duplicate allocation authority and lose
charged-but-unpublished assignments. Revisit the lane choice only with a
complete bounded alternative and corresponding review. Do not silently add slot
reuse.

## Checkable walkthroughs

These are symbolic protocol traces, not executed coordinator or storage results.

**Clean capture.** Bootstrap and generation opening complete. Fence `[a,b]`
publishes. Received/admitted submission `s` has no ordinal or operation charge.
The transition assigns `a`, debits its contribution and publishes binding,
creates its ordinary directory and publishes commitment.

The commitment's kind 20 precedes backend creation. Backend/collector/validator
events, complete result and actual reap precede offer/ack and terminal
disposition. The disposition's kind 20 precedes completion send. The worker
echoes receipt before its next sleep.

Clean stop later joins intent, its kind 20, exact ack, observed reap and the
reap's kind 20. Owner handoff and its kind 20 precede the caller's lock
transfer. The caller-final sequence is kinds 25, 20, 27, 20 and 28.

Every row/object costs capacity, including clean phase reports and the caller
tail.

**Failed commitment publication.** The owner has charged `a`, published binding
and created its directory. The commitment write retains a real prefix and fails.
That slot, ordinal and full charge remain consumed. Backend invocation count is
zero on this live controlled branch.

No result bytes or later successful cleanup can permit scenario input. The
failed commitment's kind 20 retains the observed failure where writable. One
bounded write-failure summary, stop and containment use their reserved slots
where writable. If the owner then dies, recovery does not rewrite commitment or
refund `a`. It burns through `b` and marks the failed event unavailable.

Its even slot identifies a non-fence independently of the damaged bytes. An
invalid pool map or a damaged odd fence slot instead makes the frontier
unavailable and refuses collection.

**Collection after owner death.** A known child still holds the original writer
descriptor, so the caller initially cannot acquire it. The child is resolved
under the existing containment policy. An observed exit is not invented for a
grandchild. After actual original-lock acquisition and holder/identity checks,
the bounded scan checks the unique last fence `[a,b]`.

The caller burns both owner slot ranges and unresolved ordinals through `b`,
preserving all partial objects and unknown charges. It writes kinds 25, 20, 5
and 20, then any delayed holder observations. Only then can it write a new fence
starting `b+1`. Binding and directory creation for the first collection command
use terminal and collection capacity respectively. Required collection order,
exact stop and inventory keep separate outcomes.

Any unresolved holder, torn fence, missing backing or failed recovery write ends
this trace before a collection command. Final caller loss never starts another
recovery.

## Later controls and remaining inputs

The [expanded recovery control design](../verification/settings-activation/KEEPALIVE-RECOVERY-CONTROLS.md)
names the original S2–S6 cases and the finite publication, codec, recovery and lifecycle products.
It separates real retained bytes, observed publication results and dependent-action permission.
Its case count is a design inventory, not an executable manifest or a native execution budget.
Scoped review and every earned integration precede consumption.

The [qualification
plan](../verification/settings-activation/KEEPALIVE-QUALIFICATION.md#storage-and-process-loss-controls)
owns S1 and the existing S2–S6 case groups. The table below refines later
real-coordinator coverage. It does not add executed cases to the 13-case native
mechanism envelope or claim the old 18-case S count covers every expanded row.
The complete-profile task must enumerate a finite implementation suite and its
actual process overlap before requesting any separate execution scope.

<!-- tc: depart synonym-rotation because launch names process execution while start also names range and time origins -->
| Boundary / later control | Approved enabling point and required discrimination |
|---|---|
| Encoding and S2 catalogue | Real encoder/decoder and original-lock coordinator. Declared finite fixture inputs. Every kind, missing/zero/unknown/inapplicable value, maximum and one-past length/count, wrong version/type/digest/predecessor and duplicate/stale slot. No allocator substitution. Check exact size formula and actual bytes. |
| S2 clean/failure accounting | Real charge/tail calculation plus approved owner capacity observations. Enumerate each attempted row, every scheduled kind 20, kind 29 and every reserved slot's attachments. Include parity-skipped slots, partial setup, refusal, cancellation and charged-unpublished attempts. Check the complete logical-byte, object-count and physical-rounding formulas. Exhaust history with tail intact. Reject borrowing each other lane/class and recycling clean rows. |
| S3 slot consumption | Approved owner/caller barriers and named write results. Stop points: before slot choice, after choice before first write, and after a real prefix. Also stop after full write before flush observation, and after observation before dependent record. End the directly owned writer once per declared case. Burn empty uncertainty without rewriting it. |
| S3 fence/assignment/directory/commitment | Preserve the eight named S3 schedules. Add declared boundary subcases where needed. Failure before write performs no write. Partial failure retains exactly the declared real prefix. For every required write/flush observation assert zero dependent directory creation or child launch when failed/unknown. |
| S3 recovery entry and final lane | Real original lock plus audited caller barriers/write results before/after recovery and generation rows, at new fence, and at final transfer. No second recovery attempt after a failed entry or caller death, no duplicate ordinals or synthesised charges. |
| S4 delivery/final joins | Keep its four cases, and enumerate result offer/ack/terminal/send/echo and kind 27/28 failures against the schema. Complete-looking remaining rows must not permit another scenario action or final acceptance. |
| S5 holder/backing/frontier | Controlled child retains the real inherited descriptor. Mismatched capacity/identity result uses the approved copied observation. Finite declared malformed slot fixtures exercise empty, torn, duplicate, stale and ambiguous frontier cases. No live-volume corruption or lock deletion. Unknown ownership never authorises a signal. |
| S6 protected writes | Real collection directory and terminal slot prefix under the approved write-result seams. Preserve the old prefix and independent status when later protected publication fails. Kind 29's failure generates no kind 29 recursion. |
| R setup/progress/settlement | Existing backend limit-call/readback and owner capacity/write-result seams. Commitment has no fabricated setup fact. Raw/producer/collector failures stay separate from successful process status. All originals retain their own class and bound. |
| Collector R3/R5 | Only the approved separately audited R3 pre-read barrier and R5 raw-storage write-result sites. R3 releases without waiting for blocked writers. R5 is failure before write or **exactly 1024 real persisted bytes then failure**. Neither substitutes the kernel queue/native bounds or authorises another collector site. |
| Lifecycle, signals and input | Owner/backend/caller audited barriers/clock plus controlled CLI/sleep. Include every stop race, INT/TERM/HUP, orphan loss, both held-pointer cases, unavailable lock and no release input. Preserve original containment deadlines and collection order. |

All copied sites require correspondence audits and must fail for missing,
duplicated, unexpected or unused controls and unrelated source changes. Controls
run after implementation and before downstream consumption. They test handling.
Native storage/queue/codec/service qualification remains separate. Source-only
diagram, formula and link checks performed during design are not these results.

The full profile still owes exact `n,a,w,h,q,g,p,b,f,f_c,v,t`, all vector/object
maxima, tail-state tables, fence width, slot size/counts, physical metadata
costs, message/parser/scan peak memory and complete useful fit. It also owes
start queue and boot timing, post-start uploads, all ticks and collection,
dependency issue #13's evidence, every R/S expansion and whole-design
reconciliation. Missing inputs keep startup unavailable. All original parent
duties and runtime holds remain live.

The [phase assignment](../verification/settings-activation/KEEPALIVE-ACCOUNTING.md#assign-every-publication-to-its-deadline)
places every carrier in its existing deadline.
K126 must establish useful fit with the selected fence width and qualified storage costs.
The current two-second selection-to-commitment
ceiling includes any required fence, binding, directory creation and commitment
publication. The mandatory commitment-observation kind 20 also precedes child
creation and consumes the existing creation-phase allowance. All required write,
flush and visibility work must fit its phase and the admission or
whole-operation deadline.

K119 must account for first-fence and reused-fence paths, plus all other added
carriers in their existing deadlines. No independent choice of `W`, storage
flush cost or capacity establishes that fit. Any revised timing belongs to
explicit whole-design reconciliation, without changing input order, cadence or
one-attempt transports here.
