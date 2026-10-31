# Settings owner records and collection recovery

## Contract and scope

This is the proposed `settings-owner-records/1` format for the
[Settings command owner](settings-keepalive-owner.md). It supplies the bounded
records and recovery rules required by that design. The owner contract remains
authoritative for scheduling, eligibility, process ownership and collection order.
The [producer contract](settings-capture-resource-contract.md) owns dependency
units and approved test substitutions. Neither a parseable record nor this
proposal establishes an implemented or qualified mechanism.

The design uses immutable records in a predeclared terminal pool. Each writer
has a disjoint range of slots. A successor abandons the preceding writer's
remaining range, even when a slot appears empty. Separately, an allocation fence
bounds the command ordinals that writer can consume. A collection successor
burns uncertain ordinals and never resumes the scenario.

The [storage view](../design/architecture/settings-activation/keepalive-storage.mmd)
and [record view](../design/architecture/settings-activation/keepalive-records.mmd)
show those two sequences. Graphs start at the dark **Start here** node. They are
explanations, not proofs of storage behavior or model-checking results.

All quantities below are format sizes or symbolic workload parameters. They
are not selected useful resource limits. The qualification proposal's
eight-ordinal fence and 4096-byte record remain study choices. The full profile,
mechanism evidence and independent whole-design review remain prerequisites to
adoption. No native experiment or dependency implementation is authorized here.

## Encoding and identity

All integer encodings are unsigned, big-endian and checked before addition,
multiplication, offset calculation or conversion. Signed values use a signed
64-bit two's-complement payload only where explicitly specified. No length is
an allocation instruction until it is checked against both the remaining frame
and the immutable profile. A zero bound means zero permitted units, never infinity.

The wire/storage version is major 1, minor 0. Reject any other version, unknown
kind, unknown code, nonzero reserved bits, excess field, repeated field, wrong
field order, wrong length or trailing bytes within a frame. There is no optional
field omission. Schema changes, including a code or unit-set change, need a new
version and an exact profile binding. Do not guess compatibility.

| Atom | Bytes | Encoding and meaning |
|---|---:|---|
| `I` | 16 | Opaque nonzero 128-bit identity. Chosen once at creation, checked for collision within the run. It is not a PID, path or authorization capability. |
| `K` | 24 | Tagged identity: state byte, seven zero bytes, then `I` bytes. Known is nonzero; missing retains the expected identity; unknown/inapplicable payload is zero. Uses the four `Q` states. |
| `U` | 8 | Required finite count, index, ordinal or length. Zero is a real value. Ordinals and slot indices start at 1. |
| `C` | 4 | Two unsigned 16-bit words: namespace and value. Each field has a closed enum, as specified below or in its pinned profile registry. |
| `Q` | 16 | State byte, seven zero bytes, then unsigned value. States 0 known, 1 missing, 2 unknown, 3 inapplicable. Non-known payload is zero. Signed status quantities use the same layout with signed payload. |
| `T` | 32 | `Q` nanoseconds followed by `I` clock identity. Continuous times use the pinned host boot/API identity; presentation wall time uses its separately declared clock identity and signed value. Non-known times retain the relevant clock ID. |
| `H` | 32 | SHA-256 digest bytes. A digest field is required and known; use a tagged reference when the digest is unavailable. No textual hex in the frame. |
| `R` | 72 | State byte; storage-class byte; expected-kind unsigned 16-bit word; four zero bytes; object `I`; index `U`; length `U`; digest `H`. States are the same four as `Q`. For known references all fields are checked. Non-known references have zero length/digest; a missing reference retains its expected object/index/type; unknown or inapplicable uses zero object/index. |
| `V(X,n)` | `4 + n * size(X)` | Unsigned 32-bit count followed by exactly that many fixed-size entries. Count is at most the field's profile maximum `n`; no nested unbounded vector. |

Known zero differs from missing (a required named observation/object was not
published), unknown (its identity or fact cannot be established), and inapplicable
(the protocol does not require it on this branch). Known empty bytes have length
zero and the digest of empty bytes. A missing record never becomes a known empty
record. A whole frame that is absent or torn is not a frame with unknown fields.

All original commands, argv bytes, predicates, environment values, channel frames,
paths, VM selectors and raw text live in bounded private objects. Records contain
references, not excerpts. Object names are derived from opaque identities, not
their secret contents. Public diagnostics contain only kind/reason codes and
opaque IDs; no private-root path or environment dump. References and pool
inventories are themselves private. A digest is an integrity check, not
authentication, confidentiality or evidence of execution.

For private byte objects the format is exact length plus exact original bytes,
without normalization, trimming or truncation. A vector of original argv or
environment entries uses a 32-bit entry count, then a 64-bit byte length and the
original bytes for each entry; environment entries separately encode name and
value, or an explicit absence code. The profile bounds count, each length and
aggregate bytes before receipt. An oversized or malformed producer message
closes that channel and eligibility. Retain all bytes already accepted within its
charged receive buffer, including a partial frame, and mark the unread tail
unknown. Do not drain an unbounded remainder or claim to have retained bytes
that never entered the owner. The profile must cover normal valid messages in full.

An object reference resolves only within the root's immutable object map. The
map fixes class, owning attempt or setup role, permitted maximum length and
derived location. A reference to a terminal record includes its global slot
index; an ordinary/collection object uses its object index. The reader checks
root, type, exact identity, actual length and digest before treating the join as
known. Expected-kind values 65534 and 65535 identify a retained raw prefix and native
raw object respectively; they never satisfy a complete-record join. This permits
a checksum of real partial bytes without inventing a valid record. There is no fallback pathname search. Forward references are permitted
only as missing expectations in a declaration; a known evidence reference must
name already completed bytes. A later record can report newly observed evidence
but cannot repair a missing earlier publication.

### Common frame

Every record has **384 bytes of framing** plus its kind's payload:

| Ordered field | Bytes |
|---|---:|
| ASCII magic `KORREC01`; major; minor; kind; flags (each of the last four is 16-bit, flags zero) | 16 |
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
still be zero; extra nonzero content is invalid, not a second record. Neither a checksum nor a successful read proves a successful
prior flush. A record cannot attest to its own later flush, return or exit.
The next dependent record retains that publication observation. Final publication
uses the existing caller-return trust boundary, without another recursive logger.

