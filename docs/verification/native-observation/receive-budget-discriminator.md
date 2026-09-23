# Receive acquisition discriminator

Freeze before execution. Run only in disposable TestAnyware clone
`koine-k102-budget`. This diagnostic exports no rights and sends only to its
own freshly allocated local port. It contacts no AX service or target app.

Question: does a 4096-byte receive buffer with MACH_RCV_LARGE and a 65536-byte
post-receive payload cap prevent acquiring a larger OOL mapping?

Use one ordinary virtual-copy OOL descriptor, outbound deallocate=false,
no voucher or reply right, an audit trailer request and one-second receive
timeout. Sequential payload sizes are 0, 32768 and 131072 bytes. Each message
has the same 44-byte inline representation. The sender is this process;
its audit token must equal a fresh TASK_AUDIT_TOKEN read. This is not the
held-other-task authentication or foreign-source test required by k101.

Record raw sent/received envelopes, actual trailer, returned descriptor flags,
local send reference counts, exact returned mapping presence before the
payload-cap decision, content equality and disappearance after destruction.
Keep the source mapping until afterward; it must survive envelope destruction.
Reject unknown/error forms rather than invent cleanup; process exit reclaims
this diagnostic's known resources. No error output is credited as balance.

Controls: receive the same large payload with only 32 bytes inline capacity
and MACH_RCV_LARGE; require TOO_LARGE and a still-queued message, then destroy
the owned receive/send port. Separately omit destruction for the over-budget
case: the mapping witness must detect the retained mapping and exit 1, after
explicitly reclaiming it. Normal run exits 0. No destructive buffer mutation.

The largest sender allocation is 128 KiB, with at most one message outstanding.
The instrument's fixed input bound is separate from any receiver admission
guarantee. No stress, VM exhaustion, partial copyout, OOL-port, physical/volatile
OOL, guarded-right or malicious sender schedule is claimed. The result must
either demonstrate this candidate budget fails or record an inconclusive run;
it cannot prove all native receive mechanisms impossible.

Hash source, executable, Taskfile, discriminator and consumed SDK message header
before/after; preserve guest executable digests, platform identity, launch status
and per-case output. Finish edits before measuring. Each control uses the same
binary with its recorded option.
