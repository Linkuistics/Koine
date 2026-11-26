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

**Where the harness admits the cancelled reply (2026-11-26).** The rule goes
into the read table beside `lost_reply`, for the reason that k8 records. The
cancelled reply has CLI status 0, so `validate_response` refuses it at the exec
fields, because the exit code is -1. The backend then asks the new
`cancelled_reply` in `scripts/vm_exec_reads.py`. It admits only the `restart`
submission. The record must have `ok: true`, the exact command, `timed_out:
false` and exit code -1. It must also have the outcome `{"kind": "cancelled",
"before_start": false}`, the exact clean stdout, and a stderr that ends in the
projection note `Process cancelled`.

The backend also keeps the evidence checks of a clean record: a typed macOS
agent record, and complete UTF-8 captures of both streams. A complete capture
shows that the stdout is whole, not a prefix.

The read record says `"reply": "cancelled"` and keeps the stdout. Like the lost
record, it has no `submitted` field. The cancellation can come before
`reboot3`, so only the changed boot decides the restart. The record of
attempt 6 (record 000670) satisfies each condition: its stderr capture is
empty, and its stderr field is the bare note.

The macOS agent writes the note as the whole stderr when the command wrote
none. Otherwise it appends `\n[Process cancelled]`
(`agents/macos/Sources/TestAnywareAgent/ProcessRunner.swift`, `project`, in the
TestAnyware checkout beside this repository).

**The diagnostic guest (2026-11-26).** `task app:vm-probe-restart-reply` ran
the revised `restart_guest` with the real backend on its own clone
(`.build/vm-verify/restart-cancelled-20261126T062406Z`, clone
`koine-restart-cancelled-probe`, macOS 27.2.1, 26B131, TestAnyware 3.0.0). The
probe now takes `KOINE_PROBE_TRIALS`, and this run made three trials. Each
reply was `CONNECTION_DROPPED` with CLI status 1, and the backend recorded a
clean lost reply. In each trial, the first boot read after the 30-second wait
showed a changed boot record.

All twelve receipts are clean, the root did not latch, and the probe stopped
its clone. The subject digests matched the files after the run.

The race gave no cancelled reply in these three trials. The task allows that.
So a helper test now sends the exact bytes of record 000670 through the real
backend, and the backend records a clean cancelled reply. The same record with
`before_start: true` stays unavailable. With `CANCELLED_REPLY` emptied, the
test failed with the reason of attempt 6, so the test can fail. The record is
kept in `docs/verification/restart-reply/attempt6-000670/`.

**The checks (2026-11-26).** Twenty-three Taskfile checks read the read table,
the backend, the helper, the fixture CLI, the scenario, its backend, the
baseline or the probe. They are the seventeen that k8 ran, and
`check:vm-latency-installations`, `check:vm-physical-evidence`,
`check:vm-settings-audits`, `check:vm-settings-containment`,
`check:vm-ui-evidence` and `check:vm-window-evidence`. Each passed in one serial
run. The thirty changed files had the same digests before and after the run.
`check:docs` fails only on the link of #22, as on the parent change.
The leaf posted the result on issue #17. Attempt 7 of `release-0-4-1-k4` runs
on the same notarised bundle.
