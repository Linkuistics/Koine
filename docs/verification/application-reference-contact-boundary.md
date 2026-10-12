# Application reference contact boundary

The [contact contract](application-reference-evidence.md#contact-observation-outside-the-producer)
requires named bounded evidence for the retained pure invocation under Antony's
[selected contact limits](application-population-metadata-shape.md#authority-and-admission-choices).
C1–C8 retain the contact classification; they are not a promise to observe or prevent
every effect. Documentary sources, table extraction and presentation checks cannot supply
collector availability, runtime identity, installed-query/contents evidence or no-contact credit.
The [whole-producer handoff](application-reference-evidence.md#whole-producer-obligation-comparison)
requires complete review/integration before construction planning and actual qualification
before admission; no partial repair is a construction handoff.

The canonical selected clauses and original-obligation comparison own the bounded-contact,
closed pre-lookup and incomplete-evidence amendments. Missing current-service, proxy,
initial-right and mapping correspondence stays unknown, never full no-contact proof.
[Chartered independent acceptance](application-reference-evidence.md#chartered-independent-acceptance)
follows inspection-only review/earned integration; the
[independent release supervisor](application-reference-evidence.md#independent-live-release-and-role-selection)
keeps qualification disarmed, including after receipt publication. Actual retained role/
entry/armed-state refusals qualify only through SCRATCH controls; no test selects LIVE.
These obligations waive none of B1–B8's required claims or accepted-unknown limits and
preserve every other selected clause. Changing construction/evidence observations belong
in the separate [current report](application-reference-input-partition.md#current-construction-and-evidence-report),
which the measured chain must not consume. This companion binds its whole bytes.

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
| [Mach RPC declarations](reference-contact-inventory/mig-routines.tsv) | Every routine/simpleroutine/skip declaration outside comments in mach_vm.defs, mach_port.defs and task.defs, including names selected after a multiline declaration by conditional branches. Each row retains declaration/name source lines, logical name, exact name expression and branch context. These selected interfaces are not all kernel RPCs or user-space services. Compiled message IDs/configuration applicability remain unestablished. |
| [Published API basis](reference-contact-inventory/api-basis.tsv) | Named Apple API documents, retrieval URLs/date and exact retrieved JSON digests. Documentation identities support the route/privilege facts below, not current ABI, service names, image identity or a frozen runtime expectation. The upstream JSON is mutable; re-acquisition must match its digest or become an independently reviewed change. |

Enumeration preserves documentary facts, not a semantic exclusion list or a current
kernel/service completeness gate. The independent inventory retains every row and branch,
then associates relevant rows with named operations/controls or the accepted unknown
current-correspondence class. Every claimed actual route needs its own independently
supported correspondence; no source name, placeholder, skip or producer call graph
supplies it. Rows outside a named claim remain documentary candidates with unknown
current applicability, not proven harmless/inapplicable. Table counts are diagnostics.

| Whole-byte input | Selected binding and claim limit |
| --- | --- |
| source-pins.tsv and every pinned whole source | Preserve exact source/revision/hash/URL tuples and original objects; no current-kernel or installed-provider identity follows. |
| bsd-declarations.tsv | Preserve every slot, source line, name and conditional branch; disposition requires named-claim review, with unobserved current correspondence explicitly accepted unknown. |
| mach-traps.tsv | Preserve every trap/variant/placeholder separately from BSD; the same bounded disposition applies, without installed-probe inference. |
| mig-routines.tsv | Preserve every declaration/name line, logical name, complete macro expression, branch and skip; no compiled message ID/configuration is inferred. |
| api-basis.tsv and every retrieved whole JSON object | Preserve all retrieval identities/digests/locators; published API/privilege facts supply documentary basis only. Unobserved current image/service correspondence is accepted unknown. |

Both companions, all five complete tables, original documentary objects and separately
required runtime/format bases remain accepted full-byte inputs. Nothing is sliced into
an unchecked reporting appendix. A changed disposition is a reviewed normative change
requiring affected qualification, not retrospective removal of a failed control.

The probe basis is the pinned [systrace source](https://github.com/apple-oss-distributions/xnu/blob/ac9718fb1af618d5ce8678d0dc6e8a58f252216f/bsd/dev/dtrace/systrace.c):
it constructs entry/return probes from BSD `syscallnames` and separately from Mach
`mach_syscall_name_table`, registering **syscall** and **mach_trap** providers. Published
declaration names are not guessed installed probe names. Required provider/probe mappings,
enabled configuration, readable operands and current restrictions require independent
establishment before a named claim can credit them. Adding the Mach provider is no proxy-causality certificate.

`declared_name` is the logical inner routine name; `declaration_expression` retains the
source's complete wrapper expression. The pinned mach_vm.defs/task.defs macro definitions
can add `_kernelrpc_`, `_external` or `_mig` according to build configuration, with a
separate sandbox suffix rule. Branch context and the two source coordinates preserve
alternatives without selecting a configuration. Neither the logical name nor a wrapper
token alone identifies a compiled routine, message ID or installed probe.

## Required contact families

Contact includes **issuing** a forbidden request, even if it errors, returns nothing,
is later cancelled or is refused by the recipient. A source/index query is contact at
submission, not only when a file is opened. Distinguish allowed task/runtime-image
reads from application/source inspection using independently approved object/operation
associations; a blanket ban on every /System read would also misclassify the runtime.
K277 owns that actual read closure. An allowlisted loaded image grants no permission
to call its query, resource, coordination or proxy facilities.

The C table enumerates contact candidates and the association needed **if that route is
claimed observed/prevented**. It is not an admission requirement to establish every
association. The B table selects required bounded claims; the U table records the
accepted unobserved remainder without treating it as harmless or inapplicable.

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

The independent inventory binds each claim to its exact operation/object, retained
image/entry, expectation/basis, evidence origin, Q/P/A stage and missing coverage.
Use the [operation-credit contract](application-reference-packaging-runtime.md#operation-and-credit-map).
The following B coordinates select bounded claims within the C families, rather than
asserting full-family coverage. Their required controls cannot be waived as unknown.

| Claim / family | Required named evidence | Explicit accepted unknown beyond that evidence |
| --- | --- | --- |
| B1 / C1 | Independently authored raw/path/link policy expectations; actual scratch held search-only open/stat/readlink calls, flags and request order; direct/miswired entry refusals | Unobserved alternate native/startup lookup and hidden redirect/current-TCC effects; no universal no-lookup claim |
| B2 / C2 | Actual scratch root/named-held identity, no-follow type/direct inventory/alias controls and complete independent raw-coordinate comparisons | Identity-only/bulk/opaque operations not observed by those seams and their current correspondence |
| B3 / C3 | Actual emitter pipe/descriptor I/O, fd-3 transfer, declared descriptor closure/reuse/short-read/drain/reap tests with retained operands/results and known-peer identities | Unenumerated inherited/transferred rights/fds, detached or async effects outside the named programme |
| B4 / C4 | Independent immutable byte/tree expectations and review of declared image/mapping operations; any actually available narrow backing/range observation identifies only that mapping | Complete initial VM/right/backing provenance, plain loads and opaque remap/shared/proxy effects; source review proves no absence |
| B5 / C5 | Exact fixed exec/query intents mapped to a held scratch emitter; source review of admitted entry/native API plan; known synthetic service-request refusal controls | Actual framework/current-service transports/getters/index behavior and delegated effects; scratch services never qualify real endpoints |
| B6 / C6 | Actual scratch socketpair/channel framing, nonce/domain/peer/image checks and isolated constructed transfer/proxy refusal controls for named endpoints | Complete Mach/XPC/service/right inventory and detached causal-proxy correspondence; no full IPC certificate |
| B7 / C7 | Actual scratch authority/export/write/rename/flush and prohibited-operation/refusal tests; named UID/build/random calls use their own independent native expectations | Unobserved multiplexed/device/topology/native side effects; no mount/index/registration or protected-target test is authorized |
| B8 / C8 | Exact retained request/Task/script/CLI/launcher/checker/parser/domain tests, known process/image identities, start/death/EOF/true-return and before/after freeze evidence | Complete opaque constructor/loader/thread/service/proxy/initial-right/map closure beyond named observations |

Independently authored values/bytes/associations establish their computed facts; source
review establishes reviewed intent/reach, never actual absence of native contact. Actual
unprivileged scratch adapters establish only their performed calls and objects. Available
bounded observations may add a named claim with original evidence and its scope; absence
of such optional observations grants no clean bit and is not itself a failed required
control. No mechanism survey/probe or speculative exhaustive programme is required.

For a required coordinate return **observed allowed**, **observed forbidden attempt**,
**independently established prevented attempt**, or **unavailable**, with original evidence
and reason. A separately recorded **accepted unknown** names the canonical amendment and
unobserved class; it is no success or inapplicability. Required failed/missing/stale Q
mechanics, expectations, actual identities or controls block Q; fresh P facts block
before intent; failed A evidence prevents complete publication. Only the unknowns named
above may remain without a blanket contact gate. Known defects/forbidden attempts require
repair before the affected consumer, never risk relabelling.

The commissioned checker and the required named startup controls precede Task/loader
startup. Every observation states its interval, process/image/object/descriptor/right/map
association, operands/results, loss/filter/readiness and termination evidence as applicable.
A post-gate trace cannot describe earlier startup; a child-only record cannot describe
a detached proxy. Missing coverage retains the explicit accepted risk that forbidden
native/startup/inherited/proxy contact could occur undetected. Forbidden contact remains
forbidden. Pre-effect prevention credit requires independent evidence for that exact
route; a denied live request remains an issued request. No full no-contact result follows.

## Per-family independent controls

Every required named B1–B8 operation/variant has its own positive and isolating cells;
one open sentinel cannot stand for a different claimed noncancel, identity, async,
mapping or Mach route. The following C-family bypass inventory is retained in full.
The independent required inventory identifies which exact scratch/entry/native controls
are mandatory and which rows only delimit accepted unobserved contact classes; it cannot
delete a previously required control or claim an unavailable variant was tested.
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

For **each required named observation/control**, independently perturb the applicable
six dimensions: (1) not-ready
or disabled release; (2) wrong process/object/descriptor/map/right/endpoint association;
(3) induced event/operand/output loss or overflow; (4) wrong filter/provider/variant;
(5) late attach or an uncovered startup/exec interval; (6) early collector/child/proxy
termination, missing drain or reap. Required evidence must identify the intended cell as
forbidden/prevented or unavailable. No events under a disabled/wrong filter is not a pass.
Readiness includes the providers/endpoints/declared initial state the claim actually uses,
not just a live PID. Full unobserved initial-right/map/proxy coverage remains accepted
unknown; it cannot stand in for a required known fd/channel/image identity. Unknown
applicability or an unavailable way to induce/observe a required named control stays a
blocking missing cell. Original control traces and full inputs are separately owned/frozen;
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
Named byte/value/association, actual scratch-adapter, retained-entry and native-operation
credit is possible only with its required B/Q evidence, followed by fresh required P
facts and independent release. It needs no complete mechanism for accepted unknowns.
An apparently clean partial trace supplies neither full no-contact credit nor admission
on its own. Do not schedule another U2 leaf to reproduce this unavailable conclusion.

| Unavailable coordinate | Exact missing identities/evidence | Owner and placement |
| --- | --- | --- |
| U1 current independent universe | Full current kernel/service/probe/opaque-command correspondence is accepted unknown. Exact current UID/build/API/loaded-image identities required by O05–O07/O15/O21/O23/O25 remain separate blockers; pins cannot supply them. | K269 assigns whole-row documentary disposition and required named API/image expectations before their Q credit/P use. No exhaustive current-universe survey or target/probe acquisition is implied. |
| U2 full mechanism | Full unprivileged C1–C8 prevention/observation is unestablished and explicitly accepted unknown; no complete no-contact proof. B1–B8 required evidence remains mandatory. | After whole-k282 review/integration, k269 assigns named scratch/native/entry/read controls and any claimed bounded observation, not impossible-mechanism repetition. A stronger arrangement first requires Antony's concrete decision. |
| U3 launch and capability state | Complete hidden startup/thread/initial-right/map closure is accepted unknown. Known launcher/Task/interpreter/CLI/verifier/checker images, process/peer/channel/cwd and declared fd identities/actions are required Q/P facts. | K269 assigns exact retained-entry/startup/known-descriptor controls before their Q credit and fresh P channel/image checks before intent; no opaque-state completeness prerequisite. |
| U4 mediated and memory effects | Complete service/proxy/async/inherited-map/backing provenance stays accepted unknown. Required named scratch endpoints, transfers, refusal controls and any claimed narrow mapping must have exact associations. | K269 assigns B3/B4/B5/B6 named cells and their limits before credit; no synthetic endpoint is credited as a real daemon or universal detached-proxy result. |
| U5 independent controls | Every required named B/Q control, intended negative, positive, readiness/association/loss/filter/startup/termination check and original frozen result remains a blocker when missing/failed. Universal per-route calibration outside those claims is not selected. | K269 assigns independent authoring/adjudication and actual permitted scratch/native execution before unchanged-candidate measurement. Missing required evidence is live work, never accepted unknown. |
| U6 topology and final stability | Exact pre-lookup policy/raw/link/out-and-back controls and required final input/tool/image equality remain blockers. Hidden physical ancestry, current TCC and opaque contact remain accepted unknown. | K269 assigns the reviewed policy and final affected requalification/independent audit after last edits; named failures block k244 close/k245. No protected/topology probe or historical certificate. |

K287 reconciles this whole boundary with every original obligation and schedules the
mandatory whole-k282 review/integration before k269 consumes it.
K269 must represent these exact owners as live work ahead of their first execution/credit
consumer, retain a distinct final requalification/closing owner, and preserve every original
k244 obligation. An owner or a source pin is not a qualified identity. No unavailable cell
can be rewritten as inapplicable solely to close k244/k242.

The canonical requirements select the stated bounded contact limit with independent authored
expectations, source review, exact task/parser/domain and actual scratch controls, and
any actually available bounded observations. Unobserved proxy/initial-capability/mapping
and current-service risks are accepted explicitly; they remain unknown, never clean.
The [canonical pre-lookup rule](application-population-metadata-shape.md#authority-and-admission-choices)
refuses known/unsettled or unlisted risk before lookup, with explicit Data/protected/
out-and-back and separate authority/export expectations. A refused required copy has
an accepted truthful incomplete boundary, not useful loss or finite-subject credit.
The B/U tables and pre-lookup plan apply that selection without a blanket completeness gate.
Complete release/acceptance/input/whole reconciliation and required whole review
precede construction; no partial child can be consumed.
Any stronger candidate must name operator, full and missing coverage, consent/signing/SIP/
helper/VM and host/service effects and calibrated scope. Root tracing alone is insufficient.
Antony retains the decision; no deeper repeated unavailable survey substitutes for it.
Required useful copies and all original obligations remain, and the existing product/native
VM programme grants this tool no VM authority.

## Protected Data and out-and-back specimens

The [canonical choices](application-population-metadata-shape.md#authority-and-admission-choices)
and [descriptor ADR](../adr/filesystem-access-is-descriptor-relative.md) remain authoritative.
The contract's [complete topology table](application-reference-evidence.md#topology-and-the-inherited-component-rule)
is retained. These are authored operation/value expectations, not current topology evidence.

The contract's [pre-lookup plan](application-reference-evidence.md#topology-and-the-inherited-component-rule)
enumerates target classes T1–T7, search-only ancestor A1 and distinct authority/export
A2/A3 entries. Each actual entry/operation must be independently reviewed/fixed before
lookup. Ordinary direct and observed-link Data/Applications and Data/Library positives
need distinct entries, complete operation sequences and controlled identity/layout checks.
Data/private and every Data/Users home refuse before their first lookup, as do /private,
/Users and the named Desktop/Documents/Downloads/Containers/Group Containers/Mail/Messages/
Mobile Documents components. Whole raw spelling classification precedes target ancestor
entry: a directly rejected slot performs no target filesystem operation. After an admitted
link's exact `readlinkat`, classify the expansion before its next lookup; never walk into
the refused component first. Preserve every raw slot, observed link text, performed prefix
and precise unperformed bytes/associations. No blanket Data exclusion or absence follows.

For an admitted link whose text expands through `/Users/u` and then back into
`/Applications/A.app`, retain that exact text and the proposed operation sequence. Permit
only A1's held search-only common ancestors used to enter an admitted prefix; refuse **before
the first outside lookup/open**, not after reaching the final in-scope name. Test an absolute
expansion and relative physical `..`, including lexical simplification that would erase the
outside step. B1/B2/B3/B5/B6's required named scratch controls reject listing/read/proxy/
identity/descriptor requests around those refusals; success cannot prove unobserved native
bypasses absent. All specimens stay scratch or simulated, never real protected paths.

Mount-device changes remain observations, not a volume allowlist. Simulated firmlink/cryptex
redirects preserve returned identity/walk spelling without inventing readlink text or hidden
target ancestry. No component walk guarantees absence of opaque mounted-root contact or
an intervening move-and-restore. Bounded evidence reports only its actual associations;
hidden ancestry/current TCC stays accepted unknown. No current topology probe or changed
permission follows. A refused required copy retains its raw slot and missing work through
k245/k246/k247 and whole review, with a truthful failed/incomplete package/subject boundary;
no complete subject, useful loss, private eligibility, omission or second attempt follows.

## Verification and limits

Compare the source tables without compiling/preprocessing or silently selecting a branch.
BSD and Mach row/variant/slot sequences require item-by-item comparison with pinned complete files; RPC
routine/skip membership, logical names, exact expressions and conditional/name coordinates
are checked against the complete pinned sources and separately authored wrapped/branched
name expectations. The original wrapper-token/omitted-branch table and deliberate name,
expression, context and branch-omission mutations must fail the comparison. This establishes
documentary enumeration only. API-document
digests record retrieved bytes; they cannot identify current frameworks or daemons.

Diagram rendering, browser inspection and repository link checks validate presentation.
No collector, syscall bypass, target, topology, protected-folder, initialization, native or
VM experiment is part of those checks. Complete whole-design review/earned integration and
all required B/Q/P evidence and U5/U6 controls remain required before actual instrument
admission; U1–U4 accepted unknowns stay explicitly scoped, never passed. Instrument closure
supplies no finite-subject/private/product/native qualification: retain each existing hold
until its own required evidence qualifies it. Reporting cannot spend the target pass.
