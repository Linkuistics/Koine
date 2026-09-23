# process-identity-without-time-k51 — brief

## Goal

Replace the time-based process incarnation in `koine-desktop/1` — the client's
`DesktopProcessIdentity { pid, startedAt }` and the start instant that
application and window references encode — with a mechanism that does not
depend on time, and record it as the contract, before the first public release
publishes the current one.

## Current targeting agreement

In `native-target-contract-k78`, the human selected **endpoint addressing only**.
Capture/reference lifetime remains tied to the original process; Koine never
rebinds its admitted endpoint. Receiver movement, descriptor reuse, forwarding
and downstream effects on another process, including a restored successor, are
explicitly outside the effect guarantee. Read the current capture ADR and
`docs/specs/machine.md#native-targeting-discussion` for the precise boundary.
This qualifies inherited strict-effect criteria below; historical investigation
and decision logs retain the requirements against which they were written.
Public clients, callback-time capture, non-time identity, Koine consent and no
helper/injection/cooperation remain required. No shipping mechanism, lifecycle
policy, restart policy or first release is approved. k79 reviews this agreement;
k75 retains the full protocol and k52 handoff. The parents remain live.

## Context

- **The human's decision, in `documentation-and-handoff-k45`**, answering the
  contract-only client's first finding (the spec never names the instant's
  source): "Anything that depends on time is inherently problematic. You cannot
  guarantee non-collision, especially given multi-core machines. I would prefer
  some mechanism other than time." They then chose to design it **before**
  `homebrew-distribution-k46`, so the first public `koine-desktop/1` already
  carries it. Do not re-ask whether; this leaf decides how.
- **What exists today.** The provider reads `proc_pidinfo(PROC_PIDTBSDINFO)`'s
  `pbi_start_tvsec`/`pbi_start_tvusec` (`Providers/DesktopProvider/Sources/ProcessIdentity.swift`),
  renders it `YYYY-MM-DDTHH:MM:SS.ffffffZ` (`Logic/ProcessStart.swift`) and
  compares exactly; references encode the microsecond count
  (`Logic/DesktopReference.swift`, e.g. `koine://desktop/application/363/1789906911246535`).
  The client has to capture the same instant, which no documented CLI can give
  at that precision — the contract-only client compiles a C helper at runtime
  (`docs/verification/contract-only-client.md`, finding 1; the author's own
  account is `contract-only-client-gaps.md` §1.1–1.2).
- **What the public macOS SDK does and does not offer**, read from the SDK
  headers in k45, not from memory — re-check before relying on it:
  - no per-pid non-time incarnation identifier in public `<sys/proc_info.h>`:
    `PROC_PIDUNIQIDENTIFIERINFO` and the kernel's per-boot `p_uniqueid` are not
    in the public header;
  - `audit_token_to_pidversion()` (`<bsm/libbsm.h>`) is public, but a caller
    can also obtain another same-user task's token via `task_name_for_pid`
    and `TASK_AUDIT_TOKEN`, subject to policy. Investigation below corrects
    k45's narrower premise and explains why the 32-bit pidversion is insufficient.
- **Candidates k45 named, none evaluated:** a Koine-assigned incarnation token
  from Koine's own launch observation — for example a lookup such as "the
  frontmost application" that answers with a reference, so the client never
  handles a pid at all; audit-token `pidversion`; the private `uniqueid`. There
  may be better ones. Whatever is chosen must still keep the existing
  guarantee: a recycled PID never selects a new application, and a missing
  reliable identity is an input error, not permission to target by PID alone.
- **The interaction the contract serves**: ModalAnyware captures the
  application at interaction start, then lists and focuses its windows. A
  mechanism that is correct but cannot be captured at that moment by a
  TypeScript-fronted client with a native side does not serve it.

## Done when

- The mechanism is chosen **with the human**: the candidates with the
  trade-off, a recommendation and its evidence, as `references/execute.md`
  frames a hand-back.
- `docs/specs/machine.md` and `docs/design/desktop-schema.graphql` state it,
  and the application-reference encoding it implies, precisely enough that a
  client written from the documents alone needs no guess — the standard the
  contract-only client's findings set.
