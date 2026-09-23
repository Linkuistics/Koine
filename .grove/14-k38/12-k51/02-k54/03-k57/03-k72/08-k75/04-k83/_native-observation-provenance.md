# native-observation-provenance-k83 — brief


## Goal

Determine whether the retained AX endpoint can register and deliver window
closure with source, capture/window lifetime and freshness attribution, including
the registration/publication boundary. Supply bounded native evidence or the
specific feasibility conflict before a full protocol is adopted.



## Context

Consume k81's proposal, k82's review and any integration first. The served
WindowObservation uses PID registration and PID-only termination delivery;
neither supplies the replacement mechanism. Existing direct-endpoint reports
establish selected synchronous reads/effects, not notifications. Do not run k74.

## Done when

- Consume k88's repaired proposal. Before probing, freeze both candidate orders:
  application registration before enumeration (cross-channel delivery gap), and
  per-element registration after enumeration (additional reuse gap). Test older
  closure delivery delayed past later enumeration and confirmation replies,
  including already usable records. Name the native barrier/lifetime premise
  that permits publication, or report its absence and dependent refusal.
- Include suppressed emission, saturated queues and failed delivery. Independently
  witness the missing closure; demonstrate the loss detector catches a deliberate
  missing-delivery control, or record that it cannot. Distinguish residual silent
  loss from detected loss and synthetic rejection from native completeness.
  Evidence read attribution to the same window lifetime under undetected reuse;
  equal descriptors or authentic senders do not suffice. Carry any failure to k87
  as an unagreed read consequence, not part of the effect relaxation.
- Map actual bounded nonblocking send outcomes to proven not-enqueued, enqueued
  or ambiguous, with rights cleanup, full queue, dead destination and interruption
  controls. Exercise the bounded ingress cut before dispatch, budget refusal and
  arrival after the cut. k86 owns maintained bounds/result mappings; no unchecked
  worker handoff, implicit retry or error-name inference of no-send is allowed.
- Exercise both preparation exits (proven closure versus listing failure),
  unauthenticated discard versus authenticated current-registration withdrawal,
  window/registration/capture refusal scopes, and fresh registration under the
  same live capture without reviving old references. Inventory behaviors and
  observed applications/workflows refused for k87's support agreement.

- Inspect the actual registration and delivery paths on pinned platform bytes:
  target destination, client receive ownership, message forms, kernel sender
  evidence, intermediaries, descriptor attribution, acknowledgment and removal.
  Trace the destination to the already retained endpoint; no hidden public AX,
  PID or PSN acquisition may stand in for it.
- Before running a probe, freeze a discriminator for closure during the gap
  between listing, registration acknowledgment and publication. A local cookie
  cannot prove native event age or descriptor lifetime. A missing native barrier
  is an explicit result, not something to fill in from the proposal.
- Independently witness an ordinary live enumeration/closure and Space absence;
  show known closure causes permanent refusal, while absence alone does not.
  Exercise queued old delivery, duplicate delivery, registration refusal,
  missing/mismatched provenance and old descriptor reappearance. Demonstrate
  controls actually detect a wrong-source/old-registration mutation. Separate
  synthetic rejection from actual native descriptor or PID reuse.
- Extend only the direct protocol needed for this discriminator. Authenticate
  each used read/reference/confirmation reply in the required fresh-right,
  actual-request, kernel-trailer, then live-task order. Sender identity does not
  establish request correlation or read freshness. Document every native form
  still unsupported and fail the affected operation rather than omit windows.
- Exercise cancellation/late reply, unregister with queued delivery, and held
  ownership through cleanup. Death/exec/reuse stops subsequent old-endpoint
  work; ordinary live effects and refusal require an independent witness.
  Do not promote post-death refusal into atomic targeting or count a fixture's
  behavior as proof about arbitrary handlers.
- Reconcile the proposal with evidence and carry precise adoption/refusal
  prerequisites forward. If the question exceeds this focused leaf, externalize
  its next discriminator before executing it; do not absorb all protocol work.

## Notes

All native execution is in disposable TestAnyware clones on frozen inputs.
Use owned wire handling only where layouts/cleanup are established; diagnostic
internal stubs are comparison evidence, not an approved shipping ABI. Public
schema and application-support changes await the complete agreement. A failure
must be surfaced before later work assumes a feasible mechanism.

## Decisions (running log)

- k88 exposes three distinct native questions: the registration/delivery wire
  path, its window-lifetime/order/loss semantics, and bounded send/cleanup
  behavior. The complete matrix does not fit one focused session. Preserve
  every original criterion above and decompose before native probing. The first
  child inspects pinned loaded bytes and freezes the experiment boundaries;
  subsequent children must supply runtime evidence or a specific conflict.
  Static layout inspection is not an observed closure or a publication barrier.

## Decomposition and obligation ownership

The original Goal and Done when remain unchanged above. These are design
investigations, not implementation leaves or an automatic survey sequence:

- `native-observation-wire-k89` pins and inspects the registration/delivery
  path, identifies encoder prerequisites and freezes the discriminator.
- `native-observation-ordering-k90` owns native closure versus Space absence,
  publication in both registration orders, loss detection and read attribution,
  preparation/withdrawal scopes, old registrations, recovery and support impact.
- `native-observation-send-cleanup-k91` owns bounded initiation/result meanings,
  ingress cut, cancellation/late replies, unregister/drain, ownership and
  death/exec/reuse refusal, with independent witnesses.
- `native-observation-conclusion-k92` reconciles every original criterion and
  carries precise evidence/conflicts to k84–k87 and the parent rollups. A failed
  native premise must be surfaced when found, not hidden until this synthesis.

The first inspection may expose an encoder prerequisite requiring its own
focused child before runtime tests. No schema, behavioral support restriction,
native adoption or k52 permission follows from this decomposition.

k90 decomposed before native sends because k89 left owned-wire prerequisites.
Its first child, k93, derives a partial layout dossier from the frozen scans;
k94–k96 retain exchange validation, publication/read lifetime and loss/recovery.
The new byte tables establish no closure, completeness or publication barrier.
The original k83 charter above and k91/k92's responsibilities remain unchanged.