Terminal event sequence equals global terminal slot index. Gaps are allowed and
retained as gaps; it is not a count of successful publications. `previous` names
the preceding complete terminal event known to that writer, while `causal` names
the event that caused this one. A failure can therefore follow a damaged slot
while its predecessor still points to the preceding complete event. Missing joins
prevent acceptance even if this shorter chain validates. At lane transfer the
first event references the prior lane's last verified event and its range
disposition. Backend frames use an operation-local monotonically increasing
sequence and exact commitment reference. They do not allocate terminal event
numbers or command ordinals.

For clean acceptance, consecutive records in one lane must use the first
permitted slot after their predecessor, allowing only the parity skip required
by the next kind. Larger unexplained gaps are unavailable. A declared irreversible
lane closure can leave an unused suffix; its handoff/range summary records that
suffix. A shorter checksum chain alone cannot hide a consumed non-fence slot.
Recovery range burning never establishes clean acceptance.

### Fixed bundles and registries

These bundles make the catalogue below a complete size calculation. Fields are
ordered as listed. A bundle cannot contain an arbitrary dictionary.

| Bundle | Size | Ordered fields |
|---|---:|---|
| `P`, process observation | 232 | Token `I` and parent token `K`; role and observed relationship `2C`; PID, parent PID, process group and session `4Q`; boot `I`; incarnation/start observation `T`; creation evidence `R`. |
| `S`, status | 64 | Status domain `C`; raw wait representation, exit code and signal `3Q`; outcome `C`; source event/object index `U`. A raw wait value is signed; exit/signal cannot both be known for the same terminal observation. |
| `D`, deadline | 104 | Phase and observer `2C`; origin, absolute deadline and observed check `3T`. |
| `B`, resource cell | 168 | Unit, phase, enforcer and check outcome `4C`; declared limit, requested quantity, observed quantity, irrevocable charge and remaining capacity `5Q`; evidence `R`. |
| `E`, object extent | 184 | Object, backing and directory `3I`; role and class `2C`; maximum bytes `U`; observed length, allocated bytes and metadata contribution `3Q`; exact retained content/prefix `R`. |
| `J`, missing or required join | 80 | Required kind and reason `2C`; evidence or expected evidence `R`. |
| `A`, slot range | 24 | First, count and maximum frame bytes `3U`. |
| `F`, publication observation | 176 | Target `R`; requested-write, write-result, requested-flush, flush-result, namespace-result and visibility-result `6C`; requested bytes and observed written bytes `2Q`; observation time `T`; raw I/O status `Q`. |

Core code namespaces are closed: storage class (terminal, ordinary, collection),
outcome (clean, state-failed, unavailable, interrupted, cancelled-unstarted,
refused, not-started, started, unknown), fact/check (not-requested, success,
failure, unknown, inapplicable), relationship (direct-child, reported-owned,
unestablished), role (caller, owner, worker, sleep, backend, intermediary,
producer, collector, validator, helper), input state (clear, possibly-held,
unknown), recovery mode (normal-handoff, failed-owner, refusal), and reason
(protocol, identity, capacity, deadline, I/O, process, channel, validation,
signal, normal-end, predecessor, frontier, missing-evidence).
Each list assigns consecutive values starting at 1 in its listed order;
namespaces are assigned in that same order starting at 1. Unknown is a fact,
not a wildcard code. No arbitrary error text goes in `C`.

Field-local subtypes use namespace `100 + kind`, with listed values numbered
from 1. Kind 5's mode is owner or collection-only; kind 12's phase uses the
worker-phase table; kind 26's eligibility uses its listed three values. Registry
namespaces start at 1000 in the order named below. Status-domain codes are
shell, POSIX-wait, local-evaluator, dependency, channel and I/O, in namespace 9.

Operation, phase, unit, transport, predicate, environment and object-role codes
are indexes into finite registries frozen in the profile. Each registry row has
its numeric ID, semantic version, exact private definition reference and maximum
representation. The profile records the exact registry length and digest.
No runtime registration is allowed. The producer's unit schema is independently
versioned and pinned; this format cannot invent its still-missing definitions.
Status domains declare how to interpret the raw signed value, including shell,
POSIX wait, local evaluator and dependency status. A shell 130 and signal 2
remain separate reported facts. Field-specific enum restrictions are part of
each row's semantics; inapplicable does not excuse a required fact.

## Record catalogue

Kind numbers are the first column. Each payload is the listed concatenation;
maximum encoded size is **384 plus the sum of its listed field sizes**, including
every four-byte vector count. All vector maxima are finite profile inputs below.
This formula applies to failed rows too. Partial writes consume the whole assigned
slot/allowance, never merely the visible prefix. `R` names an original object or
record; it does not duplicate that payload.

### Setup, allocation and submissions

