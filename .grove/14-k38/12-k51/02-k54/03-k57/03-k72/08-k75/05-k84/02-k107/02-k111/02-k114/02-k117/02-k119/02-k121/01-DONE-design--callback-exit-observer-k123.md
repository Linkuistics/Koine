# callback-exit-observer-k123

## Goal
Establish externally observed exit status for an independently launched diagnostic
app, plus a bounded timeout control with a known descendant, before the recorder
uses this mechanism.

## Context
The k118 runner observes `open -W`, and its app's terminal record precedes
finalization. Neither supplies actual app exit status. Consume the native route
assessment and k121's retained original criteria.

## Done when
- Specify and implement a diagnostic-only gated observer using public process
  observation. Kernel registration must precede permission to exit; failures
  cannot pass as status zero. Keep launcher status separate from app status.
- Run signed LaunchServices apps in a disposable clone; record their own parent,
  identity and permission observations independently from the observer.
- Preserve raw evidence for normal zero, nonzero-after-success-intent, signal
  termination and watchdog termination of a root plus one known descendant.
  Check actual statuses and independently enumerate remaining group members.
- Expose build/run through Taskfile; run analyzer controls before native cases;
  freeze all declared read inputs and report itemwise digests, native dependencies,
  exact exits and measurement limits.
- Document integration obligations in the assessment/view and keep k124 live for
  actual four-process capture, returned boundary, messages and full provenance.

## Notes
This is a diagnostic design discriminator, not the completed recorder or a
universal process-tree supervisor. It does not establish capture or freshness.

## Decisions (running log)

- Use a socket-gated EVFILT_PROC/NOTE_EXITSTATUS registration for a separately
  LaunchServices-launched diagnostic app. Kernel exit status, launcher status and
  self-recorded intent remain separate; this is not a capture transcript.
- The single bounded reviewer found two valid/actionable evidence defects:
  proc_listpgrppids returns a count and can mask errors as zero, and unchanged
  guest bytes were not bound to the frozen local build. Check errno/count units,
  add an injected enumeration-error control, and compare complete guest/local
  file maps before and after measurement. These fixes have executable controls;
  no second review is required. The known-group and startup-failure limitations
  remain explicit and full recorder containment/provenance stays in k124.
- Frozen final native cases match all six expected outcomes, with unchanged
  itemwise host inputs and guest files bound to the local build. A waiting guest
  shell supplies actual observer exits; detached launch acknowledgments never
  count as completion. Read-only hash retries and earlier incomplete transport
  collections remain explicit. No native case was retried within the final run.
- The only new deliverable is the exit discriminator and its measured limits.
  k124 remains live for every original k121 capture/retention, four-role cleanup
  and full provenance obligation; k122 still owns gates and parent reconciliation.
  No ADR or product agreement changes follow from this diagnostic evidence.
