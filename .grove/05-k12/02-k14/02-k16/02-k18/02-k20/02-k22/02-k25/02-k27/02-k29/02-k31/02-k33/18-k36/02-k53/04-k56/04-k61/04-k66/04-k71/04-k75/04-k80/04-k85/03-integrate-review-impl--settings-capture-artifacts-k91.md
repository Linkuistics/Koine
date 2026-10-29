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
