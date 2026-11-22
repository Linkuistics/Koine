# settings-exhausted-poll-observations-k167

**Reviews:** settings-exhausted-poll-observations-k166

## Goal

Review the deferred exhaustion of the facade polls adversarially, before k164
consumes the scenario. Include the k165 library change, because both changes
deliver one duty. Report findings, not fixes.

## Context

The artifacts are the k166 commit, the k165 commit `bd8fa49f` and these files:

- `scripts/vm-exec-read-evidence-lib.sh`, `scripts/vm-sysevents-evidence-lib.sh`,
  `scripts/vm-window-evidence-lib.sh` and `scripts/vm-click-evidence-lib.sh`
- `scripts/vm-settings-scenario-lib.sh`, `scripts/vm-verify-menu-bar.sh` and
  `scripts/vm-verify-menu-bar-prefix.sh`
- the facade suites, `Tests/scripts/vm-settings-scenario.bats` and
  `Tests/scripts/fixtures/settings-scenario-backend.py`
- the section "Repair of gap G6" of
  `docs/verification/settings-activation/ORDERING-PREFIX-RESULTS.md` and its
  records in `ordering-exhausted-poll-evidence/`.

The contract is the k166 task file, the k36 brief and lines 187–193 of
`ORDERING-EVALUATION-PLAN.md`. Read each contract yourself.

## Done when

- Test the doubts below, and any other doubt that the artifacts raise:
  - Can status 1 from a deferred facade mean anything except a clean
    exhaustion? Can a failed transport, a failed sleep or a backend failure
    reach the observations or a `state-failed` receipt?
  - Does each receipt keep the operation name, predicate, outcome and status
    of the facade's former receipt on every call path?
  - Does any successful action, read count, wait, bound or printed value
    change? Does any legacy lane change?
  - Can an observation change the guest, or replace the evidence that the
    failure message or a later classifier reads?
  - Is every state-failed path of the scenario classified? Does each exclusion
    in the report hold against the protocol?
  - Would each control fail for the fault that it names?
- Record the findings in a committed review document. If a finding is worth
  acting on, cut the integration leaf.

## Notes

No VM, clone or signed subject. This review changes no source.

## Decisions (running log)

- 2026-11-23: Backend status 1 is not reserved for a clean false state.
  `_guest_evidence_backend` latches an unexpected backend exit but returns its
  original status. A failed Allow OCR backend can therefore reach
  `settings_poll_failed` as 1 and produce a false exhaustion receipt. Record
  this as a material failure-classification finding, derived from the source.
- 2026-11-23: A clean menu-title mismatch still sends Escape and waits before
  `settings_fail` takes the new observations. This defeats the protocol's
  untouched failure capture. Record this as an incomplete k165 repair; keep
  the successful menu-close path and the runtime holds in the integration's
  contract.
- 2026-11-23: The committed review document is
  `docs/verification/settings-activation/ORDERING-EXHAUSTED-POLL-REVIEW.md`.
  Read-only inspection matched sixteen reviewed source/test files to the
  retained verification manifest and matched the manifest and output-log
  digests to its receipt. This review reran no development checks. Cut one
  adjacent integration before k164 to triage the two findings; they directly
  unblock its consumption of the failure-observation duty.
