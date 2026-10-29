# settings-keepalive-coordination-k92

## Goal
Resolve the capture keepalive's coordination with the shared evidence writer
before any downstream helper consumption or scenario adoption.

## Context
K91 integrates k90's findings from commit acf50e4d against k88 commit 07d632b7.
Read ORDERING-CAPTURE-RESULTS.md, its k91 triage and integration receipts, the
k85/k80/k75/k71/k66 charters, ORDERING-EVALUATION-PLAN.md and the current shared,
physical and click reports. A keepalive tick every sleep-20 can collide with
the locked 30-second Allow read; refusal latches and ends the loop. Its own
capture can refuse scenario actions. The legacy motivation is the observed VZ
idle assertion after roughly 60 seconds without a VNC client, not proven safe
availability under this new lock. No finite native qualification or collision
probability exists. The deterministic overlap control proves refusal only.

## Done when
- Establish a coherent, reviewable design for keepalive/scenario ownership,
  scheduling, failure eligibility, collection/containment and exact local
  interruption/partial records. Compare alternatives against the existing
  single-writer, nonblocking refusal and first-failure rules; state each proposed
  amendment explicitly rather than silently relaxing it.
- Preserve original scenario inputs, waits and poll bounds, strict one-attempt
  transports, unique complete captures qualified under their owned domain,
  exact VM identity, every raw outcome and private secret-bearing roots.
  If the requirements cannot be reconciled, state the precise new scope decision
  needed and keep adoption/runtime held. No guest, candidate or freeze here.
- Address unbounded retained screenshots and validator allocation honestly:
  current code reads/copies full compressed bytes and expands to header-derived
  pixel dimensions; no file-byte, dimension, memory or evidence-volume cap exists.
  Distinguish failure stopping/partials from guaranteed serviceability. Any new
  cap/retention change needs an explicit contract, controls and original-duty
  comparison, not arbitrary silent truncation, deletion or ignored failure.
- Land the design in the existing verification/spec contracts as appropriate.
  Cut independent review-design before k89, requiring every earned integration
  before implementation/consumption. Place any resulting impl and its earned
  review/integration before k89/k81/k76 consumption. The review chain is lazy:
  this producer creates its review once the design artifact exists.
- Carry every remaining k89 file/environment/lifecycle/collection duty, k81 exec
  and one-shot consequence, k76 complete adoption/signals/both held-pointer
  controls, and k67/k62/k57/k54 original duties. Retain missing-tree/empty-AXValue,
  OCR substring, held-frame fallback and privacy limits. No original duty is
  waived and no ancestor closes.

## Notes
This is design work, not permission for a guest, new sample, input retry,
lock bypass, latch reset, scheduling wait or product correction. Native cause,
ownership and repair acceptance remain unresolved.