| Kind | Payload in encoding order | Meaning and maximum multiplicity |
|---|---|---|
| 1 Root declaration | `I run, I exact-VM, R private-VM-binding, R original-lock-binding, R backing-map, R profile, R pool-layout, R caller-binding, R clock-registry` | One caller setup record. Private bindings retain actual opened filesystem identity and exact VM identity; tokens alone are insufficient. |
| 2 Profile fragment | `U part, U parts, R original-profile, V(B,u) units, V(R,r) registry-bindings` | `p` parts, predeclared. Their ordered digest/length list is bound by the root. Includes workload, count/size/metadata and enforcement evidence, not only limit numbers. |
| 3 Pool declaration | `I pool, U slot-size, U slots, V(A,5) lanes, R physical-layout, R bootstrap-manifest` | One. Layout fixes bootstrap, owner-history, owner-tail, successor and caller-final ranges in that order. |
| 4 Setup publication | `V(F,z) publications, V(E,o) setup-objects, V(J,j) missing` | Bounded setup batches `b`. Establishes observed preparation, not guaranteed future I/O. |
| 5 Generation open | `C mode, P writer, R predecessor-handoff, R recovery, V(A,2) assigned-ranges, V(J,j) missing` | Once for the owner; at most once for the collection successor. Neither ordinary admission nor generation reuse follows from parsing it. |
| 6 Allocation fence | `R prior-fence, U lower, U upper, I generation, R backing-map, C class, Q collection-item, Q retired-unused-lower, F prior-publication` | `f` ordinary fences and at most `f_c` collection fences; each inclusive finite range is contiguous with its established predecessor frontier. A collection fence binds exactly one plan item and one ordinal. |
| 7 Assignment/storage binding | `I submission, U ordinal, R fence, C class, I backing, I directory, I operation-token, R exact-request, R cost-profile, V(B,u) charge, V(A,2) terminal-reservation, F fence-publication` | Once per assigned attempt, even if later publication fails. The in-memory assignment/charge precedes this write. |
| 8 Submission observation | `C received-admitted-refused-cancelled, I sender, I submission, U producer-sequence, R original-frame, R operation-definition, R cost-profile, R holder, R stop, T producer-origin, T receive, D admission, V(B,u) check, V(J,j) missing` | At most four rows per bounded submission `n`; received then admitted or refused, and at most one unstarted cancellation. All are ordinal-free. The subtype is a field-local closed enum in listed order. |
| 9 Dispatch commitment | `I submission, U ordinal, R assignment, R directory-observation, R exact-request, R predicate, R transport, R eligibility, R stop, V(D,d) deadlines, V(B,u) charge, F binding-publication` | At most one per assignment `a`. The charge is the same immutable charge, not another debit. Installed-limit observations are inapplicable here. |
| 10 First failure/control | `C reason, C phase, I sender, R original-frame, R failed-subject, R prior-backend-latch, S status, D deadline, C input-state, V(J,j) missing` | First failure plus bounded later distinct controls `q`. First-failure identity never changes. Repeated identical observations update no file and emit no new event. |

Root/profile/layout use a bootstrap manifest prepared before owner creation.
The caller retains the original lock while recording the observed owner creation
in a setup attachment. The created owner waits for this startup handoff without
writing. Only after complete bootstrap and exclusive transfer of the original
writer domain can it publish generation opening/readiness. Parent loss during
this handoff is failed startup, never authority to repair or reopen bootstrap.
To avoid a digest cycle, its canonical content contains root/pool IDs, fixed
slot ranges, profile fragment content hashes and object layout, but no digest
of a frame that itself references this manifest. Fragment frames reference that
content digest. Root and pool records reference already prepared content objects.
Profile fragment references in the manifest name content objects, never the
frames that wrap them. Prepared object layouts contain missing/inapplicable
content references for future bytes, not future digests or self-references.
These setup objects, their complete bytes, prefixes and metadata are charged
to terminal setup capacity. Incomplete bootstrap prohibits owner readiness and
any attempt allocation; it is retained, never reinitialized in place.

### Referenced private objects

The following object shapes close the indirection in the catalogue. Each object
has a 16-byte prefix (eight-byte ASCII magic `KOROBJ01`, 16-bit major and minor,
16-bit object type and 16 zero bits), an eight-byte payload length, its payload
and a 32-byte digest over prefix/length/payload: **56 bytes plus payload**.
Original raw byte streams and images are exceptions: preserve their native bytes
exactly and retain length/digest in the referencing observation. A partial object
is a real retained prefix, never a valid wrapper claiming a complete original.

| Object type | Ordered payload and maximum size method |
|---|---|
| 1 Exact bytes | `U length` and at most `x` original bytes. Total at most `64+x`. Used for commands, paths, VM selector, predicates, original channel frames and diagnostic originals. Length and `x` are byte counts, not characters. |
| 2 Argument/environment vector | 32-bit entry count, followed by at most `x_count` length-prefixed original entries as defined below. Count/absence/name/value headers plus the profile's aggregate `x_bytes` are all charged. No recursive values or conversion to normalized text. |
| 3 Filesystem/lock binding | `I logical, C role, Q device, Q inode, Q incarnation, I volume, I mount, R original-path, R opened-identity-evidence, S observation`. Logical identity is not authority without matching opened evidence. Platform-specific original evidence is a bounded type-1 object. |
| 4 Bootstrap/profile layout | `I root, I pool, I run, U slot-size, V(A,5) lanes, V(R,r) profile-fragments, V(R,r) registries, V(R,3) backings, R lock, R clocks, R collection-plan, R object-layout, V(Q,m) parameters, V(R,r) tail-tables`. Parameter order is frozen as below; variable lists have finite bootstrap maxima supplied before parsing. |
| 5 Registry | `C registry, U version, V(R,r) definitions`. Each definition is a type-1 exact byte object with a declared bounded versioned grammar supplied by that owning contract. No runtime extension or dependency-unit inference. |
| 6 Object/descriptor layout | `U count, V(E,o) objects, V(R,r) descriptor-bindings`. Each descriptor binding is a fixed tuple `I process-token, C role, Q descriptor-number, C access-mode, R object, C inheritance, C closure-phase`; access is read/write/read-write and inheritance is keep/close. |
| 7 Required/observed join summary | `V(J,j) joins`. Used for holder, event-range, collection and missing-evidence summaries. A missing summarized object remains missing; the summary confers no success. |
| 8 Tail-state table | `U states, V(R,r) states`. Each state is a fixed tuple of profile state `C`, allowed transition `C`, predecessor state `C`, `V(B,u)` maximum next cost and `V(B,u)` remaining-tail cost. Counts cover the full finite state expansion. |
| 9 Ordered collection plan | `U count, V(R,r) items`. Each item is `U index, R operation-definition, R exact-target, R cost-profile, C applicability, V(R,r) prerequisites`. Applicability codes are always, failure-only, held-input, or declared-protocol-condition; the last references its exact predicate through operation-definition. |

Fixed tuple objects referenced by types 6, 8 and 9 use the same wrapper with
object types 10, 11 and 12 respectively. Type-10 access and inheritance use
namespaces 210 and 211; type-12 applicability uses namespace 212, with values in
listed order. Profile state/transition/closure-phase meanings are pinned registry
definitions. Redundant count fields must equal the vector count. A type-2 entry
contains a `C` argv/environment-present/environment-absent discriminator, then
length-prefixed bytes (one argv value; name and value for present environment;
name only for absent environment). Its namespace is 202, values in listed order.
No NUL terminators or character normalization are added.

