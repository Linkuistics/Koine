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

## Decisions (running log)

**The readiness receipt carries the frozen declaration.** `run` reads the
receipt that the ledger digested. A receipt without a valid declaration refuses
before admission, so it consumes no slot. k54 writes the receipt, and the new
`inventory` verb gives it the exact item format.

**The `endpoint` phase is the installed audit at both endpoints.** The protocol
and `ORDERING-REVIEW.md` name "original/endpoint/golden audits". The `audit`
phase holds the host inputs and the originals. The `environment` phase holds G5
and the defaults.

**The installed audit compares with the frozen bundle.** Each endpoint must equal
the frozen bundle item by item. A before and after comparison alone would accept
a wrong bundle that stayed the same.

**The caller reads the guest before its stop.** It reads the installed inventory,
the defaults and the Koine process through the evidence class. The prefix has no
process read while Koine runs, so G5 needs this read.

**An audit before a slot that does not pass holds the sequence.** A `held` ledger
entry blocks every later admission, and it consumes no slot.

**`run` stops before settlement.** The screenshot audit needs a judgement that
the caller cannot make. A new `settle-run` verb takes that result and settles the
slot. It also compares the retained files with the manifest again.

**Acceptance needs a closing golden audit.** A new `close` verb records it. Five
qualified slots report `awaiting-golden-audit` until that audit passes.

**A collected run refuses `settle`.** Otherwise hand-written phases could replace
the audited ones. A run that died before it wrote its phases still uses `settle`.

**An unreadable item is unavailable.** The first implementation reported it as
missing, which is a clean difference that the read did not establish.

**Result.** `ORDERING-AUDITS-RESULTS.md` records the audits, their 65 controls,
their guard mutations and their limits.
