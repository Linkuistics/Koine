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

## Decisions (running log)

- 2026-10-29: Adopt the mandated design leaf. Use Tier 2 graph project
  Users-antony-Development-AbstractingComputers-Koine.gh-issue-14, generation
  2026-10-29T09:52:58Z. Changed metadata and partial shell parsing require
  direct current source reads. Graph call edges to unrelated Swift/trace
  symbols are not credited. No whole-repository completeness claim.
- 2026-10-29: Preserve the existing implementation and accepted timing rules.
  A permitted overlap schedule disproves collision-free operation under immediate
  sleep-20 admission and a nonblocking whole-operation writer. The reverse
  overlap also matters. No inspected coordination alternative preserves every
  rule while eliminating this conflict; this is a bounded design finding, not
  an impossibility proof about every possible transport.
- 2026-10-29: Recommend an explicit scope decision permitting design of serialized
  scheduling, with visible scenario admission delays and deferred ticks, plus an
  explicit resource profile. Neither is approved or implemented here. Preserve
  single-attempt transport, complete under-lock captures, sticky first failure,
  originals and exact containment. No numerical budget or native interval is
  invented. Independent design review precedes the scope decision and all
  downstream consumption. The task's unresolved-scope branch is the deliverable.
- 2026-10-29: Use codebase-design ownership and alternative comparison, the existing
  browser presentation, and verification-before-completion. The mandated tree
  review supplies the independent doubt check; no in-session reviewer duplicates
  it. No production code, guest, candidate or freeze is part of this leaf.

- 2026-10-29: The browser exposed a Mermaid sequence-label semicolon parse error;
  replacing the delimiters with commas renders the collision and scope views.
  Existing task check:vm-capture-evidence passes all 22 controls. Task check:docs
  returns 201 for only the two known k23 archive targets. All measured source,
  fixture, diagram and Markdown inputs remain unchanged during those checks;
  ordering-keepalive-design-evidence retains actual output and digests.
- 2026-10-29: settings-keepalive-scope-k93 owns the precise subsequent human scope
  decision. Insert the independent review of this artifact immediately before
  it; every earned integration must also precede k93 and k89 consumption. The
  current design's explicit unresolved-scope branch is complete. No implementation
  leaf is cut; any approved replacement goes through concrete design and planning.
  K89 and all downstream original duties remain live; no ancestor can close.

- 2026-10-29: Independent review settings-keepalive-coordination-k94 is placed
  before scope k93 and file/lifecycle k89. No current GROVE_PROVIDER_EVIDENCE is
  present, so no Creator line is invented. Final documentation recheck retains
  only the two known archive links; all tested code/fixtures are unchanged.
  Retirement affects this design leaf only; the parent still has live work.
