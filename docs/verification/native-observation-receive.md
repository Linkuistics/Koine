# Native observation receive envelope

**Koine does not own a private AX reply or notification channel, because no
mechanism bounds what such a channel acquires before Koine can parse it.** The
[public Accessibility decision](../adr/desktop-automation-uses-public-accessibility.md)
instead accepts framework-managed AX reception without a Koine-enforced
pre-acquisition bound. This record holds the measurement and source assessment
behind that choice. It is not a proof that every possible native mechanism fails.

## Acquisition-budget experiment

**A 4096-byte inline capacity and a 65536-byte payload cap did not prevent a
131072-byte OOL mapping from entering the receiving address space.** A parser
cap applied after receive is therefore not an acquisition bound. This is not a
measurement of added physical memory.

The [frozen discriminator](native-observation/receive-budget-discriminator.md)
and [instrument](native-observation/receive-budget.c) use one self-sent ordinary
virtual-copy OOL descriptor, no exported rights, and no AX endpoint. The largest
payload is 128 KiB, with one message outstanding. Those fixed test inputs bound
the experiment, not a receiver exposed to arbitrary senders.

`task fixture:receive-budget` builds the diagnostic with Apple clang 21.0.0,
`-Wall -Wextra -Werror`, SDK 27.0 and deployment floor 26.0; it never runs it.
It was executed only in a disposable TestAnyware clone. The
[platform record](native-observation/receive-budget-platform.json) reports
macOS 26.5 (25F71), arm64, Darwin 25.5.0 / xnu-12377.121.6~2 and 16384-byte
pages. That record and the [image inventory](native-observation/receive-budget-images.json)
preserve system-library slice UUIDs. The executable is linker ad-hoc signed.

| Case | Actual receive | Mapping before payload policy | Disposal observation |
|---|---|---|---|
| 0-byte OOL, capacity 4096 | Success, inline size 44 | No nonempty mapping | No nonempty mapping afterward |
| 32768-byte OOL, capacity 4096 | Success, inline size 44 | Present; policy accepts | Whole span absent afterward |
| 131072-byte OOL, capacity 4096 | Success, inline size 44 | Present; policy rejects | Whole span absent afterward |
| 131072-byte OOL, capacity 32 | `MACH_RCV_TOO_LARGE`, required inline size 44 | No received envelope credited | One message remains queued; owned port is torn down |
| 131072-byte OOL, destruction deliberately skipped | Success, inline size 44 | Present; policy rejects | Span remains present; leak witness fails, then cleanup runs |

The [normal launch](native-observation/receive-budget-normal.json) completed
with exit 0 and four complete per-case records. The
[mutant launch](native-observation/receive-budget-mutant.json) completed with
the required exit 1, not a timeout or transport failure. Both preserve exact
commands, raw sent/received envelopes, options and local accounting. Every
successful receive supplied a 52-byte format-0 audit trailer matching the current
task's audit token; this proves self-sender agreement only.

Nonempty returned descriptors carried copy=1 and deallocate=1 despite outbound
deallocate=false. Their mapping addresses differed from the still-held source,
and the complete bytes compared equal. The instrument queried that span before
the policy decision and after destruction. The mapping query tests full-span
containment in one region; it is not an exhaustive leak detector.

The [before](native-observation/receive-budget-before.sha256) and
[after](native-observation/receive-budget-after.sha256) subjects match exactly:
source, binary, Taskfile, discriminator and consumed SDK message header.
[Guest before](native-observation/receive-budget-guest-before.json) and
[guest after](native-observation/receive-budget-guest-after.json) match the
host executable digest.

No foreign sender, physical/volatile OOL, OOL ports, guarded descriptors,
copyout failure, interruption or voucher-policy case ran. Zero and nonempty
ordinary OOL and inline-too-large are the only native forms measured.

## Pre-copyout admission assessment

An owned channel would need an admission boundary that constrains receiver
mappings, imported rights and queued resources **before** protocol parsing,
including partially successful copyout. Fixed inline storage plus later
rejection fails that boundary, as measured above, and none of the inspected
alternatives supplies one.

This is a source assessment of XNU commit
`f6217f891ac0bb64f3d375211650a4c1ff8ca1ea`. It is not a byte match to the running
25F71 kernel. The installed SDK is macOS 27.0. The
[source manifest](native-observation/admission-sources.md) pins URLs, inspected
symbols and ranges, and [digests](native-observation/admission-primary.sha256).

### Admission alternatives

| Mechanism | What the inspected interface supplies | Why it does not bound acquisition |
|---|---|---|
| Fixed inline capacity, timeout and parser allowlist | Bounds inline storage and waiting; recognizes accepted payloads after receive | A 44-byte message already maps 128 KiB before the payload cap. The notification layout itself contains an OOL descriptor, so refusing OOL-capable messages also refuses ordinary native delivery. |
| Port queue limit | Counts queued messages, not their OOL bytes or enclosed rights | One accepted message can exceed any payload budget, and the [send-once path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_mqueue.c#L431-L475) can pass the configured limit. |
| Audit peek before receive | [`mach_port_peek`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/mach_port.c#L966-L1030) returns sequence, size, ID and trailer | It exposes no descriptor count, OOL lengths or port-array count. An authenticated target may still send a kernel-valid oversized body. |
| Legacy overwrite/scatter receive | Selects a separate inline receive buffer in the [user wrapper](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/libsyscall/mach/mach_msg.c#L190-L235) | `MACH_RCV_OVERWRITE` is zero in the SDK and the wrapper ignores `rcv_scatter_size`, so there is no caller-supplied bounded OOL destination. |
| Kernel type and size ceilings | Finite representation limits and platform-wide checks | No memory, right, queue and partial-copyout total reconciles to a usable resident-process budget. |
| `MPO_FILTER_MSG` | [Policy selection](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/kern/mach_filter.h#L39-L70) from sending task, port label and message ID | The callback receives no body, OOL lengths or right counts, and its [invocation](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_policy.c#L969-L978) depends on sender policy. |

A body-copyout failure cannot be treated as "nothing acquired". The
[copyout implementation](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_kmsg.c#L3803-L4144)
maps ordinary and volatile OOL through the same descriptor path, imports
port-array rights individually and accumulates descriptor errors while
continuing. The [receive result path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/mach_msg.c#L309-L382)
returns the partially processed body for body errors.

Other kernel policy mechanisms, task-wide quotas and alternate receive
architectures are not proved absent. A process boundary alone would not
establish a system resource budget or cleanup guarantee either.
