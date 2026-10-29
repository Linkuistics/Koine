# settings-ordering-application-k52


## Goal
Implement the independently reviewed activation-before-window-ordering change
inside the existing application owner, and verify compilation and the relevant
headless controls. This is a source implementation boundary, not repair acceptance.



## Context
Read docs/specs/settings-activation-discrimination.md and
docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md,
ORDERING-DESIGN-EVIDENCE.md and ORDERING-REVIEW.md. K49/k50/k51 already select and
review the order. The end-to-end failing seam is historical real VM behavior.

## Done when
- Prepare the same retained window and requested section; perform one existing
  activation request before one existing key/front request in the same invocation.
  Move each trace boundary with its call. Preserve all callers and readiness.
- Recheck Apple contracts and cite both calls at the empirical order decision.
  Add no native fake, public seam, retry, deferral, yield or focus wait.
- Run the existing build and relevant headless controls with source digests
  before/after; distinguish compilation/recorder controls from native acceptance.
- Retain historical candidates and evidence. Record the source-only boundary in
  the current contract and verification handoffs; no signed evaluation subject,
  freeze, clone, runtime slot, release or notarization in this child.
- Leave precise live children for shared harness repairs and finite evaluation.
  No parent or causal ancestor closes.

## Notes
Use the existing jj workspace and Taskfile through mise. No new ADR is earned
by the small reversible call-order change.

## Implementation plan

- [x] Inspect all shared show callers, retained-window lifetime and disabled
  diagnostic branches. Recheck the macOS floor and the two Apple contracts.
- [x] In Sources/KoineApp/AppDelegate.swift, move the three activation lines
  immediately before the three key/front lines after navigation.show. Explain
  that the empirical order supplies no activation-completion guarantee.
- [x] Run mise exec -- task build and
  mise exec -- task check:settings-activation-interval. The existing disabled
  measurement test must still perform the operation once without reading ticks.
  Retain command statuses, full logs and unchanged measured-input hashes.
- [x] Publish the bounded source/build result and reconcile current handoffs.
  Inspect the final diff, retire this child and seal its jj change.

## Decisions (running log)

- 2026-10-29: K36 spans a product implementation, shared scenario/transport
  repairs and runtime freeze/evaluation. Decompose at independently verifiable
  boundaries; this session owns only this first child. The reviewed design
  already authorizes this exact order and its cross-caller effects.
- 2026-10-29: CBM list_projects refuses before project/generation/coverage discovery
  with the pre-coordination/unverified-generation error. Use bounded exact source
  reads; do not stop other CBM sessions or claim graph coverage.
- 2026-10-29: The approved contract establishes no deterministic local native
  RED seam and explicitly rejects a fake/order assertion as proof of repair.
  Retain historical real VM failures as the failing product evidence; add no
  test that only mirrors this six-line reordering. Existing controls verify
  the unchanged one-call disabled wrapper, not repaired native focus.
- 2026-10-29: Recheck Apple's live Markdown contracts and installed macOS 27
  NSApplication.h. Neither contract requires the relative order; activation
  may be declined or complete later. Cite both calls beside the local reordering.
- 2026-10-29: task build and check:settings-activation-interval both exit zero;
  nine existing tests pass. All 143 selected local input digests match item by
  item before/after. The inventories do not cover dependency checkouts, caches
  or the complete SDK and are not the runtime freeze. Publish the precise
  source-only result in ORDERING-APPLICATION-RESULTS.md.
- 2026-10-29: No additional reviewer is earned by the exact local reordering
  already independently reviewed as a whole design. K53 must assess its
  substantial harness/caller artifact for review before K54 runtime. No signed
  application subject or guest is produced; every slot is NOT RUN and no
  ancestor closes. No ADR is earned by this reversible implementation.
- 2026-10-29: check:docs returns Task 201/checker 1 only for the two known
  missing archived-context targets. Parent file show/list confirms the cited
  links and absent targets predate this child; k23 retains their byte-preserving
  repair. Current contract, verification entry points, root/nearest parent and
  presentation captions now distinguish implemented application order from
  outstanding shared harness/native acceptance.
