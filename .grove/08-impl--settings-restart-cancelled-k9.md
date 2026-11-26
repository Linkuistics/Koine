# settings-restart-cancelled-k9

## Goal

Make the guest restart of the menu-bar scenario accept a cancelled reply, beside
the dropped reply that k8 admits. Then attempt 7 of the release check can run
the login launch and the final Quit.

## Context

- Attempt 6 of `release-0-4-1-k4` passed every assertion before the restart. Its
  evidence root is `.build/vm-verify/menu-bar-20261126T165831-evidence` in this
  workspace. In record 000670, the CLI exited 0 with `ok: true`, the outcome
  kind `cancelled` with `before_start: false`, exit code -1, the stderr "Process
  cancelled" and the clean shutdown stdout. The backend recorded the step as
  unavailable and read no boot record. The running log of that leaf records the
  run.
- At SIGTERM, the macOS TestAnyware agent closes admission, cancels every running
  command and replies if it can. The source is
  `agents/macos/Sources/testanyware-agent/AgentServer.swift`, "Agent run and
  SIGTERM", in the TestAnyware checkout beside this repository. So one race gives
  both forms. A closed connection gives `CONNECTION_DROPPED` (attempt 5 and the
  three k8 trials), and a reply that gets out first gives the cancelled record.
- k8 added the dropped form in `scripts/vm_exec_reads.py`: `LOST_REPLY`,
  `lost_reply` and the `restart` submission. Its backend and
  `restart_guest` in `scripts/vm-exec-one-shot-evidence-lib.sh` use them. The
  running log of `settings-restart-reply-k8` records why the rule lives in the
  read table and not only in the helper.
- `Tests/scripts/vm-exec-one-shot-evidence.bats` tests the helper.
  `Tests/scripts/fixtures/settings-scenario-backend.py` simulates the guest.
  `scripts/vm-guest-exec.py` also reads the restart reply.
- `task app:vm-probe-restart-reply` (`scripts/vm-probe-restart-reply.sh`) is the
  k8 probe. `docs/verification/restart-reply/` keeps its trials.
- The notarised 0.4.1 bundle and its zip are in `.build/app` and
  `.build/release-0.4.1`. Do not run `task app`, because it re-signs the bundle
  and drops the staple.
- A guest run needs `KOINE_TESTANYWARE_CLI` and `KOINE_JQ` as resolved absolute
  paths, and `KOINE_VM_BASE=testanyware-golden-macos-27`. Give each clone its own
  name, and stop it after the run.

## Done when

- The restart submission admits the cancelled form: CLI status 0, `ok: true`,
  the outcome kind `cancelled` with `before_start: false`, and the clean shutdown
  stdout. The boot poll then decides the restart, as it does for the dropped
  form.
- A cancelled record with `before_start: true`, a cancelled record with other
  stdout, and
  every other outcome stay unavailable at once.
- The tests cover a cancelled reply with a changed boot and a cancelled reply
  with an unchanged boot. The simulated backend can give the cancelled reply,
  and a scenario test passes through the login assertions with it.
- A diagnostic guest, apart from the scenario, runs the revised restart on
  today's guest. It needs to show only that each restart is decided by the boot
  record, whichever form the reply takes. One run cannot force the race either
  way.
- `task check:vm-settings-scenario` and every other Taskfile check that reads the
  read table, the helper, the scenario, its backend or the baseline pass.
- The spec and `docs/verification/menu-bar-vm.md` state the two admitted forms
  for issue 15. Issue #17 records the result.

## Notes

Antony chose this repair on 2026-11-26, after attempt 6. The other choices were
to accept attempt 6, to rerun unchanged, or to stop with nothing shipped. The
running log of `release-0-4-1-k4` records the choice.

The diagnostic guest is not an acceptance attempt of the release leaf. Keep it
apart from the scenario, as k5 to k8 did with their probes.

Read the ADR `docs/adr/settings-harness-takes-no-keepalive-captures.md` before a
change adds a wait. It governs the waits of the harness.

The delivery rule applies. A finding that does not break the happy path becomes
a GitHub issue.

## Decisions (running log)
