# Native observation receive envelope

**The native callback is not the owned authenticated receiver.** On the pinned
25F71 image, CoreFoundation requests an extended trailer and adopts the received
voucher; HIServices then writes the observer pointer into the trailer context
slot. Successful post handling releases its OOL mapping itself, while the MIG
dispatcher destroys rejected complex requests. An adapter that mixed those
paths with unconditional envelope destruction could release the mapping twice.

The native-path inspection below is static evidence and a conditional receive
contract. The subsequent [acquisition-budget experiment](#acquisition-budget-experiment)
adds a bounded local IPC counterexample: a parser cap did not prevent acquiring
an oversized OOL mapping. No owned AX request, notification delivery or closure
experiment ran.
The [wire view](../design/architecture/index.html#diagram-process-observation-wire)
shows the new boundary. The [observation proposal](../specs/machine.md#observation-and-retirement-protocol-proposal)
remains unadopted; source identity alone cannot establish window lifetime.

## Evidence and measurement

The unchanged [read-only inspector](retained-ax-binding/receiver-inspect.m) ran
only in disposable TestAnyware clone `koine-k100-receive`. It reads its own
loaded bytes without invoking scanned functions or contacting an AX target.
`task fixture:ax-receiver-inspector` built it. The frozen
[discriminator](native-observation/receive-discriminator.md) governs the reads.
This development CLI is not a Koine consent or signed-build acceptance test.

[Platform identity](native-observation/receive-platform.json) is macOS 26.5
(25F71), arm64, HIServices arm64e UUID
`34C40608-353D-3A06-BBF1-6B927CB8B39D`. The
[CoreFoundation inventory](native-observation/receive-cf-functions.txt) records
arm64e UUID `04E3598B-F226-3250-B3B2-CE938DD4DB7E`.
Addresses apply only to the matching image and are never callable ABI promises.

| Read | Query and raw bytes | Completion and frozen subjects |
|---|---|---|
| HIServices source/dispatch/post | [query](native-observation/receive-symbols.txt), [bytes](native-observation/receive-inspection.json) | [launch](native-observation/receive-launch.json), [before](native-observation/receive-before.sha256), [after](native-observation/receive-after.sha256) |
| CoreFoundation receive/dispatch | [inventory command](native-observation/receive-cf-discovery.json), [query](native-observation/receive-cf-symbols.txt), [bytes](native-observation/receive-cf-inspection.json) | [launch](native-observation/receive-cf-launch.json), [before](native-observation/receive-cf-before.sha256), [after](native-observation/receive-cf-after.sha256) |

Both launches completed with exit 0 and no timeout. Host and guest scanner/query
digests match item by item; the corresponding `guest-receive[-cf]-before/after`
files preserve deployed inputs. Host before/after records include the scanner
source/binary, query, function inventory, decoder, Taskfile and discriminator.
The CoreFoundation inventory command is read-only discovery, not an AX run.

Every requested code entry resolves to its exact recorded symbol start and
returns 3072 bytes. Public entries resolve; the deliberately nonexistent symbol
reports missing. Full windows can include adjacent functions. The selected
[HIServices listing](native-observation/receive-disassembly.txt) and
[CoreFoundation listing](native-observation/receive-cf-disassembly.txt) stop at
the next function start in their inventories. The repository graph verified the
scanner and decoder at Tier 2, generation `2026-09-23T10:46:34Z`, with matching
metadata and no recorded gaps. Exact source reads confirmed the scanner's
self-memory access; its heuristic graph edges are not a platform call graph.
Inventories and raw native data were read directly.

## Source and receive context

`AXObserverCreate +0x38..0x94` creates the observer and passes it as argument six
to `MSHCreateMIGServerSource`, with flags and supplied port zero. It stores the
source and delivery port, then attempts queue limit `0x400`. That is an
unchecked native call here, not an observed successful limit setting.

`MSHCreateMIGServerSource +0x54..0xbc` installs a version-1 run-loop source
context with `mshRelease`, `mshGetPort` and `mshMIGPerform`. Its private context
stores the supplied observer at `+8` and MIG subsystem at `+0x20`. The default
path allocates receive and send rights; the prior
[connection report](native-observation-connection.md#four-different-port-owners)
distinguishes connection, delivery, endpoint and reply ownership.

The inspected `__CFRunLoopServiceMachPort +0x40..0x9c` passes options
`0x07000806` to `mach_msg`, adding `0x100` for a finite timeout. The installed
SDK and Apple's [message definitions](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/mach/message.h)
decode these as receive, large-message reporting, voucher receive and format-0
AV trailer, with optional receive timeout. That trailer contains audit bytes;
requesting them does not show that an AX callback authenticates them. The
initial inline buffer is `0xc00`; the too-large branch grows it to the reported
size plus `0x44`, aligned to four, and loops. This is not the candidate's fixed
resource budget.

At `+0xa4..0xd0`, the same helper reverts the prior voucher, adopts the message
voucher and optionally copies it. This is a static call path, not evidence of
the diagnostic's actual voucher or launch responsibility. The source-1 dispatch
path calls its registered perform function. Neither these selected helpers nor
their names establish every surrounding run-loop branch, intermediary, or TCC
policy consequence. An owned receive loop must make its execution context
explicit and must not adopt another client's authority.

`mshMIGPerform +0xb4..0xcc` stores the private context's `+8` value at
`request + msgh_size + 0x34` before calling the selected MIG routine.
`_XPostNotification +0x124..0x15c` reads trailer `+0x34` and passes it to
`_XXMIGPostNotification`, whose callback path uses it as the observer pointer.
Thus this callback argument is locally injected routing context. It is not
untouched kernel sender evidence, a native event age, or a window generation.
The full audit field is distinct, at trailer `+0x14..+0x33`.

## Reply and OOL ownership

`mshMIGPerform +0x90..0xac` initializes a simple `0x24` reply: received remote
disposition, received reply right as destination, null local port, and request
ID plus 100. The [matched decoders](native-observation-requests.md#decoder-contract)
supply NDR/status and expand successful add/remove replies to `0x28`. This
explains surrounding reply construction; it is not a native reply capture.

The dispatcher handles MIG no-reply (`-305`) separately. For other nonzero
simple errors with a complex request, `+0x218..0x228` clears its remote port and
calls `mach_msg_destroy`, preserving the reply destination already copied into
the reply. It sends a non-null reply destination at `+0x22c..0x25c`; selected
send-error branches destroy that reply. These branches do not cover k91's full
send-result matrix and must not be copied as a universal failure algorithm.

On normal post processing, `_XXMIGPostNotification +0x2a8..0x3a8` selects an
ordinary or info callback, potentially deserializing OOL data. Its common exit
at `+0x4a8..0x4e0` releases constructed CF values, calls `munmap(address, size)`
for nonzero info length and returns zero. The dispatcher therefore does not
also destroy that successful incoming complex message on its error path.
The owned design must use its own decoder and one resource owner, rather than
calling this private handler and then destroying the original message.

Apple's [userland destructor](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/libsyscall/mach/mach_msg.c#L310-L467)
walks received header rights and descriptors, not the local receive right.
Ordinary OOL release depends on the received descriptor's deallocate bit;
volatile OOL is skipped. It is not a bounds-checking parser for arbitrary
mutated bytes. The pinned [kernel copyout](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_kmsg.c#L3803-L3925)
maps OOL data before user parsing and derives the returned deallocate bit from
copy mode. Its [descriptor loop](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_kmsg.c#L4107-L4144)
can continue after individual copyout failures and report a body error.
These primary sources explain obligations; they are not matched 25F71 kernel
measurements. Outbound deallocate=false is not the received ownership contract.

## Conditional owned-envelope contract

The native transport owner retains the capture task, admitted endpoint, local
connection and delivery lifetime independently. It alone owns each received
envelope. A decoder borrows immutable bytes and returns bounded values; it
neither adopts vouchers nor releases rights or mappings. This internal seam
keeps callers from reconstructing cleanup rules and lets controlled envelopes
exercise rejection without adding a public API.

1. Give each add/remove/read one fresh owned reply receive right; delivery has
   its separate owned receive right. Record exact request bytes and the send
   outcome. Keep originals alive across waits; no PID-cache destination lookup.
2. Before receiving, choose an explicit finite buffer, timeout, interruption
   policy and format-0 audit-trailer request. Reserve aligned message space plus
   the complete requested trailer. No resize/retry loop or voucher-adopting
   run-loop callback is inherited implicitly. The voucher mode and ambient
   context still require the experiment below; this document selects no policy
   equivalence for omitting them.
3. A successful kernel receive creates an envelope. Before semantic use, check
   header bounds and the aligned trailer location with checked arithmetic,
   trailer type/size, and the entire audit range against received storage.
   Match the expected reply form or notification form. Compare kernel sender
   evidence to the continuously held live task after receipt. Body PID, cookie
   and local context cannot supply this comparison. Preserve the original
   envelope for disposal; parsing or controls must not corrupt its descriptor
   ledger.
4. Only after source authentication may a current-registration cookie select
   records. An old cookie or wrong source accepts no event. Authentication does
   not establish descriptor lifetime, event age or completeness. Malformed
   unauthenticated input discards resources; independently authenticated current
   registration failure may withdraw the dependent scope per the proposal.
5. On accepted or rejected messages, release the envelope once after copying
   any accepted bounded values. No borrowed OOL pointer escapes. A transferred
   resource would need an explicit ledger removal, not a second implicit owner.
   The minimal diagnostic proposes no such transfer and no info deserialization
   until that format and a bound are established. Protocol rejection must still
   clean up every kernel-valid descriptor form that can reach the port.

| Outcome | Ownership rule and required control before live exchange |
|---|---|
| Valid add/remove success or AX/MIG refusal | Dispose received envelope once; request owner separately retires its fresh reply right. Refusal does not prove native bookkeeping rolled back. |
| Foreign, old-registration or unexpected successful receive | Accept no state; dispose original kernel-returned resources. Synthetic parser mutations use a byte copy, never the destructible ownership buffer. |
| Valid notification with supported OOL | Copy only bounded accepted values, then dispose mapping exactly once. Verify received copy/deallocate representation and local mapping counts. |
| Unknown protocol form | Reject the operation; generic envelope disposal must already cover its kernel descriptor forms. A parser allowlist alone is insufficient. |
| Too-large, interrupted, timeout, body/header copyout error | Distinguish queued, not-received and partially returned resources from the actual kernel result. No universal destroy-on-error or no-message rule is established here. Unknown ownership prevents exporting the probe's rights and sending. |
| Cancellation, remove and late message | End acceptance first; keep separate envelope and port owners through bounded cleanup. Remove success proves neither delivery teardown nor drainage. k91 owns the broader schedules. |

**An inline buffer limit or a post-receive OOL size check is not a bound on
memory admitted by the receive.** The kernel may already have mapped OOL data
before either sender authentication or the protocol's repeated length check.
Before the owned experiment, establish a finite acquisition/resource envelope
and cleanup for all exposed descriptor forms, including physical/volatile OOL,
OOL ports and partial copyout, or identify the exact unsupported receive case
and stop. A guessed info cap or the ordinary sender's virtual-copy form does
not close that requirement against foreign input. This is an unresolved
preflight obligation, not a demonstrated impossibility of bounded reception.

## Next experiment and retained obligations

The [local budget result](#acquisition-budget-experiment) now falsifies using
fixed inline capacity plus payload rejection as the acquisition policy. It
does not resolve actual AX voucher context or the remaining ownership cases.

The existing owned path remains the recommendation: it exposes the retained
destination, fresh replies and one envelope owner. Reusing the native source
would add automatic buffer growth, voucher adoption, injected pointer context
and split cleanup to its interface. Calling private post handlers would hide
those same obligations. Reconsider only for a concrete primitive that supplies
the required ownership and authentication, not for a shorter call signature.

Before any AX send, the exchange must freeze and test the receive primitive's
actual trailer and error/ownership behavior, with local right/mapping accounting
and a bounded acquired-memory policy. Pin the actual voucher/execution context
and generic requester branch against launch responsibility. Freeze mutation
controls separately from the native ownership ledger. Neither the current
source scan nor a public observer callback substitutes for these controls.

Then run owned add, independently witnessed closure/delivery and remove,
including an unmodified application, registration refusal after possible
first-add bookkeeping, wrong-source and old-registration controls that fail
when broken, and unexpected reply cleanup. Authenticate every supporting
read/reference/confirmation; record correlation separately from freshness.
Record actual refused workflows and unsupported native forms, never omitted
windows. Remote/presenter/custom/block paths, non-generic requester classes,
nonempty info formats and the runtime source/intermediary chain remain
unvalidated. No application was exercised or observed refused in this slice.

k100 completes only the static receive-envelope design. k101 retains all these
runtime prerequisites and every original k99/k94 criterion. Its k102 child
supplies the local budget result; k103 retains a usable resource-admission
policy and the actual exchange. k101, k99 and k94 remain
live; k95/k96 cannot infer an exchange or publication/read/loss premise from
these tables. k91 retains its broader send/cleanup matrix; k86 maintained
consent/resource policy and k87 human agreement remain separate. No shipping
adapter, schema change, support restriction, k52 implementation or release
approval follows.

## Acquisition-budget experiment

**A 4096-byte inline capacity and a 65536-byte payload cap did not prevent a
131072-byte OOL mapping from entering the receiving address space.** This is
the concrete conflict for that candidate admission policy. It is not a proof
that all native receive strategies are impossible, or a measurement of added
physical memory. The [budget view](../design/architecture/index.html#diagram-process-receive-budget)
separates acquisition from later validation and disposal.

The [frozen discriminator](native-observation/receive-budget-discriminator.md)
and [instrument](native-observation/receive-budget.c) use one self-sent ordinary
virtual-copy OOL descriptor, no exported rights, and no AX endpoint. The largest
payload is 128 KiB, with one message outstanding. Those fixed test inputs bound
the experiment, not a receiver exposed to arbitrary senders.

`task fixture:receive-budget` builds the diagnostic with Apple clang 21.0.0,
`-Wall -Wextra -Werror`, SDK 27.0 and deployment floor 26.0; it never runs it.
Execution was only in disposable TestAnyware clone `koine-k102-budget`.
The [platform record](native-observation/receive-budget-platform.json) reports
macOS 26.5 (25F71), arm64, Darwin 25.5.0 / xnu-12377.121.6~2 and 16384-byte
pages. That record and the [image inventory](native-observation/receive-budget-images.json)
preserve system-library slice UUIDs. These are image inventory, not a byte match
of the running kernel to the explanatory open-source revision. The executable
is linker ad-hoc signed; this is not Koine signing, consent or release acceptance.

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
successful receive supplied a 52-byte format-0 audit trailer, matching a fresh
read of the current task's entire audit token. This proves self-sender agreement
only; it does not discharge AX responder or held-other-task authentication.

Nonempty returned descriptors carried copy=1 and deallocate=1 despite outbound
deallocate=false. Their mapping addresses differed from the still-held source;
the complete bytes compared equal. The instrument queried that span before
the policy decision and after destruction. Local send references remained 1,
the receive/send name disappeared at teardown, and the source mapping survived
until its own release. `mach_msg_destroy` supplies no status: the evidence is
its inspected once-only invocation plus the mapping observations. The mapping
query tests full-span containment in one region; it is not an exhaustive leak
detector for partial unmaps, fragmented mappings or total kernel resources.

The [before](native-observation/receive-budget-before.sha256) and
[after](native-observation/receive-budget-after.sha256) subjects match exactly:
source, binary, Taskfile, discriminator and consumed SDK message header.
[Guest before](native-observation/receive-budget-guest-before.json) and
[guest after](native-observation/receive-budget-guest-after.json) match the
host executable digest. The Taskfile later gained the diagram render entry,
after this measurement ended. No instrument or input was edited during a run.

### Admission design consequence

Keep one envelope owner and a borrowing decoder, but require an independently
enforced acquisition policy before exposing AX reply/delivery rights. Three
alternatives have different evidence:

| Approach | Evidence and consequence |
|---|---|
| Inline limit plus post-receive payload cap | Rejected as sufficient admission control by the measured ordinary-OOL case. Useful parser validation and prompt disposal do not undo acquisition. |
| Legacy scatter/overwrite receive as a presumed fixed OOL buffer | Not a substantiated replacement: the installed SDK defines `MACH_RCV_OVERWRITE` as zero; the inspected user wrapper marks `rcv_scatter_size` unused. A historical comment is insufficient. |
| A separately established native acquisition envelope | Still required before AX sends: name enforceable bounds on mappings and rights, queued resources and every exposed descriptor/error form. A mathematical maximum alone must be reconciled with a usable maintained budget. No such mechanism is established by this experiment. |

The explanatory [kernel receive path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/mach_msg.c#L309-L382)
handles inline-too-large before successful copyout; body-error paths can return
partially copied resources. The [OOL copyout path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/ipc/ipc_kmsg.c#L3803-L3925)
maps the payload and derives returned deallocate from copy mode.
The [user wrapper and destructor](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/libsyscall/mach/mach_msg.c)
separate receive-buffer selection from descriptor disposal. These sources
explain the obligation; the native result above is the 25F71 observation.
[Downloaded-source digests](native-observation/receive-budget-primary.sha256)
identify the inspected texts. No abstract model would establish those OS facts.

No foreign sender, physical/volatile OOL, OOL ports, guarded descriptors,
copyout failure, interruption or voucher-policy case ran. No target application
or workflow was exercised or observed refused. Zero/nonempty ordinary OOL and
inline-too-large are the only native forms measured here. A helper process,
target cooperation or application restriction is not authorized as a workaround.
The reversal condition is a concrete primitive or complete resource argument
with native controls enforcing a usable bound before excessive acquisition.

One independent reviewer checked the frozen instrument and discriminator
against SDK and primary sources before execution, finding no actionable issue
within this scope. Its stated limits are included above. Graph Tier 2 lookup
and exact source reads covered the probe; final reviewer coverage generation
`2026-09-23T11:22:34Z` matched both probe and discriminator, with no recorded
gaps. The graph is not evidence for native kernel behavior.

### Obligation handoff

| Original exchange obligation | Current evidence / remaining owner |
|---|---|
| Bounded acquisition and exactly-once cleanup | k102 disproves the cap-only policy and tests ordinary local OOL disposal; k103 retains an enforceable bound and every exposed foreign/error form |
| Voucher, requester and launch responsibility | Static paths only; k103 must establish actual execution context before sends |
| Owned connection/delivery/reply allocation and policy | Local probe port creation/limit calls succeeded; this is not AX connection acceptance or first-add bookkeeping cleanup; k103 retains both |
| Actual request, fresh reply, audit and live held-task attribution | Self audit only here; k103 must authenticate every AX read/reference/confirmation and delivery chain |
| Add, closure/delivery and remove with independent witness | Not run; k103 retains the unmodified-application case and complete raw/resource ledger |
| Refusal, unexpected reply, wrong source and old registration | Not run; k103 retains real controls and their falsification, without relabelling local IPC as native registration evidence |
| Unsupported forms, refused workflows and parent reconciliation | Explicit limits above; k103 reconciles all k101/k99/k94 criteria. All three nodes stay live |

k91 still owns the broader send/cancellation/drain matrix, k95/k96 publication,
read lifetime and loss/recovery, and k86/k87 maintained bounds, consent and human
agreement. No AX exchange, shipping feasibility or parent completion follows.

## Reproduction

`task design:decode-native-observation-receive` decodes both saved code captures
with Capstone 5.0.7, without executing native instructions. The task completed;
every saved code window decoded fully, and the
[complete subjects](native-observation/receive-complete-decode-before.sha256)
matched [afterward](native-observation/receive-complete-decode-after.sha256).
Native reproduction requires the pinned images and newly checked entry
coordinates. The preserved launch records carry the exact guest commands.

One bounded independent reviewer re-derived the cited paths from raw bytes
with Capstone and checked the primary cleanup source and SDK layouts, reporting
no material finding. This reviews static claims and the conditional contract;
it does not replace any runtime preflight control.
