# settings-ordering-audits-k170

## Goal

Add the per-item audits and the declared-environment comparison to the finite
caller. Their results feed the `audit` and `environment` phases of the k57
settle verb.

## Context

Read `scripts/settings-ordering-sequence.py` and
`docs/verification/settings-activation/ORDERING-CALLER-RESULTS.md`. Read the
"Freeze, audit and exact cleanup" section of `ORDERING-EVALUATION-PLAN.md`. The
"K62 prefix handoff" of `settings-ordering-caller-k57` names G5, the defaults
read and the installed audit.

## Done when

- The caller audits the host inputs and the bundle before and after each slot.
  The audit compares each item, and it uses no count-only equality.
- The caller audits the installed regular-file hashes and symlink targets at
  both endpoints of each slot. The prefix records the installed inventory once,
  so an E slot needs its own audit after the slot.
- The caller audits the originals and partials with a manifest. The manifest
  compares each saved artifact with its original.
- The caller rechecks the stopped golden image before A01 and after the
  sequence, item by item. A mismatch prevents acceptance.
- G5: the caller compares the `system` and `gatekeeper` receipts and the Koine
  process arguments with the declared image and inputs. A mismatch holds the
  sequence.
- The caller reads the diagnostic defaults after each slot. A clean absence is
  required, and a failed read is unavailable.
- Each audit result stays separate, and it feeds the k57 settle verb.
- Failing controls come before each repair. They cover extra, missing and
  changed items, and an unavailable read.
- A reusable Taskfile check runs these controls without a VM.
- As the last act, cut the whole-harness and caller review as a `review-impl`
  leaf, directly before `settings-ordering-reconciliation-k171`. The caller is
  load-bearing, and no independent review has read it.

## Notes

No clone, slot or signed subject is created here. k54 owns the actual freeze
and the actual golden digests. The private roots can hold `KOINE_VM_PASSWORD`,
so plan finite storage and do not publish them.

## K169 containment handoff

Read `docs/verification/settings-activation/ORDERING-CONTAINMENT-RESULTS.md`.

The `run` verb settles the slot in one step. `Containment.execute` sets the
`environment`, `endpoint`, `audit` and `screenshots` phases to `not-run`, so
every run now settles as `unresolved`. Replace the first three with real results.

The k54 screenshot audit must reach the `screenshots` phase before settlement.
No route exists yet, so this task must add one. A recurrence candidate cannot
become `rejected` without it.

An audit before the slot must run before `admit_slot`, because admission
consumes the slot. The root now also holds the receipts `containment-stop` and
`containment-inventory`. The frozen `containment/classification.json` excludes
them, so read that file for the class of the scenario.
