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
