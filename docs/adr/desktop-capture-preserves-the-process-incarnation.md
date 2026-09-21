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
