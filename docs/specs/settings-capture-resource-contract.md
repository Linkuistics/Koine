# Settings capture resource contract

## Problem and agreement

The Settings command owner must bound capture work before it allocates or writes,
while preserving the existing TestAnyware capture, input and OCR behavior. The
[enforcement survey](../research/settings-keepalive-enforcement-a.md#capture-allocations-before-checks)
finds that the inspected producer cannot provide that contract unchanged.

Antony approved the bounded-producer design path on 2026-10-31. This is Koine's
required dependency interface, not an implemented TestAnyware API or a selected
release. Approval covers this design work and a separately reviewed proposal for
native/storage qualification. External implementation, issue filing and native
execution have not been authorised. The [owner design](settings-keepalive-owner.md)
continues to prohibit startup without the complete enforceable useful profile.

## Responsibility and interface

The owner is the only writer/ordinal authority. Admission checks capacity without
an operation charge. At commitment the owner repeats that check, irrevocably
charges the operation, assigns its backing storage and records commitment before
creating the backend. The backend launches one producer for that commitment. The producer
cannot choose another root, ordinal, storage class, capture scale or resource
profile, and cannot borrow protected collection or terminal capacity.

Use one immutable **bounded operation request**, validated before connection or
payload processing. It is an internal versioned contract between the owner-side
launch adapter and the selected dependency. Its transport and CLI spelling belong
to the dependency design; Koine must not depend on a collection of independent
environment defaults. The request is bounded in representation before parsing.
Its maximum representation, bootstrap memory and diagnostic cost are explicit
profile inputs, not exemptions from accounting.

| Request group | Required values and meaning |
|---|---|
| Identity | Contract version, profile identity, root/generation/operation binding, selected producer build and supported resource contract. An unknown version, missing field or mismatched binding refuses the operation. |
| Operation | The already selected command, arguments, capture coordinate space, scale behavior, region if any, and existing OCR polling policy. Resource fields do not alter any of these. |
| Geometry | Independent maximum wire width/height/pixels, selected-frame dimensions/bytes and region dimensions/bytes. All products and rectangle endpoints use checked arithmetic before allocation or indexing. |
| Wire work | Per-message and cumulative bytes, message/rectangle counts, handshake/error/clipboard/name limits and the original absolute deadline. Persistent decode state belongs to the same operation budget. |
| Decode | Compressed input, inflated intermediate, reconstructed pixel and codec-workspace capacities for each accepted encoding. An aggregate bound cannot replace these units. |
| Capture/encode | Wire frame, selected owned frame, crop, encoder rows/state, compressed intermediates, outer PNG and total simultaneously owned capacity. Record both length and capacity limits where they differ. |
| Output | Assigned artifact objects, maximum bytes per object, aggregate bytes and object count, bounded stdout/stderr and diagnostic/result bytes. Ordinary and collection operations have distinct assignments. |
| Time and containment | Original continuous-clock/boot identity and absolute deadline, applicable process/native boundary and the separate launcher evidence reference. Producer progress cannot extend the deadline. |

Every limit is a finite integer in a declared unit. Missing, overflowed,
contradictory or unsupported values refuse use; zero is not an unlimited sentinel.
The final profile must explicitly represent a disallowed unit. Validate internal
relationships, including frame products, phase peaks and output totals, before
processing external data. A request is a declaration of the required bounds;
successful parsing or a producer's acknowledgement is not enforcement evidence.

The producer returns a bounded **operation observation**: request/profile/build
identity, setup outcome, first failure, stage/unit, requested quantity if known,
enforced bound, actual byte/object counts, retained output bindings, and explicit
unknowns. Error codes and bounded fields take the place of arbitrary remote text
in this record. Original raw streams remain separately retained. Native crash,
signal, timeout or output failure may leave no complete observation. The backend
then records what it actually knows; it never synthesises producer success.

## Enforcement inside the producer

Each accepting path must check the relevant unit before allocating, growing,
copying or writing it. The chosen dependency must supply evidence for the
allocation primitive's requested and actual capacity, including alignment and
temporary overlap. Checking a vector's length after growth is insufficient.
Fixed-capacity storage or a capacity-aware allocator can implement the contract;
an unchecked library allocation cannot be charged retrospectively as enforcement.

| Boundary and owner | Required behavior before work | Required refusal behavior |
|---|---|---|
| Connection/handshake reader | Bound variable-length reasons, names and security negotiation, plus parser/read-ahead buffers. Apply byte/count/deadline allowances even on discarded or error messages. | Do not allocate the advertised excessive length, drain an unbounded remainder or echo arbitrary text into diagnostics. |
| Framebuffer manager | Validate initial and resized geometry, checked byte products and source/destination rectangles before payload storage or frame allocation. Reserve the simultaneous old/new frame peak before resize. | Keep existing evidence; do not resize down or reinterpret a rejected update as a usable capture. |
| Raw and CopyRect decoder | Raw payload fits the rectangle, wire and output budgets before read/allocation; CopyRect validates both ranges before copying. | Reject the malformed or over-budget operation without a corrective input or another capture. |
| ZRLE decoder | Bound compressed storage, persistent inflater state, each inflate chunk, total expansion, tile scratch and decoded output before growth. Validate tiles within those limits. | No final oversized chunk appended before checking. No reset/retry to make the same request fit. |
| Tight basic/fill/palette/gradient decoder | Account for persistent streams, compressed input, indices/palette, reconstruction and output capacities at their overlapping phases. | A protocol field maximum or expected final length cannot authorise a larger intermediate allocation. |
| Tight JPEG decoder | Validate header geometry before output allocation and constrain input, decoder workspace and decoded capacity before the library consumes them. | An output-only library setting cannot stand in for earlier workspace limits. If any required path lacks a bound, the dependency cannot qualify that encoding. |
| Capture selection | Reserve selected-frame capacity while retaining the wire frame. Preserve logical/physical scale behavior and existing held-frame fallback. | No extra downsample, skipped due capture or fallback caused by a resource failure. |
| Crop and PNG encoder | Validate the region against the acquired frame; bound crop, row/state, compressor output, outer PNG and fallback-compressor overlap before allocation/growth. | No unbounded vector behind a bounded file writer. No recompression or lower quality selected to evade a refusal. |
| Native OCR adapter | Bound each owned PNG copy, native-input copy and result collection; identify native image/recognition/device/service work separately. Retain the selected OCR engine and polling semantics. | Unsupported native coverage keeps the complete profile unavailable. A measured successful OCR call is not a hard native bound. |
| Output writer | Use only assigned objects and check the next write against per-object and aggregate budgets before issuing it. Include temporary objects and raw/error/result output. | Retain the real written prefix on short write or failure; never delete, truncate or overwrite an earlier artifact to recover capacity. |

All accepted encodings remain in scope. Removing JPEG, changing the negotiated
encoding set, replacing OCR, or changing the existing scale/held-frame behavior
requires a separate requirements decision. A codec with no suitable pre-allocation
interface needs dependency work; it is not silently bypassed. Bounded owned
memory does not establish loader, allocator metadata, native/device memory or
aggregate process/service containment.

### Capacity and lifetime

The profile accounts for overlapping **capacities**, not only final lengths.
During selection it contains the retained wire frame and selected owned frame.
During encoding it contains those frames, crop, rows/state, compressed and outer
PNG buffers, plus any simultaneous fallback compressor. Resize contains old and
new frames until the old allocation is actually released. Decode includes its
applicable intermediates and persistent streams. OCR includes every live copy,
native work and retained result. A maximum over justified phases avoids summing
mutually exclusive temporaries, while a live buffer crossing phases remains
charged in each phase.

Reusable in-process scratch capacity may be reused only after its lifetime ends.
This does not refund the owner's irrevocable operation charge or retained storage.
Unknown allocator slack, bootstrap cost or native peak remains unknown. The
24,883,200-byte two-frame-plus-crop example in the survey is not a useful profile.
Numerical values must follow the complete workload and qualified implementation.

### Time, failures and retention

The owner keeps its absolute deadline across setup, input, decode, native work,
write, validation and publication. Cooperative checks before reads and work
chunks supplement the owner's independent supervision; they do not guarantee
that a synchronous native call stops. Mid-message deadline cancellation ends
that operation and connection. It must not resume a half-consumed parser, retry
transport or classify resource expiry as the existing clean held-frame timeout.

Assigned output objects have stable identity and one owning attempt. A suitable
dependency interface accepts owned output handles or an equivalently constrained
writer; unrestricted default paths and delete-on-error temporary downloads do
not meet this contract. The interface must preserve partial downloads as well as
captures. A failed partial remains attached to its original attempt. No second
output pathname or replacement artifact conceals it. Actual file-write, flush
and observation failures remain distinct; a receipt does not invent durability.

If a raw stream reaches its bound, the operation fails at the write boundary.
The writer must not silently discard bytes and report success. The returned
failure, retained prefix and unknown later bytes remain explicit. Separate
protected capacity supports the backend and owner failure records where writable;
it is never an extension of the producer's output allowance.

Resource failure is sticky and preserves the first failure. It does not trigger
another capture, input release, reconnect, polling attempt, revised cap or
collection dispatch. The owner settles delivery/validation/publication using its
existing protocol and decides collection only after exact writer containment.
The producer cannot certify owner eligibility or normal stop.

## Approved Koine test controls

Antony approved resource-result substitutions on 2026-10-31, in addition to
audited phase barriers and the continuous-clock reader. The enabling point is
an audited copy of the responsible owner, backend or caller module, selected
only by the offline test harness. No production switch or allocator replacement
is introduced. The test still executes the real coordinator's transitions,
locking, charge calculation, publication sequence and failure propagation.

| Named copied boundary | Controlled result | Required real observation |
|---|---|---|
| Owner admission capacity query | Available, insufficient or unavailable identity/capacity | No capture charge or ordinal for refused/pending-cancelled work; terminal-record allowance remains required. |
| Owner commitment capacity recheck | Changed capacity/identity after admitted work waits | Actual recheck refuses before assignment/charge/attempt creation; a later success does not reopen eligibility. |
| Backend launcher setup call/readback | Setup failure or unavailable/mismatched observation | The existing commitment and charge remain; zero external invocations on setup refusal; no installed-limit fact is backfilled into commitment. |
| Owner allocation fence/binding writes | Error before write or failure after a real retained prefix | No dependent attempt creation, commitment publication or child dispatch; uncertain consumed ordinals stay burned under the eventual recovery protocol. |
| Owner lifecycle/disposition/handoff writes | Named write failure | Earlier evidence remains intact, missing terminal facts stay unavailable, and the submitter cannot infer permission to continue. |
| Backend attempt directory/raw/artifact/receipt writes | Create/write error, or real prefix followed by failure | Original prefix/partial object and attempt identity remain; failure settles once, with no retry or later scenario dispatch. |
| Caller owner-exit/final-outcome writes | Named final publication failure | Actual observed child facts remain distinct from the unavailable final record; exit zero alone cannot complete the run. |

The harness identifies a substitution by module, named boundary and invocation
within the assigned operation/lifecycle event. Missing, duplicated, unexpected
or unused control sites fail the test. Each copied module is compared with its
pinned production source; only the declared barrier, clock and named result-site
changes are allowed. Any other byte difference fails the correspondence check.
Copy production again when it changes; do not maintain a second coordinator.

A failure-before-write control performs no write. A partial-write control writes
the declared finite prefix to the real isolated test object and then reports the
matching failure at that boundary. It must not fabricate bytes, claim a successful
write that did not happen, truncate an earlier result or skip the real error
handling. A successful path uses actual writes. Tests retain the control manifest
and source/copy identities separately, so substituted observations cannot be
misread as native mechanism evidence.

Controls cross admission, commitment, creation, launch, validation, publication,
normal-stop races, signals, owner loss and both held-pointer cases from the owner
spec. Inject failure before and after each relevant ownership transition and
observe invocation counts, immutable event/ordinal relations, retained bytes,
cancelled work, first failure and later-dispatch refusal. The final schema must
map every named write boundary to a row; this contract does not invent that schema.

Discriminating mutants include charging at admission; omitting the commitment
recheck; refunding a failed operation; borrowing terminal capacity; dropping a
partial; treating readback as capability proof; dispatching after a failed fence;
accepting a missing final record; and accepting a test copy with an unrelated
edit. Each must fail the corresponding control. These are obligations for future
tests, not tests executed by this design session.

The approved substitutions qualify **failure handling only**. Producer guard
tests require the real dependency with finite protocol fixtures; they must
observe rejection before the actual allocation/write and unchanged in-budget
pixels/behavior. This design adds no copied-producer allocator seam. Native
limit, storage reservation and codec/service coverage need their own evidence.

## Alternatives and costs

Inherited limits with the unchanged producer minimise dependency changes but
fail the required per-unit contract. A separate adapter which checks only CLI
input or the completed PNG cannot see allocations inside the decoder. Isolation
may add aggregate containment but does not supply individual geometry/codec
checks or preserve native behavior by itself.

The selected design gives allocation knowledge to the producer and retains
cross-operation accounting in the owner. Callers supply one request rather than
reconstructing buffer lifetimes or independently setting limits. The cost is
dependency/codec work, a verified launch adapter, output-interface migration and
copy auditing in Koine tests. Internal codec state still requires implementation
evidence; a smaller interface alone does not make that state simpler.

A conforming unchanged dependency or a qualified equivalent boundary that
preserves every unit and behavior could reverse the need for dependency changes.
No such evidence was established. Merely fitting one observed image or returning
the configured limits is not that counterexample.

## Remaining qualification and adoption

This contract supplies no selected producer build, launcher/map floor, numeric
useful limits, protected storage arrangement, recovery schema or full-run
duration/tick budget. VM-start queue/boot containment, uploads and the complete
collection/final tail remain part of the whole owner design. The separate
qualification proposal must expose these dependencies and name exact finite
subjects before requesting any execution authority.

Review this contract independently before consuming it in that proposal.
External implementation belongs to TestAnyware's owner. Its reviewed evidence
must return to Koine before the final profile and independent whole-design
review. Planning, implementation and every earned review/integration still
precede adoption. No resource refusal, successful fixture or approved test
substitution permits a VM/candidate/freeze/acceptance run or closes an ancestor.
