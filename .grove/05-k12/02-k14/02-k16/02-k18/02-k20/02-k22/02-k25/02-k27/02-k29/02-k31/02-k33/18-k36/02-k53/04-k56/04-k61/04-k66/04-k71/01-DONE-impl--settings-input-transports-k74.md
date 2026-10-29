# settings-input-transports-k74

## Goal
Migrate keyboard, text and scroll inputs consumed by the complete ordinary
scenario to the reviewed writer/ordinal/latch domain when an evidence root is set.

## Context
Read the k71/k66 charters, reviewed ordering protocol, shared adapter and physical/
window handoffs. The input source is the immutable TestAnyware v2.7.0 tag after
its manifest. Preserve the unset-root lane used by other existing VM consumers.

## Done when
- Enumerate actual key/type/scroll callers in the complete scenario and consumed
  shared UI/consent helpers. Move those callers to one source-only facade with
  explicit operation names, preserving payload arguments, ordering and all waits.
- Explicit roots must be initialized/nonempty; no failed/empty root falls back.
  Validate actual key/modifier, text/Unicode scalar count, and scroll coordinate/
  delta payloads. Keep full raw streams/statuses/receipts in the shared adapter.
- Every failed/malformed/nonzero/partial/interrupted input stops that caller and
  prevents subsequent scenario input. No retries, constant predicates or reset.
  Check strict shell failure propagation at consumed scroll/menu/consent seams.
- Show meaningful failing controls against the prior bare input routes, then
  passing Taskfile controls including original bytes, exact argv, shared latch/
  ordinals, argument refusal, schemas, signals and unchanged unset-root behavior.
- Record the bounded result and remaining duties; cut independent review before
  later migration. No root adoption, full shell signal handling, VM or acceptance.

## Implementation plan

1. Add Bats controls using the real adapter/store/jq and a substituted external
   CLI; retain a baseline against the old bare-input routes before implementation.
2. Add scripts/vm-input-evidence-lib.sh with scenario_input OP ACTION ARGS,
   checking explicit-root validity, command shape and exact emitted payload.
3. Replace actual key/type/scroll calls in scripts/vm-verify-menu-bar.sh,
   scripts/vm-verify-lib.sh and scripts/vm-verify-desktop-lib.sh; source the facade
   without startup effects and stop before settling sleeps on input failures.
4. Add check:vm-input-evidence and run it plus consumed adapter/physical/window/
   menu/resize checks. Digest measured subjects before and after each run.
5. Write the durable input handoff, retain the complete remaining charter and
   schedule review before k75 consumption. Retire only this child and seal jj.

## Notes
K75/k76 retain every original k71 criterion. K67 owns positive setup/title/liveness;
k62 exact prefix and whole-duty reconciliation; k57 finite collection/containment;
k54 readiness/runtime. No VM, candidate freeze, historical evidence or causal-slot
change.

## Decisions (running log)

- 2026-10-29: Reuse the reviewed adapter and explicit-root selection already used
  by physical helpers. Keep commands, arguments and waits unchanged; the new
  operation argument identifies receipts only. The existing design and user
  mandate authorize this implementation; no new product design is selected.
- 2026-10-29: Inspect immutable TestAnyware v2.7.0 manifest/handlers/declarations.
  Validate exact key/modifier, text/Unicode-scalar-count and scroll x/y/dx/dy
  payloads; accept no extra input options. Reject leading-hyphen payloads at
  this current-caller boundary rather than permit parser option interpretation.
- 2026-10-29: Retain meaningful pre-repair controls. The initial argument baseline
  sourced the absent new facade; label that setup defect, retain its bytes, and
  correct the baseline to export its test-only bare route. Final formatted
  controls also run against the actual parent caller functions in isolation.
- 2026-10-29: Migrate only the ordinary scenario's reachable input calls. Leave
  unrelated shared create/revoke/quit fallback definitions in their legacy lane;
  enumerate them visibly in the bounded inventory. Add explicit scroll/menu/
  consent failure returns so shell conditional contexts cannot consume a failed
  input then continue into a settling sleep. The helper controls pass; full
  scenario root adoption/signals and every downstream UI confirmation remain.
- 2026-10-29: Final Taskfile checks pass: input 14, shared adapter 37, physical
  16, window 20, pointer 8 and resize 9 controls. Their subject digests match
  before/after. Documentation retains only the two original archive-link failures;
  source bytes match parent 00320226 and k23 owns the missing targets. The input
  artifact is load-bearing for later migration, so cut independent review k77
  before k75. No in-session reviewer or VM ran; k71 and all ancestors remain live.
