# Desktop capture preserves the process incarnation

The desktop target is captured by the client's native event handler when the
interaction begins. It denotes that OS process incarnation and expires when
the process ends. Restoring the same logical application under a new process
does not keep the capture alive. Koine must not substitute whichever application
is frontmost when its query arrives, or another process that reuses a PID.

This boundary preserves ModalAnyware's interaction: a user invokes an operation
in one application and can choose a window after focus has moved elsewhere.
The identity must not depend on time. Timestamp identity remains in the existing
implementation while its replacement is designed; it is not the approved
first-release mechanism. The [machine spec](../specs/machine.md) identifies that
open contract change. Retained native identity is the next design direction,
not yet an approved transport, reference encoding or restart policy.

A public Process Manager serial number plus platform boot identity is rejected
as the process identity. The
[macOS 26.5 counterexample](../verification/process-serial-lifetime.md) shows the
same pair before and after automatic termination/restoration, with different
PIDs and audit-token pidversions. Even a live-process check accepts the restored
process if Koine receives the capture after restoration. This alternative would
need a separate trustworthy incarnation discriminator, or an explicit change to
logical-application semantics, before reconsideration. Deprecation is not the
reason for rejecting it.

Retained task rights alone do not settle target safety: they retain identity,
not ownership of a PID. Capture attribution and the native endpoint of every
effect must bind to the captured incarnation. Checking identity and then acting
through a fresh PID lookup does not meet that obligation. Client capture and
strict process lifetime are settled constraints; the remaining protocol must
establish them before the public schema changes.

Retaining an AX window and its AX application parent also does not supply that
binding. A [macOS 26.5 PID-recycling experiment](../verification/retained-ax-binding.md)
kept both objects and a task-name right while the original process ended. The
task right became dead, but the held window later addressed and minimized a
replacement process at the same PID, without a fresh AX acquisition in the
holder. A task check cannot exclude death between the check and that effect.
This candidate needs an independently established native endpoint binding;
retention plus another pre-check is not a replacement mechanism. Investigation
of private APIs inside Koine is authorized, while clients keep public APIs and
strict process lifetime remains required. No particular private-API solution
or relaxation of the no-substitution guarantee is agreed.

Private AX token or data reconstruction is not the missing binding either.
The [signed/hardened private probe](../verification/retained-ax-binding.md#private-token-and-data-reconstruction-also-cross-incarnations)
shows both reconstructed objects affecting a successor at a recycled PID;
reporting the element's "actual PID" does not distinguish that successor.
These routes add private dependency risk without satisfying strict lifetime.
Reconsider them only with an independently established native binding, not
another encoding or check. Direct acquisition of a retained AX service endpoint
remains an investigation. A [signed/hardened direct-port probe](../verification/direct-ax-endpoint.md)
found that the retained port stayed dead across actual PID reuse, and a fresh
error reply with a kernel audit trailer matched the retained live task while
rejecting a wrong-task control. This makes direct endpoint admission a concrete
candidate; it does not establish client-event attribution, receive-right
ownership across all native transitions, or the complete effect transport.
Continue evaluating that route without treating finite audit fields as permanent
identity or the successful admission test as an action guarantee. No complete
replacement mechanism is approved.
