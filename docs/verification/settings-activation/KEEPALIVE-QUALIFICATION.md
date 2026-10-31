# Settings keepalive mechanism qualification proposal

## Decision and authority

Propose a minimal native producer launcher, bounded backend pipe capture and
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
and final publication. This proposal supplies questions and finite controls.
It does not supply a complete resource profile. All capability rows below are
**NOT RUN**. Source observations and documentation checks are not capability results.

## Subject closure before an execution decision

One immutable manifest must bind the following subjects. A changed subject
invalidates correspondence and returns to design/review. It never silently
replaces an execution slot. Missing entries keep the affected row unavailable.

| Subject | Current evidence and required closure |
|---|---|
| Koine baseline | `e52b04bc997fbb166e0a205bf98563f3345d5fa9`. The proposed owner, launcher, collector and recovery protocol are not implemented by this revision. Pin their eventual source tree, all patches, build inputs and executable SHA-256 values before requesting execution. |
| TestAnyware comparison source | `65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03` (`v2.7.0` basis), exactly as traced in the [survey](../../research/settings-keepalive-enforcement-a.md#evidence-identities-and-limits). It is evidence of gaps, not a conforming producer. No selected conforming build or unit-schema version is available. |
| Required producer | Its owner must supply a reviewed revision, complete lockfiles/features, bounded-operation contract version and unit-schema version, codec/native source evidence and build recipe. Bind executable bytes, Mach-O UUID/signing identity, linked images and loaded runtime versions to that source. A tag, path or version string alone is insufficient. |
| Host | Read-only observations on 2026-10-31: macOS `27.0.1`, build `26A434`, Darwin `27.0.0`, `xnu-13432.1.9~1/RELEASE_ARM64_T6041`, arm64. Record boot identity, hardware/page size, loaded system image identities and filesystem tools in the later manifest. Refuse host drift. |
| Kernel comparison source | Apple XNU `f6217f891ac0bb64f3d375211650a4c1ff8ca1ea` (`12377.1.9`) differs from this host. Require corresponding source/build evidence for any claimed route bound. Finite target-host observations can qualify named cases only. |
| Launcher build | Proposed thin arm64 C17 executable, optimised with `-Os`, dynamically linked to libSystem. No shell, Python, Rust runtime, constructor work or additional framework. Pin compiler executable, flags, SDK, linker, deployment target, Mach-O/load commands, source and binary digest. This is a selected design, not an existing binary. |
| Toolchain | Read-only `xcrun clang --version` reports Apple Clang `21.0.0 (clang-2100.4.1.1)`. `xcrun --show-sdk-path` names `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk`, but `--show-sdk-version` fails because that SDK cannot be located. No build correspondence or SDK selection is established. Resolve and review this before building a subject. Do not infer it from the Clang output. |
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
a bounded request (at most 16 KiB for these controls), using fixed storage. It
checks bindings, closes undeclared descriptors and installs applicable soft and
hard limits immediately before `execve` of the exact producer. It reports actual
call/readback outcomes through a separate bounded setup channel. Failure prevents
producer exec, preserving the committed ordinal, charge and partial evidence.

The intermediary replaces itself with the producer: it creates no additional
child. The backend retains its direct-child relationship and process incarnation
across exec. The collector is a separate owned child so it can survive producer
exit. This topology must integrate with the owner's backend group and original
lock inheritance. No limit is installed in the owner or finite caller.

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

All sizes below are **study ceilings**, not proposed useful-run limits.
Use the common bounds and stop rules below. `P` is the recorded host page size.
`F` is map-accounting size immediately at the audited install point. The probe
must relate its measurement to the setter's map accounting from corresponding
source.

RSS, peak RSS, a VM address-span sum or `getrlimit` alone cannot supply F.
If that relation is unavailable, record F as unknown and do not derive a limit.

| Row / question | One finite control and decisive evidence |
|---|---|
| L1: installation floor | A no-op probe at the exact intermediary site. Retain the complete map-accounting observation and return values. Separate fresh children request `max(0,F-P)`, `F`, and `ceil(F/P)*P+8P`. Each recomputes its own F under the same declared algorithm. Refuse if F or the computed limit exceeds 16 GiB. No search for a passing cap. The first tests rejection, the others installation only. Measurement must not allocate after F is sampled. Bracket any unavoidable observation perturbation and mark the floor unresolved if it cannot be bounded. |
| L2: map routes after installation | Use separate children for anonymous mmap, Mach allocation and Mach remap. Each permits at most nine new mapping pages and one touched page. Source must explain which mapping contributes to the limit and any temporary overlap. Use the same F-plus-eight-pages rule. A denied route qualifies that case. Success beyond the claimed bound refutes that claim. No large allocation, repeated growth or RSS-pressure test. |
| L3: exec coverage | Two fixed no-op images, one with an additional 4 MiB mapped segment, plus one same-image exec. Install the L1 computed limit before exec. Record pre-exec and new-image map/limit facts and one at-most-nine-page growth request. A target that cannot report remains failed/unknown. Preserved readback without effective map enforcement fails the claim. Source must address the survey's unchecked exec-setter return and remap route. Do not enlarge a cap after failure. |
| L4: inherited member | One declared helper child, no grandchildren, with one at-most-nine-page request and one 4097-byte output. Record fork/exec identities and limits. This tests the named member only, never an aggregate subtree guarantee or `RLIMIT_NPROC` by user exhaustion. |
| L5: per-file write boundary | A 4096-byte file limit, one 4096-byte write and a separate 4097-byte write in fresh children. Retain actual prefixes, syscall/wait results and SIGXFSZ where observed. No conclusion about aggregate files, pipes, mmap growth or native memory follows. |

The finite helper payload does not by itself bound kernel or loader work.
An execution proposal must state those remaining exposures explicitly and name
the evidence required to admit the study. These cases are not a universal proof
of undocumented routes. Corresponding source must cover every route on which
the final producer and launcher rely. Missing coverage remains a prerequisite.

### Producer guards and useful fit

The dependency owner supplies guard evidence at the actual allocation/write
points, covering all units in the producer contract. The proposed fixture envelope has these ceilings:

- Wire and selected frames: 64 by 64 pixels.
- Crop: 32 by 32 pixels.
- Supplied wire bytes: 256 KiB.
- Per operation: 32 messages and 16 rectangles.
- Requested owned-buffer capacity: 4 MiB.
- Encoded output: 256 KiB.

Arithmetic-overflow and excessive-length cases send only finite headers. They
must refuse before following the claimed length. No large decompression payload.

Use three separate fixtures for each declared unit.
They cover the largest declared in-budget quantity, its first excess and a malformed representation.
Include Raw/CopyRect, ZRLE, every accepted Tight mode/JPEG and resize old/new overlap.
Include scale-1/scale-2 logical and physical capture, crop/PNG fallback overlap and OCR input/result copies.

Preserve in-budget pixels against fixed originals and the
existing held-frame outcome. The dependency's source and actual-capacity evidence
must precede execution: no copied allocator or new injection seam is approved.
The complete fixture manifest may contain at most 48 cases. If the unit schema
cannot fit within that bound, redesign/review the study instead of dropping units.

Two distinct later fit questions remain. Small fixtures can establish that guards
are useful for those fixtures. They cannot establish the complete Settings
workload's fit, tick count, transfers, timings or retained volume.

K112 must derive
that workload and return a finite reviewed fit proposal. This matrix spends no
E/A or closed causal slot. This proposal grants zero native Vision calls, zero
VM launches and zero input actions. A future native fit request must name the
exact conforming build, fixed images/workload, native membership and separate
reviewed execution scope first. It must preserve the OCR engine and transport.

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

At first excess or write failure, retain the current read prefix and stop draining
both pipes. Signal only established writers under the existing containment window.
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
installed kernel. Do not assign 64 KiB from the header as a target-host bound.
Until queue, temporary-memory and capture-storage bounds are established, this
candidate cannot satisfy the producer contract or admit real producer work.

Collector loss, failed tail storage or an unresolved inherited writer can lose
accepted bytes or leave them inaccessible. Record persisted prefix length,
accepted/queued observations and the unknown remainder. Do not report complete
retention or clean completion.

A successor never replaces the original lock or
opens another raw writer. The design therefore has a process-loss availability
limit: pipes are not durable spools. A non-growing durable backing object would
be preferable if its write, seek, aggregate and metadata bounds can be qualified.
A pre-sized regular file or direct raw file does not establish those properties.

| Row | Fixed finite emission / required distinction |
|---|---|
| R1 | Empty streams. 4095, 4096 and 4097 bytes on each stream separately. And one byte on both streams. Eight cases. `Lout=Lerr=4096`, `Lsum=8192`. Require exact originals and EOF for clean rows. Excess is sticky despite exit zero. |
| R2 | Both streams: 4096 each at `Lsum=8192`, then 4096 each at `Lsum=8191`. Two cases. The second must fail the aggregate even though both individual limits fit. |
| R3 | One 8192-byte burst per stream while the collector is held at its approved barrier. One case. All actually accepted bytes must survive when writers resolve. The finite burst tests retention but does not prove Q. |
| R4 | Four fixed abnormal cases: missing-executable loader error, direct-write then abnormal exit, one owned inherited-descriptor child, collector death after a 1024-byte persisted prefix. Each controlled emitter supplies at most 8192 bytes per stream. Capture loader output under the established Q boundary. Do not assume its text size. Distinguish execution, EOF, child reap, persisted bytes and unknown tails. |
| R5 | Two approved copied backend write-result cases: fail before write. Write exactly 1024 real bytes then fail. Never fabricate a successful prefix. These qualify failure handling only. |

For these 17 cases, each raw capture object has a 256 KiB total extent ceiling.
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

Use the **original lock object in terminal storage** and one global sequence.
The logical root binds all three backing identities. Collection directories
physically belong to collection storage.

Command ordinals never come from
scanning separate roots. Records are immutable framed objects, at most 4096
bytes each in this fixture, with schema version, root/generation, record type,
sequence, exact payload length and checksum. Checksums detect damage. They
neither prove durable media nor authenticate hostile same-user writes.

For the study, precreate a terminal record pool inside the object cap. Bind each
slot once. Reserve a distinct slot for each attempted write, including damaged
prefixes.

Unused capacity is not a clean event. Retain the immutable slot binding,
used length and partial state. Never zero/rewrite a failed slot. Test whether
precreation and allocation actually survive the chosen open/write flags. It does
not reserve unspecified future directory metadata.

The proposed operation sequence is:

1. Before consuming a range member, publish a terminal allocation fence.
   It names a finite eight-ordinal range, its predecessor and backing identities.
   Observe the declared flush outcome before dependent work. This fence burns
   recovery uncertainty. It is neither dispatch commitment nor an operation charge.
2. Recheck admission in the serialised commitment transition, assign one ordinal
   and irrevocably charge its full contribution. Publish its terminal binding:
   submission, class, profile/cost, ordinal, backing UUID and assigned directory
   token. Only then create the attempt directory in the assigned class and
   publish commitment. Failed steps retain the charge and ordinal.
3. Launch only from that commitment. Append actual setup/execution/settlement
   observations separately. Neither readback nor a later result rewrites intent.
4. After owner loss, a collection-only generation resolves holders and acquires the same lock.
   It checks backing identities and reads the bounded terminal prefix.
   Burn all unused or uncertain members of the last valid fence. Do not invent
   execution or charge a capture merely because its ordinal is burned.
5. A partial fence with no safely established upper frontier, damaged predecessor,
   lost binding identity or unresolved lock refuses recovery. Do not scan output
   roots, truncate a record, reuse an ordinal or resume scenario commands.
   A later valid fence/disposition is a new record, never a rewrite in place.

For process loss on the still-mounted healthy system, this sequence must be
tested at every boundary below. Requested flush, successful flush, namespace
publication and subsequent visibility are separate fields. No successful
process-loss control establishes power-loss atomicity, cross-volume transactions,
device availability or universal APFS metadata reservation. Those claims remain
unsupported and must not appear in the final profile by implication.

### Storage and process-loss controls

| Row | Finite cases and required observation |
|---|---|
| S1: ordinary exhaustion | One quota-boundary sequence above, followed by one collection directory/raw/receipt set and terminal failure/final rows. Retain actual block/object use before/after, identities and prefixes. Ordinary refusal must not consume either protected class. Failure of protected writes is a separate result. |
| S2: record coverage | One complete clean synthetic lifecycle and one failed lifecycle. Enumerate every owner row against the [lifecycle table](../../specs/settings-keepalive-owner.md#lifecycle-evidence-and-final-observation). Include received/admitted/resource-refused/cancelled submissions, phase reports, launch and resource observations, acknowledgements, completion sends/echoes, stop/reap/handoff, caller owner-exit/final-outcome, plus fence/binding/recovery rows. Backend request/raw/validation/result rows belong to their ordinary or collection attempt. The manifest supplies exact row counts and lengths within the pool. No clean row is free. |
| S3: owner loss | Eight separately named controls: before fence. Partial fence. Complete fence before assignment. Charged assignment before binding. Partial binding. Complete binding before directory. Directory before commitment. Commitment before launch. Use approved barriers/result substitutions and real retained prefixes. A directly owned process ends once per case. Check burned uncertainty, no duplicate ordinal/charge, no scenario restart and truthful unstarted/unknown launch. |
| S4: lifecycle/final loss | Four controls: backend result before owner disposition. Completion sent before echo. Worker acknowledgement before reap publication. Owner handoff before caller final write. Retain all prior records, actual wait observations and unavailable final joins. No complete-looking prefix establishes clean acceptance. |
| S5: ownership/backing | Two controls: one known child retains the original lock after owner exit. One backing directory identity is deliberately mismatched in the approved copied capacity observation. Recovery refuses until exact holder resolution, and always refuses the mismatch. No live-volume detach or lock deletion is used to manufacture the case. |
| S6: protected publication | Two approved result substitutions: collection directory create failure. Terminal slot partial write followed by failure. Observe retained objects and unavailable collection/final record separately. These are handling controls, not claims of actual ENOSPC or durability. |

S2's manifest also enumerates the remaining failure tail before startup and
checks at each transition that its distinct slots and bytes remain available.
No recycling of successful rows funds later failure evidence. Unstarted
cancellation has terminal rows and no capture ordinal/charge. Collection uses
the same global ordinal sequence and original lock. The synthetic records
contain no VM or client secrets and establish no native collection availability.

## Common finite execution envelope and cleanup

Before any later permission request, freeze every expanded case and exact helper
source/build. The tables permit 12 launcher/map/write cases, 17 raw cases, 48 producer fixtures and 19 storage cases: at most **96** cases.
L1 has three cases, L2 three, L3 three, L4 one and L5 two.

No retry,
replacement, adaptive search or follow-on native fit is included. Unavailable
dependencies leave their cases NOT RUN. Expected refusal is only a control
result. An unexpected result stops that group and all dependent groups.

Each case has an absolute ten-second work deadline from its supervisor's launch intent, using the owner's continuous clock/boot identity.
The existing twenty-second failure-containment window also applies. The entire study has an absolute
3600-second deadline including setup, collection and detach.

Each image setup
or detach operation has at most 60 seconds, within that total. The supervisor
observes deadlines independently. Expiry prevents further cases and never claims
that an uninterruptible process exited. No unconditional blocking wait follows.

At most six owned processes are live at once: supervisor, owner under test,
backend, collector, intermediary/producer and one declared helper. Image utilities
run serially with the test processes stopped, under the same six-process ceiling.
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
ceiling already includes retention. Use no force-detach or guessed-device action.
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
guarantees are external prerequisites. No implementation or issue filing is
authorised here. K112 must either obtain adequate evidence under separately
agreed reviewed scope or present the precise unmet requirement and alternatives
to Antony. It cannot declare the profile complete from these small controls.

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
