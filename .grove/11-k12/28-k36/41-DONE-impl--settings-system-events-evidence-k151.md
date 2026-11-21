# settings-system-events-evidence-k151

## Goal

Supply strict exec reads for the System Events and enrolment outputs of the
Settings scenario. This leaf owns that part of the k81 charter.

## Context

Read the k81 task, its exec read report
`docs/verification/settings-activation/ORDERING-EXEC-READ-RESULTS.md` and the reviewed results of its
review and every earned integration. Consume the k81 helpers only after that
integration. Read the archived k75, k71 and k66 charters through
`docs/verification/grove-tree-structure/README.md`, and the reviewed ordering
protocol.

The callers are `sysevents` and its users in `scripts/vm-verify-lib.sh`. They
are the menu item count and label, the label poll and the item and row frame
polls. They are also the menu titles, the background-only flag, the Dock list
and the front application. They also include the System Events check after the automation
grant. The enrolment caller is `enrol`, through `guest_json`, in
`scripts/vm-verify-menu-bar.sh`. The k81 caller table lists each one.

## Done when

- Each System Events read returns a complete payload or is unavailable. A clean
  "no such element" answer is a negative only where the existing poll admits a
  negative. Classify each AppleScript error number from a primary source. Any
  other error, a timeout or a nonzero exit is unavailable.
- The list outputs keep the existing assertions. A rendered list that a
  separator makes ambiguous is a defect to remove, not a value to compare.
- The enrolment read requires the complete JSON response of the client, and
  the existing status and error predicate. Later text never rehabilitates a
  failed submission.
- Preserve every original assertion, read count, wait and poll bound. Use the
  k81 read mechanism and the shared writer domain. Add no retry and no read.
- Classify each new evidence-class command as read-only, or admit it only in
  the read-poll class.
- Show failing controls before each repair, and show passing Taskfile checks.
  Cut the review and every earned integration before k152 or k76 consumes
  this work.
- k152 owns the one-shot submissions, including the background automation
  start. k76 owns adoption, signals and both held-pointer controls. k67, k62,
  k57 and k54 keep their duties.
- Secret-bearing roots stay private. This task permits no VM, candidate,
  freeze or acceptance.

## Decisions (running log)

- 2026-11-22: Adopt k151 in the jj workspace `gh-issue-14`. `main` is an
  ancestor of the working copy, and no newer change sits on it, so the base is
  current. k81, k153 and k154 are complete, so consumption may start.
- 2026-11-22: The System Events reads run `osascript -s so`. The host page
  `osascript(1)` says that the default form "can introduce ambiguities", and
  that the `s` modifier prints recompilable source. The `o` modifier prints a
  script error to stdout. A host control showed that `{"a, b"}` and `{"a",
  "b"}` both print `a, b` by default. Thus the separator defect goes away at
  the source, and each list compares as a parsed list.
- 2026-11-22: The AppleScript Language Guide page of error numbers names
  -1728 and -1719 as a missing object or index. Only these two are an absence,
  and only the label poll, the item frame poll and the row frame poll admit
  one. Every other error number, a syntax error and any status other than 0
  or 1 are unavailable. The SDK on this host has no numeric list for -1728.
  `AppleEvents.h` defines -1743 only.
- 2026-11-22: No System Events read is in the evidence class. An Apple event
  can start System Events and can raise its Automation consent prompt.
- 2026-11-22: The enrolment sends a grant request, so it is a checked
  submission in the one-shot class. The read table now marks such an entry,
  and the backend admits the one-shot class only for it. The legacy client
  output and its predicate stay unchanged.
- 2026-11-22: Legacy `guest` merges guest stderr into its value, so legacy
  `sysevents` returns an error line as a value. The first character of that
  line is a digit, so the legacy frame polls stopped on it as on a position. The legacy grant check
  passed on a refusal, and the legacy Dock check read the error text as names.
- 2026-11-22: The frame polls keep the legacy predicate exactly: a position
  whose x is a nonnegative integer. The record keeps the human-readable
  rendering, and `click_centre` still checks it.
- 2026-11-22: The first baseline run failed on a fixture artefact. The
  fixture added a synthetic stderr line to a successful legacy `osascript`.
  A real `osascript` writes no stderr then, so the fixture now writes none.
  Five tests now lead with their strongest legacy defect.
- 2026-11-22: The host suite replaces only the System Events target. A
  test-only shim checks the exact invocation, and the real `osascript`
  evaluates a literal with the same flags. No Apple event reaches System
  Events, so no consent prompt can appear on the host. The enrolment runs the
  real client against a local stub server under a temporary HOME.
- 2026-11-22: My first host and synthetic assertions used `[[ … ]] && …`.
  Under `set -e`, a false left side does not fail a bats test. Each such
  assertion now has its own line.
- 2026-11-22: In the first mutation run, 15 of 16 mutations failed their
  named controls. S08 did not apply, because the instrument searched for the
  escape text of U+2026 and the source holds the character. The repaired
  instrument runs the whole set again into one receipt.
- 2026-11-22: The environment has no `GROVE_PROVIDER_EVIDENCE` and no
  `HARNESS_DISPATCH_RUN_ID`, so the review leaf gets no Creator line.
- 2026-11-22: The final mutation run fails each named control for each of the
  16 mutations. The measured run passes 15 Taskfile checks with 242 tests, and
  its 4437 subjects stayed the same. After it, only the report, the k151, k152
  and k76 task files and the new review leaf changed.
- 2026-11-22: The review settings-system-events-evidence-k155 sits before
  k152, because k152 and k76 build on these reads. Its body carries the
  artifact, its contract and the open doubts, with no conclusion.
