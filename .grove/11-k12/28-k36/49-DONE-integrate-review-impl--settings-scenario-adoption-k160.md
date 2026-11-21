# settings-scenario-adoption-k160

**Integrates:** settings-scenario-adoption-k159

## Goal

Triage the review of the complete ordinary Settings scenario. Apply the
findings that block agreed acceptance or identify a material risk. Verify the
resulting artifact before k67 consumes it.

## Context

Read the findings from the commit of `settings-scenario-adoption-k159`, whose
durable report is
`docs/verification/settings-activation/ORDERING-SCENARIO-REVIEW.md`.
The producer is `settings-scenario-adoption-k76`. Its contract, the k36 brief,
the ordering protocol and the reviewed helper handoffs remain binding.

## Done when

- Each finding is verified against the source and classified under the Grove
  integration procedure. Record the evidence and disposition of each one.
- Required repairs and meaningful verification are complete. Preserve the
  original control records and identify every subject of fresh verification.
- Update the report and handoffs to state the resulting behaviour and limits.
  Keep each later duty with its owner. k67 owns the setup, title and liveness
  work. k62 owns the prefix and duty comparison. k57 owns the caller and
  containment. k54 owns the freeze and runtime.

## Notes

No VM, candidate, freeze or runtime slot is authorised. Preserve the exact
successful actions, read counts, sleeps and bounds, the private originals and
partials, the common writer domain and the keepalive withdrawal. Optional
improvements do not widen acceptance. A finding may be rejected with evidence.
The review's list is not this task's acceptance checklist.

## Decisions (running log)

- 2026-11-22: Triage. Each of the four findings reproduces from the source,
  and each is a real issue. None is an unclear contract, and none needs a
  redesign. P2-1: macOS `/bin/bash` 3.2 ignores `set -e` in a function that a
  `||` caller runs, so the helper continues after a failed wait. A scratch
  script showed this. P2-2: the `optional` read accepts a match without a
  value, and the snapshot caller table requires the value. P2-3: `init` creates
  the root with ordinary `mkdir`, so its mode follows the umask. P2-4: the
  transcript setup opens a timestamped name with plain `tee`, which truncates
  an earlier file. Each case breaks a duty that the review cites. Repair all
  four here, with controls that fail before the repair.
- 2026-11-22: P2-1 repair. `_physical_sleep` in the physical facade keeps
  the status of every wait of `drag_window_corner` and `click_at`. In strict mode a failed
  wait records one sleep receipt, which latches the root, and the helper
  returns the failure. The wait operations end in `-wait`, and none begins with
  `resize-down-`, so the held-pointer state still comes from the held points
  alone. Successful waits keep their durations and positions.
- 2026-11-22: P2-2 repair. The existing request-label read selects `value`.
  This adds no read. A missing label or an omitted AXValue is unavailable.
- 2026-11-22: P2-3 repair. `init` creates every root with mode 700 and sets
  that exact mode before its first write. The repair is in the backend, so it
  covers each root, including those of k57.
- 2026-11-22: P2-4 repair. The shared transcript setup creates its file
  exclusively. A name that an earlier run holds stops the run with status 2,
  before any root or transport. Status 1 stays the clean false state with its
  receipt, and status 2 already means a refused existing root.
- 2026-11-22: Controls. The red record runs the three affected suites before
  the repairs: only the eight new or tightened controls fail. The simulated
  backend now applies each snapshot predicate as the real backend does. Thus
  the complete run is also a positive control for every snapshot predicate.
- 2026-11-22: Handoffs. k67 and k57 receive direct handoffs, because k67
  consumes the scenario next and k57 owns the containment that reads the
  receipts. Both task files needed a conversion first, which landed as its own
  change.
- 2026-11-22: No new review round. Each repair is a small, direct change for a
  named finding, and a control that failed first covers it. No repair is a
  redesign that needs another independent challenge. k67 consumes next, and
  k62 and k57 still reconcile every duty with this integration.
- 2026-11-22: Final verification. All eighteen affected Taskfile tasks pass,
  with 292 passing tests and no failure. None of the 4,492 subjects changed
  during the run. The records are in
  `docs/verification/settings-activation/ordering-scenario-integration/`.
