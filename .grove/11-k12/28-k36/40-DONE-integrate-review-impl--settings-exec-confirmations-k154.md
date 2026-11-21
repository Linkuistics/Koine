# settings-exec-confirmations-k154

**Integrates:** settings-exec-confirmations-k153

## Goal

Triage the independent k153 review of k81 and resolve the findings that meet
agreed acceptance before k151, k152 or k76 consumes the checked exec reads.
This is a flat repair step under k36, immediately before the first consumer.
It unblocks the shared harness needed for the accepted Settings evaluation.

## Context

Read the findings from the commit named by `settings-exec-confirmations-k153`,
including `docs/verification/settings-activation/ORDERING-EXEC-READ-REVIEW.md`.
Read producer c3aa47c0, the current exec read report and its retained receipts.
Read the archived k75, k71 and k66 contracts through the structural crosswalk.
Read the current additive briefs and the reviewed ordering protocol. The review
inspected source only and ran no test, build, lint, format or guest command.

## Done when

- Independently check and classify each review finding against the artifact
  and its contract. Record each disposition and its source evidence in the
  exec read report, without rewriting historical receipts.
- Apply the necessary bounded repairs and meaningful controls. Check the
  effective-defaults source boundary and the completeness and incarnation
  limits of process evidence against primary sources. Preserve the exact
  one-attempt semantics, command statuses, actions, read counts, sleeps and
  poll bounds. No retry or later success repairs a failed observation.
- Run the appropriate existing Taskfile checks after all edits. Keep complete
  consumed-input provenance and retained failing and passing controls for
  repairs. Reconcile the producer's coverage and availability claims with
  the delivered source and controls before consumption.
- Keep the immediate k151, k152 and k76 handoffs coherent. Every original
  k75, k71 and k66 duty keeps its owner. k67, k62, k57 and k54 keep theirs.
  A repair that needs a substantial redesign follows the integration skill's
  scope rule. No speculative additional review chain replaces triage here.
- Preserve the private secret-bearing roots and all snapshot, AXValue and
  OCR availability limits. This leaf permits no VM, candidate, freeze,
  runtime acceptance, cap expansion or ancestor closure.

## Notes

The concrete obstacle is incomplete required evidence at the checked exec
read boundary. The finite handoff is the repaired and verified read artifact,
its explicit remaining limits and a disposition of each finding. k152 still
owns one-shot consequences and the restart feasibility question. k76 still
owns complete adoption, signals and both held-pointer controls.

## Decisions (running log)

- 2026-11-22: Classify P2-1 as a real issue, with an overstated report
  contract. Apple's CF source (`CFApplicationPreferences.c`, SHA-256
  b6e99c7c…) adds four any-user domains after the four current-user domains.
  `CFPreferences.c` (SHA-256 c455857b…) stores any-user current-host files in
  `/Library/Preferences/` and any-user any-host files in
  `/Library/Preferences/Network/`. On the macOS 27.2.1 host, which is not the
  guest, `UserDefaults.standard` returns a key that only the any-user global
  file holds. Repair: export the four any-user domains by path in the same
  read. Narrow the report claim to the twelve persistent sources. The
  argument, registration and volatile domains stay outside the read.
- 2026-11-22: Classify P2-2 as a real issue. A host control shows
  `ps -p "$$,99998"` exiting 0 with one row. Repair: print the selected PID
  set, and require both `ps` blocks to hold exactly that set. Add the start
  time to the argument block, so that each row pair joins on PID and start
  time. A missing member is unavailable, with no retry. Accept the
  one-second start-time resolution and the reuse window between `pgrep` and
  the first `ps` as stated limits. A pattern match stays no executable
  identity, and k152 keeps the exact executable and descriptor join.
- 2026-11-22: The new host control found a defect that the repair would
  otherwise introduce. The host's any-user global domain holds a time-zone
  string with raw C0 control characters. CFPropertyList writes them into
  XML, and expat refuses that XML. A guest with a time zone probably holds
  the same key. Repair: replace each character that XML 1.0 forbids with
  U+FFFD before parsing. No diagnostic key name or tag holds one, so key
  presence survives.
- 2026-11-22: Apple's `ps` source (`print.c`, `getproclline`) prints argv[0]
  in the `comm` column and skips the saved executable path. The process
  sets argv[0], so the record field `executable` overstated its content.
  No consumer reads it yet. Rename it to `argv0`, and hand k152 the fact
  that an executable identity needs another source.
- 2026-11-22: The baseline with the read table of 7627bb06 fails eight
  controls. Two real-command host controls reproduce both counterexamples.
  Each of five mutations fails its named control. The final measured run
  passes 13 Taskfile checks and 219 tests, with every subject unchanged.
  The receipts are in
  `docs/verification/settings-activation/ordering-exec-read-integration-evidence/`.
  The repairs are bounded, so no further review round is earned. k151,
  k152 and k76 may consume the reads, and every runtime hold stays.
