# settings-keepalive-scope-k93

## Goal
Resolve the explicit keepalive timing, failure-ordering, normal-stop and resource choices with
Antony after k92's independent review and every earned integration.

## Context
Read the current KEEPALIVE-DESIGN.md under docs/verification/settings-activation,
the spec's keepalive-coordination hold, ORDERING-EVALUATION-PLAN.md and current
capture/shared/click reports. K92 takes its charter's unresolved-scope branch;
its recommendation is not an approved scheduler or resource profile.
K95 integrates k94 in the design's Review integration section. Use the current
Required scope decision section as the single proposal and recommendation.

## Done when
- Present every choice and cost in Required scope decision, including the
  separate evidence-writer and liveness-only alternatives, tagged persistent
  consumers, connection risks and normal-stop semantics. Explain the design's
  recommendation and its limits. Record Antony's actual answer for each choice;
  do not treat design review or silence as agreement.
- Resolve the resource choice in the design. No arbitrary caps, deletion,
  overwrite, downsampling or skipped required evidence. Explain that post-capture
  checks/streaming alone cannot bound the external producer.
- Any accepted timing amendment names what changes: scheduling delay and cadence,
  distinct from unchanged input order, explicit sleeps, poll counts and one-attempt
  transport. An ownership-based admission delay explicitly reopens the excluded
  driver-wait class; approval must name that scope proposal and its UI-independent
  boundary. A liveness-only choice separately amends required tick evidence and
  retention. A normal-stop choice must name any nonfailure lifecycle semantics
  without excusing a prior latch or interrupted required capture. Preserve
  first-failure eligibility, exact VM identity and private
  roots. No native idle interval or collection availability is established.
- Update the existing verification/spec contracts and brief handoffs with the
  exact agreement and complete original-duty comparison. If a replacement is
  authorized for design, cut that precise design ahead of k89; its independent
  review/integrations and planning/implementation/earned review must precede
  k89/k81/k76 consumption. Do not create speculative implementation leaves.
- Keep every k89 file/environment/lifecycle/collection, k81 exec/one-shot,
  k76 adoption/signals/both held-pointer, k67 setup/title/liveness, k62 exact-prefix,
  k57 caller/containment and k54 readiness/freeze/runtime duty. Retain snapshot
  missing-tree/empty-AXValue, OCR substring, held-frame fallback and privacy limits.
  No guest, candidate, freeze, cap expansion or ancestor closure follows.

## Notes
The independent review and every earned integration of
settings-keepalive-coordination-k92 must finish before this decision. Review
findings live with their review, not in this charter. Existing source behavior
and all historical outcomes stay unchanged until an authorized implementation.

## Decisions (running log)

- 2026-10-29: Antony answers "approved" to the proposed design of one serialized
  owner for scenario and keepalive commands. This explicitly reopens the excluded
  driver-wait class only for logged admission delays determined by command
  ownership and fixed policy, independent of UI state, focus or success. Ticks
  may be deferred and scenario input may wait behind capture qualification.
  Existing input order, explicit sleeps, poll counts and single-attempt transports
  stay fixed; elapsed timing changes and may affect the intermittent symptom.
  The approved proposal preserves complete required-capture validation before
  later scenario input. No separate writer or liveness-only evidence exemption
  was selected. This permits further design only; it establishes no safe native
  idle interval or collection availability. Resources, normal worker stop and
  test-seam agreement remain open. Record the complete agreement and grow the
  tree only after the interview reaches shared understanding.

- 2026-10-29: Antony answers "approved" to design and offline qualification of
  an enforceable finite resource profile covering encoded image size, dimensions,
  decoded data, validation memory and elapsed work, aggregate captures/raw data/
  partials, and separate capacity for final records and cleanup. The design must
  account for the external capture producer: post-capture checks and streaming
  validation alone cannot bound its prior allocations or writes. Reaching a
  limit stops acceptance and later scenario dispatch, retains all produced
  originals and partials, and reports unavailable preservation or cleanup
  honestly. No truncation, deletion, overwrite, downsampling or skipped required
  image is authorized. Numerical bounds and their usefulness remain design work;
  unbounded host resource exposure was not selected. Normal worker stop and the
  final test-seam/shared-understanding check remain open.

- 2026-10-30: Antony answers "yes" to design of a cooperative planned keepalive
  stop with a distinct lifecycle record matched to the owned worker and its
  confirmed exit. A stop between captures after normal scenario completion may
  finish without making the run unavailable. Earlier failures remain binding;
  unexpected exits, interrupted required captures and missing stop records
  still prevent acceptance. This authorizes design of nonfailure lifecycle
  semantics, never a clean tick, retrospective relabelling, latch reset or
  forgiveness of required work already dispatched. Exact schema, stop/dispatch
  races and controls remain design work. The final test-seam/shared-understanding
  check remains open.

- 2026-10-30: Antony answers "yes" to the final test-seam and shared-scope check.
  Keep the existing helper/adapter boundary, controlling CLI and sleep behavior
  while testing real coordination, locks, capture validation and records. Cover
  both collision directions, failure ordering, stop/dispatch races, unexpected
  exits, resource limits, original/partial retention, signals and both held-pointer
  cases. Keep native behavior at the existing TestAnyware VM workflow after
  design, review, implementation and readiness; local controls establish neither
  VNC liveness nor repaired focus. The agreed scope is one serialized owner with
  UI-independent ownership waits, complete required-capture validation before
  later scenario input, enforceable finite resources and recorded normal shutdown.
  Numerical policies and schemas remain design work. No new native experiment
  or runtime is authorized. The interview is complete: update the current
  contracts and handoffs, then cut the precise design ahead of k89, retaining
  independent design review, planning, implementation and earned review/integration
  before downstream consumption.

## Completion and verification

The existing KEEPALIVE-DESIGN.md, Settings activation spec and ordering protocol
now record the actual agreement, timing costs and complete original-duty
comparison. The capture report, current discussion/diagrams, root and k85 briefs,
and k89 handoff agree with those contracts. Settings-keepalive-owner-k96 is the
next sibling, before k89. It owns concrete policies/schemas and must place its
independent review and every earned integration before planning, implementation
and downstream consumption. No speculative implementation leaf is created.

On 2026-10-30, `mise exec -- task check:docs` returns Task status 201 (checker 1)
with only the two existing missing targets in context-initial-inputs/CONTEXT-PLAN.md:
context-predicate.txt and context-qualify-filter.sh. The k95 retained check has
the same two failures; settings-archive-links-k23 already owns their repair.
The whole tracked working-copy revision remained
16f3549c4494b996fe8ad1295fa6e6df4211f38b across the check. The updated keepalive
and repair-scope Mermaid views both render in the existing browser viewer with
the approved-scope text. The temporary loopback server and verification tab are
closed. These are documentation checks, not native qualification.

Tier 2 coverage generation 2026-10-30T09:51:57Z reports changed metadata for the
edited documents and partial Mermaid ranges (keepalive-scope 1-30, scope-choice
1-15); direct current-file reads and rendered views supply the relied-on evidence.
The retained k95 check has untracked coverage metadata and was read directly.
No graph completeness claim follows. The scope permission is reversible and
earns no ADR. K96 and k89 remain live, so k85 and every ancestor remain open.
No source implementation, guest, candidate, freeze, acceptance or release occurs.
