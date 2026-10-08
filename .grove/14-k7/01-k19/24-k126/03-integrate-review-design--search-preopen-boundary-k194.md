# search-preopen-boundary-k194

**Integrates:** search-preopen-boundary-k192

## Goal

Triage the findings of `search-preopen-boundary-k192` against the pre-open
boundary analysis from `search-preopen-boundary-k189`, then apply the real ones,
so that metadata requirements `search-preopen-metadata-k190` asks Antony only
the questions the reviewed boundary still leaves open.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `23d6e0e277b5`, whose coordinates
  equal the review's tree.
- The artifact: `docs/verification/search-preopen-boundary.md`, the spec's
  pre-open proof boundary and the sections it touches in
  `docs/specs/workspace-search.md` (roots/domain, component resolution, pre-open
  policy, canonical observation, witness accounts, k119 calls), the cited ADRs,
  CONTEXT, SDL comments/examples, client guide, workflow trace, the focused
  search-preopen view and the other changed views with captions/README, and the
  k126 brief plus the k190/k191/k193 leaves that consume this boundary.
- Approval is unchanged. No new consent, entitlement, usage key, setup, helper,
  raised account, shorter ceiling, smaller domain, incompatible version or
  changed k119 call set is authorized. Lost workflow coverage goes to
  `protected-home-search-k93` before it becomes a dependency.

## Done when

- Classify every finding as a contract stated unclearly, valid and actionable,
  a visible trade-off, or noise; record each verdict and its reason in the
  running log, and apply actionable repairs in place across every affected
  durable artifact and summary layer.
- Where a finding removes or narrows part of the escalation, say so in the
  boundary and reframe k190's leaf to the questions that remain; where it
  confirms the escalation, make the k190 framing carry the missing disclosure.
  Do not select a call, consent or workflow change here — that stays k190's.
- Escalate rather than rely on any repair that would change workflow coverage,
  approval posture, k119's call set or another increment's contract. A repair
  amounting to substantive redesign is k191's, not this integration's.
- Regenerate changed views and run frozen `task design:search-render`,
  `task design:search-check` and `task check:docs`.
- k190 then consumes the reconciled boundary; k191, the mandatory node review
  k193 and k127/k123/k120/k30 keep their order.

## Notes

Design triage only: no implementation, probe or native evidence chain. All
native, prompt, hydration, binary and useful-coverage acceptance stays pending.
