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

## Decisions (running log)

- 2026-11-21: No scenario assertion, audit or check program reads a keepalive
  name. I searched the whole repository except `.git`, `.jj`, `.build` and
  `.grove`, with `grep -rIn`. Outside the Markdown files, the term occurs in
  three classes:
  - The four files in scope. They are the only readers of
    `keepalive_guest_evidence` and `VNC_KEEPALIVE_PID`.
  - The HTTP keep-alive code and tests. `keepalive-client` in
    `vm-verify-grant-workflows.sh` is the label of an HTTP client.
  - The JSON, Mermaid and text evidence under `docs/`. These files are data,
    and no program among them reads a keepalive name.

  The legacy loop writes `${WORK}/keepalive.png`. No script reads a file in
  `${WORK}` by a glob, and cleanup removes the directory. For the positive
  control, the same command found `VNC_KEEPALIVE_PID` in `vm-verify-lib.sh`.
  For the cross-tree control, it found `keepalive-N` names in 118 evidence files
  under `docs/`. With the mutated pattern `VNC_KEEPALIVE_PIDX`, the positive
  control found nothing and exited 1, so it can fail.
- 2026-11-21: The failing control is `Tests/scripts/vm-verify-start.bats`. It
  copies `scripts/` and `App/Info.plist` into a temporary repository. Then it
  runs the real scenario script with stubs for `testanyware` and `sleep`. The
  stub records each screen capture. The first upload stops the script after
  one capture, or after 2 s. Against the old source, the menu-bar test failed
  with one capture of `keepalive.png`. The test with an inherited
  `VNC_KEEPALIVE_PID` failed for the same capture. The `vm-verify.sh` test
  passed, so the instrument detects a loop.
- 2026-11-21: `start_vm` keeps the loop, and the new
  `start_vm_without_keepalive` starts none. Both call `_start_vm`. The
  menu-bar scenario calls the second function, so no environment variable can
  start its loop. An argument to `start_vm` failed ShellCheck SC2119 at each
  of about 30 callers that pass no argument.
- 2026-11-21: `vm-verify-lib.sh` now sets `VNC_KEEPALIVE_PID` to empty when a
  script sources it. Before, an inherited value made cleanup kill that process
  in a scenario without a loop. The loop of every other caller is unchanged.
- 2026-11-21: The seven historical Settings experiment prefixes under
  `docs/verification/settings-activation/` also call `start_vm`. They are
  retained evidence, and they keep the loop unchanged.
- 2026-11-21: `capture_waits` in the setup of `vm-capture-evidence.bats` served
  only the four removed tests. I removed it. The baseline-mode
  `capture_guest_evidence` wrapper stays, with its `keepalive.png` file name.
- 2026-11-21: The new Taskfile check `check:vm-verify-start` runs the control.
  It also runs `bash -n` and ShellCheck on the library, the scenario and
  `vm-verify.sh`.
- 2026-11-21: Each command below exited 0, in one serial run. SHA-256 digests
  of the seven subject files matched before and after the run:
  - `task check:vm-capture-evidence`: 18 of 18 tests pass, with 22 before the
    removal.
  - `task check:vm-verify-start`: 3 of 3 tests pass.
  - `task check:vm-menu-pointer`, `task check:vm-input-evidence` and
    `task check:vm-window-resize` read both files directly.
  - `task check:vm-click-evidence`, `task check:vm-window-evidence` and
    `task check:vm-ui-evidence` extract functions from the library.
  - `task check:vm-latency-installations`, `task selection:vm-check`,
    `task target-locations:fixtures-check`,
    `task application-locations:fixtures-check`,
    `task prefix-registration:fixtures-check`, `task check:vm-settings-order`
    and `task check:vm-settings-native` lint a script that sources the library.

  The control file had the same digest in the red run and in this run. No
  guest started.
- 2026-11-21: This leaf cuts no `review-impl`. The shared capture library lost
  only the helper that no caller used. `start_vm` keeps the same loop for each
  other caller, and the third control shows it for `vm-verify.sh`. The empty
  `VNC_KEEPALIVE_PID` changes another caller only when it inherits the
  variable and stops before `start_vm`. Then cleanup no longer kills an
  unrelated process.
