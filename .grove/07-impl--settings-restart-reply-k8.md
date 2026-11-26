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
