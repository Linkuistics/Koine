# retained-ax-lifetime-k55


## Goal

Determine whether retaining public AX objects alongside a task-name right binds
native effects to the original process, and preserve the evidence and the
human's choice of the next design direction.

## Context

The parent retains the full process-identity contract obligations. This child
owns the public candidate's native lifetime premise, not its eventual transfer
protocol. Read `docs/verification/retained-ax-binding.md` and the capture ADR.

## Done when

- A disposable VM has tested actual PID recycling with the original task right,
  AX window and AX parent continuously retained, and an independent observer
  distinguishes an effect on the replacement from a stale local read.
- Sources, commands, native output, before/after digests and limits are recorded.
- The spec's acceptance claims, current ADRs, client warning and architecture
  discussion distinguish the platform counterexample from Koine acceptance
  and from an approved replacement contract.
- The human's next direction is recorded; the original remaining contract work
  is represented by live design leaves before k52.

## Notes

Completed native result: on macOS 26.5, PID 781 was genuinely recycled after
99,413 child allocations. The original task right became dead, but a minimize
request through the original held AX window affected the replacement. The
holder performed no fresh AX acquisition after the original died. The separate
observer saw false → true minimization. This is a counterexample to endpoint
binding by retention, not a Koine mistarget or a universal impossibility proof.

The human chose investigation of private APIs inside Koine, with public client
APIs and strict process lifetime preserved. `private-process-binding-k56`
investigates feasibility; `process-identity-contract-k57` consumes a feasible
result to settle the full protocol, docs, schema and k52 handoff with the human.
Neither a mechanism nor a restart-policy change is approved by that choice.
