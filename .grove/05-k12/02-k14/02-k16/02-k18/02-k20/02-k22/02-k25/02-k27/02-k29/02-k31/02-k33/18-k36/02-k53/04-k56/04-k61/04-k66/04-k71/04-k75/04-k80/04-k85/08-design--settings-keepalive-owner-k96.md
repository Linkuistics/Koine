# settings-keepalive-owner-k96

## Goal
Produce the concrete design of one owner for scenario and keepalive commands,
with the agreed timing, failure, finite-resource and normal-stop contracts.

## Context
Antony settled settings-keepalive-scope-k93: "approved" to the serialized-owner
scope and finite resource-profile design on 2026-10-29; "yes" to cooperative
normal-stop semantics and the final test-seam/shared-scope check on 2026-10-30.
Read docs/verification/settings-activation/KEEPALIVE-DESIGN.md and
ORDERING-EVALUATION-PLAN.md in that directory, plus the keepalive-coordination
hold in docs/specs/settings-activation-discrimination.md. KEEPALIVE-DESIGN.md
records the precise agreement, alternatives, k94/k95 review and complete duty
comparison. Consume the current capture/shared/click contracts and their reviewed
source limits. K92's assessment is complete; the concrete replacement is not.

## Done when
- Define one command owner, its submission/result interface, exact VM/root and
  process ownership, maximum pending work, eligibility recheck at actual
  dispatch, writer/ordinal domain and terminal-publication boundary. Preserve
  full required-capture qualification before any subsequent scenario dispatch.
  Distinguish queued/unstarted cancellation from dispatched attempts; never
  allocate a fake attempt or let later success clear an earlier failure.
- Fix the admission/operation deadlines, arbitration and tick-delay policy,
  including a due tick during OCR, exec/transfer and post-CLI validation, and
  scenario arrival during capture. Keep input order, explicit sleeps (including
  sleep20), poll counts and one-attempt transports. Only logged command-ownership
  admission delays under fixed policy are admitted; they must be independent of
  observed UI state, focus or success. State the elapsed-timing and symptom-
  preservation cost. No priority rule may hide starvation or an uninterruptible
  holder. Deadline expiry stops acceptance/later dispatch, never retry,
  resubmission, busy-tick omission or a passing cleanup classification.
- Design the approved cooperative normal stop with a distinct lifecycle record
  matched to the exact owned worker and confirmed exit. Specify sleep/pending/
  dispatch/capture/validation/publication/stop races, suppression of future ticks
  and reap. Normal completion between captures may finish without failing the
  run; prior failure, unexpected exit, interrupted required capture or missing
  lifecycle evidence still prevents acceptance. No relabelling or latch reset.
- Establish a declared enforceable finite resource profile: encoded bytes,
  dimensions/decoded bytes, peak owned validation buffers and elapsed work,
  aggregate captures/raw output/partials, and separate final-record/cleanup
  capacity. Identify the external CLI/encoder limits and actual enforcement
  owner. A post-capture check or streaming validator alone is insufficient.
  Derive numerical limits from a declared workload and reasoned accounting,
  with offline boundary controls and an explicit usefulness argument. At a
  limit, stop acceptance and later dispatch, retaining every produced original
  and partial. No arbitrary cap, truncation, overwrite, deletion, downsampling
  or skipped required image. State what cannot be preserved or contained when
  storage or a holder is unavailable; free-space observations are not reservations.
- Specify failure and containment through the same domain: exact statuses,
  partial/missing records, INT/TERM/HUP and unexpected death, orphan/inherited
  holder resolution, untouched observer/window/screenshot order, endpoint/
  environment/original audits, exact clone stop and separate inventory. Both
  held-pointer cases remain binding; no corrective input or bare release.
- Use the agreed existing helper/adapter seam with controlled CLI/sleep and
  real coordinator/lock/validation/receipt behavior. Design discriminating
  controls for both overlap directions, failure before/after admission,
  cancellation without dispatch, capture failure before later input, normal
  stop and prior latch, stop/dispatch races, missing publication, resource
  boundaries and final-record failure, signals/orphan locks and both held-pointer
  cases. Keep native behavior at the existing TestAnyware workflow after every
  prerequisite. Local controls prove neither VNC liveness nor repaired focus.
- Reconcile the existing verification/spec contracts, observation policy and
  complete original-duty comparison. K89 keeps every file/environment/lifecycle/
  collection helper; k81 every exec/one-shot consequence; k76 complete adoption,
  statuses/signals and both held-pointer cases; k67 setup/title/liveness; k62
  exact E/A prefix; k57 finite caller/retention/containment; k54 readiness,
  signed/all-input/completed-golden freeze and runtime. Private roots, snapshot
  missing-tree/empty-AXValue, OCR substring and held-frame fallback limits remain.
- Place independent design review before k89 consumption once the coherent
  artifact exists. Every earned integration, planning, implementation and earned
  review/integration must also precede k89/k81/k76 consumption. Create no
  speculative implementation leaves. If this exceeds one session, decompose
  at a precise design question while preserving this whole contract.

## Notes
This is design authority only. No VM, candidate, freeze, native acceptance,
cap expansion, closed causal-slot reuse, release or ancestor closure. A needed
native capability experiment requires its own explicit reviewed scope; E/A slots
cannot discover replacement limits or qualify a different transport. Neither
a deadline nor serialized commands establishes a safe native idle interval.
Separate evidence writers, liveness-only ticks and persistent transports were
not selected. Existing source behavior and historical records stay unchanged
until authorized implementation. No ADR is earned by permission to design alone.
