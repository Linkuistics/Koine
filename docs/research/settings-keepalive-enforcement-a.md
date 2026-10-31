# Settings keepalive: external enforcement survey

Research-a for `settings-keepalive-enforcement-k106`, 2026-10-31. Audience:
`settings-keepalive-complete-profile-k107`. This consumes the reviewed k105
admission boundary, k108 findings and k109 integration, the
[owner spec](../specs/settings-keepalive-owner.md#resource-admission-boundary),
[resource report](../verification/settings-activation/KEEPALIVE-RESOURCES.md),
and the complete k102/k98/k96 charters.

## Result and scope

**An unchanged CLI with inherited process limits and reserved storage does not
establish the required profile.** The pinned producer has allocations before
geometry, decoded-size and encoded-size checks. A process map limit cannot
enforce those individual units. The kernel evidence also has qualifications at
exec and Mach remapping, and does not correspond to the installed kernel.
Storage quotas and reserves do not, by themselves, establish the required
metadata capacity or recovery of the single ordinal sequence.

The survey identifies concrete mechanisms and their failure boundaries. It
selects no numerical budget, producer change, isolation system or executable
profile. Source evidence cannot establish useful native fit. Missing inputs
continue to prohibit startup under the owner spec. No native limit experiment,
storage mutation, VM, candidate, freeze, acceptance or causal slot was used.

The most direct next candidate is an explicitly bounded producer plus qualified
process and storage containment. That is an inference from the gaps below, not
authority to change TestAnyware. Its actual owner must agree the dependency
work. Isolation remains a comparison, not a substitute already shown to preserve
the native capture and input contract.

## Evidence identities and limits

| Evidence | Identity and what it establishes |
|---|---|
| Intended host, read-only observation | `sw_vers`: macOS `27.0.1`, build `26A434`; `uname -a` and `sysctl kern.version`: Darwin `27.0.0`, `xnu-13432.1.9~1/RELEASE_ARM64_T6041`, arm64. This establishes host identity, not enforcement. |
| Published XNU inspected | Apple commit [`f6217f891ac0bb64f3d375211650a4c1ff8ca1ea`][xnu-pin], identified as `xnu-12377.1.9`. It is a different kernel. The bounded Apple tag/search review found no corresponding primary source for the installed `13432.1.9`; it does not prove none exists. |
| Producer source | TestAnyware `v2.7.0` basis, commit `65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03`, read with `git show` from the adjacent repository. The checkout HEAD is instead `a0d88be9a90a10ae243788f940d2b28e1c87fef4`. Current graph snippets were navigation only; historical claims use the pin. No installed executable was authenticated as that build. |
| Producer dependencies | The pinned `cli-rs/Cargo.lock` selects `image 0.25.10`, `png 0.18.1`, `jpeg-decoder 0.3.2`, `flate2 1.1.9`, `miniz_oxide 0.8.9`, `fdeflate 0.3.7`. The three inspected image/PNG/JPEG crate archives were downloaded from the publisher registry, matched to lock checksums, and the inspected cached source bytes matched the archives. |
| Koine | Starting parent `25923628`; current backend and inspector read directly. They are evidence of the existing boundary, not implementations of the proposed owner/launcher. |

The verified archive SHA-256 values are:

```text
image-0.25.10       85ab80394333c02fe689eaf900ab500fbd0c2213da414687ebf995a65d5a6104
png-0.18.1         60769b8b31b2a9f263dae2776c37b1b28ae246943cf719eb6946a1db05128a61
jpeg-decoder-0.3.2  00810f1d8b74be64b13dbf3db89ac67740615d6c891f0e7b6179326533011a07
```

Primary code is linked at the historical revision below. Private repository
links may require access; the source reads were local, not inferred from a
failed public fetch. Manuals describe API contracts, sometimes for old OS
versions. They do not override contradictory pinned implementation evidence or
establish current-host behavior.

## Process limits: what the source actually covers

### Installation floor, fork and exec

In [`dosetrlimit`][xnu-resource], `RLIMIT_AS` changes the calling process's
current map. `RLIMIT_DATA` also sets a whole-map limit. Both map setters refuse
a value below `map->size`; setting a lower hard limit does not evict existing
maps. Raising a hard limit requires privilege. The header makes `RLIMIT_RSS`
an alias of `RLIMIT_AS`, not an independent physical-resident-byte control.
These facts differ from the archived manual's data-segment and RSS descriptions.
See [map setters, lines 22084–22153][xnu-map],
[resource header, lines 504–516][xnu-resource-h], and [Apple's manual][setrlimit].

The existing [backend](../../scripts/vm-guest-exec.py) opens raw files and calls
`subprocess.run` with the lock descriptor passed through; it installs no resource
limits. Under the proposed unchanged-producer arrangement, the exact intended
install site is the backend's child **after commitment and child creation but
before exec of TestAnyware**, with applicable soft and hard limits, checked
return values and readback. The caller and owner must retain their own capacity
for terminal records. Installing limits in the owner would give them a different
failure boundary.

**There is no implemented or selected launcher whose map size can be measured
at that site. Its numeric floor is therefore not established.** A shell's RSS,
this research interpreter's map, or TestAnyware's post-start RSS would answer a
different question. For a forked Python backend child, the relevant floor is
the inherited Python map at the call, including runtime and mapped reservations.
An exec'd minimal intermediary changes that floor but adds another image and an
earlier bootstrap interval. An in-producer call changes the dependency. Neither
is silently selected here. Python also warns that `preexec_fn` is unsafe with
threads; a concrete launcher needs an implementation choice rather than an
assumed Python callback. [CPython subprocess documentation][subprocess]

Three distinct questions must stay separate:

| Question | Source answer | Still required |
|---|---|---|
| Can the launcher install the proposed limit? | It must be at least the calling map's size. | Exact image/runtime, call site, map-accounting measurement and successful setup on the intended host. |
| Does the producer usefully fit? | Loader, mapped images, allocator reservations, thread stacks and native work compete with buffers. A buffer sum alone is insufficient. | Complete useful workload and qualified runtime envelope, separately from installation. |
| Does exec preserve enforcement? | Fork copies map limits. Exec attempts to apply BSD limits to its new map. | The important exec qualification below, target-host correspondence and allocation-route coverage. |

Fork's [`vm_map_inherit_limits`][xnu-map] copies size/data/wire values at lines
13737–13743. Exec is weaker evidence than the earlier report's simple survival
description: [`kern_exec.c`, lines 1497–1533][xnu-exec], has already obtained the
loaded new map when it calls the size/data setters, and does not inspect their
return values. Those setters reject limits below the new map's size. Thus this
source does **not** justify treating preserved BSD limit values or a successful
`getrlimit` alone as proof that the new map accepted the limit. This is a
source-derived failure condition, not an observed bypass on this host.

### Allocations, files and aggregate exposure

The normal [`vm_map_enter` path][xnu-map] checks `map->size` against both size and
data limits, returning `KERN_NO_SPACE` and cleaning up the new mapping
(lines 3677–3725 and 3831–3856). This supports a bound on successful map growth
through that path. It does not mean that no temporary kernel work occurs before
failure, or that an allocation satisfied from an existing arena has an
independent size check.

There is a further coverage gap in the inspected `vm_map_remap` route:
lines 19766–19884 find space, link entries and add `target_size` to the target
map without the size/data comparison used by `vm_map_enter`. Its
`vm_map_is_map_size_valid` helper, lines 25590–25625, checks a kernel-map
single-allocation restriction and accepts user maps. This bounded source read
defeats an assertion that the cited `vm_map_enter` check covers every Mach
mapping route. It does not establish that the selected native encoder uses this
route, nor demonstrate an installed-host exploit. Both need qualification.
[Pinned VM implementation][xnu-map]

`RLIMIT_FSIZE` acts later and on a different unit. The regular-file write path
checks the writer's limit, permits the fitting prefix where applicable, and
returns `EFBIG`/signals `SIGXFSZ` at the boundary. Truncation growth also checks
the limit. This can leave a partial file, which must be retained. It does not cap
the in-memory PNG, total files, total bytes over many files, directory entries,
filesystem metadata, network output or a different process's writes. This
survey does not establish complete mmap/file-growth coverage from those two
paths. [Write path, lines 1265 and 1350–1435][xnu-vnops];
[truncate, lines 8635–8650][xnu-vfs]

Each forked process gets its own allowance; it does not share one aggregate
budget. `RLIMIT_NPROC` is checked against a real user's process count, with
privileged exceptions, not this operation's subtree or thread count. A process
group is useful for ownership and signals but supplies no memory accounting
boundary. [Fork checks, lines 240–283][xnu-fork]

The pinned macOS OCR dispatch copies PNG bytes into a blocking task, calls native
Vision in process, copies them into CFData, decodes a CGImage and accumulates OCR
results. In-process allocations through a qualified map-growth route would be
subject to that process's map limit; no per-request native peak follows from
the API. Apple describes Vision work on CPU/GPU/Neural Engine and advises limiting
concurrency for memory-intensive requests. No primary source found in this
bounded search supplies a hard per-request resource envelope or promises that
all driver, device and service work is charged to the client's map. Do not
invent either an all-in-process guarantee or a particular external daemon.
[OCR engine][ta-engine], [Vision binding][ta-vision], [Apple Vision session][vision]

There are definite boundaries outside inherited child limits. The CLI can ask
the already running app to start a VM over its socket; guest exec and file
operations go to the guest agent over HTTP. Client inheritance does not limit
those existing processes. Upload streams chunks in the pinned client; it is
not evidence of a whole-file upload buffer. Download streams to a temporary
sibling and removes it on error, which cannot be repurposed as proof of the
owner's raw/partial-retention contract. Whole response and progress handling
still need their own profile. [VM start][ta-vm], [app client][ta-app-client],
[agent client, lines 390–495][ta-agent], [file commands][ta-file]

## Capture allocations before checks

The following traces the selected RFB capture path and native OCR handoff at the
pin. It is not a claim to have audited every allocator inside every dependency.
Rust capacity growth, allocator overhead, codec state and native internals remain
additional peak costs. Protocol field widths are not useful workload budgets.

| Stage | Allocation and order | Consequence for enforcement |
|---|---|---|
| Security negotiation | Failure reasons use a server `u32` length before reading the string; offered security types use a `u8` count. | Bound lengths before allocation and reads, including error paths. |
| ServerInit | Width/height are `u16`; desktop name uses a `u32` length. The name is allocated before zero-size/frame validation. Framebuffer construction checks nonzero dimensions and multiplication overflow, then allocates `4WH`. | Overflow checks do not impose useful geometry or handshake budgets. |
| Other messages | Colour-map storage follows a `u16` count times six. Clipboard text follows a `u32` length even though it is discarded. | Non-image messages also need finite count, byte and elapsed budgets. |
| Raw rectangle | Payload `w*h*bytes_per_pixel` is allocated and read before `raw_rect` checks destination bounds. | A bad rectangle can allocate before rejection. |
| CopyRect | Framebuffer code validates source and destination before the in-place copy. | This path avoids another full rectangle buffer; it does not repair the other paths. |
| ZRLE envelope | A `u32` compressed length allocates the compressed vector before decode. | The wire field can consume memory independently of screen geometry. |
| ZRLE decode | Initial inflate capacity is proportional to compressed length; repeated 16 KiB chunks extend an uncapped inflated vector. Tile decoding and run/trailing checks happen afterward, with another `4wh` output. | Neither rectangle bounds nor successful final tile validation limits prior inflation. Persistent inflater state also costs memory. |
| Tight basic/fill | Fill allocates `4wh`. Basic paths calculate expected decoded size; palette/gradient forms add their own buffers. Compressed input uses the 22-bit compact length before inflation. | A finite protocol maximum is not the selected cap. `inflate_exact` can append a chunk beyond expected length before rejecting; capacity can exceed length. |
| Tight JPEG | The compact-length blob goes to `jpeg_decoder.decode()` before comparing decoded dimensions with the RFB rectangle. | The library defaults its output-buffer limit to `usize::MAX`; TestAnyware does not set it. Its optional output limit is not itself proof of a bound on every earlier codec allocation. |
| DesktopSize | The new `4WH` framebuffer is constructed before replacing the old frame. | Peak includes both old and new frames, before returning the old storage. |
| Capture selection | Logical scale 1 clones the wire frame through `Cow::into_owned`; scale greater than 1 creates a downsample. Physical capture clones the wire frame. | The connection and wire frame stay alive with the owned capture through encode/write. |
| Crop and PNG | Region checks follow acquisition. Conversion creates a cropped RGBA vector; the PNG writer builds encoded bytes in a `Vec`, before `std::fs::write`. | Output-file enforcement is too late for pixel and encoded-buffer units. |

Sources: [connection, lines 87–198, 247–270 and 380–492][ta-connection];
[framebuffer, lines 24–193][ta-frame]; [ZRLE, lines 50–93 and tile decoder][ta-zrle];
[Tight, lines 69–295][ta-tight]; [capture, lines 55–146][ta-capture];
[screen command, lines 51–140][ta-screen]; [JPEG decoder][jpeg-source].

For Tight's negotiated three-byte pixels, copy/gradient data is `3wh`.
The gradient conversion adds a `3wh` reconstruction and `4wh` BGRX output.
Palette decoding retains up to 256 raw three-byte entries and their four-byte
converted entries, plus `ceil(w/8)*h` indices for two colours or `wh` indices
otherwise, then `4wh` output. Four persistent zlib streams may remain live.
The inflate loop runs while length is below expected, so its final append can
overshoot expected length by up to 16 KiB minus one before rejection; that is
not a capacity bound. These intermediates must be assigned to their actual
overlapping phases. [Tight implementation][ta-tight]

The selected image encoder defaults to fast PNG compression. In `png 0.18.1`,
that maps to `FdeflateUltraFast`. The encoder holds row buffers and a complete
zlib vector, then copies IDAT data into the outer PNG output. If fast compression
exceeds the stored representation, a second compressor builds the fallback
while the first compressed vector is still in scope. A peak calculation must
include these simultaneous capacities and possible reallocations, not just the
final PNG length. [Image PNG wrapper][image-source],
[PNG encoder][png-source], [compression mapping][png-common]

### Simultaneous frame accounting

Let `F = 4*wire_width*wire_height`, `S` be the selected owned capture bytes,
`C = 4*crop_width*crop_height`, `Z` be the encoder's intermediate compressed
capacity and `E` the outer PNG capacity. These are accounting terms, not new
profile limits.

| Requested surface | Retained connection | Owned capture | Before crop/codec additions |
|---|---:|---:|---:|
| Logical, scale 1 | `F` | `F` | `2F` |
| Physical, scale 1 | `F` | `F` | `2F` |
| Logical, valid scale 2 | `F` | `F/4` | `5F/4` |
| Physical, scale 2 | `F` | `F` | `2F` |

The connection implements integer downsampling, with scale fallback behavior;
these rows describe the 1x/2x workload cases, not permission to change resolution.
At PNG emission the source permits at least `F + S + C + Z + E` to coexist,
plus row buffers, compressor state, capacity slack and runtime. The fallback
compression branch can have a different peak. During decode, use the applicable
wire frame plus compressed/inflated/decoded intermediates; during resize use old
and new wire frames. Take the maximum of justified phase peaks, not the sum of
every mutually exclusive temporary. [Capture and frame ownership][ta-capture],
[connection][ta-connection], [PNG encoder][png-source]

OCR adds the still-owned PNG, its blocking-task copy, CFData, native decode and
recognition state, and results. The current Koine
[inspector](../../scripts/vm_capture_artifact.py) separately retains the encoded
file, accumulates IDAT, creates payload/CRC temporaries and decompresses according
to the header-derived expected size. Its post-exit validation does not constrain
the earlier producer. Streaming or explicit bounds for this validator remain
k107 design work. [OCR engine][ta-engine], [Vision binding][ta-vision]

There is no useful absolute-time proof in the capture helper's five-second
wait: it guards readability before the full message read, and repeated messages
can extend work. OCR polling checks elapsed time after recognition returns.
The outer owner must retain its separately designed absolute deadlines and
containment outcome; it cannot derive a synchronous native completion guarantee
from those helper timeouts. [Capture refresh][ta-capture],
[OCR command, lines 153–248][ta-screen]

## Storage: concrete arrangement and remaining qualifications

Apple documents an APFS reserve as available capacity and a quota as a maximum;
the installed `diskutil(8)` describes the reserve in terms of user-file data.
The APFS format has per-volume reserve/quota block fields, but also shared
container structures. These sources do not specify a worst-case inode,
directory-entry and metadata reservation for this workload. A reserve is more
than a free-space snapshot; it is not evidence that all the owner's record
creation will succeed. [Disk Utility guide][apfs-guide],
[APFS reference, volume superblock fields, page 54][apfs-format]

### Arrangement that k107 can evaluate

The following is an implementable topology, **not a qualified or selected
configuration**. All provisioning would precede a run and requires its own
authority. No volume or directory was provisioned here.

| Backing storage | Physical contents | Authority and capacity requirement |
|---|---|---|
| Terminal volume | Root identity manifest, original lock, global allocation/recovery records, all clean/failed lifecycle rows, final caller outcome | One original writer domain. Reserve and cap this class independently of outputs; include every admission, refusal, cancellation, setup result and damaged record. |
| Ordinary volume | Scenario/tick attempt directories with assigned ordinals, raw streams, images, result/validation receipts and partials | Independently capped aggregate usage. No access path may charge these bytes to terminal or collection storage. |
| Collection volume | Collection attempt directories and outputs, finite observer/window/screenshot sequence, audits, exact-clone stop and independent inventory evidence | Independently reserved and capped. Directory creation itself occurs here, so ordinary-directory exhaustion cannot consume its directory budget. |

A private logical root binds the three volume identities and their mount
relationships. It is not enough that the same path strings still exist: loss or
replacement must refuse use. The backend receives the already assigned
directory, ordinal and inherited original lock. It does not scan either volume
for a maximum ordinal. The public flat-root scanner is unsuitable for allocating
this split layout. These requirements follow from the
[reviewed storage contract](../specs/settings-keepalive-owner.md#retention-and-protected-capacity)
and the [existing scanner](../../scripts/vm-guest-exec.py).

Three APFS volumes in one container offer actual reserve/quota controls, but
their shared metadata and documented accounting exclusions still need a proof
or bounded qualification. Distinct, fixed-capacity backing devices/partitions
with separate containers would remove that particular shared block pool; they
still share possible device/I/O failure and need a metadata budget. This is a
more invasive alternative, not permission to repartition. Sparse images, logical
file sizes and thin clones alone are not evidence of physically reserved
capacity. No primary source found here turns a mere three-volume layout into
the complete guarantee requested by the spec. [APFS format][apfs-format]

File-space preallocation can contribute to a design, but does not complete it.
Apple's `F_PREALLOCATE` with `F_ALLOCATEALL` requests all requested space or none
for a file and reports allocated bytes. It does not preallocate all future
directory names or record metadata. The unchanged producer writes by pathname
through `std::fs::write`, which creates/replaces the file contents; a designer
cannot assume a preallocated output survives that opening/truncation behavior.
An already open, retained extent interface would be a producer change.
[Apple fcntl manual][fcntl], [Rust write contract][rust-write],
[screen output path][ta-screen]

The complete budget must bound object counts as well as bytes: ordinary and
collection attempt directories, raw stdout/stderr, captures, receipts,
temporary files, partially created objects, terminal event rows and recovery
records. Account for simultaneous extents, block rounding, filesystem metadata
and allocation failures. A finite precreated pool might help protect terminal
records, but its slot-binding, immutable-partial retention and interaction with
charge-before-attempt-creation would need explicit design. No per-inode quota or
metadata-reservation contract sufficient for this profile was found in the
primary sources examined. Do not count precreation as already approved.

### Single-sequence recovery after owner loss

The following is a candidate recovery protocol for k107 to specify and review.
It makes the missing write ordering visible; it is not a new adopted schema.
It must preserve the existing commitment charge point and original lock.

1. Before any operation can consume an ordinal, persist a bounded allocation
   fence in terminal storage. It identifies the root/generation and a finite
   range or upper frontier that recovery must never reuse. This is an allocation
   recovery record, not a dispatch commitment or an installed-limit claim.
2. In the owner's serialized transition, assign the next ordinal and charge
   its full contribution. Persist its class, backing identity and assigned
   directory before creating that directory, publishing commitment or creating
   the backend. Failed creation/publication does not refund the charge.
3. The backend uses only that binding. Later launch and terminal rows append
   actual setup, execution, retained extents and unknown facts. They never
   rewrite the commitment. All these rows, including successful ones, consume
   terminal capacity.
4. A collection-only generation waits for established holder resolution and
   acquires the same writer domain. It validates terminal identity and the
   durable frontier before assigning anything. An unused or uncertain fenced
   ordinal is burned, with the uncertainty retained; it is not fabricated as an
   executed operation or silently reused. Exhaustion of the six-digit domain
   refuses further allocation.
5. Partial reservation records remain intact. Recovery validates a bounded
   prefix and records a separate recovery disposition. It never truncates an
   unknown tail to make it valid. If the frontier, backing identity or lock
   ownership cannot be established, collection is unavailable. Separate root
   scans cannot reconstruct a lost global order.

The fence is needed because a death after an in-memory assignment and before
any durable binding can otherwise leave no evidence that the ordinal was
consumed. K107 must reconcile its exact representation and durability with the
existing immutable lifecycle sequence. The write-ahead fence is a design
inference, not something `flock`, `rename` or APFS supplies automatically.
No cross-volume atomic rename exists; even a same-volume rename can fail for
quota/metadata reasons. The terminal log must govern side effects in the other
objects. [Apple rename manual][rename]

Keep process-loss recovery separate from power/device-loss guarantees. Flush
APIs have documented limitations; the archived `fsync`/`F_FULLFSYNC` descriptions
do not prove a current APFS multi-file transaction. Unknown durability remains
unknown. `flock` is advisory and shared across duplicated/forked descriptors;
it is an ownership mechanism for cooperating participants, not isolation from
every same-user process. Do not delete or replace the lock to recover.
[Apple fsync manual][fsync], [fcntl][fcntl], [flock][flock]

| Failure | Required disposition |
|---|---|
| Ordinary allowance exhausted | Close eligibility; retain complete and partial artifacts. Use collection storage only for the finite collection path after ownership permits it. |
| Limit setup or CLI fails after commitment | Preserve ordinal, charge, raw/partial files and separate setup/execution facts; no retry. |
| Collection quota/write fails | Retain its partial attempt and failure. Terminal capacity records it where possible; ordinary storage is not borrowed to conceal the failure. |
| Terminal write fails | No later dispatch justified by an unrecorded commitment. Final facts can be unavailable despite reserved capacity. |
| Owner dies with known fence and resolvable holder | Recover conservatively under the same lock; burn uncertainty and use only collection work. No scenario restart. |
| Unknown holder, missing backing or unprovable tail | Collection and any unsafe new ordinal remain unavailable. No second lock, allocator or cleanup writer. |

These are requirements and consequences of the proposed protocol, not successful
tests of that protocol. Protected capacity cannot guarantee service after device
loss or make an unavailable holder release the lock.

## Mechanism-by-obligation comparison

“Conditional” means the source supports part of the mechanism, with qualifications
above; it does not mean qualified on this host.

| Obligation | Unchanged CLI + inherited limits | Explicitly bounded producer | Isolation boundary |
|---|---|---|---|
| Handshake lengths, geometry, decoded units before allocation | **Fails as a complete mechanism:** only an aggregate map envelope, with gaps; producer checks are late. | Can check every entry path before allocation, if dependency implementation and codec coverage are established. | Aggregate memory containment does not enforce individual geometry/encoded units. |
| PNG/native encoder peak | File limit acts after encoding; map route/native coverage unresolved. | Capacity-aware buffers and decoder limits can cover owned memory; native internals still require evidence. | Can contain some aggregate work if all producers/services are inside; host device/runtime exclusions remain. |
| Fork/exec and launcher useful fit | Conditional, with caller-map floor and unchecked exec setter results. | Installation after own startup changes bootstrap coverage; no free solution. | Requires its own launch/bootstrap and service-membership proof. |
| Aggregate descendants/services | Per-process limits insufficient. | Explicit admission/counts can bound known children; separately running services still separate. | Linux cgroup v2 supplies a hierarchical memory/process mechanism for its members; it does not move the macOS app or Vision inside it. |
| Encoded/raw file size and total retention | FSIZE conditional per file; independent quotas and complete byte/object accounting still needed. | Can bound writes, but quotas/reserves and partial retention still needed. | Filesystem and storage reservations still needed. |
| Protected terminal/collection capacity and global sequence | Possible topology above; metadata/recovery qualification remains. | Same owner/storage duties. | Same duties; isolation cannot invent a durable global binding. |
| Preserve transport/input/held-frame behavior | Best compatibility, but fails the conjunction of required units. | Must preserve all existing behavior and undergo owner-approved dependency qualification. | Native macOS workload and transport equivalence unestablished; no substitution selected. |

Linux cgroup v2's `memory.max` is hierarchical and can invoke cgroup OOM;
documentation permits temporary excess. `memory.high` is pressure/throttling,
not a hard maximum. Swap and `pids.max` need separate treatment, with the latter
counting tasks including threads. Those are useful contrasting semantics, not
a macOS facility. A configured Apple VM `memorySize` describes guest RAM; the
API does not promise a cap on all host hypervisor, display, driver or service
memory. [Linux 6.12 cgroup v2 documentation][cgroup],
[Apple Virtualization memorySize][vm-memory]

## Controls and later capability scope

The existing approval covers audited copies with phase barriers and a
replaceable continuous-clock reader, plus established controlled CLI/sleep
boundaries. It does not approve new limit-call, allocator, capacity or write
substitutions. The
[resource-control matrix](../verification/settings-activation/KEEPALIVE-RESOURCES.md#resource-control-enabling-points)
and k107's explicit choice still apply.

| Question/control | Actual enabling point | Scope and what a result could establish |
|---|---|---|
| Refusal at commitment | Real owner checks the declared remaining class capacity before assignment/charge/directory creation. | Safe offline record/state controls can check ordering once implemented. Replacing the capacity observation is a new substitution needing approval. |
| Limit-call refusal | Actual launcher calls `setrlimit`, or an audited copy substitutes that exact result. | A deliberately inadequate AS/DATA value depends on the actual caller map. Native limit testing needs separate scope; a substitute qualifies handling only and is not yet approved. |
| Failure after successful setup | Controlled CLI exits or leaves a partial result after launch. | Existing controlled transport can distinguish execution failure from setup refusal. It cannot prove the kernel's limit semantics. |
| Ordinary exhaustion with protected capacity | Writes reach a real bounded ordinary backing object, while collection/terminal use their own objects. | Native storage provisioning/exhaustion is separately scoped. A fake quota/write result is a new, unapproved copied-module substitution. |
| Protected write fails | The owner's terminal append, collection directory/file creation, or caller final publication actually fails. | Name each write site; an external CLI cannot force every owner-side write. Real failing objects need scope, or explicit approval of each copied write-result seam. |
| Unknown holder or lost owner | Approved barriers/clock controls at the real ownership/recovery boundary, controlled children and retained descriptors. | Can check no dispatch, no lock bypass and honest unknown facts. Does not prove native reap latency or storage durability. |
| Decoder/encoder cap and useful fit | Producer entry lengths, allocation/capacity operations and native call boundaries. | Small offline fixtures can check explicit guards once an owner-approved producer exists. Native encoders/OS coverage require separate qualification; do not expand payloads to exhaust this host. |

If k107 still needs a native capability study, its explicit reviewed scope must
first name the following. This survey does not execute or grow such a task.

- Exact question: on the identified host and selected binary/runtime, what is
  the launcher's map size immediately before installation; do the chosen limits
  apply after fork/exec and to the required mapping routes; can the declared
  useful workload complete inside them? Keep floor, enforcement and usefulness
  as separate observations. A bounded test cannot prove every undocumented path.
- Exact process/service membership, permitted APIs, finite small inputs, timeout,
  child/holder cleanup, raw evidence and stop conditions. Do not use a fork bomb,
  global same-user process exhaustion, system-memory exhaustion or an unbounded
  malformed image as a probe. Do not change the native OCR engine or app route
  to obtain a favorable result.
- For storage, an explicitly authorized disposable backing object, provisioned
  reservation/quota, total extent and object-count ceiling, metadata question,
  write/flush/recovery points, cleanup responsibility and preserved evidence.
  No use of existing evidence volumes or machine-wide free-space exhaustion.
- Separate claims for successful setup/readback, denied allocation/write,
  partial retention, terminal availability, process loss and device-loss limits.
  Any test-copy substitution must be declared and approved in addition to the
  existing barriers/clock seam; it proves the coordinator's reaction only.
- No E/A or closed causal slot, candidate/freeze/acceptance run, cap expansion
  or unauthorized implementation in another repository. The resulting evidence
  must return to design and independent review before consumption.

## Reversal conditions and unresolved inputs for k107

| Present conclusion | Evidence that could change or qualify it |
|---|---|
| Cited XNU is not host-corresponding. | A primary source/build correspondence for `13432.1.9`, or narrowly scoped host evidence with its limits stated. The older manual cannot supply it. |
| A readback does not prove complete exec/map enforcement. | Explain the unchecked exec setter failure and required Mach allocation routes with corresponding source and bounded capability evidence. [Exec][xnu-exec], [map setters/remap][xnu-map] are the concrete challenges. |
| Actual launcher floor and useful fit are unknown. | Select the exact launcher and install point, then obtain its map-accounting evidence and complete workload fit. A different process's RSS cannot reverse this. |
| Unchanged capture does not enforce required units. | An owner-approved source revision with pre-allocation checks for all paths in the allocation table, codec/encoder capacity evidence and preserved transport behavior. Lowering one process cap or adding a post-capture validator does not reverse it. |
| Native/device/service aggregate work is uncovered. | Establish actual membership and accounting for the selected OCR/app/guest routes, including exclusions; bound each required resource or retain unavailability. |
| Three reserved/quota volumes are not yet a full storage proof. | Establish user-data and metadata/object accounting, useful reserved capacity, binding identities and owner-loss recovery under one sequence; or qualify a different physical arrangement. |
| A partial global binding cannot be repaired by scanning each output root. | A reviewed durable frontier/fence and bounded recovery schema which never reuses uncertain ordinals and preserves unknown tails. |
| Existing test-seam approval cannot induce all failures. | K107 obtains the explicit new substitution choice, or reviews separately authorized real-mechanism controls. Neither option proves more than it exercises. |

No numerical dimensions, byte budgets, object counts, launcher floor, native
peak, protected reserve or full-run allowance are supplied by this survey.
K107 must derive them from the entire useful workload and name the enforcement
owner before each allocation/write. Reconcile the 600-second start queue,
boot/interrupted-start containment, uploads, tick count, collection and final
record tail. Do not fit the budget by omitting a tick, changing input order,
downsampling, deleting evidence, retrying a transport or selecting a different
OCR path.

All original k89/k81/k76/k67/k62/k57/k54 duties and the k102/k98/k96 charters
remain open. Whole-design review, earned integration, externalized planning and
implementation still precede consumption. The already approved clock/barrier
seam stays approved; other substitutions and native work stay unapproved.

## Walk-away checks and search silence

| System considered | What remains legible with the tool uninstalled |
|---|---|
| BSD limits/XNU launcher | Requested/observed values, executable and kernel identities, setup errors and raw statuses can remain in plain immutable records. A limit itself disappears with its process and is not proof after the fact. |
| TestAnyware/explicit producer | Original PNGs, raw streams, partial bytes, operation arguments and pinned source remain interpretable independently. A private decoder format or unrecorded service dependency would weaken that property. |
| APFS reservation/quota layout | Regular files and the root/volume/ordinal manifest remain interpretable on an APFS-capable system. Unmounting/removing the OS facility does not make that storage universally readable; export original files and identities when appropriate, without replacing evidence. |
| Linux cgroup or VM isolation | Plain artifacts and recorded configuration can outlive the runtime. Live cgroup counters and an opaque guest disk alone are not a sufficient portable audit trail. |

The bounded search found no primary guarantee for the installed kernel's exact
limit semantics, Vision's complete per-request resource envelope, APFS
per-workload inode/metadata reservations, or a universal flush-based
multi-volume transaction. It also found no existing selected launcher from which
to obtain the required install-point map size. These are explicit missing
inputs, not affirmative guarantees inferred from API names.

## Research and verification record

Tier 2 graph discovery used Koine project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14` and TestAnyware
project `Users-antony-Development-AbstractingComputers-TestAnyware`.
Initial Koine coverage generation was `2026-10-31T03:30:13Z`; the final path
check used `2026-10-31T03:41:27Z`. TestAnyware was
`2026-10-29T07:11:24Z`, a current-checkout index, not the historical pin.
Material source claims were checked against exact files. Coverage reported no
recorded gaps for the inspected code paths; the excluded Cargo.lock was read
directly. Unrelated/missing graph call edges were discarded, including a VM
start trace whose pagination ended without its evident source calls. No
negative or exhaustive source claim relies on graph absence.
New research and changed task text were read directly where freshness was
untracked or changed; no source completeness follows from the coverage signal.

Read-only host commands, pinned source downloads, registry checksum comparison
and documentation checks are the evidence gathered here. No native enforcement,
coordinator behavior, storage availability or useful fit is claimed by them.
The task's final running log records the documentation-check result.

[xnu-pin]: https://github.com/apple-oss-distributions/xnu/commit/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea
[xnu-resource]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_resource.c#L1430-L1654
[xnu-resource-h]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/resource.h#L504-L516
[xnu-map]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/vm_map.c
[xnu-exec]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exec.c#L1497-L1533
[xnu-fork]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_fork.c#L240-L283
[xnu-vnops]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/vfs/vfs_vnops.c#L1350-L1435
[xnu-vfs]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/vfs/vfs_syscalls.c#L8635-L8650
[setrlimit]: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/setrlimit.2.html
[subprocess]: https://docs.python.org/3.15/library/subprocess.html
[ta-connection]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/connection.rs
[ta-frame]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/framebuffer.rs
[ta-zrle]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/zrle.rs
[ta-tight]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/tight.rs
[ta-capture]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-vm/src/capture.rs
[ta-screen]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/screen.rs
[ta-engine]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-ocr-client/src/engine.rs
[ta-vision]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-ocr-client/src/vision.rs
[ta-vm]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/vm.rs#L96-L129
[ta-app-client]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-app-client/src/lib.rs#L332-L383
[ta-agent]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-agent-client/src/lib.rs
[ta-file]: https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/file.rs
[image-source]: https://docs.rs/crate/image/0.25.10/source/src/codecs/png.rs
[png-source]: https://docs.rs/crate/png/0.18.1/source/src/encoder.rs
[png-common]: https://docs.rs/crate/png/0.18.1/source/src/common.rs
[jpeg-source]: https://docs.rs/crate/jpeg-decoder/0.3.2/source/src/decoder.rs
[vision]: https://developer.apple.com/videos/play/wwdc2024/10163/
[apfs-guide]: https://support.apple.com/en-ie/guide/disk-utility/dskua9e6a110/mac
[apfs-format]: https://developer.apple.com/support/downloads/Apple-File-System-Reference.pdf
[fcntl]: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fcntl.2.html
[fsync]: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fsync.2.html
[rename]: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/rename.2.html
[flock]: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/flock.2.html
[rust-write]: https://doc.rust-lang.org/std/fs/fn.write.html
[cgroup]: https://www.kernel.org/doc/html/v6.12/admin-guide/cgroup-v2.html
[vm-memory]: https://developer.apple.com/documentation/virtualization/vzvirtualmachineconfiguration/memorysize
