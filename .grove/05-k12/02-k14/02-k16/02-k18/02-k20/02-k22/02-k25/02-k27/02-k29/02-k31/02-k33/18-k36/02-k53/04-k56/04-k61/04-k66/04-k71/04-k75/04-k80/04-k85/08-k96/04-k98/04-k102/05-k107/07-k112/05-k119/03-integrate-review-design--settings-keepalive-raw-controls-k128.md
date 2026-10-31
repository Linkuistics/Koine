# settings-keepalive-raw-controls-k128

**Integrates:** settings-keepalive-raw-controls-k127

## Goal
Triage the k127 review of the k122 raw-output control design. Apply the real
findings to the design document and to the documents it changed. Do this before
settings-keepalive-recovery-controls-k123 consumes the design.

## Context
Read the findings in the k127 review leaf and its commit. The reviewed artifact
is commit 716caad9. The design is
docs/verification/settings-activation/KEEPALIVE-RAW-CONTROLS.md with its
owner-spec link, the qualification proposal's R rows and the raw-output view.
Grade each finding against the k122 charter and the k119 brief chain. Grade it
also against the owner spec, the producer contract, the record schema and the
qualification proposal. No in-session reviewer ran in k122 or k127.

## Done when
- Classify each k127 finding as real, a visible trade-off, an unclear contract
  or noise, with a reason.
- Apply each real finding inside the design document and the documents it
  touches. Where a finding changes an R obligation's coverage, reconcile the
  qualification proposal's R rows to the same coverage.
- Keep every approved substitution as approved. Add no collector site,
  replacement collector, second raw writer, allocator seam or production
  injection. Preserve the exact R3 and R5 scope and its separate audit.
- Present any loss of an original R obligation to Antony as an explicit choice
  with costs. Infer no relaxation.
- Adopt no numerical capacity, queue bound, storage result or mechanism result.
  Keep every prerequisite and the complete-profile duties live in k119 and the
  parents.
- Record each disposition in the edited documents or this leaf. Check the
  edited documents and views. Retire only this leaf.

## Notes
The integration owns corrections and all post-correction document checks. It
may spend one narrow in-session reviewer. A redesign of the collector mechanism
or a new control class is a new producer and review chain beside this leaf, not
an inline change. No coordinator or native control runs.
