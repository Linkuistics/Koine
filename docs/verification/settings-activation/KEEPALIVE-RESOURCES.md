# Keepalive resource admission and enforcement evidence

## Outcome and scope

The command owner now has a proposed [resource-admission
contract](../../specs/settings-keepalive-owner.md#resource-admission-boundary).
It requires enforcement before producer execution, separate ordinary/collection/
terminal allowances, and one retained writer authority. It supplies no numerical
profile, implemented limit or startup permission.

The inspected capture pipeline allocates frames and encoded PNG bytes before
the image file is written. A quota and a later PNG validator cannot alone meet
the accepted producer-resource requirement. Current XNU source supports an
address-space-limit candidate; it does not by itself qualify the installed
host, every native service or useful execution under a chosen limit.

This is the admission slice of settings-keepalive-resources-k102. Independent
review and every earned integration precede external-enforcement research k106.
Complete-profile design k107 retains every original k102/k98/k96 criterion not
established by the reviewed slices. Whole-design review still precedes planning.
There is no source change, native experiment, storage mutation, VM or frozen subject.

## Producer and validator boundary

The TestAnyware source identity is
`65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03`, the existing v2.7.0 basis.
These are direct reads of that commit, not claims about an installed binary.

| Boundary | Observed work | Consequence |
|---|---|---|
| [Screen capture](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/screen.rs#L51) | Connect, acquire the full selected framebuffer, encode the crop, then write the PNG. Region cropping follows acquisition. | A small region does not bound prior frame allocation. A file-write guard acts after encoded bytes exist. |
| [Frame and PNG work](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-vm/src/capture.rs#L55) | Capture obtains an owned framebuffer. Encoding allocates a cropped RGBA vector and a growing output vector. | Account for concurrent frame/crop/output storage and encoder internals. No profile-specific admission appears at these allocation sites. |
| [Framebuffer allocation](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/framebuffer.rs#L24) | Nonzero dimensions and multiplication overflow are checked before allocation. | Arithmetic validity is not a useful workload limit. Logical and physical surfaces must be distinguished. |
| [Wire update](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/connection.rs#L415) | Raw rectangles allocate their payload before the framebuffer bounds check. ZRLE allocates from a 32-bit compressed-length field before decoding. Desktop resize creates another framebuffer. | A fixed starting display does not establish bounds for all allocation paths. Geometry checks must include resize and wire decoding. |
| [Koine backend](../../../scripts/vm-guest-exec.py) | The locked attempt writes raw streams directly to unique files. It calls the inspector after CLI completion. | This is the current failure/publication seam, not pre-producer enforcement. |
| [PNG inspector](../../../scripts/vm_capture_artifact.py) | Reads the complete encoded file, accumulates compressed IDAT, and decompresses using header-derived expected size. | Encoded data, chunk copies, compressed data and decoded storage can coexist. Streaming changes would still need their own buffer proof and cannot bound the earlier producer. |

For RGBA8, pixel storage is `4 × width × height`; the filtered decoded stream
is `(4 × width + 1) × height`. These formulas describe units, not selected caps.
Encoded PNG length requires its own bound. Neither a small retained image nor
the six-digit attempt ordinal establishes a useful peak or aggregate limit.

The shared capture function is also used by OCR. This assessment does not trace
all OCR/native-service, file-transfer or VM-start allocations. K106 must include
them where the complete owner profile relies on their resource coverage.

## Primary OS evidence and its limits

Apple's [setrlimit manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/setrlimit.2.html)
describes a per-file size limit and failed writes with SIGXFSZ. It describes
RLIMIT_DATA in terms of the data segment and RLIMIT_RSS as a reclamation
preference. That text alone does not establish a hard limit over all modern
allocation paths. The installed manual repeats those descriptions.

The inspected XNU revision is
`f6217f891ac0bb64f3d375211650a4c1ff8ca1ea`. Its
[resource setter](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_resource.c#L1647)
passes RLIMIT_AS to Mach VM and rejects a limit below existing map use.
Its [mapping path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/vm_map.c#L3677)
changes an otherwise successful mapping result to KERN_NO_SPACE when map size
exceeds that limit. This check follows possible mapping establishment; it is
not a promise that no kernel work occurs.
The [exec path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exec.c#L1531)
sets the new map's size limit from the process limit.
These are positive reasons to investigate inherited limits rather than declaring
all macOS memory limits ineffective.

The inspected host reports macOS 27.0.1, build 26A434, Darwin 27.0.0.
No source-to-build correspondence or runtime enforcement test was established.
The source call in exec alone does not prove every loader, mapping, child or
external-service path is covered, nor that a useful chosen limit permits startup.
An address-space ceiling is not an exact dimension, encoded-vector, RSS,
aggregate-process or total host-memory ceiling.

Apple's [APFS volume guide](https://support.apple.com/en-asia/guide/disk-utility/dskua9e6a110/mac)
distinguishes reserved capacity from a maximum allocation quota.
This supports investigating separate ordinary and protected storage allowances.
It does not establish a directory quota, reserve a particular record write,
bound native memory, or guarantee service after storage failure. No volume was
created or reconfigured.

## Alternatives and design consequence

| Candidate | What it can contribute | Evidence still needed |
|---|---|---|
| Unchanged transport with inherited limits and reserved/capped storage | Lowest transport-change cost; launcher owns limit setup while caller retains process and writer ownership. | Actual host enforcement, exec/child/service coverage, each required resource unit, aggregate exposure and useful fit. |
| Explicit bounded producer | Geometry, wire lengths, decoder growth and output buffers can be checked at their owning allocation sites. | External dependency scope, complete implementation contract and qualification without changing required pixels, attempts or input. |
| Isolated execution environment | Could provide a separate aggregate resource boundary. | Supported topology and native-service coverage, actual reservation/enforcement, transfer costs and unchanged transport semantics. |
| Post-capture rejection or RSS polling alone | Detects some completed excess or observed pressure. | Rejected as sufficient enforcement: observation follows the work and cannot prevent its earlier allocation or write. |

The preferred candidate to investigate first is inherited enforcement because
it can preserve the transport. Preference is conditional, not mechanism approval.
Reject it if any required allocation/write unit escapes its established boundary
or if a useful workload cannot fit. A changed producer or isolation remains
design work; neither is silently substituted.

The admission contract keeps queue policy separate from resource accounting.
Callers submit once; the owner owns the commitment decision and its resource
proof. Removing that owner would distribute reservation, failure and publication
knowledge across scenario and worker. Its interface remains small, but its
internal accounting and supervision costs are real.

## External evidence needed before numerical design

K106's survey must answer these questions for k107:

1. Which supported mechanism actually bounds allocations of the pinned producer
   on the intended host, including loader, allocator, mappings, children and any
   native OCR/service work? What does it exclude? Can inherited settings survive
   exec and every required route without relying on readback alone?
2. Where are exact dimension, wire-decoder, decoded, encoded and peak-buffer
   limits enforced? Can the unchanged transport meet each unit, or is an explicit
   producer boundary required? Trace handshake, resize and every accepted encoding.
3. What storage arrangement reserves and caps ordinary, collection and terminal
   work independently while retaining one logical root/writer/ordinal domain?
   Include metadata, temporary output, record growth and all partials.
4. How are process counts and service contributions bounded in aggregate?
   What remains unknown after owner loss or inherited-holder loss?
5. Which source facts are sufficient, and which require a separately scoped
   capability experiment? Give the exact question and failure consequence.
   Never use E/A or the closed causal slots as qualification budgets.

These questions are deliberately prior to selecting numbers. A return from
setrlimit, an observed RSS peak, a free-space reading or one successful native
image cannot answer them alone.

## Test seam and later controls

On 2026-10-31 Antony answered **"approved"** to test-only phase barriers and a
replaceable continuous-clock reader in audited copies of the owner, backend and
caller. Each copy must match production except for declared substitutions;
the correspondence check must reject any other difference. The points are those
already specified in the lifecycle and scheduling contracts. This settles the
choice carried by k100 and k104.

The chosen seam reaches internal races and exact clock boundaries while preserving
production interfaces. Its cost is auditing every test copy. A production injection
interface adds a maintenance obligation; external CLI/sleep controls alone leave
those internal races and exact deadlines unqualified. Neither alternative was chosen.
This approval does not qualify a resource mechanism or authorize a native experiment.

The resource-specific controls must exercise launcher refusal before invocation,
per-unit and aggregate admission, ordinary exhaustion with protected capacity
remaining, failure of the protected writes themselves, and unavailable holders.
Observe real records, exact invocation counts, unchanged originals/partials and
later-dispatch refusal. Mutants that charge after launch, refund failed work,
borrow terminal capacity, truncate an earlier file or accept limit readback as
capability proof must fail the corresponding control.

These are proposed tests of the future real coordinator. No native bound or
coordinator behavior was tested in this design session.

## Complete original duties

The [original-duty comparison](KEEPALIVE-DESIGN.md#original-duties-and-handoff)
remains binding. This slice discharges no downstream implementation or runtime duty.

| Owner | Remaining work |
|---|---|
| K102, k98 and k96 through k107 | Every original complete-profile criterion: numeric useful workload, all schemas, complete finite caller and containment, controls, protocol/observation/diagram reconciliation, independent whole-design review and planning. |
| K89 | Every file, environment, lifecycle and collection helper. |
| K81 | Every exec and one-shot consequence, including defaults, launch/reopen, installed inventory and clean restart plus changed boot. |
| K76 | Complete root/helper adoption, statuses, INT/TERM/HUP and both held-pointer cases. |
| K67 | Positive setup, original-list title audit and liveness/process outcomes. |
| K62 | Exact final E/A prefix through TextEdit quit before resize and whole-duty reconciliation. |
| K57 | Finite caller, private original/partial retention, untouched collection and exact-clone containment with independent inventory. |
| K54 | Readiness and actual signed/all-input/completed-golden freeze before runtime. |

K107 must reconcile the retained 600-second start queue, later boot work and the
120-second proposed lifecycle allowance. Post-start upload also needs actual
byte/work accounting and honest connection history. No timing arithmetic proves
a safe VNC idle interval. Admission/operation numbers remain proposed, not silently
revised by this report.

Private roots, snapshot-tree and empty-AXValue limits, OCR substring early stop,
held-frame fallback, first-failure eligibility, both held-pointer cases and
untouched observer/window/screenshot order remain binding. Historical evidence,
caps and held causal slots stay unchanged. No ancestor closes.

## Evidence discipline

Tier 2 discovery located the inspector and its backend caller. The graph also
returned unrelated outgoing edges; those contribute no evidence.
Koine coverage generation was 2026-10-30T12:10:34Z. Direct source reads covered
the relied-on backend/validator, common-library and scenario parse gaps,
click-library gap, Bats setup/control source and diagram source.
TestAnyware's graph generation was 2026-10-29T07:11:24Z; the exact historical
source reads above, rather than current graph offsets, establish its claims.
Coverage is best-effort, not an exhaustive allocation audit.

The source/API assessment establishes the admission design's open boundary.
The [verification receipt](ordering-keepalive-resources/verification.json)
records document-link and browser checks, which establish only delivery of that
design. The documentation task retains the two existing missing archive targets
in context-initial-inputs; no new missing target was reported.