- An ADR records the decision, the time-based design it replaces and why.
- The impl leaf after this one (`process-identity-without-time-k52`) has what
  it needs: its body names the provider, schema, reference, test and evidence
  changes, and which VM evidence documents must be re-run because they cite the
  schema digest or the old reference form.

## Notes

The contract is still `koine-desktop/1`: nothing has been published, so this is
a change to the agreed contract before its first release, not a version bump —
confirm that framing with the human along with the mechanism.

## Investigation

The macOS SDK in Xcode on this host declares `task_name_for_pid`,
`TASK_AUDIT_TOKEN`, and `audit_token_to_pidversion`. The earlier claim that an
audit token can only be obtained for self or a message sender is too narrow:
[XNU's task-name lookup](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/kern/kern_proc.c)
can obtain a same-user task-name port (subject to MAC policy), and
[task_info_from_user](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/kern/task.c)
accepts that port for `TASK_AUDIT_TOKEN`. This is source evidence, not a
signed-build compatibility test.

`pidversion` alone does not establish permanent non-reuse:
[fork allocation](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/kern/kern_fork.c)
increments a shared 32-bit `int`, and
[exec](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/kern/kern_exec.c)
also increments it. `p_uniqueid` is wider and non-time-based but its query is
not declared in the installed public `sys/proc_info.h`. The public
`NSRunningApplication` header directs callers to `isEqual:` instead of PID
comparison and says a PID can change on automatic termination; it does not
specify a portable non-time process-incarnation value.

Client-event capture is required. A retained task-name right captured there and
transferred via native IPC is the next design direction; sending a Mach port's
numeric name as JSON does not transfer that right. Server-side foreground
capture is rejected. See
[Capture at the server or at the client event](../../../docs/design/architecture/index.html#diagram-process-capture).

One bounded fresh-context reviewer examined task-port lifetime/equality,
death, PID reuse, exec, and the boundary to PID-based Accessibility APIs.
The native mechanism, reference encoding and version framing remain unagreed;
the capture boundary and strict process lifetime are settled below.

### Public serial-number candidate

The installed public HIServices `Processes.h` declares `GetFrontProcess`,
`GetProcessForPID`, and `GetProcessPID`, all deprecated since macOS 10.9.
Its current comments describe PSNs as unique identifiers for application
instances. Apple's [classic Process Manager documentation](https://developer.apple.com/library/archive/documentation/mac/pdf/Processes/Process_Manager.pdf)
states per-boot uniqueness; that older statement is not runtime proof of the
modern implementation. A native event handler can capture a canonical PSN
directly rather than discovering a PID and acquiring its identity later.
The public IOKit header `pwr_mgt/IOPM.h` declares `kIOPMBootSessionUUIDKey`
as an identity for one boot that remains unchanged through sleep and hibernation.
A boot identity would scope a portable PSN; time must not be used as that scope.

A throwaway C probe, compiled on the host with its public SDK and run only in
TestAnyware clone `koine-k51-identity`, observed on macOS 26.5 (25F71):

| Subject | PID | Canonical PSN | Result |
|---|---:|---|---|
| TextEdit before termination | 690 | `0000000000026026` | Front capture, PSN→PID and PID→PSN succeeded |
| Old PSN after termination | — | `0000000000026026` | `GetProcessPID` returned `procNotFound` (-600) |
| TextEdit after relaunch | 758 | `000000000002d02d` | Front capture and both lookups succeeded |
| Old PSN after relaunch | — | `0000000000026026` | Still `procNotFound` |
| PID 1 | 1 | — | `GetProcessForPID` returned `procNotFound` |

Both live TextEdit runs also allowed task-name acquisition and audit-token
reads; repeated acquisition coalesced to the same port name in the probe's
namespace. These observations establish neither actual PID reuse nor counter
wrap, PSN non-reuse for an entire boot, automatic-termination semantics, native
action binding, or the signed Koine app's behavior. No Koine was launched.

The subsequent automatic-termination experiment **rules out PSN plus boot
identity for the agreed process-incarnation contract**. A diagnostic app's
serial survived its process's end and identified a new PID after restoration.
The repeat held PSN `000000000003f03f` and boot UUID constant while PID changed
893 → 910; a live-process check after restoration cannot reject that pair.
Sources, raw output, unchanged before/after hashes, public IOKit boot retrieval,
reproduction and limits are in
[process-serial-lifetime.md](../../../docs/verification/process-serial-lifetime.md).
The earlier quit/relaunch result is accurate but does not cover this lifecycle.

### Bounded review outcome

The sole in-session reviewer identified four valid, actionable obligations for
the task-right candidate. Sources are pinned to XNU commit
`f6217f891ac0bb64f3d375211650a4c1ff8ca1ea`:

- A task right does not reserve the PID. Checking it and then creating an AX
  target from PID permits termination/reuse between those steps. Every
  effectful operation needs a native endpoint bound to the captured identity;
  another pre-check or a post-check cannot provide that binding.
  [Task port lifetime](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/kern/ipc_tt.c#L437-L453).
- Looking up a task right from a PID does not prove it is the application
  observed earlier. Initial capture needs an explicit boundary and attribution
  rule. `task_name_for_pid` may return success with a null port, which must be
  refused. [Lookup](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_proc.c#L5882-L5923).
- Equality of port names is useful only in one namespace while ownership is
  continuously retained. Exclude null/dead rights, serialize retirement with
  comparison, balance temporary acquisitions, and transfer actual rights
  across processes. [Copyout coalescing](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_object.c#L939-L955).
- Task replacement during exec invalidates the held right. Never reacquire the
  replacement by PID under an existing reference.
  [Exec task replacement](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exec.c#L5110-L5133).

The review did not demonstrate retargeting of retained AX objects; it found
that their cross-incarnation binding was unproved. These findings are design
obligations, not permission to narrow the existing no-substitution guarantee.

No formal model is used for the unresolved platform-lifetime question: assuming
unique native identities inside a model would not establish that the platform
actually provides them. The probe and primary API/implementation evidence are
the appropriate instruments here. A later concrete protocol may have its own
ordering obligations worth modelling.

The comparison is served from `docs/design/architecture` at
`http://127.0.0.1:8772/#discussion`. Host browser automation had no available
browser. A copy was subsequently served and opened in Safari inside the
TestAnyware clone: the serial-number deep link reached the intended rendered
view, with the outline and current/updated markers visible. The PNG export was
also inspected. No mobile or dark-theme browser check was performed.

## Decomposition

The work crossed from evaluating a replacement value into designing native
capture/transfer and proving action binding. It no longer fits one focused
session. This is a concrete design split, not an automatic research or review
stage:

- `process-identity-boundaries-k53` records the agreed capture/lifetime
  constraints, corrects candidate premises, and preserves the public-serial
  counterexample and implementation/evidence impact.
- `retained-process-identity-k54` must settle a complete feasible native
  contract with the human and finish this node's original spec, SDL, ADR and
  k52 handoff criteria. No implementation should consume an unapproved proposal.

Read `docs/adr/desktop-capture-preserves-the-process-incarnation.md` and
`docs/verification/process-serial-lifetime.md` with the original contract. The
native direction has not resolved the PID-to-AX race; do not turn the task-right
candidate into a claimed guarantee by assumption.

## Decisions (running log)

- The human chose **preserve client-event capture** when offered that versus
  selecting the frontmost application when Koine handles the first query.
  A later server-side foreground lookup is therefore not a replacement for
  the captured target. This settles the capture boundary only, not the native
  transport, the identity mechanism or its remaining lifetime obligations.
- The human chose **evaluate public serial numbers**: investigate the smaller
  native-client PSN capture plus boot identity carried over GraphQL before
  choosing retained task rights and a native transfer path. This authorizes
  evaluation of the public, deprecated APIs; it is not approval of their
  lifetime guarantees, the final contract, or the version framing.
- After a macOS 26.5 VM demonstrated automatic termination/restoration with
  the same boot identity and PSN but a different PID (848 → 863), the human
  chose **keep strict process identity**. Captures expire with their original
  OS process; application restoration does not extend their lifetime. The
  boot-plus-PSN candidate is therefore ruled out as the process identity.
  Continue the retained-native-identity design; this does not yet approve a
  transport, a change to restart behavior, or the final contract.
