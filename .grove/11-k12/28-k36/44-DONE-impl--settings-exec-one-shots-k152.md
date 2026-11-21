# settings-exec-one-shots-k152

## Goal

Supply each one-shot exec submission of the Settings scenario with its clean
completion and its exact downstream confirmation. This leaf owns that part of
the k81 charter.

## Context

Read the k81 and k151 tasks, their reports and the reviewed results of their
reviews and every earned integration. Consume their helpers only after those
integrations. Read the archived k75, k71 and k66 charters and the reviewed
ordering protocol, especially its one-shot confirmation table.

The caller table in
`docs/verification/settings-activation/ORDERING-EXEC-READ-RESULTS.md` lists
each one-shot caller and its owner. Its section on the boot poll states the
restart question.

## Done when

- Each one-shot submits exactly once. It needs a clean completion and then its
  confirmation from the ordering protocol. A downstream success never
  rehabilitates a failed submission. These one-shots are in scope:
  - the bundle extraction during the install
  - the first launch, the silent launch after setup and the reopen of the
    running application
  - the TextEdit launch, and the TextEdit quit with one clean absence read
  - the restart, with the changed boot inside the existing 30-second wait and
    60-by-5-second poll
  - the background submission of the System Events automation request
  - the open of the Accessibility pane during the consent
  - the diagnostic defaults write, which the protocol never permits
<!-- tc: depart synonym-rotation because the process start time is an identity field, not the launch action -->
- The launch identity joins the descriptor, the process, its executable and
  its start time. A reopen keeps the same process.
- The boot poll after a restart is an open availability question. Each poll
  read must be clean, and a guest that is still restarting may refuse the
  connection. Decide from source evidence whether a clean poll is feasible. If
  clean completion is demonstrably infeasible, hold before E01 for a new
  decision, without a qualifying guest.
- Preserve every original assertion, input, wait and poll bound. Add no retry,
  substitute route or delayed shutdown.
- Show failing controls before each repair, and show passing Taskfile checks.
  Cut the review and every earned integration before k76 consumes this work.
- k76 owns adoption, signals and both held-pointer controls. k67, k62, k57 and
  k54 keep their duties.
- Secret-bearing roots stay private. This task permits no VM, candidate,
  freeze or acceptance.

## Notes

The k154 integration changed the process read. The record holds the
`pgrep` selection, and each row holds `argv0`, `started` and `arguments`.
A selected process without both `ps` rows makes the read unavailable. Each
row pair joins on PID and start time, with one-second resolution.

The `comm` column of `ps` prints argv[0], which the process sets. Thus neither the
pattern match nor `argv0` is an executable identity. The executable join of
this leaf needs another source of the saved executable path.

## K151 handoff

k151 checks the enrolment as a one-shot submission. The read table marks a
submission entry, and only the one-shot class admits it. The table can hold
your submissions in the same way. The background System Events automation
request stays with you.

k151 classifies AppleScript error numbers from the AppleScript Language
Guide. Only -1728 and -1719 are an absence, and only three polls admit one.

## Decisions (running log)

- 2026-11-22: Adopt k152 in the jj workspace `gh-issue-14`. `main` is an
  ancestor of the working copy, and no newer change sits on it, so the base
  is current. k81, k153, k154, k151, k155 and k156 are complete, so
  consumption may start.
- 2026-11-22: Each one-shot becomes a checked submission in the read table.
  The entry keeps the unchanged legacy command and an exact stdout grammar,
  and only the one-shot class admits it. The tagged agent waits for the bash
  process only and strips trailing `\s+` from stdout (`ProcessRunner.swift`
  at v2.7.0). Thus each background or launch command has empty clean stdout.
  Caller adoption stays with k76, so no scenario line changes.
- 2026-11-22: Apple's `shutdown.c` on the `now` path skips the fork, prints
  "Shutdown NOW!" and "System shutdown time has arrived" with two BEL
  characters, calls `reboot3` and reaches `finish(0)` if that call returns.
  The agent writes stdout to a regular file, so both lines reach it only at
  exit. The restart grammar is therefore exactly those two lines. The lock
  failure path exits 0 with the first line only, and the grammar refuses it.
  No host can run this command, so the grammar is source-only.
- 2026-11-22: The boot poll after the restart is feasible, but its
  availability is an unmeasured race. The tagged CLI makes one connection
  and has no retry, so each exec during the guest's outage fails. The agent
  is a per-user LaunchAgent (`golden.rs` at v2.7.0). Thus the outage lasts
  from the teardown of the old session to the autologin of the new one. A
  clean poll needs that whole outage inside the 30-second wait, because no
  boot-through-login fits one 5-second gap. Nothing in the source sets the
  outage length, so clean completion is not demonstrably infeasible. The
  evaluation does not hold before E01 for this reason. A failed poll read
  stays unavailable, and the protocol accepts this cost visibly. The
  restart runs only in the A slots.
- 2026-11-22: The launch identity read uses `proc_pidpath` and
  `proc_pidinfo` with `PROC_PIDTBSDINFO` through Python `ctypes`. The host
  SDK declares both in `libproc.h`, and `sys/proc_info.h` gives the
  `proc_bsdinfo` layout with the start time in microseconds. The kernel
  path is the executable identity that `ps` cannot give. Python can raise
  the Command Line Tools prompt on a guest without them, so the read stays
  out of the evidence class.
- 2026-11-22: The protocol permits no enabling diagnostic defaults write. A
  facade function records that refusal and latches, and it sends nothing.
- 2026-11-22: The first baseline run failed three restart controls on a
  fixture artefact. The legacy `guest` merges stderr into the boot value,
  and the fixture added a synthetic stderr line that a real `sysctl` never
  writes. The second baseline fails all 16 controls, each for a legacy
  cause. The shared fixture now reads answers as bytes, so a CR survives.
- 2026-11-22: Seven of eight mutations fail their named controls. M04
  survives, because the backend latch already refuses the absence read after
  a failed quit. The latch is the guard, and the receipt keeps the survivor.
- 2026-11-22: The measured run passes 17 Taskfile checks with 269 tests, and
  its 4462 subjects stayed the same. After it, only the report, the k152 and
  k76 task files and the new review leaf changed.
- 2026-11-22: The review settings-exec-one-shots sits before k76, because
  k76 adopts these submissions. Its body carries the artifact, its contract
  and the open doubts, with no conclusion.
