# Application reference contact boundary

The [contact contract](application-reference-evidence.md#contact-observation-outside-the-producer)
requires independent coverage of the whole pure invocation. This source-based design
delivers an **exact unavailable boundary**, proposed for the complete admission-design
review. It supplies neither a collector nor an observed no-contact result. Source research,
table extraction and presentation checks acquired no installed query, contents, topology,
collector availability or runtime identity. The selected target pass remains unused.

[Contact → Establish coverage before releasing a pure subject](../design/architecture/index.html#diagram-native-reference-contact)
shows the reading order. Graphs enter at the dark Start here node. The independent
approval register must accept the required inventory before construction can credit it;
these documentary tables are not that acceptance or an executable proof schema.

## Independent source baseline

The public basis is Apple's **xnu-12377.121.6**, commit
`ac9718fb1af618d5ce8678d0dc6e8a58f252216f`. It was selected independently of the
instrument's operations. [Source pins](reference-contact-inventory/source-pins.tsv)
bind complete retrieved files by SHA-256 and immutable upstream URL. This is a
published source baseline, **not** a claim that build 26A434 uses that kernel,
configuration, syscall table, provider set or service implementation.

| Documentary inventory | Enumeration and limits |
| --- | --- |
| [BSD declarations](reference-contact-inventory/bsd-declarations.tsv) | Every numbered declaration line, including conditional alternatives and published placeholders; number, source line, name and branch context. All source numbers from zero through the last declared slot are represented. No configuration branch is silently selected. |
| [Mach traps](reference-contact-inventory/mach-traps.tsv) | Every numbered trap-table declaration and conditional alternative, including invalid slots; separate from BSD syscall numbering. |
| [Mach RPC declarations](reference-contact-inventory/mig-routines.tsv) | Every routine/simpleroutine/skip declaration outside comments in mach_vm.defs, mach_port.defs and task.defs, with exact source/line. These selected interfaces expose VM and capability-transfer obligations; they are not all kernel RPCs or user-space services. Compiled message IDs/conditional applicability remain unestablished. |
| [Published API basis](reference-contact-inventory/api-basis.tsv) | Named Apple API documents, retrieval URLs/date and exact retrieved JSON digests. Documentation identities support the route/privilege facts below, not current ABI, service names, image identity or a frozen runtime expectation. The upstream JSON is mutable; re-acquisition must match its digest or become an independently reviewed change. |

Enumeration preserves facts, not a semantic exclusion list. Each non-placeholder BSD/trap
entry remains marked **required semantic and current-correspondence review**, even if
it looks unrelated to acquisition. Each RPC also requires that review. Published
placeholders/skips are facts of this source only, not proof of an unavailable current
route. The named families below are a mandatory lower bound, never permission to drop
unclassified entries. Independent inventory ownership must account for every row,
conditional/configuration choice, new/unknown current entry and indirect effect, with
source-derived reasons for genuine inapplicability. A producer's call graph or clean
run cannot establish that disposition. Table counts are diagnostics, not completeness.

The probe basis is the pinned [systrace source](https://github.com/apple-oss-distributions/xnu/blob/ac9718fb1af618d5ce8678d0dc6e8a58f252216f/bsd/dev/dtrace/systrace.c):
it constructs entry/return probes from BSD `syscallnames` and separately from Mach
`mach_syscall_name_table`, registering **syscall** and **mach_trap** providers. Published
declaration names are not guessed installed probe names. Required provider/probe mappings,
enabled configuration, readable operands and current restrictions are unavailable until
independently established. Adding the Mach provider is no proxy-causality certificate.

## Required contact families

Contact includes **issuing** a forbidden request, even if it errors, returns nothing,
is later cancelled or is refused by the recipient. A source/index query is contact at
submission, not only when a file is opened. Distinguish allowed task/runtime-image
reads from application/source inspection using independently approved object/operation
associations; a blanket ban on every /System read would also misclassify the runtime.
K277 owns that actual read closure. An allowlisted loaded image grants no permission
to call its query, resource, coordination or proxy facilities.

| Family | Independent minimum entries/routes | Required object/operation association |
| --- | --- | --- |
| C1 pathname acquisition and lookup | open/open_nocancel/openat/openat_nocancel; open_extended; open_dprotected_np/openat_dprotected_np; guarded_open_np/guarded_open_dprotected_np; access/access_extended/faccessat; readlink/readlinkat/freadlink; chdir/fchdir and pthread variants; execve/__mac_execve/posix_spawn | Raw path bytes or relative component, cwd/dirfd identity, flags, link expansion and attempted lookup; image loading also belongs to the read closure. |
| C2 identity acquisition, attributes and enumeration | openbyid_np, fhopen/getfh, fsgetpath/fsgetpath_ext; stat/lstat/fstat and 64/extended/at variants; pathconf/fpathconf; getattrlist/fgetattrlist/getattrlistat/getattrlistbulk/getdirentriesattr; getdirentries/getdirentries64/searchfs; get/list-xattr and fd variants; statfs/fstatfs/getfsstat variants; fsctl/ffsctl/ioctl/fcntl and MAC file/link/fd operations | Device/object/filehandle/descriptor identity and command-specific operands; a pathname filter cannot observe identity-only access. Bulk and nested command payloads cannot be elided. |
| C3 descriptor data and lifetime | read/pread/readv and noncancel variants; preadv/preadv_nocancel; aio_read/lio_listio with completion/cancel/error/return; sendfile/copyfile/clonefileat/fclonefileat; dup/dup2/fcntl, guarded close/change guard, close/noncancel; fileport_makeport/fileport_makefd; spawn/fork inheritance; recvmsg/SCM_RIGHTS | Descriptor generation and backing object, offset/range/async request, transfer origin and recipient. Closing a number cannot erase its history; reuse cannot inherit an old association. |
| C4 mapped or shared data | mmap/msync/noncancel, mprotect/madvise/minherit/munmap; shared_region_map_and_slide_2_np/map_with_linking_np/mremap_encrypted; shmat/shmget/shm_open; Mach VM read/map/remap/copy, memory-entry and task-memory operations in the pinned tables/RPCs | Mapping/backing-memory-object/right provenance before release, ranges and protection changes; reads of an already inherited mapping may execute no new syscall. Anonymous memory is allowed only with established provenance. |
| C5 source/index and mediated I/O | Fixed mdfind exec; MDQuery/NSMetadataQuery and metadata-item getters; Bundle/URL resource and LaunchServices facilities; NSFileCoordinator/File Provider or other daemon-mediated requests | Request/operation plus actual endpoint incarnation/capability and any delegated effect. These API families are mandatory candidates, not an assertion that every current call uses a particular daemon. Current framework/service/protocol inventories are missing. |
| C6 IPC, capability transfer and detached proxies | mach_msg_trap/mach_msg_overwrite_trap/mach_msg2_trap; Mach port/task/RPC rights, task_for_pid/read/inspect routes; XPC Mach-service connections; socket/connect/connectx/socket_delegate/send/recv and noncancel/x variants; UNIX sockets, SCM_RIGHTS, SysV messages/shared memory, pipe/shared-channel protocols | Sender/receiver process and stable endpoint/right/descriptor generation, message IDs/commands and rights/objects transferred. A daemon outside the child tree is inside the causal obligation. Unknown IPC cannot be labelled harmless by an empty path trace. |
| C7 mutation, topology and opaque command effects | write/pwrite/writev/guarded/noncancel variants; rename/link/unlink/symlink/mkdir/mknod and at variants; truncate/chmod/chown/flags/times/xattr/attribute mutations; exchange/delete/clone/copy; mount/unmount/fmount/funmount/pivot_root/fs_snapshot/graftdmg; syscall, ioctl, fcntl, sysctl, MAC, IOKit/device or other multiplexed commands | Exact command and effect. Forbidden launch, index/registration change, executable acquisition and protected/outside contact stay forbidden; runtime initialization is not an automatic exemption. Unclassified entries remain here pending independent semantic disposition. |
| C8 process, image and observation lifecycle | fork/vfork/posix_spawn/exec variants, threads/work queues, exit/kill/wait/reap and noncancel variants; inherited fd/port/VM state; collector/provider attach/enabling/filter/drop/error/termination | Full launch-to-true-return subject closure, actual images and incarnations, descriptor/right/map ancestry and complete observation interval. PID/parent-PID matching alone is insufficient. |

The [BSD source](https://github.com/apple-oss-distributions/xnu/blob/ac9718fb1af618d5ce8678d0dc6e8a58f252216f/bsd/kern/syscalls.master)
and [Mach table](https://github.com/apple-oss-distributions/xnu/blob/ac9718fb1af618d5ce8678d0dc6e8a58f252216f/osfmk/kern/syscall_sw.c)
establish these entry candidates. Apple documents
[NSMetadataQuery](https://developer.apple.com/documentation/foundation/nsmetadataquery)
as a Spotlight query API,
[NSFileCoordinator](https://developer.apple.com/documentation/foundation/nsfilecoordinator)
as inter-presenter file coordination, and
[XPC Mach-service connection creation](https://developer.apple.com/documentation/xpc/xpc_connection_create_mach_service(_:_:_:)).
Their existence defeats an exec-only definition of source contact. Exact current
transport, protocol, endpoint and delegated-effect coverage remains unavailable;
we do not infer those implementations from API names.

## Observation or containment interface

One independently owned boundary consumes an externally accepted required inventory,
exact pure launch/read closure and allowed scratch object/capability set. Its result is
per required coordinate: **observed allowed**, **observed forbidden attempt**,
**independently established prevented attempt**, or **unavailable**, with original
evidence and reason. It cannot return an aggregate clean bit. The producer supplies no
applicability, collector-success flag or backing-object assertion that this boundary trusts.

Coverage starts before the first task/interpreter/loader/subject operation, using the
commissioned trust base rather than a self-observation cycle. It covers the task runner,
scripts/interpreters, verifier/checker/coordinator, scratch emitter, decoder, calibration
subjects and all spawned or causally enlisted recipients. It ends only after child/proxy
and async completion is accounted for and terminal records are retained. K277 supplies
the actual packaging selection and bootstrap/read partition; neither half can certify
the other from a pathname hash.

Observation needs raw request and return/error, process/thread incarnation, object and
descriptor/right/map generation, endpoint/request correlation, entry/return pairing,
sequence/loss evidence, filter/probe configuration, ready acknowledgement and true
termination. Containment may close a coordinate only with independently demonstrated
pre-effect enforcement, complete mediated classes and initial capability state. It must
deny an unknown effect rather than silently allow it. A denied scratch attempt may be
a successful negative control; an issued live request is not erased by its eventual denial.
No current mechanism satisfying this interface is supplied by this design.

## Per-family independent controls

Every applicable C1–C8 operation/variant has its own positive and isolating bypass cells;
one open sentinel cannot stand for noncancel, identity, async, mapping or Mach routes.
Author specimens before producer comparison. Only synthetic values, constructed scratch
objects and newly constructed scratch endpoints may be calibration subjects. Never use
an installed root, real index request, protected folder or actual system daemon as a
positive. A fixture's simulated service name is not permission to connect to its real name.

| Family | Direct, child, inherited and proxy counterexamples |
| --- | --- |
| C1 | Direct alternate/noncancel/guarded open outside wrappers; child exec or cwd/dirfd-relative lookup bypass; scratch server asked to perform the same lookup. |
| C2 | Scratch open-by-identity/filehandle and bulk attribute/listing request; inherited directory enumeration; detached scratch proxy performing identity/attribute access. |
| C3 | Preopened/duplicated/reused descriptor read; child and SCM_RIGHTS/fileport transfer; async submission/completion/cancellation; proxy reads while the sender exits. |
| C4 | Scratch mapping established before release, inherited/rights-transferred/remapped backing and a plain memory load with no new syscall; child/shared-memory/proxy delivery. Coverage must establish provenance or prevention, not invent a read event. |
| C5 | In-process source-service request bypassing exec/gate; child request; independent scratch protocol/proxy performs index-like work. This proves its synthetic route only; untested actual framework/service correspondence remains unavailable. |
| C6 | Direct Mach and socket transport, transferred rights/fds, inherited endpoint and detached scratch recipient; wrong/reused endpoint and encrypted/opaque or truncated payload leave the exact operation association unavailable. |
| C7 | Direct/child/proxy mutation and opaque command attempt on scratch objects; authored mount/firmlink inputs exercise policy only. No actual mount, registration or native topology change is a calibration. |
| C8 | Immediate spawn/exec/exit, double-fork or reparenting, thread/PID reuse, fd/right reuse, supervisor/collector death, late proxy/async completion and missing reap. Unknown descendants cannot simply be omitted. |

For **each applicable family**, independently perturb all six dimensions: (1) not-ready
or disabled release; (2) wrong process/object/descriptor/map/right/endpoint association;
(3) induced event/operand/output loss or overflow; (4) wrong filter/provider/variant;
(5) late attach or an uncovered startup/exec interval; (6) early collector/child/proxy
termination, missing drain or reap. Required evidence must identify the intended cell as
forbidden/prevented or unavailable. No events under a disabled/wrong filter is not a pass.
Readiness includes all required providers and initial fd/port/VM state, not just a live PID.
Unknown applicability or an unavailable way to induce/observe a required control stays a
missing cell. Original calibration traces and full inputs are separately owned/frozen;
producer wrapper traces remain useful intent evidence with their limited provenance.

## Candidate assessment and exact unavailable identities

| Arrangement | Source-supported assessment and remaining boundary |
| --- | --- |
| Existing gate, mocks, interposition or static reachability | Useful pure logic/intent evidence. Direct syscall, child, IPC and inherited-memory bypass prevents independent complete contact credit. |
| DTrace BSD plus Mach trap candidate | Published providers are richer than a syscall-only list, but the pinned [privilege glue](https://github.com/apple-oss-distributions/xnu/blob/ac9718fb1af618d5ce8678d0dc6e8a58f252216f/bsd/dev/dtrace/dtrace_glue.c) uses a superuser credential check. [dtrace_open/credential conversion](https://github.com/apple-oss-distributions/xnu/blob/ac9718fb1af618d5ce8678d0dc6e8a58f252216f/bsd/dev/dtrace/dtrace.c) checks resulting privilege and restrictions. This source basis supplies no authorized unprivileged collector, installed provider/operand availability, daemon causality or initial-map proof. No initialization was tried. |
| Endpoint Security | Apple's [not-privileged result](https://developer.apple.com/documentation/endpointsecurity/es_new_client_result_err_not_privileged) documents root, and its [entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.endpoint-security.client) requires Apple's approval. Both are outside the selected authority. Even an authorized event subset would still need full contact/IPC/VM coverage and loss controls; no completeness follows from the name. |
| Unprivileged sandbox, capability broker or debugger | A concrete, independently enforceable scratch-only launch could be useful, but none is specified/qualified here for this actual runtime, inherited capabilities, proxies and all C1–C8 effects. [App Sandbox](https://developer.apple.com/documentation/security/app-sandbox) documents resource restriction; it does not certify this custom boundary or authorize signing/entitlement changes. A private policy, dylib hook or denied-open log is no substitute. |
| Root collector, SIP change, privileged helper/entitlement or isolated VM | Unselected alternatives, not workarounds authorized by a pure-test label. Root tracing alone still does not solve causal proxies or existing mappings. A VM additionally needs a reviewed absence of target bytes/index and host/network/service bridges. None is adopted or commissioned. |

The conclusion is bounded: **no complete arrangement is established or selected for
implementation under the current authority**. This is not a theorem that none can exist.
Keep useful independently authored value/byte/schema/intent work possible, with no actual
adapter, packaging, read-closure or no-contact qualification credit until its required
boundary is satisfied. An apparently clean partial trace cannot admit the target pass.

| Unavailable coordinate | Exact missing identities/evidence | Owner and placement |
| --- | --- | --- |
| U1 current independent universe | Actual kernel/build/configuration and BSD/Mach/RPC/provider correspondence; complete current service/framework/opaque-command inventory and independent per-entry disposition, including public-source gaps | K269 assigns independent inventory/source-correspondence design and review before any real-adapter or observer credit. No target/probe acquisition is authorized by this report. |
| U2 full mechanism | Actual unprivileged enforcement/collector/launcher artifacts, API basis and class coverage for all C1–C8; an identified pre-effect enforcement rule or independent observation for each | K269 retains a live contact-boundary design owner before capability/calibration or shared packaging rehearsal. If no realizable candidate can be named, retain this exact unavailable boundary; do not repeat the same source survey as qualification. |
| U3 launch and capability state | Actual runner/interpreter/loader/image/process/thread identity; initial fd/port/right/VM closure, transfers, cwd and object generation through true return | K277 supplies the entry/read contract; k269 assigns independent launch/association construction and qualification before checker/verifier correspondence or adapter credit. |
| U4 mediated and memory effects | Actual endpoint/protocol/receiver/proxy/request/effect associations, async lifetime and inherited-map/backing provenance or containment | K269 assigns explicitly separate required C3–C6 cells before source/acquisition or no-contact credit; a detached recipient is not excluded. |
| U5 independent calibration | Actual per-family/variant direct/child/proxy/descriptor controls, ready/association/drop/filter/attach/termination controls and original frozen results | K269 assigns authoring, capability assessment and calibrated actual pure execution only after the reviewed mechanism and authorized scope; missing cells stay live before final measurement. |
| U6 topology and final stability | Protected/out-and-back pure controls and exact operation outcomes; actual affected input/collector/runtime closure and final unchanged-candidate requalification | K269 assigns policy specimens and final affected requalification/independent audit after review repairs/last edits, before k244 closes or k245 consumes evidence. Hidden physical ancestry is not demanded or inferred. |

K278 reconciles this whole boundary and k273's mandatory review before k269 consumes it.
K269 must represent these exact owners as live work ahead of their first execution/credit
consumer, retain a distinct final requalification/closing owner, and preserve every original
k244 obligation. An owner or a source pin is not a qualified identity. No unavailable cell
can be rewritten as inapplicable solely to close k244/k242.

The recommendation is to preserve the unprivileged selection and progress the unaffected
pure work. If a stronger arrangement is pursued, **first** create concrete requirements
work before its consumer: choose retaining this unavailable boundary versus the precisely
specified root/entitlement/helper/VM arrangement; name its operator, complete coverage,
consent/signing/SIP and host/service effects, proposed calibration scope and trade-off.
Prefer a contained scratch-only candidate over blanket administrator tracing only if its
full inherited/proxy/read closure can be specified; neither is authorized now. Antony
retains that decision. A useful target/required copy is never dropped as the price of a
clean proof, and the existing product/native VM programme grants this tool no VM authority.

## Protected Data and out-and-back specimens

The [canonical choices](application-population-metadata-shape.md#authority-and-admission-choices)
and [descriptor ADR](../adr/filesystem-access-is-descriptor-relative.md) remain authoritative.
The contract's [complete topology table](application-reference-evidence.md#topology-and-the-inherited-component-rule)
is retained. These are authored operation/value expectations, not current topology evidence.

An ordinary synthetic `/System/Volumes/Data/Applications/A.app` passes both prefix tests
when its controlled identity/layout checks pass. A synthetic protected
`/System/Volumes/Data/Users/u/{Desktop,Documents,Downloads}/X.app`, directly or by an
admitted link, also passes syntax but refuses listing/content handles under the protected
rule. Preserve every raw occurrence and observed link/identity; mark its unperformed bytes
and associations unavailable. For `/System/Volumes/Data/private/Specimen.app`, a known or
unsettled consent-risk input refuses; Data spelling alone supplies neither denial nor consent.
No blanket Data exclusion, absent-copy inference or new useful-category loss follows.

For an admitted link whose text expands through `/Users/u` and then back into
`/Applications/A.app`, retain that exact text and the proposed operation sequence. Permit
only held search-only common ancestors used to enter an admitted prefix; refuse **before
the first outside lookup/open**, not after reaching the final in-scope name. Test an absolute
expansion and relative physical `..`, including lexical simplification that would erase the
outside step. C1/C2/C3/C5/C6 controls must also reject listing/read/proxy/identity/descriptor
bypass of those refusals; all specimens stay scratch or simulated, never real protected paths.

Mount-device changes remain observations, not a volume allowlist. Simulated firmlink/cryptex
redirects preserve returned identity/walk spelling without inventing readlink text or hidden
target ancestry. No component walk guarantees absence of opaque mounted-root contact or
an intervening move-and-restore. Full-boundary evidence must report what it can associate;
unknown handling stays unavailable without a current topology probe or changed permission.

## Verification and limits

The source tables were extracted without compiling/preprocessing the source. BSD and Mach
row/variant/slot sequences are compared item by item with the pinned complete files; RPC
routine/skip membership is checked independently of the first extraction. Changed or omitted
rows must fail that comparison. This establishes documentary enumeration only. API-document
digests record retrieved bytes; they cannot identify current frameworks or daemons.

Diagram rendering, browser inspection and repository link checks validate presentation.
No collector, syscall bypass, target, topology, protected-folder, initialization, native or
VM experiment is part of those checks. Complete whole-design review/earned integration and
all U1–U6 work remain required before actual instrument admission. The target pass is unused;
private eligibility is false, both product holds and every native pending duty remain.
