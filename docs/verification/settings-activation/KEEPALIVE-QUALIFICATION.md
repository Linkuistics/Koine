# Settings keepalive mechanism qualification proposal

## Decision and authority

Propose a minimal native intermediary, bounded backend pipe capture and
three separately backed storage classes. Qualify each claim separately before
using it in the complete owner profile. This is the design deliverable for
`settings-keepalive-qualification-k111`, following k114's integrated
[producer contract](../../specs/settings-capture-resource-contract.md).
The [qualification view](../../design/architecture/settings-activation/keepalive-qualification.mmd)
shows the evidence dependencies. The [storage view](../../design/architecture/settings-activation/keepalive-storage.mmd)
shows the proposed allocation and recovery order.

Antony approved designing this proposal. No capability experiment, launcher
implementation, external dependency work, image provisioning or VM is authorised
by it. Independent review and every earned integration precede an execution
decision or k112 consumption. No execution permission is requested now: the
exact executable subjects and several enforcement prerequisites are unavailable.

The [owner contract](../../specs/settings-keepalive-owner.md) remains authoritative
for eligibility, commitment charges, original-lock ownership, clocks, collection
and final publication. This proposal separates mechanism questions from future coordinator controls.
It does not supply a complete resource profile. All capability rows below are
**NOT RUN**. Source observations and documentation checks are not capability results.

## Subject closure before an execution decision

The [external evidence scope](KEEPALIVE-EVIDENCE-SCOPE.md) specifies the required
producer-unit, real-Fe, native, queue, loader, storage and host-work returns.
Its candidate scopes remain unavailable until every subject and cost is filled,
reviewed and separately authorised. It does not enlarge the 13-case envelope.

One immutable manifest must bind the following subjects. A changed subject
invalidates correspondence and returns to design/review. It never silently
replaces an execution slot. Missing entries keep the affected row unavailable.

