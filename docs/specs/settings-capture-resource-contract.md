> **History.** The ADR [settings harness takes no keepalive captures](../adr/settings-harness-takes-no-keepalive-captures.md)
> rejects the keepalive owner design. This document belongs to that design. It is
> now a historical record and binds no current work.

<!-- tc: off because this historical record keeps its original text -->

# Settings capture resource contract

## Problem and agreement

The Settings command owner must bound capture work before it allocates or writes,
while preserving the existing TestAnyware capture, input and OCR behaviour. The
[enforcement survey](../research/settings-keepalive-enforcement-a.md#capture-allocations-before-checks)
finds that the inspected producer cannot provide that contract unchanged.

Antony approved the bounded-producer design path on 2026-10-31. This is Koine's
required dependency interface, not an implemented TestAnyware API or a selected
release. Approval covers this design work and a separately reviewed proposal for
native/storage qualification. On 2026-11-01 Antony also approved filing the bounded
dependency design/evidence request, now [TestAnyware issue #13](https://github.com/Linkuistics/TestAnyware/issues/13).
External implementation and native execution remain unauthorised. The [owner design](settings-keepalive-owner.md)
continues to prohibit initialisation without the complete enforceable useful profile.

## Responsibility and interface

The owner is the only writer/ordinal authority. Admission checks capacity without
an operation charge. At commitment the owner repeats that check, irrevocably
charges the operation, assigns its backing storage and records commitment before
creating the backend. The backend launches one producer for that commitment. The producer
cannot choose another root, ordinal, storage class, capture scale or resource
profile, and cannot borrow protected collection or terminal capacity.

Use one immutable **bounded operation request**, checked before connection or
payload processing. It is an internal versioned contract between the **producer
launcher** and the selected dependency. Its transport and CLI spelling belong
to the dependency design. Koine must not depend on a collection of independent
environment defaults. The request is bounded in representation before parsing.
Its maximum representation, bootstrap memory and diagnostic cost are explicit
profile inputs, not exemptions from accounting.

| Request group | Required values and meaning |
|---|---|
| Identity | Contract version, profile identity, opaque operation token, selected producer build and supported resource contract. An unknown version, missing field or mismatched binding refuses the operation. |
| Operation | The already selected command, arguments, exact target, capture coordinate space, scale behaviour, region and existing OCR polling policy. Resource fields cannot change these values. |
| Producer behaviour | Ordered encoding proposal, permitted encoding set, OCR engine identity and execution mode, declared child/interpreter identities, and launch-environment identity. These describe the selected behaviour, not permission to change it. |
| Geometry | Independent maximum wire width/height/pixels, selected-frame dimensions/bytes and region dimensions/bytes. All products and rectangle endpoints use checked arithmetic before allocation or indexing. |
| Wire work | Per-message and cumulative bytes, message/rectangle counts, handshake/error/clipboard/name limits and the original absolute deadline. Persistent decode state belongs to the same operation budget. |
| Decode | Compressed input, inflated intermediate, reconstructed pixel and codec-workspace capacities for each accepted encoding. An aggregate bound cannot replace these units. |
| Capture/encode | Wire frame, selected owned frame, crop, encoder rows/state, compressed intermediates, outer PNG and total simultaneously owned capacity. Record both length and capacity limits where they differ. |
| Output | Assigned artifact objects, per-object and aggregate byte limits, object count and producer-controlled diagnostic/result limits. Separate backend stdout/stderr limits cover all descriptor output. Ordinary and collection operations have distinct assignments. |
| Time and containment | Original continuous-clock/boot identity and absolute deadline, applicable process/native boundary and the separate launcher evidence reference. Producer progress cannot extend the deadline. |

Every limit is a finite integer in a declared unit. Missing, overflowed,
contradictory or unsupported values refuse use. Zero is not an unlimited sentinel.

The final profile must explicitly represent a disallowed unit. Check internal
relationships, including frame products, phase peaks and output totals, before
processing external data. A request is a declaration of the required bounds.
Successful parsing or a producer's acknowledgement is not enforcement evidence.

The dependency declares each internal allocation unit in its resource-contract
version. Koine pins that version and the profile's values for its declared units.
A changed unit schema requires a new version. A version mismatch refuses use.
The owner still declares outer workload and aggregate limits. It cannot infer
codec units from an older build or replace them with one outer byte ceiling.

The owner issues the opaque operation token for its root, generation and operation.
Only the retained owner/backend binding resolves that token. The token and producer
observation never contain the private evidence-root path. Assigned output objects
use opaque identities or handles. Private path mappings remain in owner/backend evidence.

The producer launcher constructs a bounded, explicitly declared environment.
It does not inherit undeclared variables from its parent. The declaration fixes
each permitted variable's value or absence, including behaviour and target selectors.
The launcher checks it before execution. The producer checks effective selectors
against the request before connection, child creation or payload processing.
A mismatch or undeclared selector refuses the operation without fallback.

At the inspected pin, relevant selectors include `TESTANYWARE_RFB_ENCODING`,
`TESTANYWARE_OCR_FALLBACK`, `TESTANYWARE_OCR_PYTHON` and `TESTANYWARE_APP_SOCKET`.
This list is source evidence, not an exhaustive allowlist for a future build.
That build must declare its complete environment contract, including bootstrap selectors.
The request binds the encoding proposal before connection. Later observations
record the encodings actually used, which must belong to the permitted set.
An unsupported path fails rather than changing the proposal or reconnecting.

The engine declaration distinguishes in-process Vision from a daemon child.
It identifies any interpreter, child and service contribution that the profile must cover.
The launch observation records the actual environment identity and comparison outcome.
Exact environment values stay in bounded private evidence, referenced by opaque identity.
No public diagnostic dumps the environment or private paths. This binding does not
authorise an encoding, OCR-engine or target change to make a profile fit.

The producer returns a bounded **operation observation** with request/profile/build identity, setup outcome, first failure, stage/unit and requested quantity if known. It also records the enforced bound, actual byte/object counts, retained output bindings and explicit unknowns. Error codes and bounded fields take the place of arbitrary remote text
in this record.

Original raw streams remain separately retained. Native crash,
signal, timeout or output failure may leave no complete observation. The backend
then records what it actually knows. It never synthesises producer success.

## Enforcement inside the producer

Each accepting path must check the relevant unit before allocating, growing,
copying or writing it. The chosen dependency must supply evidence for the
allocation primitive's requested and actual capacity, including alignment and
temporary overlap. Checking a vector's length after growth is insufficient.
Fixed-capacity storage or a capacity-aware allocator can implement the contract.
An unchecked library allocation cannot be charged retrospectively as enforcement.

| Boundary and owner | Required behaviour before work | Required refusal behaviour |
|---|---|---|
| Connection/handshake reader | Bound variable-length reasons, names and security negotiation, plus parser/read-ahead buffers, colour maps and clipboard text. Apply byte/count/deadline allowances even on discarded or error messages. | Do not allocate the advertised excessive length, drain an unbounded remainder or echo arbitrary text into diagnostics. |
| Framebuffer manager | Check initial and resized geometry, checked byte products and source/destination rectangles before payload storage or frame allocation. Reserve the simultaneous old/new frame peak before resize. | Honour valid server resizes, including smaller geometry. Do not shrink or downsample a rejected frame to fit a budget or call it usable. |
| Raw and CopyRect decoder | Raw payload fits the rectangle, wire and output budgets before read/allocation. CopyRect checks both ranges before copying. | Reject the malformed or over-budget operation without a corrective input or another capture. |
| ZRLE decoder | Bound compressed storage, persistent inflater state, each inflate chunk, total expansion, tile scratch and decoded output before growth. Check tiles within those limits. | No final oversized chunk appended before checking. No reset/retry to make the same request fit. |
| Tight basic/fill/palette/gradient decoder | Account for persistent streams, compressed input, indices/palette, reconstruction and output capacities at their overlapping phases. | A protocol field maximum or expected final length cannot authorise a larger intermediate allocation. |
| Tight JPEG decoder | Check header geometry before output allocation and constrain input, decoder workspace and decoded capacity before the library consumes them. | An output-only library setting cannot stand in for earlier workspace limits. If any required path lacks a bound, the dependency cannot qualify that encoding. |
| Capture selection | Recheck current geometry, derived scale and selected-frame capacity at every capture, including each OCR poll after resize. Reserve capacity while retaining the wire frame. Preserve logical/physical selection and held-frame fallback. | No extra downsample, skipped due capture or fallback caused by a resource failure. |
| Crop and PNG encoder | Check the region against the acquired frame. Bound crop, row/state, compressor output, outer PNG and fallback-compressor overlap before allocation/growth. | No unbounded vector behind a bounded file writer. No recompression or lower quality selected to evade a refusal. |
| Native OCR adapter | Bound owned PNG copies, native-input copies and result collection. Identify native image/recognition/device/service work separately. Use the request's OCR engine and unchanged polling semantics. | Unsupported native coverage keeps the complete profile unavailable. A measured successful OCR call is not a hard native bound. |
| Output writer | Use assigned objects and check per-object and aggregate budgets before each write. Include temporary objects and producer-controlled structured diagnostics/results. The backend separately bounds all raw descriptor output. | Retain the real written prefix on short write or failure. Never delete, truncate or overwrite an earlier artifact to recover capacity. |

All accepted encodings remain in scope. Removing JPEG, changing the negotiated
encoding set, replacing OCR, or changing the existing scale/held-frame behaviour
requires a separate requirements decision. A codec with no suitable pre-allocation
interface needs dependency work. It is not silently bypassed. Bounded owned
memory does not establish loader, allocator metadata, native/device memory or
aggregate process/service containment.

### Capacity and lifetime

The profile accounts for overlapping **capacities**, not only final lengths.
During selection it contains the retained wire frame and selected owned frame.
During encoding it contains those frames, crop, rows/state, compressed and outer
PNG buffers, plus any simultaneous fallback compressor.

Resize contains old and
new frames until the old allocation is actually released. Decode includes its
applicable intermediates and persistent streams. OCR includes every live copy,
native work and retained result. A maximum over justified phases avoids summing
mutually exclusive temporaries, while a live buffer crossing phases remains
charged in each phase.

Reusable in-process scratch capacity may be reused only after its lifetime ends.
This does not refund the owner's irrevocable operation charge or retained storage.
Unknown allocator slack, bootstrap cost or native peak remains unknown. The
24,883,200-byte two-frame-plus-crop example in the
[resource report](../verification/settings-activation/KEEPALIVE-RESOURCES.md#evidence-needed-to-finish-the-profile)
is not a useful profile.
Numerical values must follow the complete workload and qualified implementation.

### Time, failures and retention

The owner keeps its absolute deadline across setup, input, decode, native work,
write, validation and publication. Cooperative checks before reads and work
chunks supplement the owner's independent supervision. They do not guarantee
that a synchronous native call stops. Mid-message deadline cancellation ends
that operation and connection. It must not resume a half-consumed parser, retry
transport or classify resource expiry as the existing clean held-frame timeout.

Assigned output objects have stable identity and one owning attempt. A suitable
dependency interface accepts owned output handles or an equivalently constrained
writer. Unrestricted default paths and delete-on-error temporary downloads do
not meet this contract.

The interface must preserve partial downloads as well as
captures. A failed partial remains attached to its original attempt. No second
output pathname or replacement artifact conceals it. Actual file-write, flush
and observation failures remain distinct. A receipt does not invent durability.

### Raw descriptor capture belongs to the backend

The backend owns enforcement for every byte on the producer's stdout and stderr.
This includes loader errors, panics, native diagnostics and inherited child output.
The producer bounds its own structured emission. That check cannot replace the
backend's boundary for output which bypasses the structured writer.

Before execution, the producer launcher must bind both descriptors to qualified
bounded capture objects under the committed allowance. Limits cover each stream,
their aggregate, collector memory, queued bytes, backing storage and object metadata.
No direct unbounded file or alternate inherited descriptor may bypass that boundary.

An exact-limit complete stream may succeed. A write beyond its allowance, a short
write or a capture failure closes eligibility and retains the real written prefix.
The first excess or write failure opens the existing containment window immediately. An earlier open window keeps its original deadline.
The backend records the stream, bound, observed failure and unknown tail separately
from any producer observation. Producer exit zero cannot clear this failure.

The [qualification proposal](../verification/settings-activation/KEEPALIVE-QUALIFICATION.md#backend-raw-descriptor-capture)
retains backend-owned pipes and precharged queue-tail retention as a candidate after review integration.
Queue coverage, bootstrap and process-loss limits remain explicit. The raw group is blocked until those required bounds exist.

The collector is a proposed separate C/libSystem image. Its build, bootstrap and runtime contribution need independent evidence.
It inherits the original writer descriptor as an active command writer.
The producer receives only pipe write ends for raw output, never raw-storage write descriptors. Use requires
actual qualification evidence under separately agreed execution scope.

Candidates include a bounded collector or a non-growing backing object with enforced
write limits. A pipe's finite capacity alone only creates backpressure.
A pre-sized file alone does not prevent growth.

Neither establishes this contract.
The design must preserve all accepted bytes, including bytes queued before failure,
without truncating evidence or consuming protected capacity. It must bound draining
and holder resolution under the original deadline. Unknown ownership or lost bytes
remain unavailable, never clean completion. No output is discarded to keep a run eligible.

Separate protected capacity supports backend and owner failure records where writable.
It never extends the producer's output allowance. Failure of that final write
leaves the corresponding facts unavailable under the existing publication protocol.

Resource failure is sticky and preserves the first failure. It does not trigger
another capture, input release, reconnect, polling attempt, revised cap or
collection dispatch. The owner settles delivery/validation/publication using its
existing protocol and decides collection only after exact writer containment.
The producer cannot certify owner eligibility or normal stop.

## Approved Koine test controls

This section addresses Koine harness maintainers. It keeps the shared approval,
copy audit and authoritative control list together, at the cost of mixing audiences.
It does not require TestAnyware's owner to implement Koine test seams.
The dependency owes the interface and real producer-guard evidence described below.

Antony approved resource-result substitutions on 2026-10-31, in addition to
audited phase barriers and the continuous-clock reader. The enabling point is
an audited copy of the responsible owner, backend or caller module, selected
only by the offline test harness. No production switch or allocator replacement
is introduced. The test still executes the real coordinator's transitions,
locking, charge calculation, publication sequence and failure propagation.

| Named copied boundary | Controlled result | Required real observation |
|---|---|---|
| Owner admission capacity query | Available, insufficient or unavailable identity/capacity | No capture charge or ordinal for refused/pending-cancelled work. Terminal-record allowance remains required. |
| Owner commitment capacity recheck | Changed capacity/identity after admitted work waits | Actual recheck refuses before assignment/charge/attempt creation. A later success does not reopen eligibility. |
| Producer launcher setup call/readback in the backend | Setup failure or unavailable/mismatched observation | The existing commitment and charge remain. Setup refusal causes zero external invocations. Commitment receives no later installed-limit fact. |
| Owner allocation fence/binding writes | Error before write or failure after a real retained prefix | No dependent attempt creation, commitment publication or child dispatch. Uncertain consumed ordinals stay burned under the eventual recovery protocol. |
| Owner lifecycle/disposition/handoff writes | Named write failure | Earlier evidence remains intact, missing terminal facts stay unavailable, and the submitter cannot infer permission to continue. |
| Owner attempt-directory creation after binding | Create error | Original ordinal and full charge remain. No commitment or backend creation follows. The collection successor uses the same transition. |
| Backend raw/artifact/receipt writes | Write error, or real prefix followed by failure | Original prefix/partial object and attempt identity remain. Failure settles once, with no retry or later scenario dispatch. |
| Caller owner-exit/final-outcome writes | Named final publication failure | Actual observed child facts remain distinct from the unavailable final record. Exit zero alone cannot complete the run. |

The harness identifies a substitution by module, named boundary and invocation
within the assigned operation/lifecycle event. Missing, duplicated, unexpected
or unused control sites fail the test. Each copied module is compared with its
pinned production source.

Only the declared barrier, clock and named result-site
changes are allowed. Any other byte difference fails the correspondence check.
Copy production again when it changes. Do not maintain a second coordinator.

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
cancelled work, first failure and later-dispatch refusal. The
[record schema](settings-keepalive-records.md#later-controls-and-remaining-inputs)
maps the named write boundaries to bounded rows and later coordinator controls.
Its numerical capacities and native storage qualification remain unresolved.

The following is the authoritative resource-mutant list for Koine controls:

- Charge at admission or charge a cancelled pending capture.
- Charge after producer execution instead of during commitment.
- Omit the commitment recheck.
- Refund a failed operation or borrow terminal capacity.
- Drop a partial or truncate an earlier file.
- Treat limit readback as capability proof or invent setup facts in commitment.
- Dispatch after a failed allocation fence.
- Accept a missing final record.
- Accept a test copy with an unrelated edit.
- Accept an environment, encoding or OCR-engine mismatch.
- Accept raw output beyond its bound or let producer success clear a capture failure.

Each mutant must fail its corresponding control. These are future test obligations,
not tests executed by this design session.
The qualification proposal maps all R rows and S2 through S6 to later implementation controls.

Those rows do not add mechanism prerequisites before the coordinator exists. This section remains authoritative for substitutions and resource mutants.
The owner spec remains authoritative for lifecycle, transitions and lock ownership.

The [expanded record and recovery controls](../verification/settings-activation/KEEPALIVE-RECOVERY-CONTROLS.md)
identify copied boundaries, actual prefixes and dependent-action oracles for S2–S6 and retained lifecycle controls.
Their canonical IDs and aliases prevent duplicate execution and charging.
Their negative complete-write observations use the approved extension below.
An unavailable approved site also leaves its case unavailable until an explicit seam decision.

### Complete-write observation extension

Antony approved this exact extension on 2026-11-01 during k130.
Existing approvals above remain unchanged. Implementation and correspondence audits still precede execution.

| Approved copied boundary | Approved controlled result | Required actual evidence and limits |
|---|---|---|
| The twelve named C targets in the recovery-control design, at their caller or owner publication-result return | After a complete actual write, report exactly one required flush, visibility or namespace result as failed or unknown | Retain complete real bytes and all actual call results independently. The real coordinator must refuse the dependent effect and retain the substituted observation. |
| Caller K28 final publication-result return for G-final-result | After a complete actual write, report flush failure | Retain actual bytes and call results. The caller must return unavailable despite complete readback. |

The substitution changes one returned observation field, never the actual write, flush, namespace or readback call.
Successful write length, object identity and real bytes stay unchanged.
The fixture transcript marks the returned field as substituted and retains its original value and actual raw status separately.
It does not fabricate an OS error number or claim an actual failed syscall.
Only an operation required by the frozen publication method can receive the failed or unknown observation.

If no namespace operation is required, its result stays inapplicable and its two cases remain explicitly inapplicable.

The approval covers 72 conditional negative C cases and one final-result case.
The 24 namespace cases also require an applicable publication method.
The twelve clean C cases continue to use actual calls only.

Each copied site and invocation needs a correspondence audit against pinned production source.
That audit and the extra transcripts, fixtures and retained bytes are the added costs for workload accounting.
These controls establish failure handling only. They establish no actual I/O failure, durability, storage reservation or native bound.
The approval adds no collector site, allocator replacement or production injection.

The extension lets controls exercise the schema's existing rule that failed and unknown publication observations block dependent work.
Keeping only the earlier two write-result shapes would leave these cases unavailable pending separately qualified real failure methods.
Antony chose the extension with its audit and evidence costs. No requirement is relaxed.

### Approved collector controls

Antony approved the separate collector's two named copied boundaries on 2026-11-01.
R3 follows descriptor/buffer binding and precedes the first raw read.
R5 controls the raw-storage write result. It reports failure before any write or after exactly 1024 real persisted bytes.

 R3 records accepted finite emitter
writes without waiting for blocked writers to finish before releasing the barrier.
It does not prove the kernel queue bound. Existing controlled CLI emitters can
write finite stdout/stderr prefixes without a structured observation, then exit
or retain a descriptor.

The [collector control decision](../verification/settings-activation/KEEPALIVE-RESOURCES.md#collector-control-decision)
requires a separate correspondence audit against the pinned collector source.
Only the two declared sites may differ. Missing, duplicate or unused sites and
unrelated edits fail the audit. Preserve real failure propagation, stop/drain,
containment and retained-prefix behaviour. Never fabricate a successful write.

These controls distinguish exact-limit completion, excess output, simultaneous
streams, write failure and unresolved inherited holders. They qualify failure
handling, not the actual raw-capture mechanism or native failures.

The approved substitutions qualify **failure handling only**. Producer guard
tests require the real dependency with finite protocol fixtures. They must
observe rejection before the actual allocation/write and unchanged in-budget
pixels/behaviour.

The dependency owner must enumerate every unit and expanded control before separate review.
The former 48-case proposal supplies no complete guard matrix.
Pre-Vision copies cannot qualify native-input consumption or post-recognition result collection.
Those require the real native path and separate explicit execution scope.
This design adds no copied-producer allocator seam. Native
limit, storage reservation and codec/service coverage need their own evidence.

## Alternatives and costs

Inherited limits with the unchanged producer minimise dependency changes but
fail the required per-unit contract. A separate adapter which checks only CLI
input or the completed PNG cannot see allocations inside the decoder. Isolation
may add aggregate containment but does not supply individual geometry/codec
checks or preserve native behaviour by itself.

An outer-bounds-only request would hide internal codec units from Koine.
That alternative conflicts with the required per-unit profile and rejection evidence.
The dependency therefore owns the versioned unit schema while Koine pins its values.

The selected design gives allocation knowledge to the producer and retains
cross-operation accounting in the owner. Callers supply one request rather than
reconstructing buffer lifetimes or independently setting limits. The cost is
dependency/codec work, a verified producer launcher, output-interface migration and
copy auditing in Koine tests. Internal codec state still requires implementation
evidence. A smaller interface alone does not make that state simpler.

A conforming unchanged dependency or a qualified equivalent boundary that
preserves every unit and behaviour could reverse the need for dependency changes.
No such evidence was established. Merely fitting one observed image or returning
the configured limits is not that counterexample.

## Remaining qualification and adoption

The [combined accounting](../verification/settings-activation/KEEPALIVE-ACCOUNTING.md)
includes internal OCR cycles and input-confirmation frame work within each operation's charge.
It also includes raw queue retention, simultaneous capacities and actual process overlap.
Exact unit definitions, producer evidence and useful finite limits remain missing.
The derivation adds no dependency operation or native execution authority.

This contract supplies no selected producer build, launcher/map floor, numeric
useful limits, protected storage arrangement, recovery schema or full-run
duration/tick budget. VM-launch queue/boot containment, uploads and the complete
collection/final tail remain part of the whole owner design. The separate
qualification proposal must expose these dependencies and name exact finite
subjects before requesting any execution authority.

Review this contract independently before consuming it in that proposal.
External implementation belongs to TestAnyware's owner. Its reviewed evidence
must return to Koine before the final profile and independent whole-design
review. Planning, implementation and every earned review/integration still
precede adoption. No resource refusal, successful fixture or approved test
substitution permits a VM/candidate/freeze/acceptance run or closes an ancestor.