The parameter vector in type 4 has this fixed order: `n,a,w,h,q,g,p,b,f,f_c,v,t`,
then `u,r,z,o,j,d,m`, fence width, slot size, total slots, maximum object bytes,
maximum original-frame bytes, maximum argv/environment entries and aggregate
bytes, maximum receive/parser/scan live bytes, maximum depth and component bytes.
All are known finite `Q` values at startup; missing/unknown is a refused profile.
Each distinct field may have a smaller bound through its registry definition,
never a larger implicit one. Type 4's `m` must accommodate this fixed vector.
Large manifests use predeclared fragments with numbered parts, total parts and
exact reference lists; all fragment/object counts, bytes and metadata are charged.
Neither fragmentation nor references permit an unbounded chain or cycle.

Terminal original-frame and summary objects are preassigned by
`(pool, slot, object-role, element-index)`. Their exact IDs, sizes and opened
identities are in the immutable object layout. Reserve their slots before writing
their bytes; write each object once before its referring event. A crash burns
these attachments with their parent slot even if the event remains empty.
Backend objects are assigned by `(operation-token, object-role, element-index)`
under the exact directory binding. The frozen role schema determines those
identities before launch. Both maps have finite checked domains and reject any
ID collision before writes. No dynamic map entry or recursive binding record is
needed. Received/admitted/refused submission originals belong to terminal
attachments, because no attempt yet exists. Later records reference them without
copying. A digest of an unavailable original is never invented.

### Processes, results and delivery

| Kind | Payload in encoding order | Meaning and maximum multiplicity |
|---|---|---|
| 11 Process/holder observation | `P process, R commitment, R channel-binding, R descriptor-inventory, C creation-exit-holder, S status, T sender, T receive, V(J,j) missing` | Bound `h` includes each created child, inherited descriptor owner, exit and holder-resolution observation. Subtype is a field-local enum in listed order. A reported grandchild exit is not caller reap. |
| 12 Worker readiness/phase | `I worker, U sequence, C phase, K sleep-or-tick, Q tick-sequence, Q sleep-sequence, R original-frame, R creation, R preceding-completion, T sender, T receive, T completion-receipt, S sleep-status, D deadline` | Bound `w` covers readiness and every permitted phase transition, including stop races. Phase uses the owner spec's seven phases in table order. No periodic heartbeat rows. |
| 13 Backend/launcher/collector progress | `U ordinal, R commitment, P reporter, R original-frame, C phase, T sender, T receive, D current, D next, S status, R environment, R selector-comparison, R descriptor-inventory, V(B,u) resources, V(E,o) extents, V(J,j) missing` | Bound `g` per attempt covers setup, raw binding, limit calls/readbacks, producer/collector/validator phases and failures. Actual creator and external execution are separate events. |
| 14 Backend request | `U ordinal, I operation-token, R commitment, R dependency-request, R exact-argv, R environment, R predicate, V(E,o) outputs, V(D,d) deadlines` | One child-owned frame per attempt in its assigned class. Contains no invented setup result. |
| 15 Backend validation/result | `U ordinal, R request, R producer-observation, R stdout, R stderr, R payload, R validation, S transport, S evaluator, S emission, V(E,o) extents, V(J,j) missing` | At most two frames per attempt: validation then result, distinguished by the validation/result field-local subtype prepended as `C`. An incomplete producer observation remains missing. |
| 16 Result offer | `I offer, I submission, U ordinal, R backend-result, R payload, D delivery, S send` | At most one per completed backend attempt; records actual offer/send state. |
| 17 Payload acknowledgement | `I offer, I submission, U ordinal, R original-ack, R payload, R backend-result, T receipt, T owner-receive, S channel` | At most one per offer. Retains the exact ack before interpreting its match. |
| 18 Terminal disposition | `U ordinal, R commitment, R launch, R backend-result, R backend-reap, R acknowledgement, R first-failure, C outcome, V(S,4) statuses, V(B,u) settlement, V(E,o) extents, V(J,j) missing` | At most one per assigned attempt; a failed attempt can have missing commitment/backend. Settlement never refunds. |
| 19 Completion observation | `C send-echo, I submission, U ordinal, R terminal, R original-frame, T sender, T receipt, T owner-receive, D deadline, S channel` | At most two per terminal disposition. Subtype is a field-local enum in listed order. The send and later echo stay distinct. |
| 20 Publication observation | `F publication, R first-failure` | Bound `v`. Use only when the next semantic event cannot carry the observation it needs. No observation of this observation is required. |

For kind 15 the prepended subtype makes the size unambiguously
`384 + 4 + 8 + 6*72 + 3*64 + (4 + 184o) + (4 + 80j)`.
Status, raw streams and producer observation remain separate. Artifact and raw
bytes are objects, not additional free records. A private command/result JSON
needed by an existing consumer is another declared object in the attempt's
charge; this schema does not make that compatibility copy free.

### Stop, recovery and the caller

