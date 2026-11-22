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
