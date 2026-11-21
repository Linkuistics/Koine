# settings-keepalive-loop-removal-k147

## Goal

Remove Koine's keepalive captures from the Settings evaluation harness, as the
ADR `settings-harness-takes-no-keepalive-captures` decides. Leave every other
verification script unchanged.

## Context

- The running log of settings-keepalive-removal-k145 holds the survey of the
  scripts. The k146 amendments of the spec and the evaluation plan state the
  contract.
- The files in scope:
  - `scripts/vm-capture-evidence-lib.sh`: `keepalive_guest_evidence` and the
    header comment that names it.
  - `Tests/scripts/vm-capture-evidence.bats`: the baseline-mode
    `keepalive_guest_evidence` wrapper in `setup` and the four tests whose
    names start with "keepalive".
  - `Taskfile.yml`: the description of `check:vm-capture-evidence`.
  - `scripts/vm-verify-lib.sh`: the background capture loop in `start_vm`, its
    comment and the `VNC_KEEPALIVE_PID` kill in `cleanup`.
  - `scripts/vm-verify-menu-bar.sh`: the complete scenario. Both evaluation sets
    run it, and it calls `start_vm`.
- Out of scope: the HTTP keep-alive case in `vm-verify-grant-workflows.sh` and
  `vm-verify-grant-workflow-client.py`, and `vm-verify-latency-client.py`. They
  test Koine's connection behaviour, not VNC.

## Done when

- Before you remove code, enumerate every reader of these names across scripts,
  tests, the Taskfile and check programs: the keepalive operations, the
  `keepalive-N` capture names, `keepalive.png` and `VNC_KEEPALIVE_PID`. Record
  that no scenario assertion or audit reads them. If one does, stop and report
  the dependency. Use the positive and cross-tree controls of the grove rule for
  claims about the repository.
- Remove `keepalive_guest_evidence`, its four tests and its baseline-mode
  wrapper. Keep the baseline-mode `capture_guest_evidence` wrapper, because the
  other baseline controls use it. Update the Taskfile description.
- The other capture tests and their behaviour stay unchanged. This covers the
  single writer, nonblocking refusal, unique complete captures, sticky first
  failure, the latch and private roots.
- The Settings scenario starts no VNC capture loop. Make this a source-level
  choice that the caller's environment cannot reverse. Every other `start_vm`
  caller keeps the loop unchanged.
- Update the `start_vm` comment. The crash does not occur on macOS 27.2.1
  (26B131) with Tart 2.42.0, and the Settings harness does not use the loop.
  Cite the ADR.
- Show a failing control first. It runs the menu-bar start path with stubbed
  `testanyware` and guest commands, and it records any background screen
  capture. It fails against the current source and passes after the change.
- Show a second control: another `start_vm` caller still starts the loop. This
  proves that the instrument detects a loop.
- Run `task check:vm-capture-evidence` and each Taskfile check that covers
  `vm-verify-lib.sh` or `vm-verify-menu-bar.sh`. Record each command and its
  result in the running log.
- Do not start a guest to test this change. This leaf authorises no VM, slot,
  freeze, acceptance or release.
- No separate `review-impl` is planned. The change removes an unconsumed helper
  and one background loop. The whole-harness review that k76 and k57 cut before
  runtime covers the Settings start path. If the change reaches further, for
  example into shared capture behaviour or another caller, cut `review-impl` as
  the last act.

## Notes

- k89 is the first consumer of the harness, and it runs after this leaf.
- Retained evidence documents, such as `ORDERING-CAPTURE-RESULTS.md`, stay
  unchanged. Their keepalive receipts are history.
