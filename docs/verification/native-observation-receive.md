# Native observation receive envelope

**The native callback is not the owned authenticated receiver.** On the pinned
25F71 image, CoreFoundation requests an extended trailer and adopts the received
voucher; HIServices then writes the observer pointer into the trailer context
slot. Successful post handling releases its OOL mapping itself, while the MIG
dispatcher destroys rejected complex requests. An adapter that mixed those
paths with unconditional envelope destruction could release the mapping twice.

This is static evidence and a conditional receive contract. No AX request,
notification delivery, resource-accounting control or closure experiment ran.
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
runtime prerequisites and every original k99/k94 criterion. k99 and k94 remain
live; k95/k96 cannot infer an exchange or publication/read/loss premise from
these tables. k91 retains its broader send/cleanup matrix; k86 maintained
consent/resource policy and k87 human agreement remain separate. No shipping
adapter, schema change, support restriction, k52 implementation or release
approval follows.

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
