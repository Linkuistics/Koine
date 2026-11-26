# settings-restart-reply-k8

## Goal

Make the guest restart of the menu-bar scenario accept a lost reply when the
guest restarts. Then attempt 6 of the release check can run the login launch and
the final Quit.

## Context

- Attempt 5 of `release-0-4-1-k4` passed every assertion before the restart. Its
  evidence root is `.build/vm-verify/menu-bar-20261126T134522-evidence` in this
  workspace. Record 000669 holds the boot record before the restart. In record
  000670, the CLI exited 1 with `CONNECTION_DROPPED` 0.35 s after
  `shutdown -r now`. The running log of that leaf records the run.
- `restart_guest` in `scripts/vm-exec-one-shot-evidence-lib.sh` submits one
  restart, waits 30 seconds and then makes at most sixty boot reads, five seconds
  apart. A failed submission returns unavailable at once, before any boot read.
  `scripts/vm-verify-menu-bar.sh` calls it before the login-launch assertions.
- No retained evidence root holds an earlier strict restart. The other VM checks,
  such as `scripts/vm-verify-release.sh`, send the same `shutdown -r now` and
  ignore its reply.
- The closed protocol chose the strict rule on purpose. The spec
  `docs/specs/settings-activation-discrimination.md` and
  `docs/verification/menu-bar-vm.md` both state that a restart disconnect stays
  unavailable despite a later boot. `ORDERING-EVALUATION-PLAN.md` and
  `ORDERING-REVIEW.md` (P1-1) under `docs/verification/settings-activation/`
  record the reason. That protocol does not run for issue 15.
- `Tests/scripts/vm-exec-one-shot-evidence.bats` tests the helper.
  `Tests/scripts/fixtures/settings-scenario-backend.py` simulates the guest, and
  `scripts/check-settings-baseline.py` reads the baseline event stream.
- Issue #17 records the race and the rule to decide.
- The notarised 0.4.1 bundle and its zip are in `.build/app` and
  `.build/release-0.4.1`. Do not run `task app`, because it re-signs the bundle
  and drops the staple.
- A guest run needs `KOINE_TESTANYWARE_CLI` and `KOINE_JQ` as resolved absolute
  paths, and `KOINE_VM_BASE=testanyware-golden-macos-27`. Give each clone its own
  name, and stop it after the run.

## Done when

- A lost restart reply counts as a restart when a later boot read shows a
  changed boot record. A clean refusal of the restart and an unchanged boot
  after the bound stay failures of the restart, not of Koine.
- A failed boot read during the restart does not end the poll at once, if the
  repair needs that. The bound of sixty reads stays.
- The helper tests cover a dropped reply with a changed boot, a dropped reply
  with an unchanged boot and a clean restart. The simulated backend can drop the
  reply, and a scenario test passes through the login assertions with that drop.
- A diagnostic guest, apart from the scenario, qualifies the revised restart on
  today's guest. It shows the boot record change after the dropped reply.
- `task check:vm-settings-scenario` and every other Taskfile check that reads the
  helper, the scenario, its backend or the baseline pass.
- The spec and `docs/verification/menu-bar-vm.md` state the new rule for issue
  15 and the diagnostic evidence. Issue #17 records the result.

## Notes

Antony chose this repair on 2026-11-26, after attempt 5. The other choices were
to rerun unchanged, to accept attempt 5 as it was, or to stop with nothing
shipped. The running log of `release-0-4-1-k4` records the choice.

The diagnostic guest is not an acceptance attempt of the release leaf. Keep it
apart from the scenario, as k5, k6 and k7 did with their probes.

Read the ADR `docs/adr/settings-harness-takes-no-keepalive-captures.md` before a
change adds a wait. It governs the waits of the harness.

The delivery rule applies. A finding that does not break the happy path becomes
a GitHub issue.

## Decisions (running log)

**Where the harness accepts the lost reply (2026-11-26).** The evidence backend
latches the root after any attempt that is not clean, and a latched root
refuses each later scenario input. So the helper alone cannot accept a lost
reply. The repair goes into the checked read table
(`scripts/vm_exec_reads.py`) and its backend. The `restart` submission admits
one more answer: CLI status 1 with the exact CLI error envelope and the code
`CONNECTION_DROPPED`. The backend records that attempt as clean, and its read
record says `"reply": "lost"`.

The boot poll that follows then decides the restart.
The outcome vocabulary stays as it is, so the tooling of the closed protocol
reads a root without change. Every other failure of the submission stays
unavailable at once. That covers a missing envelope, another code, a timeout,
a guest failure and other stdout.

TestAnyware 3.0.0 gives `CONNECTION_DROPPED` for a connection that failed
after it opened, so the request can reach the guest
(`cli-rs/crates/testanyware-agent-client/src/lib.rs`, `dropped`). A refused
dial is `CONNECTION_REFUSED`, and then the request did not leave the host.

**The raw observation (2026-11-26).** Before the change, a scratch script
restarted a clone of `testanyware-golden-macos-27` twice
(`.build/vm-verify/restart-observe-20261126T051132Z`, macOS 27.2.1, 26B131).
It sent the restart with the raw CLI and then read the boot record every two
seconds. In both trials, the reply was `CONNECTION_DROPPED` after about 0.4 s.
The boot reads gave `CONNECTION_REFUSED` for about 16 s. The boot record
changed in the read about 18 s after the request.

So the drop occurred in three of three restarts on today's guest, with attempt
5. The helper waits 30 s before its first boot read, and the guest was back
after 18 s. The repair therefore keeps a failed boot read unavailable at once,
as the task allows. The delivery rule applies: a slower guest that needs more
than 30 s is a hardening case for an issue.

**The qualification (2026-11-26).** `task app:vm-probe-restart-reply`
(`scripts/vm-probe-restart-reply.sh`) ran the revised `restart_guest` with the
real backend on its own clone (`.build/vm-verify/restart-reply-20261126T051903Z`,
clone `koine-restart-reply-probe`, macOS 27.2.1, 26B131). It made two trials in
one evidence root. In each trial, the reply was `CONNECTION_DROPPED` with CLI
status 1. The backend recorded a clean lost reply.

In each trial, the first boot read after the 30-second wait showed a changed
boot record. All eight receipts are clean, and the root did not latch. The
probe stopped its clone. `docs/verification/restart-reply/` keeps the trials,
the subject digests, the two restart attempts and the raw observation.

**The link check (2026-11-26).** `task check:docs` fails on one link in
`ORDERING-PROVENANCE-RESULTS.md`, which points to a removed grove task file.
The same link is on `main` and on the parent of this change, so this leaf did
not cause it. The new documents add no failure. The leaf filed #22 by the
delivery rule.

**The checks (2026-11-26).** Seventeen Taskfile checks read the helper, the
backend, the read table, the fixture CLI, the scenario, its backend or the
baseline. Each passed: `check:vm-exec-one-shot-evidence`,
`check:vm-exec-one-shot-host`, `check:vm-exec-read-evidence`,
`check:vm-exec-read-host`, `check:vm-guest-exec`, `check:vm-sysevents-evidence`,
`check:vm-sysevents-host`, `check:settings-baseline`,
`check:vm-settings-scenario`, `check:vm-settings-prefix`,
`check:vm-settings-sequence`, `check:vm-capture-evidence`,
`check:vm-file-lifecycle-evidence`, `check:vm-input-evidence`,
`check:vm-menu-pointer`, `check:vm-verify-start` and `check:vm-window-resize`.
The leaf posted the result on issue #17. Attempt 6 of `release-0-4-1-k4` runs
on the same notarised bundle.