| Kind | Payload in encoding order | Meaning and maximum multiplicity |
|---|---|---|
| 21 Stop intent | `I stop, C reason, R scenario-end, R final-scenario-result, R first-failure, R worker-phase, V(R,2) pending, Q active-ordinal, D deadline, C input-state` | One owner stop intent. A later failure references it without issuing another normal stop or resetting its deadline. |
| 22 Worker stop acknowledgement | `I stop, I worker, R original-ack, R last-tick, R disposition, C phase, T sender, T receive, S status` | At most one matched ack; one malformed/duplicate channel event instead closes eligibility and consumes control capacity. |
| 23 Worker reap | `K stop, P worker, R acknowledgement, R tick-resolution, S wait, C lifecycle-outcome, V(J,j) missing` | At most one direct-child reap record; unavailable is retained if observation is absent. |
| 24 Containment action/result | `R first-failure, P target, C action, T origin, T observation, D unchanged-window, S result, R ownership, C input-state, V(J,j) missing` | Bounded by `t` actual targets and their fixed TERM/KILL/observation protocol. Action enum: term, kill, wait, lock-acquire, disposition. Unknown targets receive no signal. |
| 25 Recovery/range disposition | `I failed-generation, I successor-generation, C mode, R original-lock-observation, R backing-check, R last-fence, Q safe-upper, V(A,2) burned-slot-ranges, Q burn-lower, Q burn-upper, V(R,r) known-assignments, V(J,j) uncertain, R first-failure, C input-state` | At most one caller recovery entry. Ordinal burning is not a capture charge. Refusal is permitted only if the original terminal identity/lock and a valid unused successor lane are established; otherwise no new record is possible. |
| 26 Owner handoff | `R first-failure, R final-worker, R final-attempt, R event-range-summary, R holder-summary, R required-collection-order, R collection-results, R exact-stop, R independent-inventory, C eligibility, C input-state, V(J,j) missing` | At most one. Eligibility enum: closed-clean-history, closed-failed, unknown; none permits another scenario command. Summaries are bounded objects, not substituted evidence. |
| 27 Caller owner-exit | `P owner, R handoff, R original-response, S response, S channel, S wait, T receipt, T wait-observation, V(J,j) missing` | At most one after the caller establishes exclusive original-lock ownership. Caller retains observations in its charged memory until then. |
| 28 Caller final outcome | `R owner-exit, R recovery, R first-failure, R collection-results, R exact-stop, R independent-inventory, C outcome, C input-state, V(J,j) missing` | One attempted final write. Caller return/exit after publication is explicitly unrecorded. |
| 29 Bounded write-failure summary | `R failed-slot, F write-observation, R first-failure, V(J,j) missing` | At most one per active writer role: bootstrap, owner, successor, caller-final. Its own failure causes no further log write. Existing bytes and unavailable tail are the outcome. |

Closed channel records retain the original failed or partial message in a charged
private object. Unknown senders cannot create unbounded refusal rows: the first
protocol violation closes that channel, then at most one closure observation is
retained. Signals are bounded per owned process by the fixed containment policy;
later duplicate notifications do not cause new records. Unknown descendants
are one unresolved set, not an unbounded discovered-PID log or signal target list.

## One-use pool and bounded costs

The pool is a precreated set of fixed-size regular slot objects in terminal
storage, plus immutable bootstrap objects and the original lock. Its private
layout maps each slot index to one opened object identity, maximum size and
permitted writer lane. Precreation, extent allocation and namespace metadata are
qualification obligations. A zero-filled slot is unused capacity, never a record.
The implementation may not replace, truncate, rename over, clone or grow a slot.
It writes only the selected frame prefix into that slot once, with positional
writes bounded by its fixed size. A short write or error ends this attempted
publication; it is not continued or retried as a second frame.

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
an even length. Odd slots permit only allocation fences (kind 6); even slots
permit every other allowed terminal kind. Bootstrap and final lanes cannot
publish fences. Select the next slot of the required kind, burning any skipped
slot. This makes a damaged non-fence slot distinguishable from a damaged fence
without trusting the damaged frame's header. Mark the chosen index consumed **before
any write call**. The first byte need not reach disk for that slot to be consumed.
Moving from history to tail irreversibly closes history. A successful publication
never releases a slot. A write failure consumes its full slot and closes scenario
eligibility; any later failure-handling record gets another allowed slot.

The slot's immutable layout entry is its assignment. There is no new assignment
record for each record write, and no allocation log that needs its own allocator.
Kind, generation, writer and slot in the attempted frame must match that entry.
The layout binds permitted roles; generation-open binds the actual owner token
before its other writes. Bootstrap preparation is never resumed after preparer
loss. The original caller retains its own role/token until its return; another
process cannot impersonate it by reading the layout.

On a normal handoff the caller burns all unused owner and successor slots before
using its final lane. On failed owner handoff it burns **both complete owner
ranges**, retaining their existing bytes. This is a range disposition, not a
physical overwrite. It enters the successor lane at its predetermined first
index. A caller already partway through that lane never restarts it. Caller death
or collection-successor loss ends recoverable work for this run. There is at most
one collection successor and no successor to the final caller. This follows the
finite caller trust boundary, and prevents endless recovery generations.

### Encoded and physical accounting

Let `n` bound all valid received submissions, including due ticks and collection;
`a` bound all assigned attempts; `w` bound worker reports; `h` bound process/holder
observations; `q` bound distinct priority controls; and `g` bound progress events
per attempt. Let `p,b,f,f_c,v,t` have the catalogue meanings. All are finite
whole-workload inputs, including failure branches. Counts do not come from
the number of successful captures. Distinguish `a` from complete commitments.

For each kind `k`, let `L_k` be its catalogue maximum. For example:

- Kind 6: `384 + 72 + 8 + 8 + 16 + 72 + 4 + 2*16 + 176 = 772` bytes.
- Kind 7: `384 + 16 + 8 + 72 + 4 + 3*16 + 2*72 + (4+168u) + (4+24*2) + 176 = 908 + 168u` bytes.
- Kind 8: `384 + 4 + 2*16 + 8 + 5*72 + 2*32 + 104 + (4+168u) + (4+80j) = 964 + 168u + 80j` bytes.
- Kind 28: `384 + 6*72 + 2*4 + (4+80j) = 828 + 80j` bytes.

`S = max(L_k)` over permitted terminal kinds is the minimum logical slot size;
rounding/allocation granularity can make the physical size larger. Backend kinds
14/15 use their attempt's separately bounded record objects. Select no numerical
`S` until all vector maxima are supplied. In particular 4096 is not a default.

A conservative catalogue count vector for kinds 1 through 29 is
`[1,p,1,b,2,f+f_c,a,4n,a,q,h,w,a*g,a,2a,a,a,a,2a,v,1,1,1,5t+3,1,1,1,1,4]`.
Kinds 14/15 are charged to attempts, not the terminal pool. `t` counts distinct
target/window pairs across the owner and caller windows; the extra three kind-24
rows cover lock/disposition observations. If the final implementation needs more
observations or compatible objects, expand the declared vector before startup;
do not silently exceed it. Lane-specific path maxima must still place these rows
in their actual normal/failure/recovery paths and include all attachment bytes.

