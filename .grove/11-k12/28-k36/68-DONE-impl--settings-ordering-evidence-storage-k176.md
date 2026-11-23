# settings-ordering-evidence-storage-k176

## Goal

Deliver the finite storage plan and the privacy guard for the E and A evidence
roots. This closes duties D215, D216, D270, D275 and D372 of the reconciliation
ledger.

## Context

Read `docs/verification/settings-activation/ORDERING-RECONCILIATION.md`, the five
ledger rows and the "Availability boundaries" section of the k36 brief. Review
`settings-keepalive-contract-removal-k148` keeps this duty after the keepalive
removal.

The evidence roots can hold `KOINE_VM_PASSWORD`. `declare` gives them mode 700,
but it accepts any path, including a tracked or published one. The capture report
states that no practical file, dimension, memory or run-volume cap exists.

## Done when

- A written plan states the location of the sequence directory and the retained
  classes of evidence.
- The plan gives a measured or bounded size for each slot. It also gives the free
  space that the five slots require.
- The plan states what happens when space runs out. A failed write stays failed
  evidence, stops later slots and deletes no original or partial.
- `declare`, or a reviewed readiness step, refuses a sequence directory in a
  tracked or unignored path. A control shows each refusal.
- The k54 task states the no-commit and no-publish rule, the free-space check and
  the separate retention of the `.build/vm-verify` transcripts.
- The five ledger rows are `met`, or a precise new leaf owns the remainder.
  `task check:settings-duty-ledger` and each affected harness check pass.

## Notes

Review k148 requires a plan and requests no new cap, profile or resource design.
Do not redact required raw evidence, and do not weaken text validation. Do not
add an automatic deletion or a size cap that drops an original. If no finite
bound can be established without a guest, state that limit and return the
decision to the owner before k54 freezes a subject.

## Decisions (running log)

- The guard stays in `declare`. It reads each enclosing Git and jj tree, because
  jj snapshots an unignored file without an add step.
- No proven byte bound exists without a guest. The plan gives a 300 GB allowance,
  and k54 returns that decision to the owner before the freeze.
- The containment code stays unchanged. On a full volume, `run` can exit 0 and
  leave a clone running. The existing recovery route covers this case, and k54
  now states it.
