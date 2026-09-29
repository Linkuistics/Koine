# capture-transfer-admission-k108


## Goal

Establish a usable pre-acquisition resource envelope for a public native-right
transfer channel, or surface its concrete feasibility conflict.



## Context

Read `docs/verification/callback-capture-transfer.md` and the native receive
report's pre-copyout assessment. XPC's declared COPY_SEND and copy getter prove
public primitives, not a receiver quota. The measured AX/OOL cap failure is not
an XPC experiment or a universal impossibility result. This channel is designed
by Koine and can choose a smaller wire envelope than AX.

## Done when

- Compare XPC with a deliberately minimal public Mach construction against the
  required memory/right/queue bound. Before native work, identify a callable
  admission mechanism, exact size/trailer/descriptor semantics and complete
  accounting. A header-only send-right transfer is a lead to check, not a
  conclusion that its queue or receiver is bounded.
- Distinguish sender/kernel queued resources, copyout into the receiver, runtime
  allocations before callbacks, retained records and disposal. Account for
  header rights/vouchers, complex/ordinary/volatile OOL, port arrays, receive
  rights, send-once exceptions, repeated sends and partial copyout where exposed.
  Body validation, peer identity, grants, timeouts or queue count alone are not
  pre-acquisition byte/right budgets.
- Run a frozen isolated-VM sender/receiver discriminator: successful actual
  transfer with sender release; numeric-name-as-data refusal; adversarial
  oversized/resource-bearing messages; maximum concurrency and churn; failed or
  partial acquisition and teardown. Observe mappings/right counts before
  validation and after cleanup, and demonstrate the controls fail when broken.
- State concrete experimental ceilings, their enforcement point and every
  platform assumption. Distinguish those values from product budgets, which
  the full protocol must choose from ordinary workloads. Include untrusted and
  authenticated senders; consent or good client behavior cannot enforce a quota.
- Record a feasible candidate and limits for resident-capture-transfer-k109,
  or escalate the exact conflict and recommendation. No helper, weaker resource
  promise or changed application boundary follows without explicit agreement.

## Notes

This is a transfer-channel discriminator, not revived private AX work. It need
not settle discovery or the grant protocol; it must not claim the full k84
contract complete on a local IPC result. Reuse the existing native VM seam.