For each reachable complete path, count every attempted terminal publication by
kind, including the write that fails, kind 20 observations, setup and kind 29.
Reserve `N_lane >= 2 * max_path(sum attempted rows in that lane)` slots for each
lane, with an even length. This pays for at most one skipped parity slot per
attempted row, including fences and the final unused parity slot. Slots use the
same maximum size even though their permitted kinds differ. Logical pool bytes are
`S * sum(N_lane)` plus bootstrap object bytes. This conservative maximum avoids
an unproved packing/reuse argument. The same path calculation reserves original
channel-frame objects, summaries, profile/registry objects and their prefixes.
Each object has one creation attempt and a fixed maximum; a failed prefix keeps
that full charge. A missing frame that was never received has no invented bytes.

For terminal physical capacity include the lock, slot directory tree, each
precreated slot, bootstrap/private-original objects and every permitted metadata
operation, in addition to rounded data extents. Write it as
`T_phys = T_data + M_lock + M_dirs + sum M_objects + M_updates + M_backing`.
No `M` is assumed zero. APFS/image/host allocation and copy-on-write costs need
qualified upper bounds; lack of such bounds keeps startup unavailable. No
checksum or row-count calculation supplies them. Partial bootstrap has its own
bounded preparation allocation and no resize/retry under this run identity.

Ordinary and collection charges separately include each attempted directory,
request/validation/result object, original control object owned by that attempt,
artifact, raw stream, retained prefix and simultaneous temporary object. Terminal
payload references do not move these bytes to terminal storage. Collection
directories are charged only to collection storage; terminal assignment and
commitment rows are charged only to terminal storage. Accounting cells repeat
the same charge ID/reference for explanation and never debit it a second time.

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
caller-final capacity. Refusal and unstarted cancellation have their own terminal
cost even when no operation is charged. The refusal's cost is reserved before
admission can be attempted; failure of that write is still unavailable.

One bounded kind-29 failure summary per failing writer path is the last optional
write about logging itself. Its failure emits no recursive summary. The writer
then attempts only already reserved, independently necessary stop/containment/
handoff records whose facts it can actually establish, each once. A terminal
capacity failure cannot spend collection bytes or reassign an old slot. Physical
I/O failure can defeat all remaining writes despite reservation; close eligibility
in memory and channels, preserve prefixes, and leave unavailable observations.

## Ordered writes and recovery

### Original owner operation

The following steps are serialized under the original writer lock. They do not
form a cross-volume transaction.

1. Verify root, original lock object, backing identities, complete bootstrap and
   owner generation. Acquire actual exclusive ownership and publish readiness.
2. Before consuming an ordinal, select a fresh slot, write a fence, and observe
   its required write/flush/visibility results. Fence width `W` is a positive
   profile parameter derived from the workload. Only one fence may be open.
   Its inclusive range starts at the previous valid upper frontier plus one.
   Do not consume its members after failed or unknown publication.
   Ordinary fences use width `W`. Collection fences use one ordinal and bind
   one immutable collection-plan item, so a failed owner cannot obscure which
   collection item may already have run.
3. Drain failure/stop controls; recheck eligibility, deadlines, identities and
   resource/tail capacity. Assign the next ordinal, directory and operation token,
   and debit the full operation contribution in memory. This is irreversible.
   Publish kind 7 before creating any attempt directory. An error retains the
   charge/ordinal; a crash may leave their individual facts unknown.
4. Create the exact assigned directory once in ordinary or collection backing.
   Retain its identity and creation result in the commitment's referenced bounded
   observation object. Existing or mismatched objects are failure, never adoption.
   Publish kind 9 and observe its required publication results before child
   creation. Failure at any point prevents launch and all later scenario work.
5. The backend receives this assigned directory/ordinal and inherited lock. It
   cannot scan roots, allocate an ordinal or launch from a binding alone. Observe
   actual setup, process, collector, validation, result and reap facts separately.
6. Complete the offer/acknowledgement/terminal/send/echo protocol and original
   deadlines. Failed publication after payload receipt still blocks later input.
   A new ordinary fence is permitted only after the current one is exhausted and
   every assigned predecessor is settled. On irrevocable scenario closure, the
   first collection fence can instead retire the unused ordinary suffix: its
   `retired-unused-lower` names that suffix, ending at the prior fence's upper
   bound. No charge is created for that suffix. Later collection fences name
   the next unattempted applicable plan item; no normal owner restart exists.

Write-result observations required for dependent work must be both observed by
the live writer and retained in the next semantic record (or kind 20). A record
can say what was requested for itself but cannot predeclare its own successful
flush. Recovery treats unrecorded flush success as unknown. Readability on the
still-mounted system supplies only a later visibility fact.

### Collection-only entry

The original finite caller stops scenario activity on owner failure. It resolves
actual owned holders under the one existing containment window. PID text, a
zero exit from an unrelated process, missing files or a newly created lock do
not establish ownership. It must actually acquire the **same original lock
object** after positively settling known holders. Unknown descendants or inherited
holders keep containment unresolved even if a lock API reports acquisition.
No caller evidence writes occur concurrently with the owner/backend. If it cannot
acquire that lock, its final persistent tail can remain unavailable.

Under that lock the caller checks the complete immutable root/profile/pool and
physical object identities, and reads the bounded full predecessor ranges. It
does not stop scanning at the first empty slot. The declared upper bound makes
this scan finite. Validate every nonempty frame and its allowed lane, identity,
predecessors and references; retain all invalid bytes and missing joins.

The complete bootstrap supplies the genesis frontier zero. Before any fence,
recovery can therefore start at ordinal 1. The first fence has an inapplicable
prior-fence reference and references setup publication. A structurally complete,
properly linked fence whose own flush outcome was not retained can supply a
conservative upper frontier to burn; it cannot establish a successful prior
publication or any clean attempt.

