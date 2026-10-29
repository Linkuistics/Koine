# settings-nonexec-evidence-k60


## Goal
Extend the reviewed exec adapter with supported eligibility inspection, explicit
failed-confirmation recording and one-attempt non-exec CLI evidence in the same
writer-lock and ordinal domain, without migrating ordinary callers yet.



## Context
H-1 in settings-exec-evidence-k58, integrated by k59, motivates this increment.
Read ORDERING-TRANSPORT-RESULTS.md and ORDERING-EVALUATION-PLAN.md. The existing
adapter, facade and Bats controls are the seam. Actual scenario call-site/schema
enumeration and command-specific artifact/confirmation checks remain k61.

## Done when
- A supported gate inspects prior receipts/latch under the shared lock; failed
  downstream confirmations produce sticky, ordinal receipts through a supported
  interface. Neither can clear a failure or authorize an unlocked later input.
- Non-exec TestAnyware calls dispatch once, retain full raw streams/argv/VM,
  times/status/predicate and share exec's lock, ordinals, signal/partial handling.
  Require CLI zero, complete strict JSON success and one true payload predicate;
  reject dry-run and conflicting endpoint arguments. Collection cannot restore
  eligibility. Lifecycle calls bind their requested identity explicitly.
- Meaningful failing controls precede implementation, covering cross-transport
  gating, malformed/failed payloads, confirmations, contention and interrupted
  attempts. Existing exec, pointer and resize controls remain green.
- Reusable Taskfile checks pass with unchanged before/after input digests and
  retained per-command results. Document limits and cut earned review before
  scenario consumption; no VM or frozen subject.

## Notes
This is an expand increment only. K56 remains live with every original duty.

## Implementation plan

1. Extend Tests/scripts/vm-guest-exec.bats with real facade/subprocess controls
   for gate, fail and non-exec calls; retain the expected failing baseline.
2. Extend scripts/vm-guest-exec.py and its source-only facade using the existing
   writer and atomic receipt implementation. Preserve strict exec validation.
3. Run check:vm-guest-exec, check:vm-menu-pointer and check:vm-window-resize;
   preserve final inputs, outputs and exact outcomes in a new evidence receipt.
4. Document the supported interface and its caller obligations; commission tree
   review, retire this child and seal its focused jj change.

## Decisions (running log)

- 2026-10-29: Reuse one backend and writer domain instead of sidecar latch edits
  or a second recorder. Gate is inspection only; actual non-exec dispatch must
  recheck eligibility while holding the same lock. Explicit confirmation failure
  is an evidence event and remains recordable after a latch.
- 2026-10-29: Inspect the official local v2.7.0 tag's manifest, output envelope
  and CLI declarations. Non-exec requires the common strict JSON success base
  plus a mandatory caller predicate; do not invent exec fields. Pin endpoint
  --vm and lifecycle --id/positional stop identity. Actual schema/artifact and
  downstream confirmation checks remain with k61, provenance with k54.
- 2026-10-29: Eight initial controls fail against the absent interface. All
  eleven final additions fail against copied k59 sources; the missing-lock
  mutant independently fails the mixed collection control. A new embedded --
  case exposes a guard gap in the first expansion; retain its failing receipt
  before repair. The integrated Taskfile check now passes 32 controls. Schedule
  independent tree review before consumption rather than spend an in-session
  reviewer; that step can challenge the expanded interface and its caller limits.
- 2026-10-29: Final frozen-input verification passes the 32 adapter, eight
  pointer and nine resize controls. Each test identity and output hash matches;
  all named subject digests remain unchanged. The receipt audit rejects a
  deliberately wrong backend digest, and local report links resolve. Retire
  this expand child only and insert its independent review before k61. No
  provider evidence is supplied in this session's environment, so no Creator
  line is invented. K56 and every ancestor remain live, with no runtime/freeze.
