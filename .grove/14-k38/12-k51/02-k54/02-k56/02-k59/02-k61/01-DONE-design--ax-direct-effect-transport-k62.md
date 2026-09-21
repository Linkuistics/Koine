# ax-direct-effect-transport-k62


## Goal
Establish an actual read/restore/main/raise/activate/confirm path through one
retained AX endpoint, with a bounded native diagnostic and exact evidence.
## Context
Read `docs/verification/direct-ax-endpoint.md` and its direct-effect section.
This is k61's first independently verified slice; the parent still owns the
complete lifetime/admission/feasibility criteria.

## Done when
- A signed/hardened TestAnyware diagnostic exercises the effect sequence with
  one retained endpoint and no target-port refresh during dispatch.
- A separate observer verifies the visible minimize/restore/focus transition;
  a post-death request is refused. Preserve exact input hashes and exit status.
- The actual inferred ABI, ownership assumptions, limits and next obligations
  are recorded in the evidence report, capture ADR and checked visual view.

## Notes
`task fixture:ax-effects` builds only; native execution belongs in TestAnyware.
The macOS 26.5 internal call sites are a diagnostic interface, not a chosen
shipping dependency. `ax-endpoint-lifetime-and-admission-k63` consumes this
result under the original parent contract. No implementation leaf is added.

## Decisions (running log)
- The direct-stub path completed for PID 788, with a separate public-AX and
  NSWorkspace witness. Post-death transport returned MACH_SEND_INVALID_DEST.
  Retain this as feasibility evidence for effect dispatch, not proof of
  receiver ownership, client-event attribution, or arbitrary-target safety.