The caller can recover only if it can establish a unique valid ordinal frontier.
Every attempted fence must be either complete and validated or demonstrably
absent without a dependent assignment. Any nonempty torn/invalid fence, conflicting
fence range, broken fence predecessor, foreign generation or indistinguishable
damaged slot that might be a fence prevents allocation. An all-zero slot alone
does not prove no write: the qualification assumption below must establish that
successfully published dependent records cannot vanish during this process-loss
model. If that assumption is unavailable, recovery is unavailable.

Burn every unused or uncertain member of the last valid fence; the new ordinal
starts strictly after its upper bound. Also retain all known earlier assignments
and charges. A missing kind-7 write may hide whether charging occurred. Record
that subset as unknown and conservatively keep the prior ordinary allowance
unavailable; do not synthesize a per-operation charge, refund, replacement
ordinal or proof of execution. Recovery has its own separately prebudgeted
collection path. It can proceed despite an unfinished failed ordinary attempt
only after holder resolution, with that attempt and its uncertainty retained.

Burn the failed writer's slot ranges, write kind 25 in the predetermined successor
lane, then kind 5 in collection-only mode. If either write fails, do not allocate
a new fence or dispatch collection. No second entry attempt is allowed. The
original caller owns the successor role; it creates no replacement scenario
owner or worker. Its fresh generation token is never reused. It uses a new
fence beyond the established frontier, the same global ordinal sequence and
the exact collection-backed directories. Each collection item has a disjoint
prebudgeted contribution and one immutable plan index. A valid predecessor
collection fence makes its named item possibly attempted even when binding is
missing. Withhold that item's allowance as uncertain, without inventing a known
charge, and never reissue it. Retain any known result. Only an applicable suffix
proved never fenced can dispatch; a torn collection fence prevents proving that
frontier and refuses further collection. No second full collection set is created
by recovery. Preserve unavailable earlier items and the untouched
observer/window/screenshot order and exact-clone
stop plus independent inventory. Neither held-pointer case permits release input.

At final transfer, burn unused successor slots and use the caller-final range
under the same lock. The caller records owner response/channel/wait observations
and one final outcome. If it dies or the final write fails, the unknown tail is
terminal. Existing files cannot establish its later return or acceptance.

### Ambiguity table

| Observed condition | Required disposition |
|---|---|
| Empty slot before the first write, or death between in-memory slot consumption and first byte | Preserve it and burn the failed lane. Never infer that it is reusable. No fabricated event is added. |
| Short/torn frame or checksum/length failure | Retain the full real slot and prefix. Mark the event unavailable. If it could hide a fence or destroys the unique frontier, refuse new ordinals. |
| Complete duplicate record, repeated submission, reused slot or conflicting binding | Protocol failure; no idempotent success. Conflicting allocation evidence refuses recovery. Copying a valid frame into another slot fails identity checks. |
| Stale generation, root/pool mismatch or replaced backing/lock | Refuse recovery and later slots. Do not unlink, remount into another identity or create another writer domain. |
| Complete fence; death before or during assignment/binding | Burn the fence remainder. Preserve known charges and mark hidden assignment/charge facts unknown. No launch from the fence. |
| Complete binding; empty or partial directory | Retain assignment/charge and exact backing. Never recreate the directory under the old ordinal; no child launch. |
| Directory exists; commitment absent or torn | Retain directory and charge. Live failure before launch knows not-started; post-death launch can remain unknown unless actual evidence establishes it. |
| Commitment complete; backend creation/launch evidence absent | Intent only. Do not infer no execution or resend. Resolve holders before collection. |
| Handoff present; owner wait or final caller write absent | No final acceptance. Preserve actual available response and wait observations separately. |
| Last fence upper frontier or required layout identity unavailable | No new ordinal, collection command or exact-clone command through another domain. Retain unresolved containment and block every later slot. |

## Assumptions and guarantees

The protocol guarantees one-use allocation **conditional on** a cooperating
implementation and the following still-unestablished mechanism prerequisites.
Failure of a prerequisite is an unavailable profile or recovery, not permission
to weaken its guarantee.

| Prerequisite | What must be established; what is not inferred |
|---|---|
| Original lock and identity | Actual exclusivity across intended inherited holders, descriptor lifetime and reliable opened-object identity. Merely retaining its pathname is insufficient. |
| Bounded original pool | Fixed object identities/sizes, no replacement or unintended resize, complete bounded scan and protection of remaining class capacity/metadata. Precreation alone proves none of these. |
| Process-loss visibility | On the supported still-mounted healthy system, a completed required publication and dependent ordering remain visible after process loss; a partial write cannot silently become a different valid record. Establish the actual write, flush, read and identity behavior used. |
| Ordering and flush | The selected calls and observed outcomes precede dependent directory/launch work. No atomic multi-record, cross-volume or rename transaction is assumed. Failed/unknown flush prevents dependent work. |
| Damage detection | SHA-256/length/identity checks detect accidental mismatches within the declared fault model. This is not protection against a malicious same-user writer or proof of non-collision. |
| Bounded parser and channel retention | Declared frame/object/count/peak-memory limits apply before allocation, including incomplete reads, digests and recovery scans. No unbounded JSON/parser expansion behind a length check. |
| Private backing and metadata | The three backing identities, host/image allocations, directory/object/update costs and protected ordinary/collection/terminal separation have qualified bounds. Shared-device loss can make all classes unavailable. |

Power failure, device loss, remount recovery, hostile mutation and filesystem
rollback are outside this process-loss claim. They can make the upper frontier
unavailable. A passing S1/S3 fixture does not extend the claim to them. No storage
call, checksum, extent reservation or finite process-loss test proves universal
durability or available cleanup.

The one-use lanes avoid an atomic persistent slot counter, at the cost of unused
retained capacity and no second recovery generation. A mutable high-water file
would be smaller but needs an atomic update/recovery proof not supplied here.
A separate allocation log would recreate the same allocation problem. Scanning
ordinary and collection roots would duplicate allocation authority and lose
charged-but-unpublished assignments. Revisit the lane choice only with a complete
bounded alternative and corresponding review; do not silently add slot reuse.

## Checkable walkthroughs

These are symbolic protocol traces, not executed coordinator or storage results.

