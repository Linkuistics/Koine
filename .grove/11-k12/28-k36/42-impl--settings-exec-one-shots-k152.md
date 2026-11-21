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
