# settings-ordering-harness-k172

**Reviews:** settings-ordering-audits-k170

## Goal

Review the shared Settings harness and the finite caller adversarially, before
k171 and k54 consume them. No independent review has read the caller. Report
findings, not fixes.

## Context

The caller is `scripts/settings-ordering-sequence.py`. Its three slices are the
commits of `settings-ordering-caller-k57`, `settings-ordering-containment-k169`
and `settings-ordering-audits-k170`. Read these artifacts:

- the caller and its suites `Tests/scripts/vm-settings-sequence.bats`,
  `vm-settings-containment.bats` and `vm-settings-audits.bats`
- the fixtures `settings-run-task.sh`, `settings-audit-frozen.sh` and
  `file-lifecycle-cli.py` under `Tests/scripts/fixtures/`
- the backend `scripts/vm-guest-exec.py`, `scripts/vm_exec_reads.py` and the
  facades that the scenario sources
- the scenario `scripts/vm-verify-menu-bar.sh`, its prefix and
  `scripts/vm-settings-scenario-lib.sh`

The contract is the k36 brief, `ORDERING-EVALUATION-PLAN.md` and the accepted
spec `docs/specs/settings-activation-discrimination.md`. The task files of k57,
k169 and k170 state the duties of each slice.

## Done when

- The review tries to make the caller report a qualified slot or an accepted
  sequence that the protocol does not admit.
- The review tries to make a Koine failure, a test-driver failure and an
  assertion NOT RUN read as one another.
- The review tries to consume a slot, lose a held input or leave a clone running
  without a record that blocks later slots.
- The review checks each audit against a real receipt shape, not only against
  the synthetic CLI.
- The review checks whether any route settles a runtime slot without its audits.
- Each finding names its file, its line, a concrete failing case and its
  severity. A review without findings worth acting on cuts no integration.

## Notes

Run no VM, clone or signed subject. The evidence roots can hold
`KOINE_VM_PASSWORD`, so do not publish them.

## Decisions (running log)

**Review method.** Inspect the three producer commits and the current source,
controls and recorded verification. Run no tests, builds, linters, formatters,
VMs or signed subjects. Use Tier 2 graph evidence with direct source checks;
the scenario library has recorded parse gaps, and the Bats suites need direct
reads.

**Recovery settlement.** The exposed `settle` route can qualify a runtime slot
after caller loss before `containment/phases.json`, using supplied passed phases
without the audits or containment. The k54 instruction to avoid that verb does
not protect this recovery path. Record this as a material finding.

**Recurrence qualification.** A failed audit of the pre-selection installed
subject or guest environment cannot establish a qualified recurrence. The
current settlement ignores those distinctions and can reject the candidate
from the wrong subject. Preserve later-failure precedence without treating an
invalid prerequisite as a later collection failure.

**Original membership.** The originals audit enumerates surviving guest streams
rather than the streams required by the attempt. Loss before the manifest is
written can disappear from both checks and leave the slot qualified. Record
this separately from a changed original, which the existing controls cover.

**Result and placement.** The findings and receipt-shape inspection are in
`docs/verification/settings-activation/ORDERING-HARNESS-REVIEW.md`. They are
source-derived, not executed reproductions. Cut one integration sibling directly
before k171 so it can triage the material risks before the pre-runtime
reconciliation. Keep k36 and every product/causal ancestor open.
