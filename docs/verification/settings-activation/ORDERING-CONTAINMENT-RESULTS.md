# Finite Settings caller: slot run and containment

This report belongs to `settings-ordering-containment-k169`. That task adds the
`run` verb to `scripts/settings-ordering-sequence.py`. One command admits one
slot, runs its declared Task entry once, collects its evidence, contains its
exact clone and settles the slot.

The evidence is source and controls only. No VM ran, and no clone, signed
subject or runtime slot exists. The work establishes no native behaviour, no
native cause and no scenario readiness. It closes no ancestor.

k170 later changed the end of this flow. `run` now audits before admission and
stops before settlement, and `settle-run` settles the slot. The
[audit report](ORDERING-AUDITS-RESULTS.md) states the current flow. A phase that
did not run still cannot pass.

## The run

`settings-ordering-sequence.py run DIR SLOT` takes these steps:

1. Refuse `KOINE_VM_KEEP`, `KOINE_VM_DISPLAY` and `KOINE_SETTINGS_TRACE`, before admission.
2. Admit the slot through the k57 ledger.
3. Start the Task entry in a new process group, behind a closed gate.
4. Record the group, then open the gate.
5. Wait for the entry, and forward the first signal to the group.
6. Resolve any process that remains in the group.
7. Read `scenario.exit`, and freeze the classification of the evidence root.
8. Send at most one exact stop, then read one independent inventory.
9. Record the refusals and a digest manifest.
10. Settle the slot through the k57 ledger.

The run sets `KOINE_VM_ID`, `KOINE_VM_BASE`, `KOINE_VM_EVIDENCE_ROOT` and
`KOINE_K4_OUT` from the declaration. The scenario sends no stop, so the caller
cannot honour a keep request.

The gate closes a small gap. Without it, the caller could die after the start
and before the record, and leave an unrecorded group. A closed gate ends the
child before it runs Task.

The caller does not reap the group leader until the group is empty. The unreaped
leader keeps the group ID reserved, so a later signal cannot reach a new process
that reused that ID.

## Separate results

Each result stays in its own field of `containment/result.json`.

| Result | Source | Meaning |
|---|---|---|
| Scenario status | `scenario.exit` | Only one strict status line counts. A missing or malformed file is no status |
| Task status | The exit of the Task process | A signal becomes 128 plus its number |
| Classification | The receipts, before containment | Containment receipts cannot change it |
| Holder | The group and the lock | `none`, `waited`, `ended` or `unresolved` |
| Held input | The held-point receipts | `none`, `held`, `released` or `uncertain` |
| Start | The `vm-start` receipt | Whether a start was requested, and whether its creation is uncertain |
| Stop | Its receipt and status | `passed`, `failed`, `unavailable` or `not-run` |
| Inventory | Its receipt and status | `passed`, `failed`, `unavailable` or `not-run` |
| Refusals | `refusals.jsonl`, `facade-refusals.log` | Each request, with its class and reason |

Real Task 3.54.0 shows why the two statuses differ. After a TERM, the scenario
wrote status 143, and Task itself exited with 201.

A cleanup success cannot requalify a failed slot. The `cleanup` field has three
values:

| Value | Condition |
|---|---|
| `confirmed` | The stop and the inventory passed |
| `not-requested` | No start was attempted, and the inventory shows the clone absent |
| `unresolved` | Anything else |

## Containment rules

The caller sends a stop when the root holds a `vm-start` attempt. It also sends
a stop when an unreadable request or an ordinal gap could hide that attempt. A
failed or interrupted start therefore keeps its uncertain creation, and the
caller contains that exact clone. It starts no replacement.

The tagged `vm stop` returns an error for a clone that does not exist. A failed
start that created no clone therefore records a failed stop and unresolved
cleanup. This outcome is conservative, and the slot cannot qualify in any case.

The tagged [`tart` stop path](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-vm/src/tart.rs)
has no time limit of its own. The caller therefore bounds the stop at 180 seconds
and the inventory at 60 seconds. After a bound, it ends the helper's own process
group. It never sends a second stop.

The caller resolves a lock holder in this order:

1. Wait up to 30 seconds for the recorded group to become empty.
2. Send TERM to the group, and wait up to 10 seconds.
3. Send KILL to the group, and wait up to 5 seconds.
4. Test the writer lock without writing to the root.

If a member survives or another process holds the lock, the holder is
`unresolved`. The caller then sends no stop and reads no inventory, because
either call would meet the lock. It never bypasses the lock or clears the latch.

Held and uncertain input stays recorded. The caller sends no release, and the
only containment of that input is the exact clone stop.

## Decisions for review

- Each of the three override variables refuses the run. A silent removal would
  hide a request that the protocol does not admit.
- The protocol declares no time limit for a whole scenario, so the caller adds
  none. A hung scenario waits until an operator sends a signal.
- When the scenario leaves no root, the caller creates the declared root for the
  inventory only. The frozen class stays `no-root`, and the collection phase
  stays `unavailable`.
- The bounds accept `KOINE_SEQUENCE_BOUNDS`, so that the controls run quickly.
  `process.json` records the bounds that each run used.

## Controls and provenance

`task check:vm-settings-containment` runs 43 controls without a VM. A fake `task`
writes real receipts through the real facades, against the synthetic TestAnyware
CLI. One control runs the installed Task 3.54.0 and checks its process group and
its signal behaviour.

The records are in [`ordering-containment-evidence/`](ordering-containment-evidence/):

- `red.txt` runs the first 39 controls before the `run` verb exists. All 39 fail,
  for that broad reason.
- `defects-red.txt` shows two defects that a read of the first implementation
  found. One was a wait that never ended after a failed exit watch. The other
  was a stop helper whose surviving CLI kept the lock.
- `mutations.jsonl` disables 23 guards, one at a time, in isolated copies. Each
  named control passes on the unmutated copy and fails on the mutated copy.
  `mutate.py` is the instrument.
- `final-verification.txt` runs the affected checks. Its `.subjects` files
  record the digests before and after the run.

Three controls have a narrower failing record:

- The final assertion of the TERM control in `defects-red.txt` was wrong. A stop
  that never acted leaves the clone running, so the inventory correctly fails.
  The corrected control fails under the `stop-escalation` mutation.
- The control for a signal before the gate opens came after the implementation.
  The `gate-withhold` mutation shows that it can fail.
- The installed-Task control observes a dependency, so it has no failing record.

## Limits

- The controls use real receipts but no real guest. E01 still qualifies the real
  stop and inventory payloads.
- A SIGKILL of the caller cannot be caught. The group then runs without a
  supervisor, and the slot stays `started-unsettled`. That state blocks every
  later slot. `process.json` names the group for an operator.
- An owned holder is a member of the recorded group. A process that left the
  group and holds the lock is `unresolved`. A process that left the group without
  the lock is not tracked.
- The lock test briefly takes the lock. A cooperating writer outside the group
  could be refused during that moment.
- The manifest digests the files at one moment. If a holder stays unresolved, a
  file can still change afterwards.
- Task 3.54.0 is the observed version. k54 pins the frozen version.

## Handoff

k170 feeds the `environment`, `endpoint` and `audit` phases, and it cuts the
whole-harness review. Its `settle-run` verb is the route by which the k54
screenshot audit reaches the `screenshots` phase. k171 reconciles every original
duty after that review. k54 still owns the freeze, the readiness receipts and
the runtime.
