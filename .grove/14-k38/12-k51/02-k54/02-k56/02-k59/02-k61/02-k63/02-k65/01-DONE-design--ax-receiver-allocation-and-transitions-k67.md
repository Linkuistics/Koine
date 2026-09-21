# ax-receiver-allocation-and-transitions-k67

## Goal
Preserve the actual 25F71 receiver allocation/registration/cleanup evidence and
admitted direct-endpoint exec/restoration schedules, with their bounded contract.

## Context
- Parent k65 criteria remain binding. Top-level routing now has a separate
  concrete experiment and remains live in `ax-top-level-routing-k68`.
- `docs/verification/direct-ax-endpoint.md` holds protocol, earlier schedules and
  reviewer reconciliation. Preserve old measurements rather than replacing them.

## Done when
- Loaded-code evidence resolves the actual imported allocation, registration
  and release calls, and distinguishes supplied send rights from receive transfer.
- A completed native exec retains the same admitted endpoint, records old
  task/endpoint state and independently inspects the successor. The restoration
  attempt has an explicit outcome; unmet original criteria remain live in k69.
- Every claimed run has explicit program exit and matching measurement-input
  hashes. Calibration failures are excluded and explained.
- Evidence, capture ADR and visual discussion agree on what is established and
  what remains. The remaining routing leaf runs before policy/adoption. No
  product contract, source or schema changes.

## Decisions (running log)

- Reuse the audited read and effect helper semantics in a separate frozen
  transition diagnostic, leaving the earlier admission measurement unchanged.
- The first positive-control read raced AppKit's minimize animation. Allow at
  most 50 reads, separated by 100 ms and using the native one-second timeout,
  before allowing a transition schedule.
  The automatic-termination fixture also gets a minimizable window. An accepted
  request alone does not establish the visible control.
- Resolved the actual default MSH allocation, bootstrap send registration and
  release calls on 25F71. Ordinary allocated ports are not proved immovable;
  arbitrary target transfer/recovery and callback semantics remain outside this
  bounded contract.
- Frozen exec PID 867 retained its PID but replaced its task: both old rights
  became dead names, all seven later primitives refused, and the separate
  successor witness was unchanged. Program exit 0 was collected explicitly.
- Admitted restoration PID 905 passed the live control, then stayed live; the
  holder exited 25. Preserve its complete exit record and the earlier collection
  timeout separately. The no-AX control terminated at 937 and restored at 972
  with the same PSN/boot; fixture differences prevent a causal attribution.
- All fourteen receiver and eleven restoration input hashes match before/after
  and current host files; all eight guest executable/plist hashes match both
  periods. The scan's completed exit and saved-output digest match. Builds,
  rendering, task parsing, report links and manifest checks passed; the PNG and
  Safari deep link/outline/Current/Updated markers were inspected in the clone.
- Updated the capture ADR, evidence report and stable receiver view. The parent
  stays open with k69 then k68 live before k66 policy/adoption. No product change
  or full-contract acceptance follows from this leaf.