| Subject | Current evidence and required closure |
|---|---|
| Koine baseline | `e52b04bc997fbb166e0a205bf98563f3345d5fa9`. The proposed owner, launcher, collector and recovery protocol are not implemented by this revision. Owner behaviour is a later implementation subject. Pin each mechanism probe independently before requesting its execution. |
| TestAnyware comparison source | `65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03` (`v2.7.0` basis), exactly as traced in the [survey](../../research/settings-keepalive-enforcement-a.md#evidence-identities-and-limits). It is evidence of gaps, not a conforming producer. No selected conforming build or unit-schema version is available. |
| Required producer | Its owner must supply a reviewed revision, complete lockfiles/features, bounded-operation contract version and unit-schema version, codec/native source evidence and build recipe. Bind executable bytes, Mach-O UUID/signing identity, linked images and loaded runtime versions to that source. A tag, path or version string alone is insufficient. |
| Host | Read-only observations on 2026-10-31: macOS `27.0.1`, build `26A434`, Darwin `27.0.0`, `xnu-13432.1.9~1/RELEASE_ARM64_T6041`, arm64. Record boot identity, hardware/page size, loaded system image identities and filesystem tools in the later manifest. Refuse host drift. |
| Kernel comparison source | Apple XNU `f6217f891ac0bb64f3d375211650a4c1ff8ca1ea` (`12377.1.9`) differs from this host. Require corresponding source/build evidence for any claimed route bound. Finite target-host observations can qualify named cases only. |
| Intermediary build | Proposed thin arm64 C17 executable, optimised with `-Os`, dynamically linked to libSystem. No shell, Python, Rust runtime, constructor work or additional framework. Pin compiler executable, flags, SDK, linker, deployment target, Mach-O/load commands, source and binary digest. This is a selected design, not an existing binary. |
| Collector build | A new backend-owned C17/libSystem executable, separate from the Python backend and intermediary. Use the same architecture, optimisation and provenance requirements as the intermediary. Pin source, fixed buffers, stack, allocator, linked images, loader exposure and binary identity. No collector binary or qualified runtime contribution exists yet. |
| Toolchain | Read-only `xcrun clang --version` reports Apple Clang `21.0.0 (clang-2100.4.1.1)`. `xcrun --show-sdk-path` names `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk`, but `--show-sdk-version` fails because that SDK cannot be located. The active developer directory is `/Applications/Xcode.app/Contents/Developer`. Clang resolves inside Xcode. The SDK path instead names Command Line Tools, whose `MacOSX27.0.sdk` directory exists. This is a mixed toolchain. No build correspondence or SDK selection is established. Resolve and review this before building a subject. Do not infer it from the Clang output. |
| Fixtures and controls | Pin every source, compiled helper, fixture byte string, expected result, approved copied-module substitution and copy audit. A small RFB fixture is a decoder control. It does not replace the native TestAnyware transport. |
| Storage | Bind three image file identities and allocation extents, attached devices, partition/container/volume UUIDs, mount identities, filesystem block sizes, quotas/reserves and all object-pool bindings. None has been created. |

Bind each source/build input to an available immutable archive and its digest
before work, recheck afterwards, and retain item-by-item differences. These
read-only prerequisite archives are not created by the study. All newly copied
inputs and generated records count within its retained-evidence ceiling.

Missing
archive access or insufficient fit prevents execution. Record the actual loaded executable and
environment at each launch. A binary built elsewhere needs equivalent
source-to-binary provenance. Merely hashing an unidentified binary proves identity
only. Release builds and instrumented probes are different subjects.

The manifest binds the producer's complete environment allowlist, including each
value or deliberate absence, before any loader runs. Pin locale, working directory,
target selection, loader selectors and permitted output handles as well as the
encoding/OCR selectors named in the producer contract. Keep exact values private.

Compare the effective encoding proposal and permitted set before connection.
Retain actual encodings used. Pin in-process Vision as the macOS path being
qualified if that is the declared workload. A Python/daemon OCR path is a
different subject requiring its own manifest and review, never a fallback to fit.
List every permitted child/interpreter and inherited descriptor. Unexpected
membership stops qualification and leaves its contribution unknown.

## Launcher and native coverage

### Chosen install point

After owner commitment and protected terminal binding, the backend creates the
two capture pipes and assigned output objects. It launches the native intermediary
with only the declared environment and descriptors. The intermediary receives
a bounded request (at most 16 KiB for these controls), using fixed storage.

It checks bindings and closes undeclared descriptors. It installs the declared soft and hard limits immediately before `execve` of the exact producer. It reports actual
call/readback outcomes through a separate bounded setup channel. Failure prevents
producer exec, preserving the committed ordinal, charge and partial evidence.

The intermediary replaces itself with the producer: it creates no additional
child. The backend retains its direct-child relationship and process incarnation
across exec. The collector is a separate backend-owned child in the backend group.

A backend reader thread would also survive producer exit. The proposed separate image instead makes its runtime contribution independently inspectable.
That costs another bootstrap, process identity and lock holder. No bound follows merely from choosing C/libSystem.
No limit is installed in the owner or finite caller.

The active backend passes the original writer descriptor to the intermediary, producer and collector.
The intermediary declares that descriptor and preserves it across exec. The collector retains it until its final write and exit.

Only assigned raw-storage descriptors reach the collector. The producer receives pipe write ends, its setup channel and assigned artifact/result handles.
The manifest lists every descriptor, inheritance flag and closure point. Undeclared descriptors close before exec.
The worker and scenario client still receive no writer descriptor. Recovery resolves every actual holder before acquiring that same lock.

The proposed installed limit set is closed:

- `RLIMIT_AS`: equal soft and hard values for the applicable map-size claim, subject to both floors and route coverage below.
- `RLIMIT_FSIZE`: equal soft and hard values for regular-file growth defence. L5 tests 4096 bytes only.

The file limit cannot enforce per-object or aggregate producer budgets, pipes, seek/mmap routes or protected storage.
Those duties remain with the producer guards, collector and backing arrangement. A useful-run file limit needs separate derivation.
No `RLIMIT_DATA`, `RLIMIT_RSS`, `RLIMIT_NPROC` or CPU-limit claim is made by this proposal.
The independent clock and existing containment policy retain their separate duties.

This choice avoids using the Python backend's inherited map as the install floor.
It costs an extra image and a **bootstrap interval before the intermediary's
limit installation**, including its loader and libSystem. Small C source does
not bound that interval. Backend/collector bootstrap and native kernel work also
need separate coverage. Until those contributions have an established bound,
the whole profile remains unavailable. A watchdog bounds eligibility and waiting,
not allocation before it can run.

Python `preexec_fn` retains the interpreter map and has thread-safety constraints.
An in-producer setter runs after producer bootstrap. Prefer this candidate to either alternative.
The survey explains both alternatives. None removes the
bootstrap obligation. Reverse this preference if a qualified parent-launch
facility covers the complete interval with less caller knowledge and unchanged
producer behaviour.

### Separate claims and finite controls

All sizes below are **study ceilings**, not useful-run limits.
`P` is the recorded host page size. `Fi` is the intermediary's map size at its audited install point.
`Fe` is the real producer's new-map size when exec applies the inherited limit.
The installable threshold must cover both: at least `max(Fi, Fe)`.
This threshold does not cover later loader/runtime growth or establish useful fit.

The pinned [exec path][exec-source] ignores the map-limit setter's return.
The [setter][map-setter] rejects values below the map's current size.
Thus, successful installation in the intermediary cannot establish effective installation in the producer.
L3's no-op images cannot supply the real producer's `Fe`.

The candidate observation for `Fi` is `task_info(TASK_VM_INFO).virtual_size` at the audited site.
The pinned [task implementation][task-source] reports `vm_map_adjusted_size`.
For an ordinary map, [that function][map-size] returns `map->size`.
The manifest must establish corresponding host source and the map category, sampling point and observation perturbation.
RSS, address-span sums and limit readback cannot substitute for this relation.

Require a measurement or conservative bound for `Fe` on the exact producer image before adopting any limit.
A post-exec user-space sample is later than the setter. It cannot directly measure `Fe`.

Its use requires corresponding source evidence that bounds intervening removals, additions and sampling effects.
Otherwise an independently reviewed observation at the setter is required.
No such method or producer subject is established here. This evidence is outside the no-op cases and their execution envelope.
K112 must present the exact additional observation scope and costs before requesting execution.
Unknown `Fi` or `Fe` keeps the relevant claim unavailable.

| Mechanism row / question | One finite control and decisive evidence |
|---|---|
| L1: installation floor | Three fresh child cases each contain their own no-op probe at the exact intermediary site. There is no fourth baseline process. Retain the complete map-accounting observation and return values. Separate fresh children request `max(0,Fi-P)`, `Fi`, and `ceil(Fi/P)*P+8P`. Each recomputes its own Fi under the same declared algorithm. Refuse if Fi or the computed limit exceeds 16 GiB. No search for a passing cap. The first tests rejection, the others installation only. Measurement must not allocate after Fi is sampled. Bracket any unavoidable observation perturbation and mark the floor unresolved if it cannot be bounded. |
| L2: map routes after installation | Three fresh child cases cover anonymous mmap, Mach allocation and Mach remap. Install `ceil(Fi/P)*P+8P`. Pre-touch the runtime before sampling Fi. Sample map size immediately before and after each request without unbounded observer allocation. First admit one page, then request eight further pages, with at most one page touched overall. Source must relate each route's charged size and temporary overlap to the limit. The first request is the in-budget control. The second must exceed the remaining allowance under the recorded map accounting. Unrelated errors, a failed positive control or unbounded incidental growth leave the result unresolved. Denial alone never qualifies a route. No allocation-until-failure search is permitted. |
| L3: exec coverage | Two fixed no-op images, one with an additional 4 MiB mapped segment, plus one same-image exec. Install the L1 computed limit before exec. Record pre-exec and new-image map/limit facts. Apply L2's bounded positive/excess pair and perturbation rules after exec. Record whether the image itself prevents this control. A target that cannot report remains failed/unknown. These no-op cases establish no real-producer floor. Preserved readback without effective map enforcement fails the claim. Source must address the survey's unchecked exec-setter return and remap route. Do not enlarge a cap after failure. |
| L4: inherited member | One declared helper child, no grandchildren, with one at-most-nine-page request and one 4097-byte output. Record fork/exec identities and limits. This tests the named member only, never an aggregate subtree guarantee or `RLIMIT_NPROC` by user exhaustion. |
| L5: per-file write boundary | A 4096-byte file limit, one 4096-byte write and a separate 4097-byte write in fresh children. Retain actual prefixes, syscall/wait results and SIGXFSZ where observed. No conclusion about aggregate files, pipes, mmap growth or native memory follows. |

The finite helper payload does not by itself bound kernel or loader work.
An execution proposal must state those remaining exposures explicitly and name
the evidence required to admit the study. These cases are not a universal proof
of undocumented routes. Corresponding source must cover every route on which
the final producer and launcher rely. Missing coverage remains a prerequisite.

### Producer guards and useful fit

The dependency owner supplies guard evidence at the actual allocation/write points.
It must cover every unit in its pinned resource schema and the complete producer contract.
This evidence is an external prerequisite, outside the mechanism-study case count.
The former 48-case envelope cannot cover the known boundary families and is withdrawn.
It grants no partial qualification or permission to omit a unit.

| Contract boundary | Evidence that the dependency must supply |
|---|---|
| Connection/handshake reader | Reasons, names, security negotiation, parser/read-ahead capacity, colour maps, clipboard text and discarded/error-message work. |
| Framebuffer manager | Initial geometry, checked products, rectangle ranges and simultaneous old/new frames at resize. |
| Raw and CopyRect | Wire/output capacity and both copy ranges before allocation or copying. |
| ZRLE | Compressed input, persistent inflater state, inflate chunks, total expansion, tile scratch and decoded output. |
| Tight basic/fill/palette/gradient | Every accepted mode, persistent streams, compressed input, palette/indices, reconstruction and overlapping output capacity. |
| Tight JPEG | Header geometry, compressed input, decoder workspace and output capacity before the relevant library call. |
| Capture selection | Scale-1 and scale-2 logical capture, physical capture, retained wire plus selected frame, resize and held-frame behaviour. |
| Crop and PNG | Crop, rows/state, compressor output, outer PNG and fallback-compressor overlap. |
| Native OCR adapter | Owned PNG/native-input copies and result collection, with native/image/device/service work separately bounded. |
| Output writer | Per-object and aggregate writes, temporary objects, structured diagnostics/results and actual partial-write retention. |

Each schema unit needs an in-budget, first-excess and malformed control where those categories apply.
The manifest must explain each inapplicable category. It must enumerate actual units and expanded cases before its separate review.
No grouped row above supplies a fixture count. A source-level branch or protocol field maximum cannot substitute for capacity evidence.
The contract's enforcement table remains authoritative if the dependency exposes additional units.

Candidate small-fixture ceilings remain 64-by-64 frames, 32-by-32 crops, 256 KiB wire bytes, 32 messages and 16 rectangles per operation.
Requested owned-buffer capacity is at most 4 MiB, with 256 KiB encoded output.
Arithmetic-overflow and excessive-length controls supply finite headers and require refusal before following the claimed length.

These ceilings do not establish aggregate fixture fit or approve a dependency execution plan.
That plan must count its own objects, retained bytes, processes and deadlines.
Preserve in-budget pixels and held-frame behaviour. No copied allocator or production injection seam is approved.

Pre-Vision copy controls cannot qualify native-input consumption or result collection after recognition.
Those controls need the real native path, including an exact Vision-call count in a separately reviewed execution request.
The current proposal grants zero Vision calls, VM launches and input actions.
No synthetic OCR result, engine replacement or transport change closes that evidence gap.

Small fixtures cannot establish the complete Settings workload's fit, tick count, transfers, timings or retained volume.
K112 retains those duties and the separately reviewed native/useful-fit scope.
Neither dependency controls nor mechanism cases spend E/A or closed causal slots.

Owned buffers, allocator/runtime maps, Vision/image frameworks, GPU/Neural Engine
and driver/service work are separate claims. The survey supplies no hard bound
for the latter contributions. Existing VM-host/app and guest-agent processes do
not inherit a newly launched CLI's limits. No process group, small successful
OCR call or configured guest RAM closes that gap. If a required native/service
bound cannot be established, return a requirements choice to Antony. Do not
adopt an outer-buffer-only profile or launch experiments to manufacture a guarantee.

## Backend raw descriptor capture

Choose two anonymous pipes, one for each raw stream, drained by one backend-owned
collector using fixed 4096-byte read buffers. Bind descriptors before the
intermediary launches so loader failures, direct native writes and panic text use
the same route. The producer never receives the raw-storage write descriptors.
Its structured result and artifact writers remain separate bounded interfaces.

Persist each completed nonempty read before the next raw read.
Do not defer persistence until a full buffer or EOF.
The R4 prefix observation and R5 first data-write controls depend on this production rule.

Define `Lout`, `Lerr` and `Lsum` as eligibility byte limits. The collector limits
each read to the remaining applicable allowance plus **one** byte. Complete EOF
at exactly the limit can be clean.

A first excess byte closes eligibility even
if producer exit is zero. A byte count equal to the limit without EOF is not
completion. A short storage write is also failure. Per-stream ordering is retained.
The collector does not invent a total order between streams.

Before launch, charge physical raw retention capacity for `Lout + Lerr + 1 + Q`,
plus metadata and any separately retained setup record. `Q` must cover the
maximum total outstanding accepted bytes in **both** pipes, including direct
transfer/pinned-write and temporary buffering paths. Charge collector capacity
separately: two 4096-byte buffers, at most 16 KiB control data, and the qualified
runtime/stack/allocator contribution. The per-stream and aggregate accounting
must include bytes in a partially persisted read buffer. No allowance can be
borrowed from terminal or collection storage for ordinary raw output.

At first excess or write failure, close eligibility and stop draining both pipes immediately.
Retain the current read prefix where storage permits. This failure opens the existing twenty-second containment window immediately.

An earlier open window keeps its original deadline. Do not postpone containment until the operation deadline.
Signal only established writers under that policy.
Draining while live writers can refill would invalidate Q.

After every writer is established unable to write again, drain the finite remainder once into the precharged tail.
Keep this drain within the original operation deadline or its already-open failure-containment window.
EOF, persisted counts, child outcomes and holder
resolution are distinct observations. No timer resets, new reader loop or
capture retry is allowed. Retention-tail bytes never become eligible output.

The [comparison pipe header](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/pipe.h)
has buffer constants and conditional direct-transfer structures. The
[implementation](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/sys_pipe.c)
must be read with its build configuration. Neither supplies Q for this different
installed kernel.

Do not assign 64 KiB from the header as a target-host bound.
Until queue, temporary-memory and capture-storage bounds are established, this
candidate cannot satisfy the producer contract or admit real producer work.
The raw group is blocked on this host.

No R row is currently runnable.
A stopped-reader nonblocking fill observes one write pattern and kernel state. It cannot bound every queued or direct-transfer path.
It therefore cannot replace Q. Global allocation conditions can change observed capacity without excluding a source-derived upper bound.
The missing facts are source/build correspondence and coverage of every relevant route.

Collector loss, failed tail storage or an unresolved inherited writer can lose
accepted bytes or leave them inaccessible. Record persisted prefix length,
accepted/queued observations and the unknown remainder. Do not report complete
retention or clean completion.

A successor never replaces the original lock or
opens another raw writer. The design therefore has a process-loss availability
limit: pipes are not durable spools. A non-growing durable backing object would
be preferable if its write, seek, aggregate and metadata bounds can be qualified.
A pre-sized regular file or direct raw file does not establish those properties.

The R rows are **future coordinator/collector implementation controls**, not pre-implementation mechanism cases.
The [owner test seams](../../specs/settings-keepalive-owner.md#test-seams-and-discriminating-controls) govern transitions and ownership.
The [producer control contract](../../specs/settings-capture-resource-contract.md#approved-koine-test-controls) governs substitutions and resource mutants.
Those sections are authoritative. The rows below map their obligations to the proposed pipe arrangement.
They require implemented subjects, a separate complete test envelope and established real mechanisms wherever a control relies on them.

| Later control | Fixed finite emission / required distinction |
|---|---|
| R1 | Empty streams. 4095, 4096 and 4097 bytes on each stream separately. And one byte on both streams. Eight cases. `Lout=Lerr=4096`, `Lsum=8192`. Exact-limit rows require raw-clean completion after actual EOF. Excess rows retain all 4097 accepted bytes on the emitting stream and empty originals on the other. Excess remains failure despite exit zero. |
| R2 | Both streams: 4096 each at `Lsum=8192`, then 4096 each at `Lsum=8191`. Two cases. Retain exactly 4096 accepted bytes per stream in both. The first requires raw-clean EOF completion. The second fails the aggregate although individual limits fit. |
| R3 | One 8192-byte burst per stream during the approved pre-read hold. One case. Release without waiting for write returns. Record entry, return and release order. Only independently established blocking tests release deadlock. Require all accepted bytes after writer resolution, using the raw design's independent prefix-plus-remainder oracle. Missing killed-write counts leave retention coverage unavailable. The observation route remains k125 work. No burst proves Q. |
| R4 | Four base cases: backend refusal of an absent executable, direct-write abnormal exit, an owned inherited-descriptor child, and collector death after 1024 persisted bytes. The first has zero external invocations and two empty originals, without pipe EOF. The child case holds both descriptors at exactly 4096 stdout bytes until real containment signals it after expiry. Require independent helper-exit evidence, descriptor closure, EOF and complete retention without clearing failure. The backend reaps only its own child. Actual loader-output capture remains an additional open obligation outside these four cases. |
| R5 | Two approved collector-copy write-result cases: fail before write. Write exactly 1024 real bytes then fail. Never fabricate a successful prefix. These qualify failure handling only. |

These 17 later controls retain a proposed 256 KiB total extent ceiling per raw capture object.
The [expanded raw design](KEEPALIVE-RAW-CONTROLS.md#fixed-case-matrix) specifies their observations and open coverage.
K125 must separately specify actual loader diagnostics after descriptor binding, without assuming their text size.
It also owns R3's missing observation route for blocking and killed-write accepted counts.
K124 and k126 retain the additional costs and complete R coverage duties.

The base count closes neither obligation. No collector site, numerical bound or native execution authority follows.

Antony approved the two named collector-copy boundaries on 2026-11-01, with a
separate source-correspondence audit. The [collector control decision](KEEPALIVE-RESOURCES.md#collector-control-decision)
records the exact sites, real-prefix requirement and rejected unaudited edits.
A backend-only or external control has not established the required reach.

The collector owns raw persistence, so a backend seam cannot be assumed to reach
its writes. The selected copies preserve the real failure paths and qualify
failure handling only. Their execution follows implementation and the required
planning/reviews. The approval supplies neither Q nor any native execution scope.

Q plus the stated limits must fit that ceiling before a native row is admitted.
Otherwise no row runs and the proposal returns to review. A control which leaves
a holder intentionally unresolved is followed only by exact owned-child teardown,
never another operation using that lock. No release of real input is involved.

## Disposable storage and recoverable order

### Backing arrangement and study ceilings

Propose three fresh **256 MiB fixed-size raw images**, each with its own partition
map and APFS container/volume: ordinary, collection and terminal. Create them
only in a new private study directory, never on existing evidence volumes.
Fully allocate each image on the host before attachment.

Reject sparse, cloned
or compressed backing. Record actual allocation and extent correspondence.
The [preallocation API](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fcntl.2.html)
is a candidate for allocating the entire backing object, not a guarantee of all
later host metadata or native I/O. If this arrangement cannot be established
within the fixed size, stop without resizing or using another disk.

Separate containers prevent ordinary guest-volume allocations from sharing the
collection/terminal container's internal free-block pool. Host APFS copy-on-write,
image-layer metadata and shared physical-device/I/O failures still require
evidence. The images alone do not establish protected capacity. No physical
repartitioning, host-volume exhaustion or power/device-loss test is proposed.

The study caps total image extents at 768 MiB and additional retained evidence outside them at 32 MiB.
Payload ceilings are 16 MiB ordinary, 8 MiB collection and 8 MiB terminal.
Within the images allow at most 512 created objects
total: 128 ordinary, 128 collection and 256 terminal, counting directories,
partial objects and recovery rows.

Retain all objects across the suite. Each
path component is at most 64 ASCII bytes and depth at most four below its class
root. No symlink/hardlink/clone, xattr growth, snapshot, compression or additional
writer is permitted in the fixture. The complete run's eventual workload is
different and must be accounted separately.

Predeclare one quota-boundary case with an 8 MiB ordinary-volume quota and a
fixed sequence of at most sixteen 1 MiB payload writes. Keep every prefix.
Setup failure, metadata overhead or earlier refusal is a result, not a reason
to change the quota.

If no boundary occurs within that finite sequence, the
case is inconclusive. Never keep filling the image or host. Collection and
terminal cases each have an 8 MiB study payload ceiling independent of that
quota. All physical metadata stays inside the fixed image extent where that
mapping is established. Any host allocation beyond the predeclared envelope
invalidates the proposed isolation claim.

### Candidate fence and binding schema

The [record and recovery specification](../../specs/settings-keepalive-records.md)
now owns the bounded schema and ordered writes. Use the original lock object in
terminal storage and one global ordinal sequence across the three bound storage
identities. Collection directories belong to collection storage. Neither class
root is an ordinal allocator.

The earlier **eight-ordinal fence** and **4096-byte record** are fixture choices,
not selected production values. S1 still uses fixed byte objects and establishes
no coordinator behaviour. A future coordinator fixture must instantiate the
schema's complete counts, vector maxima, slot size and physical metadata costs
within its separately declared envelope.
It cannot assume either study number fits, resize the study or borrow the 13-case mechanism allowance.

The proposed pool preassigns bootstrap, owner-history, owner-tail, single
collection-successor and caller-final ranges. Odd slots permit fences. Even
slots permit other records. Each attempted write consumes its full slot and
preassigned original-object attachments, including a failure before any byte is
written. Failed-writer ranges are burned, never cleared or reused. This layout
accounts for its own assignment without another allocation log.

Precreation,
fixed extents, opened identities and metadata protection still need qualification.

A valid fence precedes ordinal assignment and irreversible charging. The
terminal storage binding precedes attempt-directory creation. Complete commitment
and observed publication precede launch. Readback, flush and subsequent visibility
are separate facts. A record cannot attest to its own later successful flush.
The [walkthroughs](../../specs/settings-keepalive-records.md#checkable-walkthroughs)
cover clean work, failed commitment publication and owner-death collection.

After owner loss the original caller resolves actual holders and acquires the
same original lock. It scans the entire bounded predecessor ranges, including
gaps, and establishes a unique fence frontier. Unknown assignments retain
unknown charge facts and unavailable prior allowance. Burned ordinals are not
invented captures. An invalid/torn fence, damaged allocation chain, lost binding
identity or unresolved holder prevents new ordinals and collection. No lock
replacement, other root or scenario restart is allowed.

Ordinary fence width remains workload-derived. A collection fence binds one
ordinal and one immutable collection-plan item. Recovery never repeats a
possibly attempted collection item. It can use only a proven unattempted suffix.
It uses the separate successor lane, retaining all prior bytes. Caller or
successor loss permits no further recovery generation.

These are future coordinator obligations under the explicit
[mechanism assumptions](../../specs/settings-keepalive-records.md#assumptions-and-guarantees).
Still-mounted process-loss visibility must be qualified. No result establishes
power-loss atomicity, cross-volume transactions, device availability or universal
APFS metadata reservation. Full numerical capacities and useful fit remain open.

### Storage and process-loss controls

S1 is one pre-implementation storage-mechanism case. It uses throwaway file writes, not the future owner protocol.
Its collection and terminal records are fixed byte objects with declared names and lengths.

They establish storage observations only, never lifecycle, recovery or final-publication correctness.
S2 through S6 are future coordinator implementation controls under the authoritative owner and producer control sections.
Their original 18 cases are excluded from the mechanism-study envelope.

The [expanded recovery design](KEEPALIVE-RECOVERY-CONTROLS.md#accounting-alternatives-and-handoff)
preserves those cases and recounts publication, attachment, codec, recovery, lifecycle and deadline products.
The schema's [boundary mapping](../../specs/settings-keepalive-records.md#later-controls-and-remaining-inputs) remains authoritative.
The later executable manifest binds each canonical design ID to implemented subjects, exact invocations and complete accounting.
Declared aliases share that canonical result and all its assertions, without another invocation or charge.

The original eighteen remain canonical. Successor directory-create failure and scenario post-CLI validation remain additional obligations.
Negative complete-write observations use the [approved extension](../../specs/settings-capture-resource-contract.md#complete-write-observation-extension).
The expanded design count supplies no execution budget.

| Class / row | Finite cases and required observation |
|---|---|
| S1: ordinary exhaustion | One quota-boundary sequence above, followed by one collection directory/raw/receipt set and terminal failure/final rows. Retain actual block/object use before/after, identities and prefixes. Ordinary refusal must not consume either protected class. Failure of protected writes is a separate result. |
| S2: record coverage | One complete clean synthetic lifecycle and one failed lifecycle. Enumerate every owner row against the [lifecycle table](../../specs/settings-keepalive-owner.md#lifecycle-evidence-and-final-observation). Include received/admitted/resource-refused/cancelled submissions, phase reports, launch and resource observations, acknowledgements, completion sends/echoes, stop/reap/handoff, caller owner-exit/final-outcome, plus fence/binding/recovery rows. Backend request/raw/validation/result rows belong to their ordinary or collection attempt. The manifest supplies exact row counts and lengths within the pool, including parity-slot loss, preassigned original objects, setup and bounded write-failure summaries. No clean row is free. |
| S3: owner loss | Eight separately named controls: before fence. Partial fence. Complete fence before assignment. Charged assignment before binding. Partial binding. Complete binding before directory. Directory before commitment. Commitment before launch. Use approved barriers/result substitutions and real retained prefixes. A directly owned process ends once per case. Check burned uncertainty, no duplicate ordinal/charge, no scenario restart and truthful unstarted/unknown launch. Expand the schema's before-first-byte, flush, successor-entry and partially completed collection boundaries as separately named finite subcases. |
| S4: lifecycle/final loss | Four controls: backend result before owner disposition. Completion sent before echo. Worker acknowledgement before reap publication. Owner handoff before caller final write. Retain all prior records, actual wait observations and unavailable final joins. No complete-looking prefix establishes clean acceptance. |
| S5: ownership/backing | Two controls: one known child retains the original lock after owner exit. One backing directory identity is deliberately mismatched in the approved copied capacity observation. Recovery refuses until exact holder resolution, and always refuses the mismatch. No live-volume detach or lock deletion is used to manufacture the case. |
| S6: protected publication | Two approved result substitutions: collection directory create failure. Terminal slot partial write followed by failure. Observe retained objects and unavailable collection/final record separately. These are handling controls, not claims of actual ENOSPC or durability. |

The later S2 manifest also enumerates the remaining failure tail before startup and
checks at each transition that its distinct slots and bytes remain available.
No recycling of successful rows funds later failure evidence. Unstarted
cancellation has terminal rows and no capture ordinal/charge. Collection uses
the same global ordinal sequence and original lock. The synthetic records
contain no VM or client secrets and establish no native collection availability.

## Common finite execution envelope and cleanup

This envelope applies only to pre-implementation mechanism cases: L1 through L5 and S1.
Before any later permission request, freeze every expanded case and exact helper source/build.
The count is `3 + 3 + 3 + 1 + 2 + 1 = 13` cases.

Each L1 child contains its own measurement. Neither a fourth baseline child nor a real-producer floor measurement is included.
No R row, S2-to-S6 control, dependency fixture or native/useful-fit experiment belongs to that count.
Their evidence duties remain live and need their own complete reviewed scope.

The pre-implementation process set contains the supervisor, backend probe, collector probe, intermediary/producer probe and one declared helper.
At most five such processes overlap, within the retained six-process ceiling.
L1's three children run serially.

No owner, keepalive worker or sleep child runs in this mechanism study.
Image utilities run serially with those test processes stopped. Their exact child inventory must also fit the ceiling.

The later S2/S4 controls need the real owner, worker and sleep child.
With supervisor, backend, collector, intermediary/producer and one helper, that topology can reach eight processes.
Those controls therefore cannot reuse this envelope. Their later plan must count actual overlap, retained bytes and containment duties before execution.

No retry, replacement, adaptive search or follow-on native fit is included.
Unavailable dependencies leave their cases NOT RUN. Unexpected results stop that group and all dependent groups.
Expected refusal is only a control result.

Each case has an absolute ten-second work deadline from its supervisor's launch intent, using the owner's continuous clock/boot identity.
The existing twenty-second failure-containment window also applies.
At most thirteen cases consume `13 * 30 = 390` seconds. Six image setup/detach operations add at most 360 seconds.
Their 750-second sum fits the 3600-second total, leaving setup, accounting and collection within that same total. The entire study has an absolute
3600-second deadline including setup, collection and detach.

Each image setup
or detach operation has at most 60 seconds, within that total. The supervisor
observes deadlines independently. Expiry prevents further cases and never claims
that an uninterruptible process exited. No unconditional blocking wait follows.

Fixture input plus explicit requested/touched buffers is at most 8 MiB per case.
L3's additional 4 MiB map and L2's pages are counted separately as mapped exposure.
No fork loop, allocation-until-failure, large image, host disk fill or process
count exhaustion is permitted. Native/loader/kernel contributions remain separate
unresolved admission questions, not silently included in this owned-buffer cap.

The supervisor retains direct-child creation handles, process incarnations,
group membership, original-lock identity and inherited-descriptor inventory.
Use the existing TERM/KILL/observation policy once on established owned targets.
Do not signal by process name, a stale PID, or an unverified group. Unknown
holders block further work and detach. They remain unresolved rather than clean.

Cleanup means stop known writers, record outcomes, hash and inventory retained
objects, then detach only the exact study-created devices when ownership permits.
Retain the three image files, originals and partials for review. Do not remove,
truncate, compact or convert them.

Their 768 MiB backing plus 32 MiB evidence
ceiling already includes retention.
Each mechanism case permits two raw objects of at most 256 KiB, including each retained tail.
Their worst-case sum is `13 * 2 * 256 KiB = 6.5 MiB`.

The remaining 25.5 MiB must contain every other copied input, helper binary, setup log, result and inventory outside the images.
The manifest must sum actual ceilings, including duplicated copies, before execution. It cannot assume every independent maximum fits.

The withdrawn 48-fixture and 17-raw-case mixture could alone require 32.5 MiB. It never established fit under 32 MiB. Use no force-detach or guessed-device action.
An unsuccessful detach or final write is retained as unavailable. Later disposal
requires a separately authorised action on these exact identities.

## Evidence, ownership and handoff

Each result must state its claim, manifest/case identity, actual inputs, setup/exec/map/write outcomes, first failure and process/holder facts.
It must also state exact retained prefixes, missing tails, storage identities, cleanup and clock origins/deadlines.
Keep source reasoning, substituted results, actual mechanism observations and
unresolved prerequisites in separate fields. A result classified as unavailable
cannot be used as negative evidence or cleared by later success.

Koine owns this consumer proposal and its future harness integration. TestAnyware's
owner owns a conforming producer and its guard evidence. Apple/native and storage
guarantees are external prerequisites.

This proposal authorises no implementation. Antony separately approved the
dependency design/evidence request on 2026-11-01. It is filed as
[TestAnyware issue #13](https://github.com/Linkuistics/TestAnyware/issues/13).
K112 consumes mechanism and dependency evidence before complete-profile adoption.
It specifies future coordinator controls but cannot require their results before implementation exists.
After implementation, those controls must pass before downstream consumption.

K112 must either obtain adequate evidence under separately agreed reviewed scope or present the precise unmet requirement and alternatives to Antony. It cannot declare the profile complete from these small controls.

<!-- tc: depart synonym-rotation because the VM start queue is a named operation distinct from launching a process -->
The complete profile still owes all numerical useful workload, validator capacity,
600-second start queue/boot reconciliation, uploads, tick count, collection/final
tail, record schemas and whole-design review. The
[original-duty table](KEEPALIVE-RESOURCES.md#complete-original-duties) remains binding
for k89/k81/k76/k67/k62/k57/k54. Keep input order, sleep20, all other waits, poll counts and one-attempt transports.
Preserve first-failure eligibility, both held-pointer cases, private roots, snapshot/OCR/held-frame limits and every historical cap.
No native idle interval, focus correction, acceptance or ancestor closure follows.

### Evidence gathered for this proposal

Read the integrated contract, owner spec and k106 survey. Tier 2 graph generation
`2026-10-31T05:37:19Z` reports matching metadata and no recorded gaps for the
backend/inspector and cited design inputs. The exact `run_locked` source still
opens direct raw files and executes the CLI through `subprocess.run`.

Its trace
contains unrelated name matches, discarded here. This is bounded navigation,
not an exhaustive allocation or environment audit. New/changed prose and diagram
sources are read directly. Host/toolchain observations above are read-only.

The [design-check receipt](ordering-keepalive-qualification/verification.json)
records documentation and browser checks, including their limits. It records
no launcher, resource, storage or native qualification result.

## Integration evidence

K116 integrates the k115 findings from commit `56563024`, against the reviewed proposal at `0fbb6fe7`.
Its task commit records every disposition. No production source, cadence, lock rule or ordinary caller changes here.
The [integration receipt](ordering-keepalive-qualification-integration/verification.json) records document checks and their limitations.
The earlier k111 receipt remains historical. No capability row ran during this integration.

[exec-source]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exec.c#L1531-L1533
[map-setter]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/vm_map.c#L22084-L22110
[task-source]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/kern/task.c#L6035
[map-size]: https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/vm_map.c#L1849-L1864
