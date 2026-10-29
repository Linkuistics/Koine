# settings-capture-artifacts-k91

**Integrates:** settings-capture-artifacts-k90

## Goal
Triage the k90 review of the k88 capture and keepalive helpers. Apply the
real findings to the helpers, their controls, the report and the k85
handoff. Finish before k89, k81 or k76 consumes the helpers.

## Context
Read the findings in the k90 review leaf and its commit. The reviewed
artifact is commit 07d632b7. Grade each finding against the k85, k80, k75,
k71 and k66 charters and the reviewed ORDERING-EVALUATION-PLAN.md. Also use
the shared adapter, the legacy keepalive in `scripts/vm-verify-lib.sh` and
the v2.7.0 TestAnyware capture sources.

## Done when
- Classify each k90 finding as real, a visible trade-off or noise, with a reason.
- Apply each real finding inside the reviewed design. Show a failing control
  before each behaviour change. Keep the existing red receipts unchanged.
- If a finding needs a change to a reviewed design rule, such as the
  nonblocking shared lock, do not apply it here. Escalate it, or cut a new
  producer and review chain beside this leaf.
- Pass the Taskfile checks and record final digests and receipts.
- Keep every remaining k85 duty for k89.
- Keep every exec and one-shot consequence for k81.
- Keep complete adoption, signals and both held-pointer cases for k76.
- Keep the snapshot and OCR availability limits and private secret-bearing
  roots. Change no ordinary caller.

## Notes
No VM, candidate, freeze, native acceptance or ancestor closure.

## Decisions (running log)

- 2026-10-29: Adopt k91 in the clean jj workspace and read the findings from
  k90 commit acf50e4d against producer 07d632b7. Tier 2 graph coverage generation
  2026-10-29T09:52:58Z has no recorded gap for the adapter/validator/library;
  Bats metadata is untracked and shell sources have partial ranges. Read actual
  bounded sources and flagged ranges; caller trace is not a completeness claim.
- 2026-10-29: P1-1 is a real design conflict at adoption. A sleep-20 tick can
  collide with the locked 30-second Allow read, stop and latch; the capture can
  also refuse a scenario action. Keep the reviewed nonblocking lock unchanged
  here. Insert a separate design producer before k89, requiring independent review
  and every earned integration, then any implementation/review before adoption.
  No availability estimate or successful native keepalive qualification exists.
- 2026-10-29: P2-1 is real: generic CLI capture bypasses unique artifact/image
  checks. Reject that command through the generic route in every class and
  reserve it for the checked capture backend. P2-2 is a real control gap:
  add reusable acceptance of nonzero filters, consecutive IDAT/ancillary chunks
  and the retained real PNG, exact rejection-reason controls and mutation disproof.
- 2026-10-29: P3-1 is real: contention replaces a local sleep signal status with
  125. Preserve the already observed signal status after attempting the same
  one locked record; retain refusal evidence and latch, with no retry or bypass.
  The shared historical reason says window poll; classify structured fields.
  P3-2 is a real handoff gap: document retained private image volume and unbounded
  allocation/MemoryError partials. Fail-closed partials are an accepted visible
  resource limit, not a bounded-memory guarantee; no arbitrary cap is introduced.
- 2026-10-29: The two focused controls fail against the unchanged producer:
  generic CLI capture dispatches instead of refusing, and a contended sleep
  signal returns 125 instead of 143. After the narrow repairs both pass.
  Retain repair-red/repair-green receipts in ordering-capture-integration.
- 2026-10-29: Expanded Taskfile checks pass 22 capture and 37 adapter controls,
  including real lock contention and deterministic MemoryError partials.
  The original 16 controls pass a reject-nonzero-filter mutant; new controls
  disprove that mutant and separate reject-multiple-IDAT/reject-ancillary mutants.
  Only the nonzero-filter mutant necessarily refuses the inspected native image:
  k90's broader assertion that the other two refuse every real capture is noise,
  since this retained native PNG has one IDAT and no ancillary chunk. The control
  gap itself is real because those valid structures are in the stated contract.
- 2026-10-29: Insert settings-keepalive-coordination-k92 before k89. Its design
  must earn independent review/every integration and any required implementation/
  review before downstream consumption. K85 and all ancestors stay open.
  Official tagged-source and lock-pinned registry digests match the original
  source receipt; this is source provenance, not installed/native availability.
- 2026-10-29: Final verification passes all nine reusable Taskfile checks and
  174 controls with unchanged measured subjects. The 59 capture/adapter test
  outcomes match the earlier expanded run item by item. No tested script,
  suite, fixture or Taskfile changed afterward. Production validator and
  ordinary callers remain unchanged; original k88 receipts have no diff.
- 2026-10-29: The first documentation check also found its own not-yet-written
  receipt link. Open the actual log before checking and preserve that first
  failed receipt. The completed check and full-document-input audit agree item
  by item on only the two existing k23 archive gaps, with unchanged subjects.
  docs-audit includes the link checker and every scanned markdown/diagram input;
  earlier documentation receipts are narrower input audits. The final report
  differs from the source-verification snapshot only by explaining that
  documentation-only receipt correction; tested artifacts still match digests.
- 2026-10-29: Decline an in-session reviewer because executable regression and
  mutation evidence directly disproves the repaired claims; another read of the
  same material would add no independent instrument. Substantial coordination/
  resource design is already chartered to k92 with its own independent review
  and every earned integration before consumption. No ADR change is earned by
  these reversible helper repairs. K85 has live k92 and k89, so no parent closes.
