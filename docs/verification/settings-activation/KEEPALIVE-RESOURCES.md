# Keepalive resource admission and enforcement evidence

## Outcome and scope

The command owner now has a proposed [resource-admission
contract](../../specs/settings-keepalive-owner.md#resource-admission-boundary).
It requires enforcement before producer execution, separate ordinary/collection/
terminal allowances, and one retained writer authority. It supplies no numerical
profile, implemented limit or startup permission.

The [k108 integration](#review-integration) clarifies the install point, storage
obligations, charge point and test enabling points. Admission checks without
charging operation capacity. The commitment transition charges before directory
creation and publication. Launcher enforcement follows commitment and precedes
external execution. The physical storage arrangement remains a research obligation.

The inspected capture pipeline allocates frames and encoded PNG bytes before
the image file is written. A quota and a later PNG validator cannot alone meet
the accepted producer-resource requirement. Current XNU source supports an
address-space-limit candidate. It does not by itself qualify the installed
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
| [Frame and PNG work](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-vm/src/capture.rs#L55) | Capture obtains an owned copy while the connection retains its wire framebuffer. Encoding adds a cropped RGBA vector and a growing output vector. | Account for both frames, crop, output and encoder internals. The owned copy's size follows logical/physical selection and scale. No profile-specific admission appears here. |
| [Framebuffer allocation](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/framebuffer.rs#L24) | Nonzero dimensions and multiplication overflow are checked before allocation. | Arithmetic validity is not a useful workload limit. Logical and physical surfaces must be distinguished. |
| [Wire update](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/connection.rs#L415) | Raw rectangles allocate their payload before the framebuffer bounds check. ZRLE allocates from a 32-bit compressed-length field before decoding. Desktop resize creates another framebuffer. | A fixed starting display does not establish bounds for all allocation paths. Geometry checks must include resize and wire decoding. |
| [Koine backend](../../../scripts/vm-guest-exec.py) | The locked attempt writes raw streams directly to unique files. It calls the inspector after CLI completion. | This is the current failure/publication seam, not pre-producer enforcement. |
| [PNG inspector](../../../scripts/vm_capture_artifact.py) | Reads the complete encoded file, accumulates compressed IDAT, and decompresses using header-derived expected size. | Encoded data, chunk copies, compressed data and decoded storage can coexist. Streaming changes would still need their own buffer proof and cannot bound the earlier producer. |

For RGBA8, pixel storage is `4 × width × height`. The filtered decoded stream
is `(4 × width + 1) × height`. These formulas describe units, not selected caps.
Encoded PNG length requires its own bound. Neither a small retained image nor
the six-digit attempt ordinal establishes a useful peak or aggregate limit.

At scale 1, the [logical accessor](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/connection.rs#L247)
borrows the wire framebuffer, so `into_owned` clones it. At scale 2, that accessor
returns an owned downsample with one quarter of the wire pixel count.
Physical capture clones the full wire framebuffer at either scale.
The connection remains alive through encoding and file writing. Thus two frame
buffers coexist before counting crop, PNG output and wire-decoder work.

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
exceeds that limit. This check follows possible mapping establishment. It is
not a promise that no kernel work occurs.

The [exec path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exec.c#L1531)
sets the new map's size limit from the process limit.
The [map inheritance path](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/vm_map.c#L13737)
copies the size and data limits to the child map.
These are positive reasons to investigate inherited limits rather than declaring
all macOS memory limits ineffective.

The launcher has a separate installable-limit floor. The setter acts on
`current_map()`, and [map validation](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/vm_map.c#L22084)
rejects a limit below that map's current size. A pre-exec call in a forked Python
backend child therefore cannot choose a smaller limit than its inherited map.
This is a source-derived constraint, not a measured host footprint. K106 must
establish the install point, calling map size and useful producer allowance separately.

<!-- tc: depart synonym-rotation because launch evidence names child execution while start queue names a VM command -->
A minimal exec'd intermediary could change that floor but adds a process and
new launch/ownership evidence. An in-producer call changes the external dependency.
Neither option is selected. A limit that survives exec can still be unusable
because the earlier installer cannot set it.

The pinned [RLIMIT_DATA setter](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_resource.c#L1503)
also passes a limit to Mach VM. The [mapping check](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/vm_map.c#L3703)
compares it with whole-map size, unlike the manual's data-segment description.
The pinned [resource header](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/resource.h#L509)
aliases RLIMIT_RSS to RLIMIT_AS. The installed SDK header has the same alias.
The manual's RSS wording therefore supplies no independent hard-memory mechanism.

The inspected host reports macOS 27.0.1, build 26A434, Darwin 27.0.0.
No source-to-build correspondence or runtime enforcement test was established.
The source call in exec alone does not prove coverage of every loader, mapping,
child or external-service path. It does not establish useful startup limits.
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
| Unchanged transport with inherited limits and reserved/capped storage | Lowest transport-change cost. The backend installs limits under the owner's commitment. The owner retains writer and backend-process ownership. The caller owns the owner child. | Actual install point and launcher map floor, host enforcement, exec/child/service coverage, each resource unit, aggregate exposure and useful fit. |
| Explicit bounded producer | Geometry, wire lengths, decoder growth and output buffers can be checked at their owning allocation sites. | External dependency scope, complete implementation contract and qualification without changing required pixels, attempts or input. |
| Isolated execution environment | Could provide a separate aggregate resource boundary. | Supported topology and native-service coverage, actual reservation/enforcement, transfer costs and unchanged transport semantics. |
| Post-capture rejection or RSS polling alone | Detects some completed excess or observed pressure. | Rejected as sufficient enforcement: observation follows the work and cannot prevent its earlier allocation or write. |

The preferred candidate to investigate first is inherited enforcement because
it can preserve the transport. Preference is conditional, not mechanism approval.
Reject it if any required allocation/write unit escapes its established boundary
or if a useful workload cannot fit. A changed producer or isolation remains
design work. Neither is silently substituted.

The admission contract keeps queue policy separate from resource accounting.
Callers submit once. The owner owns the commitment decision and its resource
proof. Removing that owner would distribute reservation, failure and publication
knowledge across scenario and worker. Its interface remains small, but its
internal accounting and supervision costs are real.

## External evidence needed before numerical design

K106's survey must answer these questions for k107:

1. Which supported mechanism actually bounds allocations of the pinned producer
   on the intended host? Include loader, allocator, mappings, children and native
   OCR/service work. What does it exclude? Can inherited settings survive
   exec and every required route without relying on readback alone?
   At which process and execution phase can limits be installed? What is the
   backend or intermediary map size at that point on the intended host?
   Distinguish RLIMIT_DATA's source semantics and the RLIMIT_RSS alias from manual wording.
2. Where are exact dimension, wire-decoder, decoded, encoded and peak-buffer
   limits enforced? Can the unchanged transport meet each unit, or is an explicit
   producer boundary required? Trace handshake, resize and every accepted encoding.
   Include the retained wire frame and owned logical/physical capture copy at each scale.
3. What storage arrangement reserves and caps ordinary, collection and terminal
   work independently while retaining one logical root/writer/ordinal domain?
   Include metadata, temporary output, record growth and all partials.
   Place collection attempt directories in collection-backed storage and global
   ordinal/storage bindings in terminal-backed storage. Explain recovery of the
   single sequence after owner loss, without relying on a volatile ledger.
   The private backend consumes an assigned directory. The existing public
   root scan cannot allocate across separate backing objects.
   Account for every clean and failed lifecycle row and the final caller records.
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
caller. Each copy must match production except for declared substitutions. The correspondence check must reject any other difference. The points are those
already specified in the lifecycle and scheduling contracts. This settles the
choice carried by k100 and k104.

The chosen seam reaches internal races and exact clock boundaries while preserving
production interfaces. Its cost is auditing every test copy. A production injection
interface adds a maintenance obligation. External CLI/sleep controls alone leave
those internal races and exact deadlines unqualified. Neither alternative was chosen.
This approval does not qualify a resource mechanism or authorise a native experiment.

The resource-specific controls must exercise launcher refusal before invocation
and per-unit and aggregate admission. They must cover ordinary exhaustion with
protected capacity remaining, failed protected writes and unavailable holders.
Observe real records, exact invocation counts, unchanged originals/partials and
later-dispatch refusal. Each control must reject its corresponding mutant:

<!-- tc: depart synonym-rotation because launch means external execution while startup means owner readiness -->
- Charging after launch
- Refunding failed work
- Borrowing terminal capacity
- Truncating earlier files
- Accepting limit readback as capability proof.

### Resource control enabling points

The approved copied-module substitutions cover barriers and the continuous-clock
reader only. Existing external CLI/sleep controls remain available at their agreed
seam. They cannot prove a native resource bound or directly fail a launcher setup call.

| Required control | Enabling point and real work retained | Approval or dependency |
|---|---|---|
| Launcher refuses before external invocation | A real rejected setup/readback at the backend launcher, or a limit-call-result substitution in its audited copy. Observe zero CLI invocations and the real commitment/launch/terminal records. | K106 must identify a safe real mechanism control and any required native scope. A new limit-call substitution needs k107's explicit decision. |
| Per-unit/aggregate refusal and unstarted cancellation | Declared finite profile inputs, controlled CLI output and approved barriers around the real admission/commitment transition. Observe charges, cancellation/refusal records and invocation counts. | Existing seam applies to coordinator accounting. Mechanism enforcement still requires k106 evidence. No allocator substitution is approved. |
| Ordinary exhaustion preserves collection and terminal capacity | Real capped/reserved backing objects with collection directory creation and global ordinal recovery. Alternatively, substitute capacity/limit-call results in the audited owner/backend copies. | Real objects depend on k106 and applicable experiment scope. Substitutions require k107 approval and prove accounting only. |
| Protected writes themselves fail | A real failed protected-object write, or a write-result substitution at the corresponding owner, backend or caller write in its audited copy. Retain real failure propagation and unavailable outcomes. | Barriers and clocks cannot enable this row. A new write-result substitution needs k107 approval. Real failure controls need an established mechanism and appropriate scope. |
| Holder remains unavailable | Controlled CLI child retains its inherited descriptor. Approved barriers and clock values place loss/expiry around real ownership and containment. Observe unresolved containment and no bypass. | Existing controlled-process seam applies. It does not reproduce kernel uninterruptibility or guarantee eventual release. |

K107 must choose between real mechanism controls and additional audited
substitutions where the current seam cannot trigger the defect. Real controls
depend on mechanism availability and safe qualification scope. Substitutions add
copy-audit cost and qualify failure handling only. Neither choice can replace
native enforcement evidence, and no additional substitution is approved here.

The tests must also reject charging at pending admission, charging cancelled pending
captures, or inventing installed-limit facts in commitment records. Terminal
record costs still apply to refused and cancelled submissions.
These are proposed tests of the future real coordinator. No native bound or
coordinator behaviour was tested in this design session.

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
returned unrelated outgoing edges. Those contribute no evidence.

K105 reported Koine generation 2026-10-30T12:10:34Z here and
2026-10-30T12:26:51Z in its review handoff. Its receipt does not establish which
generation supported each discovery. Neither timestamp is a verified historical
provenance claim. K105 reported direct source reads covering
the relied-on backend/validator, common-library and scenario parse gaps,
click-library gap, Bats setup/control source and diagram source.

TestAnyware's graph generation was 2026-10-29T07:11:24Z. The exact historical
source reads above, rather than current graph offsets, establish its claims.

Coverage is best-effort, not an exhaustive allocation audit.

K109 rechecked the backend and inspector with Tier 2 graph evidence at generation
2026-10-30T12:26:51Z. Their metadata matched, and the inspector's inbound trace
identified `run_locked`. Direct reads covered the changed documents and the
resource diagram's complete recorded parse gap. Pinned source reads establish
the external-source claims independently of current graph offsets.

The source/API assessment establishes the admission design's open boundary.
The [verification receipt](ordering-keepalive-resources/verification.json)
records document-link and browser checks, which establish only delivery of that
design. The documentation task retains the two existing missing archive targets
in context-initial-inputs. No new missing target was reported.

## Review integration

K109 grades the findings from k108's commit `780b4ab8` against k105 at `04c84236`.
The review's supported items remain supported, with the limits stated above.
The following changes affect the admission contract and research questions only.

| Finding | Classification and reason | Disposition |
|---|---|---|
| P2-1: launcher map floor | Real issue. The pinned setter checks the calling map before producer exec. Inheritance alone does not establish an installable useful limit. | Name the floor, install point, DATA check and RSS alias. K106 retains host correspondence and footprint qualification. |
| P2-2: storage arrangement and record costs | Unclear contract. Collection directories and clean lifecycle records lacked explicit allowance ownership. | Require collection-backed directories and terminal-backed global bindings/history. K106 must establish physical separation and recovery. The proposed private backend already receives its directory without rescanning, so the review's current-scanner example is a constraint, not proof of impossibility. |
| P2-3: charge point | Unclear contract. Admission and commitment are distinct scheduling events. | Admission checks without an operation charge. The commitment transition charges before directory creation/publication. Resource refusal has its own submission event. Pending cancellation costs terminal records only. |
| P2-4: resource control enabling points | Real issue. Approved barriers and a clock cannot directly produce limit-call or protected-write failure. | Name each enabling point above. K107 owns any new substitution choice and its costs. No approval or native experiment is inferred. |
| P3-1: concurrent frames | Real issue. The connection retains its wire frame while capture owns a copy or downsample. | Name both buffers and scale/physical selection in the source table and k106's allocation trace. |
| P3-2: premature installed-limit facts | Real issue. Commitment precedes backend creation and limit setup. | Put declarations and charges in commitment, actual setup/readback in later launch observations, and settlement in terminal disposition. |
| P3-3: caption ordering and missing refusal | Real issue. Enforcement follows commitment and can refuse before CLI execution. | Separate admission, charging and launcher setup in the view. Add launcher refusal and reconcile both captions. |
| P3-4: caller ownership | Real issue. The reviewed owner holds writer authority and owns backend children. | State the retained ownership in the candidate row. The caller owns only the owner child. |
| P3-5: terms and provenance | Real issue. New terms lacked glossary entries, and the historical generation stamps disagree. | Define the terms and remove the unsupported historical precision. Preserve both reported stamps as unresolved history and record fresh coverage separately. |

These changes select no storage topology, numerical limit or external producer.
They require no new ADR. K106 and k107 retain mechanism and complete-design work,
including whole-design review before planning. Every original duty and runtime
hold above remains. No ancestor closes.

One narrow in-session reviewer traced cancellation, refusal and publication failure.
It found a real inconsistency in the scheduling section: expiry previously
cancelled all unstarted work without ordinals. That included an assigned,
charged attempt whose directory or commitment publication had stalled.
The wording now distinguishes expiry before assignment from expiry afterward.
The latter retains its ordinal, charge and partial evidence without resubmission.

This reconciles the existing retention rule and changes no deadline or mechanism.
No second reviewer ran. Whole-profile review remains required after k107.

The [integration receipt](ordering-keepalive-admission-integration/verification.json)
records this revision's documentation checks and source coverage. Historical
receipts remain unchanged and do not certify the edited documents.
