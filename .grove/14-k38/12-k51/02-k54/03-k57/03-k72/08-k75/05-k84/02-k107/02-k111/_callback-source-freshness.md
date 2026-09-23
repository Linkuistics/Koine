# callback-source-freshness-k111 — brief


## Goal

Establish or falsify the concrete public foreground source's freshness and
process mapping using exact guest implementation evidence and independently
witnessed native callback schedules.



## Context

Read the capture assessment's "Callback witness protocol" and sampling view.
Its witness is a design, not an existing fixture or validated oracle. Start
with the two named public pairs only: NSWorkspace.frontmostApplication plus
processIdentifier, and GetFrontProcess plus GetProcessPID. No wider API survey.

## Done when

- Inspect the exact guest public-entry paths through cache/IPC/process mapping;
  retain image identities, instruction ranges and primary-source limits. Identify
  actual observations separately from method entry/return. Unresolved boundaries
  stay explicit, never inferred fresh from a passing schedule.
- Build the narrowly scoped diagnostic and causal analyzer through the root
  Taskfile; freeze all source/configuration/dependency/schedule inputs before
  running only in a disposable TestAnyware clone. Exercise the specified missing,
  wrong-marker, reordered-record and outside-callback failure controls first.
- Reach ordinary live capture, delayed callback entry, switch during callback,
  withheld-main-loop and normally serviced comparisons, and switch after sample.
  Compare bounded pre-held candidates and one acquire/resample attempt; preserve
  captured B across later C input. Refusal-only output is not a working path.
- Run separate synthetic stale-F and stale-M controls, including plausible PID
  equality with a live right. Report native versus synthetic observations and
  whether any wrong attribution escaped the independent witness. Do not require
  runtime detection of a stale value the proposed source contract excludes.
- Record exact exits, per-case causal reachability, raw witnesses, before/after
  source and binary digests, thread/loop behavior, permissions and timing limits
  in the existing assessment. Update its view and the separate capture-source
  part of the Koine-side client note; do not edit ModalAnyware.
- Leave every lifetime/admission/protocol criterion live in its named owner.
  If neither source establishes freshness, surface the concrete gap and a
  recommendation without selecting cached data or weakening the contract.

## Notes

This is diagnostic design evidence, not product code. Any proposal to change
targeting or add permissions requires its own explicit agreement. Callback
entry delayed by the OS, an in-callback gate and a later worker are different
schedules. A blocked/disabled tap or absent input acknowledgment is unreached.

## Decisions (running log)

- Exact loaded-code inspection and a not-yet-built multiprocess causal fixture
  are independently checkable work. Split at that boundary before execution.
  Complete the entry-path inspection first; build and falsify the witness next;
  only then measure callback schedules. Preserve every original criterion above.
  Inspection alone cannot select a source or establish callback freshness.

## Decomposition

- `foreground-entry-paths-k113` records the two public pairs' loaded guest
  implementation paths, identities, bounded ranges and unresolved boundaries.
- `callback-causal-fixture-k114` builds the diagnostic and analyzer through the
  root Taskfile and demonstrates the causal failure controls before measurement.
- `callback-native-schedules-k115` runs the frozen live/delayed/switched/loop
  schedules, both constructions and stale-F/stale-M controls; reconciles every
  original k111 criterion and the separate client-source note.

All are diagnostic design evidence under the existing isolated VM seam. No
production implementation, API adoption or new permission agreement follows.
Lifetime cases stay in k112, admission in k108 and resident composition in k109.