**Clean capture.** Bootstrap and generation opening complete. Fence `[a,b]`
publishes. Received/admitted submission `s` has no ordinal or operation charge.
The transition assigns `a`, debits its contribution and publishes binding, creates
its ordinary directory and publishes commitment. Backend/collector/validator
events, complete result and actual reap precede offer/ack, terminal disposition
and completion send. The worker echoes receipt before its next sleep. Clean
stop later joins intent, exact ack and observed reap. Owner handoff precedes the
caller's lock transfer, owner-exit record and final outcome. Every row/object
costs capacity, including clean phase reports and the caller tail.

**Failed commitment publication.** The owner has charged `a`, published binding
and created its directory. The commitment write retains a real prefix and fails.
That slot, ordinal and full charge remain consumed; backend invocation count is
zero on this live controlled branch. No result bytes or later successful cleanup
can permit scenario input. One bounded write-failure summary, stop and containment
use their reserved slots where writable. If the owner then dies, recovery does
not rewrite commitment or refund `a`. It burns through `b` and marks the failed
event unavailable. Its even slot identifies a non-fence independently of the
damaged bytes. An invalid pool map or a damaged odd fence slot instead makes
the frontier unavailable and refuses collection.

**Collection after owner death.** A known child still holds the original writer
descriptor, so the caller initially cannot acquire it. The child is resolved
under the existing containment policy; an observed exit is not invented for a
grandchild. After actual original-lock acquisition and holder/identity checks,
the bounded scan validates the unique last fence `[a,b]`. The caller burns both
owner slot ranges and unresolved ordinals through `b`, preserving all partial
objects and unknown charges. It writes recovery and collection-generation rows,
then a new fence starting `b+1`. Binding and directory creation for the first
collection command use terminal and collection capacity respectively. Required
collection order, exact stop and inventory keep separate outcomes. Any unresolved
holder, torn fence, missing backing or failed recovery write ends this trace
before a collection command. Final caller loss never starts another recovery.

## Later controls and remaining inputs

The [qualification plan](../verification/settings-activation/KEEPALIVE-QUALIFICATION.md#storage-and-process-loss-controls)
owns S1 and the existing S2–S6 case groups. The table below refines later
real-coordinator coverage; it does not add executed cases to the 13-case native
mechanism envelope or claim the old 18-case S count covers every expanded row.
The complete-profile task must enumerate a finite implementation suite and its
actual process overlap before requesting any separate execution scope.

| Boundary / later control | Approved enabling point and required discrimination |
|---|---|
| Encoding and S2 catalogue | Real encoder/decoder and original-lock coordinator; declared finite fixture inputs. Every kind, missing/zero/unknown/inapplicable value, maximum and one-past length/count, wrong version/type/digest/predecessor and duplicate/stale slot. No allocator substitution. Verify exact size formula and actual bytes. |
| S2 clean/failure accounting | Real charge/tail calculation plus approved owner capacity observations. Enumerate each attempted row and private object, including kind 20/29, partial setup, refusal, cancellation and charged-unpublished attempt. Exhaust history with tail intact; reject borrowing each other lane/class and recycling clean rows. |
| S3 slot consumption | Approved owner/caller barriers and named write results: stop before slot choice, after choice before first write, after a real prefix, after full write before flush observation, and after observation before dependent record. End the directly owned writer once per declared case. Burn empty uncertainty without rewriting it. |
| S3 fence/assignment/directory/commitment | Preserve the eight named S3 schedules; add declared boundary subcases where needed. Failure before write performs no write; partial failure retains exactly the declared real prefix. For every required write/flush observation assert zero dependent directory creation or child launch when failed/unknown. |
| S3 recovery entry and final lane | Real original lock plus audited caller barriers/write results before/after recovery and generation rows, at new fence, and at final transfer. No second recovery attempt after a failed entry or caller death, no duplicate ordinals or synthesized charges. |
| S4 delivery/final joins | Keep its four cases, and enumerate result offer/ack/terminal/send/echo and kind 27/28 failures against the schema. Complete-looking remaining rows must not permit another scenario action or final acceptance. |
| S5 holder/backing/frontier | Controlled child retains the real inherited descriptor. Mismatched capacity/identity result uses the approved copied observation. Finite declared malformed slot fixtures exercise empty, torn, duplicate, stale and ambiguous frontier cases; no live-volume corruption or lock deletion. Unknown ownership never authorizes a signal. |
| S6 protected writes | Real collection directory and terminal slot prefix under the approved write-result seams. Preserve the old prefix and independent status when later protected publication fails. Kind 29's failure generates no kind 29 recursion. |
| R setup/progress/settlement | Existing backend limit-call/readback and owner capacity/write-result seams. Commitment has no fabricated setup fact. Raw/producer/collector failures stay separate from successful process status; all originals retain their own class and bound. |
| Collector R3/R5 | Only the approved separately audited R3 pre-read barrier and R5 raw-storage write-result sites. R3 releases without waiting for blocked writers. R5 is failure before write or **exactly 1024 real persisted bytes then failure**. Neither substitutes the kernel queue/native bounds or authorizes another collector site. |
| Lifecycle, signals and input | Owner/backend/caller audited barriers/clock plus controlled CLI/sleep. Include every stop race, INT/TERM/HUP, orphan loss, both held-pointer cases, unavailable lock and no release input. Preserve original containment deadlines and collection order. |

All copied sites require correspondence audits and must fail for missing,
duplicated, unexpected or unused controls and unrelated source changes. Controls
run after implementation and before downstream consumption. They test handling;
native storage/queue/codec/service qualification remains separate. Source-only
diagram, formula and link checks performed during design are not these results.

The full profile still owes exact `n,a,w,h,q,g,p,b,f,f_c,v,t`, all vector/object
maxima, tail-state tables, fence width, slot size/counts, physical metadata costs,
message/parser/scan peak memory and complete useful fit. It also owes start queue
and boot timing, post-start uploads, all ticks and collection, dependency issue
#13's evidence, every R/S expansion and whole-design reconciliation. Missing
inputs keep startup unavailable. All original parent duties and runtime holds
remain live.
