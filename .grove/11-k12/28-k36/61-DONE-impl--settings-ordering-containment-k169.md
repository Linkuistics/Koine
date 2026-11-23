# settings-ordering-containment-k169

## Goal

Add the slot run and its containment to the finite caller that k57 delivers.
One command runs one admitted slot, collects its evidence and contains its
exact clone.

## Context

Read `scripts/settings-ordering-sequence.py` and
`docs/verification/settings-activation/ORDERING-CALLER-RESULTS.md`. The handoff
sections of `settings-ordering-caller-k57` state the binding containment
duties. Read its "Physical-helper containment handoff" and "Contract ownership
after k140" sections. `ORDERING-NONEXEC-RESULTS.md` and
`ORDERING-FILE-LIFECYCLE-RESULTS.md` own the adapter limits.

## Done when

- One verb admits a slot through the k57 ledger and then runs its declared Task
  entry once, in its own recorded process group.
- The run passes the declared clone ID, base and evidence root. It sets
  `KOINE_K4_OUT`, and it reads `scenario.exit`.
- A failed or interrupted run still collects the available evidence. It then
  settles the slot through the k57 ledger, with separate phase results.
- The caller sends at most one exact stop per slot, through `stop_guest_vm`. An
  independent `inventory_guest_vms` read follows that stop.
- A failed or interrupted VM start keeps its uncertain creation. The caller
  contains that exact clone and starts no replacement.
- The caller records each refused collection, confirmation or stop request from
  `refusals.jsonl` and `facade-refusals.log`, with its reason.
- The caller waits for an owned lock holder, or ends its recorded process group,
  before the exact stop. It never bypasses the lock or clears the latch.
- A clean `resize-down-N` without a later clean `resize-release` stays held
  input. A failed, partial or missing held point or release stays uncertain.
- The caller sends no compensating release. Held or uncertain input is recorded
  separately, and it is contained through the exact clone only.
- An unresolved holder, stop or inventory records unresolved cleanup. Every
  later slot stays NOT RUN.
- Failing controls come before each repair. They cover malformed, partial,
  timeout and nonzero results, and extra or missing inventory entries. They also
  cover interruption, cleanup, stop admission and stop classification.
- A reusable Taskfile check runs these controls without a VM.

## Notes

No clone, slot or signed subject is created here. The k57 settle verb takes the
phase results that this leaf produces. Keep each result separate. A cleanup
success never requalifies a failed slot.

`KOINE_VM_KEEP` is a containment decision that k89 assigned to this caller. The
scenario sends no stop, so the caller must not honour a keep request.

## Decisions (running log)

**A keep request refuses the run.** The refusal comes before admission, so it
consumes no slot. The display and trace overrides refuse in the same way.

**The class freezes before containment.** The stop and inventory receipts share
the evidence root, so a later classification would read them as scenario work.

**No scenario time limit.** The protocol declares none. The caller bounds only
its own holder wait, stop and inventory.

**A stop needs a start attempt.** A root without a `vm-start` attempt gets an
inventory only, and its cleanup is `not-requested`. An unreadable request or an
ordinal gap counts as a possible start.

**The four unowned phases stay `not-run`.** Each run therefore settles as
`unresolved` until k170 and k54 supply them. The route for the screenshot audit
is a named k170 duty.

**Result.** `ORDERING-CONTAINMENT-RESULTS.md` records the run, its 43 controls,
its 23 guard mutations and its limits.
