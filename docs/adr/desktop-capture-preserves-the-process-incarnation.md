# Desktop capture preserves the process incarnation

A client captures the target process as `{ pid, startedAt }` at interaction
start: the PID and the kernel's microsecond start instant
(`proc_pidinfo(PROC_PIDTBSDINFO)`). Koine resolves only when both halves match
the live process. An absent process, or a live PID with another start instant,
is null. Koine never substitutes a later foreground application or a restored
process under an old capture, and never falls back to the PID alone.

This is the `koine-desktop/1` contract. Time cannot strictly guarantee that two
incarnations never collide, but a collision needs the kernel to reissue the
same PID within the same microsecond of start time, and Koine accepts that
residual risk.

Koine does not use a continuously held, non-time native identity, sampled in
the client's callback and transferred to Koine as a Mach right over an
authenticated channel, because it needs a new capture/transfer protocol, sample
attribution and expiry, and a body of native evidence far out of proportion to
the residual risk it removes. Koine does not use the PID alone, because PIDs are
reused, nor a Process Manager serial number plus boot identity, because the
[restoration counterexample](../verification/process-serial-lifetime.md) keeps
that pair while the OS process changes.

Process identity does not alone bind an AX destination. The
[public Accessibility decision](desktop-automation-uses-public-accessibility.md)
and the [machine spec](../specs/machine.md#native-targeting-discussion) state
the reuse races Koine accepts.
