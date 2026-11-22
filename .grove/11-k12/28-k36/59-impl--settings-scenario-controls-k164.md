# settings-scenario-controls-k164

## Goal

Add the scenario-level controls that the k62 duty comparison found missing.
Change no successful action, read count, wait or bound.

## Context

Read the "Gaps and their owners" section of
`docs/verification/settings-activation/ORDERING-PREFIX-RESULTS.md`. Consume
the review `settings-focused-prefix-k163` and every earned integration first.
Integration k165 repaired the failure observations, and
`settings-exhausted-poll-observations-k166` closes gap G6 before this task.
Consume its review `settings-exhausted-poll-observations-k167` and any earned
integration first.

Integration k168 makes a backend exit of 1 return 125 at the
backend seam. It adds the simulator flag `menu-title-wrong`, and `settings_fault`
can now name a local poll record. A read-failure control can use
`settings_fault_status=1`.

For the G1 reveal counts, reuse the simulator flag `scroll-ignored`. The k165
control "an exhausted reveal takes the untouched failure observations before
its receipt (k165)" already uses it to exhaust the reveal. A fully exhausted
reveal makes 120 element reads and one frame read, not 60 reads in total.
The simulated backend `Tests/scripts/fixtures/settings-scenario-backend.py`
and the real backend with a fixture CLI are the existing seams.

## Done when

- G1: controls on the strict scenario path for these items:
  - the exhaustion of the reveal loop (60 reads), the calibration (30 scrolls)
    and the Add loop (15 reads and 14 waits)
  - the TextEdit read count at the scenario's call site
  - the `optional-vertical` and `position-y` modes at their call sites
  - a window at the silent launch
  - a clean on-screen negative against a read failure.
- G2: the legacy-transport inventory scans every helper that the scenario
  reaches, with the five root-unset lanes classified. A scan of the strict
  surface finds no constant-true predicate. Each scan has a positive control
  and a mutation that it detects.
- G3: fixtures for ELEMENT_NOT_FOUND and TEXT_NOT_FOUND with CLI status 3.
- G4: the held-state report gives `uncertain` for a failed or partial
  `resize-release` and for an unavailable or partial `resize-down-N`. A consent
  run with a `KOINE_VM_PASSWORD` override keeps the raw text in the private
  root, with synthetic text only.
- Show each control failing against a mutation or the source before any
  repair. If a control finds a defect, repair it with the least change, and
  keep the prefix byte check green.
- Run the reusable Taskfile checks, keep the records, and decide whether the
  change earns a review before k57.

## Notes

No VM, clone or signed subject. G5, the comparison with the declared
environment, belongs to k57. A source change before the TextEdit quit needs a
new prefix extraction and the check.
