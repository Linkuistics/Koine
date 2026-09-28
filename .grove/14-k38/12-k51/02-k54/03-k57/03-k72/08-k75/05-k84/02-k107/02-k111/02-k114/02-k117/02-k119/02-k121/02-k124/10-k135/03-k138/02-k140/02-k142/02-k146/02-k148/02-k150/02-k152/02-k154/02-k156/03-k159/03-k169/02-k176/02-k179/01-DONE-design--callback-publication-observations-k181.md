# callback-publication-observations-k181


## Goal
Specify the byte/observation and causal contract needed to distinguish attempted
publication, local write completion and feasible receiver observation.



## Context
Use the existing causal/native recorder contracts and V26 pending-native view.
The immutable transcript and Trace remain the seam; no native recorder runs.

## Done when
- State frame ownership, raw commit/begin/result/receipt and loss observations,
  error/partial/pending behavior, FIFO and exact external waits.
- Enumerate discriminating histories, including receipt before write-result
  recording, and show the required causal edges through the existing Trace.
- Reconcile both contracts, assessment and a checked visual view; distinguish
  this proposed successor from executable V1–V26. Give k182 every original
  k179 executable/version/frozen-corpus obligation and k180 its handoff limits.

## Notes
Diagnostic design only. This child completes no k179 or ancestor criterion that
requires executable falsification. Native viewing only in a disposable clone.

## Decisions (running log)

- Keep frame commitment, attempts, actual results and receipt distinct. Each
  serialized writer owns exact immutable bytes; each broker hop needs its own
  observation. Receipt order depends on contributing begins, never an inferred
  result. Use bounded interval evidence and the existing Trace, not another
  causal model. The successor changes broker wire observations explicitly;
  activation/helper/PID relays remain audit-only and old versions stay frozen.
- The sole in-session review found ambiguous loss classification and an unsafe
  buffer-lifetime endpoint. Clarify that an intact covering attempt can remain
  feasible with missing results, while missing necessary evidence is unverified.
  Require an outstanding call's buffer to remain owned until actual return or
  externally established process termination, even after abandonment. Preserve
  these dispositions in the assessment and commission tree review of the revised
  contract before k182 consumes it; no second in-session reviewer.
